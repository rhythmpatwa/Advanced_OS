
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 53 0b 00 00       	call   800b90 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 89 0e 00 00       	call   800ed2 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 4e 0b 00 00       	call   800baf <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 25 0b 00 00       	call   800baf <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 08 40 80 00       	mov    0x804008,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 08 40 80 00       	mov    %eax,0x804008
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 e0 26 80 00       	push   $0x8026e0
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 08 27 80 00       	push   $0x802708
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 1b 27 80 00       	push   $0x80271b
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000f8:	e8 93 0a 00 00       	call   800b90 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 97 11 00 00       	call   8012d5 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 07 0a 00 00       	call   800b4f <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 30 0a 00 00       	call   800b90 <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 44 27 80 00       	push   $0x802744
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 37 27 80 00 	movl   $0x802737,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 4f 09 00 00       	call   800b12 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 54 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 f4 08 00 00       	call   800b12 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 b2 21 00 00       	call   802440 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 9f 22 00 00       	call   802570 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 67 27 80 00 	movsbl 0x802767(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ec:	83 fa 01             	cmp    $0x1,%edx
  8002ef:	7e 0e                	jle    8002ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	8b 52 04             	mov    0x4(%edx),%edx
  8002fd:	eb 22                	jmp    800321 <getuint+0x38>
	else if (lflag)
  8002ff:	85 d2                	test   %edx,%edx
  800301:	74 10                	je     800313 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	eb 0e                	jmp    800321 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8d 4a 01             	lea    0x1(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	88 02                	mov    %al,(%edx)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 75 08             	mov    0x8(%ebp),%esi
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036f:	eb 12                	jmp    800383 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	85 c0                	test   %eax,%eax
  800373:	0f 84 a9 03 00 00    	je     800722 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	ff d6                	call   *%esi
  800380:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800383:	83 c7 01             	add    $0x1,%edi
  800386:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038a:	83 f8 25             	cmp    $0x25,%eax
  80038d:	75 e2                	jne    800371 <vprintfmt+0x14>
  80038f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800393:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 07                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8d 47 01             	lea    0x1(%edi),%eax
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	0f b6 07             	movzbl (%edi),%eax
  8003bf:	0f b6 c8             	movzbl %al,%ecx
  8003c2:	83 e8 23             	sub    $0x23,%eax
  8003c5:	3c 55                	cmp    $0x55,%al
  8003c7:	0f 87 3a 03 00 00    	ja     800707 <vprintfmt+0x3aa>
  8003cd:	0f b6 c0             	movzbl %al,%eax
  8003d0:	ff 24 85 a0 28 80 00 	jmp    *0x8028a0(,%eax,4)
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003de:	eb d6                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ee:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f8:	83 fa 09             	cmp    $0x9,%edx
  8003fb:	77 39                	ja     800436 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800400:	eb e9                	jmp    8003eb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 48 04             	lea    0x4(%eax),%ecx
  800408:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800413:	eb 27                	jmp    80043c <vprintfmt+0xdf>
  800415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800418:	85 c0                	test   %eax,%eax
  80041a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041f:	0f 49 c8             	cmovns %eax,%ecx
  800422:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800428:	eb 8c                	jmp    8003b6 <vprintfmt+0x59>
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800434:	eb 80                	jmp    8003b6 <vprintfmt+0x59>
  800436:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800439:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800440:	0f 89 70 ff ff ff    	jns    8003b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800446:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800453:	e9 5e ff ff ff       	jmp    8003b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800458:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045e:	e9 53 ff ff ff       	jmp    8003b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	ff 30                	pushl  (%eax)
  800472:	ff d6                	call   *%esi
			break;
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047a:	e9 04 ff ff ff       	jmp    800383 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	99                   	cltd   
  80048b:	31 d0                	xor    %edx,%eax
  80048d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048f:	83 f8 0f             	cmp    $0xf,%eax
  800492:	7f 0b                	jg     80049f <vprintfmt+0x142>
  800494:	8b 14 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 7f 27 80 00       	push   $0x80277f
  8004a5:	53                   	push   %ebx
  8004a6:	56                   	push   %esi
  8004a7:	e8 94 fe ff ff       	call   800340 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b2:	e9 cc fe ff ff       	jmp    800383 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b7:	52                   	push   %edx
  8004b8:	68 0d 2c 80 00       	push   $0x802c0d
  8004bd:	53                   	push   %ebx
  8004be:	56                   	push   %esi
  8004bf:	e8 7c fe ff ff       	call   800340 <printfmt>
  8004c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 b4 fe ff ff       	jmp    800383 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	b8 78 27 80 00       	mov    $0x802778,%eax
  8004e1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e8:	0f 8e 94 00 00 00    	jle    800582 <vprintfmt+0x225>
  8004ee:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f2:	0f 84 98 00 00 00    	je     800590 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8004fe:	57                   	push   %edi
  8004ff:	e8 a6 02 00 00       	call   8007aa <strnlen>
  800504:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800507:	29 c1                	sub    %eax,%ecx
  800509:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800513:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800516:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800519:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	eb 0f                	jmp    80052c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	ff 75 e0             	pushl  -0x20(%ebp)
  800524:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	83 ef 01             	sub    $0x1,%edi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	85 ff                	test   %edi,%edi
  80052e:	7f ed                	jg     80051d <vprintfmt+0x1c0>
  800530:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800533:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800536:	85 c9                	test   %ecx,%ecx
  800538:	b8 00 00 00 00       	mov    $0x0,%eax
  80053d:	0f 49 c1             	cmovns %ecx,%eax
  800540:	29 c1                	sub    %eax,%ecx
  800542:	89 75 08             	mov    %esi,0x8(%ebp)
  800545:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800548:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054b:	89 cb                	mov    %ecx,%ebx
  80054d:	eb 4d                	jmp    80059c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800553:	74 1b                	je     800570 <vprintfmt+0x213>
  800555:	0f be c0             	movsbl %al,%eax
  800558:	83 e8 20             	sub    $0x20,%eax
  80055b:	83 f8 5e             	cmp    $0x5e,%eax
  80055e:	76 10                	jbe    800570 <vprintfmt+0x213>
					putch('?', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	ff 75 0c             	pushl  0xc(%ebp)
  800566:	6a 3f                	push   $0x3f
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 0d                	jmp    80057d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	52                   	push   %edx
  800577:	ff 55 08             	call   *0x8(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	83 eb 01             	sub    $0x1,%ebx
  800580:	eb 1a                	jmp    80059c <vprintfmt+0x23f>
  800582:	89 75 08             	mov    %esi,0x8(%ebp)
  800585:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800588:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058e:	eb 0c                	jmp    80059c <vprintfmt+0x23f>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	83 c7 01             	add    $0x1,%edi
  80059f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a3:	0f be d0             	movsbl %al,%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	74 23                	je     8005cd <vprintfmt+0x270>
  8005aa:	85 f6                	test   %esi,%esi
  8005ac:	78 a1                	js     80054f <vprintfmt+0x1f2>
  8005ae:	83 ee 01             	sub    $0x1,%esi
  8005b1:	79 9c                	jns    80054f <vprintfmt+0x1f2>
  8005b3:	89 df                	mov    %ebx,%edi
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bb:	eb 18                	jmp    8005d5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	6a 20                	push   $0x20
  8005c3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c5:	83 ef 01             	sub    $0x1,%edi
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 08                	jmp    8005d5 <vprintfmt+0x278>
  8005cd:	89 df                	mov    %ebx,%edi
  8005cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	7f e4                	jg     8005bd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	e9 a2 fd ff ff       	jmp    800383 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e1:	83 fa 01             	cmp    $0x1,%edx
  8005e4:	7e 16                	jle    8005fc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 08             	lea    0x8(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 50 04             	mov    0x4(%eax),%edx
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fa:	eb 32                	jmp    80062e <vprintfmt+0x2d1>
	else if (lflag)
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	74 18                	je     800618 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	89 c1                	mov    %eax,%ecx
  800610:	c1 f9 1f             	sar    $0x1f,%ecx
  800613:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800616:	eb 16                	jmp    80062e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800626:	89 c1                	mov    %eax,%ecx
  800628:	c1 f9 1f             	sar    $0x1f,%ecx
  80062b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800631:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800639:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063d:	0f 89 90 00 00 00    	jns    8006d3 <vprintfmt+0x376>
				putch('-', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	6a 2d                	push   $0x2d
  800649:	ff d6                	call   *%esi
				num = -(long long) num;
  80064b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800651:	f7 d8                	neg    %eax
  800653:	83 d2 00             	adc    $0x0,%edx
  800656:	f7 da                	neg    %edx
  800658:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800660:	eb 71                	jmp    8006d3 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800662:	8d 45 14             	lea    0x14(%ebp),%eax
  800665:	e8 7f fc ff ff       	call   8002e9 <getuint>
			base = 10;
  80066a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066f:	eb 62                	jmp    8006d3 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 70 fc ff ff       	call   8002e9 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800680:	51                   	push   %ecx
  800681:	ff 75 e0             	pushl  -0x20(%ebp)
  800684:	6a 08                	push   $0x8
  800686:	52                   	push   %edx
  800687:	50                   	push   %eax
  800688:	89 da                	mov    %ebx,%edx
  80068a:	89 f0                	mov    %esi,%eax
  80068c:	e8 a9 fb ff ff       	call   80023a <printnum>
			break;
  800691:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800697:	e9 e7 fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 30                	push   $0x30
  8006a2:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a4:	83 c4 08             	add    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	6a 78                	push   $0x78
  8006aa:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 04             	lea    0x4(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006bc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006bf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006c4:	eb 0d                	jmp    8006d3 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c9:	e8 1b fc ff ff       	call   8002e9 <getuint>
			base = 16;
  8006ce:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d3:	83 ec 0c             	sub    $0xc,%esp
  8006d6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006da:	57                   	push   %edi
  8006db:	ff 75 e0             	pushl  -0x20(%ebp)
  8006de:	51                   	push   %ecx
  8006df:	52                   	push   %edx
  8006e0:	50                   	push   %eax
  8006e1:	89 da                	mov    %ebx,%edx
  8006e3:	89 f0                	mov    %esi,%eax
  8006e5:	e8 50 fb ff ff       	call   80023a <printnum>
			break;
  8006ea:	83 c4 20             	add    $0x20,%esp
  8006ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f0:	e9 8e fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	51                   	push   %ecx
  8006fa:	ff d6                	call   *%esi
			break;
  8006fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800702:	e9 7c fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	6a 25                	push   $0x25
  80070d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	eb 03                	jmp    800717 <vprintfmt+0x3ba>
  800714:	83 ef 01             	sub    $0x1,%edi
  800717:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80071b:	75 f7                	jne    800714 <vprintfmt+0x3b7>
  80071d:	e9 61 fc ff ff       	jmp    800383 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800722:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 18             	sub    $0x18,%esp
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800736:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800739:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800740:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800747:	85 c0                	test   %eax,%eax
  800749:	74 26                	je     800771 <vsnprintf+0x47>
  80074b:	85 d2                	test   %edx,%edx
  80074d:	7e 22                	jle    800771 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074f:	ff 75 14             	pushl  0x14(%ebp)
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	50                   	push   %eax
  800759:	68 23 03 80 00       	push   $0x800323
  80075e:	e8 fa fb ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800763:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800766:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076c:	83 c4 10             	add    $0x10,%esp
  80076f:	eb 05                	jmp    800776 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800781:	50                   	push   %eax
  800782:	ff 75 10             	pushl  0x10(%ebp)
  800785:	ff 75 0c             	pushl  0xc(%ebp)
  800788:	ff 75 08             	pushl  0x8(%ebp)
  80078b:	e8 9a ff ff ff       	call   80072a <vsnprintf>
	va_end(ap);

	return rc;
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800798:	b8 00 00 00 00       	mov    $0x0,%eax
  80079d:	eb 03                	jmp    8007a2 <strlen+0x10>
		n++;
  80079f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a6:	75 f7                	jne    80079f <strlen+0xd>
		n++;
	return n;
}
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b8:	eb 03                	jmp    8007bd <strnlen+0x13>
		n++;
  8007ba:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bd:	39 c2                	cmp    %eax,%edx
  8007bf:	74 08                	je     8007c9 <strnlen+0x1f>
  8007c1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007c5:	75 f3                	jne    8007ba <strnlen+0x10>
  8007c7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d5:	89 c2                	mov    %eax,%edx
  8007d7:	83 c2 01             	add    $0x1,%edx
  8007da:	83 c1 01             	add    $0x1,%ecx
  8007dd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e4:	84 db                	test   %bl,%bl
  8007e6:	75 ef                	jne    8007d7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e8:	5b                   	pop    %ebx
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f2:	53                   	push   %ebx
  8007f3:	e8 9a ff ff ff       	call   800792 <strlen>
  8007f8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007fb:	ff 75 0c             	pushl  0xc(%ebp)
  8007fe:	01 d8                	add    %ebx,%eax
  800800:	50                   	push   %eax
  800801:	e8 c5 ff ff ff       	call   8007cb <strcpy>
	return dst;
}
  800806:	89 d8                	mov    %ebx,%eax
  800808:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080b:	c9                   	leave  
  80080c:	c3                   	ret    

0080080d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	56                   	push   %esi
  800811:	53                   	push   %ebx
  800812:	8b 75 08             	mov    0x8(%ebp),%esi
  800815:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800818:	89 f3                	mov    %esi,%ebx
  80081a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081d:	89 f2                	mov    %esi,%edx
  80081f:	eb 0f                	jmp    800830 <strncpy+0x23>
		*dst++ = *src;
  800821:	83 c2 01             	add    $0x1,%edx
  800824:	0f b6 01             	movzbl (%ecx),%eax
  800827:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082a:	80 39 01             	cmpb   $0x1,(%ecx)
  80082d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800830:	39 da                	cmp    %ebx,%edx
  800832:	75 ed                	jne    800821 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800834:	89 f0                	mov    %esi,%eax
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 75 08             	mov    0x8(%ebp),%esi
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800845:	8b 55 10             	mov    0x10(%ebp),%edx
  800848:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084a:	85 d2                	test   %edx,%edx
  80084c:	74 21                	je     80086f <strlcpy+0x35>
  80084e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800852:	89 f2                	mov    %esi,%edx
  800854:	eb 09                	jmp    80085f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800856:	83 c2 01             	add    $0x1,%edx
  800859:	83 c1 01             	add    $0x1,%ecx
  80085c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80085f:	39 c2                	cmp    %eax,%edx
  800861:	74 09                	je     80086c <strlcpy+0x32>
  800863:	0f b6 19             	movzbl (%ecx),%ebx
  800866:	84 db                	test   %bl,%bl
  800868:	75 ec                	jne    800856 <strlcpy+0x1c>
  80086a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80086c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086f:	29 f0                	sub    %esi,%eax
}
  800871:	5b                   	pop    %ebx
  800872:	5e                   	pop    %esi
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087e:	eb 06                	jmp    800886 <strcmp+0x11>
		p++, q++;
  800880:	83 c1 01             	add    $0x1,%ecx
  800883:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800886:	0f b6 01             	movzbl (%ecx),%eax
  800889:	84 c0                	test   %al,%al
  80088b:	74 04                	je     800891 <strcmp+0x1c>
  80088d:	3a 02                	cmp    (%edx),%al
  80088f:	74 ef                	je     800880 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800891:	0f b6 c0             	movzbl %al,%eax
  800894:	0f b6 12             	movzbl (%edx),%edx
  800897:	29 d0                	sub    %edx,%eax
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a5:	89 c3                	mov    %eax,%ebx
  8008a7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008aa:	eb 06                	jmp    8008b2 <strncmp+0x17>
		n--, p++, q++;
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b2:	39 d8                	cmp    %ebx,%eax
  8008b4:	74 15                	je     8008cb <strncmp+0x30>
  8008b6:	0f b6 08             	movzbl (%eax),%ecx
  8008b9:	84 c9                	test   %cl,%cl
  8008bb:	74 04                	je     8008c1 <strncmp+0x26>
  8008bd:	3a 0a                	cmp    (%edx),%cl
  8008bf:	74 eb                	je     8008ac <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c1:	0f b6 00             	movzbl (%eax),%eax
  8008c4:	0f b6 12             	movzbl (%edx),%edx
  8008c7:	29 d0                	sub    %edx,%eax
  8008c9:	eb 05                	jmp    8008d0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008dd:	eb 07                	jmp    8008e6 <strchr+0x13>
		if (*s == c)
  8008df:	38 ca                	cmp    %cl,%dl
  8008e1:	74 0f                	je     8008f2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e3:	83 c0 01             	add    $0x1,%eax
  8008e6:	0f b6 10             	movzbl (%eax),%edx
  8008e9:	84 d2                	test   %dl,%dl
  8008eb:	75 f2                	jne    8008df <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fe:	eb 03                	jmp    800903 <strfind+0xf>
  800900:	83 c0 01             	add    $0x1,%eax
  800903:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 04                	je     80090e <strfind+0x1a>
  80090a:	84 d2                	test   %dl,%dl
  80090c:	75 f2                	jne    800900 <strfind+0xc>
			break;
	return (char *) s;
}
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	57                   	push   %edi
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	8b 7d 08             	mov    0x8(%ebp),%edi
  800919:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091c:	85 c9                	test   %ecx,%ecx
  80091e:	74 36                	je     800956 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800920:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800926:	75 28                	jne    800950 <memset+0x40>
  800928:	f6 c1 03             	test   $0x3,%cl
  80092b:	75 23                	jne    800950 <memset+0x40>
		c &= 0xFF;
  80092d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800931:	89 d3                	mov    %edx,%ebx
  800933:	c1 e3 08             	shl    $0x8,%ebx
  800936:	89 d6                	mov    %edx,%esi
  800938:	c1 e6 18             	shl    $0x18,%esi
  80093b:	89 d0                	mov    %edx,%eax
  80093d:	c1 e0 10             	shl    $0x10,%eax
  800940:	09 f0                	or     %esi,%eax
  800942:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800944:	89 d8                	mov    %ebx,%eax
  800946:	09 d0                	or     %edx,%eax
  800948:	c1 e9 02             	shr    $0x2,%ecx
  80094b:	fc                   	cld    
  80094c:	f3 ab                	rep stos %eax,%es:(%edi)
  80094e:	eb 06                	jmp    800956 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800950:	8b 45 0c             	mov    0xc(%ebp),%eax
  800953:	fc                   	cld    
  800954:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800956:	89 f8                	mov    %edi,%eax
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5f                   	pop    %edi
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	57                   	push   %edi
  800961:	56                   	push   %esi
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	8b 75 0c             	mov    0xc(%ebp),%esi
  800968:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096b:	39 c6                	cmp    %eax,%esi
  80096d:	73 35                	jae    8009a4 <memmove+0x47>
  80096f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800972:	39 d0                	cmp    %edx,%eax
  800974:	73 2e                	jae    8009a4 <memmove+0x47>
		s += n;
		d += n;
  800976:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800979:	89 d6                	mov    %edx,%esi
  80097b:	09 fe                	or     %edi,%esi
  80097d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800983:	75 13                	jne    800998 <memmove+0x3b>
  800985:	f6 c1 03             	test   $0x3,%cl
  800988:	75 0e                	jne    800998 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80098a:	83 ef 04             	sub    $0x4,%edi
  80098d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800990:	c1 e9 02             	shr    $0x2,%ecx
  800993:	fd                   	std    
  800994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800996:	eb 09                	jmp    8009a1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800998:	83 ef 01             	sub    $0x1,%edi
  80099b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80099e:	fd                   	std    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a1:	fc                   	cld    
  8009a2:	eb 1d                	jmp    8009c1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	89 f2                	mov    %esi,%edx
  8009a6:	09 c2                	or     %eax,%edx
  8009a8:	f6 c2 03             	test   $0x3,%dl
  8009ab:	75 0f                	jne    8009bc <memmove+0x5f>
  8009ad:	f6 c1 03             	test   $0x3,%cl
  8009b0:	75 0a                	jne    8009bc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009b2:	c1 e9 02             	shr    $0x2,%ecx
  8009b5:	89 c7                	mov    %eax,%edi
  8009b7:	fc                   	cld    
  8009b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ba:	eb 05                	jmp    8009c1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009bc:	89 c7                	mov    %eax,%edi
  8009be:	fc                   	cld    
  8009bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c1:	5e                   	pop    %esi
  8009c2:	5f                   	pop    %edi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c8:	ff 75 10             	pushl  0x10(%ebp)
  8009cb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ce:	ff 75 08             	pushl  0x8(%ebp)
  8009d1:	e8 87 ff ff ff       	call   80095d <memmove>
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e3:	89 c6                	mov    %eax,%esi
  8009e5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e8:	eb 1a                	jmp    800a04 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ea:	0f b6 08             	movzbl (%eax),%ecx
  8009ed:	0f b6 1a             	movzbl (%edx),%ebx
  8009f0:	38 d9                	cmp    %bl,%cl
  8009f2:	74 0a                	je     8009fe <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f4:	0f b6 c1             	movzbl %cl,%eax
  8009f7:	0f b6 db             	movzbl %bl,%ebx
  8009fa:	29 d8                	sub    %ebx,%eax
  8009fc:	eb 0f                	jmp    800a0d <memcmp+0x35>
		s1++, s2++;
  8009fe:	83 c0 01             	add    $0x1,%eax
  800a01:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a04:	39 f0                	cmp    %esi,%eax
  800a06:	75 e2                	jne    8009ea <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	53                   	push   %ebx
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a18:	89 c1                	mov    %eax,%ecx
  800a1a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a21:	eb 0a                	jmp    800a2d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a23:	0f b6 10             	movzbl (%eax),%edx
  800a26:	39 da                	cmp    %ebx,%edx
  800a28:	74 07                	je     800a31 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	39 c8                	cmp    %ecx,%eax
  800a2f:	72 f2                	jb     800a23 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a31:	5b                   	pop    %ebx
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a40:	eb 03                	jmp    800a45 <strtol+0x11>
		s++;
  800a42:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a45:	0f b6 01             	movzbl (%ecx),%eax
  800a48:	3c 20                	cmp    $0x20,%al
  800a4a:	74 f6                	je     800a42 <strtol+0xe>
  800a4c:	3c 09                	cmp    $0x9,%al
  800a4e:	74 f2                	je     800a42 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a50:	3c 2b                	cmp    $0x2b,%al
  800a52:	75 0a                	jne    800a5e <strtol+0x2a>
		s++;
  800a54:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a57:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5c:	eb 11                	jmp    800a6f <strtol+0x3b>
  800a5e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a63:	3c 2d                	cmp    $0x2d,%al
  800a65:	75 08                	jne    800a6f <strtol+0x3b>
		s++, neg = 1;
  800a67:	83 c1 01             	add    $0x1,%ecx
  800a6a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a75:	75 15                	jne    800a8c <strtol+0x58>
  800a77:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7a:	75 10                	jne    800a8c <strtol+0x58>
  800a7c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a80:	75 7c                	jne    800afe <strtol+0xca>
		s += 2, base = 16;
  800a82:	83 c1 02             	add    $0x2,%ecx
  800a85:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8a:	eb 16                	jmp    800aa2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	75 12                	jne    800aa2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a90:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a95:	80 39 30             	cmpb   $0x30,(%ecx)
  800a98:	75 08                	jne    800aa2 <strtol+0x6e>
		s++, base = 8;
  800a9a:	83 c1 01             	add    $0x1,%ecx
  800a9d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aaa:	0f b6 11             	movzbl (%ecx),%edx
  800aad:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 09             	cmp    $0x9,%bl
  800ab5:	77 08                	ja     800abf <strtol+0x8b>
			dig = *s - '0';
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 30             	sub    $0x30,%edx
  800abd:	eb 22                	jmp    800ae1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800abf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac2:	89 f3                	mov    %esi,%ebx
  800ac4:	80 fb 19             	cmp    $0x19,%bl
  800ac7:	77 08                	ja     800ad1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ac9:	0f be d2             	movsbl %dl,%edx
  800acc:	83 ea 57             	sub    $0x57,%edx
  800acf:	eb 10                	jmp    800ae1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ad1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad4:	89 f3                	mov    %esi,%ebx
  800ad6:	80 fb 19             	cmp    $0x19,%bl
  800ad9:	77 16                	ja     800af1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800adb:	0f be d2             	movsbl %dl,%edx
  800ade:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae4:	7d 0b                	jge    800af1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ae6:	83 c1 01             	add    $0x1,%ecx
  800ae9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aed:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aef:	eb b9                	jmp    800aaa <strtol+0x76>

	if (endptr)
  800af1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af5:	74 0d                	je     800b04 <strtol+0xd0>
		*endptr = (char *) s;
  800af7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afa:	89 0e                	mov    %ecx,(%esi)
  800afc:	eb 06                	jmp    800b04 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800afe:	85 db                	test   %ebx,%ebx
  800b00:	74 98                	je     800a9a <strtol+0x66>
  800b02:	eb 9e                	jmp    800aa2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b04:	89 c2                	mov    %eax,%edx
  800b06:	f7 da                	neg    %edx
  800b08:	85 ff                	test   %edi,%edi
  800b0a:	0f 45 c2             	cmovne %edx,%eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b20:	8b 55 08             	mov    0x8(%ebp),%edx
  800b23:	89 c3                	mov    %eax,%ebx
  800b25:	89 c7                	mov    %eax,%edi
  800b27:	89 c6                	mov    %eax,%esi
  800b29:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b40:	89 d1                	mov    %edx,%ecx
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	89 d7                	mov    %edx,%edi
  800b46:	89 d6                	mov    %edx,%esi
  800b48:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b62:	8b 55 08             	mov    0x8(%ebp),%edx
  800b65:	89 cb                	mov    %ecx,%ebx
  800b67:	89 cf                	mov    %ecx,%edi
  800b69:	89 ce                	mov    %ecx,%esi
  800b6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7e 17                	jle    800b88 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	50                   	push   %eax
  800b75:	6a 03                	push   $0x3
  800b77:	68 5f 2a 80 00       	push   $0x802a5f
  800b7c:	6a 23                	push   $0x23
  800b7e:	68 7c 2a 80 00       	push   $0x802a7c
  800b83:	e8 c5 f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba0:	89 d1                	mov    %edx,%ecx
  800ba2:	89 d3                	mov    %edx,%ebx
  800ba4:	89 d7                	mov    %edx,%edi
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_yield>:

void
sys_yield(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	be 00 00 00 00       	mov    $0x0,%esi
  800bdc:	b8 04 00 00 00       	mov    $0x4,%eax
  800be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bea:	89 f7                	mov    %esi,%edi
  800bec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bee:	85 c0                	test   %eax,%eax
  800bf0:	7e 17                	jle    800c09 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf2:	83 ec 0c             	sub    $0xc,%esp
  800bf5:	50                   	push   %eax
  800bf6:	6a 04                	push   $0x4
  800bf8:	68 5f 2a 80 00       	push   $0x802a5f
  800bfd:	6a 23                	push   $0x23
  800bff:	68 7c 2a 80 00       	push   $0x802a7c
  800c04:	e8 44 f5 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	7e 17                	jle    800c4b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	50                   	push   %eax
  800c38:	6a 05                	push   $0x5
  800c3a:	68 5f 2a 80 00       	push   $0x802a5f
  800c3f:	6a 23                	push   $0x23
  800c41:	68 7c 2a 80 00       	push   $0x802a7c
  800c46:	e8 02 f5 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c61:	b8 06 00 00 00       	mov    $0x6,%eax
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	89 df                	mov    %ebx,%edi
  800c6e:	89 de                	mov    %ebx,%esi
  800c70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c72:	85 c0                	test   %eax,%eax
  800c74:	7e 17                	jle    800c8d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c76:	83 ec 0c             	sub    $0xc,%esp
  800c79:	50                   	push   %eax
  800c7a:	6a 06                	push   $0x6
  800c7c:	68 5f 2a 80 00       	push   $0x802a5f
  800c81:	6a 23                	push   $0x23
  800c83:	68 7c 2a 80 00       	push   $0x802a7c
  800c88:	e8 c0 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cab:	8b 55 08             	mov    0x8(%ebp),%edx
  800cae:	89 df                	mov    %ebx,%edi
  800cb0:	89 de                	mov    %ebx,%esi
  800cb2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7e 17                	jle    800ccf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 08                	push   $0x8
  800cbe:	68 5f 2a 80 00       	push   $0x802a5f
  800cc3:	6a 23                	push   $0x23
  800cc5:	68 7c 2a 80 00       	push   $0x802a7c
  800cca:	e8 7e f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ced:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf0:	89 df                	mov    %ebx,%edi
  800cf2:	89 de                	mov    %ebx,%esi
  800cf4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 17                	jle    800d11 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 09                	push   $0x9
  800d00:	68 5f 2a 80 00       	push   $0x802a5f
  800d05:	6a 23                	push   $0x23
  800d07:	68 7c 2a 80 00       	push   $0x802a7c
  800d0c:	e8 3c f4 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d27:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	89 df                	mov    %ebx,%edi
  800d34:	89 de                	mov    %ebx,%esi
  800d36:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7e 17                	jle    800d53 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 0a                	push   $0xa
  800d42:	68 5f 2a 80 00       	push   $0x802a5f
  800d47:	6a 23                	push   $0x23
  800d49:	68 7c 2a 80 00       	push   $0x802a7c
  800d4e:	e8 fa f3 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d61:	be 00 00 00 00       	mov    $0x0,%esi
  800d66:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d74:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d77:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 cb                	mov    %ecx,%ebx
  800d96:	89 cf                	mov    %ecx,%edi
  800d98:	89 ce                	mov    %ecx,%esi
  800d9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 17                	jle    800db7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 0d                	push   $0xd
  800da6:	68 5f 2a 80 00       	push   $0x802a5f
  800dab:	6a 23                	push   $0x23
  800dad:	68 7c 2a 80 00       	push   $0x802a7c
  800db2:	e8 96 f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dca:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dcf:	89 d1                	mov    %edx,%ecx
  800dd1:	89 d3                	mov    %edx,%ebx
  800dd3:	89 d7                	mov    %edx,%edi
  800dd5:	89 d6                	mov    %edx,%esi
  800dd7:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	53                   	push   %ebx
  800de2:	83 ec 04             	sub    $0x4,%esp
  800de5:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800de8:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800dea:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ded:	f6 c1 02             	test   $0x2,%cl
  800df0:	74 2e                	je     800e20 <pgfault+0x42>
  800df2:	89 c2                	mov    %eax,%edx
  800df4:	c1 ea 16             	shr    $0x16,%edx
  800df7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dfe:	f6 c2 01             	test   $0x1,%dl
  800e01:	74 1d                	je     800e20 <pgfault+0x42>
  800e03:	89 c2                	mov    %eax,%edx
  800e05:	c1 ea 0c             	shr    $0xc,%edx
  800e08:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800e0f:	f6 c3 01             	test   $0x1,%bl
  800e12:	74 0c                	je     800e20 <pgfault+0x42>
  800e14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1b:	f6 c6 08             	test   $0x8,%dh
  800e1e:	75 12                	jne    800e32 <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800e20:	51                   	push   %ecx
  800e21:	68 8a 2a 80 00       	push   $0x802a8a
  800e26:	6a 1e                	push   $0x1e
  800e28:	68 a3 2a 80 00       	push   $0x802aa3
  800e2d:	e8 1b f3 ff ff       	call   80014d <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800e32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e37:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800e39:	83 ec 04             	sub    $0x4,%esp
  800e3c:	6a 07                	push   $0x7
  800e3e:	68 00 f0 7f 00       	push   $0x7ff000
  800e43:	6a 00                	push   $0x0
  800e45:	e8 84 fd ff ff       	call   800bce <sys_page_alloc>
  800e4a:	83 c4 10             	add    $0x10,%esp
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	79 12                	jns    800e63 <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800e51:	50                   	push   %eax
  800e52:	68 ae 2a 80 00       	push   $0x802aae
  800e57:	6a 29                	push   $0x29
  800e59:	68 a3 2a 80 00       	push   $0x802aa3
  800e5e:	e8 ea f2 ff ff       	call   80014d <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	68 00 10 00 00       	push   $0x1000
  800e6b:	53                   	push   %ebx
  800e6c:	68 00 f0 7f 00       	push   $0x7ff000
  800e71:	e8 4f fb ff ff       	call   8009c5 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e76:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e7d:	53                   	push   %ebx
  800e7e:	6a 00                	push   $0x0
  800e80:	68 00 f0 7f 00       	push   $0x7ff000
  800e85:	6a 00                	push   $0x0
  800e87:	e8 85 fd ff ff       	call   800c11 <sys_page_map>
  800e8c:	83 c4 20             	add    $0x20,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	79 12                	jns    800ea5 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800e93:	50                   	push   %eax
  800e94:	68 c9 2a 80 00       	push   $0x802ac9
  800e99:	6a 2e                	push   $0x2e
  800e9b:	68 a3 2a 80 00       	push   $0x802aa3
  800ea0:	e8 a8 f2 ff ff       	call   80014d <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800ea5:	83 ec 08             	sub    $0x8,%esp
  800ea8:	68 00 f0 7f 00       	push   $0x7ff000
  800ead:	6a 00                	push   $0x0
  800eaf:	e8 9f fd ff ff       	call   800c53 <sys_page_unmap>
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	79 12                	jns    800ecd <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800ebb:	50                   	push   %eax
  800ebc:	68 e2 2a 80 00       	push   $0x802ae2
  800ec1:	6a 31                	push   $0x31
  800ec3:	68 a3 2a 80 00       	push   $0x802aa3
  800ec8:	e8 80 f2 ff ff       	call   80014d <_panic>

}
  800ecd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800edb:	68 de 0d 80 00       	push   $0x800dde
  800ee0:	e8 82 13 00 00       	call   802267 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ee5:	b8 07 00 00 00       	mov    $0x7,%eax
  800eea:	cd 30                	int    $0x30
  800eec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800eef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efa:	85 c0                	test   %eax,%eax
  800efc:	75 21                	jne    800f1f <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800efe:	e8 8d fc ff ff       	call   800b90 <sys_getenvid>
  800f03:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f08:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f0b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f10:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1a:	e9 c9 01 00 00       	jmp    8010e8 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  800f1f:	89 d8                	mov    %ebx,%eax
  800f21:	c1 e8 16             	shr    $0x16,%eax
  800f24:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f2b:	a8 01                	test   $0x1,%al
  800f2d:	0f 84 1b 01 00 00    	je     80104e <fork+0x17c>
  800f33:	89 de                	mov    %ebx,%esi
  800f35:	c1 ee 0c             	shr    $0xc,%esi
  800f38:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f3f:	a8 01                	test   $0x1,%al
  800f41:	0f 84 07 01 00 00    	je     80104e <fork+0x17c>
  800f47:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f4e:	a8 04                	test   $0x4,%al
  800f50:	0f 84 f8 00 00 00    	je     80104e <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  800f56:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f5d:	f6 c4 04             	test   $0x4,%ah
  800f60:	74 3c                	je     800f9e <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  800f62:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f69:	c1 e6 0c             	shl    $0xc,%esi
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f74:	50                   	push   %eax
  800f75:	56                   	push   %esi
  800f76:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f79:	56                   	push   %esi
  800f7a:	6a 00                	push   $0x0
  800f7c:	e8 90 fc ff ff       	call   800c11 <sys_page_map>
  800f81:	83 c4 20             	add    $0x20,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	0f 89 c2 00 00 00    	jns    80104e <fork+0x17c>
			panic("duppage: %e", r);
  800f8c:	50                   	push   %eax
  800f8d:	68 fd 2a 80 00       	push   $0x802afd
  800f92:	6a 48                	push   $0x48
  800f94:	68 a3 2a 80 00       	push   $0x802aa3
  800f99:	e8 af f1 ff ff       	call   80014d <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  800f9e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fa5:	f6 c4 08             	test   $0x8,%ah
  800fa8:	75 0b                	jne    800fb5 <fork+0xe3>
  800faa:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb1:	a8 02                	test   $0x2,%al
  800fb3:	74 6c                	je     801021 <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  800fb5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fbc:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  800fbf:	83 f8 01             	cmp    $0x1,%eax
  800fc2:	19 ff                	sbb    %edi,%edi
  800fc4:	83 e7 fc             	and    $0xfffffffc,%edi
  800fc7:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  800fcd:	c1 e6 0c             	shl    $0xc,%esi
  800fd0:	83 ec 0c             	sub    $0xc,%esp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd8:	56                   	push   %esi
  800fd9:	6a 00                	push   $0x0
  800fdb:	e8 31 fc ff ff       	call   800c11 <sys_page_map>
  800fe0:	83 c4 20             	add    $0x20,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	79 12                	jns    800ff9 <fork+0x127>
			panic("duppage: %e", r);
  800fe7:	50                   	push   %eax
  800fe8:	68 fd 2a 80 00       	push   $0x802afd
  800fed:	6a 50                	push   $0x50
  800fef:	68 a3 2a 80 00       	push   $0x802aa3
  800ff4:	e8 54 f1 ff ff       	call   80014d <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	57                   	push   %edi
  800ffd:	56                   	push   %esi
  800ffe:	6a 00                	push   $0x0
  801000:	56                   	push   %esi
  801001:	6a 00                	push   $0x0
  801003:	e8 09 fc ff ff       	call   800c11 <sys_page_map>
  801008:	83 c4 20             	add    $0x20,%esp
  80100b:	85 c0                	test   %eax,%eax
  80100d:	79 3f                	jns    80104e <fork+0x17c>
			panic("duppage: %e", r);
  80100f:	50                   	push   %eax
  801010:	68 fd 2a 80 00       	push   $0x802afd
  801015:	6a 53                	push   $0x53
  801017:	68 a3 2a 80 00       	push   $0x802aa3
  80101c:	e8 2c f1 ff ff       	call   80014d <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  801021:	c1 e6 0c             	shl    $0xc,%esi
  801024:	83 ec 0c             	sub    $0xc,%esp
  801027:	6a 05                	push   $0x5
  801029:	56                   	push   %esi
  80102a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80102d:	56                   	push   %esi
  80102e:	6a 00                	push   $0x0
  801030:	e8 dc fb ff ff       	call   800c11 <sys_page_map>
  801035:	83 c4 20             	add    $0x20,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	79 12                	jns    80104e <fork+0x17c>
			panic("duppage: %e", r);
  80103c:	50                   	push   %eax
  80103d:	68 fd 2a 80 00       	push   $0x802afd
  801042:	6a 57                	push   $0x57
  801044:	68 a3 2a 80 00       	push   $0x802aa3
  801049:	e8 ff f0 ff ff       	call   80014d <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  80104e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801054:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80105a:	0f 85 bf fe ff ff    	jne    800f1f <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  801060:	83 ec 04             	sub    $0x4,%esp
  801063:	6a 07                	push   $0x7
  801065:	68 00 f0 bf ee       	push   $0xeebff000
  80106a:	ff 75 e0             	pushl  -0x20(%ebp)
  80106d:	e8 5c fb ff ff       	call   800bce <sys_page_alloc>
  801072:	83 c4 10             	add    $0x10,%esp
  801075:	85 c0                	test   %eax,%eax
  801077:	74 17                	je     801090 <fork+0x1be>
		panic("sys_page_alloc Error");
  801079:	83 ec 04             	sub    $0x4,%esp
  80107c:	68 09 2b 80 00       	push   $0x802b09
  801081:	68 83 00 00 00       	push   $0x83
  801086:	68 a3 2a 80 00       	push   $0x802aa3
  80108b:	e8 bd f0 ff ff       	call   80014d <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	68 d6 22 80 00       	push   $0x8022d6
  801098:	ff 75 e0             	pushl  -0x20(%ebp)
  80109b:	e8 79 fc ff ff       	call   800d19 <sys_env_set_pgfault_upcall>
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	79 15                	jns    8010bc <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  8010a7:	50                   	push   %eax
  8010a8:	68 1e 2b 80 00       	push   $0x802b1e
  8010ad:	68 86 00 00 00       	push   $0x86
  8010b2:	68 a3 2a 80 00       	push   $0x802aa3
  8010b7:	e8 91 f0 ff ff       	call   80014d <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  8010bc:	83 ec 08             	sub    $0x8,%esp
  8010bf:	6a 02                	push   $0x2
  8010c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8010c4:	e8 cc fb ff ff       	call   800c95 <sys_env_set_status>
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 15                	jns    8010e5 <fork+0x213>
		panic("fork set status: %e", r);
  8010d0:	50                   	push   %eax
  8010d1:	68 36 2b 80 00       	push   $0x802b36
  8010d6:	68 89 00 00 00       	push   $0x89
  8010db:	68 a3 2a 80 00       	push   $0x802aa3
  8010e0:	e8 68 f0 ff ff       	call   80014d <_panic>
	
	return envid;
  8010e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8010e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sfork>:


// Challenge!
int
sfork(void)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010f6:	68 4a 2b 80 00       	push   $0x802b4a
  8010fb:	68 93 00 00 00       	push   $0x93
  801100:	68 a3 2a 80 00       	push   $0x802aa3
  801105:	e8 43 f0 ff ff       	call   80014d <_panic>

0080110a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80110d:	8b 45 08             	mov    0x8(%ebp),%eax
  801110:	05 00 00 00 30       	add    $0x30000000,%eax
  801115:	c1 e8 0c             	shr    $0xc,%eax
}
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80111d:	8b 45 08             	mov    0x8(%ebp),%eax
  801120:	05 00 00 00 30       	add    $0x30000000,%eax
  801125:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80112a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801137:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80113c:	89 c2                	mov    %eax,%edx
  80113e:	c1 ea 16             	shr    $0x16,%edx
  801141:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801148:	f6 c2 01             	test   $0x1,%dl
  80114b:	74 11                	je     80115e <fd_alloc+0x2d>
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	c1 ea 0c             	shr    $0xc,%edx
  801152:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801159:	f6 c2 01             	test   $0x1,%dl
  80115c:	75 09                	jne    801167 <fd_alloc+0x36>
			*fd_store = fd;
  80115e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801160:	b8 00 00 00 00       	mov    $0x0,%eax
  801165:	eb 17                	jmp    80117e <fd_alloc+0x4d>
  801167:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80116c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801171:	75 c9                	jne    80113c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801173:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801179:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801186:	83 f8 1f             	cmp    $0x1f,%eax
  801189:	77 36                	ja     8011c1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80118b:	c1 e0 0c             	shl    $0xc,%eax
  80118e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801193:	89 c2                	mov    %eax,%edx
  801195:	c1 ea 16             	shr    $0x16,%edx
  801198:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119f:	f6 c2 01             	test   $0x1,%dl
  8011a2:	74 24                	je     8011c8 <fd_lookup+0x48>
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 ea 0c             	shr    $0xc,%edx
  8011a9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b0:	f6 c2 01             	test   $0x1,%dl
  8011b3:	74 1a                	je     8011cf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b8:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bf:	eb 13                	jmp    8011d4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c6:	eb 0c                	jmp    8011d4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011cd:	eb 05                	jmp    8011d4 <fd_lookup+0x54>
  8011cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	83 ec 08             	sub    $0x8,%esp
  8011dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011df:	ba e0 2b 80 00       	mov    $0x802be0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011e4:	eb 13                	jmp    8011f9 <dev_lookup+0x23>
  8011e6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011e9:	39 08                	cmp    %ecx,(%eax)
  8011eb:	75 0c                	jne    8011f9 <dev_lookup+0x23>
			*dev = devtab[i];
  8011ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f7:	eb 2e                	jmp    801227 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011f9:	8b 02                	mov    (%edx),%eax
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	75 e7                	jne    8011e6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ff:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801204:	8b 40 48             	mov    0x48(%eax),%eax
  801207:	83 ec 04             	sub    $0x4,%esp
  80120a:	51                   	push   %ecx
  80120b:	50                   	push   %eax
  80120c:	68 60 2b 80 00       	push   $0x802b60
  801211:	e8 10 f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  801216:	8b 45 0c             	mov    0xc(%ebp),%eax
  801219:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801227:	c9                   	leave  
  801228:	c3                   	ret    

00801229 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	56                   	push   %esi
  80122d:	53                   	push   %ebx
  80122e:	83 ec 10             	sub    $0x10,%esp
  801231:	8b 75 08             	mov    0x8(%ebp),%esi
  801234:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801237:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801241:	c1 e8 0c             	shr    $0xc,%eax
  801244:	50                   	push   %eax
  801245:	e8 36 ff ff ff       	call   801180 <fd_lookup>
  80124a:	83 c4 08             	add    $0x8,%esp
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 05                	js     801256 <fd_close+0x2d>
	    || fd != fd2)
  801251:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801254:	74 0c                	je     801262 <fd_close+0x39>
		return (must_exist ? r : 0);
  801256:	84 db                	test   %bl,%bl
  801258:	ba 00 00 00 00       	mov    $0x0,%edx
  80125d:	0f 44 c2             	cmove  %edx,%eax
  801260:	eb 41                	jmp    8012a3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801268:	50                   	push   %eax
  801269:	ff 36                	pushl  (%esi)
  80126b:	e8 66 ff ff ff       	call   8011d6 <dev_lookup>
  801270:	89 c3                	mov    %eax,%ebx
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	78 1a                	js     801293 <fd_close+0x6a>
		if (dev->dev_close)
  801279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80127f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801284:	85 c0                	test   %eax,%eax
  801286:	74 0b                	je     801293 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801288:	83 ec 0c             	sub    $0xc,%esp
  80128b:	56                   	push   %esi
  80128c:	ff d0                	call   *%eax
  80128e:	89 c3                	mov    %eax,%ebx
  801290:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801293:	83 ec 08             	sub    $0x8,%esp
  801296:	56                   	push   %esi
  801297:	6a 00                	push   $0x0
  801299:	e8 b5 f9 ff ff       	call   800c53 <sys_page_unmap>
	return r;
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	89 d8                	mov    %ebx,%eax
}
  8012a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a6:	5b                   	pop    %ebx
  8012a7:	5e                   	pop    %esi
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	ff 75 08             	pushl  0x8(%ebp)
  8012b7:	e8 c4 fe ff ff       	call   801180 <fd_lookup>
  8012bc:	83 c4 08             	add    $0x8,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 10                	js     8012d3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	6a 01                	push   $0x1
  8012c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012cb:	e8 59 ff ff ff       	call   801229 <fd_close>
  8012d0:	83 c4 10             	add    $0x10,%esp
}
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    

008012d5 <close_all>:

void
close_all(void)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012dc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012e1:	83 ec 0c             	sub    $0xc,%esp
  8012e4:	53                   	push   %ebx
  8012e5:	e8 c0 ff ff ff       	call   8012aa <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ea:	83 c3 01             	add    $0x1,%ebx
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	83 fb 20             	cmp    $0x20,%ebx
  8012f3:	75 ec                	jne    8012e1 <close_all+0xc>
		close(i);
}
  8012f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	57                   	push   %edi
  8012fe:	56                   	push   %esi
  8012ff:	53                   	push   %ebx
  801300:	83 ec 2c             	sub    $0x2c,%esp
  801303:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801306:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	ff 75 08             	pushl  0x8(%ebp)
  80130d:	e8 6e fe ff ff       	call   801180 <fd_lookup>
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	0f 88 c1 00 00 00    	js     8013de <dup+0xe4>
		return r;
	close(newfdnum);
  80131d:	83 ec 0c             	sub    $0xc,%esp
  801320:	56                   	push   %esi
  801321:	e8 84 ff ff ff       	call   8012aa <close>

	newfd = INDEX2FD(newfdnum);
  801326:	89 f3                	mov    %esi,%ebx
  801328:	c1 e3 0c             	shl    $0xc,%ebx
  80132b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801331:	83 c4 04             	add    $0x4,%esp
  801334:	ff 75 e4             	pushl  -0x1c(%ebp)
  801337:	e8 de fd ff ff       	call   80111a <fd2data>
  80133c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80133e:	89 1c 24             	mov    %ebx,(%esp)
  801341:	e8 d4 fd ff ff       	call   80111a <fd2data>
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80134c:	89 f8                	mov    %edi,%eax
  80134e:	c1 e8 16             	shr    $0x16,%eax
  801351:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801358:	a8 01                	test   $0x1,%al
  80135a:	74 37                	je     801393 <dup+0x99>
  80135c:	89 f8                	mov    %edi,%eax
  80135e:	c1 e8 0c             	shr    $0xc,%eax
  801361:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801368:	f6 c2 01             	test   $0x1,%dl
  80136b:	74 26                	je     801393 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80136d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801374:	83 ec 0c             	sub    $0xc,%esp
  801377:	25 07 0e 00 00       	and    $0xe07,%eax
  80137c:	50                   	push   %eax
  80137d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801380:	6a 00                	push   $0x0
  801382:	57                   	push   %edi
  801383:	6a 00                	push   $0x0
  801385:	e8 87 f8 ff ff       	call   800c11 <sys_page_map>
  80138a:	89 c7                	mov    %eax,%edi
  80138c:	83 c4 20             	add    $0x20,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 2e                	js     8013c1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801393:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801396:	89 d0                	mov    %edx,%eax
  801398:	c1 e8 0c             	shr    $0xc,%eax
  80139b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a2:	83 ec 0c             	sub    $0xc,%esp
  8013a5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013aa:	50                   	push   %eax
  8013ab:	53                   	push   %ebx
  8013ac:	6a 00                	push   $0x0
  8013ae:	52                   	push   %edx
  8013af:	6a 00                	push   $0x0
  8013b1:	e8 5b f8 ff ff       	call   800c11 <sys_page_map>
  8013b6:	89 c7                	mov    %eax,%edi
  8013b8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013bb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013bd:	85 ff                	test   %edi,%edi
  8013bf:	79 1d                	jns    8013de <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013c1:	83 ec 08             	sub    $0x8,%esp
  8013c4:	53                   	push   %ebx
  8013c5:	6a 00                	push   $0x0
  8013c7:	e8 87 f8 ff ff       	call   800c53 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013cc:	83 c4 08             	add    $0x8,%esp
  8013cf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d2:	6a 00                	push   $0x0
  8013d4:	e8 7a f8 ff ff       	call   800c53 <sys_page_unmap>
	return r;
  8013d9:	83 c4 10             	add    $0x10,%esp
  8013dc:	89 f8                	mov    %edi,%eax
}
  8013de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e1:	5b                   	pop    %ebx
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 14             	sub    $0x14,%esp
  8013ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f3:	50                   	push   %eax
  8013f4:	53                   	push   %ebx
  8013f5:	e8 86 fd ff ff       	call   801180 <fd_lookup>
  8013fa:	83 c4 08             	add    $0x8,%esp
  8013fd:	89 c2                	mov    %eax,%edx
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 6d                	js     801470 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801409:	50                   	push   %eax
  80140a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140d:	ff 30                	pushl  (%eax)
  80140f:	e8 c2 fd ff ff       	call   8011d6 <dev_lookup>
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 4c                	js     801467 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80141b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80141e:	8b 42 08             	mov    0x8(%edx),%eax
  801421:	83 e0 03             	and    $0x3,%eax
  801424:	83 f8 01             	cmp    $0x1,%eax
  801427:	75 21                	jne    80144a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801429:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80142e:	8b 40 48             	mov    0x48(%eax),%eax
  801431:	83 ec 04             	sub    $0x4,%esp
  801434:	53                   	push   %ebx
  801435:	50                   	push   %eax
  801436:	68 a4 2b 80 00       	push   $0x802ba4
  80143b:	e8 e6 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801448:	eb 26                	jmp    801470 <read+0x8a>
	}
	if (!dev->dev_read)
  80144a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144d:	8b 40 08             	mov    0x8(%eax),%eax
  801450:	85 c0                	test   %eax,%eax
  801452:	74 17                	je     80146b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801454:	83 ec 04             	sub    $0x4,%esp
  801457:	ff 75 10             	pushl  0x10(%ebp)
  80145a:	ff 75 0c             	pushl  0xc(%ebp)
  80145d:	52                   	push   %edx
  80145e:	ff d0                	call   *%eax
  801460:	89 c2                	mov    %eax,%edx
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	eb 09                	jmp    801470 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801467:	89 c2                	mov    %eax,%edx
  801469:	eb 05                	jmp    801470 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80146b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801470:	89 d0                	mov    %edx,%eax
  801472:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	57                   	push   %edi
  80147b:	56                   	push   %esi
  80147c:	53                   	push   %ebx
  80147d:	83 ec 0c             	sub    $0xc,%esp
  801480:	8b 7d 08             	mov    0x8(%ebp),%edi
  801483:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801486:	bb 00 00 00 00       	mov    $0x0,%ebx
  80148b:	eb 21                	jmp    8014ae <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80148d:	83 ec 04             	sub    $0x4,%esp
  801490:	89 f0                	mov    %esi,%eax
  801492:	29 d8                	sub    %ebx,%eax
  801494:	50                   	push   %eax
  801495:	89 d8                	mov    %ebx,%eax
  801497:	03 45 0c             	add    0xc(%ebp),%eax
  80149a:	50                   	push   %eax
  80149b:	57                   	push   %edi
  80149c:	e8 45 ff ff ff       	call   8013e6 <read>
		if (m < 0)
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 10                	js     8014b8 <readn+0x41>
			return m;
		if (m == 0)
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	74 0a                	je     8014b6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ac:	01 c3                	add    %eax,%ebx
  8014ae:	39 f3                	cmp    %esi,%ebx
  8014b0:	72 db                	jb     80148d <readn+0x16>
  8014b2:	89 d8                	mov    %ebx,%eax
  8014b4:	eb 02                	jmp    8014b8 <readn+0x41>
  8014b6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014bb:	5b                   	pop    %ebx
  8014bc:	5e                   	pop    %esi
  8014bd:	5f                   	pop    %edi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	53                   	push   %ebx
  8014c4:	83 ec 14             	sub    $0x14,%esp
  8014c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cd:	50                   	push   %eax
  8014ce:	53                   	push   %ebx
  8014cf:	e8 ac fc ff ff       	call   801180 <fd_lookup>
  8014d4:	83 c4 08             	add    $0x8,%esp
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 68                	js     801545 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e7:	ff 30                	pushl  (%eax)
  8014e9:	e8 e8 fc ff ff       	call   8011d6 <dev_lookup>
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 47                	js     80153c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014fc:	75 21                	jne    80151f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014fe:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801503:	8b 40 48             	mov    0x48(%eax),%eax
  801506:	83 ec 04             	sub    $0x4,%esp
  801509:	53                   	push   %ebx
  80150a:	50                   	push   %eax
  80150b:	68 c0 2b 80 00       	push   $0x802bc0
  801510:	e8 11 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151d:	eb 26                	jmp    801545 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80151f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801522:	8b 52 0c             	mov    0xc(%edx),%edx
  801525:	85 d2                	test   %edx,%edx
  801527:	74 17                	je     801540 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801529:	83 ec 04             	sub    $0x4,%esp
  80152c:	ff 75 10             	pushl  0x10(%ebp)
  80152f:	ff 75 0c             	pushl  0xc(%ebp)
  801532:	50                   	push   %eax
  801533:	ff d2                	call   *%edx
  801535:	89 c2                	mov    %eax,%edx
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	eb 09                	jmp    801545 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153c:	89 c2                	mov    %eax,%edx
  80153e:	eb 05                	jmp    801545 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801540:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801545:	89 d0                	mov    %edx,%eax
  801547:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154a:	c9                   	leave  
  80154b:	c3                   	ret    

0080154c <seek>:

int
seek(int fdnum, off_t offset)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801552:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801555:	50                   	push   %eax
  801556:	ff 75 08             	pushl  0x8(%ebp)
  801559:	e8 22 fc ff ff       	call   801180 <fd_lookup>
  80155e:	83 c4 08             	add    $0x8,%esp
  801561:	85 c0                	test   %eax,%eax
  801563:	78 0e                	js     801573 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801565:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801568:	8b 55 0c             	mov    0xc(%ebp),%edx
  80156b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80156e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	53                   	push   %ebx
  801579:	83 ec 14             	sub    $0x14,%esp
  80157c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	53                   	push   %ebx
  801584:	e8 f7 fb ff ff       	call   801180 <fd_lookup>
  801589:	83 c4 08             	add    $0x8,%esp
  80158c:	89 c2                	mov    %eax,%edx
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 65                	js     8015f7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801592:	83 ec 08             	sub    $0x8,%esp
  801595:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159c:	ff 30                	pushl  (%eax)
  80159e:	e8 33 fc ff ff       	call   8011d6 <dev_lookup>
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 44                	js     8015ee <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b1:	75 21                	jne    8015d4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015b3:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015b8:	8b 40 48             	mov    0x48(%eax),%eax
  8015bb:	83 ec 04             	sub    $0x4,%esp
  8015be:	53                   	push   %ebx
  8015bf:	50                   	push   %eax
  8015c0:	68 80 2b 80 00       	push   $0x802b80
  8015c5:	e8 5c ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d2:	eb 23                	jmp    8015f7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d7:	8b 52 18             	mov    0x18(%edx),%edx
  8015da:	85 d2                	test   %edx,%edx
  8015dc:	74 14                	je     8015f2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	ff 75 0c             	pushl  0xc(%ebp)
  8015e4:	50                   	push   %eax
  8015e5:	ff d2                	call   *%edx
  8015e7:	89 c2                	mov    %eax,%edx
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	eb 09                	jmp    8015f7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	eb 05                	jmp    8015f7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015f7:	89 d0                	mov    %edx,%eax
  8015f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    

008015fe <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	53                   	push   %ebx
  801602:	83 ec 14             	sub    $0x14,%esp
  801605:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801608:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	ff 75 08             	pushl  0x8(%ebp)
  80160f:	e8 6c fb ff ff       	call   801180 <fd_lookup>
  801614:	83 c4 08             	add    $0x8,%esp
  801617:	89 c2                	mov    %eax,%edx
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 58                	js     801675 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801627:	ff 30                	pushl  (%eax)
  801629:	e8 a8 fb ff ff       	call   8011d6 <dev_lookup>
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 37                	js     80166c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801635:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801638:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80163c:	74 32                	je     801670 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80163e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801641:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801648:	00 00 00 
	stat->st_isdir = 0;
  80164b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801652:	00 00 00 
	stat->st_dev = dev;
  801655:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	53                   	push   %ebx
  80165f:	ff 75 f0             	pushl  -0x10(%ebp)
  801662:	ff 50 14             	call   *0x14(%eax)
  801665:	89 c2                	mov    %eax,%edx
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	eb 09                	jmp    801675 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	eb 05                	jmp    801675 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801670:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801675:	89 d0                	mov    %edx,%eax
  801677:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801681:	83 ec 08             	sub    $0x8,%esp
  801684:	6a 00                	push   $0x0
  801686:	ff 75 08             	pushl  0x8(%ebp)
  801689:	e8 ef 01 00 00       	call   80187d <open>
  80168e:	89 c3                	mov    %eax,%ebx
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	85 c0                	test   %eax,%eax
  801695:	78 1b                	js     8016b2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	ff 75 0c             	pushl  0xc(%ebp)
  80169d:	50                   	push   %eax
  80169e:	e8 5b ff ff ff       	call   8015fe <fstat>
  8016a3:	89 c6                	mov    %eax,%esi
	close(fd);
  8016a5:	89 1c 24             	mov    %ebx,(%esp)
  8016a8:	e8 fd fb ff ff       	call   8012aa <close>
	return r;
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	89 f0                	mov    %esi,%eax
}
  8016b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    

008016b9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	56                   	push   %esi
  8016bd:	53                   	push   %ebx
  8016be:	89 c6                	mov    %eax,%esi
  8016c0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016c2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016c9:	75 12                	jne    8016dd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016cb:	83 ec 0c             	sub    $0xc,%esp
  8016ce:	6a 01                	push   $0x1
  8016d0:	e8 ed 0c 00 00       	call   8023c2 <ipc_find_env>
  8016d5:	a3 00 40 80 00       	mov    %eax,0x804000
  8016da:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016dd:	6a 07                	push   $0x7
  8016df:	68 00 50 80 00       	push   $0x805000
  8016e4:	56                   	push   %esi
  8016e5:	ff 35 00 40 80 00    	pushl  0x804000
  8016eb:	e8 83 0c 00 00       	call   802373 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016f0:	83 c4 0c             	add    $0xc,%esp
  8016f3:	6a 00                	push   $0x0
  8016f5:	53                   	push   %ebx
  8016f6:	6a 00                	push   $0x0
  8016f8:	e8 00 0c 00 00       	call   8022fd <ipc_recv>
}
  8016fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801700:	5b                   	pop    %ebx
  801701:	5e                   	pop    %esi
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    

00801704 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80170a:	8b 45 08             	mov    0x8(%ebp),%eax
  80170d:	8b 40 0c             	mov    0xc(%eax),%eax
  801710:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801715:	8b 45 0c             	mov    0xc(%ebp),%eax
  801718:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80171d:	ba 00 00 00 00       	mov    $0x0,%edx
  801722:	b8 02 00 00 00       	mov    $0x2,%eax
  801727:	e8 8d ff ff ff       	call   8016b9 <fsipc>
}
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801734:	8b 45 08             	mov    0x8(%ebp),%eax
  801737:	8b 40 0c             	mov    0xc(%eax),%eax
  80173a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80173f:	ba 00 00 00 00       	mov    $0x0,%edx
  801744:	b8 06 00 00 00       	mov    $0x6,%eax
  801749:	e8 6b ff ff ff       	call   8016b9 <fsipc>
}
  80174e:	c9                   	leave  
  80174f:	c3                   	ret    

00801750 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	53                   	push   %ebx
  801754:	83 ec 04             	sub    $0x4,%esp
  801757:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80175a:	8b 45 08             	mov    0x8(%ebp),%eax
  80175d:	8b 40 0c             	mov    0xc(%eax),%eax
  801760:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801765:	ba 00 00 00 00       	mov    $0x0,%edx
  80176a:	b8 05 00 00 00       	mov    $0x5,%eax
  80176f:	e8 45 ff ff ff       	call   8016b9 <fsipc>
  801774:	85 c0                	test   %eax,%eax
  801776:	78 2c                	js     8017a4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801778:	83 ec 08             	sub    $0x8,%esp
  80177b:	68 00 50 80 00       	push   $0x805000
  801780:	53                   	push   %ebx
  801781:	e8 45 f0 ff ff       	call   8007cb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801786:	a1 80 50 80 00       	mov    0x805080,%eax
  80178b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801791:	a1 84 50 80 00       	mov    0x805084,%eax
  801796:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	53                   	push   %ebx
  8017ad:	83 ec 08             	sub    $0x8,%esp
  8017b0:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b6:	8b 52 0c             	mov    0xc(%edx),%edx
  8017b9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017bf:	a3 04 50 80 00       	mov    %eax,0x805004
  8017c4:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8017c9:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8017ce:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017d1:	53                   	push   %ebx
  8017d2:	ff 75 0c             	pushl  0xc(%ebp)
  8017d5:	68 08 50 80 00       	push   $0x805008
  8017da:	e8 7e f1 ff ff       	call   80095d <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e9:	e8 cb fe ff ff       	call   8016b9 <fsipc>
  8017ee:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8017f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	8b 40 0c             	mov    0xc(%eax),%eax
  801809:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80180e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
  801819:	b8 03 00 00 00       	mov    $0x3,%eax
  80181e:	e8 96 fe ff ff       	call   8016b9 <fsipc>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	85 c0                	test   %eax,%eax
  801827:	78 4b                	js     801874 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801829:	39 c6                	cmp    %eax,%esi
  80182b:	73 16                	jae    801843 <devfile_read+0x48>
  80182d:	68 f4 2b 80 00       	push   $0x802bf4
  801832:	68 fb 2b 80 00       	push   $0x802bfb
  801837:	6a 7c                	push   $0x7c
  801839:	68 10 2c 80 00       	push   $0x802c10
  80183e:	e8 0a e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  801843:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801848:	7e 16                	jle    801860 <devfile_read+0x65>
  80184a:	68 1b 2c 80 00       	push   $0x802c1b
  80184f:	68 fb 2b 80 00       	push   $0x802bfb
  801854:	6a 7d                	push   $0x7d
  801856:	68 10 2c 80 00       	push   $0x802c10
  80185b:	e8 ed e8 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801860:	83 ec 04             	sub    $0x4,%esp
  801863:	50                   	push   %eax
  801864:	68 00 50 80 00       	push   $0x805000
  801869:	ff 75 0c             	pushl  0xc(%ebp)
  80186c:	e8 ec f0 ff ff       	call   80095d <memmove>
	return r;
  801871:	83 c4 10             	add    $0x10,%esp
}
  801874:	89 d8                	mov    %ebx,%eax
  801876:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801879:	5b                   	pop    %ebx
  80187a:	5e                   	pop    %esi
  80187b:	5d                   	pop    %ebp
  80187c:	c3                   	ret    

0080187d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	53                   	push   %ebx
  801881:	83 ec 20             	sub    $0x20,%esp
  801884:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801887:	53                   	push   %ebx
  801888:	e8 05 ef ff ff       	call   800792 <strlen>
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801895:	7f 67                	jg     8018fe <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801897:	83 ec 0c             	sub    $0xc,%esp
  80189a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189d:	50                   	push   %eax
  80189e:	e8 8e f8 ff ff       	call   801131 <fd_alloc>
  8018a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8018a6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	78 57                	js     801903 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018ac:	83 ec 08             	sub    $0x8,%esp
  8018af:	53                   	push   %ebx
  8018b0:	68 00 50 80 00       	push   $0x805000
  8018b5:	e8 11 ef ff ff       	call   8007cb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ca:	e8 ea fd ff ff       	call   8016b9 <fsipc>
  8018cf:	89 c3                	mov    %eax,%ebx
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	79 14                	jns    8018ec <open+0x6f>
		fd_close(fd, 0);
  8018d8:	83 ec 08             	sub    $0x8,%esp
  8018db:	6a 00                	push   $0x0
  8018dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e0:	e8 44 f9 ff ff       	call   801229 <fd_close>
		return r;
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	89 da                	mov    %ebx,%edx
  8018ea:	eb 17                	jmp    801903 <open+0x86>
	}

	return fd2num(fd);
  8018ec:	83 ec 0c             	sub    $0xc,%esp
  8018ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f2:	e8 13 f8 ff ff       	call   80110a <fd2num>
  8018f7:	89 c2                	mov    %eax,%edx
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	eb 05                	jmp    801903 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018fe:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801903:	89 d0                	mov    %edx,%eax
  801905:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801910:	ba 00 00 00 00       	mov    $0x0,%edx
  801915:	b8 08 00 00 00       	mov    $0x8,%eax
  80191a:	e8 9a fd ff ff       	call   8016b9 <fsipc>
}
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	56                   	push   %esi
  801925:	53                   	push   %ebx
  801926:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801929:	83 ec 0c             	sub    $0xc,%esp
  80192c:	ff 75 08             	pushl  0x8(%ebp)
  80192f:	e8 e6 f7 ff ff       	call   80111a <fd2data>
  801934:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801936:	83 c4 08             	add    $0x8,%esp
  801939:	68 27 2c 80 00       	push   $0x802c27
  80193e:	53                   	push   %ebx
  80193f:	e8 87 ee ff ff       	call   8007cb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801944:	8b 46 04             	mov    0x4(%esi),%eax
  801947:	2b 06                	sub    (%esi),%eax
  801949:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80194f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801956:	00 00 00 
	stat->st_dev = &devpipe;
  801959:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801960:	30 80 00 
	return 0;
}
  801963:	b8 00 00 00 00       	mov    $0x0,%eax
  801968:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196b:	5b                   	pop    %ebx
  80196c:	5e                   	pop    %esi
  80196d:	5d                   	pop    %ebp
  80196e:	c3                   	ret    

0080196f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	53                   	push   %ebx
  801973:	83 ec 0c             	sub    $0xc,%esp
  801976:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801979:	53                   	push   %ebx
  80197a:	6a 00                	push   $0x0
  80197c:	e8 d2 f2 ff ff       	call   800c53 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801981:	89 1c 24             	mov    %ebx,(%esp)
  801984:	e8 91 f7 ff ff       	call   80111a <fd2data>
  801989:	83 c4 08             	add    $0x8,%esp
  80198c:	50                   	push   %eax
  80198d:	6a 00                	push   $0x0
  80198f:	e8 bf f2 ff ff       	call   800c53 <sys_page_unmap>
}
  801994:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	57                   	push   %edi
  80199d:	56                   	push   %esi
  80199e:	53                   	push   %ebx
  80199f:	83 ec 1c             	sub    $0x1c,%esp
  8019a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019a5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019a7:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8019ac:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8019b5:	e8 41 0a 00 00       	call   8023fb <pageref>
  8019ba:	89 c3                	mov    %eax,%ebx
  8019bc:	89 3c 24             	mov    %edi,(%esp)
  8019bf:	e8 37 0a 00 00       	call   8023fb <pageref>
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	39 c3                	cmp    %eax,%ebx
  8019c9:	0f 94 c1             	sete   %cl
  8019cc:	0f b6 c9             	movzbl %cl,%ecx
  8019cf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019d2:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8019d8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019db:	39 ce                	cmp    %ecx,%esi
  8019dd:	74 1b                	je     8019fa <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019df:	39 c3                	cmp    %eax,%ebx
  8019e1:	75 c4                	jne    8019a7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019e3:	8b 42 58             	mov    0x58(%edx),%eax
  8019e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019e9:	50                   	push   %eax
  8019ea:	56                   	push   %esi
  8019eb:	68 2e 2c 80 00       	push   $0x802c2e
  8019f0:	e8 31 e8 ff ff       	call   800226 <cprintf>
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	eb ad                	jmp    8019a7 <_pipeisclosed+0xe>
	}
}
  8019fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a00:	5b                   	pop    %ebx
  801a01:	5e                   	pop    %esi
  801a02:	5f                   	pop    %edi
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	57                   	push   %edi
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
  801a0b:	83 ec 28             	sub    $0x28,%esp
  801a0e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a11:	56                   	push   %esi
  801a12:	e8 03 f7 ff ff       	call   80111a <fd2data>
  801a17:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	bf 00 00 00 00       	mov    $0x0,%edi
  801a21:	eb 4b                	jmp    801a6e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a23:	89 da                	mov    %ebx,%edx
  801a25:	89 f0                	mov    %esi,%eax
  801a27:	e8 6d ff ff ff       	call   801999 <_pipeisclosed>
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	75 48                	jne    801a78 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a30:	e8 7a f1 ff ff       	call   800baf <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a35:	8b 43 04             	mov    0x4(%ebx),%eax
  801a38:	8b 0b                	mov    (%ebx),%ecx
  801a3a:	8d 51 20             	lea    0x20(%ecx),%edx
  801a3d:	39 d0                	cmp    %edx,%eax
  801a3f:	73 e2                	jae    801a23 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a44:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a48:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a4b:	89 c2                	mov    %eax,%edx
  801a4d:	c1 fa 1f             	sar    $0x1f,%edx
  801a50:	89 d1                	mov    %edx,%ecx
  801a52:	c1 e9 1b             	shr    $0x1b,%ecx
  801a55:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a58:	83 e2 1f             	and    $0x1f,%edx
  801a5b:	29 ca                	sub    %ecx,%edx
  801a5d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a61:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a65:	83 c0 01             	add    $0x1,%eax
  801a68:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6b:	83 c7 01             	add    $0x1,%edi
  801a6e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a71:	75 c2                	jne    801a35 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a73:	8b 45 10             	mov    0x10(%ebp),%eax
  801a76:	eb 05                	jmp    801a7d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a78:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5f                   	pop    %edi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    

00801a85 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	57                   	push   %edi
  801a89:	56                   	push   %esi
  801a8a:	53                   	push   %ebx
  801a8b:	83 ec 18             	sub    $0x18,%esp
  801a8e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a91:	57                   	push   %edi
  801a92:	e8 83 f6 ff ff       	call   80111a <fd2data>
  801a97:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aa1:	eb 3d                	jmp    801ae0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aa3:	85 db                	test   %ebx,%ebx
  801aa5:	74 04                	je     801aab <devpipe_read+0x26>
				return i;
  801aa7:	89 d8                	mov    %ebx,%eax
  801aa9:	eb 44                	jmp    801aef <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aab:	89 f2                	mov    %esi,%edx
  801aad:	89 f8                	mov    %edi,%eax
  801aaf:	e8 e5 fe ff ff       	call   801999 <_pipeisclosed>
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	75 32                	jne    801aea <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ab8:	e8 f2 f0 ff ff       	call   800baf <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801abd:	8b 06                	mov    (%esi),%eax
  801abf:	3b 46 04             	cmp    0x4(%esi),%eax
  801ac2:	74 df                	je     801aa3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ac4:	99                   	cltd   
  801ac5:	c1 ea 1b             	shr    $0x1b,%edx
  801ac8:	01 d0                	add    %edx,%eax
  801aca:	83 e0 1f             	and    $0x1f,%eax
  801acd:	29 d0                	sub    %edx,%eax
  801acf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ada:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801add:	83 c3 01             	add    $0x1,%ebx
  801ae0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ae3:	75 d8                	jne    801abd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ae5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae8:	eb 05                	jmp    801aef <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5f                   	pop    %edi
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
  801afc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801aff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b02:	50                   	push   %eax
  801b03:	e8 29 f6 ff ff       	call   801131 <fd_alloc>
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	89 c2                	mov    %eax,%edx
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	0f 88 2c 01 00 00    	js     801c41 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b15:	83 ec 04             	sub    $0x4,%esp
  801b18:	68 07 04 00 00       	push   $0x407
  801b1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b20:	6a 00                	push   $0x0
  801b22:	e8 a7 f0 ff ff       	call   800bce <sys_page_alloc>
  801b27:	83 c4 10             	add    $0x10,%esp
  801b2a:	89 c2                	mov    %eax,%edx
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	0f 88 0d 01 00 00    	js     801c41 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b34:	83 ec 0c             	sub    $0xc,%esp
  801b37:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b3a:	50                   	push   %eax
  801b3b:	e8 f1 f5 ff ff       	call   801131 <fd_alloc>
  801b40:	89 c3                	mov    %eax,%ebx
  801b42:	83 c4 10             	add    $0x10,%esp
  801b45:	85 c0                	test   %eax,%eax
  801b47:	0f 88 e2 00 00 00    	js     801c2f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4d:	83 ec 04             	sub    $0x4,%esp
  801b50:	68 07 04 00 00       	push   $0x407
  801b55:	ff 75 f0             	pushl  -0x10(%ebp)
  801b58:	6a 00                	push   $0x0
  801b5a:	e8 6f f0 ff ff       	call   800bce <sys_page_alloc>
  801b5f:	89 c3                	mov    %eax,%ebx
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	85 c0                	test   %eax,%eax
  801b66:	0f 88 c3 00 00 00    	js     801c2f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b6c:	83 ec 0c             	sub    $0xc,%esp
  801b6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b72:	e8 a3 f5 ff ff       	call   80111a <fd2data>
  801b77:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b79:	83 c4 0c             	add    $0xc,%esp
  801b7c:	68 07 04 00 00       	push   $0x407
  801b81:	50                   	push   %eax
  801b82:	6a 00                	push   $0x0
  801b84:	e8 45 f0 ff ff       	call   800bce <sys_page_alloc>
  801b89:	89 c3                	mov    %eax,%ebx
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	0f 88 89 00 00 00    	js     801c1f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b96:	83 ec 0c             	sub    $0xc,%esp
  801b99:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9c:	e8 79 f5 ff ff       	call   80111a <fd2data>
  801ba1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ba8:	50                   	push   %eax
  801ba9:	6a 00                	push   $0x0
  801bab:	56                   	push   %esi
  801bac:	6a 00                	push   $0x0
  801bae:	e8 5e f0 ff ff       	call   800c11 <sys_page_map>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	83 c4 20             	add    $0x20,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	78 55                	js     801c11 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bbc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bd1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bda:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bdf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801be6:	83 ec 0c             	sub    $0xc,%esp
  801be9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bec:	e8 19 f5 ff ff       	call   80110a <fd2num>
  801bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bf6:	83 c4 04             	add    $0x4,%esp
  801bf9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bfc:	e8 09 f5 ff ff       	call   80110a <fd2num>
  801c01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c04:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0f:	eb 30                	jmp    801c41 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c11:	83 ec 08             	sub    $0x8,%esp
  801c14:	56                   	push   %esi
  801c15:	6a 00                	push   $0x0
  801c17:	e8 37 f0 ff ff       	call   800c53 <sys_page_unmap>
  801c1c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c1f:	83 ec 08             	sub    $0x8,%esp
  801c22:	ff 75 f0             	pushl  -0x10(%ebp)
  801c25:	6a 00                	push   $0x0
  801c27:	e8 27 f0 ff ff       	call   800c53 <sys_page_unmap>
  801c2c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c2f:	83 ec 08             	sub    $0x8,%esp
  801c32:	ff 75 f4             	pushl  -0xc(%ebp)
  801c35:	6a 00                	push   $0x0
  801c37:	e8 17 f0 ff ff       	call   800c53 <sys_page_unmap>
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c41:	89 d0                	mov    %edx,%eax
  801c43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c46:	5b                   	pop    %ebx
  801c47:	5e                   	pop    %esi
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c53:	50                   	push   %eax
  801c54:	ff 75 08             	pushl  0x8(%ebp)
  801c57:	e8 24 f5 ff ff       	call   801180 <fd_lookup>
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	78 18                	js     801c7b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c63:	83 ec 0c             	sub    $0xc,%esp
  801c66:	ff 75 f4             	pushl  -0xc(%ebp)
  801c69:	e8 ac f4 ff ff       	call   80111a <fd2data>
	return _pipeisclosed(fd, p);
  801c6e:	89 c2                	mov    %eax,%edx
  801c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c73:	e8 21 fd ff ff       	call   801999 <_pipeisclosed>
  801c78:	83 c4 10             	add    $0x10,%esp
}
  801c7b:	c9                   	leave  
  801c7c:	c3                   	ret    

00801c7d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c83:	68 46 2c 80 00       	push   $0x802c46
  801c88:	ff 75 0c             	pushl  0xc(%ebp)
  801c8b:	e8 3b eb ff ff       	call   8007cb <strcpy>
	return 0;
}
  801c90:	b8 00 00 00 00       	mov    $0x0,%eax
  801c95:	c9                   	leave  
  801c96:	c3                   	ret    

00801c97 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	53                   	push   %ebx
  801c9b:	83 ec 10             	sub    $0x10,%esp
  801c9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ca1:	53                   	push   %ebx
  801ca2:	e8 54 07 00 00       	call   8023fb <pageref>
  801ca7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801caa:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801caf:	83 f8 01             	cmp    $0x1,%eax
  801cb2:	75 10                	jne    801cc4 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801cb4:	83 ec 0c             	sub    $0xc,%esp
  801cb7:	ff 73 0c             	pushl  0xc(%ebx)
  801cba:	e8 c0 02 00 00       	call   801f7f <nsipc_close>
  801cbf:	89 c2                	mov    %eax,%edx
  801cc1:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801cc4:	89 d0                	mov    %edx,%eax
  801cc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cd1:	6a 00                	push   $0x0
  801cd3:	ff 75 10             	pushl  0x10(%ebp)
  801cd6:	ff 75 0c             	pushl  0xc(%ebp)
  801cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdc:	ff 70 0c             	pushl  0xc(%eax)
  801cdf:	e8 78 03 00 00       	call   80205c <nsipc_send>
}
  801ce4:	c9                   	leave  
  801ce5:	c3                   	ret    

00801ce6 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cec:	6a 00                	push   $0x0
  801cee:	ff 75 10             	pushl  0x10(%ebp)
  801cf1:	ff 75 0c             	pushl  0xc(%ebp)
  801cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf7:	ff 70 0c             	pushl  0xc(%eax)
  801cfa:	e8 f1 02 00 00       	call   801ff0 <nsipc_recv>
}
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d07:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d0a:	52                   	push   %edx
  801d0b:	50                   	push   %eax
  801d0c:	e8 6f f4 ff ff       	call   801180 <fd_lookup>
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	85 c0                	test   %eax,%eax
  801d16:	78 17                	js     801d2f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1b:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801d21:	39 08                	cmp    %ecx,(%eax)
  801d23:	75 05                	jne    801d2a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d25:	8b 40 0c             	mov    0xc(%eax),%eax
  801d28:	eb 05                	jmp    801d2f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d2a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	56                   	push   %esi
  801d35:	53                   	push   %ebx
  801d36:	83 ec 1c             	sub    $0x1c,%esp
  801d39:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3e:	50                   	push   %eax
  801d3f:	e8 ed f3 ff ff       	call   801131 <fd_alloc>
  801d44:	89 c3                	mov    %eax,%ebx
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	78 1b                	js     801d68 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d4d:	83 ec 04             	sub    $0x4,%esp
  801d50:	68 07 04 00 00       	push   $0x407
  801d55:	ff 75 f4             	pushl  -0xc(%ebp)
  801d58:	6a 00                	push   $0x0
  801d5a:	e8 6f ee ff ff       	call   800bce <sys_page_alloc>
  801d5f:	89 c3                	mov    %eax,%ebx
  801d61:	83 c4 10             	add    $0x10,%esp
  801d64:	85 c0                	test   %eax,%eax
  801d66:	79 10                	jns    801d78 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d68:	83 ec 0c             	sub    $0xc,%esp
  801d6b:	56                   	push   %esi
  801d6c:	e8 0e 02 00 00       	call   801f7f <nsipc_close>
		return r;
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	89 d8                	mov    %ebx,%eax
  801d76:	eb 24                	jmp    801d9c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d78:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d81:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d86:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d8d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d90:	83 ec 0c             	sub    $0xc,%esp
  801d93:	50                   	push   %eax
  801d94:	e8 71 f3 ff ff       	call   80110a <fd2num>
  801d99:	83 c4 10             	add    $0x10,%esp
}
  801d9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801da9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dac:	e8 50 ff ff ff       	call   801d01 <fd2sockid>
		return r;
  801db1:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801db3:	85 c0                	test   %eax,%eax
  801db5:	78 1f                	js     801dd6 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801db7:	83 ec 04             	sub    $0x4,%esp
  801dba:	ff 75 10             	pushl  0x10(%ebp)
  801dbd:	ff 75 0c             	pushl  0xc(%ebp)
  801dc0:	50                   	push   %eax
  801dc1:	e8 12 01 00 00       	call   801ed8 <nsipc_accept>
  801dc6:	83 c4 10             	add    $0x10,%esp
		return r;
  801dc9:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 07                	js     801dd6 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801dcf:	e8 5d ff ff ff       	call   801d31 <alloc_sockfd>
  801dd4:	89 c1                	mov    %eax,%ecx
}
  801dd6:	89 c8                	mov    %ecx,%eax
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    

00801dda <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801de0:	8b 45 08             	mov    0x8(%ebp),%eax
  801de3:	e8 19 ff ff ff       	call   801d01 <fd2sockid>
  801de8:	85 c0                	test   %eax,%eax
  801dea:	78 12                	js     801dfe <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801dec:	83 ec 04             	sub    $0x4,%esp
  801def:	ff 75 10             	pushl  0x10(%ebp)
  801df2:	ff 75 0c             	pushl  0xc(%ebp)
  801df5:	50                   	push   %eax
  801df6:	e8 2d 01 00 00       	call   801f28 <nsipc_bind>
  801dfb:	83 c4 10             	add    $0x10,%esp
}
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <shutdown>:

int
shutdown(int s, int how)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e06:	8b 45 08             	mov    0x8(%ebp),%eax
  801e09:	e8 f3 fe ff ff       	call   801d01 <fd2sockid>
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	78 0f                	js     801e21 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e12:	83 ec 08             	sub    $0x8,%esp
  801e15:	ff 75 0c             	pushl  0xc(%ebp)
  801e18:	50                   	push   %eax
  801e19:	e8 3f 01 00 00       	call   801f5d <nsipc_shutdown>
  801e1e:	83 c4 10             	add    $0x10,%esp
}
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e29:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2c:	e8 d0 fe ff ff       	call   801d01 <fd2sockid>
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 12                	js     801e47 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e35:	83 ec 04             	sub    $0x4,%esp
  801e38:	ff 75 10             	pushl  0x10(%ebp)
  801e3b:	ff 75 0c             	pushl  0xc(%ebp)
  801e3e:	50                   	push   %eax
  801e3f:	e8 55 01 00 00       	call   801f99 <nsipc_connect>
  801e44:	83 c4 10             	add    $0x10,%esp
}
  801e47:	c9                   	leave  
  801e48:	c3                   	ret    

00801e49 <listen>:

int
listen(int s, int backlog)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e52:	e8 aa fe ff ff       	call   801d01 <fd2sockid>
  801e57:	85 c0                	test   %eax,%eax
  801e59:	78 0f                	js     801e6a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	ff 75 0c             	pushl  0xc(%ebp)
  801e61:	50                   	push   %eax
  801e62:	e8 67 01 00 00       	call   801fce <nsipc_listen>
  801e67:	83 c4 10             	add    $0x10,%esp
}
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e72:	ff 75 10             	pushl  0x10(%ebp)
  801e75:	ff 75 0c             	pushl  0xc(%ebp)
  801e78:	ff 75 08             	pushl  0x8(%ebp)
  801e7b:	e8 3a 02 00 00       	call   8020ba <nsipc_socket>
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 05                	js     801e8c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e87:	e8 a5 fe ff ff       	call   801d31 <alloc_sockfd>
}
  801e8c:	c9                   	leave  
  801e8d:	c3                   	ret    

00801e8e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	53                   	push   %ebx
  801e92:	83 ec 04             	sub    $0x4,%esp
  801e95:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e97:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e9e:	75 12                	jne    801eb2 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ea0:	83 ec 0c             	sub    $0xc,%esp
  801ea3:	6a 02                	push   $0x2
  801ea5:	e8 18 05 00 00       	call   8023c2 <ipc_find_env>
  801eaa:	a3 04 40 80 00       	mov    %eax,0x804004
  801eaf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801eb2:	6a 07                	push   $0x7
  801eb4:	68 00 60 80 00       	push   $0x806000
  801eb9:	53                   	push   %ebx
  801eba:	ff 35 04 40 80 00    	pushl  0x804004
  801ec0:	e8 ae 04 00 00       	call   802373 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ec5:	83 c4 0c             	add    $0xc,%esp
  801ec8:	6a 00                	push   $0x0
  801eca:	6a 00                	push   $0x0
  801ecc:	6a 00                	push   $0x0
  801ece:	e8 2a 04 00 00       	call   8022fd <ipc_recv>
}
  801ed3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    

00801ed8 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	56                   	push   %esi
  801edc:	53                   	push   %ebx
  801edd:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ee8:	8b 06                	mov    (%esi),%eax
  801eea:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801eef:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef4:	e8 95 ff ff ff       	call   801e8e <nsipc>
  801ef9:	89 c3                	mov    %eax,%ebx
  801efb:	85 c0                	test   %eax,%eax
  801efd:	78 20                	js     801f1f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801eff:	83 ec 04             	sub    $0x4,%esp
  801f02:	ff 35 10 60 80 00    	pushl  0x806010
  801f08:	68 00 60 80 00       	push   $0x806000
  801f0d:	ff 75 0c             	pushl  0xc(%ebp)
  801f10:	e8 48 ea ff ff       	call   80095d <memmove>
		*addrlen = ret->ret_addrlen;
  801f15:	a1 10 60 80 00       	mov    0x806010,%eax
  801f1a:	89 06                	mov    %eax,(%esi)
  801f1c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f1f:	89 d8                	mov    %ebx,%eax
  801f21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f24:	5b                   	pop    %ebx
  801f25:	5e                   	pop    %esi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    

00801f28 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	53                   	push   %ebx
  801f2c:	83 ec 08             	sub    $0x8,%esp
  801f2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f32:	8b 45 08             	mov    0x8(%ebp),%eax
  801f35:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f3a:	53                   	push   %ebx
  801f3b:	ff 75 0c             	pushl  0xc(%ebp)
  801f3e:	68 04 60 80 00       	push   $0x806004
  801f43:	e8 15 ea ff ff       	call   80095d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f48:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f4e:	b8 02 00 00 00       	mov    $0x2,%eax
  801f53:	e8 36 ff ff ff       	call   801e8e <nsipc>
}
  801f58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f63:	8b 45 08             	mov    0x8(%ebp),%eax
  801f66:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f73:	b8 03 00 00 00       	mov    $0x3,%eax
  801f78:	e8 11 ff ff ff       	call   801e8e <nsipc>
}
  801f7d:	c9                   	leave  
  801f7e:	c3                   	ret    

00801f7f <nsipc_close>:

int
nsipc_close(int s)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f85:	8b 45 08             	mov    0x8(%ebp),%eax
  801f88:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f8d:	b8 04 00 00 00       	mov    $0x4,%eax
  801f92:	e8 f7 fe ff ff       	call   801e8e <nsipc>
}
  801f97:	c9                   	leave  
  801f98:	c3                   	ret    

00801f99 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	53                   	push   %ebx
  801f9d:	83 ec 08             	sub    $0x8,%esp
  801fa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fab:	53                   	push   %ebx
  801fac:	ff 75 0c             	pushl  0xc(%ebp)
  801faf:	68 04 60 80 00       	push   $0x806004
  801fb4:	e8 a4 e9 ff ff       	call   80095d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fb9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fbf:	b8 05 00 00 00       	mov    $0x5,%eax
  801fc4:	e8 c5 fe ff ff       	call   801e8e <nsipc>
}
  801fc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fcc:	c9                   	leave  
  801fcd:	c3                   	ret    

00801fce <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fdf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801fe4:	b8 06 00 00 00       	mov    $0x6,%eax
  801fe9:	e8 a0 fe ff ff       	call   801e8e <nsipc>
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	56                   	push   %esi
  801ff4:	53                   	push   %ebx
  801ff5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ff8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802000:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802006:	8b 45 14             	mov    0x14(%ebp),%eax
  802009:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80200e:	b8 07 00 00 00       	mov    $0x7,%eax
  802013:	e8 76 fe ff ff       	call   801e8e <nsipc>
  802018:	89 c3                	mov    %eax,%ebx
  80201a:	85 c0                	test   %eax,%eax
  80201c:	78 35                	js     802053 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80201e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802023:	7f 04                	jg     802029 <nsipc_recv+0x39>
  802025:	39 c6                	cmp    %eax,%esi
  802027:	7d 16                	jge    80203f <nsipc_recv+0x4f>
  802029:	68 52 2c 80 00       	push   $0x802c52
  80202e:	68 fb 2b 80 00       	push   $0x802bfb
  802033:	6a 62                	push   $0x62
  802035:	68 67 2c 80 00       	push   $0x802c67
  80203a:	e8 0e e1 ff ff       	call   80014d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80203f:	83 ec 04             	sub    $0x4,%esp
  802042:	50                   	push   %eax
  802043:	68 00 60 80 00       	push   $0x806000
  802048:	ff 75 0c             	pushl  0xc(%ebp)
  80204b:	e8 0d e9 ff ff       	call   80095d <memmove>
  802050:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802053:	89 d8                	mov    %ebx,%eax
  802055:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802058:	5b                   	pop    %ebx
  802059:	5e                   	pop    %esi
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    

0080205c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	53                   	push   %ebx
  802060:	83 ec 04             	sub    $0x4,%esp
  802063:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802066:	8b 45 08             	mov    0x8(%ebp),%eax
  802069:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80206e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802074:	7e 16                	jle    80208c <nsipc_send+0x30>
  802076:	68 73 2c 80 00       	push   $0x802c73
  80207b:	68 fb 2b 80 00       	push   $0x802bfb
  802080:	6a 6d                	push   $0x6d
  802082:	68 67 2c 80 00       	push   $0x802c67
  802087:	e8 c1 e0 ff ff       	call   80014d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80208c:	83 ec 04             	sub    $0x4,%esp
  80208f:	53                   	push   %ebx
  802090:	ff 75 0c             	pushl  0xc(%ebp)
  802093:	68 0c 60 80 00       	push   $0x80600c
  802098:	e8 c0 e8 ff ff       	call   80095d <memmove>
	nsipcbuf.send.req_size = size;
  80209d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8020a6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8020b0:	e8 d9 fd ff ff       	call   801e8e <nsipc>
}
  8020b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b8:	c9                   	leave  
  8020b9:	c3                   	ret    

008020ba <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020cb:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8020d8:	b8 09 00 00 00       	mov    $0x9,%eax
  8020dd:	e8 ac fd ff ff       	call   801e8e <nsipc>
}
  8020e2:	c9                   	leave  
  8020e3:	c3                   	ret    

008020e4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    

008020ee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020f4:	68 7f 2c 80 00       	push   $0x802c7f
  8020f9:	ff 75 0c             	pushl  0xc(%ebp)
  8020fc:	e8 ca e6 ff ff       	call   8007cb <strcpy>
	return 0;
}
  802101:	b8 00 00 00 00       	mov    $0x0,%eax
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	57                   	push   %edi
  80210c:	56                   	push   %esi
  80210d:	53                   	push   %ebx
  80210e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802114:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802119:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80211f:	eb 2d                	jmp    80214e <devcons_write+0x46>
		m = n - tot;
  802121:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802124:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802126:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802129:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80212e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802131:	83 ec 04             	sub    $0x4,%esp
  802134:	53                   	push   %ebx
  802135:	03 45 0c             	add    0xc(%ebp),%eax
  802138:	50                   	push   %eax
  802139:	57                   	push   %edi
  80213a:	e8 1e e8 ff ff       	call   80095d <memmove>
		sys_cputs(buf, m);
  80213f:	83 c4 08             	add    $0x8,%esp
  802142:	53                   	push   %ebx
  802143:	57                   	push   %edi
  802144:	e8 c9 e9 ff ff       	call   800b12 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802149:	01 de                	add    %ebx,%esi
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	89 f0                	mov    %esi,%eax
  802150:	3b 75 10             	cmp    0x10(%ebp),%esi
  802153:	72 cc                	jb     802121 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802155:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802158:	5b                   	pop    %ebx
  802159:	5e                   	pop    %esi
  80215a:	5f                   	pop    %edi
  80215b:	5d                   	pop    %ebp
  80215c:	c3                   	ret    

0080215d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80215d:	55                   	push   %ebp
  80215e:	89 e5                	mov    %esp,%ebp
  802160:	83 ec 08             	sub    $0x8,%esp
  802163:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802168:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80216c:	74 2a                	je     802198 <devcons_read+0x3b>
  80216e:	eb 05                	jmp    802175 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802170:	e8 3a ea ff ff       	call   800baf <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802175:	e8 b6 e9 ff ff       	call   800b30 <sys_cgetc>
  80217a:	85 c0                	test   %eax,%eax
  80217c:	74 f2                	je     802170 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80217e:	85 c0                	test   %eax,%eax
  802180:	78 16                	js     802198 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802182:	83 f8 04             	cmp    $0x4,%eax
  802185:	74 0c                	je     802193 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802187:	8b 55 0c             	mov    0xc(%ebp),%edx
  80218a:	88 02                	mov    %al,(%edx)
	return 1;
  80218c:	b8 01 00 00 00       	mov    $0x1,%eax
  802191:	eb 05                	jmp    802198 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802193:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802198:	c9                   	leave  
  802199:	c3                   	ret    

0080219a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021a6:	6a 01                	push   $0x1
  8021a8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ab:	50                   	push   %eax
  8021ac:	e8 61 e9 ff ff       	call   800b12 <sys_cputs>
}
  8021b1:	83 c4 10             	add    $0x10,%esp
  8021b4:	c9                   	leave  
  8021b5:	c3                   	ret    

008021b6 <getchar>:

int
getchar(void)
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021bc:	6a 01                	push   $0x1
  8021be:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021c1:	50                   	push   %eax
  8021c2:	6a 00                	push   $0x0
  8021c4:	e8 1d f2 ff ff       	call   8013e6 <read>
	if (r < 0)
  8021c9:	83 c4 10             	add    $0x10,%esp
  8021cc:	85 c0                	test   %eax,%eax
  8021ce:	78 0f                	js     8021df <getchar+0x29>
		return r;
	if (r < 1)
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	7e 06                	jle    8021da <getchar+0x24>
		return -E_EOF;
	return c;
  8021d4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021d8:	eb 05                	jmp    8021df <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021da:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021df:	c9                   	leave  
  8021e0:	c3                   	ret    

008021e1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ea:	50                   	push   %eax
  8021eb:	ff 75 08             	pushl  0x8(%ebp)
  8021ee:	e8 8d ef ff ff       	call   801180 <fd_lookup>
  8021f3:	83 c4 10             	add    $0x10,%esp
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	78 11                	js     80220b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fd:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802203:	39 10                	cmp    %edx,(%eax)
  802205:	0f 94 c0             	sete   %al
  802208:	0f b6 c0             	movzbl %al,%eax
}
  80220b:	c9                   	leave  
  80220c:	c3                   	ret    

0080220d <opencons>:

int
opencons(void)
{
  80220d:	55                   	push   %ebp
  80220e:	89 e5                	mov    %esp,%ebp
  802210:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802213:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802216:	50                   	push   %eax
  802217:	e8 15 ef ff ff       	call   801131 <fd_alloc>
  80221c:	83 c4 10             	add    $0x10,%esp
		return r;
  80221f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802221:	85 c0                	test   %eax,%eax
  802223:	78 3e                	js     802263 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802225:	83 ec 04             	sub    $0x4,%esp
  802228:	68 07 04 00 00       	push   $0x407
  80222d:	ff 75 f4             	pushl  -0xc(%ebp)
  802230:	6a 00                	push   $0x0
  802232:	e8 97 e9 ff ff       	call   800bce <sys_page_alloc>
  802237:	83 c4 10             	add    $0x10,%esp
		return r;
  80223a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80223c:	85 c0                	test   %eax,%eax
  80223e:	78 23                	js     802263 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802240:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802246:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802249:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80224b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802255:	83 ec 0c             	sub    $0xc,%esp
  802258:	50                   	push   %eax
  802259:	e8 ac ee ff ff       	call   80110a <fd2num>
  80225e:	89 c2                	mov    %eax,%edx
  802260:	83 c4 10             	add    $0x10,%esp
}
  802263:	89 d0                	mov    %edx,%eax
  802265:	c9                   	leave  
  802266:	c3                   	ret    

00802267 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802267:	55                   	push   %ebp
  802268:	89 e5                	mov    %esp,%ebp
  80226a:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  80226d:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802274:	75 56                	jne    8022cc <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  802276:	83 ec 04             	sub    $0x4,%esp
  802279:	6a 07                	push   $0x7
  80227b:	68 00 f0 bf ee       	push   $0xeebff000
  802280:	6a 00                	push   $0x0
  802282:	e8 47 e9 ff ff       	call   800bce <sys_page_alloc>
  802287:	83 c4 10             	add    $0x10,%esp
  80228a:	85 c0                	test   %eax,%eax
  80228c:	74 14                	je     8022a2 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  80228e:	83 ec 04             	sub    $0x4,%esp
  802291:	68 09 2b 80 00       	push   $0x802b09
  802296:	6a 21                	push   $0x21
  802298:	68 8b 2c 80 00       	push   $0x802c8b
  80229d:	e8 ab de ff ff       	call   80014d <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  8022a2:	83 ec 08             	sub    $0x8,%esp
  8022a5:	68 d6 22 80 00       	push   $0x8022d6
  8022aa:	6a 00                	push   $0x0
  8022ac:	e8 68 ea ff ff       	call   800d19 <sys_env_set_pgfault_upcall>
  8022b1:	83 c4 10             	add    $0x10,%esp
  8022b4:	85 c0                	test   %eax,%eax
  8022b6:	74 14                	je     8022cc <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  8022b8:	83 ec 04             	sub    $0x4,%esp
  8022bb:	68 99 2c 80 00       	push   $0x802c99
  8022c0:	6a 23                	push   $0x23
  8022c2:	68 8b 2c 80 00       	push   $0x802c8b
  8022c7:	e8 81 de ff ff       	call   80014d <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022cf:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8022d4:	c9                   	leave  
  8022d5:	c3                   	ret    

008022d6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022d6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022d7:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022dc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022de:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  8022e1:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  8022e3:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  8022e7:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8022eb:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  8022ec:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  8022ee:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  8022f3:	83 c4 08             	add    $0x8,%esp
	popal
  8022f6:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8022f7:	83 c4 04             	add    $0x4,%esp
	popfl
  8022fa:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8022fb:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022fc:	c3                   	ret    

008022fd <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	56                   	push   %esi
  802301:	53                   	push   %ebx
  802302:	8b 75 08             	mov    0x8(%ebp),%esi
  802305:	8b 45 0c             	mov    0xc(%ebp),%eax
  802308:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  80230b:	85 c0                	test   %eax,%eax
  80230d:	74 0e                	je     80231d <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  80230f:	83 ec 0c             	sub    $0xc,%esp
  802312:	50                   	push   %eax
  802313:	e8 66 ea ff ff       	call   800d7e <sys_ipc_recv>
  802318:	83 c4 10             	add    $0x10,%esp
  80231b:	eb 10                	jmp    80232d <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  80231d:	83 ec 0c             	sub    $0xc,%esp
  802320:	68 00 00 c0 ee       	push   $0xeec00000
  802325:	e8 54 ea ff ff       	call   800d7e <sys_ipc_recv>
  80232a:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  80232d:	85 c0                	test   %eax,%eax
  80232f:	79 17                	jns    802348 <ipc_recv+0x4b>
		if(*from_env_store)
  802331:	83 3e 00             	cmpl   $0x0,(%esi)
  802334:	74 06                	je     80233c <ipc_recv+0x3f>
			*from_env_store = 0;
  802336:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  80233c:	85 db                	test   %ebx,%ebx
  80233e:	74 2c                	je     80236c <ipc_recv+0x6f>
			*perm_store = 0;
  802340:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802346:	eb 24                	jmp    80236c <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  802348:	85 f6                	test   %esi,%esi
  80234a:	74 0a                	je     802356 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  80234c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802351:	8b 40 74             	mov    0x74(%eax),%eax
  802354:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802356:	85 db                	test   %ebx,%ebx
  802358:	74 0a                	je     802364 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  80235a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80235f:	8b 40 78             	mov    0x78(%eax),%eax
  802362:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802364:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802369:	8b 40 70             	mov    0x70(%eax),%eax
}
  80236c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80236f:	5b                   	pop    %ebx
  802370:	5e                   	pop    %esi
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    

00802373 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802373:	55                   	push   %ebp
  802374:	89 e5                	mov    %esp,%ebp
  802376:	57                   	push   %edi
  802377:	56                   	push   %esi
  802378:	53                   	push   %ebx
  802379:	83 ec 0c             	sub    $0xc,%esp
  80237c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80237f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802382:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802385:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  802387:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  80238c:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  80238f:	e8 1b e8 ff ff       	call   800baf <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  802394:	ff 75 14             	pushl  0x14(%ebp)
  802397:	53                   	push   %ebx
  802398:	56                   	push   %esi
  802399:	57                   	push   %edi
  80239a:	e8 bc e9 ff ff       	call   800d5b <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  80239f:	89 c2                	mov    %eax,%edx
  8023a1:	f7 d2                	not    %edx
  8023a3:	c1 ea 1f             	shr    $0x1f,%edx
  8023a6:	83 c4 10             	add    $0x10,%esp
  8023a9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023ac:	0f 94 c1             	sete   %cl
  8023af:	09 ca                	or     %ecx,%edx
  8023b1:	85 c0                	test   %eax,%eax
  8023b3:	0f 94 c0             	sete   %al
  8023b6:	38 c2                	cmp    %al,%dl
  8023b8:	77 d5                	ja     80238f <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8023ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023bd:	5b                   	pop    %ebx
  8023be:	5e                   	pop    %esi
  8023bf:	5f                   	pop    %edi
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    

008023c2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023c2:	55                   	push   %ebp
  8023c3:	89 e5                	mov    %esp,%ebp
  8023c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023c8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023cd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023d0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023d6:	8b 52 50             	mov    0x50(%edx),%edx
  8023d9:	39 ca                	cmp    %ecx,%edx
  8023db:	75 0d                	jne    8023ea <ipc_find_env+0x28>
			return envs[i].env_id;
  8023dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023e5:	8b 40 48             	mov    0x48(%eax),%eax
  8023e8:	eb 0f                	jmp    8023f9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023ea:	83 c0 01             	add    $0x1,%eax
  8023ed:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023f2:	75 d9                	jne    8023cd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023f9:	5d                   	pop    %ebp
  8023fa:	c3                   	ret    

008023fb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023fb:	55                   	push   %ebp
  8023fc:	89 e5                	mov    %esp,%ebp
  8023fe:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802401:	89 d0                	mov    %edx,%eax
  802403:	c1 e8 16             	shr    $0x16,%eax
  802406:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80240d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802412:	f6 c1 01             	test   $0x1,%cl
  802415:	74 1d                	je     802434 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802417:	c1 ea 0c             	shr    $0xc,%edx
  80241a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802421:	f6 c2 01             	test   $0x1,%dl
  802424:	74 0e                	je     802434 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802426:	c1 ea 0c             	shr    $0xc,%edx
  802429:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802430:	ef 
  802431:	0f b7 c0             	movzwl %ax,%eax
}
  802434:	5d                   	pop    %ebp
  802435:	c3                   	ret    
  802436:	66 90                	xchg   %ax,%ax
  802438:	66 90                	xchg   %ax,%ax
  80243a:	66 90                	xchg   %ax,%ax
  80243c:	66 90                	xchg   %ax,%ax
  80243e:	66 90                	xchg   %ax,%ax

00802440 <__udivdi3>:
  802440:	55                   	push   %ebp
  802441:	57                   	push   %edi
  802442:	56                   	push   %esi
  802443:	53                   	push   %ebx
  802444:	83 ec 1c             	sub    $0x1c,%esp
  802447:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80244b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80244f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802453:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802457:	85 f6                	test   %esi,%esi
  802459:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80245d:	89 ca                	mov    %ecx,%edx
  80245f:	89 f8                	mov    %edi,%eax
  802461:	75 3d                	jne    8024a0 <__udivdi3+0x60>
  802463:	39 cf                	cmp    %ecx,%edi
  802465:	0f 87 c5 00 00 00    	ja     802530 <__udivdi3+0xf0>
  80246b:	85 ff                	test   %edi,%edi
  80246d:	89 fd                	mov    %edi,%ebp
  80246f:	75 0b                	jne    80247c <__udivdi3+0x3c>
  802471:	b8 01 00 00 00       	mov    $0x1,%eax
  802476:	31 d2                	xor    %edx,%edx
  802478:	f7 f7                	div    %edi
  80247a:	89 c5                	mov    %eax,%ebp
  80247c:	89 c8                	mov    %ecx,%eax
  80247e:	31 d2                	xor    %edx,%edx
  802480:	f7 f5                	div    %ebp
  802482:	89 c1                	mov    %eax,%ecx
  802484:	89 d8                	mov    %ebx,%eax
  802486:	89 cf                	mov    %ecx,%edi
  802488:	f7 f5                	div    %ebp
  80248a:	89 c3                	mov    %eax,%ebx
  80248c:	89 d8                	mov    %ebx,%eax
  80248e:	89 fa                	mov    %edi,%edx
  802490:	83 c4 1c             	add    $0x1c,%esp
  802493:	5b                   	pop    %ebx
  802494:	5e                   	pop    %esi
  802495:	5f                   	pop    %edi
  802496:	5d                   	pop    %ebp
  802497:	c3                   	ret    
  802498:	90                   	nop
  802499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	39 ce                	cmp    %ecx,%esi
  8024a2:	77 74                	ja     802518 <__udivdi3+0xd8>
  8024a4:	0f bd fe             	bsr    %esi,%edi
  8024a7:	83 f7 1f             	xor    $0x1f,%edi
  8024aa:	0f 84 98 00 00 00    	je     802548 <__udivdi3+0x108>
  8024b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	89 c5                	mov    %eax,%ebp
  8024b9:	29 fb                	sub    %edi,%ebx
  8024bb:	d3 e6                	shl    %cl,%esi
  8024bd:	89 d9                	mov    %ebx,%ecx
  8024bf:	d3 ed                	shr    %cl,%ebp
  8024c1:	89 f9                	mov    %edi,%ecx
  8024c3:	d3 e0                	shl    %cl,%eax
  8024c5:	09 ee                	or     %ebp,%esi
  8024c7:	89 d9                	mov    %ebx,%ecx
  8024c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024cd:	89 d5                	mov    %edx,%ebp
  8024cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024d3:	d3 ed                	shr    %cl,%ebp
  8024d5:	89 f9                	mov    %edi,%ecx
  8024d7:	d3 e2                	shl    %cl,%edx
  8024d9:	89 d9                	mov    %ebx,%ecx
  8024db:	d3 e8                	shr    %cl,%eax
  8024dd:	09 c2                	or     %eax,%edx
  8024df:	89 d0                	mov    %edx,%eax
  8024e1:	89 ea                	mov    %ebp,%edx
  8024e3:	f7 f6                	div    %esi
  8024e5:	89 d5                	mov    %edx,%ebp
  8024e7:	89 c3                	mov    %eax,%ebx
  8024e9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ed:	39 d5                	cmp    %edx,%ebp
  8024ef:	72 10                	jb     802501 <__udivdi3+0xc1>
  8024f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024f5:	89 f9                	mov    %edi,%ecx
  8024f7:	d3 e6                	shl    %cl,%esi
  8024f9:	39 c6                	cmp    %eax,%esi
  8024fb:	73 07                	jae    802504 <__udivdi3+0xc4>
  8024fd:	39 d5                	cmp    %edx,%ebp
  8024ff:	75 03                	jne    802504 <__udivdi3+0xc4>
  802501:	83 eb 01             	sub    $0x1,%ebx
  802504:	31 ff                	xor    %edi,%edi
  802506:	89 d8                	mov    %ebx,%eax
  802508:	89 fa                	mov    %edi,%edx
  80250a:	83 c4 1c             	add    $0x1c,%esp
  80250d:	5b                   	pop    %ebx
  80250e:	5e                   	pop    %esi
  80250f:	5f                   	pop    %edi
  802510:	5d                   	pop    %ebp
  802511:	c3                   	ret    
  802512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802518:	31 ff                	xor    %edi,%edi
  80251a:	31 db                	xor    %ebx,%ebx
  80251c:	89 d8                	mov    %ebx,%eax
  80251e:	89 fa                	mov    %edi,%edx
  802520:	83 c4 1c             	add    $0x1c,%esp
  802523:	5b                   	pop    %ebx
  802524:	5e                   	pop    %esi
  802525:	5f                   	pop    %edi
  802526:	5d                   	pop    %ebp
  802527:	c3                   	ret    
  802528:	90                   	nop
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	89 d8                	mov    %ebx,%eax
  802532:	f7 f7                	div    %edi
  802534:	31 ff                	xor    %edi,%edi
  802536:	89 c3                	mov    %eax,%ebx
  802538:	89 d8                	mov    %ebx,%eax
  80253a:	89 fa                	mov    %edi,%edx
  80253c:	83 c4 1c             	add    $0x1c,%esp
  80253f:	5b                   	pop    %ebx
  802540:	5e                   	pop    %esi
  802541:	5f                   	pop    %edi
  802542:	5d                   	pop    %ebp
  802543:	c3                   	ret    
  802544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802548:	39 ce                	cmp    %ecx,%esi
  80254a:	72 0c                	jb     802558 <__udivdi3+0x118>
  80254c:	31 db                	xor    %ebx,%ebx
  80254e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802552:	0f 87 34 ff ff ff    	ja     80248c <__udivdi3+0x4c>
  802558:	bb 01 00 00 00       	mov    $0x1,%ebx
  80255d:	e9 2a ff ff ff       	jmp    80248c <__udivdi3+0x4c>
  802562:	66 90                	xchg   %ax,%ax
  802564:	66 90                	xchg   %ax,%ax
  802566:	66 90                	xchg   %ax,%ax
  802568:	66 90                	xchg   %ax,%ax
  80256a:	66 90                	xchg   %ax,%ax
  80256c:	66 90                	xchg   %ax,%ax
  80256e:	66 90                	xchg   %ax,%ax

00802570 <__umoddi3>:
  802570:	55                   	push   %ebp
  802571:	57                   	push   %edi
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
  802574:	83 ec 1c             	sub    $0x1c,%esp
  802577:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80257b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80257f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802583:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802587:	85 d2                	test   %edx,%edx
  802589:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80258d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802591:	89 f3                	mov    %esi,%ebx
  802593:	89 3c 24             	mov    %edi,(%esp)
  802596:	89 74 24 04          	mov    %esi,0x4(%esp)
  80259a:	75 1c                	jne    8025b8 <__umoddi3+0x48>
  80259c:	39 f7                	cmp    %esi,%edi
  80259e:	76 50                	jbe    8025f0 <__umoddi3+0x80>
  8025a0:	89 c8                	mov    %ecx,%eax
  8025a2:	89 f2                	mov    %esi,%edx
  8025a4:	f7 f7                	div    %edi
  8025a6:	89 d0                	mov    %edx,%eax
  8025a8:	31 d2                	xor    %edx,%edx
  8025aa:	83 c4 1c             	add    $0x1c,%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5f                   	pop    %edi
  8025b0:	5d                   	pop    %ebp
  8025b1:	c3                   	ret    
  8025b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025b8:	39 f2                	cmp    %esi,%edx
  8025ba:	89 d0                	mov    %edx,%eax
  8025bc:	77 52                	ja     802610 <__umoddi3+0xa0>
  8025be:	0f bd ea             	bsr    %edx,%ebp
  8025c1:	83 f5 1f             	xor    $0x1f,%ebp
  8025c4:	75 5a                	jne    802620 <__umoddi3+0xb0>
  8025c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ca:	0f 82 e0 00 00 00    	jb     8026b0 <__umoddi3+0x140>
  8025d0:	39 0c 24             	cmp    %ecx,(%esp)
  8025d3:	0f 86 d7 00 00 00    	jbe    8026b0 <__umoddi3+0x140>
  8025d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025e1:	83 c4 1c             	add    $0x1c,%esp
  8025e4:	5b                   	pop    %ebx
  8025e5:	5e                   	pop    %esi
  8025e6:	5f                   	pop    %edi
  8025e7:	5d                   	pop    %ebp
  8025e8:	c3                   	ret    
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	85 ff                	test   %edi,%edi
  8025f2:	89 fd                	mov    %edi,%ebp
  8025f4:	75 0b                	jne    802601 <__umoddi3+0x91>
  8025f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025fb:	31 d2                	xor    %edx,%edx
  8025fd:	f7 f7                	div    %edi
  8025ff:	89 c5                	mov    %eax,%ebp
  802601:	89 f0                	mov    %esi,%eax
  802603:	31 d2                	xor    %edx,%edx
  802605:	f7 f5                	div    %ebp
  802607:	89 c8                	mov    %ecx,%eax
  802609:	f7 f5                	div    %ebp
  80260b:	89 d0                	mov    %edx,%eax
  80260d:	eb 99                	jmp    8025a8 <__umoddi3+0x38>
  80260f:	90                   	nop
  802610:	89 c8                	mov    %ecx,%eax
  802612:	89 f2                	mov    %esi,%edx
  802614:	83 c4 1c             	add    $0x1c,%esp
  802617:	5b                   	pop    %ebx
  802618:	5e                   	pop    %esi
  802619:	5f                   	pop    %edi
  80261a:	5d                   	pop    %ebp
  80261b:	c3                   	ret    
  80261c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802620:	8b 34 24             	mov    (%esp),%esi
  802623:	bf 20 00 00 00       	mov    $0x20,%edi
  802628:	89 e9                	mov    %ebp,%ecx
  80262a:	29 ef                	sub    %ebp,%edi
  80262c:	d3 e0                	shl    %cl,%eax
  80262e:	89 f9                	mov    %edi,%ecx
  802630:	89 f2                	mov    %esi,%edx
  802632:	d3 ea                	shr    %cl,%edx
  802634:	89 e9                	mov    %ebp,%ecx
  802636:	09 c2                	or     %eax,%edx
  802638:	89 d8                	mov    %ebx,%eax
  80263a:	89 14 24             	mov    %edx,(%esp)
  80263d:	89 f2                	mov    %esi,%edx
  80263f:	d3 e2                	shl    %cl,%edx
  802641:	89 f9                	mov    %edi,%ecx
  802643:	89 54 24 04          	mov    %edx,0x4(%esp)
  802647:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	89 e9                	mov    %ebp,%ecx
  80264f:	89 c6                	mov    %eax,%esi
  802651:	d3 e3                	shl    %cl,%ebx
  802653:	89 f9                	mov    %edi,%ecx
  802655:	89 d0                	mov    %edx,%eax
  802657:	d3 e8                	shr    %cl,%eax
  802659:	89 e9                	mov    %ebp,%ecx
  80265b:	09 d8                	or     %ebx,%eax
  80265d:	89 d3                	mov    %edx,%ebx
  80265f:	89 f2                	mov    %esi,%edx
  802661:	f7 34 24             	divl   (%esp)
  802664:	89 d6                	mov    %edx,%esi
  802666:	d3 e3                	shl    %cl,%ebx
  802668:	f7 64 24 04          	mull   0x4(%esp)
  80266c:	39 d6                	cmp    %edx,%esi
  80266e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802672:	89 d1                	mov    %edx,%ecx
  802674:	89 c3                	mov    %eax,%ebx
  802676:	72 08                	jb     802680 <__umoddi3+0x110>
  802678:	75 11                	jne    80268b <__umoddi3+0x11b>
  80267a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80267e:	73 0b                	jae    80268b <__umoddi3+0x11b>
  802680:	2b 44 24 04          	sub    0x4(%esp),%eax
  802684:	1b 14 24             	sbb    (%esp),%edx
  802687:	89 d1                	mov    %edx,%ecx
  802689:	89 c3                	mov    %eax,%ebx
  80268b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80268f:	29 da                	sub    %ebx,%edx
  802691:	19 ce                	sbb    %ecx,%esi
  802693:	89 f9                	mov    %edi,%ecx
  802695:	89 f0                	mov    %esi,%eax
  802697:	d3 e0                	shl    %cl,%eax
  802699:	89 e9                	mov    %ebp,%ecx
  80269b:	d3 ea                	shr    %cl,%edx
  80269d:	89 e9                	mov    %ebp,%ecx
  80269f:	d3 ee                	shr    %cl,%esi
  8026a1:	09 d0                	or     %edx,%eax
  8026a3:	89 f2                	mov    %esi,%edx
  8026a5:	83 c4 1c             	add    $0x1c,%esp
  8026a8:	5b                   	pop    %ebx
  8026a9:	5e                   	pop    %esi
  8026aa:	5f                   	pop    %edi
  8026ab:	5d                   	pop    %ebp
  8026ac:	c3                   	ret    
  8026ad:	8d 76 00             	lea    0x0(%esi),%esi
  8026b0:	29 f9                	sub    %edi,%ecx
  8026b2:	19 d6                	sbb    %edx,%esi
  8026b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026bc:	e9 18 ff ff ff       	jmp    8025d9 <__umoddi3+0x69>
