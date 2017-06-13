
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 60 2a 80 00       	push   $0x802a60
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 40 80 00       	push   $0x804000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 28 2b 80 00       	push   $0x802b28
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 6f 2a 80 00       	push   $0x802a6f
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 60 80 00       	push   $0x806020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 64 2b 80 00       	push   $0x802b64
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 86 2a 80 00       	push   $0x802a86
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 9c 2a 80 00       	push   $0x802a9c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 92 09 00 00       	call   800a9d <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 a8 2a 80 00       	push   $0x802aa8
  800123:	56                   	push   %esi
  800124:	e8 74 09 00 00       	call   800a9d <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 68 09 00 00       	call   800a9d <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 a9 2a 80 00       	push   $0x802aa9
  80013d:	56                   	push   %esi
  80013e:	e8 5a 09 00 00       	call   800a9d <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 ab 2a 80 00       	push   $0x802aab
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 af 2a 80 00 	movl   $0x802aaf,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 b6 10 00 00       	call   801230 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 c1 2a 80 00       	push   $0x802ac1
  80018c:	6a 37                	push   $0x37
  80018e:	68 ce 2a 80 00       	push   $0x802ace
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 da 2a 80 00       	push   $0x802ada
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 ce 2a 80 00       	push   $0x802ace
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 c6 10 00 00       	call   801280 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 f4 2a 80 00       	push   $0x802af4
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 ce 2a 80 00       	push   $0x802ace
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 fc 2a 80 00       	push   $0x802afc
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 10 2b 80 00       	push   $0x802b10
  8001ea:	68 0f 2b 80 00       	push   $0x802b0f
  8001ef:	e8 0a 1c 00 00       	call   801dfe <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 13 2b 80 00       	push   $0x802b13
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 b6 1f 00 00       	call   8021cd <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 93 2b 80 00       	push   $0x802b93
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 44 08 00 00       	call   800a7d <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 98 09 00 00       	call   800c0f <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 43 0b 00 00       	call   800dc4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 b4 0b 00 00       	call   800e61 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 30 0b 00 00       	call   800de2 <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 db 0a 00 00       	call   800dc4 <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 6b 10 00 00       	call   80136c <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 db 0d 00 00       	call   801106 <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 63 0d 00 00       	call   8010b7 <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 11 0b 00 00       	call   800e80 <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 57 80 00    	mov    0x805770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 fa 0c 00 00       	call   801090 <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8003aa:	e8 93 0a 00 00       	call   800e42 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bc:	a3 90 77 80 00       	mov    %eax,0x807790
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	e8 88 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d6:	e8 0a 00 00 00       	call   8003e5 <exit>
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003eb:	e8 6b 0e 00 00       	call   80125b <close_all>
	sys_env_destroy(0);
  8003f0:	83 ec 0c             	sub    $0xc,%esp
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 07 0a 00 00       	call   800e01 <sys_env_destroy>
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800407:	8b 35 8c 57 80 00    	mov    0x80578c,%esi
  80040d:	e8 30 0a 00 00       	call   800e42 <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 ac 2b 80 00       	push   $0x802bac
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 9c 30 80 00 	movl   $0x80309c,(%esp)
  80043a:	e8 99 00 00 00       	call   8004d8 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x43>

00800445 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044f:	8b 13                	mov    (%ebx),%edx
  800451:	8d 42 01             	lea    0x1(%edx),%eax
  800454:	89 03                	mov    %eax,(%ebx)
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800462:	75 1a                	jne    80047e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 ff 00 00 00       	push   $0xff
  80046c:	8d 43 08             	lea    0x8(%ebx),%eax
  80046f:	50                   	push   %eax
  800470:	e8 4f 09 00 00       	call   800dc4 <sys_cputs>
		b->idx = 0;
  800475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	68 45 04 80 00       	push   $0x800445
  8004b6:	e8 54 01 00 00       	call   80060f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 f4 08 00 00       	call   800dc4 <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	50                   	push   %eax
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 9d ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 1c             	sub    $0x1c,%esp
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 d6                	mov    %edx,%esi
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800505:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80050d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800510:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800513:	39 d3                	cmp    %edx,%ebx
  800515:	72 05                	jb     80051c <printnum+0x30>
  800517:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051a:	77 45                	ja     800561 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	ff 75 18             	pushl  0x18(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800528:	53                   	push   %ebx
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	ff 75 e0             	pushl  -0x20(%ebp)
  800535:	ff 75 dc             	pushl  -0x24(%ebp)
  800538:	ff 75 d8             	pushl  -0x28(%ebp)
  80053b:	e8 80 22 00 00       	call   8027c0 <__udivdi3>
  800540:	83 c4 18             	add    $0x18,%esp
  800543:	52                   	push   %edx
  800544:	50                   	push   %eax
  800545:	89 f2                	mov    %esi,%edx
  800547:	89 f8                	mov    %edi,%eax
  800549:	e8 9e ff ff ff       	call   8004ec <printnum>
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	eb 18                	jmp    80056b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff d7                	call   *%edi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 03                	jmp    800564 <printnum+0x78>
  800561:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	85 db                	test   %ebx,%ebx
  800569:	7f e8                	jg     800553 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	56                   	push   %esi
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	ff 75 e4             	pushl  -0x1c(%ebp)
  800575:	ff 75 e0             	pushl  -0x20(%ebp)
  800578:	ff 75 dc             	pushl  -0x24(%ebp)
  80057b:	ff 75 d8             	pushl  -0x28(%ebp)
  80057e:	e8 6d 23 00 00       	call   8028f0 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 cf 2b 80 00 	movsbl 0x802bcf(%eax),%eax
  80058d:	50                   	push   %eax
  80058e:	ff d7                	call   *%edi
}
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80059e:	83 fa 01             	cmp    $0x1,%edx
  8005a1:	7e 0e                	jle    8005b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a8:	89 08                	mov    %ecx,(%eax)
  8005aa:	8b 02                	mov    (%edx),%eax
  8005ac:	8b 52 04             	mov    0x4(%edx),%edx
  8005af:	eb 22                	jmp    8005d3 <getuint+0x38>
	else if (lflag)
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 10                	je     8005c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ba:	89 08                	mov    %ecx,(%eax)
  8005bc:	8b 02                	mov    (%edx),%eax
  8005be:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c3:	eb 0e                	jmp    8005d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ca:	89 08                	mov    %ecx,(%eax)
  8005cc:	8b 02                	mov    (%edx),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e4:	73 0a                	jae    8005f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	88 02                	mov    %al,(%edx)
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 10             	pushl  0x10(%ebp)
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	e8 05 00 00 00       	call   80060f <vprintfmt>
	va_end(ap);
}
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	57                   	push   %edi
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	83 ec 2c             	sub    $0x2c,%esp
  800618:	8b 75 08             	mov    0x8(%ebp),%esi
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800621:	eb 12                	jmp    800635 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800623:	85 c0                	test   %eax,%eax
  800625:	0f 84 a9 03 00 00    	je     8009d4 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	ff d6                	call   *%esi
  800632:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800635:	83 c7 01             	add    $0x1,%edi
  800638:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063c:	83 f8 25             	cmp    $0x25,%eax
  80063f:	75 e2                	jne    800623 <vprintfmt+0x14>
  800641:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800645:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80064c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800653:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80065a:	ba 00 00 00 00       	mov    $0x0,%edx
  80065f:	eb 07                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800664:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8d 47 01             	lea    0x1(%edi),%eax
  80066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066e:	0f b6 07             	movzbl (%edi),%eax
  800671:	0f b6 c8             	movzbl %al,%ecx
  800674:	83 e8 23             	sub    $0x23,%eax
  800677:	3c 55                	cmp    $0x55,%al
  800679:	0f 87 3a 03 00 00    	ja     8009b9 <vprintfmt+0x3aa>
  80067f:	0f b6 c0             	movzbl %al,%eax
  800682:	ff 24 85 20 2d 80 00 	jmp    *0x802d20(,%eax,4)
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80068c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800690:	eb d6                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800695:	b8 00 00 00 00       	mov    $0x0,%eax
  80069a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80069d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006a0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8006a4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006a7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006aa:	83 fa 09             	cmp    $0x9,%edx
  8006ad:	77 39                	ja     8006e8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006b2:	eb e9                	jmp    80069d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006c5:	eb 27                	jmp    8006ee <vprintfmt+0xdf>
  8006c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d1:	0f 49 c8             	cmovns %eax,%ecx
  8006d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	eb 8c                	jmp    800668 <vprintfmt+0x59>
  8006dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006e6:	eb 80                	jmp    800668 <vprintfmt+0x59>
  8006e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006eb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f2:	0f 89 70 ff ff ff    	jns    800668 <vprintfmt+0x59>
				width = precision, precision = -1;
  8006f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800705:	e9 5e ff ff ff       	jmp    800668 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80070a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800710:	e9 53 ff ff ff       	jmp    800668 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8d 50 04             	lea    0x4(%eax),%edx
  80071b:	89 55 14             	mov    %edx,0x14(%ebp)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	ff 30                	pushl  (%eax)
  800724:	ff d6                	call   *%esi
			break;
  800726:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80072c:	e9 04 ff ff ff       	jmp    800635 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 04             	lea    0x4(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	99                   	cltd   
  80073d:	31 d0                	xor    %edx,%eax
  80073f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800741:	83 f8 0f             	cmp    $0xf,%eax
  800744:	7f 0b                	jg     800751 <vprintfmt+0x142>
  800746:	8b 14 85 80 2e 80 00 	mov    0x802e80(,%eax,4),%edx
  80074d:	85 d2                	test   %edx,%edx
  80074f:	75 18                	jne    800769 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800751:	50                   	push   %eax
  800752:	68 e7 2b 80 00       	push   $0x802be7
  800757:	53                   	push   %ebx
  800758:	56                   	push   %esi
  800759:	e8 94 fe ff ff       	call   8005f2 <printfmt>
  80075e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800764:	e9 cc fe ff ff       	jmp    800635 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800769:	52                   	push   %edx
  80076a:	68 b5 2f 80 00       	push   $0x802fb5
  80076f:	53                   	push   %ebx
  800770:	56                   	push   %esi
  800771:	e8 7c fe ff ff       	call   8005f2 <printfmt>
  800776:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077c:	e9 b4 fe ff ff       	jmp    800635 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8d 50 04             	lea    0x4(%eax),%edx
  800787:	89 55 14             	mov    %edx,0x14(%ebp)
  80078a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80078c:	85 ff                	test   %edi,%edi
  80078e:	b8 e0 2b 80 00       	mov    $0x802be0,%eax
  800793:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800796:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80079a:	0f 8e 94 00 00 00    	jle    800834 <vprintfmt+0x225>
  8007a0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007a4:	0f 84 98 00 00 00    	je     800842 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	ff 75 d0             	pushl  -0x30(%ebp)
  8007b0:	57                   	push   %edi
  8007b1:	e8 a6 02 00 00       	call   800a5c <strnlen>
  8007b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007b9:	29 c1                	sub    %eax,%ecx
  8007bb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007be:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007c1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007cb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cd:	eb 0f                	jmp    8007de <vprintfmt+0x1cf>
					putch(padc, putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d8:	83 ef 01             	sub    $0x1,%edi
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	85 ff                	test   %edi,%edi
  8007e0:	7f ed                	jg     8007cf <vprintfmt+0x1c0>
  8007e2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007e5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007e8:	85 c9                	test   %ecx,%ecx
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	0f 49 c1             	cmovns %ecx,%eax
  8007f2:	29 c1                	sub    %eax,%ecx
  8007f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8007f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007fd:	89 cb                	mov    %ecx,%ebx
  8007ff:	eb 4d                	jmp    80084e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800801:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800805:	74 1b                	je     800822 <vprintfmt+0x213>
  800807:	0f be c0             	movsbl %al,%eax
  80080a:	83 e8 20             	sub    $0x20,%eax
  80080d:	83 f8 5e             	cmp    $0x5e,%eax
  800810:	76 10                	jbe    800822 <vprintfmt+0x213>
					putch('?', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	6a 3f                	push   $0x3f
  80081a:	ff 55 08             	call   *0x8(%ebp)
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	eb 0d                	jmp    80082f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	52                   	push   %edx
  800829:	ff 55 08             	call   *0x8(%ebp)
  80082c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80082f:	83 eb 01             	sub    $0x1,%ebx
  800832:	eb 1a                	jmp    80084e <vprintfmt+0x23f>
  800834:	89 75 08             	mov    %esi,0x8(%ebp)
  800837:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80083a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80083d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800840:	eb 0c                	jmp    80084e <vprintfmt+0x23f>
  800842:	89 75 08             	mov    %esi,0x8(%ebp)
  800845:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800848:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80084b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084e:	83 c7 01             	add    $0x1,%edi
  800851:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800855:	0f be d0             	movsbl %al,%edx
  800858:	85 d2                	test   %edx,%edx
  80085a:	74 23                	je     80087f <vprintfmt+0x270>
  80085c:	85 f6                	test   %esi,%esi
  80085e:	78 a1                	js     800801 <vprintfmt+0x1f2>
  800860:	83 ee 01             	sub    $0x1,%esi
  800863:	79 9c                	jns    800801 <vprintfmt+0x1f2>
  800865:	89 df                	mov    %ebx,%edi
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086d:	eb 18                	jmp    800887 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	53                   	push   %ebx
  800873:	6a 20                	push   $0x20
  800875:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800877:	83 ef 01             	sub    $0x1,%edi
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	eb 08                	jmp    800887 <vprintfmt+0x278>
  80087f:	89 df                	mov    %ebx,%edi
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800887:	85 ff                	test   %edi,%edi
  800889:	7f e4                	jg     80086f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088e:	e9 a2 fd ff ff       	jmp    800635 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800893:	83 fa 01             	cmp    $0x1,%edx
  800896:	7e 16                	jle    8008ae <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 08             	lea    0x8(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	8b 50 04             	mov    0x4(%eax),%edx
  8008a4:	8b 00                	mov    (%eax),%eax
  8008a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008ac:	eb 32                	jmp    8008e0 <vprintfmt+0x2d1>
	else if (lflag)
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	74 18                	je     8008ca <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 50 04             	lea    0x4(%eax),%edx
  8008b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c0:	89 c1                	mov    %eax,%ecx
  8008c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8008c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008c8:	eb 16                	jmp    8008e0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 00                	mov    (%eax),%eax
  8008d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d8:	89 c1                	mov    %eax,%ecx
  8008da:	c1 f9 1f             	sar    $0x1f,%ecx
  8008dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008ef:	0f 89 90 00 00 00    	jns    800985 <vprintfmt+0x376>
				putch('-', putdat);
  8008f5:	83 ec 08             	sub    $0x8,%esp
  8008f8:	53                   	push   %ebx
  8008f9:	6a 2d                	push   $0x2d
  8008fb:	ff d6                	call   *%esi
				num = -(long long) num;
  8008fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800900:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800903:	f7 d8                	neg    %eax
  800905:	83 d2 00             	adc    $0x0,%edx
  800908:	f7 da                	neg    %edx
  80090a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80090d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800912:	eb 71                	jmp    800985 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800914:	8d 45 14             	lea    0x14(%ebp),%eax
  800917:	e8 7f fc ff ff       	call   80059b <getuint>
			base = 10;
  80091c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800921:	eb 62                	jmp    800985 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800923:	8d 45 14             	lea    0x14(%ebp),%eax
  800926:	e8 70 fc ff ff       	call   80059b <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  80092b:	83 ec 0c             	sub    $0xc,%esp
  80092e:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800932:	51                   	push   %ecx
  800933:	ff 75 e0             	pushl  -0x20(%ebp)
  800936:	6a 08                	push   $0x8
  800938:	52                   	push   %edx
  800939:	50                   	push   %eax
  80093a:	89 da                	mov    %ebx,%edx
  80093c:	89 f0                	mov    %esi,%eax
  80093e:	e8 a9 fb ff ff       	call   8004ec <printnum>
			break;
  800943:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800946:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800949:	e9 e7 fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	53                   	push   %ebx
  800952:	6a 30                	push   $0x30
  800954:	ff d6                	call   *%esi
			putch('x', putdat);
  800956:	83 c4 08             	add    $0x8,%esp
  800959:	53                   	push   %ebx
  80095a:	6a 78                	push   $0x78
  80095c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80095e:	8b 45 14             	mov    0x14(%ebp),%eax
  800961:	8d 50 04             	lea    0x4(%eax),%edx
  800964:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800967:	8b 00                	mov    (%eax),%eax
  800969:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80096e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800971:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800976:	eb 0d                	jmp    800985 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800978:	8d 45 14             	lea    0x14(%ebp),%eax
  80097b:	e8 1b fc ff ff       	call   80059b <getuint>
			base = 16;
  800980:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800985:	83 ec 0c             	sub    $0xc,%esp
  800988:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80098c:	57                   	push   %edi
  80098d:	ff 75 e0             	pushl  -0x20(%ebp)
  800990:	51                   	push   %ecx
  800991:	52                   	push   %edx
  800992:	50                   	push   %eax
  800993:	89 da                	mov    %ebx,%edx
  800995:	89 f0                	mov    %esi,%eax
  800997:	e8 50 fb ff ff       	call   8004ec <printnum>
			break;
  80099c:	83 c4 20             	add    $0x20,%esp
  80099f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009a2:	e9 8e fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	53                   	push   %ebx
  8009ab:	51                   	push   %ecx
  8009ac:	ff d6                	call   *%esi
			break;
  8009ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009b4:	e9 7c fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009b9:	83 ec 08             	sub    $0x8,%esp
  8009bc:	53                   	push   %ebx
  8009bd:	6a 25                	push   $0x25
  8009bf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c1:	83 c4 10             	add    $0x10,%esp
  8009c4:	eb 03                	jmp    8009c9 <vprintfmt+0x3ba>
  8009c6:	83 ef 01             	sub    $0x1,%edi
  8009c9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009cd:	75 f7                	jne    8009c6 <vprintfmt+0x3b7>
  8009cf:	e9 61 fc ff ff       	jmp    800635 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009d7:	5b                   	pop    %ebx
  8009d8:	5e                   	pop    %esi
  8009d9:	5f                   	pop    %edi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 18             	sub    $0x18,%esp
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009eb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009ef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009f9:	85 c0                	test   %eax,%eax
  8009fb:	74 26                	je     800a23 <vsnprintf+0x47>
  8009fd:	85 d2                	test   %edx,%edx
  8009ff:	7e 22                	jle    800a23 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a01:	ff 75 14             	pushl  0x14(%ebp)
  800a04:	ff 75 10             	pushl  0x10(%ebp)
  800a07:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a0a:	50                   	push   %eax
  800a0b:	68 d5 05 80 00       	push   $0x8005d5
  800a10:	e8 fa fb ff ff       	call   80060f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a15:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a18:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a1e:	83 c4 10             	add    $0x10,%esp
  800a21:	eb 05                	jmp    800a28 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    

00800a2a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a30:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a33:	50                   	push   %eax
  800a34:	ff 75 10             	pushl  0x10(%ebp)
  800a37:	ff 75 0c             	pushl  0xc(%ebp)
  800a3a:	ff 75 08             	pushl  0x8(%ebp)
  800a3d:	e8 9a ff ff ff       	call   8009dc <vsnprintf>
	va_end(ap);

	return rc;
}
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	eb 03                	jmp    800a54 <strlen+0x10>
		n++;
  800a51:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a54:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a58:	75 f7                	jne    800a51 <strlen+0xd>
		n++;
	return n;
}
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6a:	eb 03                	jmp    800a6f <strnlen+0x13>
		n++;
  800a6c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a6f:	39 c2                	cmp    %eax,%edx
  800a71:	74 08                	je     800a7b <strnlen+0x1f>
  800a73:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a77:	75 f3                	jne    800a6c <strnlen+0x10>
  800a79:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a87:	89 c2                	mov    %eax,%edx
  800a89:	83 c2 01             	add    $0x1,%edx
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a93:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a96:	84 db                	test   %bl,%bl
  800a98:	75 ef                	jne    800a89 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	53                   	push   %ebx
  800aa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa4:	53                   	push   %ebx
  800aa5:	e8 9a ff ff ff       	call   800a44 <strlen>
  800aaa:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800aad:	ff 75 0c             	pushl  0xc(%ebp)
  800ab0:	01 d8                	add    %ebx,%eax
  800ab2:	50                   	push   %eax
  800ab3:	e8 c5 ff ff ff       	call   800a7d <strcpy>
	return dst;
}
  800ab8:	89 d8                	mov    %ebx,%eax
  800aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acf:	89 f2                	mov    %esi,%edx
  800ad1:	eb 0f                	jmp    800ae2 <strncpy+0x23>
		*dst++ = *src;
  800ad3:	83 c2 01             	add    $0x1,%edx
  800ad6:	0f b6 01             	movzbl (%ecx),%eax
  800ad9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800adc:	80 39 01             	cmpb   $0x1,(%ecx)
  800adf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae2:	39 da                	cmp    %ebx,%edx
  800ae4:	75 ed                	jne    800ad3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae6:	89 f0                	mov    %esi,%eax
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 75 08             	mov    0x8(%ebp),%esi
  800af4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af7:	8b 55 10             	mov    0x10(%ebp),%edx
  800afa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800afc:	85 d2                	test   %edx,%edx
  800afe:	74 21                	je     800b21 <strlcpy+0x35>
  800b00:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b04:	89 f2                	mov    %esi,%edx
  800b06:	eb 09                	jmp    800b11 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b08:	83 c2 01             	add    $0x1,%edx
  800b0b:	83 c1 01             	add    $0x1,%ecx
  800b0e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b11:	39 c2                	cmp    %eax,%edx
  800b13:	74 09                	je     800b1e <strlcpy+0x32>
  800b15:	0f b6 19             	movzbl (%ecx),%ebx
  800b18:	84 db                	test   %bl,%bl
  800b1a:	75 ec                	jne    800b08 <strlcpy+0x1c>
  800b1c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b1e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b21:	29 f0                	sub    %esi,%eax
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b30:	eb 06                	jmp    800b38 <strcmp+0x11>
		p++, q++;
  800b32:	83 c1 01             	add    $0x1,%ecx
  800b35:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b38:	0f b6 01             	movzbl (%ecx),%eax
  800b3b:	84 c0                	test   %al,%al
  800b3d:	74 04                	je     800b43 <strcmp+0x1c>
  800b3f:	3a 02                	cmp    (%edx),%al
  800b41:	74 ef                	je     800b32 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b43:	0f b6 c0             	movzbl %al,%eax
  800b46:	0f b6 12             	movzbl (%edx),%edx
  800b49:	29 d0                	sub    %edx,%eax
}
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	53                   	push   %ebx
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b57:	89 c3                	mov    %eax,%ebx
  800b59:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b5c:	eb 06                	jmp    800b64 <strncmp+0x17>
		n--, p++, q++;
  800b5e:	83 c0 01             	add    $0x1,%eax
  800b61:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b64:	39 d8                	cmp    %ebx,%eax
  800b66:	74 15                	je     800b7d <strncmp+0x30>
  800b68:	0f b6 08             	movzbl (%eax),%ecx
  800b6b:	84 c9                	test   %cl,%cl
  800b6d:	74 04                	je     800b73 <strncmp+0x26>
  800b6f:	3a 0a                	cmp    (%edx),%cl
  800b71:	74 eb                	je     800b5e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b73:	0f b6 00             	movzbl (%eax),%eax
  800b76:	0f b6 12             	movzbl (%edx),%edx
  800b79:	29 d0                	sub    %edx,%eax
  800b7b:	eb 05                	jmp    800b82 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b82:	5b                   	pop    %ebx
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b8f:	eb 07                	jmp    800b98 <strchr+0x13>
		if (*s == c)
  800b91:	38 ca                	cmp    %cl,%dl
  800b93:	74 0f                	je     800ba4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b95:	83 c0 01             	add    $0x1,%eax
  800b98:	0f b6 10             	movzbl (%eax),%edx
  800b9b:	84 d2                	test   %dl,%dl
  800b9d:	75 f2                	jne    800b91 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb0:	eb 03                	jmp    800bb5 <strfind+0xf>
  800bb2:	83 c0 01             	add    $0x1,%eax
  800bb5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bb8:	38 ca                	cmp    %cl,%dl
  800bba:	74 04                	je     800bc0 <strfind+0x1a>
  800bbc:	84 d2                	test   %dl,%dl
  800bbe:	75 f2                	jne    800bb2 <strfind+0xc>
			break;
	return (char *) s;
}
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bce:	85 c9                	test   %ecx,%ecx
  800bd0:	74 36                	je     800c08 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd8:	75 28                	jne    800c02 <memset+0x40>
  800bda:	f6 c1 03             	test   $0x3,%cl
  800bdd:	75 23                	jne    800c02 <memset+0x40>
		c &= 0xFF;
  800bdf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	c1 e3 08             	shl    $0x8,%ebx
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	c1 e6 18             	shl    $0x18,%esi
  800bed:	89 d0                	mov    %edx,%eax
  800bef:	c1 e0 10             	shl    $0x10,%eax
  800bf2:	09 f0                	or     %esi,%eax
  800bf4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bf6:	89 d8                	mov    %ebx,%eax
  800bf8:	09 d0                	or     %edx,%eax
  800bfa:	c1 e9 02             	shr    $0x2,%ecx
  800bfd:	fc                   	cld    
  800bfe:	f3 ab                	rep stos %eax,%es:(%edi)
  800c00:	eb 06                	jmp    800c08 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c05:	fc                   	cld    
  800c06:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c08:	89 f8                	mov    %edi,%eax
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	8b 45 08             	mov    0x8(%ebp),%eax
  800c17:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c1d:	39 c6                	cmp    %eax,%esi
  800c1f:	73 35                	jae    800c56 <memmove+0x47>
  800c21:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c24:	39 d0                	cmp    %edx,%eax
  800c26:	73 2e                	jae    800c56 <memmove+0x47>
		s += n;
		d += n;
  800c28:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2b:	89 d6                	mov    %edx,%esi
  800c2d:	09 fe                	or     %edi,%esi
  800c2f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c35:	75 13                	jne    800c4a <memmove+0x3b>
  800c37:	f6 c1 03             	test   $0x3,%cl
  800c3a:	75 0e                	jne    800c4a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c3c:	83 ef 04             	sub    $0x4,%edi
  800c3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c42:	c1 e9 02             	shr    $0x2,%ecx
  800c45:	fd                   	std    
  800c46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c48:	eb 09                	jmp    800c53 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c4a:	83 ef 01             	sub    $0x1,%edi
  800c4d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c50:	fd                   	std    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c53:	fc                   	cld    
  800c54:	eb 1d                	jmp    800c73 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c56:	89 f2                	mov    %esi,%edx
  800c58:	09 c2                	or     %eax,%edx
  800c5a:	f6 c2 03             	test   $0x3,%dl
  800c5d:	75 0f                	jne    800c6e <memmove+0x5f>
  800c5f:	f6 c1 03             	test   $0x3,%cl
  800c62:	75 0a                	jne    800c6e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c64:	c1 e9 02             	shr    $0x2,%ecx
  800c67:	89 c7                	mov    %eax,%edi
  800c69:	fc                   	cld    
  800c6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6c:	eb 05                	jmp    800c73 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c6e:	89 c7                	mov    %eax,%edi
  800c70:	fc                   	cld    
  800c71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c7a:	ff 75 10             	pushl  0x10(%ebp)
  800c7d:	ff 75 0c             	pushl  0xc(%ebp)
  800c80:	ff 75 08             	pushl  0x8(%ebp)
  800c83:	e8 87 ff ff ff       	call   800c0f <memmove>
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c95:	89 c6                	mov    %eax,%esi
  800c97:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9a:	eb 1a                	jmp    800cb6 <memcmp+0x2c>
		if (*s1 != *s2)
  800c9c:	0f b6 08             	movzbl (%eax),%ecx
  800c9f:	0f b6 1a             	movzbl (%edx),%ebx
  800ca2:	38 d9                	cmp    %bl,%cl
  800ca4:	74 0a                	je     800cb0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ca6:	0f b6 c1             	movzbl %cl,%eax
  800ca9:	0f b6 db             	movzbl %bl,%ebx
  800cac:	29 d8                	sub    %ebx,%eax
  800cae:	eb 0f                	jmp    800cbf <memcmp+0x35>
		s1++, s2++;
  800cb0:	83 c0 01             	add    $0x1,%eax
  800cb3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb6:	39 f0                	cmp    %esi,%eax
  800cb8:	75 e2                	jne    800c9c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	53                   	push   %ebx
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cca:	89 c1                	mov    %eax,%ecx
  800ccc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ccf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd3:	eb 0a                	jmp    800cdf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd5:	0f b6 10             	movzbl (%eax),%edx
  800cd8:	39 da                	cmp    %ebx,%edx
  800cda:	74 07                	je     800ce3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cdc:	83 c0 01             	add    $0x1,%eax
  800cdf:	39 c8                	cmp    %ecx,%eax
  800ce1:	72 f2                	jb     800cd5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce3:	5b                   	pop    %ebx
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf2:	eb 03                	jmp    800cf7 <strtol+0x11>
		s++;
  800cf4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf7:	0f b6 01             	movzbl (%ecx),%eax
  800cfa:	3c 20                	cmp    $0x20,%al
  800cfc:	74 f6                	je     800cf4 <strtol+0xe>
  800cfe:	3c 09                	cmp    $0x9,%al
  800d00:	74 f2                	je     800cf4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d02:	3c 2b                	cmp    $0x2b,%al
  800d04:	75 0a                	jne    800d10 <strtol+0x2a>
		s++;
  800d06:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d09:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0e:	eb 11                	jmp    800d21 <strtol+0x3b>
  800d10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d15:	3c 2d                	cmp    $0x2d,%al
  800d17:	75 08                	jne    800d21 <strtol+0x3b>
		s++, neg = 1;
  800d19:	83 c1 01             	add    $0x1,%ecx
  800d1c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d21:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d27:	75 15                	jne    800d3e <strtol+0x58>
  800d29:	80 39 30             	cmpb   $0x30,(%ecx)
  800d2c:	75 10                	jne    800d3e <strtol+0x58>
  800d2e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d32:	75 7c                	jne    800db0 <strtol+0xca>
		s += 2, base = 16;
  800d34:	83 c1 02             	add    $0x2,%ecx
  800d37:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3c:	eb 16                	jmp    800d54 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d3e:	85 db                	test   %ebx,%ebx
  800d40:	75 12                	jne    800d54 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d42:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d47:	80 39 30             	cmpb   $0x30,(%ecx)
  800d4a:	75 08                	jne    800d54 <strtol+0x6e>
		s++, base = 8;
  800d4c:	83 c1 01             	add    $0x1,%ecx
  800d4f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d54:	b8 00 00 00 00       	mov    $0x0,%eax
  800d59:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d5c:	0f b6 11             	movzbl (%ecx),%edx
  800d5f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d62:	89 f3                	mov    %esi,%ebx
  800d64:	80 fb 09             	cmp    $0x9,%bl
  800d67:	77 08                	ja     800d71 <strtol+0x8b>
			dig = *s - '0';
  800d69:	0f be d2             	movsbl %dl,%edx
  800d6c:	83 ea 30             	sub    $0x30,%edx
  800d6f:	eb 22                	jmp    800d93 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d71:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d74:	89 f3                	mov    %esi,%ebx
  800d76:	80 fb 19             	cmp    $0x19,%bl
  800d79:	77 08                	ja     800d83 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d7b:	0f be d2             	movsbl %dl,%edx
  800d7e:	83 ea 57             	sub    $0x57,%edx
  800d81:	eb 10                	jmp    800d93 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d83:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d86:	89 f3                	mov    %esi,%ebx
  800d88:	80 fb 19             	cmp    $0x19,%bl
  800d8b:	77 16                	ja     800da3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d8d:	0f be d2             	movsbl %dl,%edx
  800d90:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d93:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d96:	7d 0b                	jge    800da3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d98:	83 c1 01             	add    $0x1,%ecx
  800d9b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800da1:	eb b9                	jmp    800d5c <strtol+0x76>

	if (endptr)
  800da3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da7:	74 0d                	je     800db6 <strtol+0xd0>
		*endptr = (char *) s;
  800da9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dac:	89 0e                	mov    %ecx,(%esi)
  800dae:	eb 06                	jmp    800db6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800db0:	85 db                	test   %ebx,%ebx
  800db2:	74 98                	je     800d4c <strtol+0x66>
  800db4:	eb 9e                	jmp    800d54 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	f7 da                	neg    %edx
  800dba:	85 ff                	test   %edi,%edi
  800dbc:	0f 45 c2             	cmovne %edx,%eax
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dca:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	89 c3                	mov    %eax,%ebx
  800dd7:	89 c7                	mov    %eax,%edi
  800dd9:	89 c6                	mov    %eax,%esi
  800ddb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ded:	b8 01 00 00 00       	mov    $0x1,%eax
  800df2:	89 d1                	mov    %edx,%ecx
  800df4:	89 d3                	mov    %edx,%ebx
  800df6:	89 d7                	mov    %edx,%edi
  800df8:	89 d6                	mov    %edx,%esi
  800dfa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	89 cb                	mov    %ecx,%ebx
  800e19:	89 cf                	mov    %ecx,%edi
  800e1b:	89 ce                	mov    %ecx,%esi
  800e1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 17                	jle    800e3a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	50                   	push   %eax
  800e27:	6a 03                	push   $0x3
  800e29:	68 df 2e 80 00       	push   $0x802edf
  800e2e:	6a 23                	push   $0x23
  800e30:	68 fc 2e 80 00       	push   $0x802efc
  800e35:	e8 c5 f5 ff ff       	call   8003ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e52:	89 d1                	mov    %edx,%ecx
  800e54:	89 d3                	mov    %edx,%ebx
  800e56:	89 d7                	mov    %edx,%edi
  800e58:	89 d6                	mov    %edx,%esi
  800e5a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_yield>:

void
sys_yield(void)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e67:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e71:	89 d1                	mov    %edx,%ecx
  800e73:	89 d3                	mov    %edx,%ebx
  800e75:	89 d7                	mov    %edx,%edi
  800e77:	89 d6                	mov    %edx,%esi
  800e79:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e89:	be 00 00 00 00       	mov    $0x0,%esi
  800e8e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e96:	8b 55 08             	mov    0x8(%ebp),%edx
  800e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9c:	89 f7                	mov    %esi,%edi
  800e9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 17                	jle    800ebb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	50                   	push   %eax
  800ea8:	6a 04                	push   $0x4
  800eaa:	68 df 2e 80 00       	push   $0x802edf
  800eaf:	6a 23                	push   $0x23
  800eb1:	68 fc 2e 80 00       	push   $0x802efc
  800eb6:	e8 44 f5 ff ff       	call   8003ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecc:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800edd:	8b 75 18             	mov    0x18(%ebp),%esi
  800ee0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	7e 17                	jle    800efd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee6:	83 ec 0c             	sub    $0xc,%esp
  800ee9:	50                   	push   %eax
  800eea:	6a 05                	push   $0x5
  800eec:	68 df 2e 80 00       	push   $0x802edf
  800ef1:	6a 23                	push   $0x23
  800ef3:	68 fc 2e 80 00       	push   $0x802efc
  800ef8:	e8 02 f5 ff ff       	call   8003ff <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800efd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
  800f0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f13:	b8 06 00 00 00       	mov    $0x6,%eax
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	89 df                	mov    %ebx,%edi
  800f20:	89 de                	mov    %ebx,%esi
  800f22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f24:	85 c0                	test   %eax,%eax
  800f26:	7e 17                	jle    800f3f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	50                   	push   %eax
  800f2c:	6a 06                	push   $0x6
  800f2e:	68 df 2e 80 00       	push   $0x802edf
  800f33:	6a 23                	push   $0x23
  800f35:	68 fc 2e 80 00       	push   $0x802efc
  800f3a:	e8 c0 f4 ff ff       	call   8003ff <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f42:	5b                   	pop    %ebx
  800f43:	5e                   	pop    %esi
  800f44:	5f                   	pop    %edi
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f55:	b8 08 00 00 00       	mov    $0x8,%eax
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f60:	89 df                	mov    %ebx,%edi
  800f62:	89 de                	mov    %ebx,%esi
  800f64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	7e 17                	jle    800f81 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	50                   	push   %eax
  800f6e:	6a 08                	push   $0x8
  800f70:	68 df 2e 80 00       	push   $0x802edf
  800f75:	6a 23                	push   $0x23
  800f77:	68 fc 2e 80 00       	push   $0x802efc
  800f7c:	e8 7e f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	57                   	push   %edi
  800f8d:	56                   	push   %esi
  800f8e:	53                   	push   %ebx
  800f8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f97:	b8 09 00 00 00       	mov    $0x9,%eax
  800f9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa2:	89 df                	mov    %ebx,%edi
  800fa4:	89 de                	mov    %ebx,%esi
  800fa6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	7e 17                	jle    800fc3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	50                   	push   %eax
  800fb0:	6a 09                	push   $0x9
  800fb2:	68 df 2e 80 00       	push   $0x802edf
  800fb7:	6a 23                	push   $0x23
  800fb9:	68 fc 2e 80 00       	push   $0x802efc
  800fbe:	e8 3c f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
  800fd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe4:	89 df                	mov    %ebx,%edi
  800fe6:	89 de                	mov    %ebx,%esi
  800fe8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	7e 17                	jle    801005 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	50                   	push   %eax
  800ff2:	6a 0a                	push   $0xa
  800ff4:	68 df 2e 80 00       	push   $0x802edf
  800ff9:	6a 23                	push   $0x23
  800ffb:	68 fc 2e 80 00       	push   $0x802efc
  801000:	e8 fa f3 ff ff       	call   8003ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801005:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	57                   	push   %edi
  801011:	56                   	push   %esi
  801012:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801013:	be 00 00 00 00       	mov    $0x0,%esi
  801018:	b8 0c 00 00 00       	mov    $0xc,%eax
  80101d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801020:	8b 55 08             	mov    0x8(%ebp),%edx
  801023:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801026:	8b 7d 14             	mov    0x14(%ebp),%edi
  801029:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	53                   	push   %ebx
  801036:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801039:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801043:	8b 55 08             	mov    0x8(%ebp),%edx
  801046:	89 cb                	mov    %ecx,%ebx
  801048:	89 cf                	mov    %ecx,%edi
  80104a:	89 ce                	mov    %ecx,%esi
  80104c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	7e 17                	jle    801069 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	50                   	push   %eax
  801056:	6a 0d                	push   $0xd
  801058:	68 df 2e 80 00       	push   $0x802edf
  80105d:	6a 23                	push   $0x23
  80105f:	68 fc 2e 80 00       	push   $0x802efc
  801064:	e8 96 f3 ff ff       	call   8003ff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801069:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801077:	ba 00 00 00 00       	mov    $0x0,%edx
  80107c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801081:	89 d1                	mov    %edx,%ecx
  801083:	89 d3                	mov    %edx,%ebx
  801085:	89 d7                	mov    %edx,%edi
  801087:	89 d6                	mov    %edx,%esi
  801089:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	05 00 00 00 30       	add    $0x30000000,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
}
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010c2:	89 c2                	mov    %eax,%edx
  8010c4:	c1 ea 16             	shr    $0x16,%edx
  8010c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ce:	f6 c2 01             	test   $0x1,%dl
  8010d1:	74 11                	je     8010e4 <fd_alloc+0x2d>
  8010d3:	89 c2                	mov    %eax,%edx
  8010d5:	c1 ea 0c             	shr    $0xc,%edx
  8010d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010df:	f6 c2 01             	test   $0x1,%dl
  8010e2:	75 09                	jne    8010ed <fd_alloc+0x36>
			*fd_store = fd;
  8010e4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010eb:	eb 17                	jmp    801104 <fd_alloc+0x4d>
  8010ed:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010f7:	75 c9                	jne    8010c2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    

00801106 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80110c:	83 f8 1f             	cmp    $0x1f,%eax
  80110f:	77 36                	ja     801147 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801111:	c1 e0 0c             	shl    $0xc,%eax
  801114:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801119:	89 c2                	mov    %eax,%edx
  80111b:	c1 ea 16             	shr    $0x16,%edx
  80111e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801125:	f6 c2 01             	test   $0x1,%dl
  801128:	74 24                	je     80114e <fd_lookup+0x48>
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	c1 ea 0c             	shr    $0xc,%edx
  80112f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801136:	f6 c2 01             	test   $0x1,%dl
  801139:	74 1a                	je     801155 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80113b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113e:	89 02                	mov    %eax,(%edx)
	return 0;
  801140:	b8 00 00 00 00       	mov    $0x0,%eax
  801145:	eb 13                	jmp    80115a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801147:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114c:	eb 0c                	jmp    80115a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80114e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801153:	eb 05                	jmp    80115a <fd_lookup+0x54>
  801155:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801165:	ba 88 2f 80 00       	mov    $0x802f88,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80116a:	eb 13                	jmp    80117f <dev_lookup+0x23>
  80116c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80116f:	39 08                	cmp    %ecx,(%eax)
  801171:	75 0c                	jne    80117f <dev_lookup+0x23>
			*dev = devtab[i];
  801173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801176:	89 01                	mov    %eax,(%ecx)
			return 0;
  801178:	b8 00 00 00 00       	mov    $0x0,%eax
  80117d:	eb 2e                	jmp    8011ad <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80117f:	8b 02                	mov    (%edx),%eax
  801181:	85 c0                	test   %eax,%eax
  801183:	75 e7                	jne    80116c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801185:	a1 90 77 80 00       	mov    0x807790,%eax
  80118a:	8b 40 48             	mov    0x48(%eax),%eax
  80118d:	83 ec 04             	sub    $0x4,%esp
  801190:	51                   	push   %ecx
  801191:	50                   	push   %eax
  801192:	68 0c 2f 80 00       	push   $0x802f0c
  801197:	e8 3c f3 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  80119c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80119f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ad:	c9                   	leave  
  8011ae:	c3                   	ret    

008011af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	56                   	push   %esi
  8011b3:	53                   	push   %ebx
  8011b4:	83 ec 10             	sub    $0x10,%esp
  8011b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011c7:	c1 e8 0c             	shr    $0xc,%eax
  8011ca:	50                   	push   %eax
  8011cb:	e8 36 ff ff ff       	call   801106 <fd_lookup>
  8011d0:	83 c4 08             	add    $0x8,%esp
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	78 05                	js     8011dc <fd_close+0x2d>
	    || fd != fd2)
  8011d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011da:	74 0c                	je     8011e8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011dc:	84 db                	test   %bl,%bl
  8011de:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e3:	0f 44 c2             	cmove  %edx,%eax
  8011e6:	eb 41                	jmp    801229 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ee:	50                   	push   %eax
  8011ef:	ff 36                	pushl  (%esi)
  8011f1:	e8 66 ff ff ff       	call   80115c <dev_lookup>
  8011f6:	89 c3                	mov    %eax,%ebx
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 1a                	js     801219 <fd_close+0x6a>
		if (dev->dev_close)
  8011ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801202:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801205:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80120a:	85 c0                	test   %eax,%eax
  80120c:	74 0b                	je     801219 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80120e:	83 ec 0c             	sub    $0xc,%esp
  801211:	56                   	push   %esi
  801212:	ff d0                	call   *%eax
  801214:	89 c3                	mov    %eax,%ebx
  801216:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801219:	83 ec 08             	sub    $0x8,%esp
  80121c:	56                   	push   %esi
  80121d:	6a 00                	push   $0x0
  80121f:	e8 e1 fc ff ff       	call   800f05 <sys_page_unmap>
	return r;
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	89 d8                	mov    %ebx,%eax
}
  801229:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122c:	5b                   	pop    %ebx
  80122d:	5e                   	pop    %esi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801236:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801239:	50                   	push   %eax
  80123a:	ff 75 08             	pushl  0x8(%ebp)
  80123d:	e8 c4 fe ff ff       	call   801106 <fd_lookup>
  801242:	83 c4 08             	add    $0x8,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	78 10                	js     801259 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	6a 01                	push   $0x1
  80124e:	ff 75 f4             	pushl  -0xc(%ebp)
  801251:	e8 59 ff ff ff       	call   8011af <fd_close>
  801256:	83 c4 10             	add    $0x10,%esp
}
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <close_all>:

void
close_all(void)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	53                   	push   %ebx
  80125f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801262:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	53                   	push   %ebx
  80126b:	e8 c0 ff ff ff       	call   801230 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801270:	83 c3 01             	add    $0x1,%ebx
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	83 fb 20             	cmp    $0x20,%ebx
  801279:	75 ec                	jne    801267 <close_all+0xc>
		close(i);
}
  80127b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127e:	c9                   	leave  
  80127f:	c3                   	ret    

00801280 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 2c             	sub    $0x2c,%esp
  801289:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80128c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	ff 75 08             	pushl  0x8(%ebp)
  801293:	e8 6e fe ff ff       	call   801106 <fd_lookup>
  801298:	83 c4 08             	add    $0x8,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	0f 88 c1 00 00 00    	js     801364 <dup+0xe4>
		return r;
	close(newfdnum);
  8012a3:	83 ec 0c             	sub    $0xc,%esp
  8012a6:	56                   	push   %esi
  8012a7:	e8 84 ff ff ff       	call   801230 <close>

	newfd = INDEX2FD(newfdnum);
  8012ac:	89 f3                	mov    %esi,%ebx
  8012ae:	c1 e3 0c             	shl    $0xc,%ebx
  8012b1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012b7:	83 c4 04             	add    $0x4,%esp
  8012ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012bd:	e8 de fd ff ff       	call   8010a0 <fd2data>
  8012c2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012c4:	89 1c 24             	mov    %ebx,(%esp)
  8012c7:	e8 d4 fd ff ff       	call   8010a0 <fd2data>
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012d2:	89 f8                	mov    %edi,%eax
  8012d4:	c1 e8 16             	shr    $0x16,%eax
  8012d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012de:	a8 01                	test   $0x1,%al
  8012e0:	74 37                	je     801319 <dup+0x99>
  8012e2:	89 f8                	mov    %edi,%eax
  8012e4:	c1 e8 0c             	shr    $0xc,%eax
  8012e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ee:	f6 c2 01             	test   $0x1,%dl
  8012f1:	74 26                	je     801319 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012fa:	83 ec 0c             	sub    $0xc,%esp
  8012fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801302:	50                   	push   %eax
  801303:	ff 75 d4             	pushl  -0x2c(%ebp)
  801306:	6a 00                	push   $0x0
  801308:	57                   	push   %edi
  801309:	6a 00                	push   $0x0
  80130b:	e8 b3 fb ff ff       	call   800ec3 <sys_page_map>
  801310:	89 c7                	mov    %eax,%edi
  801312:	83 c4 20             	add    $0x20,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 2e                	js     801347 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801319:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80131c:	89 d0                	mov    %edx,%eax
  80131e:	c1 e8 0c             	shr    $0xc,%eax
  801321:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801328:	83 ec 0c             	sub    $0xc,%esp
  80132b:	25 07 0e 00 00       	and    $0xe07,%eax
  801330:	50                   	push   %eax
  801331:	53                   	push   %ebx
  801332:	6a 00                	push   $0x0
  801334:	52                   	push   %edx
  801335:	6a 00                	push   $0x0
  801337:	e8 87 fb ff ff       	call   800ec3 <sys_page_map>
  80133c:	89 c7                	mov    %eax,%edi
  80133e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801341:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801343:	85 ff                	test   %edi,%edi
  801345:	79 1d                	jns    801364 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	53                   	push   %ebx
  80134b:	6a 00                	push   $0x0
  80134d:	e8 b3 fb ff ff       	call   800f05 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801352:	83 c4 08             	add    $0x8,%esp
  801355:	ff 75 d4             	pushl  -0x2c(%ebp)
  801358:	6a 00                	push   $0x0
  80135a:	e8 a6 fb ff ff       	call   800f05 <sys_page_unmap>
	return r;
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	89 f8                	mov    %edi,%eax
}
  801364:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801367:	5b                   	pop    %ebx
  801368:	5e                   	pop    %esi
  801369:	5f                   	pop    %edi
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    

0080136c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	53                   	push   %ebx
  801370:	83 ec 14             	sub    $0x14,%esp
  801373:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801376:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	53                   	push   %ebx
  80137b:	e8 86 fd ff ff       	call   801106 <fd_lookup>
  801380:	83 c4 08             	add    $0x8,%esp
  801383:	89 c2                	mov    %eax,%edx
  801385:	85 c0                	test   %eax,%eax
  801387:	78 6d                	js     8013f6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801393:	ff 30                	pushl  (%eax)
  801395:	e8 c2 fd ff ff       	call   80115c <dev_lookup>
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 4c                	js     8013ed <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013a4:	8b 42 08             	mov    0x8(%edx),%eax
  8013a7:	83 e0 03             	and    $0x3,%eax
  8013aa:	83 f8 01             	cmp    $0x1,%eax
  8013ad:	75 21                	jne    8013d0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013af:	a1 90 77 80 00       	mov    0x807790,%eax
  8013b4:	8b 40 48             	mov    0x48(%eax),%eax
  8013b7:	83 ec 04             	sub    $0x4,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	50                   	push   %eax
  8013bc:	68 4d 2f 80 00       	push   $0x802f4d
  8013c1:	e8 12 f1 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ce:	eb 26                	jmp    8013f6 <read+0x8a>
	}
	if (!dev->dev_read)
  8013d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d3:	8b 40 08             	mov    0x8(%eax),%eax
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	74 17                	je     8013f1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013da:	83 ec 04             	sub    $0x4,%esp
  8013dd:	ff 75 10             	pushl  0x10(%ebp)
  8013e0:	ff 75 0c             	pushl  0xc(%ebp)
  8013e3:	52                   	push   %edx
  8013e4:	ff d0                	call   *%eax
  8013e6:	89 c2                	mov    %eax,%edx
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	eb 09                	jmp    8013f6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ed:	89 c2                	mov    %eax,%edx
  8013ef:	eb 05                	jmp    8013f6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013f6:	89 d0                	mov    %edx,%eax
  8013f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fb:	c9                   	leave  
  8013fc:	c3                   	ret    

008013fd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	57                   	push   %edi
  801401:	56                   	push   %esi
  801402:	53                   	push   %ebx
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	8b 7d 08             	mov    0x8(%ebp),%edi
  801409:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80140c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801411:	eb 21                	jmp    801434 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801413:	83 ec 04             	sub    $0x4,%esp
  801416:	89 f0                	mov    %esi,%eax
  801418:	29 d8                	sub    %ebx,%eax
  80141a:	50                   	push   %eax
  80141b:	89 d8                	mov    %ebx,%eax
  80141d:	03 45 0c             	add    0xc(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	57                   	push   %edi
  801422:	e8 45 ff ff ff       	call   80136c <read>
		if (m < 0)
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 10                	js     80143e <readn+0x41>
			return m;
		if (m == 0)
  80142e:	85 c0                	test   %eax,%eax
  801430:	74 0a                	je     80143c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801432:	01 c3                	add    %eax,%ebx
  801434:	39 f3                	cmp    %esi,%ebx
  801436:	72 db                	jb     801413 <readn+0x16>
  801438:	89 d8                	mov    %ebx,%eax
  80143a:	eb 02                	jmp    80143e <readn+0x41>
  80143c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80143e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801441:	5b                   	pop    %ebx
  801442:	5e                   	pop    %esi
  801443:	5f                   	pop    %edi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    

00801446 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	53                   	push   %ebx
  80144a:	83 ec 14             	sub    $0x14,%esp
  80144d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801450:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801453:	50                   	push   %eax
  801454:	53                   	push   %ebx
  801455:	e8 ac fc ff ff       	call   801106 <fd_lookup>
  80145a:	83 c4 08             	add    $0x8,%esp
  80145d:	89 c2                	mov    %eax,%edx
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 68                	js     8014cb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146d:	ff 30                	pushl  (%eax)
  80146f:	e8 e8 fc ff ff       	call   80115c <dev_lookup>
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	85 c0                	test   %eax,%eax
  801479:	78 47                	js     8014c2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80147b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801482:	75 21                	jne    8014a5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801484:	a1 90 77 80 00       	mov    0x807790,%eax
  801489:	8b 40 48             	mov    0x48(%eax),%eax
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	53                   	push   %ebx
  801490:	50                   	push   %eax
  801491:	68 69 2f 80 00       	push   $0x802f69
  801496:	e8 3d f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014a3:	eb 26                	jmp    8014cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ab:	85 d2                	test   %edx,%edx
  8014ad:	74 17                	je     8014c6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014af:	83 ec 04             	sub    $0x4,%esp
  8014b2:	ff 75 10             	pushl  0x10(%ebp)
  8014b5:	ff 75 0c             	pushl  0xc(%ebp)
  8014b8:	50                   	push   %eax
  8014b9:	ff d2                	call   *%edx
  8014bb:	89 c2                	mov    %eax,%edx
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	eb 09                	jmp    8014cb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c2:	89 c2                	mov    %eax,%edx
  8014c4:	eb 05                	jmp    8014cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014cb:	89 d0                	mov    %edx,%eax
  8014cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    

008014d2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	ff 75 08             	pushl  0x8(%ebp)
  8014df:	e8 22 fc ff ff       	call   801106 <fd_lookup>
  8014e4:	83 c4 08             	add    $0x8,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 0e                	js     8014f9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f9:	c9                   	leave  
  8014fa:	c3                   	ret    

008014fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	53                   	push   %ebx
  8014ff:	83 ec 14             	sub    $0x14,%esp
  801502:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801505:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	53                   	push   %ebx
  80150a:	e8 f7 fb ff ff       	call   801106 <fd_lookup>
  80150f:	83 c4 08             	add    $0x8,%esp
  801512:	89 c2                	mov    %eax,%edx
  801514:	85 c0                	test   %eax,%eax
  801516:	78 65                	js     80157d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801518:	83 ec 08             	sub    $0x8,%esp
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801522:	ff 30                	pushl  (%eax)
  801524:	e8 33 fc ff ff       	call   80115c <dev_lookup>
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 44                	js     801574 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801530:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801533:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801537:	75 21                	jne    80155a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801539:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80153e:	8b 40 48             	mov    0x48(%eax),%eax
  801541:	83 ec 04             	sub    $0x4,%esp
  801544:	53                   	push   %ebx
  801545:	50                   	push   %eax
  801546:	68 2c 2f 80 00       	push   $0x802f2c
  80154b:	e8 88 ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801558:	eb 23                	jmp    80157d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80155a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155d:	8b 52 18             	mov    0x18(%edx),%edx
  801560:	85 d2                	test   %edx,%edx
  801562:	74 14                	je     801578 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	ff 75 0c             	pushl  0xc(%ebp)
  80156a:	50                   	push   %eax
  80156b:	ff d2                	call   *%edx
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	eb 09                	jmp    80157d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801574:	89 c2                	mov    %eax,%edx
  801576:	eb 05                	jmp    80157d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801578:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80157d:	89 d0                	mov    %edx,%eax
  80157f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801582:	c9                   	leave  
  801583:	c3                   	ret    

00801584 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	53                   	push   %ebx
  801588:	83 ec 14             	sub    $0x14,%esp
  80158b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	ff 75 08             	pushl  0x8(%ebp)
  801595:	e8 6c fb ff ff       	call   801106 <fd_lookup>
  80159a:	83 c4 08             	add    $0x8,%esp
  80159d:	89 c2                	mov    %eax,%edx
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 58                	js     8015fb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	ff 30                	pushl  (%eax)
  8015af:	e8 a8 fb ff ff       	call   80115c <dev_lookup>
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 37                	js     8015f2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015c2:	74 32                	je     8015f6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ce:	00 00 00 
	stat->st_isdir = 0;
  8015d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d8:	00 00 00 
	stat->st_dev = dev;
  8015db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	53                   	push   %ebx
  8015e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e8:	ff 50 14             	call   *0x14(%eax)
  8015eb:	89 c2                	mov    %eax,%edx
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	eb 09                	jmp    8015fb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f2:	89 c2                	mov    %eax,%edx
  8015f4:	eb 05                	jmp    8015fb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015fb:	89 d0                	mov    %edx,%eax
  8015fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801600:	c9                   	leave  
  801601:	c3                   	ret    

00801602 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	56                   	push   %esi
  801606:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	6a 00                	push   $0x0
  80160c:	ff 75 08             	pushl  0x8(%ebp)
  80160f:	e8 ef 01 00 00       	call   801803 <open>
  801614:	89 c3                	mov    %eax,%ebx
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 1b                	js     801638 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	ff 75 0c             	pushl  0xc(%ebp)
  801623:	50                   	push   %eax
  801624:	e8 5b ff ff ff       	call   801584 <fstat>
  801629:	89 c6                	mov    %eax,%esi
	close(fd);
  80162b:	89 1c 24             	mov    %ebx,(%esp)
  80162e:	e8 fd fb ff ff       	call   801230 <close>
	return r;
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	89 f0                	mov    %esi,%eax
}
  801638:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	89 c6                	mov    %eax,%esi
  801646:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801648:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80164f:	75 12                	jne    801663 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801651:	83 ec 0c             	sub    $0xc,%esp
  801654:	6a 01                	push   $0x1
  801656:	e8 ed 10 00 00       	call   802748 <ipc_find_env>
  80165b:	a3 00 60 80 00       	mov    %eax,0x806000
  801660:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801663:	6a 07                	push   $0x7
  801665:	68 00 80 80 00       	push   $0x808000
  80166a:	56                   	push   %esi
  80166b:	ff 35 00 60 80 00    	pushl  0x806000
  801671:	e8 83 10 00 00       	call   8026f9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801676:	83 c4 0c             	add    $0xc,%esp
  801679:	6a 00                	push   $0x0
  80167b:	53                   	push   %ebx
  80167c:	6a 00                	push   $0x0
  80167e:	e8 00 10 00 00       	call   802683 <ipc_recv>
}
  801683:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801686:	5b                   	pop    %ebx
  801687:	5e                   	pop    %esi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    

0080168a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801690:	8b 45 08             	mov    0x8(%ebp),%eax
  801693:	8b 40 0c             	mov    0xc(%eax),%eax
  801696:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.set_size.req_size = newsize;
  80169b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169e:	a3 04 80 80 00       	mov    %eax,0x808004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ad:	e8 8d ff ff ff       	call   80163f <fsipc>
}
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c0:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  8016c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8016cf:	e8 6b ff ff ff       	call   80163f <fsipc>
}
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e6:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f5:	e8 45 ff ff ff       	call   80163f <fsipc>
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 2c                	js     80172a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016fe:	83 ec 08             	sub    $0x8,%esp
  801701:	68 00 80 80 00       	push   $0x808000
  801706:	53                   	push   %ebx
  801707:	e8 71 f3 ff ff       	call   800a7d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80170c:	a1 80 80 80 00       	mov    0x808080,%eax
  801711:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801717:	a1 84 80 80 00       	mov    0x808084,%eax
  80171c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80172a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	53                   	push   %ebx
  801733:	83 ec 08             	sub    $0x8,%esp
  801736:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801739:	8b 55 08             	mov    0x8(%ebp),%edx
  80173c:	8b 52 0c             	mov    0xc(%edx),%edx
  80173f:	89 15 00 80 80 00    	mov    %edx,0x808000
	fsipcbuf.write.req_n = n;
  801745:	a3 04 80 80 00       	mov    %eax,0x808004
  80174a:	3d 08 80 80 00       	cmp    $0x808008,%eax
  80174f:	bb 08 80 80 00       	mov    $0x808008,%ebx
  801754:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801757:	53                   	push   %ebx
  801758:	ff 75 0c             	pushl  0xc(%ebp)
  80175b:	68 08 80 80 00       	push   $0x808008
  801760:	e8 aa f4 ff ff       	call   800c0f <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801765:	ba 00 00 00 00       	mov    $0x0,%edx
  80176a:	b8 04 00 00 00       	mov    $0x4,%eax
  80176f:	e8 cb fe ff ff       	call   80163f <fsipc>
  801774:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801777:	85 c0                	test   %eax,%eax
  801779:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  80177c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801789:	8b 45 08             	mov    0x8(%ebp),%eax
  80178c:	8b 40 0c             	mov    0xc(%eax),%eax
  80178f:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801794:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80179a:	ba 00 00 00 00       	mov    $0x0,%edx
  80179f:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a4:	e8 96 fe ff ff       	call   80163f <fsipc>
  8017a9:	89 c3                	mov    %eax,%ebx
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 4b                	js     8017fa <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017af:	39 c6                	cmp    %eax,%esi
  8017b1:	73 16                	jae    8017c9 <devfile_read+0x48>
  8017b3:	68 9c 2f 80 00       	push   $0x802f9c
  8017b8:	68 a3 2f 80 00       	push   $0x802fa3
  8017bd:	6a 7c                	push   $0x7c
  8017bf:	68 b8 2f 80 00       	push   $0x802fb8
  8017c4:	e8 36 ec ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  8017c9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ce:	7e 16                	jle    8017e6 <devfile_read+0x65>
  8017d0:	68 c3 2f 80 00       	push   $0x802fc3
  8017d5:	68 a3 2f 80 00       	push   $0x802fa3
  8017da:	6a 7d                	push   $0x7d
  8017dc:	68 b8 2f 80 00       	push   $0x802fb8
  8017e1:	e8 19 ec ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e6:	83 ec 04             	sub    $0x4,%esp
  8017e9:	50                   	push   %eax
  8017ea:	68 00 80 80 00       	push   $0x808000
  8017ef:	ff 75 0c             	pushl  0xc(%ebp)
  8017f2:	e8 18 f4 ff ff       	call   800c0f <memmove>
	return r;
  8017f7:	83 c4 10             	add    $0x10,%esp
}
  8017fa:	89 d8                	mov    %ebx,%eax
  8017fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ff:	5b                   	pop    %ebx
  801800:	5e                   	pop    %esi
  801801:	5d                   	pop    %ebp
  801802:	c3                   	ret    

00801803 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	53                   	push   %ebx
  801807:	83 ec 20             	sub    $0x20,%esp
  80180a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80180d:	53                   	push   %ebx
  80180e:	e8 31 f2 ff ff       	call   800a44 <strlen>
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80181b:	7f 67                	jg     801884 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80181d:	83 ec 0c             	sub    $0xc,%esp
  801820:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801823:	50                   	push   %eax
  801824:	e8 8e f8 ff ff       	call   8010b7 <fd_alloc>
  801829:	83 c4 10             	add    $0x10,%esp
		return r;
  80182c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182e:	85 c0                	test   %eax,%eax
  801830:	78 57                	js     801889 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801832:	83 ec 08             	sub    $0x8,%esp
  801835:	53                   	push   %ebx
  801836:	68 00 80 80 00       	push   $0x808000
  80183b:	e8 3d f2 ff ff       	call   800a7d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801840:	8b 45 0c             	mov    0xc(%ebp),%eax
  801843:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801848:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184b:	b8 01 00 00 00       	mov    $0x1,%eax
  801850:	e8 ea fd ff ff       	call   80163f <fsipc>
  801855:	89 c3                	mov    %eax,%ebx
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	85 c0                	test   %eax,%eax
  80185c:	79 14                	jns    801872 <open+0x6f>
		fd_close(fd, 0);
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	6a 00                	push   $0x0
  801863:	ff 75 f4             	pushl  -0xc(%ebp)
  801866:	e8 44 f9 ff ff       	call   8011af <fd_close>
		return r;
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	89 da                	mov    %ebx,%edx
  801870:	eb 17                	jmp    801889 <open+0x86>
	}

	return fd2num(fd);
  801872:	83 ec 0c             	sub    $0xc,%esp
  801875:	ff 75 f4             	pushl  -0xc(%ebp)
  801878:	e8 13 f8 ff ff       	call   801090 <fd2num>
  80187d:	89 c2                	mov    %eax,%edx
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	eb 05                	jmp    801889 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801884:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801889:	89 d0                	mov    %edx,%eax
  80188b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801896:	ba 00 00 00 00       	mov    $0x0,%edx
  80189b:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a0:	e8 9a fd ff ff       	call   80163f <fsipc>
}
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	57                   	push   %edi
  8018ab:	56                   	push   %esi
  8018ac:	53                   	push   %ebx
  8018ad:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018b3:	6a 00                	push   $0x0
  8018b5:	ff 75 08             	pushl  0x8(%ebp)
  8018b8:	e8 46 ff ff ff       	call   801803 <open>
  8018bd:	89 c7                	mov    %eax,%edi
  8018bf:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	0f 88 81 04 00 00    	js     801d51 <spawn+0x4aa>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018d0:	83 ec 04             	sub    $0x4,%esp
  8018d3:	68 00 02 00 00       	push   $0x200
  8018d8:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018de:	50                   	push   %eax
  8018df:	57                   	push   %edi
  8018e0:	e8 18 fb ff ff       	call   8013fd <readn>
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018ed:	75 0c                	jne    8018fb <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018ef:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018f6:	45 4c 46 
  8018f9:	74 33                	je     80192e <spawn+0x87>
		close(fd);
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801904:	e8 27 f9 ff ff       	call   801230 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801909:	83 c4 0c             	add    $0xc,%esp
  80190c:	68 7f 45 4c 46       	push   $0x464c457f
  801911:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801917:	68 cf 2f 80 00       	push   $0x802fcf
  80191c:	e8 b7 eb ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801929:	e9 c6 04 00 00       	jmp    801df4 <spawn+0x54d>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80192e:	b8 07 00 00 00       	mov    $0x7,%eax
  801933:	cd 30                	int    $0x30
  801935:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80193b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801941:	85 c0                	test   %eax,%eax
  801943:	0f 88 13 04 00 00    	js     801d5c <spawn+0x4b5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801949:	89 c6                	mov    %eax,%esi
  80194b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801951:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801954:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80195a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801960:	b9 11 00 00 00       	mov    $0x11,%ecx
  801965:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801967:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80196d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801973:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801978:	be 00 00 00 00       	mov    $0x0,%esi
  80197d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801980:	eb 13                	jmp    801995 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	50                   	push   %eax
  801986:	e8 b9 f0 ff ff       	call   800a44 <strlen>
  80198b:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80198f:	83 c3 01             	add    $0x1,%ebx
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80199c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	75 df                	jne    801982 <spawn+0xdb>
  8019a3:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019a9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019af:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019b4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019b6:	89 fa                	mov    %edi,%edx
  8019b8:	83 e2 fc             	and    $0xfffffffc,%edx
  8019bb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019c2:	29 c2                	sub    %eax,%edx
  8019c4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019ca:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019cd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019d2:	0f 86 9a 03 00 00    	jbe    801d72 <spawn+0x4cb>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019d8:	83 ec 04             	sub    $0x4,%esp
  8019db:	6a 07                	push   $0x7
  8019dd:	68 00 00 40 00       	push   $0x400000
  8019e2:	6a 00                	push   $0x0
  8019e4:	e8 97 f4 ff ff       	call   800e80 <sys_page_alloc>
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	0f 88 85 03 00 00    	js     801d79 <spawn+0x4d2>
  8019f4:	be 00 00 00 00       	mov    $0x0,%esi
  8019f9:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a02:	eb 30                	jmp    801a34 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a04:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a0a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a10:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a13:	83 ec 08             	sub    $0x8,%esp
  801a16:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a19:	57                   	push   %edi
  801a1a:	e8 5e f0 ff ff       	call   800a7d <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a1f:	83 c4 04             	add    $0x4,%esp
  801a22:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a25:	e8 1a f0 ff ff       	call   800a44 <strlen>
  801a2a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a2e:	83 c6 01             	add    $0x1,%esi
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a3a:	7f c8                	jg     801a04 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a3c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a42:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801a48:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a4f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a55:	74 19                	je     801a70 <spawn+0x1c9>
  801a57:	68 5c 30 80 00       	push   $0x80305c
  801a5c:	68 a3 2f 80 00       	push   $0x802fa3
  801a61:	68 f1 00 00 00       	push   $0xf1
  801a66:	68 e9 2f 80 00       	push   $0x802fe9
  801a6b:	e8 8f e9 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a70:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a76:	89 f8                	mov    %edi,%eax
  801a78:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a7d:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a80:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a86:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a89:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a8f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	6a 07                	push   $0x7
  801a9a:	68 00 d0 bf ee       	push   $0xeebfd000
  801a9f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aa5:	68 00 00 40 00       	push   $0x400000
  801aaa:	6a 00                	push   $0x0
  801aac:	e8 12 f4 ff ff       	call   800ec3 <sys_page_map>
  801ab1:	89 c3                	mov    %eax,%ebx
  801ab3:	83 c4 20             	add    $0x20,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	0f 88 24 03 00 00    	js     801de2 <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801abe:	83 ec 08             	sub    $0x8,%esp
  801ac1:	68 00 00 40 00       	push   $0x400000
  801ac6:	6a 00                	push   $0x0
  801ac8:	e8 38 f4 ff ff       	call   800f05 <sys_page_unmap>
  801acd:	89 c3                	mov    %eax,%ebx
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	0f 88 08 03 00 00    	js     801de2 <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ada:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ae0:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ae7:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801aed:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801af4:	00 00 00 
  801af7:	e9 8a 01 00 00       	jmp    801c86 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801afc:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b02:	83 38 01             	cmpl   $0x1,(%eax)
  801b05:	0f 85 6d 01 00 00    	jne    801c78 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b0b:	89 c7                	mov    %eax,%edi
  801b0d:	8b 40 18             	mov    0x18(%eax),%eax
  801b10:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b16:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b19:	83 f8 01             	cmp    $0x1,%eax
  801b1c:	19 c0                	sbb    %eax,%eax
  801b1e:	83 e0 fe             	and    $0xfffffffe,%eax
  801b21:	83 c0 07             	add    $0x7,%eax
  801b24:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b2a:	89 f8                	mov    %edi,%eax
  801b2c:	8b 7f 04             	mov    0x4(%edi),%edi
  801b2f:	89 f9                	mov    %edi,%ecx
  801b31:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b37:	8b 78 10             	mov    0x10(%eax),%edi
  801b3a:	8b 70 14             	mov    0x14(%eax),%esi
  801b3d:	89 f2                	mov    %esi,%edx
  801b3f:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801b45:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b48:	89 f0                	mov    %esi,%eax
  801b4a:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b4f:	74 14                	je     801b65 <spawn+0x2be>
		va -= i;
  801b51:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b53:	01 c2                	add    %eax,%edx
  801b55:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b5b:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b5d:	29 c1                	sub    %eax,%ecx
  801b5f:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b65:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b6a:	e9 f7 00 00 00       	jmp    801c66 <spawn+0x3bf>
		if (i >= filesz) {
  801b6f:	39 df                	cmp    %ebx,%edi
  801b71:	77 27                	ja     801b9a <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b73:	83 ec 04             	sub    $0x4,%esp
  801b76:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b7c:	56                   	push   %esi
  801b7d:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b83:	e8 f8 f2 ff ff       	call   800e80 <sys_page_alloc>
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	0f 89 c7 00 00 00    	jns    801c5a <spawn+0x3b3>
  801b93:	89 c3                	mov    %eax,%ebx
  801b95:	e9 ed 01 00 00       	jmp    801d87 <spawn+0x4e0>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b9a:	83 ec 04             	sub    $0x4,%esp
  801b9d:	6a 07                	push   $0x7
  801b9f:	68 00 00 40 00       	push   $0x400000
  801ba4:	6a 00                	push   $0x0
  801ba6:	e8 d5 f2 ff ff       	call   800e80 <sys_page_alloc>
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	0f 88 c7 01 00 00    	js     801d7d <spawn+0x4d6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bb6:	83 ec 08             	sub    $0x8,%esp
  801bb9:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bbf:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bc5:	50                   	push   %eax
  801bc6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bcc:	e8 01 f9 ff ff       	call   8014d2 <seek>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	0f 88 a5 01 00 00    	js     801d81 <spawn+0x4da>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bdc:	83 ec 04             	sub    $0x4,%esp
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801be7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bec:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801bf1:	0f 47 c1             	cmova  %ecx,%eax
  801bf4:	50                   	push   %eax
  801bf5:	68 00 00 40 00       	push   $0x400000
  801bfa:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c00:	e8 f8 f7 ff ff       	call   8013fd <readn>
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	0f 88 75 01 00 00    	js     801d85 <spawn+0x4de>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c10:	83 ec 0c             	sub    $0xc,%esp
  801c13:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c19:	56                   	push   %esi
  801c1a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c20:	68 00 00 40 00       	push   $0x400000
  801c25:	6a 00                	push   $0x0
  801c27:	e8 97 f2 ff ff       	call   800ec3 <sys_page_map>
  801c2c:	83 c4 20             	add    $0x20,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	79 15                	jns    801c48 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801c33:	50                   	push   %eax
  801c34:	68 f5 2f 80 00       	push   $0x802ff5
  801c39:	68 24 01 00 00       	push   $0x124
  801c3e:	68 e9 2f 80 00       	push   $0x802fe9
  801c43:	e8 b7 e7 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801c48:	83 ec 08             	sub    $0x8,%esp
  801c4b:	68 00 00 40 00       	push   $0x400000
  801c50:	6a 00                	push   $0x0
  801c52:	e8 ae f2 ff ff       	call   800f05 <sys_page_unmap>
  801c57:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c5a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c60:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c66:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c6c:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c72:	0f 87 f7 fe ff ff    	ja     801b6f <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c78:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c7f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c86:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c8d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c93:	0f 8c 63 fe ff ff    	jl     801afc <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c99:	83 ec 0c             	sub    $0xc,%esp
  801c9c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ca2:	e8 89 f5 ff ff       	call   801230 <close>
  801ca7:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  801caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801caf:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  801cb5:	89 d8                	mov    %ebx,%eax
  801cb7:	c1 e0 0c             	shl    $0xc,%eax
		if (((uvpd[PDX(pgnum*PGSIZE)] & PTE_P) && (uvpt[pgnum] & PTE_P) && (uvpt[pgnum] & PTE_SHARE))){
  801cba:	89 c2                	mov    %eax,%edx
  801cbc:	c1 ea 16             	shr    $0x16,%edx
  801cbf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cc6:	f6 c2 01             	test   $0x1,%dl
  801cc9:	74 35                	je     801d00 <spawn+0x459>
  801ccb:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801cd2:	f6 c2 01             	test   $0x1,%dl
  801cd5:	74 29                	je     801d00 <spawn+0x459>
  801cd7:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801cde:	f6 c6 04             	test   $0x4,%dh
  801ce1:	74 1d                	je     801d00 <spawn+0x459>
			if((r=sys_page_map(0, (void *)(pgnum*PGSIZE), child, (void *)(pgnum*PGSIZE), PTE_SYSCALL))<0)
  801ce3:	83 ec 0c             	sub    $0xc,%esp
  801ce6:	68 07 0e 00 00       	push   $0xe07
  801ceb:	50                   	push   %eax
  801cec:	56                   	push   %esi
  801ced:	50                   	push   %eax
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 ce f1 ff ff       	call   800ec3 <sys_page_map>
  801cf5:	83 c4 20             	add    $0x20,%esp
  801cf8:	85 c0                	test   %eax,%eax
  801cfa:	0f 88 a8 00 00 00    	js     801da8 <spawn+0x501>
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  801d00:	83 c3 01             	add    $0x1,%ebx
  801d03:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  801d09:	75 aa                	jne    801cb5 <spawn+0x40e>
  801d0b:	e9 ad 00 00 00       	jmp    801dbd <spawn+0x516>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801d10:	50                   	push   %eax
  801d11:	68 12 30 80 00       	push   $0x803012
  801d16:	68 85 00 00 00       	push   $0x85
  801d1b:	68 e9 2f 80 00       	push   $0x802fe9
  801d20:	e8 da e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d25:	83 ec 08             	sub    $0x8,%esp
  801d28:	6a 02                	push   $0x2
  801d2a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d30:	e8 12 f2 ff ff       	call   800f47 <sys_env_set_status>
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	79 2b                	jns    801d67 <spawn+0x4c0>
		panic("sys_env_set_status: %e", r);
  801d3c:	50                   	push   %eax
  801d3d:	68 2c 30 80 00       	push   $0x80302c
  801d42:	68 88 00 00 00       	push   $0x88
  801d47:	68 e9 2f 80 00       	push   $0x802fe9
  801d4c:	e8 ae e6 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d51:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d57:	e9 98 00 00 00       	jmp    801df4 <spawn+0x54d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d5c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d62:	e9 8d 00 00 00       	jmp    801df4 <spawn+0x54d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d67:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d6d:	e9 82 00 00 00       	jmp    801df4 <spawn+0x54d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d72:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d77:	eb 7b                	jmp    801df4 <spawn+0x54d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	eb 77                	jmp    801df4 <spawn+0x54d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d7d:	89 c3                	mov    %eax,%ebx
  801d7f:	eb 06                	jmp    801d87 <spawn+0x4e0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	eb 02                	jmp    801d87 <spawn+0x4e0>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d85:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801d87:	83 ec 0c             	sub    $0xc,%esp
  801d8a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d90:	e8 6c f0 ff ff       	call   800e01 <sys_env_destroy>
	close(fd);
  801d95:	83 c4 04             	add    $0x4,%esp
  801d98:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d9e:	e8 8d f4 ff ff       	call   801230 <close>
	return r;
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	eb 4c                	jmp    801df4 <spawn+0x54d>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801da8:	50                   	push   %eax
  801da9:	68 43 30 80 00       	push   $0x803043
  801dae:	68 82 00 00 00       	push   $0x82
  801db3:	68 e9 2f 80 00       	push   $0x802fe9
  801db8:	e8 42 e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801dbd:	83 ec 08             	sub    $0x8,%esp
  801dc0:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801dc6:	50                   	push   %eax
  801dc7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dcd:	e8 b7 f1 ff ff       	call   800f89 <sys_env_set_trapframe>
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	0f 89 48 ff ff ff    	jns    801d25 <spawn+0x47e>
  801ddd:	e9 2e ff ff ff       	jmp    801d10 <spawn+0x469>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801de2:	83 ec 08             	sub    $0x8,%esp
  801de5:	68 00 00 40 00       	push   $0x400000
  801dea:	6a 00                	push   $0x0
  801dec:	e8 14 f1 ff ff       	call   800f05 <sys_page_unmap>
  801df1:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801df4:	89 d8                	mov    %ebx,%eax
  801df6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df9:	5b                   	pop    %ebx
  801dfa:	5e                   	pop    %esi
  801dfb:	5f                   	pop    %edi
  801dfc:	5d                   	pop    %ebp
  801dfd:	c3                   	ret    

00801dfe <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	56                   	push   %esi
  801e02:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e03:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e06:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e0b:	eb 03                	jmp    801e10 <spawnl+0x12>
		argc++;
  801e0d:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e10:	83 c2 04             	add    $0x4,%edx
  801e13:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e17:	75 f4                	jne    801e0d <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e19:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e20:	83 e2 f0             	and    $0xfffffff0,%edx
  801e23:	29 d4                	sub    %edx,%esp
  801e25:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e29:	c1 ea 02             	shr    $0x2,%edx
  801e2c:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e33:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e38:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e3f:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e46:	00 
  801e47:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e49:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4e:	eb 0a                	jmp    801e5a <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e50:	83 c0 01             	add    $0x1,%eax
  801e53:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e57:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e5a:	39 d0                	cmp    %edx,%eax
  801e5c:	75 f2                	jne    801e50 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e5e:	83 ec 08             	sub    $0x8,%esp
  801e61:	56                   	push   %esi
  801e62:	ff 75 08             	pushl  0x8(%ebp)
  801e65:	e8 3d fa ff ff       	call   8018a7 <spawn>
}
  801e6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e6d:	5b                   	pop    %ebx
  801e6e:	5e                   	pop    %esi
  801e6f:	5d                   	pop    %ebp
  801e70:	c3                   	ret    

00801e71 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	56                   	push   %esi
  801e75:	53                   	push   %ebx
  801e76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e79:	83 ec 0c             	sub    $0xc,%esp
  801e7c:	ff 75 08             	pushl  0x8(%ebp)
  801e7f:	e8 1c f2 ff ff       	call   8010a0 <fd2data>
  801e84:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e86:	83 c4 08             	add    $0x8,%esp
  801e89:	68 84 30 80 00       	push   $0x803084
  801e8e:	53                   	push   %ebx
  801e8f:	e8 e9 eb ff ff       	call   800a7d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e94:	8b 46 04             	mov    0x4(%esi),%eax
  801e97:	2b 06                	sub    (%esi),%eax
  801e99:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e9f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ea6:	00 00 00 
	stat->st_dev = &devpipe;
  801ea9:	c7 83 88 00 00 00 ac 	movl   $0x8057ac,0x88(%ebx)
  801eb0:	57 80 00 
	return 0;
}
  801eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebb:	5b                   	pop    %ebx
  801ebc:	5e                   	pop    %esi
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	53                   	push   %ebx
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ec9:	53                   	push   %ebx
  801eca:	6a 00                	push   $0x0
  801ecc:	e8 34 f0 ff ff       	call   800f05 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ed1:	89 1c 24             	mov    %ebx,(%esp)
  801ed4:	e8 c7 f1 ff ff       	call   8010a0 <fd2data>
  801ed9:	83 c4 08             	add    $0x8,%esp
  801edc:	50                   	push   %eax
  801edd:	6a 00                	push   $0x0
  801edf:	e8 21 f0 ff ff       	call   800f05 <sys_page_unmap>
}
  801ee4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee7:	c9                   	leave  
  801ee8:	c3                   	ret    

00801ee9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	57                   	push   %edi
  801eed:	56                   	push   %esi
  801eee:	53                   	push   %ebx
  801eef:	83 ec 1c             	sub    $0x1c,%esp
  801ef2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ef5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ef7:	a1 90 77 80 00       	mov    0x807790,%eax
  801efc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801eff:	83 ec 0c             	sub    $0xc,%esp
  801f02:	ff 75 e0             	pushl  -0x20(%ebp)
  801f05:	e8 77 08 00 00       	call   802781 <pageref>
  801f0a:	89 c3                	mov    %eax,%ebx
  801f0c:	89 3c 24             	mov    %edi,(%esp)
  801f0f:	e8 6d 08 00 00       	call   802781 <pageref>
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	39 c3                	cmp    %eax,%ebx
  801f19:	0f 94 c1             	sete   %cl
  801f1c:	0f b6 c9             	movzbl %cl,%ecx
  801f1f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f22:	8b 15 90 77 80 00    	mov    0x807790,%edx
  801f28:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f2b:	39 ce                	cmp    %ecx,%esi
  801f2d:	74 1b                	je     801f4a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f2f:	39 c3                	cmp    %eax,%ebx
  801f31:	75 c4                	jne    801ef7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f33:	8b 42 58             	mov    0x58(%edx),%eax
  801f36:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f39:	50                   	push   %eax
  801f3a:	56                   	push   %esi
  801f3b:	68 8b 30 80 00       	push   $0x80308b
  801f40:	e8 93 e5 ff ff       	call   8004d8 <cprintf>
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	eb ad                	jmp    801ef7 <_pipeisclosed+0xe>
	}
}
  801f4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f50:	5b                   	pop    %ebx
  801f51:	5e                   	pop    %esi
  801f52:	5f                   	pop    %edi
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	57                   	push   %edi
  801f59:	56                   	push   %esi
  801f5a:	53                   	push   %ebx
  801f5b:	83 ec 28             	sub    $0x28,%esp
  801f5e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f61:	56                   	push   %esi
  801f62:	e8 39 f1 ff ff       	call   8010a0 <fd2data>
  801f67:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	bf 00 00 00 00       	mov    $0x0,%edi
  801f71:	eb 4b                	jmp    801fbe <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f73:	89 da                	mov    %ebx,%edx
  801f75:	89 f0                	mov    %esi,%eax
  801f77:	e8 6d ff ff ff       	call   801ee9 <_pipeisclosed>
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	75 48                	jne    801fc8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f80:	e8 dc ee ff ff       	call   800e61 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f85:	8b 43 04             	mov    0x4(%ebx),%eax
  801f88:	8b 0b                	mov    (%ebx),%ecx
  801f8a:	8d 51 20             	lea    0x20(%ecx),%edx
  801f8d:	39 d0                	cmp    %edx,%eax
  801f8f:	73 e2                	jae    801f73 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f94:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f98:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f9b:	89 c2                	mov    %eax,%edx
  801f9d:	c1 fa 1f             	sar    $0x1f,%edx
  801fa0:	89 d1                	mov    %edx,%ecx
  801fa2:	c1 e9 1b             	shr    $0x1b,%ecx
  801fa5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fa8:	83 e2 1f             	and    $0x1f,%edx
  801fab:	29 ca                	sub    %ecx,%edx
  801fad:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fb1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fb5:	83 c0 01             	add    $0x1,%eax
  801fb8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fbb:	83 c7 01             	add    $0x1,%edi
  801fbe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fc1:	75 c2                	jne    801f85 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fc3:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc6:	eb 05                	jmp    801fcd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fc8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd0:	5b                   	pop    %ebx
  801fd1:	5e                   	pop    %esi
  801fd2:	5f                   	pop    %edi
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    

00801fd5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	57                   	push   %edi
  801fd9:	56                   	push   %esi
  801fda:	53                   	push   %ebx
  801fdb:	83 ec 18             	sub    $0x18,%esp
  801fde:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fe1:	57                   	push   %edi
  801fe2:	e8 b9 f0 ff ff       	call   8010a0 <fd2data>
  801fe7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe9:	83 c4 10             	add    $0x10,%esp
  801fec:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ff1:	eb 3d                	jmp    802030 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ff3:	85 db                	test   %ebx,%ebx
  801ff5:	74 04                	je     801ffb <devpipe_read+0x26>
				return i;
  801ff7:	89 d8                	mov    %ebx,%eax
  801ff9:	eb 44                	jmp    80203f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ffb:	89 f2                	mov    %esi,%edx
  801ffd:	89 f8                	mov    %edi,%eax
  801fff:	e8 e5 fe ff ff       	call   801ee9 <_pipeisclosed>
  802004:	85 c0                	test   %eax,%eax
  802006:	75 32                	jne    80203a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802008:	e8 54 ee ff ff       	call   800e61 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80200d:	8b 06                	mov    (%esi),%eax
  80200f:	3b 46 04             	cmp    0x4(%esi),%eax
  802012:	74 df                	je     801ff3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802014:	99                   	cltd   
  802015:	c1 ea 1b             	shr    $0x1b,%edx
  802018:	01 d0                	add    %edx,%eax
  80201a:	83 e0 1f             	and    $0x1f,%eax
  80201d:	29 d0                	sub    %edx,%eax
  80201f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802024:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802027:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80202a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80202d:	83 c3 01             	add    $0x1,%ebx
  802030:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802033:	75 d8                	jne    80200d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802035:	8b 45 10             	mov    0x10(%ebp),%eax
  802038:	eb 05                	jmp    80203f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80203a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80203f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802042:	5b                   	pop    %ebx
  802043:	5e                   	pop    %esi
  802044:	5f                   	pop    %edi
  802045:	5d                   	pop    %ebp
  802046:	c3                   	ret    

00802047 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	56                   	push   %esi
  80204b:	53                   	push   %ebx
  80204c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80204f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802052:	50                   	push   %eax
  802053:	e8 5f f0 ff ff       	call   8010b7 <fd_alloc>
  802058:	83 c4 10             	add    $0x10,%esp
  80205b:	89 c2                	mov    %eax,%edx
  80205d:	85 c0                	test   %eax,%eax
  80205f:	0f 88 2c 01 00 00    	js     802191 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802065:	83 ec 04             	sub    $0x4,%esp
  802068:	68 07 04 00 00       	push   $0x407
  80206d:	ff 75 f4             	pushl  -0xc(%ebp)
  802070:	6a 00                	push   $0x0
  802072:	e8 09 ee ff ff       	call   800e80 <sys_page_alloc>
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	89 c2                	mov    %eax,%edx
  80207c:	85 c0                	test   %eax,%eax
  80207e:	0f 88 0d 01 00 00    	js     802191 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802084:	83 ec 0c             	sub    $0xc,%esp
  802087:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80208a:	50                   	push   %eax
  80208b:	e8 27 f0 ff ff       	call   8010b7 <fd_alloc>
  802090:	89 c3                	mov    %eax,%ebx
  802092:	83 c4 10             	add    $0x10,%esp
  802095:	85 c0                	test   %eax,%eax
  802097:	0f 88 e2 00 00 00    	js     80217f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209d:	83 ec 04             	sub    $0x4,%esp
  8020a0:	68 07 04 00 00       	push   $0x407
  8020a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8020a8:	6a 00                	push   $0x0
  8020aa:	e8 d1 ed ff ff       	call   800e80 <sys_page_alloc>
  8020af:	89 c3                	mov    %eax,%ebx
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	0f 88 c3 00 00 00    	js     80217f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020bc:	83 ec 0c             	sub    $0xc,%esp
  8020bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c2:	e8 d9 ef ff ff       	call   8010a0 <fd2data>
  8020c7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c9:	83 c4 0c             	add    $0xc,%esp
  8020cc:	68 07 04 00 00       	push   $0x407
  8020d1:	50                   	push   %eax
  8020d2:	6a 00                	push   $0x0
  8020d4:	e8 a7 ed ff ff       	call   800e80 <sys_page_alloc>
  8020d9:	89 c3                	mov    %eax,%ebx
  8020db:	83 c4 10             	add    $0x10,%esp
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	0f 88 89 00 00 00    	js     80216f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e6:	83 ec 0c             	sub    $0xc,%esp
  8020e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ec:	e8 af ef ff ff       	call   8010a0 <fd2data>
  8020f1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020f8:	50                   	push   %eax
  8020f9:	6a 00                	push   $0x0
  8020fb:	56                   	push   %esi
  8020fc:	6a 00                	push   $0x0
  8020fe:	e8 c0 ed ff ff       	call   800ec3 <sys_page_map>
  802103:	89 c3                	mov    %eax,%ebx
  802105:	83 c4 20             	add    $0x20,%esp
  802108:	85 c0                	test   %eax,%eax
  80210a:	78 55                	js     802161 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80210c:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  802112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802115:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802117:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802121:	8b 15 ac 57 80 00    	mov    0x8057ac,%edx
  802127:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80212a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80212c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80212f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802136:	83 ec 0c             	sub    $0xc,%esp
  802139:	ff 75 f4             	pushl  -0xc(%ebp)
  80213c:	e8 4f ef ff ff       	call   801090 <fd2num>
  802141:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802144:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802146:	83 c4 04             	add    $0x4,%esp
  802149:	ff 75 f0             	pushl  -0x10(%ebp)
  80214c:	e8 3f ef ff ff       	call   801090 <fd2num>
  802151:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802154:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802157:	83 c4 10             	add    $0x10,%esp
  80215a:	ba 00 00 00 00       	mov    $0x0,%edx
  80215f:	eb 30                	jmp    802191 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802161:	83 ec 08             	sub    $0x8,%esp
  802164:	56                   	push   %esi
  802165:	6a 00                	push   $0x0
  802167:	e8 99 ed ff ff       	call   800f05 <sys_page_unmap>
  80216c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80216f:	83 ec 08             	sub    $0x8,%esp
  802172:	ff 75 f0             	pushl  -0x10(%ebp)
  802175:	6a 00                	push   $0x0
  802177:	e8 89 ed ff ff       	call   800f05 <sys_page_unmap>
  80217c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80217f:	83 ec 08             	sub    $0x8,%esp
  802182:	ff 75 f4             	pushl  -0xc(%ebp)
  802185:	6a 00                	push   $0x0
  802187:	e8 79 ed ff ff       	call   800f05 <sys_page_unmap>
  80218c:	83 c4 10             	add    $0x10,%esp
  80218f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802191:	89 d0                	mov    %edx,%eax
  802193:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802196:	5b                   	pop    %ebx
  802197:	5e                   	pop    %esi
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    

0080219a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a3:	50                   	push   %eax
  8021a4:	ff 75 08             	pushl  0x8(%ebp)
  8021a7:	e8 5a ef ff ff       	call   801106 <fd_lookup>
  8021ac:	83 c4 10             	add    $0x10,%esp
  8021af:	85 c0                	test   %eax,%eax
  8021b1:	78 18                	js     8021cb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021b3:	83 ec 0c             	sub    $0xc,%esp
  8021b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b9:	e8 e2 ee ff ff       	call   8010a0 <fd2data>
	return _pipeisclosed(fd, p);
  8021be:	89 c2                	mov    %eax,%edx
  8021c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c3:	e8 21 fd ff ff       	call   801ee9 <_pipeisclosed>
  8021c8:	83 c4 10             	add    $0x10,%esp
}
  8021cb:	c9                   	leave  
  8021cc:	c3                   	ret    

008021cd <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021cd:	55                   	push   %ebp
  8021ce:	89 e5                	mov    %esp,%ebp
  8021d0:	56                   	push   %esi
  8021d1:	53                   	push   %ebx
  8021d2:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8021d5:	85 f6                	test   %esi,%esi
  8021d7:	75 16                	jne    8021ef <wait+0x22>
  8021d9:	68 a3 30 80 00       	push   $0x8030a3
  8021de:	68 a3 2f 80 00       	push   $0x802fa3
  8021e3:	6a 09                	push   $0x9
  8021e5:	68 ae 30 80 00       	push   $0x8030ae
  8021ea:	e8 10 e2 ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  8021ef:	89 f3                	mov    %esi,%ebx
  8021f1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021f7:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8021fa:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802200:	eb 05                	jmp    802207 <wait+0x3a>
		sys_yield();
  802202:	e8 5a ec ff ff       	call   800e61 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802207:	8b 43 48             	mov    0x48(%ebx),%eax
  80220a:	39 c6                	cmp    %eax,%esi
  80220c:	75 07                	jne    802215 <wait+0x48>
  80220e:	8b 43 54             	mov    0x54(%ebx),%eax
  802211:	85 c0                	test   %eax,%eax
  802213:	75 ed                	jne    802202 <wait+0x35>
		sys_yield();
}
  802215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802218:	5b                   	pop    %ebx
  802219:	5e                   	pop    %esi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    

0080221c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802222:	68 b9 30 80 00       	push   $0x8030b9
  802227:	ff 75 0c             	pushl  0xc(%ebp)
  80222a:	e8 4e e8 ff ff       	call   800a7d <strcpy>
	return 0;
}
  80222f:	b8 00 00 00 00       	mov    $0x0,%eax
  802234:	c9                   	leave  
  802235:	c3                   	ret    

00802236 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802236:	55                   	push   %ebp
  802237:	89 e5                	mov    %esp,%ebp
  802239:	53                   	push   %ebx
  80223a:	83 ec 10             	sub    $0x10,%esp
  80223d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802240:	53                   	push   %ebx
  802241:	e8 3b 05 00 00       	call   802781 <pageref>
  802246:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802249:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80224e:	83 f8 01             	cmp    $0x1,%eax
  802251:	75 10                	jne    802263 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802253:	83 ec 0c             	sub    $0xc,%esp
  802256:	ff 73 0c             	pushl  0xc(%ebx)
  802259:	e8 c0 02 00 00       	call   80251e <nsipc_close>
  80225e:	89 c2                	mov    %eax,%edx
  802260:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802263:	89 d0                	mov    %edx,%eax
  802265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802268:	c9                   	leave  
  802269:	c3                   	ret    

0080226a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802270:	6a 00                	push   $0x0
  802272:	ff 75 10             	pushl  0x10(%ebp)
  802275:	ff 75 0c             	pushl  0xc(%ebp)
  802278:	8b 45 08             	mov    0x8(%ebp),%eax
  80227b:	ff 70 0c             	pushl  0xc(%eax)
  80227e:	e8 78 03 00 00       	call   8025fb <nsipc_send>
}
  802283:	c9                   	leave  
  802284:	c3                   	ret    

00802285 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80228b:	6a 00                	push   $0x0
  80228d:	ff 75 10             	pushl  0x10(%ebp)
  802290:	ff 75 0c             	pushl  0xc(%ebp)
  802293:	8b 45 08             	mov    0x8(%ebp),%eax
  802296:	ff 70 0c             	pushl  0xc(%eax)
  802299:	e8 f1 02 00 00       	call   80258f <nsipc_recv>
}
  80229e:	c9                   	leave  
  80229f:	c3                   	ret    

008022a0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8022a6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8022a9:	52                   	push   %edx
  8022aa:	50                   	push   %eax
  8022ab:	e8 56 ee ff ff       	call   801106 <fd_lookup>
  8022b0:	83 c4 10             	add    $0x10,%esp
  8022b3:	85 c0                	test   %eax,%eax
  8022b5:	78 17                	js     8022ce <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8022b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ba:	8b 0d c8 57 80 00    	mov    0x8057c8,%ecx
  8022c0:	39 08                	cmp    %ecx,(%eax)
  8022c2:	75 05                	jne    8022c9 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8022c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8022c7:	eb 05                	jmp    8022ce <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8022c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8022ce:	c9                   	leave  
  8022cf:	c3                   	ret    

008022d0 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	56                   	push   %esi
  8022d4:	53                   	push   %ebx
  8022d5:	83 ec 1c             	sub    $0x1c,%esp
  8022d8:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8022da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022dd:	50                   	push   %eax
  8022de:	e8 d4 ed ff ff       	call   8010b7 <fd_alloc>
  8022e3:	89 c3                	mov    %eax,%ebx
  8022e5:	83 c4 10             	add    $0x10,%esp
  8022e8:	85 c0                	test   %eax,%eax
  8022ea:	78 1b                	js     802307 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8022ec:	83 ec 04             	sub    $0x4,%esp
  8022ef:	68 07 04 00 00       	push   $0x407
  8022f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8022f7:	6a 00                	push   $0x0
  8022f9:	e8 82 eb ff ff       	call   800e80 <sys_page_alloc>
  8022fe:	89 c3                	mov    %eax,%ebx
  802300:	83 c4 10             	add    $0x10,%esp
  802303:	85 c0                	test   %eax,%eax
  802305:	79 10                	jns    802317 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802307:	83 ec 0c             	sub    $0xc,%esp
  80230a:	56                   	push   %esi
  80230b:	e8 0e 02 00 00       	call   80251e <nsipc_close>
		return r;
  802310:	83 c4 10             	add    $0x10,%esp
  802313:	89 d8                	mov    %ebx,%eax
  802315:	eb 24                	jmp    80233b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802317:	8b 15 c8 57 80 00    	mov    0x8057c8,%edx
  80231d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802320:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802322:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802325:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80232c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80232f:	83 ec 0c             	sub    $0xc,%esp
  802332:	50                   	push   %eax
  802333:	e8 58 ed ff ff       	call   801090 <fd2num>
  802338:	83 c4 10             	add    $0x10,%esp
}
  80233b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80233e:	5b                   	pop    %ebx
  80233f:	5e                   	pop    %esi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    

00802342 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802342:	55                   	push   %ebp
  802343:	89 e5                	mov    %esp,%ebp
  802345:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802348:	8b 45 08             	mov    0x8(%ebp),%eax
  80234b:	e8 50 ff ff ff       	call   8022a0 <fd2sockid>
		return r;
  802350:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802352:	85 c0                	test   %eax,%eax
  802354:	78 1f                	js     802375 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802356:	83 ec 04             	sub    $0x4,%esp
  802359:	ff 75 10             	pushl  0x10(%ebp)
  80235c:	ff 75 0c             	pushl  0xc(%ebp)
  80235f:	50                   	push   %eax
  802360:	e8 12 01 00 00       	call   802477 <nsipc_accept>
  802365:	83 c4 10             	add    $0x10,%esp
		return r;
  802368:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80236a:	85 c0                	test   %eax,%eax
  80236c:	78 07                	js     802375 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80236e:	e8 5d ff ff ff       	call   8022d0 <alloc_sockfd>
  802373:	89 c1                	mov    %eax,%ecx
}
  802375:	89 c8                	mov    %ecx,%eax
  802377:	c9                   	leave  
  802378:	c3                   	ret    

00802379 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802379:	55                   	push   %ebp
  80237a:	89 e5                	mov    %esp,%ebp
  80237c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80237f:	8b 45 08             	mov    0x8(%ebp),%eax
  802382:	e8 19 ff ff ff       	call   8022a0 <fd2sockid>
  802387:	85 c0                	test   %eax,%eax
  802389:	78 12                	js     80239d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80238b:	83 ec 04             	sub    $0x4,%esp
  80238e:	ff 75 10             	pushl  0x10(%ebp)
  802391:	ff 75 0c             	pushl  0xc(%ebp)
  802394:	50                   	push   %eax
  802395:	e8 2d 01 00 00       	call   8024c7 <nsipc_bind>
  80239a:	83 c4 10             	add    $0x10,%esp
}
  80239d:	c9                   	leave  
  80239e:	c3                   	ret    

0080239f <shutdown>:

int
shutdown(int s, int how)
{
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a8:	e8 f3 fe ff ff       	call   8022a0 <fd2sockid>
  8023ad:	85 c0                	test   %eax,%eax
  8023af:	78 0f                	js     8023c0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8023b1:	83 ec 08             	sub    $0x8,%esp
  8023b4:	ff 75 0c             	pushl  0xc(%ebp)
  8023b7:	50                   	push   %eax
  8023b8:	e8 3f 01 00 00       	call   8024fc <nsipc_shutdown>
  8023bd:	83 c4 10             	add    $0x10,%esp
}
  8023c0:	c9                   	leave  
  8023c1:	c3                   	ret    

008023c2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023c2:	55                   	push   %ebp
  8023c3:	89 e5                	mov    %esp,%ebp
  8023c5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023cb:	e8 d0 fe ff ff       	call   8022a0 <fd2sockid>
  8023d0:	85 c0                	test   %eax,%eax
  8023d2:	78 12                	js     8023e6 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8023d4:	83 ec 04             	sub    $0x4,%esp
  8023d7:	ff 75 10             	pushl  0x10(%ebp)
  8023da:	ff 75 0c             	pushl  0xc(%ebp)
  8023dd:	50                   	push   %eax
  8023de:	e8 55 01 00 00       	call   802538 <nsipc_connect>
  8023e3:	83 c4 10             	add    $0x10,%esp
}
  8023e6:	c9                   	leave  
  8023e7:	c3                   	ret    

008023e8 <listen>:

int
listen(int s, int backlog)
{
  8023e8:	55                   	push   %ebp
  8023e9:	89 e5                	mov    %esp,%ebp
  8023eb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f1:	e8 aa fe ff ff       	call   8022a0 <fd2sockid>
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	78 0f                	js     802409 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8023fa:	83 ec 08             	sub    $0x8,%esp
  8023fd:	ff 75 0c             	pushl  0xc(%ebp)
  802400:	50                   	push   %eax
  802401:	e8 67 01 00 00       	call   80256d <nsipc_listen>
  802406:	83 c4 10             	add    $0x10,%esp
}
  802409:	c9                   	leave  
  80240a:	c3                   	ret    

0080240b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802411:	ff 75 10             	pushl  0x10(%ebp)
  802414:	ff 75 0c             	pushl  0xc(%ebp)
  802417:	ff 75 08             	pushl  0x8(%ebp)
  80241a:	e8 3a 02 00 00       	call   802659 <nsipc_socket>
  80241f:	83 c4 10             	add    $0x10,%esp
  802422:	85 c0                	test   %eax,%eax
  802424:	78 05                	js     80242b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802426:	e8 a5 fe ff ff       	call   8022d0 <alloc_sockfd>
}
  80242b:	c9                   	leave  
  80242c:	c3                   	ret    

0080242d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80242d:	55                   	push   %ebp
  80242e:	89 e5                	mov    %esp,%ebp
  802430:	53                   	push   %ebx
  802431:	83 ec 04             	sub    $0x4,%esp
  802434:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802436:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  80243d:	75 12                	jne    802451 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80243f:	83 ec 0c             	sub    $0xc,%esp
  802442:	6a 02                	push   $0x2
  802444:	e8 ff 02 00 00       	call   802748 <ipc_find_env>
  802449:	a3 04 60 80 00       	mov    %eax,0x806004
  80244e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802451:	6a 07                	push   $0x7
  802453:	68 00 90 80 00       	push   $0x809000
  802458:	53                   	push   %ebx
  802459:	ff 35 04 60 80 00    	pushl  0x806004
  80245f:	e8 95 02 00 00       	call   8026f9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802464:	83 c4 0c             	add    $0xc,%esp
  802467:	6a 00                	push   $0x0
  802469:	6a 00                	push   $0x0
  80246b:	6a 00                	push   $0x0
  80246d:	e8 11 02 00 00       	call   802683 <ipc_recv>
}
  802472:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802475:	c9                   	leave  
  802476:	c3                   	ret    

00802477 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802477:	55                   	push   %ebp
  802478:	89 e5                	mov    %esp,%ebp
  80247a:	56                   	push   %esi
  80247b:	53                   	push   %ebx
  80247c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80247f:	8b 45 08             	mov    0x8(%ebp),%eax
  802482:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802487:	8b 06                	mov    (%esi),%eax
  802489:	a3 04 90 80 00       	mov    %eax,0x809004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80248e:	b8 01 00 00 00       	mov    $0x1,%eax
  802493:	e8 95 ff ff ff       	call   80242d <nsipc>
  802498:	89 c3                	mov    %eax,%ebx
  80249a:	85 c0                	test   %eax,%eax
  80249c:	78 20                	js     8024be <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80249e:	83 ec 04             	sub    $0x4,%esp
  8024a1:	ff 35 10 90 80 00    	pushl  0x809010
  8024a7:	68 00 90 80 00       	push   $0x809000
  8024ac:	ff 75 0c             	pushl  0xc(%ebp)
  8024af:	e8 5b e7 ff ff       	call   800c0f <memmove>
		*addrlen = ret->ret_addrlen;
  8024b4:	a1 10 90 80 00       	mov    0x809010,%eax
  8024b9:	89 06                	mov    %eax,(%esi)
  8024bb:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8024be:	89 d8                	mov    %ebx,%eax
  8024c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5d                   	pop    %ebp
  8024c6:	c3                   	ret    

008024c7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8024c7:	55                   	push   %ebp
  8024c8:	89 e5                	mov    %esp,%ebp
  8024ca:	53                   	push   %ebx
  8024cb:	83 ec 08             	sub    $0x8,%esp
  8024ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8024d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d4:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8024d9:	53                   	push   %ebx
  8024da:	ff 75 0c             	pushl  0xc(%ebp)
  8024dd:	68 04 90 80 00       	push   $0x809004
  8024e2:	e8 28 e7 ff ff       	call   800c0f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8024e7:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_BIND);
  8024ed:	b8 02 00 00 00       	mov    $0x2,%eax
  8024f2:	e8 36 ff ff ff       	call   80242d <nsipc>
}
  8024f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024fa:	c9                   	leave  
  8024fb:	c3                   	ret    

008024fc <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8024fc:	55                   	push   %ebp
  8024fd:	89 e5                	mov    %esp,%ebp
  8024ff:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802502:	8b 45 08             	mov    0x8(%ebp),%eax
  802505:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.shutdown.req_how = how;
  80250a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80250d:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_SHUTDOWN);
  802512:	b8 03 00 00 00       	mov    $0x3,%eax
  802517:	e8 11 ff ff ff       	call   80242d <nsipc>
}
  80251c:	c9                   	leave  
  80251d:	c3                   	ret    

0080251e <nsipc_close>:

int
nsipc_close(int s)
{
  80251e:	55                   	push   %ebp
  80251f:	89 e5                	mov    %esp,%ebp
  802521:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802524:	8b 45 08             	mov    0x8(%ebp),%eax
  802527:	a3 00 90 80 00       	mov    %eax,0x809000
	return nsipc(NSREQ_CLOSE);
  80252c:	b8 04 00 00 00       	mov    $0x4,%eax
  802531:	e8 f7 fe ff ff       	call   80242d <nsipc>
}
  802536:	c9                   	leave  
  802537:	c3                   	ret    

00802538 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802538:	55                   	push   %ebp
  802539:	89 e5                	mov    %esp,%ebp
  80253b:	53                   	push   %ebx
  80253c:	83 ec 08             	sub    $0x8,%esp
  80253f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802542:	8b 45 08             	mov    0x8(%ebp),%eax
  802545:	a3 00 90 80 00       	mov    %eax,0x809000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80254a:	53                   	push   %ebx
  80254b:	ff 75 0c             	pushl  0xc(%ebp)
  80254e:	68 04 90 80 00       	push   $0x809004
  802553:	e8 b7 e6 ff ff       	call   800c0f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802558:	89 1d 14 90 80 00    	mov    %ebx,0x809014
	return nsipc(NSREQ_CONNECT);
  80255e:	b8 05 00 00 00       	mov    $0x5,%eax
  802563:	e8 c5 fe ff ff       	call   80242d <nsipc>
}
  802568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80256b:	c9                   	leave  
  80256c:	c3                   	ret    

0080256d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80256d:	55                   	push   %ebp
  80256e:	89 e5                	mov    %esp,%ebp
  802570:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802573:	8b 45 08             	mov    0x8(%ebp),%eax
  802576:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.listen.req_backlog = backlog;
  80257b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80257e:	a3 04 90 80 00       	mov    %eax,0x809004
	return nsipc(NSREQ_LISTEN);
  802583:	b8 06 00 00 00       	mov    $0x6,%eax
  802588:	e8 a0 fe ff ff       	call   80242d <nsipc>
}
  80258d:	c9                   	leave  
  80258e:	c3                   	ret    

0080258f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80258f:	55                   	push   %ebp
  802590:	89 e5                	mov    %esp,%ebp
  802592:	56                   	push   %esi
  802593:	53                   	push   %ebx
  802594:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802597:	8b 45 08             	mov    0x8(%ebp),%eax
  80259a:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.recv.req_len = len;
  80259f:	89 35 04 90 80 00    	mov    %esi,0x809004
	nsipcbuf.recv.req_flags = flags;
  8025a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8025a8:	a3 08 90 80 00       	mov    %eax,0x809008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8025ad:	b8 07 00 00 00       	mov    $0x7,%eax
  8025b2:	e8 76 fe ff ff       	call   80242d <nsipc>
  8025b7:	89 c3                	mov    %eax,%ebx
  8025b9:	85 c0                	test   %eax,%eax
  8025bb:	78 35                	js     8025f2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8025bd:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8025c2:	7f 04                	jg     8025c8 <nsipc_recv+0x39>
  8025c4:	39 c6                	cmp    %eax,%esi
  8025c6:	7d 16                	jge    8025de <nsipc_recv+0x4f>
  8025c8:	68 c5 30 80 00       	push   $0x8030c5
  8025cd:	68 a3 2f 80 00       	push   $0x802fa3
  8025d2:	6a 62                	push   $0x62
  8025d4:	68 da 30 80 00       	push   $0x8030da
  8025d9:	e8 21 de ff ff       	call   8003ff <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8025de:	83 ec 04             	sub    $0x4,%esp
  8025e1:	50                   	push   %eax
  8025e2:	68 00 90 80 00       	push   $0x809000
  8025e7:	ff 75 0c             	pushl  0xc(%ebp)
  8025ea:	e8 20 e6 ff ff       	call   800c0f <memmove>
  8025ef:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8025f2:	89 d8                	mov    %ebx,%eax
  8025f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025f7:	5b                   	pop    %ebx
  8025f8:	5e                   	pop    %esi
  8025f9:	5d                   	pop    %ebp
  8025fa:	c3                   	ret    

008025fb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8025fb:	55                   	push   %ebp
  8025fc:	89 e5                	mov    %esp,%ebp
  8025fe:	53                   	push   %ebx
  8025ff:	83 ec 04             	sub    $0x4,%esp
  802602:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802605:	8b 45 08             	mov    0x8(%ebp),%eax
  802608:	a3 00 90 80 00       	mov    %eax,0x809000
	assert(size < 1600);
  80260d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802613:	7e 16                	jle    80262b <nsipc_send+0x30>
  802615:	68 e6 30 80 00       	push   $0x8030e6
  80261a:	68 a3 2f 80 00       	push   $0x802fa3
  80261f:	6a 6d                	push   $0x6d
  802621:	68 da 30 80 00       	push   $0x8030da
  802626:	e8 d4 dd ff ff       	call   8003ff <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80262b:	83 ec 04             	sub    $0x4,%esp
  80262e:	53                   	push   %ebx
  80262f:	ff 75 0c             	pushl  0xc(%ebp)
  802632:	68 0c 90 80 00       	push   $0x80900c
  802637:	e8 d3 e5 ff ff       	call   800c0f <memmove>
	nsipcbuf.send.req_size = size;
  80263c:	89 1d 04 90 80 00    	mov    %ebx,0x809004
	nsipcbuf.send.req_flags = flags;
  802642:	8b 45 14             	mov    0x14(%ebp),%eax
  802645:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SEND);
  80264a:	b8 08 00 00 00       	mov    $0x8,%eax
  80264f:	e8 d9 fd ff ff       	call   80242d <nsipc>
}
  802654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802657:	c9                   	leave  
  802658:	c3                   	ret    

00802659 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802659:	55                   	push   %ebp
  80265a:	89 e5                	mov    %esp,%ebp
  80265c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80265f:	8b 45 08             	mov    0x8(%ebp),%eax
  802662:	a3 00 90 80 00       	mov    %eax,0x809000
	nsipcbuf.socket.req_type = type;
  802667:	8b 45 0c             	mov    0xc(%ebp),%eax
  80266a:	a3 04 90 80 00       	mov    %eax,0x809004
	nsipcbuf.socket.req_protocol = protocol;
  80266f:	8b 45 10             	mov    0x10(%ebp),%eax
  802672:	a3 08 90 80 00       	mov    %eax,0x809008
	return nsipc(NSREQ_SOCKET);
  802677:	b8 09 00 00 00       	mov    $0x9,%eax
  80267c:	e8 ac fd ff ff       	call   80242d <nsipc>
}
  802681:	c9                   	leave  
  802682:	c3                   	ret    

00802683 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802683:	55                   	push   %ebp
  802684:	89 e5                	mov    %esp,%ebp
  802686:	56                   	push   %esi
  802687:	53                   	push   %ebx
  802688:	8b 75 08             	mov    0x8(%ebp),%esi
  80268b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80268e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  802691:	85 c0                	test   %eax,%eax
  802693:	74 0e                	je     8026a3 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  802695:	83 ec 0c             	sub    $0xc,%esp
  802698:	50                   	push   %eax
  802699:	e8 92 e9 ff ff       	call   801030 <sys_ipc_recv>
  80269e:	83 c4 10             	add    $0x10,%esp
  8026a1:	eb 10                	jmp    8026b3 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  8026a3:	83 ec 0c             	sub    $0xc,%esp
  8026a6:	68 00 00 c0 ee       	push   $0xeec00000
  8026ab:	e8 80 e9 ff ff       	call   801030 <sys_ipc_recv>
  8026b0:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8026b3:	85 c0                	test   %eax,%eax
  8026b5:	79 17                	jns    8026ce <ipc_recv+0x4b>
		if(*from_env_store)
  8026b7:	83 3e 00             	cmpl   $0x0,(%esi)
  8026ba:	74 06                	je     8026c2 <ipc_recv+0x3f>
			*from_env_store = 0;
  8026bc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8026c2:	85 db                	test   %ebx,%ebx
  8026c4:	74 2c                	je     8026f2 <ipc_recv+0x6f>
			*perm_store = 0;
  8026c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026cc:	eb 24                	jmp    8026f2 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  8026ce:	85 f6                	test   %esi,%esi
  8026d0:	74 0a                	je     8026dc <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  8026d2:	a1 90 77 80 00       	mov    0x807790,%eax
  8026d7:	8b 40 74             	mov    0x74(%eax),%eax
  8026da:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8026dc:	85 db                	test   %ebx,%ebx
  8026de:	74 0a                	je     8026ea <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8026e0:	a1 90 77 80 00       	mov    0x807790,%eax
  8026e5:	8b 40 78             	mov    0x78(%eax),%eax
  8026e8:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8026ea:	a1 90 77 80 00       	mov    0x807790,%eax
  8026ef:	8b 40 70             	mov    0x70(%eax),%eax
}
  8026f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026f5:	5b                   	pop    %ebx
  8026f6:	5e                   	pop    %esi
  8026f7:	5d                   	pop    %ebp
  8026f8:	c3                   	ret    

008026f9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026f9:	55                   	push   %ebp
  8026fa:	89 e5                	mov    %esp,%ebp
  8026fc:	57                   	push   %edi
  8026fd:	56                   	push   %esi
  8026fe:	53                   	push   %ebx
  8026ff:	83 ec 0c             	sub    $0xc,%esp
  802702:	8b 7d 08             	mov    0x8(%ebp),%edi
  802705:	8b 75 0c             	mov    0xc(%ebp),%esi
  802708:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80270b:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80270d:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802712:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802715:	e8 47 e7 ff ff       	call   800e61 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  80271a:	ff 75 14             	pushl  0x14(%ebp)
  80271d:	53                   	push   %ebx
  80271e:	56                   	push   %esi
  80271f:	57                   	push   %edi
  802720:	e8 e8 e8 ff ff       	call   80100d <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802725:	89 c2                	mov    %eax,%edx
  802727:	f7 d2                	not    %edx
  802729:	c1 ea 1f             	shr    $0x1f,%edx
  80272c:	83 c4 10             	add    $0x10,%esp
  80272f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802732:	0f 94 c1             	sete   %cl
  802735:	09 ca                	or     %ecx,%edx
  802737:	85 c0                	test   %eax,%eax
  802739:	0f 94 c0             	sete   %al
  80273c:	38 c2                	cmp    %al,%dl
  80273e:	77 d5                	ja     802715 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802740:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802743:	5b                   	pop    %ebx
  802744:	5e                   	pop    %esi
  802745:	5f                   	pop    %edi
  802746:	5d                   	pop    %ebp
  802747:	c3                   	ret    

00802748 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802748:	55                   	push   %ebp
  802749:	89 e5                	mov    %esp,%ebp
  80274b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80274e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802753:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802756:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80275c:	8b 52 50             	mov    0x50(%edx),%edx
  80275f:	39 ca                	cmp    %ecx,%edx
  802761:	75 0d                	jne    802770 <ipc_find_env+0x28>
			return envs[i].env_id;
  802763:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802766:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80276b:	8b 40 48             	mov    0x48(%eax),%eax
  80276e:	eb 0f                	jmp    80277f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802770:	83 c0 01             	add    $0x1,%eax
  802773:	3d 00 04 00 00       	cmp    $0x400,%eax
  802778:	75 d9                	jne    802753 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80277a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80277f:	5d                   	pop    %ebp
  802780:	c3                   	ret    

00802781 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802781:	55                   	push   %ebp
  802782:	89 e5                	mov    %esp,%ebp
  802784:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802787:	89 d0                	mov    %edx,%eax
  802789:	c1 e8 16             	shr    $0x16,%eax
  80278c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802793:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802798:	f6 c1 01             	test   $0x1,%cl
  80279b:	74 1d                	je     8027ba <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80279d:	c1 ea 0c             	shr    $0xc,%edx
  8027a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8027a7:	f6 c2 01             	test   $0x1,%dl
  8027aa:	74 0e                	je     8027ba <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027ac:	c1 ea 0c             	shr    $0xc,%edx
  8027af:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8027b6:	ef 
  8027b7:	0f b7 c0             	movzwl %ax,%eax
}
  8027ba:	5d                   	pop    %ebp
  8027bb:	c3                   	ret    
  8027bc:	66 90                	xchg   %ax,%ax
  8027be:	66 90                	xchg   %ax,%ax

008027c0 <__udivdi3>:
  8027c0:	55                   	push   %ebp
  8027c1:	57                   	push   %edi
  8027c2:	56                   	push   %esi
  8027c3:	53                   	push   %ebx
  8027c4:	83 ec 1c             	sub    $0x1c,%esp
  8027c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027d7:	85 f6                	test   %esi,%esi
  8027d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027dd:	89 ca                	mov    %ecx,%edx
  8027df:	89 f8                	mov    %edi,%eax
  8027e1:	75 3d                	jne    802820 <__udivdi3+0x60>
  8027e3:	39 cf                	cmp    %ecx,%edi
  8027e5:	0f 87 c5 00 00 00    	ja     8028b0 <__udivdi3+0xf0>
  8027eb:	85 ff                	test   %edi,%edi
  8027ed:	89 fd                	mov    %edi,%ebp
  8027ef:	75 0b                	jne    8027fc <__udivdi3+0x3c>
  8027f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027f6:	31 d2                	xor    %edx,%edx
  8027f8:	f7 f7                	div    %edi
  8027fa:	89 c5                	mov    %eax,%ebp
  8027fc:	89 c8                	mov    %ecx,%eax
  8027fe:	31 d2                	xor    %edx,%edx
  802800:	f7 f5                	div    %ebp
  802802:	89 c1                	mov    %eax,%ecx
  802804:	89 d8                	mov    %ebx,%eax
  802806:	89 cf                	mov    %ecx,%edi
  802808:	f7 f5                	div    %ebp
  80280a:	89 c3                	mov    %eax,%ebx
  80280c:	89 d8                	mov    %ebx,%eax
  80280e:	89 fa                	mov    %edi,%edx
  802810:	83 c4 1c             	add    $0x1c,%esp
  802813:	5b                   	pop    %ebx
  802814:	5e                   	pop    %esi
  802815:	5f                   	pop    %edi
  802816:	5d                   	pop    %ebp
  802817:	c3                   	ret    
  802818:	90                   	nop
  802819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802820:	39 ce                	cmp    %ecx,%esi
  802822:	77 74                	ja     802898 <__udivdi3+0xd8>
  802824:	0f bd fe             	bsr    %esi,%edi
  802827:	83 f7 1f             	xor    $0x1f,%edi
  80282a:	0f 84 98 00 00 00    	je     8028c8 <__udivdi3+0x108>
  802830:	bb 20 00 00 00       	mov    $0x20,%ebx
  802835:	89 f9                	mov    %edi,%ecx
  802837:	89 c5                	mov    %eax,%ebp
  802839:	29 fb                	sub    %edi,%ebx
  80283b:	d3 e6                	shl    %cl,%esi
  80283d:	89 d9                	mov    %ebx,%ecx
  80283f:	d3 ed                	shr    %cl,%ebp
  802841:	89 f9                	mov    %edi,%ecx
  802843:	d3 e0                	shl    %cl,%eax
  802845:	09 ee                	or     %ebp,%esi
  802847:	89 d9                	mov    %ebx,%ecx
  802849:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80284d:	89 d5                	mov    %edx,%ebp
  80284f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802853:	d3 ed                	shr    %cl,%ebp
  802855:	89 f9                	mov    %edi,%ecx
  802857:	d3 e2                	shl    %cl,%edx
  802859:	89 d9                	mov    %ebx,%ecx
  80285b:	d3 e8                	shr    %cl,%eax
  80285d:	09 c2                	or     %eax,%edx
  80285f:	89 d0                	mov    %edx,%eax
  802861:	89 ea                	mov    %ebp,%edx
  802863:	f7 f6                	div    %esi
  802865:	89 d5                	mov    %edx,%ebp
  802867:	89 c3                	mov    %eax,%ebx
  802869:	f7 64 24 0c          	mull   0xc(%esp)
  80286d:	39 d5                	cmp    %edx,%ebp
  80286f:	72 10                	jb     802881 <__udivdi3+0xc1>
  802871:	8b 74 24 08          	mov    0x8(%esp),%esi
  802875:	89 f9                	mov    %edi,%ecx
  802877:	d3 e6                	shl    %cl,%esi
  802879:	39 c6                	cmp    %eax,%esi
  80287b:	73 07                	jae    802884 <__udivdi3+0xc4>
  80287d:	39 d5                	cmp    %edx,%ebp
  80287f:	75 03                	jne    802884 <__udivdi3+0xc4>
  802881:	83 eb 01             	sub    $0x1,%ebx
  802884:	31 ff                	xor    %edi,%edi
  802886:	89 d8                	mov    %ebx,%eax
  802888:	89 fa                	mov    %edi,%edx
  80288a:	83 c4 1c             	add    $0x1c,%esp
  80288d:	5b                   	pop    %ebx
  80288e:	5e                   	pop    %esi
  80288f:	5f                   	pop    %edi
  802890:	5d                   	pop    %ebp
  802891:	c3                   	ret    
  802892:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802898:	31 ff                	xor    %edi,%edi
  80289a:	31 db                	xor    %ebx,%ebx
  80289c:	89 d8                	mov    %ebx,%eax
  80289e:	89 fa                	mov    %edi,%edx
  8028a0:	83 c4 1c             	add    $0x1c,%esp
  8028a3:	5b                   	pop    %ebx
  8028a4:	5e                   	pop    %esi
  8028a5:	5f                   	pop    %edi
  8028a6:	5d                   	pop    %ebp
  8028a7:	c3                   	ret    
  8028a8:	90                   	nop
  8028a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028b0:	89 d8                	mov    %ebx,%eax
  8028b2:	f7 f7                	div    %edi
  8028b4:	31 ff                	xor    %edi,%edi
  8028b6:	89 c3                	mov    %eax,%ebx
  8028b8:	89 d8                	mov    %ebx,%eax
  8028ba:	89 fa                	mov    %edi,%edx
  8028bc:	83 c4 1c             	add    $0x1c,%esp
  8028bf:	5b                   	pop    %ebx
  8028c0:	5e                   	pop    %esi
  8028c1:	5f                   	pop    %edi
  8028c2:	5d                   	pop    %ebp
  8028c3:	c3                   	ret    
  8028c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028c8:	39 ce                	cmp    %ecx,%esi
  8028ca:	72 0c                	jb     8028d8 <__udivdi3+0x118>
  8028cc:	31 db                	xor    %ebx,%ebx
  8028ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028d2:	0f 87 34 ff ff ff    	ja     80280c <__udivdi3+0x4c>
  8028d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028dd:	e9 2a ff ff ff       	jmp    80280c <__udivdi3+0x4c>
  8028e2:	66 90                	xchg   %ax,%ax
  8028e4:	66 90                	xchg   %ax,%ax
  8028e6:	66 90                	xchg   %ax,%ax
  8028e8:	66 90                	xchg   %ax,%ax
  8028ea:	66 90                	xchg   %ax,%ax
  8028ec:	66 90                	xchg   %ax,%ax
  8028ee:	66 90                	xchg   %ax,%ax

008028f0 <__umoddi3>:
  8028f0:	55                   	push   %ebp
  8028f1:	57                   	push   %edi
  8028f2:	56                   	push   %esi
  8028f3:	53                   	push   %ebx
  8028f4:	83 ec 1c             	sub    $0x1c,%esp
  8028f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802903:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802907:	85 d2                	test   %edx,%edx
  802909:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80290d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802911:	89 f3                	mov    %esi,%ebx
  802913:	89 3c 24             	mov    %edi,(%esp)
  802916:	89 74 24 04          	mov    %esi,0x4(%esp)
  80291a:	75 1c                	jne    802938 <__umoddi3+0x48>
  80291c:	39 f7                	cmp    %esi,%edi
  80291e:	76 50                	jbe    802970 <__umoddi3+0x80>
  802920:	89 c8                	mov    %ecx,%eax
  802922:	89 f2                	mov    %esi,%edx
  802924:	f7 f7                	div    %edi
  802926:	89 d0                	mov    %edx,%eax
  802928:	31 d2                	xor    %edx,%edx
  80292a:	83 c4 1c             	add    $0x1c,%esp
  80292d:	5b                   	pop    %ebx
  80292e:	5e                   	pop    %esi
  80292f:	5f                   	pop    %edi
  802930:	5d                   	pop    %ebp
  802931:	c3                   	ret    
  802932:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802938:	39 f2                	cmp    %esi,%edx
  80293a:	89 d0                	mov    %edx,%eax
  80293c:	77 52                	ja     802990 <__umoddi3+0xa0>
  80293e:	0f bd ea             	bsr    %edx,%ebp
  802941:	83 f5 1f             	xor    $0x1f,%ebp
  802944:	75 5a                	jne    8029a0 <__umoddi3+0xb0>
  802946:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80294a:	0f 82 e0 00 00 00    	jb     802a30 <__umoddi3+0x140>
  802950:	39 0c 24             	cmp    %ecx,(%esp)
  802953:	0f 86 d7 00 00 00    	jbe    802a30 <__umoddi3+0x140>
  802959:	8b 44 24 08          	mov    0x8(%esp),%eax
  80295d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802961:	83 c4 1c             	add    $0x1c,%esp
  802964:	5b                   	pop    %ebx
  802965:	5e                   	pop    %esi
  802966:	5f                   	pop    %edi
  802967:	5d                   	pop    %ebp
  802968:	c3                   	ret    
  802969:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802970:	85 ff                	test   %edi,%edi
  802972:	89 fd                	mov    %edi,%ebp
  802974:	75 0b                	jne    802981 <__umoddi3+0x91>
  802976:	b8 01 00 00 00       	mov    $0x1,%eax
  80297b:	31 d2                	xor    %edx,%edx
  80297d:	f7 f7                	div    %edi
  80297f:	89 c5                	mov    %eax,%ebp
  802981:	89 f0                	mov    %esi,%eax
  802983:	31 d2                	xor    %edx,%edx
  802985:	f7 f5                	div    %ebp
  802987:	89 c8                	mov    %ecx,%eax
  802989:	f7 f5                	div    %ebp
  80298b:	89 d0                	mov    %edx,%eax
  80298d:	eb 99                	jmp    802928 <__umoddi3+0x38>
  80298f:	90                   	nop
  802990:	89 c8                	mov    %ecx,%eax
  802992:	89 f2                	mov    %esi,%edx
  802994:	83 c4 1c             	add    $0x1c,%esp
  802997:	5b                   	pop    %ebx
  802998:	5e                   	pop    %esi
  802999:	5f                   	pop    %edi
  80299a:	5d                   	pop    %ebp
  80299b:	c3                   	ret    
  80299c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029a0:	8b 34 24             	mov    (%esp),%esi
  8029a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8029a8:	89 e9                	mov    %ebp,%ecx
  8029aa:	29 ef                	sub    %ebp,%edi
  8029ac:	d3 e0                	shl    %cl,%eax
  8029ae:	89 f9                	mov    %edi,%ecx
  8029b0:	89 f2                	mov    %esi,%edx
  8029b2:	d3 ea                	shr    %cl,%edx
  8029b4:	89 e9                	mov    %ebp,%ecx
  8029b6:	09 c2                	or     %eax,%edx
  8029b8:	89 d8                	mov    %ebx,%eax
  8029ba:	89 14 24             	mov    %edx,(%esp)
  8029bd:	89 f2                	mov    %esi,%edx
  8029bf:	d3 e2                	shl    %cl,%edx
  8029c1:	89 f9                	mov    %edi,%ecx
  8029c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029cb:	d3 e8                	shr    %cl,%eax
  8029cd:	89 e9                	mov    %ebp,%ecx
  8029cf:	89 c6                	mov    %eax,%esi
  8029d1:	d3 e3                	shl    %cl,%ebx
  8029d3:	89 f9                	mov    %edi,%ecx
  8029d5:	89 d0                	mov    %edx,%eax
  8029d7:	d3 e8                	shr    %cl,%eax
  8029d9:	89 e9                	mov    %ebp,%ecx
  8029db:	09 d8                	or     %ebx,%eax
  8029dd:	89 d3                	mov    %edx,%ebx
  8029df:	89 f2                	mov    %esi,%edx
  8029e1:	f7 34 24             	divl   (%esp)
  8029e4:	89 d6                	mov    %edx,%esi
  8029e6:	d3 e3                	shl    %cl,%ebx
  8029e8:	f7 64 24 04          	mull   0x4(%esp)
  8029ec:	39 d6                	cmp    %edx,%esi
  8029ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029f2:	89 d1                	mov    %edx,%ecx
  8029f4:	89 c3                	mov    %eax,%ebx
  8029f6:	72 08                	jb     802a00 <__umoddi3+0x110>
  8029f8:	75 11                	jne    802a0b <__umoddi3+0x11b>
  8029fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029fe:	73 0b                	jae    802a0b <__umoddi3+0x11b>
  802a00:	2b 44 24 04          	sub    0x4(%esp),%eax
  802a04:	1b 14 24             	sbb    (%esp),%edx
  802a07:	89 d1                	mov    %edx,%ecx
  802a09:	89 c3                	mov    %eax,%ebx
  802a0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802a0f:	29 da                	sub    %ebx,%edx
  802a11:	19 ce                	sbb    %ecx,%esi
  802a13:	89 f9                	mov    %edi,%ecx
  802a15:	89 f0                	mov    %esi,%eax
  802a17:	d3 e0                	shl    %cl,%eax
  802a19:	89 e9                	mov    %ebp,%ecx
  802a1b:	d3 ea                	shr    %cl,%edx
  802a1d:	89 e9                	mov    %ebp,%ecx
  802a1f:	d3 ee                	shr    %cl,%esi
  802a21:	09 d0                	or     %edx,%eax
  802a23:	89 f2                	mov    %esi,%edx
  802a25:	83 c4 1c             	add    $0x1c,%esp
  802a28:	5b                   	pop    %ebx
  802a29:	5e                   	pop    %esi
  802a2a:	5f                   	pop    %edi
  802a2b:	5d                   	pop    %ebp
  802a2c:	c3                   	ret    
  802a2d:	8d 76 00             	lea    0x0(%esi),%esi
  802a30:	29 f9                	sub    %edi,%ecx
  802a32:	19 d6                	sbb    %edx,%esi
  802a34:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a3c:	e9 18 ff ff ff       	jmp    802959 <__umoddi3+0x69>
