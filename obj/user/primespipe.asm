
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 71 15 00 00       	call   8015c2 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 20 28 80 00       	push   $0x802820
  80006d:	6a 15                	push   $0x15
  80006f:	68 4f 28 80 00       	push   $0x80284f
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 61 28 80 00       	push   $0x802861
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 b1 1b 00 00       	call   801c42 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 65 28 80 00       	push   $0x802865
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 4f 28 80 00       	push   $0x80284f
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 6b 0f 00 00       	call   80101d <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 6e 28 80 00       	push   $0x80286e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 4f 28 80 00       	push   $0x80284f
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 20 13 00 00       	call   8013f5 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 15 13 00 00       	call   8013f5 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 ff 12 00 00       	call   8013f5 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 b7 14 00 00       	call   8015c2 <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 77 28 80 00       	push   $0x802877
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 4f 28 80 00       	push   $0x80284f
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 bd 14 00 00       	call   80160b <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 93 28 80 00       	push   $0x802893
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 4f 28 80 00       	push   $0x80284f
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 ad 	movl   $0x8028ad,0x803000
  800187:	28 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 af 1a 00 00       	call   801c42 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 65 28 80 00       	push   $0x802865
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 4f 28 80 00       	push   $0x80284f
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 69 0e 00 00       	call   80101d <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 6e 28 80 00       	push   $0x80286e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 4f 28 80 00       	push   $0x80284f
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 1c 12 00 00       	call   8013f5 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 06 12 00 00       	call   8013f5 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 01 14 00 00       	call   80160b <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 b8 28 80 00       	push   $0x8028b8
  800226:	6a 4a                	push   $0x4a
  800228:	68 4f 28 80 00       	push   $0x80284f
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800243:	e8 93 0a 00 00       	call   800cdb <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 97 11 00 00       	call   801420 <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 07 0a 00 00       	call   800c9a <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 30 0a 00 00       	call   800cdb <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 dc 28 80 00       	push   $0x8028dc
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 63 28 80 00 	movl   $0x802863,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 4f 09 00 00       	call   800c5d <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 54 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 f4 08 00 00       	call   800c5d <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 b7 21 00 00       	call   802590 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 a4 22 00 00       	call   8026c0 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 ff 28 80 00 	movsbl 0x8028ff(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800437:	83 fa 01             	cmp    $0x1,%edx
  80043a:	7e 0e                	jle    80044a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	8b 52 04             	mov    0x4(%edx),%edx
  800448:	eb 22                	jmp    80046c <getuint+0x38>
	else if (lflag)
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 10                	je     80045e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 04             	lea    0x4(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 0e                	jmp    80046c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800474:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	3b 50 04             	cmp    0x4(%eax),%edx
  80047d:	73 0a                	jae    800489 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800482:	89 08                	mov    %ecx,(%eax)
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	88 02                	mov    %al,(%edx)
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
	va_end(ap);
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 2c             	sub    $0x2c,%esp
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ba:	eb 12                	jmp    8004ce <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	0f 84 a9 03 00 00    	je     80086d <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	50                   	push   %eax
  8004c9:	ff d6                	call   *%esi
  8004cb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ce:	83 c7 01             	add    $0x1,%edi
  8004d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d5:	83 f8 25             	cmp    $0x25,%eax
  8004d8:	75 e2                	jne    8004bc <vprintfmt+0x14>
  8004da:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f8:	eb 07                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8d 47 01             	lea    0x1(%edi),%eax
  800504:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800507:	0f b6 07             	movzbl (%edi),%eax
  80050a:	0f b6 c8             	movzbl %al,%ecx
  80050d:	83 e8 23             	sub    $0x23,%eax
  800510:	3c 55                	cmp    $0x55,%al
  800512:	0f 87 3a 03 00 00    	ja     800852 <vprintfmt+0x3aa>
  800518:	0f b6 c0             	movzbl %al,%eax
  80051b:	ff 24 85 40 2a 80 00 	jmp    *0x802a40(,%eax,4)
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800525:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800529:	eb d6                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052e:	b8 00 00 00 00       	mov    $0x0,%eax
  800533:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800536:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800539:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80053d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800540:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800543:	83 fa 09             	cmp    $0x9,%edx
  800546:	77 39                	ja     800581 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800548:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80054b:	eb e9                	jmp    800536 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 48 04             	lea    0x4(%eax),%ecx
  800553:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055e:	eb 27                	jmp    800587 <vprintfmt+0xdf>
  800560:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800563:	85 c0                	test   %eax,%eax
  800565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056a:	0f 49 c8             	cmovns %eax,%ecx
  80056d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800573:	eb 8c                	jmp    800501 <vprintfmt+0x59>
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800578:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057f:	eb 80                	jmp    800501 <vprintfmt+0x59>
  800581:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800584:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 89 70 ff ff ff    	jns    800501 <vprintfmt+0x59>
				width = precision, precision = -1;
  800591:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800594:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800597:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059e:	e9 5e ff ff ff       	jmp    800501 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a9:	e9 53 ff ff ff       	jmp    800501 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	ff 30                	pushl  (%eax)
  8005bd:	ff d6                	call   *%esi
			break;
  8005bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c5:	e9 04 ff ff ff       	jmp    8004ce <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	99                   	cltd   
  8005d6:	31 d0                	xor    %edx,%eax
  8005d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005da:	83 f8 0f             	cmp    $0xf,%eax
  8005dd:	7f 0b                	jg     8005ea <vprintfmt+0x142>
  8005df:	8b 14 85 a0 2b 80 00 	mov    0x802ba0(,%eax,4),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 18                	jne    800602 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 17 29 80 00       	push   $0x802917
  8005f0:	53                   	push   %ebx
  8005f1:	56                   	push   %esi
  8005f2:	e8 94 fe ff ff       	call   80048b <printfmt>
  8005f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fd:	e9 cc fe ff ff       	jmp    8004ce <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800602:	52                   	push   %edx
  800603:	68 ad 2d 80 00       	push   $0x802dad
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 7c fe ff ff       	call   80048b <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800615:	e9 b4 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
  800623:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800625:	85 ff                	test   %edi,%edi
  800627:	b8 10 29 80 00       	mov    $0x802910,%eax
  80062c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80062f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800633:	0f 8e 94 00 00 00    	jle    8006cd <vprintfmt+0x225>
  800639:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80063d:	0f 84 98 00 00 00    	je     8006db <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	ff 75 d0             	pushl  -0x30(%ebp)
  800649:	57                   	push   %edi
  80064a:	e8 a6 02 00 00       	call   8008f5 <strnlen>
  80064f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800652:	29 c1                	sub    %eax,%ecx
  800654:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800657:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80065a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800661:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800664:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	eb 0f                	jmp    800677 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	ff 75 e0             	pushl  -0x20(%ebp)
  80066f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800671:	83 ef 01             	sub    $0x1,%edi
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	85 ff                	test   %edi,%edi
  800679:	7f ed                	jg     800668 <vprintfmt+0x1c0>
  80067b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800681:	85 c9                	test   %ecx,%ecx
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	0f 49 c1             	cmovns %ecx,%eax
  80068b:	29 c1                	sub    %eax,%ecx
  80068d:	89 75 08             	mov    %esi,0x8(%ebp)
  800690:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800693:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800696:	89 cb                	mov    %ecx,%ebx
  800698:	eb 4d                	jmp    8006e7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069e:	74 1b                	je     8006bb <vprintfmt+0x213>
  8006a0:	0f be c0             	movsbl %al,%eax
  8006a3:	83 e8 20             	sub    $0x20,%eax
  8006a6:	83 f8 5e             	cmp    $0x5e,%eax
  8006a9:	76 10                	jbe    8006bb <vprintfmt+0x213>
					putch('?', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	6a 3f                	push   $0x3f
  8006b3:	ff 55 08             	call   *0x8(%ebp)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	52                   	push   %edx
  8006c2:	ff 55 08             	call   *0x8(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c8:	83 eb 01             	sub    $0x1,%ebx
  8006cb:	eb 1a                	jmp    8006e7 <vprintfmt+0x23f>
  8006cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d9:	eb 0c                	jmp    8006e7 <vprintfmt+0x23f>
  8006db:	89 75 08             	mov    %esi,0x8(%ebp)
  8006de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e7:	83 c7 01             	add    $0x1,%edi
  8006ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ee:	0f be d0             	movsbl %al,%edx
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	74 23                	je     800718 <vprintfmt+0x270>
  8006f5:	85 f6                	test   %esi,%esi
  8006f7:	78 a1                	js     80069a <vprintfmt+0x1f2>
  8006f9:	83 ee 01             	sub    $0x1,%esi
  8006fc:	79 9c                	jns    80069a <vprintfmt+0x1f2>
  8006fe:	89 df                	mov    %ebx,%edi
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800706:	eb 18                	jmp    800720 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 20                	push   $0x20
  80070e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800710:	83 ef 01             	sub    $0x1,%edi
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 08                	jmp    800720 <vprintfmt+0x278>
  800718:	89 df                	mov    %ebx,%edi
  80071a:	8b 75 08             	mov    0x8(%ebp),%esi
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800720:	85 ff                	test   %edi,%edi
  800722:	7f e4                	jg     800708 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800727:	e9 a2 fd ff ff       	jmp    8004ce <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072c:	83 fa 01             	cmp    $0x1,%edx
  80072f:	7e 16                	jle    800747 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 08             	lea    0x8(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 50 04             	mov    0x4(%eax),%edx
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800742:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800745:	eb 32                	jmp    800779 <vprintfmt+0x2d1>
	else if (lflag)
  800747:	85 d2                	test   %edx,%edx
  800749:	74 18                	je     800763 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 50 04             	lea    0x4(%eax),%edx
  800751:	89 55 14             	mov    %edx,0x14(%ebp)
  800754:	8b 00                	mov    (%eax),%eax
  800756:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800759:	89 c1                	mov    %eax,%ecx
  80075b:	c1 f9 1f             	sar    $0x1f,%ecx
  80075e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800761:	eb 16                	jmp    800779 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800771:	89 c1                	mov    %eax,%ecx
  800773:	c1 f9 1f             	sar    $0x1f,%ecx
  800776:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800779:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800784:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800788:	0f 89 90 00 00 00    	jns    80081e <vprintfmt+0x376>
				putch('-', putdat);
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	53                   	push   %ebx
  800792:	6a 2d                	push   $0x2d
  800794:	ff d6                	call   *%esi
				num = -(long long) num;
  800796:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800799:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80079c:	f7 d8                	neg    %eax
  80079e:	83 d2 00             	adc    $0x0,%edx
  8007a1:	f7 da                	neg    %edx
  8007a3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007ab:	eb 71                	jmp    80081e <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b0:	e8 7f fc ff ff       	call   800434 <getuint>
			base = 10;
  8007b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007ba:	eb 62                	jmp    80081e <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bf:	e8 70 fc ff ff       	call   800434 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8007c4:	83 ec 0c             	sub    $0xc,%esp
  8007c7:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8007cb:	51                   	push   %ecx
  8007cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8007cf:	6a 08                	push   $0x8
  8007d1:	52                   	push   %edx
  8007d2:	50                   	push   %eax
  8007d3:	89 da                	mov    %ebx,%edx
  8007d5:	89 f0                	mov    %esi,%eax
  8007d7:	e8 a9 fb ff ff       	call   800385 <printnum>
			break;
  8007dc:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  8007e2:	e9 e7 fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8007e7:	83 ec 08             	sub    $0x8,%esp
  8007ea:	53                   	push   %ebx
  8007eb:	6a 30                	push   $0x30
  8007ed:	ff d6                	call   *%esi
			putch('x', putdat);
  8007ef:	83 c4 08             	add    $0x8,%esp
  8007f2:	53                   	push   %ebx
  8007f3:	6a 78                	push   $0x78
  8007f5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8d 50 04             	lea    0x4(%eax),%edx
  8007fd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800800:	8b 00                	mov    (%eax),%eax
  800802:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800807:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80080f:	eb 0d                	jmp    80081e <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800811:	8d 45 14             	lea    0x14(%ebp),%eax
  800814:	e8 1b fc ff ff       	call   800434 <getuint>
			base = 16;
  800819:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081e:	83 ec 0c             	sub    $0xc,%esp
  800821:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800825:	57                   	push   %edi
  800826:	ff 75 e0             	pushl  -0x20(%ebp)
  800829:	51                   	push   %ecx
  80082a:	52                   	push   %edx
  80082b:	50                   	push   %eax
  80082c:	89 da                	mov    %ebx,%edx
  80082e:	89 f0                	mov    %esi,%eax
  800830:	e8 50 fb ff ff       	call   800385 <printnum>
			break;
  800835:	83 c4 20             	add    $0x20,%esp
  800838:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80083b:	e9 8e fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	53                   	push   %ebx
  800844:	51                   	push   %ecx
  800845:	ff d6                	call   *%esi
			break;
  800847:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80084d:	e9 7c fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800852:	83 ec 08             	sub    $0x8,%esp
  800855:	53                   	push   %ebx
  800856:	6a 25                	push   $0x25
  800858:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085a:	83 c4 10             	add    $0x10,%esp
  80085d:	eb 03                	jmp    800862 <vprintfmt+0x3ba>
  80085f:	83 ef 01             	sub    $0x1,%edi
  800862:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800866:	75 f7                	jne    80085f <vprintfmt+0x3b7>
  800868:	e9 61 fc ff ff       	jmp    8004ce <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80086d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5f                   	pop    %edi
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 18             	sub    $0x18,%esp
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800881:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800884:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800888:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80088b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800892:	85 c0                	test   %eax,%eax
  800894:	74 26                	je     8008bc <vsnprintf+0x47>
  800896:	85 d2                	test   %edx,%edx
  800898:	7e 22                	jle    8008bc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089a:	ff 75 14             	pushl  0x14(%ebp)
  80089d:	ff 75 10             	pushl  0x10(%ebp)
  8008a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a3:	50                   	push   %eax
  8008a4:	68 6e 04 80 00       	push   $0x80046e
  8008a9:	e8 fa fb ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	eb 05                	jmp    8008c1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    

008008c3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008cc:	50                   	push   %eax
  8008cd:	ff 75 10             	pushl  0x10(%ebp)
  8008d0:	ff 75 0c             	pushl  0xc(%ebp)
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 9a ff ff ff       	call   800875 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e8:	eb 03                	jmp    8008ed <strlen+0x10>
		n++;
  8008ea:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f1:	75 f7                	jne    8008ea <strlen+0xd>
		n++;
	return n;
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800903:	eb 03                	jmp    800908 <strnlen+0x13>
		n++;
  800905:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800908:	39 c2                	cmp    %eax,%edx
  80090a:	74 08                	je     800914 <strnlen+0x1f>
  80090c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800910:	75 f3                	jne    800905 <strnlen+0x10>
  800912:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	53                   	push   %ebx
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800920:	89 c2                	mov    %eax,%edx
  800922:	83 c2 01             	add    $0x1,%edx
  800925:	83 c1 01             	add    $0x1,%ecx
  800928:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80092c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80092f:	84 db                	test   %bl,%bl
  800931:	75 ef                	jne    800922 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800933:	5b                   	pop    %ebx
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80093d:	53                   	push   %ebx
  80093e:	e8 9a ff ff ff       	call   8008dd <strlen>
  800943:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800946:	ff 75 0c             	pushl  0xc(%ebp)
  800949:	01 d8                	add    %ebx,%eax
  80094b:	50                   	push   %eax
  80094c:	e8 c5 ff ff ff       	call   800916 <strcpy>
	return dst;
}
  800951:	89 d8                	mov    %ebx,%eax
  800953:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 75 08             	mov    0x8(%ebp),%esi
  800960:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800963:	89 f3                	mov    %esi,%ebx
  800965:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800968:	89 f2                	mov    %esi,%edx
  80096a:	eb 0f                	jmp    80097b <strncpy+0x23>
		*dst++ = *src;
  80096c:	83 c2 01             	add    $0x1,%edx
  80096f:	0f b6 01             	movzbl (%ecx),%eax
  800972:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800975:	80 39 01             	cmpb   $0x1,(%ecx)
  800978:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097b:	39 da                	cmp    %ebx,%edx
  80097d:	75 ed                	jne    80096c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80097f:	89 f0                	mov    %esi,%eax
  800981:	5b                   	pop    %ebx
  800982:	5e                   	pop    %esi
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	56                   	push   %esi
  800989:	53                   	push   %ebx
  80098a:	8b 75 08             	mov    0x8(%ebp),%esi
  80098d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800990:	8b 55 10             	mov    0x10(%ebp),%edx
  800993:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800995:	85 d2                	test   %edx,%edx
  800997:	74 21                	je     8009ba <strlcpy+0x35>
  800999:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80099d:	89 f2                	mov    %esi,%edx
  80099f:	eb 09                	jmp    8009aa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a1:	83 c2 01             	add    $0x1,%edx
  8009a4:	83 c1 01             	add    $0x1,%ecx
  8009a7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009aa:	39 c2                	cmp    %eax,%edx
  8009ac:	74 09                	je     8009b7 <strlcpy+0x32>
  8009ae:	0f b6 19             	movzbl (%ecx),%ebx
  8009b1:	84 db                	test   %bl,%bl
  8009b3:	75 ec                	jne    8009a1 <strlcpy+0x1c>
  8009b5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ba:	29 f0                	sub    %esi,%eax
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c9:	eb 06                	jmp    8009d1 <strcmp+0x11>
		p++, q++;
  8009cb:	83 c1 01             	add    $0x1,%ecx
  8009ce:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d1:	0f b6 01             	movzbl (%ecx),%eax
  8009d4:	84 c0                	test   %al,%al
  8009d6:	74 04                	je     8009dc <strcmp+0x1c>
  8009d8:	3a 02                	cmp    (%edx),%al
  8009da:	74 ef                	je     8009cb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009dc:	0f b6 c0             	movzbl %al,%eax
  8009df:	0f b6 12             	movzbl (%edx),%edx
  8009e2:	29 d0                	sub    %edx,%eax
}
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	53                   	push   %ebx
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f0:	89 c3                	mov    %eax,%ebx
  8009f2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f5:	eb 06                	jmp    8009fd <strncmp+0x17>
		n--, p++, q++;
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009fd:	39 d8                	cmp    %ebx,%eax
  8009ff:	74 15                	je     800a16 <strncmp+0x30>
  800a01:	0f b6 08             	movzbl (%eax),%ecx
  800a04:	84 c9                	test   %cl,%cl
  800a06:	74 04                	je     800a0c <strncmp+0x26>
  800a08:	3a 0a                	cmp    (%edx),%cl
  800a0a:	74 eb                	je     8009f7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0c:	0f b6 00             	movzbl (%eax),%eax
  800a0f:	0f b6 12             	movzbl (%edx),%edx
  800a12:	29 d0                	sub    %edx,%eax
  800a14:	eb 05                	jmp    800a1b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a1b:	5b                   	pop    %ebx
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a28:	eb 07                	jmp    800a31 <strchr+0x13>
		if (*s == c)
  800a2a:	38 ca                	cmp    %cl,%dl
  800a2c:	74 0f                	je     800a3d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a2e:	83 c0 01             	add    $0x1,%eax
  800a31:	0f b6 10             	movzbl (%eax),%edx
  800a34:	84 d2                	test   %dl,%dl
  800a36:	75 f2                	jne    800a2a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a49:	eb 03                	jmp    800a4e <strfind+0xf>
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a51:	38 ca                	cmp    %cl,%dl
  800a53:	74 04                	je     800a59 <strfind+0x1a>
  800a55:	84 d2                	test   %dl,%dl
  800a57:	75 f2                	jne    800a4b <strfind+0xc>
			break;
	return (char *) s;
}
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a64:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a67:	85 c9                	test   %ecx,%ecx
  800a69:	74 36                	je     800aa1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a71:	75 28                	jne    800a9b <memset+0x40>
  800a73:	f6 c1 03             	test   $0x3,%cl
  800a76:	75 23                	jne    800a9b <memset+0x40>
		c &= 0xFF;
  800a78:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a7c:	89 d3                	mov    %edx,%ebx
  800a7e:	c1 e3 08             	shl    $0x8,%ebx
  800a81:	89 d6                	mov    %edx,%esi
  800a83:	c1 e6 18             	shl    $0x18,%esi
  800a86:	89 d0                	mov    %edx,%eax
  800a88:	c1 e0 10             	shl    $0x10,%eax
  800a8b:	09 f0                	or     %esi,%eax
  800a8d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a8f:	89 d8                	mov    %ebx,%eax
  800a91:	09 d0                	or     %edx,%eax
  800a93:	c1 e9 02             	shr    $0x2,%ecx
  800a96:	fc                   	cld    
  800a97:	f3 ab                	rep stos %eax,%es:(%edi)
  800a99:	eb 06                	jmp    800aa1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9e:	fc                   	cld    
  800a9f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa1:	89 f8                	mov    %edi,%eax
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab6:	39 c6                	cmp    %eax,%esi
  800ab8:	73 35                	jae    800aef <memmove+0x47>
  800aba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800abd:	39 d0                	cmp    %edx,%eax
  800abf:	73 2e                	jae    800aef <memmove+0x47>
		s += n;
		d += n;
  800ac1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	89 d6                	mov    %edx,%esi
  800ac6:	09 fe                	or     %edi,%esi
  800ac8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ace:	75 13                	jne    800ae3 <memmove+0x3b>
  800ad0:	f6 c1 03             	test   $0x3,%cl
  800ad3:	75 0e                	jne    800ae3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ad5:	83 ef 04             	sub    $0x4,%edi
  800ad8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800adb:	c1 e9 02             	shr    $0x2,%ecx
  800ade:	fd                   	std    
  800adf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae1:	eb 09                	jmp    800aec <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae3:	83 ef 01             	sub    $0x1,%edi
  800ae6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ae9:	fd                   	std    
  800aea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aec:	fc                   	cld    
  800aed:	eb 1d                	jmp    800b0c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aef:	89 f2                	mov    %esi,%edx
  800af1:	09 c2                	or     %eax,%edx
  800af3:	f6 c2 03             	test   $0x3,%dl
  800af6:	75 0f                	jne    800b07 <memmove+0x5f>
  800af8:	f6 c1 03             	test   $0x3,%cl
  800afb:	75 0a                	jne    800b07 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800afd:	c1 e9 02             	shr    $0x2,%ecx
  800b00:	89 c7                	mov    %eax,%edi
  800b02:	fc                   	cld    
  800b03:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b05:	eb 05                	jmp    800b0c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b07:	89 c7                	mov    %eax,%edi
  800b09:	fc                   	cld    
  800b0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b13:	ff 75 10             	pushl  0x10(%ebp)
  800b16:	ff 75 0c             	pushl  0xc(%ebp)
  800b19:	ff 75 08             	pushl  0x8(%ebp)
  800b1c:	e8 87 ff ff ff       	call   800aa8 <memmove>
}
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2e:	89 c6                	mov    %eax,%esi
  800b30:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b33:	eb 1a                	jmp    800b4f <memcmp+0x2c>
		if (*s1 != *s2)
  800b35:	0f b6 08             	movzbl (%eax),%ecx
  800b38:	0f b6 1a             	movzbl (%edx),%ebx
  800b3b:	38 d9                	cmp    %bl,%cl
  800b3d:	74 0a                	je     800b49 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b3f:	0f b6 c1             	movzbl %cl,%eax
  800b42:	0f b6 db             	movzbl %bl,%ebx
  800b45:	29 d8                	sub    %ebx,%eax
  800b47:	eb 0f                	jmp    800b58 <memcmp+0x35>
		s1++, s2++;
  800b49:	83 c0 01             	add    $0x1,%eax
  800b4c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4f:	39 f0                	cmp    %esi,%eax
  800b51:	75 e2                	jne    800b35 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	53                   	push   %ebx
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b63:	89 c1                	mov    %eax,%ecx
  800b65:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b68:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b6c:	eb 0a                	jmp    800b78 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6e:	0f b6 10             	movzbl (%eax),%edx
  800b71:	39 da                	cmp    %ebx,%edx
  800b73:	74 07                	je     800b7c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b75:	83 c0 01             	add    $0x1,%eax
  800b78:	39 c8                	cmp    %ecx,%eax
  800b7a:	72 f2                	jb     800b6e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8b:	eb 03                	jmp    800b90 <strtol+0x11>
		s++;
  800b8d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b90:	0f b6 01             	movzbl (%ecx),%eax
  800b93:	3c 20                	cmp    $0x20,%al
  800b95:	74 f6                	je     800b8d <strtol+0xe>
  800b97:	3c 09                	cmp    $0x9,%al
  800b99:	74 f2                	je     800b8d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b9b:	3c 2b                	cmp    $0x2b,%al
  800b9d:	75 0a                	jne    800ba9 <strtol+0x2a>
		s++;
  800b9f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba7:	eb 11                	jmp    800bba <strtol+0x3b>
  800ba9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bae:	3c 2d                	cmp    $0x2d,%al
  800bb0:	75 08                	jne    800bba <strtol+0x3b>
		s++, neg = 1;
  800bb2:	83 c1 01             	add    $0x1,%ecx
  800bb5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bc0:	75 15                	jne    800bd7 <strtol+0x58>
  800bc2:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc5:	75 10                	jne    800bd7 <strtol+0x58>
  800bc7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bcb:	75 7c                	jne    800c49 <strtol+0xca>
		s += 2, base = 16;
  800bcd:	83 c1 02             	add    $0x2,%ecx
  800bd0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd5:	eb 16                	jmp    800bed <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bd7:	85 db                	test   %ebx,%ebx
  800bd9:	75 12                	jne    800bed <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bdb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be0:	80 39 30             	cmpb   $0x30,(%ecx)
  800be3:	75 08                	jne    800bed <strtol+0x6e>
		s++, base = 8;
  800be5:	83 c1 01             	add    $0x1,%ecx
  800be8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf5:	0f b6 11             	movzbl (%ecx),%edx
  800bf8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bfb:	89 f3                	mov    %esi,%ebx
  800bfd:	80 fb 09             	cmp    $0x9,%bl
  800c00:	77 08                	ja     800c0a <strtol+0x8b>
			dig = *s - '0';
  800c02:	0f be d2             	movsbl %dl,%edx
  800c05:	83 ea 30             	sub    $0x30,%edx
  800c08:	eb 22                	jmp    800c2c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c0a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c0d:	89 f3                	mov    %esi,%ebx
  800c0f:	80 fb 19             	cmp    $0x19,%bl
  800c12:	77 08                	ja     800c1c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c14:	0f be d2             	movsbl %dl,%edx
  800c17:	83 ea 57             	sub    $0x57,%edx
  800c1a:	eb 10                	jmp    800c2c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c1c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c1f:	89 f3                	mov    %esi,%ebx
  800c21:	80 fb 19             	cmp    $0x19,%bl
  800c24:	77 16                	ja     800c3c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c26:	0f be d2             	movsbl %dl,%edx
  800c29:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c2c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c2f:	7d 0b                	jge    800c3c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c31:	83 c1 01             	add    $0x1,%ecx
  800c34:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c38:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c3a:	eb b9                	jmp    800bf5 <strtol+0x76>

	if (endptr)
  800c3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c40:	74 0d                	je     800c4f <strtol+0xd0>
		*endptr = (char *) s;
  800c42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c45:	89 0e                	mov    %ecx,(%esi)
  800c47:	eb 06                	jmp    800c4f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c49:	85 db                	test   %ebx,%ebx
  800c4b:	74 98                	je     800be5 <strtol+0x66>
  800c4d:	eb 9e                	jmp    800bed <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c4f:	89 c2                	mov    %eax,%edx
  800c51:	f7 da                	neg    %edx
  800c53:	85 ff                	test   %edi,%edi
  800c55:	0f 45 c2             	cmovne %edx,%eax
}
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	89 c3                	mov    %eax,%ebx
  800c70:	89 c7                	mov    %eax,%edi
  800c72:	89 c6                	mov    %eax,%esi
  800c74:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c81:	ba 00 00 00 00       	mov    $0x0,%edx
  800c86:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8b:	89 d1                	mov    %edx,%ecx
  800c8d:	89 d3                	mov    %edx,%ebx
  800c8f:	89 d7                	mov    %edx,%edi
  800c91:	89 d6                	mov    %edx,%esi
  800c93:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca8:	b8 03 00 00 00       	mov    $0x3,%eax
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	89 cb                	mov    %ecx,%ebx
  800cb2:	89 cf                	mov    %ecx,%edi
  800cb4:	89 ce                	mov    %ecx,%esi
  800cb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 03                	push   $0x3
  800cc2:	68 ff 2b 80 00       	push   $0x802bff
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 1c 2c 80 00       	push   $0x802c1c
  800cce:	e8 c5 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ceb:	89 d1                	mov    %edx,%ecx
  800ced:	89 d3                	mov    %edx,%ebx
  800cef:	89 d7                	mov    %edx,%edi
  800cf1:	89 d6                	mov    %edx,%esi
  800cf3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_yield>:

void
sys_yield(void)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d00:	ba 00 00 00 00       	mov    $0x0,%edx
  800d05:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0a:	89 d1                	mov    %edx,%ecx
  800d0c:	89 d3                	mov    %edx,%ebx
  800d0e:	89 d7                	mov    %edx,%edi
  800d10:	89 d6                	mov    %edx,%esi
  800d12:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d22:	be 00 00 00 00       	mov    $0x0,%esi
  800d27:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d35:	89 f7                	mov    %esi,%edi
  800d37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 17                	jle    800d54 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	50                   	push   %eax
  800d41:	6a 04                	push   $0x4
  800d43:	68 ff 2b 80 00       	push   $0x802bff
  800d48:	6a 23                	push   $0x23
  800d4a:	68 1c 2c 80 00       	push   $0x802c1c
  800d4f:	e8 44 f5 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d65:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d76:	8b 75 18             	mov    0x18(%ebp),%esi
  800d79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	7e 17                	jle    800d96 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	50                   	push   %eax
  800d83:	6a 05                	push   $0x5
  800d85:	68 ff 2b 80 00       	push   $0x802bff
  800d8a:	6a 23                	push   $0x23
  800d8c:	68 1c 2c 80 00       	push   $0x802c1c
  800d91:	e8 02 f5 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dac:	b8 06 00 00 00       	mov    $0x6,%eax
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	89 df                	mov    %ebx,%edi
  800db9:	89 de                	mov    %ebx,%esi
  800dbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	7e 17                	jle    800dd8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	50                   	push   %eax
  800dc5:	6a 06                	push   $0x6
  800dc7:	68 ff 2b 80 00       	push   $0x802bff
  800dcc:	6a 23                	push   $0x23
  800dce:	68 1c 2c 80 00       	push   $0x802c1c
  800dd3:	e8 c0 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dee:	b8 08 00 00 00       	mov    $0x8,%eax
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 de                	mov    %ebx,%esi
  800dfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 17                	jle    800e1a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 08                	push   $0x8
  800e09:	68 ff 2b 80 00       	push   $0x802bff
  800e0e:	6a 23                	push   $0x23
  800e10:	68 1c 2c 80 00       	push   $0x802c1c
  800e15:	e8 7e f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e30:	b8 09 00 00 00       	mov    $0x9,%eax
  800e35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e38:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3b:	89 df                	mov    %ebx,%edi
  800e3d:	89 de                	mov    %ebx,%esi
  800e3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e41:	85 c0                	test   %eax,%eax
  800e43:	7e 17                	jle    800e5c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	83 ec 0c             	sub    $0xc,%esp
  800e48:	50                   	push   %eax
  800e49:	6a 09                	push   $0x9
  800e4b:	68 ff 2b 80 00       	push   $0x802bff
  800e50:	6a 23                	push   $0x23
  800e52:	68 1c 2c 80 00       	push   $0x802c1c
  800e57:	e8 3c f4 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	53                   	push   %ebx
  800e6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e72:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7d:	89 df                	mov    %ebx,%edi
  800e7f:	89 de                	mov    %ebx,%esi
  800e81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e83:	85 c0                	test   %eax,%eax
  800e85:	7e 17                	jle    800e9e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e87:	83 ec 0c             	sub    $0xc,%esp
  800e8a:	50                   	push   %eax
  800e8b:	6a 0a                	push   $0xa
  800e8d:	68 ff 2b 80 00       	push   $0x802bff
  800e92:	6a 23                	push   $0x23
  800e94:	68 1c 2c 80 00       	push   $0x802c1c
  800e99:	e8 fa f3 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	be 00 00 00 00       	mov    $0x0,%esi
  800eb1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800edc:	8b 55 08             	mov    0x8(%ebp),%edx
  800edf:	89 cb                	mov    %ecx,%ebx
  800ee1:	89 cf                	mov    %ecx,%edi
  800ee3:	89 ce                	mov    %ecx,%esi
  800ee5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	7e 17                	jle    800f02 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	50                   	push   %eax
  800eef:	6a 0d                	push   $0xd
  800ef1:	68 ff 2b 80 00       	push   $0x802bff
  800ef6:	6a 23                	push   $0x23
  800ef8:	68 1c 2c 80 00       	push   $0x802c1c
  800efd:	e8 96 f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	57                   	push   %edi
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f10:	ba 00 00 00 00       	mov    $0x0,%edx
  800f15:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f1a:	89 d1                	mov    %edx,%ecx
  800f1c:	89 d3                	mov    %edx,%ebx
  800f1e:	89 d7                	mov    %edx,%edi
  800f20:	89 d6                	mov    %edx,%esi
  800f22:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	53                   	push   %ebx
  800f2d:	83 ec 04             	sub    $0x4,%esp
  800f30:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f33:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800f35:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f38:	f6 c1 02             	test   $0x2,%cl
  800f3b:	74 2e                	je     800f6b <pgfault+0x42>
  800f3d:	89 c2                	mov    %eax,%edx
  800f3f:	c1 ea 16             	shr    $0x16,%edx
  800f42:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f49:	f6 c2 01             	test   $0x1,%dl
  800f4c:	74 1d                	je     800f6b <pgfault+0x42>
  800f4e:	89 c2                	mov    %eax,%edx
  800f50:	c1 ea 0c             	shr    $0xc,%edx
  800f53:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800f5a:	f6 c3 01             	test   $0x1,%bl
  800f5d:	74 0c                	je     800f6b <pgfault+0x42>
  800f5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f66:	f6 c6 08             	test   $0x8,%dh
  800f69:	75 12                	jne    800f7d <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800f6b:	51                   	push   %ecx
  800f6c:	68 2a 2c 80 00       	push   $0x802c2a
  800f71:	6a 1e                	push   $0x1e
  800f73:	68 43 2c 80 00       	push   $0x802c43
  800f78:	e8 1b f3 ff ff       	call   800298 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800f7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f82:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	6a 07                	push   $0x7
  800f89:	68 00 f0 7f 00       	push   $0x7ff000
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 84 fd ff ff       	call   800d19 <sys_page_alloc>
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	79 12                	jns    800fae <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800f9c:	50                   	push   %eax
  800f9d:	68 4e 2c 80 00       	push   $0x802c4e
  800fa2:	6a 29                	push   $0x29
  800fa4:	68 43 2c 80 00       	push   $0x802c43
  800fa9:	e8 ea f2 ff ff       	call   800298 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	68 00 10 00 00       	push   $0x1000
  800fb6:	53                   	push   %ebx
  800fb7:	68 00 f0 7f 00       	push   $0x7ff000
  800fbc:	e8 4f fb ff ff       	call   800b10 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800fc1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fc8:	53                   	push   %ebx
  800fc9:	6a 00                	push   $0x0
  800fcb:	68 00 f0 7f 00       	push   $0x7ff000
  800fd0:	6a 00                	push   $0x0
  800fd2:	e8 85 fd ff ff       	call   800d5c <sys_page_map>
  800fd7:	83 c4 20             	add    $0x20,%esp
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	79 12                	jns    800ff0 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800fde:	50                   	push   %eax
  800fdf:	68 69 2c 80 00       	push   $0x802c69
  800fe4:	6a 2e                	push   $0x2e
  800fe6:	68 43 2c 80 00       	push   $0x802c43
  800feb:	e8 a8 f2 ff ff       	call   800298 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800ff0:	83 ec 08             	sub    $0x8,%esp
  800ff3:	68 00 f0 7f 00       	push   $0x7ff000
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 9f fd ff ff       	call   800d9e <sys_page_unmap>
  800fff:	83 c4 10             	add    $0x10,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	79 12                	jns    801018 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  801006:	50                   	push   %eax
  801007:	68 82 2c 80 00       	push   $0x802c82
  80100c:	6a 31                	push   $0x31
  80100e:	68 43 2c 80 00       	push   $0x802c43
  801013:	e8 80 f2 ff ff       	call   800298 <_panic>

}
  801018:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101b:	c9                   	leave  
  80101c:	c3                   	ret    

0080101d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	57                   	push   %edi
  801021:	56                   	push   %esi
  801022:	53                   	push   %ebx
  801023:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  801026:	68 29 0f 80 00       	push   $0x800f29
  80102b:	e8 82 13 00 00       	call   8023b2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801030:	b8 07 00 00 00       	mov    $0x7,%eax
  801035:	cd 30                	int    $0x30
  801037:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80103a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	bb 00 00 00 00       	mov    $0x0,%ebx
  801045:	85 c0                	test   %eax,%eax
  801047:	75 21                	jne    80106a <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  801049:	e8 8d fc ff ff       	call   800cdb <sys_getenvid>
  80104e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80105b:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801060:	b8 00 00 00 00       	mov    $0x0,%eax
  801065:	e9 c9 01 00 00       	jmp    801233 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  80106a:	89 d8                	mov    %ebx,%eax
  80106c:	c1 e8 16             	shr    $0x16,%eax
  80106f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801076:	a8 01                	test   $0x1,%al
  801078:	0f 84 1b 01 00 00    	je     801199 <fork+0x17c>
  80107e:	89 de                	mov    %ebx,%esi
  801080:	c1 ee 0c             	shr    $0xc,%esi
  801083:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80108a:	a8 01                	test   $0x1,%al
  80108c:	0f 84 07 01 00 00    	je     801199 <fork+0x17c>
  801092:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801099:	a8 04                	test   $0x4,%al
  80109b:	0f 84 f8 00 00 00    	je     801199 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  8010a1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a8:	f6 c4 04             	test   $0x4,%ah
  8010ab:	74 3c                	je     8010e9 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  8010ad:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b4:	c1 e6 0c             	shl    $0xc,%esi
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	25 07 0e 00 00       	and    $0xe07,%eax
  8010bf:	50                   	push   %eax
  8010c0:	56                   	push   %esi
  8010c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c4:	56                   	push   %esi
  8010c5:	6a 00                	push   $0x0
  8010c7:	e8 90 fc ff ff       	call   800d5c <sys_page_map>
  8010cc:	83 c4 20             	add    $0x20,%esp
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	0f 89 c2 00 00 00    	jns    801199 <fork+0x17c>
			panic("duppage: %e", r);
  8010d7:	50                   	push   %eax
  8010d8:	68 9d 2c 80 00       	push   $0x802c9d
  8010dd:	6a 48                	push   $0x48
  8010df:	68 43 2c 80 00       	push   $0x802c43
  8010e4:	e8 af f1 ff ff       	call   800298 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  8010e9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010f0:	f6 c4 08             	test   $0x8,%ah
  8010f3:	75 0b                	jne    801100 <fork+0xe3>
  8010f5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010fc:	a8 02                	test   $0x2,%al
  8010fe:	74 6c                	je     80116c <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  801100:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801107:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  80110a:	83 f8 01             	cmp    $0x1,%eax
  80110d:	19 ff                	sbb    %edi,%edi
  80110f:	83 e7 fc             	and    $0xfffffffc,%edi
  801112:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  801118:	c1 e6 0c             	shl    $0xc,%esi
  80111b:	83 ec 0c             	sub    $0xc,%esp
  80111e:	57                   	push   %edi
  80111f:	56                   	push   %esi
  801120:	ff 75 e4             	pushl  -0x1c(%ebp)
  801123:	56                   	push   %esi
  801124:	6a 00                	push   $0x0
  801126:	e8 31 fc ff ff       	call   800d5c <sys_page_map>
  80112b:	83 c4 20             	add    $0x20,%esp
  80112e:	85 c0                	test   %eax,%eax
  801130:	79 12                	jns    801144 <fork+0x127>
			panic("duppage: %e", r);
  801132:	50                   	push   %eax
  801133:	68 9d 2c 80 00       	push   $0x802c9d
  801138:	6a 50                	push   $0x50
  80113a:	68 43 2c 80 00       	push   $0x802c43
  80113f:	e8 54 f1 ff ff       	call   800298 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	57                   	push   %edi
  801148:	56                   	push   %esi
  801149:	6a 00                	push   $0x0
  80114b:	56                   	push   %esi
  80114c:	6a 00                	push   $0x0
  80114e:	e8 09 fc ff ff       	call   800d5c <sys_page_map>
  801153:	83 c4 20             	add    $0x20,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	79 3f                	jns    801199 <fork+0x17c>
			panic("duppage: %e", r);
  80115a:	50                   	push   %eax
  80115b:	68 9d 2c 80 00       	push   $0x802c9d
  801160:	6a 53                	push   $0x53
  801162:	68 43 2c 80 00       	push   $0x802c43
  801167:	e8 2c f1 ff ff       	call   800298 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  80116c:	c1 e6 0c             	shl    $0xc,%esi
  80116f:	83 ec 0c             	sub    $0xc,%esp
  801172:	6a 05                	push   $0x5
  801174:	56                   	push   %esi
  801175:	ff 75 e4             	pushl  -0x1c(%ebp)
  801178:	56                   	push   %esi
  801179:	6a 00                	push   $0x0
  80117b:	e8 dc fb ff ff       	call   800d5c <sys_page_map>
  801180:	83 c4 20             	add    $0x20,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	79 12                	jns    801199 <fork+0x17c>
			panic("duppage: %e", r);
  801187:	50                   	push   %eax
  801188:	68 9d 2c 80 00       	push   $0x802c9d
  80118d:	6a 57                	push   $0x57
  80118f:	68 43 2c 80 00       	push   $0x802c43
  801194:	e8 ff f0 ff ff       	call   800298 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  801199:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80119f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011a5:	0f 85 bf fe ff ff    	jne    80106a <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  8011ab:	83 ec 04             	sub    $0x4,%esp
  8011ae:	6a 07                	push   $0x7
  8011b0:	68 00 f0 bf ee       	push   $0xeebff000
  8011b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b8:	e8 5c fb ff ff       	call   800d19 <sys_page_alloc>
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	74 17                	je     8011db <fork+0x1be>
		panic("sys_page_alloc Error");
  8011c4:	83 ec 04             	sub    $0x4,%esp
  8011c7:	68 a9 2c 80 00       	push   $0x802ca9
  8011cc:	68 83 00 00 00       	push   $0x83
  8011d1:	68 43 2c 80 00       	push   $0x802c43
  8011d6:	e8 bd f0 ff ff       	call   800298 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  8011db:	83 ec 08             	sub    $0x8,%esp
  8011de:	68 21 24 80 00       	push   $0x802421
  8011e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8011e6:	e8 79 fc ff ff       	call   800e64 <sys_env_set_pgfault_upcall>
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	79 15                	jns    801207 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  8011f2:	50                   	push   %eax
  8011f3:	68 be 2c 80 00       	push   $0x802cbe
  8011f8:	68 86 00 00 00       	push   $0x86
  8011fd:	68 43 2c 80 00       	push   $0x802c43
  801202:	e8 91 f0 ff ff       	call   800298 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	6a 02                	push   $0x2
  80120c:	ff 75 e0             	pushl  -0x20(%ebp)
  80120f:	e8 cc fb ff ff       	call   800de0 <sys_env_set_status>
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	79 15                	jns    801230 <fork+0x213>
		panic("fork set status: %e", r);
  80121b:	50                   	push   %eax
  80121c:	68 d6 2c 80 00       	push   $0x802cd6
  801221:	68 89 00 00 00       	push   $0x89
  801226:	68 43 2c 80 00       	push   $0x802c43
  80122b:	e8 68 f0 ff ff       	call   800298 <_panic>
	
	return envid;
  801230:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801233:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801236:	5b                   	pop    %ebx
  801237:	5e                   	pop    %esi
  801238:	5f                   	pop    %edi
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    

0080123b <sfork>:


// Challenge!
int
sfork(void)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801241:	68 ea 2c 80 00       	push   $0x802cea
  801246:	68 93 00 00 00       	push   $0x93
  80124b:	68 43 2c 80 00       	push   $0x802c43
  801250:	e8 43 f0 ff ff       	call   800298 <_panic>

00801255 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801258:	8b 45 08             	mov    0x8(%ebp),%eax
  80125b:	05 00 00 00 30       	add    $0x30000000,%eax
  801260:	c1 e8 0c             	shr    $0xc,%eax
}
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801268:	8b 45 08             	mov    0x8(%ebp),%eax
  80126b:	05 00 00 00 30       	add    $0x30000000,%eax
  801270:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801275:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801282:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801287:	89 c2                	mov    %eax,%edx
  801289:	c1 ea 16             	shr    $0x16,%edx
  80128c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801293:	f6 c2 01             	test   $0x1,%dl
  801296:	74 11                	je     8012a9 <fd_alloc+0x2d>
  801298:	89 c2                	mov    %eax,%edx
  80129a:	c1 ea 0c             	shr    $0xc,%edx
  80129d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a4:	f6 c2 01             	test   $0x1,%dl
  8012a7:	75 09                	jne    8012b2 <fd_alloc+0x36>
			*fd_store = fd;
  8012a9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b0:	eb 17                	jmp    8012c9 <fd_alloc+0x4d>
  8012b2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012bc:	75 c9                	jne    801287 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012be:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012c4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d1:	83 f8 1f             	cmp    $0x1f,%eax
  8012d4:	77 36                	ja     80130c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d6:	c1 e0 0c             	shl    $0xc,%eax
  8012d9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	c1 ea 16             	shr    $0x16,%edx
  8012e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ea:	f6 c2 01             	test   $0x1,%dl
  8012ed:	74 24                	je     801313 <fd_lookup+0x48>
  8012ef:	89 c2                	mov    %eax,%edx
  8012f1:	c1 ea 0c             	shr    $0xc,%edx
  8012f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fb:	f6 c2 01             	test   $0x1,%dl
  8012fe:	74 1a                	je     80131a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801300:	8b 55 0c             	mov    0xc(%ebp),%edx
  801303:	89 02                	mov    %eax,(%edx)
	return 0;
  801305:	b8 00 00 00 00       	mov    $0x0,%eax
  80130a:	eb 13                	jmp    80131f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801311:	eb 0c                	jmp    80131f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801313:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801318:	eb 05                	jmp    80131f <fd_lookup+0x54>
  80131a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80131f:	5d                   	pop    %ebp
  801320:	c3                   	ret    

00801321 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132a:	ba 80 2d 80 00       	mov    $0x802d80,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80132f:	eb 13                	jmp    801344 <dev_lookup+0x23>
  801331:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801334:	39 08                	cmp    %ecx,(%eax)
  801336:	75 0c                	jne    801344 <dev_lookup+0x23>
			*dev = devtab[i];
  801338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80133d:	b8 00 00 00 00       	mov    $0x0,%eax
  801342:	eb 2e                	jmp    801372 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801344:	8b 02                	mov    (%edx),%eax
  801346:	85 c0                	test   %eax,%eax
  801348:	75 e7                	jne    801331 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80134a:	a1 08 40 80 00       	mov    0x804008,%eax
  80134f:	8b 40 48             	mov    0x48(%eax),%eax
  801352:	83 ec 04             	sub    $0x4,%esp
  801355:	51                   	push   %ecx
  801356:	50                   	push   %eax
  801357:	68 00 2d 80 00       	push   $0x802d00
  80135c:	e8 10 f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  801361:	8b 45 0c             	mov    0xc(%ebp),%eax
  801364:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801372:	c9                   	leave  
  801373:	c3                   	ret    

00801374 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	56                   	push   %esi
  801378:	53                   	push   %ebx
  801379:	83 ec 10             	sub    $0x10,%esp
  80137c:	8b 75 08             	mov    0x8(%ebp),%esi
  80137f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801385:	50                   	push   %eax
  801386:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80138c:	c1 e8 0c             	shr    $0xc,%eax
  80138f:	50                   	push   %eax
  801390:	e8 36 ff ff ff       	call   8012cb <fd_lookup>
  801395:	83 c4 08             	add    $0x8,%esp
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 05                	js     8013a1 <fd_close+0x2d>
	    || fd != fd2)
  80139c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80139f:	74 0c                	je     8013ad <fd_close+0x39>
		return (must_exist ? r : 0);
  8013a1:	84 db                	test   %bl,%bl
  8013a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a8:	0f 44 c2             	cmove  %edx,%eax
  8013ab:	eb 41                	jmp    8013ee <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	ff 36                	pushl  (%esi)
  8013b6:	e8 66 ff ff ff       	call   801321 <dev_lookup>
  8013bb:	89 c3                	mov    %eax,%ebx
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 1a                	js     8013de <fd_close+0x6a>
		if (dev->dev_close)
  8013c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013ca:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	74 0b                	je     8013de <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013d3:	83 ec 0c             	sub    $0xc,%esp
  8013d6:	56                   	push   %esi
  8013d7:	ff d0                	call   *%eax
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	56                   	push   %esi
  8013e2:	6a 00                	push   $0x0
  8013e4:	e8 b5 f9 ff ff       	call   800d9e <sys_page_unmap>
	return r;
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	89 d8                	mov    %ebx,%eax
}
  8013ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5e                   	pop    %esi
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	ff 75 08             	pushl  0x8(%ebp)
  801402:	e8 c4 fe ff ff       	call   8012cb <fd_lookup>
  801407:	83 c4 08             	add    $0x8,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 10                	js     80141e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	6a 01                	push   $0x1
  801413:	ff 75 f4             	pushl  -0xc(%ebp)
  801416:	e8 59 ff ff ff       	call   801374 <fd_close>
  80141b:	83 c4 10             	add    $0x10,%esp
}
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <close_all>:

void
close_all(void)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	53                   	push   %ebx
  801424:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801427:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80142c:	83 ec 0c             	sub    $0xc,%esp
  80142f:	53                   	push   %ebx
  801430:	e8 c0 ff ff ff       	call   8013f5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801435:	83 c3 01             	add    $0x1,%ebx
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	83 fb 20             	cmp    $0x20,%ebx
  80143e:	75 ec                	jne    80142c <close_all+0xc>
		close(i);
}
  801440:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	57                   	push   %edi
  801449:	56                   	push   %esi
  80144a:	53                   	push   %ebx
  80144b:	83 ec 2c             	sub    $0x2c,%esp
  80144e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801451:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	ff 75 08             	pushl  0x8(%ebp)
  801458:	e8 6e fe ff ff       	call   8012cb <fd_lookup>
  80145d:	83 c4 08             	add    $0x8,%esp
  801460:	85 c0                	test   %eax,%eax
  801462:	0f 88 c1 00 00 00    	js     801529 <dup+0xe4>
		return r;
	close(newfdnum);
  801468:	83 ec 0c             	sub    $0xc,%esp
  80146b:	56                   	push   %esi
  80146c:	e8 84 ff ff ff       	call   8013f5 <close>

	newfd = INDEX2FD(newfdnum);
  801471:	89 f3                	mov    %esi,%ebx
  801473:	c1 e3 0c             	shl    $0xc,%ebx
  801476:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80147c:	83 c4 04             	add    $0x4,%esp
  80147f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801482:	e8 de fd ff ff       	call   801265 <fd2data>
  801487:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801489:	89 1c 24             	mov    %ebx,(%esp)
  80148c:	e8 d4 fd ff ff       	call   801265 <fd2data>
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801497:	89 f8                	mov    %edi,%eax
  801499:	c1 e8 16             	shr    $0x16,%eax
  80149c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a3:	a8 01                	test   $0x1,%al
  8014a5:	74 37                	je     8014de <dup+0x99>
  8014a7:	89 f8                	mov    %edi,%eax
  8014a9:	c1 e8 0c             	shr    $0xc,%eax
  8014ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014b3:	f6 c2 01             	test   $0x1,%dl
  8014b6:	74 26                	je     8014de <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bf:	83 ec 0c             	sub    $0xc,%esp
  8014c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c7:	50                   	push   %eax
  8014c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014cb:	6a 00                	push   $0x0
  8014cd:	57                   	push   %edi
  8014ce:	6a 00                	push   $0x0
  8014d0:	e8 87 f8 ff ff       	call   800d5c <sys_page_map>
  8014d5:	89 c7                	mov    %eax,%edi
  8014d7:	83 c4 20             	add    $0x20,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 2e                	js     80150c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014e1:	89 d0                	mov    %edx,%eax
  8014e3:	c1 e8 0c             	shr    $0xc,%eax
  8014e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ed:	83 ec 0c             	sub    $0xc,%esp
  8014f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f5:	50                   	push   %eax
  8014f6:	53                   	push   %ebx
  8014f7:	6a 00                	push   $0x0
  8014f9:	52                   	push   %edx
  8014fa:	6a 00                	push   $0x0
  8014fc:	e8 5b f8 ff ff       	call   800d5c <sys_page_map>
  801501:	89 c7                	mov    %eax,%edi
  801503:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801506:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801508:	85 ff                	test   %edi,%edi
  80150a:	79 1d                	jns    801529 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	53                   	push   %ebx
  801510:	6a 00                	push   $0x0
  801512:	e8 87 f8 ff ff       	call   800d9e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80151d:	6a 00                	push   $0x0
  80151f:	e8 7a f8 ff ff       	call   800d9e <sys_page_unmap>
	return r;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	89 f8                	mov    %edi,%eax
}
  801529:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152c:	5b                   	pop    %ebx
  80152d:	5e                   	pop    %esi
  80152e:	5f                   	pop    %edi
  80152f:	5d                   	pop    %ebp
  801530:	c3                   	ret    

00801531 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	83 ec 14             	sub    $0x14,%esp
  801538:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153e:	50                   	push   %eax
  80153f:	53                   	push   %ebx
  801540:	e8 86 fd ff ff       	call   8012cb <fd_lookup>
  801545:	83 c4 08             	add    $0x8,%esp
  801548:	89 c2                	mov    %eax,%edx
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 6d                	js     8015bb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801558:	ff 30                	pushl  (%eax)
  80155a:	e8 c2 fd ff ff       	call   801321 <dev_lookup>
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	78 4c                	js     8015b2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801566:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801569:	8b 42 08             	mov    0x8(%edx),%eax
  80156c:	83 e0 03             	and    $0x3,%eax
  80156f:	83 f8 01             	cmp    $0x1,%eax
  801572:	75 21                	jne    801595 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801574:	a1 08 40 80 00       	mov    0x804008,%eax
  801579:	8b 40 48             	mov    0x48(%eax),%eax
  80157c:	83 ec 04             	sub    $0x4,%esp
  80157f:	53                   	push   %ebx
  801580:	50                   	push   %eax
  801581:	68 44 2d 80 00       	push   $0x802d44
  801586:	e8 e6 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801593:	eb 26                	jmp    8015bb <read+0x8a>
	}
	if (!dev->dev_read)
  801595:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801598:	8b 40 08             	mov    0x8(%eax),%eax
  80159b:	85 c0                	test   %eax,%eax
  80159d:	74 17                	je     8015b6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80159f:	83 ec 04             	sub    $0x4,%esp
  8015a2:	ff 75 10             	pushl  0x10(%ebp)
  8015a5:	ff 75 0c             	pushl  0xc(%ebp)
  8015a8:	52                   	push   %edx
  8015a9:	ff d0                	call   *%eax
  8015ab:	89 c2                	mov    %eax,%edx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	eb 09                	jmp    8015bb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b2:	89 c2                	mov    %eax,%edx
  8015b4:	eb 05                	jmp    8015bb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015bb:	89 d0                	mov    %edx,%eax
  8015bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	57                   	push   %edi
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 0c             	sub    $0xc,%esp
  8015cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d6:	eb 21                	jmp    8015f9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d8:	83 ec 04             	sub    $0x4,%esp
  8015db:	89 f0                	mov    %esi,%eax
  8015dd:	29 d8                	sub    %ebx,%eax
  8015df:	50                   	push   %eax
  8015e0:	89 d8                	mov    %ebx,%eax
  8015e2:	03 45 0c             	add    0xc(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	57                   	push   %edi
  8015e7:	e8 45 ff ff ff       	call   801531 <read>
		if (m < 0)
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 10                	js     801603 <readn+0x41>
			return m;
		if (m == 0)
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	74 0a                	je     801601 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f7:	01 c3                	add    %eax,%ebx
  8015f9:	39 f3                	cmp    %esi,%ebx
  8015fb:	72 db                	jb     8015d8 <readn+0x16>
  8015fd:	89 d8                	mov    %ebx,%eax
  8015ff:	eb 02                	jmp    801603 <readn+0x41>
  801601:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5f                   	pop    %edi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	53                   	push   %ebx
  80160f:	83 ec 14             	sub    $0x14,%esp
  801612:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801615:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	53                   	push   %ebx
  80161a:	e8 ac fc ff ff       	call   8012cb <fd_lookup>
  80161f:	83 c4 08             	add    $0x8,%esp
  801622:	89 c2                	mov    %eax,%edx
  801624:	85 c0                	test   %eax,%eax
  801626:	78 68                	js     801690 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801632:	ff 30                	pushl  (%eax)
  801634:	e8 e8 fc ff ff       	call   801321 <dev_lookup>
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 47                	js     801687 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801640:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801643:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801647:	75 21                	jne    80166a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801649:	a1 08 40 80 00       	mov    0x804008,%eax
  80164e:	8b 40 48             	mov    0x48(%eax),%eax
  801651:	83 ec 04             	sub    $0x4,%esp
  801654:	53                   	push   %ebx
  801655:	50                   	push   %eax
  801656:	68 60 2d 80 00       	push   $0x802d60
  80165b:	e8 11 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801668:	eb 26                	jmp    801690 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80166a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166d:	8b 52 0c             	mov    0xc(%edx),%edx
  801670:	85 d2                	test   %edx,%edx
  801672:	74 17                	je     80168b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801674:	83 ec 04             	sub    $0x4,%esp
  801677:	ff 75 10             	pushl  0x10(%ebp)
  80167a:	ff 75 0c             	pushl  0xc(%ebp)
  80167d:	50                   	push   %eax
  80167e:	ff d2                	call   *%edx
  801680:	89 c2                	mov    %eax,%edx
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	eb 09                	jmp    801690 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801687:	89 c2                	mov    %eax,%edx
  801689:	eb 05                	jmp    801690 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80168b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801690:	89 d0                	mov    %edx,%eax
  801692:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <seek>:

int
seek(int fdnum, off_t offset)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016a0:	50                   	push   %eax
  8016a1:	ff 75 08             	pushl  0x8(%ebp)
  8016a4:	e8 22 fc ff ff       	call   8012cb <fd_lookup>
  8016a9:	83 c4 08             	add    $0x8,%esp
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 0e                	js     8016be <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 14             	sub    $0x14,%esp
  8016c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cd:	50                   	push   %eax
  8016ce:	53                   	push   %ebx
  8016cf:	e8 f7 fb ff ff       	call   8012cb <fd_lookup>
  8016d4:	83 c4 08             	add    $0x8,%esp
  8016d7:	89 c2                	mov    %eax,%edx
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 65                	js     801742 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dd:	83 ec 08             	sub    $0x8,%esp
  8016e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e3:	50                   	push   %eax
  8016e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e7:	ff 30                	pushl  (%eax)
  8016e9:	e8 33 fc ff ff       	call   801321 <dev_lookup>
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 44                	js     801739 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016fc:	75 21                	jne    80171f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016fe:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801703:	8b 40 48             	mov    0x48(%eax),%eax
  801706:	83 ec 04             	sub    $0x4,%esp
  801709:	53                   	push   %ebx
  80170a:	50                   	push   %eax
  80170b:	68 20 2d 80 00       	push   $0x802d20
  801710:	e8 5c ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80171d:	eb 23                	jmp    801742 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80171f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801722:	8b 52 18             	mov    0x18(%edx),%edx
  801725:	85 d2                	test   %edx,%edx
  801727:	74 14                	je     80173d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	ff 75 0c             	pushl  0xc(%ebp)
  80172f:	50                   	push   %eax
  801730:	ff d2                	call   *%edx
  801732:	89 c2                	mov    %eax,%edx
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	eb 09                	jmp    801742 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801739:	89 c2                	mov    %eax,%edx
  80173b:	eb 05                	jmp    801742 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80173d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801742:	89 d0                	mov    %edx,%eax
  801744:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801747:	c9                   	leave  
  801748:	c3                   	ret    

00801749 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	53                   	push   %ebx
  80174d:	83 ec 14             	sub    $0x14,%esp
  801750:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801753:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	ff 75 08             	pushl  0x8(%ebp)
  80175a:	e8 6c fb ff ff       	call   8012cb <fd_lookup>
  80175f:	83 c4 08             	add    $0x8,%esp
  801762:	89 c2                	mov    %eax,%edx
  801764:	85 c0                	test   %eax,%eax
  801766:	78 58                	js     8017c0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801768:	83 ec 08             	sub    $0x8,%esp
  80176b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176e:	50                   	push   %eax
  80176f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801772:	ff 30                	pushl  (%eax)
  801774:	e8 a8 fb ff ff       	call   801321 <dev_lookup>
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 37                	js     8017b7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801780:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801783:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801787:	74 32                	je     8017bb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801789:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80178c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801793:	00 00 00 
	stat->st_isdir = 0;
  801796:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80179d:	00 00 00 
	stat->st_dev = dev;
  8017a0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	53                   	push   %ebx
  8017aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ad:	ff 50 14             	call   *0x14(%eax)
  8017b0:	89 c2                	mov    %eax,%edx
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	eb 09                	jmp    8017c0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b7:	89 c2                	mov    %eax,%edx
  8017b9:	eb 05                	jmp    8017c0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017c0:	89 d0                	mov    %edx,%eax
  8017c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	56                   	push   %esi
  8017cb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	6a 00                	push   $0x0
  8017d1:	ff 75 08             	pushl  0x8(%ebp)
  8017d4:	e8 ef 01 00 00       	call   8019c8 <open>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 1b                	js     8017fd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	ff 75 0c             	pushl  0xc(%ebp)
  8017e8:	50                   	push   %eax
  8017e9:	e8 5b ff ff ff       	call   801749 <fstat>
  8017ee:	89 c6                	mov    %eax,%esi
	close(fd);
  8017f0:	89 1c 24             	mov    %ebx,(%esp)
  8017f3:	e8 fd fb ff ff       	call   8013f5 <close>
	return r;
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	89 f0                	mov    %esi,%eax
}
  8017fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	89 c6                	mov    %eax,%esi
  80180b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80180d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801814:	75 12                	jne    801828 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801816:	83 ec 0c             	sub    $0xc,%esp
  801819:	6a 01                	push   $0x1
  80181b:	e8 ed 0c 00 00       	call   80250d <ipc_find_env>
  801820:	a3 00 40 80 00       	mov    %eax,0x804000
  801825:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801828:	6a 07                	push   $0x7
  80182a:	68 00 50 80 00       	push   $0x805000
  80182f:	56                   	push   %esi
  801830:	ff 35 00 40 80 00    	pushl  0x804000
  801836:	e8 83 0c 00 00       	call   8024be <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80183b:	83 c4 0c             	add    $0xc,%esp
  80183e:	6a 00                	push   $0x0
  801840:	53                   	push   %ebx
  801841:	6a 00                	push   $0x0
  801843:	e8 00 0c 00 00       	call   802448 <ipc_recv>
}
  801848:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5e                   	pop    %esi
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801855:	8b 45 08             	mov    0x8(%ebp),%eax
  801858:	8b 40 0c             	mov    0xc(%eax),%eax
  80185b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801860:	8b 45 0c             	mov    0xc(%ebp),%eax
  801863:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801868:	ba 00 00 00 00       	mov    $0x0,%edx
  80186d:	b8 02 00 00 00       	mov    $0x2,%eax
  801872:	e8 8d ff ff ff       	call   801804 <fsipc>
}
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80187f:	8b 45 08             	mov    0x8(%ebp),%eax
  801882:	8b 40 0c             	mov    0xc(%eax),%eax
  801885:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80188a:	ba 00 00 00 00       	mov    $0x0,%edx
  80188f:	b8 06 00 00 00       	mov    $0x6,%eax
  801894:	e8 6b ff ff ff       	call   801804 <fsipc>
}
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	53                   	push   %ebx
  80189f:	83 ec 04             	sub    $0x4,%esp
  8018a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ab:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ba:	e8 45 ff ff ff       	call   801804 <fsipc>
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	78 2c                	js     8018ef <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c3:	83 ec 08             	sub    $0x8,%esp
  8018c6:	68 00 50 80 00       	push   $0x805000
  8018cb:	53                   	push   %ebx
  8018cc:	e8 45 f0 ff ff       	call   800916 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018d1:	a1 80 50 80 00       	mov    0x805080,%eax
  8018d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018dc:	a1 84 50 80 00       	mov    0x805084,%eax
  8018e1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801901:	8b 52 0c             	mov    0xc(%edx),%edx
  801904:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80190a:	a3 04 50 80 00       	mov    %eax,0x805004
  80190f:	3d 08 50 80 00       	cmp    $0x805008,%eax
  801914:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801919:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  80191c:	53                   	push   %ebx
  80191d:	ff 75 0c             	pushl  0xc(%ebp)
  801920:	68 08 50 80 00       	push   $0x805008
  801925:	e8 7e f1 ff ff       	call   800aa8 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80192a:	ba 00 00 00 00       	mov    $0x0,%edx
  80192f:	b8 04 00 00 00       	mov    $0x4,%eax
  801934:	e8 cb fe ff ff       	call   801804 <fsipc>
  801939:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  80193c:	85 c0                	test   %eax,%eax
  80193e:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801941:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	56                   	push   %esi
  80194a:	53                   	push   %ebx
  80194b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	8b 40 0c             	mov    0xc(%eax),%eax
  801954:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801959:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80195f:	ba 00 00 00 00       	mov    $0x0,%edx
  801964:	b8 03 00 00 00       	mov    $0x3,%eax
  801969:	e8 96 fe ff ff       	call   801804 <fsipc>
  80196e:	89 c3                	mov    %eax,%ebx
  801970:	85 c0                	test   %eax,%eax
  801972:	78 4b                	js     8019bf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801974:	39 c6                	cmp    %eax,%esi
  801976:	73 16                	jae    80198e <devfile_read+0x48>
  801978:	68 94 2d 80 00       	push   $0x802d94
  80197d:	68 9b 2d 80 00       	push   $0x802d9b
  801982:	6a 7c                	push   $0x7c
  801984:	68 b0 2d 80 00       	push   $0x802db0
  801989:	e8 0a e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  80198e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801993:	7e 16                	jle    8019ab <devfile_read+0x65>
  801995:	68 bb 2d 80 00       	push   $0x802dbb
  80199a:	68 9b 2d 80 00       	push   $0x802d9b
  80199f:	6a 7d                	push   $0x7d
  8019a1:	68 b0 2d 80 00       	push   $0x802db0
  8019a6:	e8 ed e8 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019ab:	83 ec 04             	sub    $0x4,%esp
  8019ae:	50                   	push   %eax
  8019af:	68 00 50 80 00       	push   $0x805000
  8019b4:	ff 75 0c             	pushl  0xc(%ebp)
  8019b7:	e8 ec f0 ff ff       	call   800aa8 <memmove>
	return r;
  8019bc:	83 c4 10             	add    $0x10,%esp
}
  8019bf:	89 d8                	mov    %ebx,%eax
  8019c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    

008019c8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	53                   	push   %ebx
  8019cc:	83 ec 20             	sub    $0x20,%esp
  8019cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019d2:	53                   	push   %ebx
  8019d3:	e8 05 ef ff ff       	call   8008dd <strlen>
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019e0:	7f 67                	jg     801a49 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e8:	50                   	push   %eax
  8019e9:	e8 8e f8 ff ff       	call   80127c <fd_alloc>
  8019ee:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 57                	js     801a4e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019f7:	83 ec 08             	sub    $0x8,%esp
  8019fa:	53                   	push   %ebx
  8019fb:	68 00 50 80 00       	push   $0x805000
  801a00:	e8 11 ef ff ff       	call   800916 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a08:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a10:	b8 01 00 00 00       	mov    $0x1,%eax
  801a15:	e8 ea fd ff ff       	call   801804 <fsipc>
  801a1a:	89 c3                	mov    %eax,%ebx
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	79 14                	jns    801a37 <open+0x6f>
		fd_close(fd, 0);
  801a23:	83 ec 08             	sub    $0x8,%esp
  801a26:	6a 00                	push   $0x0
  801a28:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2b:	e8 44 f9 ff ff       	call   801374 <fd_close>
		return r;
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	89 da                	mov    %ebx,%edx
  801a35:	eb 17                	jmp    801a4e <open+0x86>
	}

	return fd2num(fd);
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3d:	e8 13 f8 ff ff       	call   801255 <fd2num>
  801a42:	89 c2                	mov    %eax,%edx
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	eb 05                	jmp    801a4e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a49:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a4e:	89 d0                	mov    %edx,%eax
  801a50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a60:	b8 08 00 00 00       	mov    $0x8,%eax
  801a65:	e8 9a fd ff ff       	call   801804 <fsipc>
}
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a74:	83 ec 0c             	sub    $0xc,%esp
  801a77:	ff 75 08             	pushl  0x8(%ebp)
  801a7a:	e8 e6 f7 ff ff       	call   801265 <fd2data>
  801a7f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a81:	83 c4 08             	add    $0x8,%esp
  801a84:	68 c7 2d 80 00       	push   $0x802dc7
  801a89:	53                   	push   %ebx
  801a8a:	e8 87 ee ff ff       	call   800916 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a8f:	8b 46 04             	mov    0x4(%esi),%eax
  801a92:	2b 06                	sub    (%esi),%eax
  801a94:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a9a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aa1:	00 00 00 
	stat->st_dev = &devpipe;
  801aa4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801aab:	30 80 00 
	return 0;
}
  801aae:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab6:	5b                   	pop    %ebx
  801ab7:	5e                   	pop    %esi
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    

00801aba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	53                   	push   %ebx
  801abe:	83 ec 0c             	sub    $0xc,%esp
  801ac1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ac4:	53                   	push   %ebx
  801ac5:	6a 00                	push   $0x0
  801ac7:	e8 d2 f2 ff ff       	call   800d9e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801acc:	89 1c 24             	mov    %ebx,(%esp)
  801acf:	e8 91 f7 ff ff       	call   801265 <fd2data>
  801ad4:	83 c4 08             	add    $0x8,%esp
  801ad7:	50                   	push   %eax
  801ad8:	6a 00                	push   $0x0
  801ada:	e8 bf f2 ff ff       	call   800d9e <sys_page_unmap>
}
  801adf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    

00801ae4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	57                   	push   %edi
  801ae8:	56                   	push   %esi
  801ae9:	53                   	push   %ebx
  801aea:	83 ec 1c             	sub    $0x1c,%esp
  801aed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801af0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801af2:	a1 08 40 80 00       	mov    0x804008,%eax
  801af7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	ff 75 e0             	pushl  -0x20(%ebp)
  801b00:	e8 41 0a 00 00       	call   802546 <pageref>
  801b05:	89 c3                	mov    %eax,%ebx
  801b07:	89 3c 24             	mov    %edi,(%esp)
  801b0a:	e8 37 0a 00 00       	call   802546 <pageref>
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	39 c3                	cmp    %eax,%ebx
  801b14:	0f 94 c1             	sete   %cl
  801b17:	0f b6 c9             	movzbl %cl,%ecx
  801b1a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b1d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b23:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b26:	39 ce                	cmp    %ecx,%esi
  801b28:	74 1b                	je     801b45 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b2a:	39 c3                	cmp    %eax,%ebx
  801b2c:	75 c4                	jne    801af2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b2e:	8b 42 58             	mov    0x58(%edx),%eax
  801b31:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b34:	50                   	push   %eax
  801b35:	56                   	push   %esi
  801b36:	68 ce 2d 80 00       	push   $0x802dce
  801b3b:	e8 31 e8 ff ff       	call   800371 <cprintf>
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	eb ad                	jmp    801af2 <_pipeisclosed+0xe>
	}
}
  801b45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4b:	5b                   	pop    %ebx
  801b4c:	5e                   	pop    %esi
  801b4d:	5f                   	pop    %edi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	57                   	push   %edi
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	83 ec 28             	sub    $0x28,%esp
  801b59:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b5c:	56                   	push   %esi
  801b5d:	e8 03 f7 ff ff       	call   801265 <fd2data>
  801b62:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	bf 00 00 00 00       	mov    $0x0,%edi
  801b6c:	eb 4b                	jmp    801bb9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b6e:	89 da                	mov    %ebx,%edx
  801b70:	89 f0                	mov    %esi,%eax
  801b72:	e8 6d ff ff ff       	call   801ae4 <_pipeisclosed>
  801b77:	85 c0                	test   %eax,%eax
  801b79:	75 48                	jne    801bc3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b7b:	e8 7a f1 ff ff       	call   800cfa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b80:	8b 43 04             	mov    0x4(%ebx),%eax
  801b83:	8b 0b                	mov    (%ebx),%ecx
  801b85:	8d 51 20             	lea    0x20(%ecx),%edx
  801b88:	39 d0                	cmp    %edx,%eax
  801b8a:	73 e2                	jae    801b6e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b93:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b96:	89 c2                	mov    %eax,%edx
  801b98:	c1 fa 1f             	sar    $0x1f,%edx
  801b9b:	89 d1                	mov    %edx,%ecx
  801b9d:	c1 e9 1b             	shr    $0x1b,%ecx
  801ba0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ba3:	83 e2 1f             	and    $0x1f,%edx
  801ba6:	29 ca                	sub    %ecx,%edx
  801ba8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bb0:	83 c0 01             	add    $0x1,%eax
  801bb3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb6:	83 c7 01             	add    $0x1,%edi
  801bb9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bbc:	75 c2                	jne    801b80 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bbe:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc1:	eb 05                	jmp    801bc8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5e                   	pop    %esi
  801bcd:	5f                   	pop    %edi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	57                   	push   %edi
  801bd4:	56                   	push   %esi
  801bd5:	53                   	push   %ebx
  801bd6:	83 ec 18             	sub    $0x18,%esp
  801bd9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bdc:	57                   	push   %edi
  801bdd:	e8 83 f6 ff ff       	call   801265 <fd2data>
  801be2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bec:	eb 3d                	jmp    801c2b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bee:	85 db                	test   %ebx,%ebx
  801bf0:	74 04                	je     801bf6 <devpipe_read+0x26>
				return i;
  801bf2:	89 d8                	mov    %ebx,%eax
  801bf4:	eb 44                	jmp    801c3a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bf6:	89 f2                	mov    %esi,%edx
  801bf8:	89 f8                	mov    %edi,%eax
  801bfa:	e8 e5 fe ff ff       	call   801ae4 <_pipeisclosed>
  801bff:	85 c0                	test   %eax,%eax
  801c01:	75 32                	jne    801c35 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c03:	e8 f2 f0 ff ff       	call   800cfa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c08:	8b 06                	mov    (%esi),%eax
  801c0a:	3b 46 04             	cmp    0x4(%esi),%eax
  801c0d:	74 df                	je     801bee <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c0f:	99                   	cltd   
  801c10:	c1 ea 1b             	shr    $0x1b,%edx
  801c13:	01 d0                	add    %edx,%eax
  801c15:	83 e0 1f             	and    $0x1f,%eax
  801c18:	29 d0                	sub    %edx,%eax
  801c1a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c22:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c25:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c28:	83 c3 01             	add    $0x1,%ebx
  801c2b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c2e:	75 d8                	jne    801c08 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c30:	8b 45 10             	mov    0x10(%ebp),%eax
  801c33:	eb 05                	jmp    801c3a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c35:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5f                   	pop    %edi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	56                   	push   %esi
  801c46:	53                   	push   %ebx
  801c47:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4d:	50                   	push   %eax
  801c4e:	e8 29 f6 ff ff       	call   80127c <fd_alloc>
  801c53:	83 c4 10             	add    $0x10,%esp
  801c56:	89 c2                	mov    %eax,%edx
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	0f 88 2c 01 00 00    	js     801d8c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c60:	83 ec 04             	sub    $0x4,%esp
  801c63:	68 07 04 00 00       	push   $0x407
  801c68:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6b:	6a 00                	push   $0x0
  801c6d:	e8 a7 f0 ff ff       	call   800d19 <sys_page_alloc>
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	89 c2                	mov    %eax,%edx
  801c77:	85 c0                	test   %eax,%eax
  801c79:	0f 88 0d 01 00 00    	js     801d8c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c7f:	83 ec 0c             	sub    $0xc,%esp
  801c82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c85:	50                   	push   %eax
  801c86:	e8 f1 f5 ff ff       	call   80127c <fd_alloc>
  801c8b:	89 c3                	mov    %eax,%ebx
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	0f 88 e2 00 00 00    	js     801d7a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	68 07 04 00 00       	push   $0x407
  801ca0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 6f f0 ff ff       	call   800d19 <sys_page_alloc>
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	83 c4 10             	add    $0x10,%esp
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	0f 88 c3 00 00 00    	js     801d7a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cb7:	83 ec 0c             	sub    $0xc,%esp
  801cba:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbd:	e8 a3 f5 ff ff       	call   801265 <fd2data>
  801cc2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc4:	83 c4 0c             	add    $0xc,%esp
  801cc7:	68 07 04 00 00       	push   $0x407
  801ccc:	50                   	push   %eax
  801ccd:	6a 00                	push   $0x0
  801ccf:	e8 45 f0 ff ff       	call   800d19 <sys_page_alloc>
  801cd4:	89 c3                	mov    %eax,%ebx
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	0f 88 89 00 00 00    	js     801d6a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce1:	83 ec 0c             	sub    $0xc,%esp
  801ce4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce7:	e8 79 f5 ff ff       	call   801265 <fd2data>
  801cec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf3:	50                   	push   %eax
  801cf4:	6a 00                	push   $0x0
  801cf6:	56                   	push   %esi
  801cf7:	6a 00                	push   $0x0
  801cf9:	e8 5e f0 ff ff       	call   800d5c <sys_page_map>
  801cfe:	89 c3                	mov    %eax,%ebx
  801d00:	83 c4 20             	add    $0x20,%esp
  801d03:	85 c0                	test   %eax,%eax
  801d05:	78 55                	js     801d5c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d10:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d15:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d1c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d25:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d31:	83 ec 0c             	sub    $0xc,%esp
  801d34:	ff 75 f4             	pushl  -0xc(%ebp)
  801d37:	e8 19 f5 ff ff       	call   801255 <fd2num>
  801d3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d41:	83 c4 04             	add    $0x4,%esp
  801d44:	ff 75 f0             	pushl  -0x10(%ebp)
  801d47:	e8 09 f5 ff ff       	call   801255 <fd2num>
  801d4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5a:	eb 30                	jmp    801d8c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d5c:	83 ec 08             	sub    $0x8,%esp
  801d5f:	56                   	push   %esi
  801d60:	6a 00                	push   $0x0
  801d62:	e8 37 f0 ff ff       	call   800d9e <sys_page_unmap>
  801d67:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d6a:	83 ec 08             	sub    $0x8,%esp
  801d6d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d70:	6a 00                	push   $0x0
  801d72:	e8 27 f0 ff ff       	call   800d9e <sys_page_unmap>
  801d77:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d7a:	83 ec 08             	sub    $0x8,%esp
  801d7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d80:	6a 00                	push   $0x0
  801d82:	e8 17 f0 ff ff       	call   800d9e <sys_page_unmap>
  801d87:	83 c4 10             	add    $0x10,%esp
  801d8a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d8c:	89 d0                	mov    %edx,%eax
  801d8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d91:	5b                   	pop    %ebx
  801d92:	5e                   	pop    %esi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9e:	50                   	push   %eax
  801d9f:	ff 75 08             	pushl  0x8(%ebp)
  801da2:	e8 24 f5 ff ff       	call   8012cb <fd_lookup>
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	85 c0                	test   %eax,%eax
  801dac:	78 18                	js     801dc6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dae:	83 ec 0c             	sub    $0xc,%esp
  801db1:	ff 75 f4             	pushl  -0xc(%ebp)
  801db4:	e8 ac f4 ff ff       	call   801265 <fd2data>
	return _pipeisclosed(fd, p);
  801db9:	89 c2                	mov    %eax,%edx
  801dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbe:	e8 21 fd ff ff       	call   801ae4 <_pipeisclosed>
  801dc3:	83 c4 10             	add    $0x10,%esp
}
  801dc6:	c9                   	leave  
  801dc7:	c3                   	ret    

00801dc8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801dce:	68 e1 2d 80 00       	push   $0x802de1
  801dd3:	ff 75 0c             	pushl  0xc(%ebp)
  801dd6:	e8 3b eb ff ff       	call   800916 <strcpy>
	return 0;
}
  801ddb:	b8 00 00 00 00       	mov    $0x0,%eax
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	53                   	push   %ebx
  801de6:	83 ec 10             	sub    $0x10,%esp
  801de9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801dec:	53                   	push   %ebx
  801ded:	e8 54 07 00 00       	call   802546 <pageref>
  801df2:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801df5:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801dfa:	83 f8 01             	cmp    $0x1,%eax
  801dfd:	75 10                	jne    801e0f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801dff:	83 ec 0c             	sub    $0xc,%esp
  801e02:	ff 73 0c             	pushl  0xc(%ebx)
  801e05:	e8 c0 02 00 00       	call   8020ca <nsipc_close>
  801e0a:	89 c2                	mov    %eax,%edx
  801e0c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801e0f:	89 d0                	mov    %edx,%eax
  801e11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e1c:	6a 00                	push   $0x0
  801e1e:	ff 75 10             	pushl  0x10(%ebp)
  801e21:	ff 75 0c             	pushl  0xc(%ebp)
  801e24:	8b 45 08             	mov    0x8(%ebp),%eax
  801e27:	ff 70 0c             	pushl  0xc(%eax)
  801e2a:	e8 78 03 00 00       	call   8021a7 <nsipc_send>
}
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e37:	6a 00                	push   $0x0
  801e39:	ff 75 10             	pushl  0x10(%ebp)
  801e3c:	ff 75 0c             	pushl  0xc(%ebp)
  801e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e42:	ff 70 0c             	pushl  0xc(%eax)
  801e45:	e8 f1 02 00 00       	call   80213b <nsipc_recv>
}
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e52:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e55:	52                   	push   %edx
  801e56:	50                   	push   %eax
  801e57:	e8 6f f4 ff ff       	call   8012cb <fd_lookup>
  801e5c:	83 c4 10             	add    $0x10,%esp
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	78 17                	js     801e7a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e66:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801e6c:	39 08                	cmp    %ecx,(%eax)
  801e6e:	75 05                	jne    801e75 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e70:	8b 40 0c             	mov    0xc(%eax),%eax
  801e73:	eb 05                	jmp    801e7a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e75:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	56                   	push   %esi
  801e80:	53                   	push   %ebx
  801e81:	83 ec 1c             	sub    $0x1c,%esp
  801e84:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e89:	50                   	push   %eax
  801e8a:	e8 ed f3 ff ff       	call   80127c <fd_alloc>
  801e8f:	89 c3                	mov    %eax,%ebx
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	85 c0                	test   %eax,%eax
  801e96:	78 1b                	js     801eb3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e98:	83 ec 04             	sub    $0x4,%esp
  801e9b:	68 07 04 00 00       	push   $0x407
  801ea0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea3:	6a 00                	push   $0x0
  801ea5:	e8 6f ee ff ff       	call   800d19 <sys_page_alloc>
  801eaa:	89 c3                	mov    %eax,%ebx
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	79 10                	jns    801ec3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801eb3:	83 ec 0c             	sub    $0xc,%esp
  801eb6:	56                   	push   %esi
  801eb7:	e8 0e 02 00 00       	call   8020ca <nsipc_close>
		return r;
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	89 d8                	mov    %ebx,%eax
  801ec1:	eb 24                	jmp    801ee7 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ec3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ed8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801edb:	83 ec 0c             	sub    $0xc,%esp
  801ede:	50                   	push   %eax
  801edf:	e8 71 f3 ff ff       	call   801255 <fd2num>
  801ee4:	83 c4 10             	add    $0x10,%esp
}
  801ee7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eea:	5b                   	pop    %ebx
  801eeb:	5e                   	pop    %esi
  801eec:	5d                   	pop    %ebp
  801eed:	c3                   	ret    

00801eee <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef7:	e8 50 ff ff ff       	call   801e4c <fd2sockid>
		return r;
  801efc:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801efe:	85 c0                	test   %eax,%eax
  801f00:	78 1f                	js     801f21 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f02:	83 ec 04             	sub    $0x4,%esp
  801f05:	ff 75 10             	pushl  0x10(%ebp)
  801f08:	ff 75 0c             	pushl  0xc(%ebp)
  801f0b:	50                   	push   %eax
  801f0c:	e8 12 01 00 00       	call   802023 <nsipc_accept>
  801f11:	83 c4 10             	add    $0x10,%esp
		return r;
  801f14:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f16:	85 c0                	test   %eax,%eax
  801f18:	78 07                	js     801f21 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801f1a:	e8 5d ff ff ff       	call   801e7c <alloc_sockfd>
  801f1f:	89 c1                	mov    %eax,%ecx
}
  801f21:	89 c8                	mov    %ecx,%eax
  801f23:	c9                   	leave  
  801f24:	c3                   	ret    

00801f25 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2e:	e8 19 ff ff ff       	call   801e4c <fd2sockid>
  801f33:	85 c0                	test   %eax,%eax
  801f35:	78 12                	js     801f49 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801f37:	83 ec 04             	sub    $0x4,%esp
  801f3a:	ff 75 10             	pushl  0x10(%ebp)
  801f3d:	ff 75 0c             	pushl  0xc(%ebp)
  801f40:	50                   	push   %eax
  801f41:	e8 2d 01 00 00       	call   802073 <nsipc_bind>
  801f46:	83 c4 10             	add    $0x10,%esp
}
  801f49:	c9                   	leave  
  801f4a:	c3                   	ret    

00801f4b <shutdown>:

int
shutdown(int s, int how)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f51:	8b 45 08             	mov    0x8(%ebp),%eax
  801f54:	e8 f3 fe ff ff       	call   801e4c <fd2sockid>
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	78 0f                	js     801f6c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f5d:	83 ec 08             	sub    $0x8,%esp
  801f60:	ff 75 0c             	pushl  0xc(%ebp)
  801f63:	50                   	push   %eax
  801f64:	e8 3f 01 00 00       	call   8020a8 <nsipc_shutdown>
  801f69:	83 c4 10             	add    $0x10,%esp
}
  801f6c:	c9                   	leave  
  801f6d:	c3                   	ret    

00801f6e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f74:	8b 45 08             	mov    0x8(%ebp),%eax
  801f77:	e8 d0 fe ff ff       	call   801e4c <fd2sockid>
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	78 12                	js     801f92 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801f80:	83 ec 04             	sub    $0x4,%esp
  801f83:	ff 75 10             	pushl  0x10(%ebp)
  801f86:	ff 75 0c             	pushl  0xc(%ebp)
  801f89:	50                   	push   %eax
  801f8a:	e8 55 01 00 00       	call   8020e4 <nsipc_connect>
  801f8f:	83 c4 10             	add    $0x10,%esp
}
  801f92:	c9                   	leave  
  801f93:	c3                   	ret    

00801f94 <listen>:

int
listen(int s, int backlog)
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9d:	e8 aa fe ff ff       	call   801e4c <fd2sockid>
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	78 0f                	js     801fb5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801fa6:	83 ec 08             	sub    $0x8,%esp
  801fa9:	ff 75 0c             	pushl  0xc(%ebp)
  801fac:	50                   	push   %eax
  801fad:	e8 67 01 00 00       	call   802119 <nsipc_listen>
  801fb2:	83 c4 10             	add    $0x10,%esp
}
  801fb5:	c9                   	leave  
  801fb6:	c3                   	ret    

00801fb7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801fbd:	ff 75 10             	pushl  0x10(%ebp)
  801fc0:	ff 75 0c             	pushl  0xc(%ebp)
  801fc3:	ff 75 08             	pushl  0x8(%ebp)
  801fc6:	e8 3a 02 00 00       	call   802205 <nsipc_socket>
  801fcb:	83 c4 10             	add    $0x10,%esp
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	78 05                	js     801fd7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801fd2:	e8 a5 fe ff ff       	call   801e7c <alloc_sockfd>
}
  801fd7:	c9                   	leave  
  801fd8:	c3                   	ret    

00801fd9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	53                   	push   %ebx
  801fdd:	83 ec 04             	sub    $0x4,%esp
  801fe0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fe2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801fe9:	75 12                	jne    801ffd <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801feb:	83 ec 0c             	sub    $0xc,%esp
  801fee:	6a 02                	push   $0x2
  801ff0:	e8 18 05 00 00       	call   80250d <ipc_find_env>
  801ff5:	a3 04 40 80 00       	mov    %eax,0x804004
  801ffa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ffd:	6a 07                	push   $0x7
  801fff:	68 00 60 80 00       	push   $0x806000
  802004:	53                   	push   %ebx
  802005:	ff 35 04 40 80 00    	pushl  0x804004
  80200b:	e8 ae 04 00 00       	call   8024be <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802010:	83 c4 0c             	add    $0xc,%esp
  802013:	6a 00                	push   $0x0
  802015:	6a 00                	push   $0x0
  802017:	6a 00                	push   $0x0
  802019:	e8 2a 04 00 00       	call   802448 <ipc_recv>
}
  80201e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802021:	c9                   	leave  
  802022:	c3                   	ret    

00802023 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	56                   	push   %esi
  802027:	53                   	push   %ebx
  802028:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80202b:	8b 45 08             	mov    0x8(%ebp),%eax
  80202e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802033:	8b 06                	mov    (%esi),%eax
  802035:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80203a:	b8 01 00 00 00       	mov    $0x1,%eax
  80203f:	e8 95 ff ff ff       	call   801fd9 <nsipc>
  802044:	89 c3                	mov    %eax,%ebx
  802046:	85 c0                	test   %eax,%eax
  802048:	78 20                	js     80206a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80204a:	83 ec 04             	sub    $0x4,%esp
  80204d:	ff 35 10 60 80 00    	pushl  0x806010
  802053:	68 00 60 80 00       	push   $0x806000
  802058:	ff 75 0c             	pushl  0xc(%ebp)
  80205b:	e8 48 ea ff ff       	call   800aa8 <memmove>
		*addrlen = ret->ret_addrlen;
  802060:	a1 10 60 80 00       	mov    0x806010,%eax
  802065:	89 06                	mov    %eax,(%esi)
  802067:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80206a:	89 d8                	mov    %ebx,%eax
  80206c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5d                   	pop    %ebp
  802072:	c3                   	ret    

00802073 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	53                   	push   %ebx
  802077:	83 ec 08             	sub    $0x8,%esp
  80207a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80207d:	8b 45 08             	mov    0x8(%ebp),%eax
  802080:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802085:	53                   	push   %ebx
  802086:	ff 75 0c             	pushl  0xc(%ebp)
  802089:	68 04 60 80 00       	push   $0x806004
  80208e:	e8 15 ea ff ff       	call   800aa8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802093:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  802099:	b8 02 00 00 00       	mov    $0x2,%eax
  80209e:	e8 36 ff ff ff       	call   801fd9 <nsipc>
}
  8020a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a6:	c9                   	leave  
  8020a7:	c3                   	ret    

008020a8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8020ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8020b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8020be:	b8 03 00 00 00       	mov    $0x3,%eax
  8020c3:	e8 11 ff ff ff       	call   801fd9 <nsipc>
}
  8020c8:	c9                   	leave  
  8020c9:	c3                   	ret    

008020ca <nsipc_close>:

int
nsipc_close(int s)
{
  8020ca:	55                   	push   %ebp
  8020cb:	89 e5                	mov    %esp,%ebp
  8020cd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8020d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8020d8:	b8 04 00 00 00       	mov    $0x4,%eax
  8020dd:	e8 f7 fe ff ff       	call   801fd9 <nsipc>
}
  8020e2:	c9                   	leave  
  8020e3:	c3                   	ret    

008020e4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	53                   	push   %ebx
  8020e8:	83 ec 08             	sub    $0x8,%esp
  8020eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020f6:	53                   	push   %ebx
  8020f7:	ff 75 0c             	pushl  0xc(%ebp)
  8020fa:	68 04 60 80 00       	push   $0x806004
  8020ff:	e8 a4 e9 ff ff       	call   800aa8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802104:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80210a:	b8 05 00 00 00       	mov    $0x5,%eax
  80210f:	e8 c5 fe ff ff       	call   801fd9 <nsipc>
}
  802114:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802117:	c9                   	leave  
  802118:	c3                   	ret    

00802119 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80211f:	8b 45 08             	mov    0x8(%ebp),%eax
  802122:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802127:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80212f:	b8 06 00 00 00       	mov    $0x6,%eax
  802134:	e8 a0 fe ff ff       	call   801fd9 <nsipc>
}
  802139:	c9                   	leave  
  80213a:	c3                   	ret    

0080213b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80213b:	55                   	push   %ebp
  80213c:	89 e5                	mov    %esp,%ebp
  80213e:	56                   	push   %esi
  80213f:	53                   	push   %ebx
  802140:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802143:	8b 45 08             	mov    0x8(%ebp),%eax
  802146:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80214b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802151:	8b 45 14             	mov    0x14(%ebp),%eax
  802154:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802159:	b8 07 00 00 00       	mov    $0x7,%eax
  80215e:	e8 76 fe ff ff       	call   801fd9 <nsipc>
  802163:	89 c3                	mov    %eax,%ebx
  802165:	85 c0                	test   %eax,%eax
  802167:	78 35                	js     80219e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802169:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80216e:	7f 04                	jg     802174 <nsipc_recv+0x39>
  802170:	39 c6                	cmp    %eax,%esi
  802172:	7d 16                	jge    80218a <nsipc_recv+0x4f>
  802174:	68 ed 2d 80 00       	push   $0x802ded
  802179:	68 9b 2d 80 00       	push   $0x802d9b
  80217e:	6a 62                	push   $0x62
  802180:	68 02 2e 80 00       	push   $0x802e02
  802185:	e8 0e e1 ff ff       	call   800298 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80218a:	83 ec 04             	sub    $0x4,%esp
  80218d:	50                   	push   %eax
  80218e:	68 00 60 80 00       	push   $0x806000
  802193:	ff 75 0c             	pushl  0xc(%ebp)
  802196:	e8 0d e9 ff ff       	call   800aa8 <memmove>
  80219b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80219e:	89 d8                	mov    %ebx,%eax
  8021a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    

008021a7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	53                   	push   %ebx
  8021ab:	83 ec 04             	sub    $0x4,%esp
  8021ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8021b9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021bf:	7e 16                	jle    8021d7 <nsipc_send+0x30>
  8021c1:	68 0e 2e 80 00       	push   $0x802e0e
  8021c6:	68 9b 2d 80 00       	push   $0x802d9b
  8021cb:	6a 6d                	push   $0x6d
  8021cd:	68 02 2e 80 00       	push   $0x802e02
  8021d2:	e8 c1 e0 ff ff       	call   800298 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021d7:	83 ec 04             	sub    $0x4,%esp
  8021da:	53                   	push   %ebx
  8021db:	ff 75 0c             	pushl  0xc(%ebp)
  8021de:	68 0c 60 80 00       	push   $0x80600c
  8021e3:	e8 c0 e8 ff ff       	call   800aa8 <memmove>
	nsipcbuf.send.req_size = size;
  8021e8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8021ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8021f1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8021f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8021fb:	e8 d9 fd ff ff       	call   801fd9 <nsipc>
}
  802200:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802203:	c9                   	leave  
  802204:	c3                   	ret    

00802205 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80220b:	8b 45 08             	mov    0x8(%ebp),%eax
  80220e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802213:	8b 45 0c             	mov    0xc(%ebp),%eax
  802216:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80221b:	8b 45 10             	mov    0x10(%ebp),%eax
  80221e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802223:	b8 09 00 00 00       	mov    $0x9,%eax
  802228:	e8 ac fd ff ff       	call   801fd9 <nsipc>
}
  80222d:	c9                   	leave  
  80222e:	c3                   	ret    

0080222f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80222f:	55                   	push   %ebp
  802230:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802232:	b8 00 00 00 00       	mov    $0x0,%eax
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    

00802239 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802239:	55                   	push   %ebp
  80223a:	89 e5                	mov    %esp,%ebp
  80223c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80223f:	68 1a 2e 80 00       	push   $0x802e1a
  802244:	ff 75 0c             	pushl  0xc(%ebp)
  802247:	e8 ca e6 ff ff       	call   800916 <strcpy>
	return 0;
}
  80224c:	b8 00 00 00 00       	mov    $0x0,%eax
  802251:	c9                   	leave  
  802252:	c3                   	ret    

00802253 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	57                   	push   %edi
  802257:	56                   	push   %esi
  802258:	53                   	push   %ebx
  802259:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80225f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802264:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80226a:	eb 2d                	jmp    802299 <devcons_write+0x46>
		m = n - tot;
  80226c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80226f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802271:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802274:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802279:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80227c:	83 ec 04             	sub    $0x4,%esp
  80227f:	53                   	push   %ebx
  802280:	03 45 0c             	add    0xc(%ebp),%eax
  802283:	50                   	push   %eax
  802284:	57                   	push   %edi
  802285:	e8 1e e8 ff ff       	call   800aa8 <memmove>
		sys_cputs(buf, m);
  80228a:	83 c4 08             	add    $0x8,%esp
  80228d:	53                   	push   %ebx
  80228e:	57                   	push   %edi
  80228f:	e8 c9 e9 ff ff       	call   800c5d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802294:	01 de                	add    %ebx,%esi
  802296:	83 c4 10             	add    $0x10,%esp
  802299:	89 f0                	mov    %esi,%eax
  80229b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80229e:	72 cc                	jb     80226c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    

008022a8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	83 ec 08             	sub    $0x8,%esp
  8022ae:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022b7:	74 2a                	je     8022e3 <devcons_read+0x3b>
  8022b9:	eb 05                	jmp    8022c0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022bb:	e8 3a ea ff ff       	call   800cfa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022c0:	e8 b6 e9 ff ff       	call   800c7b <sys_cgetc>
  8022c5:	85 c0                	test   %eax,%eax
  8022c7:	74 f2                	je     8022bb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022c9:	85 c0                	test   %eax,%eax
  8022cb:	78 16                	js     8022e3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022cd:	83 f8 04             	cmp    $0x4,%eax
  8022d0:	74 0c                	je     8022de <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022d5:	88 02                	mov    %al,(%edx)
	return 1;
  8022d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8022dc:	eb 05                	jmp    8022e3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022de:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022e3:	c9                   	leave  
  8022e4:	c3                   	ret    

008022e5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022e5:	55                   	push   %ebp
  8022e6:	89 e5                	mov    %esp,%ebp
  8022e8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ee:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022f1:	6a 01                	push   $0x1
  8022f3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022f6:	50                   	push   %eax
  8022f7:	e8 61 e9 ff ff       	call   800c5d <sys_cputs>
}
  8022fc:	83 c4 10             	add    $0x10,%esp
  8022ff:	c9                   	leave  
  802300:	c3                   	ret    

00802301 <getchar>:

int
getchar(void)
{
  802301:	55                   	push   %ebp
  802302:	89 e5                	mov    %esp,%ebp
  802304:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802307:	6a 01                	push   $0x1
  802309:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80230c:	50                   	push   %eax
  80230d:	6a 00                	push   $0x0
  80230f:	e8 1d f2 ff ff       	call   801531 <read>
	if (r < 0)
  802314:	83 c4 10             	add    $0x10,%esp
  802317:	85 c0                	test   %eax,%eax
  802319:	78 0f                	js     80232a <getchar+0x29>
		return r;
	if (r < 1)
  80231b:	85 c0                	test   %eax,%eax
  80231d:	7e 06                	jle    802325 <getchar+0x24>
		return -E_EOF;
	return c;
  80231f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802323:	eb 05                	jmp    80232a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802325:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80232a:	c9                   	leave  
  80232b:	c3                   	ret    

0080232c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
  80232f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802332:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802335:	50                   	push   %eax
  802336:	ff 75 08             	pushl  0x8(%ebp)
  802339:	e8 8d ef ff ff       	call   8012cb <fd_lookup>
  80233e:	83 c4 10             	add    $0x10,%esp
  802341:	85 c0                	test   %eax,%eax
  802343:	78 11                	js     802356 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802345:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802348:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80234e:	39 10                	cmp    %edx,(%eax)
  802350:	0f 94 c0             	sete   %al
  802353:	0f b6 c0             	movzbl %al,%eax
}
  802356:	c9                   	leave  
  802357:	c3                   	ret    

00802358 <opencons>:

int
opencons(void)
{
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80235e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802361:	50                   	push   %eax
  802362:	e8 15 ef ff ff       	call   80127c <fd_alloc>
  802367:	83 c4 10             	add    $0x10,%esp
		return r;
  80236a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80236c:	85 c0                	test   %eax,%eax
  80236e:	78 3e                	js     8023ae <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802370:	83 ec 04             	sub    $0x4,%esp
  802373:	68 07 04 00 00       	push   $0x407
  802378:	ff 75 f4             	pushl  -0xc(%ebp)
  80237b:	6a 00                	push   $0x0
  80237d:	e8 97 e9 ff ff       	call   800d19 <sys_page_alloc>
  802382:	83 c4 10             	add    $0x10,%esp
		return r;
  802385:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802387:	85 c0                	test   %eax,%eax
  802389:	78 23                	js     8023ae <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80238b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802394:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802396:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802399:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023a0:	83 ec 0c             	sub    $0xc,%esp
  8023a3:	50                   	push   %eax
  8023a4:	e8 ac ee ff ff       	call   801255 <fd2num>
  8023a9:	89 c2                	mov    %eax,%edx
  8023ab:	83 c4 10             	add    $0x10,%esp
}
  8023ae:	89 d0                	mov    %edx,%eax
  8023b0:	c9                   	leave  
  8023b1:	c3                   	ret    

008023b2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023b2:	55                   	push   %ebp
  8023b3:	89 e5                	mov    %esp,%ebp
  8023b5:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  8023b8:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023bf:	75 56                	jne    802417 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  8023c1:	83 ec 04             	sub    $0x4,%esp
  8023c4:	6a 07                	push   $0x7
  8023c6:	68 00 f0 bf ee       	push   $0xeebff000
  8023cb:	6a 00                	push   $0x0
  8023cd:	e8 47 e9 ff ff       	call   800d19 <sys_page_alloc>
  8023d2:	83 c4 10             	add    $0x10,%esp
  8023d5:	85 c0                	test   %eax,%eax
  8023d7:	74 14                	je     8023ed <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  8023d9:	83 ec 04             	sub    $0x4,%esp
  8023dc:	68 a9 2c 80 00       	push   $0x802ca9
  8023e1:	6a 21                	push   $0x21
  8023e3:	68 26 2e 80 00       	push   $0x802e26
  8023e8:	e8 ab de ff ff       	call   800298 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  8023ed:	83 ec 08             	sub    $0x8,%esp
  8023f0:	68 21 24 80 00       	push   $0x802421
  8023f5:	6a 00                	push   $0x0
  8023f7:	e8 68 ea ff ff       	call   800e64 <sys_env_set_pgfault_upcall>
  8023fc:	83 c4 10             	add    $0x10,%esp
  8023ff:	85 c0                	test   %eax,%eax
  802401:	74 14                	je     802417 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  802403:	83 ec 04             	sub    $0x4,%esp
  802406:	68 34 2e 80 00       	push   $0x802e34
  80240b:	6a 23                	push   $0x23
  80240d:	68 26 2e 80 00       	push   $0x802e26
  802412:	e8 81 de ff ff       	call   800298 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802417:	8b 45 08             	mov    0x8(%ebp),%eax
  80241a:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80241f:	c9                   	leave  
  802420:	c3                   	ret    

00802421 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802421:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802422:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802427:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802429:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  80242c:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  80242e:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  802432:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  802436:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  802437:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  802439:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  80243e:	83 c4 08             	add    $0x8,%esp
	popal
  802441:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802442:	83 c4 04             	add    $0x4,%esp
	popfl
  802445:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802446:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802447:	c3                   	ret    

00802448 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802448:	55                   	push   %ebp
  802449:	89 e5                	mov    %esp,%ebp
  80244b:	56                   	push   %esi
  80244c:	53                   	push   %ebx
  80244d:	8b 75 08             	mov    0x8(%ebp),%esi
  802450:	8b 45 0c             	mov    0xc(%ebp),%eax
  802453:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  802456:	85 c0                	test   %eax,%eax
  802458:	74 0e                	je     802468 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  80245a:	83 ec 0c             	sub    $0xc,%esp
  80245d:	50                   	push   %eax
  80245e:	e8 66 ea ff ff       	call   800ec9 <sys_ipc_recv>
  802463:	83 c4 10             	add    $0x10,%esp
  802466:	eb 10                	jmp    802478 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802468:	83 ec 0c             	sub    $0xc,%esp
  80246b:	68 00 00 c0 ee       	push   $0xeec00000
  802470:	e8 54 ea ff ff       	call   800ec9 <sys_ipc_recv>
  802475:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  802478:	85 c0                	test   %eax,%eax
  80247a:	79 17                	jns    802493 <ipc_recv+0x4b>
		if(*from_env_store)
  80247c:	83 3e 00             	cmpl   $0x0,(%esi)
  80247f:	74 06                	je     802487 <ipc_recv+0x3f>
			*from_env_store = 0;
  802481:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  802487:	85 db                	test   %ebx,%ebx
  802489:	74 2c                	je     8024b7 <ipc_recv+0x6f>
			*perm_store = 0;
  80248b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802491:	eb 24                	jmp    8024b7 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  802493:	85 f6                	test   %esi,%esi
  802495:	74 0a                	je     8024a1 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  802497:	a1 08 40 80 00       	mov    0x804008,%eax
  80249c:	8b 40 74             	mov    0x74(%eax),%eax
  80249f:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8024a1:	85 db                	test   %ebx,%ebx
  8024a3:	74 0a                	je     8024af <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8024a5:	a1 08 40 80 00       	mov    0x804008,%eax
  8024aa:	8b 40 78             	mov    0x78(%eax),%eax
  8024ad:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8024af:	a1 08 40 80 00       	mov    0x804008,%eax
  8024b4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024ba:	5b                   	pop    %ebx
  8024bb:	5e                   	pop    %esi
  8024bc:	5d                   	pop    %ebp
  8024bd:	c3                   	ret    

008024be <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024be:	55                   	push   %ebp
  8024bf:	89 e5                	mov    %esp,%ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 0c             	sub    $0xc,%esp
  8024c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8024d0:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  8024d2:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  8024d7:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  8024da:	e8 1b e8 ff ff       	call   800cfa <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  8024df:	ff 75 14             	pushl  0x14(%ebp)
  8024e2:	53                   	push   %ebx
  8024e3:	56                   	push   %esi
  8024e4:	57                   	push   %edi
  8024e5:	e8 bc e9 ff ff       	call   800ea6 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  8024ea:	89 c2                	mov    %eax,%edx
  8024ec:	f7 d2                	not    %edx
  8024ee:	c1 ea 1f             	shr    $0x1f,%edx
  8024f1:	83 c4 10             	add    $0x10,%esp
  8024f4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024f7:	0f 94 c1             	sete   %cl
  8024fa:	09 ca                	or     %ecx,%edx
  8024fc:	85 c0                	test   %eax,%eax
  8024fe:	0f 94 c0             	sete   %al
  802501:	38 c2                	cmp    %al,%dl
  802503:	77 d5                	ja     8024da <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802505:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802508:	5b                   	pop    %ebx
  802509:	5e                   	pop    %esi
  80250a:	5f                   	pop    %edi
  80250b:	5d                   	pop    %ebp
  80250c:	c3                   	ret    

0080250d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80250d:	55                   	push   %ebp
  80250e:	89 e5                	mov    %esp,%ebp
  802510:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802513:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802518:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80251b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802521:	8b 52 50             	mov    0x50(%edx),%edx
  802524:	39 ca                	cmp    %ecx,%edx
  802526:	75 0d                	jne    802535 <ipc_find_env+0x28>
			return envs[i].env_id;
  802528:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80252b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802530:	8b 40 48             	mov    0x48(%eax),%eax
  802533:	eb 0f                	jmp    802544 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802535:	83 c0 01             	add    $0x1,%eax
  802538:	3d 00 04 00 00       	cmp    $0x400,%eax
  80253d:	75 d9                	jne    802518 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80253f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802544:	5d                   	pop    %ebp
  802545:	c3                   	ret    

00802546 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802546:	55                   	push   %ebp
  802547:	89 e5                	mov    %esp,%ebp
  802549:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80254c:	89 d0                	mov    %edx,%eax
  80254e:	c1 e8 16             	shr    $0x16,%eax
  802551:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802558:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80255d:	f6 c1 01             	test   $0x1,%cl
  802560:	74 1d                	je     80257f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802562:	c1 ea 0c             	shr    $0xc,%edx
  802565:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80256c:	f6 c2 01             	test   $0x1,%dl
  80256f:	74 0e                	je     80257f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802571:	c1 ea 0c             	shr    $0xc,%edx
  802574:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80257b:	ef 
  80257c:	0f b7 c0             	movzwl %ax,%eax
}
  80257f:	5d                   	pop    %ebp
  802580:	c3                   	ret    
  802581:	66 90                	xchg   %ax,%ax
  802583:	66 90                	xchg   %ax,%ax
  802585:	66 90                	xchg   %ax,%ax
  802587:	66 90                	xchg   %ax,%ax
  802589:	66 90                	xchg   %ax,%ax
  80258b:	66 90                	xchg   %ax,%ax
  80258d:	66 90                	xchg   %ax,%ax
  80258f:	90                   	nop

00802590 <__udivdi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	53                   	push   %ebx
  802594:	83 ec 1c             	sub    $0x1c,%esp
  802597:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80259b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80259f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025a7:	85 f6                	test   %esi,%esi
  8025a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025ad:	89 ca                	mov    %ecx,%edx
  8025af:	89 f8                	mov    %edi,%eax
  8025b1:	75 3d                	jne    8025f0 <__udivdi3+0x60>
  8025b3:	39 cf                	cmp    %ecx,%edi
  8025b5:	0f 87 c5 00 00 00    	ja     802680 <__udivdi3+0xf0>
  8025bb:	85 ff                	test   %edi,%edi
  8025bd:	89 fd                	mov    %edi,%ebp
  8025bf:	75 0b                	jne    8025cc <__udivdi3+0x3c>
  8025c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c6:	31 d2                	xor    %edx,%edx
  8025c8:	f7 f7                	div    %edi
  8025ca:	89 c5                	mov    %eax,%ebp
  8025cc:	89 c8                	mov    %ecx,%eax
  8025ce:	31 d2                	xor    %edx,%edx
  8025d0:	f7 f5                	div    %ebp
  8025d2:	89 c1                	mov    %eax,%ecx
  8025d4:	89 d8                	mov    %ebx,%eax
  8025d6:	89 cf                	mov    %ecx,%edi
  8025d8:	f7 f5                	div    %ebp
  8025da:	89 c3                	mov    %eax,%ebx
  8025dc:	89 d8                	mov    %ebx,%eax
  8025de:	89 fa                	mov    %edi,%edx
  8025e0:	83 c4 1c             	add    $0x1c,%esp
  8025e3:	5b                   	pop    %ebx
  8025e4:	5e                   	pop    %esi
  8025e5:	5f                   	pop    %edi
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
  8025e8:	90                   	nop
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	39 ce                	cmp    %ecx,%esi
  8025f2:	77 74                	ja     802668 <__udivdi3+0xd8>
  8025f4:	0f bd fe             	bsr    %esi,%edi
  8025f7:	83 f7 1f             	xor    $0x1f,%edi
  8025fa:	0f 84 98 00 00 00    	je     802698 <__udivdi3+0x108>
  802600:	bb 20 00 00 00       	mov    $0x20,%ebx
  802605:	89 f9                	mov    %edi,%ecx
  802607:	89 c5                	mov    %eax,%ebp
  802609:	29 fb                	sub    %edi,%ebx
  80260b:	d3 e6                	shl    %cl,%esi
  80260d:	89 d9                	mov    %ebx,%ecx
  80260f:	d3 ed                	shr    %cl,%ebp
  802611:	89 f9                	mov    %edi,%ecx
  802613:	d3 e0                	shl    %cl,%eax
  802615:	09 ee                	or     %ebp,%esi
  802617:	89 d9                	mov    %ebx,%ecx
  802619:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80261d:	89 d5                	mov    %edx,%ebp
  80261f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802623:	d3 ed                	shr    %cl,%ebp
  802625:	89 f9                	mov    %edi,%ecx
  802627:	d3 e2                	shl    %cl,%edx
  802629:	89 d9                	mov    %ebx,%ecx
  80262b:	d3 e8                	shr    %cl,%eax
  80262d:	09 c2                	or     %eax,%edx
  80262f:	89 d0                	mov    %edx,%eax
  802631:	89 ea                	mov    %ebp,%edx
  802633:	f7 f6                	div    %esi
  802635:	89 d5                	mov    %edx,%ebp
  802637:	89 c3                	mov    %eax,%ebx
  802639:	f7 64 24 0c          	mull   0xc(%esp)
  80263d:	39 d5                	cmp    %edx,%ebp
  80263f:	72 10                	jb     802651 <__udivdi3+0xc1>
  802641:	8b 74 24 08          	mov    0x8(%esp),%esi
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e6                	shl    %cl,%esi
  802649:	39 c6                	cmp    %eax,%esi
  80264b:	73 07                	jae    802654 <__udivdi3+0xc4>
  80264d:	39 d5                	cmp    %edx,%ebp
  80264f:	75 03                	jne    802654 <__udivdi3+0xc4>
  802651:	83 eb 01             	sub    $0x1,%ebx
  802654:	31 ff                	xor    %edi,%edi
  802656:	89 d8                	mov    %ebx,%eax
  802658:	89 fa                	mov    %edi,%edx
  80265a:	83 c4 1c             	add    $0x1c,%esp
  80265d:	5b                   	pop    %ebx
  80265e:	5e                   	pop    %esi
  80265f:	5f                   	pop    %edi
  802660:	5d                   	pop    %ebp
  802661:	c3                   	ret    
  802662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802668:	31 ff                	xor    %edi,%edi
  80266a:	31 db                	xor    %ebx,%ebx
  80266c:	89 d8                	mov    %ebx,%eax
  80266e:	89 fa                	mov    %edi,%edx
  802670:	83 c4 1c             	add    $0x1c,%esp
  802673:	5b                   	pop    %ebx
  802674:	5e                   	pop    %esi
  802675:	5f                   	pop    %edi
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    
  802678:	90                   	nop
  802679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802680:	89 d8                	mov    %ebx,%eax
  802682:	f7 f7                	div    %edi
  802684:	31 ff                	xor    %edi,%edi
  802686:	89 c3                	mov    %eax,%ebx
  802688:	89 d8                	mov    %ebx,%eax
  80268a:	89 fa                	mov    %edi,%edx
  80268c:	83 c4 1c             	add    $0x1c,%esp
  80268f:	5b                   	pop    %ebx
  802690:	5e                   	pop    %esi
  802691:	5f                   	pop    %edi
  802692:	5d                   	pop    %ebp
  802693:	c3                   	ret    
  802694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802698:	39 ce                	cmp    %ecx,%esi
  80269a:	72 0c                	jb     8026a8 <__udivdi3+0x118>
  80269c:	31 db                	xor    %ebx,%ebx
  80269e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026a2:	0f 87 34 ff ff ff    	ja     8025dc <__udivdi3+0x4c>
  8026a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026ad:	e9 2a ff ff ff       	jmp    8025dc <__udivdi3+0x4c>
  8026b2:	66 90                	xchg   %ax,%ax
  8026b4:	66 90                	xchg   %ax,%ax
  8026b6:	66 90                	xchg   %ax,%ax
  8026b8:	66 90                	xchg   %ax,%ax
  8026ba:	66 90                	xchg   %ax,%ax
  8026bc:	66 90                	xchg   %ax,%ax
  8026be:	66 90                	xchg   %ax,%ax

008026c0 <__umoddi3>:
  8026c0:	55                   	push   %ebp
  8026c1:	57                   	push   %edi
  8026c2:	56                   	push   %esi
  8026c3:	53                   	push   %ebx
  8026c4:	83 ec 1c             	sub    $0x1c,%esp
  8026c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026d7:	85 d2                	test   %edx,%edx
  8026d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026e1:	89 f3                	mov    %esi,%ebx
  8026e3:	89 3c 24             	mov    %edi,(%esp)
  8026e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ea:	75 1c                	jne    802708 <__umoddi3+0x48>
  8026ec:	39 f7                	cmp    %esi,%edi
  8026ee:	76 50                	jbe    802740 <__umoddi3+0x80>
  8026f0:	89 c8                	mov    %ecx,%eax
  8026f2:	89 f2                	mov    %esi,%edx
  8026f4:	f7 f7                	div    %edi
  8026f6:	89 d0                	mov    %edx,%eax
  8026f8:	31 d2                	xor    %edx,%edx
  8026fa:	83 c4 1c             	add    $0x1c,%esp
  8026fd:	5b                   	pop    %ebx
  8026fe:	5e                   	pop    %esi
  8026ff:	5f                   	pop    %edi
  802700:	5d                   	pop    %ebp
  802701:	c3                   	ret    
  802702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802708:	39 f2                	cmp    %esi,%edx
  80270a:	89 d0                	mov    %edx,%eax
  80270c:	77 52                	ja     802760 <__umoddi3+0xa0>
  80270e:	0f bd ea             	bsr    %edx,%ebp
  802711:	83 f5 1f             	xor    $0x1f,%ebp
  802714:	75 5a                	jne    802770 <__umoddi3+0xb0>
  802716:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80271a:	0f 82 e0 00 00 00    	jb     802800 <__umoddi3+0x140>
  802720:	39 0c 24             	cmp    %ecx,(%esp)
  802723:	0f 86 d7 00 00 00    	jbe    802800 <__umoddi3+0x140>
  802729:	8b 44 24 08          	mov    0x8(%esp),%eax
  80272d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802731:	83 c4 1c             	add    $0x1c,%esp
  802734:	5b                   	pop    %ebx
  802735:	5e                   	pop    %esi
  802736:	5f                   	pop    %edi
  802737:	5d                   	pop    %ebp
  802738:	c3                   	ret    
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	85 ff                	test   %edi,%edi
  802742:	89 fd                	mov    %edi,%ebp
  802744:	75 0b                	jne    802751 <__umoddi3+0x91>
  802746:	b8 01 00 00 00       	mov    $0x1,%eax
  80274b:	31 d2                	xor    %edx,%edx
  80274d:	f7 f7                	div    %edi
  80274f:	89 c5                	mov    %eax,%ebp
  802751:	89 f0                	mov    %esi,%eax
  802753:	31 d2                	xor    %edx,%edx
  802755:	f7 f5                	div    %ebp
  802757:	89 c8                	mov    %ecx,%eax
  802759:	f7 f5                	div    %ebp
  80275b:	89 d0                	mov    %edx,%eax
  80275d:	eb 99                	jmp    8026f8 <__umoddi3+0x38>
  80275f:	90                   	nop
  802760:	89 c8                	mov    %ecx,%eax
  802762:	89 f2                	mov    %esi,%edx
  802764:	83 c4 1c             	add    $0x1c,%esp
  802767:	5b                   	pop    %ebx
  802768:	5e                   	pop    %esi
  802769:	5f                   	pop    %edi
  80276a:	5d                   	pop    %ebp
  80276b:	c3                   	ret    
  80276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802770:	8b 34 24             	mov    (%esp),%esi
  802773:	bf 20 00 00 00       	mov    $0x20,%edi
  802778:	89 e9                	mov    %ebp,%ecx
  80277a:	29 ef                	sub    %ebp,%edi
  80277c:	d3 e0                	shl    %cl,%eax
  80277e:	89 f9                	mov    %edi,%ecx
  802780:	89 f2                	mov    %esi,%edx
  802782:	d3 ea                	shr    %cl,%edx
  802784:	89 e9                	mov    %ebp,%ecx
  802786:	09 c2                	or     %eax,%edx
  802788:	89 d8                	mov    %ebx,%eax
  80278a:	89 14 24             	mov    %edx,(%esp)
  80278d:	89 f2                	mov    %esi,%edx
  80278f:	d3 e2                	shl    %cl,%edx
  802791:	89 f9                	mov    %edi,%ecx
  802793:	89 54 24 04          	mov    %edx,0x4(%esp)
  802797:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80279b:	d3 e8                	shr    %cl,%eax
  80279d:	89 e9                	mov    %ebp,%ecx
  80279f:	89 c6                	mov    %eax,%esi
  8027a1:	d3 e3                	shl    %cl,%ebx
  8027a3:	89 f9                	mov    %edi,%ecx
  8027a5:	89 d0                	mov    %edx,%eax
  8027a7:	d3 e8                	shr    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	09 d8                	or     %ebx,%eax
  8027ad:	89 d3                	mov    %edx,%ebx
  8027af:	89 f2                	mov    %esi,%edx
  8027b1:	f7 34 24             	divl   (%esp)
  8027b4:	89 d6                	mov    %edx,%esi
  8027b6:	d3 e3                	shl    %cl,%ebx
  8027b8:	f7 64 24 04          	mull   0x4(%esp)
  8027bc:	39 d6                	cmp    %edx,%esi
  8027be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027c2:	89 d1                	mov    %edx,%ecx
  8027c4:	89 c3                	mov    %eax,%ebx
  8027c6:	72 08                	jb     8027d0 <__umoddi3+0x110>
  8027c8:	75 11                	jne    8027db <__umoddi3+0x11b>
  8027ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ce:	73 0b                	jae    8027db <__umoddi3+0x11b>
  8027d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027d4:	1b 14 24             	sbb    (%esp),%edx
  8027d7:	89 d1                	mov    %edx,%ecx
  8027d9:	89 c3                	mov    %eax,%ebx
  8027db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027df:	29 da                	sub    %ebx,%edx
  8027e1:	19 ce                	sbb    %ecx,%esi
  8027e3:	89 f9                	mov    %edi,%ecx
  8027e5:	89 f0                	mov    %esi,%eax
  8027e7:	d3 e0                	shl    %cl,%eax
  8027e9:	89 e9                	mov    %ebp,%ecx
  8027eb:	d3 ea                	shr    %cl,%edx
  8027ed:	89 e9                	mov    %ebp,%ecx
  8027ef:	d3 ee                	shr    %cl,%esi
  8027f1:	09 d0                	or     %edx,%eax
  8027f3:	89 f2                	mov    %esi,%edx
  8027f5:	83 c4 1c             	add    $0x1c,%esp
  8027f8:	5b                   	pop    %ebx
  8027f9:	5e                   	pop    %esi
  8027fa:	5f                   	pop    %edi
  8027fb:	5d                   	pop    %ebp
  8027fc:	c3                   	ret    
  8027fd:	8d 76 00             	lea    0x0(%esi),%esi
  802800:	29 f9                	sub    %edi,%ecx
  802802:	19 d6                	sbb    %edx,%esi
  802804:	89 74 24 04          	mov    %esi,0x4(%esp)
  802808:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80280c:	e9 18 ff ff ff       	jmp    802729 <__umoddi3+0x69>
