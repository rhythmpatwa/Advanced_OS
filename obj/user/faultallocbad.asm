
obj/user/faultallocbad.debug:     file format elf32-i386


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

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 80 23 80 00       	push   $0x802380
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 38 0b 00 00       	call   800b96 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 a0 23 80 00       	push   $0x8023a0
  80006f:	6a 0f                	push   $0xf
  800071:	68 8a 23 80 00       	push   $0x80238a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 cc 23 80 00       	push   $0x8023cc
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 b7 06 00 00       	call   800740 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 05 0d 00 00       	call   800da6 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 2a 0a 00 00       	call   800ada <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
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
  8000c0:	e8 93 0a 00 00       	call   800b58 <sys_getenvid>
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
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

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
  800101:	e8 01 0f 00 00       	call   801007 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 07 0a 00 00       	call   800b17 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 30 0a 00 00       	call   800b58 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 f8 23 80 00       	push   $0x8023f8
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 63 28 80 00 	movl   $0x802863,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 4f 09 00 00       	call   800ada <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 54 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 f4 08 00 00       	call   800ada <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 8a 1e 00 00       	call   8020e0 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 77 1f 00 00       	call   802210 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 1b 24 80 00 	movsbl 0x80241b(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b4:	83 fa 01             	cmp    $0x1,%edx
  8002b7:	7e 0e                	jle    8002c7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	8b 52 04             	mov    0x4(%edx),%edx
  8002c5:	eb 22                	jmp    8002e9 <getuint+0x38>
	else if (lflag)
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 10                	je     8002db <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	eb 0e                	jmp    8002e9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fa:	73 0a                	jae    800306 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	88 02                	mov    %al,(%edx)
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
	va_end(ap);
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
  80032e:	8b 75 08             	mov    0x8(%ebp),%esi
  800331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800334:	8b 7d 10             	mov    0x10(%ebp),%edi
  800337:	eb 12                	jmp    80034b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 84 a9 03 00 00    	je     8006ea <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	53                   	push   %ebx
  800345:	50                   	push   %eax
  800346:	ff d6                	call   *%esi
  800348:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034b:	83 c7 01             	add    $0x1,%edi
  80034e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800352:	83 f8 25             	cmp    $0x25,%eax
  800355:	75 e2                	jne    800339 <vprintfmt+0x14>
  800357:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800369:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	eb 07                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8d 47 01             	lea    0x1(%edi),%eax
  800381:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800384:	0f b6 07             	movzbl (%edi),%eax
  800387:	0f b6 c8             	movzbl %al,%ecx
  80038a:	83 e8 23             	sub    $0x23,%eax
  80038d:	3c 55                	cmp    $0x55,%al
  80038f:	0f 87 3a 03 00 00    	ja     8006cf <vprintfmt+0x3aa>
  800395:	0f b6 c0             	movzbl %al,%eax
  800398:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a6:	eb d6                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c0:	83 fa 09             	cmp    $0x9,%edx
  8003c3:	77 39                	ja     8003fe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c8:	eb e9                	jmp    8003b3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003db:	eb 27                	jmp    800404 <vprintfmt+0xdf>
  8003dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e7:	0f 49 c8             	cmovns %eax,%ecx
  8003ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	eb 8c                	jmp    80037e <vprintfmt+0x59>
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fc:	eb 80                	jmp    80037e <vprintfmt+0x59>
  8003fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800401:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800404:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800408:	0f 89 70 ff ff ff    	jns    80037e <vprintfmt+0x59>
				width = precision, precision = -1;
  80040e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800411:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800414:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041b:	e9 5e ff ff ff       	jmp    80037e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800420:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800426:	e9 53 ff ff ff       	jmp    80037e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 55 14             	mov    %edx,0x14(%ebp)
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	ff 30                	pushl  (%eax)
  80043a:	ff d6                	call   *%esi
			break;
  80043c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800442:	e9 04 ff ff ff       	jmp    80034b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	99                   	cltd   
  800453:	31 d0                	xor    %edx,%eax
  800455:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800457:	83 f8 0f             	cmp    $0xf,%eax
  80045a:	7f 0b                	jg     800467 <vprintfmt+0x142>
  80045c:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  800463:	85 d2                	test   %edx,%edx
  800465:	75 18                	jne    80047f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800467:	50                   	push   %eax
  800468:	68 33 24 80 00       	push   $0x802433
  80046d:	53                   	push   %ebx
  80046e:	56                   	push   %esi
  80046f:	e8 94 fe ff ff       	call   800308 <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047a:	e9 cc fe ff ff       	jmp    80034b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047f:	52                   	push   %edx
  800480:	68 31 28 80 00       	push   $0x802831
  800485:	53                   	push   %ebx
  800486:	56                   	push   %esi
  800487:	e8 7c fe ff ff       	call   800308 <printfmt>
  80048c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	e9 b4 fe ff ff       	jmp    80034b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 50 04             	lea    0x4(%eax),%edx
  80049d:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	b8 2c 24 80 00       	mov    $0x80242c,%eax
  8004a9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b0:	0f 8e 94 00 00 00    	jle    80054a <vprintfmt+0x225>
  8004b6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ba:	0f 84 98 00 00 00    	je     800558 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c6:	57                   	push   %edi
  8004c7:	e8 a6 02 00 00       	call   800772 <strnlen>
  8004cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cf:	29 c1                	sub    %eax,%ecx
  8004d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	eb 0f                	jmp    8004f4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 ef 01             	sub    $0x1,%edi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f ed                	jg     8004e5 <vprintfmt+0x1c0>
  8004f8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004fe:	85 c9                	test   %ecx,%ecx
  800500:	b8 00 00 00 00       	mov    $0x0,%eax
  800505:	0f 49 c1             	cmovns %ecx,%eax
  800508:	29 c1                	sub    %eax,%ecx
  80050a:	89 75 08             	mov    %esi,0x8(%ebp)
  80050d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800510:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800513:	89 cb                	mov    %ecx,%ebx
  800515:	eb 4d                	jmp    800564 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800517:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051b:	74 1b                	je     800538 <vprintfmt+0x213>
  80051d:	0f be c0             	movsbl %al,%eax
  800520:	83 e8 20             	sub    $0x20,%eax
  800523:	83 f8 5e             	cmp    $0x5e,%eax
  800526:	76 10                	jbe    800538 <vprintfmt+0x213>
					putch('?', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	ff 75 0c             	pushl  0xc(%ebp)
  80052e:	6a 3f                	push   $0x3f
  800530:	ff 55 08             	call   *0x8(%ebp)
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	eb 0d                	jmp    800545 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	52                   	push   %edx
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800545:	83 eb 01             	sub    $0x1,%ebx
  800548:	eb 1a                	jmp    800564 <vprintfmt+0x23f>
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800550:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800553:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800556:	eb 0c                	jmp    800564 <vprintfmt+0x23f>
  800558:	89 75 08             	mov    %esi,0x8(%ebp)
  80055b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800561:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056b:	0f be d0             	movsbl %al,%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	74 23                	je     800595 <vprintfmt+0x270>
  800572:	85 f6                	test   %esi,%esi
  800574:	78 a1                	js     800517 <vprintfmt+0x1f2>
  800576:	83 ee 01             	sub    $0x1,%esi
  800579:	79 9c                	jns    800517 <vprintfmt+0x1f2>
  80057b:	89 df                	mov    %ebx,%edi
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	eb 18                	jmp    80059d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	53                   	push   %ebx
  800589:	6a 20                	push   $0x20
  80058b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058d:	83 ef 01             	sub    $0x1,%edi
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	eb 08                	jmp    80059d <vprintfmt+0x278>
  800595:	89 df                	mov    %ebx,%edi
  800597:	8b 75 08             	mov    0x8(%ebp),%esi
  80059a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059d:	85 ff                	test   %edi,%edi
  80059f:	7f e4                	jg     800585 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a4:	e9 a2 fd ff ff       	jmp    80034b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a9:	83 fa 01             	cmp    $0x1,%edx
  8005ac:	7e 16                	jle    8005c4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 08             	lea    0x8(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 50 04             	mov    0x4(%eax),%edx
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c2:	eb 32                	jmp    8005f6 <vprintfmt+0x2d1>
	else if (lflag)
  8005c4:	85 d2                	test   %edx,%edx
  8005c6:	74 18                	je     8005e0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005de:	eb 16                	jmp    8005f6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800601:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800605:	0f 89 90 00 00 00    	jns    80069b <vprintfmt+0x376>
				putch('-', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 2d                	push   $0x2d
  800611:	ff d6                	call   *%esi
				num = -(long long) num;
  800613:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800616:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800619:	f7 d8                	neg    %eax
  80061b:	83 d2 00             	adc    $0x0,%edx
  80061e:	f7 da                	neg    %edx
  800620:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800623:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800628:	eb 71                	jmp    80069b <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 7f fc ff ff       	call   8002b1 <getuint>
			base = 10;
  800632:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800637:	eb 62                	jmp    80069b <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800639:	8d 45 14             	lea    0x14(%ebp),%eax
  80063c:	e8 70 fc ff ff       	call   8002b1 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800641:	83 ec 0c             	sub    $0xc,%esp
  800644:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800648:	51                   	push   %ecx
  800649:	ff 75 e0             	pushl  -0x20(%ebp)
  80064c:	6a 08                	push   $0x8
  80064e:	52                   	push   %edx
  80064f:	50                   	push   %eax
  800650:	89 da                	mov    %ebx,%edx
  800652:	89 f0                	mov    %esi,%eax
  800654:	e8 a9 fb ff ff       	call   800202 <printnum>
			break;
  800659:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  80065f:	e9 e7 fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	6a 30                	push   $0x30
  80066a:	ff d6                	call   *%esi
			putch('x', putdat);
  80066c:	83 c4 08             	add    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 78                	push   $0x78
  800672:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 04             	lea    0x4(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800684:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800687:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068c:	eb 0d                	jmp    80069b <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 1b fc ff ff       	call   8002b1 <getuint>
			base = 16;
  800696:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a2:	57                   	push   %edi
  8006a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a6:	51                   	push   %ecx
  8006a7:	52                   	push   %edx
  8006a8:	50                   	push   %eax
  8006a9:	89 da                	mov    %ebx,%edx
  8006ab:	89 f0                	mov    %esi,%eax
  8006ad:	e8 50 fb ff ff       	call   800202 <printnum>
			break;
  8006b2:	83 c4 20             	add    $0x20,%esp
  8006b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b8:	e9 8e fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	51                   	push   %ecx
  8006c2:	ff d6                	call   *%esi
			break;
  8006c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ca:	e9 7c fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	6a 25                	push   $0x25
  8006d5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	eb 03                	jmp    8006df <vprintfmt+0x3ba>
  8006dc:	83 ef 01             	sub    $0x1,%edi
  8006df:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e3:	75 f7                	jne    8006dc <vprintfmt+0x3b7>
  8006e5:	e9 61 fc ff ff       	jmp    80034b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ed:	5b                   	pop    %ebx
  8006ee:	5e                   	pop    %esi
  8006ef:	5f                   	pop    %edi
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 18             	sub    $0x18,%esp
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800701:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800705:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800708:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070f:	85 c0                	test   %eax,%eax
  800711:	74 26                	je     800739 <vsnprintf+0x47>
  800713:	85 d2                	test   %edx,%edx
  800715:	7e 22                	jle    800739 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800717:	ff 75 14             	pushl  0x14(%ebp)
  80071a:	ff 75 10             	pushl  0x10(%ebp)
  80071d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	68 eb 02 80 00       	push   $0x8002eb
  800726:	e8 fa fb ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800731:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	eb 05                	jmp    80073e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800739:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    

00800740 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800749:	50                   	push   %eax
  80074a:	ff 75 10             	pushl  0x10(%ebp)
  80074d:	ff 75 0c             	pushl  0xc(%ebp)
  800750:	ff 75 08             	pushl  0x8(%ebp)
  800753:	e8 9a ff ff ff       	call   8006f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800760:	b8 00 00 00 00       	mov    $0x0,%eax
  800765:	eb 03                	jmp    80076a <strlen+0x10>
		n++;
  800767:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076e:	75 f7                	jne    800767 <strlen+0xd>
		n++;
	return n;
}
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800778:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077b:	ba 00 00 00 00       	mov    $0x0,%edx
  800780:	eb 03                	jmp    800785 <strnlen+0x13>
		n++;
  800782:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800785:	39 c2                	cmp    %eax,%edx
  800787:	74 08                	je     800791 <strnlen+0x1f>
  800789:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078d:	75 f3                	jne    800782 <strnlen+0x10>
  80078f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 45 08             	mov    0x8(%ebp),%eax
  80079a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c2 01             	add    $0x1,%edx
  8007a2:	83 c1 01             	add    $0x1,%ecx
  8007a5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ac:	84 db                	test   %bl,%bl
  8007ae:	75 ef                	jne    80079f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b0:	5b                   	pop    %ebx
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ba:	53                   	push   %ebx
  8007bb:	e8 9a ff ff ff       	call   80075a <strlen>
  8007c0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c3:	ff 75 0c             	pushl  0xc(%ebp)
  8007c6:	01 d8                	add    %ebx,%eax
  8007c8:	50                   	push   %eax
  8007c9:	e8 c5 ff ff ff       	call   800793 <strcpy>
	return dst;
}
  8007ce:	89 d8                	mov    %ebx,%eax
  8007d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	56                   	push   %esi
  8007d9:	53                   	push   %ebx
  8007da:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e0:	89 f3                	mov    %esi,%ebx
  8007e2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e5:	89 f2                	mov    %esi,%edx
  8007e7:	eb 0f                	jmp    8007f8 <strncpy+0x23>
		*dst++ = *src;
  8007e9:	83 c2 01             	add    $0x1,%edx
  8007ec:	0f b6 01             	movzbl (%ecx),%eax
  8007ef:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f8:	39 da                	cmp    %ebx,%edx
  8007fa:	75 ed                	jne    8007e9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fc:	89 f0                	mov    %esi,%eax
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 75 08             	mov    0x8(%ebp),%esi
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080d:	8b 55 10             	mov    0x10(%ebp),%edx
  800810:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800812:	85 d2                	test   %edx,%edx
  800814:	74 21                	je     800837 <strlcpy+0x35>
  800816:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081a:	89 f2                	mov    %esi,%edx
  80081c:	eb 09                	jmp    800827 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081e:	83 c2 01             	add    $0x1,%edx
  800821:	83 c1 01             	add    $0x1,%ecx
  800824:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800827:	39 c2                	cmp    %eax,%edx
  800829:	74 09                	je     800834 <strlcpy+0x32>
  80082b:	0f b6 19             	movzbl (%ecx),%ebx
  80082e:	84 db                	test   %bl,%bl
  800830:	75 ec                	jne    80081e <strlcpy+0x1c>
  800832:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800834:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800837:	29 f0                	sub    %esi,%eax
}
  800839:	5b                   	pop    %ebx
  80083a:	5e                   	pop    %esi
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800846:	eb 06                	jmp    80084e <strcmp+0x11>
		p++, q++;
  800848:	83 c1 01             	add    $0x1,%ecx
  80084b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084e:	0f b6 01             	movzbl (%ecx),%eax
  800851:	84 c0                	test   %al,%al
  800853:	74 04                	je     800859 <strcmp+0x1c>
  800855:	3a 02                	cmp    (%edx),%al
  800857:	74 ef                	je     800848 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800859:	0f b6 c0             	movzbl %al,%eax
  80085c:	0f b6 12             	movzbl (%edx),%edx
  80085f:	29 d0                	sub    %edx,%eax
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086d:	89 c3                	mov    %eax,%ebx
  80086f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800872:	eb 06                	jmp    80087a <strncmp+0x17>
		n--, p++, q++;
  800874:	83 c0 01             	add    $0x1,%eax
  800877:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087a:	39 d8                	cmp    %ebx,%eax
  80087c:	74 15                	je     800893 <strncmp+0x30>
  80087e:	0f b6 08             	movzbl (%eax),%ecx
  800881:	84 c9                	test   %cl,%cl
  800883:	74 04                	je     800889 <strncmp+0x26>
  800885:	3a 0a                	cmp    (%edx),%cl
  800887:	74 eb                	je     800874 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800889:	0f b6 00             	movzbl (%eax),%eax
  80088c:	0f b6 12             	movzbl (%edx),%edx
  80088f:	29 d0                	sub    %edx,%eax
  800891:	eb 05                	jmp    800898 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a5:	eb 07                	jmp    8008ae <strchr+0x13>
		if (*s == c)
  8008a7:	38 ca                	cmp    %cl,%dl
  8008a9:	74 0f                	je     8008ba <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	0f b6 10             	movzbl (%eax),%edx
  8008b1:	84 d2                	test   %dl,%dl
  8008b3:	75 f2                	jne    8008a7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c6:	eb 03                	jmp    8008cb <strfind+0xf>
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ce:	38 ca                	cmp    %cl,%dl
  8008d0:	74 04                	je     8008d6 <strfind+0x1a>
  8008d2:	84 d2                	test   %dl,%dl
  8008d4:	75 f2                	jne    8008c8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	57                   	push   %edi
  8008dc:	56                   	push   %esi
  8008dd:	53                   	push   %ebx
  8008de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e4:	85 c9                	test   %ecx,%ecx
  8008e6:	74 36                	je     80091e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ee:	75 28                	jne    800918 <memset+0x40>
  8008f0:	f6 c1 03             	test   $0x3,%cl
  8008f3:	75 23                	jne    800918 <memset+0x40>
		c &= 0xFF;
  8008f5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f9:	89 d3                	mov    %edx,%ebx
  8008fb:	c1 e3 08             	shl    $0x8,%ebx
  8008fe:	89 d6                	mov    %edx,%esi
  800900:	c1 e6 18             	shl    $0x18,%esi
  800903:	89 d0                	mov    %edx,%eax
  800905:	c1 e0 10             	shl    $0x10,%eax
  800908:	09 f0                	or     %esi,%eax
  80090a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090c:	89 d8                	mov    %ebx,%eax
  80090e:	09 d0                	or     %edx,%eax
  800910:	c1 e9 02             	shr    $0x2,%ecx
  800913:	fc                   	cld    
  800914:	f3 ab                	rep stos %eax,%es:(%edi)
  800916:	eb 06                	jmp    80091e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800918:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091b:	fc                   	cld    
  80091c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091e:	89 f8                	mov    %edi,%eax
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5f                   	pop    %edi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800930:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800933:	39 c6                	cmp    %eax,%esi
  800935:	73 35                	jae    80096c <memmove+0x47>
  800937:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093a:	39 d0                	cmp    %edx,%eax
  80093c:	73 2e                	jae    80096c <memmove+0x47>
		s += n;
		d += n;
  80093e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800941:	89 d6                	mov    %edx,%esi
  800943:	09 fe                	or     %edi,%esi
  800945:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094b:	75 13                	jne    800960 <memmove+0x3b>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	75 0e                	jne    800960 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800952:	83 ef 04             	sub    $0x4,%edi
  800955:	8d 72 fc             	lea    -0x4(%edx),%esi
  800958:	c1 e9 02             	shr    $0x2,%ecx
  80095b:	fd                   	std    
  80095c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095e:	eb 09                	jmp    800969 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800960:	83 ef 01             	sub    $0x1,%edi
  800963:	8d 72 ff             	lea    -0x1(%edx),%esi
  800966:	fd                   	std    
  800967:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800969:	fc                   	cld    
  80096a:	eb 1d                	jmp    800989 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096c:	89 f2                	mov    %esi,%edx
  80096e:	09 c2                	or     %eax,%edx
  800970:	f6 c2 03             	test   $0x3,%dl
  800973:	75 0f                	jne    800984 <memmove+0x5f>
  800975:	f6 c1 03             	test   $0x3,%cl
  800978:	75 0a                	jne    800984 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097a:	c1 e9 02             	shr    $0x2,%ecx
  80097d:	89 c7                	mov    %eax,%edi
  80097f:	fc                   	cld    
  800980:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800982:	eb 05                	jmp    800989 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800984:	89 c7                	mov    %eax,%edi
  800986:	fc                   	cld    
  800987:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800989:	5e                   	pop    %esi
  80098a:	5f                   	pop    %edi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800990:	ff 75 10             	pushl  0x10(%ebp)
  800993:	ff 75 0c             	pushl  0xc(%ebp)
  800996:	ff 75 08             	pushl  0x8(%ebp)
  800999:	e8 87 ff ff ff       	call   800925 <memmove>
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ab:	89 c6                	mov    %eax,%esi
  8009ad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b0:	eb 1a                	jmp    8009cc <memcmp+0x2c>
		if (*s1 != *s2)
  8009b2:	0f b6 08             	movzbl (%eax),%ecx
  8009b5:	0f b6 1a             	movzbl (%edx),%ebx
  8009b8:	38 d9                	cmp    %bl,%cl
  8009ba:	74 0a                	je     8009c6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bc:	0f b6 c1             	movzbl %cl,%eax
  8009bf:	0f b6 db             	movzbl %bl,%ebx
  8009c2:	29 d8                	sub    %ebx,%eax
  8009c4:	eb 0f                	jmp    8009d5 <memcmp+0x35>
		s1++, s2++;
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cc:	39 f0                	cmp    %esi,%eax
  8009ce:	75 e2                	jne    8009b2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	53                   	push   %ebx
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e0:	89 c1                	mov    %eax,%ecx
  8009e2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e9:	eb 0a                	jmp    8009f5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009eb:	0f b6 10             	movzbl (%eax),%edx
  8009ee:	39 da                	cmp    %ebx,%edx
  8009f0:	74 07                	je     8009f9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f2:	83 c0 01             	add    $0x1,%eax
  8009f5:	39 c8                	cmp    %ecx,%eax
  8009f7:	72 f2                	jb     8009eb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f9:	5b                   	pop    %ebx
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a08:	eb 03                	jmp    800a0d <strtol+0x11>
		s++;
  800a0a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0d:	0f b6 01             	movzbl (%ecx),%eax
  800a10:	3c 20                	cmp    $0x20,%al
  800a12:	74 f6                	je     800a0a <strtol+0xe>
  800a14:	3c 09                	cmp    $0x9,%al
  800a16:	74 f2                	je     800a0a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a18:	3c 2b                	cmp    $0x2b,%al
  800a1a:	75 0a                	jne    800a26 <strtol+0x2a>
		s++;
  800a1c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a24:	eb 11                	jmp    800a37 <strtol+0x3b>
  800a26:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2b:	3c 2d                	cmp    $0x2d,%al
  800a2d:	75 08                	jne    800a37 <strtol+0x3b>
		s++, neg = 1;
  800a2f:	83 c1 01             	add    $0x1,%ecx
  800a32:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a37:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3d:	75 15                	jne    800a54 <strtol+0x58>
  800a3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a42:	75 10                	jne    800a54 <strtol+0x58>
  800a44:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a48:	75 7c                	jne    800ac6 <strtol+0xca>
		s += 2, base = 16;
  800a4a:	83 c1 02             	add    $0x2,%ecx
  800a4d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a52:	eb 16                	jmp    800a6a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a54:	85 db                	test   %ebx,%ebx
  800a56:	75 12                	jne    800a6a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a58:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a60:	75 08                	jne    800a6a <strtol+0x6e>
		s++, base = 8;
  800a62:	83 c1 01             	add    $0x1,%ecx
  800a65:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a72:	0f b6 11             	movzbl (%ecx),%edx
  800a75:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	80 fb 09             	cmp    $0x9,%bl
  800a7d:	77 08                	ja     800a87 <strtol+0x8b>
			dig = *s - '0';
  800a7f:	0f be d2             	movsbl %dl,%edx
  800a82:	83 ea 30             	sub    $0x30,%edx
  800a85:	eb 22                	jmp    800aa9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a87:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8a:	89 f3                	mov    %esi,%ebx
  800a8c:	80 fb 19             	cmp    $0x19,%bl
  800a8f:	77 08                	ja     800a99 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a91:	0f be d2             	movsbl %dl,%edx
  800a94:	83 ea 57             	sub    $0x57,%edx
  800a97:	eb 10                	jmp    800aa9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a99:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9c:	89 f3                	mov    %esi,%ebx
  800a9e:	80 fb 19             	cmp    $0x19,%bl
  800aa1:	77 16                	ja     800ab9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa3:	0f be d2             	movsbl %dl,%edx
  800aa6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aac:	7d 0b                	jge    800ab9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aae:	83 c1 01             	add    $0x1,%ecx
  800ab1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab7:	eb b9                	jmp    800a72 <strtol+0x76>

	if (endptr)
  800ab9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abd:	74 0d                	je     800acc <strtol+0xd0>
		*endptr = (char *) s;
  800abf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac2:	89 0e                	mov    %ecx,(%esi)
  800ac4:	eb 06                	jmp    800acc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac6:	85 db                	test   %ebx,%ebx
  800ac8:	74 98                	je     800a62 <strtol+0x66>
  800aca:	eb 9e                	jmp    800a6a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800acc:	89 c2                	mov    %eax,%edx
  800ace:	f7 da                	neg    %edx
  800ad0:	85 ff                	test   %edi,%edi
  800ad2:	0f 45 c2             	cmovne %edx,%eax
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aeb:	89 c3                	mov    %eax,%ebx
  800aed:	89 c7                	mov    %eax,%edi
  800aef:	89 c6                	mov    %eax,%esi
  800af1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af3:	5b                   	pop    %ebx
  800af4:	5e                   	pop    %esi
  800af5:	5f                   	pop    %edi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afe:	ba 00 00 00 00       	mov    $0x0,%edx
  800b03:	b8 01 00 00 00       	mov    $0x1,%eax
  800b08:	89 d1                	mov    %edx,%ecx
  800b0a:	89 d3                	mov    %edx,%ebx
  800b0c:	89 d7                	mov    %edx,%edi
  800b0e:	89 d6                	mov    %edx,%esi
  800b10:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b25:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	89 cb                	mov    %ecx,%ebx
  800b2f:	89 cf                	mov    %ecx,%edi
  800b31:	89 ce                	mov    %ecx,%esi
  800b33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	7e 17                	jle    800b50 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	50                   	push   %eax
  800b3d:	6a 03                	push   $0x3
  800b3f:	68 1f 27 80 00       	push   $0x80271f
  800b44:	6a 23                	push   $0x23
  800b46:	68 3c 27 80 00       	push   $0x80273c
  800b4b:	e8 c5 f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b63:	b8 02 00 00 00       	mov    $0x2,%eax
  800b68:	89 d1                	mov    %edx,%ecx
  800b6a:	89 d3                	mov    %edx,%ebx
  800b6c:	89 d7                	mov    %edx,%edi
  800b6e:	89 d6                	mov    %edx,%esi
  800b70:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_yield>:

void
sys_yield(void)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b82:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b87:	89 d1                	mov    %edx,%ecx
  800b89:	89 d3                	mov    %edx,%ebx
  800b8b:	89 d7                	mov    %edx,%edi
  800b8d:	89 d6                	mov    %edx,%esi
  800b8f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	be 00 00 00 00       	mov    $0x0,%esi
  800ba4:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb2:	89 f7                	mov    %esi,%edi
  800bb4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb6:	85 c0                	test   %eax,%eax
  800bb8:	7e 17                	jle    800bd1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	50                   	push   %eax
  800bbe:	6a 04                	push   $0x4
  800bc0:	68 1f 27 80 00       	push   $0x80271f
  800bc5:	6a 23                	push   $0x23
  800bc7:	68 3c 27 80 00       	push   $0x80273c
  800bcc:	e8 44 f5 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	b8 05 00 00 00       	mov    $0x5,%eax
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7e 17                	jle    800c13 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	50                   	push   %eax
  800c00:	6a 05                	push   $0x5
  800c02:	68 1f 27 80 00       	push   $0x80271f
  800c07:	6a 23                	push   $0x23
  800c09:	68 3c 27 80 00       	push   $0x80273c
  800c0e:	e8 02 f5 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c29:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	89 df                	mov    %ebx,%edi
  800c36:	89 de                	mov    %ebx,%esi
  800c38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	7e 17                	jle    800c55 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3e:	83 ec 0c             	sub    $0xc,%esp
  800c41:	50                   	push   %eax
  800c42:	6a 06                	push   $0x6
  800c44:	68 1f 27 80 00       	push   $0x80271f
  800c49:	6a 23                	push   $0x23
  800c4b:	68 3c 27 80 00       	push   $0x80273c
  800c50:	e8 c0 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	89 df                	mov    %ebx,%edi
  800c78:	89 de                	mov    %ebx,%esi
  800c7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	7e 17                	jle    800c97 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	50                   	push   %eax
  800c84:	6a 08                	push   $0x8
  800c86:	68 1f 27 80 00       	push   $0x80271f
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 3c 27 80 00       	push   $0x80273c
  800c92:	e8 7e f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cad:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	89 df                	mov    %ebx,%edi
  800cba:	89 de                	mov    %ebx,%esi
  800cbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7e 17                	jle    800cd9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	50                   	push   %eax
  800cc6:	6a 09                	push   $0x9
  800cc8:	68 1f 27 80 00       	push   $0x80271f
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 3c 27 80 00       	push   $0x80273c
  800cd4:	e8 3c f4 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cef:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	89 df                	mov    %ebx,%edi
  800cfc:	89 de                	mov    %ebx,%esi
  800cfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d00:	85 c0                	test   %eax,%eax
  800d02:	7e 17                	jle    800d1b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	50                   	push   %eax
  800d08:	6a 0a                	push   $0xa
  800d0a:	68 1f 27 80 00       	push   $0x80271f
  800d0f:	6a 23                	push   $0x23
  800d11:	68 3c 27 80 00       	push   $0x80273c
  800d16:	e8 fa f3 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d29:	be 00 00 00 00       	mov    $0x0,%esi
  800d2e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d54:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 cb                	mov    %ecx,%ebx
  800d5e:	89 cf                	mov    %ecx,%edi
  800d60:	89 ce                	mov    %ecx,%esi
  800d62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d64:	85 c0                	test   %eax,%eax
  800d66:	7e 17                	jle    800d7f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	50                   	push   %eax
  800d6c:	6a 0d                	push   $0xd
  800d6e:	68 1f 27 80 00       	push   $0x80271f
  800d73:	6a 23                	push   $0x23
  800d75:	68 3c 27 80 00       	push   $0x80273c
  800d7a:	e8 96 f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d92:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d97:	89 d1                	mov    %edx,%ecx
  800d99:	89 d3                	mov    %edx,%ebx
  800d9b:	89 d7                	mov    %edx,%edi
  800d9d:	89 d6                	mov    %edx,%esi
  800d9f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  800dac:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800db3:	75 56                	jne    800e0b <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	6a 07                	push   $0x7
  800dba:	68 00 f0 bf ee       	push   $0xeebff000
  800dbf:	6a 00                	push   $0x0
  800dc1:	e8 d0 fd ff ff       	call   800b96 <sys_page_alloc>
  800dc6:	83 c4 10             	add    $0x10,%esp
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	74 14                	je     800de1 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  800dcd:	83 ec 04             	sub    $0x4,%esp
  800dd0:	68 4a 27 80 00       	push   $0x80274a
  800dd5:	6a 21                	push   $0x21
  800dd7:	68 5f 27 80 00       	push   $0x80275f
  800ddc:	e8 34 f3 ff ff       	call   800115 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  800de1:	83 ec 08             	sub    $0x8,%esp
  800de4:	68 15 0e 80 00       	push   $0x800e15
  800de9:	6a 00                	push   $0x0
  800deb:	e8 f1 fe ff ff       	call   800ce1 <sys_env_set_pgfault_upcall>
  800df0:	83 c4 10             	add    $0x10,%esp
  800df3:	85 c0                	test   %eax,%eax
  800df5:	74 14                	je     800e0b <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	68 6d 27 80 00       	push   $0x80276d
  800dff:	6a 23                	push   $0x23
  800e01:	68 5f 27 80 00       	push   $0x80275f
  800e06:	e8 0a f3 ff ff       	call   800115 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800e13:	c9                   	leave  
  800e14:	c3                   	ret    

00800e15 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e15:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e16:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e1b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e1d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  800e20:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  800e22:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  800e26:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  800e2a:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  800e2b:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  800e2d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  800e32:	83 c4 08             	add    $0x8,%esp
	popal
  800e35:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800e36:	83 c4 04             	add    $0x4,%esp
	popfl
  800e39:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e3a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e3b:	c3                   	ret    

00800e3c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e42:	05 00 00 00 30       	add    $0x30000000,%eax
  800e47:	c1 e8 0c             	shr    $0xc,%eax
}
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	05 00 00 00 30       	add    $0x30000000,%eax
  800e57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e5c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e69:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e6e:	89 c2                	mov    %eax,%edx
  800e70:	c1 ea 16             	shr    $0x16,%edx
  800e73:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e7a:	f6 c2 01             	test   $0x1,%dl
  800e7d:	74 11                	je     800e90 <fd_alloc+0x2d>
  800e7f:	89 c2                	mov    %eax,%edx
  800e81:	c1 ea 0c             	shr    $0xc,%edx
  800e84:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8b:	f6 c2 01             	test   $0x1,%dl
  800e8e:	75 09                	jne    800e99 <fd_alloc+0x36>
			*fd_store = fd;
  800e90:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	eb 17                	jmp    800eb0 <fd_alloc+0x4d>
  800e99:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e9e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ea3:	75 c9                	jne    800e6e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ea5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800eab:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eb8:	83 f8 1f             	cmp    $0x1f,%eax
  800ebb:	77 36                	ja     800ef3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ebd:	c1 e0 0c             	shl    $0xc,%eax
  800ec0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	c1 ea 16             	shr    $0x16,%edx
  800eca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed1:	f6 c2 01             	test   $0x1,%dl
  800ed4:	74 24                	je     800efa <fd_lookup+0x48>
  800ed6:	89 c2                	mov    %eax,%edx
  800ed8:	c1 ea 0c             	shr    $0xc,%edx
  800edb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee2:	f6 c2 01             	test   $0x1,%dl
  800ee5:	74 1a                	je     800f01 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eea:	89 02                	mov    %eax,(%edx)
	return 0;
  800eec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef1:	eb 13                	jmp    800f06 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef8:	eb 0c                	jmp    800f06 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800efa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eff:	eb 05                	jmp    800f06 <fd_lookup+0x54>
  800f01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	83 ec 08             	sub    $0x8,%esp
  800f0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f11:	ba 04 28 80 00       	mov    $0x802804,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f16:	eb 13                	jmp    800f2b <dev_lookup+0x23>
  800f18:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f1b:	39 08                	cmp    %ecx,(%eax)
  800f1d:	75 0c                	jne    800f2b <dev_lookup+0x23>
			*dev = devtab[i];
  800f1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f22:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
  800f29:	eb 2e                	jmp    800f59 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f2b:	8b 02                	mov    (%edx),%eax
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	75 e7                	jne    800f18 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f31:	a1 08 40 80 00       	mov    0x804008,%eax
  800f36:	8b 40 48             	mov    0x48(%eax),%eax
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	51                   	push   %ecx
  800f3d:	50                   	push   %eax
  800f3e:	68 84 27 80 00       	push   $0x802784
  800f43:	e8 a6 f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f51:	83 c4 10             	add    $0x10,%esp
  800f54:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	83 ec 10             	sub    $0x10,%esp
  800f63:	8b 75 08             	mov    0x8(%ebp),%esi
  800f66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6c:	50                   	push   %eax
  800f6d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f73:	c1 e8 0c             	shr    $0xc,%eax
  800f76:	50                   	push   %eax
  800f77:	e8 36 ff ff ff       	call   800eb2 <fd_lookup>
  800f7c:	83 c4 08             	add    $0x8,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 05                	js     800f88 <fd_close+0x2d>
	    || fd != fd2)
  800f83:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f86:	74 0c                	je     800f94 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f88:	84 db                	test   %bl,%bl
  800f8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8f:	0f 44 c2             	cmove  %edx,%eax
  800f92:	eb 41                	jmp    800fd5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f94:	83 ec 08             	sub    $0x8,%esp
  800f97:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f9a:	50                   	push   %eax
  800f9b:	ff 36                	pushl  (%esi)
  800f9d:	e8 66 ff ff ff       	call   800f08 <dev_lookup>
  800fa2:	89 c3                	mov    %eax,%ebx
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 1a                	js     800fc5 <fd_close+0x6a>
		if (dev->dev_close)
  800fab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fae:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fb1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	74 0b                	je     800fc5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	56                   	push   %esi
  800fbe:	ff d0                	call   *%eax
  800fc0:	89 c3                	mov    %eax,%ebx
  800fc2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fc5:	83 ec 08             	sub    $0x8,%esp
  800fc8:	56                   	push   %esi
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 4b fc ff ff       	call   800c1b <sys_page_unmap>
	return r;
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	89 d8                	mov    %ebx,%eax
}
  800fd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe5:	50                   	push   %eax
  800fe6:	ff 75 08             	pushl  0x8(%ebp)
  800fe9:	e8 c4 fe ff ff       	call   800eb2 <fd_lookup>
  800fee:	83 c4 08             	add    $0x8,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 10                	js     801005 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ff5:	83 ec 08             	sub    $0x8,%esp
  800ff8:	6a 01                	push   $0x1
  800ffa:	ff 75 f4             	pushl  -0xc(%ebp)
  800ffd:	e8 59 ff ff ff       	call   800f5b <fd_close>
  801002:	83 c4 10             	add    $0x10,%esp
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <close_all>:

void
close_all(void)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	53                   	push   %ebx
  80100b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80100e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	53                   	push   %ebx
  801017:	e8 c0 ff ff ff       	call   800fdc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80101c:	83 c3 01             	add    $0x1,%ebx
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	83 fb 20             	cmp    $0x20,%ebx
  801025:	75 ec                	jne    801013 <close_all+0xc>
		close(i);
}
  801027:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    

0080102c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	53                   	push   %ebx
  801032:	83 ec 2c             	sub    $0x2c,%esp
  801035:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801038:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80103b:	50                   	push   %eax
  80103c:	ff 75 08             	pushl  0x8(%ebp)
  80103f:	e8 6e fe ff ff       	call   800eb2 <fd_lookup>
  801044:	83 c4 08             	add    $0x8,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	0f 88 c1 00 00 00    	js     801110 <dup+0xe4>
		return r;
	close(newfdnum);
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	56                   	push   %esi
  801053:	e8 84 ff ff ff       	call   800fdc <close>

	newfd = INDEX2FD(newfdnum);
  801058:	89 f3                	mov    %esi,%ebx
  80105a:	c1 e3 0c             	shl    $0xc,%ebx
  80105d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801063:	83 c4 04             	add    $0x4,%esp
  801066:	ff 75 e4             	pushl  -0x1c(%ebp)
  801069:	e8 de fd ff ff       	call   800e4c <fd2data>
  80106e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801070:	89 1c 24             	mov    %ebx,(%esp)
  801073:	e8 d4 fd ff ff       	call   800e4c <fd2data>
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80107e:	89 f8                	mov    %edi,%eax
  801080:	c1 e8 16             	shr    $0x16,%eax
  801083:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80108a:	a8 01                	test   $0x1,%al
  80108c:	74 37                	je     8010c5 <dup+0x99>
  80108e:	89 f8                	mov    %edi,%eax
  801090:	c1 e8 0c             	shr    $0xc,%eax
  801093:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80109a:	f6 c2 01             	test   $0x1,%dl
  80109d:	74 26                	je     8010c5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80109f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ae:	50                   	push   %eax
  8010af:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b2:	6a 00                	push   $0x0
  8010b4:	57                   	push   %edi
  8010b5:	6a 00                	push   $0x0
  8010b7:	e8 1d fb ff ff       	call   800bd9 <sys_page_map>
  8010bc:	89 c7                	mov    %eax,%edi
  8010be:	83 c4 20             	add    $0x20,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 2e                	js     8010f3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010c8:	89 d0                	mov    %edx,%eax
  8010ca:	c1 e8 0c             	shr    $0xc,%eax
  8010cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010dc:	50                   	push   %eax
  8010dd:	53                   	push   %ebx
  8010de:	6a 00                	push   $0x0
  8010e0:	52                   	push   %edx
  8010e1:	6a 00                	push   $0x0
  8010e3:	e8 f1 fa ff ff       	call   800bd9 <sys_page_map>
  8010e8:	89 c7                	mov    %eax,%edi
  8010ea:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010ed:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ef:	85 ff                	test   %edi,%edi
  8010f1:	79 1d                	jns    801110 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010f3:	83 ec 08             	sub    $0x8,%esp
  8010f6:	53                   	push   %ebx
  8010f7:	6a 00                	push   $0x0
  8010f9:	e8 1d fb ff ff       	call   800c1b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010fe:	83 c4 08             	add    $0x8,%esp
  801101:	ff 75 d4             	pushl  -0x2c(%ebp)
  801104:	6a 00                	push   $0x0
  801106:	e8 10 fb ff ff       	call   800c1b <sys_page_unmap>
	return r;
  80110b:	83 c4 10             	add    $0x10,%esp
  80110e:	89 f8                	mov    %edi,%eax
}
  801110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	53                   	push   %ebx
  80111c:	83 ec 14             	sub    $0x14,%esp
  80111f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801122:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801125:	50                   	push   %eax
  801126:	53                   	push   %ebx
  801127:	e8 86 fd ff ff       	call   800eb2 <fd_lookup>
  80112c:	83 c4 08             	add    $0x8,%esp
  80112f:	89 c2                	mov    %eax,%edx
  801131:	85 c0                	test   %eax,%eax
  801133:	78 6d                	js     8011a2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801135:	83 ec 08             	sub    $0x8,%esp
  801138:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113b:	50                   	push   %eax
  80113c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113f:	ff 30                	pushl  (%eax)
  801141:	e8 c2 fd ff ff       	call   800f08 <dev_lookup>
  801146:	83 c4 10             	add    $0x10,%esp
  801149:	85 c0                	test   %eax,%eax
  80114b:	78 4c                	js     801199 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80114d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801150:	8b 42 08             	mov    0x8(%edx),%eax
  801153:	83 e0 03             	and    $0x3,%eax
  801156:	83 f8 01             	cmp    $0x1,%eax
  801159:	75 21                	jne    80117c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80115b:	a1 08 40 80 00       	mov    0x804008,%eax
  801160:	8b 40 48             	mov    0x48(%eax),%eax
  801163:	83 ec 04             	sub    $0x4,%esp
  801166:	53                   	push   %ebx
  801167:	50                   	push   %eax
  801168:	68 c8 27 80 00       	push   $0x8027c8
  80116d:	e8 7c f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80117a:	eb 26                	jmp    8011a2 <read+0x8a>
	}
	if (!dev->dev_read)
  80117c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117f:	8b 40 08             	mov    0x8(%eax),%eax
  801182:	85 c0                	test   %eax,%eax
  801184:	74 17                	je     80119d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	ff 75 10             	pushl  0x10(%ebp)
  80118c:	ff 75 0c             	pushl  0xc(%ebp)
  80118f:	52                   	push   %edx
  801190:	ff d0                	call   *%eax
  801192:	89 c2                	mov    %eax,%edx
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	eb 09                	jmp    8011a2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801199:	89 c2                	mov    %eax,%edx
  80119b:	eb 05                	jmp    8011a2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80119d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011a2:	89 d0                	mov    %edx,%eax
  8011a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a7:	c9                   	leave  
  8011a8:	c3                   	ret    

008011a9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	57                   	push   %edi
  8011ad:	56                   	push   %esi
  8011ae:	53                   	push   %ebx
  8011af:	83 ec 0c             	sub    $0xc,%esp
  8011b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bd:	eb 21                	jmp    8011e0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	89 f0                	mov    %esi,%eax
  8011c4:	29 d8                	sub    %ebx,%eax
  8011c6:	50                   	push   %eax
  8011c7:	89 d8                	mov    %ebx,%eax
  8011c9:	03 45 0c             	add    0xc(%ebp),%eax
  8011cc:	50                   	push   %eax
  8011cd:	57                   	push   %edi
  8011ce:	e8 45 ff ff ff       	call   801118 <read>
		if (m < 0)
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 10                	js     8011ea <readn+0x41>
			return m;
		if (m == 0)
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	74 0a                	je     8011e8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011de:	01 c3                	add    %eax,%ebx
  8011e0:	39 f3                	cmp    %esi,%ebx
  8011e2:	72 db                	jb     8011bf <readn+0x16>
  8011e4:	89 d8                	mov    %ebx,%eax
  8011e6:	eb 02                	jmp    8011ea <readn+0x41>
  8011e8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 14             	sub    $0x14,%esp
  8011f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ff:	50                   	push   %eax
  801200:	53                   	push   %ebx
  801201:	e8 ac fc ff ff       	call   800eb2 <fd_lookup>
  801206:	83 c4 08             	add    $0x8,%esp
  801209:	89 c2                	mov    %eax,%edx
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 68                	js     801277 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801219:	ff 30                	pushl  (%eax)
  80121b:	e8 e8 fc ff ff       	call   800f08 <dev_lookup>
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	78 47                	js     80126e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801227:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122e:	75 21                	jne    801251 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801230:	a1 08 40 80 00       	mov    0x804008,%eax
  801235:	8b 40 48             	mov    0x48(%eax),%eax
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	53                   	push   %ebx
  80123c:	50                   	push   %eax
  80123d:	68 e4 27 80 00       	push   $0x8027e4
  801242:	e8 a7 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124f:	eb 26                	jmp    801277 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801251:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801254:	8b 52 0c             	mov    0xc(%edx),%edx
  801257:	85 d2                	test   %edx,%edx
  801259:	74 17                	je     801272 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80125b:	83 ec 04             	sub    $0x4,%esp
  80125e:	ff 75 10             	pushl  0x10(%ebp)
  801261:	ff 75 0c             	pushl  0xc(%ebp)
  801264:	50                   	push   %eax
  801265:	ff d2                	call   *%edx
  801267:	89 c2                	mov    %eax,%edx
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	eb 09                	jmp    801277 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126e:	89 c2                	mov    %eax,%edx
  801270:	eb 05                	jmp    801277 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801272:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801277:	89 d0                	mov    %edx,%eax
  801279:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127c:	c9                   	leave  
  80127d:	c3                   	ret    

0080127e <seek>:

int
seek(int fdnum, off_t offset)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801284:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801287:	50                   	push   %eax
  801288:	ff 75 08             	pushl  0x8(%ebp)
  80128b:	e8 22 fc ff ff       	call   800eb2 <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 0e                	js     8012a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801297:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80129a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	53                   	push   %ebx
  8012ab:	83 ec 14             	sub    $0x14,%esp
  8012ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b4:	50                   	push   %eax
  8012b5:	53                   	push   %ebx
  8012b6:	e8 f7 fb ff ff       	call   800eb2 <fd_lookup>
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 65                	js     801329 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ce:	ff 30                	pushl  (%eax)
  8012d0:	e8 33 fc ff ff       	call   800f08 <dev_lookup>
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 44                	js     801320 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012df:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012e3:	75 21                	jne    801306 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012e5:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ea:	8b 40 48             	mov    0x48(%eax),%eax
  8012ed:	83 ec 04             	sub    $0x4,%esp
  8012f0:	53                   	push   %ebx
  8012f1:	50                   	push   %eax
  8012f2:	68 a4 27 80 00       	push   $0x8027a4
  8012f7:	e8 f2 ee ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801304:	eb 23                	jmp    801329 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801306:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801309:	8b 52 18             	mov    0x18(%edx),%edx
  80130c:	85 d2                	test   %edx,%edx
  80130e:	74 14                	je     801324 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801310:	83 ec 08             	sub    $0x8,%esp
  801313:	ff 75 0c             	pushl  0xc(%ebp)
  801316:	50                   	push   %eax
  801317:	ff d2                	call   *%edx
  801319:	89 c2                	mov    %eax,%edx
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	eb 09                	jmp    801329 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801320:	89 c2                	mov    %eax,%edx
  801322:	eb 05                	jmp    801329 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801324:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801329:	89 d0                	mov    %edx,%eax
  80132b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132e:	c9                   	leave  
  80132f:	c3                   	ret    

00801330 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	53                   	push   %ebx
  801334:	83 ec 14             	sub    $0x14,%esp
  801337:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	ff 75 08             	pushl  0x8(%ebp)
  801341:	e8 6c fb ff ff       	call   800eb2 <fd_lookup>
  801346:	83 c4 08             	add    $0x8,%esp
  801349:	89 c2                	mov    %eax,%edx
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 58                	js     8013a7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801355:	50                   	push   %eax
  801356:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801359:	ff 30                	pushl  (%eax)
  80135b:	e8 a8 fb ff ff       	call   800f08 <dev_lookup>
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	78 37                	js     80139e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801367:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80136e:	74 32                	je     8013a2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801370:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801373:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80137a:	00 00 00 
	stat->st_isdir = 0;
  80137d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801384:	00 00 00 
	stat->st_dev = dev;
  801387:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80138d:	83 ec 08             	sub    $0x8,%esp
  801390:	53                   	push   %ebx
  801391:	ff 75 f0             	pushl  -0x10(%ebp)
  801394:	ff 50 14             	call   *0x14(%eax)
  801397:	89 c2                	mov    %eax,%edx
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	eb 09                	jmp    8013a7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139e:	89 c2                	mov    %eax,%edx
  8013a0:	eb 05                	jmp    8013a7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013a7:	89 d0                	mov    %edx,%eax
  8013a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	6a 00                	push   $0x0
  8013b8:	ff 75 08             	pushl  0x8(%ebp)
  8013bb:	e8 ef 01 00 00       	call   8015af <open>
  8013c0:	89 c3                	mov    %eax,%ebx
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 1b                	js     8013e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013c9:	83 ec 08             	sub    $0x8,%esp
  8013cc:	ff 75 0c             	pushl  0xc(%ebp)
  8013cf:	50                   	push   %eax
  8013d0:	e8 5b ff ff ff       	call   801330 <fstat>
  8013d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8013d7:	89 1c 24             	mov    %ebx,(%esp)
  8013da:	e8 fd fb ff ff       	call   800fdc <close>
	return r;
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	89 f0                	mov    %esi,%eax
}
  8013e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    

008013eb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	56                   	push   %esi
  8013ef:	53                   	push   %ebx
  8013f0:	89 c6                	mov    %eax,%esi
  8013f2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013f4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013fb:	75 12                	jne    80140f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013fd:	83 ec 0c             	sub    $0xc,%esp
  801400:	6a 01                	push   $0x1
  801402:	e8 57 0c 00 00       	call   80205e <ipc_find_env>
  801407:	a3 00 40 80 00       	mov    %eax,0x804000
  80140c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80140f:	6a 07                	push   $0x7
  801411:	68 00 50 80 00       	push   $0x805000
  801416:	56                   	push   %esi
  801417:	ff 35 00 40 80 00    	pushl  0x804000
  80141d:	e8 ed 0b 00 00       	call   80200f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801422:	83 c4 0c             	add    $0xc,%esp
  801425:	6a 00                	push   $0x0
  801427:	53                   	push   %ebx
  801428:	6a 00                	push   $0x0
  80142a:	e8 6a 0b 00 00       	call   801f99 <ipc_recv>
}
  80142f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801432:	5b                   	pop    %ebx
  801433:	5e                   	pop    %esi
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    

00801436 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80143c:	8b 45 08             	mov    0x8(%ebp),%eax
  80143f:	8b 40 0c             	mov    0xc(%eax),%eax
  801442:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801447:	8b 45 0c             	mov    0xc(%ebp),%eax
  80144a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80144f:	ba 00 00 00 00       	mov    $0x0,%edx
  801454:	b8 02 00 00 00       	mov    $0x2,%eax
  801459:	e8 8d ff ff ff       	call   8013eb <fsipc>
}
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801466:	8b 45 08             	mov    0x8(%ebp),%eax
  801469:	8b 40 0c             	mov    0xc(%eax),%eax
  80146c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801471:	ba 00 00 00 00       	mov    $0x0,%edx
  801476:	b8 06 00 00 00       	mov    $0x6,%eax
  80147b:	e8 6b ff ff ff       	call   8013eb <fsipc>
}
  801480:	c9                   	leave  
  801481:	c3                   	ret    

00801482 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	53                   	push   %ebx
  801486:	83 ec 04             	sub    $0x4,%esp
  801489:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80148c:	8b 45 08             	mov    0x8(%ebp),%eax
  80148f:	8b 40 0c             	mov    0xc(%eax),%eax
  801492:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801497:	ba 00 00 00 00       	mov    $0x0,%edx
  80149c:	b8 05 00 00 00       	mov    $0x5,%eax
  8014a1:	e8 45 ff ff ff       	call   8013eb <fsipc>
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 2c                	js     8014d6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	68 00 50 80 00       	push   $0x805000
  8014b2:	53                   	push   %ebx
  8014b3:	e8 db f2 ff ff       	call   800793 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b8:	a1 80 50 80 00       	mov    0x805080,%eax
  8014bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c3:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014eb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014f1:	a3 04 50 80 00       	mov    %eax,0x805004
  8014f6:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8014fb:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801500:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801503:	53                   	push   %ebx
  801504:	ff 75 0c             	pushl  0xc(%ebp)
  801507:	68 08 50 80 00       	push   $0x805008
  80150c:	e8 14 f4 ff ff       	call   800925 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801511:	ba 00 00 00 00       	mov    $0x0,%edx
  801516:	b8 04 00 00 00       	mov    $0x4,%eax
  80151b:	e8 cb fe ff ff       	call   8013eb <fsipc>
  801520:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801523:	85 c0                	test   %eax,%eax
  801525:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801528:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    

0080152d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
  801532:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801535:	8b 45 08             	mov    0x8(%ebp),%eax
  801538:	8b 40 0c             	mov    0xc(%eax),%eax
  80153b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801540:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801546:	ba 00 00 00 00       	mov    $0x0,%edx
  80154b:	b8 03 00 00 00       	mov    $0x3,%eax
  801550:	e8 96 fe ff ff       	call   8013eb <fsipc>
  801555:	89 c3                	mov    %eax,%ebx
  801557:	85 c0                	test   %eax,%eax
  801559:	78 4b                	js     8015a6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80155b:	39 c6                	cmp    %eax,%esi
  80155d:	73 16                	jae    801575 <devfile_read+0x48>
  80155f:	68 18 28 80 00       	push   $0x802818
  801564:	68 1f 28 80 00       	push   $0x80281f
  801569:	6a 7c                	push   $0x7c
  80156b:	68 34 28 80 00       	push   $0x802834
  801570:	e8 a0 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  801575:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80157a:	7e 16                	jle    801592 <devfile_read+0x65>
  80157c:	68 3f 28 80 00       	push   $0x80283f
  801581:	68 1f 28 80 00       	push   $0x80281f
  801586:	6a 7d                	push   $0x7d
  801588:	68 34 28 80 00       	push   $0x802834
  80158d:	e8 83 eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801592:	83 ec 04             	sub    $0x4,%esp
  801595:	50                   	push   %eax
  801596:	68 00 50 80 00       	push   $0x805000
  80159b:	ff 75 0c             	pushl  0xc(%ebp)
  80159e:	e8 82 f3 ff ff       	call   800925 <memmove>
	return r;
  8015a3:	83 c4 10             	add    $0x10,%esp
}
  8015a6:	89 d8                	mov    %ebx,%eax
  8015a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ab:	5b                   	pop    %ebx
  8015ac:	5e                   	pop    %esi
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    

008015af <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	53                   	push   %ebx
  8015b3:	83 ec 20             	sub    $0x20,%esp
  8015b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015b9:	53                   	push   %ebx
  8015ba:	e8 9b f1 ff ff       	call   80075a <strlen>
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015c7:	7f 67                	jg     801630 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cf:	50                   	push   %eax
  8015d0:	e8 8e f8 ff ff       	call   800e63 <fd_alloc>
  8015d5:	83 c4 10             	add    $0x10,%esp
		return r;
  8015d8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 57                	js     801635 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	53                   	push   %ebx
  8015e2:	68 00 50 80 00       	push   $0x805000
  8015e7:	e8 a7 f1 ff ff       	call   800793 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ef:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8015fc:	e8 ea fd ff ff       	call   8013eb <fsipc>
  801601:	89 c3                	mov    %eax,%ebx
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	85 c0                	test   %eax,%eax
  801608:	79 14                	jns    80161e <open+0x6f>
		fd_close(fd, 0);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	6a 00                	push   $0x0
  80160f:	ff 75 f4             	pushl  -0xc(%ebp)
  801612:	e8 44 f9 ff ff       	call   800f5b <fd_close>
		return r;
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	89 da                	mov    %ebx,%edx
  80161c:	eb 17                	jmp    801635 <open+0x86>
	}

	return fd2num(fd);
  80161e:	83 ec 0c             	sub    $0xc,%esp
  801621:	ff 75 f4             	pushl  -0xc(%ebp)
  801624:	e8 13 f8 ff ff       	call   800e3c <fd2num>
  801629:	89 c2                	mov    %eax,%edx
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	eb 05                	jmp    801635 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801630:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801635:	89 d0                	mov    %edx,%eax
  801637:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	b8 08 00 00 00       	mov    $0x8,%eax
  80164c:	e8 9a fd ff ff       	call   8013eb <fsipc>
}
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	56                   	push   %esi
  801657:	53                   	push   %ebx
  801658:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80165b:	83 ec 0c             	sub    $0xc,%esp
  80165e:	ff 75 08             	pushl  0x8(%ebp)
  801661:	e8 e6 f7 ff ff       	call   800e4c <fd2data>
  801666:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801668:	83 c4 08             	add    $0x8,%esp
  80166b:	68 4b 28 80 00       	push   $0x80284b
  801670:	53                   	push   %ebx
  801671:	e8 1d f1 ff ff       	call   800793 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801676:	8b 46 04             	mov    0x4(%esi),%eax
  801679:	2b 06                	sub    (%esi),%eax
  80167b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801681:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801688:	00 00 00 
	stat->st_dev = &devpipe;
  80168b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801692:	30 80 00 
	return 0;
}
  801695:	b8 00 00 00 00       	mov    $0x0,%eax
  80169a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5e                   	pop    %esi
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	53                   	push   %ebx
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016ab:	53                   	push   %ebx
  8016ac:	6a 00                	push   $0x0
  8016ae:	e8 68 f5 ff ff       	call   800c1b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016b3:	89 1c 24             	mov    %ebx,(%esp)
  8016b6:	e8 91 f7 ff ff       	call   800e4c <fd2data>
  8016bb:	83 c4 08             	add    $0x8,%esp
  8016be:	50                   	push   %eax
  8016bf:	6a 00                	push   $0x0
  8016c1:	e8 55 f5 ff ff       	call   800c1b <sys_page_unmap>
}
  8016c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	57                   	push   %edi
  8016cf:	56                   	push   %esi
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 1c             	sub    $0x1c,%esp
  8016d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016d7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016d9:	a1 08 40 80 00       	mov    0x804008,%eax
  8016de:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016e1:	83 ec 0c             	sub    $0xc,%esp
  8016e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8016e7:	e8 ab 09 00 00       	call   802097 <pageref>
  8016ec:	89 c3                	mov    %eax,%ebx
  8016ee:	89 3c 24             	mov    %edi,(%esp)
  8016f1:	e8 a1 09 00 00       	call   802097 <pageref>
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	39 c3                	cmp    %eax,%ebx
  8016fb:	0f 94 c1             	sete   %cl
  8016fe:	0f b6 c9             	movzbl %cl,%ecx
  801701:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801704:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80170a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80170d:	39 ce                	cmp    %ecx,%esi
  80170f:	74 1b                	je     80172c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801711:	39 c3                	cmp    %eax,%ebx
  801713:	75 c4                	jne    8016d9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801715:	8b 42 58             	mov    0x58(%edx),%eax
  801718:	ff 75 e4             	pushl  -0x1c(%ebp)
  80171b:	50                   	push   %eax
  80171c:	56                   	push   %esi
  80171d:	68 52 28 80 00       	push   $0x802852
  801722:	e8 c7 ea ff ff       	call   8001ee <cprintf>
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	eb ad                	jmp    8016d9 <_pipeisclosed+0xe>
	}
}
  80172c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5f                   	pop    %edi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	57                   	push   %edi
  80173b:	56                   	push   %esi
  80173c:	53                   	push   %ebx
  80173d:	83 ec 28             	sub    $0x28,%esp
  801740:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801743:	56                   	push   %esi
  801744:	e8 03 f7 ff ff       	call   800e4c <fd2data>
  801749:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	bf 00 00 00 00       	mov    $0x0,%edi
  801753:	eb 4b                	jmp    8017a0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801755:	89 da                	mov    %ebx,%edx
  801757:	89 f0                	mov    %esi,%eax
  801759:	e8 6d ff ff ff       	call   8016cb <_pipeisclosed>
  80175e:	85 c0                	test   %eax,%eax
  801760:	75 48                	jne    8017aa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801762:	e8 10 f4 ff ff       	call   800b77 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801767:	8b 43 04             	mov    0x4(%ebx),%eax
  80176a:	8b 0b                	mov    (%ebx),%ecx
  80176c:	8d 51 20             	lea    0x20(%ecx),%edx
  80176f:	39 d0                	cmp    %edx,%eax
  801771:	73 e2                	jae    801755 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801773:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801776:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80177a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80177d:	89 c2                	mov    %eax,%edx
  80177f:	c1 fa 1f             	sar    $0x1f,%edx
  801782:	89 d1                	mov    %edx,%ecx
  801784:	c1 e9 1b             	shr    $0x1b,%ecx
  801787:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80178a:	83 e2 1f             	and    $0x1f,%edx
  80178d:	29 ca                	sub    %ecx,%edx
  80178f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801793:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801797:	83 c0 01             	add    $0x1,%eax
  80179a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179d:	83 c7 01             	add    $0x1,%edi
  8017a0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017a3:	75 c2                	jne    801767 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a8:	eb 05                	jmp    8017af <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017aa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5e                   	pop    %esi
  8017b4:	5f                   	pop    %edi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	57                   	push   %edi
  8017bb:	56                   	push   %esi
  8017bc:	53                   	push   %ebx
  8017bd:	83 ec 18             	sub    $0x18,%esp
  8017c0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017c3:	57                   	push   %edi
  8017c4:	e8 83 f6 ff ff       	call   800e4c <fd2data>
  8017c9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017d3:	eb 3d                	jmp    801812 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017d5:	85 db                	test   %ebx,%ebx
  8017d7:	74 04                	je     8017dd <devpipe_read+0x26>
				return i;
  8017d9:	89 d8                	mov    %ebx,%eax
  8017db:	eb 44                	jmp    801821 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017dd:	89 f2                	mov    %esi,%edx
  8017df:	89 f8                	mov    %edi,%eax
  8017e1:	e8 e5 fe ff ff       	call   8016cb <_pipeisclosed>
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	75 32                	jne    80181c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017ea:	e8 88 f3 ff ff       	call   800b77 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017ef:	8b 06                	mov    (%esi),%eax
  8017f1:	3b 46 04             	cmp    0x4(%esi),%eax
  8017f4:	74 df                	je     8017d5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017f6:	99                   	cltd   
  8017f7:	c1 ea 1b             	shr    $0x1b,%edx
  8017fa:	01 d0                	add    %edx,%eax
  8017fc:	83 e0 1f             	and    $0x1f,%eax
  8017ff:	29 d0                	sub    %edx,%eax
  801801:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801806:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801809:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80180c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80180f:	83 c3 01             	add    $0x1,%ebx
  801812:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801815:	75 d8                	jne    8017ef <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801817:	8b 45 10             	mov    0x10(%ebp),%eax
  80181a:	eb 05                	jmp    801821 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80181c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801821:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801824:	5b                   	pop    %ebx
  801825:	5e                   	pop    %esi
  801826:	5f                   	pop    %edi
  801827:	5d                   	pop    %ebp
  801828:	c3                   	ret    

00801829 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	56                   	push   %esi
  80182d:	53                   	push   %ebx
  80182e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801831:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801834:	50                   	push   %eax
  801835:	e8 29 f6 ff ff       	call   800e63 <fd_alloc>
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	89 c2                	mov    %eax,%edx
  80183f:	85 c0                	test   %eax,%eax
  801841:	0f 88 2c 01 00 00    	js     801973 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	68 07 04 00 00       	push   $0x407
  80184f:	ff 75 f4             	pushl  -0xc(%ebp)
  801852:	6a 00                	push   $0x0
  801854:	e8 3d f3 ff ff       	call   800b96 <sys_page_alloc>
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	89 c2                	mov    %eax,%edx
  80185e:	85 c0                	test   %eax,%eax
  801860:	0f 88 0d 01 00 00    	js     801973 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186c:	50                   	push   %eax
  80186d:	e8 f1 f5 ff ff       	call   800e63 <fd_alloc>
  801872:	89 c3                	mov    %eax,%ebx
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	85 c0                	test   %eax,%eax
  801879:	0f 88 e2 00 00 00    	js     801961 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187f:	83 ec 04             	sub    $0x4,%esp
  801882:	68 07 04 00 00       	push   $0x407
  801887:	ff 75 f0             	pushl  -0x10(%ebp)
  80188a:	6a 00                	push   $0x0
  80188c:	e8 05 f3 ff ff       	call   800b96 <sys_page_alloc>
  801891:	89 c3                	mov    %eax,%ebx
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	85 c0                	test   %eax,%eax
  801898:	0f 88 c3 00 00 00    	js     801961 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a4:	e8 a3 f5 ff ff       	call   800e4c <fd2data>
  8018a9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ab:	83 c4 0c             	add    $0xc,%esp
  8018ae:	68 07 04 00 00       	push   $0x407
  8018b3:	50                   	push   %eax
  8018b4:	6a 00                	push   $0x0
  8018b6:	e8 db f2 ff ff       	call   800b96 <sys_page_alloc>
  8018bb:	89 c3                	mov    %eax,%ebx
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	0f 88 89 00 00 00    	js     801951 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c8:	83 ec 0c             	sub    $0xc,%esp
  8018cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ce:	e8 79 f5 ff ff       	call   800e4c <fd2data>
  8018d3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018da:	50                   	push   %eax
  8018db:	6a 00                	push   $0x0
  8018dd:	56                   	push   %esi
  8018de:	6a 00                	push   $0x0
  8018e0:	e8 f4 f2 ff ff       	call   800bd9 <sys_page_map>
  8018e5:	89 c3                	mov    %eax,%ebx
  8018e7:	83 c4 20             	add    $0x20,%esp
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	78 55                	js     801943 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018ee:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801903:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801909:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80190e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801911:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	ff 75 f4             	pushl  -0xc(%ebp)
  80191e:	e8 19 f5 ff ff       	call   800e3c <fd2num>
  801923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801926:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801928:	83 c4 04             	add    $0x4,%esp
  80192b:	ff 75 f0             	pushl  -0x10(%ebp)
  80192e:	e8 09 f5 ff ff       	call   800e3c <fd2num>
  801933:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801936:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	ba 00 00 00 00       	mov    $0x0,%edx
  801941:	eb 30                	jmp    801973 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801943:	83 ec 08             	sub    $0x8,%esp
  801946:	56                   	push   %esi
  801947:	6a 00                	push   $0x0
  801949:	e8 cd f2 ff ff       	call   800c1b <sys_page_unmap>
  80194e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	ff 75 f0             	pushl  -0x10(%ebp)
  801957:	6a 00                	push   $0x0
  801959:	e8 bd f2 ff ff       	call   800c1b <sys_page_unmap>
  80195e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801961:	83 ec 08             	sub    $0x8,%esp
  801964:	ff 75 f4             	pushl  -0xc(%ebp)
  801967:	6a 00                	push   $0x0
  801969:	e8 ad f2 ff ff       	call   800c1b <sys_page_unmap>
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801973:	89 d0                	mov    %edx,%eax
  801975:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801978:	5b                   	pop    %ebx
  801979:	5e                   	pop    %esi
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801982:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801985:	50                   	push   %eax
  801986:	ff 75 08             	pushl  0x8(%ebp)
  801989:	e8 24 f5 ff ff       	call   800eb2 <fd_lookup>
  80198e:	83 c4 10             	add    $0x10,%esp
  801991:	85 c0                	test   %eax,%eax
  801993:	78 18                	js     8019ad <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801995:	83 ec 0c             	sub    $0xc,%esp
  801998:	ff 75 f4             	pushl  -0xc(%ebp)
  80199b:	e8 ac f4 ff ff       	call   800e4c <fd2data>
	return _pipeisclosed(fd, p);
  8019a0:	89 c2                	mov    %eax,%edx
  8019a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a5:	e8 21 fd ff ff       	call   8016cb <_pipeisclosed>
  8019aa:	83 c4 10             	add    $0x10,%esp
}
  8019ad:	c9                   	leave  
  8019ae:	c3                   	ret    

008019af <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019b5:	68 6a 28 80 00       	push   $0x80286a
  8019ba:	ff 75 0c             	pushl  0xc(%ebp)
  8019bd:	e8 d1 ed ff ff       	call   800793 <strcpy>
	return 0;
}
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	53                   	push   %ebx
  8019cd:	83 ec 10             	sub    $0x10,%esp
  8019d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019d3:	53                   	push   %ebx
  8019d4:	e8 be 06 00 00       	call   802097 <pageref>
  8019d9:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019dc:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019e1:	83 f8 01             	cmp    $0x1,%eax
  8019e4:	75 10                	jne    8019f6 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	ff 73 0c             	pushl  0xc(%ebx)
  8019ec:	e8 c0 02 00 00       	call   801cb1 <nsipc_close>
  8019f1:	89 c2                	mov    %eax,%edx
  8019f3:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019f6:	89 d0                	mov    %edx,%eax
  8019f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fb:	c9                   	leave  
  8019fc:	c3                   	ret    

008019fd <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a03:	6a 00                	push   $0x0
  801a05:	ff 75 10             	pushl  0x10(%ebp)
  801a08:	ff 75 0c             	pushl  0xc(%ebp)
  801a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0e:	ff 70 0c             	pushl  0xc(%eax)
  801a11:	e8 78 03 00 00       	call   801d8e <nsipc_send>
}
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a1e:	6a 00                	push   $0x0
  801a20:	ff 75 10             	pushl  0x10(%ebp)
  801a23:	ff 75 0c             	pushl  0xc(%ebp)
  801a26:	8b 45 08             	mov    0x8(%ebp),%eax
  801a29:	ff 70 0c             	pushl  0xc(%eax)
  801a2c:	e8 f1 02 00 00       	call   801d22 <nsipc_recv>
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a39:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a3c:	52                   	push   %edx
  801a3d:	50                   	push   %eax
  801a3e:	e8 6f f4 ff ff       	call   800eb2 <fd_lookup>
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 17                	js     801a61 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4d:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801a53:	39 08                	cmp    %ecx,(%eax)
  801a55:	75 05                	jne    801a5c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a57:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5a:	eb 05                	jmp    801a61 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a5c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	56                   	push   %esi
  801a67:	53                   	push   %ebx
  801a68:	83 ec 1c             	sub    $0x1c,%esp
  801a6b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a70:	50                   	push   %eax
  801a71:	e8 ed f3 ff ff       	call   800e63 <fd_alloc>
  801a76:	89 c3                	mov    %eax,%ebx
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 1b                	js     801a9a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a7f:	83 ec 04             	sub    $0x4,%esp
  801a82:	68 07 04 00 00       	push   $0x407
  801a87:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8a:	6a 00                	push   $0x0
  801a8c:	e8 05 f1 ff ff       	call   800b96 <sys_page_alloc>
  801a91:	89 c3                	mov    %eax,%ebx
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	85 c0                	test   %eax,%eax
  801a98:	79 10                	jns    801aaa <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	56                   	push   %esi
  801a9e:	e8 0e 02 00 00       	call   801cb1 <nsipc_close>
		return r;
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	89 d8                	mov    %ebx,%eax
  801aa8:	eb 24                	jmp    801ace <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801aaa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab3:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801abf:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	50                   	push   %eax
  801ac6:	e8 71 f3 ff ff       	call   800e3c <fd2num>
  801acb:	83 c4 10             	add    $0x10,%esp
}
  801ace:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad1:	5b                   	pop    %ebx
  801ad2:	5e                   	pop    %esi
  801ad3:	5d                   	pop    %ebp
  801ad4:	c3                   	ret    

00801ad5 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801adb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ade:	e8 50 ff ff ff       	call   801a33 <fd2sockid>
		return r;
  801ae3:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 1f                	js     801b08 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ae9:	83 ec 04             	sub    $0x4,%esp
  801aec:	ff 75 10             	pushl  0x10(%ebp)
  801aef:	ff 75 0c             	pushl  0xc(%ebp)
  801af2:	50                   	push   %eax
  801af3:	e8 12 01 00 00       	call   801c0a <nsipc_accept>
  801af8:	83 c4 10             	add    $0x10,%esp
		return r;
  801afb:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801afd:	85 c0                	test   %eax,%eax
  801aff:	78 07                	js     801b08 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b01:	e8 5d ff ff ff       	call   801a63 <alloc_sockfd>
  801b06:	89 c1                	mov    %eax,%ecx
}
  801b08:	89 c8                	mov    %ecx,%eax
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b12:	8b 45 08             	mov    0x8(%ebp),%eax
  801b15:	e8 19 ff ff ff       	call   801a33 <fd2sockid>
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 12                	js     801b30 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b1e:	83 ec 04             	sub    $0x4,%esp
  801b21:	ff 75 10             	pushl  0x10(%ebp)
  801b24:	ff 75 0c             	pushl  0xc(%ebp)
  801b27:	50                   	push   %eax
  801b28:	e8 2d 01 00 00       	call   801c5a <nsipc_bind>
  801b2d:	83 c4 10             	add    $0x10,%esp
}
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <shutdown>:

int
shutdown(int s, int how)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	e8 f3 fe ff ff       	call   801a33 <fd2sockid>
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 0f                	js     801b53 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b44:	83 ec 08             	sub    $0x8,%esp
  801b47:	ff 75 0c             	pushl  0xc(%ebp)
  801b4a:	50                   	push   %eax
  801b4b:	e8 3f 01 00 00       	call   801c8f <nsipc_shutdown>
  801b50:	83 c4 10             	add    $0x10,%esp
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    

00801b55 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	e8 d0 fe ff ff       	call   801a33 <fd2sockid>
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 12                	js     801b79 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b67:	83 ec 04             	sub    $0x4,%esp
  801b6a:	ff 75 10             	pushl  0x10(%ebp)
  801b6d:	ff 75 0c             	pushl  0xc(%ebp)
  801b70:	50                   	push   %eax
  801b71:	e8 55 01 00 00       	call   801ccb <nsipc_connect>
  801b76:	83 c4 10             	add    $0x10,%esp
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <listen>:

int
listen(int s, int backlog)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b81:	8b 45 08             	mov    0x8(%ebp),%eax
  801b84:	e8 aa fe ff ff       	call   801a33 <fd2sockid>
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	78 0f                	js     801b9c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b8d:	83 ec 08             	sub    $0x8,%esp
  801b90:	ff 75 0c             	pushl  0xc(%ebp)
  801b93:	50                   	push   %eax
  801b94:	e8 67 01 00 00       	call   801d00 <nsipc_listen>
  801b99:	83 c4 10             	add    $0x10,%esp
}
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ba4:	ff 75 10             	pushl  0x10(%ebp)
  801ba7:	ff 75 0c             	pushl  0xc(%ebp)
  801baa:	ff 75 08             	pushl  0x8(%ebp)
  801bad:	e8 3a 02 00 00       	call   801dec <nsipc_socket>
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	78 05                	js     801bbe <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bb9:	e8 a5 fe ff ff       	call   801a63 <alloc_sockfd>
}
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 04             	sub    $0x4,%esp
  801bc7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bc9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bd0:	75 12                	jne    801be4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	6a 02                	push   $0x2
  801bd7:	e8 82 04 00 00       	call   80205e <ipc_find_env>
  801bdc:	a3 04 40 80 00       	mov    %eax,0x804004
  801be1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801be4:	6a 07                	push   $0x7
  801be6:	68 00 60 80 00       	push   $0x806000
  801beb:	53                   	push   %ebx
  801bec:	ff 35 04 40 80 00    	pushl  0x804004
  801bf2:	e8 18 04 00 00       	call   80200f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bf7:	83 c4 0c             	add    $0xc,%esp
  801bfa:	6a 00                	push   $0x0
  801bfc:	6a 00                	push   $0x0
  801bfe:	6a 00                	push   $0x0
  801c00:	e8 94 03 00 00       	call   801f99 <ipc_recv>
}
  801c05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	56                   	push   %esi
  801c0e:	53                   	push   %ebx
  801c0f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c12:	8b 45 08             	mov    0x8(%ebp),%eax
  801c15:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c1a:	8b 06                	mov    (%esi),%eax
  801c1c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c21:	b8 01 00 00 00       	mov    $0x1,%eax
  801c26:	e8 95 ff ff ff       	call   801bc0 <nsipc>
  801c2b:	89 c3                	mov    %eax,%ebx
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	78 20                	js     801c51 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c31:	83 ec 04             	sub    $0x4,%esp
  801c34:	ff 35 10 60 80 00    	pushl  0x806010
  801c3a:	68 00 60 80 00       	push   $0x806000
  801c3f:	ff 75 0c             	pushl  0xc(%ebp)
  801c42:	e8 de ec ff ff       	call   800925 <memmove>
		*addrlen = ret->ret_addrlen;
  801c47:	a1 10 60 80 00       	mov    0x806010,%eax
  801c4c:	89 06                	mov    %eax,(%esi)
  801c4e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c51:	89 d8                	mov    %ebx,%eax
  801c53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    

00801c5a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	53                   	push   %ebx
  801c5e:	83 ec 08             	sub    $0x8,%esp
  801c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  801c67:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c6c:	53                   	push   %ebx
  801c6d:	ff 75 0c             	pushl  0xc(%ebp)
  801c70:	68 04 60 80 00       	push   $0x806004
  801c75:	e8 ab ec ff ff       	call   800925 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c7a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c80:	b8 02 00 00 00       	mov    $0x2,%eax
  801c85:	e8 36 ff ff ff       	call   801bc0 <nsipc>
}
  801c8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ca5:	b8 03 00 00 00       	mov    $0x3,%eax
  801caa:	e8 11 ff ff ff       	call   801bc0 <nsipc>
}
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    

00801cb1 <nsipc_close>:

int
nsipc_close(int s)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cba:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cbf:	b8 04 00 00 00       	mov    $0x4,%eax
  801cc4:	e8 f7 fe ff ff       	call   801bc0 <nsipc>
}
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	53                   	push   %ebx
  801ccf:	83 ec 08             	sub    $0x8,%esp
  801cd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cdd:	53                   	push   %ebx
  801cde:	ff 75 0c             	pushl  0xc(%ebp)
  801ce1:	68 04 60 80 00       	push   $0x806004
  801ce6:	e8 3a ec ff ff       	call   800925 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ceb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cf1:	b8 05 00 00 00       	mov    $0x5,%eax
  801cf6:	e8 c5 fe ff ff       	call   801bc0 <nsipc>
}
  801cfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d06:	8b 45 08             	mov    0x8(%ebp),%eax
  801d09:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d11:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d16:	b8 06 00 00 00       	mov    $0x6,%eax
  801d1b:	e8 a0 fe ff ff       	call   801bc0 <nsipc>
}
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	56                   	push   %esi
  801d26:	53                   	push   %ebx
  801d27:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d32:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d38:	8b 45 14             	mov    0x14(%ebp),%eax
  801d3b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d40:	b8 07 00 00 00       	mov    $0x7,%eax
  801d45:	e8 76 fe ff ff       	call   801bc0 <nsipc>
  801d4a:	89 c3                	mov    %eax,%ebx
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	78 35                	js     801d85 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d50:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d55:	7f 04                	jg     801d5b <nsipc_recv+0x39>
  801d57:	39 c6                	cmp    %eax,%esi
  801d59:	7d 16                	jge    801d71 <nsipc_recv+0x4f>
  801d5b:	68 76 28 80 00       	push   $0x802876
  801d60:	68 1f 28 80 00       	push   $0x80281f
  801d65:	6a 62                	push   $0x62
  801d67:	68 8b 28 80 00       	push   $0x80288b
  801d6c:	e8 a4 e3 ff ff       	call   800115 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d71:	83 ec 04             	sub    $0x4,%esp
  801d74:	50                   	push   %eax
  801d75:	68 00 60 80 00       	push   $0x806000
  801d7a:	ff 75 0c             	pushl  0xc(%ebp)
  801d7d:	e8 a3 eb ff ff       	call   800925 <memmove>
  801d82:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d85:	89 d8                	mov    %ebx,%eax
  801d87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	53                   	push   %ebx
  801d92:	83 ec 04             	sub    $0x4,%esp
  801d95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d98:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801da0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801da6:	7e 16                	jle    801dbe <nsipc_send+0x30>
  801da8:	68 97 28 80 00       	push   $0x802897
  801dad:	68 1f 28 80 00       	push   $0x80281f
  801db2:	6a 6d                	push   $0x6d
  801db4:	68 8b 28 80 00       	push   $0x80288b
  801db9:	e8 57 e3 ff ff       	call   800115 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dbe:	83 ec 04             	sub    $0x4,%esp
  801dc1:	53                   	push   %ebx
  801dc2:	ff 75 0c             	pushl  0xc(%ebp)
  801dc5:	68 0c 60 80 00       	push   $0x80600c
  801dca:	e8 56 eb ff ff       	call   800925 <memmove>
	nsipcbuf.send.req_size = size;
  801dcf:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801dd5:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ddd:	b8 08 00 00 00       	mov    $0x8,%eax
  801de2:	e8 d9 fd ff ff       	call   801bc0 <nsipc>
}
  801de7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801df2:	8b 45 08             	mov    0x8(%ebp),%eax
  801df5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfd:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e02:	8b 45 10             	mov    0x10(%ebp),%eax
  801e05:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e0a:	b8 09 00 00 00       	mov    $0x9,%eax
  801e0f:	e8 ac fd ff ff       	call   801bc0 <nsipc>
}
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e19:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1e:	5d                   	pop    %ebp
  801e1f:	c3                   	ret    

00801e20 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e26:	68 a3 28 80 00       	push   $0x8028a3
  801e2b:	ff 75 0c             	pushl  0xc(%ebp)
  801e2e:	e8 60 e9 ff ff       	call   800793 <strcpy>
	return 0;
}
  801e33:	b8 00 00 00 00       	mov    $0x0,%eax
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	57                   	push   %edi
  801e3e:	56                   	push   %esi
  801e3f:	53                   	push   %ebx
  801e40:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e46:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e4b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e51:	eb 2d                	jmp    801e80 <devcons_write+0x46>
		m = n - tot;
  801e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e56:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e58:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e5b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e60:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e63:	83 ec 04             	sub    $0x4,%esp
  801e66:	53                   	push   %ebx
  801e67:	03 45 0c             	add    0xc(%ebp),%eax
  801e6a:	50                   	push   %eax
  801e6b:	57                   	push   %edi
  801e6c:	e8 b4 ea ff ff       	call   800925 <memmove>
		sys_cputs(buf, m);
  801e71:	83 c4 08             	add    $0x8,%esp
  801e74:	53                   	push   %ebx
  801e75:	57                   	push   %edi
  801e76:	e8 5f ec ff ff       	call   800ada <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7b:	01 de                	add    %ebx,%esi
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	89 f0                	mov    %esi,%eax
  801e82:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e85:	72 cc                	jb     801e53 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8a:	5b                   	pop    %ebx
  801e8b:	5e                   	pop    %esi
  801e8c:	5f                   	pop    %edi
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	83 ec 08             	sub    $0x8,%esp
  801e95:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e9e:	74 2a                	je     801eca <devcons_read+0x3b>
  801ea0:	eb 05                	jmp    801ea7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ea2:	e8 d0 ec ff ff       	call   800b77 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ea7:	e8 4c ec ff ff       	call   800af8 <sys_cgetc>
  801eac:	85 c0                	test   %eax,%eax
  801eae:	74 f2                	je     801ea2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	78 16                	js     801eca <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eb4:	83 f8 04             	cmp    $0x4,%eax
  801eb7:	74 0c                	je     801ec5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ebc:	88 02                	mov    %al,(%edx)
	return 1;
  801ebe:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec3:	eb 05                	jmp    801eca <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eca:	c9                   	leave  
  801ecb:	c3                   	ret    

00801ecc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ed8:	6a 01                	push   $0x1
  801eda:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801edd:	50                   	push   %eax
  801ede:	e8 f7 eb ff ff       	call   800ada <sys_cputs>
}
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	c9                   	leave  
  801ee7:	c3                   	ret    

00801ee8 <getchar>:

int
getchar(void)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801eee:	6a 01                	push   $0x1
  801ef0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ef3:	50                   	push   %eax
  801ef4:	6a 00                	push   $0x0
  801ef6:	e8 1d f2 ff ff       	call   801118 <read>
	if (r < 0)
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	85 c0                	test   %eax,%eax
  801f00:	78 0f                	js     801f11 <getchar+0x29>
		return r;
	if (r < 1)
  801f02:	85 c0                	test   %eax,%eax
  801f04:	7e 06                	jle    801f0c <getchar+0x24>
		return -E_EOF;
	return c;
  801f06:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f0a:	eb 05                	jmp    801f11 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f0c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1c:	50                   	push   %eax
  801f1d:	ff 75 08             	pushl  0x8(%ebp)
  801f20:	e8 8d ef ff ff       	call   800eb2 <fd_lookup>
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 11                	js     801f3d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f35:	39 10                	cmp    %edx,(%eax)
  801f37:	0f 94 c0             	sete   %al
  801f3a:	0f b6 c0             	movzbl %al,%eax
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <opencons>:

int
opencons(void)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f48:	50                   	push   %eax
  801f49:	e8 15 ef ff ff       	call   800e63 <fd_alloc>
  801f4e:	83 c4 10             	add    $0x10,%esp
		return r;
  801f51:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f53:	85 c0                	test   %eax,%eax
  801f55:	78 3e                	js     801f95 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f57:	83 ec 04             	sub    $0x4,%esp
  801f5a:	68 07 04 00 00       	push   $0x407
  801f5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f62:	6a 00                	push   $0x0
  801f64:	e8 2d ec ff ff       	call   800b96 <sys_page_alloc>
  801f69:	83 c4 10             	add    $0x10,%esp
		return r;
  801f6c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 23                	js     801f95 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f72:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f80:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f87:	83 ec 0c             	sub    $0xc,%esp
  801f8a:	50                   	push   %eax
  801f8b:	e8 ac ee ff ff       	call   800e3c <fd2num>
  801f90:	89 c2                	mov    %eax,%edx
  801f92:	83 c4 10             	add    $0x10,%esp
}
  801f95:	89 d0                	mov    %edx,%eax
  801f97:	c9                   	leave  
  801f98:	c3                   	ret    

00801f99 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	56                   	push   %esi
  801f9d:	53                   	push   %ebx
  801f9e:	8b 75 08             	mov    0x8(%ebp),%esi
  801fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	74 0e                	je     801fb9 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801fab:	83 ec 0c             	sub    $0xc,%esp
  801fae:	50                   	push   %eax
  801faf:	e8 92 ed ff ff       	call   800d46 <sys_ipc_recv>
  801fb4:	83 c4 10             	add    $0x10,%esp
  801fb7:	eb 10                	jmp    801fc9 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	68 00 00 c0 ee       	push   $0xeec00000
  801fc1:	e8 80 ed ff ff       	call   800d46 <sys_ipc_recv>
  801fc6:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	79 17                	jns    801fe4 <ipc_recv+0x4b>
		if(*from_env_store)
  801fcd:	83 3e 00             	cmpl   $0x0,(%esi)
  801fd0:	74 06                	je     801fd8 <ipc_recv+0x3f>
			*from_env_store = 0;
  801fd2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801fd8:	85 db                	test   %ebx,%ebx
  801fda:	74 2c                	je     802008 <ipc_recv+0x6f>
			*perm_store = 0;
  801fdc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fe2:	eb 24                	jmp    802008 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801fe4:	85 f6                	test   %esi,%esi
  801fe6:	74 0a                	je     801ff2 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801fe8:	a1 08 40 80 00       	mov    0x804008,%eax
  801fed:	8b 40 74             	mov    0x74(%eax),%eax
  801ff0:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801ff2:	85 db                	test   %ebx,%ebx
  801ff4:	74 0a                	je     802000 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801ff6:	a1 08 40 80 00       	mov    0x804008,%eax
  801ffb:	8b 40 78             	mov    0x78(%eax),%eax
  801ffe:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802000:	a1 08 40 80 00       	mov    0x804008,%eax
  802005:	8b 40 70             	mov    0x70(%eax),%eax
}
  802008:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200b:	5b                   	pop    %ebx
  80200c:	5e                   	pop    %esi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    

0080200f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	57                   	push   %edi
  802013:	56                   	push   %esi
  802014:	53                   	push   %ebx
  802015:	83 ec 0c             	sub    $0xc,%esp
  802018:	8b 7d 08             	mov    0x8(%ebp),%edi
  80201b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80201e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802021:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  802023:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802028:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  80202b:	e8 47 eb ff ff       	call   800b77 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  802030:	ff 75 14             	pushl  0x14(%ebp)
  802033:	53                   	push   %ebx
  802034:	56                   	push   %esi
  802035:	57                   	push   %edi
  802036:	e8 e8 ec ff ff       	call   800d23 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  80203b:	89 c2                	mov    %eax,%edx
  80203d:	f7 d2                	not    %edx
  80203f:	c1 ea 1f             	shr    $0x1f,%edx
  802042:	83 c4 10             	add    $0x10,%esp
  802045:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802048:	0f 94 c1             	sete   %cl
  80204b:	09 ca                	or     %ecx,%edx
  80204d:	85 c0                	test   %eax,%eax
  80204f:	0f 94 c0             	sete   %al
  802052:	38 c2                	cmp    %al,%dl
  802054:	77 d5                	ja     80202b <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802056:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802059:	5b                   	pop    %ebx
  80205a:	5e                   	pop    %esi
  80205b:	5f                   	pop    %edi
  80205c:	5d                   	pop    %ebp
  80205d:	c3                   	ret    

0080205e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802064:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802069:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80206c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802072:	8b 52 50             	mov    0x50(%edx),%edx
  802075:	39 ca                	cmp    %ecx,%edx
  802077:	75 0d                	jne    802086 <ipc_find_env+0x28>
			return envs[i].env_id;
  802079:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80207c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802081:	8b 40 48             	mov    0x48(%eax),%eax
  802084:	eb 0f                	jmp    802095 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802086:	83 c0 01             	add    $0x1,%eax
  802089:	3d 00 04 00 00       	cmp    $0x400,%eax
  80208e:	75 d9                	jne    802069 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802090:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    

00802097 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80209d:	89 d0                	mov    %edx,%eax
  80209f:	c1 e8 16             	shr    $0x16,%eax
  8020a2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020a9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ae:	f6 c1 01             	test   $0x1,%cl
  8020b1:	74 1d                	je     8020d0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020b3:	c1 ea 0c             	shr    $0xc,%edx
  8020b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020bd:	f6 c2 01             	test   $0x1,%dl
  8020c0:	74 0e                	je     8020d0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020c2:	c1 ea 0c             	shr    $0xc,%edx
  8020c5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020cc:	ef 
  8020cd:	0f b7 c0             	movzwl %ax,%eax
}
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	66 90                	xchg   %ax,%ax
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 f6                	test   %esi,%esi
  8020f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020fd:	89 ca                	mov    %ecx,%edx
  8020ff:	89 f8                	mov    %edi,%eax
  802101:	75 3d                	jne    802140 <__udivdi3+0x60>
  802103:	39 cf                	cmp    %ecx,%edi
  802105:	0f 87 c5 00 00 00    	ja     8021d0 <__udivdi3+0xf0>
  80210b:	85 ff                	test   %edi,%edi
  80210d:	89 fd                	mov    %edi,%ebp
  80210f:	75 0b                	jne    80211c <__udivdi3+0x3c>
  802111:	b8 01 00 00 00       	mov    $0x1,%eax
  802116:	31 d2                	xor    %edx,%edx
  802118:	f7 f7                	div    %edi
  80211a:	89 c5                	mov    %eax,%ebp
  80211c:	89 c8                	mov    %ecx,%eax
  80211e:	31 d2                	xor    %edx,%edx
  802120:	f7 f5                	div    %ebp
  802122:	89 c1                	mov    %eax,%ecx
  802124:	89 d8                	mov    %ebx,%eax
  802126:	89 cf                	mov    %ecx,%edi
  802128:	f7 f5                	div    %ebp
  80212a:	89 c3                	mov    %eax,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	39 ce                	cmp    %ecx,%esi
  802142:	77 74                	ja     8021b8 <__udivdi3+0xd8>
  802144:	0f bd fe             	bsr    %esi,%edi
  802147:	83 f7 1f             	xor    $0x1f,%edi
  80214a:	0f 84 98 00 00 00    	je     8021e8 <__udivdi3+0x108>
  802150:	bb 20 00 00 00       	mov    $0x20,%ebx
  802155:	89 f9                	mov    %edi,%ecx
  802157:	89 c5                	mov    %eax,%ebp
  802159:	29 fb                	sub    %edi,%ebx
  80215b:	d3 e6                	shl    %cl,%esi
  80215d:	89 d9                	mov    %ebx,%ecx
  80215f:	d3 ed                	shr    %cl,%ebp
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e0                	shl    %cl,%eax
  802165:	09 ee                	or     %ebp,%esi
  802167:	89 d9                	mov    %ebx,%ecx
  802169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216d:	89 d5                	mov    %edx,%ebp
  80216f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802173:	d3 ed                	shr    %cl,%ebp
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e2                	shl    %cl,%edx
  802179:	89 d9                	mov    %ebx,%ecx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	09 c2                	or     %eax,%edx
  80217f:	89 d0                	mov    %edx,%eax
  802181:	89 ea                	mov    %ebp,%edx
  802183:	f7 f6                	div    %esi
  802185:	89 d5                	mov    %edx,%ebp
  802187:	89 c3                	mov    %eax,%ebx
  802189:	f7 64 24 0c          	mull   0xc(%esp)
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	72 10                	jb     8021a1 <__udivdi3+0xc1>
  802191:	8b 74 24 08          	mov    0x8(%esp),%esi
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e6                	shl    %cl,%esi
  802199:	39 c6                	cmp    %eax,%esi
  80219b:	73 07                	jae    8021a4 <__udivdi3+0xc4>
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	75 03                	jne    8021a4 <__udivdi3+0xc4>
  8021a1:	83 eb 01             	sub    $0x1,%ebx
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 d8                	mov    %ebx,%eax
  8021a8:	89 fa                	mov    %edi,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	31 ff                	xor    %edi,%edi
  8021ba:	31 db                	xor    %ebx,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d8                	mov    %ebx,%eax
  8021d2:	f7 f7                	div    %edi
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 c3                	mov    %eax,%ebx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 fa                	mov    %edi,%edx
  8021dc:	83 c4 1c             	add    $0x1c,%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	39 ce                	cmp    %ecx,%esi
  8021ea:	72 0c                	jb     8021f8 <__udivdi3+0x118>
  8021ec:	31 db                	xor    %ebx,%ebx
  8021ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021f2:	0f 87 34 ff ff ff    	ja     80212c <__udivdi3+0x4c>
  8021f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021fd:	e9 2a ff ff ff       	jmp    80212c <__udivdi3+0x4c>
  802202:	66 90                	xchg   %ax,%ax
  802204:	66 90                	xchg   %ax,%ax
  802206:	66 90                	xchg   %ax,%ax
  802208:	66 90                	xchg   %ax,%ax
  80220a:	66 90                	xchg   %ax,%ax
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__umoddi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80221b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80221f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 d2                	test   %edx,%edx
  802229:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80222d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802231:	89 f3                	mov    %esi,%ebx
  802233:	89 3c 24             	mov    %edi,(%esp)
  802236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223a:	75 1c                	jne    802258 <__umoddi3+0x48>
  80223c:	39 f7                	cmp    %esi,%edi
  80223e:	76 50                	jbe    802290 <__umoddi3+0x80>
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	f7 f7                	div    %edi
  802246:	89 d0                	mov    %edx,%eax
  802248:	31 d2                	xor    %edx,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	39 f2                	cmp    %esi,%edx
  80225a:	89 d0                	mov    %edx,%eax
  80225c:	77 52                	ja     8022b0 <__umoddi3+0xa0>
  80225e:	0f bd ea             	bsr    %edx,%ebp
  802261:	83 f5 1f             	xor    $0x1f,%ebp
  802264:	75 5a                	jne    8022c0 <__umoddi3+0xb0>
  802266:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80226a:	0f 82 e0 00 00 00    	jb     802350 <__umoddi3+0x140>
  802270:	39 0c 24             	cmp    %ecx,(%esp)
  802273:	0f 86 d7 00 00 00    	jbe    802350 <__umoddi3+0x140>
  802279:	8b 44 24 08          	mov    0x8(%esp),%eax
  80227d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802281:	83 c4 1c             	add    $0x1c,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5f                   	pop    %edi
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	85 ff                	test   %edi,%edi
  802292:	89 fd                	mov    %edi,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x91>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f7                	div    %edi
  80229f:	89 c5                	mov    %eax,%ebp
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f5                	div    %ebp
  8022a7:	89 c8                	mov    %ecx,%eax
  8022a9:	f7 f5                	div    %ebp
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	eb 99                	jmp    802248 <__umoddi3+0x38>
  8022af:	90                   	nop
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	83 c4 1c             	add    $0x1c,%esp
  8022b7:	5b                   	pop    %ebx
  8022b8:	5e                   	pop    %esi
  8022b9:	5f                   	pop    %edi
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	8b 34 24             	mov    (%esp),%esi
  8022c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022c8:	89 e9                	mov    %ebp,%ecx
  8022ca:	29 ef                	sub    %ebp,%edi
  8022cc:	d3 e0                	shl    %cl,%eax
  8022ce:	89 f9                	mov    %edi,%ecx
  8022d0:	89 f2                	mov    %esi,%edx
  8022d2:	d3 ea                	shr    %cl,%edx
  8022d4:	89 e9                	mov    %ebp,%ecx
  8022d6:	09 c2                	or     %eax,%edx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 14 24             	mov    %edx,(%esp)
  8022dd:	89 f2                	mov    %esi,%edx
  8022df:	d3 e2                	shl    %cl,%edx
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	89 c6                	mov    %eax,%esi
  8022f1:	d3 e3                	shl    %cl,%ebx
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 d0                	mov    %edx,%eax
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	09 d8                	or     %ebx,%eax
  8022fd:	89 d3                	mov    %edx,%ebx
  8022ff:	89 f2                	mov    %esi,%edx
  802301:	f7 34 24             	divl   (%esp)
  802304:	89 d6                	mov    %edx,%esi
  802306:	d3 e3                	shl    %cl,%ebx
  802308:	f7 64 24 04          	mull   0x4(%esp)
  80230c:	39 d6                	cmp    %edx,%esi
  80230e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802312:	89 d1                	mov    %edx,%ecx
  802314:	89 c3                	mov    %eax,%ebx
  802316:	72 08                	jb     802320 <__umoddi3+0x110>
  802318:	75 11                	jne    80232b <__umoddi3+0x11b>
  80231a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80231e:	73 0b                	jae    80232b <__umoddi3+0x11b>
  802320:	2b 44 24 04          	sub    0x4(%esp),%eax
  802324:	1b 14 24             	sbb    (%esp),%edx
  802327:	89 d1                	mov    %edx,%ecx
  802329:	89 c3                	mov    %eax,%ebx
  80232b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80232f:	29 da                	sub    %ebx,%edx
  802331:	19 ce                	sbb    %ecx,%esi
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 f0                	mov    %esi,%eax
  802337:	d3 e0                	shl    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	d3 ea                	shr    %cl,%edx
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	d3 ee                	shr    %cl,%esi
  802341:	09 d0                	or     %edx,%eax
  802343:	89 f2                	mov    %esi,%edx
  802345:	83 c4 1c             	add    $0x1c,%esp
  802348:	5b                   	pop    %ebx
  802349:	5e                   	pop    %esi
  80234a:	5f                   	pop    %edi
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    
  80234d:	8d 76 00             	lea    0x0(%esi),%esi
  802350:	29 f9                	sub    %edi,%ecx
  802352:	19 d6                	sbb    %edx,%esi
  802354:	89 74 24 04          	mov    %esi,0x4(%esp)
  802358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80235c:	e9 18 ff ff ff       	jmp    802279 <__umoddi3+0x69>
