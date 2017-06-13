
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 94 18 00 00       	call   8018e3 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 8a 18 00 00       	call   8018e3 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 6b 2f 80 00 	movl   $0x802f6b,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 26 0e 00 00       	call   800ea9 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 eb 16 00 00       	call   80177d <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 7a 2f 80 00       	push   $0x802f7a
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 f1 0d 00 00       	call   800ea9 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 b6 16 00 00       	call   80177d <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 75 2f 80 00       	push   $0x802f75
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 46 15 00 00       	call   801641 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 3a 15 00 00       	call   801641 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 88 2f 80 00       	push   $0x802f88
  80011b:	e8 f4 1a 00 00       	call   801c14 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 95 2f 80 00       	push   $0x802f95
  80012f:	6a 13                	push   $0x13
  800131:	68 ab 2f 80 00       	push   $0x802fab
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 11 23 00 00       	call   802458 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 bc 2f 80 00       	push   $0x802fbc
  800154:	6a 15                	push   $0x15
  800156:	68 ab 2f 80 00       	push   $0x802fab
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 24 2f 80 00       	push   $0x802f24
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 f4 10 00 00       	call   801269 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 c5 2f 80 00       	push   $0x802fc5
  800182:	6a 1a                	push   $0x1a
  800184:	68 ab 2f 80 00       	push   $0x802fab
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 f4 14 00 00       	call   801691 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 e9 14 00 00       	call   801691 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 91 14 00 00       	call   801641 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 89 14 00 00       	call   801641 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 ce 2f 80 00       	push   $0x802fce
  8001bf:	68 92 2f 80 00       	push   $0x802f92
  8001c4:	68 d1 2f 80 00       	push   $0x802fd1
  8001c9:	e8 41 20 00 00       	call   80220f <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 d5 2f 80 00       	push   $0x802fd5
  8001dd:	6a 21                	push   $0x21
  8001df:	68 ab 2f 80 00       	push   $0x802fab
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 4e 14 00 00       	call   801641 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 42 14 00 00       	call   801641 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 d7 23 00 00       	call   8025de <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 29 14 00 00       	call   801641 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 21 14 00 00       	call   801641 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 df 2f 80 00       	push   $0x802fdf
  800230:	e8 df 19 00 00       	call   801c14 <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 48 2f 80 00       	push   $0x802f48
  800245:	6a 2c                	push   $0x2c
  800247:	68 ab 2f 80 00       	push   $0x802fab
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 11 15 00 00       	call   80177d <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 fe 14 00 00       	call   80177d <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 ed 2f 80 00       	push   $0x802fed
  80028c:	6a 33                	push   $0x33
  80028e:	68 ab 2f 80 00       	push   $0x802fab
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 07 30 80 00       	push   $0x803007
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 ab 2f 80 00       	push   $0x802fab
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 21 30 80 00       	push   $0x803021
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 36 30 80 00       	push   $0x803036
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 44 08 00 00       	call   800b62 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 98 09 00 00       	call   800cf4 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 43 0b 00 00       	call   800ea9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 b4 0b 00 00       	call   800f46 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 30 0b 00 00       	call   800ec7 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 db 0a 00 00       	call   800ea9 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 97 13 00 00       	call   80177d <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 07 11 00 00       	call   801517 <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 8f 10 00 00       	call   8014c8 <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 11 0b 00 00       	call   800f65 <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 26 10 00 00       	call   8014a1 <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80048f:	e8 93 0a 00 00       	call   800f27 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 08 50 80 00       	mov    %eax,0x805008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 97 11 00 00       	call   80166c <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 07 0a 00 00       	call   800ee6 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 30 0a 00 00       	call   800f27 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 4c 30 80 00       	push   $0x80304c
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 78 2f 80 00 	movl   $0x802f78,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 4f 09 00 00       	call   800ea9 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 54 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 f4 08 00 00       	call   800ea9 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 4b 26 00 00       	call   802c70 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 38 27 00 00       	call   802da0 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 6f 30 80 00 	movsbl 0x80306f(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 05 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 2c             	sub    $0x2c,%esp
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	8b 7d 10             	mov    0x10(%ebp),%edi
  800706:	eb 12                	jmp    80071a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 a9 03 00 00    	je     800ab9 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e2                	jne    800708 <vprintfmt+0x14>
  800726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800731:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 07                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800749:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8d 47 01             	lea    0x1(%edi),%eax
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800753:	0f b6 07             	movzbl (%edi),%eax
  800756:	0f b6 c8             	movzbl %al,%ecx
  800759:	83 e8 23             	sub    $0x23,%eax
  80075c:	3c 55                	cmp    $0x55,%al
  80075e:	0f 87 3a 03 00 00    	ja     800a9e <vprintfmt+0x3aa>
  800764:	0f b6 c0             	movzbl %al,%eax
  800767:	ff 24 85 c0 31 80 00 	jmp    *0x8031c0(,%eax,4)
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800771:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800775:	eb d6                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800782:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800785:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800789:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80078c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80078f:	83 fa 09             	cmp    $0x9,%edx
  800792:	77 39                	ja     8007cd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800794:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800797:	eb e9                	jmp    800782 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 48 04             	lea    0x4(%eax),%ecx
  80079f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007aa:	eb 27                	jmp    8007d3 <vprintfmt+0xdf>
  8007ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	0f 49 c8             	cmovns %eax,%ecx
  8007b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bf:	eb 8c                	jmp    80074d <vprintfmt+0x59>
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007cb:	eb 80                	jmp    80074d <vprintfmt+0x59>
  8007cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d7:	0f 89 70 ff ff ff    	jns    80074d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ea:	e9 5e ff ff ff       	jmp    80074d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ef:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f5:	e9 53 ff ff ff       	jmp    80074d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	ff 30                	pushl  (%eax)
  800809:	ff d6                	call   *%esi
			break;
  80080b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800811:	e9 04 ff ff ff       	jmp    80071a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	99                   	cltd   
  800822:	31 d0                	xor    %edx,%eax
  800824:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800826:	83 f8 0f             	cmp    $0xf,%eax
  800829:	7f 0b                	jg     800836 <vprintfmt+0x142>
  80082b:	8b 14 85 20 33 80 00 	mov    0x803320(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 87 30 80 00       	push   $0x803087
  80083c:	53                   	push   %ebx
  80083d:	56                   	push   %esi
  80083e:	e8 94 fe ff ff       	call   8006d7 <printfmt>
  800843:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800849:	e9 cc fe ff ff       	jmp    80071a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80084e:	52                   	push   %edx
  80084f:	68 29 35 80 00       	push   $0x803529
  800854:	53                   	push   %ebx
  800855:	56                   	push   %esi
  800856:	e8 7c fe ff ff       	call   8006d7 <printfmt>
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800861:	e9 b4 fe ff ff       	jmp    80071a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800871:	85 ff                	test   %edi,%edi
  800873:	b8 80 30 80 00       	mov    $0x803080,%eax
  800878:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80087b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80087f:	0f 8e 94 00 00 00    	jle    800919 <vprintfmt+0x225>
  800885:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800889:	0f 84 98 00 00 00    	je     800927 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	ff 75 d0             	pushl  -0x30(%ebp)
  800895:	57                   	push   %edi
  800896:	e8 a6 02 00 00       	call   800b41 <strnlen>
  80089b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80089e:	29 c1                	sub    %eax,%ecx
  8008a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b2:	eb 0f                	jmp    8008c3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	85 ff                	test   %edi,%edi
  8008c5:	7f ed                	jg     8008b4 <vprintfmt+0x1c0>
  8008c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	0f 49 c1             	cmovns %ecx,%eax
  8008d7:	29 c1                	sub    %eax,%ecx
  8008d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e2:	89 cb                	mov    %ecx,%ebx
  8008e4:	eb 4d                	jmp    800933 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ea:	74 1b                	je     800907 <vprintfmt+0x213>
  8008ec:	0f be c0             	movsbl %al,%eax
  8008ef:	83 e8 20             	sub    $0x20,%eax
  8008f2:	83 f8 5e             	cmp    $0x5e,%eax
  8008f5:	76 10                	jbe    800907 <vprintfmt+0x213>
					putch('?', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	6a 3f                	push   $0x3f
  8008ff:	ff 55 08             	call   *0x8(%ebp)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 0d                	jmp    800914 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	52                   	push   %edx
  80090e:	ff 55 08             	call   *0x8(%ebp)
  800911:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800914:	83 eb 01             	sub    $0x1,%ebx
  800917:	eb 1a                	jmp    800933 <vprintfmt+0x23f>
  800919:	89 75 08             	mov    %esi,0x8(%ebp)
  80091c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80091f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800925:	eb 0c                	jmp    800933 <vprintfmt+0x23f>
  800927:	89 75 08             	mov    %esi,0x8(%ebp)
  80092a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80092d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800930:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800933:	83 c7 01             	add    $0x1,%edi
  800936:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093a:	0f be d0             	movsbl %al,%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 23                	je     800964 <vprintfmt+0x270>
  800941:	85 f6                	test   %esi,%esi
  800943:	78 a1                	js     8008e6 <vprintfmt+0x1f2>
  800945:	83 ee 01             	sub    $0x1,%esi
  800948:	79 9c                	jns    8008e6 <vprintfmt+0x1f2>
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800952:	eb 18                	jmp    80096c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 20                	push   $0x20
  80095a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	eb 08                	jmp    80096c <vprintfmt+0x278>
  800964:	89 df                	mov    %ebx,%edi
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096c:	85 ff                	test   %edi,%edi
  80096e:	7f e4                	jg     800954 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	e9 a2 fd ff ff       	jmp    80071a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800978:	83 fa 01             	cmp    $0x1,%edx
  80097b:	7e 16                	jle    800993 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 08             	lea    0x8(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 50 04             	mov    0x4(%eax),%edx
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800991:	eb 32                	jmp    8009c5 <vprintfmt+0x2d1>
	else if (lflag)
  800993:	85 d2                	test   %edx,%edx
  800995:	74 18                	je     8009af <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a5:	89 c1                	mov    %eax,%ecx
  8009a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009ad:	eb 16                	jmp    8009c5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bd:	89 c1                	mov    %eax,%ecx
  8009bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d4:	0f 89 90 00 00 00    	jns    800a6a <vprintfmt+0x376>
				putch('-', putdat);
  8009da:	83 ec 08             	sub    $0x8,%esp
  8009dd:	53                   	push   %ebx
  8009de:	6a 2d                	push   $0x2d
  8009e0:	ff d6                	call   *%esi
				num = -(long long) num;
  8009e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e8:	f7 d8                	neg    %eax
  8009ea:	83 d2 00             	adc    $0x0,%edx
  8009ed:	f7 da                	neg    %edx
  8009ef:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f7:	eb 71                	jmp    800a6a <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fc:	e8 7f fc ff ff       	call   800680 <getuint>
			base = 10;
  800a01:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a06:	eb 62                	jmp    800a6a <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a08:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0b:	e8 70 fc ff ff       	call   800680 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800a10:	83 ec 0c             	sub    $0xc,%esp
  800a13:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800a17:	51                   	push   %ecx
  800a18:	ff 75 e0             	pushl  -0x20(%ebp)
  800a1b:	6a 08                	push   $0x8
  800a1d:	52                   	push   %edx
  800a1e:	50                   	push   %eax
  800a1f:	89 da                	mov    %ebx,%edx
  800a21:	89 f0                	mov    %esi,%eax
  800a23:	e8 a9 fb ff ff       	call   8005d1 <printnum>
			break;
  800a28:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800a2e:	e9 e7 fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	53                   	push   %ebx
  800a37:	6a 30                	push   $0x30
  800a39:	ff d6                	call   *%esi
			putch('x', putdat);
  800a3b:	83 c4 08             	add    $0x8,%esp
  800a3e:	53                   	push   %ebx
  800a3f:	6a 78                	push   $0x78
  800a41:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a43:	8b 45 14             	mov    0x14(%ebp),%eax
  800a46:	8d 50 04             	lea    0x4(%eax),%edx
  800a49:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a4c:	8b 00                	mov    (%eax),%eax
  800a4e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a53:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a56:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a5b:	eb 0d                	jmp    800a6a <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a5d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a60:	e8 1b fc ff ff       	call   800680 <getuint>
			base = 16;
  800a65:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a6a:	83 ec 0c             	sub    $0xc,%esp
  800a6d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a71:	57                   	push   %edi
  800a72:	ff 75 e0             	pushl  -0x20(%ebp)
  800a75:	51                   	push   %ecx
  800a76:	52                   	push   %edx
  800a77:	50                   	push   %eax
  800a78:	89 da                	mov    %ebx,%edx
  800a7a:	89 f0                	mov    %esi,%eax
  800a7c:	e8 50 fb ff ff       	call   8005d1 <printnum>
			break;
  800a81:	83 c4 20             	add    $0x20,%esp
  800a84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a87:	e9 8e fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a8c:	83 ec 08             	sub    $0x8,%esp
  800a8f:	53                   	push   %ebx
  800a90:	51                   	push   %ecx
  800a91:	ff d6                	call   *%esi
			break;
  800a93:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a99:	e9 7c fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a9e:	83 ec 08             	sub    $0x8,%esp
  800aa1:	53                   	push   %ebx
  800aa2:	6a 25                	push   $0x25
  800aa4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	eb 03                	jmp    800aae <vprintfmt+0x3ba>
  800aab:	83 ef 01             	sub    $0x1,%edi
  800aae:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ab2:	75 f7                	jne    800aab <vprintfmt+0x3b7>
  800ab4:	e9 61 fc ff ff       	jmp    80071a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ab9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	83 ec 18             	sub    $0x18,%esp
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800acd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ad0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ad4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ad7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	74 26                	je     800b08 <vsnprintf+0x47>
  800ae2:	85 d2                	test   %edx,%edx
  800ae4:	7e 22                	jle    800b08 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae6:	ff 75 14             	pushl  0x14(%ebp)
  800ae9:	ff 75 10             	pushl  0x10(%ebp)
  800aec:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aef:	50                   	push   %eax
  800af0:	68 ba 06 80 00       	push   $0x8006ba
  800af5:	e8 fa fb ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800afa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800afd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	eb 05                	jmp    800b0d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b15:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b18:	50                   	push   %eax
  800b19:	ff 75 10             	pushl  0x10(%ebp)
  800b1c:	ff 75 0c             	pushl  0xc(%ebp)
  800b1f:	ff 75 08             	pushl  0x8(%ebp)
  800b22:	e8 9a ff ff ff       	call   800ac1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b27:	c9                   	leave  
  800b28:	c3                   	ret    

00800b29 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b34:	eb 03                	jmp    800b39 <strlen+0x10>
		n++;
  800b36:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b39:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b3d:	75 f7                	jne    800b36 <strlen+0xd>
		n++;
	return n;
}
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b47:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4f:	eb 03                	jmp    800b54 <strnlen+0x13>
		n++;
  800b51:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b54:	39 c2                	cmp    %eax,%edx
  800b56:	74 08                	je     800b60 <strnlen+0x1f>
  800b58:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b5c:	75 f3                	jne    800b51 <strnlen+0x10>
  800b5e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 45 08             	mov    0x8(%ebp),%eax
  800b69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b6c:	89 c2                	mov    %eax,%edx
  800b6e:	83 c2 01             	add    $0x1,%edx
  800b71:	83 c1 01             	add    $0x1,%ecx
  800b74:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b78:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b7b:	84 db                	test   %bl,%bl
  800b7d:	75 ef                	jne    800b6e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	53                   	push   %ebx
  800b86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b89:	53                   	push   %ebx
  800b8a:	e8 9a ff ff ff       	call   800b29 <strlen>
  800b8f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b92:	ff 75 0c             	pushl  0xc(%ebp)
  800b95:	01 d8                	add    %ebx,%eax
  800b97:	50                   	push   %eax
  800b98:	e8 c5 ff ff ff       	call   800b62 <strcpy>
	return dst;
}
  800b9d:	89 d8                	mov    %ebx,%eax
  800b9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baf:	89 f3                	mov    %esi,%ebx
  800bb1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bb4:	89 f2                	mov    %esi,%edx
  800bb6:	eb 0f                	jmp    800bc7 <strncpy+0x23>
		*dst++ = *src;
  800bb8:	83 c2 01             	add    $0x1,%edx
  800bbb:	0f b6 01             	movzbl (%ecx),%eax
  800bbe:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bc1:	80 39 01             	cmpb   $0x1,(%ecx)
  800bc4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bc7:	39 da                	cmp    %ebx,%edx
  800bc9:	75 ed                	jne    800bb8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bcb:	89 f0                	mov    %esi,%eax
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdc:	8b 55 10             	mov    0x10(%ebp),%edx
  800bdf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800be1:	85 d2                	test   %edx,%edx
  800be3:	74 21                	je     800c06 <strlcpy+0x35>
  800be5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800be9:	89 f2                	mov    %esi,%edx
  800beb:	eb 09                	jmp    800bf6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bed:	83 c2 01             	add    $0x1,%edx
  800bf0:	83 c1 01             	add    $0x1,%ecx
  800bf3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bf6:	39 c2                	cmp    %eax,%edx
  800bf8:	74 09                	je     800c03 <strlcpy+0x32>
  800bfa:	0f b6 19             	movzbl (%ecx),%ebx
  800bfd:	84 db                	test   %bl,%bl
  800bff:	75 ec                	jne    800bed <strlcpy+0x1c>
  800c01:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c03:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c06:	29 f0                	sub    %esi,%eax
}
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c12:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c15:	eb 06                	jmp    800c1d <strcmp+0x11>
		p++, q++;
  800c17:	83 c1 01             	add    $0x1,%ecx
  800c1a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c1d:	0f b6 01             	movzbl (%ecx),%eax
  800c20:	84 c0                	test   %al,%al
  800c22:	74 04                	je     800c28 <strcmp+0x1c>
  800c24:	3a 02                	cmp    (%edx),%al
  800c26:	74 ef                	je     800c17 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c28:	0f b6 c0             	movzbl %al,%eax
  800c2b:	0f b6 12             	movzbl (%edx),%edx
  800c2e:	29 d0                	sub    %edx,%eax
}
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	53                   	push   %ebx
  800c36:	8b 45 08             	mov    0x8(%ebp),%eax
  800c39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3c:	89 c3                	mov    %eax,%ebx
  800c3e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c41:	eb 06                	jmp    800c49 <strncmp+0x17>
		n--, p++, q++;
  800c43:	83 c0 01             	add    $0x1,%eax
  800c46:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c49:	39 d8                	cmp    %ebx,%eax
  800c4b:	74 15                	je     800c62 <strncmp+0x30>
  800c4d:	0f b6 08             	movzbl (%eax),%ecx
  800c50:	84 c9                	test   %cl,%cl
  800c52:	74 04                	je     800c58 <strncmp+0x26>
  800c54:	3a 0a                	cmp    (%edx),%cl
  800c56:	74 eb                	je     800c43 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c58:	0f b6 00             	movzbl (%eax),%eax
  800c5b:	0f b6 12             	movzbl (%edx),%edx
  800c5e:	29 d0                	sub    %edx,%eax
  800c60:	eb 05                	jmp    800c67 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c62:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c67:	5b                   	pop    %ebx
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c74:	eb 07                	jmp    800c7d <strchr+0x13>
		if (*s == c)
  800c76:	38 ca                	cmp    %cl,%dl
  800c78:	74 0f                	je     800c89 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c7a:	83 c0 01             	add    $0x1,%eax
  800c7d:	0f b6 10             	movzbl (%eax),%edx
  800c80:	84 d2                	test   %dl,%dl
  800c82:	75 f2                	jne    800c76 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c95:	eb 03                	jmp    800c9a <strfind+0xf>
  800c97:	83 c0 01             	add    $0x1,%eax
  800c9a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c9d:	38 ca                	cmp    %cl,%dl
  800c9f:	74 04                	je     800ca5 <strfind+0x1a>
  800ca1:	84 d2                	test   %dl,%dl
  800ca3:	75 f2                	jne    800c97 <strfind+0xc>
			break;
	return (char *) s;
}
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cb0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cb3:	85 c9                	test   %ecx,%ecx
  800cb5:	74 36                	je     800ced <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cb7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cbd:	75 28                	jne    800ce7 <memset+0x40>
  800cbf:	f6 c1 03             	test   $0x3,%cl
  800cc2:	75 23                	jne    800ce7 <memset+0x40>
		c &= 0xFF;
  800cc4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cc8:	89 d3                	mov    %edx,%ebx
  800cca:	c1 e3 08             	shl    $0x8,%ebx
  800ccd:	89 d6                	mov    %edx,%esi
  800ccf:	c1 e6 18             	shl    $0x18,%esi
  800cd2:	89 d0                	mov    %edx,%eax
  800cd4:	c1 e0 10             	shl    $0x10,%eax
  800cd7:	09 f0                	or     %esi,%eax
  800cd9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cdb:	89 d8                	mov    %ebx,%eax
  800cdd:	09 d0                	or     %edx,%eax
  800cdf:	c1 e9 02             	shr    $0x2,%ecx
  800ce2:	fc                   	cld    
  800ce3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ce5:	eb 06                	jmp    800ced <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cea:	fc                   	cld    
  800ceb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ced:	89 f8                	mov    %edi,%eax
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d02:	39 c6                	cmp    %eax,%esi
  800d04:	73 35                	jae    800d3b <memmove+0x47>
  800d06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d09:	39 d0                	cmp    %edx,%eax
  800d0b:	73 2e                	jae    800d3b <memmove+0x47>
		s += n;
		d += n;
  800d0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d10:	89 d6                	mov    %edx,%esi
  800d12:	09 fe                	or     %edi,%esi
  800d14:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d1a:	75 13                	jne    800d2f <memmove+0x3b>
  800d1c:	f6 c1 03             	test   $0x3,%cl
  800d1f:	75 0e                	jne    800d2f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d21:	83 ef 04             	sub    $0x4,%edi
  800d24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d27:	c1 e9 02             	shr    $0x2,%ecx
  800d2a:	fd                   	std    
  800d2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d2d:	eb 09                	jmp    800d38 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d2f:	83 ef 01             	sub    $0x1,%edi
  800d32:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d35:	fd                   	std    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d38:	fc                   	cld    
  800d39:	eb 1d                	jmp    800d58 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d3b:	89 f2                	mov    %esi,%edx
  800d3d:	09 c2                	or     %eax,%edx
  800d3f:	f6 c2 03             	test   $0x3,%dl
  800d42:	75 0f                	jne    800d53 <memmove+0x5f>
  800d44:	f6 c1 03             	test   $0x3,%cl
  800d47:	75 0a                	jne    800d53 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d49:	c1 e9 02             	shr    $0x2,%ecx
  800d4c:	89 c7                	mov    %eax,%edi
  800d4e:	fc                   	cld    
  800d4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d51:	eb 05                	jmp    800d58 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d53:	89 c7                	mov    %eax,%edi
  800d55:	fc                   	cld    
  800d56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d5f:	ff 75 10             	pushl  0x10(%ebp)
  800d62:	ff 75 0c             	pushl  0xc(%ebp)
  800d65:	ff 75 08             	pushl  0x8(%ebp)
  800d68:	e8 87 ff ff ff       	call   800cf4 <memmove>
}
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	8b 45 08             	mov    0x8(%ebp),%eax
  800d77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d7a:	89 c6                	mov    %eax,%esi
  800d7c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7f:	eb 1a                	jmp    800d9b <memcmp+0x2c>
		if (*s1 != *s2)
  800d81:	0f b6 08             	movzbl (%eax),%ecx
  800d84:	0f b6 1a             	movzbl (%edx),%ebx
  800d87:	38 d9                	cmp    %bl,%cl
  800d89:	74 0a                	je     800d95 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d8b:	0f b6 c1             	movzbl %cl,%eax
  800d8e:	0f b6 db             	movzbl %bl,%ebx
  800d91:	29 d8                	sub    %ebx,%eax
  800d93:	eb 0f                	jmp    800da4 <memcmp+0x35>
		s1++, s2++;
  800d95:	83 c0 01             	add    $0x1,%eax
  800d98:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d9b:	39 f0                	cmp    %esi,%eax
  800d9d:	75 e2                	jne    800d81 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	53                   	push   %ebx
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800daf:	89 c1                	mov    %eax,%ecx
  800db1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800db4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800db8:	eb 0a                	jmp    800dc4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dba:	0f b6 10             	movzbl (%eax),%edx
  800dbd:	39 da                	cmp    %ebx,%edx
  800dbf:	74 07                	je     800dc8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dc1:	83 c0 01             	add    $0x1,%eax
  800dc4:	39 c8                	cmp    %ecx,%eax
  800dc6:	72 f2                	jb     800dba <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dd7:	eb 03                	jmp    800ddc <strtol+0x11>
		s++;
  800dd9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ddc:	0f b6 01             	movzbl (%ecx),%eax
  800ddf:	3c 20                	cmp    $0x20,%al
  800de1:	74 f6                	je     800dd9 <strtol+0xe>
  800de3:	3c 09                	cmp    $0x9,%al
  800de5:	74 f2                	je     800dd9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800de7:	3c 2b                	cmp    $0x2b,%al
  800de9:	75 0a                	jne    800df5 <strtol+0x2a>
		s++;
  800deb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dee:	bf 00 00 00 00       	mov    $0x0,%edi
  800df3:	eb 11                	jmp    800e06 <strtol+0x3b>
  800df5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dfa:	3c 2d                	cmp    $0x2d,%al
  800dfc:	75 08                	jne    800e06 <strtol+0x3b>
		s++, neg = 1;
  800dfe:	83 c1 01             	add    $0x1,%ecx
  800e01:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e06:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e0c:	75 15                	jne    800e23 <strtol+0x58>
  800e0e:	80 39 30             	cmpb   $0x30,(%ecx)
  800e11:	75 10                	jne    800e23 <strtol+0x58>
  800e13:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e17:	75 7c                	jne    800e95 <strtol+0xca>
		s += 2, base = 16;
  800e19:	83 c1 02             	add    $0x2,%ecx
  800e1c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e21:	eb 16                	jmp    800e39 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e23:	85 db                	test   %ebx,%ebx
  800e25:	75 12                	jne    800e39 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e27:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e2c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e2f:	75 08                	jne    800e39 <strtol+0x6e>
		s++, base = 8;
  800e31:	83 c1 01             	add    $0x1,%ecx
  800e34:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e39:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e41:	0f b6 11             	movzbl (%ecx),%edx
  800e44:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e47:	89 f3                	mov    %esi,%ebx
  800e49:	80 fb 09             	cmp    $0x9,%bl
  800e4c:	77 08                	ja     800e56 <strtol+0x8b>
			dig = *s - '0';
  800e4e:	0f be d2             	movsbl %dl,%edx
  800e51:	83 ea 30             	sub    $0x30,%edx
  800e54:	eb 22                	jmp    800e78 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e56:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e59:	89 f3                	mov    %esi,%ebx
  800e5b:	80 fb 19             	cmp    $0x19,%bl
  800e5e:	77 08                	ja     800e68 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e60:	0f be d2             	movsbl %dl,%edx
  800e63:	83 ea 57             	sub    $0x57,%edx
  800e66:	eb 10                	jmp    800e78 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e68:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e6b:	89 f3                	mov    %esi,%ebx
  800e6d:	80 fb 19             	cmp    $0x19,%bl
  800e70:	77 16                	ja     800e88 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e72:	0f be d2             	movsbl %dl,%edx
  800e75:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e78:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e7b:	7d 0b                	jge    800e88 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e7d:	83 c1 01             	add    $0x1,%ecx
  800e80:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e84:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e86:	eb b9                	jmp    800e41 <strtol+0x76>

	if (endptr)
  800e88:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e8c:	74 0d                	je     800e9b <strtol+0xd0>
		*endptr = (char *) s;
  800e8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e91:	89 0e                	mov    %ecx,(%esi)
  800e93:	eb 06                	jmp    800e9b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e95:	85 db                	test   %ebx,%ebx
  800e97:	74 98                	je     800e31 <strtol+0x66>
  800e99:	eb 9e                	jmp    800e39 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e9b:	89 c2                	mov    %eax,%edx
  800e9d:	f7 da                	neg    %edx
  800e9f:	85 ff                	test   %edi,%edi
  800ea1:	0f 45 c2             	cmovne %edx,%eax
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eba:	89 c3                	mov    %eax,%ebx
  800ebc:	89 c7                	mov    %eax,%edi
  800ebe:	89 c6                	mov    %eax,%esi
  800ec0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed7:	89 d1                	mov    %edx,%ecx
  800ed9:	89 d3                	mov    %edx,%ebx
  800edb:	89 d7                	mov    %edx,%edi
  800edd:	89 d6                	mov    %edx,%esi
  800edf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ef9:	8b 55 08             	mov    0x8(%ebp),%edx
  800efc:	89 cb                	mov    %ecx,%ebx
  800efe:	89 cf                	mov    %ecx,%edi
  800f00:	89 ce                	mov    %ecx,%esi
  800f02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7e 17                	jle    800f1f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	50                   	push   %eax
  800f0c:	6a 03                	push   $0x3
  800f0e:	68 7f 33 80 00       	push   $0x80337f
  800f13:	6a 23                	push   $0x23
  800f15:	68 9c 33 80 00       	push   $0x80339c
  800f1a:	e8 c5 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f32:	b8 02 00 00 00       	mov    $0x2,%eax
  800f37:	89 d1                	mov    %edx,%ecx
  800f39:	89 d3                	mov    %edx,%ebx
  800f3b:	89 d7                	mov    %edx,%edi
  800f3d:	89 d6                	mov    %edx,%esi
  800f3f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <sys_yield>:

void
sys_yield(void)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f51:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f56:	89 d1                	mov    %edx,%ecx
  800f58:	89 d3                	mov    %edx,%ebx
  800f5a:	89 d7                	mov    %edx,%edi
  800f5c:	89 d6                	mov    %edx,%esi
  800f5e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
  800f6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6e:	be 00 00 00 00       	mov    $0x0,%esi
  800f73:	b8 04 00 00 00       	mov    $0x4,%eax
  800f78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f81:	89 f7                	mov    %esi,%edi
  800f83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f85:	85 c0                	test   %eax,%eax
  800f87:	7e 17                	jle    800fa0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f89:	83 ec 0c             	sub    $0xc,%esp
  800f8c:	50                   	push   %eax
  800f8d:	6a 04                	push   $0x4
  800f8f:	68 7f 33 80 00       	push   $0x80337f
  800f94:	6a 23                	push   $0x23
  800f96:	68 9c 33 80 00       	push   $0x80339c
  800f9b:	e8 44 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa3:	5b                   	pop    %ebx
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
  800fae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb1:	b8 05 00 00 00       	mov    $0x5,%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc2:	8b 75 18             	mov    0x18(%ebp),%esi
  800fc5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	7e 17                	jle    800fe2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcb:	83 ec 0c             	sub    $0xc,%esp
  800fce:	50                   	push   %eax
  800fcf:	6a 05                	push   $0x5
  800fd1:	68 7f 33 80 00       	push   $0x80337f
  800fd6:	6a 23                	push   $0x23
  800fd8:	68 9c 33 80 00       	push   $0x80339c
  800fdd:	e8 02 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fe2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe5:	5b                   	pop    %ebx
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
  800ff0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ffd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	89 df                	mov    %ebx,%edi
  801005:	89 de                	mov    %ebx,%esi
  801007:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801009:	85 c0                	test   %eax,%eax
  80100b:	7e 17                	jle    801024 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	50                   	push   %eax
  801011:	6a 06                	push   $0x6
  801013:	68 7f 33 80 00       	push   $0x80337f
  801018:	6a 23                	push   $0x23
  80101a:	68 9c 33 80 00       	push   $0x80339c
  80101f:	e8 c0 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	53                   	push   %ebx
  801032:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801035:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103a:	b8 08 00 00 00       	mov    $0x8,%eax
  80103f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801042:	8b 55 08             	mov    0x8(%ebp),%edx
  801045:	89 df                	mov    %ebx,%edi
  801047:	89 de                	mov    %ebx,%esi
  801049:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104b:	85 c0                	test   %eax,%eax
  80104d:	7e 17                	jle    801066 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	50                   	push   %eax
  801053:	6a 08                	push   $0x8
  801055:	68 7f 33 80 00       	push   $0x80337f
  80105a:	6a 23                	push   $0x23
  80105c:	68 9c 33 80 00       	push   $0x80339c
  801061:	e8 7e f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801066:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801069:	5b                   	pop    %ebx
  80106a:	5e                   	pop    %esi
  80106b:	5f                   	pop    %edi
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
  801074:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801077:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107c:	b8 09 00 00 00       	mov    $0x9,%eax
  801081:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801084:	8b 55 08             	mov    0x8(%ebp),%edx
  801087:	89 df                	mov    %ebx,%edi
  801089:	89 de                	mov    %ebx,%esi
  80108b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80108d:	85 c0                	test   %eax,%eax
  80108f:	7e 17                	jle    8010a8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	50                   	push   %eax
  801095:	6a 09                	push   $0x9
  801097:	68 7f 33 80 00       	push   $0x80337f
  80109c:	6a 23                	push   $0x23
  80109e:	68 9c 33 80 00       	push   $0x80339c
  8010a3:	e8 3c f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ab:	5b                   	pop    %ebx
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c9:	89 df                	mov    %ebx,%edi
  8010cb:	89 de                	mov    %ebx,%esi
  8010cd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	7e 17                	jle    8010ea <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	50                   	push   %eax
  8010d7:	6a 0a                	push   $0xa
  8010d9:	68 7f 33 80 00       	push   $0x80337f
  8010de:	6a 23                	push   $0x23
  8010e0:	68 9c 33 80 00       	push   $0x80339c
  8010e5:	e8 fa f3 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f8:	be 00 00 00 00       	mov    $0x0,%esi
  8010fd:	b8 0c 00 00 00       	mov    $0xc,%eax
  801102:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801105:	8b 55 08             	mov    0x8(%ebp),%edx
  801108:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80110b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80110e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5f                   	pop    %edi
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	57                   	push   %edi
  801119:	56                   	push   %esi
  80111a:	53                   	push   %ebx
  80111b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801123:	b8 0d 00 00 00       	mov    $0xd,%eax
  801128:	8b 55 08             	mov    0x8(%ebp),%edx
  80112b:	89 cb                	mov    %ecx,%ebx
  80112d:	89 cf                	mov    %ecx,%edi
  80112f:	89 ce                	mov    %ecx,%esi
  801131:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801133:	85 c0                	test   %eax,%eax
  801135:	7e 17                	jle    80114e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801137:	83 ec 0c             	sub    $0xc,%esp
  80113a:	50                   	push   %eax
  80113b:	6a 0d                	push   $0xd
  80113d:	68 7f 33 80 00       	push   $0x80337f
  801142:	6a 23                	push   $0x23
  801144:	68 9c 33 80 00       	push   $0x80339c
  801149:	e8 96 f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	57                   	push   %edi
  80115a:	56                   	push   %esi
  80115b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115c:	ba 00 00 00 00       	mov    $0x0,%edx
  801161:	b8 0e 00 00 00       	mov    $0xe,%eax
  801166:	89 d1                	mov    %edx,%ecx
  801168:	89 d3                	mov    %edx,%ebx
  80116a:	89 d7                	mov    %edx,%edi
  80116c:	89 d6                	mov    %edx,%esi
  80116e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	53                   	push   %ebx
  801179:	83 ec 04             	sub    $0x4,%esp
  80117c:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80117f:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  801181:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  801184:	f6 c1 02             	test   $0x2,%cl
  801187:	74 2e                	je     8011b7 <pgfault+0x42>
  801189:	89 c2                	mov    %eax,%edx
  80118b:	c1 ea 16             	shr    $0x16,%edx
  80118e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801195:	f6 c2 01             	test   $0x1,%dl
  801198:	74 1d                	je     8011b7 <pgfault+0x42>
  80119a:	89 c2                	mov    %eax,%edx
  80119c:	c1 ea 0c             	shr    $0xc,%edx
  80119f:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  8011a6:	f6 c3 01             	test   $0x1,%bl
  8011a9:	74 0c                	je     8011b7 <pgfault+0x42>
  8011ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b2:	f6 c6 08             	test   $0x8,%dh
  8011b5:	75 12                	jne    8011c9 <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  8011b7:	51                   	push   %ecx
  8011b8:	68 aa 33 80 00       	push   $0x8033aa
  8011bd:	6a 1e                	push   $0x1e
  8011bf:	68 c3 33 80 00       	push   $0x8033c3
  8011c4:	e8 1b f3 ff ff       	call   8004e4 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  8011c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ce:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  8011d0:	83 ec 04             	sub    $0x4,%esp
  8011d3:	6a 07                	push   $0x7
  8011d5:	68 00 f0 7f 00       	push   $0x7ff000
  8011da:	6a 00                	push   $0x0
  8011dc:	e8 84 fd ff ff       	call   800f65 <sys_page_alloc>
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	79 12                	jns    8011fa <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  8011e8:	50                   	push   %eax
  8011e9:	68 ce 33 80 00       	push   $0x8033ce
  8011ee:	6a 29                	push   $0x29
  8011f0:	68 c3 33 80 00       	push   $0x8033c3
  8011f5:	e8 ea f2 ff ff       	call   8004e4 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  8011fa:	83 ec 04             	sub    $0x4,%esp
  8011fd:	68 00 10 00 00       	push   $0x1000
  801202:	53                   	push   %ebx
  801203:	68 00 f0 7f 00       	push   $0x7ff000
  801208:	e8 4f fb ff ff       	call   800d5c <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80120d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801214:	53                   	push   %ebx
  801215:	6a 00                	push   $0x0
  801217:	68 00 f0 7f 00       	push   $0x7ff000
  80121c:	6a 00                	push   $0x0
  80121e:	e8 85 fd ff ff       	call   800fa8 <sys_page_map>
  801223:	83 c4 20             	add    $0x20,%esp
  801226:	85 c0                	test   %eax,%eax
  801228:	79 12                	jns    80123c <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  80122a:	50                   	push   %eax
  80122b:	68 e9 33 80 00       	push   $0x8033e9
  801230:	6a 2e                	push   $0x2e
  801232:	68 c3 33 80 00       	push   $0x8033c3
  801237:	e8 a8 f2 ff ff       	call   8004e4 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	68 00 f0 7f 00       	push   $0x7ff000
  801244:	6a 00                	push   $0x0
  801246:	e8 9f fd ff ff       	call   800fea <sys_page_unmap>
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	79 12                	jns    801264 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  801252:	50                   	push   %eax
  801253:	68 02 34 80 00       	push   $0x803402
  801258:	6a 31                	push   $0x31
  80125a:	68 c3 33 80 00       	push   $0x8033c3
  80125f:	e8 80 f2 ff ff       	call   8004e4 <_panic>

}
  801264:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801267:	c9                   	leave  
  801268:	c3                   	ret    

00801269 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	57                   	push   %edi
  80126d:	56                   	push   %esi
  80126e:	53                   	push   %ebx
  80126f:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  801272:	68 75 11 80 00       	push   $0x801175
  801277:	e8 18 18 00 00       	call   802a94 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80127c:	b8 07 00 00 00       	mov    $0x7,%eax
  801281:	cd 30                	int    $0x30
  801283:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801286:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801291:	85 c0                	test   %eax,%eax
  801293:	75 21                	jne    8012b6 <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  801295:	e8 8d fc ff ff       	call   800f27 <sys_getenvid>
  80129a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80129f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012a7:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8012ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b1:	e9 c9 01 00 00       	jmp    80147f <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  8012b6:	89 d8                	mov    %ebx,%eax
  8012b8:	c1 e8 16             	shr    $0x16,%eax
  8012bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c2:	a8 01                	test   $0x1,%al
  8012c4:	0f 84 1b 01 00 00    	je     8013e5 <fork+0x17c>
  8012ca:	89 de                	mov    %ebx,%esi
  8012cc:	c1 ee 0c             	shr    $0xc,%esi
  8012cf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012d6:	a8 01                	test   $0x1,%al
  8012d8:	0f 84 07 01 00 00    	je     8013e5 <fork+0x17c>
  8012de:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012e5:	a8 04                	test   $0x4,%al
  8012e7:	0f 84 f8 00 00 00    	je     8013e5 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  8012ed:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012f4:	f6 c4 04             	test   $0x4,%ah
  8012f7:	74 3c                	je     801335 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  8012f9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801300:	c1 e6 0c             	shl    $0xc,%esi
  801303:	83 ec 0c             	sub    $0xc,%esp
  801306:	25 07 0e 00 00       	and    $0xe07,%eax
  80130b:	50                   	push   %eax
  80130c:	56                   	push   %esi
  80130d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801310:	56                   	push   %esi
  801311:	6a 00                	push   $0x0
  801313:	e8 90 fc ff ff       	call   800fa8 <sys_page_map>
  801318:	83 c4 20             	add    $0x20,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	0f 89 c2 00 00 00    	jns    8013e5 <fork+0x17c>
			panic("duppage: %e", r);
  801323:	50                   	push   %eax
  801324:	68 1d 34 80 00       	push   $0x80341d
  801329:	6a 48                	push   $0x48
  80132b:	68 c3 33 80 00       	push   $0x8033c3
  801330:	e8 af f1 ff ff       	call   8004e4 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  801335:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80133c:	f6 c4 08             	test   $0x8,%ah
  80133f:	75 0b                	jne    80134c <fork+0xe3>
  801341:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801348:	a8 02                	test   $0x2,%al
  80134a:	74 6c                	je     8013b8 <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  80134c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801353:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  801356:	83 f8 01             	cmp    $0x1,%eax
  801359:	19 ff                	sbb    %edi,%edi
  80135b:	83 e7 fc             	and    $0xfffffffc,%edi
  80135e:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  801364:	c1 e6 0c             	shl    $0xc,%esi
  801367:	83 ec 0c             	sub    $0xc,%esp
  80136a:	57                   	push   %edi
  80136b:	56                   	push   %esi
  80136c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80136f:	56                   	push   %esi
  801370:	6a 00                	push   $0x0
  801372:	e8 31 fc ff ff       	call   800fa8 <sys_page_map>
  801377:	83 c4 20             	add    $0x20,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	79 12                	jns    801390 <fork+0x127>
			panic("duppage: %e", r);
  80137e:	50                   	push   %eax
  80137f:	68 1d 34 80 00       	push   $0x80341d
  801384:	6a 50                	push   $0x50
  801386:	68 c3 33 80 00       	push   $0x8033c3
  80138b:	e8 54 f1 ff ff       	call   8004e4 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  801390:	83 ec 0c             	sub    $0xc,%esp
  801393:	57                   	push   %edi
  801394:	56                   	push   %esi
  801395:	6a 00                	push   $0x0
  801397:	56                   	push   %esi
  801398:	6a 00                	push   $0x0
  80139a:	e8 09 fc ff ff       	call   800fa8 <sys_page_map>
  80139f:	83 c4 20             	add    $0x20,%esp
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	79 3f                	jns    8013e5 <fork+0x17c>
			panic("duppage: %e", r);
  8013a6:	50                   	push   %eax
  8013a7:	68 1d 34 80 00       	push   $0x80341d
  8013ac:	6a 53                	push   $0x53
  8013ae:	68 c3 33 80 00       	push   $0x8033c3
  8013b3:	e8 2c f1 ff ff       	call   8004e4 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  8013b8:	c1 e6 0c             	shl    $0xc,%esi
  8013bb:	83 ec 0c             	sub    $0xc,%esp
  8013be:	6a 05                	push   $0x5
  8013c0:	56                   	push   %esi
  8013c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c4:	56                   	push   %esi
  8013c5:	6a 00                	push   $0x0
  8013c7:	e8 dc fb ff ff       	call   800fa8 <sys_page_map>
  8013cc:	83 c4 20             	add    $0x20,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	79 12                	jns    8013e5 <fork+0x17c>
			panic("duppage: %e", r);
  8013d3:	50                   	push   %eax
  8013d4:	68 1d 34 80 00       	push   $0x80341d
  8013d9:	6a 57                	push   $0x57
  8013db:	68 c3 33 80 00       	push   $0x8033c3
  8013e0:	e8 ff f0 ff ff       	call   8004e4 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  8013e5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013eb:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8013f1:	0f 85 bf fe ff ff    	jne    8012b6 <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  8013f7:	83 ec 04             	sub    $0x4,%esp
  8013fa:	6a 07                	push   $0x7
  8013fc:	68 00 f0 bf ee       	push   $0xeebff000
  801401:	ff 75 e0             	pushl  -0x20(%ebp)
  801404:	e8 5c fb ff ff       	call   800f65 <sys_page_alloc>
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	74 17                	je     801427 <fork+0x1be>
		panic("sys_page_alloc Error");
  801410:	83 ec 04             	sub    $0x4,%esp
  801413:	68 29 34 80 00       	push   $0x803429
  801418:	68 83 00 00 00       	push   $0x83
  80141d:	68 c3 33 80 00       	push   $0x8033c3
  801422:	e8 bd f0 ff ff       	call   8004e4 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	68 03 2b 80 00       	push   $0x802b03
  80142f:	ff 75 e0             	pushl  -0x20(%ebp)
  801432:	e8 79 fc ff ff       	call   8010b0 <sys_env_set_pgfault_upcall>
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	79 15                	jns    801453 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  80143e:	50                   	push   %eax
  80143f:	68 3e 34 80 00       	push   $0x80343e
  801444:	68 86 00 00 00       	push   $0x86
  801449:	68 c3 33 80 00       	push   $0x8033c3
  80144e:	e8 91 f0 ff ff       	call   8004e4 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	6a 02                	push   $0x2
  801458:	ff 75 e0             	pushl  -0x20(%ebp)
  80145b:	e8 cc fb ff ff       	call   80102c <sys_env_set_status>
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	79 15                	jns    80147c <fork+0x213>
		panic("fork set status: %e", r);
  801467:	50                   	push   %eax
  801468:	68 56 34 80 00       	push   $0x803456
  80146d:	68 89 00 00 00       	push   $0x89
  801472:	68 c3 33 80 00       	push   $0x8033c3
  801477:	e8 68 f0 ff ff       	call   8004e4 <_panic>
	
	return envid;
  80147c:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  80147f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801482:	5b                   	pop    %ebx
  801483:	5e                   	pop    %esi
  801484:	5f                   	pop    %edi
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <sfork>:


// Challenge!
int
sfork(void)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80148d:	68 6a 34 80 00       	push   $0x80346a
  801492:	68 93 00 00 00       	push   $0x93
  801497:	68 c3 33 80 00       	push   $0x8033c3
  80149c:	e8 43 f0 ff ff       	call   8004e4 <_panic>

008014a1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a7:	05 00 00 00 30       	add    $0x30000000,%eax
  8014ac:	c1 e8 0c             	shr    $0xc,%eax
}
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8014bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014c1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014c6:	5d                   	pop    %ebp
  8014c7:	c3                   	ret    

008014c8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ce:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	c1 ea 16             	shr    $0x16,%edx
  8014d8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014df:	f6 c2 01             	test   $0x1,%dl
  8014e2:	74 11                	je     8014f5 <fd_alloc+0x2d>
  8014e4:	89 c2                	mov    %eax,%edx
  8014e6:	c1 ea 0c             	shr    $0xc,%edx
  8014e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f0:	f6 c2 01             	test   $0x1,%dl
  8014f3:	75 09                	jne    8014fe <fd_alloc+0x36>
			*fd_store = fd;
  8014f5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fc:	eb 17                	jmp    801515 <fd_alloc+0x4d>
  8014fe:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801503:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801508:	75 c9                	jne    8014d3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80150a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801510:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    

00801517 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80151d:	83 f8 1f             	cmp    $0x1f,%eax
  801520:	77 36                	ja     801558 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801522:	c1 e0 0c             	shl    $0xc,%eax
  801525:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	c1 ea 16             	shr    $0x16,%edx
  80152f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801536:	f6 c2 01             	test   $0x1,%dl
  801539:	74 24                	je     80155f <fd_lookup+0x48>
  80153b:	89 c2                	mov    %eax,%edx
  80153d:	c1 ea 0c             	shr    $0xc,%edx
  801540:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801547:	f6 c2 01             	test   $0x1,%dl
  80154a:	74 1a                	je     801566 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80154c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80154f:	89 02                	mov    %eax,(%edx)
	return 0;
  801551:	b8 00 00 00 00       	mov    $0x0,%eax
  801556:	eb 13                	jmp    80156b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801558:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155d:	eb 0c                	jmp    80156b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80155f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801564:	eb 05                	jmp    80156b <fd_lookup+0x54>
  801566:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    

0080156d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801576:	ba fc 34 80 00       	mov    $0x8034fc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80157b:	eb 13                	jmp    801590 <dev_lookup+0x23>
  80157d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801580:	39 08                	cmp    %ecx,(%eax)
  801582:	75 0c                	jne    801590 <dev_lookup+0x23>
			*dev = devtab[i];
  801584:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801587:	89 01                	mov    %eax,(%ecx)
			return 0;
  801589:	b8 00 00 00 00       	mov    $0x0,%eax
  80158e:	eb 2e                	jmp    8015be <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801590:	8b 02                	mov    (%edx),%eax
  801592:	85 c0                	test   %eax,%eax
  801594:	75 e7                	jne    80157d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801596:	a1 08 50 80 00       	mov    0x805008,%eax
  80159b:	8b 40 48             	mov    0x48(%eax),%eax
  80159e:	83 ec 04             	sub    $0x4,%esp
  8015a1:	51                   	push   %ecx
  8015a2:	50                   	push   %eax
  8015a3:	68 80 34 80 00       	push   $0x803480
  8015a8:	e8 10 f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  8015ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	56                   	push   %esi
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 10             	sub    $0x10,%esp
  8015c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8015cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015d8:	c1 e8 0c             	shr    $0xc,%eax
  8015db:	50                   	push   %eax
  8015dc:	e8 36 ff ff ff       	call   801517 <fd_lookup>
  8015e1:	83 c4 08             	add    $0x8,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 05                	js     8015ed <fd_close+0x2d>
	    || fd != fd2)
  8015e8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015eb:	74 0c                	je     8015f9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015ed:	84 db                	test   %bl,%bl
  8015ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f4:	0f 44 c2             	cmove  %edx,%eax
  8015f7:	eb 41                	jmp    80163a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ff:	50                   	push   %eax
  801600:	ff 36                	pushl  (%esi)
  801602:	e8 66 ff ff ff       	call   80156d <dev_lookup>
  801607:	89 c3                	mov    %eax,%ebx
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 1a                	js     80162a <fd_close+0x6a>
		if (dev->dev_close)
  801610:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801613:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801616:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80161b:	85 c0                	test   %eax,%eax
  80161d:	74 0b                	je     80162a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80161f:	83 ec 0c             	sub    $0xc,%esp
  801622:	56                   	push   %esi
  801623:	ff d0                	call   *%eax
  801625:	89 c3                	mov    %eax,%ebx
  801627:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	56                   	push   %esi
  80162e:	6a 00                	push   $0x0
  801630:	e8 b5 f9 ff ff       	call   800fea <sys_page_unmap>
	return r;
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	89 d8                	mov    %ebx,%eax
}
  80163a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163d:	5b                   	pop    %ebx
  80163e:	5e                   	pop    %esi
  80163f:	5d                   	pop    %ebp
  801640:	c3                   	ret    

00801641 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	ff 75 08             	pushl  0x8(%ebp)
  80164e:	e8 c4 fe ff ff       	call   801517 <fd_lookup>
  801653:	83 c4 08             	add    $0x8,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 10                	js     80166a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	6a 01                	push   $0x1
  80165f:	ff 75 f4             	pushl  -0xc(%ebp)
  801662:	e8 59 ff ff ff       	call   8015c0 <fd_close>
  801667:	83 c4 10             	add    $0x10,%esp
}
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <close_all>:

void
close_all(void)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	53                   	push   %ebx
  801670:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801673:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801678:	83 ec 0c             	sub    $0xc,%esp
  80167b:	53                   	push   %ebx
  80167c:	e8 c0 ff ff ff       	call   801641 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801681:	83 c3 01             	add    $0x1,%ebx
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	83 fb 20             	cmp    $0x20,%ebx
  80168a:	75 ec                	jne    801678 <close_all+0xc>
		close(i);
}
  80168c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168f:	c9                   	leave  
  801690:	c3                   	ret    

00801691 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	57                   	push   %edi
  801695:	56                   	push   %esi
  801696:	53                   	push   %ebx
  801697:	83 ec 2c             	sub    $0x2c,%esp
  80169a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80169d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016a0:	50                   	push   %eax
  8016a1:	ff 75 08             	pushl  0x8(%ebp)
  8016a4:	e8 6e fe ff ff       	call   801517 <fd_lookup>
  8016a9:	83 c4 08             	add    $0x8,%esp
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	0f 88 c1 00 00 00    	js     801775 <dup+0xe4>
		return r;
	close(newfdnum);
  8016b4:	83 ec 0c             	sub    $0xc,%esp
  8016b7:	56                   	push   %esi
  8016b8:	e8 84 ff ff ff       	call   801641 <close>

	newfd = INDEX2FD(newfdnum);
  8016bd:	89 f3                	mov    %esi,%ebx
  8016bf:	c1 e3 0c             	shl    $0xc,%ebx
  8016c2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016c8:	83 c4 04             	add    $0x4,%esp
  8016cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016ce:	e8 de fd ff ff       	call   8014b1 <fd2data>
  8016d3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016d5:	89 1c 24             	mov    %ebx,(%esp)
  8016d8:	e8 d4 fd ff ff       	call   8014b1 <fd2data>
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016e3:	89 f8                	mov    %edi,%eax
  8016e5:	c1 e8 16             	shr    $0x16,%eax
  8016e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016ef:	a8 01                	test   $0x1,%al
  8016f1:	74 37                	je     80172a <dup+0x99>
  8016f3:	89 f8                	mov    %edi,%eax
  8016f5:	c1 e8 0c             	shr    $0xc,%eax
  8016f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ff:	f6 c2 01             	test   $0x1,%dl
  801702:	74 26                	je     80172a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801704:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80170b:	83 ec 0c             	sub    $0xc,%esp
  80170e:	25 07 0e 00 00       	and    $0xe07,%eax
  801713:	50                   	push   %eax
  801714:	ff 75 d4             	pushl  -0x2c(%ebp)
  801717:	6a 00                	push   $0x0
  801719:	57                   	push   %edi
  80171a:	6a 00                	push   $0x0
  80171c:	e8 87 f8 ff ff       	call   800fa8 <sys_page_map>
  801721:	89 c7                	mov    %eax,%edi
  801723:	83 c4 20             	add    $0x20,%esp
  801726:	85 c0                	test   %eax,%eax
  801728:	78 2e                	js     801758 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80172a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80172d:	89 d0                	mov    %edx,%eax
  80172f:	c1 e8 0c             	shr    $0xc,%eax
  801732:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801739:	83 ec 0c             	sub    $0xc,%esp
  80173c:	25 07 0e 00 00       	and    $0xe07,%eax
  801741:	50                   	push   %eax
  801742:	53                   	push   %ebx
  801743:	6a 00                	push   $0x0
  801745:	52                   	push   %edx
  801746:	6a 00                	push   $0x0
  801748:	e8 5b f8 ff ff       	call   800fa8 <sys_page_map>
  80174d:	89 c7                	mov    %eax,%edi
  80174f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801752:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801754:	85 ff                	test   %edi,%edi
  801756:	79 1d                	jns    801775 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	53                   	push   %ebx
  80175c:	6a 00                	push   $0x0
  80175e:	e8 87 f8 ff ff       	call   800fea <sys_page_unmap>
	sys_page_unmap(0, nva);
  801763:	83 c4 08             	add    $0x8,%esp
  801766:	ff 75 d4             	pushl  -0x2c(%ebp)
  801769:	6a 00                	push   $0x0
  80176b:	e8 7a f8 ff ff       	call   800fea <sys_page_unmap>
	return r;
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	89 f8                	mov    %edi,%eax
}
  801775:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5f                   	pop    %edi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	53                   	push   %ebx
  801781:	83 ec 14             	sub    $0x14,%esp
  801784:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801787:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178a:	50                   	push   %eax
  80178b:	53                   	push   %ebx
  80178c:	e8 86 fd ff ff       	call   801517 <fd_lookup>
  801791:	83 c4 08             	add    $0x8,%esp
  801794:	89 c2                	mov    %eax,%edx
  801796:	85 c0                	test   %eax,%eax
  801798:	78 6d                	js     801807 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a0:	50                   	push   %eax
  8017a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a4:	ff 30                	pushl  (%eax)
  8017a6:	e8 c2 fd ff ff       	call   80156d <dev_lookup>
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 4c                	js     8017fe <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017b5:	8b 42 08             	mov    0x8(%edx),%eax
  8017b8:	83 e0 03             	and    $0x3,%eax
  8017bb:	83 f8 01             	cmp    $0x1,%eax
  8017be:	75 21                	jne    8017e1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017c0:	a1 08 50 80 00       	mov    0x805008,%eax
  8017c5:	8b 40 48             	mov    0x48(%eax),%eax
  8017c8:	83 ec 04             	sub    $0x4,%esp
  8017cb:	53                   	push   %ebx
  8017cc:	50                   	push   %eax
  8017cd:	68 c1 34 80 00       	push   $0x8034c1
  8017d2:	e8 e6 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017df:	eb 26                	jmp    801807 <read+0x8a>
	}
	if (!dev->dev_read)
  8017e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e4:	8b 40 08             	mov    0x8(%eax),%eax
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	74 17                	je     801802 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017eb:	83 ec 04             	sub    $0x4,%esp
  8017ee:	ff 75 10             	pushl  0x10(%ebp)
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	52                   	push   %edx
  8017f5:	ff d0                	call   *%eax
  8017f7:	89 c2                	mov    %eax,%edx
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	eb 09                	jmp    801807 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fe:	89 c2                	mov    %eax,%edx
  801800:	eb 05                	jmp    801807 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801802:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801807:	89 d0                	mov    %edx,%eax
  801809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	57                   	push   %edi
  801812:	56                   	push   %esi
  801813:	53                   	push   %ebx
  801814:	83 ec 0c             	sub    $0xc,%esp
  801817:	8b 7d 08             	mov    0x8(%ebp),%edi
  80181a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80181d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801822:	eb 21                	jmp    801845 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801824:	83 ec 04             	sub    $0x4,%esp
  801827:	89 f0                	mov    %esi,%eax
  801829:	29 d8                	sub    %ebx,%eax
  80182b:	50                   	push   %eax
  80182c:	89 d8                	mov    %ebx,%eax
  80182e:	03 45 0c             	add    0xc(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	57                   	push   %edi
  801833:	e8 45 ff ff ff       	call   80177d <read>
		if (m < 0)
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 10                	js     80184f <readn+0x41>
			return m;
		if (m == 0)
  80183f:	85 c0                	test   %eax,%eax
  801841:	74 0a                	je     80184d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801843:	01 c3                	add    %eax,%ebx
  801845:	39 f3                	cmp    %esi,%ebx
  801847:	72 db                	jb     801824 <readn+0x16>
  801849:	89 d8                	mov    %ebx,%eax
  80184b:	eb 02                	jmp    80184f <readn+0x41>
  80184d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80184f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801852:	5b                   	pop    %ebx
  801853:	5e                   	pop    %esi
  801854:	5f                   	pop    %edi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	53                   	push   %ebx
  80185b:	83 ec 14             	sub    $0x14,%esp
  80185e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801861:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801864:	50                   	push   %eax
  801865:	53                   	push   %ebx
  801866:	e8 ac fc ff ff       	call   801517 <fd_lookup>
  80186b:	83 c4 08             	add    $0x8,%esp
  80186e:	89 c2                	mov    %eax,%edx
  801870:	85 c0                	test   %eax,%eax
  801872:	78 68                	js     8018dc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801874:	83 ec 08             	sub    $0x8,%esp
  801877:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187a:	50                   	push   %eax
  80187b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187e:	ff 30                	pushl  (%eax)
  801880:	e8 e8 fc ff ff       	call   80156d <dev_lookup>
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 47                	js     8018d3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801893:	75 21                	jne    8018b6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801895:	a1 08 50 80 00       	mov    0x805008,%eax
  80189a:	8b 40 48             	mov    0x48(%eax),%eax
  80189d:	83 ec 04             	sub    $0x4,%esp
  8018a0:	53                   	push   %ebx
  8018a1:	50                   	push   %eax
  8018a2:	68 dd 34 80 00       	push   $0x8034dd
  8018a7:	e8 11 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018b4:	eb 26                	jmp    8018dc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8018bc:	85 d2                	test   %edx,%edx
  8018be:	74 17                	je     8018d7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018c0:	83 ec 04             	sub    $0x4,%esp
  8018c3:	ff 75 10             	pushl  0x10(%ebp)
  8018c6:	ff 75 0c             	pushl  0xc(%ebp)
  8018c9:	50                   	push   %eax
  8018ca:	ff d2                	call   *%edx
  8018cc:	89 c2                	mov    %eax,%edx
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	eb 09                	jmp    8018dc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d3:	89 c2                	mov    %eax,%edx
  8018d5:	eb 05                	jmp    8018dc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018dc:	89 d0                	mov    %edx,%eax
  8018de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e1:	c9                   	leave  
  8018e2:	c3                   	ret    

008018e3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018e9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018ec:	50                   	push   %eax
  8018ed:	ff 75 08             	pushl  0x8(%ebp)
  8018f0:	e8 22 fc ff ff       	call   801517 <fd_lookup>
  8018f5:	83 c4 08             	add    $0x8,%esp
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 0e                	js     80190a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801902:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	53                   	push   %ebx
  801910:	83 ec 14             	sub    $0x14,%esp
  801913:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801916:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801919:	50                   	push   %eax
  80191a:	53                   	push   %ebx
  80191b:	e8 f7 fb ff ff       	call   801517 <fd_lookup>
  801920:	83 c4 08             	add    $0x8,%esp
  801923:	89 c2                	mov    %eax,%edx
  801925:	85 c0                	test   %eax,%eax
  801927:	78 65                	js     80198e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801929:	83 ec 08             	sub    $0x8,%esp
  80192c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801933:	ff 30                	pushl  (%eax)
  801935:	e8 33 fc ff ff       	call   80156d <dev_lookup>
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 44                	js     801985 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801941:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801944:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801948:	75 21                	jne    80196b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80194a:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80194f:	8b 40 48             	mov    0x48(%eax),%eax
  801952:	83 ec 04             	sub    $0x4,%esp
  801955:	53                   	push   %ebx
  801956:	50                   	push   %eax
  801957:	68 a0 34 80 00       	push   $0x8034a0
  80195c:	e8 5c ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801969:	eb 23                	jmp    80198e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80196b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196e:	8b 52 18             	mov    0x18(%edx),%edx
  801971:	85 d2                	test   %edx,%edx
  801973:	74 14                	je     801989 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801975:	83 ec 08             	sub    $0x8,%esp
  801978:	ff 75 0c             	pushl  0xc(%ebp)
  80197b:	50                   	push   %eax
  80197c:	ff d2                	call   *%edx
  80197e:	89 c2                	mov    %eax,%edx
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	eb 09                	jmp    80198e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801985:	89 c2                	mov    %eax,%edx
  801987:	eb 05                	jmp    80198e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801989:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80198e:	89 d0                	mov    %edx,%eax
  801990:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	53                   	push   %ebx
  801999:	83 ec 14             	sub    $0x14,%esp
  80199c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80199f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019a2:	50                   	push   %eax
  8019a3:	ff 75 08             	pushl  0x8(%ebp)
  8019a6:	e8 6c fb ff ff       	call   801517 <fd_lookup>
  8019ab:	83 c4 08             	add    $0x8,%esp
  8019ae:	89 c2                	mov    %eax,%edx
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	78 58                	js     801a0c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b4:	83 ec 08             	sub    $0x8,%esp
  8019b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ba:	50                   	push   %eax
  8019bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019be:	ff 30                	pushl  (%eax)
  8019c0:	e8 a8 fb ff ff       	call   80156d <dev_lookup>
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	78 37                	js     801a03 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019d3:	74 32                	je     801a07 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019df:	00 00 00 
	stat->st_isdir = 0;
  8019e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e9:	00 00 00 
	stat->st_dev = dev;
  8019ec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019f2:	83 ec 08             	sub    $0x8,%esp
  8019f5:	53                   	push   %ebx
  8019f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f9:	ff 50 14             	call   *0x14(%eax)
  8019fc:	89 c2                	mov    %eax,%edx
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	eb 09                	jmp    801a0c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a03:	89 c2                	mov    %eax,%edx
  801a05:	eb 05                	jmp    801a0c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a07:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a0c:	89 d0                	mov    %edx,%eax
  801a0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a18:	83 ec 08             	sub    $0x8,%esp
  801a1b:	6a 00                	push   $0x0
  801a1d:	ff 75 08             	pushl  0x8(%ebp)
  801a20:	e8 ef 01 00 00       	call   801c14 <open>
  801a25:	89 c3                	mov    %eax,%ebx
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 1b                	js     801a49 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a2e:	83 ec 08             	sub    $0x8,%esp
  801a31:	ff 75 0c             	pushl  0xc(%ebp)
  801a34:	50                   	push   %eax
  801a35:	e8 5b ff ff ff       	call   801995 <fstat>
  801a3a:	89 c6                	mov    %eax,%esi
	close(fd);
  801a3c:	89 1c 24             	mov    %ebx,(%esp)
  801a3f:	e8 fd fb ff ff       	call   801641 <close>
	return r;
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	89 f0                	mov    %esi,%eax
}
  801a49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4c:	5b                   	pop    %ebx
  801a4d:	5e                   	pop    %esi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	56                   	push   %esi
  801a54:	53                   	push   %ebx
  801a55:	89 c6                	mov    %eax,%esi
  801a57:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a59:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a60:	75 12                	jne    801a74 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	6a 01                	push   $0x1
  801a67:	e8 83 11 00 00       	call   802bef <ipc_find_env>
  801a6c:	a3 00 50 80 00       	mov    %eax,0x805000
  801a71:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a74:	6a 07                	push   $0x7
  801a76:	68 00 60 80 00       	push   $0x806000
  801a7b:	56                   	push   %esi
  801a7c:	ff 35 00 50 80 00    	pushl  0x805000
  801a82:	e8 19 11 00 00       	call   802ba0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a87:	83 c4 0c             	add    $0xc,%esp
  801a8a:	6a 00                	push   $0x0
  801a8c:	53                   	push   %ebx
  801a8d:	6a 00                	push   $0x0
  801a8f:	e8 96 10 00 00       	call   802b2a <ipc_recv>
}
  801a94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a97:	5b                   	pop    %ebx
  801a98:	5e                   	pop    %esi
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa4:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa7:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801aac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aaf:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ab4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab9:	b8 02 00 00 00       	mov    $0x2,%eax
  801abe:	e8 8d ff ff ff       	call   801a50 <fsipc>
}
  801ac3:	c9                   	leave  
  801ac4:	c3                   	ret    

00801ac5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801acb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ace:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad1:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ad6:	ba 00 00 00 00       	mov    $0x0,%edx
  801adb:	b8 06 00 00 00       	mov    $0x6,%eax
  801ae0:	e8 6b ff ff ff       	call   801a50 <fsipc>
}
  801ae5:	c9                   	leave  
  801ae6:	c3                   	ret    

00801ae7 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	53                   	push   %ebx
  801aeb:	83 ec 04             	sub    $0x4,%esp
  801aee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801af1:	8b 45 08             	mov    0x8(%ebp),%eax
  801af4:	8b 40 0c             	mov    0xc(%eax),%eax
  801af7:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801afc:	ba 00 00 00 00       	mov    $0x0,%edx
  801b01:	b8 05 00 00 00       	mov    $0x5,%eax
  801b06:	e8 45 ff ff ff       	call   801a50 <fsipc>
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 2c                	js     801b3b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b0f:	83 ec 08             	sub    $0x8,%esp
  801b12:	68 00 60 80 00       	push   $0x806000
  801b17:	53                   	push   %ebx
  801b18:	e8 45 f0 ff ff       	call   800b62 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b1d:	a1 80 60 80 00       	mov    0x806080,%eax
  801b22:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b28:	a1 84 60 80 00       	mov    0x806084,%eax
  801b2d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3e:	c9                   	leave  
  801b3f:	c3                   	ret    

00801b40 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	53                   	push   %ebx
  801b44:	83 ec 08             	sub    $0x8,%esp
  801b47:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  801b4d:	8b 52 0c             	mov    0xc(%edx),%edx
  801b50:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b56:	a3 04 60 80 00       	mov    %eax,0x806004
  801b5b:	3d 08 60 80 00       	cmp    $0x806008,%eax
  801b60:	bb 08 60 80 00       	mov    $0x806008,%ebx
  801b65:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b68:	53                   	push   %ebx
  801b69:	ff 75 0c             	pushl  0xc(%ebp)
  801b6c:	68 08 60 80 00       	push   $0x806008
  801b71:	e8 7e f1 ff ff       	call   800cf4 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801b76:	ba 00 00 00 00       	mov    $0x0,%edx
  801b7b:	b8 04 00 00 00       	mov    $0x4,%eax
  801b80:	e8 cb fe ff ff       	call   801a50 <fsipc>
  801b85:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801b8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
  801b97:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9d:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ba5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bab:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb0:	b8 03 00 00 00       	mov    $0x3,%eax
  801bb5:	e8 96 fe ff ff       	call   801a50 <fsipc>
  801bba:	89 c3                	mov    %eax,%ebx
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	78 4b                	js     801c0b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801bc0:	39 c6                	cmp    %eax,%esi
  801bc2:	73 16                	jae    801bda <devfile_read+0x48>
  801bc4:	68 10 35 80 00       	push   $0x803510
  801bc9:	68 17 35 80 00       	push   $0x803517
  801bce:	6a 7c                	push   $0x7c
  801bd0:	68 2c 35 80 00       	push   $0x80352c
  801bd5:	e8 0a e9 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801bda:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bdf:	7e 16                	jle    801bf7 <devfile_read+0x65>
  801be1:	68 37 35 80 00       	push   $0x803537
  801be6:	68 17 35 80 00       	push   $0x803517
  801beb:	6a 7d                	push   $0x7d
  801bed:	68 2c 35 80 00       	push   $0x80352c
  801bf2:	e8 ed e8 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bf7:	83 ec 04             	sub    $0x4,%esp
  801bfa:	50                   	push   %eax
  801bfb:	68 00 60 80 00       	push   $0x806000
  801c00:	ff 75 0c             	pushl  0xc(%ebp)
  801c03:	e8 ec f0 ff ff       	call   800cf4 <memmove>
	return r;
  801c08:	83 c4 10             	add    $0x10,%esp
}
  801c0b:	89 d8                	mov    %ebx,%eax
  801c0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c10:	5b                   	pop    %ebx
  801c11:	5e                   	pop    %esi
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    

00801c14 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	53                   	push   %ebx
  801c18:	83 ec 20             	sub    $0x20,%esp
  801c1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c1e:	53                   	push   %ebx
  801c1f:	e8 05 ef ff ff       	call   800b29 <strlen>
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c2c:	7f 67                	jg     801c95 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c2e:	83 ec 0c             	sub    $0xc,%esp
  801c31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c34:	50                   	push   %eax
  801c35:	e8 8e f8 ff ff       	call   8014c8 <fd_alloc>
  801c3a:	83 c4 10             	add    $0x10,%esp
		return r;
  801c3d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	78 57                	js     801c9a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c43:	83 ec 08             	sub    $0x8,%esp
  801c46:	53                   	push   %ebx
  801c47:	68 00 60 80 00       	push   $0x806000
  801c4c:	e8 11 ef ff ff       	call   800b62 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c54:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c59:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c5c:	b8 01 00 00 00       	mov    $0x1,%eax
  801c61:	e8 ea fd ff ff       	call   801a50 <fsipc>
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	79 14                	jns    801c83 <open+0x6f>
		fd_close(fd, 0);
  801c6f:	83 ec 08             	sub    $0x8,%esp
  801c72:	6a 00                	push   $0x0
  801c74:	ff 75 f4             	pushl  -0xc(%ebp)
  801c77:	e8 44 f9 ff ff       	call   8015c0 <fd_close>
		return r;
  801c7c:	83 c4 10             	add    $0x10,%esp
  801c7f:	89 da                	mov    %ebx,%edx
  801c81:	eb 17                	jmp    801c9a <open+0x86>
	}

	return fd2num(fd);
  801c83:	83 ec 0c             	sub    $0xc,%esp
  801c86:	ff 75 f4             	pushl  -0xc(%ebp)
  801c89:	e8 13 f8 ff ff       	call   8014a1 <fd2num>
  801c8e:	89 c2                	mov    %eax,%edx
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	eb 05                	jmp    801c9a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c95:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c9a:	89 d0                	mov    %edx,%eax
  801c9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9f:	c9                   	leave  
  801ca0:	c3                   	ret    

00801ca1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ca7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cac:	b8 08 00 00 00       	mov    $0x8,%eax
  801cb1:	e8 9a fd ff ff       	call   801a50 <fsipc>
}
  801cb6:	c9                   	leave  
  801cb7:	c3                   	ret    

00801cb8 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	57                   	push   %edi
  801cbc:	56                   	push   %esi
  801cbd:	53                   	push   %ebx
  801cbe:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801cc4:	6a 00                	push   $0x0
  801cc6:	ff 75 08             	pushl  0x8(%ebp)
  801cc9:	e8 46 ff ff ff       	call   801c14 <open>
  801cce:	89 c7                	mov    %eax,%edi
  801cd0:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	0f 88 81 04 00 00    	js     802162 <spawn+0x4aa>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801ce1:	83 ec 04             	sub    $0x4,%esp
  801ce4:	68 00 02 00 00       	push   $0x200
  801ce9:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801cef:	50                   	push   %eax
  801cf0:	57                   	push   %edi
  801cf1:	e8 18 fb ff ff       	call   80180e <readn>
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	3d 00 02 00 00       	cmp    $0x200,%eax
  801cfe:	75 0c                	jne    801d0c <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801d00:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801d07:	45 4c 46 
  801d0a:	74 33                	je     801d3f <spawn+0x87>
		close(fd);
  801d0c:	83 ec 0c             	sub    $0xc,%esp
  801d0f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d15:	e8 27 f9 ff ff       	call   801641 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801d1a:	83 c4 0c             	add    $0xc,%esp
  801d1d:	68 7f 45 4c 46       	push   $0x464c457f
  801d22:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801d28:	68 43 35 80 00       	push   $0x803543
  801d2d:	e8 8b e8 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801d3a:	e9 c6 04 00 00       	jmp    802205 <spawn+0x54d>
  801d3f:	b8 07 00 00 00       	mov    $0x7,%eax
  801d44:	cd 30                	int    $0x30
  801d46:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d4c:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d52:	85 c0                	test   %eax,%eax
  801d54:	0f 88 13 04 00 00    	js     80216d <spawn+0x4b5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d5a:	89 c6                	mov    %eax,%esi
  801d5c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801d62:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801d65:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d6b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d71:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d78:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d7e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d84:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d89:	be 00 00 00 00       	mov    $0x0,%esi
  801d8e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d91:	eb 13                	jmp    801da6 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d93:	83 ec 0c             	sub    $0xc,%esp
  801d96:	50                   	push   %eax
  801d97:	e8 8d ed ff ff       	call   800b29 <strlen>
  801d9c:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801da0:	83 c3 01             	add    $0x1,%ebx
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801dad:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801db0:	85 c0                	test   %eax,%eax
  801db2:	75 df                	jne    801d93 <spawn+0xdb>
  801db4:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801dba:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801dc0:	bf 00 10 40 00       	mov    $0x401000,%edi
  801dc5:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801dc7:	89 fa                	mov    %edi,%edx
  801dc9:	83 e2 fc             	and    $0xfffffffc,%edx
  801dcc:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801dd3:	29 c2                	sub    %eax,%edx
  801dd5:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ddb:	8d 42 f8             	lea    -0x8(%edx),%eax
  801dde:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801de3:	0f 86 9a 03 00 00    	jbe    802183 <spawn+0x4cb>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801de9:	83 ec 04             	sub    $0x4,%esp
  801dec:	6a 07                	push   $0x7
  801dee:	68 00 00 40 00       	push   $0x400000
  801df3:	6a 00                	push   $0x0
  801df5:	e8 6b f1 ff ff       	call   800f65 <sys_page_alloc>
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	0f 88 85 03 00 00    	js     80218a <spawn+0x4d2>
  801e05:	be 00 00 00 00       	mov    $0x0,%esi
  801e0a:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801e10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e13:	eb 30                	jmp    801e45 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801e15:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e1b:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e21:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801e24:	83 ec 08             	sub    $0x8,%esp
  801e27:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e2a:	57                   	push   %edi
  801e2b:	e8 32 ed ff ff       	call   800b62 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e30:	83 c4 04             	add    $0x4,%esp
  801e33:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e36:	e8 ee ec ff ff       	call   800b29 <strlen>
  801e3b:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e3f:	83 c6 01             	add    $0x1,%esi
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801e4b:	7f c8                	jg     801e15 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801e4d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e53:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801e59:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e60:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e66:	74 19                	je     801e81 <spawn+0x1c9>
  801e68:	68 d0 35 80 00       	push   $0x8035d0
  801e6d:	68 17 35 80 00       	push   $0x803517
  801e72:	68 f1 00 00 00       	push   $0xf1
  801e77:	68 5d 35 80 00       	push   $0x80355d
  801e7c:	e8 63 e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e81:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e87:	89 f8                	mov    %edi,%eax
  801e89:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e8e:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e91:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e97:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e9a:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801ea0:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	6a 07                	push   $0x7
  801eab:	68 00 d0 bf ee       	push   $0xeebfd000
  801eb0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801eb6:	68 00 00 40 00       	push   $0x400000
  801ebb:	6a 00                	push   $0x0
  801ebd:	e8 e6 f0 ff ff       	call   800fa8 <sys_page_map>
  801ec2:	89 c3                	mov    %eax,%ebx
  801ec4:	83 c4 20             	add    $0x20,%esp
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	0f 88 24 03 00 00    	js     8021f3 <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ecf:	83 ec 08             	sub    $0x8,%esp
  801ed2:	68 00 00 40 00       	push   $0x400000
  801ed7:	6a 00                	push   $0x0
  801ed9:	e8 0c f1 ff ff       	call   800fea <sys_page_unmap>
  801ede:	89 c3                	mov    %eax,%ebx
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	0f 88 08 03 00 00    	js     8021f3 <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801eeb:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ef1:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ef8:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801efe:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801f05:	00 00 00 
  801f08:	e9 8a 01 00 00       	jmp    802097 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801f0d:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801f13:	83 38 01             	cmpl   $0x1,(%eax)
  801f16:	0f 85 6d 01 00 00    	jne    802089 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f1c:	89 c7                	mov    %eax,%edi
  801f1e:	8b 40 18             	mov    0x18(%eax),%eax
  801f21:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801f27:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801f2a:	83 f8 01             	cmp    $0x1,%eax
  801f2d:	19 c0                	sbb    %eax,%eax
  801f2f:	83 e0 fe             	and    $0xfffffffe,%eax
  801f32:	83 c0 07             	add    $0x7,%eax
  801f35:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801f3b:	89 f8                	mov    %edi,%eax
  801f3d:	8b 7f 04             	mov    0x4(%edi),%edi
  801f40:	89 f9                	mov    %edi,%ecx
  801f42:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801f48:	8b 78 10             	mov    0x10(%eax),%edi
  801f4b:	8b 70 14             	mov    0x14(%eax),%esi
  801f4e:	89 f2                	mov    %esi,%edx
  801f50:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801f56:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801f59:	89 f0                	mov    %esi,%eax
  801f5b:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f60:	74 14                	je     801f76 <spawn+0x2be>
		va -= i;
  801f62:	29 c6                	sub    %eax,%esi
		memsz += i;
  801f64:	01 c2                	add    %eax,%edx
  801f66:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801f6c:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801f6e:	29 c1                	sub    %eax,%ecx
  801f70:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f76:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f7b:	e9 f7 00 00 00       	jmp    802077 <spawn+0x3bf>
		if (i >= filesz) {
  801f80:	39 df                	cmp    %ebx,%edi
  801f82:	77 27                	ja     801fab <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f84:	83 ec 04             	sub    $0x4,%esp
  801f87:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f8d:	56                   	push   %esi
  801f8e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f94:	e8 cc ef ff ff       	call   800f65 <sys_page_alloc>
  801f99:	83 c4 10             	add    $0x10,%esp
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	0f 89 c7 00 00 00    	jns    80206b <spawn+0x3b3>
  801fa4:	89 c3                	mov    %eax,%ebx
  801fa6:	e9 ed 01 00 00       	jmp    802198 <spawn+0x4e0>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801fab:	83 ec 04             	sub    $0x4,%esp
  801fae:	6a 07                	push   $0x7
  801fb0:	68 00 00 40 00       	push   $0x400000
  801fb5:	6a 00                	push   $0x0
  801fb7:	e8 a9 ef ff ff       	call   800f65 <sys_page_alloc>
  801fbc:	83 c4 10             	add    $0x10,%esp
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	0f 88 c7 01 00 00    	js     80218e <spawn+0x4d6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801fc7:	83 ec 08             	sub    $0x8,%esp
  801fca:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801fd0:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801fd6:	50                   	push   %eax
  801fd7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fdd:	e8 01 f9 ff ff       	call   8018e3 <seek>
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	0f 88 a5 01 00 00    	js     802192 <spawn+0x4da>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801fed:	83 ec 04             	sub    $0x4,%esp
  801ff0:	89 f8                	mov    %edi,%eax
  801ff2:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801ff8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ffd:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802002:	0f 47 c1             	cmova  %ecx,%eax
  802005:	50                   	push   %eax
  802006:	68 00 00 40 00       	push   $0x400000
  80200b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802011:	e8 f8 f7 ff ff       	call   80180e <readn>
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	85 c0                	test   %eax,%eax
  80201b:	0f 88 75 01 00 00    	js     802196 <spawn+0x4de>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802021:	83 ec 0c             	sub    $0xc,%esp
  802024:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80202a:	56                   	push   %esi
  80202b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802031:	68 00 00 40 00       	push   $0x400000
  802036:	6a 00                	push   $0x0
  802038:	e8 6b ef ff ff       	call   800fa8 <sys_page_map>
  80203d:	83 c4 20             	add    $0x20,%esp
  802040:	85 c0                	test   %eax,%eax
  802042:	79 15                	jns    802059 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  802044:	50                   	push   %eax
  802045:	68 69 35 80 00       	push   $0x803569
  80204a:	68 24 01 00 00       	push   $0x124
  80204f:	68 5d 35 80 00       	push   $0x80355d
  802054:	e8 8b e4 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  802059:	83 ec 08             	sub    $0x8,%esp
  80205c:	68 00 00 40 00       	push   $0x400000
  802061:	6a 00                	push   $0x0
  802063:	e8 82 ef ff ff       	call   800fea <sys_page_unmap>
  802068:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80206b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802071:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802077:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80207d:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802083:	0f 87 f7 fe ff ff    	ja     801f80 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802089:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802090:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802097:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80209e:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8020a4:	0f 8c 63 fe ff ff    	jl     801f0d <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8020aa:	83 ec 0c             	sub    $0xc,%esp
  8020ad:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8020b3:	e8 89 f5 ff ff       	call   801641 <close>
  8020b8:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  8020bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020c0:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  8020c6:	89 d8                	mov    %ebx,%eax
  8020c8:	c1 e0 0c             	shl    $0xc,%eax
		if (((uvpd[PDX(pgnum*PGSIZE)] & PTE_P) && (uvpt[pgnum] & PTE_P) && (uvpt[pgnum] & PTE_SHARE))){
  8020cb:	89 c2                	mov    %eax,%edx
  8020cd:	c1 ea 16             	shr    $0x16,%edx
  8020d0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020d7:	f6 c2 01             	test   $0x1,%dl
  8020da:	74 35                	je     802111 <spawn+0x459>
  8020dc:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  8020e3:	f6 c2 01             	test   $0x1,%dl
  8020e6:	74 29                	je     802111 <spawn+0x459>
  8020e8:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  8020ef:	f6 c6 04             	test   $0x4,%dh
  8020f2:	74 1d                	je     802111 <spawn+0x459>
			if((r=sys_page_map(0, (void *)(pgnum*PGSIZE), child, (void *)(pgnum*PGSIZE), PTE_SYSCALL))<0)
  8020f4:	83 ec 0c             	sub    $0xc,%esp
  8020f7:	68 07 0e 00 00       	push   $0xe07
  8020fc:	50                   	push   %eax
  8020fd:	56                   	push   %esi
  8020fe:	50                   	push   %eax
  8020ff:	6a 00                	push   $0x0
  802101:	e8 a2 ee ff ff       	call   800fa8 <sys_page_map>
  802106:	83 c4 20             	add    $0x20,%esp
  802109:	85 c0                	test   %eax,%eax
  80210b:	0f 88 a8 00 00 00    	js     8021b9 <spawn+0x501>
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  802111:	83 c3 01             	add    $0x1,%ebx
  802114:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  80211a:	75 aa                	jne    8020c6 <spawn+0x40e>
  80211c:	e9 ad 00 00 00       	jmp    8021ce <spawn+0x516>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802121:	50                   	push   %eax
  802122:	68 86 35 80 00       	push   $0x803586
  802127:	68 85 00 00 00       	push   $0x85
  80212c:	68 5d 35 80 00       	push   $0x80355d
  802131:	e8 ae e3 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802136:	83 ec 08             	sub    $0x8,%esp
  802139:	6a 02                	push   $0x2
  80213b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802141:	e8 e6 ee ff ff       	call   80102c <sys_env_set_status>
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	85 c0                	test   %eax,%eax
  80214b:	79 2b                	jns    802178 <spawn+0x4c0>
		panic("sys_env_set_status: %e", r);
  80214d:	50                   	push   %eax
  80214e:	68 a0 35 80 00       	push   $0x8035a0
  802153:	68 88 00 00 00       	push   $0x88
  802158:	68 5d 35 80 00       	push   $0x80355d
  80215d:	e8 82 e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802162:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802168:	e9 98 00 00 00       	jmp    802205 <spawn+0x54d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  80216d:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802173:	e9 8d 00 00 00       	jmp    802205 <spawn+0x54d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802178:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80217e:	e9 82 00 00 00       	jmp    802205 <spawn+0x54d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802183:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802188:	eb 7b                	jmp    802205 <spawn+0x54d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80218a:	89 c3                	mov    %eax,%ebx
  80218c:	eb 77                	jmp    802205 <spawn+0x54d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80218e:	89 c3                	mov    %eax,%ebx
  802190:	eb 06                	jmp    802198 <spawn+0x4e0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802192:	89 c3                	mov    %eax,%ebx
  802194:	eb 02                	jmp    802198 <spawn+0x4e0>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802196:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802198:	83 ec 0c             	sub    $0xc,%esp
  80219b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021a1:	e8 40 ed ff ff       	call   800ee6 <sys_env_destroy>
	close(fd);
  8021a6:	83 c4 04             	add    $0x4,%esp
  8021a9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8021af:	e8 8d f4 ff ff       	call   801641 <close>
	return r;
  8021b4:	83 c4 10             	add    $0x10,%esp
  8021b7:	eb 4c                	jmp    802205 <spawn+0x54d>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8021b9:	50                   	push   %eax
  8021ba:	68 b7 35 80 00       	push   $0x8035b7
  8021bf:	68 82 00 00 00       	push   $0x82
  8021c4:	68 5d 35 80 00       	push   $0x80355d
  8021c9:	e8 16 e3 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8021ce:	83 ec 08             	sub    $0x8,%esp
  8021d1:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8021d7:	50                   	push   %eax
  8021d8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021de:	e8 8b ee ff ff       	call   80106e <sys_env_set_trapframe>
  8021e3:	83 c4 10             	add    $0x10,%esp
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	0f 89 48 ff ff ff    	jns    802136 <spawn+0x47e>
  8021ee:	e9 2e ff ff ff       	jmp    802121 <spawn+0x469>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8021f3:	83 ec 08             	sub    $0x8,%esp
  8021f6:	68 00 00 40 00       	push   $0x400000
  8021fb:	6a 00                	push   $0x0
  8021fd:	e8 e8 ed ff ff       	call   800fea <sys_page_unmap>
  802202:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802205:	89 d8                	mov    %ebx,%eax
  802207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80220a:	5b                   	pop    %ebx
  80220b:	5e                   	pop    %esi
  80220c:	5f                   	pop    %edi
  80220d:	5d                   	pop    %ebp
  80220e:	c3                   	ret    

0080220f <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80220f:	55                   	push   %ebp
  802210:	89 e5                	mov    %esp,%ebp
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802214:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802217:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80221c:	eb 03                	jmp    802221 <spawnl+0x12>
		argc++;
  80221e:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802221:	83 c2 04             	add    $0x4,%edx
  802224:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802228:	75 f4                	jne    80221e <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80222a:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802231:	83 e2 f0             	and    $0xfffffff0,%edx
  802234:	29 d4                	sub    %edx,%esp
  802236:	8d 54 24 03          	lea    0x3(%esp),%edx
  80223a:	c1 ea 02             	shr    $0x2,%edx
  80223d:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802244:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802246:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802249:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802250:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802257:	00 
  802258:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80225a:	b8 00 00 00 00       	mov    $0x0,%eax
  80225f:	eb 0a                	jmp    80226b <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802261:	83 c0 01             	add    $0x1,%eax
  802264:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802268:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80226b:	39 d0                	cmp    %edx,%eax
  80226d:	75 f2                	jne    802261 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80226f:	83 ec 08             	sub    $0x8,%esp
  802272:	56                   	push   %esi
  802273:	ff 75 08             	pushl  0x8(%ebp)
  802276:	e8 3d fa ff ff       	call   801cb8 <spawn>
}
  80227b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80227e:	5b                   	pop    %ebx
  80227f:	5e                   	pop    %esi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    

00802282 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802282:	55                   	push   %ebp
  802283:	89 e5                	mov    %esp,%ebp
  802285:	56                   	push   %esi
  802286:	53                   	push   %ebx
  802287:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80228a:	83 ec 0c             	sub    $0xc,%esp
  80228d:	ff 75 08             	pushl  0x8(%ebp)
  802290:	e8 1c f2 ff ff       	call   8014b1 <fd2data>
  802295:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802297:	83 c4 08             	add    $0x8,%esp
  80229a:	68 f8 35 80 00       	push   $0x8035f8
  80229f:	53                   	push   %ebx
  8022a0:	e8 bd e8 ff ff       	call   800b62 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022a5:	8b 46 04             	mov    0x4(%esi),%eax
  8022a8:	2b 06                	sub    (%esi),%eax
  8022aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8022b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022b7:	00 00 00 
	stat->st_dev = &devpipe;
  8022ba:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8022c1:	40 80 00 
	return 0;
}
  8022c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022cc:	5b                   	pop    %ebx
  8022cd:	5e                   	pop    %esi
  8022ce:	5d                   	pop    %ebp
  8022cf:	c3                   	ret    

008022d0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 0c             	sub    $0xc,%esp
  8022d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8022da:	53                   	push   %ebx
  8022db:	6a 00                	push   $0x0
  8022dd:	e8 08 ed ff ff       	call   800fea <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8022e2:	89 1c 24             	mov    %ebx,(%esp)
  8022e5:	e8 c7 f1 ff ff       	call   8014b1 <fd2data>
  8022ea:	83 c4 08             	add    $0x8,%esp
  8022ed:	50                   	push   %eax
  8022ee:	6a 00                	push   $0x0
  8022f0:	e8 f5 ec ff ff       	call   800fea <sys_page_unmap>
}
  8022f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022f8:	c9                   	leave  
  8022f9:	c3                   	ret    

008022fa <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022fa:	55                   	push   %ebp
  8022fb:	89 e5                	mov    %esp,%ebp
  8022fd:	57                   	push   %edi
  8022fe:	56                   	push   %esi
  8022ff:	53                   	push   %ebx
  802300:	83 ec 1c             	sub    $0x1c,%esp
  802303:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802306:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802308:	a1 08 50 80 00       	mov    0x805008,%eax
  80230d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802310:	83 ec 0c             	sub    $0xc,%esp
  802313:	ff 75 e0             	pushl  -0x20(%ebp)
  802316:	e8 0d 09 00 00       	call   802c28 <pageref>
  80231b:	89 c3                	mov    %eax,%ebx
  80231d:	89 3c 24             	mov    %edi,(%esp)
  802320:	e8 03 09 00 00       	call   802c28 <pageref>
  802325:	83 c4 10             	add    $0x10,%esp
  802328:	39 c3                	cmp    %eax,%ebx
  80232a:	0f 94 c1             	sete   %cl
  80232d:	0f b6 c9             	movzbl %cl,%ecx
  802330:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802333:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802339:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80233c:	39 ce                	cmp    %ecx,%esi
  80233e:	74 1b                	je     80235b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802340:	39 c3                	cmp    %eax,%ebx
  802342:	75 c4                	jne    802308 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802344:	8b 42 58             	mov    0x58(%edx),%eax
  802347:	ff 75 e4             	pushl  -0x1c(%ebp)
  80234a:	50                   	push   %eax
  80234b:	56                   	push   %esi
  80234c:	68 ff 35 80 00       	push   $0x8035ff
  802351:	e8 67 e2 ff ff       	call   8005bd <cprintf>
  802356:	83 c4 10             	add    $0x10,%esp
  802359:	eb ad                	jmp    802308 <_pipeisclosed+0xe>
	}
}
  80235b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80235e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802361:	5b                   	pop    %ebx
  802362:	5e                   	pop    %esi
  802363:	5f                   	pop    %edi
  802364:	5d                   	pop    %ebp
  802365:	c3                   	ret    

00802366 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802366:	55                   	push   %ebp
  802367:	89 e5                	mov    %esp,%ebp
  802369:	57                   	push   %edi
  80236a:	56                   	push   %esi
  80236b:	53                   	push   %ebx
  80236c:	83 ec 28             	sub    $0x28,%esp
  80236f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802372:	56                   	push   %esi
  802373:	e8 39 f1 ff ff       	call   8014b1 <fd2data>
  802378:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80237a:	83 c4 10             	add    $0x10,%esp
  80237d:	bf 00 00 00 00       	mov    $0x0,%edi
  802382:	eb 4b                	jmp    8023cf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802384:	89 da                	mov    %ebx,%edx
  802386:	89 f0                	mov    %esi,%eax
  802388:	e8 6d ff ff ff       	call   8022fa <_pipeisclosed>
  80238d:	85 c0                	test   %eax,%eax
  80238f:	75 48                	jne    8023d9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802391:	e8 b0 eb ff ff       	call   800f46 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802396:	8b 43 04             	mov    0x4(%ebx),%eax
  802399:	8b 0b                	mov    (%ebx),%ecx
  80239b:	8d 51 20             	lea    0x20(%ecx),%edx
  80239e:	39 d0                	cmp    %edx,%eax
  8023a0:	73 e2                	jae    802384 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023a5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8023a9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8023ac:	89 c2                	mov    %eax,%edx
  8023ae:	c1 fa 1f             	sar    $0x1f,%edx
  8023b1:	89 d1                	mov    %edx,%ecx
  8023b3:	c1 e9 1b             	shr    $0x1b,%ecx
  8023b6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8023b9:	83 e2 1f             	and    $0x1f,%edx
  8023bc:	29 ca                	sub    %ecx,%edx
  8023be:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8023c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8023c6:	83 c0 01             	add    $0x1,%eax
  8023c9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023cc:	83 c7 01             	add    $0x1,%edi
  8023cf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8023d2:	75 c2                	jne    802396 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8023d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8023d7:	eb 05                	jmp    8023de <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023d9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8023de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e1:	5b                   	pop    %ebx
  8023e2:	5e                   	pop    %esi
  8023e3:	5f                   	pop    %edi
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    

008023e6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023e6:	55                   	push   %ebp
  8023e7:	89 e5                	mov    %esp,%ebp
  8023e9:	57                   	push   %edi
  8023ea:	56                   	push   %esi
  8023eb:	53                   	push   %ebx
  8023ec:	83 ec 18             	sub    $0x18,%esp
  8023ef:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023f2:	57                   	push   %edi
  8023f3:	e8 b9 f0 ff ff       	call   8014b1 <fd2data>
  8023f8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023fa:	83 c4 10             	add    $0x10,%esp
  8023fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  802402:	eb 3d                	jmp    802441 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802404:	85 db                	test   %ebx,%ebx
  802406:	74 04                	je     80240c <devpipe_read+0x26>
				return i;
  802408:	89 d8                	mov    %ebx,%eax
  80240a:	eb 44                	jmp    802450 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80240c:	89 f2                	mov    %esi,%edx
  80240e:	89 f8                	mov    %edi,%eax
  802410:	e8 e5 fe ff ff       	call   8022fa <_pipeisclosed>
  802415:	85 c0                	test   %eax,%eax
  802417:	75 32                	jne    80244b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802419:	e8 28 eb ff ff       	call   800f46 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80241e:	8b 06                	mov    (%esi),%eax
  802420:	3b 46 04             	cmp    0x4(%esi),%eax
  802423:	74 df                	je     802404 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802425:	99                   	cltd   
  802426:	c1 ea 1b             	shr    $0x1b,%edx
  802429:	01 d0                	add    %edx,%eax
  80242b:	83 e0 1f             	and    $0x1f,%eax
  80242e:	29 d0                	sub    %edx,%eax
  802430:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802435:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802438:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80243b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80243e:	83 c3 01             	add    $0x1,%ebx
  802441:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802444:	75 d8                	jne    80241e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802446:	8b 45 10             	mov    0x10(%ebp),%eax
  802449:	eb 05                	jmp    802450 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80244b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802450:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802453:	5b                   	pop    %ebx
  802454:	5e                   	pop    %esi
  802455:	5f                   	pop    %edi
  802456:	5d                   	pop    %ebp
  802457:	c3                   	ret    

00802458 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802458:	55                   	push   %ebp
  802459:	89 e5                	mov    %esp,%ebp
  80245b:	56                   	push   %esi
  80245c:	53                   	push   %ebx
  80245d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802460:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802463:	50                   	push   %eax
  802464:	e8 5f f0 ff ff       	call   8014c8 <fd_alloc>
  802469:	83 c4 10             	add    $0x10,%esp
  80246c:	89 c2                	mov    %eax,%edx
  80246e:	85 c0                	test   %eax,%eax
  802470:	0f 88 2c 01 00 00    	js     8025a2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802476:	83 ec 04             	sub    $0x4,%esp
  802479:	68 07 04 00 00       	push   $0x407
  80247e:	ff 75 f4             	pushl  -0xc(%ebp)
  802481:	6a 00                	push   $0x0
  802483:	e8 dd ea ff ff       	call   800f65 <sys_page_alloc>
  802488:	83 c4 10             	add    $0x10,%esp
  80248b:	89 c2                	mov    %eax,%edx
  80248d:	85 c0                	test   %eax,%eax
  80248f:	0f 88 0d 01 00 00    	js     8025a2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802495:	83 ec 0c             	sub    $0xc,%esp
  802498:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80249b:	50                   	push   %eax
  80249c:	e8 27 f0 ff ff       	call   8014c8 <fd_alloc>
  8024a1:	89 c3                	mov    %eax,%ebx
  8024a3:	83 c4 10             	add    $0x10,%esp
  8024a6:	85 c0                	test   %eax,%eax
  8024a8:	0f 88 e2 00 00 00    	js     802590 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024ae:	83 ec 04             	sub    $0x4,%esp
  8024b1:	68 07 04 00 00       	push   $0x407
  8024b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8024b9:	6a 00                	push   $0x0
  8024bb:	e8 a5 ea ff ff       	call   800f65 <sys_page_alloc>
  8024c0:	89 c3                	mov    %eax,%ebx
  8024c2:	83 c4 10             	add    $0x10,%esp
  8024c5:	85 c0                	test   %eax,%eax
  8024c7:	0f 88 c3 00 00 00    	js     802590 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8024cd:	83 ec 0c             	sub    $0xc,%esp
  8024d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8024d3:	e8 d9 ef ff ff       	call   8014b1 <fd2data>
  8024d8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024da:	83 c4 0c             	add    $0xc,%esp
  8024dd:	68 07 04 00 00       	push   $0x407
  8024e2:	50                   	push   %eax
  8024e3:	6a 00                	push   $0x0
  8024e5:	e8 7b ea ff ff       	call   800f65 <sys_page_alloc>
  8024ea:	89 c3                	mov    %eax,%ebx
  8024ec:	83 c4 10             	add    $0x10,%esp
  8024ef:	85 c0                	test   %eax,%eax
  8024f1:	0f 88 89 00 00 00    	js     802580 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024f7:	83 ec 0c             	sub    $0xc,%esp
  8024fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8024fd:	e8 af ef ff ff       	call   8014b1 <fd2data>
  802502:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802509:	50                   	push   %eax
  80250a:	6a 00                	push   $0x0
  80250c:	56                   	push   %esi
  80250d:	6a 00                	push   $0x0
  80250f:	e8 94 ea ff ff       	call   800fa8 <sys_page_map>
  802514:	89 c3                	mov    %eax,%ebx
  802516:	83 c4 20             	add    $0x20,%esp
  802519:	85 c0                	test   %eax,%eax
  80251b:	78 55                	js     802572 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80251d:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802523:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802526:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802528:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80252b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802532:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802538:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80253b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80253d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802540:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802547:	83 ec 0c             	sub    $0xc,%esp
  80254a:	ff 75 f4             	pushl  -0xc(%ebp)
  80254d:	e8 4f ef ff ff       	call   8014a1 <fd2num>
  802552:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802555:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802557:	83 c4 04             	add    $0x4,%esp
  80255a:	ff 75 f0             	pushl  -0x10(%ebp)
  80255d:	e8 3f ef ff ff       	call   8014a1 <fd2num>
  802562:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802565:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802568:	83 c4 10             	add    $0x10,%esp
  80256b:	ba 00 00 00 00       	mov    $0x0,%edx
  802570:	eb 30                	jmp    8025a2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802572:	83 ec 08             	sub    $0x8,%esp
  802575:	56                   	push   %esi
  802576:	6a 00                	push   $0x0
  802578:	e8 6d ea ff ff       	call   800fea <sys_page_unmap>
  80257d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802580:	83 ec 08             	sub    $0x8,%esp
  802583:	ff 75 f0             	pushl  -0x10(%ebp)
  802586:	6a 00                	push   $0x0
  802588:	e8 5d ea ff ff       	call   800fea <sys_page_unmap>
  80258d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802590:	83 ec 08             	sub    $0x8,%esp
  802593:	ff 75 f4             	pushl  -0xc(%ebp)
  802596:	6a 00                	push   $0x0
  802598:	e8 4d ea ff ff       	call   800fea <sys_page_unmap>
  80259d:	83 c4 10             	add    $0x10,%esp
  8025a0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8025a2:	89 d0                	mov    %edx,%eax
  8025a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025a7:	5b                   	pop    %ebx
  8025a8:	5e                   	pop    %esi
  8025a9:	5d                   	pop    %ebp
  8025aa:	c3                   	ret    

008025ab <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8025ab:	55                   	push   %ebp
  8025ac:	89 e5                	mov    %esp,%ebp
  8025ae:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025b4:	50                   	push   %eax
  8025b5:	ff 75 08             	pushl  0x8(%ebp)
  8025b8:	e8 5a ef ff ff       	call   801517 <fd_lookup>
  8025bd:	83 c4 10             	add    $0x10,%esp
  8025c0:	85 c0                	test   %eax,%eax
  8025c2:	78 18                	js     8025dc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8025c4:	83 ec 0c             	sub    $0xc,%esp
  8025c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8025ca:	e8 e2 ee ff ff       	call   8014b1 <fd2data>
	return _pipeisclosed(fd, p);
  8025cf:	89 c2                	mov    %eax,%edx
  8025d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d4:	e8 21 fd ff ff       	call   8022fa <_pipeisclosed>
  8025d9:	83 c4 10             	add    $0x10,%esp
}
  8025dc:	c9                   	leave  
  8025dd:	c3                   	ret    

008025de <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8025de:	55                   	push   %ebp
  8025df:	89 e5                	mov    %esp,%ebp
  8025e1:	56                   	push   %esi
  8025e2:	53                   	push   %ebx
  8025e3:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8025e6:	85 f6                	test   %esi,%esi
  8025e8:	75 16                	jne    802600 <wait+0x22>
  8025ea:	68 17 36 80 00       	push   $0x803617
  8025ef:	68 17 35 80 00       	push   $0x803517
  8025f4:	6a 09                	push   $0x9
  8025f6:	68 22 36 80 00       	push   $0x803622
  8025fb:	e8 e4 de ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  802600:	89 f3                	mov    %esi,%ebx
  802602:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802608:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80260b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802611:	eb 05                	jmp    802618 <wait+0x3a>
		sys_yield();
  802613:	e8 2e e9 ff ff       	call   800f46 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802618:	8b 43 48             	mov    0x48(%ebx),%eax
  80261b:	39 c6                	cmp    %eax,%esi
  80261d:	75 07                	jne    802626 <wait+0x48>
  80261f:	8b 43 54             	mov    0x54(%ebx),%eax
  802622:	85 c0                	test   %eax,%eax
  802624:	75 ed                	jne    802613 <wait+0x35>
		sys_yield();
}
  802626:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802629:	5b                   	pop    %ebx
  80262a:	5e                   	pop    %esi
  80262b:	5d                   	pop    %ebp
  80262c:	c3                   	ret    

0080262d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80262d:	55                   	push   %ebp
  80262e:	89 e5                	mov    %esp,%ebp
  802630:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802633:	68 2d 36 80 00       	push   $0x80362d
  802638:	ff 75 0c             	pushl  0xc(%ebp)
  80263b:	e8 22 e5 ff ff       	call   800b62 <strcpy>
	return 0;
}
  802640:	b8 00 00 00 00       	mov    $0x0,%eax
  802645:	c9                   	leave  
  802646:	c3                   	ret    

00802647 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802647:	55                   	push   %ebp
  802648:	89 e5                	mov    %esp,%ebp
  80264a:	53                   	push   %ebx
  80264b:	83 ec 10             	sub    $0x10,%esp
  80264e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802651:	53                   	push   %ebx
  802652:	e8 d1 05 00 00       	call   802c28 <pageref>
  802657:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80265a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80265f:	83 f8 01             	cmp    $0x1,%eax
  802662:	75 10                	jne    802674 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802664:	83 ec 0c             	sub    $0xc,%esp
  802667:	ff 73 0c             	pushl  0xc(%ebx)
  80266a:	e8 c0 02 00 00       	call   80292f <nsipc_close>
  80266f:	89 c2                	mov    %eax,%edx
  802671:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802674:	89 d0                	mov    %edx,%eax
  802676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802679:	c9                   	leave  
  80267a:	c3                   	ret    

0080267b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80267b:	55                   	push   %ebp
  80267c:	89 e5                	mov    %esp,%ebp
  80267e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802681:	6a 00                	push   $0x0
  802683:	ff 75 10             	pushl  0x10(%ebp)
  802686:	ff 75 0c             	pushl  0xc(%ebp)
  802689:	8b 45 08             	mov    0x8(%ebp),%eax
  80268c:	ff 70 0c             	pushl  0xc(%eax)
  80268f:	e8 78 03 00 00       	call   802a0c <nsipc_send>
}
  802694:	c9                   	leave  
  802695:	c3                   	ret    

00802696 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802696:	55                   	push   %ebp
  802697:	89 e5                	mov    %esp,%ebp
  802699:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80269c:	6a 00                	push   $0x0
  80269e:	ff 75 10             	pushl  0x10(%ebp)
  8026a1:	ff 75 0c             	pushl  0xc(%ebp)
  8026a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a7:	ff 70 0c             	pushl  0xc(%eax)
  8026aa:	e8 f1 02 00 00       	call   8029a0 <nsipc_recv>
}
  8026af:	c9                   	leave  
  8026b0:	c3                   	ret    

008026b1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8026b1:	55                   	push   %ebp
  8026b2:	89 e5                	mov    %esp,%ebp
  8026b4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8026b7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8026ba:	52                   	push   %edx
  8026bb:	50                   	push   %eax
  8026bc:	e8 56 ee ff ff       	call   801517 <fd_lookup>
  8026c1:	83 c4 10             	add    $0x10,%esp
  8026c4:	85 c0                	test   %eax,%eax
  8026c6:	78 17                	js     8026df <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8026c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026cb:	8b 0d 58 40 80 00    	mov    0x804058,%ecx
  8026d1:	39 08                	cmp    %ecx,(%eax)
  8026d3:	75 05                	jne    8026da <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8026d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8026d8:	eb 05                	jmp    8026df <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8026da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8026df:	c9                   	leave  
  8026e0:	c3                   	ret    

008026e1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8026e1:	55                   	push   %ebp
  8026e2:	89 e5                	mov    %esp,%ebp
  8026e4:	56                   	push   %esi
  8026e5:	53                   	push   %ebx
  8026e6:	83 ec 1c             	sub    $0x1c,%esp
  8026e9:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8026eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026ee:	50                   	push   %eax
  8026ef:	e8 d4 ed ff ff       	call   8014c8 <fd_alloc>
  8026f4:	89 c3                	mov    %eax,%ebx
  8026f6:	83 c4 10             	add    $0x10,%esp
  8026f9:	85 c0                	test   %eax,%eax
  8026fb:	78 1b                	js     802718 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8026fd:	83 ec 04             	sub    $0x4,%esp
  802700:	68 07 04 00 00       	push   $0x407
  802705:	ff 75 f4             	pushl  -0xc(%ebp)
  802708:	6a 00                	push   $0x0
  80270a:	e8 56 e8 ff ff       	call   800f65 <sys_page_alloc>
  80270f:	89 c3                	mov    %eax,%ebx
  802711:	83 c4 10             	add    $0x10,%esp
  802714:	85 c0                	test   %eax,%eax
  802716:	79 10                	jns    802728 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802718:	83 ec 0c             	sub    $0xc,%esp
  80271b:	56                   	push   %esi
  80271c:	e8 0e 02 00 00       	call   80292f <nsipc_close>
		return r;
  802721:	83 c4 10             	add    $0x10,%esp
  802724:	89 d8                	mov    %ebx,%eax
  802726:	eb 24                	jmp    80274c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802728:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80272e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802731:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802736:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80273d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802740:	83 ec 0c             	sub    $0xc,%esp
  802743:	50                   	push   %eax
  802744:	e8 58 ed ff ff       	call   8014a1 <fd2num>
  802749:	83 c4 10             	add    $0x10,%esp
}
  80274c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80274f:	5b                   	pop    %ebx
  802750:	5e                   	pop    %esi
  802751:	5d                   	pop    %ebp
  802752:	c3                   	ret    

00802753 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802753:	55                   	push   %ebp
  802754:	89 e5                	mov    %esp,%ebp
  802756:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802759:	8b 45 08             	mov    0x8(%ebp),%eax
  80275c:	e8 50 ff ff ff       	call   8026b1 <fd2sockid>
		return r;
  802761:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802763:	85 c0                	test   %eax,%eax
  802765:	78 1f                	js     802786 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802767:	83 ec 04             	sub    $0x4,%esp
  80276a:	ff 75 10             	pushl  0x10(%ebp)
  80276d:	ff 75 0c             	pushl  0xc(%ebp)
  802770:	50                   	push   %eax
  802771:	e8 12 01 00 00       	call   802888 <nsipc_accept>
  802776:	83 c4 10             	add    $0x10,%esp
		return r;
  802779:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80277b:	85 c0                	test   %eax,%eax
  80277d:	78 07                	js     802786 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80277f:	e8 5d ff ff ff       	call   8026e1 <alloc_sockfd>
  802784:	89 c1                	mov    %eax,%ecx
}
  802786:	89 c8                	mov    %ecx,%eax
  802788:	c9                   	leave  
  802789:	c3                   	ret    

0080278a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80278a:	55                   	push   %ebp
  80278b:	89 e5                	mov    %esp,%ebp
  80278d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802790:	8b 45 08             	mov    0x8(%ebp),%eax
  802793:	e8 19 ff ff ff       	call   8026b1 <fd2sockid>
  802798:	85 c0                	test   %eax,%eax
  80279a:	78 12                	js     8027ae <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80279c:	83 ec 04             	sub    $0x4,%esp
  80279f:	ff 75 10             	pushl  0x10(%ebp)
  8027a2:	ff 75 0c             	pushl  0xc(%ebp)
  8027a5:	50                   	push   %eax
  8027a6:	e8 2d 01 00 00       	call   8028d8 <nsipc_bind>
  8027ab:	83 c4 10             	add    $0x10,%esp
}
  8027ae:	c9                   	leave  
  8027af:	c3                   	ret    

008027b0 <shutdown>:

int
shutdown(int s, int how)
{
  8027b0:	55                   	push   %ebp
  8027b1:	89 e5                	mov    %esp,%ebp
  8027b3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8027b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8027b9:	e8 f3 fe ff ff       	call   8026b1 <fd2sockid>
  8027be:	85 c0                	test   %eax,%eax
  8027c0:	78 0f                	js     8027d1 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8027c2:	83 ec 08             	sub    $0x8,%esp
  8027c5:	ff 75 0c             	pushl  0xc(%ebp)
  8027c8:	50                   	push   %eax
  8027c9:	e8 3f 01 00 00       	call   80290d <nsipc_shutdown>
  8027ce:	83 c4 10             	add    $0x10,%esp
}
  8027d1:	c9                   	leave  
  8027d2:	c3                   	ret    

008027d3 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8027d3:	55                   	push   %ebp
  8027d4:	89 e5                	mov    %esp,%ebp
  8027d6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8027d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8027dc:	e8 d0 fe ff ff       	call   8026b1 <fd2sockid>
  8027e1:	85 c0                	test   %eax,%eax
  8027e3:	78 12                	js     8027f7 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8027e5:	83 ec 04             	sub    $0x4,%esp
  8027e8:	ff 75 10             	pushl  0x10(%ebp)
  8027eb:	ff 75 0c             	pushl  0xc(%ebp)
  8027ee:	50                   	push   %eax
  8027ef:	e8 55 01 00 00       	call   802949 <nsipc_connect>
  8027f4:	83 c4 10             	add    $0x10,%esp
}
  8027f7:	c9                   	leave  
  8027f8:	c3                   	ret    

008027f9 <listen>:

int
listen(int s, int backlog)
{
  8027f9:	55                   	push   %ebp
  8027fa:	89 e5                	mov    %esp,%ebp
  8027fc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8027ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802802:	e8 aa fe ff ff       	call   8026b1 <fd2sockid>
  802807:	85 c0                	test   %eax,%eax
  802809:	78 0f                	js     80281a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80280b:	83 ec 08             	sub    $0x8,%esp
  80280e:	ff 75 0c             	pushl  0xc(%ebp)
  802811:	50                   	push   %eax
  802812:	e8 67 01 00 00       	call   80297e <nsipc_listen>
  802817:	83 c4 10             	add    $0x10,%esp
}
  80281a:	c9                   	leave  
  80281b:	c3                   	ret    

0080281c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80281c:	55                   	push   %ebp
  80281d:	89 e5                	mov    %esp,%ebp
  80281f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802822:	ff 75 10             	pushl  0x10(%ebp)
  802825:	ff 75 0c             	pushl  0xc(%ebp)
  802828:	ff 75 08             	pushl  0x8(%ebp)
  80282b:	e8 3a 02 00 00       	call   802a6a <nsipc_socket>
  802830:	83 c4 10             	add    $0x10,%esp
  802833:	85 c0                	test   %eax,%eax
  802835:	78 05                	js     80283c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802837:	e8 a5 fe ff ff       	call   8026e1 <alloc_sockfd>
}
  80283c:	c9                   	leave  
  80283d:	c3                   	ret    

0080283e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80283e:	55                   	push   %ebp
  80283f:	89 e5                	mov    %esp,%ebp
  802841:	53                   	push   %ebx
  802842:	83 ec 04             	sub    $0x4,%esp
  802845:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802847:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  80284e:	75 12                	jne    802862 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802850:	83 ec 0c             	sub    $0xc,%esp
  802853:	6a 02                	push   $0x2
  802855:	e8 95 03 00 00       	call   802bef <ipc_find_env>
  80285a:	a3 04 50 80 00       	mov    %eax,0x805004
  80285f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802862:	6a 07                	push   $0x7
  802864:	68 00 70 80 00       	push   $0x807000
  802869:	53                   	push   %ebx
  80286a:	ff 35 04 50 80 00    	pushl  0x805004
  802870:	e8 2b 03 00 00       	call   802ba0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802875:	83 c4 0c             	add    $0xc,%esp
  802878:	6a 00                	push   $0x0
  80287a:	6a 00                	push   $0x0
  80287c:	6a 00                	push   $0x0
  80287e:	e8 a7 02 00 00       	call   802b2a <ipc_recv>
}
  802883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802886:	c9                   	leave  
  802887:	c3                   	ret    

00802888 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802888:	55                   	push   %ebp
  802889:	89 e5                	mov    %esp,%ebp
  80288b:	56                   	push   %esi
  80288c:	53                   	push   %ebx
  80288d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802890:	8b 45 08             	mov    0x8(%ebp),%eax
  802893:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802898:	8b 06                	mov    (%esi),%eax
  80289a:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80289f:	b8 01 00 00 00       	mov    $0x1,%eax
  8028a4:	e8 95 ff ff ff       	call   80283e <nsipc>
  8028a9:	89 c3                	mov    %eax,%ebx
  8028ab:	85 c0                	test   %eax,%eax
  8028ad:	78 20                	js     8028cf <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8028af:	83 ec 04             	sub    $0x4,%esp
  8028b2:	ff 35 10 70 80 00    	pushl  0x807010
  8028b8:	68 00 70 80 00       	push   $0x807000
  8028bd:	ff 75 0c             	pushl  0xc(%ebp)
  8028c0:	e8 2f e4 ff ff       	call   800cf4 <memmove>
		*addrlen = ret->ret_addrlen;
  8028c5:	a1 10 70 80 00       	mov    0x807010,%eax
  8028ca:	89 06                	mov    %eax,(%esi)
  8028cc:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8028cf:	89 d8                	mov    %ebx,%eax
  8028d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8028d4:	5b                   	pop    %ebx
  8028d5:	5e                   	pop    %esi
  8028d6:	5d                   	pop    %ebp
  8028d7:	c3                   	ret    

008028d8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8028d8:	55                   	push   %ebp
  8028d9:	89 e5                	mov    %esp,%ebp
  8028db:	53                   	push   %ebx
  8028dc:	83 ec 08             	sub    $0x8,%esp
  8028df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8028e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8028e5:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8028ea:	53                   	push   %ebx
  8028eb:	ff 75 0c             	pushl  0xc(%ebp)
  8028ee:	68 04 70 80 00       	push   $0x807004
  8028f3:	e8 fc e3 ff ff       	call   800cf4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8028f8:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8028fe:	b8 02 00 00 00       	mov    $0x2,%eax
  802903:	e8 36 ff ff ff       	call   80283e <nsipc>
}
  802908:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80290b:	c9                   	leave  
  80290c:	c3                   	ret    

0080290d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80290d:	55                   	push   %ebp
  80290e:	89 e5                	mov    %esp,%ebp
  802910:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802913:	8b 45 08             	mov    0x8(%ebp),%eax
  802916:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80291b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80291e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802923:	b8 03 00 00 00       	mov    $0x3,%eax
  802928:	e8 11 ff ff ff       	call   80283e <nsipc>
}
  80292d:	c9                   	leave  
  80292e:	c3                   	ret    

0080292f <nsipc_close>:

int
nsipc_close(int s)
{
  80292f:	55                   	push   %ebp
  802930:	89 e5                	mov    %esp,%ebp
  802932:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802935:	8b 45 08             	mov    0x8(%ebp),%eax
  802938:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80293d:	b8 04 00 00 00       	mov    $0x4,%eax
  802942:	e8 f7 fe ff ff       	call   80283e <nsipc>
}
  802947:	c9                   	leave  
  802948:	c3                   	ret    

00802949 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802949:	55                   	push   %ebp
  80294a:	89 e5                	mov    %esp,%ebp
  80294c:	53                   	push   %ebx
  80294d:	83 ec 08             	sub    $0x8,%esp
  802950:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802953:	8b 45 08             	mov    0x8(%ebp),%eax
  802956:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80295b:	53                   	push   %ebx
  80295c:	ff 75 0c             	pushl  0xc(%ebp)
  80295f:	68 04 70 80 00       	push   $0x807004
  802964:	e8 8b e3 ff ff       	call   800cf4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802969:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80296f:	b8 05 00 00 00       	mov    $0x5,%eax
  802974:	e8 c5 fe ff ff       	call   80283e <nsipc>
}
  802979:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80297c:	c9                   	leave  
  80297d:	c3                   	ret    

0080297e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80297e:	55                   	push   %ebp
  80297f:	89 e5                	mov    %esp,%ebp
  802981:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802984:	8b 45 08             	mov    0x8(%ebp),%eax
  802987:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80298c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80298f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802994:	b8 06 00 00 00       	mov    $0x6,%eax
  802999:	e8 a0 fe ff ff       	call   80283e <nsipc>
}
  80299e:	c9                   	leave  
  80299f:	c3                   	ret    

008029a0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8029a0:	55                   	push   %ebp
  8029a1:	89 e5                	mov    %esp,%ebp
  8029a3:	56                   	push   %esi
  8029a4:	53                   	push   %ebx
  8029a5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8029a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8029ab:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8029b0:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8029b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8029b9:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8029be:	b8 07 00 00 00       	mov    $0x7,%eax
  8029c3:	e8 76 fe ff ff       	call   80283e <nsipc>
  8029c8:	89 c3                	mov    %eax,%ebx
  8029ca:	85 c0                	test   %eax,%eax
  8029cc:	78 35                	js     802a03 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8029ce:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8029d3:	7f 04                	jg     8029d9 <nsipc_recv+0x39>
  8029d5:	39 c6                	cmp    %eax,%esi
  8029d7:	7d 16                	jge    8029ef <nsipc_recv+0x4f>
  8029d9:	68 39 36 80 00       	push   $0x803639
  8029de:	68 17 35 80 00       	push   $0x803517
  8029e3:	6a 62                	push   $0x62
  8029e5:	68 4e 36 80 00       	push   $0x80364e
  8029ea:	e8 f5 da ff ff       	call   8004e4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8029ef:	83 ec 04             	sub    $0x4,%esp
  8029f2:	50                   	push   %eax
  8029f3:	68 00 70 80 00       	push   $0x807000
  8029f8:	ff 75 0c             	pushl  0xc(%ebp)
  8029fb:	e8 f4 e2 ff ff       	call   800cf4 <memmove>
  802a00:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802a03:	89 d8                	mov    %ebx,%eax
  802a05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a08:	5b                   	pop    %ebx
  802a09:	5e                   	pop    %esi
  802a0a:	5d                   	pop    %ebp
  802a0b:	c3                   	ret    

00802a0c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802a0c:	55                   	push   %ebp
  802a0d:	89 e5                	mov    %esp,%ebp
  802a0f:	53                   	push   %ebx
  802a10:	83 ec 04             	sub    $0x4,%esp
  802a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802a16:	8b 45 08             	mov    0x8(%ebp),%eax
  802a19:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802a1e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802a24:	7e 16                	jle    802a3c <nsipc_send+0x30>
  802a26:	68 5a 36 80 00       	push   $0x80365a
  802a2b:	68 17 35 80 00       	push   $0x803517
  802a30:	6a 6d                	push   $0x6d
  802a32:	68 4e 36 80 00       	push   $0x80364e
  802a37:	e8 a8 da ff ff       	call   8004e4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802a3c:	83 ec 04             	sub    $0x4,%esp
  802a3f:	53                   	push   %ebx
  802a40:	ff 75 0c             	pushl  0xc(%ebp)
  802a43:	68 0c 70 80 00       	push   $0x80700c
  802a48:	e8 a7 e2 ff ff       	call   800cf4 <memmove>
	nsipcbuf.send.req_size = size;
  802a4d:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802a53:	8b 45 14             	mov    0x14(%ebp),%eax
  802a56:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802a5b:	b8 08 00 00 00       	mov    $0x8,%eax
  802a60:	e8 d9 fd ff ff       	call   80283e <nsipc>
}
  802a65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a68:	c9                   	leave  
  802a69:	c3                   	ret    

00802a6a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802a6a:	55                   	push   %ebp
  802a6b:	89 e5                	mov    %esp,%ebp
  802a6d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802a70:	8b 45 08             	mov    0x8(%ebp),%eax
  802a73:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a7b:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802a80:	8b 45 10             	mov    0x10(%ebp),%eax
  802a83:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802a88:	b8 09 00 00 00       	mov    $0x9,%eax
  802a8d:	e8 ac fd ff ff       	call   80283e <nsipc>
}
  802a92:	c9                   	leave  
  802a93:	c3                   	ret    

00802a94 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802a94:	55                   	push   %ebp
  802a95:	89 e5                	mov    %esp,%ebp
  802a97:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  802a9a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802aa1:	75 56                	jne    802af9 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  802aa3:	83 ec 04             	sub    $0x4,%esp
  802aa6:	6a 07                	push   $0x7
  802aa8:	68 00 f0 bf ee       	push   $0xeebff000
  802aad:	6a 00                	push   $0x0
  802aaf:	e8 b1 e4 ff ff       	call   800f65 <sys_page_alloc>
  802ab4:	83 c4 10             	add    $0x10,%esp
  802ab7:	85 c0                	test   %eax,%eax
  802ab9:	74 14                	je     802acf <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  802abb:	83 ec 04             	sub    $0x4,%esp
  802abe:	68 29 34 80 00       	push   $0x803429
  802ac3:	6a 21                	push   $0x21
  802ac5:	68 66 36 80 00       	push   $0x803666
  802aca:	e8 15 da ff ff       	call   8004e4 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  802acf:	83 ec 08             	sub    $0x8,%esp
  802ad2:	68 03 2b 80 00       	push   $0x802b03
  802ad7:	6a 00                	push   $0x0
  802ad9:	e8 d2 e5 ff ff       	call   8010b0 <sys_env_set_pgfault_upcall>
  802ade:	83 c4 10             	add    $0x10,%esp
  802ae1:	85 c0                	test   %eax,%eax
  802ae3:	74 14                	je     802af9 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  802ae5:	83 ec 04             	sub    $0x4,%esp
  802ae8:	68 74 36 80 00       	push   $0x803674
  802aed:	6a 23                	push   $0x23
  802aef:	68 66 36 80 00       	push   $0x803666
  802af4:	e8 eb d9 ff ff       	call   8004e4 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802af9:	8b 45 08             	mov    0x8(%ebp),%eax
  802afc:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802b01:	c9                   	leave  
  802b02:	c3                   	ret    

00802b03 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802b03:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802b04:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802b09:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802b0b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  802b0e:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  802b10:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  802b14:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  802b18:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  802b19:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  802b1b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  802b20:	83 c4 08             	add    $0x8,%esp
	popal
  802b23:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802b24:	83 c4 04             	add    $0x4,%esp
	popfl
  802b27:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802b28:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802b29:	c3                   	ret    

00802b2a <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802b2a:	55                   	push   %ebp
  802b2b:	89 e5                	mov    %esp,%ebp
  802b2d:	56                   	push   %esi
  802b2e:	53                   	push   %ebx
  802b2f:	8b 75 08             	mov    0x8(%ebp),%esi
  802b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  802b38:	85 c0                	test   %eax,%eax
  802b3a:	74 0e                	je     802b4a <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  802b3c:	83 ec 0c             	sub    $0xc,%esp
  802b3f:	50                   	push   %eax
  802b40:	e8 d0 e5 ff ff       	call   801115 <sys_ipc_recv>
  802b45:	83 c4 10             	add    $0x10,%esp
  802b48:	eb 10                	jmp    802b5a <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802b4a:	83 ec 0c             	sub    $0xc,%esp
  802b4d:	68 00 00 c0 ee       	push   $0xeec00000
  802b52:	e8 be e5 ff ff       	call   801115 <sys_ipc_recv>
  802b57:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  802b5a:	85 c0                	test   %eax,%eax
  802b5c:	79 17                	jns    802b75 <ipc_recv+0x4b>
		if(*from_env_store)
  802b5e:	83 3e 00             	cmpl   $0x0,(%esi)
  802b61:	74 06                	je     802b69 <ipc_recv+0x3f>
			*from_env_store = 0;
  802b63:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  802b69:	85 db                	test   %ebx,%ebx
  802b6b:	74 2c                	je     802b99 <ipc_recv+0x6f>
			*perm_store = 0;
  802b6d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802b73:	eb 24                	jmp    802b99 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  802b75:	85 f6                	test   %esi,%esi
  802b77:	74 0a                	je     802b83 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  802b79:	a1 08 50 80 00       	mov    0x805008,%eax
  802b7e:	8b 40 74             	mov    0x74(%eax),%eax
  802b81:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802b83:	85 db                	test   %ebx,%ebx
  802b85:	74 0a                	je     802b91 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  802b87:	a1 08 50 80 00       	mov    0x805008,%eax
  802b8c:	8b 40 78             	mov    0x78(%eax),%eax
  802b8f:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802b91:	a1 08 50 80 00       	mov    0x805008,%eax
  802b96:	8b 40 70             	mov    0x70(%eax),%eax
}
  802b99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b9c:	5b                   	pop    %ebx
  802b9d:	5e                   	pop    %esi
  802b9e:	5d                   	pop    %ebp
  802b9f:	c3                   	ret    

00802ba0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802ba0:	55                   	push   %ebp
  802ba1:	89 e5                	mov    %esp,%ebp
  802ba3:	57                   	push   %edi
  802ba4:	56                   	push   %esi
  802ba5:	53                   	push   %ebx
  802ba6:	83 ec 0c             	sub    $0xc,%esp
  802ba9:	8b 7d 08             	mov    0x8(%ebp),%edi
  802bac:	8b 75 0c             	mov    0xc(%ebp),%esi
  802baf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802bb2:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  802bb4:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802bb9:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802bbc:	e8 85 e3 ff ff       	call   800f46 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  802bc1:	ff 75 14             	pushl  0x14(%ebp)
  802bc4:	53                   	push   %ebx
  802bc5:	56                   	push   %esi
  802bc6:	57                   	push   %edi
  802bc7:	e8 26 e5 ff ff       	call   8010f2 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802bcc:	89 c2                	mov    %eax,%edx
  802bce:	f7 d2                	not    %edx
  802bd0:	c1 ea 1f             	shr    $0x1f,%edx
  802bd3:	83 c4 10             	add    $0x10,%esp
  802bd6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802bd9:	0f 94 c1             	sete   %cl
  802bdc:	09 ca                	or     %ecx,%edx
  802bde:	85 c0                	test   %eax,%eax
  802be0:	0f 94 c0             	sete   %al
  802be3:	38 c2                	cmp    %al,%dl
  802be5:	77 d5                	ja     802bbc <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bea:	5b                   	pop    %ebx
  802beb:	5e                   	pop    %esi
  802bec:	5f                   	pop    %edi
  802bed:	5d                   	pop    %ebp
  802bee:	c3                   	ret    

00802bef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802bef:	55                   	push   %ebp
  802bf0:	89 e5                	mov    %esp,%ebp
  802bf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802bf5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802bfa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802bfd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802c03:	8b 52 50             	mov    0x50(%edx),%edx
  802c06:	39 ca                	cmp    %ecx,%edx
  802c08:	75 0d                	jne    802c17 <ipc_find_env+0x28>
			return envs[i].env_id;
  802c0a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802c0d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802c12:	8b 40 48             	mov    0x48(%eax),%eax
  802c15:	eb 0f                	jmp    802c26 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802c17:	83 c0 01             	add    $0x1,%eax
  802c1a:	3d 00 04 00 00       	cmp    $0x400,%eax
  802c1f:	75 d9                	jne    802bfa <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802c21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802c26:	5d                   	pop    %ebp
  802c27:	c3                   	ret    

00802c28 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802c28:	55                   	push   %ebp
  802c29:	89 e5                	mov    %esp,%ebp
  802c2b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802c2e:	89 d0                	mov    %edx,%eax
  802c30:	c1 e8 16             	shr    $0x16,%eax
  802c33:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802c3a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802c3f:	f6 c1 01             	test   $0x1,%cl
  802c42:	74 1d                	je     802c61 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802c44:	c1 ea 0c             	shr    $0xc,%edx
  802c47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802c4e:	f6 c2 01             	test   $0x1,%dl
  802c51:	74 0e                	je     802c61 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802c53:	c1 ea 0c             	shr    $0xc,%edx
  802c56:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802c5d:	ef 
  802c5e:	0f b7 c0             	movzwl %ax,%eax
}
  802c61:	5d                   	pop    %ebp
  802c62:	c3                   	ret    
  802c63:	66 90                	xchg   %ax,%ax
  802c65:	66 90                	xchg   %ax,%ax
  802c67:	66 90                	xchg   %ax,%ax
  802c69:	66 90                	xchg   %ax,%ax
  802c6b:	66 90                	xchg   %ax,%ax
  802c6d:	66 90                	xchg   %ax,%ax
  802c6f:	90                   	nop

00802c70 <__udivdi3>:
  802c70:	55                   	push   %ebp
  802c71:	57                   	push   %edi
  802c72:	56                   	push   %esi
  802c73:	53                   	push   %ebx
  802c74:	83 ec 1c             	sub    $0x1c,%esp
  802c77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802c7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802c7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802c87:	85 f6                	test   %esi,%esi
  802c89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c8d:	89 ca                	mov    %ecx,%edx
  802c8f:	89 f8                	mov    %edi,%eax
  802c91:	75 3d                	jne    802cd0 <__udivdi3+0x60>
  802c93:	39 cf                	cmp    %ecx,%edi
  802c95:	0f 87 c5 00 00 00    	ja     802d60 <__udivdi3+0xf0>
  802c9b:	85 ff                	test   %edi,%edi
  802c9d:	89 fd                	mov    %edi,%ebp
  802c9f:	75 0b                	jne    802cac <__udivdi3+0x3c>
  802ca1:	b8 01 00 00 00       	mov    $0x1,%eax
  802ca6:	31 d2                	xor    %edx,%edx
  802ca8:	f7 f7                	div    %edi
  802caa:	89 c5                	mov    %eax,%ebp
  802cac:	89 c8                	mov    %ecx,%eax
  802cae:	31 d2                	xor    %edx,%edx
  802cb0:	f7 f5                	div    %ebp
  802cb2:	89 c1                	mov    %eax,%ecx
  802cb4:	89 d8                	mov    %ebx,%eax
  802cb6:	89 cf                	mov    %ecx,%edi
  802cb8:	f7 f5                	div    %ebp
  802cba:	89 c3                	mov    %eax,%ebx
  802cbc:	89 d8                	mov    %ebx,%eax
  802cbe:	89 fa                	mov    %edi,%edx
  802cc0:	83 c4 1c             	add    $0x1c,%esp
  802cc3:	5b                   	pop    %ebx
  802cc4:	5e                   	pop    %esi
  802cc5:	5f                   	pop    %edi
  802cc6:	5d                   	pop    %ebp
  802cc7:	c3                   	ret    
  802cc8:	90                   	nop
  802cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802cd0:	39 ce                	cmp    %ecx,%esi
  802cd2:	77 74                	ja     802d48 <__udivdi3+0xd8>
  802cd4:	0f bd fe             	bsr    %esi,%edi
  802cd7:	83 f7 1f             	xor    $0x1f,%edi
  802cda:	0f 84 98 00 00 00    	je     802d78 <__udivdi3+0x108>
  802ce0:	bb 20 00 00 00       	mov    $0x20,%ebx
  802ce5:	89 f9                	mov    %edi,%ecx
  802ce7:	89 c5                	mov    %eax,%ebp
  802ce9:	29 fb                	sub    %edi,%ebx
  802ceb:	d3 e6                	shl    %cl,%esi
  802ced:	89 d9                	mov    %ebx,%ecx
  802cef:	d3 ed                	shr    %cl,%ebp
  802cf1:	89 f9                	mov    %edi,%ecx
  802cf3:	d3 e0                	shl    %cl,%eax
  802cf5:	09 ee                	or     %ebp,%esi
  802cf7:	89 d9                	mov    %ebx,%ecx
  802cf9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802cfd:	89 d5                	mov    %edx,%ebp
  802cff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802d03:	d3 ed                	shr    %cl,%ebp
  802d05:	89 f9                	mov    %edi,%ecx
  802d07:	d3 e2                	shl    %cl,%edx
  802d09:	89 d9                	mov    %ebx,%ecx
  802d0b:	d3 e8                	shr    %cl,%eax
  802d0d:	09 c2                	or     %eax,%edx
  802d0f:	89 d0                	mov    %edx,%eax
  802d11:	89 ea                	mov    %ebp,%edx
  802d13:	f7 f6                	div    %esi
  802d15:	89 d5                	mov    %edx,%ebp
  802d17:	89 c3                	mov    %eax,%ebx
  802d19:	f7 64 24 0c          	mull   0xc(%esp)
  802d1d:	39 d5                	cmp    %edx,%ebp
  802d1f:	72 10                	jb     802d31 <__udivdi3+0xc1>
  802d21:	8b 74 24 08          	mov    0x8(%esp),%esi
  802d25:	89 f9                	mov    %edi,%ecx
  802d27:	d3 e6                	shl    %cl,%esi
  802d29:	39 c6                	cmp    %eax,%esi
  802d2b:	73 07                	jae    802d34 <__udivdi3+0xc4>
  802d2d:	39 d5                	cmp    %edx,%ebp
  802d2f:	75 03                	jne    802d34 <__udivdi3+0xc4>
  802d31:	83 eb 01             	sub    $0x1,%ebx
  802d34:	31 ff                	xor    %edi,%edi
  802d36:	89 d8                	mov    %ebx,%eax
  802d38:	89 fa                	mov    %edi,%edx
  802d3a:	83 c4 1c             	add    $0x1c,%esp
  802d3d:	5b                   	pop    %ebx
  802d3e:	5e                   	pop    %esi
  802d3f:	5f                   	pop    %edi
  802d40:	5d                   	pop    %ebp
  802d41:	c3                   	ret    
  802d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802d48:	31 ff                	xor    %edi,%edi
  802d4a:	31 db                	xor    %ebx,%ebx
  802d4c:	89 d8                	mov    %ebx,%eax
  802d4e:	89 fa                	mov    %edi,%edx
  802d50:	83 c4 1c             	add    $0x1c,%esp
  802d53:	5b                   	pop    %ebx
  802d54:	5e                   	pop    %esi
  802d55:	5f                   	pop    %edi
  802d56:	5d                   	pop    %ebp
  802d57:	c3                   	ret    
  802d58:	90                   	nop
  802d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802d60:	89 d8                	mov    %ebx,%eax
  802d62:	f7 f7                	div    %edi
  802d64:	31 ff                	xor    %edi,%edi
  802d66:	89 c3                	mov    %eax,%ebx
  802d68:	89 d8                	mov    %ebx,%eax
  802d6a:	89 fa                	mov    %edi,%edx
  802d6c:	83 c4 1c             	add    $0x1c,%esp
  802d6f:	5b                   	pop    %ebx
  802d70:	5e                   	pop    %esi
  802d71:	5f                   	pop    %edi
  802d72:	5d                   	pop    %ebp
  802d73:	c3                   	ret    
  802d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d78:	39 ce                	cmp    %ecx,%esi
  802d7a:	72 0c                	jb     802d88 <__udivdi3+0x118>
  802d7c:	31 db                	xor    %ebx,%ebx
  802d7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802d82:	0f 87 34 ff ff ff    	ja     802cbc <__udivdi3+0x4c>
  802d88:	bb 01 00 00 00       	mov    $0x1,%ebx
  802d8d:	e9 2a ff ff ff       	jmp    802cbc <__udivdi3+0x4c>
  802d92:	66 90                	xchg   %ax,%ax
  802d94:	66 90                	xchg   %ax,%ax
  802d96:	66 90                	xchg   %ax,%ax
  802d98:	66 90                	xchg   %ax,%ax
  802d9a:	66 90                	xchg   %ax,%ax
  802d9c:	66 90                	xchg   %ax,%ax
  802d9e:	66 90                	xchg   %ax,%ax

00802da0 <__umoddi3>:
  802da0:	55                   	push   %ebp
  802da1:	57                   	push   %edi
  802da2:	56                   	push   %esi
  802da3:	53                   	push   %ebx
  802da4:	83 ec 1c             	sub    $0x1c,%esp
  802da7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802dab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802daf:	8b 74 24 34          	mov    0x34(%esp),%esi
  802db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802db7:	85 d2                	test   %edx,%edx
  802db9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802dbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802dc1:	89 f3                	mov    %esi,%ebx
  802dc3:	89 3c 24             	mov    %edi,(%esp)
  802dc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802dca:	75 1c                	jne    802de8 <__umoddi3+0x48>
  802dcc:	39 f7                	cmp    %esi,%edi
  802dce:	76 50                	jbe    802e20 <__umoddi3+0x80>
  802dd0:	89 c8                	mov    %ecx,%eax
  802dd2:	89 f2                	mov    %esi,%edx
  802dd4:	f7 f7                	div    %edi
  802dd6:	89 d0                	mov    %edx,%eax
  802dd8:	31 d2                	xor    %edx,%edx
  802dda:	83 c4 1c             	add    $0x1c,%esp
  802ddd:	5b                   	pop    %ebx
  802dde:	5e                   	pop    %esi
  802ddf:	5f                   	pop    %edi
  802de0:	5d                   	pop    %ebp
  802de1:	c3                   	ret    
  802de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802de8:	39 f2                	cmp    %esi,%edx
  802dea:	89 d0                	mov    %edx,%eax
  802dec:	77 52                	ja     802e40 <__umoddi3+0xa0>
  802dee:	0f bd ea             	bsr    %edx,%ebp
  802df1:	83 f5 1f             	xor    $0x1f,%ebp
  802df4:	75 5a                	jne    802e50 <__umoddi3+0xb0>
  802df6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802dfa:	0f 82 e0 00 00 00    	jb     802ee0 <__umoddi3+0x140>
  802e00:	39 0c 24             	cmp    %ecx,(%esp)
  802e03:	0f 86 d7 00 00 00    	jbe    802ee0 <__umoddi3+0x140>
  802e09:	8b 44 24 08          	mov    0x8(%esp),%eax
  802e0d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802e11:	83 c4 1c             	add    $0x1c,%esp
  802e14:	5b                   	pop    %ebx
  802e15:	5e                   	pop    %esi
  802e16:	5f                   	pop    %edi
  802e17:	5d                   	pop    %ebp
  802e18:	c3                   	ret    
  802e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802e20:	85 ff                	test   %edi,%edi
  802e22:	89 fd                	mov    %edi,%ebp
  802e24:	75 0b                	jne    802e31 <__umoddi3+0x91>
  802e26:	b8 01 00 00 00       	mov    $0x1,%eax
  802e2b:	31 d2                	xor    %edx,%edx
  802e2d:	f7 f7                	div    %edi
  802e2f:	89 c5                	mov    %eax,%ebp
  802e31:	89 f0                	mov    %esi,%eax
  802e33:	31 d2                	xor    %edx,%edx
  802e35:	f7 f5                	div    %ebp
  802e37:	89 c8                	mov    %ecx,%eax
  802e39:	f7 f5                	div    %ebp
  802e3b:	89 d0                	mov    %edx,%eax
  802e3d:	eb 99                	jmp    802dd8 <__umoddi3+0x38>
  802e3f:	90                   	nop
  802e40:	89 c8                	mov    %ecx,%eax
  802e42:	89 f2                	mov    %esi,%edx
  802e44:	83 c4 1c             	add    $0x1c,%esp
  802e47:	5b                   	pop    %ebx
  802e48:	5e                   	pop    %esi
  802e49:	5f                   	pop    %edi
  802e4a:	5d                   	pop    %ebp
  802e4b:	c3                   	ret    
  802e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802e50:	8b 34 24             	mov    (%esp),%esi
  802e53:	bf 20 00 00 00       	mov    $0x20,%edi
  802e58:	89 e9                	mov    %ebp,%ecx
  802e5a:	29 ef                	sub    %ebp,%edi
  802e5c:	d3 e0                	shl    %cl,%eax
  802e5e:	89 f9                	mov    %edi,%ecx
  802e60:	89 f2                	mov    %esi,%edx
  802e62:	d3 ea                	shr    %cl,%edx
  802e64:	89 e9                	mov    %ebp,%ecx
  802e66:	09 c2                	or     %eax,%edx
  802e68:	89 d8                	mov    %ebx,%eax
  802e6a:	89 14 24             	mov    %edx,(%esp)
  802e6d:	89 f2                	mov    %esi,%edx
  802e6f:	d3 e2                	shl    %cl,%edx
  802e71:	89 f9                	mov    %edi,%ecx
  802e73:	89 54 24 04          	mov    %edx,0x4(%esp)
  802e77:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802e7b:	d3 e8                	shr    %cl,%eax
  802e7d:	89 e9                	mov    %ebp,%ecx
  802e7f:	89 c6                	mov    %eax,%esi
  802e81:	d3 e3                	shl    %cl,%ebx
  802e83:	89 f9                	mov    %edi,%ecx
  802e85:	89 d0                	mov    %edx,%eax
  802e87:	d3 e8                	shr    %cl,%eax
  802e89:	89 e9                	mov    %ebp,%ecx
  802e8b:	09 d8                	or     %ebx,%eax
  802e8d:	89 d3                	mov    %edx,%ebx
  802e8f:	89 f2                	mov    %esi,%edx
  802e91:	f7 34 24             	divl   (%esp)
  802e94:	89 d6                	mov    %edx,%esi
  802e96:	d3 e3                	shl    %cl,%ebx
  802e98:	f7 64 24 04          	mull   0x4(%esp)
  802e9c:	39 d6                	cmp    %edx,%esi
  802e9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802ea2:	89 d1                	mov    %edx,%ecx
  802ea4:	89 c3                	mov    %eax,%ebx
  802ea6:	72 08                	jb     802eb0 <__umoddi3+0x110>
  802ea8:	75 11                	jne    802ebb <__umoddi3+0x11b>
  802eaa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802eae:	73 0b                	jae    802ebb <__umoddi3+0x11b>
  802eb0:	2b 44 24 04          	sub    0x4(%esp),%eax
  802eb4:	1b 14 24             	sbb    (%esp),%edx
  802eb7:	89 d1                	mov    %edx,%ecx
  802eb9:	89 c3                	mov    %eax,%ebx
  802ebb:	8b 54 24 08          	mov    0x8(%esp),%edx
  802ebf:	29 da                	sub    %ebx,%edx
  802ec1:	19 ce                	sbb    %ecx,%esi
  802ec3:	89 f9                	mov    %edi,%ecx
  802ec5:	89 f0                	mov    %esi,%eax
  802ec7:	d3 e0                	shl    %cl,%eax
  802ec9:	89 e9                	mov    %ebp,%ecx
  802ecb:	d3 ea                	shr    %cl,%edx
  802ecd:	89 e9                	mov    %ebp,%ecx
  802ecf:	d3 ee                	shr    %cl,%esi
  802ed1:	09 d0                	or     %edx,%eax
  802ed3:	89 f2                	mov    %esi,%edx
  802ed5:	83 c4 1c             	add    $0x1c,%esp
  802ed8:	5b                   	pop    %ebx
  802ed9:	5e                   	pop    %esi
  802eda:	5f                   	pop    %edi
  802edb:	5d                   	pop    %ebp
  802edc:	c3                   	ret    
  802edd:	8d 76 00             	lea    0x0(%esi),%esi
  802ee0:	29 f9                	sub    %edi,%ecx
  802ee2:	19 d6                	sbb    %edx,%esi
  802ee4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ee8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802eec:	e9 18 ff ff ff       	jmp    802e09 <__umoddi3+0x69>
