
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 84 09 00 00       	call   8009b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 80 37 80 00       	push   $0x803780
  800060:	e8 89 0a 00 00       	call   800aee <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 8f 37 80 00       	push   $0x80378f
  800084:	e8 65 0a 00 00       	call   800aee <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 9d 37 80 00       	push   $0x80379d
  8000b0:	e8 d9 11 00 00       	call   80128e <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 a2 37 80 00       	push   $0x8037a2
  8000dd:	e8 0c 0a 00 00       	call   800aee <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 b3 37 80 00       	push   $0x8037b3
  8000fb:	e8 8e 11 00 00       	call   80128e <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 a7 37 80 00       	push   $0x8037a7
  80012b:	e8 be 09 00 00       	call   800aee <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 af 37 80 00       	push   $0x8037af
  800151:	e8 38 11 00 00       	call   80128e <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 bb 37 80 00       	push   $0x8037bb
  800180:	e8 69 09 00 00       	call   800aee <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 cc 00 00 00    	je     80030d <runcmd+0x104>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 3b 02 00 00    	je     800489 <runcmd+0x280>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1f 02 00 00       	jmp    800477 <runcmd+0x26e>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 25 01 00 00    	je     80038b <runcmd+0x182>
  800266:	e9 0c 02 00 00       	jmp    800477 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 c5 37 80 00       	push   $0x8037c5
  800278:	e8 71 08 00 00       	call   800aee <cprintf>
				exit();
  80027d:	e8 79 07 00 00       	call   8009fb <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 18 39 80 00       	push   $0x803918
  8002ac:	e8 3d 08 00 00       	call   800aee <cprintf>
				exit();
  8002b1:	e8 45 07 00 00       	call   8009fb <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if((fd = open (t, O_RDONLY)) < 0){
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 c6 20 00 00       	call   80238c <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 d9 37 80 00       	push   $0x8037d9
  8002db:	e8 0e 08 00 00       	call   800aee <cprintf>
				exit();
  8002e0:	e8 16 07 00 00       	call   8009fb <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	eb 08                	jmp    8002f2 <runcmd+0xe9>
			}
			if(fd != 0){
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 38 ff ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 0);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	57                   	push   %edi
  8002f8:	e8 0c 1b 00 00       	call   801e09 <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 b4 1a 00 00       	call   801db9 <close>
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	e9 1d ff ff ff       	jmp    80022a <runcmd+0x21>
			//panic("< redirection not implemented");
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	53                   	push   %ebx
  800311:	6a 00                	push   $0x0
  800313:	e8 86 fe ff ff       	call   80019e <gettoken>
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	83 f8 77             	cmp    $0x77,%eax
  80031e:	74 15                	je     800335 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	68 40 39 80 00       	push   $0x803940
  800328:	e8 c1 07 00 00       	call   800aee <cprintf>
				exit();
  80032d:	e8 c9 06 00 00       	call   8009fb <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 47 20 00 00       	call   80238c <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 ee 37 80 00       	push   $0x8037ee
  80035a:	e8 8f 07 00 00       	call   800aee <cprintf>
				exit();
  80035f:	e8 97 06 00 00       	call   8009fb <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 8e 1a 00 00       	call   801e09 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 36 1a 00 00       	call   801db9 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 46 29 00 00       	call   802ce0 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 04 38 80 00       	push   $0x803804
  8003aa:	e8 3f 07 00 00       	call   800aee <cprintf>
				exit();
  8003af:	e8 47 06 00 00       	call   8009fb <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 0d 38 80 00       	push   $0x80380d
  8003d4:	e8 15 07 00 00       	call   800aee <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 ac 14 00 00       	call   80188d <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 1a 38 80 00       	push   $0x80381a
  8003f0:	e8 f9 06 00 00       	call   800aee <cprintf>
				exit();
  8003f5:	e8 01 06 00 00       	call   8009fb <exit>
  8003fa:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	75 3c                	jne    80043d <runcmd+0x234>
				if (p[0] != 0) {
  800401:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[0], 0);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 00                	push   $0x0
  800410:	50                   	push   %eax
  800411:	e8 f3 19 00 00       	call   801e09 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 95 19 00 00       	call   801db9 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 84 19 00 00       	call   801db9 <close>
				goto again;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 e8 fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043d:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800443:	83 f8 01             	cmp    $0x1,%eax
  800446:	74 1c                	je     800464 <runcmd+0x25b>
					dup(p[1], 1);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	6a 01                	push   $0x1
  80044d:	50                   	push   %eax
  80044e:	e8 b6 19 00 00       	call   801e09 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 58 19 00 00       	call   801db9 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 47 19 00 00       	call   801db9 <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 23 38 80 00       	push   $0x803823
  80047d:	6a 78                	push   $0x78
  80047f:	68 3f 38 80 00       	push   $0x80383f
  800484:	e8 8c 05 00 00       	call   800a15 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800489:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 22                	jne    8004b4 <runcmd+0x2ab>
		if (debug)
  800492:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800499:	0f 84 96 01 00 00    	je     800635 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	68 49 38 80 00       	push   $0x803849
  8004a7:	e8 42 06 00 00       	call   800aee <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 81 01 00 00       	jmp    800635 <runcmd+0x42c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004ba:	74 23                	je     8004df <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004bc:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	50                   	push   %eax
  8004c7:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cd:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 ad 0c 00 00       	call   801186 <strcpy>
		argv[0] = argv0buf;
  8004d9:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e6:	00 

	// Print the command.
	if (debug) {
  8004e7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ee:	74 49                	je     800539 <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f0:	a1 28 54 80 00       	mov    0x805428,%eax
  8004f5:	8b 40 48             	mov    0x48(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 58 38 80 00       	push   $0x803858
  800501:	e8 e8 05 00 00       	call   800aee <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 e0 38 80 00       	push   $0x8038e0
  800517:	e8 d2 05 00 00       	call   800aee <cprintf>
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800522:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e5                	jne    80050e <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	68 a0 37 80 00       	push   $0x8037a0
  800531:	e8 b8 05 00 00       	call   800aee <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 f8 1f 00 00       	call   802540 <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 66 38 80 00       	push   $0x803866
  800561:	e8 88 05 00 00       	call   800aee <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 79 18 00 00       	call   801de4 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 28 54 80 00       	mov    0x805428,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 74 38 80 00       	push   $0x803874
  800582:	e8 67 05 00 00       	call   800aee <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 d3 28 00 00       	call   802e66 <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 28 54 80 00       	mov    0x805428,%eax
  8005a8:	8b 40 48             	mov    0x48(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 89 38 80 00       	push   $0x803889
  8005b4:	e8 35 05 00 00       	call   800aee <cprintf>
  8005b9:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	74 51                	je     800611 <runcmd+0x408>
		if (debug)
  8005c0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c7:	74 1a                	je     8005e3 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c9:	a1 28 54 80 00       	mov    0x805428,%eax
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 9f 38 80 00       	push   $0x80389f
  8005db:	e8 0e 05 00 00       	call   800aee <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 7a 28 00 00       	call   802e66 <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 28 54 80 00       	mov    0x805428,%eax
  8005fd:	8b 40 48             	mov    0x48(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 89 38 80 00       	push   $0x803889
  800609:	e8 e0 04 00 00       	call   800aee <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 e5 03 00 00       	call   8009fb <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 c7 17 00 00       	call   801de4 <close_all>
	if (r >= 0) {
		if (debug)
  80061d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800624:	0f 84 60 ff ff ff    	je     80058a <runcmd+0x381>
  80062a:	e9 41 ff ff ff       	jmp    800570 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062f:	85 ff                	test   %edi,%edi
  800631:	75 b0                	jne    8005e3 <runcmd+0x3da>
  800633:	eb dc                	jmp    800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <usage>:
}


void
usage(void)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800643:	68 68 39 80 00       	push   $0x803968
  800648:	e8 a1 04 00 00       	call   800aee <cprintf>
	exit();
  80064d:	e8 a9 03 00 00       	call   8009fb <exit>
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <umain>:

void
umain(int argc, char **argv)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	83 ec 30             	sub    $0x30,%esp
  800660:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800663:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	57                   	push   %edi
  800668:	8d 45 08             	lea    0x8(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 54 14 00 00       	call   801ac5 <argstart>
	while ((r = argnext(&args)) >= 0)
  800671:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800674:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067b:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800680:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800683:	eb 2f                	jmp    8006b4 <umain+0x5d>
		switch (r) {
  800685:	83 f8 69             	cmp    $0x69,%eax
  800688:	74 25                	je     8006af <umain+0x58>
  80068a:	83 f8 78             	cmp    $0x78,%eax
  80068d:	74 07                	je     800696 <umain+0x3f>
  80068f:	83 f8 64             	cmp    $0x64,%eax
  800692:	75 14                	jne    8006a8 <umain+0x51>
  800694:	eb 09                	jmp    80069f <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800696:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069d:	eb 15                	jmp    8006b4 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069f:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a6:	eb 0c                	jmp    8006b4 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a8:	e8 90 ff ff ff       	call   80063d <usage>
  8006ad:	eb 05                	jmp    8006b4 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006af:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	e8 38 14 00 00       	call   801af5 <argnext>
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	79 c1                	jns    800685 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c8:	7e 05                	jle    8006cf <umain+0x78>
		usage();
  8006ca:	e8 6e ff ff ff       	call   80063d <usage>
	if (argc == 2) {
  8006cf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d3:	75 56                	jne    80072b <umain+0xd4>
		close(0);
  8006d5:	83 ec 0c             	sub    $0xc,%esp
  8006d8:	6a 00                	push   $0x0
  8006da:	e8 da 16 00 00       	call   801db9 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 a0 1c 00 00       	call   80238c <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 bc 38 80 00       	push   $0x8038bc
  8006ff:	68 28 01 00 00       	push   $0x128
  800704:	68 3f 38 80 00       	push   $0x80383f
  800709:	e8 07 03 00 00       	call   800a15 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 c8 38 80 00       	push   $0x8038c8
  800717:	68 cf 38 80 00       	push   $0x8038cf
  80071c:	68 29 01 00 00       	push   $0x129
  800721:	68 3f 38 80 00       	push   $0x80383f
  800726:	e8 ea 02 00 00       	call   800a15 <_panic>
	}
	if (interactive == '?')
  80072b:	83 fe 3f             	cmp    $0x3f,%esi
  80072e:	75 0f                	jne    80073f <umain+0xe8>
		interactive = iscons(0);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	6a 00                	push   $0x0
  800735:	e8 f5 01 00 00       	call   80092f <iscons>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 f6                	test   %esi,%esi
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	bf e4 38 80 00       	mov    $0x8038e4,%edi
  80074b:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	57                   	push   %edi
  800752:	e8 03 09 00 00       	call   80105a <readline>
  800757:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	75 1e                	jne    80077e <umain+0x127>
			if (debug)
  800760:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800767:	74 10                	je     800779 <umain+0x122>
				cprintf("EXITING\n");
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	68 e7 38 80 00       	push   $0x8038e7
  800771:	e8 78 03 00 00       	call   800aee <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 7d 02 00 00       	call   8009fb <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 f0 38 80 00       	push   $0x8038f0
  800790:	e8 59 03 00 00       	call   800aee <cprintf>
  800795:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800798:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079b:	74 b1                	je     80074e <umain+0xf7>
			continue;
		if (echocmds)
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	74 11                	je     8007b4 <umain+0x15d>
			printf("# %s\n", buf);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	68 fa 38 80 00       	push   $0x8038fa
  8007ac:	e8 79 1d 00 00       	call   80252a <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 00 39 80 00       	push   $0x803900
  8007c5:	e8 24 03 00 00       	call   800aee <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 bb 10 00 00       	call   80188d <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 1a 38 80 00       	push   $0x80381a
  8007de:	68 40 01 00 00       	push   $0x140
  8007e3:	68 3f 38 80 00       	push   $0x80383f
  8007e8:	e8 28 02 00 00       	call   800a15 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 0d 39 80 00       	push   $0x80390d
  8007ff:	e8 ea 02 00 00       	call   800aee <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 e2 01 00 00       	call   8009fb <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 3c 26 00 00       	call   802e66 <wait>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	e9 1c ff ff ff       	jmp    80074e <umain+0xf7>

00800832 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800842:	68 89 39 80 00       	push   $0x803989
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	e8 37 09 00 00       	call   801186 <strcpy>
	return 0;
}
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800862:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800867:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086d:	eb 2d                	jmp    80089c <devcons_write+0x46>
		m = n - tot;
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800872:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800874:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800877:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80087c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	53                   	push   %ebx
  800883:	03 45 0c             	add    0xc(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	57                   	push   %edi
  800888:	e8 8b 0a 00 00       	call   801318 <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 36 0c 00 00       	call   8014cd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800897:	01 de                	add    %ebx,%esi
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a1:	72 cc                	jb     80086f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008ba:	74 2a                	je     8008e6 <devcons_read+0x3b>
  8008bc:	eb 05                	jmp    8008c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008be:	e8 a7 0c 00 00       	call   80156a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 23 0c 00 00       	call   8014eb <sys_cgetc>
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 f2                	je     8008be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 16                	js     8008e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d0:	83 f8 04             	cmp    $0x4,%eax
  8008d3:	74 0c                	je     8008e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	88 02                	mov    %al,(%edx)
	return 1;
  8008da:	b8 01 00 00 00       	mov    $0x1,%eax
  8008df:	eb 05                	jmp    8008e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f4:	6a 01                	push   $0x1
  8008f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 ce 0b 00 00       	call   8014cd <sys_cputs>
}
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <getchar>:

int
getchar(void)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090a:	6a 01                	push   $0x1
  80090c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	6a 00                	push   $0x0
  800912:	e8 de 15 00 00       	call   801ef5 <read>
	if (r < 0)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 0f                	js     80092d <getchar+0x29>
		return r;
	if (r < 1)
  80091e:	85 c0                	test   %eax,%eax
  800920:	7e 06                	jle    800928 <getchar+0x24>
		return -E_EOF;
	return c;
  800922:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800926:	eb 05                	jmp    80092d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800928:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 4e 13 00 00       	call   801c8f <fd_lookup>
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	85 c0                	test   %eax,%eax
  800946:	78 11                	js     800959 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800951:	39 10                	cmp    %edx,(%eax)
  800953:	0f 94 c0             	sete   %al
  800956:	0f b6 c0             	movzbl %al,%eax
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <opencons>:

int
opencons(void)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	e8 d6 12 00 00       	call   801c40 <fd_alloc>
  80096a:	83 c4 10             	add    $0x10,%esp
		return r;
  80096d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 3e                	js     8009b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	68 07 04 00 00       	push   $0x407
  80097b:	ff 75 f4             	pushl  -0xc(%ebp)
  80097e:	6a 00                	push   $0x0
  800980:	e8 04 0c 00 00       	call   801589 <sys_page_alloc>
  800985:	83 c4 10             	add    $0x10,%esp
		return r;
  800988:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098a:	85 c0                	test   %eax,%eax
  80098c:	78 23                	js     8009b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a3:	83 ec 0c             	sub    $0xc,%esp
  8009a6:	50                   	push   %eax
  8009a7:	e8 6d 12 00 00       	call   801c19 <fd2num>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	83 c4 10             	add    $0x10,%esp
}
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8009c0:	e8 86 0b 00 00       	call   80154b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8009c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d2:	a3 28 54 80 00       	mov    %eax,0x805428
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	7e 07                	jle    8009e2 <libmain+0x2d>
		binaryname = argv[0];
  8009db:	8b 06                	mov    (%esi),%eax
  8009dd:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	e8 6b fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  8009ec:	e8 0a 00 00 00       	call   8009fb <exit>
}
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a01:	e8 de 13 00 00       	call   801de4 <close_all>
	sys_env_destroy(0);
  800a06:	83 ec 0c             	sub    $0xc,%esp
  800a09:	6a 00                	push   $0x0
  800a0b:	e8 fa 0a 00 00       	call   80150a <sys_env_destroy>
}
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a1a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a1d:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a23:	e8 23 0b 00 00       	call   80154b <sys_getenvid>
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	ff 75 08             	pushl  0x8(%ebp)
  800a31:	56                   	push   %esi
  800a32:	50                   	push   %eax
  800a33:	68 a0 39 80 00       	push   $0x8039a0
  800a38:	e8 b1 00 00 00       	call   800aee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3d:	83 c4 18             	add    $0x18,%esp
  800a40:	53                   	push   %ebx
  800a41:	ff 75 10             	pushl  0x10(%ebp)
  800a44:	e8 54 00 00 00       	call   800a9d <vcprintf>
	cprintf("\n");
  800a49:	c7 04 24 a0 37 80 00 	movl   $0x8037a0,(%esp)
  800a50:	e8 99 00 00 00       	call   800aee <cprintf>
  800a55:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a58:	cc                   	int3   
  800a59:	eb fd                	jmp    800a58 <_panic+0x43>

00800a5b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a65:	8b 13                	mov    (%ebx),%edx
  800a67:	8d 42 01             	lea    0x1(%edx),%eax
  800a6a:	89 03                	mov    %eax,(%ebx)
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a73:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a78:	75 1a                	jne    800a94 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a7a:	83 ec 08             	sub    $0x8,%esp
  800a7d:	68 ff 00 00 00       	push   $0xff
  800a82:	8d 43 08             	lea    0x8(%ebx),%eax
  800a85:	50                   	push   %eax
  800a86:	e8 42 0a 00 00       	call   8014cd <sys_cputs>
		b->idx = 0;
  800a8b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a91:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a94:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aa6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aad:	00 00 00 
	b.cnt = 0;
  800ab0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800aba:	ff 75 0c             	pushl  0xc(%ebp)
  800abd:	ff 75 08             	pushl  0x8(%ebp)
  800ac0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ac6:	50                   	push   %eax
  800ac7:	68 5b 0a 80 00       	push   $0x800a5b
  800acc:	e8 54 01 00 00       	call   800c25 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ada:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800ae0:	50                   	push   %eax
  800ae1:	e8 e7 09 00 00       	call   8014cd <sys_cputs>

	return b.cnt;
}
  800ae6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af7:	50                   	push   %eax
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 9d ff ff ff       	call   800a9d <vcprintf>
	va_end(ap);

	return cnt;
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	83 ec 1c             	sub    $0x1c,%esp
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b18:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b23:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b26:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b29:	39 d3                	cmp    %edx,%ebx
  800b2b:	72 05                	jb     800b32 <printnum+0x30>
  800b2d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b30:	77 45                	ja     800b77 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 18             	pushl  0x18(%ebp)
  800b38:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b3e:	53                   	push   %ebx
  800b3f:	ff 75 10             	pushl  0x10(%ebp)
  800b42:	83 ec 08             	sub    $0x8,%esp
  800b45:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b48:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4b:	ff 75 dc             	pushl  -0x24(%ebp)
  800b4e:	ff 75 d8             	pushl  -0x28(%ebp)
  800b51:	e8 9a 29 00 00       	call   8034f0 <__udivdi3>
  800b56:	83 c4 18             	add    $0x18,%esp
  800b59:	52                   	push   %edx
  800b5a:	50                   	push   %eax
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	89 f8                	mov    %edi,%eax
  800b5f:	e8 9e ff ff ff       	call   800b02 <printnum>
  800b64:	83 c4 20             	add    $0x20,%esp
  800b67:	eb 18                	jmp    800b81 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b69:	83 ec 08             	sub    $0x8,%esp
  800b6c:	56                   	push   %esi
  800b6d:	ff 75 18             	pushl  0x18(%ebp)
  800b70:	ff d7                	call   *%edi
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 03                	jmp    800b7a <printnum+0x78>
  800b77:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b7a:	83 eb 01             	sub    $0x1,%ebx
  800b7d:	85 db                	test   %ebx,%ebx
  800b7f:	7f e8                	jg     800b69 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b81:	83 ec 08             	sub    $0x8,%esp
  800b84:	56                   	push   %esi
  800b85:	83 ec 04             	sub    $0x4,%esp
  800b88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b91:	ff 75 d8             	pushl  -0x28(%ebp)
  800b94:	e8 87 2a 00 00       	call   803620 <__umoddi3>
  800b99:	83 c4 14             	add    $0x14,%esp
  800b9c:	0f be 80 c3 39 80 00 	movsbl 0x8039c3(%eax),%eax
  800ba3:	50                   	push   %eax
  800ba4:	ff d7                	call   *%edi
}
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bb4:	83 fa 01             	cmp    $0x1,%edx
  800bb7:	7e 0e                	jle    800bc7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bb9:	8b 10                	mov    (%eax),%edx
  800bbb:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bbe:	89 08                	mov    %ecx,(%eax)
  800bc0:	8b 02                	mov    (%edx),%eax
  800bc2:	8b 52 04             	mov    0x4(%edx),%edx
  800bc5:	eb 22                	jmp    800be9 <getuint+0x38>
	else if (lflag)
  800bc7:	85 d2                	test   %edx,%edx
  800bc9:	74 10                	je     800bdb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bcb:	8b 10                	mov    (%eax),%edx
  800bcd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bd0:	89 08                	mov    %ecx,(%eax)
  800bd2:	8b 02                	mov    (%edx),%eax
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	eb 0e                	jmp    800be9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bdb:	8b 10                	mov    (%eax),%edx
  800bdd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800be0:	89 08                	mov    %ecx,(%eax)
  800be2:	8b 02                	mov    (%edx),%eax
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bf1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bf5:	8b 10                	mov    (%eax),%edx
  800bf7:	3b 50 04             	cmp    0x4(%eax),%edx
  800bfa:	73 0a                	jae    800c06 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bfc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bff:	89 08                	mov    %ecx,(%eax)
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	88 02                	mov    %al,(%edx)
}
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c0e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c11:	50                   	push   %eax
  800c12:	ff 75 10             	pushl  0x10(%ebp)
  800c15:	ff 75 0c             	pushl  0xc(%ebp)
  800c18:	ff 75 08             	pushl  0x8(%ebp)
  800c1b:	e8 05 00 00 00       	call   800c25 <vprintfmt>
	va_end(ap);
}
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 2c             	sub    $0x2c,%esp
  800c2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c34:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c37:	eb 12                	jmp    800c4b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	0f 84 a9 03 00 00    	je     800fea <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800c41:	83 ec 08             	sub    $0x8,%esp
  800c44:	53                   	push   %ebx
  800c45:	50                   	push   %eax
  800c46:	ff d6                	call   *%esi
  800c48:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c4b:	83 c7 01             	add    $0x1,%edi
  800c4e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c52:	83 f8 25             	cmp    $0x25,%eax
  800c55:	75 e2                	jne    800c39 <vprintfmt+0x14>
  800c57:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c5b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c62:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c69:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c70:	ba 00 00 00 00       	mov    $0x0,%edx
  800c75:	eb 07                	jmp    800c7e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c77:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c7a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7e:	8d 47 01             	lea    0x1(%edi),%eax
  800c81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c84:	0f b6 07             	movzbl (%edi),%eax
  800c87:	0f b6 c8             	movzbl %al,%ecx
  800c8a:	83 e8 23             	sub    $0x23,%eax
  800c8d:	3c 55                	cmp    $0x55,%al
  800c8f:	0f 87 3a 03 00 00    	ja     800fcf <vprintfmt+0x3aa>
  800c95:	0f b6 c0             	movzbl %al,%eax
  800c98:	ff 24 85 00 3b 80 00 	jmp    *0x803b00(,%eax,4)
  800c9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ca2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800ca6:	eb d6                	jmp    800c7e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cab:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cb3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cb6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800cbd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800cc0:	83 fa 09             	cmp    $0x9,%edx
  800cc3:	77 39                	ja     800cfe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800cc5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cc8:	eb e9                	jmp    800cb3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cca:	8b 45 14             	mov    0x14(%ebp),%eax
  800ccd:	8d 48 04             	lea    0x4(%eax),%ecx
  800cd0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800cd3:	8b 00                	mov    (%eax),%eax
  800cd5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800cdb:	eb 27                	jmp    800d04 <vprintfmt+0xdf>
  800cdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce7:	0f 49 c8             	cmovns %eax,%ecx
  800cea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ced:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cf0:	eb 8c                	jmp    800c7e <vprintfmt+0x59>
  800cf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cf5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cfc:	eb 80                	jmp    800c7e <vprintfmt+0x59>
  800cfe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d01:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d08:	0f 89 70 ff ff ff    	jns    800c7e <vprintfmt+0x59>
				width = precision, precision = -1;
  800d0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d11:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d14:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d1b:	e9 5e ff ff ff       	jmp    800c7e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d20:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d26:	e9 53 ff ff ff       	jmp    800c7e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2e:	8d 50 04             	lea    0x4(%eax),%edx
  800d31:	89 55 14             	mov    %edx,0x14(%ebp)
  800d34:	83 ec 08             	sub    $0x8,%esp
  800d37:	53                   	push   %ebx
  800d38:	ff 30                	pushl  (%eax)
  800d3a:	ff d6                	call   *%esi
			break;
  800d3c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d42:	e9 04 ff ff ff       	jmp    800c4b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d47:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4a:	8d 50 04             	lea    0x4(%eax),%edx
  800d4d:	89 55 14             	mov    %edx,0x14(%ebp)
  800d50:	8b 00                	mov    (%eax),%eax
  800d52:	99                   	cltd   
  800d53:	31 d0                	xor    %edx,%eax
  800d55:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d57:	83 f8 0f             	cmp    $0xf,%eax
  800d5a:	7f 0b                	jg     800d67 <vprintfmt+0x142>
  800d5c:	8b 14 85 60 3c 80 00 	mov    0x803c60(,%eax,4),%edx
  800d63:	85 d2                	test   %edx,%edx
  800d65:	75 18                	jne    800d7f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d67:	50                   	push   %eax
  800d68:	68 db 39 80 00       	push   $0x8039db
  800d6d:	53                   	push   %ebx
  800d6e:	56                   	push   %esi
  800d6f:	e8 94 fe ff ff       	call   800c08 <printfmt>
  800d74:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d7a:	e9 cc fe ff ff       	jmp    800c4b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d7f:	52                   	push   %edx
  800d80:	68 e1 38 80 00       	push   $0x8038e1
  800d85:	53                   	push   %ebx
  800d86:	56                   	push   %esi
  800d87:	e8 7c fe ff ff       	call   800c08 <printfmt>
  800d8c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d92:	e9 b4 fe ff ff       	jmp    800c4b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d97:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9a:	8d 50 04             	lea    0x4(%eax),%edx
  800d9d:	89 55 14             	mov    %edx,0x14(%ebp)
  800da0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800da2:	85 ff                	test   %edi,%edi
  800da4:	b8 d4 39 80 00       	mov    $0x8039d4,%eax
  800da9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800dac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800db0:	0f 8e 94 00 00 00    	jle    800e4a <vprintfmt+0x225>
  800db6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800dba:	0f 84 98 00 00 00    	je     800e58 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dc0:	83 ec 08             	sub    $0x8,%esp
  800dc3:	ff 75 d0             	pushl  -0x30(%ebp)
  800dc6:	57                   	push   %edi
  800dc7:	e8 99 03 00 00       	call   801165 <strnlen>
  800dcc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800dcf:	29 c1                	sub    %eax,%ecx
  800dd1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800dd4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800dd7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800ddb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800dde:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800de1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800de3:	eb 0f                	jmp    800df4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800de5:	83 ec 08             	sub    $0x8,%esp
  800de8:	53                   	push   %ebx
  800de9:	ff 75 e0             	pushl  -0x20(%ebp)
  800dec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800dee:	83 ef 01             	sub    $0x1,%edi
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	85 ff                	test   %edi,%edi
  800df6:	7f ed                	jg     800de5 <vprintfmt+0x1c0>
  800df8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dfb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800dfe:	85 c9                	test   %ecx,%ecx
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
  800e05:	0f 49 c1             	cmovns %ecx,%eax
  800e08:	29 c1                	sub    %eax,%ecx
  800e0a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e0d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e10:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e13:	89 cb                	mov    %ecx,%ebx
  800e15:	eb 4d                	jmp    800e64 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e17:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e1b:	74 1b                	je     800e38 <vprintfmt+0x213>
  800e1d:	0f be c0             	movsbl %al,%eax
  800e20:	83 e8 20             	sub    $0x20,%eax
  800e23:	83 f8 5e             	cmp    $0x5e,%eax
  800e26:	76 10                	jbe    800e38 <vprintfmt+0x213>
					putch('?', putdat);
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	ff 75 0c             	pushl  0xc(%ebp)
  800e2e:	6a 3f                	push   $0x3f
  800e30:	ff 55 08             	call   *0x8(%ebp)
  800e33:	83 c4 10             	add    $0x10,%esp
  800e36:	eb 0d                	jmp    800e45 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	ff 75 0c             	pushl  0xc(%ebp)
  800e3e:	52                   	push   %edx
  800e3f:	ff 55 08             	call   *0x8(%ebp)
  800e42:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e45:	83 eb 01             	sub    $0x1,%ebx
  800e48:	eb 1a                	jmp    800e64 <vprintfmt+0x23f>
  800e4a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e4d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e50:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e53:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e56:	eb 0c                	jmp    800e64 <vprintfmt+0x23f>
  800e58:	89 75 08             	mov    %esi,0x8(%ebp)
  800e5b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e5e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e61:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e64:	83 c7 01             	add    $0x1,%edi
  800e67:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e6b:	0f be d0             	movsbl %al,%edx
  800e6e:	85 d2                	test   %edx,%edx
  800e70:	74 23                	je     800e95 <vprintfmt+0x270>
  800e72:	85 f6                	test   %esi,%esi
  800e74:	78 a1                	js     800e17 <vprintfmt+0x1f2>
  800e76:	83 ee 01             	sub    $0x1,%esi
  800e79:	79 9c                	jns    800e17 <vprintfmt+0x1f2>
  800e7b:	89 df                	mov    %ebx,%edi
  800e7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e83:	eb 18                	jmp    800e9d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	53                   	push   %ebx
  800e89:	6a 20                	push   $0x20
  800e8b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e8d:	83 ef 01             	sub    $0x1,%edi
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	eb 08                	jmp    800e9d <vprintfmt+0x278>
  800e95:	89 df                	mov    %ebx,%edi
  800e97:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e9d:	85 ff                	test   %edi,%edi
  800e9f:	7f e4                	jg     800e85 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ea1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ea4:	e9 a2 fd ff ff       	jmp    800c4b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ea9:	83 fa 01             	cmp    $0x1,%edx
  800eac:	7e 16                	jle    800ec4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800eae:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb1:	8d 50 08             	lea    0x8(%eax),%edx
  800eb4:	89 55 14             	mov    %edx,0x14(%ebp)
  800eb7:	8b 50 04             	mov    0x4(%eax),%edx
  800eba:	8b 00                	mov    (%eax),%eax
  800ebc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ebf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ec2:	eb 32                	jmp    800ef6 <vprintfmt+0x2d1>
	else if (lflag)
  800ec4:	85 d2                	test   %edx,%edx
  800ec6:	74 18                	je     800ee0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800ec8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ecb:	8d 50 04             	lea    0x4(%eax),%edx
  800ece:	89 55 14             	mov    %edx,0x14(%ebp)
  800ed1:	8b 00                	mov    (%eax),%eax
  800ed3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ed6:	89 c1                	mov    %eax,%ecx
  800ed8:	c1 f9 1f             	sar    $0x1f,%ecx
  800edb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ede:	eb 16                	jmp    800ef6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ee0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee3:	8d 50 04             	lea    0x4(%eax),%edx
  800ee6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ee9:	8b 00                	mov    (%eax),%eax
  800eeb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eee:	89 c1                	mov    %eax,%ecx
  800ef0:	c1 f9 1f             	sar    $0x1f,%ecx
  800ef3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ef6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ef9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800efc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f01:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f05:	0f 89 90 00 00 00    	jns    800f9b <vprintfmt+0x376>
				putch('-', putdat);
  800f0b:	83 ec 08             	sub    $0x8,%esp
  800f0e:	53                   	push   %ebx
  800f0f:	6a 2d                	push   $0x2d
  800f11:	ff d6                	call   *%esi
				num = -(long long) num;
  800f13:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f16:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f19:	f7 d8                	neg    %eax
  800f1b:	83 d2 00             	adc    $0x0,%edx
  800f1e:	f7 da                	neg    %edx
  800f20:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f23:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f28:	eb 71                	jmp    800f9b <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f2a:	8d 45 14             	lea    0x14(%ebp),%eax
  800f2d:	e8 7f fc ff ff       	call   800bb1 <getuint>
			base = 10;
  800f32:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f37:	eb 62                	jmp    800f9b <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800f39:	8d 45 14             	lea    0x14(%ebp),%eax
  800f3c:	e8 70 fc ff ff       	call   800bb1 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800f41:	83 ec 0c             	sub    $0xc,%esp
  800f44:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800f48:	51                   	push   %ecx
  800f49:	ff 75 e0             	pushl  -0x20(%ebp)
  800f4c:	6a 08                	push   $0x8
  800f4e:	52                   	push   %edx
  800f4f:	50                   	push   %eax
  800f50:	89 da                	mov    %ebx,%edx
  800f52:	89 f0                	mov    %esi,%eax
  800f54:	e8 a9 fb ff ff       	call   800b02 <printnum>
			break;
  800f59:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800f5f:	e9 e7 fc ff ff       	jmp    800c4b <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800f64:	83 ec 08             	sub    $0x8,%esp
  800f67:	53                   	push   %ebx
  800f68:	6a 30                	push   $0x30
  800f6a:	ff d6                	call   *%esi
			putch('x', putdat);
  800f6c:	83 c4 08             	add    $0x8,%esp
  800f6f:	53                   	push   %ebx
  800f70:	6a 78                	push   $0x78
  800f72:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f74:	8b 45 14             	mov    0x14(%ebp),%eax
  800f77:	8d 50 04             	lea    0x4(%eax),%edx
  800f7a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f7d:	8b 00                	mov    (%eax),%eax
  800f7f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f84:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f87:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f8c:	eb 0d                	jmp    800f9b <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f8e:	8d 45 14             	lea    0x14(%ebp),%eax
  800f91:	e8 1b fc ff ff       	call   800bb1 <getuint>
			base = 16;
  800f96:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f9b:	83 ec 0c             	sub    $0xc,%esp
  800f9e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800fa2:	57                   	push   %edi
  800fa3:	ff 75 e0             	pushl  -0x20(%ebp)
  800fa6:	51                   	push   %ecx
  800fa7:	52                   	push   %edx
  800fa8:	50                   	push   %eax
  800fa9:	89 da                	mov    %ebx,%edx
  800fab:	89 f0                	mov    %esi,%eax
  800fad:	e8 50 fb ff ff       	call   800b02 <printnum>
			break;
  800fb2:	83 c4 20             	add    $0x20,%esp
  800fb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fb8:	e9 8e fc ff ff       	jmp    800c4b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	53                   	push   %ebx
  800fc1:	51                   	push   %ecx
  800fc2:	ff d6                	call   *%esi
			break;
  800fc4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fc7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fca:	e9 7c fc ff ff       	jmp    800c4b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fcf:	83 ec 08             	sub    $0x8,%esp
  800fd2:	53                   	push   %ebx
  800fd3:	6a 25                	push   $0x25
  800fd5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	eb 03                	jmp    800fdf <vprintfmt+0x3ba>
  800fdc:	83 ef 01             	sub    $0x1,%edi
  800fdf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fe3:	75 f7                	jne    800fdc <vprintfmt+0x3b7>
  800fe5:	e9 61 fc ff ff       	jmp    800c4b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5f                   	pop    %edi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	83 ec 18             	sub    $0x18,%esp
  800ff8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ffe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801001:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801005:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801008:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80100f:	85 c0                	test   %eax,%eax
  801011:	74 26                	je     801039 <vsnprintf+0x47>
  801013:	85 d2                	test   %edx,%edx
  801015:	7e 22                	jle    801039 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801017:	ff 75 14             	pushl  0x14(%ebp)
  80101a:	ff 75 10             	pushl  0x10(%ebp)
  80101d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801020:	50                   	push   %eax
  801021:	68 eb 0b 80 00       	push   $0x800beb
  801026:	e8 fa fb ff ff       	call   800c25 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80102b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80102e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801031:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	eb 05                	jmp    80103e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801039:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801046:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801049:	50                   	push   %eax
  80104a:	ff 75 10             	pushl  0x10(%ebp)
  80104d:	ff 75 0c             	pushl  0xc(%ebp)
  801050:	ff 75 08             	pushl  0x8(%ebp)
  801053:	e8 9a ff ff ff       	call   800ff2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801058:	c9                   	leave  
  801059:	c3                   	ret    

0080105a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	57                   	push   %edi
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801066:	85 c0                	test   %eax,%eax
  801068:	74 13                	je     80107d <readline+0x23>
		fprintf(1, "%s", prompt);
  80106a:	83 ec 04             	sub    $0x4,%esp
  80106d:	50                   	push   %eax
  80106e:	68 e1 38 80 00       	push   $0x8038e1
  801073:	6a 01                	push   $0x1
  801075:	e8 99 14 00 00       	call   802513 <fprintf>
  80107a:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80107d:	83 ec 0c             	sub    $0xc,%esp
  801080:	6a 00                	push   $0x0
  801082:	e8 a8 f8 ff ff       	call   80092f <iscons>
  801087:	89 c7                	mov    %eax,%edi
  801089:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80108c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801091:	e8 6e f8 ff ff       	call   800904 <getchar>
  801096:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801098:	85 c0                	test   %eax,%eax
  80109a:	79 29                	jns    8010c5 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80109c:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8010a1:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8010a4:	0f 84 9b 00 00 00    	je     801145 <readline+0xeb>
				cprintf("read error: %e\n", c);
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	53                   	push   %ebx
  8010ae:	68 bf 3c 80 00       	push   $0x803cbf
  8010b3:	e8 36 fa ff ff       	call   800aee <cprintf>
  8010b8:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c0:	e9 80 00 00 00       	jmp    801145 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010c5:	83 f8 08             	cmp    $0x8,%eax
  8010c8:	0f 94 c2             	sete   %dl
  8010cb:	83 f8 7f             	cmp    $0x7f,%eax
  8010ce:	0f 94 c0             	sete   %al
  8010d1:	08 c2                	or     %al,%dl
  8010d3:	74 1a                	je     8010ef <readline+0x95>
  8010d5:	85 f6                	test   %esi,%esi
  8010d7:	7e 16                	jle    8010ef <readline+0x95>
			if (echoing)
  8010d9:	85 ff                	test   %edi,%edi
  8010db:	74 0d                	je     8010ea <readline+0x90>
				cputchar('\b');
  8010dd:	83 ec 0c             	sub    $0xc,%esp
  8010e0:	6a 08                	push   $0x8
  8010e2:	e8 01 f8 ff ff       	call   8008e8 <cputchar>
  8010e7:	83 c4 10             	add    $0x10,%esp
			i--;
  8010ea:	83 ee 01             	sub    $0x1,%esi
  8010ed:	eb a2                	jmp    801091 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010ef:	83 fb 1f             	cmp    $0x1f,%ebx
  8010f2:	7e 26                	jle    80111a <readline+0xc0>
  8010f4:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010fa:	7f 1e                	jg     80111a <readline+0xc0>
			if (echoing)
  8010fc:	85 ff                	test   %edi,%edi
  8010fe:	74 0c                	je     80110c <readline+0xb2>
				cputchar(c);
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	53                   	push   %ebx
  801104:	e8 df f7 ff ff       	call   8008e8 <cputchar>
  801109:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80110c:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801112:	8d 76 01             	lea    0x1(%esi),%esi
  801115:	e9 77 ff ff ff       	jmp    801091 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  80111a:	83 fb 0a             	cmp    $0xa,%ebx
  80111d:	74 09                	je     801128 <readline+0xce>
  80111f:	83 fb 0d             	cmp    $0xd,%ebx
  801122:	0f 85 69 ff ff ff    	jne    801091 <readline+0x37>
			if (echoing)
  801128:	85 ff                	test   %edi,%edi
  80112a:	74 0d                	je     801139 <readline+0xdf>
				cputchar('\n');
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	6a 0a                	push   $0xa
  801131:	e8 b2 f7 ff ff       	call   8008e8 <cputchar>
  801136:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801139:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801140:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5f                   	pop    %edi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801153:	b8 00 00 00 00       	mov    $0x0,%eax
  801158:	eb 03                	jmp    80115d <strlen+0x10>
		n++;
  80115a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80115d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801161:	75 f7                	jne    80115a <strlen+0xd>
		n++;
	return n;
}
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80116e:	ba 00 00 00 00       	mov    $0x0,%edx
  801173:	eb 03                	jmp    801178 <strnlen+0x13>
		n++;
  801175:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801178:	39 c2                	cmp    %eax,%edx
  80117a:	74 08                	je     801184 <strnlen+0x1f>
  80117c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801180:	75 f3                	jne    801175 <strnlen+0x10>
  801182:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	53                   	push   %ebx
  80118a:	8b 45 08             	mov    0x8(%ebp),%eax
  80118d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801190:	89 c2                	mov    %eax,%edx
  801192:	83 c2 01             	add    $0x1,%edx
  801195:	83 c1 01             	add    $0x1,%ecx
  801198:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80119c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80119f:	84 db                	test   %bl,%bl
  8011a1:	75 ef                	jne    801192 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8011a3:	5b                   	pop    %ebx
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	53                   	push   %ebx
  8011aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011ad:	53                   	push   %ebx
  8011ae:	e8 9a ff ff ff       	call   80114d <strlen>
  8011b3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011b6:	ff 75 0c             	pushl  0xc(%ebp)
  8011b9:	01 d8                	add    %ebx,%eax
  8011bb:	50                   	push   %eax
  8011bc:	e8 c5 ff ff ff       	call   801186 <strcpy>
	return dst;
}
  8011c1:	89 d8                	mov    %ebx,%eax
  8011c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c6:	c9                   	leave  
  8011c7:	c3                   	ret    

008011c8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d3:	89 f3                	mov    %esi,%ebx
  8011d5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011d8:	89 f2                	mov    %esi,%edx
  8011da:	eb 0f                	jmp    8011eb <strncpy+0x23>
		*dst++ = *src;
  8011dc:	83 c2 01             	add    $0x1,%edx
  8011df:	0f b6 01             	movzbl (%ecx),%eax
  8011e2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011e5:	80 39 01             	cmpb   $0x1,(%ecx)
  8011e8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011eb:	39 da                	cmp    %ebx,%edx
  8011ed:	75 ed                	jne    8011dc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011ef:	89 f0                	mov    %esi,%eax
  8011f1:	5b                   	pop    %ebx
  8011f2:	5e                   	pop    %esi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	56                   	push   %esi
  8011f9:	53                   	push   %ebx
  8011fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801200:	8b 55 10             	mov    0x10(%ebp),%edx
  801203:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801205:	85 d2                	test   %edx,%edx
  801207:	74 21                	je     80122a <strlcpy+0x35>
  801209:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80120d:	89 f2                	mov    %esi,%edx
  80120f:	eb 09                	jmp    80121a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801211:	83 c2 01             	add    $0x1,%edx
  801214:	83 c1 01             	add    $0x1,%ecx
  801217:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80121a:	39 c2                	cmp    %eax,%edx
  80121c:	74 09                	je     801227 <strlcpy+0x32>
  80121e:	0f b6 19             	movzbl (%ecx),%ebx
  801221:	84 db                	test   %bl,%bl
  801223:	75 ec                	jne    801211 <strlcpy+0x1c>
  801225:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801227:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80122a:	29 f0                	sub    %esi,%eax
}
  80122c:	5b                   	pop    %ebx
  80122d:	5e                   	pop    %esi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801236:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801239:	eb 06                	jmp    801241 <strcmp+0x11>
		p++, q++;
  80123b:	83 c1 01             	add    $0x1,%ecx
  80123e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801241:	0f b6 01             	movzbl (%ecx),%eax
  801244:	84 c0                	test   %al,%al
  801246:	74 04                	je     80124c <strcmp+0x1c>
  801248:	3a 02                	cmp    (%edx),%al
  80124a:	74 ef                	je     80123b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80124c:	0f b6 c0             	movzbl %al,%eax
  80124f:	0f b6 12             	movzbl (%edx),%edx
  801252:	29 d0                	sub    %edx,%eax
}
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	53                   	push   %ebx
  80125a:	8b 45 08             	mov    0x8(%ebp),%eax
  80125d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801260:	89 c3                	mov    %eax,%ebx
  801262:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801265:	eb 06                	jmp    80126d <strncmp+0x17>
		n--, p++, q++;
  801267:	83 c0 01             	add    $0x1,%eax
  80126a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80126d:	39 d8                	cmp    %ebx,%eax
  80126f:	74 15                	je     801286 <strncmp+0x30>
  801271:	0f b6 08             	movzbl (%eax),%ecx
  801274:	84 c9                	test   %cl,%cl
  801276:	74 04                	je     80127c <strncmp+0x26>
  801278:	3a 0a                	cmp    (%edx),%cl
  80127a:	74 eb                	je     801267 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80127c:	0f b6 00             	movzbl (%eax),%eax
  80127f:	0f b6 12             	movzbl (%edx),%edx
  801282:	29 d0                	sub    %edx,%eax
  801284:	eb 05                	jmp    80128b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801286:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80128b:	5b                   	pop    %ebx
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    

0080128e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	8b 45 08             	mov    0x8(%ebp),%eax
  801294:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801298:	eb 07                	jmp    8012a1 <strchr+0x13>
		if (*s == c)
  80129a:	38 ca                	cmp    %cl,%dl
  80129c:	74 0f                	je     8012ad <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80129e:	83 c0 01             	add    $0x1,%eax
  8012a1:	0f b6 10             	movzbl (%eax),%edx
  8012a4:	84 d2                	test   %dl,%dl
  8012a6:	75 f2                	jne    80129a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8012a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012b9:	eb 03                	jmp    8012be <strfind+0xf>
  8012bb:	83 c0 01             	add    $0x1,%eax
  8012be:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012c1:	38 ca                	cmp    %cl,%dl
  8012c3:	74 04                	je     8012c9 <strfind+0x1a>
  8012c5:	84 d2                	test   %dl,%dl
  8012c7:	75 f2                	jne    8012bb <strfind+0xc>
			break;
	return (char *) s;
}
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	57                   	push   %edi
  8012cf:	56                   	push   %esi
  8012d0:	53                   	push   %ebx
  8012d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012d7:	85 c9                	test   %ecx,%ecx
  8012d9:	74 36                	je     801311 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012db:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012e1:	75 28                	jne    80130b <memset+0x40>
  8012e3:	f6 c1 03             	test   $0x3,%cl
  8012e6:	75 23                	jne    80130b <memset+0x40>
		c &= 0xFF;
  8012e8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012ec:	89 d3                	mov    %edx,%ebx
  8012ee:	c1 e3 08             	shl    $0x8,%ebx
  8012f1:	89 d6                	mov    %edx,%esi
  8012f3:	c1 e6 18             	shl    $0x18,%esi
  8012f6:	89 d0                	mov    %edx,%eax
  8012f8:	c1 e0 10             	shl    $0x10,%eax
  8012fb:	09 f0                	or     %esi,%eax
  8012fd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8012ff:	89 d8                	mov    %ebx,%eax
  801301:	09 d0                	or     %edx,%eax
  801303:	c1 e9 02             	shr    $0x2,%ecx
  801306:	fc                   	cld    
  801307:	f3 ab                	rep stos %eax,%es:(%edi)
  801309:	eb 06                	jmp    801311 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80130b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130e:	fc                   	cld    
  80130f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801311:	89 f8                	mov    %edi,%eax
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	57                   	push   %edi
  80131c:	56                   	push   %esi
  80131d:	8b 45 08             	mov    0x8(%ebp),%eax
  801320:	8b 75 0c             	mov    0xc(%ebp),%esi
  801323:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801326:	39 c6                	cmp    %eax,%esi
  801328:	73 35                	jae    80135f <memmove+0x47>
  80132a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80132d:	39 d0                	cmp    %edx,%eax
  80132f:	73 2e                	jae    80135f <memmove+0x47>
		s += n;
		d += n;
  801331:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801334:	89 d6                	mov    %edx,%esi
  801336:	09 fe                	or     %edi,%esi
  801338:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80133e:	75 13                	jne    801353 <memmove+0x3b>
  801340:	f6 c1 03             	test   $0x3,%cl
  801343:	75 0e                	jne    801353 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801345:	83 ef 04             	sub    $0x4,%edi
  801348:	8d 72 fc             	lea    -0x4(%edx),%esi
  80134b:	c1 e9 02             	shr    $0x2,%ecx
  80134e:	fd                   	std    
  80134f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801351:	eb 09                	jmp    80135c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801353:	83 ef 01             	sub    $0x1,%edi
  801356:	8d 72 ff             	lea    -0x1(%edx),%esi
  801359:	fd                   	std    
  80135a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80135c:	fc                   	cld    
  80135d:	eb 1d                	jmp    80137c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80135f:	89 f2                	mov    %esi,%edx
  801361:	09 c2                	or     %eax,%edx
  801363:	f6 c2 03             	test   $0x3,%dl
  801366:	75 0f                	jne    801377 <memmove+0x5f>
  801368:	f6 c1 03             	test   $0x3,%cl
  80136b:	75 0a                	jne    801377 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80136d:	c1 e9 02             	shr    $0x2,%ecx
  801370:	89 c7                	mov    %eax,%edi
  801372:	fc                   	cld    
  801373:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801375:	eb 05                	jmp    80137c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801377:	89 c7                	mov    %eax,%edi
  801379:	fc                   	cld    
  80137a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80137c:	5e                   	pop    %esi
  80137d:	5f                   	pop    %edi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801383:	ff 75 10             	pushl  0x10(%ebp)
  801386:	ff 75 0c             	pushl  0xc(%ebp)
  801389:	ff 75 08             	pushl  0x8(%ebp)
  80138c:	e8 87 ff ff ff       	call   801318 <memmove>
}
  801391:	c9                   	leave  
  801392:	c3                   	ret    

00801393 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	56                   	push   %esi
  801397:	53                   	push   %ebx
  801398:	8b 45 08             	mov    0x8(%ebp),%eax
  80139b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80139e:	89 c6                	mov    %eax,%esi
  8013a0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013a3:	eb 1a                	jmp    8013bf <memcmp+0x2c>
		if (*s1 != *s2)
  8013a5:	0f b6 08             	movzbl (%eax),%ecx
  8013a8:	0f b6 1a             	movzbl (%edx),%ebx
  8013ab:	38 d9                	cmp    %bl,%cl
  8013ad:	74 0a                	je     8013b9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8013af:	0f b6 c1             	movzbl %cl,%eax
  8013b2:	0f b6 db             	movzbl %bl,%ebx
  8013b5:	29 d8                	sub    %ebx,%eax
  8013b7:	eb 0f                	jmp    8013c8 <memcmp+0x35>
		s1++, s2++;
  8013b9:	83 c0 01             	add    $0x1,%eax
  8013bc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013bf:	39 f0                	cmp    %esi,%eax
  8013c1:	75 e2                	jne    8013a5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	53                   	push   %ebx
  8013d0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013d3:	89 c1                	mov    %eax,%ecx
  8013d5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013d8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013dc:	eb 0a                	jmp    8013e8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013de:	0f b6 10             	movzbl (%eax),%edx
  8013e1:	39 da                	cmp    %ebx,%edx
  8013e3:	74 07                	je     8013ec <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013e5:	83 c0 01             	add    $0x1,%eax
  8013e8:	39 c8                	cmp    %ecx,%eax
  8013ea:	72 f2                	jb     8013de <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013ec:	5b                   	pop    %ebx
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    

008013ef <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	57                   	push   %edi
  8013f3:	56                   	push   %esi
  8013f4:	53                   	push   %ebx
  8013f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013fb:	eb 03                	jmp    801400 <strtol+0x11>
		s++;
  8013fd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801400:	0f b6 01             	movzbl (%ecx),%eax
  801403:	3c 20                	cmp    $0x20,%al
  801405:	74 f6                	je     8013fd <strtol+0xe>
  801407:	3c 09                	cmp    $0x9,%al
  801409:	74 f2                	je     8013fd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80140b:	3c 2b                	cmp    $0x2b,%al
  80140d:	75 0a                	jne    801419 <strtol+0x2a>
		s++;
  80140f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801412:	bf 00 00 00 00       	mov    $0x0,%edi
  801417:	eb 11                	jmp    80142a <strtol+0x3b>
  801419:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80141e:	3c 2d                	cmp    $0x2d,%al
  801420:	75 08                	jne    80142a <strtol+0x3b>
		s++, neg = 1;
  801422:	83 c1 01             	add    $0x1,%ecx
  801425:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80142a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801430:	75 15                	jne    801447 <strtol+0x58>
  801432:	80 39 30             	cmpb   $0x30,(%ecx)
  801435:	75 10                	jne    801447 <strtol+0x58>
  801437:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80143b:	75 7c                	jne    8014b9 <strtol+0xca>
		s += 2, base = 16;
  80143d:	83 c1 02             	add    $0x2,%ecx
  801440:	bb 10 00 00 00       	mov    $0x10,%ebx
  801445:	eb 16                	jmp    80145d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801447:	85 db                	test   %ebx,%ebx
  801449:	75 12                	jne    80145d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80144b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801450:	80 39 30             	cmpb   $0x30,(%ecx)
  801453:	75 08                	jne    80145d <strtol+0x6e>
		s++, base = 8;
  801455:	83 c1 01             	add    $0x1,%ecx
  801458:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80145d:	b8 00 00 00 00       	mov    $0x0,%eax
  801462:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801465:	0f b6 11             	movzbl (%ecx),%edx
  801468:	8d 72 d0             	lea    -0x30(%edx),%esi
  80146b:	89 f3                	mov    %esi,%ebx
  80146d:	80 fb 09             	cmp    $0x9,%bl
  801470:	77 08                	ja     80147a <strtol+0x8b>
			dig = *s - '0';
  801472:	0f be d2             	movsbl %dl,%edx
  801475:	83 ea 30             	sub    $0x30,%edx
  801478:	eb 22                	jmp    80149c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80147a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80147d:	89 f3                	mov    %esi,%ebx
  80147f:	80 fb 19             	cmp    $0x19,%bl
  801482:	77 08                	ja     80148c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801484:	0f be d2             	movsbl %dl,%edx
  801487:	83 ea 57             	sub    $0x57,%edx
  80148a:	eb 10                	jmp    80149c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80148c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80148f:	89 f3                	mov    %esi,%ebx
  801491:	80 fb 19             	cmp    $0x19,%bl
  801494:	77 16                	ja     8014ac <strtol+0xbd>
			dig = *s - 'A' + 10;
  801496:	0f be d2             	movsbl %dl,%edx
  801499:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80149c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80149f:	7d 0b                	jge    8014ac <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8014a1:	83 c1 01             	add    $0x1,%ecx
  8014a4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8014a8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8014aa:	eb b9                	jmp    801465 <strtol+0x76>

	if (endptr)
  8014ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014b0:	74 0d                	je     8014bf <strtol+0xd0>
		*endptr = (char *) s;
  8014b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014b5:	89 0e                	mov    %ecx,(%esi)
  8014b7:	eb 06                	jmp    8014bf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014b9:	85 db                	test   %ebx,%ebx
  8014bb:	74 98                	je     801455 <strtol+0x66>
  8014bd:	eb 9e                	jmp    80145d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8014bf:	89 c2                	mov    %eax,%edx
  8014c1:	f7 da                	neg    %edx
  8014c3:	85 ff                	test   %edi,%edi
  8014c5:	0f 45 c2             	cmovne %edx,%eax
}
  8014c8:	5b                   	pop    %ebx
  8014c9:	5e                   	pop    %esi
  8014ca:	5f                   	pop    %edi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	57                   	push   %edi
  8014d1:	56                   	push   %esi
  8014d2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014db:	8b 55 08             	mov    0x8(%ebp),%edx
  8014de:	89 c3                	mov    %eax,%ebx
  8014e0:	89 c7                	mov    %eax,%edi
  8014e2:	89 c6                	mov    %eax,%esi
  8014e4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014e6:	5b                   	pop    %ebx
  8014e7:	5e                   	pop    %esi
  8014e8:	5f                   	pop    %edi
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    

008014eb <sys_cgetc>:

int
sys_cgetc(void)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	57                   	push   %edi
  8014ef:	56                   	push   %esi
  8014f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fb:	89 d1                	mov    %edx,%ecx
  8014fd:	89 d3                	mov    %edx,%ebx
  8014ff:	89 d7                	mov    %edx,%edi
  801501:	89 d6                	mov    %edx,%esi
  801503:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801505:	5b                   	pop    %ebx
  801506:	5e                   	pop    %esi
  801507:	5f                   	pop    %edi
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    

0080150a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	57                   	push   %edi
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
  801510:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801513:	b9 00 00 00 00       	mov    $0x0,%ecx
  801518:	b8 03 00 00 00       	mov    $0x3,%eax
  80151d:	8b 55 08             	mov    0x8(%ebp),%edx
  801520:	89 cb                	mov    %ecx,%ebx
  801522:	89 cf                	mov    %ecx,%edi
  801524:	89 ce                	mov    %ecx,%esi
  801526:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801528:	85 c0                	test   %eax,%eax
  80152a:	7e 17                	jle    801543 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80152c:	83 ec 0c             	sub    $0xc,%esp
  80152f:	50                   	push   %eax
  801530:	6a 03                	push   $0x3
  801532:	68 cf 3c 80 00       	push   $0x803ccf
  801537:	6a 23                	push   $0x23
  801539:	68 ec 3c 80 00       	push   $0x803cec
  80153e:	e8 d2 f4 ff ff       	call   800a15 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801543:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801546:	5b                   	pop    %ebx
  801547:	5e                   	pop    %esi
  801548:	5f                   	pop    %edi
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    

0080154b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	57                   	push   %edi
  80154f:	56                   	push   %esi
  801550:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801551:	ba 00 00 00 00       	mov    $0x0,%edx
  801556:	b8 02 00 00 00       	mov    $0x2,%eax
  80155b:	89 d1                	mov    %edx,%ecx
  80155d:	89 d3                	mov    %edx,%ebx
  80155f:	89 d7                	mov    %edx,%edi
  801561:	89 d6                	mov    %edx,%esi
  801563:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801565:	5b                   	pop    %ebx
  801566:	5e                   	pop    %esi
  801567:	5f                   	pop    %edi
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <sys_yield>:

void
sys_yield(void)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	57                   	push   %edi
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801570:	ba 00 00 00 00       	mov    $0x0,%edx
  801575:	b8 0b 00 00 00       	mov    $0xb,%eax
  80157a:	89 d1                	mov    %edx,%ecx
  80157c:	89 d3                	mov    %edx,%ebx
  80157e:	89 d7                	mov    %edx,%edi
  801580:	89 d6                	mov    %edx,%esi
  801582:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801584:	5b                   	pop    %ebx
  801585:	5e                   	pop    %esi
  801586:	5f                   	pop    %edi
  801587:	5d                   	pop    %ebp
  801588:	c3                   	ret    

00801589 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	57                   	push   %edi
  80158d:	56                   	push   %esi
  80158e:	53                   	push   %ebx
  80158f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801592:	be 00 00 00 00       	mov    $0x0,%esi
  801597:	b8 04 00 00 00       	mov    $0x4,%eax
  80159c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80159f:	8b 55 08             	mov    0x8(%ebp),%edx
  8015a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015a5:	89 f7                	mov    %esi,%edi
  8015a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	7e 17                	jle    8015c4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015ad:	83 ec 0c             	sub    $0xc,%esp
  8015b0:	50                   	push   %eax
  8015b1:	6a 04                	push   $0x4
  8015b3:	68 cf 3c 80 00       	push   $0x803ccf
  8015b8:	6a 23                	push   $0x23
  8015ba:	68 ec 3c 80 00       	push   $0x803cec
  8015bf:	e8 51 f4 ff ff       	call   800a15 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5e                   	pop    %esi
  8015c9:	5f                   	pop    %edi
  8015ca:	5d                   	pop    %ebp
  8015cb:	c3                   	ret    

008015cc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	57                   	push   %edi
  8015d0:	56                   	push   %esi
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8015da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015e3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015e6:	8b 75 18             	mov    0x18(%ebp),%esi
  8015e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	7e 17                	jle    801606 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015ef:	83 ec 0c             	sub    $0xc,%esp
  8015f2:	50                   	push   %eax
  8015f3:	6a 05                	push   $0x5
  8015f5:	68 cf 3c 80 00       	push   $0x803ccf
  8015fa:	6a 23                	push   $0x23
  8015fc:	68 ec 3c 80 00       	push   $0x803cec
  801601:	e8 0f f4 ff ff       	call   800a15 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801606:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801609:	5b                   	pop    %ebx
  80160a:	5e                   	pop    %esi
  80160b:	5f                   	pop    %edi
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	57                   	push   %edi
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801617:	bb 00 00 00 00       	mov    $0x0,%ebx
  80161c:	b8 06 00 00 00       	mov    $0x6,%eax
  801621:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801624:	8b 55 08             	mov    0x8(%ebp),%edx
  801627:	89 df                	mov    %ebx,%edi
  801629:	89 de                	mov    %ebx,%esi
  80162b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80162d:	85 c0                	test   %eax,%eax
  80162f:	7e 17                	jle    801648 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801631:	83 ec 0c             	sub    $0xc,%esp
  801634:	50                   	push   %eax
  801635:	6a 06                	push   $0x6
  801637:	68 cf 3c 80 00       	push   $0x803ccf
  80163c:	6a 23                	push   $0x23
  80163e:	68 ec 3c 80 00       	push   $0x803cec
  801643:	e8 cd f3 ff ff       	call   800a15 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801648:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5f                   	pop    %edi
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	57                   	push   %edi
  801654:	56                   	push   %esi
  801655:	53                   	push   %ebx
  801656:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801659:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165e:	b8 08 00 00 00       	mov    $0x8,%eax
  801663:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801666:	8b 55 08             	mov    0x8(%ebp),%edx
  801669:	89 df                	mov    %ebx,%edi
  80166b:	89 de                	mov    %ebx,%esi
  80166d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80166f:	85 c0                	test   %eax,%eax
  801671:	7e 17                	jle    80168a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	50                   	push   %eax
  801677:	6a 08                	push   $0x8
  801679:	68 cf 3c 80 00       	push   $0x803ccf
  80167e:	6a 23                	push   $0x23
  801680:	68 ec 3c 80 00       	push   $0x803cec
  801685:	e8 8b f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80168a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5e                   	pop    %esi
  80168f:	5f                   	pop    %edi
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	57                   	push   %edi
  801696:	56                   	push   %esi
  801697:	53                   	push   %ebx
  801698:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80169b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a0:	b8 09 00 00 00       	mov    $0x9,%eax
  8016a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ab:	89 df                	mov    %ebx,%edi
  8016ad:	89 de                	mov    %ebx,%esi
  8016af:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	7e 17                	jle    8016cc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016b5:	83 ec 0c             	sub    $0xc,%esp
  8016b8:	50                   	push   %eax
  8016b9:	6a 09                	push   $0x9
  8016bb:	68 cf 3c 80 00       	push   $0x803ccf
  8016c0:	6a 23                	push   $0x23
  8016c2:	68 ec 3c 80 00       	push   $0x803cec
  8016c7:	e8 49 f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5e                   	pop    %esi
  8016d1:	5f                   	pop    %edi
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	57                   	push   %edi
  8016d8:	56                   	push   %esi
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ed:	89 df                	mov    %ebx,%edi
  8016ef:	89 de                	mov    %ebx,%esi
  8016f1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	7e 17                	jle    80170e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016f7:	83 ec 0c             	sub    $0xc,%esp
  8016fa:	50                   	push   %eax
  8016fb:	6a 0a                	push   $0xa
  8016fd:	68 cf 3c 80 00       	push   $0x803ccf
  801702:	6a 23                	push   $0x23
  801704:	68 ec 3c 80 00       	push   $0x803cec
  801709:	e8 07 f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80170e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801711:	5b                   	pop    %ebx
  801712:	5e                   	pop    %esi
  801713:	5f                   	pop    %edi
  801714:	5d                   	pop    %ebp
  801715:	c3                   	ret    

00801716 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	57                   	push   %edi
  80171a:	56                   	push   %esi
  80171b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80171c:	be 00 00 00 00       	mov    $0x0,%esi
  801721:	b8 0c 00 00 00       	mov    $0xc,%eax
  801726:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801729:	8b 55 08             	mov    0x8(%ebp),%edx
  80172c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80172f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801732:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801734:	5b                   	pop    %ebx
  801735:	5e                   	pop    %esi
  801736:	5f                   	pop    %edi
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	57                   	push   %edi
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
  80173f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801742:	b9 00 00 00 00       	mov    $0x0,%ecx
  801747:	b8 0d 00 00 00       	mov    $0xd,%eax
  80174c:	8b 55 08             	mov    0x8(%ebp),%edx
  80174f:	89 cb                	mov    %ecx,%ebx
  801751:	89 cf                	mov    %ecx,%edi
  801753:	89 ce                	mov    %ecx,%esi
  801755:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801757:	85 c0                	test   %eax,%eax
  801759:	7e 17                	jle    801772 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80175b:	83 ec 0c             	sub    $0xc,%esp
  80175e:	50                   	push   %eax
  80175f:	6a 0d                	push   $0xd
  801761:	68 cf 3c 80 00       	push   $0x803ccf
  801766:	6a 23                	push   $0x23
  801768:	68 ec 3c 80 00       	push   $0x803cec
  80176d:	e8 a3 f2 ff ff       	call   800a15 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801772:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5f                   	pop    %edi
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	57                   	push   %edi
  80177e:	56                   	push   %esi
  80177f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801780:	ba 00 00 00 00       	mov    $0x0,%edx
  801785:	b8 0e 00 00 00       	mov    $0xe,%eax
  80178a:	89 d1                	mov    %edx,%ecx
  80178c:	89 d3                	mov    %edx,%ebx
  80178e:	89 d7                	mov    %edx,%edi
  801790:	89 d6                	mov    %edx,%esi
  801792:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801794:	5b                   	pop    %ebx
  801795:	5e                   	pop    %esi
  801796:	5f                   	pop    %edi
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	53                   	push   %ebx
  80179d:	83 ec 04             	sub    $0x4,%esp
  8017a0:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  8017a3:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  8017a5:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  8017a8:	f6 c1 02             	test   $0x2,%cl
  8017ab:	74 2e                	je     8017db <pgfault+0x42>
  8017ad:	89 c2                	mov    %eax,%edx
  8017af:	c1 ea 16             	shr    $0x16,%edx
  8017b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017b9:	f6 c2 01             	test   $0x1,%dl
  8017bc:	74 1d                	je     8017db <pgfault+0x42>
  8017be:	89 c2                	mov    %eax,%edx
  8017c0:	c1 ea 0c             	shr    $0xc,%edx
  8017c3:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  8017ca:	f6 c3 01             	test   $0x1,%bl
  8017cd:	74 0c                	je     8017db <pgfault+0x42>
  8017cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017d6:	f6 c6 08             	test   $0x8,%dh
  8017d9:	75 12                	jne    8017ed <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  8017db:	51                   	push   %ecx
  8017dc:	68 fa 3c 80 00       	push   $0x803cfa
  8017e1:	6a 1e                	push   $0x1e
  8017e3:	68 13 3d 80 00       	push   $0x803d13
  8017e8:	e8 28 f2 ff ff       	call   800a15 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  8017ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8017f2:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  8017f4:	83 ec 04             	sub    $0x4,%esp
  8017f7:	6a 07                	push   $0x7
  8017f9:	68 00 f0 7f 00       	push   $0x7ff000
  8017fe:	6a 00                	push   $0x0
  801800:	e8 84 fd ff ff       	call   801589 <sys_page_alloc>
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	85 c0                	test   %eax,%eax
  80180a:	79 12                	jns    80181e <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  80180c:	50                   	push   %eax
  80180d:	68 1e 3d 80 00       	push   $0x803d1e
  801812:	6a 29                	push   $0x29
  801814:	68 13 3d 80 00       	push   $0x803d13
  801819:	e8 f7 f1 ff ff       	call   800a15 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  80181e:	83 ec 04             	sub    $0x4,%esp
  801821:	68 00 10 00 00       	push   $0x1000
  801826:	53                   	push   %ebx
  801827:	68 00 f0 7f 00       	push   $0x7ff000
  80182c:	e8 4f fb ff ff       	call   801380 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801831:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801838:	53                   	push   %ebx
  801839:	6a 00                	push   $0x0
  80183b:	68 00 f0 7f 00       	push   $0x7ff000
  801840:	6a 00                	push   $0x0
  801842:	e8 85 fd ff ff       	call   8015cc <sys_page_map>
  801847:	83 c4 20             	add    $0x20,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	79 12                	jns    801860 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  80184e:	50                   	push   %eax
  80184f:	68 39 3d 80 00       	push   $0x803d39
  801854:	6a 2e                	push   $0x2e
  801856:	68 13 3d 80 00       	push   $0x803d13
  80185b:	e8 b5 f1 ff ff       	call   800a15 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  801860:	83 ec 08             	sub    $0x8,%esp
  801863:	68 00 f0 7f 00       	push   $0x7ff000
  801868:	6a 00                	push   $0x0
  80186a:	e8 9f fd ff ff       	call   80160e <sys_page_unmap>
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	85 c0                	test   %eax,%eax
  801874:	79 12                	jns    801888 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  801876:	50                   	push   %eax
  801877:	68 52 3d 80 00       	push   $0x803d52
  80187c:	6a 31                	push   $0x31
  80187e:	68 13 3d 80 00       	push   $0x803d13
  801883:	e8 8d f1 ff ff       	call   800a15 <_panic>

}
  801888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	57                   	push   %edi
  801891:	56                   	push   %esi
  801892:	53                   	push   %ebx
  801893:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  801896:	68 99 17 80 00       	push   $0x801799
  80189b:	e8 7c 1a 00 00       	call   80331c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8018a0:	b8 07 00 00 00       	mov    $0x7,%eax
  8018a5:	cd 30                	int    $0x30
  8018a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	75 21                	jne    8018da <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  8018b9:	e8 8d fc ff ff       	call   80154b <sys_getenvid>
  8018be:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018c3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018c6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018cb:	a3 28 54 80 00       	mov    %eax,0x805428
		return 0;
  8018d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d5:	e9 c9 01 00 00       	jmp    801aa3 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  8018da:	89 d8                	mov    %ebx,%eax
  8018dc:	c1 e8 16             	shr    $0x16,%eax
  8018df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018e6:	a8 01                	test   $0x1,%al
  8018e8:	0f 84 1b 01 00 00    	je     801a09 <fork+0x17c>
  8018ee:	89 de                	mov    %ebx,%esi
  8018f0:	c1 ee 0c             	shr    $0xc,%esi
  8018f3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8018fa:	a8 01                	test   $0x1,%al
  8018fc:	0f 84 07 01 00 00    	je     801a09 <fork+0x17c>
  801902:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801909:	a8 04                	test   $0x4,%al
  80190b:	0f 84 f8 00 00 00    	je     801a09 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  801911:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801918:	f6 c4 04             	test   $0x4,%ah
  80191b:	74 3c                	je     801959 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  80191d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801924:	c1 e6 0c             	shl    $0xc,%esi
  801927:	83 ec 0c             	sub    $0xc,%esp
  80192a:	25 07 0e 00 00       	and    $0xe07,%eax
  80192f:	50                   	push   %eax
  801930:	56                   	push   %esi
  801931:	ff 75 e4             	pushl  -0x1c(%ebp)
  801934:	56                   	push   %esi
  801935:	6a 00                	push   $0x0
  801937:	e8 90 fc ff ff       	call   8015cc <sys_page_map>
  80193c:	83 c4 20             	add    $0x20,%esp
  80193f:	85 c0                	test   %eax,%eax
  801941:	0f 89 c2 00 00 00    	jns    801a09 <fork+0x17c>
			panic("duppage: %e", r);
  801947:	50                   	push   %eax
  801948:	68 6d 3d 80 00       	push   $0x803d6d
  80194d:	6a 48                	push   $0x48
  80194f:	68 13 3d 80 00       	push   $0x803d13
  801954:	e8 bc f0 ff ff       	call   800a15 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  801959:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801960:	f6 c4 08             	test   $0x8,%ah
  801963:	75 0b                	jne    801970 <fork+0xe3>
  801965:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80196c:	a8 02                	test   $0x2,%al
  80196e:	74 6c                	je     8019dc <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  801970:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801977:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  80197a:	83 f8 01             	cmp    $0x1,%eax
  80197d:	19 ff                	sbb    %edi,%edi
  80197f:	83 e7 fc             	and    $0xfffffffc,%edi
  801982:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  801988:	c1 e6 0c             	shl    $0xc,%esi
  80198b:	83 ec 0c             	sub    $0xc,%esp
  80198e:	57                   	push   %edi
  80198f:	56                   	push   %esi
  801990:	ff 75 e4             	pushl  -0x1c(%ebp)
  801993:	56                   	push   %esi
  801994:	6a 00                	push   $0x0
  801996:	e8 31 fc ff ff       	call   8015cc <sys_page_map>
  80199b:	83 c4 20             	add    $0x20,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	79 12                	jns    8019b4 <fork+0x127>
			panic("duppage: %e", r);
  8019a2:	50                   	push   %eax
  8019a3:	68 6d 3d 80 00       	push   $0x803d6d
  8019a8:	6a 50                	push   $0x50
  8019aa:	68 13 3d 80 00       	push   $0x803d13
  8019af:	e8 61 f0 ff ff       	call   800a15 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  8019b4:	83 ec 0c             	sub    $0xc,%esp
  8019b7:	57                   	push   %edi
  8019b8:	56                   	push   %esi
  8019b9:	6a 00                	push   $0x0
  8019bb:	56                   	push   %esi
  8019bc:	6a 00                	push   $0x0
  8019be:	e8 09 fc ff ff       	call   8015cc <sys_page_map>
  8019c3:	83 c4 20             	add    $0x20,%esp
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	79 3f                	jns    801a09 <fork+0x17c>
			panic("duppage: %e", r);
  8019ca:	50                   	push   %eax
  8019cb:	68 6d 3d 80 00       	push   $0x803d6d
  8019d0:	6a 53                	push   $0x53
  8019d2:	68 13 3d 80 00       	push   $0x803d13
  8019d7:	e8 39 f0 ff ff       	call   800a15 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  8019dc:	c1 e6 0c             	shl    $0xc,%esi
  8019df:	83 ec 0c             	sub    $0xc,%esp
  8019e2:	6a 05                	push   $0x5
  8019e4:	56                   	push   %esi
  8019e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019e8:	56                   	push   %esi
  8019e9:	6a 00                	push   $0x0
  8019eb:	e8 dc fb ff ff       	call   8015cc <sys_page_map>
  8019f0:	83 c4 20             	add    $0x20,%esp
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	79 12                	jns    801a09 <fork+0x17c>
			panic("duppage: %e", r);
  8019f7:	50                   	push   %eax
  8019f8:	68 6d 3d 80 00       	push   $0x803d6d
  8019fd:	6a 57                	push   $0x57
  8019ff:	68 13 3d 80 00       	push   $0x803d13
  801a04:	e8 0c f0 ff ff       	call   800a15 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  801a09:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a0f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801a15:	0f 85 bf fe ff ff    	jne    8018da <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  801a1b:	83 ec 04             	sub    $0x4,%esp
  801a1e:	6a 07                	push   $0x7
  801a20:	68 00 f0 bf ee       	push   $0xeebff000
  801a25:	ff 75 e0             	pushl  -0x20(%ebp)
  801a28:	e8 5c fb ff ff       	call   801589 <sys_page_alloc>
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	85 c0                	test   %eax,%eax
  801a32:	74 17                	je     801a4b <fork+0x1be>
		panic("sys_page_alloc Error");
  801a34:	83 ec 04             	sub    $0x4,%esp
  801a37:	68 79 3d 80 00       	push   $0x803d79
  801a3c:	68 83 00 00 00       	push   $0x83
  801a41:	68 13 3d 80 00       	push   $0x803d13
  801a46:	e8 ca ef ff ff       	call   800a15 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  801a4b:	83 ec 08             	sub    $0x8,%esp
  801a4e:	68 8b 33 80 00       	push   $0x80338b
  801a53:	ff 75 e0             	pushl  -0x20(%ebp)
  801a56:	e8 79 fc ff ff       	call   8016d4 <sys_env_set_pgfault_upcall>
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	79 15                	jns    801a77 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  801a62:	50                   	push   %eax
  801a63:	68 8e 3d 80 00       	push   $0x803d8e
  801a68:	68 86 00 00 00       	push   $0x86
  801a6d:	68 13 3d 80 00       	push   $0x803d13
  801a72:	e8 9e ef ff ff       	call   800a15 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801a77:	83 ec 08             	sub    $0x8,%esp
  801a7a:	6a 02                	push   $0x2
  801a7c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a7f:	e8 cc fb ff ff       	call   801650 <sys_env_set_status>
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	79 15                	jns    801aa0 <fork+0x213>
		panic("fork set status: %e", r);
  801a8b:	50                   	push   %eax
  801a8c:	68 a6 3d 80 00       	push   $0x803da6
  801a91:	68 89 00 00 00       	push   $0x89
  801a96:	68 13 3d 80 00       	push   $0x803d13
  801a9b:	e8 75 ef ff ff       	call   800a15 <_panic>
	
	return envid;
  801aa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5f                   	pop    %edi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <sfork>:


// Challenge!
int
sfork(void)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801ab1:	68 ba 3d 80 00       	push   $0x803dba
  801ab6:	68 93 00 00 00       	push   $0x93
  801abb:	68 13 3d 80 00       	push   $0x803d13
  801ac0:	e8 50 ef ff ff       	call   800a15 <_panic>

00801ac5 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  801acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ace:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801ad1:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801ad3:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801ad6:	83 3a 01             	cmpl   $0x1,(%edx)
  801ad9:	7e 09                	jle    801ae4 <argstart+0x1f>
  801adb:	ba a1 37 80 00       	mov    $0x8037a1,%edx
  801ae0:	85 c9                	test   %ecx,%ecx
  801ae2:	75 05                	jne    801ae9 <argstart+0x24>
  801ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae9:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801aec:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <argnext>:

int
argnext(struct Argstate *args)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	53                   	push   %ebx
  801af9:	83 ec 04             	sub    $0x4,%esp
  801afc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801aff:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b06:	8b 43 08             	mov    0x8(%ebx),%eax
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	74 6f                	je     801b7c <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801b0d:	80 38 00             	cmpb   $0x0,(%eax)
  801b10:	75 4e                	jne    801b60 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b12:	8b 0b                	mov    (%ebx),%ecx
  801b14:	83 39 01             	cmpl   $0x1,(%ecx)
  801b17:	74 55                	je     801b6e <argnext+0x79>
		    || args->argv[1][0] != '-'
  801b19:	8b 53 04             	mov    0x4(%ebx),%edx
  801b1c:	8b 42 04             	mov    0x4(%edx),%eax
  801b1f:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b22:	75 4a                	jne    801b6e <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b24:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b28:	74 44                	je     801b6e <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b2a:	83 c0 01             	add    $0x1,%eax
  801b2d:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b30:	83 ec 04             	sub    $0x4,%esp
  801b33:	8b 01                	mov    (%ecx),%eax
  801b35:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b3c:	50                   	push   %eax
  801b3d:	8d 42 08             	lea    0x8(%edx),%eax
  801b40:	50                   	push   %eax
  801b41:	83 c2 04             	add    $0x4,%edx
  801b44:	52                   	push   %edx
  801b45:	e8 ce f7 ff ff       	call   801318 <memmove>
		(*args->argc)--;
  801b4a:	8b 03                	mov    (%ebx),%eax
  801b4c:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b4f:	8b 43 08             	mov    0x8(%ebx),%eax
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b58:	75 06                	jne    801b60 <argnext+0x6b>
  801b5a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b5e:	74 0e                	je     801b6e <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b60:	8b 53 08             	mov    0x8(%ebx),%edx
  801b63:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b66:	83 c2 01             	add    $0x1,%edx
  801b69:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b6c:	eb 13                	jmp    801b81 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b6e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b7a:	eb 05                	jmp    801b81 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 04             	sub    $0x4,%esp
  801b8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b90:	8b 43 08             	mov    0x8(%ebx),%eax
  801b93:	85 c0                	test   %eax,%eax
  801b95:	74 58                	je     801bef <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b97:	80 38 00             	cmpb   $0x0,(%eax)
  801b9a:	74 0c                	je     801ba8 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b9c:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b9f:	c7 43 08 a1 37 80 00 	movl   $0x8037a1,0x8(%ebx)
  801ba6:	eb 42                	jmp    801bea <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801ba8:	8b 13                	mov    (%ebx),%edx
  801baa:	83 3a 01             	cmpl   $0x1,(%edx)
  801bad:	7e 2d                	jle    801bdc <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801baf:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb2:	8b 48 04             	mov    0x4(%eax),%ecx
  801bb5:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801bb8:	83 ec 04             	sub    $0x4,%esp
  801bbb:	8b 12                	mov    (%edx),%edx
  801bbd:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801bc4:	52                   	push   %edx
  801bc5:	8d 50 08             	lea    0x8(%eax),%edx
  801bc8:	52                   	push   %edx
  801bc9:	83 c0 04             	add    $0x4,%eax
  801bcc:	50                   	push   %eax
  801bcd:	e8 46 f7 ff ff       	call   801318 <memmove>
		(*args->argc)--;
  801bd2:	8b 03                	mov    (%ebx),%eax
  801bd4:	83 28 01             	subl   $0x1,(%eax)
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	eb 0e                	jmp    801bea <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801bdc:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801be3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801bea:	8b 43 0c             	mov    0xc(%ebx),%eax
  801bed:	eb 05                	jmp    801bf4 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801bf4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    

00801bf9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	83 ec 08             	sub    $0x8,%esp
  801bff:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c02:	8b 51 0c             	mov    0xc(%ecx),%edx
  801c05:	89 d0                	mov    %edx,%eax
  801c07:	85 d2                	test   %edx,%edx
  801c09:	75 0c                	jne    801c17 <argvalue+0x1e>
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	51                   	push   %ecx
  801c0f:	e8 72 ff ff ff       	call   801b86 <argnextvalue>
  801c14:	83 c4 10             	add    $0x10,%esp
}
  801c17:	c9                   	leave  
  801c18:	c3                   	ret    

00801c19 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1f:	05 00 00 00 30       	add    $0x30000000,%eax
  801c24:	c1 e8 0c             	shr    $0xc,%eax
}
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2f:	05 00 00 00 30       	add    $0x30000000,%eax
  801c34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c39:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c46:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c4b:	89 c2                	mov    %eax,%edx
  801c4d:	c1 ea 16             	shr    $0x16,%edx
  801c50:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c57:	f6 c2 01             	test   $0x1,%dl
  801c5a:	74 11                	je     801c6d <fd_alloc+0x2d>
  801c5c:	89 c2                	mov    %eax,%edx
  801c5e:	c1 ea 0c             	shr    $0xc,%edx
  801c61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c68:	f6 c2 01             	test   $0x1,%dl
  801c6b:	75 09                	jne    801c76 <fd_alloc+0x36>
			*fd_store = fd;
  801c6d:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c74:	eb 17                	jmp    801c8d <fd_alloc+0x4d>
  801c76:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c7b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c80:	75 c9                	jne    801c4b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c82:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c88:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c95:	83 f8 1f             	cmp    $0x1f,%eax
  801c98:	77 36                	ja     801cd0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c9a:	c1 e0 0c             	shl    $0xc,%eax
  801c9d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801ca2:	89 c2                	mov    %eax,%edx
  801ca4:	c1 ea 16             	shr    $0x16,%edx
  801ca7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cae:	f6 c2 01             	test   $0x1,%dl
  801cb1:	74 24                	je     801cd7 <fd_lookup+0x48>
  801cb3:	89 c2                	mov    %eax,%edx
  801cb5:	c1 ea 0c             	shr    $0xc,%edx
  801cb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cbf:	f6 c2 01             	test   $0x1,%dl
  801cc2:	74 1a                	je     801cde <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801cc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc7:	89 02                	mov    %eax,(%edx)
	return 0;
  801cc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cce:	eb 13                	jmp    801ce3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cd0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cd5:	eb 0c                	jmp    801ce3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cd7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cdc:	eb 05                	jmp    801ce3 <fd_lookup+0x54>
  801cde:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 08             	sub    $0x8,%esp
  801ceb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cee:	ba 4c 3e 80 00       	mov    $0x803e4c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801cf3:	eb 13                	jmp    801d08 <dev_lookup+0x23>
  801cf5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801cf8:	39 08                	cmp    %ecx,(%eax)
  801cfa:	75 0c                	jne    801d08 <dev_lookup+0x23>
			*dev = devtab[i];
  801cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cff:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d01:	b8 00 00 00 00       	mov    $0x0,%eax
  801d06:	eb 2e                	jmp    801d36 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d08:	8b 02                	mov    (%edx),%eax
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	75 e7                	jne    801cf5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d0e:	a1 28 54 80 00       	mov    0x805428,%eax
  801d13:	8b 40 48             	mov    0x48(%eax),%eax
  801d16:	83 ec 04             	sub    $0x4,%esp
  801d19:	51                   	push   %ecx
  801d1a:	50                   	push   %eax
  801d1b:	68 d0 3d 80 00       	push   $0x803dd0
  801d20:	e8 c9 ed ff ff       	call   800aee <cprintf>
	*dev = 0;
  801d25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d28:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d36:	c9                   	leave  
  801d37:	c3                   	ret    

00801d38 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	56                   	push   %esi
  801d3c:	53                   	push   %ebx
  801d3d:	83 ec 10             	sub    $0x10,%esp
  801d40:	8b 75 08             	mov    0x8(%ebp),%esi
  801d43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d49:	50                   	push   %eax
  801d4a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d50:	c1 e8 0c             	shr    $0xc,%eax
  801d53:	50                   	push   %eax
  801d54:	e8 36 ff ff ff       	call   801c8f <fd_lookup>
  801d59:	83 c4 08             	add    $0x8,%esp
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	78 05                	js     801d65 <fd_close+0x2d>
	    || fd != fd2)
  801d60:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d63:	74 0c                	je     801d71 <fd_close+0x39>
		return (must_exist ? r : 0);
  801d65:	84 db                	test   %bl,%bl
  801d67:	ba 00 00 00 00       	mov    $0x0,%edx
  801d6c:	0f 44 c2             	cmove  %edx,%eax
  801d6f:	eb 41                	jmp    801db2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d71:	83 ec 08             	sub    $0x8,%esp
  801d74:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d77:	50                   	push   %eax
  801d78:	ff 36                	pushl  (%esi)
  801d7a:	e8 66 ff ff ff       	call   801ce5 <dev_lookup>
  801d7f:	89 c3                	mov    %eax,%ebx
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	85 c0                	test   %eax,%eax
  801d86:	78 1a                	js     801da2 <fd_close+0x6a>
		if (dev->dev_close)
  801d88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d8b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d8e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d93:	85 c0                	test   %eax,%eax
  801d95:	74 0b                	je     801da2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d97:	83 ec 0c             	sub    $0xc,%esp
  801d9a:	56                   	push   %esi
  801d9b:	ff d0                	call   *%eax
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801da2:	83 ec 08             	sub    $0x8,%esp
  801da5:	56                   	push   %esi
  801da6:	6a 00                	push   $0x0
  801da8:	e8 61 f8 ff ff       	call   80160e <sys_page_unmap>
	return r;
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	89 d8                	mov    %ebx,%eax
}
  801db2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db5:	5b                   	pop    %ebx
  801db6:	5e                   	pop    %esi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    

00801db9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc2:	50                   	push   %eax
  801dc3:	ff 75 08             	pushl  0x8(%ebp)
  801dc6:	e8 c4 fe ff ff       	call   801c8f <fd_lookup>
  801dcb:	83 c4 08             	add    $0x8,%esp
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 10                	js     801de2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801dd2:	83 ec 08             	sub    $0x8,%esp
  801dd5:	6a 01                	push   $0x1
  801dd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dda:	e8 59 ff ff ff       	call   801d38 <fd_close>
  801ddf:	83 c4 10             	add    $0x10,%esp
}
  801de2:	c9                   	leave  
  801de3:	c3                   	ret    

00801de4 <close_all>:

void
close_all(void)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	53                   	push   %ebx
  801de8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801deb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801df0:	83 ec 0c             	sub    $0xc,%esp
  801df3:	53                   	push   %ebx
  801df4:	e8 c0 ff ff ff       	call   801db9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801df9:	83 c3 01             	add    $0x1,%ebx
  801dfc:	83 c4 10             	add    $0x10,%esp
  801dff:	83 fb 20             	cmp    $0x20,%ebx
  801e02:	75 ec                	jne    801df0 <close_all+0xc>
		close(i);
}
  801e04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e07:	c9                   	leave  
  801e08:	c3                   	ret    

00801e09 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	57                   	push   %edi
  801e0d:	56                   	push   %esi
  801e0e:	53                   	push   %ebx
  801e0f:	83 ec 2c             	sub    $0x2c,%esp
  801e12:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e15:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e18:	50                   	push   %eax
  801e19:	ff 75 08             	pushl  0x8(%ebp)
  801e1c:	e8 6e fe ff ff       	call   801c8f <fd_lookup>
  801e21:	83 c4 08             	add    $0x8,%esp
  801e24:	85 c0                	test   %eax,%eax
  801e26:	0f 88 c1 00 00 00    	js     801eed <dup+0xe4>
		return r;
	close(newfdnum);
  801e2c:	83 ec 0c             	sub    $0xc,%esp
  801e2f:	56                   	push   %esi
  801e30:	e8 84 ff ff ff       	call   801db9 <close>

	newfd = INDEX2FD(newfdnum);
  801e35:	89 f3                	mov    %esi,%ebx
  801e37:	c1 e3 0c             	shl    $0xc,%ebx
  801e3a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e40:	83 c4 04             	add    $0x4,%esp
  801e43:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e46:	e8 de fd ff ff       	call   801c29 <fd2data>
  801e4b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e4d:	89 1c 24             	mov    %ebx,(%esp)
  801e50:	e8 d4 fd ff ff       	call   801c29 <fd2data>
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e5b:	89 f8                	mov    %edi,%eax
  801e5d:	c1 e8 16             	shr    $0x16,%eax
  801e60:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e67:	a8 01                	test   $0x1,%al
  801e69:	74 37                	je     801ea2 <dup+0x99>
  801e6b:	89 f8                	mov    %edi,%eax
  801e6d:	c1 e8 0c             	shr    $0xc,%eax
  801e70:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e77:	f6 c2 01             	test   $0x1,%dl
  801e7a:	74 26                	je     801ea2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e7c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e83:	83 ec 0c             	sub    $0xc,%esp
  801e86:	25 07 0e 00 00       	and    $0xe07,%eax
  801e8b:	50                   	push   %eax
  801e8c:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e8f:	6a 00                	push   $0x0
  801e91:	57                   	push   %edi
  801e92:	6a 00                	push   $0x0
  801e94:	e8 33 f7 ff ff       	call   8015cc <sys_page_map>
  801e99:	89 c7                	mov    %eax,%edi
  801e9b:	83 c4 20             	add    $0x20,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 2e                	js     801ed0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ea2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ea5:	89 d0                	mov    %edx,%eax
  801ea7:	c1 e8 0c             	shr    $0xc,%eax
  801eaa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801eb1:	83 ec 0c             	sub    $0xc,%esp
  801eb4:	25 07 0e 00 00       	and    $0xe07,%eax
  801eb9:	50                   	push   %eax
  801eba:	53                   	push   %ebx
  801ebb:	6a 00                	push   $0x0
  801ebd:	52                   	push   %edx
  801ebe:	6a 00                	push   $0x0
  801ec0:	e8 07 f7 ff ff       	call   8015cc <sys_page_map>
  801ec5:	89 c7                	mov    %eax,%edi
  801ec7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801eca:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ecc:	85 ff                	test   %edi,%edi
  801ece:	79 1d                	jns    801eed <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ed0:	83 ec 08             	sub    $0x8,%esp
  801ed3:	53                   	push   %ebx
  801ed4:	6a 00                	push   $0x0
  801ed6:	e8 33 f7 ff ff       	call   80160e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801edb:	83 c4 08             	add    $0x8,%esp
  801ede:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ee1:	6a 00                	push   $0x0
  801ee3:	e8 26 f7 ff ff       	call   80160e <sys_page_unmap>
	return r;
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	89 f8                	mov    %edi,%eax
}
  801eed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef0:	5b                   	pop    %ebx
  801ef1:	5e                   	pop    %esi
  801ef2:	5f                   	pop    %edi
  801ef3:	5d                   	pop    %ebp
  801ef4:	c3                   	ret    

00801ef5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	53                   	push   %ebx
  801ef9:	83 ec 14             	sub    $0x14,%esp
  801efc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801eff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f02:	50                   	push   %eax
  801f03:	53                   	push   %ebx
  801f04:	e8 86 fd ff ff       	call   801c8f <fd_lookup>
  801f09:	83 c4 08             	add    $0x8,%esp
  801f0c:	89 c2                	mov    %eax,%edx
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	78 6d                	js     801f7f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f12:	83 ec 08             	sub    $0x8,%esp
  801f15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f18:	50                   	push   %eax
  801f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f1c:	ff 30                	pushl  (%eax)
  801f1e:	e8 c2 fd ff ff       	call   801ce5 <dev_lookup>
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 4c                	js     801f76 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f2d:	8b 42 08             	mov    0x8(%edx),%eax
  801f30:	83 e0 03             	and    $0x3,%eax
  801f33:	83 f8 01             	cmp    $0x1,%eax
  801f36:	75 21                	jne    801f59 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f38:	a1 28 54 80 00       	mov    0x805428,%eax
  801f3d:	8b 40 48             	mov    0x48(%eax),%eax
  801f40:	83 ec 04             	sub    $0x4,%esp
  801f43:	53                   	push   %ebx
  801f44:	50                   	push   %eax
  801f45:	68 11 3e 80 00       	push   $0x803e11
  801f4a:	e8 9f eb ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f57:	eb 26                	jmp    801f7f <read+0x8a>
	}
	if (!dev->dev_read)
  801f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5c:	8b 40 08             	mov    0x8(%eax),%eax
  801f5f:	85 c0                	test   %eax,%eax
  801f61:	74 17                	je     801f7a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f63:	83 ec 04             	sub    $0x4,%esp
  801f66:	ff 75 10             	pushl  0x10(%ebp)
  801f69:	ff 75 0c             	pushl  0xc(%ebp)
  801f6c:	52                   	push   %edx
  801f6d:	ff d0                	call   *%eax
  801f6f:	89 c2                	mov    %eax,%edx
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	eb 09                	jmp    801f7f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f76:	89 c2                	mov    %eax,%edx
  801f78:	eb 05                	jmp    801f7f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f7a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801f7f:	89 d0                	mov    %edx,%eax
  801f81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f84:	c9                   	leave  
  801f85:	c3                   	ret    

00801f86 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	57                   	push   %edi
  801f8a:	56                   	push   %esi
  801f8b:	53                   	push   %ebx
  801f8c:	83 ec 0c             	sub    $0xc,%esp
  801f8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f92:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f95:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f9a:	eb 21                	jmp    801fbd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f9c:	83 ec 04             	sub    $0x4,%esp
  801f9f:	89 f0                	mov    %esi,%eax
  801fa1:	29 d8                	sub    %ebx,%eax
  801fa3:	50                   	push   %eax
  801fa4:	89 d8                	mov    %ebx,%eax
  801fa6:	03 45 0c             	add    0xc(%ebp),%eax
  801fa9:	50                   	push   %eax
  801faa:	57                   	push   %edi
  801fab:	e8 45 ff ff ff       	call   801ef5 <read>
		if (m < 0)
  801fb0:	83 c4 10             	add    $0x10,%esp
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	78 10                	js     801fc7 <readn+0x41>
			return m;
		if (m == 0)
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	74 0a                	je     801fc5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fbb:	01 c3                	add    %eax,%ebx
  801fbd:	39 f3                	cmp    %esi,%ebx
  801fbf:	72 db                	jb     801f9c <readn+0x16>
  801fc1:	89 d8                	mov    %ebx,%eax
  801fc3:	eb 02                	jmp    801fc7 <readn+0x41>
  801fc5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801fc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fca:	5b                   	pop    %ebx
  801fcb:	5e                   	pop    %esi
  801fcc:	5f                   	pop    %edi
  801fcd:	5d                   	pop    %ebp
  801fce:	c3                   	ret    

00801fcf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	53                   	push   %ebx
  801fd3:	83 ec 14             	sub    $0x14,%esp
  801fd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fd9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fdc:	50                   	push   %eax
  801fdd:	53                   	push   %ebx
  801fde:	e8 ac fc ff ff       	call   801c8f <fd_lookup>
  801fe3:	83 c4 08             	add    $0x8,%esp
  801fe6:	89 c2                	mov    %eax,%edx
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	78 68                	js     802054 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fec:	83 ec 08             	sub    $0x8,%esp
  801fef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff2:	50                   	push   %eax
  801ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff6:	ff 30                	pushl  (%eax)
  801ff8:	e8 e8 fc ff ff       	call   801ce5 <dev_lookup>
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	85 c0                	test   %eax,%eax
  802002:	78 47                	js     80204b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802004:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802007:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80200b:	75 21                	jne    80202e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80200d:	a1 28 54 80 00       	mov    0x805428,%eax
  802012:	8b 40 48             	mov    0x48(%eax),%eax
  802015:	83 ec 04             	sub    $0x4,%esp
  802018:	53                   	push   %ebx
  802019:	50                   	push   %eax
  80201a:	68 2d 3e 80 00       	push   $0x803e2d
  80201f:	e8 ca ea ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  802024:	83 c4 10             	add    $0x10,%esp
  802027:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80202c:	eb 26                	jmp    802054 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80202e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802031:	8b 52 0c             	mov    0xc(%edx),%edx
  802034:	85 d2                	test   %edx,%edx
  802036:	74 17                	je     80204f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802038:	83 ec 04             	sub    $0x4,%esp
  80203b:	ff 75 10             	pushl  0x10(%ebp)
  80203e:	ff 75 0c             	pushl  0xc(%ebp)
  802041:	50                   	push   %eax
  802042:	ff d2                	call   *%edx
  802044:	89 c2                	mov    %eax,%edx
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	eb 09                	jmp    802054 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80204b:	89 c2                	mov    %eax,%edx
  80204d:	eb 05                	jmp    802054 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80204f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802054:	89 d0                	mov    %edx,%eax
  802056:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802059:	c9                   	leave  
  80205a:	c3                   	ret    

0080205b <seek>:

int
seek(int fdnum, off_t offset)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802061:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802064:	50                   	push   %eax
  802065:	ff 75 08             	pushl  0x8(%ebp)
  802068:	e8 22 fc ff ff       	call   801c8f <fd_lookup>
  80206d:	83 c4 08             	add    $0x8,%esp
  802070:	85 c0                	test   %eax,%eax
  802072:	78 0e                	js     802082 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802074:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802077:	8b 55 0c             	mov    0xc(%ebp),%edx
  80207a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80207d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802082:	c9                   	leave  
  802083:	c3                   	ret    

00802084 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	53                   	push   %ebx
  802088:	83 ec 14             	sub    $0x14,%esp
  80208b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80208e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802091:	50                   	push   %eax
  802092:	53                   	push   %ebx
  802093:	e8 f7 fb ff ff       	call   801c8f <fd_lookup>
  802098:	83 c4 08             	add    $0x8,%esp
  80209b:	89 c2                	mov    %eax,%edx
  80209d:	85 c0                	test   %eax,%eax
  80209f:	78 65                	js     802106 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020a1:	83 ec 08             	sub    $0x8,%esp
  8020a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a7:	50                   	push   %eax
  8020a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ab:	ff 30                	pushl  (%eax)
  8020ad:	e8 33 fc ff ff       	call   801ce5 <dev_lookup>
  8020b2:	83 c4 10             	add    $0x10,%esp
  8020b5:	85 c0                	test   %eax,%eax
  8020b7:	78 44                	js     8020fd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020c0:	75 21                	jne    8020e3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8020c2:	a1 28 54 80 00       	mov    0x805428,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020c7:	8b 40 48             	mov    0x48(%eax),%eax
  8020ca:	83 ec 04             	sub    $0x4,%esp
  8020cd:	53                   	push   %ebx
  8020ce:	50                   	push   %eax
  8020cf:	68 f0 3d 80 00       	push   $0x803df0
  8020d4:	e8 15 ea ff ff       	call   800aee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8020d9:	83 c4 10             	add    $0x10,%esp
  8020dc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8020e1:	eb 23                	jmp    802106 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8020e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020e6:	8b 52 18             	mov    0x18(%edx),%edx
  8020e9:	85 d2                	test   %edx,%edx
  8020eb:	74 14                	je     802101 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020ed:	83 ec 08             	sub    $0x8,%esp
  8020f0:	ff 75 0c             	pushl  0xc(%ebp)
  8020f3:	50                   	push   %eax
  8020f4:	ff d2                	call   *%edx
  8020f6:	89 c2                	mov    %eax,%edx
  8020f8:	83 c4 10             	add    $0x10,%esp
  8020fb:	eb 09                	jmp    802106 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020fd:	89 c2                	mov    %eax,%edx
  8020ff:	eb 05                	jmp    802106 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802101:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802106:	89 d0                	mov    %edx,%eax
  802108:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80210b:	c9                   	leave  
  80210c:	c3                   	ret    

0080210d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80210d:	55                   	push   %ebp
  80210e:	89 e5                	mov    %esp,%ebp
  802110:	53                   	push   %ebx
  802111:	83 ec 14             	sub    $0x14,%esp
  802114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802117:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80211a:	50                   	push   %eax
  80211b:	ff 75 08             	pushl  0x8(%ebp)
  80211e:	e8 6c fb ff ff       	call   801c8f <fd_lookup>
  802123:	83 c4 08             	add    $0x8,%esp
  802126:	89 c2                	mov    %eax,%edx
  802128:	85 c0                	test   %eax,%eax
  80212a:	78 58                	js     802184 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80212c:	83 ec 08             	sub    $0x8,%esp
  80212f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802132:	50                   	push   %eax
  802133:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802136:	ff 30                	pushl  (%eax)
  802138:	e8 a8 fb ff ff       	call   801ce5 <dev_lookup>
  80213d:	83 c4 10             	add    $0x10,%esp
  802140:	85 c0                	test   %eax,%eax
  802142:	78 37                	js     80217b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802144:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802147:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80214b:	74 32                	je     80217f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80214d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802150:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802157:	00 00 00 
	stat->st_isdir = 0;
  80215a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802161:	00 00 00 
	stat->st_dev = dev;
  802164:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80216a:	83 ec 08             	sub    $0x8,%esp
  80216d:	53                   	push   %ebx
  80216e:	ff 75 f0             	pushl  -0x10(%ebp)
  802171:	ff 50 14             	call   *0x14(%eax)
  802174:	89 c2                	mov    %eax,%edx
  802176:	83 c4 10             	add    $0x10,%esp
  802179:	eb 09                	jmp    802184 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80217b:	89 c2                	mov    %eax,%edx
  80217d:	eb 05                	jmp    802184 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80217f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802184:	89 d0                	mov    %edx,%eax
  802186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802189:	c9                   	leave  
  80218a:	c3                   	ret    

0080218b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
  80218e:	56                   	push   %esi
  80218f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802190:	83 ec 08             	sub    $0x8,%esp
  802193:	6a 00                	push   $0x0
  802195:	ff 75 08             	pushl  0x8(%ebp)
  802198:	e8 ef 01 00 00       	call   80238c <open>
  80219d:	89 c3                	mov    %eax,%ebx
  80219f:	83 c4 10             	add    $0x10,%esp
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	78 1b                	js     8021c1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8021a6:	83 ec 08             	sub    $0x8,%esp
  8021a9:	ff 75 0c             	pushl  0xc(%ebp)
  8021ac:	50                   	push   %eax
  8021ad:	e8 5b ff ff ff       	call   80210d <fstat>
  8021b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8021b4:	89 1c 24             	mov    %ebx,(%esp)
  8021b7:	e8 fd fb ff ff       	call   801db9 <close>
	return r;
  8021bc:	83 c4 10             	add    $0x10,%esp
  8021bf:	89 f0                	mov    %esi,%eax
}
  8021c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    

008021c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	56                   	push   %esi
  8021cc:	53                   	push   %ebx
  8021cd:	89 c6                	mov    %eax,%esi
  8021cf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8021d1:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8021d8:	75 12                	jne    8021ec <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021da:	83 ec 0c             	sub    $0xc,%esp
  8021dd:	6a 01                	push   $0x1
  8021df:	e8 93 12 00 00       	call   803477 <ipc_find_env>
  8021e4:	a3 20 54 80 00       	mov    %eax,0x805420
  8021e9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021ec:	6a 07                	push   $0x7
  8021ee:	68 00 60 80 00       	push   $0x806000
  8021f3:	56                   	push   %esi
  8021f4:	ff 35 20 54 80 00    	pushl  0x805420
  8021fa:	e8 29 12 00 00       	call   803428 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021ff:	83 c4 0c             	add    $0xc,%esp
  802202:	6a 00                	push   $0x0
  802204:	53                   	push   %ebx
  802205:	6a 00                	push   $0x0
  802207:	e8 a6 11 00 00       	call   8033b2 <ipc_recv>
}
  80220c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80220f:	5b                   	pop    %ebx
  802210:	5e                   	pop    %esi
  802211:	5d                   	pop    %ebp
  802212:	c3                   	ret    

00802213 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802213:	55                   	push   %ebp
  802214:	89 e5                	mov    %esp,%ebp
  802216:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802219:	8b 45 08             	mov    0x8(%ebp),%eax
  80221c:	8b 40 0c             	mov    0xc(%eax),%eax
  80221f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802224:	8b 45 0c             	mov    0xc(%ebp),%eax
  802227:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80222c:	ba 00 00 00 00       	mov    $0x0,%edx
  802231:	b8 02 00 00 00       	mov    $0x2,%eax
  802236:	e8 8d ff ff ff       	call   8021c8 <fsipc>
}
  80223b:	c9                   	leave  
  80223c:	c3                   	ret    

0080223d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80223d:	55                   	push   %ebp
  80223e:	89 e5                	mov    %esp,%ebp
  802240:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802243:	8b 45 08             	mov    0x8(%ebp),%eax
  802246:	8b 40 0c             	mov    0xc(%eax),%eax
  802249:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80224e:	ba 00 00 00 00       	mov    $0x0,%edx
  802253:	b8 06 00 00 00       	mov    $0x6,%eax
  802258:	e8 6b ff ff ff       	call   8021c8 <fsipc>
}
  80225d:	c9                   	leave  
  80225e:	c3                   	ret    

0080225f <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80225f:	55                   	push   %ebp
  802260:	89 e5                	mov    %esp,%ebp
  802262:	53                   	push   %ebx
  802263:	83 ec 04             	sub    $0x4,%esp
  802266:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802269:	8b 45 08             	mov    0x8(%ebp),%eax
  80226c:	8b 40 0c             	mov    0xc(%eax),%eax
  80226f:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802274:	ba 00 00 00 00       	mov    $0x0,%edx
  802279:	b8 05 00 00 00       	mov    $0x5,%eax
  80227e:	e8 45 ff ff ff       	call   8021c8 <fsipc>
  802283:	85 c0                	test   %eax,%eax
  802285:	78 2c                	js     8022b3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802287:	83 ec 08             	sub    $0x8,%esp
  80228a:	68 00 60 80 00       	push   $0x806000
  80228f:	53                   	push   %ebx
  802290:	e8 f1 ee ff ff       	call   801186 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802295:	a1 80 60 80 00       	mov    0x806080,%eax
  80229a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8022a0:	a1 84 60 80 00       	mov    0x806084,%eax
  8022a5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8022ab:	83 c4 10             	add    $0x10,%esp
  8022ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022b6:	c9                   	leave  
  8022b7:	c3                   	ret    

008022b8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8022b8:	55                   	push   %ebp
  8022b9:	89 e5                	mov    %esp,%ebp
  8022bb:	53                   	push   %ebx
  8022bc:	83 ec 08             	sub    $0x8,%esp
  8022bf:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8022c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8022c8:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  8022ce:	a3 04 60 80 00       	mov    %eax,0x806004
  8022d3:	3d 08 60 80 00       	cmp    $0x806008,%eax
  8022d8:	bb 08 60 80 00       	mov    $0x806008,%ebx
  8022dd:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8022e0:	53                   	push   %ebx
  8022e1:	ff 75 0c             	pushl  0xc(%ebp)
  8022e4:	68 08 60 80 00       	push   $0x806008
  8022e9:	e8 2a f0 ff ff       	call   801318 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8022ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8022f8:	e8 cb fe ff ff       	call   8021c8 <fsipc>
  8022fd:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  802300:	85 c0                	test   %eax,%eax
  802302:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  802305:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802308:	c9                   	leave  
  802309:	c3                   	ret    

0080230a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80230a:	55                   	push   %ebp
  80230b:	89 e5                	mov    %esp,%ebp
  80230d:	56                   	push   %esi
  80230e:	53                   	push   %ebx
  80230f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802312:	8b 45 08             	mov    0x8(%ebp),%eax
  802315:	8b 40 0c             	mov    0xc(%eax),%eax
  802318:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80231d:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802323:	ba 00 00 00 00       	mov    $0x0,%edx
  802328:	b8 03 00 00 00       	mov    $0x3,%eax
  80232d:	e8 96 fe ff ff       	call   8021c8 <fsipc>
  802332:	89 c3                	mov    %eax,%ebx
  802334:	85 c0                	test   %eax,%eax
  802336:	78 4b                	js     802383 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802338:	39 c6                	cmp    %eax,%esi
  80233a:	73 16                	jae    802352 <devfile_read+0x48>
  80233c:	68 60 3e 80 00       	push   $0x803e60
  802341:	68 cf 38 80 00       	push   $0x8038cf
  802346:	6a 7c                	push   $0x7c
  802348:	68 67 3e 80 00       	push   $0x803e67
  80234d:	e8 c3 e6 ff ff       	call   800a15 <_panic>
	assert(r <= PGSIZE);
  802352:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802357:	7e 16                	jle    80236f <devfile_read+0x65>
  802359:	68 72 3e 80 00       	push   $0x803e72
  80235e:	68 cf 38 80 00       	push   $0x8038cf
  802363:	6a 7d                	push   $0x7d
  802365:	68 67 3e 80 00       	push   $0x803e67
  80236a:	e8 a6 e6 ff ff       	call   800a15 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80236f:	83 ec 04             	sub    $0x4,%esp
  802372:	50                   	push   %eax
  802373:	68 00 60 80 00       	push   $0x806000
  802378:	ff 75 0c             	pushl  0xc(%ebp)
  80237b:	e8 98 ef ff ff       	call   801318 <memmove>
	return r;
  802380:	83 c4 10             	add    $0x10,%esp
}
  802383:	89 d8                	mov    %ebx,%eax
  802385:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5d                   	pop    %ebp
  80238b:	c3                   	ret    

0080238c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80238c:	55                   	push   %ebp
  80238d:	89 e5                	mov    %esp,%ebp
  80238f:	53                   	push   %ebx
  802390:	83 ec 20             	sub    $0x20,%esp
  802393:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802396:	53                   	push   %ebx
  802397:	e8 b1 ed ff ff       	call   80114d <strlen>
  80239c:	83 c4 10             	add    $0x10,%esp
  80239f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8023a4:	7f 67                	jg     80240d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8023a6:	83 ec 0c             	sub    $0xc,%esp
  8023a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ac:	50                   	push   %eax
  8023ad:	e8 8e f8 ff ff       	call   801c40 <fd_alloc>
  8023b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8023b5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8023b7:	85 c0                	test   %eax,%eax
  8023b9:	78 57                	js     802412 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8023bb:	83 ec 08             	sub    $0x8,%esp
  8023be:	53                   	push   %ebx
  8023bf:	68 00 60 80 00       	push   $0x806000
  8023c4:	e8 bd ed ff ff       	call   801186 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8023c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023cc:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8023d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d9:	e8 ea fd ff ff       	call   8021c8 <fsipc>
  8023de:	89 c3                	mov    %eax,%ebx
  8023e0:	83 c4 10             	add    $0x10,%esp
  8023e3:	85 c0                	test   %eax,%eax
  8023e5:	79 14                	jns    8023fb <open+0x6f>
		fd_close(fd, 0);
  8023e7:	83 ec 08             	sub    $0x8,%esp
  8023ea:	6a 00                	push   $0x0
  8023ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8023ef:	e8 44 f9 ff ff       	call   801d38 <fd_close>
		return r;
  8023f4:	83 c4 10             	add    $0x10,%esp
  8023f7:	89 da                	mov    %ebx,%edx
  8023f9:	eb 17                	jmp    802412 <open+0x86>
	}

	return fd2num(fd);
  8023fb:	83 ec 0c             	sub    $0xc,%esp
  8023fe:	ff 75 f4             	pushl  -0xc(%ebp)
  802401:	e8 13 f8 ff ff       	call   801c19 <fd2num>
  802406:	89 c2                	mov    %eax,%edx
  802408:	83 c4 10             	add    $0x10,%esp
  80240b:	eb 05                	jmp    802412 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80240d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802412:	89 d0                	mov    %edx,%eax
  802414:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802417:	c9                   	leave  
  802418:	c3                   	ret    

00802419 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802419:	55                   	push   %ebp
  80241a:	89 e5                	mov    %esp,%ebp
  80241c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80241f:	ba 00 00 00 00       	mov    $0x0,%edx
  802424:	b8 08 00 00 00       	mov    $0x8,%eax
  802429:	e8 9a fd ff ff       	call   8021c8 <fsipc>
}
  80242e:	c9                   	leave  
  80242f:	c3                   	ret    

00802430 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802430:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802434:	7e 37                	jle    80246d <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	53                   	push   %ebx
  80243a:	83 ec 08             	sub    $0x8,%esp
  80243d:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80243f:	ff 70 04             	pushl  0x4(%eax)
  802442:	8d 40 10             	lea    0x10(%eax),%eax
  802445:	50                   	push   %eax
  802446:	ff 33                	pushl  (%ebx)
  802448:	e8 82 fb ff ff       	call   801fcf <write>
		if (result > 0)
  80244d:	83 c4 10             	add    $0x10,%esp
  802450:	85 c0                	test   %eax,%eax
  802452:	7e 03                	jle    802457 <writebuf+0x27>
			b->result += result;
  802454:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802457:	3b 43 04             	cmp    0x4(%ebx),%eax
  80245a:	74 0d                	je     802469 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80245c:	85 c0                	test   %eax,%eax
  80245e:	ba 00 00 00 00       	mov    $0x0,%edx
  802463:	0f 4f c2             	cmovg  %edx,%eax
  802466:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802469:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80246c:	c9                   	leave  
  80246d:	f3 c3                	repz ret 

0080246f <putch>:

static void
putch(int ch, void *thunk)
{
  80246f:	55                   	push   %ebp
  802470:	89 e5                	mov    %esp,%ebp
  802472:	53                   	push   %ebx
  802473:	83 ec 04             	sub    $0x4,%esp
  802476:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802479:	8b 53 04             	mov    0x4(%ebx),%edx
  80247c:	8d 42 01             	lea    0x1(%edx),%eax
  80247f:	89 43 04             	mov    %eax,0x4(%ebx)
  802482:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802485:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802489:	3d 00 01 00 00       	cmp    $0x100,%eax
  80248e:	75 0e                	jne    80249e <putch+0x2f>
		writebuf(b);
  802490:	89 d8                	mov    %ebx,%eax
  802492:	e8 99 ff ff ff       	call   802430 <writebuf>
		b->idx = 0;
  802497:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80249e:	83 c4 04             	add    $0x4,%esp
  8024a1:	5b                   	pop    %ebx
  8024a2:	5d                   	pop    %ebp
  8024a3:	c3                   	ret    

008024a4 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8024a4:	55                   	push   %ebp
  8024a5:	89 e5                	mov    %esp,%ebp
  8024a7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8024ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b0:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8024b6:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8024bd:	00 00 00 
	b.result = 0;
  8024c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8024c7:	00 00 00 
	b.error = 1;
  8024ca:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8024d1:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8024d4:	ff 75 10             	pushl  0x10(%ebp)
  8024d7:	ff 75 0c             	pushl  0xc(%ebp)
  8024da:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024e0:	50                   	push   %eax
  8024e1:	68 6f 24 80 00       	push   $0x80246f
  8024e6:	e8 3a e7 ff ff       	call   800c25 <vprintfmt>
	if (b.idx > 0)
  8024eb:	83 c4 10             	add    $0x10,%esp
  8024ee:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024f5:	7e 0b                	jle    802502 <vfprintf+0x5e>
		writebuf(&b);
  8024f7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024fd:	e8 2e ff ff ff       	call   802430 <writebuf>

	return (b.result ? b.result : b.error);
  802502:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802508:	85 c0                	test   %eax,%eax
  80250a:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802511:	c9                   	leave  
  802512:	c3                   	ret    

00802513 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802513:	55                   	push   %ebp
  802514:	89 e5                	mov    %esp,%ebp
  802516:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802519:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80251c:	50                   	push   %eax
  80251d:	ff 75 0c             	pushl  0xc(%ebp)
  802520:	ff 75 08             	pushl  0x8(%ebp)
  802523:	e8 7c ff ff ff       	call   8024a4 <vfprintf>
	va_end(ap);

	return cnt;
}
  802528:	c9                   	leave  
  802529:	c3                   	ret    

0080252a <printf>:

int
printf(const char *fmt, ...)
{
  80252a:	55                   	push   %ebp
  80252b:	89 e5                	mov    %esp,%ebp
  80252d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802530:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802533:	50                   	push   %eax
  802534:	ff 75 08             	pushl  0x8(%ebp)
  802537:	6a 01                	push   $0x1
  802539:	e8 66 ff ff ff       	call   8024a4 <vfprintf>
	va_end(ap);

	return cnt;
}
  80253e:	c9                   	leave  
  80253f:	c3                   	ret    

00802540 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802540:	55                   	push   %ebp
  802541:	89 e5                	mov    %esp,%ebp
  802543:	57                   	push   %edi
  802544:	56                   	push   %esi
  802545:	53                   	push   %ebx
  802546:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80254c:	6a 00                	push   $0x0
  80254e:	ff 75 08             	pushl  0x8(%ebp)
  802551:	e8 36 fe ff ff       	call   80238c <open>
  802556:	89 c7                	mov    %eax,%edi
  802558:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80255e:	83 c4 10             	add    $0x10,%esp
  802561:	85 c0                	test   %eax,%eax
  802563:	0f 88 81 04 00 00    	js     8029ea <spawn+0x4aa>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802569:	83 ec 04             	sub    $0x4,%esp
  80256c:	68 00 02 00 00       	push   $0x200
  802571:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802577:	50                   	push   %eax
  802578:	57                   	push   %edi
  802579:	e8 08 fa ff ff       	call   801f86 <readn>
  80257e:	83 c4 10             	add    $0x10,%esp
  802581:	3d 00 02 00 00       	cmp    $0x200,%eax
  802586:	75 0c                	jne    802594 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802588:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80258f:	45 4c 46 
  802592:	74 33                	je     8025c7 <spawn+0x87>
		close(fd);
  802594:	83 ec 0c             	sub    $0xc,%esp
  802597:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80259d:	e8 17 f8 ff ff       	call   801db9 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8025a2:	83 c4 0c             	add    $0xc,%esp
  8025a5:	68 7f 45 4c 46       	push   $0x464c457f
  8025aa:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8025b0:	68 7e 3e 80 00       	push   $0x803e7e
  8025b5:	e8 34 e5 ff ff       	call   800aee <cprintf>
		return -E_NOT_EXEC;
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8025c2:	e9 c6 04 00 00       	jmp    802a8d <spawn+0x54d>
  8025c7:	b8 07 00 00 00       	mov    $0x7,%eax
  8025cc:	cd 30                	int    $0x30
  8025ce:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8025d4:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8025da:	85 c0                	test   %eax,%eax
  8025dc:	0f 88 13 04 00 00    	js     8029f5 <spawn+0x4b5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8025e2:	89 c6                	mov    %eax,%esi
  8025e4:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8025ea:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8025ed:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8025f3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025f9:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802600:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802606:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80260c:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802611:	be 00 00 00 00       	mov    $0x0,%esi
  802616:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802619:	eb 13                	jmp    80262e <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80261b:	83 ec 0c             	sub    $0xc,%esp
  80261e:	50                   	push   %eax
  80261f:	e8 29 eb ff ff       	call   80114d <strlen>
  802624:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802628:	83 c3 01             	add    $0x1,%ebx
  80262b:	83 c4 10             	add    $0x10,%esp
  80262e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802635:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802638:	85 c0                	test   %eax,%eax
  80263a:	75 df                	jne    80261b <spawn+0xdb>
  80263c:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802642:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802648:	bf 00 10 40 00       	mov    $0x401000,%edi
  80264d:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80264f:	89 fa                	mov    %edi,%edx
  802651:	83 e2 fc             	and    $0xfffffffc,%edx
  802654:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80265b:	29 c2                	sub    %eax,%edx
  80265d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802663:	8d 42 f8             	lea    -0x8(%edx),%eax
  802666:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80266b:	0f 86 9a 03 00 00    	jbe    802a0b <spawn+0x4cb>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802671:	83 ec 04             	sub    $0x4,%esp
  802674:	6a 07                	push   $0x7
  802676:	68 00 00 40 00       	push   $0x400000
  80267b:	6a 00                	push   $0x0
  80267d:	e8 07 ef ff ff       	call   801589 <sys_page_alloc>
  802682:	83 c4 10             	add    $0x10,%esp
  802685:	85 c0                	test   %eax,%eax
  802687:	0f 88 85 03 00 00    	js     802a12 <spawn+0x4d2>
  80268d:	be 00 00 00 00       	mov    $0x0,%esi
  802692:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802698:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80269b:	eb 30                	jmp    8026cd <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80269d:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8026a3:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8026a9:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8026ac:	83 ec 08             	sub    $0x8,%esp
  8026af:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026b2:	57                   	push   %edi
  8026b3:	e8 ce ea ff ff       	call   801186 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8026b8:	83 c4 04             	add    $0x4,%esp
  8026bb:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026be:	e8 8a ea ff ff       	call   80114d <strlen>
  8026c3:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026c7:	83 c6 01             	add    $0x1,%esi
  8026ca:	83 c4 10             	add    $0x10,%esp
  8026cd:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8026d3:	7f c8                	jg     80269d <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8026d5:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8026db:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  8026e1:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026e8:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026ee:	74 19                	je     802709 <spawn+0x1c9>
  8026f0:	68 08 3f 80 00       	push   $0x803f08
  8026f5:	68 cf 38 80 00       	push   $0x8038cf
  8026fa:	68 f1 00 00 00       	push   $0xf1
  8026ff:	68 98 3e 80 00       	push   $0x803e98
  802704:	e8 0c e3 ff ff       	call   800a15 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802709:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80270f:	89 f8                	mov    %edi,%eax
  802711:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802716:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  802719:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80271f:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802722:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  802728:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80272e:	83 ec 0c             	sub    $0xc,%esp
  802731:	6a 07                	push   $0x7
  802733:	68 00 d0 bf ee       	push   $0xeebfd000
  802738:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80273e:	68 00 00 40 00       	push   $0x400000
  802743:	6a 00                	push   $0x0
  802745:	e8 82 ee ff ff       	call   8015cc <sys_page_map>
  80274a:	89 c3                	mov    %eax,%ebx
  80274c:	83 c4 20             	add    $0x20,%esp
  80274f:	85 c0                	test   %eax,%eax
  802751:	0f 88 24 03 00 00    	js     802a7b <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802757:	83 ec 08             	sub    $0x8,%esp
  80275a:	68 00 00 40 00       	push   $0x400000
  80275f:	6a 00                	push   $0x0
  802761:	e8 a8 ee ff ff       	call   80160e <sys_page_unmap>
  802766:	89 c3                	mov    %eax,%ebx
  802768:	83 c4 10             	add    $0x10,%esp
  80276b:	85 c0                	test   %eax,%eax
  80276d:	0f 88 08 03 00 00    	js     802a7b <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802773:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802779:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802780:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802786:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80278d:	00 00 00 
  802790:	e9 8a 01 00 00       	jmp    80291f <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  802795:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80279b:	83 38 01             	cmpl   $0x1,(%eax)
  80279e:	0f 85 6d 01 00 00    	jne    802911 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8027a4:	89 c7                	mov    %eax,%edi
  8027a6:	8b 40 18             	mov    0x18(%eax),%eax
  8027a9:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8027af:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8027b2:	83 f8 01             	cmp    $0x1,%eax
  8027b5:	19 c0                	sbb    %eax,%eax
  8027b7:	83 e0 fe             	and    $0xfffffffe,%eax
  8027ba:	83 c0 07             	add    $0x7,%eax
  8027bd:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8027c3:	89 f8                	mov    %edi,%eax
  8027c5:	8b 7f 04             	mov    0x4(%edi),%edi
  8027c8:	89 f9                	mov    %edi,%ecx
  8027ca:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8027d0:	8b 78 10             	mov    0x10(%eax),%edi
  8027d3:	8b 70 14             	mov    0x14(%eax),%esi
  8027d6:	89 f2                	mov    %esi,%edx
  8027d8:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8027de:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8027e1:	89 f0                	mov    %esi,%eax
  8027e3:	25 ff 0f 00 00       	and    $0xfff,%eax
  8027e8:	74 14                	je     8027fe <spawn+0x2be>
		va -= i;
  8027ea:	29 c6                	sub    %eax,%esi
		memsz += i;
  8027ec:	01 c2                	add    %eax,%edx
  8027ee:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8027f4:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8027f6:	29 c1                	sub    %eax,%ecx
  8027f8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  802803:	e9 f7 00 00 00       	jmp    8028ff <spawn+0x3bf>
		if (i >= filesz) {
  802808:	39 df                	cmp    %ebx,%edi
  80280a:	77 27                	ja     802833 <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80280c:	83 ec 04             	sub    $0x4,%esp
  80280f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802815:	56                   	push   %esi
  802816:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80281c:	e8 68 ed ff ff       	call   801589 <sys_page_alloc>
  802821:	83 c4 10             	add    $0x10,%esp
  802824:	85 c0                	test   %eax,%eax
  802826:	0f 89 c7 00 00 00    	jns    8028f3 <spawn+0x3b3>
  80282c:	89 c3                	mov    %eax,%ebx
  80282e:	e9 ed 01 00 00       	jmp    802a20 <spawn+0x4e0>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802833:	83 ec 04             	sub    $0x4,%esp
  802836:	6a 07                	push   $0x7
  802838:	68 00 00 40 00       	push   $0x400000
  80283d:	6a 00                	push   $0x0
  80283f:	e8 45 ed ff ff       	call   801589 <sys_page_alloc>
  802844:	83 c4 10             	add    $0x10,%esp
  802847:	85 c0                	test   %eax,%eax
  802849:	0f 88 c7 01 00 00    	js     802a16 <spawn+0x4d6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80284f:	83 ec 08             	sub    $0x8,%esp
  802852:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802858:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80285e:	50                   	push   %eax
  80285f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802865:	e8 f1 f7 ff ff       	call   80205b <seek>
  80286a:	83 c4 10             	add    $0x10,%esp
  80286d:	85 c0                	test   %eax,%eax
  80286f:	0f 88 a5 01 00 00    	js     802a1a <spawn+0x4da>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802875:	83 ec 04             	sub    $0x4,%esp
  802878:	89 f8                	mov    %edi,%eax
  80287a:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802880:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802885:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80288a:	0f 47 c1             	cmova  %ecx,%eax
  80288d:	50                   	push   %eax
  80288e:	68 00 00 40 00       	push   $0x400000
  802893:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802899:	e8 e8 f6 ff ff       	call   801f86 <readn>
  80289e:	83 c4 10             	add    $0x10,%esp
  8028a1:	85 c0                	test   %eax,%eax
  8028a3:	0f 88 75 01 00 00    	js     802a1e <spawn+0x4de>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8028a9:	83 ec 0c             	sub    $0xc,%esp
  8028ac:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8028b2:	56                   	push   %esi
  8028b3:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8028b9:	68 00 00 40 00       	push   $0x400000
  8028be:	6a 00                	push   $0x0
  8028c0:	e8 07 ed ff ff       	call   8015cc <sys_page_map>
  8028c5:	83 c4 20             	add    $0x20,%esp
  8028c8:	85 c0                	test   %eax,%eax
  8028ca:	79 15                	jns    8028e1 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  8028cc:	50                   	push   %eax
  8028cd:	68 a4 3e 80 00       	push   $0x803ea4
  8028d2:	68 24 01 00 00       	push   $0x124
  8028d7:	68 98 3e 80 00       	push   $0x803e98
  8028dc:	e8 34 e1 ff ff       	call   800a15 <_panic>
			sys_page_unmap(0, UTEMP);
  8028e1:	83 ec 08             	sub    $0x8,%esp
  8028e4:	68 00 00 40 00       	push   $0x400000
  8028e9:	6a 00                	push   $0x0
  8028eb:	e8 1e ed ff ff       	call   80160e <sys_page_unmap>
  8028f0:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028f3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028f9:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028ff:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802905:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  80290b:	0f 87 f7 fe ff ff    	ja     802808 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802911:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802918:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80291f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802926:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80292c:	0f 8c 63 fe ff ff    	jl     802795 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802932:	83 ec 0c             	sub    $0xc,%esp
  802935:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80293b:	e8 79 f4 ff ff       	call   801db9 <close>
  802940:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  802943:	bb 00 00 00 00       	mov    $0x0,%ebx
  802948:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  80294e:	89 d8                	mov    %ebx,%eax
  802950:	c1 e0 0c             	shl    $0xc,%eax
		if (((uvpd[PDX(pgnum*PGSIZE)] & PTE_P) && (uvpt[pgnum] & PTE_P) && (uvpt[pgnum] & PTE_SHARE))){
  802953:	89 c2                	mov    %eax,%edx
  802955:	c1 ea 16             	shr    $0x16,%edx
  802958:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80295f:	f6 c2 01             	test   $0x1,%dl
  802962:	74 35                	je     802999 <spawn+0x459>
  802964:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  80296b:	f6 c2 01             	test   $0x1,%dl
  80296e:	74 29                	je     802999 <spawn+0x459>
  802970:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  802977:	f6 c6 04             	test   $0x4,%dh
  80297a:	74 1d                	je     802999 <spawn+0x459>
			if((r=sys_page_map(0, (void *)(pgnum*PGSIZE), child, (void *)(pgnum*PGSIZE), PTE_SYSCALL))<0)
  80297c:	83 ec 0c             	sub    $0xc,%esp
  80297f:	68 07 0e 00 00       	push   $0xe07
  802984:	50                   	push   %eax
  802985:	56                   	push   %esi
  802986:	50                   	push   %eax
  802987:	6a 00                	push   $0x0
  802989:	e8 3e ec ff ff       	call   8015cc <sys_page_map>
  80298e:	83 c4 20             	add    $0x20,%esp
  802991:	85 c0                	test   %eax,%eax
  802993:	0f 88 a8 00 00 00    	js     802a41 <spawn+0x501>
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  802999:	83 c3 01             	add    $0x1,%ebx
  80299c:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  8029a2:	75 aa                	jne    80294e <spawn+0x40e>
  8029a4:	e9 ad 00 00 00       	jmp    802a56 <spawn+0x516>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8029a9:	50                   	push   %eax
  8029aa:	68 c1 3e 80 00       	push   $0x803ec1
  8029af:	68 85 00 00 00       	push   $0x85
  8029b4:	68 98 3e 80 00       	push   $0x803e98
  8029b9:	e8 57 e0 ff ff       	call   800a15 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029be:	83 ec 08             	sub    $0x8,%esp
  8029c1:	6a 02                	push   $0x2
  8029c3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029c9:	e8 82 ec ff ff       	call   801650 <sys_env_set_status>
  8029ce:	83 c4 10             	add    $0x10,%esp
  8029d1:	85 c0                	test   %eax,%eax
  8029d3:	79 2b                	jns    802a00 <spawn+0x4c0>
		panic("sys_env_set_status: %e", r);
  8029d5:	50                   	push   %eax
  8029d6:	68 db 3e 80 00       	push   $0x803edb
  8029db:	68 88 00 00 00       	push   $0x88
  8029e0:	68 98 3e 80 00       	push   $0x803e98
  8029e5:	e8 2b e0 ff ff       	call   800a15 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029ea:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8029f0:	e9 98 00 00 00       	jmp    802a8d <spawn+0x54d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8029f5:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029fb:	e9 8d 00 00 00       	jmp    802a8d <spawn+0x54d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802a00:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a06:	e9 82 00 00 00       	jmp    802a8d <spawn+0x54d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802a0b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802a10:	eb 7b                	jmp    802a8d <spawn+0x54d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802a12:	89 c3                	mov    %eax,%ebx
  802a14:	eb 77                	jmp    802a8d <spawn+0x54d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a16:	89 c3                	mov    %eax,%ebx
  802a18:	eb 06                	jmp    802a20 <spawn+0x4e0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a1a:	89 c3                	mov    %eax,%ebx
  802a1c:	eb 02                	jmp    802a20 <spawn+0x4e0>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a1e:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a20:	83 ec 0c             	sub    $0xc,%esp
  802a23:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a29:	e8 dc ea ff ff       	call   80150a <sys_env_destroy>
	close(fd);
  802a2e:	83 c4 04             	add    $0x4,%esp
  802a31:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a37:	e8 7d f3 ff ff       	call   801db9 <close>
	return r;
  802a3c:	83 c4 10             	add    $0x10,%esp
  802a3f:	eb 4c                	jmp    802a8d <spawn+0x54d>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802a41:	50                   	push   %eax
  802a42:	68 f2 3e 80 00       	push   $0x803ef2
  802a47:	68 82 00 00 00       	push   $0x82
  802a4c:	68 98 3e 80 00       	push   $0x803e98
  802a51:	e8 bf df ff ff       	call   800a15 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a56:	83 ec 08             	sub    $0x8,%esp
  802a59:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a5f:	50                   	push   %eax
  802a60:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a66:	e8 27 ec ff ff       	call   801692 <sys_env_set_trapframe>
  802a6b:	83 c4 10             	add    $0x10,%esp
  802a6e:	85 c0                	test   %eax,%eax
  802a70:	0f 89 48 ff ff ff    	jns    8029be <spawn+0x47e>
  802a76:	e9 2e ff ff ff       	jmp    8029a9 <spawn+0x469>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a7b:	83 ec 08             	sub    $0x8,%esp
  802a7e:	68 00 00 40 00       	push   $0x400000
  802a83:	6a 00                	push   $0x0
  802a85:	e8 84 eb ff ff       	call   80160e <sys_page_unmap>
  802a8a:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a8d:	89 d8                	mov    %ebx,%eax
  802a8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a92:	5b                   	pop    %ebx
  802a93:	5e                   	pop    %esi
  802a94:	5f                   	pop    %edi
  802a95:	5d                   	pop    %ebp
  802a96:	c3                   	ret    

00802a97 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a97:	55                   	push   %ebp
  802a98:	89 e5                	mov    %esp,%ebp
  802a9a:	56                   	push   %esi
  802a9b:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a9c:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a9f:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802aa4:	eb 03                	jmp    802aa9 <spawnl+0x12>
		argc++;
  802aa6:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802aa9:	83 c2 04             	add    $0x4,%edx
  802aac:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802ab0:	75 f4                	jne    802aa6 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802ab2:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802ab9:	83 e2 f0             	and    $0xfffffff0,%edx
  802abc:	29 d4                	sub    %edx,%esp
  802abe:	8d 54 24 03          	lea    0x3(%esp),%edx
  802ac2:	c1 ea 02             	shr    $0x2,%edx
  802ac5:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802acc:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802ace:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ad1:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802ad8:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802adf:	00 
  802ae0:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  802ae7:	eb 0a                	jmp    802af3 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802ae9:	83 c0 01             	add    $0x1,%eax
  802aec:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802af0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802af3:	39 d0                	cmp    %edx,%eax
  802af5:	75 f2                	jne    802ae9 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802af7:	83 ec 08             	sub    $0x8,%esp
  802afa:	56                   	push   %esi
  802afb:	ff 75 08             	pushl  0x8(%ebp)
  802afe:	e8 3d fa ff ff       	call   802540 <spawn>
}
  802b03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b06:	5b                   	pop    %ebx
  802b07:	5e                   	pop    %esi
  802b08:	5d                   	pop    %ebp
  802b09:	c3                   	ret    

00802b0a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802b0a:	55                   	push   %ebp
  802b0b:	89 e5                	mov    %esp,%ebp
  802b0d:	56                   	push   %esi
  802b0e:	53                   	push   %ebx
  802b0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802b12:	83 ec 0c             	sub    $0xc,%esp
  802b15:	ff 75 08             	pushl  0x8(%ebp)
  802b18:	e8 0c f1 ff ff       	call   801c29 <fd2data>
  802b1d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802b1f:	83 c4 08             	add    $0x8,%esp
  802b22:	68 30 3f 80 00       	push   $0x803f30
  802b27:	53                   	push   %ebx
  802b28:	e8 59 e6 ff ff       	call   801186 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802b2d:	8b 46 04             	mov    0x4(%esi),%eax
  802b30:	2b 06                	sub    (%esi),%eax
  802b32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802b38:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802b3f:	00 00 00 
	stat->st_dev = &devpipe;
  802b42:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802b49:	40 80 00 
	return 0;
}
  802b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  802b51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b54:	5b                   	pop    %ebx
  802b55:	5e                   	pop    %esi
  802b56:	5d                   	pop    %ebp
  802b57:	c3                   	ret    

00802b58 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b58:	55                   	push   %ebp
  802b59:	89 e5                	mov    %esp,%ebp
  802b5b:	53                   	push   %ebx
  802b5c:	83 ec 0c             	sub    $0xc,%esp
  802b5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b62:	53                   	push   %ebx
  802b63:	6a 00                	push   $0x0
  802b65:	e8 a4 ea ff ff       	call   80160e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b6a:	89 1c 24             	mov    %ebx,(%esp)
  802b6d:	e8 b7 f0 ff ff       	call   801c29 <fd2data>
  802b72:	83 c4 08             	add    $0x8,%esp
  802b75:	50                   	push   %eax
  802b76:	6a 00                	push   $0x0
  802b78:	e8 91 ea ff ff       	call   80160e <sys_page_unmap>
}
  802b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b80:	c9                   	leave  
  802b81:	c3                   	ret    

00802b82 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b82:	55                   	push   %ebp
  802b83:	89 e5                	mov    %esp,%ebp
  802b85:	57                   	push   %edi
  802b86:	56                   	push   %esi
  802b87:	53                   	push   %ebx
  802b88:	83 ec 1c             	sub    $0x1c,%esp
  802b8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802b8e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b90:	a1 28 54 80 00       	mov    0x805428,%eax
  802b95:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802b98:	83 ec 0c             	sub    $0xc,%esp
  802b9b:	ff 75 e0             	pushl  -0x20(%ebp)
  802b9e:	e8 0d 09 00 00       	call   8034b0 <pageref>
  802ba3:	89 c3                	mov    %eax,%ebx
  802ba5:	89 3c 24             	mov    %edi,(%esp)
  802ba8:	e8 03 09 00 00       	call   8034b0 <pageref>
  802bad:	83 c4 10             	add    $0x10,%esp
  802bb0:	39 c3                	cmp    %eax,%ebx
  802bb2:	0f 94 c1             	sete   %cl
  802bb5:	0f b6 c9             	movzbl %cl,%ecx
  802bb8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802bbb:	8b 15 28 54 80 00    	mov    0x805428,%edx
  802bc1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802bc4:	39 ce                	cmp    %ecx,%esi
  802bc6:	74 1b                	je     802be3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802bc8:	39 c3                	cmp    %eax,%ebx
  802bca:	75 c4                	jne    802b90 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802bcc:	8b 42 58             	mov    0x58(%edx),%eax
  802bcf:	ff 75 e4             	pushl  -0x1c(%ebp)
  802bd2:	50                   	push   %eax
  802bd3:	56                   	push   %esi
  802bd4:	68 37 3f 80 00       	push   $0x803f37
  802bd9:	e8 10 df ff ff       	call   800aee <cprintf>
  802bde:	83 c4 10             	add    $0x10,%esp
  802be1:	eb ad                	jmp    802b90 <_pipeisclosed+0xe>
	}
}
  802be3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802be9:	5b                   	pop    %ebx
  802bea:	5e                   	pop    %esi
  802beb:	5f                   	pop    %edi
  802bec:	5d                   	pop    %ebp
  802bed:	c3                   	ret    

00802bee <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802bee:	55                   	push   %ebp
  802bef:	89 e5                	mov    %esp,%ebp
  802bf1:	57                   	push   %edi
  802bf2:	56                   	push   %esi
  802bf3:	53                   	push   %ebx
  802bf4:	83 ec 28             	sub    $0x28,%esp
  802bf7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802bfa:	56                   	push   %esi
  802bfb:	e8 29 f0 ff ff       	call   801c29 <fd2data>
  802c00:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c02:	83 c4 10             	add    $0x10,%esp
  802c05:	bf 00 00 00 00       	mov    $0x0,%edi
  802c0a:	eb 4b                	jmp    802c57 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802c0c:	89 da                	mov    %ebx,%edx
  802c0e:	89 f0                	mov    %esi,%eax
  802c10:	e8 6d ff ff ff       	call   802b82 <_pipeisclosed>
  802c15:	85 c0                	test   %eax,%eax
  802c17:	75 48                	jne    802c61 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802c19:	e8 4c e9 ff ff       	call   80156a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c1e:	8b 43 04             	mov    0x4(%ebx),%eax
  802c21:	8b 0b                	mov    (%ebx),%ecx
  802c23:	8d 51 20             	lea    0x20(%ecx),%edx
  802c26:	39 d0                	cmp    %edx,%eax
  802c28:	73 e2                	jae    802c0c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c2d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802c31:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802c34:	89 c2                	mov    %eax,%edx
  802c36:	c1 fa 1f             	sar    $0x1f,%edx
  802c39:	89 d1                	mov    %edx,%ecx
  802c3b:	c1 e9 1b             	shr    $0x1b,%ecx
  802c3e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802c41:	83 e2 1f             	and    $0x1f,%edx
  802c44:	29 ca                	sub    %ecx,%edx
  802c46:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802c4a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c4e:	83 c0 01             	add    $0x1,%eax
  802c51:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c54:	83 c7 01             	add    $0x1,%edi
  802c57:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c5a:	75 c2                	jne    802c1e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  802c5f:	eb 05                	jmp    802c66 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c61:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c69:	5b                   	pop    %ebx
  802c6a:	5e                   	pop    %esi
  802c6b:	5f                   	pop    %edi
  802c6c:	5d                   	pop    %ebp
  802c6d:	c3                   	ret    

00802c6e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c6e:	55                   	push   %ebp
  802c6f:	89 e5                	mov    %esp,%ebp
  802c71:	57                   	push   %edi
  802c72:	56                   	push   %esi
  802c73:	53                   	push   %ebx
  802c74:	83 ec 18             	sub    $0x18,%esp
  802c77:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c7a:	57                   	push   %edi
  802c7b:	e8 a9 ef ff ff       	call   801c29 <fd2data>
  802c80:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c82:	83 c4 10             	add    $0x10,%esp
  802c85:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c8a:	eb 3d                	jmp    802cc9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c8c:	85 db                	test   %ebx,%ebx
  802c8e:	74 04                	je     802c94 <devpipe_read+0x26>
				return i;
  802c90:	89 d8                	mov    %ebx,%eax
  802c92:	eb 44                	jmp    802cd8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c94:	89 f2                	mov    %esi,%edx
  802c96:	89 f8                	mov    %edi,%eax
  802c98:	e8 e5 fe ff ff       	call   802b82 <_pipeisclosed>
  802c9d:	85 c0                	test   %eax,%eax
  802c9f:	75 32                	jne    802cd3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802ca1:	e8 c4 e8 ff ff       	call   80156a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802ca6:	8b 06                	mov    (%esi),%eax
  802ca8:	3b 46 04             	cmp    0x4(%esi),%eax
  802cab:	74 df                	je     802c8c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802cad:	99                   	cltd   
  802cae:	c1 ea 1b             	shr    $0x1b,%edx
  802cb1:	01 d0                	add    %edx,%eax
  802cb3:	83 e0 1f             	and    $0x1f,%eax
  802cb6:	29 d0                	sub    %edx,%eax
  802cb8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cc0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802cc3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802cc6:	83 c3 01             	add    $0x1,%ebx
  802cc9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802ccc:	75 d8                	jne    802ca6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802cce:	8b 45 10             	mov    0x10(%ebp),%eax
  802cd1:	eb 05                	jmp    802cd8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802cd3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cdb:	5b                   	pop    %ebx
  802cdc:	5e                   	pop    %esi
  802cdd:	5f                   	pop    %edi
  802cde:	5d                   	pop    %ebp
  802cdf:	c3                   	ret    

00802ce0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802ce0:	55                   	push   %ebp
  802ce1:	89 e5                	mov    %esp,%ebp
  802ce3:	56                   	push   %esi
  802ce4:	53                   	push   %ebx
  802ce5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ceb:	50                   	push   %eax
  802cec:	e8 4f ef ff ff       	call   801c40 <fd_alloc>
  802cf1:	83 c4 10             	add    $0x10,%esp
  802cf4:	89 c2                	mov    %eax,%edx
  802cf6:	85 c0                	test   %eax,%eax
  802cf8:	0f 88 2c 01 00 00    	js     802e2a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cfe:	83 ec 04             	sub    $0x4,%esp
  802d01:	68 07 04 00 00       	push   $0x407
  802d06:	ff 75 f4             	pushl  -0xc(%ebp)
  802d09:	6a 00                	push   $0x0
  802d0b:	e8 79 e8 ff ff       	call   801589 <sys_page_alloc>
  802d10:	83 c4 10             	add    $0x10,%esp
  802d13:	89 c2                	mov    %eax,%edx
  802d15:	85 c0                	test   %eax,%eax
  802d17:	0f 88 0d 01 00 00    	js     802e2a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802d1d:	83 ec 0c             	sub    $0xc,%esp
  802d20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d23:	50                   	push   %eax
  802d24:	e8 17 ef ff ff       	call   801c40 <fd_alloc>
  802d29:	89 c3                	mov    %eax,%ebx
  802d2b:	83 c4 10             	add    $0x10,%esp
  802d2e:	85 c0                	test   %eax,%eax
  802d30:	0f 88 e2 00 00 00    	js     802e18 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d36:	83 ec 04             	sub    $0x4,%esp
  802d39:	68 07 04 00 00       	push   $0x407
  802d3e:	ff 75 f0             	pushl  -0x10(%ebp)
  802d41:	6a 00                	push   $0x0
  802d43:	e8 41 e8 ff ff       	call   801589 <sys_page_alloc>
  802d48:	89 c3                	mov    %eax,%ebx
  802d4a:	83 c4 10             	add    $0x10,%esp
  802d4d:	85 c0                	test   %eax,%eax
  802d4f:	0f 88 c3 00 00 00    	js     802e18 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d55:	83 ec 0c             	sub    $0xc,%esp
  802d58:	ff 75 f4             	pushl  -0xc(%ebp)
  802d5b:	e8 c9 ee ff ff       	call   801c29 <fd2data>
  802d60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d62:	83 c4 0c             	add    $0xc,%esp
  802d65:	68 07 04 00 00       	push   $0x407
  802d6a:	50                   	push   %eax
  802d6b:	6a 00                	push   $0x0
  802d6d:	e8 17 e8 ff ff       	call   801589 <sys_page_alloc>
  802d72:	89 c3                	mov    %eax,%ebx
  802d74:	83 c4 10             	add    $0x10,%esp
  802d77:	85 c0                	test   %eax,%eax
  802d79:	0f 88 89 00 00 00    	js     802e08 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d7f:	83 ec 0c             	sub    $0xc,%esp
  802d82:	ff 75 f0             	pushl  -0x10(%ebp)
  802d85:	e8 9f ee ff ff       	call   801c29 <fd2data>
  802d8a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d91:	50                   	push   %eax
  802d92:	6a 00                	push   $0x0
  802d94:	56                   	push   %esi
  802d95:	6a 00                	push   $0x0
  802d97:	e8 30 e8 ff ff       	call   8015cc <sys_page_map>
  802d9c:	89 c3                	mov    %eax,%ebx
  802d9e:	83 c4 20             	add    $0x20,%esp
  802da1:	85 c0                	test   %eax,%eax
  802da3:	78 55                	js     802dfa <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802da5:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dae:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802db3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802dba:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dc3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dc8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802dcf:	83 ec 0c             	sub    $0xc,%esp
  802dd2:	ff 75 f4             	pushl  -0xc(%ebp)
  802dd5:	e8 3f ee ff ff       	call   801c19 <fd2num>
  802dda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ddd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802ddf:	83 c4 04             	add    $0x4,%esp
  802de2:	ff 75 f0             	pushl  -0x10(%ebp)
  802de5:	e8 2f ee ff ff       	call   801c19 <fd2num>
  802dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ded:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802df0:	83 c4 10             	add    $0x10,%esp
  802df3:	ba 00 00 00 00       	mov    $0x0,%edx
  802df8:	eb 30                	jmp    802e2a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802dfa:	83 ec 08             	sub    $0x8,%esp
  802dfd:	56                   	push   %esi
  802dfe:	6a 00                	push   $0x0
  802e00:	e8 09 e8 ff ff       	call   80160e <sys_page_unmap>
  802e05:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802e08:	83 ec 08             	sub    $0x8,%esp
  802e0b:	ff 75 f0             	pushl  -0x10(%ebp)
  802e0e:	6a 00                	push   $0x0
  802e10:	e8 f9 e7 ff ff       	call   80160e <sys_page_unmap>
  802e15:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802e18:	83 ec 08             	sub    $0x8,%esp
  802e1b:	ff 75 f4             	pushl  -0xc(%ebp)
  802e1e:	6a 00                	push   $0x0
  802e20:	e8 e9 e7 ff ff       	call   80160e <sys_page_unmap>
  802e25:	83 c4 10             	add    $0x10,%esp
  802e28:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802e2a:	89 d0                	mov    %edx,%eax
  802e2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e2f:	5b                   	pop    %ebx
  802e30:	5e                   	pop    %esi
  802e31:	5d                   	pop    %ebp
  802e32:	c3                   	ret    

00802e33 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e33:	55                   	push   %ebp
  802e34:	89 e5                	mov    %esp,%ebp
  802e36:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e3c:	50                   	push   %eax
  802e3d:	ff 75 08             	pushl  0x8(%ebp)
  802e40:	e8 4a ee ff ff       	call   801c8f <fd_lookup>
  802e45:	83 c4 10             	add    $0x10,%esp
  802e48:	85 c0                	test   %eax,%eax
  802e4a:	78 18                	js     802e64 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e4c:	83 ec 0c             	sub    $0xc,%esp
  802e4f:	ff 75 f4             	pushl  -0xc(%ebp)
  802e52:	e8 d2 ed ff ff       	call   801c29 <fd2data>
	return _pipeisclosed(fd, p);
  802e57:	89 c2                	mov    %eax,%edx
  802e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e5c:	e8 21 fd ff ff       	call   802b82 <_pipeisclosed>
  802e61:	83 c4 10             	add    $0x10,%esp
}
  802e64:	c9                   	leave  
  802e65:	c3                   	ret    

00802e66 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e66:	55                   	push   %ebp
  802e67:	89 e5                	mov    %esp,%ebp
  802e69:	56                   	push   %esi
  802e6a:	53                   	push   %ebx
  802e6b:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e6e:	85 f6                	test   %esi,%esi
  802e70:	75 16                	jne    802e88 <wait+0x22>
  802e72:	68 4f 3f 80 00       	push   $0x803f4f
  802e77:	68 cf 38 80 00       	push   $0x8038cf
  802e7c:	6a 09                	push   $0x9
  802e7e:	68 5a 3f 80 00       	push   $0x803f5a
  802e83:	e8 8d db ff ff       	call   800a15 <_panic>
	e = &envs[ENVX(envid)];
  802e88:	89 f3                	mov    %esi,%ebx
  802e8a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e90:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802e93:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802e99:	eb 05                	jmp    802ea0 <wait+0x3a>
		sys_yield();
  802e9b:	e8 ca e6 ff ff       	call   80156a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ea0:	8b 43 48             	mov    0x48(%ebx),%eax
  802ea3:	39 c6                	cmp    %eax,%esi
  802ea5:	75 07                	jne    802eae <wait+0x48>
  802ea7:	8b 43 54             	mov    0x54(%ebx),%eax
  802eaa:	85 c0                	test   %eax,%eax
  802eac:	75 ed                	jne    802e9b <wait+0x35>
		sys_yield();
}
  802eae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802eb1:	5b                   	pop    %ebx
  802eb2:	5e                   	pop    %esi
  802eb3:	5d                   	pop    %ebp
  802eb4:	c3                   	ret    

00802eb5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802eb5:	55                   	push   %ebp
  802eb6:	89 e5                	mov    %esp,%ebp
  802eb8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802ebb:	68 65 3f 80 00       	push   $0x803f65
  802ec0:	ff 75 0c             	pushl  0xc(%ebp)
  802ec3:	e8 be e2 ff ff       	call   801186 <strcpy>
	return 0;
}
  802ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  802ecd:	c9                   	leave  
  802ece:	c3                   	ret    

00802ecf <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802ecf:	55                   	push   %ebp
  802ed0:	89 e5                	mov    %esp,%ebp
  802ed2:	53                   	push   %ebx
  802ed3:	83 ec 10             	sub    $0x10,%esp
  802ed6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802ed9:	53                   	push   %ebx
  802eda:	e8 d1 05 00 00       	call   8034b0 <pageref>
  802edf:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802ee2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802ee7:	83 f8 01             	cmp    $0x1,%eax
  802eea:	75 10                	jne    802efc <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802eec:	83 ec 0c             	sub    $0xc,%esp
  802eef:	ff 73 0c             	pushl  0xc(%ebx)
  802ef2:	e8 c0 02 00 00       	call   8031b7 <nsipc_close>
  802ef7:	89 c2                	mov    %eax,%edx
  802ef9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802efc:	89 d0                	mov    %edx,%eax
  802efe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f01:	c9                   	leave  
  802f02:	c3                   	ret    

00802f03 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802f03:	55                   	push   %ebp
  802f04:	89 e5                	mov    %esp,%ebp
  802f06:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802f09:	6a 00                	push   $0x0
  802f0b:	ff 75 10             	pushl  0x10(%ebp)
  802f0e:	ff 75 0c             	pushl  0xc(%ebp)
  802f11:	8b 45 08             	mov    0x8(%ebp),%eax
  802f14:	ff 70 0c             	pushl  0xc(%eax)
  802f17:	e8 78 03 00 00       	call   803294 <nsipc_send>
}
  802f1c:	c9                   	leave  
  802f1d:	c3                   	ret    

00802f1e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802f1e:	55                   	push   %ebp
  802f1f:	89 e5                	mov    %esp,%ebp
  802f21:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802f24:	6a 00                	push   $0x0
  802f26:	ff 75 10             	pushl  0x10(%ebp)
  802f29:	ff 75 0c             	pushl  0xc(%ebp)
  802f2c:	8b 45 08             	mov    0x8(%ebp),%eax
  802f2f:	ff 70 0c             	pushl  0xc(%eax)
  802f32:	e8 f1 02 00 00       	call   803228 <nsipc_recv>
}
  802f37:	c9                   	leave  
  802f38:	c3                   	ret    

00802f39 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802f39:	55                   	push   %ebp
  802f3a:	89 e5                	mov    %esp,%ebp
  802f3c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802f3f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802f42:	52                   	push   %edx
  802f43:	50                   	push   %eax
  802f44:	e8 46 ed ff ff       	call   801c8f <fd_lookup>
  802f49:	83 c4 10             	add    $0x10,%esp
  802f4c:	85 c0                	test   %eax,%eax
  802f4e:	78 17                	js     802f67 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f53:	8b 0d 58 40 80 00    	mov    0x804058,%ecx
  802f59:	39 08                	cmp    %ecx,(%eax)
  802f5b:	75 05                	jne    802f62 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802f5d:	8b 40 0c             	mov    0xc(%eax),%eax
  802f60:	eb 05                	jmp    802f67 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802f62:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802f67:	c9                   	leave  
  802f68:	c3                   	ret    

00802f69 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802f69:	55                   	push   %ebp
  802f6a:	89 e5                	mov    %esp,%ebp
  802f6c:	56                   	push   %esi
  802f6d:	53                   	push   %ebx
  802f6e:	83 ec 1c             	sub    $0x1c,%esp
  802f71:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802f73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f76:	50                   	push   %eax
  802f77:	e8 c4 ec ff ff       	call   801c40 <fd_alloc>
  802f7c:	89 c3                	mov    %eax,%ebx
  802f7e:	83 c4 10             	add    $0x10,%esp
  802f81:	85 c0                	test   %eax,%eax
  802f83:	78 1b                	js     802fa0 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802f85:	83 ec 04             	sub    $0x4,%esp
  802f88:	68 07 04 00 00       	push   $0x407
  802f8d:	ff 75 f4             	pushl  -0xc(%ebp)
  802f90:	6a 00                	push   $0x0
  802f92:	e8 f2 e5 ff ff       	call   801589 <sys_page_alloc>
  802f97:	89 c3                	mov    %eax,%ebx
  802f99:	83 c4 10             	add    $0x10,%esp
  802f9c:	85 c0                	test   %eax,%eax
  802f9e:	79 10                	jns    802fb0 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802fa0:	83 ec 0c             	sub    $0xc,%esp
  802fa3:	56                   	push   %esi
  802fa4:	e8 0e 02 00 00       	call   8031b7 <nsipc_close>
		return r;
  802fa9:	83 c4 10             	add    $0x10,%esp
  802fac:	89 d8                	mov    %ebx,%eax
  802fae:	eb 24                	jmp    802fd4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802fb0:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fb9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fbe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802fc5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802fc8:	83 ec 0c             	sub    $0xc,%esp
  802fcb:	50                   	push   %eax
  802fcc:	e8 48 ec ff ff       	call   801c19 <fd2num>
  802fd1:	83 c4 10             	add    $0x10,%esp
}
  802fd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fd7:	5b                   	pop    %ebx
  802fd8:	5e                   	pop    %esi
  802fd9:	5d                   	pop    %ebp
  802fda:	c3                   	ret    

00802fdb <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802fdb:	55                   	push   %ebp
  802fdc:	89 e5                	mov    %esp,%ebp
  802fde:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  802fe4:	e8 50 ff ff ff       	call   802f39 <fd2sockid>
		return r;
  802fe9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802feb:	85 c0                	test   %eax,%eax
  802fed:	78 1f                	js     80300e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802fef:	83 ec 04             	sub    $0x4,%esp
  802ff2:	ff 75 10             	pushl  0x10(%ebp)
  802ff5:	ff 75 0c             	pushl  0xc(%ebp)
  802ff8:	50                   	push   %eax
  802ff9:	e8 12 01 00 00       	call   803110 <nsipc_accept>
  802ffe:	83 c4 10             	add    $0x10,%esp
		return r;
  803001:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  803003:	85 c0                	test   %eax,%eax
  803005:	78 07                	js     80300e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  803007:	e8 5d ff ff ff       	call   802f69 <alloc_sockfd>
  80300c:	89 c1                	mov    %eax,%ecx
}
  80300e:	89 c8                	mov    %ecx,%eax
  803010:	c9                   	leave  
  803011:	c3                   	ret    

00803012 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803012:	55                   	push   %ebp
  803013:	89 e5                	mov    %esp,%ebp
  803015:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803018:	8b 45 08             	mov    0x8(%ebp),%eax
  80301b:	e8 19 ff ff ff       	call   802f39 <fd2sockid>
  803020:	85 c0                	test   %eax,%eax
  803022:	78 12                	js     803036 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  803024:	83 ec 04             	sub    $0x4,%esp
  803027:	ff 75 10             	pushl  0x10(%ebp)
  80302a:	ff 75 0c             	pushl  0xc(%ebp)
  80302d:	50                   	push   %eax
  80302e:	e8 2d 01 00 00       	call   803160 <nsipc_bind>
  803033:	83 c4 10             	add    $0x10,%esp
}
  803036:	c9                   	leave  
  803037:	c3                   	ret    

00803038 <shutdown>:

int
shutdown(int s, int how)
{
  803038:	55                   	push   %ebp
  803039:	89 e5                	mov    %esp,%ebp
  80303b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80303e:	8b 45 08             	mov    0x8(%ebp),%eax
  803041:	e8 f3 fe ff ff       	call   802f39 <fd2sockid>
  803046:	85 c0                	test   %eax,%eax
  803048:	78 0f                	js     803059 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80304a:	83 ec 08             	sub    $0x8,%esp
  80304d:	ff 75 0c             	pushl  0xc(%ebp)
  803050:	50                   	push   %eax
  803051:	e8 3f 01 00 00       	call   803195 <nsipc_shutdown>
  803056:	83 c4 10             	add    $0x10,%esp
}
  803059:	c9                   	leave  
  80305a:	c3                   	ret    

0080305b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80305b:	55                   	push   %ebp
  80305c:	89 e5                	mov    %esp,%ebp
  80305e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803061:	8b 45 08             	mov    0x8(%ebp),%eax
  803064:	e8 d0 fe ff ff       	call   802f39 <fd2sockid>
  803069:	85 c0                	test   %eax,%eax
  80306b:	78 12                	js     80307f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80306d:	83 ec 04             	sub    $0x4,%esp
  803070:	ff 75 10             	pushl  0x10(%ebp)
  803073:	ff 75 0c             	pushl  0xc(%ebp)
  803076:	50                   	push   %eax
  803077:	e8 55 01 00 00       	call   8031d1 <nsipc_connect>
  80307c:	83 c4 10             	add    $0x10,%esp
}
  80307f:	c9                   	leave  
  803080:	c3                   	ret    

00803081 <listen>:

int
listen(int s, int backlog)
{
  803081:	55                   	push   %ebp
  803082:	89 e5                	mov    %esp,%ebp
  803084:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803087:	8b 45 08             	mov    0x8(%ebp),%eax
  80308a:	e8 aa fe ff ff       	call   802f39 <fd2sockid>
  80308f:	85 c0                	test   %eax,%eax
  803091:	78 0f                	js     8030a2 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  803093:	83 ec 08             	sub    $0x8,%esp
  803096:	ff 75 0c             	pushl  0xc(%ebp)
  803099:	50                   	push   %eax
  80309a:	e8 67 01 00 00       	call   803206 <nsipc_listen>
  80309f:	83 c4 10             	add    $0x10,%esp
}
  8030a2:	c9                   	leave  
  8030a3:	c3                   	ret    

008030a4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8030a4:	55                   	push   %ebp
  8030a5:	89 e5                	mov    %esp,%ebp
  8030a7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8030aa:	ff 75 10             	pushl  0x10(%ebp)
  8030ad:	ff 75 0c             	pushl  0xc(%ebp)
  8030b0:	ff 75 08             	pushl  0x8(%ebp)
  8030b3:	e8 3a 02 00 00       	call   8032f2 <nsipc_socket>
  8030b8:	83 c4 10             	add    $0x10,%esp
  8030bb:	85 c0                	test   %eax,%eax
  8030bd:	78 05                	js     8030c4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8030bf:	e8 a5 fe ff ff       	call   802f69 <alloc_sockfd>
}
  8030c4:	c9                   	leave  
  8030c5:	c3                   	ret    

008030c6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8030c6:	55                   	push   %ebp
  8030c7:	89 e5                	mov    %esp,%ebp
  8030c9:	53                   	push   %ebx
  8030ca:	83 ec 04             	sub    $0x4,%esp
  8030cd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8030cf:	83 3d 24 54 80 00 00 	cmpl   $0x0,0x805424
  8030d6:	75 12                	jne    8030ea <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8030d8:	83 ec 0c             	sub    $0xc,%esp
  8030db:	6a 02                	push   $0x2
  8030dd:	e8 95 03 00 00       	call   803477 <ipc_find_env>
  8030e2:	a3 24 54 80 00       	mov    %eax,0x805424
  8030e7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8030ea:	6a 07                	push   $0x7
  8030ec:	68 00 70 80 00       	push   $0x807000
  8030f1:	53                   	push   %ebx
  8030f2:	ff 35 24 54 80 00    	pushl  0x805424
  8030f8:	e8 2b 03 00 00       	call   803428 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8030fd:	83 c4 0c             	add    $0xc,%esp
  803100:	6a 00                	push   $0x0
  803102:	6a 00                	push   $0x0
  803104:	6a 00                	push   $0x0
  803106:	e8 a7 02 00 00       	call   8033b2 <ipc_recv>
}
  80310b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80310e:	c9                   	leave  
  80310f:	c3                   	ret    

00803110 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803110:	55                   	push   %ebp
  803111:	89 e5                	mov    %esp,%ebp
  803113:	56                   	push   %esi
  803114:	53                   	push   %ebx
  803115:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  803118:	8b 45 08             	mov    0x8(%ebp),%eax
  80311b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  803120:	8b 06                	mov    (%esi),%eax
  803122:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803127:	b8 01 00 00 00       	mov    $0x1,%eax
  80312c:	e8 95 ff ff ff       	call   8030c6 <nsipc>
  803131:	89 c3                	mov    %eax,%ebx
  803133:	85 c0                	test   %eax,%eax
  803135:	78 20                	js     803157 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  803137:	83 ec 04             	sub    $0x4,%esp
  80313a:	ff 35 10 70 80 00    	pushl  0x807010
  803140:	68 00 70 80 00       	push   $0x807000
  803145:	ff 75 0c             	pushl  0xc(%ebp)
  803148:	e8 cb e1 ff ff       	call   801318 <memmove>
		*addrlen = ret->ret_addrlen;
  80314d:	a1 10 70 80 00       	mov    0x807010,%eax
  803152:	89 06                	mov    %eax,(%esi)
  803154:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  803157:	89 d8                	mov    %ebx,%eax
  803159:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80315c:	5b                   	pop    %ebx
  80315d:	5e                   	pop    %esi
  80315e:	5d                   	pop    %ebp
  80315f:	c3                   	ret    

00803160 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803160:	55                   	push   %ebp
  803161:	89 e5                	mov    %esp,%ebp
  803163:	53                   	push   %ebx
  803164:	83 ec 08             	sub    $0x8,%esp
  803167:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80316a:	8b 45 08             	mov    0x8(%ebp),%eax
  80316d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  803172:	53                   	push   %ebx
  803173:	ff 75 0c             	pushl  0xc(%ebp)
  803176:	68 04 70 80 00       	push   $0x807004
  80317b:	e8 98 e1 ff ff       	call   801318 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  803180:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  803186:	b8 02 00 00 00       	mov    $0x2,%eax
  80318b:	e8 36 ff ff ff       	call   8030c6 <nsipc>
}
  803190:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803193:	c9                   	leave  
  803194:	c3                   	ret    

00803195 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  803195:	55                   	push   %ebp
  803196:	89 e5                	mov    %esp,%ebp
  803198:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80319b:	8b 45 08             	mov    0x8(%ebp),%eax
  80319e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8031a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031a6:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8031ab:	b8 03 00 00 00       	mov    $0x3,%eax
  8031b0:	e8 11 ff ff ff       	call   8030c6 <nsipc>
}
  8031b5:	c9                   	leave  
  8031b6:	c3                   	ret    

008031b7 <nsipc_close>:

int
nsipc_close(int s)
{
  8031b7:	55                   	push   %ebp
  8031b8:	89 e5                	mov    %esp,%ebp
  8031ba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8031bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8031c0:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8031c5:	b8 04 00 00 00       	mov    $0x4,%eax
  8031ca:	e8 f7 fe ff ff       	call   8030c6 <nsipc>
}
  8031cf:	c9                   	leave  
  8031d0:	c3                   	ret    

008031d1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8031d1:	55                   	push   %ebp
  8031d2:	89 e5                	mov    %esp,%ebp
  8031d4:	53                   	push   %ebx
  8031d5:	83 ec 08             	sub    $0x8,%esp
  8031d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8031db:	8b 45 08             	mov    0x8(%ebp),%eax
  8031de:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8031e3:	53                   	push   %ebx
  8031e4:	ff 75 0c             	pushl  0xc(%ebp)
  8031e7:	68 04 70 80 00       	push   $0x807004
  8031ec:	e8 27 e1 ff ff       	call   801318 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8031f1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8031f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8031fc:	e8 c5 fe ff ff       	call   8030c6 <nsipc>
}
  803201:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803204:	c9                   	leave  
  803205:	c3                   	ret    

00803206 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  803206:	55                   	push   %ebp
  803207:	89 e5                	mov    %esp,%ebp
  803209:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80320c:	8b 45 08             	mov    0x8(%ebp),%eax
  80320f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  803214:	8b 45 0c             	mov    0xc(%ebp),%eax
  803217:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80321c:	b8 06 00 00 00       	mov    $0x6,%eax
  803221:	e8 a0 fe ff ff       	call   8030c6 <nsipc>
}
  803226:	c9                   	leave  
  803227:	c3                   	ret    

00803228 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  803228:	55                   	push   %ebp
  803229:	89 e5                	mov    %esp,%ebp
  80322b:	56                   	push   %esi
  80322c:	53                   	push   %ebx
  80322d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  803230:	8b 45 08             	mov    0x8(%ebp),%eax
  803233:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  803238:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80323e:	8b 45 14             	mov    0x14(%ebp),%eax
  803241:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  803246:	b8 07 00 00 00       	mov    $0x7,%eax
  80324b:	e8 76 fe ff ff       	call   8030c6 <nsipc>
  803250:	89 c3                	mov    %eax,%ebx
  803252:	85 c0                	test   %eax,%eax
  803254:	78 35                	js     80328b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  803256:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80325b:	7f 04                	jg     803261 <nsipc_recv+0x39>
  80325d:	39 c6                	cmp    %eax,%esi
  80325f:	7d 16                	jge    803277 <nsipc_recv+0x4f>
  803261:	68 71 3f 80 00       	push   $0x803f71
  803266:	68 cf 38 80 00       	push   $0x8038cf
  80326b:	6a 62                	push   $0x62
  80326d:	68 86 3f 80 00       	push   $0x803f86
  803272:	e8 9e d7 ff ff       	call   800a15 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  803277:	83 ec 04             	sub    $0x4,%esp
  80327a:	50                   	push   %eax
  80327b:	68 00 70 80 00       	push   $0x807000
  803280:	ff 75 0c             	pushl  0xc(%ebp)
  803283:	e8 90 e0 ff ff       	call   801318 <memmove>
  803288:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80328b:	89 d8                	mov    %ebx,%eax
  80328d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803290:	5b                   	pop    %ebx
  803291:	5e                   	pop    %esi
  803292:	5d                   	pop    %ebp
  803293:	c3                   	ret    

00803294 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  803294:	55                   	push   %ebp
  803295:	89 e5                	mov    %esp,%ebp
  803297:	53                   	push   %ebx
  803298:	83 ec 04             	sub    $0x4,%esp
  80329b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80329e:	8b 45 08             	mov    0x8(%ebp),%eax
  8032a1:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8032a6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8032ac:	7e 16                	jle    8032c4 <nsipc_send+0x30>
  8032ae:	68 92 3f 80 00       	push   $0x803f92
  8032b3:	68 cf 38 80 00       	push   $0x8038cf
  8032b8:	6a 6d                	push   $0x6d
  8032ba:	68 86 3f 80 00       	push   $0x803f86
  8032bf:	e8 51 d7 ff ff       	call   800a15 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8032c4:	83 ec 04             	sub    $0x4,%esp
  8032c7:	53                   	push   %ebx
  8032c8:	ff 75 0c             	pushl  0xc(%ebp)
  8032cb:	68 0c 70 80 00       	push   $0x80700c
  8032d0:	e8 43 e0 ff ff       	call   801318 <memmove>
	nsipcbuf.send.req_size = size;
  8032d5:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8032db:	8b 45 14             	mov    0x14(%ebp),%eax
  8032de:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8032e3:	b8 08 00 00 00       	mov    $0x8,%eax
  8032e8:	e8 d9 fd ff ff       	call   8030c6 <nsipc>
}
  8032ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8032f0:	c9                   	leave  
  8032f1:	c3                   	ret    

008032f2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8032f2:	55                   	push   %ebp
  8032f3:	89 e5                	mov    %esp,%ebp
  8032f5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8032f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8032fb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  803300:	8b 45 0c             	mov    0xc(%ebp),%eax
  803303:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  803308:	8b 45 10             	mov    0x10(%ebp),%eax
  80330b:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  803310:	b8 09 00 00 00       	mov    $0x9,%eax
  803315:	e8 ac fd ff ff       	call   8030c6 <nsipc>
}
  80331a:	c9                   	leave  
  80331b:	c3                   	ret    

0080331c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80331c:	55                   	push   %ebp
  80331d:	89 e5                	mov    %esp,%ebp
  80331f:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  803322:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  803329:	75 56                	jne    803381 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80332b:	83 ec 04             	sub    $0x4,%esp
  80332e:	6a 07                	push   $0x7
  803330:	68 00 f0 bf ee       	push   $0xeebff000
  803335:	6a 00                	push   $0x0
  803337:	e8 4d e2 ff ff       	call   801589 <sys_page_alloc>
  80333c:	83 c4 10             	add    $0x10,%esp
  80333f:	85 c0                	test   %eax,%eax
  803341:	74 14                	je     803357 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  803343:	83 ec 04             	sub    $0x4,%esp
  803346:	68 79 3d 80 00       	push   $0x803d79
  80334b:	6a 21                	push   $0x21
  80334d:	68 9e 3f 80 00       	push   $0x803f9e
  803352:	e8 be d6 ff ff       	call   800a15 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  803357:	83 ec 08             	sub    $0x8,%esp
  80335a:	68 8b 33 80 00       	push   $0x80338b
  80335f:	6a 00                	push   $0x0
  803361:	e8 6e e3 ff ff       	call   8016d4 <sys_env_set_pgfault_upcall>
  803366:	83 c4 10             	add    $0x10,%esp
  803369:	85 c0                	test   %eax,%eax
  80336b:	74 14                	je     803381 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  80336d:	83 ec 04             	sub    $0x4,%esp
  803370:	68 ac 3f 80 00       	push   $0x803fac
  803375:	6a 23                	push   $0x23
  803377:	68 9e 3f 80 00       	push   $0x803f9e
  80337c:	e8 94 d6 ff ff       	call   800a15 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803381:	8b 45 08             	mov    0x8(%ebp),%eax
  803384:	a3 00 80 80 00       	mov    %eax,0x808000
}
  803389:	c9                   	leave  
  80338a:	c3                   	ret    

0080338b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80338b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80338c:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  803391:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803393:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  803396:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  803398:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  80339c:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8033a0:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  8033a1:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  8033a3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  8033a8:	83 c4 08             	add    $0x8,%esp
	popal
  8033ab:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8033ac:	83 c4 04             	add    $0x4,%esp
	popfl
  8033af:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8033b0:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8033b1:	c3                   	ret    

008033b2 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8033b2:	55                   	push   %ebp
  8033b3:	89 e5                	mov    %esp,%ebp
  8033b5:	56                   	push   %esi
  8033b6:	53                   	push   %ebx
  8033b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8033ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8033c0:	85 c0                	test   %eax,%eax
  8033c2:	74 0e                	je     8033d2 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8033c4:	83 ec 0c             	sub    $0xc,%esp
  8033c7:	50                   	push   %eax
  8033c8:	e8 6c e3 ff ff       	call   801739 <sys_ipc_recv>
  8033cd:	83 c4 10             	add    $0x10,%esp
  8033d0:	eb 10                	jmp    8033e2 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  8033d2:	83 ec 0c             	sub    $0xc,%esp
  8033d5:	68 00 00 c0 ee       	push   $0xeec00000
  8033da:	e8 5a e3 ff ff       	call   801739 <sys_ipc_recv>
  8033df:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8033e2:	85 c0                	test   %eax,%eax
  8033e4:	79 17                	jns    8033fd <ipc_recv+0x4b>
		if(*from_env_store)
  8033e6:	83 3e 00             	cmpl   $0x0,(%esi)
  8033e9:	74 06                	je     8033f1 <ipc_recv+0x3f>
			*from_env_store = 0;
  8033eb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8033f1:	85 db                	test   %ebx,%ebx
  8033f3:	74 2c                	je     803421 <ipc_recv+0x6f>
			*perm_store = 0;
  8033f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8033fb:	eb 24                	jmp    803421 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  8033fd:	85 f6                	test   %esi,%esi
  8033ff:	74 0a                	je     80340b <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  803401:	a1 28 54 80 00       	mov    0x805428,%eax
  803406:	8b 40 74             	mov    0x74(%eax),%eax
  803409:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80340b:	85 db                	test   %ebx,%ebx
  80340d:	74 0a                	je     803419 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  80340f:	a1 28 54 80 00       	mov    0x805428,%eax
  803414:	8b 40 78             	mov    0x78(%eax),%eax
  803417:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  803419:	a1 28 54 80 00       	mov    0x805428,%eax
  80341e:	8b 40 70             	mov    0x70(%eax),%eax
}
  803421:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803424:	5b                   	pop    %ebx
  803425:	5e                   	pop    %esi
  803426:	5d                   	pop    %ebp
  803427:	c3                   	ret    

00803428 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803428:	55                   	push   %ebp
  803429:	89 e5                	mov    %esp,%ebp
  80342b:	57                   	push   %edi
  80342c:	56                   	push   %esi
  80342d:	53                   	push   %ebx
  80342e:	83 ec 0c             	sub    $0xc,%esp
  803431:	8b 7d 08             	mov    0x8(%ebp),%edi
  803434:	8b 75 0c             	mov    0xc(%ebp),%esi
  803437:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80343a:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80343c:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  803441:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  803444:	e8 21 e1 ff ff       	call   80156a <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  803449:	ff 75 14             	pushl  0x14(%ebp)
  80344c:	53                   	push   %ebx
  80344d:	56                   	push   %esi
  80344e:	57                   	push   %edi
  80344f:	e8 c2 e2 ff ff       	call   801716 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  803454:	89 c2                	mov    %eax,%edx
  803456:	f7 d2                	not    %edx
  803458:	c1 ea 1f             	shr    $0x1f,%edx
  80345b:	83 c4 10             	add    $0x10,%esp
  80345e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803461:	0f 94 c1             	sete   %cl
  803464:	09 ca                	or     %ecx,%edx
  803466:	85 c0                	test   %eax,%eax
  803468:	0f 94 c0             	sete   %al
  80346b:	38 c2                	cmp    %al,%dl
  80346d:	77 d5                	ja     803444 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  80346f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803472:	5b                   	pop    %ebx
  803473:	5e                   	pop    %esi
  803474:	5f                   	pop    %edi
  803475:	5d                   	pop    %ebp
  803476:	c3                   	ret    

00803477 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803477:	55                   	push   %ebp
  803478:	89 e5                	mov    %esp,%ebp
  80347a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80347d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803482:	6b d0 7c             	imul   $0x7c,%eax,%edx
  803485:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80348b:	8b 52 50             	mov    0x50(%edx),%edx
  80348e:	39 ca                	cmp    %ecx,%edx
  803490:	75 0d                	jne    80349f <ipc_find_env+0x28>
			return envs[i].env_id;
  803492:	6b c0 7c             	imul   $0x7c,%eax,%eax
  803495:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80349a:	8b 40 48             	mov    0x48(%eax),%eax
  80349d:	eb 0f                	jmp    8034ae <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80349f:	83 c0 01             	add    $0x1,%eax
  8034a2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8034a7:	75 d9                	jne    803482 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8034a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8034ae:	5d                   	pop    %ebp
  8034af:	c3                   	ret    

008034b0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8034b0:	55                   	push   %ebp
  8034b1:	89 e5                	mov    %esp,%ebp
  8034b3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8034b6:	89 d0                	mov    %edx,%eax
  8034b8:	c1 e8 16             	shr    $0x16,%eax
  8034bb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8034c2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8034c7:	f6 c1 01             	test   $0x1,%cl
  8034ca:	74 1d                	je     8034e9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8034cc:	c1 ea 0c             	shr    $0xc,%edx
  8034cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8034d6:	f6 c2 01             	test   $0x1,%dl
  8034d9:	74 0e                	je     8034e9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8034db:	c1 ea 0c             	shr    $0xc,%edx
  8034de:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8034e5:	ef 
  8034e6:	0f b7 c0             	movzwl %ax,%eax
}
  8034e9:	5d                   	pop    %ebp
  8034ea:	c3                   	ret    
  8034eb:	66 90                	xchg   %ax,%ax
  8034ed:	66 90                	xchg   %ax,%ax
  8034ef:	90                   	nop

008034f0 <__udivdi3>:
  8034f0:	55                   	push   %ebp
  8034f1:	57                   	push   %edi
  8034f2:	56                   	push   %esi
  8034f3:	53                   	push   %ebx
  8034f4:	83 ec 1c             	sub    $0x1c,%esp
  8034f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8034fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8034ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803503:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803507:	85 f6                	test   %esi,%esi
  803509:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80350d:	89 ca                	mov    %ecx,%edx
  80350f:	89 f8                	mov    %edi,%eax
  803511:	75 3d                	jne    803550 <__udivdi3+0x60>
  803513:	39 cf                	cmp    %ecx,%edi
  803515:	0f 87 c5 00 00 00    	ja     8035e0 <__udivdi3+0xf0>
  80351b:	85 ff                	test   %edi,%edi
  80351d:	89 fd                	mov    %edi,%ebp
  80351f:	75 0b                	jne    80352c <__udivdi3+0x3c>
  803521:	b8 01 00 00 00       	mov    $0x1,%eax
  803526:	31 d2                	xor    %edx,%edx
  803528:	f7 f7                	div    %edi
  80352a:	89 c5                	mov    %eax,%ebp
  80352c:	89 c8                	mov    %ecx,%eax
  80352e:	31 d2                	xor    %edx,%edx
  803530:	f7 f5                	div    %ebp
  803532:	89 c1                	mov    %eax,%ecx
  803534:	89 d8                	mov    %ebx,%eax
  803536:	89 cf                	mov    %ecx,%edi
  803538:	f7 f5                	div    %ebp
  80353a:	89 c3                	mov    %eax,%ebx
  80353c:	89 d8                	mov    %ebx,%eax
  80353e:	89 fa                	mov    %edi,%edx
  803540:	83 c4 1c             	add    $0x1c,%esp
  803543:	5b                   	pop    %ebx
  803544:	5e                   	pop    %esi
  803545:	5f                   	pop    %edi
  803546:	5d                   	pop    %ebp
  803547:	c3                   	ret    
  803548:	90                   	nop
  803549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803550:	39 ce                	cmp    %ecx,%esi
  803552:	77 74                	ja     8035c8 <__udivdi3+0xd8>
  803554:	0f bd fe             	bsr    %esi,%edi
  803557:	83 f7 1f             	xor    $0x1f,%edi
  80355a:	0f 84 98 00 00 00    	je     8035f8 <__udivdi3+0x108>
  803560:	bb 20 00 00 00       	mov    $0x20,%ebx
  803565:	89 f9                	mov    %edi,%ecx
  803567:	89 c5                	mov    %eax,%ebp
  803569:	29 fb                	sub    %edi,%ebx
  80356b:	d3 e6                	shl    %cl,%esi
  80356d:	89 d9                	mov    %ebx,%ecx
  80356f:	d3 ed                	shr    %cl,%ebp
  803571:	89 f9                	mov    %edi,%ecx
  803573:	d3 e0                	shl    %cl,%eax
  803575:	09 ee                	or     %ebp,%esi
  803577:	89 d9                	mov    %ebx,%ecx
  803579:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80357d:	89 d5                	mov    %edx,%ebp
  80357f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803583:	d3 ed                	shr    %cl,%ebp
  803585:	89 f9                	mov    %edi,%ecx
  803587:	d3 e2                	shl    %cl,%edx
  803589:	89 d9                	mov    %ebx,%ecx
  80358b:	d3 e8                	shr    %cl,%eax
  80358d:	09 c2                	or     %eax,%edx
  80358f:	89 d0                	mov    %edx,%eax
  803591:	89 ea                	mov    %ebp,%edx
  803593:	f7 f6                	div    %esi
  803595:	89 d5                	mov    %edx,%ebp
  803597:	89 c3                	mov    %eax,%ebx
  803599:	f7 64 24 0c          	mull   0xc(%esp)
  80359d:	39 d5                	cmp    %edx,%ebp
  80359f:	72 10                	jb     8035b1 <__udivdi3+0xc1>
  8035a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8035a5:	89 f9                	mov    %edi,%ecx
  8035a7:	d3 e6                	shl    %cl,%esi
  8035a9:	39 c6                	cmp    %eax,%esi
  8035ab:	73 07                	jae    8035b4 <__udivdi3+0xc4>
  8035ad:	39 d5                	cmp    %edx,%ebp
  8035af:	75 03                	jne    8035b4 <__udivdi3+0xc4>
  8035b1:	83 eb 01             	sub    $0x1,%ebx
  8035b4:	31 ff                	xor    %edi,%edi
  8035b6:	89 d8                	mov    %ebx,%eax
  8035b8:	89 fa                	mov    %edi,%edx
  8035ba:	83 c4 1c             	add    $0x1c,%esp
  8035bd:	5b                   	pop    %ebx
  8035be:	5e                   	pop    %esi
  8035bf:	5f                   	pop    %edi
  8035c0:	5d                   	pop    %ebp
  8035c1:	c3                   	ret    
  8035c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8035c8:	31 ff                	xor    %edi,%edi
  8035ca:	31 db                	xor    %ebx,%ebx
  8035cc:	89 d8                	mov    %ebx,%eax
  8035ce:	89 fa                	mov    %edi,%edx
  8035d0:	83 c4 1c             	add    $0x1c,%esp
  8035d3:	5b                   	pop    %ebx
  8035d4:	5e                   	pop    %esi
  8035d5:	5f                   	pop    %edi
  8035d6:	5d                   	pop    %ebp
  8035d7:	c3                   	ret    
  8035d8:	90                   	nop
  8035d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035e0:	89 d8                	mov    %ebx,%eax
  8035e2:	f7 f7                	div    %edi
  8035e4:	31 ff                	xor    %edi,%edi
  8035e6:	89 c3                	mov    %eax,%ebx
  8035e8:	89 d8                	mov    %ebx,%eax
  8035ea:	89 fa                	mov    %edi,%edx
  8035ec:	83 c4 1c             	add    $0x1c,%esp
  8035ef:	5b                   	pop    %ebx
  8035f0:	5e                   	pop    %esi
  8035f1:	5f                   	pop    %edi
  8035f2:	5d                   	pop    %ebp
  8035f3:	c3                   	ret    
  8035f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8035f8:	39 ce                	cmp    %ecx,%esi
  8035fa:	72 0c                	jb     803608 <__udivdi3+0x118>
  8035fc:	31 db                	xor    %ebx,%ebx
  8035fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803602:	0f 87 34 ff ff ff    	ja     80353c <__udivdi3+0x4c>
  803608:	bb 01 00 00 00       	mov    $0x1,%ebx
  80360d:	e9 2a ff ff ff       	jmp    80353c <__udivdi3+0x4c>
  803612:	66 90                	xchg   %ax,%ax
  803614:	66 90                	xchg   %ax,%ax
  803616:	66 90                	xchg   %ax,%ax
  803618:	66 90                	xchg   %ax,%ax
  80361a:	66 90                	xchg   %ax,%ax
  80361c:	66 90                	xchg   %ax,%ax
  80361e:	66 90                	xchg   %ax,%ax

00803620 <__umoddi3>:
  803620:	55                   	push   %ebp
  803621:	57                   	push   %edi
  803622:	56                   	push   %esi
  803623:	53                   	push   %ebx
  803624:	83 ec 1c             	sub    $0x1c,%esp
  803627:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80362b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80362f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803633:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803637:	85 d2                	test   %edx,%edx
  803639:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80363d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803641:	89 f3                	mov    %esi,%ebx
  803643:	89 3c 24             	mov    %edi,(%esp)
  803646:	89 74 24 04          	mov    %esi,0x4(%esp)
  80364a:	75 1c                	jne    803668 <__umoddi3+0x48>
  80364c:	39 f7                	cmp    %esi,%edi
  80364e:	76 50                	jbe    8036a0 <__umoddi3+0x80>
  803650:	89 c8                	mov    %ecx,%eax
  803652:	89 f2                	mov    %esi,%edx
  803654:	f7 f7                	div    %edi
  803656:	89 d0                	mov    %edx,%eax
  803658:	31 d2                	xor    %edx,%edx
  80365a:	83 c4 1c             	add    $0x1c,%esp
  80365d:	5b                   	pop    %ebx
  80365e:	5e                   	pop    %esi
  80365f:	5f                   	pop    %edi
  803660:	5d                   	pop    %ebp
  803661:	c3                   	ret    
  803662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803668:	39 f2                	cmp    %esi,%edx
  80366a:	89 d0                	mov    %edx,%eax
  80366c:	77 52                	ja     8036c0 <__umoddi3+0xa0>
  80366e:	0f bd ea             	bsr    %edx,%ebp
  803671:	83 f5 1f             	xor    $0x1f,%ebp
  803674:	75 5a                	jne    8036d0 <__umoddi3+0xb0>
  803676:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80367a:	0f 82 e0 00 00 00    	jb     803760 <__umoddi3+0x140>
  803680:	39 0c 24             	cmp    %ecx,(%esp)
  803683:	0f 86 d7 00 00 00    	jbe    803760 <__umoddi3+0x140>
  803689:	8b 44 24 08          	mov    0x8(%esp),%eax
  80368d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803691:	83 c4 1c             	add    $0x1c,%esp
  803694:	5b                   	pop    %ebx
  803695:	5e                   	pop    %esi
  803696:	5f                   	pop    %edi
  803697:	5d                   	pop    %ebp
  803698:	c3                   	ret    
  803699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036a0:	85 ff                	test   %edi,%edi
  8036a2:	89 fd                	mov    %edi,%ebp
  8036a4:	75 0b                	jne    8036b1 <__umoddi3+0x91>
  8036a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8036ab:	31 d2                	xor    %edx,%edx
  8036ad:	f7 f7                	div    %edi
  8036af:	89 c5                	mov    %eax,%ebp
  8036b1:	89 f0                	mov    %esi,%eax
  8036b3:	31 d2                	xor    %edx,%edx
  8036b5:	f7 f5                	div    %ebp
  8036b7:	89 c8                	mov    %ecx,%eax
  8036b9:	f7 f5                	div    %ebp
  8036bb:	89 d0                	mov    %edx,%eax
  8036bd:	eb 99                	jmp    803658 <__umoddi3+0x38>
  8036bf:	90                   	nop
  8036c0:	89 c8                	mov    %ecx,%eax
  8036c2:	89 f2                	mov    %esi,%edx
  8036c4:	83 c4 1c             	add    $0x1c,%esp
  8036c7:	5b                   	pop    %ebx
  8036c8:	5e                   	pop    %esi
  8036c9:	5f                   	pop    %edi
  8036ca:	5d                   	pop    %ebp
  8036cb:	c3                   	ret    
  8036cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8036d0:	8b 34 24             	mov    (%esp),%esi
  8036d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8036d8:	89 e9                	mov    %ebp,%ecx
  8036da:	29 ef                	sub    %ebp,%edi
  8036dc:	d3 e0                	shl    %cl,%eax
  8036de:	89 f9                	mov    %edi,%ecx
  8036e0:	89 f2                	mov    %esi,%edx
  8036e2:	d3 ea                	shr    %cl,%edx
  8036e4:	89 e9                	mov    %ebp,%ecx
  8036e6:	09 c2                	or     %eax,%edx
  8036e8:	89 d8                	mov    %ebx,%eax
  8036ea:	89 14 24             	mov    %edx,(%esp)
  8036ed:	89 f2                	mov    %esi,%edx
  8036ef:	d3 e2                	shl    %cl,%edx
  8036f1:	89 f9                	mov    %edi,%ecx
  8036f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8036f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8036fb:	d3 e8                	shr    %cl,%eax
  8036fd:	89 e9                	mov    %ebp,%ecx
  8036ff:	89 c6                	mov    %eax,%esi
  803701:	d3 e3                	shl    %cl,%ebx
  803703:	89 f9                	mov    %edi,%ecx
  803705:	89 d0                	mov    %edx,%eax
  803707:	d3 e8                	shr    %cl,%eax
  803709:	89 e9                	mov    %ebp,%ecx
  80370b:	09 d8                	or     %ebx,%eax
  80370d:	89 d3                	mov    %edx,%ebx
  80370f:	89 f2                	mov    %esi,%edx
  803711:	f7 34 24             	divl   (%esp)
  803714:	89 d6                	mov    %edx,%esi
  803716:	d3 e3                	shl    %cl,%ebx
  803718:	f7 64 24 04          	mull   0x4(%esp)
  80371c:	39 d6                	cmp    %edx,%esi
  80371e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803722:	89 d1                	mov    %edx,%ecx
  803724:	89 c3                	mov    %eax,%ebx
  803726:	72 08                	jb     803730 <__umoddi3+0x110>
  803728:	75 11                	jne    80373b <__umoddi3+0x11b>
  80372a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80372e:	73 0b                	jae    80373b <__umoddi3+0x11b>
  803730:	2b 44 24 04          	sub    0x4(%esp),%eax
  803734:	1b 14 24             	sbb    (%esp),%edx
  803737:	89 d1                	mov    %edx,%ecx
  803739:	89 c3                	mov    %eax,%ebx
  80373b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80373f:	29 da                	sub    %ebx,%edx
  803741:	19 ce                	sbb    %ecx,%esi
  803743:	89 f9                	mov    %edi,%ecx
  803745:	89 f0                	mov    %esi,%eax
  803747:	d3 e0                	shl    %cl,%eax
  803749:	89 e9                	mov    %ebp,%ecx
  80374b:	d3 ea                	shr    %cl,%edx
  80374d:	89 e9                	mov    %ebp,%ecx
  80374f:	d3 ee                	shr    %cl,%esi
  803751:	09 d0                	or     %edx,%eax
  803753:	89 f2                	mov    %esi,%edx
  803755:	83 c4 1c             	add    $0x1c,%esp
  803758:	5b                   	pop    %ebx
  803759:	5e                   	pop    %esi
  80375a:	5f                   	pop    %edi
  80375b:	5d                   	pop    %ebp
  80375c:	c3                   	ret    
  80375d:	8d 76 00             	lea    0x0(%esi),%esi
  803760:	29 f9                	sub    %edi,%ecx
  803762:	19 d6                	sbb    %edx,%esi
  803764:	89 74 24 04          	mov    %esi,0x4(%esp)
  803768:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80376c:	e9 18 ff ff ff       	jmp    803689 <__umoddi3+0x69>
