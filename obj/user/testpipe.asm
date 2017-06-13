
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 e0 	movl   $0x8028e0,0x803004
  800042:	28 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 6e 1c 00 00       	call   801cbc <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 ec 28 80 00       	push   $0x8028ec
  80005d:	6a 0e                	push   $0xe
  80005f:	68 f5 28 80 00       	push   $0x8028f5
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 29 10 00 00       	call   801097 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 05 29 80 00       	push   $0x802905
  80007a:	6a 11                	push   $0x11
  80007c:	68 f5 28 80 00       	push   $0x8028f5
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 08 40 80 00       	mov    0x804008,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 0e 29 80 00       	push   $0x80290e
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 bd 13 00 00       	call   80146f <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 2b 29 80 00       	push   $0x80292b
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 60 15 00 00       	call   80163c <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 48 29 80 00       	push   $0x802948
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 f5 28 80 00       	push   $0x8028f5
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 2c 09 00 00       	call   800a3a <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 51 29 80 00       	push   $0x802951
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 6d 29 80 00       	push   $0x80296d
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 08 40 80 00       	mov    0x804008,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 0e 29 80 00       	push   $0x80290e
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 05 13 00 00       	call   80146f <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 08 40 80 00       	mov    0x804008,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 80 29 80 00       	push   $0x802980
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 c6 07 00 00       	call   800957 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 e2 14 00 00       	call   801685 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 a4 07 00 00       	call   800957 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 9d 29 80 00       	push   $0x80299d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 f5 28 80 00       	push   $0x8028f5
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 98 12 00 00       	call   80146f <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 5f 1c 00 00       	call   801e42 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 a7 	movl   $0x8029a7,0x803004
  8001ea:	29 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 c4 1a 00 00       	call   801cbc <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 ec 28 80 00       	push   $0x8028ec
  800207:	6a 2c                	push   $0x2c
  800209:	68 f5 28 80 00       	push   $0x8028f5
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 7f 0e 00 00       	call   801097 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 05 29 80 00       	push   $0x802905
  800224:	6a 2f                	push   $0x2f
  800226:	68 f5 28 80 00       	push   $0x8028f5
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 30 12 00 00       	call   80146f <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 b4 29 80 00       	push   $0x8029b4
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 b6 29 80 00       	push   $0x8029b6
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 24 14 00 00       	call   801685 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 b8 29 80 00       	push   $0x8029b8
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 e6 11 00 00       	call   80146f <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 db 11 00 00       	call   80146f <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 a6 1b 00 00       	call   801e42 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 d5 29 80 00 	movl   $0x8029d5,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8002bd:	e8 93 0a 00 00       	call   800d55 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 97 11 00 00       	call   80149a <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 07 0a 00 00       	call   800d14 <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 30 0a 00 00       	call   800d55 <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 38 2a 80 00       	push   $0x802a38
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 29 29 80 00 	movl   $0x802929,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 4f 09 00 00       	call   800cd7 <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 54 01 00 00       	call   800522 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 f4 08 00 00       	call   800cd7 <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 fd 21 00 00       	call   802650 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 ea 22 00 00       	call   802780 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 5b 2a 80 00 	movsbl 0x802a5b(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b1:	83 fa 01             	cmp    $0x1,%edx
  8004b4:	7e 0e                	jle    8004c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	8b 52 04             	mov    0x4(%edx),%edx
  8004c2:	eb 22                	jmp    8004e6 <getuint+0x38>
	else if (lflag)
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	74 10                	je     8004d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	eb 0e                	jmp    8004e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d8:	8b 10                	mov    (%eax),%edx
  8004da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dd:	89 08                	mov    %ecx,(%eax)
  8004df:	8b 02                	mov    (%edx),%eax
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e6:	5d                   	pop    %ebp
  8004e7:	c3                   	ret    

008004e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f7:	73 0a                	jae    800503 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	88 02                	mov    %al,(%edx)
}
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050e:	50                   	push   %eax
  80050f:	ff 75 10             	pushl  0x10(%ebp)
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	e8 05 00 00 00       	call   800522 <vprintfmt>
	va_end(ap);
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	53                   	push   %ebx
  800528:	83 ec 2c             	sub    $0x2c,%esp
  80052b:	8b 75 08             	mov    0x8(%ebp),%esi
  80052e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800531:	8b 7d 10             	mov    0x10(%ebp),%edi
  800534:	eb 12                	jmp    800548 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 84 a9 03 00 00    	je     8008e7 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	50                   	push   %eax
  800543:	ff d6                	call   *%esi
  800545:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800548:	83 c7 01             	add    $0x1,%edi
  80054b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 e2                	jne    800536 <vprintfmt+0x14>
  800554:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800558:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800566:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056d:	ba 00 00 00 00       	mov    $0x0,%edx
  800572:	eb 07                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800577:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8d 47 01             	lea    0x1(%edi),%eax
  80057e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800581:	0f b6 07             	movzbl (%edi),%eax
  800584:	0f b6 c8             	movzbl %al,%ecx
  800587:	83 e8 23             	sub    $0x23,%eax
  80058a:	3c 55                	cmp    $0x55,%al
  80058c:	0f 87 3a 03 00 00    	ja     8008cc <vprintfmt+0x3aa>
  800592:	0f b6 c0             	movzbl %al,%eax
  800595:	ff 24 85 a0 2b 80 00 	jmp    *0x802ba0(,%eax,4)
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a3:	eb d6                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ba:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005bd:	83 fa 09             	cmp    $0x9,%edx
  8005c0:	77 39                	ja     8005fb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c5:	eb e9                	jmp    8005b0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8005cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d8:	eb 27                	jmp    800601 <vprintfmt+0xdf>
  8005da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e4:	0f 49 c8             	cmovns %eax,%ecx
  8005e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ed:	eb 8c                	jmp    80057b <vprintfmt+0x59>
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f9:	eb 80                	jmp    80057b <vprintfmt+0x59>
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800601:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800605:	0f 89 70 ff ff ff    	jns    80057b <vprintfmt+0x59>
				width = precision, precision = -1;
  80060b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800611:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800618:	e9 5e ff ff ff       	jmp    80057b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800623:	e9 53 ff ff ff       	jmp    80057b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	ff 30                	pushl  (%eax)
  800637:	ff d6                	call   *%esi
			break;
  800639:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063f:	e9 04 ff ff ff       	jmp    800548 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	99                   	cltd   
  800650:	31 d0                	xor    %edx,%eax
  800652:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800654:	83 f8 0f             	cmp    $0xf,%eax
  800657:	7f 0b                	jg     800664 <vprintfmt+0x142>
  800659:	8b 14 85 00 2d 80 00 	mov    0x802d00(,%eax,4),%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	75 18                	jne    80067c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 73 2a 80 00       	push   $0x802a73
  80066a:	53                   	push   %ebx
  80066b:	56                   	push   %esi
  80066c:	e8 94 fe ff ff       	call   800505 <printfmt>
  800671:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800677:	e9 cc fe ff ff       	jmp    800548 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067c:	52                   	push   %edx
  80067d:	68 0d 2f 80 00       	push   $0x802f0d
  800682:	53                   	push   %ebx
  800683:	56                   	push   %esi
  800684:	e8 7c fe ff ff       	call   800505 <printfmt>
  800689:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068f:	e9 b4 fe ff ff       	jmp    800548 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069f:	85 ff                	test   %edi,%edi
  8006a1:	b8 6c 2a 80 00       	mov    $0x802a6c,%eax
  8006a6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ad:	0f 8e 94 00 00 00    	jle    800747 <vprintfmt+0x225>
  8006b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b7:	0f 84 98 00 00 00    	je     800755 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c3:	57                   	push   %edi
  8006c4:	e8 a6 02 00 00       	call   80096f <strnlen>
  8006c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cc:	29 c1                	sub    %eax,%ecx
  8006ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006de:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	eb 0f                	jmp    8006f1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006eb:	83 ef 01             	sub    $0x1,%edi
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 ff                	test   %edi,%edi
  8006f3:	7f ed                	jg     8006e2 <vprintfmt+0x1c0>
  8006f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800702:	0f 49 c1             	cmovns %ecx,%eax
  800705:	29 c1                	sub    %eax,%ecx
  800707:	89 75 08             	mov    %esi,0x8(%ebp)
  80070a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800710:	89 cb                	mov    %ecx,%ebx
  800712:	eb 4d                	jmp    800761 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800714:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800718:	74 1b                	je     800735 <vprintfmt+0x213>
  80071a:	0f be c0             	movsbl %al,%eax
  80071d:	83 e8 20             	sub    $0x20,%eax
  800720:	83 f8 5e             	cmp    $0x5e,%eax
  800723:	76 10                	jbe    800735 <vprintfmt+0x213>
					putch('?', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	6a 3f                	push   $0x3f
  80072d:	ff 55 08             	call   *0x8(%ebp)
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb 0d                	jmp    800742 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	52                   	push   %edx
  80073c:	ff 55 08             	call   *0x8(%ebp)
  80073f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800742:	83 eb 01             	sub    $0x1,%ebx
  800745:	eb 1a                	jmp    800761 <vprintfmt+0x23f>
  800747:	89 75 08             	mov    %esi,0x8(%ebp)
  80074a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800750:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800753:	eb 0c                	jmp    800761 <vprintfmt+0x23f>
  800755:	89 75 08             	mov    %esi,0x8(%ebp)
  800758:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800761:	83 c7 01             	add    $0x1,%edi
  800764:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800768:	0f be d0             	movsbl %al,%edx
  80076b:	85 d2                	test   %edx,%edx
  80076d:	74 23                	je     800792 <vprintfmt+0x270>
  80076f:	85 f6                	test   %esi,%esi
  800771:	78 a1                	js     800714 <vprintfmt+0x1f2>
  800773:	83 ee 01             	sub    $0x1,%esi
  800776:	79 9c                	jns    800714 <vprintfmt+0x1f2>
  800778:	89 df                	mov    %ebx,%edi
  80077a:	8b 75 08             	mov    0x8(%ebp),%esi
  80077d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800780:	eb 18                	jmp    80079a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	53                   	push   %ebx
  800786:	6a 20                	push   $0x20
  800788:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078a:	83 ef 01             	sub    $0x1,%edi
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	eb 08                	jmp    80079a <vprintfmt+0x278>
  800792:	89 df                	mov    %ebx,%edi
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079a:	85 ff                	test   %edi,%edi
  80079c:	7f e4                	jg     800782 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a1:	e9 a2 fd ff ff       	jmp    800548 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a6:	83 fa 01             	cmp    $0x1,%edx
  8007a9:	7e 16                	jle    8007c1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 08             	lea    0x8(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 50 04             	mov    0x4(%eax),%edx
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007bf:	eb 32                	jmp    8007f3 <vprintfmt+0x2d1>
	else if (lflag)
  8007c1:	85 d2                	test   %edx,%edx
  8007c3:	74 18                	je     8007dd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 04             	lea    0x4(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 00                	mov    (%eax),%eax
  8007d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d3:	89 c1                	mov    %eax,%ecx
  8007d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007db:	eb 16                	jmp    8007f3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 c1                	mov    %eax,%ecx
  8007ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800802:	0f 89 90 00 00 00    	jns    800898 <vprintfmt+0x376>
				putch('-', putdat);
  800808:	83 ec 08             	sub    $0x8,%esp
  80080b:	53                   	push   %ebx
  80080c:	6a 2d                	push   $0x2d
  80080e:	ff d6                	call   *%esi
				num = -(long long) num;
  800810:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800813:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800816:	f7 d8                	neg    %eax
  800818:	83 d2 00             	adc    $0x0,%edx
  80081b:	f7 da                	neg    %edx
  80081d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800820:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800825:	eb 71                	jmp    800898 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800827:	8d 45 14             	lea    0x14(%ebp),%eax
  80082a:	e8 7f fc ff ff       	call   8004ae <getuint>
			base = 10;
  80082f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800834:	eb 62                	jmp    800898 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800836:	8d 45 14             	lea    0x14(%ebp),%eax
  800839:	e8 70 fc ff ff       	call   8004ae <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  80083e:	83 ec 0c             	sub    $0xc,%esp
  800841:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800845:	51                   	push   %ecx
  800846:	ff 75 e0             	pushl  -0x20(%ebp)
  800849:	6a 08                	push   $0x8
  80084b:	52                   	push   %edx
  80084c:	50                   	push   %eax
  80084d:	89 da                	mov    %ebx,%edx
  80084f:	89 f0                	mov    %esi,%eax
  800851:	e8 a9 fb ff ff       	call   8003ff <printnum>
			break;
  800856:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800859:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  80085c:	e9 e7 fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800861:	83 ec 08             	sub    $0x8,%esp
  800864:	53                   	push   %ebx
  800865:	6a 30                	push   $0x30
  800867:	ff d6                	call   *%esi
			putch('x', putdat);
  800869:	83 c4 08             	add    $0x8,%esp
  80086c:	53                   	push   %ebx
  80086d:	6a 78                	push   $0x78
  80086f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800871:	8b 45 14             	mov    0x14(%ebp),%eax
  800874:	8d 50 04             	lea    0x4(%eax),%edx
  800877:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80087a:	8b 00                	mov    (%eax),%eax
  80087c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800881:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800884:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800889:	eb 0d                	jmp    800898 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80088b:	8d 45 14             	lea    0x14(%ebp),%eax
  80088e:	e8 1b fc ff ff       	call   8004ae <getuint>
			base = 16;
  800893:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800898:	83 ec 0c             	sub    $0xc,%esp
  80089b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80089f:	57                   	push   %edi
  8008a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a3:	51                   	push   %ecx
  8008a4:	52                   	push   %edx
  8008a5:	50                   	push   %eax
  8008a6:	89 da                	mov    %ebx,%edx
  8008a8:	89 f0                	mov    %esi,%eax
  8008aa:	e8 50 fb ff ff       	call   8003ff <printnum>
			break;
  8008af:	83 c4 20             	add    $0x20,%esp
  8008b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b5:	e9 8e fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	53                   	push   %ebx
  8008be:	51                   	push   %ecx
  8008bf:	ff d6                	call   *%esi
			break;
  8008c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008c7:	e9 7c fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008cc:	83 ec 08             	sub    $0x8,%esp
  8008cf:	53                   	push   %ebx
  8008d0:	6a 25                	push   $0x25
  8008d2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	eb 03                	jmp    8008dc <vprintfmt+0x3ba>
  8008d9:	83 ef 01             	sub    $0x1,%edi
  8008dc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008e0:	75 f7                	jne    8008d9 <vprintfmt+0x3b7>
  8008e2:	e9 61 fc ff ff       	jmp    800548 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5f                   	pop    %edi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	83 ec 18             	sub    $0x18,%esp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800902:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800905:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80090c:	85 c0                	test   %eax,%eax
  80090e:	74 26                	je     800936 <vsnprintf+0x47>
  800910:	85 d2                	test   %edx,%edx
  800912:	7e 22                	jle    800936 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800914:	ff 75 14             	pushl  0x14(%ebp)
  800917:	ff 75 10             	pushl  0x10(%ebp)
  80091a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80091d:	50                   	push   %eax
  80091e:	68 e8 04 80 00       	push   $0x8004e8
  800923:	e8 fa fb ff ff       	call   800522 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800928:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	eb 05                	jmp    80093b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800936:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800943:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800946:	50                   	push   %eax
  800947:	ff 75 10             	pushl  0x10(%ebp)
  80094a:	ff 75 0c             	pushl  0xc(%ebp)
  80094d:	ff 75 08             	pushl  0x8(%ebp)
  800950:	e8 9a ff ff ff       	call   8008ef <vsnprintf>
	va_end(ap);

	return rc;
}
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80095d:	b8 00 00 00 00       	mov    $0x0,%eax
  800962:	eb 03                	jmp    800967 <strlen+0x10>
		n++;
  800964:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800967:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80096b:	75 f7                	jne    800964 <strlen+0xd>
		n++;
	return n;
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
  80097d:	eb 03                	jmp    800982 <strnlen+0x13>
		n++;
  80097f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800982:	39 c2                	cmp    %eax,%edx
  800984:	74 08                	je     80098e <strnlen+0x1f>
  800986:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80098a:	75 f3                	jne    80097f <strnlen+0x10>
  80098c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80099a:	89 c2                	mov    %eax,%edx
  80099c:	83 c2 01             	add    $0x1,%edx
  80099f:	83 c1 01             	add    $0x1,%ecx
  8009a2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009a6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a9:	84 db                	test   %bl,%bl
  8009ab:	75 ef                	jne    80099c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ad:	5b                   	pop    %ebx
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	53                   	push   %ebx
  8009b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b7:	53                   	push   %ebx
  8009b8:	e8 9a ff ff ff       	call   800957 <strlen>
  8009bd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009c0:	ff 75 0c             	pushl  0xc(%ebp)
  8009c3:	01 d8                	add    %ebx,%eax
  8009c5:	50                   	push   %eax
  8009c6:	e8 c5 ff ff ff       	call   800990 <strcpy>
	return dst;
}
  8009cb:	89 d8                	mov    %ebx,%eax
  8009cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e2:	89 f2                	mov    %esi,%edx
  8009e4:	eb 0f                	jmp    8009f5 <strncpy+0x23>
		*dst++ = *src;
  8009e6:	83 c2 01             	add    $0x1,%edx
  8009e9:	0f b6 01             	movzbl (%ecx),%eax
  8009ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8009f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f5:	39 da                	cmp    %ebx,%edx
  8009f7:	75 ed                	jne    8009e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009f9:	89 f0                	mov    %esi,%eax
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 75 08             	mov    0x8(%ebp),%esi
  800a07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0a:	8b 55 10             	mov    0x10(%ebp),%edx
  800a0d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a0f:	85 d2                	test   %edx,%edx
  800a11:	74 21                	je     800a34 <strlcpy+0x35>
  800a13:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a17:	89 f2                	mov    %esi,%edx
  800a19:	eb 09                	jmp    800a24 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a1b:	83 c2 01             	add    $0x1,%edx
  800a1e:	83 c1 01             	add    $0x1,%ecx
  800a21:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a24:	39 c2                	cmp    %eax,%edx
  800a26:	74 09                	je     800a31 <strlcpy+0x32>
  800a28:	0f b6 19             	movzbl (%ecx),%ebx
  800a2b:	84 db                	test   %bl,%bl
  800a2d:	75 ec                	jne    800a1b <strlcpy+0x1c>
  800a2f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a31:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a34:	29 f0                	sub    %esi,%eax
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a40:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a43:	eb 06                	jmp    800a4b <strcmp+0x11>
		p++, q++;
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a4b:	0f b6 01             	movzbl (%ecx),%eax
  800a4e:	84 c0                	test   %al,%al
  800a50:	74 04                	je     800a56 <strcmp+0x1c>
  800a52:	3a 02                	cmp    (%edx),%al
  800a54:	74 ef                	je     800a45 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a56:	0f b6 c0             	movzbl %al,%eax
  800a59:	0f b6 12             	movzbl (%edx),%edx
  800a5c:	29 d0                	sub    %edx,%eax
}
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	53                   	push   %ebx
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6a:	89 c3                	mov    %eax,%ebx
  800a6c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a6f:	eb 06                	jmp    800a77 <strncmp+0x17>
		n--, p++, q++;
  800a71:	83 c0 01             	add    $0x1,%eax
  800a74:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a77:	39 d8                	cmp    %ebx,%eax
  800a79:	74 15                	je     800a90 <strncmp+0x30>
  800a7b:	0f b6 08             	movzbl (%eax),%ecx
  800a7e:	84 c9                	test   %cl,%cl
  800a80:	74 04                	je     800a86 <strncmp+0x26>
  800a82:	3a 0a                	cmp    (%edx),%cl
  800a84:	74 eb                	je     800a71 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a86:	0f b6 00             	movzbl (%eax),%eax
  800a89:	0f b6 12             	movzbl (%edx),%edx
  800a8c:	29 d0                	sub    %edx,%eax
  800a8e:	eb 05                	jmp    800a95 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a90:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a95:	5b                   	pop    %ebx
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa2:	eb 07                	jmp    800aab <strchr+0x13>
		if (*s == c)
  800aa4:	38 ca                	cmp    %cl,%dl
  800aa6:	74 0f                	je     800ab7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	0f b6 10             	movzbl (%eax),%edx
  800aae:	84 d2                	test   %dl,%dl
  800ab0:	75 f2                	jne    800aa4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac3:	eb 03                	jmp    800ac8 <strfind+0xf>
  800ac5:	83 c0 01             	add    $0x1,%eax
  800ac8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800acb:	38 ca                	cmp    %cl,%dl
  800acd:	74 04                	je     800ad3 <strfind+0x1a>
  800acf:	84 d2                	test   %dl,%dl
  800ad1:	75 f2                	jne    800ac5 <strfind+0xc>
			break;
	return (char *) s;
}
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	57                   	push   %edi
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae1:	85 c9                	test   %ecx,%ecx
  800ae3:	74 36                	je     800b1b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aeb:	75 28                	jne    800b15 <memset+0x40>
  800aed:	f6 c1 03             	test   $0x3,%cl
  800af0:	75 23                	jne    800b15 <memset+0x40>
		c &= 0xFF;
  800af2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af6:	89 d3                	mov    %edx,%ebx
  800af8:	c1 e3 08             	shl    $0x8,%ebx
  800afb:	89 d6                	mov    %edx,%esi
  800afd:	c1 e6 18             	shl    $0x18,%esi
  800b00:	89 d0                	mov    %edx,%eax
  800b02:	c1 e0 10             	shl    $0x10,%eax
  800b05:	09 f0                	or     %esi,%eax
  800b07:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b09:	89 d8                	mov    %ebx,%eax
  800b0b:	09 d0                	or     %edx,%eax
  800b0d:	c1 e9 02             	shr    $0x2,%ecx
  800b10:	fc                   	cld    
  800b11:	f3 ab                	rep stos %eax,%es:(%edi)
  800b13:	eb 06                	jmp    800b1b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b18:	fc                   	cld    
  800b19:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b1b:	89 f8                	mov    %edi,%eax
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b30:	39 c6                	cmp    %eax,%esi
  800b32:	73 35                	jae    800b69 <memmove+0x47>
  800b34:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b37:	39 d0                	cmp    %edx,%eax
  800b39:	73 2e                	jae    800b69 <memmove+0x47>
		s += n;
		d += n;
  800b3b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3e:	89 d6                	mov    %edx,%esi
  800b40:	09 fe                	or     %edi,%esi
  800b42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b48:	75 13                	jne    800b5d <memmove+0x3b>
  800b4a:	f6 c1 03             	test   $0x3,%cl
  800b4d:	75 0e                	jne    800b5d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b4f:	83 ef 04             	sub    $0x4,%edi
  800b52:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b55:	c1 e9 02             	shr    $0x2,%ecx
  800b58:	fd                   	std    
  800b59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5b:	eb 09                	jmp    800b66 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5d:	83 ef 01             	sub    $0x1,%edi
  800b60:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b63:	fd                   	std    
  800b64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b66:	fc                   	cld    
  800b67:	eb 1d                	jmp    800b86 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b69:	89 f2                	mov    %esi,%edx
  800b6b:	09 c2                	or     %eax,%edx
  800b6d:	f6 c2 03             	test   $0x3,%dl
  800b70:	75 0f                	jne    800b81 <memmove+0x5f>
  800b72:	f6 c1 03             	test   $0x3,%cl
  800b75:	75 0a                	jne    800b81 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b77:	c1 e9 02             	shr    $0x2,%ecx
  800b7a:	89 c7                	mov    %eax,%edi
  800b7c:	fc                   	cld    
  800b7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7f:	eb 05                	jmp    800b86 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b81:	89 c7                	mov    %eax,%edi
  800b83:	fc                   	cld    
  800b84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b8d:	ff 75 10             	pushl  0x10(%ebp)
  800b90:	ff 75 0c             	pushl  0xc(%ebp)
  800b93:	ff 75 08             	pushl  0x8(%ebp)
  800b96:	e8 87 ff ff ff       	call   800b22 <memmove>
}
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba8:	89 c6                	mov    %eax,%esi
  800baa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bad:	eb 1a                	jmp    800bc9 <memcmp+0x2c>
		if (*s1 != *s2)
  800baf:	0f b6 08             	movzbl (%eax),%ecx
  800bb2:	0f b6 1a             	movzbl (%edx),%ebx
  800bb5:	38 d9                	cmp    %bl,%cl
  800bb7:	74 0a                	je     800bc3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bb9:	0f b6 c1             	movzbl %cl,%eax
  800bbc:	0f b6 db             	movzbl %bl,%ebx
  800bbf:	29 d8                	sub    %ebx,%eax
  800bc1:	eb 0f                	jmp    800bd2 <memcmp+0x35>
		s1++, s2++;
  800bc3:	83 c0 01             	add    $0x1,%eax
  800bc6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc9:	39 f0                	cmp    %esi,%eax
  800bcb:	75 e2                	jne    800baf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	53                   	push   %ebx
  800bda:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bdd:	89 c1                	mov    %eax,%ecx
  800bdf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800be2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be6:	eb 0a                	jmp    800bf2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be8:	0f b6 10             	movzbl (%eax),%edx
  800beb:	39 da                	cmp    %ebx,%edx
  800bed:	74 07                	je     800bf6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bef:	83 c0 01             	add    $0x1,%eax
  800bf2:	39 c8                	cmp    %ecx,%eax
  800bf4:	72 f2                	jb     800be8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c05:	eb 03                	jmp    800c0a <strtol+0x11>
		s++;
  800c07:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0a:	0f b6 01             	movzbl (%ecx),%eax
  800c0d:	3c 20                	cmp    $0x20,%al
  800c0f:	74 f6                	je     800c07 <strtol+0xe>
  800c11:	3c 09                	cmp    $0x9,%al
  800c13:	74 f2                	je     800c07 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c15:	3c 2b                	cmp    $0x2b,%al
  800c17:	75 0a                	jne    800c23 <strtol+0x2a>
		s++;
  800c19:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c21:	eb 11                	jmp    800c34 <strtol+0x3b>
  800c23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c28:	3c 2d                	cmp    $0x2d,%al
  800c2a:	75 08                	jne    800c34 <strtol+0x3b>
		s++, neg = 1;
  800c2c:	83 c1 01             	add    $0x1,%ecx
  800c2f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c3a:	75 15                	jne    800c51 <strtol+0x58>
  800c3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3f:	75 10                	jne    800c51 <strtol+0x58>
  800c41:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c45:	75 7c                	jne    800cc3 <strtol+0xca>
		s += 2, base = 16;
  800c47:	83 c1 02             	add    $0x2,%ecx
  800c4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c4f:	eb 16                	jmp    800c67 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c51:	85 db                	test   %ebx,%ebx
  800c53:	75 12                	jne    800c67 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c55:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c5d:	75 08                	jne    800c67 <strtol+0x6e>
		s++, base = 8;
  800c5f:	83 c1 01             	add    $0x1,%ecx
  800c62:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c6f:	0f b6 11             	movzbl (%ecx),%edx
  800c72:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c75:	89 f3                	mov    %esi,%ebx
  800c77:	80 fb 09             	cmp    $0x9,%bl
  800c7a:	77 08                	ja     800c84 <strtol+0x8b>
			dig = *s - '0';
  800c7c:	0f be d2             	movsbl %dl,%edx
  800c7f:	83 ea 30             	sub    $0x30,%edx
  800c82:	eb 22                	jmp    800ca6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c84:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c87:	89 f3                	mov    %esi,%ebx
  800c89:	80 fb 19             	cmp    $0x19,%bl
  800c8c:	77 08                	ja     800c96 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c8e:	0f be d2             	movsbl %dl,%edx
  800c91:	83 ea 57             	sub    $0x57,%edx
  800c94:	eb 10                	jmp    800ca6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c96:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c99:	89 f3                	mov    %esi,%ebx
  800c9b:	80 fb 19             	cmp    $0x19,%bl
  800c9e:	77 16                	ja     800cb6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ca0:	0f be d2             	movsbl %dl,%edx
  800ca3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ca6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ca9:	7d 0b                	jge    800cb6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cab:	83 c1 01             	add    $0x1,%ecx
  800cae:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cb2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cb4:	eb b9                	jmp    800c6f <strtol+0x76>

	if (endptr)
  800cb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cba:	74 0d                	je     800cc9 <strtol+0xd0>
		*endptr = (char *) s;
  800cbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbf:	89 0e                	mov    %ecx,(%esi)
  800cc1:	eb 06                	jmp    800cc9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc3:	85 db                	test   %ebx,%ebx
  800cc5:	74 98                	je     800c5f <strtol+0x66>
  800cc7:	eb 9e                	jmp    800c67 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cc9:	89 c2                	mov    %eax,%edx
  800ccb:	f7 da                	neg    %edx
  800ccd:	85 ff                	test   %edi,%edi
  800ccf:	0f 45 c2             	cmovne %edx,%eax
}
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	89 c3                	mov    %eax,%ebx
  800cea:	89 c7                	mov    %eax,%edi
  800cec:	89 c6                	mov    %eax,%esi
  800cee:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800d00:	b8 01 00 00 00       	mov    $0x1,%eax
  800d05:	89 d1                	mov    %edx,%ecx
  800d07:	89 d3                	mov    %edx,%ebx
  800d09:	89 d7                	mov    %edx,%edi
  800d0b:	89 d6                	mov    %edx,%esi
  800d0d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d22:	b8 03 00 00 00       	mov    $0x3,%eax
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 cb                	mov    %ecx,%ebx
  800d2c:	89 cf                	mov    %ecx,%edi
  800d2e:	89 ce                	mov    %ecx,%esi
  800d30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 03                	push   $0x3
  800d3c:	68 5f 2d 80 00       	push   $0x802d5f
  800d41:	6a 23                	push   $0x23
  800d43:	68 7c 2d 80 00       	push   $0x802d7c
  800d48:	e8 c5 f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d60:	b8 02 00 00 00       	mov    $0x2,%eax
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	89 d3                	mov    %edx,%ebx
  800d69:	89 d7                	mov    %edx,%edi
  800d6b:	89 d6                	mov    %edx,%esi
  800d6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_yield>:

void
sys_yield(void)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d84:	89 d1                	mov    %edx,%ecx
  800d86:	89 d3                	mov    %edx,%ebx
  800d88:	89 d7                	mov    %edx,%edi
  800d8a:	89 d6                	mov    %edx,%esi
  800d8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9c:	be 00 00 00 00       	mov    $0x0,%esi
  800da1:	b8 04 00 00 00       	mov    $0x4,%eax
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daf:	89 f7                	mov    %esi,%edi
  800db1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7e 17                	jle    800dce <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db7:	83 ec 0c             	sub    $0xc,%esp
  800dba:	50                   	push   %eax
  800dbb:	6a 04                	push   $0x4
  800dbd:	68 5f 2d 80 00       	push   $0x802d5f
  800dc2:	6a 23                	push   $0x23
  800dc4:	68 7c 2d 80 00       	push   $0x802d7c
  800dc9:	e8 44 f5 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
  800ddc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddf:	b8 05 00 00 00       	mov    $0x5,%eax
  800de4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ded:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df0:	8b 75 18             	mov    0x18(%ebp),%esi
  800df3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df5:	85 c0                	test   %eax,%eax
  800df7:	7e 17                	jle    800e10 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df9:	83 ec 0c             	sub    $0xc,%esp
  800dfc:	50                   	push   %eax
  800dfd:	6a 05                	push   $0x5
  800dff:	68 5f 2d 80 00       	push   $0x802d5f
  800e04:	6a 23                	push   $0x23
  800e06:	68 7c 2d 80 00       	push   $0x802d7c
  800e0b:	e8 02 f5 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
  800e1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e26:	b8 06 00 00 00       	mov    $0x6,%eax
  800e2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e31:	89 df                	mov    %ebx,%edi
  800e33:	89 de                	mov    %ebx,%esi
  800e35:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e37:	85 c0                	test   %eax,%eax
  800e39:	7e 17                	jle    800e52 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	50                   	push   %eax
  800e3f:	6a 06                	push   $0x6
  800e41:	68 5f 2d 80 00       	push   $0x802d5f
  800e46:	6a 23                	push   $0x23
  800e48:	68 7c 2d 80 00       	push   $0x802d7c
  800e4d:	e8 c0 f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e68:	b8 08 00 00 00       	mov    $0x8,%eax
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 df                	mov    %ebx,%edi
  800e75:	89 de                	mov    %ebx,%esi
  800e77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7e 17                	jle    800e94 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	83 ec 0c             	sub    $0xc,%esp
  800e80:	50                   	push   %eax
  800e81:	6a 08                	push   $0x8
  800e83:	68 5f 2d 80 00       	push   $0x802d5f
  800e88:	6a 23                	push   $0x23
  800e8a:	68 7c 2d 80 00       	push   $0x802d7c
  800e8f:	e8 7e f4 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
  800ea2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eaa:	b8 09 00 00 00       	mov    $0x9,%eax
  800eaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	89 df                	mov    %ebx,%edi
  800eb7:	89 de                	mov    %ebx,%esi
  800eb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	7e 17                	jle    800ed6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	50                   	push   %eax
  800ec3:	6a 09                	push   $0x9
  800ec5:	68 5f 2d 80 00       	push   $0x802d5f
  800eca:	6a 23                	push   $0x23
  800ecc:	68 7c 2d 80 00       	push   $0x802d7c
  800ed1:	e8 3c f4 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ed6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef7:	89 df                	mov    %ebx,%edi
  800ef9:	89 de                	mov    %ebx,%esi
  800efb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800efd:	85 c0                	test   %eax,%eax
  800eff:	7e 17                	jle    800f18 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f01:	83 ec 0c             	sub    $0xc,%esp
  800f04:	50                   	push   %eax
  800f05:	6a 0a                	push   $0xa
  800f07:	68 5f 2d 80 00       	push   $0x802d5f
  800f0c:	6a 23                	push   $0x23
  800f0e:	68 7c 2d 80 00       	push   $0x802d7c
  800f13:	e8 fa f3 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1b:	5b                   	pop    %ebx
  800f1c:	5e                   	pop    %esi
  800f1d:	5f                   	pop    %edi
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f26:	be 00 00 00 00       	mov    $0x0,%esi
  800f2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f33:	8b 55 08             	mov    0x8(%ebp),%edx
  800f36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f3c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	89 cb                	mov    %ecx,%ebx
  800f5b:	89 cf                	mov    %ecx,%edi
  800f5d:	89 ce                	mov    %ecx,%esi
  800f5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f61:	85 c0                	test   %eax,%eax
  800f63:	7e 17                	jle    800f7c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f65:	83 ec 0c             	sub    $0xc,%esp
  800f68:	50                   	push   %eax
  800f69:	6a 0d                	push   $0xd
  800f6b:	68 5f 2d 80 00       	push   $0x802d5f
  800f70:	6a 23                	push   $0x23
  800f72:	68 7c 2d 80 00       	push   $0x802d7c
  800f77:	e8 96 f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f94:	89 d1                	mov    %edx,%ecx
  800f96:	89 d3                	mov    %edx,%ebx
  800f98:	89 d7                	mov    %edx,%edi
  800f9a:	89 d6                	mov    %edx,%esi
  800f9c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	53                   	push   %ebx
  800fa7:	83 ec 04             	sub    $0x4,%esp
  800faa:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800fad:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800faf:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800fb2:	f6 c1 02             	test   $0x2,%cl
  800fb5:	74 2e                	je     800fe5 <pgfault+0x42>
  800fb7:	89 c2                	mov    %eax,%edx
  800fb9:	c1 ea 16             	shr    $0x16,%edx
  800fbc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc3:	f6 c2 01             	test   $0x1,%dl
  800fc6:	74 1d                	je     800fe5 <pgfault+0x42>
  800fc8:	89 c2                	mov    %eax,%edx
  800fca:	c1 ea 0c             	shr    $0xc,%edx
  800fcd:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800fd4:	f6 c3 01             	test   $0x1,%bl
  800fd7:	74 0c                	je     800fe5 <pgfault+0x42>
  800fd9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fe0:	f6 c6 08             	test   $0x8,%dh
  800fe3:	75 12                	jne    800ff7 <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800fe5:	51                   	push   %ecx
  800fe6:	68 8a 2d 80 00       	push   $0x802d8a
  800feb:	6a 1e                	push   $0x1e
  800fed:	68 a3 2d 80 00       	push   $0x802da3
  800ff2:	e8 1b f3 ff ff       	call   800312 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800ff7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ffc:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800ffe:	83 ec 04             	sub    $0x4,%esp
  801001:	6a 07                	push   $0x7
  801003:	68 00 f0 7f 00       	push   $0x7ff000
  801008:	6a 00                	push   $0x0
  80100a:	e8 84 fd ff ff       	call   800d93 <sys_page_alloc>
  80100f:	83 c4 10             	add    $0x10,%esp
  801012:	85 c0                	test   %eax,%eax
  801014:	79 12                	jns    801028 <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  801016:	50                   	push   %eax
  801017:	68 ae 2d 80 00       	push   $0x802dae
  80101c:	6a 29                	push   $0x29
  80101e:	68 a3 2d 80 00       	push   $0x802da3
  801023:	e8 ea f2 ff ff       	call   800312 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	68 00 10 00 00       	push   $0x1000
  801030:	53                   	push   %ebx
  801031:	68 00 f0 7f 00       	push   $0x7ff000
  801036:	e8 4f fb ff ff       	call   800b8a <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80103b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801042:	53                   	push   %ebx
  801043:	6a 00                	push   $0x0
  801045:	68 00 f0 7f 00       	push   $0x7ff000
  80104a:	6a 00                	push   $0x0
  80104c:	e8 85 fd ff ff       	call   800dd6 <sys_page_map>
  801051:	83 c4 20             	add    $0x20,%esp
  801054:	85 c0                	test   %eax,%eax
  801056:	79 12                	jns    80106a <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  801058:	50                   	push   %eax
  801059:	68 c9 2d 80 00       	push   $0x802dc9
  80105e:	6a 2e                	push   $0x2e
  801060:	68 a3 2d 80 00       	push   $0x802da3
  801065:	e8 a8 f2 ff ff       	call   800312 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  80106a:	83 ec 08             	sub    $0x8,%esp
  80106d:	68 00 f0 7f 00       	push   $0x7ff000
  801072:	6a 00                	push   $0x0
  801074:	e8 9f fd ff ff       	call   800e18 <sys_page_unmap>
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	85 c0                	test   %eax,%eax
  80107e:	79 12                	jns    801092 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  801080:	50                   	push   %eax
  801081:	68 e2 2d 80 00       	push   $0x802de2
  801086:	6a 31                	push   $0x31
  801088:	68 a3 2d 80 00       	push   $0x802da3
  80108d:	e8 80 f2 ff ff       	call   800312 <_panic>

}
  801092:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801095:	c9                   	leave  
  801096:	c3                   	ret    

00801097 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	57                   	push   %edi
  80109b:	56                   	push   %esi
  80109c:	53                   	push   %ebx
  80109d:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  8010a0:	68 a3 0f 80 00       	push   $0x800fa3
  8010a5:	e8 d1 13 00 00       	call   80247b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010aa:	b8 07 00 00 00       	mov    $0x7,%eax
  8010af:	cd 30                	int    $0x30
  8010b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	75 21                	jne    8010e4 <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010c3:	e8 8d fc ff ff       	call   800d55 <sys_getenvid>
  8010c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d5:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
  8010df:	e9 c9 01 00 00       	jmp    8012ad <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  8010e4:	89 d8                	mov    %ebx,%eax
  8010e6:	c1 e8 16             	shr    $0x16,%eax
  8010e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f0:	a8 01                	test   $0x1,%al
  8010f2:	0f 84 1b 01 00 00    	je     801213 <fork+0x17c>
  8010f8:	89 de                	mov    %ebx,%esi
  8010fa:	c1 ee 0c             	shr    $0xc,%esi
  8010fd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801104:	a8 01                	test   $0x1,%al
  801106:	0f 84 07 01 00 00    	je     801213 <fork+0x17c>
  80110c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801113:	a8 04                	test   $0x4,%al
  801115:	0f 84 f8 00 00 00    	je     801213 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  80111b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801122:	f6 c4 04             	test   $0x4,%ah
  801125:	74 3c                	je     801163 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  801127:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80112e:	c1 e6 0c             	shl    $0xc,%esi
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	25 07 0e 00 00       	and    $0xe07,%eax
  801139:	50                   	push   %eax
  80113a:	56                   	push   %esi
  80113b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113e:	56                   	push   %esi
  80113f:	6a 00                	push   $0x0
  801141:	e8 90 fc ff ff       	call   800dd6 <sys_page_map>
  801146:	83 c4 20             	add    $0x20,%esp
  801149:	85 c0                	test   %eax,%eax
  80114b:	0f 89 c2 00 00 00    	jns    801213 <fork+0x17c>
			panic("duppage: %e", r);
  801151:	50                   	push   %eax
  801152:	68 fd 2d 80 00       	push   $0x802dfd
  801157:	6a 48                	push   $0x48
  801159:	68 a3 2d 80 00       	push   $0x802da3
  80115e:	e8 af f1 ff ff       	call   800312 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  801163:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80116a:	f6 c4 08             	test   $0x8,%ah
  80116d:	75 0b                	jne    80117a <fork+0xe3>
  80116f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801176:	a8 02                	test   $0x2,%al
  801178:	74 6c                	je     8011e6 <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  80117a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801181:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  801184:	83 f8 01             	cmp    $0x1,%eax
  801187:	19 ff                	sbb    %edi,%edi
  801189:	83 e7 fc             	and    $0xfffffffc,%edi
  80118c:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  801192:	c1 e6 0c             	shl    $0xc,%esi
  801195:	83 ec 0c             	sub    $0xc,%esp
  801198:	57                   	push   %edi
  801199:	56                   	push   %esi
  80119a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119d:	56                   	push   %esi
  80119e:	6a 00                	push   $0x0
  8011a0:	e8 31 fc ff ff       	call   800dd6 <sys_page_map>
  8011a5:	83 c4 20             	add    $0x20,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	79 12                	jns    8011be <fork+0x127>
			panic("duppage: %e", r);
  8011ac:	50                   	push   %eax
  8011ad:	68 fd 2d 80 00       	push   $0x802dfd
  8011b2:	6a 50                	push   $0x50
  8011b4:	68 a3 2d 80 00       	push   $0x802da3
  8011b9:	e8 54 f1 ff ff       	call   800312 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  8011be:	83 ec 0c             	sub    $0xc,%esp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	6a 00                	push   $0x0
  8011c5:	56                   	push   %esi
  8011c6:	6a 00                	push   $0x0
  8011c8:	e8 09 fc ff ff       	call   800dd6 <sys_page_map>
  8011cd:	83 c4 20             	add    $0x20,%esp
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	79 3f                	jns    801213 <fork+0x17c>
			panic("duppage: %e", r);
  8011d4:	50                   	push   %eax
  8011d5:	68 fd 2d 80 00       	push   $0x802dfd
  8011da:	6a 53                	push   $0x53
  8011dc:	68 a3 2d 80 00       	push   $0x802da3
  8011e1:	e8 2c f1 ff ff       	call   800312 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  8011e6:	c1 e6 0c             	shl    $0xc,%esi
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	6a 05                	push   $0x5
  8011ee:	56                   	push   %esi
  8011ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f2:	56                   	push   %esi
  8011f3:	6a 00                	push   $0x0
  8011f5:	e8 dc fb ff ff       	call   800dd6 <sys_page_map>
  8011fa:	83 c4 20             	add    $0x20,%esp
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	79 12                	jns    801213 <fork+0x17c>
			panic("duppage: %e", r);
  801201:	50                   	push   %eax
  801202:	68 fd 2d 80 00       	push   $0x802dfd
  801207:	6a 57                	push   $0x57
  801209:	68 a3 2d 80 00       	push   $0x802da3
  80120e:	e8 ff f0 ff ff       	call   800312 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  801213:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801219:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80121f:	0f 85 bf fe ff ff    	jne    8010e4 <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  801225:	83 ec 04             	sub    $0x4,%esp
  801228:	6a 07                	push   $0x7
  80122a:	68 00 f0 bf ee       	push   $0xeebff000
  80122f:	ff 75 e0             	pushl  -0x20(%ebp)
  801232:	e8 5c fb ff ff       	call   800d93 <sys_page_alloc>
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	74 17                	je     801255 <fork+0x1be>
		panic("sys_page_alloc Error");
  80123e:	83 ec 04             	sub    $0x4,%esp
  801241:	68 09 2e 80 00       	push   $0x802e09
  801246:	68 83 00 00 00       	push   $0x83
  80124b:	68 a3 2d 80 00       	push   $0x802da3
  801250:	e8 bd f0 ff ff       	call   800312 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	68 ea 24 80 00       	push   $0x8024ea
  80125d:	ff 75 e0             	pushl  -0x20(%ebp)
  801260:	e8 79 fc ff ff       	call   800ede <sys_env_set_pgfault_upcall>
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	79 15                	jns    801281 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  80126c:	50                   	push   %eax
  80126d:	68 1e 2e 80 00       	push   $0x802e1e
  801272:	68 86 00 00 00       	push   $0x86
  801277:	68 a3 2d 80 00       	push   $0x802da3
  80127c:	e8 91 f0 ff ff       	call   800312 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	6a 02                	push   $0x2
  801286:	ff 75 e0             	pushl  -0x20(%ebp)
  801289:	e8 cc fb ff ff       	call   800e5a <sys_env_set_status>
  80128e:	83 c4 10             	add    $0x10,%esp
  801291:	85 c0                	test   %eax,%eax
  801293:	79 15                	jns    8012aa <fork+0x213>
		panic("fork set status: %e", r);
  801295:	50                   	push   %eax
  801296:	68 36 2e 80 00       	push   $0x802e36
  80129b:	68 89 00 00 00       	push   $0x89
  8012a0:	68 a3 2d 80 00       	push   $0x802da3
  8012a5:	e8 68 f0 ff ff       	call   800312 <_panic>
	
	return envid;
  8012aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8012ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <sfork>:


// Challenge!
int
sfork(void)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012bb:	68 4a 2e 80 00       	push   $0x802e4a
  8012c0:	68 93 00 00 00       	push   $0x93
  8012c5:	68 a3 2d 80 00       	push   $0x802da3
  8012ca:	e8 43 f0 ff ff       	call   800312 <_panic>

008012cf <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d5:	05 00 00 00 30       	add    $0x30000000,%eax
  8012da:	c1 e8 0c             	shr    $0xc,%eax
}
  8012dd:	5d                   	pop    %ebp
  8012de:	c3                   	ret    

008012df <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e5:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012ef:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801301:	89 c2                	mov    %eax,%edx
  801303:	c1 ea 16             	shr    $0x16,%edx
  801306:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80130d:	f6 c2 01             	test   $0x1,%dl
  801310:	74 11                	je     801323 <fd_alloc+0x2d>
  801312:	89 c2                	mov    %eax,%edx
  801314:	c1 ea 0c             	shr    $0xc,%edx
  801317:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80131e:	f6 c2 01             	test   $0x1,%dl
  801321:	75 09                	jne    80132c <fd_alloc+0x36>
			*fd_store = fd;
  801323:	89 01                	mov    %eax,(%ecx)
			return 0;
  801325:	b8 00 00 00 00       	mov    $0x0,%eax
  80132a:	eb 17                	jmp    801343 <fd_alloc+0x4d>
  80132c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801331:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801336:	75 c9                	jne    801301 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801338:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80133e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80134b:	83 f8 1f             	cmp    $0x1f,%eax
  80134e:	77 36                	ja     801386 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801350:	c1 e0 0c             	shl    $0xc,%eax
  801353:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801358:	89 c2                	mov    %eax,%edx
  80135a:	c1 ea 16             	shr    $0x16,%edx
  80135d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801364:	f6 c2 01             	test   $0x1,%dl
  801367:	74 24                	je     80138d <fd_lookup+0x48>
  801369:	89 c2                	mov    %eax,%edx
  80136b:	c1 ea 0c             	shr    $0xc,%edx
  80136e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801375:	f6 c2 01             	test   $0x1,%dl
  801378:	74 1a                	je     801394 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80137a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137d:	89 02                	mov    %eax,(%edx)
	return 0;
  80137f:	b8 00 00 00 00       	mov    $0x0,%eax
  801384:	eb 13                	jmp    801399 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801386:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138b:	eb 0c                	jmp    801399 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80138d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801392:	eb 05                	jmp    801399 <fd_lookup+0x54>
  801394:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a4:	ba e0 2e 80 00       	mov    $0x802ee0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013a9:	eb 13                	jmp    8013be <dev_lookup+0x23>
  8013ab:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ae:	39 08                	cmp    %ecx,(%eax)
  8013b0:	75 0c                	jne    8013be <dev_lookup+0x23>
			*dev = devtab[i];
  8013b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bc:	eb 2e                	jmp    8013ec <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013be:	8b 02                	mov    (%edx),%eax
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	75 e7                	jne    8013ab <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013c4:	a1 08 40 80 00       	mov    0x804008,%eax
  8013c9:	8b 40 48             	mov    0x48(%eax),%eax
  8013cc:	83 ec 04             	sub    $0x4,%esp
  8013cf:	51                   	push   %ecx
  8013d0:	50                   	push   %eax
  8013d1:	68 60 2e 80 00       	push   $0x802e60
  8013d6:	e8 10 f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  8013db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 10             	sub    $0x10,%esp
  8013f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ff:	50                   	push   %eax
  801400:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801406:	c1 e8 0c             	shr    $0xc,%eax
  801409:	50                   	push   %eax
  80140a:	e8 36 ff ff ff       	call   801345 <fd_lookup>
  80140f:	83 c4 08             	add    $0x8,%esp
  801412:	85 c0                	test   %eax,%eax
  801414:	78 05                	js     80141b <fd_close+0x2d>
	    || fd != fd2)
  801416:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801419:	74 0c                	je     801427 <fd_close+0x39>
		return (must_exist ? r : 0);
  80141b:	84 db                	test   %bl,%bl
  80141d:	ba 00 00 00 00       	mov    $0x0,%edx
  801422:	0f 44 c2             	cmove  %edx,%eax
  801425:	eb 41                	jmp    801468 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	ff 36                	pushl  (%esi)
  801430:	e8 66 ff ff ff       	call   80139b <dev_lookup>
  801435:	89 c3                	mov    %eax,%ebx
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 1a                	js     801458 <fd_close+0x6a>
		if (dev->dev_close)
  80143e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801441:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801444:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801449:	85 c0                	test   %eax,%eax
  80144b:	74 0b                	je     801458 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80144d:	83 ec 0c             	sub    $0xc,%esp
  801450:	56                   	push   %esi
  801451:	ff d0                	call   *%eax
  801453:	89 c3                	mov    %eax,%ebx
  801455:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	56                   	push   %esi
  80145c:	6a 00                	push   $0x0
  80145e:	e8 b5 f9 ff ff       	call   800e18 <sys_page_unmap>
	return r;
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	89 d8                	mov    %ebx,%eax
}
  801468:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146b:	5b                   	pop    %ebx
  80146c:	5e                   	pop    %esi
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    

0080146f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801475:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801478:	50                   	push   %eax
  801479:	ff 75 08             	pushl  0x8(%ebp)
  80147c:	e8 c4 fe ff ff       	call   801345 <fd_lookup>
  801481:	83 c4 08             	add    $0x8,%esp
  801484:	85 c0                	test   %eax,%eax
  801486:	78 10                	js     801498 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	6a 01                	push   $0x1
  80148d:	ff 75 f4             	pushl  -0xc(%ebp)
  801490:	e8 59 ff ff ff       	call   8013ee <fd_close>
  801495:	83 c4 10             	add    $0x10,%esp
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <close_all>:

void
close_all(void)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	53                   	push   %ebx
  80149e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014a6:	83 ec 0c             	sub    $0xc,%esp
  8014a9:	53                   	push   %ebx
  8014aa:	e8 c0 ff ff ff       	call   80146f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014af:	83 c3 01             	add    $0x1,%ebx
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	83 fb 20             	cmp    $0x20,%ebx
  8014b8:	75 ec                	jne    8014a6 <close_all+0xc>
		close(i);
}
  8014ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	57                   	push   %edi
  8014c3:	56                   	push   %esi
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 2c             	sub    $0x2c,%esp
  8014c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ce:	50                   	push   %eax
  8014cf:	ff 75 08             	pushl  0x8(%ebp)
  8014d2:	e8 6e fe ff ff       	call   801345 <fd_lookup>
  8014d7:	83 c4 08             	add    $0x8,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	0f 88 c1 00 00 00    	js     8015a3 <dup+0xe4>
		return r;
	close(newfdnum);
  8014e2:	83 ec 0c             	sub    $0xc,%esp
  8014e5:	56                   	push   %esi
  8014e6:	e8 84 ff ff ff       	call   80146f <close>

	newfd = INDEX2FD(newfdnum);
  8014eb:	89 f3                	mov    %esi,%ebx
  8014ed:	c1 e3 0c             	shl    $0xc,%ebx
  8014f0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014f6:	83 c4 04             	add    $0x4,%esp
  8014f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014fc:	e8 de fd ff ff       	call   8012df <fd2data>
  801501:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801503:	89 1c 24             	mov    %ebx,(%esp)
  801506:	e8 d4 fd ff ff       	call   8012df <fd2data>
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801511:	89 f8                	mov    %edi,%eax
  801513:	c1 e8 16             	shr    $0x16,%eax
  801516:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80151d:	a8 01                	test   $0x1,%al
  80151f:	74 37                	je     801558 <dup+0x99>
  801521:	89 f8                	mov    %edi,%eax
  801523:	c1 e8 0c             	shr    $0xc,%eax
  801526:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80152d:	f6 c2 01             	test   $0x1,%dl
  801530:	74 26                	je     801558 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801532:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801539:	83 ec 0c             	sub    $0xc,%esp
  80153c:	25 07 0e 00 00       	and    $0xe07,%eax
  801541:	50                   	push   %eax
  801542:	ff 75 d4             	pushl  -0x2c(%ebp)
  801545:	6a 00                	push   $0x0
  801547:	57                   	push   %edi
  801548:	6a 00                	push   $0x0
  80154a:	e8 87 f8 ff ff       	call   800dd6 <sys_page_map>
  80154f:	89 c7                	mov    %eax,%edi
  801551:	83 c4 20             	add    $0x20,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 2e                	js     801586 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801558:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80155b:	89 d0                	mov    %edx,%eax
  80155d:	c1 e8 0c             	shr    $0xc,%eax
  801560:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801567:	83 ec 0c             	sub    $0xc,%esp
  80156a:	25 07 0e 00 00       	and    $0xe07,%eax
  80156f:	50                   	push   %eax
  801570:	53                   	push   %ebx
  801571:	6a 00                	push   $0x0
  801573:	52                   	push   %edx
  801574:	6a 00                	push   $0x0
  801576:	e8 5b f8 ff ff       	call   800dd6 <sys_page_map>
  80157b:	89 c7                	mov    %eax,%edi
  80157d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801580:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801582:	85 ff                	test   %edi,%edi
  801584:	79 1d                	jns    8015a3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	53                   	push   %ebx
  80158a:	6a 00                	push   $0x0
  80158c:	e8 87 f8 ff ff       	call   800e18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	ff 75 d4             	pushl  -0x2c(%ebp)
  801597:	6a 00                	push   $0x0
  801599:	e8 7a f8 ff ff       	call   800e18 <sys_page_unmap>
	return r;
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	89 f8                	mov    %edi,%eax
}
  8015a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a6:	5b                   	pop    %ebx
  8015a7:	5e                   	pop    %esi
  8015a8:	5f                   	pop    %edi
  8015a9:	5d                   	pop    %ebp
  8015aa:	c3                   	ret    

008015ab <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 14             	sub    $0x14,%esp
  8015b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	53                   	push   %ebx
  8015ba:	e8 86 fd ff ff       	call   801345 <fd_lookup>
  8015bf:	83 c4 08             	add    $0x8,%esp
  8015c2:	89 c2                	mov    %eax,%edx
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 6d                	js     801635 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ce:	50                   	push   %eax
  8015cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d2:	ff 30                	pushl  (%eax)
  8015d4:	e8 c2 fd ff ff       	call   80139b <dev_lookup>
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 4c                	js     80162c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e3:	8b 42 08             	mov    0x8(%edx),%eax
  8015e6:	83 e0 03             	and    $0x3,%eax
  8015e9:	83 f8 01             	cmp    $0x1,%eax
  8015ec:	75 21                	jne    80160f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8015f3:	8b 40 48             	mov    0x48(%eax),%eax
  8015f6:	83 ec 04             	sub    $0x4,%esp
  8015f9:	53                   	push   %ebx
  8015fa:	50                   	push   %eax
  8015fb:	68 a4 2e 80 00       	push   $0x802ea4
  801600:	e8 e6 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80160d:	eb 26                	jmp    801635 <read+0x8a>
	}
	if (!dev->dev_read)
  80160f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801612:	8b 40 08             	mov    0x8(%eax),%eax
  801615:	85 c0                	test   %eax,%eax
  801617:	74 17                	je     801630 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801619:	83 ec 04             	sub    $0x4,%esp
  80161c:	ff 75 10             	pushl  0x10(%ebp)
  80161f:	ff 75 0c             	pushl  0xc(%ebp)
  801622:	52                   	push   %edx
  801623:	ff d0                	call   *%eax
  801625:	89 c2                	mov    %eax,%edx
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	eb 09                	jmp    801635 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	eb 05                	jmp    801635 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801630:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801635:	89 d0                	mov    %edx,%eax
  801637:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	57                   	push   %edi
  801640:	56                   	push   %esi
  801641:	53                   	push   %ebx
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	8b 7d 08             	mov    0x8(%ebp),%edi
  801648:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801650:	eb 21                	jmp    801673 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801652:	83 ec 04             	sub    $0x4,%esp
  801655:	89 f0                	mov    %esi,%eax
  801657:	29 d8                	sub    %ebx,%eax
  801659:	50                   	push   %eax
  80165a:	89 d8                	mov    %ebx,%eax
  80165c:	03 45 0c             	add    0xc(%ebp),%eax
  80165f:	50                   	push   %eax
  801660:	57                   	push   %edi
  801661:	e8 45 ff ff ff       	call   8015ab <read>
		if (m < 0)
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	85 c0                	test   %eax,%eax
  80166b:	78 10                	js     80167d <readn+0x41>
			return m;
		if (m == 0)
  80166d:	85 c0                	test   %eax,%eax
  80166f:	74 0a                	je     80167b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801671:	01 c3                	add    %eax,%ebx
  801673:	39 f3                	cmp    %esi,%ebx
  801675:	72 db                	jb     801652 <readn+0x16>
  801677:	89 d8                	mov    %ebx,%eax
  801679:	eb 02                	jmp    80167d <readn+0x41>
  80167b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80167d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801680:	5b                   	pop    %ebx
  801681:	5e                   	pop    %esi
  801682:	5f                   	pop    %edi
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    

00801685 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	53                   	push   %ebx
  801689:	83 ec 14             	sub    $0x14,%esp
  80168c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	53                   	push   %ebx
  801694:	e8 ac fc ff ff       	call   801345 <fd_lookup>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	89 c2                	mov    %eax,%edx
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 68                	js     80170a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ac:	ff 30                	pushl  (%eax)
  8016ae:	e8 e8 fc ff ff       	call   80139b <dev_lookup>
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 47                	js     801701 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c1:	75 21                	jne    8016e4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8016c8:	8b 40 48             	mov    0x48(%eax),%eax
  8016cb:	83 ec 04             	sub    $0x4,%esp
  8016ce:	53                   	push   %ebx
  8016cf:	50                   	push   %eax
  8016d0:	68 c0 2e 80 00       	push   $0x802ec0
  8016d5:	e8 11 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e2:	eb 26                	jmp    80170a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e7:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ea:	85 d2                	test   %edx,%edx
  8016ec:	74 17                	je     801705 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016ee:	83 ec 04             	sub    $0x4,%esp
  8016f1:	ff 75 10             	pushl  0x10(%ebp)
  8016f4:	ff 75 0c             	pushl  0xc(%ebp)
  8016f7:	50                   	push   %eax
  8016f8:	ff d2                	call   *%edx
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	eb 09                	jmp    80170a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801701:	89 c2                	mov    %eax,%edx
  801703:	eb 05                	jmp    80170a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801705:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80170a:	89 d0                	mov    %edx,%eax
  80170c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <seek>:

int
seek(int fdnum, off_t offset)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801717:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80171a:	50                   	push   %eax
  80171b:	ff 75 08             	pushl  0x8(%ebp)
  80171e:	e8 22 fc ff ff       	call   801345 <fd_lookup>
  801723:	83 c4 08             	add    $0x8,%esp
  801726:	85 c0                	test   %eax,%eax
  801728:	78 0e                	js     801738 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80172a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80172d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801730:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801733:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	53                   	push   %ebx
  80173e:	83 ec 14             	sub    $0x14,%esp
  801741:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801744:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801747:	50                   	push   %eax
  801748:	53                   	push   %ebx
  801749:	e8 f7 fb ff ff       	call   801345 <fd_lookup>
  80174e:	83 c4 08             	add    $0x8,%esp
  801751:	89 c2                	mov    %eax,%edx
  801753:	85 c0                	test   %eax,%eax
  801755:	78 65                	js     8017bc <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175d:	50                   	push   %eax
  80175e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801761:	ff 30                	pushl  (%eax)
  801763:	e8 33 fc ff ff       	call   80139b <dev_lookup>
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 44                	js     8017b3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80176f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801772:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801776:	75 21                	jne    801799 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801778:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80177d:	8b 40 48             	mov    0x48(%eax),%eax
  801780:	83 ec 04             	sub    $0x4,%esp
  801783:	53                   	push   %ebx
  801784:	50                   	push   %eax
  801785:	68 80 2e 80 00       	push   $0x802e80
  80178a:	e8 5c ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80178f:	83 c4 10             	add    $0x10,%esp
  801792:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801797:	eb 23                	jmp    8017bc <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801799:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179c:	8b 52 18             	mov    0x18(%edx),%edx
  80179f:	85 d2                	test   %edx,%edx
  8017a1:	74 14                	je     8017b7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	ff 75 0c             	pushl  0xc(%ebp)
  8017a9:	50                   	push   %eax
  8017aa:	ff d2                	call   *%edx
  8017ac:	89 c2                	mov    %eax,%edx
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	eb 09                	jmp    8017bc <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b3:	89 c2                	mov    %eax,%edx
  8017b5:	eb 05                	jmp    8017bc <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017bc:	89 d0                	mov    %edx,%eax
  8017be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 14             	sub    $0x14,%esp
  8017ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d0:	50                   	push   %eax
  8017d1:	ff 75 08             	pushl  0x8(%ebp)
  8017d4:	e8 6c fb ff ff       	call   801345 <fd_lookup>
  8017d9:	83 c4 08             	add    $0x8,%esp
  8017dc:	89 c2                	mov    %eax,%edx
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 58                	js     80183a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e8:	50                   	push   %eax
  8017e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ec:	ff 30                	pushl  (%eax)
  8017ee:	e8 a8 fb ff ff       	call   80139b <dev_lookup>
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 37                	js     801831 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801801:	74 32                	je     801835 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801803:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801806:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80180d:	00 00 00 
	stat->st_isdir = 0;
  801810:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801817:	00 00 00 
	stat->st_dev = dev;
  80181a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801820:	83 ec 08             	sub    $0x8,%esp
  801823:	53                   	push   %ebx
  801824:	ff 75 f0             	pushl  -0x10(%ebp)
  801827:	ff 50 14             	call   *0x14(%eax)
  80182a:	89 c2                	mov    %eax,%edx
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	eb 09                	jmp    80183a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801831:	89 c2                	mov    %eax,%edx
  801833:	eb 05                	jmp    80183a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801835:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80183a:	89 d0                	mov    %edx,%eax
  80183c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	56                   	push   %esi
  801845:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	6a 00                	push   $0x0
  80184b:	ff 75 08             	pushl  0x8(%ebp)
  80184e:	e8 ef 01 00 00       	call   801a42 <open>
  801853:	89 c3                	mov    %eax,%ebx
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 1b                	js     801877 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80185c:	83 ec 08             	sub    $0x8,%esp
  80185f:	ff 75 0c             	pushl  0xc(%ebp)
  801862:	50                   	push   %eax
  801863:	e8 5b ff ff ff       	call   8017c3 <fstat>
  801868:	89 c6                	mov    %eax,%esi
	close(fd);
  80186a:	89 1c 24             	mov    %ebx,(%esp)
  80186d:	e8 fd fb ff ff       	call   80146f <close>
	return r;
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	89 f0                	mov    %esi,%eax
}
  801877:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	56                   	push   %esi
  801882:	53                   	push   %ebx
  801883:	89 c6                	mov    %eax,%esi
  801885:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801887:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80188e:	75 12                	jne    8018a2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801890:	83 ec 0c             	sub    $0xc,%esp
  801893:	6a 01                	push   $0x1
  801895:	e8 3c 0d 00 00       	call   8025d6 <ipc_find_env>
  80189a:	a3 00 40 80 00       	mov    %eax,0x804000
  80189f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018a2:	6a 07                	push   $0x7
  8018a4:	68 00 50 80 00       	push   $0x805000
  8018a9:	56                   	push   %esi
  8018aa:	ff 35 00 40 80 00    	pushl  0x804000
  8018b0:	e8 d2 0c 00 00       	call   802587 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018b5:	83 c4 0c             	add    $0xc,%esp
  8018b8:	6a 00                	push   $0x0
  8018ba:	53                   	push   %ebx
  8018bb:	6a 00                	push   $0x0
  8018bd:	e8 4f 0c 00 00       	call   802511 <ipc_recv>
}
  8018c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5e                   	pop    %esi
  8018c7:	5d                   	pop    %ebp
  8018c8:	c3                   	ret    

008018c9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018dd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e7:	b8 02 00 00 00       	mov    $0x2,%eax
  8018ec:	e8 8d ff ff ff       	call   80187e <fsipc>
}
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ff:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801904:	ba 00 00 00 00       	mov    $0x0,%edx
  801909:	b8 06 00 00 00       	mov    $0x6,%eax
  80190e:	e8 6b ff ff ff       	call   80187e <fsipc>
}
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	53                   	push   %ebx
  801919:	83 ec 04             	sub    $0x4,%esp
  80191c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80191f:	8b 45 08             	mov    0x8(%ebp),%eax
  801922:	8b 40 0c             	mov    0xc(%eax),%eax
  801925:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80192a:	ba 00 00 00 00       	mov    $0x0,%edx
  80192f:	b8 05 00 00 00       	mov    $0x5,%eax
  801934:	e8 45 ff ff ff       	call   80187e <fsipc>
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 2c                	js     801969 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80193d:	83 ec 08             	sub    $0x8,%esp
  801940:	68 00 50 80 00       	push   $0x805000
  801945:	53                   	push   %ebx
  801946:	e8 45 f0 ff ff       	call   800990 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80194b:	a1 80 50 80 00       	mov    0x805080,%eax
  801950:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801956:	a1 84 50 80 00       	mov    0x805084,%eax
  80195b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801969:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    

0080196e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	53                   	push   %ebx
  801972:	83 ec 08             	sub    $0x8,%esp
  801975:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801978:	8b 55 08             	mov    0x8(%ebp),%edx
  80197b:	8b 52 0c             	mov    0xc(%edx),%edx
  80197e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801984:	a3 04 50 80 00       	mov    %eax,0x805004
  801989:	3d 08 50 80 00       	cmp    $0x805008,%eax
  80198e:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801993:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801996:	53                   	push   %ebx
  801997:	ff 75 0c             	pushl  0xc(%ebp)
  80199a:	68 08 50 80 00       	push   $0x805008
  80199f:	e8 7e f1 ff ff       	call   800b22 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a9:	b8 04 00 00 00       	mov    $0x4,%eax
  8019ae:	e8 cb fe ff ff       	call   80187e <fsipc>
  8019b3:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8019bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	56                   	push   %esi
  8019c4:	53                   	push   %ebx
  8019c5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019d3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019de:	b8 03 00 00 00       	mov    $0x3,%eax
  8019e3:	e8 96 fe ff ff       	call   80187e <fsipc>
  8019e8:	89 c3                	mov    %eax,%ebx
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 4b                	js     801a39 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019ee:	39 c6                	cmp    %eax,%esi
  8019f0:	73 16                	jae    801a08 <devfile_read+0x48>
  8019f2:	68 f4 2e 80 00       	push   $0x802ef4
  8019f7:	68 fb 2e 80 00       	push   $0x802efb
  8019fc:	6a 7c                	push   $0x7c
  8019fe:	68 10 2f 80 00       	push   $0x802f10
  801a03:	e8 0a e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801a08:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a0d:	7e 16                	jle    801a25 <devfile_read+0x65>
  801a0f:	68 1b 2f 80 00       	push   $0x802f1b
  801a14:	68 fb 2e 80 00       	push   $0x802efb
  801a19:	6a 7d                	push   $0x7d
  801a1b:	68 10 2f 80 00       	push   $0x802f10
  801a20:	e8 ed e8 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a25:	83 ec 04             	sub    $0x4,%esp
  801a28:	50                   	push   %eax
  801a29:	68 00 50 80 00       	push   $0x805000
  801a2e:	ff 75 0c             	pushl  0xc(%ebp)
  801a31:	e8 ec f0 ff ff       	call   800b22 <memmove>
	return r;
  801a36:	83 c4 10             	add    $0x10,%esp
}
  801a39:	89 d8                	mov    %ebx,%eax
  801a3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3e:	5b                   	pop    %ebx
  801a3f:	5e                   	pop    %esi
  801a40:	5d                   	pop    %ebp
  801a41:	c3                   	ret    

00801a42 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	53                   	push   %ebx
  801a46:	83 ec 20             	sub    $0x20,%esp
  801a49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a4c:	53                   	push   %ebx
  801a4d:	e8 05 ef ff ff       	call   800957 <strlen>
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a5a:	7f 67                	jg     801ac3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a62:	50                   	push   %eax
  801a63:	e8 8e f8 ff ff       	call   8012f6 <fd_alloc>
  801a68:	83 c4 10             	add    $0x10,%esp
		return r;
  801a6b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	78 57                	js     801ac8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a71:	83 ec 08             	sub    $0x8,%esp
  801a74:	53                   	push   %ebx
  801a75:	68 00 50 80 00       	push   $0x805000
  801a7a:	e8 11 ef ff ff       	call   800990 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a82:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a87:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a8a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8f:	e8 ea fd ff ff       	call   80187e <fsipc>
  801a94:	89 c3                	mov    %eax,%ebx
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	79 14                	jns    801ab1 <open+0x6f>
		fd_close(fd, 0);
  801a9d:	83 ec 08             	sub    $0x8,%esp
  801aa0:	6a 00                	push   $0x0
  801aa2:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa5:	e8 44 f9 ff ff       	call   8013ee <fd_close>
		return r;
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	89 da                	mov    %ebx,%edx
  801aaf:	eb 17                	jmp    801ac8 <open+0x86>
	}

	return fd2num(fd);
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab7:	e8 13 f8 ff ff       	call   8012cf <fd2num>
  801abc:	89 c2                	mov    %eax,%edx
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	eb 05                	jmp    801ac8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ac3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ac8:	89 d0                	mov    %edx,%eax
  801aca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    

00801acf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  801ada:	b8 08 00 00 00       	mov    $0x8,%eax
  801adf:	e8 9a fd ff ff       	call   80187e <fsipc>
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	56                   	push   %esi
  801aea:	53                   	push   %ebx
  801aeb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	ff 75 08             	pushl  0x8(%ebp)
  801af4:	e8 e6 f7 ff ff       	call   8012df <fd2data>
  801af9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801afb:	83 c4 08             	add    $0x8,%esp
  801afe:	68 27 2f 80 00       	push   $0x802f27
  801b03:	53                   	push   %ebx
  801b04:	e8 87 ee ff ff       	call   800990 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b09:	8b 46 04             	mov    0x4(%esi),%eax
  801b0c:	2b 06                	sub    (%esi),%eax
  801b0e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b14:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b1b:	00 00 00 
	stat->st_dev = &devpipe;
  801b1e:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b25:	30 80 00 
	return 0;
}
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	53                   	push   %ebx
  801b38:	83 ec 0c             	sub    $0xc,%esp
  801b3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b3e:	53                   	push   %ebx
  801b3f:	6a 00                	push   $0x0
  801b41:	e8 d2 f2 ff ff       	call   800e18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b46:	89 1c 24             	mov    %ebx,(%esp)
  801b49:	e8 91 f7 ff ff       	call   8012df <fd2data>
  801b4e:	83 c4 08             	add    $0x8,%esp
  801b51:	50                   	push   %eax
  801b52:	6a 00                	push   $0x0
  801b54:	e8 bf f2 ff ff       	call   800e18 <sys_page_unmap>
}
  801b59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
  801b67:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b6a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b6c:	a1 08 40 80 00       	mov    0x804008,%eax
  801b71:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b74:	83 ec 0c             	sub    $0xc,%esp
  801b77:	ff 75 e0             	pushl  -0x20(%ebp)
  801b7a:	e8 90 0a 00 00       	call   80260f <pageref>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	89 3c 24             	mov    %edi,(%esp)
  801b84:	e8 86 0a 00 00       	call   80260f <pageref>
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	39 c3                	cmp    %eax,%ebx
  801b8e:	0f 94 c1             	sete   %cl
  801b91:	0f b6 c9             	movzbl %cl,%ecx
  801b94:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b97:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b9d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ba0:	39 ce                	cmp    %ecx,%esi
  801ba2:	74 1b                	je     801bbf <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ba4:	39 c3                	cmp    %eax,%ebx
  801ba6:	75 c4                	jne    801b6c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ba8:	8b 42 58             	mov    0x58(%edx),%eax
  801bab:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bae:	50                   	push   %eax
  801baf:	56                   	push   %esi
  801bb0:	68 2e 2f 80 00       	push   $0x802f2e
  801bb5:	e8 31 e8 ff ff       	call   8003eb <cprintf>
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	eb ad                	jmp    801b6c <_pipeisclosed+0xe>
	}
}
  801bbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc5:	5b                   	pop    %ebx
  801bc6:	5e                   	pop    %esi
  801bc7:	5f                   	pop    %edi
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    

00801bca <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	57                   	push   %edi
  801bce:	56                   	push   %esi
  801bcf:	53                   	push   %ebx
  801bd0:	83 ec 28             	sub    $0x28,%esp
  801bd3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bd6:	56                   	push   %esi
  801bd7:	e8 03 f7 ff ff       	call   8012df <fd2data>
  801bdc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	bf 00 00 00 00       	mov    $0x0,%edi
  801be6:	eb 4b                	jmp    801c33 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801be8:	89 da                	mov    %ebx,%edx
  801bea:	89 f0                	mov    %esi,%eax
  801bec:	e8 6d ff ff ff       	call   801b5e <_pipeisclosed>
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	75 48                	jne    801c3d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bf5:	e8 7a f1 ff ff       	call   800d74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bfa:	8b 43 04             	mov    0x4(%ebx),%eax
  801bfd:	8b 0b                	mov    (%ebx),%ecx
  801bff:	8d 51 20             	lea    0x20(%ecx),%edx
  801c02:	39 d0                	cmp    %edx,%eax
  801c04:	73 e2                	jae    801be8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c09:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c0d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c10:	89 c2                	mov    %eax,%edx
  801c12:	c1 fa 1f             	sar    $0x1f,%edx
  801c15:	89 d1                	mov    %edx,%ecx
  801c17:	c1 e9 1b             	shr    $0x1b,%ecx
  801c1a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c1d:	83 e2 1f             	and    $0x1f,%edx
  801c20:	29 ca                	sub    %ecx,%edx
  801c22:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c26:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c2a:	83 c0 01             	add    $0x1,%eax
  801c2d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c30:	83 c7 01             	add    $0x1,%edi
  801c33:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c36:	75 c2                	jne    801bfa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c38:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3b:	eb 05                	jmp    801c42 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c3d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c45:	5b                   	pop    %ebx
  801c46:	5e                   	pop    %esi
  801c47:	5f                   	pop    %edi
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	57                   	push   %edi
  801c4e:	56                   	push   %esi
  801c4f:	53                   	push   %ebx
  801c50:	83 ec 18             	sub    $0x18,%esp
  801c53:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c56:	57                   	push   %edi
  801c57:	e8 83 f6 ff ff       	call   8012df <fd2data>
  801c5c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c66:	eb 3d                	jmp    801ca5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c68:	85 db                	test   %ebx,%ebx
  801c6a:	74 04                	je     801c70 <devpipe_read+0x26>
				return i;
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	eb 44                	jmp    801cb4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c70:	89 f2                	mov    %esi,%edx
  801c72:	89 f8                	mov    %edi,%eax
  801c74:	e8 e5 fe ff ff       	call   801b5e <_pipeisclosed>
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	75 32                	jne    801caf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c7d:	e8 f2 f0 ff ff       	call   800d74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c82:	8b 06                	mov    (%esi),%eax
  801c84:	3b 46 04             	cmp    0x4(%esi),%eax
  801c87:	74 df                	je     801c68 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c89:	99                   	cltd   
  801c8a:	c1 ea 1b             	shr    $0x1b,%edx
  801c8d:	01 d0                	add    %edx,%eax
  801c8f:	83 e0 1f             	and    $0x1f,%eax
  801c92:	29 d0                	sub    %edx,%eax
  801c94:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c9f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca2:	83 c3 01             	add    $0x1,%ebx
  801ca5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ca8:	75 d8                	jne    801c82 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801caa:	8b 45 10             	mov    0x10(%ebp),%eax
  801cad:	eb 05                	jmp    801cb4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801caf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5f                   	pop    %edi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    

00801cbc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	56                   	push   %esi
  801cc0:	53                   	push   %ebx
  801cc1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc7:	50                   	push   %eax
  801cc8:	e8 29 f6 ff ff       	call   8012f6 <fd_alloc>
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	89 c2                	mov    %eax,%edx
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 88 2c 01 00 00    	js     801e06 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cda:	83 ec 04             	sub    $0x4,%esp
  801cdd:	68 07 04 00 00       	push   $0x407
  801ce2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce5:	6a 00                	push   $0x0
  801ce7:	e8 a7 f0 ff ff       	call   800d93 <sys_page_alloc>
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	89 c2                	mov    %eax,%edx
  801cf1:	85 c0                	test   %eax,%eax
  801cf3:	0f 88 0d 01 00 00    	js     801e06 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cf9:	83 ec 0c             	sub    $0xc,%esp
  801cfc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cff:	50                   	push   %eax
  801d00:	e8 f1 f5 ff ff       	call   8012f6 <fd_alloc>
  801d05:	89 c3                	mov    %eax,%ebx
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	0f 88 e2 00 00 00    	js     801df4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d12:	83 ec 04             	sub    $0x4,%esp
  801d15:	68 07 04 00 00       	push   $0x407
  801d1a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1d:	6a 00                	push   $0x0
  801d1f:	e8 6f f0 ff ff       	call   800d93 <sys_page_alloc>
  801d24:	89 c3                	mov    %eax,%ebx
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	0f 88 c3 00 00 00    	js     801df4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d31:	83 ec 0c             	sub    $0xc,%esp
  801d34:	ff 75 f4             	pushl  -0xc(%ebp)
  801d37:	e8 a3 f5 ff ff       	call   8012df <fd2data>
  801d3c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3e:	83 c4 0c             	add    $0xc,%esp
  801d41:	68 07 04 00 00       	push   $0x407
  801d46:	50                   	push   %eax
  801d47:	6a 00                	push   $0x0
  801d49:	e8 45 f0 ff ff       	call   800d93 <sys_page_alloc>
  801d4e:	89 c3                	mov    %eax,%ebx
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	85 c0                	test   %eax,%eax
  801d55:	0f 88 89 00 00 00    	js     801de4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5b:	83 ec 0c             	sub    $0xc,%esp
  801d5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d61:	e8 79 f5 ff ff       	call   8012df <fd2data>
  801d66:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d6d:	50                   	push   %eax
  801d6e:	6a 00                	push   $0x0
  801d70:	56                   	push   %esi
  801d71:	6a 00                	push   $0x0
  801d73:	e8 5e f0 ff ff       	call   800dd6 <sys_page_map>
  801d78:	89 c3                	mov    %eax,%ebx
  801d7a:	83 c4 20             	add    $0x20,%esp
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	78 55                	js     801dd6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d81:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d96:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d9f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dab:	83 ec 0c             	sub    $0xc,%esp
  801dae:	ff 75 f4             	pushl  -0xc(%ebp)
  801db1:	e8 19 f5 ff ff       	call   8012cf <fd2num>
  801db6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dbb:	83 c4 04             	add    $0x4,%esp
  801dbe:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc1:	e8 09 f5 ff ff       	call   8012cf <fd2num>
  801dc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd4:	eb 30                	jmp    801e06 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dd6:	83 ec 08             	sub    $0x8,%esp
  801dd9:	56                   	push   %esi
  801dda:	6a 00                	push   $0x0
  801ddc:	e8 37 f0 ff ff       	call   800e18 <sys_page_unmap>
  801de1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801de4:	83 ec 08             	sub    $0x8,%esp
  801de7:	ff 75 f0             	pushl  -0x10(%ebp)
  801dea:	6a 00                	push   $0x0
  801dec:	e8 27 f0 ff ff       	call   800e18 <sys_page_unmap>
  801df1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801df4:	83 ec 08             	sub    $0x8,%esp
  801df7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfa:	6a 00                	push   $0x0
  801dfc:	e8 17 f0 ff ff       	call   800e18 <sys_page_unmap>
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e06:	89 d0                	mov    %edx,%eax
  801e08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0b:	5b                   	pop    %ebx
  801e0c:	5e                   	pop    %esi
  801e0d:	5d                   	pop    %ebp
  801e0e:	c3                   	ret    

00801e0f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e18:	50                   	push   %eax
  801e19:	ff 75 08             	pushl  0x8(%ebp)
  801e1c:	e8 24 f5 ff ff       	call   801345 <fd_lookup>
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	85 c0                	test   %eax,%eax
  801e26:	78 18                	js     801e40 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e28:	83 ec 0c             	sub    $0xc,%esp
  801e2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2e:	e8 ac f4 ff ff       	call   8012df <fd2data>
	return _pipeisclosed(fd, p);
  801e33:	89 c2                	mov    %eax,%edx
  801e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e38:	e8 21 fd ff ff       	call   801b5e <_pipeisclosed>
  801e3d:	83 c4 10             	add    $0x10,%esp
}
  801e40:	c9                   	leave  
  801e41:	c3                   	ret    

00801e42 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	56                   	push   %esi
  801e46:	53                   	push   %ebx
  801e47:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e4a:	85 f6                	test   %esi,%esi
  801e4c:	75 16                	jne    801e64 <wait+0x22>
  801e4e:	68 46 2f 80 00       	push   $0x802f46
  801e53:	68 fb 2e 80 00       	push   $0x802efb
  801e58:	6a 09                	push   $0x9
  801e5a:	68 51 2f 80 00       	push   $0x802f51
  801e5f:	e8 ae e4 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801e64:	89 f3                	mov    %esi,%ebx
  801e66:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e6c:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e6f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e75:	eb 05                	jmp    801e7c <wait+0x3a>
		sys_yield();
  801e77:	e8 f8 ee ff ff       	call   800d74 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e7c:	8b 43 48             	mov    0x48(%ebx),%eax
  801e7f:	39 c6                	cmp    %eax,%esi
  801e81:	75 07                	jne    801e8a <wait+0x48>
  801e83:	8b 43 54             	mov    0x54(%ebx),%eax
  801e86:	85 c0                	test   %eax,%eax
  801e88:	75 ed                	jne    801e77 <wait+0x35>
		sys_yield();
}
  801e8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801e97:	68 5c 2f 80 00       	push   $0x802f5c
  801e9c:	ff 75 0c             	pushl  0xc(%ebp)
  801e9f:	e8 ec ea ff ff       	call   800990 <strcpy>
	return 0;
}
  801ea4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	53                   	push   %ebx
  801eaf:	83 ec 10             	sub    $0x10,%esp
  801eb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801eb5:	53                   	push   %ebx
  801eb6:	e8 54 07 00 00       	call   80260f <pageref>
  801ebb:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ebe:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ec3:	83 f8 01             	cmp    $0x1,%eax
  801ec6:	75 10                	jne    801ed8 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ec8:	83 ec 0c             	sub    $0xc,%esp
  801ecb:	ff 73 0c             	pushl  0xc(%ebx)
  801ece:	e8 c0 02 00 00       	call   802193 <nsipc_close>
  801ed3:	89 c2                	mov    %eax,%edx
  801ed5:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ed8:	89 d0                	mov    %edx,%eax
  801eda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801edd:	c9                   	leave  
  801ede:	c3                   	ret    

00801edf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ee5:	6a 00                	push   $0x0
  801ee7:	ff 75 10             	pushl  0x10(%ebp)
  801eea:	ff 75 0c             	pushl  0xc(%ebp)
  801eed:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef0:	ff 70 0c             	pushl  0xc(%eax)
  801ef3:	e8 78 03 00 00       	call   802270 <nsipc_send>
}
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    

00801efa <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f00:	6a 00                	push   $0x0
  801f02:	ff 75 10             	pushl  0x10(%ebp)
  801f05:	ff 75 0c             	pushl  0xc(%ebp)
  801f08:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0b:	ff 70 0c             	pushl  0xc(%eax)
  801f0e:	e8 f1 02 00 00       	call   802204 <nsipc_recv>
}
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f1b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f1e:	52                   	push   %edx
  801f1f:	50                   	push   %eax
  801f20:	e8 20 f4 ff ff       	call   801345 <fd_lookup>
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 17                	js     801f43 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2f:	8b 0d 40 30 80 00    	mov    0x803040,%ecx
  801f35:	39 08                	cmp    %ecx,(%eax)
  801f37:	75 05                	jne    801f3e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f39:	8b 40 0c             	mov    0xc(%eax),%eax
  801f3c:	eb 05                	jmp    801f43 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f3e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f43:	c9                   	leave  
  801f44:	c3                   	ret    

00801f45 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	56                   	push   %esi
  801f49:	53                   	push   %ebx
  801f4a:	83 ec 1c             	sub    $0x1c,%esp
  801f4d:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f52:	50                   	push   %eax
  801f53:	e8 9e f3 ff ff       	call   8012f6 <fd_alloc>
  801f58:	89 c3                	mov    %eax,%ebx
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 1b                	js     801f7c <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f61:	83 ec 04             	sub    $0x4,%esp
  801f64:	68 07 04 00 00       	push   $0x407
  801f69:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6c:	6a 00                	push   $0x0
  801f6e:	e8 20 ee ff ff       	call   800d93 <sys_page_alloc>
  801f73:	89 c3                	mov    %eax,%ebx
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	79 10                	jns    801f8c <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801f7c:	83 ec 0c             	sub    $0xc,%esp
  801f7f:	56                   	push   %esi
  801f80:	e8 0e 02 00 00       	call   802193 <nsipc_close>
		return r;
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	89 d8                	mov    %ebx,%eax
  801f8a:	eb 24                	jmp    801fb0 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f8c:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f95:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fa1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fa4:	83 ec 0c             	sub    $0xc,%esp
  801fa7:	50                   	push   %eax
  801fa8:	e8 22 f3 ff ff       	call   8012cf <fd2num>
  801fad:	83 c4 10             	add    $0x10,%esp
}
  801fb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    

00801fb7 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc0:	e8 50 ff ff ff       	call   801f15 <fd2sockid>
		return r;
  801fc5:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	78 1f                	js     801fea <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fcb:	83 ec 04             	sub    $0x4,%esp
  801fce:	ff 75 10             	pushl  0x10(%ebp)
  801fd1:	ff 75 0c             	pushl  0xc(%ebp)
  801fd4:	50                   	push   %eax
  801fd5:	e8 12 01 00 00       	call   8020ec <nsipc_accept>
  801fda:	83 c4 10             	add    $0x10,%esp
		return r;
  801fdd:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	78 07                	js     801fea <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801fe3:	e8 5d ff ff ff       	call   801f45 <alloc_sockfd>
  801fe8:	89 c1                	mov    %eax,%ecx
}
  801fea:	89 c8                	mov    %ecx,%eax
  801fec:	c9                   	leave  
  801fed:	c3                   	ret    

00801fee <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff7:	e8 19 ff ff ff       	call   801f15 <fd2sockid>
  801ffc:	85 c0                	test   %eax,%eax
  801ffe:	78 12                	js     802012 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802000:	83 ec 04             	sub    $0x4,%esp
  802003:	ff 75 10             	pushl  0x10(%ebp)
  802006:	ff 75 0c             	pushl  0xc(%ebp)
  802009:	50                   	push   %eax
  80200a:	e8 2d 01 00 00       	call   80213c <nsipc_bind>
  80200f:	83 c4 10             	add    $0x10,%esp
}
  802012:	c9                   	leave  
  802013:	c3                   	ret    

00802014 <shutdown>:

int
shutdown(int s, int how)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80201a:	8b 45 08             	mov    0x8(%ebp),%eax
  80201d:	e8 f3 fe ff ff       	call   801f15 <fd2sockid>
  802022:	85 c0                	test   %eax,%eax
  802024:	78 0f                	js     802035 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802026:	83 ec 08             	sub    $0x8,%esp
  802029:	ff 75 0c             	pushl  0xc(%ebp)
  80202c:	50                   	push   %eax
  80202d:	e8 3f 01 00 00       	call   802171 <nsipc_shutdown>
  802032:	83 c4 10             	add    $0x10,%esp
}
  802035:	c9                   	leave  
  802036:	c3                   	ret    

00802037 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80203d:	8b 45 08             	mov    0x8(%ebp),%eax
  802040:	e8 d0 fe ff ff       	call   801f15 <fd2sockid>
  802045:	85 c0                	test   %eax,%eax
  802047:	78 12                	js     80205b <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802049:	83 ec 04             	sub    $0x4,%esp
  80204c:	ff 75 10             	pushl  0x10(%ebp)
  80204f:	ff 75 0c             	pushl  0xc(%ebp)
  802052:	50                   	push   %eax
  802053:	e8 55 01 00 00       	call   8021ad <nsipc_connect>
  802058:	83 c4 10             	add    $0x10,%esp
}
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    

0080205d <listen>:

int
listen(int s, int backlog)
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802063:	8b 45 08             	mov    0x8(%ebp),%eax
  802066:	e8 aa fe ff ff       	call   801f15 <fd2sockid>
  80206b:	85 c0                	test   %eax,%eax
  80206d:	78 0f                	js     80207e <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80206f:	83 ec 08             	sub    $0x8,%esp
  802072:	ff 75 0c             	pushl  0xc(%ebp)
  802075:	50                   	push   %eax
  802076:	e8 67 01 00 00       	call   8021e2 <nsipc_listen>
  80207b:	83 c4 10             	add    $0x10,%esp
}
  80207e:	c9                   	leave  
  80207f:	c3                   	ret    

00802080 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802086:	ff 75 10             	pushl  0x10(%ebp)
  802089:	ff 75 0c             	pushl  0xc(%ebp)
  80208c:	ff 75 08             	pushl  0x8(%ebp)
  80208f:	e8 3a 02 00 00       	call   8022ce <nsipc_socket>
  802094:	83 c4 10             	add    $0x10,%esp
  802097:	85 c0                	test   %eax,%eax
  802099:	78 05                	js     8020a0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80209b:	e8 a5 fe ff ff       	call   801f45 <alloc_sockfd>
}
  8020a0:	c9                   	leave  
  8020a1:	c3                   	ret    

008020a2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	53                   	push   %ebx
  8020a6:	83 ec 04             	sub    $0x4,%esp
  8020a9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020ab:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8020b2:	75 12                	jne    8020c6 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8020b4:	83 ec 0c             	sub    $0xc,%esp
  8020b7:	6a 02                	push   $0x2
  8020b9:	e8 18 05 00 00       	call   8025d6 <ipc_find_env>
  8020be:	a3 04 40 80 00       	mov    %eax,0x804004
  8020c3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8020c6:	6a 07                	push   $0x7
  8020c8:	68 00 60 80 00       	push   $0x806000
  8020cd:	53                   	push   %ebx
  8020ce:	ff 35 04 40 80 00    	pushl  0x804004
  8020d4:	e8 ae 04 00 00       	call   802587 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020d9:	83 c4 0c             	add    $0xc,%esp
  8020dc:	6a 00                	push   $0x0
  8020de:	6a 00                	push   $0x0
  8020e0:	6a 00                	push   $0x0
  8020e2:	e8 2a 04 00 00       	call   802511 <ipc_recv>
}
  8020e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ea:	c9                   	leave  
  8020eb:	c3                   	ret    

008020ec <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	56                   	push   %esi
  8020f0:	53                   	push   %ebx
  8020f1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8020f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8020fc:	8b 06                	mov    (%esi),%eax
  8020fe:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802103:	b8 01 00 00 00       	mov    $0x1,%eax
  802108:	e8 95 ff ff ff       	call   8020a2 <nsipc>
  80210d:	89 c3                	mov    %eax,%ebx
  80210f:	85 c0                	test   %eax,%eax
  802111:	78 20                	js     802133 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802113:	83 ec 04             	sub    $0x4,%esp
  802116:	ff 35 10 60 80 00    	pushl  0x806010
  80211c:	68 00 60 80 00       	push   $0x806000
  802121:	ff 75 0c             	pushl  0xc(%ebp)
  802124:	e8 f9 e9 ff ff       	call   800b22 <memmove>
		*addrlen = ret->ret_addrlen;
  802129:	a1 10 60 80 00       	mov    0x806010,%eax
  80212e:	89 06                	mov    %eax,(%esi)
  802130:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802133:	89 d8                	mov    %ebx,%eax
  802135:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802138:	5b                   	pop    %ebx
  802139:	5e                   	pop    %esi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    

0080213c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	53                   	push   %ebx
  802140:	83 ec 08             	sub    $0x8,%esp
  802143:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802146:	8b 45 08             	mov    0x8(%ebp),%eax
  802149:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80214e:	53                   	push   %ebx
  80214f:	ff 75 0c             	pushl  0xc(%ebp)
  802152:	68 04 60 80 00       	push   $0x806004
  802157:	e8 c6 e9 ff ff       	call   800b22 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80215c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  802162:	b8 02 00 00 00       	mov    $0x2,%eax
  802167:	e8 36 ff ff ff       	call   8020a2 <nsipc>
}
  80216c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80216f:	c9                   	leave  
  802170:	c3                   	ret    

00802171 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802171:	55                   	push   %ebp
  802172:	89 e5                	mov    %esp,%ebp
  802174:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802177:	8b 45 08             	mov    0x8(%ebp),%eax
  80217a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80217f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802182:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802187:	b8 03 00 00 00       	mov    $0x3,%eax
  80218c:	e8 11 ff ff ff       	call   8020a2 <nsipc>
}
  802191:	c9                   	leave  
  802192:	c3                   	ret    

00802193 <nsipc_close>:

int
nsipc_close(int s)
{
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802199:	8b 45 08             	mov    0x8(%ebp),%eax
  80219c:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8021a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8021a6:	e8 f7 fe ff ff       	call   8020a2 <nsipc>
}
  8021ab:	c9                   	leave  
  8021ac:	c3                   	ret    

008021ad <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021ad:	55                   	push   %ebp
  8021ae:	89 e5                	mov    %esp,%ebp
  8021b0:	53                   	push   %ebx
  8021b1:	83 ec 08             	sub    $0x8,%esp
  8021b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8021b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ba:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8021bf:	53                   	push   %ebx
  8021c0:	ff 75 0c             	pushl  0xc(%ebp)
  8021c3:	68 04 60 80 00       	push   $0x806004
  8021c8:	e8 55 e9 ff ff       	call   800b22 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8021cd:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8021d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8021d8:	e8 c5 fe ff ff       	call   8020a2 <nsipc>
}
  8021dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021e0:	c9                   	leave  
  8021e1:	c3                   	ret    

008021e2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021eb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8021f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8021f8:	b8 06 00 00 00       	mov    $0x6,%eax
  8021fd:	e8 a0 fe ff ff       	call   8020a2 <nsipc>
}
  802202:	c9                   	leave  
  802203:	c3                   	ret    

00802204 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	56                   	push   %esi
  802208:	53                   	push   %ebx
  802209:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80220c:	8b 45 08             	mov    0x8(%ebp),%eax
  80220f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802214:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80221a:	8b 45 14             	mov    0x14(%ebp),%eax
  80221d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802222:	b8 07 00 00 00       	mov    $0x7,%eax
  802227:	e8 76 fe ff ff       	call   8020a2 <nsipc>
  80222c:	89 c3                	mov    %eax,%ebx
  80222e:	85 c0                	test   %eax,%eax
  802230:	78 35                	js     802267 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802232:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802237:	7f 04                	jg     80223d <nsipc_recv+0x39>
  802239:	39 c6                	cmp    %eax,%esi
  80223b:	7d 16                	jge    802253 <nsipc_recv+0x4f>
  80223d:	68 68 2f 80 00       	push   $0x802f68
  802242:	68 fb 2e 80 00       	push   $0x802efb
  802247:	6a 62                	push   $0x62
  802249:	68 7d 2f 80 00       	push   $0x802f7d
  80224e:	e8 bf e0 ff ff       	call   800312 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802253:	83 ec 04             	sub    $0x4,%esp
  802256:	50                   	push   %eax
  802257:	68 00 60 80 00       	push   $0x806000
  80225c:	ff 75 0c             	pushl  0xc(%ebp)
  80225f:	e8 be e8 ff ff       	call   800b22 <memmove>
  802264:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802267:	89 d8                	mov    %ebx,%eax
  802269:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80226c:	5b                   	pop    %ebx
  80226d:	5e                   	pop    %esi
  80226e:	5d                   	pop    %ebp
  80226f:	c3                   	ret    

00802270 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	53                   	push   %ebx
  802274:	83 ec 04             	sub    $0x4,%esp
  802277:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80227a:	8b 45 08             	mov    0x8(%ebp),%eax
  80227d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802282:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802288:	7e 16                	jle    8022a0 <nsipc_send+0x30>
  80228a:	68 89 2f 80 00       	push   $0x802f89
  80228f:	68 fb 2e 80 00       	push   $0x802efb
  802294:	6a 6d                	push   $0x6d
  802296:	68 7d 2f 80 00       	push   $0x802f7d
  80229b:	e8 72 e0 ff ff       	call   800312 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022a0:	83 ec 04             	sub    $0x4,%esp
  8022a3:	53                   	push   %ebx
  8022a4:	ff 75 0c             	pushl  0xc(%ebp)
  8022a7:	68 0c 60 80 00       	push   $0x80600c
  8022ac:	e8 71 e8 ff ff       	call   800b22 <memmove>
	nsipcbuf.send.req_size = size;
  8022b1:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8022b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8022ba:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8022bf:	b8 08 00 00 00       	mov    $0x8,%eax
  8022c4:	e8 d9 fd ff ff       	call   8020a2 <nsipc>
}
  8022c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022cc:	c9                   	leave  
  8022cd:	c3                   	ret    

008022ce <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8022ce:	55                   	push   %ebp
  8022cf:	89 e5                	mov    %esp,%ebp
  8022d1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8022dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022df:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8022e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8022e7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8022ec:	b8 09 00 00 00       	mov    $0x9,%eax
  8022f1:	e8 ac fd ff ff       	call   8020a2 <nsipc>
}
  8022f6:	c9                   	leave  
  8022f7:	c3                   	ret    

008022f8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022f8:	55                   	push   %ebp
  8022f9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802300:	5d                   	pop    %ebp
  802301:	c3                   	ret    

00802302 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802302:	55                   	push   %ebp
  802303:	89 e5                	mov    %esp,%ebp
  802305:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802308:	68 95 2f 80 00       	push   $0x802f95
  80230d:	ff 75 0c             	pushl  0xc(%ebp)
  802310:	e8 7b e6 ff ff       	call   800990 <strcpy>
	return 0;
}
  802315:	b8 00 00 00 00       	mov    $0x0,%eax
  80231a:	c9                   	leave  
  80231b:	c3                   	ret    

0080231c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80231c:	55                   	push   %ebp
  80231d:	89 e5                	mov    %esp,%ebp
  80231f:	57                   	push   %edi
  802320:	56                   	push   %esi
  802321:	53                   	push   %ebx
  802322:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802328:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80232d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802333:	eb 2d                	jmp    802362 <devcons_write+0x46>
		m = n - tot;
  802335:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802338:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80233a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80233d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802342:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802345:	83 ec 04             	sub    $0x4,%esp
  802348:	53                   	push   %ebx
  802349:	03 45 0c             	add    0xc(%ebp),%eax
  80234c:	50                   	push   %eax
  80234d:	57                   	push   %edi
  80234e:	e8 cf e7 ff ff       	call   800b22 <memmove>
		sys_cputs(buf, m);
  802353:	83 c4 08             	add    $0x8,%esp
  802356:	53                   	push   %ebx
  802357:	57                   	push   %edi
  802358:	e8 7a e9 ff ff       	call   800cd7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80235d:	01 de                	add    %ebx,%esi
  80235f:	83 c4 10             	add    $0x10,%esp
  802362:	89 f0                	mov    %esi,%eax
  802364:	3b 75 10             	cmp    0x10(%ebp),%esi
  802367:	72 cc                	jb     802335 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802369:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80236c:	5b                   	pop    %ebx
  80236d:	5e                   	pop    %esi
  80236e:	5f                   	pop    %edi
  80236f:	5d                   	pop    %ebp
  802370:	c3                   	ret    

00802371 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802371:	55                   	push   %ebp
  802372:	89 e5                	mov    %esp,%ebp
  802374:	83 ec 08             	sub    $0x8,%esp
  802377:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80237c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802380:	74 2a                	je     8023ac <devcons_read+0x3b>
  802382:	eb 05                	jmp    802389 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802384:	e8 eb e9 ff ff       	call   800d74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802389:	e8 67 e9 ff ff       	call   800cf5 <sys_cgetc>
  80238e:	85 c0                	test   %eax,%eax
  802390:	74 f2                	je     802384 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802392:	85 c0                	test   %eax,%eax
  802394:	78 16                	js     8023ac <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802396:	83 f8 04             	cmp    $0x4,%eax
  802399:	74 0c                	je     8023a7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80239b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80239e:	88 02                	mov    %al,(%edx)
	return 1;
  8023a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a5:	eb 05                	jmp    8023ac <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023a7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023ac:	c9                   	leave  
  8023ad:	c3                   	ret    

008023ae <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023ae:	55                   	push   %ebp
  8023af:	89 e5                	mov    %esp,%ebp
  8023b1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023ba:	6a 01                	push   $0x1
  8023bc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023bf:	50                   	push   %eax
  8023c0:	e8 12 e9 ff ff       	call   800cd7 <sys_cputs>
}
  8023c5:	83 c4 10             	add    $0x10,%esp
  8023c8:	c9                   	leave  
  8023c9:	c3                   	ret    

008023ca <getchar>:

int
getchar(void)
{
  8023ca:	55                   	push   %ebp
  8023cb:	89 e5                	mov    %esp,%ebp
  8023cd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023d0:	6a 01                	push   $0x1
  8023d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023d5:	50                   	push   %eax
  8023d6:	6a 00                	push   $0x0
  8023d8:	e8 ce f1 ff ff       	call   8015ab <read>
	if (r < 0)
  8023dd:	83 c4 10             	add    $0x10,%esp
  8023e0:	85 c0                	test   %eax,%eax
  8023e2:	78 0f                	js     8023f3 <getchar+0x29>
		return r;
	if (r < 1)
  8023e4:	85 c0                	test   %eax,%eax
  8023e6:	7e 06                	jle    8023ee <getchar+0x24>
		return -E_EOF;
	return c;
  8023e8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023ec:	eb 05                	jmp    8023f3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023ee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023f3:	c9                   	leave  
  8023f4:	c3                   	ret    

008023f5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023f5:	55                   	push   %ebp
  8023f6:	89 e5                	mov    %esp,%ebp
  8023f8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023fe:	50                   	push   %eax
  8023ff:	ff 75 08             	pushl  0x8(%ebp)
  802402:	e8 3e ef ff ff       	call   801345 <fd_lookup>
  802407:	83 c4 10             	add    $0x10,%esp
  80240a:	85 c0                	test   %eax,%eax
  80240c:	78 11                	js     80241f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80240e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802411:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802417:	39 10                	cmp    %edx,(%eax)
  802419:	0f 94 c0             	sete   %al
  80241c:	0f b6 c0             	movzbl %al,%eax
}
  80241f:	c9                   	leave  
  802420:	c3                   	ret    

00802421 <opencons>:

int
opencons(void)
{
  802421:	55                   	push   %ebp
  802422:	89 e5                	mov    %esp,%ebp
  802424:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802427:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80242a:	50                   	push   %eax
  80242b:	e8 c6 ee ff ff       	call   8012f6 <fd_alloc>
  802430:	83 c4 10             	add    $0x10,%esp
		return r;
  802433:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802435:	85 c0                	test   %eax,%eax
  802437:	78 3e                	js     802477 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802439:	83 ec 04             	sub    $0x4,%esp
  80243c:	68 07 04 00 00       	push   $0x407
  802441:	ff 75 f4             	pushl  -0xc(%ebp)
  802444:	6a 00                	push   $0x0
  802446:	e8 48 e9 ff ff       	call   800d93 <sys_page_alloc>
  80244b:	83 c4 10             	add    $0x10,%esp
		return r;
  80244e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802450:	85 c0                	test   %eax,%eax
  802452:	78 23                	js     802477 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802454:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80245a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80245f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802462:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802469:	83 ec 0c             	sub    $0xc,%esp
  80246c:	50                   	push   %eax
  80246d:	e8 5d ee ff ff       	call   8012cf <fd2num>
  802472:	89 c2                	mov    %eax,%edx
  802474:	83 c4 10             	add    $0x10,%esp
}
  802477:	89 d0                	mov    %edx,%eax
  802479:	c9                   	leave  
  80247a:	c3                   	ret    

0080247b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80247b:	55                   	push   %ebp
  80247c:	89 e5                	mov    %esp,%ebp
  80247e:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  802481:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802488:	75 56                	jne    8024e0 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80248a:	83 ec 04             	sub    $0x4,%esp
  80248d:	6a 07                	push   $0x7
  80248f:	68 00 f0 bf ee       	push   $0xeebff000
  802494:	6a 00                	push   $0x0
  802496:	e8 f8 e8 ff ff       	call   800d93 <sys_page_alloc>
  80249b:	83 c4 10             	add    $0x10,%esp
  80249e:	85 c0                	test   %eax,%eax
  8024a0:	74 14                	je     8024b6 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  8024a2:	83 ec 04             	sub    $0x4,%esp
  8024a5:	68 09 2e 80 00       	push   $0x802e09
  8024aa:	6a 21                	push   $0x21
  8024ac:	68 a1 2f 80 00       	push   $0x802fa1
  8024b1:	e8 5c de ff ff       	call   800312 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  8024b6:	83 ec 08             	sub    $0x8,%esp
  8024b9:	68 ea 24 80 00       	push   $0x8024ea
  8024be:	6a 00                	push   $0x0
  8024c0:	e8 19 ea ff ff       	call   800ede <sys_env_set_pgfault_upcall>
  8024c5:	83 c4 10             	add    $0x10,%esp
  8024c8:	85 c0                	test   %eax,%eax
  8024ca:	74 14                	je     8024e0 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  8024cc:	83 ec 04             	sub    $0x4,%esp
  8024cf:	68 af 2f 80 00       	push   $0x802faf
  8024d4:	6a 23                	push   $0x23
  8024d6:	68 a1 2f 80 00       	push   $0x802fa1
  8024db:	e8 32 de ff ff       	call   800312 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e3:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8024e8:	c9                   	leave  
  8024e9:	c3                   	ret    

008024ea <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024ea:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024eb:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8024f0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024f2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  8024f5:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  8024f7:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  8024fb:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8024ff:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  802500:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  802502:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  802507:	83 c4 08             	add    $0x8,%esp
	popal
  80250a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80250b:	83 c4 04             	add    $0x4,%esp
	popfl
  80250e:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80250f:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802510:	c3                   	ret    

00802511 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802511:	55                   	push   %ebp
  802512:	89 e5                	mov    %esp,%ebp
  802514:	56                   	push   %esi
  802515:	53                   	push   %ebx
  802516:	8b 75 08             	mov    0x8(%ebp),%esi
  802519:	8b 45 0c             	mov    0xc(%ebp),%eax
  80251c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  80251f:	85 c0                	test   %eax,%eax
  802521:	74 0e                	je     802531 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  802523:	83 ec 0c             	sub    $0xc,%esp
  802526:	50                   	push   %eax
  802527:	e8 17 ea ff ff       	call   800f43 <sys_ipc_recv>
  80252c:	83 c4 10             	add    $0x10,%esp
  80252f:	eb 10                	jmp    802541 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802531:	83 ec 0c             	sub    $0xc,%esp
  802534:	68 00 00 c0 ee       	push   $0xeec00000
  802539:	e8 05 ea ff ff       	call   800f43 <sys_ipc_recv>
  80253e:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  802541:	85 c0                	test   %eax,%eax
  802543:	79 17                	jns    80255c <ipc_recv+0x4b>
		if(*from_env_store)
  802545:	83 3e 00             	cmpl   $0x0,(%esi)
  802548:	74 06                	je     802550 <ipc_recv+0x3f>
			*from_env_store = 0;
  80254a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  802550:	85 db                	test   %ebx,%ebx
  802552:	74 2c                	je     802580 <ipc_recv+0x6f>
			*perm_store = 0;
  802554:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80255a:	eb 24                	jmp    802580 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  80255c:	85 f6                	test   %esi,%esi
  80255e:	74 0a                	je     80256a <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  802560:	a1 08 40 80 00       	mov    0x804008,%eax
  802565:	8b 40 74             	mov    0x74(%eax),%eax
  802568:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80256a:	85 db                	test   %ebx,%ebx
  80256c:	74 0a                	je     802578 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  80256e:	a1 08 40 80 00       	mov    0x804008,%eax
  802573:	8b 40 78             	mov    0x78(%eax),%eax
  802576:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802578:	a1 08 40 80 00       	mov    0x804008,%eax
  80257d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802580:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802583:	5b                   	pop    %ebx
  802584:	5e                   	pop    %esi
  802585:	5d                   	pop    %ebp
  802586:	c3                   	ret    

00802587 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802587:	55                   	push   %ebp
  802588:	89 e5                	mov    %esp,%ebp
  80258a:	57                   	push   %edi
  80258b:	56                   	push   %esi
  80258c:	53                   	push   %ebx
  80258d:	83 ec 0c             	sub    $0xc,%esp
  802590:	8b 7d 08             	mov    0x8(%ebp),%edi
  802593:	8b 75 0c             	mov    0xc(%ebp),%esi
  802596:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802599:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80259b:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  8025a0:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  8025a3:	e8 cc e7 ff ff       	call   800d74 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  8025a8:	ff 75 14             	pushl  0x14(%ebp)
  8025ab:	53                   	push   %ebx
  8025ac:	56                   	push   %esi
  8025ad:	57                   	push   %edi
  8025ae:	e8 6d e9 ff ff       	call   800f20 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  8025b3:	89 c2                	mov    %eax,%edx
  8025b5:	f7 d2                	not    %edx
  8025b7:	c1 ea 1f             	shr    $0x1f,%edx
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025c0:	0f 94 c1             	sete   %cl
  8025c3:	09 ca                	or     %ecx,%edx
  8025c5:	85 c0                	test   %eax,%eax
  8025c7:	0f 94 c0             	sete   %al
  8025ca:	38 c2                	cmp    %al,%dl
  8025cc:	77 d5                	ja     8025a3 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8025ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025d1:	5b                   	pop    %ebx
  8025d2:	5e                   	pop    %esi
  8025d3:	5f                   	pop    %edi
  8025d4:	5d                   	pop    %ebp
  8025d5:	c3                   	ret    

008025d6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025d6:	55                   	push   %ebp
  8025d7:	89 e5                	mov    %esp,%ebp
  8025d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025dc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025e1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025e4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025ea:	8b 52 50             	mov    0x50(%edx),%edx
  8025ed:	39 ca                	cmp    %ecx,%edx
  8025ef:	75 0d                	jne    8025fe <ipc_find_env+0x28>
			return envs[i].env_id;
  8025f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025f9:	8b 40 48             	mov    0x48(%eax),%eax
  8025fc:	eb 0f                	jmp    80260d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025fe:	83 c0 01             	add    $0x1,%eax
  802601:	3d 00 04 00 00       	cmp    $0x400,%eax
  802606:	75 d9                	jne    8025e1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802608:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80260d:	5d                   	pop    %ebp
  80260e:	c3                   	ret    

0080260f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80260f:	55                   	push   %ebp
  802610:	89 e5                	mov    %esp,%ebp
  802612:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802615:	89 d0                	mov    %edx,%eax
  802617:	c1 e8 16             	shr    $0x16,%eax
  80261a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802621:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802626:	f6 c1 01             	test   $0x1,%cl
  802629:	74 1d                	je     802648 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80262b:	c1 ea 0c             	shr    $0xc,%edx
  80262e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802635:	f6 c2 01             	test   $0x1,%dl
  802638:	74 0e                	je     802648 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80263a:	c1 ea 0c             	shr    $0xc,%edx
  80263d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802644:	ef 
  802645:	0f b7 c0             	movzwl %ax,%eax
}
  802648:	5d                   	pop    %ebp
  802649:	c3                   	ret    
  80264a:	66 90                	xchg   %ax,%ax
  80264c:	66 90                	xchg   %ax,%ax
  80264e:	66 90                	xchg   %ax,%ax

00802650 <__udivdi3>:
  802650:	55                   	push   %ebp
  802651:	57                   	push   %edi
  802652:	56                   	push   %esi
  802653:	53                   	push   %ebx
  802654:	83 ec 1c             	sub    $0x1c,%esp
  802657:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80265b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80265f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802663:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802667:	85 f6                	test   %esi,%esi
  802669:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80266d:	89 ca                	mov    %ecx,%edx
  80266f:	89 f8                	mov    %edi,%eax
  802671:	75 3d                	jne    8026b0 <__udivdi3+0x60>
  802673:	39 cf                	cmp    %ecx,%edi
  802675:	0f 87 c5 00 00 00    	ja     802740 <__udivdi3+0xf0>
  80267b:	85 ff                	test   %edi,%edi
  80267d:	89 fd                	mov    %edi,%ebp
  80267f:	75 0b                	jne    80268c <__udivdi3+0x3c>
  802681:	b8 01 00 00 00       	mov    $0x1,%eax
  802686:	31 d2                	xor    %edx,%edx
  802688:	f7 f7                	div    %edi
  80268a:	89 c5                	mov    %eax,%ebp
  80268c:	89 c8                	mov    %ecx,%eax
  80268e:	31 d2                	xor    %edx,%edx
  802690:	f7 f5                	div    %ebp
  802692:	89 c1                	mov    %eax,%ecx
  802694:	89 d8                	mov    %ebx,%eax
  802696:	89 cf                	mov    %ecx,%edi
  802698:	f7 f5                	div    %ebp
  80269a:	89 c3                	mov    %eax,%ebx
  80269c:	89 d8                	mov    %ebx,%eax
  80269e:	89 fa                	mov    %edi,%edx
  8026a0:	83 c4 1c             	add    $0x1c,%esp
  8026a3:	5b                   	pop    %ebx
  8026a4:	5e                   	pop    %esi
  8026a5:	5f                   	pop    %edi
  8026a6:	5d                   	pop    %ebp
  8026a7:	c3                   	ret    
  8026a8:	90                   	nop
  8026a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	39 ce                	cmp    %ecx,%esi
  8026b2:	77 74                	ja     802728 <__udivdi3+0xd8>
  8026b4:	0f bd fe             	bsr    %esi,%edi
  8026b7:	83 f7 1f             	xor    $0x1f,%edi
  8026ba:	0f 84 98 00 00 00    	je     802758 <__udivdi3+0x108>
  8026c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026c5:	89 f9                	mov    %edi,%ecx
  8026c7:	89 c5                	mov    %eax,%ebp
  8026c9:	29 fb                	sub    %edi,%ebx
  8026cb:	d3 e6                	shl    %cl,%esi
  8026cd:	89 d9                	mov    %ebx,%ecx
  8026cf:	d3 ed                	shr    %cl,%ebp
  8026d1:	89 f9                	mov    %edi,%ecx
  8026d3:	d3 e0                	shl    %cl,%eax
  8026d5:	09 ee                	or     %ebp,%esi
  8026d7:	89 d9                	mov    %ebx,%ecx
  8026d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026dd:	89 d5                	mov    %edx,%ebp
  8026df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026e3:	d3 ed                	shr    %cl,%ebp
  8026e5:	89 f9                	mov    %edi,%ecx
  8026e7:	d3 e2                	shl    %cl,%edx
  8026e9:	89 d9                	mov    %ebx,%ecx
  8026eb:	d3 e8                	shr    %cl,%eax
  8026ed:	09 c2                	or     %eax,%edx
  8026ef:	89 d0                	mov    %edx,%eax
  8026f1:	89 ea                	mov    %ebp,%edx
  8026f3:	f7 f6                	div    %esi
  8026f5:	89 d5                	mov    %edx,%ebp
  8026f7:	89 c3                	mov    %eax,%ebx
  8026f9:	f7 64 24 0c          	mull   0xc(%esp)
  8026fd:	39 d5                	cmp    %edx,%ebp
  8026ff:	72 10                	jb     802711 <__udivdi3+0xc1>
  802701:	8b 74 24 08          	mov    0x8(%esp),%esi
  802705:	89 f9                	mov    %edi,%ecx
  802707:	d3 e6                	shl    %cl,%esi
  802709:	39 c6                	cmp    %eax,%esi
  80270b:	73 07                	jae    802714 <__udivdi3+0xc4>
  80270d:	39 d5                	cmp    %edx,%ebp
  80270f:	75 03                	jne    802714 <__udivdi3+0xc4>
  802711:	83 eb 01             	sub    $0x1,%ebx
  802714:	31 ff                	xor    %edi,%edi
  802716:	89 d8                	mov    %ebx,%eax
  802718:	89 fa                	mov    %edi,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	31 ff                	xor    %edi,%edi
  80272a:	31 db                	xor    %ebx,%ebx
  80272c:	89 d8                	mov    %ebx,%eax
  80272e:	89 fa                	mov    %edi,%edx
  802730:	83 c4 1c             	add    $0x1c,%esp
  802733:	5b                   	pop    %ebx
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    
  802738:	90                   	nop
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	89 d8                	mov    %ebx,%eax
  802742:	f7 f7                	div    %edi
  802744:	31 ff                	xor    %edi,%edi
  802746:	89 c3                	mov    %eax,%ebx
  802748:	89 d8                	mov    %ebx,%eax
  80274a:	89 fa                	mov    %edi,%edx
  80274c:	83 c4 1c             	add    $0x1c,%esp
  80274f:	5b                   	pop    %ebx
  802750:	5e                   	pop    %esi
  802751:	5f                   	pop    %edi
  802752:	5d                   	pop    %ebp
  802753:	c3                   	ret    
  802754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802758:	39 ce                	cmp    %ecx,%esi
  80275a:	72 0c                	jb     802768 <__udivdi3+0x118>
  80275c:	31 db                	xor    %ebx,%ebx
  80275e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802762:	0f 87 34 ff ff ff    	ja     80269c <__udivdi3+0x4c>
  802768:	bb 01 00 00 00       	mov    $0x1,%ebx
  80276d:	e9 2a ff ff ff       	jmp    80269c <__udivdi3+0x4c>
  802772:	66 90                	xchg   %ax,%ax
  802774:	66 90                	xchg   %ax,%ax
  802776:	66 90                	xchg   %ax,%ax
  802778:	66 90                	xchg   %ax,%ax
  80277a:	66 90                	xchg   %ax,%ax
  80277c:	66 90                	xchg   %ax,%ax
  80277e:	66 90                	xchg   %ax,%ax

00802780 <__umoddi3>:
  802780:	55                   	push   %ebp
  802781:	57                   	push   %edi
  802782:	56                   	push   %esi
  802783:	53                   	push   %ebx
  802784:	83 ec 1c             	sub    $0x1c,%esp
  802787:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80278b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80278f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802793:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802797:	85 d2                	test   %edx,%edx
  802799:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80279d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027a1:	89 f3                	mov    %esi,%ebx
  8027a3:	89 3c 24             	mov    %edi,(%esp)
  8027a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027aa:	75 1c                	jne    8027c8 <__umoddi3+0x48>
  8027ac:	39 f7                	cmp    %esi,%edi
  8027ae:	76 50                	jbe    802800 <__umoddi3+0x80>
  8027b0:	89 c8                	mov    %ecx,%eax
  8027b2:	89 f2                	mov    %esi,%edx
  8027b4:	f7 f7                	div    %edi
  8027b6:	89 d0                	mov    %edx,%eax
  8027b8:	31 d2                	xor    %edx,%edx
  8027ba:	83 c4 1c             	add    $0x1c,%esp
  8027bd:	5b                   	pop    %ebx
  8027be:	5e                   	pop    %esi
  8027bf:	5f                   	pop    %edi
  8027c0:	5d                   	pop    %ebp
  8027c1:	c3                   	ret    
  8027c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027c8:	39 f2                	cmp    %esi,%edx
  8027ca:	89 d0                	mov    %edx,%eax
  8027cc:	77 52                	ja     802820 <__umoddi3+0xa0>
  8027ce:	0f bd ea             	bsr    %edx,%ebp
  8027d1:	83 f5 1f             	xor    $0x1f,%ebp
  8027d4:	75 5a                	jne    802830 <__umoddi3+0xb0>
  8027d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027da:	0f 82 e0 00 00 00    	jb     8028c0 <__umoddi3+0x140>
  8027e0:	39 0c 24             	cmp    %ecx,(%esp)
  8027e3:	0f 86 d7 00 00 00    	jbe    8028c0 <__umoddi3+0x140>
  8027e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027f1:	83 c4 1c             	add    $0x1c,%esp
  8027f4:	5b                   	pop    %ebx
  8027f5:	5e                   	pop    %esi
  8027f6:	5f                   	pop    %edi
  8027f7:	5d                   	pop    %ebp
  8027f8:	c3                   	ret    
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	85 ff                	test   %edi,%edi
  802802:	89 fd                	mov    %edi,%ebp
  802804:	75 0b                	jne    802811 <__umoddi3+0x91>
  802806:	b8 01 00 00 00       	mov    $0x1,%eax
  80280b:	31 d2                	xor    %edx,%edx
  80280d:	f7 f7                	div    %edi
  80280f:	89 c5                	mov    %eax,%ebp
  802811:	89 f0                	mov    %esi,%eax
  802813:	31 d2                	xor    %edx,%edx
  802815:	f7 f5                	div    %ebp
  802817:	89 c8                	mov    %ecx,%eax
  802819:	f7 f5                	div    %ebp
  80281b:	89 d0                	mov    %edx,%eax
  80281d:	eb 99                	jmp    8027b8 <__umoddi3+0x38>
  80281f:	90                   	nop
  802820:	89 c8                	mov    %ecx,%eax
  802822:	89 f2                	mov    %esi,%edx
  802824:	83 c4 1c             	add    $0x1c,%esp
  802827:	5b                   	pop    %ebx
  802828:	5e                   	pop    %esi
  802829:	5f                   	pop    %edi
  80282a:	5d                   	pop    %ebp
  80282b:	c3                   	ret    
  80282c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802830:	8b 34 24             	mov    (%esp),%esi
  802833:	bf 20 00 00 00       	mov    $0x20,%edi
  802838:	89 e9                	mov    %ebp,%ecx
  80283a:	29 ef                	sub    %ebp,%edi
  80283c:	d3 e0                	shl    %cl,%eax
  80283e:	89 f9                	mov    %edi,%ecx
  802840:	89 f2                	mov    %esi,%edx
  802842:	d3 ea                	shr    %cl,%edx
  802844:	89 e9                	mov    %ebp,%ecx
  802846:	09 c2                	or     %eax,%edx
  802848:	89 d8                	mov    %ebx,%eax
  80284a:	89 14 24             	mov    %edx,(%esp)
  80284d:	89 f2                	mov    %esi,%edx
  80284f:	d3 e2                	shl    %cl,%edx
  802851:	89 f9                	mov    %edi,%ecx
  802853:	89 54 24 04          	mov    %edx,0x4(%esp)
  802857:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80285b:	d3 e8                	shr    %cl,%eax
  80285d:	89 e9                	mov    %ebp,%ecx
  80285f:	89 c6                	mov    %eax,%esi
  802861:	d3 e3                	shl    %cl,%ebx
  802863:	89 f9                	mov    %edi,%ecx
  802865:	89 d0                	mov    %edx,%eax
  802867:	d3 e8                	shr    %cl,%eax
  802869:	89 e9                	mov    %ebp,%ecx
  80286b:	09 d8                	or     %ebx,%eax
  80286d:	89 d3                	mov    %edx,%ebx
  80286f:	89 f2                	mov    %esi,%edx
  802871:	f7 34 24             	divl   (%esp)
  802874:	89 d6                	mov    %edx,%esi
  802876:	d3 e3                	shl    %cl,%ebx
  802878:	f7 64 24 04          	mull   0x4(%esp)
  80287c:	39 d6                	cmp    %edx,%esi
  80287e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802882:	89 d1                	mov    %edx,%ecx
  802884:	89 c3                	mov    %eax,%ebx
  802886:	72 08                	jb     802890 <__umoddi3+0x110>
  802888:	75 11                	jne    80289b <__umoddi3+0x11b>
  80288a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80288e:	73 0b                	jae    80289b <__umoddi3+0x11b>
  802890:	2b 44 24 04          	sub    0x4(%esp),%eax
  802894:	1b 14 24             	sbb    (%esp),%edx
  802897:	89 d1                	mov    %edx,%ecx
  802899:	89 c3                	mov    %eax,%ebx
  80289b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80289f:	29 da                	sub    %ebx,%edx
  8028a1:	19 ce                	sbb    %ecx,%esi
  8028a3:	89 f9                	mov    %edi,%ecx
  8028a5:	89 f0                	mov    %esi,%eax
  8028a7:	d3 e0                	shl    %cl,%eax
  8028a9:	89 e9                	mov    %ebp,%ecx
  8028ab:	d3 ea                	shr    %cl,%edx
  8028ad:	89 e9                	mov    %ebp,%ecx
  8028af:	d3 ee                	shr    %cl,%esi
  8028b1:	09 d0                	or     %edx,%eax
  8028b3:	89 f2                	mov    %esi,%edx
  8028b5:	83 c4 1c             	add    $0x1c,%esp
  8028b8:	5b                   	pop    %ebx
  8028b9:	5e                   	pop    %esi
  8028ba:	5f                   	pop    %edi
  8028bb:	5d                   	pop    %ebp
  8028bc:	c3                   	ret    
  8028bd:	8d 76 00             	lea    0x0(%esi),%esi
  8028c0:	29 f9                	sub    %edi,%ecx
  8028c2:	19 d6                	sbb    %edx,%esi
  8028c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028cc:	e9 18 ff ff ff       	jmp    8027e9 <__umoddi3+0x69>
