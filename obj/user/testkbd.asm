
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 3b 02 00 00       	call   80026c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 dd 0d 00 00       	call   800e21 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 9d 11 00 00       	call   8011f0 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 20 25 80 00       	push   $0x802520
  800065:	6a 0f                	push   $0xf
  800067:	68 2d 25 80 00       	push   $0x80252d
  80006c:	e8 5b 02 00 00       	call   8002cc <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 3c 25 80 00       	push   $0x80253c
  80007b:	6a 11                	push   $0x11
  80007d:	68 2d 25 80 00       	push   $0x80252d
  800082:	e8 45 02 00 00       	call   8002cc <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 ad 11 00 00       	call   801240 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 56 25 80 00       	push   $0x802556
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 2d 25 80 00       	push   $0x80252d
  8000a7:	e8 20 02 00 00       	call   8002cc <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 5e 25 80 00       	push   $0x80255e
  8000b4:	e8 58 08 00 00       	call   800911 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 6c 25 80 00       	push   $0x80256c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 7a 18 00 00       	call   80194a <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 70 25 80 00       	push   $0x802570
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 66 18 00 00       	call   80194a <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 88 25 80 00       	push   $0x802588
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 37 09 00 00       	call   800a3d <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2d                	jmp    800153 <devcons_write+0x46>
		m = n - tot;
  800126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800129:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80012b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800133:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	53                   	push   %ebx
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 8b 0a 00 00       	call   800bcf <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 36 0c 00 00       	call   800d84 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	89 f0                	mov    %esi,%eax
  800155:	3b 75 10             	cmp    0x10(%ebp),%esi
  800158:	72 cc                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	74 2a                	je     80019d <devcons_read+0x3b>
  800173:	eb 05                	jmp    80017a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800175:	e8 a7 0c 00 00       	call   800e21 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 23 0c 00 00       	call   800da2 <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 16                	js     80019d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb 05                	jmp    80019d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 ce 0b 00 00       	call   800d84 <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:

int
getchar(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 5e 11 00 00       	call   80132c <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 0f                	js     8001e4 <getchar+0x29>
		return r;
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
		return -E_EOF;
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001dd:	eb 05                	jmp    8001e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 ce 0e 00 00       	call   8010c6 <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:

int
opencons(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 56 0e 00 00       	call   801077 <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
		return r;
  800224:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	78 3e                	js     800268 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	68 07 04 00 00       	push   $0x407
  800232:	ff 75 f4             	pushl  -0xc(%ebp)
  800235:	6a 00                	push   $0x0
  800237:	e8 04 0c 00 00       	call   800e40 <sys_page_alloc>
  80023c:	83 c4 10             	add    $0x10,%esp
		return r;
  80023f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	78 23                	js     800268 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800245:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800253:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	e8 ed 0d 00 00       	call   801050 <fd2num>
  800263:	89 c2                	mov    %eax,%edx
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	89 d0                	mov    %edx,%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800277:	e8 86 0b 00 00       	call   800e02 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80027c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800281:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800284:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800289:	a3 08 44 80 00       	mov    %eax,0x804408
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80028e:	85 db                	test   %ebx,%ebx
  800290:	7e 07                	jle    800299 <libmain+0x2d>
		binaryname = argv[0];
  800292:	8b 06                	mov    (%esi),%eax
  800294:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	e8 90 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002a3:	e8 0a 00 00 00       	call   8002b2 <exit>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b8:	e8 5e 0f 00 00       	call   80121b <close_all>
	sys_env_destroy(0);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	6a 00                	push   $0x0
  8002c2:	e8 fa 0a 00 00       	call   800dc1 <sys_env_destroy>
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d4:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002da:	e8 23 0b 00 00       	call   800e02 <sys_getenvid>
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	56                   	push   %esi
  8002e9:	50                   	push   %eax
  8002ea:	68 a0 25 80 00       	push   $0x8025a0
  8002ef:	e8 b1 00 00 00       	call   8003a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	53                   	push   %ebx
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	e8 54 00 00 00       	call   800354 <vcprintf>
	cprintf("\n");
  800300:	c7 04 24 86 25 80 00 	movl   $0x802586,(%esp)
  800307:	e8 99 00 00 00       	call   8003a5 <cprintf>
  80030c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030f:	cc                   	int3   
  800310:	eb fd                	jmp    80030f <_panic+0x43>

00800312 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	53                   	push   %ebx
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031c:	8b 13                	mov    (%ebx),%edx
  80031e:	8d 42 01             	lea    0x1(%edx),%eax
  800321:	89 03                	mov    %eax,(%ebx)
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032f:	75 1a                	jne    80034b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 ff 00 00 00       	push   $0xff
  800339:	8d 43 08             	lea    0x8(%ebx),%eax
  80033c:	50                   	push   %eax
  80033d:	e8 42 0a 00 00       	call   800d84 <sys_cputs>
		b->idx = 0;
  800342:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800348:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80035d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800364:	00 00 00 
	b.cnt = 0;
  800367:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800371:	ff 75 0c             	pushl  0xc(%ebp)
  800374:	ff 75 08             	pushl  0x8(%ebp)
  800377:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037d:	50                   	push   %eax
  80037e:	68 12 03 80 00       	push   $0x800312
  800383:	e8 54 01 00 00       	call   8004dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	83 c4 08             	add    $0x8,%esp
  80038b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800391:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800397:	50                   	push   %eax
  800398:	e8 e7 09 00 00       	call   800d84 <sys_cputs>

	return b.cnt;
}
  80039d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ae:	50                   	push   %eax
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 9d ff ff ff       	call   800354 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 1c             	sub    $0x1c,%esp
  8003c2:	89 c7                	mov    %eax,%edi
  8003c4:	89 d6                	mov    %edx,%esi
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003dd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003e0:	39 d3                	cmp    %edx,%ebx
  8003e2:	72 05                	jb     8003e9 <printnum+0x30>
  8003e4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e7:	77 45                	ja     80042e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e9:	83 ec 0c             	sub    $0xc,%esp
  8003ec:	ff 75 18             	pushl  0x18(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003f5:	53                   	push   %ebx
  8003f6:	ff 75 10             	pushl  0x10(%ebp)
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800402:	ff 75 dc             	pushl  -0x24(%ebp)
  800405:	ff 75 d8             	pushl  -0x28(%ebp)
  800408:	e8 73 1e 00 00       	call   802280 <__udivdi3>
  80040d:	83 c4 18             	add    $0x18,%esp
  800410:	52                   	push   %edx
  800411:	50                   	push   %eax
  800412:	89 f2                	mov    %esi,%edx
  800414:	89 f8                	mov    %edi,%eax
  800416:	e8 9e ff ff ff       	call   8003b9 <printnum>
  80041b:	83 c4 20             	add    $0x20,%esp
  80041e:	eb 18                	jmp    800438 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	56                   	push   %esi
  800424:	ff 75 18             	pushl  0x18(%ebp)
  800427:	ff d7                	call   *%edi
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	eb 03                	jmp    800431 <printnum+0x78>
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800431:	83 eb 01             	sub    $0x1,%ebx
  800434:	85 db                	test   %ebx,%ebx
  800436:	7f e8                	jg     800420 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	56                   	push   %esi
  80043c:	83 ec 04             	sub    $0x4,%esp
  80043f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff 75 dc             	pushl  -0x24(%ebp)
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	e8 60 1f 00 00       	call   8023b0 <__umoddi3>
  800450:	83 c4 14             	add    $0x14,%esp
  800453:	0f be 80 c3 25 80 00 	movsbl 0x8025c3(%eax),%eax
  80045a:	50                   	push   %eax
  80045b:	ff d7                	call   *%edi
}
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800463:	5b                   	pop    %ebx
  800464:	5e                   	pop    %esi
  800465:	5f                   	pop    %edi
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046b:	83 fa 01             	cmp    $0x1,%edx
  80046e:	7e 0e                	jle    80047e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 08             	lea    0x8(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	8b 52 04             	mov    0x4(%edx),%edx
  80047c:	eb 22                	jmp    8004a0 <getuint+0x38>
	else if (lflag)
  80047e:	85 d2                	test   %edx,%edx
  800480:	74 10                	je     800492 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800482:	8b 10                	mov    (%eax),%edx
  800484:	8d 4a 04             	lea    0x4(%edx),%ecx
  800487:	89 08                	mov    %ecx,(%eax)
  800489:	8b 02                	mov    (%edx),%eax
  80048b:	ba 00 00 00 00       	mov    $0x0,%edx
  800490:	eb 0e                	jmp    8004a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800492:	8b 10                	mov    (%eax),%edx
  800494:	8d 4a 04             	lea    0x4(%edx),%ecx
  800497:	89 08                	mov    %ecx,(%eax)
  800499:	8b 02                	mov    (%edx),%eax
  80049b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b1:	73 0a                	jae    8004bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bb:	88 02                	mov    %al,(%edx)
}
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c8:	50                   	push   %eax
  8004c9:	ff 75 10             	pushl  0x10(%ebp)
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	ff 75 08             	pushl  0x8(%ebp)
  8004d2:	e8 05 00 00 00       	call   8004dc <vprintfmt>
	va_end(ap);
}
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	c9                   	leave  
  8004db:	c3                   	ret    

008004dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	83 ec 2c             	sub    $0x2c,%esp
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004eb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ee:	eb 12                	jmp    800502 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	0f 84 a9 03 00 00    	je     8008a1 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	50                   	push   %eax
  8004fd:	ff d6                	call   *%esi
  8004ff:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	83 f8 25             	cmp    $0x25,%eax
  80050c:	75 e2                	jne    8004f0 <vprintfmt+0x14>
  80050e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800512:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800519:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800520:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800527:	ba 00 00 00 00       	mov    $0x0,%edx
  80052c:	eb 07                	jmp    800535 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800531:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8d 47 01             	lea    0x1(%edi),%eax
  800538:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053b:	0f b6 07             	movzbl (%edi),%eax
  80053e:	0f b6 c8             	movzbl %al,%ecx
  800541:	83 e8 23             	sub    $0x23,%eax
  800544:	3c 55                	cmp    $0x55,%al
  800546:	0f 87 3a 03 00 00    	ja     800886 <vprintfmt+0x3aa>
  80054c:	0f b6 c0             	movzbl %al,%eax
  80054f:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800559:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80055d:	eb d6                	jmp    800535 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	b8 00 00 00 00       	mov    $0x0,%eax
  800567:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80056a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80056d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800571:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800574:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800577:	83 fa 09             	cmp    $0x9,%edx
  80057a:	77 39                	ja     8005b5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80057c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80057f:	eb e9                	jmp    80056a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 48 04             	lea    0x4(%eax),%ecx
  800587:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800592:	eb 27                	jmp    8005bb <vprintfmt+0xdf>
  800594:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800597:	85 c0                	test   %eax,%eax
  800599:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059e:	0f 49 c8             	cmovns %eax,%ecx
  8005a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	eb 8c                	jmp    800535 <vprintfmt+0x59>
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ac:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b3:	eb 80                	jmp    800535 <vprintfmt+0x59>
  8005b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bf:	0f 89 70 ff ff ff    	jns    800535 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005d2:	e9 5e ff ff ff       	jmp    800535 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005dd:	e9 53 ff ff ff       	jmp    800535 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	ff 30                	pushl  (%eax)
  8005f1:	ff d6                	call   *%esi
			break;
  8005f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f9:	e9 04 ff ff ff       	jmp    800502 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	99                   	cltd   
  80060a:	31 d0                	xor    %edx,%eax
  80060c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060e:	83 f8 0f             	cmp    $0xf,%eax
  800611:	7f 0b                	jg     80061e <vprintfmt+0x142>
  800613:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  80061a:	85 d2                	test   %edx,%edx
  80061c:	75 18                	jne    800636 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80061e:	50                   	push   %eax
  80061f:	68 db 25 80 00       	push   $0x8025db
  800624:	53                   	push   %ebx
  800625:	56                   	push   %esi
  800626:	e8 94 fe ff ff       	call   8004bf <printfmt>
  80062b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800631:	e9 cc fe ff ff       	jmp    800502 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800636:	52                   	push   %edx
  800637:	68 a9 29 80 00       	push   $0x8029a9
  80063c:	53                   	push   %ebx
  80063d:	56                   	push   %esi
  80063e:	e8 7c fe ff ff       	call   8004bf <printfmt>
  800643:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800649:	e9 b4 fe ff ff       	jmp    800502 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800659:	85 ff                	test   %edi,%edi
  80065b:	b8 d4 25 80 00       	mov    $0x8025d4,%eax
  800660:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800663:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800667:	0f 8e 94 00 00 00    	jle    800701 <vprintfmt+0x225>
  80066d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800671:	0f 84 98 00 00 00    	je     80070f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	ff 75 d0             	pushl  -0x30(%ebp)
  80067d:	57                   	push   %edi
  80067e:	e8 99 03 00 00       	call   800a1c <strnlen>
  800683:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800686:	29 c1                	sub    %eax,%ecx
  800688:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80068b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800692:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800695:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800698:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069a:	eb 0f                	jmp    8006ab <vprintfmt+0x1cf>
					putch(padc, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a5:	83 ef 01             	sub    $0x1,%edi
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	85 ff                	test   %edi,%edi
  8006ad:	7f ed                	jg     80069c <vprintfmt+0x1c0>
  8006af:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bc:	0f 49 c1             	cmovns %ecx,%eax
  8006bf:	29 c1                	sub    %eax,%ecx
  8006c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ca:	89 cb                	mov    %ecx,%ebx
  8006cc:	eb 4d                	jmp    80071b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d2:	74 1b                	je     8006ef <vprintfmt+0x213>
  8006d4:	0f be c0             	movsbl %al,%eax
  8006d7:	83 e8 20             	sub    $0x20,%eax
  8006da:	83 f8 5e             	cmp    $0x5e,%eax
  8006dd:	76 10                	jbe    8006ef <vprintfmt+0x213>
					putch('?', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	6a 3f                	push   $0x3f
  8006e7:	ff 55 08             	call   *0x8(%ebp)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 0d                	jmp    8006fc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	52                   	push   %edx
  8006f6:	ff 55 08             	call   *0x8(%ebp)
  8006f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fc:	83 eb 01             	sub    $0x1,%ebx
  8006ff:	eb 1a                	jmp    80071b <vprintfmt+0x23f>
  800701:	89 75 08             	mov    %esi,0x8(%ebp)
  800704:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800707:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070d:	eb 0c                	jmp    80071b <vprintfmt+0x23f>
  80070f:	89 75 08             	mov    %esi,0x8(%ebp)
  800712:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800715:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800718:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80071b:	83 c7 01             	add    $0x1,%edi
  80071e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800722:	0f be d0             	movsbl %al,%edx
  800725:	85 d2                	test   %edx,%edx
  800727:	74 23                	je     80074c <vprintfmt+0x270>
  800729:	85 f6                	test   %esi,%esi
  80072b:	78 a1                	js     8006ce <vprintfmt+0x1f2>
  80072d:	83 ee 01             	sub    $0x1,%esi
  800730:	79 9c                	jns    8006ce <vprintfmt+0x1f2>
  800732:	89 df                	mov    %ebx,%edi
  800734:	8b 75 08             	mov    0x8(%ebp),%esi
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073a:	eb 18                	jmp    800754 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 20                	push   $0x20
  800742:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800744:	83 ef 01             	sub    $0x1,%edi
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 08                	jmp    800754 <vprintfmt+0x278>
  80074c:	89 df                	mov    %ebx,%edi
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800754:	85 ff                	test   %edi,%edi
  800756:	7f e4                	jg     80073c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075b:	e9 a2 fd ff ff       	jmp    800502 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800760:	83 fa 01             	cmp    $0x1,%edx
  800763:	7e 16                	jle    80077b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8d 50 08             	lea    0x8(%eax),%edx
  80076b:	89 55 14             	mov    %edx,0x14(%ebp)
  80076e:	8b 50 04             	mov    0x4(%eax),%edx
  800771:	8b 00                	mov    (%eax),%eax
  800773:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800776:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800779:	eb 32                	jmp    8007ad <vprintfmt+0x2d1>
	else if (lflag)
  80077b:	85 d2                	test   %edx,%edx
  80077d:	74 18                	je     800797 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078d:	89 c1                	mov    %eax,%ecx
  80078f:	c1 f9 1f             	sar    $0x1f,%ecx
  800792:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800795:	eb 16                	jmp    8007ad <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 50 04             	lea    0x4(%eax),%edx
  80079d:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a5:	89 c1                	mov    %eax,%ecx
  8007a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007bc:	0f 89 90 00 00 00    	jns    800852 <vprintfmt+0x376>
				putch('-', putdat);
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	53                   	push   %ebx
  8007c6:	6a 2d                	push   $0x2d
  8007c8:	ff d6                	call   *%esi
				num = -(long long) num;
  8007ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007d0:	f7 d8                	neg    %eax
  8007d2:	83 d2 00             	adc    $0x0,%edx
  8007d5:	f7 da                	neg    %edx
  8007d7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007da:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007df:	eb 71                	jmp    800852 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e4:	e8 7f fc ff ff       	call   800468 <getuint>
			base = 10;
  8007e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007ee:	eb 62                	jmp    800852 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f3:	e8 70 fc ff ff       	call   800468 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8007f8:	83 ec 0c             	sub    $0xc,%esp
  8007fb:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8007ff:	51                   	push   %ecx
  800800:	ff 75 e0             	pushl  -0x20(%ebp)
  800803:	6a 08                	push   $0x8
  800805:	52                   	push   %edx
  800806:	50                   	push   %eax
  800807:	89 da                	mov    %ebx,%edx
  800809:	89 f0                	mov    %esi,%eax
  80080b:	e8 a9 fb ff ff       	call   8003b9 <printnum>
			break;
  800810:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800813:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800816:	e9 e7 fc ff ff       	jmp    800502 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	53                   	push   %ebx
  80081f:	6a 30                	push   $0x30
  800821:	ff d6                	call   *%esi
			putch('x', putdat);
  800823:	83 c4 08             	add    $0x8,%esp
  800826:	53                   	push   %ebx
  800827:	6a 78                	push   $0x78
  800829:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80082b:	8b 45 14             	mov    0x14(%ebp),%eax
  80082e:	8d 50 04             	lea    0x4(%eax),%edx
  800831:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800834:	8b 00                	mov    (%eax),%eax
  800836:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80083b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80083e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800843:	eb 0d                	jmp    800852 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800845:	8d 45 14             	lea    0x14(%ebp),%eax
  800848:	e8 1b fc ff ff       	call   800468 <getuint>
			base = 16;
  80084d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800852:	83 ec 0c             	sub    $0xc,%esp
  800855:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800859:	57                   	push   %edi
  80085a:	ff 75 e0             	pushl  -0x20(%ebp)
  80085d:	51                   	push   %ecx
  80085e:	52                   	push   %edx
  80085f:	50                   	push   %eax
  800860:	89 da                	mov    %ebx,%edx
  800862:	89 f0                	mov    %esi,%eax
  800864:	e8 50 fb ff ff       	call   8003b9 <printnum>
			break;
  800869:	83 c4 20             	add    $0x20,%esp
  80086c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80086f:	e9 8e fc ff ff       	jmp    800502 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800874:	83 ec 08             	sub    $0x8,%esp
  800877:	53                   	push   %ebx
  800878:	51                   	push   %ecx
  800879:	ff d6                	call   *%esi
			break;
  80087b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800881:	e9 7c fc ff ff       	jmp    800502 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	6a 25                	push   $0x25
  80088c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80088e:	83 c4 10             	add    $0x10,%esp
  800891:	eb 03                	jmp    800896 <vprintfmt+0x3ba>
  800893:	83 ef 01             	sub    $0x1,%edi
  800896:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80089a:	75 f7                	jne    800893 <vprintfmt+0x3b7>
  80089c:	e9 61 fc ff ff       	jmp    800502 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a4:	5b                   	pop    %ebx
  8008a5:	5e                   	pop    %esi
  8008a6:	5f                   	pop    %edi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	83 ec 18             	sub    $0x18,%esp
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008bc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c6:	85 c0                	test   %eax,%eax
  8008c8:	74 26                	je     8008f0 <vsnprintf+0x47>
  8008ca:	85 d2                	test   %edx,%edx
  8008cc:	7e 22                	jle    8008f0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ce:	ff 75 14             	pushl  0x14(%ebp)
  8008d1:	ff 75 10             	pushl  0x10(%ebp)
  8008d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d7:	50                   	push   %eax
  8008d8:	68 a2 04 80 00       	push   $0x8004a2
  8008dd:	e8 fa fb ff ff       	call   8004dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	eb 05                	jmp    8008f5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008fd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800900:	50                   	push   %eax
  800901:	ff 75 10             	pushl  0x10(%ebp)
  800904:	ff 75 0c             	pushl  0xc(%ebp)
  800907:	ff 75 08             	pushl  0x8(%ebp)
  80090a:	e8 9a ff ff ff       	call   8008a9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	57                   	push   %edi
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	83 ec 0c             	sub    $0xc,%esp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80091d:	85 c0                	test   %eax,%eax
  80091f:	74 13                	je     800934 <readline+0x23>
		fprintf(1, "%s", prompt);
  800921:	83 ec 04             	sub    $0x4,%esp
  800924:	50                   	push   %eax
  800925:	68 a9 29 80 00       	push   $0x8029a9
  80092a:	6a 01                	push   $0x1
  80092c:	e8 19 10 00 00       	call   80194a <fprintf>
  800931:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800934:	83 ec 0c             	sub    $0xc,%esp
  800937:	6a 00                	push   $0x0
  800939:	e8 a8 f8 ff ff       	call   8001e6 <iscons>
  80093e:	89 c7                	mov    %eax,%edi
  800940:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800943:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800948:	e8 6e f8 ff ff       	call   8001bb <getchar>
  80094d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80094f:	85 c0                	test   %eax,%eax
  800951:	79 29                	jns    80097c <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  800958:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80095b:	0f 84 9b 00 00 00    	je     8009fc <readline+0xeb>
				cprintf("read error: %e\n", c);
  800961:	83 ec 08             	sub    $0x8,%esp
  800964:	53                   	push   %ebx
  800965:	68 bf 28 80 00       	push   $0x8028bf
  80096a:	e8 36 fa ff ff       	call   8003a5 <cprintf>
  80096f:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
  800977:	e9 80 00 00 00       	jmp    8009fc <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  80097c:	83 f8 08             	cmp    $0x8,%eax
  80097f:	0f 94 c2             	sete   %dl
  800982:	83 f8 7f             	cmp    $0x7f,%eax
  800985:	0f 94 c0             	sete   %al
  800988:	08 c2                	or     %al,%dl
  80098a:	74 1a                	je     8009a6 <readline+0x95>
  80098c:	85 f6                	test   %esi,%esi
  80098e:	7e 16                	jle    8009a6 <readline+0x95>
			if (echoing)
  800990:	85 ff                	test   %edi,%edi
  800992:	74 0d                	je     8009a1 <readline+0x90>
				cputchar('\b');
  800994:	83 ec 0c             	sub    $0xc,%esp
  800997:	6a 08                	push   $0x8
  800999:	e8 01 f8 ff ff       	call   80019f <cputchar>
  80099e:	83 c4 10             	add    $0x10,%esp
			i--;
  8009a1:	83 ee 01             	sub    $0x1,%esi
  8009a4:	eb a2                	jmp    800948 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009a6:	83 fb 1f             	cmp    $0x1f,%ebx
  8009a9:	7e 26                	jle    8009d1 <readline+0xc0>
  8009ab:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009b1:	7f 1e                	jg     8009d1 <readline+0xc0>
			if (echoing)
  8009b3:	85 ff                	test   %edi,%edi
  8009b5:	74 0c                	je     8009c3 <readline+0xb2>
				cputchar(c);
  8009b7:	83 ec 0c             	sub    $0xc,%esp
  8009ba:	53                   	push   %ebx
  8009bb:	e8 df f7 ff ff       	call   80019f <cputchar>
  8009c0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009c3:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009c9:	8d 76 01             	lea    0x1(%esi),%esi
  8009cc:	e9 77 ff ff ff       	jmp    800948 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009d1:	83 fb 0a             	cmp    $0xa,%ebx
  8009d4:	74 09                	je     8009df <readline+0xce>
  8009d6:	83 fb 0d             	cmp    $0xd,%ebx
  8009d9:	0f 85 69 ff ff ff    	jne    800948 <readline+0x37>
			if (echoing)
  8009df:	85 ff                	test   %edi,%edi
  8009e1:	74 0d                	je     8009f0 <readline+0xdf>
				cputchar('\n');
  8009e3:	83 ec 0c             	sub    $0xc,%esp
  8009e6:	6a 0a                	push   $0xa
  8009e8:	e8 b2 f7 ff ff       	call   80019f <cputchar>
  8009ed:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8009f0:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  8009f7:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  8009fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0f:	eb 03                	jmp    800a14 <strlen+0x10>
		n++;
  800a11:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a14:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a18:	75 f7                	jne    800a11 <strlen+0xd>
		n++;
	return n;
}
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a22:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a25:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2a:	eb 03                	jmp    800a2f <strnlen+0x13>
		n++;
  800a2c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2f:	39 c2                	cmp    %eax,%edx
  800a31:	74 08                	je     800a3b <strnlen+0x1f>
  800a33:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a37:	75 f3                	jne    800a2c <strnlen+0x10>
  800a39:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	53                   	push   %ebx
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a47:	89 c2                	mov    %eax,%edx
  800a49:	83 c2 01             	add    $0x1,%edx
  800a4c:	83 c1 01             	add    $0x1,%ecx
  800a4f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a53:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a56:	84 db                	test   %bl,%bl
  800a58:	75 ef                	jne    800a49 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	53                   	push   %ebx
  800a61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a64:	53                   	push   %ebx
  800a65:	e8 9a ff ff ff       	call   800a04 <strlen>
  800a6a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a6d:	ff 75 0c             	pushl  0xc(%ebp)
  800a70:	01 d8                	add    %ebx,%eax
  800a72:	50                   	push   %eax
  800a73:	e8 c5 ff ff ff       	call   800a3d <strcpy>
	return dst;
}
  800a78:	89 d8                	mov    %ebx,%eax
  800a7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 75 08             	mov    0x8(%ebp),%esi
  800a87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8a:	89 f3                	mov    %esi,%ebx
  800a8c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8f:	89 f2                	mov    %esi,%edx
  800a91:	eb 0f                	jmp    800aa2 <strncpy+0x23>
		*dst++ = *src;
  800a93:	83 c2 01             	add    $0x1,%edx
  800a96:	0f b6 01             	movzbl (%ecx),%eax
  800a99:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9c:	80 39 01             	cmpb   $0x1,(%ecx)
  800a9f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa2:	39 da                	cmp    %ebx,%edx
  800aa4:	75 ed                	jne    800a93 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa6:	89 f0                	mov    %esi,%eax
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab7:	8b 55 10             	mov    0x10(%ebp),%edx
  800aba:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abc:	85 d2                	test   %edx,%edx
  800abe:	74 21                	je     800ae1 <strlcpy+0x35>
  800ac0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ac4:	89 f2                	mov    %esi,%edx
  800ac6:	eb 09                	jmp    800ad1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ac8:	83 c2 01             	add    $0x1,%edx
  800acb:	83 c1 01             	add    $0x1,%ecx
  800ace:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ad1:	39 c2                	cmp    %eax,%edx
  800ad3:	74 09                	je     800ade <strlcpy+0x32>
  800ad5:	0f b6 19             	movzbl (%ecx),%ebx
  800ad8:	84 db                	test   %bl,%bl
  800ada:	75 ec                	jne    800ac8 <strlcpy+0x1c>
  800adc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ade:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae1:	29 f0                	sub    %esi,%eax
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aed:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af0:	eb 06                	jmp    800af8 <strcmp+0x11>
		p++, q++;
  800af2:	83 c1 01             	add    $0x1,%ecx
  800af5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800af8:	0f b6 01             	movzbl (%ecx),%eax
  800afb:	84 c0                	test   %al,%al
  800afd:	74 04                	je     800b03 <strcmp+0x1c>
  800aff:	3a 02                	cmp    (%edx),%al
  800b01:	74 ef                	je     800af2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b03:	0f b6 c0             	movzbl %al,%eax
  800b06:	0f b6 12             	movzbl (%edx),%edx
  800b09:	29 d0                	sub    %edx,%eax
}
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	53                   	push   %ebx
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b17:	89 c3                	mov    %eax,%ebx
  800b19:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b1c:	eb 06                	jmp    800b24 <strncmp+0x17>
		n--, p++, q++;
  800b1e:	83 c0 01             	add    $0x1,%eax
  800b21:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b24:	39 d8                	cmp    %ebx,%eax
  800b26:	74 15                	je     800b3d <strncmp+0x30>
  800b28:	0f b6 08             	movzbl (%eax),%ecx
  800b2b:	84 c9                	test   %cl,%cl
  800b2d:	74 04                	je     800b33 <strncmp+0x26>
  800b2f:	3a 0a                	cmp    (%edx),%cl
  800b31:	74 eb                	je     800b1e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b33:	0f b6 00             	movzbl (%eax),%eax
  800b36:	0f b6 12             	movzbl (%edx),%edx
  800b39:	29 d0                	sub    %edx,%eax
  800b3b:	eb 05                	jmp    800b42 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b42:	5b                   	pop    %ebx
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b4f:	eb 07                	jmp    800b58 <strchr+0x13>
		if (*s == c)
  800b51:	38 ca                	cmp    %cl,%dl
  800b53:	74 0f                	je     800b64 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b55:	83 c0 01             	add    $0x1,%eax
  800b58:	0f b6 10             	movzbl (%eax),%edx
  800b5b:	84 d2                	test   %dl,%dl
  800b5d:	75 f2                	jne    800b51 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b70:	eb 03                	jmp    800b75 <strfind+0xf>
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b78:	38 ca                	cmp    %cl,%dl
  800b7a:	74 04                	je     800b80 <strfind+0x1a>
  800b7c:	84 d2                	test   %dl,%dl
  800b7e:	75 f2                	jne    800b72 <strfind+0xc>
			break;
	return (char *) s;
}
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b8e:	85 c9                	test   %ecx,%ecx
  800b90:	74 36                	je     800bc8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b92:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b98:	75 28                	jne    800bc2 <memset+0x40>
  800b9a:	f6 c1 03             	test   $0x3,%cl
  800b9d:	75 23                	jne    800bc2 <memset+0x40>
		c &= 0xFF;
  800b9f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba3:	89 d3                	mov    %edx,%ebx
  800ba5:	c1 e3 08             	shl    $0x8,%ebx
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	c1 e6 18             	shl    $0x18,%esi
  800bad:	89 d0                	mov    %edx,%eax
  800baf:	c1 e0 10             	shl    $0x10,%eax
  800bb2:	09 f0                	or     %esi,%eax
  800bb4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bb6:	89 d8                	mov    %ebx,%eax
  800bb8:	09 d0                	or     %edx,%eax
  800bba:	c1 e9 02             	shr    $0x2,%ecx
  800bbd:	fc                   	cld    
  800bbe:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc0:	eb 06                	jmp    800bc8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc5:	fc                   	cld    
  800bc6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bc8:	89 f8                	mov    %edi,%eax
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bda:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bdd:	39 c6                	cmp    %eax,%esi
  800bdf:	73 35                	jae    800c16 <memmove+0x47>
  800be1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be4:	39 d0                	cmp    %edx,%eax
  800be6:	73 2e                	jae    800c16 <memmove+0x47>
		s += n;
		d += n;
  800be8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800beb:	89 d6                	mov    %edx,%esi
  800bed:	09 fe                	or     %edi,%esi
  800bef:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf5:	75 13                	jne    800c0a <memmove+0x3b>
  800bf7:	f6 c1 03             	test   $0x3,%cl
  800bfa:	75 0e                	jne    800c0a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bfc:	83 ef 04             	sub    $0x4,%edi
  800bff:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c02:	c1 e9 02             	shr    $0x2,%ecx
  800c05:	fd                   	std    
  800c06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c08:	eb 09                	jmp    800c13 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c0a:	83 ef 01             	sub    $0x1,%edi
  800c0d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c10:	fd                   	std    
  800c11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c13:	fc                   	cld    
  800c14:	eb 1d                	jmp    800c33 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c16:	89 f2                	mov    %esi,%edx
  800c18:	09 c2                	or     %eax,%edx
  800c1a:	f6 c2 03             	test   $0x3,%dl
  800c1d:	75 0f                	jne    800c2e <memmove+0x5f>
  800c1f:	f6 c1 03             	test   $0x3,%cl
  800c22:	75 0a                	jne    800c2e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c24:	c1 e9 02             	shr    $0x2,%ecx
  800c27:	89 c7                	mov    %eax,%edi
  800c29:	fc                   	cld    
  800c2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2c:	eb 05                	jmp    800c33 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c2e:	89 c7                	mov    %eax,%edi
  800c30:	fc                   	cld    
  800c31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c3a:	ff 75 10             	pushl  0x10(%ebp)
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	ff 75 08             	pushl  0x8(%ebp)
  800c43:	e8 87 ff ff ff       	call   800bcf <memmove>
}
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    

00800c4a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c55:	89 c6                	mov    %eax,%esi
  800c57:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5a:	eb 1a                	jmp    800c76 <memcmp+0x2c>
		if (*s1 != *s2)
  800c5c:	0f b6 08             	movzbl (%eax),%ecx
  800c5f:	0f b6 1a             	movzbl (%edx),%ebx
  800c62:	38 d9                	cmp    %bl,%cl
  800c64:	74 0a                	je     800c70 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c66:	0f b6 c1             	movzbl %cl,%eax
  800c69:	0f b6 db             	movzbl %bl,%ebx
  800c6c:	29 d8                	sub    %ebx,%eax
  800c6e:	eb 0f                	jmp    800c7f <memcmp+0x35>
		s1++, s2++;
  800c70:	83 c0 01             	add    $0x1,%eax
  800c73:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c76:	39 f0                	cmp    %esi,%eax
  800c78:	75 e2                	jne    800c5c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	53                   	push   %ebx
  800c87:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c8a:	89 c1                	mov    %eax,%ecx
  800c8c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c93:	eb 0a                	jmp    800c9f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c95:	0f b6 10             	movzbl (%eax),%edx
  800c98:	39 da                	cmp    %ebx,%edx
  800c9a:	74 07                	je     800ca3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c9c:	83 c0 01             	add    $0x1,%eax
  800c9f:	39 c8                	cmp    %ecx,%eax
  800ca1:	72 f2                	jb     800c95 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ca3:	5b                   	pop    %ebx
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800caf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb2:	eb 03                	jmp    800cb7 <strtol+0x11>
		s++;
  800cb4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb7:	0f b6 01             	movzbl (%ecx),%eax
  800cba:	3c 20                	cmp    $0x20,%al
  800cbc:	74 f6                	je     800cb4 <strtol+0xe>
  800cbe:	3c 09                	cmp    $0x9,%al
  800cc0:	74 f2                	je     800cb4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc2:	3c 2b                	cmp    $0x2b,%al
  800cc4:	75 0a                	jne    800cd0 <strtol+0x2a>
		s++;
  800cc6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cce:	eb 11                	jmp    800ce1 <strtol+0x3b>
  800cd0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cd5:	3c 2d                	cmp    $0x2d,%al
  800cd7:	75 08                	jne    800ce1 <strtol+0x3b>
		s++, neg = 1;
  800cd9:	83 c1 01             	add    $0x1,%ecx
  800cdc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ce7:	75 15                	jne    800cfe <strtol+0x58>
  800ce9:	80 39 30             	cmpb   $0x30,(%ecx)
  800cec:	75 10                	jne    800cfe <strtol+0x58>
  800cee:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cf2:	75 7c                	jne    800d70 <strtol+0xca>
		s += 2, base = 16;
  800cf4:	83 c1 02             	add    $0x2,%ecx
  800cf7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cfc:	eb 16                	jmp    800d14 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cfe:	85 db                	test   %ebx,%ebx
  800d00:	75 12                	jne    800d14 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d02:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d07:	80 39 30             	cmpb   $0x30,(%ecx)
  800d0a:	75 08                	jne    800d14 <strtol+0x6e>
		s++, base = 8;
  800d0c:	83 c1 01             	add    $0x1,%ecx
  800d0f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d14:	b8 00 00 00 00       	mov    $0x0,%eax
  800d19:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d1c:	0f b6 11             	movzbl (%ecx),%edx
  800d1f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d22:	89 f3                	mov    %esi,%ebx
  800d24:	80 fb 09             	cmp    $0x9,%bl
  800d27:	77 08                	ja     800d31 <strtol+0x8b>
			dig = *s - '0';
  800d29:	0f be d2             	movsbl %dl,%edx
  800d2c:	83 ea 30             	sub    $0x30,%edx
  800d2f:	eb 22                	jmp    800d53 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d31:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d34:	89 f3                	mov    %esi,%ebx
  800d36:	80 fb 19             	cmp    $0x19,%bl
  800d39:	77 08                	ja     800d43 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d3b:	0f be d2             	movsbl %dl,%edx
  800d3e:	83 ea 57             	sub    $0x57,%edx
  800d41:	eb 10                	jmp    800d53 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d43:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d46:	89 f3                	mov    %esi,%ebx
  800d48:	80 fb 19             	cmp    $0x19,%bl
  800d4b:	77 16                	ja     800d63 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d4d:	0f be d2             	movsbl %dl,%edx
  800d50:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d53:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d56:	7d 0b                	jge    800d63 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d58:	83 c1 01             	add    $0x1,%ecx
  800d5b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d5f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d61:	eb b9                	jmp    800d1c <strtol+0x76>

	if (endptr)
  800d63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d67:	74 0d                	je     800d76 <strtol+0xd0>
		*endptr = (char *) s;
  800d69:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d6c:	89 0e                	mov    %ecx,(%esi)
  800d6e:	eb 06                	jmp    800d76 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d70:	85 db                	test   %ebx,%ebx
  800d72:	74 98                	je     800d0c <strtol+0x66>
  800d74:	eb 9e                	jmp    800d14 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d76:	89 c2                	mov    %eax,%edx
  800d78:	f7 da                	neg    %edx
  800d7a:	85 ff                	test   %edi,%edi
  800d7c:	0f 45 c2             	cmovne %edx,%eax
}
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	8b 55 08             	mov    0x8(%ebp),%edx
  800d95:	89 c3                	mov    %eax,%ebx
  800d97:	89 c7                	mov    %eax,%edi
  800d99:	89 c6                	mov    %eax,%esi
  800d9b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dad:	b8 01 00 00 00       	mov    $0x1,%eax
  800db2:	89 d1                	mov    %edx,%ecx
  800db4:	89 d3                	mov    %edx,%ebx
  800db6:	89 d7                	mov    %edx,%edi
  800db8:	89 d6                	mov    %edx,%esi
  800dba:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dcf:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	89 cb                	mov    %ecx,%ebx
  800dd9:	89 cf                	mov    %ecx,%edi
  800ddb:	89 ce                	mov    %ecx,%esi
  800ddd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 17                	jle    800dfa <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	50                   	push   %eax
  800de7:	6a 03                	push   $0x3
  800de9:	68 cf 28 80 00       	push   $0x8028cf
  800dee:	6a 23                	push   $0x23
  800df0:	68 ec 28 80 00       	push   $0x8028ec
  800df5:	e8 d2 f4 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e08:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e12:	89 d1                	mov    %edx,%ecx
  800e14:	89 d3                	mov    %edx,%ebx
  800e16:	89 d7                	mov    %edx,%edi
  800e18:	89 d6                	mov    %edx,%esi
  800e1a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <sys_yield>:

void
sys_yield(void)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e27:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e31:	89 d1                	mov    %edx,%ecx
  800e33:	89 d3                	mov    %edx,%ebx
  800e35:	89 d7                	mov    %edx,%edi
  800e37:	89 d6                	mov    %edx,%esi
  800e39:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e49:	be 00 00 00 00       	mov    $0x0,%esi
  800e4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5c:	89 f7                	mov    %esi,%edi
  800e5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	7e 17                	jle    800e7b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e64:	83 ec 0c             	sub    $0xc,%esp
  800e67:	50                   	push   %eax
  800e68:	6a 04                	push   $0x4
  800e6a:	68 cf 28 80 00       	push   $0x8028cf
  800e6f:	6a 23                	push   $0x23
  800e71:	68 ec 28 80 00       	push   $0x8028ec
  800e76:	e8 51 f4 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	b8 05 00 00 00       	mov    $0x5,%eax
  800e91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e94:	8b 55 08             	mov    0x8(%ebp),%edx
  800e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e9d:	8b 75 18             	mov    0x18(%ebp),%esi
  800ea0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	7e 17                	jle    800ebd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea6:	83 ec 0c             	sub    $0xc,%esp
  800ea9:	50                   	push   %eax
  800eaa:	6a 05                	push   $0x5
  800eac:	68 cf 28 80 00       	push   $0x8028cf
  800eb1:	6a 23                	push   $0x23
  800eb3:	68 ec 28 80 00       	push   $0x8028ec
  800eb8:	e8 0f f4 ff ff       	call   8002cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ebd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	57                   	push   %edi
  800ec9:	56                   	push   %esi
  800eca:	53                   	push   %ebx
  800ecb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ece:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ede:	89 df                	mov    %ebx,%edi
  800ee0:	89 de                	mov    %ebx,%esi
  800ee2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 06                	push   $0x6
  800eee:	68 cf 28 80 00       	push   $0x8028cf
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 ec 28 80 00       	push   $0x8028ec
  800efa:	e8 cd f3 ff ff       	call   8002cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
  800f0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f15:	b8 08 00 00 00       	mov    $0x8,%eax
  800f1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f20:	89 df                	mov    %ebx,%edi
  800f22:	89 de                	mov    %ebx,%esi
  800f24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	7e 17                	jle    800f41 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2a:	83 ec 0c             	sub    $0xc,%esp
  800f2d:	50                   	push   %eax
  800f2e:	6a 08                	push   $0x8
  800f30:	68 cf 28 80 00       	push   $0x8028cf
  800f35:	6a 23                	push   $0x23
  800f37:	68 ec 28 80 00       	push   $0x8028ec
  800f3c:	e8 8b f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	57                   	push   %edi
  800f4d:	56                   	push   %esi
  800f4e:	53                   	push   %ebx
  800f4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f57:	b8 09 00 00 00       	mov    $0x9,%eax
  800f5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f62:	89 df                	mov    %ebx,%edi
  800f64:	89 de                	mov    %ebx,%esi
  800f66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	7e 17                	jle    800f83 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	50                   	push   %eax
  800f70:	6a 09                	push   $0x9
  800f72:	68 cf 28 80 00       	push   $0x8028cf
  800f77:	6a 23                	push   $0x23
  800f79:	68 ec 28 80 00       	push   $0x8028ec
  800f7e:	e8 49 f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f86:	5b                   	pop    %ebx
  800f87:	5e                   	pop    %esi
  800f88:	5f                   	pop    %edi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	57                   	push   %edi
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
  800f91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa4:	89 df                	mov    %ebx,%edi
  800fa6:	89 de                	mov    %ebx,%esi
  800fa8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800faa:	85 c0                	test   %eax,%eax
  800fac:	7e 17                	jle    800fc5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	50                   	push   %eax
  800fb2:	6a 0a                	push   $0xa
  800fb4:	68 cf 28 80 00       	push   $0x8028cf
  800fb9:	6a 23                	push   $0x23
  800fbb:	68 ec 28 80 00       	push   $0x8028ec
  800fc0:	e8 07 f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	be 00 00 00 00       	mov    $0x0,%esi
  800fd8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fe9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	53                   	push   %ebx
  800ff6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffe:	b8 0d 00 00 00       	mov    $0xd,%eax
  801003:	8b 55 08             	mov    0x8(%ebp),%edx
  801006:	89 cb                	mov    %ecx,%ebx
  801008:	89 cf                	mov    %ecx,%edi
  80100a:	89 ce                	mov    %ecx,%esi
  80100c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80100e:	85 c0                	test   %eax,%eax
  801010:	7e 17                	jle    801029 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	50                   	push   %eax
  801016:	6a 0d                	push   $0xd
  801018:	68 cf 28 80 00       	push   $0x8028cf
  80101d:	6a 23                	push   $0x23
  80101f:	68 ec 28 80 00       	push   $0x8028ec
  801024:	e8 a3 f2 ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801029:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5f                   	pop    %edi
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	57                   	push   %edi
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801037:	ba 00 00 00 00       	mov    $0x0,%edx
  80103c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801041:	89 d1                	mov    %edx,%ecx
  801043:	89 d3                	mov    %edx,%ebx
  801045:	89 d7                	mov    %edx,%edi
  801047:	89 d6                	mov    %edx,%esi
  801049:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	05 00 00 00 30       	add    $0x30000000,%eax
  80105b:	c1 e8 0c             	shr    $0xc,%eax
}
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	05 00 00 00 30       	add    $0x30000000,%eax
  80106b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801070:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801082:	89 c2                	mov    %eax,%edx
  801084:	c1 ea 16             	shr    $0x16,%edx
  801087:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108e:	f6 c2 01             	test   $0x1,%dl
  801091:	74 11                	je     8010a4 <fd_alloc+0x2d>
  801093:	89 c2                	mov    %eax,%edx
  801095:	c1 ea 0c             	shr    $0xc,%edx
  801098:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109f:	f6 c2 01             	test   $0x1,%dl
  8010a2:	75 09                	jne    8010ad <fd_alloc+0x36>
			*fd_store = fd;
  8010a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ab:	eb 17                	jmp    8010c4 <fd_alloc+0x4d>
  8010ad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010b7:	75 c9                	jne    801082 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010b9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010bf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010cc:	83 f8 1f             	cmp    $0x1f,%eax
  8010cf:	77 36                	ja     801107 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d1:	c1 e0 0c             	shl    $0xc,%eax
  8010d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010d9:	89 c2                	mov    %eax,%edx
  8010db:	c1 ea 16             	shr    $0x16,%edx
  8010de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e5:	f6 c2 01             	test   $0x1,%dl
  8010e8:	74 24                	je     80110e <fd_lookup+0x48>
  8010ea:	89 c2                	mov    %eax,%edx
  8010ec:	c1 ea 0c             	shr    $0xc,%edx
  8010ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f6:	f6 c2 01             	test   $0x1,%dl
  8010f9:	74 1a                	je     801115 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fe:	89 02                	mov    %eax,(%edx)
	return 0;
  801100:	b8 00 00 00 00       	mov    $0x0,%eax
  801105:	eb 13                	jmp    80111a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801107:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110c:	eb 0c                	jmp    80111a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80110e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801113:	eb 05                	jmp    80111a <fd_lookup+0x54>
  801115:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 08             	sub    $0x8,%esp
  801122:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801125:	ba 7c 29 80 00       	mov    $0x80297c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80112a:	eb 13                	jmp    80113f <dev_lookup+0x23>
  80112c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80112f:	39 08                	cmp    %ecx,(%eax)
  801131:	75 0c                	jne    80113f <dev_lookup+0x23>
			*dev = devtab[i];
  801133:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801136:	89 01                	mov    %eax,(%ecx)
			return 0;
  801138:	b8 00 00 00 00       	mov    $0x0,%eax
  80113d:	eb 2e                	jmp    80116d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80113f:	8b 02                	mov    (%edx),%eax
  801141:	85 c0                	test   %eax,%eax
  801143:	75 e7                	jne    80112c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801145:	a1 08 44 80 00       	mov    0x804408,%eax
  80114a:	8b 40 48             	mov    0x48(%eax),%eax
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	51                   	push   %ecx
  801151:	50                   	push   %eax
  801152:	68 fc 28 80 00       	push   $0x8028fc
  801157:	e8 49 f2 ff ff       	call   8003a5 <cprintf>
	*dev = 0;
  80115c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    

0080116f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 10             	sub    $0x10,%esp
  801177:	8b 75 08             	mov    0x8(%ebp),%esi
  80117a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80117d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801180:	50                   	push   %eax
  801181:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801187:	c1 e8 0c             	shr    $0xc,%eax
  80118a:	50                   	push   %eax
  80118b:	e8 36 ff ff ff       	call   8010c6 <fd_lookup>
  801190:	83 c4 08             	add    $0x8,%esp
  801193:	85 c0                	test   %eax,%eax
  801195:	78 05                	js     80119c <fd_close+0x2d>
	    || fd != fd2)
  801197:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80119a:	74 0c                	je     8011a8 <fd_close+0x39>
		return (must_exist ? r : 0);
  80119c:	84 db                	test   %bl,%bl
  80119e:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a3:	0f 44 c2             	cmove  %edx,%eax
  8011a6:	eb 41                	jmp    8011e9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ae:	50                   	push   %eax
  8011af:	ff 36                	pushl  (%esi)
  8011b1:	e8 66 ff ff ff       	call   80111c <dev_lookup>
  8011b6:	89 c3                	mov    %eax,%ebx
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 1a                	js     8011d9 <fd_close+0x6a>
		if (dev->dev_close)
  8011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011c5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	74 0b                	je     8011d9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011ce:	83 ec 0c             	sub    $0xc,%esp
  8011d1:	56                   	push   %esi
  8011d2:	ff d0                	call   *%eax
  8011d4:	89 c3                	mov    %eax,%ebx
  8011d6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011d9:	83 ec 08             	sub    $0x8,%esp
  8011dc:	56                   	push   %esi
  8011dd:	6a 00                	push   $0x0
  8011df:	e8 e1 fc ff ff       	call   800ec5 <sys_page_unmap>
	return r;
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	89 d8                	mov    %ebx,%eax
}
  8011e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ec:	5b                   	pop    %ebx
  8011ed:	5e                   	pop    %esi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	ff 75 08             	pushl  0x8(%ebp)
  8011fd:	e8 c4 fe ff ff       	call   8010c6 <fd_lookup>
  801202:	83 c4 08             	add    $0x8,%esp
  801205:	85 c0                	test   %eax,%eax
  801207:	78 10                	js     801219 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801209:	83 ec 08             	sub    $0x8,%esp
  80120c:	6a 01                	push   $0x1
  80120e:	ff 75 f4             	pushl  -0xc(%ebp)
  801211:	e8 59 ff ff ff       	call   80116f <fd_close>
  801216:	83 c4 10             	add    $0x10,%esp
}
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <close_all>:

void
close_all(void)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	53                   	push   %ebx
  80121f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801222:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801227:	83 ec 0c             	sub    $0xc,%esp
  80122a:	53                   	push   %ebx
  80122b:	e8 c0 ff ff ff       	call   8011f0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801230:	83 c3 01             	add    $0x1,%ebx
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	83 fb 20             	cmp    $0x20,%ebx
  801239:	75 ec                	jne    801227 <close_all+0xc>
		close(i);
}
  80123b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123e:	c9                   	leave  
  80123f:	c3                   	ret    

00801240 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	53                   	push   %ebx
  801246:	83 ec 2c             	sub    $0x2c,%esp
  801249:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80124c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	ff 75 08             	pushl  0x8(%ebp)
  801253:	e8 6e fe ff ff       	call   8010c6 <fd_lookup>
  801258:	83 c4 08             	add    $0x8,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	0f 88 c1 00 00 00    	js     801324 <dup+0xe4>
		return r;
	close(newfdnum);
  801263:	83 ec 0c             	sub    $0xc,%esp
  801266:	56                   	push   %esi
  801267:	e8 84 ff ff ff       	call   8011f0 <close>

	newfd = INDEX2FD(newfdnum);
  80126c:	89 f3                	mov    %esi,%ebx
  80126e:	c1 e3 0c             	shl    $0xc,%ebx
  801271:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801277:	83 c4 04             	add    $0x4,%esp
  80127a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80127d:	e8 de fd ff ff       	call   801060 <fd2data>
  801282:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801284:	89 1c 24             	mov    %ebx,(%esp)
  801287:	e8 d4 fd ff ff       	call   801060 <fd2data>
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801292:	89 f8                	mov    %edi,%eax
  801294:	c1 e8 16             	shr    $0x16,%eax
  801297:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80129e:	a8 01                	test   $0x1,%al
  8012a0:	74 37                	je     8012d9 <dup+0x99>
  8012a2:	89 f8                	mov    %edi,%eax
  8012a4:	c1 e8 0c             	shr    $0xc,%eax
  8012a7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ae:	f6 c2 01             	test   $0x1,%dl
  8012b1:	74 26                	je     8012d9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ba:	83 ec 0c             	sub    $0xc,%esp
  8012bd:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c2:	50                   	push   %eax
  8012c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012c6:	6a 00                	push   $0x0
  8012c8:	57                   	push   %edi
  8012c9:	6a 00                	push   $0x0
  8012cb:	e8 b3 fb ff ff       	call   800e83 <sys_page_map>
  8012d0:	89 c7                	mov    %eax,%edi
  8012d2:	83 c4 20             	add    $0x20,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 2e                	js     801307 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012dc:	89 d0                	mov    %edx,%eax
  8012de:	c1 e8 0c             	shr    $0xc,%eax
  8012e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e8:	83 ec 0c             	sub    $0xc,%esp
  8012eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f0:	50                   	push   %eax
  8012f1:	53                   	push   %ebx
  8012f2:	6a 00                	push   $0x0
  8012f4:	52                   	push   %edx
  8012f5:	6a 00                	push   $0x0
  8012f7:	e8 87 fb ff ff       	call   800e83 <sys_page_map>
  8012fc:	89 c7                	mov    %eax,%edi
  8012fe:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801301:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801303:	85 ff                	test   %edi,%edi
  801305:	79 1d                	jns    801324 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	53                   	push   %ebx
  80130b:	6a 00                	push   $0x0
  80130d:	e8 b3 fb ff ff       	call   800ec5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	ff 75 d4             	pushl  -0x2c(%ebp)
  801318:	6a 00                	push   $0x0
  80131a:	e8 a6 fb ff ff       	call   800ec5 <sys_page_unmap>
	return r;
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	89 f8                	mov    %edi,%eax
}
  801324:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801327:	5b                   	pop    %ebx
  801328:	5e                   	pop    %esi
  801329:	5f                   	pop    %edi
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	53                   	push   %ebx
  801330:	83 ec 14             	sub    $0x14,%esp
  801333:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801336:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	53                   	push   %ebx
  80133b:	e8 86 fd ff ff       	call   8010c6 <fd_lookup>
  801340:	83 c4 08             	add    $0x8,%esp
  801343:	89 c2                	mov    %eax,%edx
  801345:	85 c0                	test   %eax,%eax
  801347:	78 6d                	js     8013b6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801353:	ff 30                	pushl  (%eax)
  801355:	e8 c2 fd ff ff       	call   80111c <dev_lookup>
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 4c                	js     8013ad <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801361:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801364:	8b 42 08             	mov    0x8(%edx),%eax
  801367:	83 e0 03             	and    $0x3,%eax
  80136a:	83 f8 01             	cmp    $0x1,%eax
  80136d:	75 21                	jne    801390 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80136f:	a1 08 44 80 00       	mov    0x804408,%eax
  801374:	8b 40 48             	mov    0x48(%eax),%eax
  801377:	83 ec 04             	sub    $0x4,%esp
  80137a:	53                   	push   %ebx
  80137b:	50                   	push   %eax
  80137c:	68 40 29 80 00       	push   $0x802940
  801381:	e8 1f f0 ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80138e:	eb 26                	jmp    8013b6 <read+0x8a>
	}
	if (!dev->dev_read)
  801390:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801393:	8b 40 08             	mov    0x8(%eax),%eax
  801396:	85 c0                	test   %eax,%eax
  801398:	74 17                	je     8013b1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80139a:	83 ec 04             	sub    $0x4,%esp
  80139d:	ff 75 10             	pushl  0x10(%ebp)
  8013a0:	ff 75 0c             	pushl  0xc(%ebp)
  8013a3:	52                   	push   %edx
  8013a4:	ff d0                	call   *%eax
  8013a6:	89 c2                	mov    %eax,%edx
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	eb 09                	jmp    8013b6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ad:	89 c2                	mov    %eax,%edx
  8013af:	eb 05                	jmp    8013b6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013b6:	89 d0                	mov    %edx,%eax
  8013b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	57                   	push   %edi
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d1:	eb 21                	jmp    8013f4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d3:	83 ec 04             	sub    $0x4,%esp
  8013d6:	89 f0                	mov    %esi,%eax
  8013d8:	29 d8                	sub    %ebx,%eax
  8013da:	50                   	push   %eax
  8013db:	89 d8                	mov    %ebx,%eax
  8013dd:	03 45 0c             	add    0xc(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	57                   	push   %edi
  8013e2:	e8 45 ff ff ff       	call   80132c <read>
		if (m < 0)
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 10                	js     8013fe <readn+0x41>
			return m;
		if (m == 0)
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	74 0a                	je     8013fc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f2:	01 c3                	add    %eax,%ebx
  8013f4:	39 f3                	cmp    %esi,%ebx
  8013f6:	72 db                	jb     8013d3 <readn+0x16>
  8013f8:	89 d8                	mov    %ebx,%eax
  8013fa:	eb 02                	jmp    8013fe <readn+0x41>
  8013fc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801401:	5b                   	pop    %ebx
  801402:	5e                   	pop    %esi
  801403:	5f                   	pop    %edi
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	53                   	push   %ebx
  80140a:	83 ec 14             	sub    $0x14,%esp
  80140d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801410:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801413:	50                   	push   %eax
  801414:	53                   	push   %ebx
  801415:	e8 ac fc ff ff       	call   8010c6 <fd_lookup>
  80141a:	83 c4 08             	add    $0x8,%esp
  80141d:	89 c2                	mov    %eax,%edx
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 68                	js     80148b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801429:	50                   	push   %eax
  80142a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142d:	ff 30                	pushl  (%eax)
  80142f:	e8 e8 fc ff ff       	call   80111c <dev_lookup>
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	78 47                	js     801482 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801442:	75 21                	jne    801465 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801444:	a1 08 44 80 00       	mov    0x804408,%eax
  801449:	8b 40 48             	mov    0x48(%eax),%eax
  80144c:	83 ec 04             	sub    $0x4,%esp
  80144f:	53                   	push   %ebx
  801450:	50                   	push   %eax
  801451:	68 5c 29 80 00       	push   $0x80295c
  801456:	e8 4a ef ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801463:	eb 26                	jmp    80148b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801465:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801468:	8b 52 0c             	mov    0xc(%edx),%edx
  80146b:	85 d2                	test   %edx,%edx
  80146d:	74 17                	je     801486 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80146f:	83 ec 04             	sub    $0x4,%esp
  801472:	ff 75 10             	pushl  0x10(%ebp)
  801475:	ff 75 0c             	pushl  0xc(%ebp)
  801478:	50                   	push   %eax
  801479:	ff d2                	call   *%edx
  80147b:	89 c2                	mov    %eax,%edx
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	eb 09                	jmp    80148b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801482:	89 c2                	mov    %eax,%edx
  801484:	eb 05                	jmp    80148b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801486:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80148b:	89 d0                	mov    %edx,%eax
  80148d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801490:	c9                   	leave  
  801491:	c3                   	ret    

00801492 <seek>:

int
seek(int fdnum, off_t offset)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801498:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	ff 75 08             	pushl  0x8(%ebp)
  80149f:	e8 22 fc ff ff       	call   8010c6 <fd_lookup>
  8014a4:	83 c4 08             	add    $0x8,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 0e                	js     8014b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 14             	sub    $0x14,%esp
  8014c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c8:	50                   	push   %eax
  8014c9:	53                   	push   %ebx
  8014ca:	e8 f7 fb ff ff       	call   8010c6 <fd_lookup>
  8014cf:	83 c4 08             	add    $0x8,%esp
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 65                	js     80153d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014de:	50                   	push   %eax
  8014df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e2:	ff 30                	pushl  (%eax)
  8014e4:	e8 33 fc ff ff       	call   80111c <dev_lookup>
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 44                	js     801534 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f7:	75 21                	jne    80151a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014f9:	a1 08 44 80 00       	mov    0x804408,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014fe:	8b 40 48             	mov    0x48(%eax),%eax
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	53                   	push   %ebx
  801505:	50                   	push   %eax
  801506:	68 1c 29 80 00       	push   $0x80291c
  80150b:	e8 95 ee ff ff       	call   8003a5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801518:	eb 23                	jmp    80153d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80151a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151d:	8b 52 18             	mov    0x18(%edx),%edx
  801520:	85 d2                	test   %edx,%edx
  801522:	74 14                	je     801538 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	ff 75 0c             	pushl  0xc(%ebp)
  80152a:	50                   	push   %eax
  80152b:	ff d2                	call   *%edx
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	eb 09                	jmp    80153d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801534:	89 c2                	mov    %eax,%edx
  801536:	eb 05                	jmp    80153d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801538:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80153d:	89 d0                	mov    %edx,%eax
  80153f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801542:	c9                   	leave  
  801543:	c3                   	ret    

00801544 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	53                   	push   %ebx
  801548:	83 ec 14             	sub    $0x14,%esp
  80154b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	ff 75 08             	pushl  0x8(%ebp)
  801555:	e8 6c fb ff ff       	call   8010c6 <fd_lookup>
  80155a:	83 c4 08             	add    $0x8,%esp
  80155d:	89 c2                	mov    %eax,%edx
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 58                	js     8015bb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156d:	ff 30                	pushl  (%eax)
  80156f:	e8 a8 fb ff ff       	call   80111c <dev_lookup>
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 37                	js     8015b2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80157b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801582:	74 32                	je     8015b6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801584:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801587:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80158e:	00 00 00 
	stat->st_isdir = 0;
  801591:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801598:	00 00 00 
	stat->st_dev = dev;
  80159b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8015a8:	ff 50 14             	call   *0x14(%eax)
  8015ab:	89 c2                	mov    %eax,%edx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	eb 09                	jmp    8015bb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b2:	89 c2                	mov    %eax,%edx
  8015b4:	eb 05                	jmp    8015bb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015bb:	89 d0                	mov    %edx,%eax
  8015bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	56                   	push   %esi
  8015c6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	6a 00                	push   $0x0
  8015cc:	ff 75 08             	pushl  0x8(%ebp)
  8015cf:	e8 ef 01 00 00       	call   8017c3 <open>
  8015d4:	89 c3                	mov    %eax,%ebx
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 1b                	js     8015f8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	ff 75 0c             	pushl  0xc(%ebp)
  8015e3:	50                   	push   %eax
  8015e4:	e8 5b ff ff ff       	call   801544 <fstat>
  8015e9:	89 c6                	mov    %eax,%esi
	close(fd);
  8015eb:	89 1c 24             	mov    %ebx,(%esp)
  8015ee:	e8 fd fb ff ff       	call   8011f0 <close>
	return r;
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	89 f0                	mov    %esi,%eax
}
  8015f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fb:	5b                   	pop    %ebx
  8015fc:	5e                   	pop    %esi
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    

008015ff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	56                   	push   %esi
  801603:	53                   	push   %ebx
  801604:	89 c6                	mov    %eax,%esi
  801606:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801608:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80160f:	75 12                	jne    801623 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	6a 01                	push   $0x1
  801616:	e8 e4 0b 00 00       	call   8021ff <ipc_find_env>
  80161b:	a3 00 44 80 00       	mov    %eax,0x804400
  801620:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801623:	6a 07                	push   $0x7
  801625:	68 00 50 80 00       	push   $0x805000
  80162a:	56                   	push   %esi
  80162b:	ff 35 00 44 80 00    	pushl  0x804400
  801631:	e8 7a 0b 00 00       	call   8021b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801636:	83 c4 0c             	add    $0xc,%esp
  801639:	6a 00                	push   $0x0
  80163b:	53                   	push   %ebx
  80163c:	6a 00                	push   $0x0
  80163e:	e8 f7 0a 00 00       	call   80213a <ipc_recv>
}
  801643:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801646:	5b                   	pop    %ebx
  801647:	5e                   	pop    %esi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801650:	8b 45 08             	mov    0x8(%ebp),%eax
  801653:	8b 40 0c             	mov    0xc(%eax),%eax
  801656:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80165b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801663:	ba 00 00 00 00       	mov    $0x0,%edx
  801668:	b8 02 00 00 00       	mov    $0x2,%eax
  80166d:	e8 8d ff ff ff       	call   8015ff <fsipc>
}
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80167a:	8b 45 08             	mov    0x8(%ebp),%eax
  80167d:	8b 40 0c             	mov    0xc(%eax),%eax
  801680:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801685:	ba 00 00 00 00       	mov    $0x0,%edx
  80168a:	b8 06 00 00 00       	mov    $0x6,%eax
  80168f:	e8 6b ff ff ff       	call   8015ff <fsipc>
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	53                   	push   %ebx
  80169a:	83 ec 04             	sub    $0x4,%esp
  80169d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b5:	e8 45 ff ff ff       	call   8015ff <fsipc>
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 2c                	js     8016ea <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	68 00 50 80 00       	push   $0x805000
  8016c6:	53                   	push   %ebx
  8016c7:	e8 71 f3 ff ff       	call   800a3d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016cc:	a1 80 50 80 00       	mov    0x805080,%eax
  8016d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d7:	a1 84 50 80 00       	mov    0x805084,%eax
  8016dc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	53                   	push   %ebx
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8016fc:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ff:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801705:	a3 04 50 80 00       	mov    %eax,0x805004
  80170a:	3d 08 50 80 00       	cmp    $0x805008,%eax
  80170f:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801714:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801717:	53                   	push   %ebx
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	68 08 50 80 00       	push   $0x805008
  801720:	e8 aa f4 ff ff       	call   800bcf <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801725:	ba 00 00 00 00       	mov    $0x0,%edx
  80172a:	b8 04 00 00 00       	mov    $0x4,%eax
  80172f:	e8 cb fe ff ff       	call   8015ff <fsipc>
  801734:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801737:	85 c0                	test   %eax,%eax
  801739:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  80173c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	56                   	push   %esi
  801745:	53                   	push   %ebx
  801746:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801749:	8b 45 08             	mov    0x8(%ebp),%eax
  80174c:	8b 40 0c             	mov    0xc(%eax),%eax
  80174f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801754:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80175a:	ba 00 00 00 00       	mov    $0x0,%edx
  80175f:	b8 03 00 00 00       	mov    $0x3,%eax
  801764:	e8 96 fe ff ff       	call   8015ff <fsipc>
  801769:	89 c3                	mov    %eax,%ebx
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 4b                	js     8017ba <devfile_read+0x79>
		return r;
	assert(r <= n);
  80176f:	39 c6                	cmp    %eax,%esi
  801771:	73 16                	jae    801789 <devfile_read+0x48>
  801773:	68 90 29 80 00       	push   $0x802990
  801778:	68 97 29 80 00       	push   $0x802997
  80177d:	6a 7c                	push   $0x7c
  80177f:	68 ac 29 80 00       	push   $0x8029ac
  801784:	e8 43 eb ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  801789:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80178e:	7e 16                	jle    8017a6 <devfile_read+0x65>
  801790:	68 b7 29 80 00       	push   $0x8029b7
  801795:	68 97 29 80 00       	push   $0x802997
  80179a:	6a 7d                	push   $0x7d
  80179c:	68 ac 29 80 00       	push   $0x8029ac
  8017a1:	e8 26 eb ff ff       	call   8002cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017a6:	83 ec 04             	sub    $0x4,%esp
  8017a9:	50                   	push   %eax
  8017aa:	68 00 50 80 00       	push   $0x805000
  8017af:	ff 75 0c             	pushl  0xc(%ebp)
  8017b2:	e8 18 f4 ff ff       	call   800bcf <memmove>
	return r;
  8017b7:	83 c4 10             	add    $0x10,%esp
}
  8017ba:	89 d8                	mov    %ebx,%eax
  8017bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5e                   	pop    %esi
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 20             	sub    $0x20,%esp
  8017ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017cd:	53                   	push   %ebx
  8017ce:	e8 31 f2 ff ff       	call   800a04 <strlen>
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017db:	7f 67                	jg     801844 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017dd:	83 ec 0c             	sub    $0xc,%esp
  8017e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e3:	50                   	push   %eax
  8017e4:	e8 8e f8 ff ff       	call   801077 <fd_alloc>
  8017e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8017ec:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 57                	js     801849 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	53                   	push   %ebx
  8017f6:	68 00 50 80 00       	push   $0x805000
  8017fb:	e8 3d f2 ff ff       	call   800a3d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801800:	8b 45 0c             	mov    0xc(%ebp),%eax
  801803:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801808:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180b:	b8 01 00 00 00       	mov    $0x1,%eax
  801810:	e8 ea fd ff ff       	call   8015ff <fsipc>
  801815:	89 c3                	mov    %eax,%ebx
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	85 c0                	test   %eax,%eax
  80181c:	79 14                	jns    801832 <open+0x6f>
		fd_close(fd, 0);
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	6a 00                	push   $0x0
  801823:	ff 75 f4             	pushl  -0xc(%ebp)
  801826:	e8 44 f9 ff ff       	call   80116f <fd_close>
		return r;
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	89 da                	mov    %ebx,%edx
  801830:	eb 17                	jmp    801849 <open+0x86>
	}

	return fd2num(fd);
  801832:	83 ec 0c             	sub    $0xc,%esp
  801835:	ff 75 f4             	pushl  -0xc(%ebp)
  801838:	e8 13 f8 ff ff       	call   801050 <fd2num>
  80183d:	89 c2                	mov    %eax,%edx
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	eb 05                	jmp    801849 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801844:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801849:	89 d0                	mov    %edx,%eax
  80184b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801856:	ba 00 00 00 00       	mov    $0x0,%edx
  80185b:	b8 08 00 00 00       	mov    $0x8,%eax
  801860:	e8 9a fd ff ff       	call   8015ff <fsipc>
}
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801867:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80186b:	7e 37                	jle    8018a4 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	53                   	push   %ebx
  801871:	83 ec 08             	sub    $0x8,%esp
  801874:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801876:	ff 70 04             	pushl  0x4(%eax)
  801879:	8d 40 10             	lea    0x10(%eax),%eax
  80187c:	50                   	push   %eax
  80187d:	ff 33                	pushl  (%ebx)
  80187f:	e8 82 fb ff ff       	call   801406 <write>
		if (result > 0)
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	85 c0                	test   %eax,%eax
  801889:	7e 03                	jle    80188e <writebuf+0x27>
			b->result += result;
  80188b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80188e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801891:	74 0d                	je     8018a0 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801893:	85 c0                	test   %eax,%eax
  801895:	ba 00 00 00 00       	mov    $0x0,%edx
  80189a:	0f 4f c2             	cmovg  %edx,%eax
  80189d:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a3:	c9                   	leave  
  8018a4:	f3 c3                	repz ret 

008018a6 <putch>:

static void
putch(int ch, void *thunk)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	53                   	push   %ebx
  8018aa:	83 ec 04             	sub    $0x4,%esp
  8018ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018b0:	8b 53 04             	mov    0x4(%ebx),%edx
  8018b3:	8d 42 01             	lea    0x1(%edx),%eax
  8018b6:	89 43 04             	mov    %eax,0x4(%ebx)
  8018b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018bc:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018c0:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018c5:	75 0e                	jne    8018d5 <putch+0x2f>
		writebuf(b);
  8018c7:	89 d8                	mov    %ebx,%eax
  8018c9:	e8 99 ff ff ff       	call   801867 <writebuf>
		b->idx = 0;
  8018ce:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018d5:	83 c4 04             	add    $0x4,%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    

008018db <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8018e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e7:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018ed:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018f4:	00 00 00 
	b.result = 0;
  8018f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018fe:	00 00 00 
	b.error = 1;
  801901:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801908:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80190b:	ff 75 10             	pushl  0x10(%ebp)
  80190e:	ff 75 0c             	pushl  0xc(%ebp)
  801911:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801917:	50                   	push   %eax
  801918:	68 a6 18 80 00       	push   $0x8018a6
  80191d:	e8 ba eb ff ff       	call   8004dc <vprintfmt>
	if (b.idx > 0)
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80192c:	7e 0b                	jle    801939 <vfprintf+0x5e>
		writebuf(&b);
  80192e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801934:	e8 2e ff ff ff       	call   801867 <writebuf>

	return (b.result ? b.result : b.error);
  801939:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80193f:	85 c0                	test   %eax,%eax
  801941:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801950:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801953:	50                   	push   %eax
  801954:	ff 75 0c             	pushl  0xc(%ebp)
  801957:	ff 75 08             	pushl  0x8(%ebp)
  80195a:	e8 7c ff ff ff       	call   8018db <vfprintf>
	va_end(ap);

	return cnt;
}
  80195f:	c9                   	leave  
  801960:	c3                   	ret    

00801961 <printf>:

int
printf(const char *fmt, ...)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801967:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80196a:	50                   	push   %eax
  80196b:	ff 75 08             	pushl  0x8(%ebp)
  80196e:	6a 01                	push   $0x1
  801970:	e8 66 ff ff ff       	call   8018db <vfprintf>
	va_end(ap);

	return cnt;
}
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	56                   	push   %esi
  80197b:	53                   	push   %ebx
  80197c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	ff 75 08             	pushl  0x8(%ebp)
  801985:	e8 d6 f6 ff ff       	call   801060 <fd2data>
  80198a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80198c:	83 c4 08             	add    $0x8,%esp
  80198f:	68 c3 29 80 00       	push   $0x8029c3
  801994:	53                   	push   %ebx
  801995:	e8 a3 f0 ff ff       	call   800a3d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80199a:	8b 46 04             	mov    0x4(%esi),%eax
  80199d:	2b 06                	sub    (%esi),%eax
  80199f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019a5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019ac:	00 00 00 
	stat->st_dev = &devpipe;
  8019af:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019b6:	30 80 00 
	return 0;
}
  8019b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c1:	5b                   	pop    %ebx
  8019c2:	5e                   	pop    %esi
  8019c3:	5d                   	pop    %ebp
  8019c4:	c3                   	ret    

008019c5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	53                   	push   %ebx
  8019c9:	83 ec 0c             	sub    $0xc,%esp
  8019cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019cf:	53                   	push   %ebx
  8019d0:	6a 00                	push   $0x0
  8019d2:	e8 ee f4 ff ff       	call   800ec5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019d7:	89 1c 24             	mov    %ebx,(%esp)
  8019da:	e8 81 f6 ff ff       	call   801060 <fd2data>
  8019df:	83 c4 08             	add    $0x8,%esp
  8019e2:	50                   	push   %eax
  8019e3:	6a 00                	push   $0x0
  8019e5:	e8 db f4 ff ff       	call   800ec5 <sys_page_unmap>
}
  8019ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    

008019ef <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	57                   	push   %edi
  8019f3:	56                   	push   %esi
  8019f4:	53                   	push   %ebx
  8019f5:	83 ec 1c             	sub    $0x1c,%esp
  8019f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019fb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019fd:	a1 08 44 80 00       	mov    0x804408,%eax
  801a02:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a05:	83 ec 0c             	sub    $0xc,%esp
  801a08:	ff 75 e0             	pushl  -0x20(%ebp)
  801a0b:	e8 28 08 00 00       	call   802238 <pageref>
  801a10:	89 c3                	mov    %eax,%ebx
  801a12:	89 3c 24             	mov    %edi,(%esp)
  801a15:	e8 1e 08 00 00       	call   802238 <pageref>
  801a1a:	83 c4 10             	add    $0x10,%esp
  801a1d:	39 c3                	cmp    %eax,%ebx
  801a1f:	0f 94 c1             	sete   %cl
  801a22:	0f b6 c9             	movzbl %cl,%ecx
  801a25:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a28:	8b 15 08 44 80 00    	mov    0x804408,%edx
  801a2e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a31:	39 ce                	cmp    %ecx,%esi
  801a33:	74 1b                	je     801a50 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a35:	39 c3                	cmp    %eax,%ebx
  801a37:	75 c4                	jne    8019fd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a39:	8b 42 58             	mov    0x58(%edx),%eax
  801a3c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a3f:	50                   	push   %eax
  801a40:	56                   	push   %esi
  801a41:	68 ca 29 80 00       	push   $0x8029ca
  801a46:	e8 5a e9 ff ff       	call   8003a5 <cprintf>
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	eb ad                	jmp    8019fd <_pipeisclosed+0xe>
	}
}
  801a50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5f                   	pop    %edi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	57                   	push   %edi
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	83 ec 28             	sub    $0x28,%esp
  801a64:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a67:	56                   	push   %esi
  801a68:	e8 f3 f5 ff ff       	call   801060 <fd2data>
  801a6d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	bf 00 00 00 00       	mov    $0x0,%edi
  801a77:	eb 4b                	jmp    801ac4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a79:	89 da                	mov    %ebx,%edx
  801a7b:	89 f0                	mov    %esi,%eax
  801a7d:	e8 6d ff ff ff       	call   8019ef <_pipeisclosed>
  801a82:	85 c0                	test   %eax,%eax
  801a84:	75 48                	jne    801ace <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a86:	e8 96 f3 ff ff       	call   800e21 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a8b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a8e:	8b 0b                	mov    (%ebx),%ecx
  801a90:	8d 51 20             	lea    0x20(%ecx),%edx
  801a93:	39 d0                	cmp    %edx,%eax
  801a95:	73 e2                	jae    801a79 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a9e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aa1:	89 c2                	mov    %eax,%edx
  801aa3:	c1 fa 1f             	sar    $0x1f,%edx
  801aa6:	89 d1                	mov    %edx,%ecx
  801aa8:	c1 e9 1b             	shr    $0x1b,%ecx
  801aab:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aae:	83 e2 1f             	and    $0x1f,%edx
  801ab1:	29 ca                	sub    %ecx,%edx
  801ab3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ab7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801abb:	83 c0 01             	add    $0x1,%eax
  801abe:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac1:	83 c7 01             	add    $0x1,%edi
  801ac4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ac7:	75 c2                	jne    801a8b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ac9:	8b 45 10             	mov    0x10(%ebp),%eax
  801acc:	eb 05                	jmp    801ad3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ace:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ad3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad6:	5b                   	pop    %ebx
  801ad7:	5e                   	pop    %esi
  801ad8:	5f                   	pop    %edi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	57                   	push   %edi
  801adf:	56                   	push   %esi
  801ae0:	53                   	push   %ebx
  801ae1:	83 ec 18             	sub    $0x18,%esp
  801ae4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ae7:	57                   	push   %edi
  801ae8:	e8 73 f5 ff ff       	call   801060 <fd2data>
  801aed:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801af7:	eb 3d                	jmp    801b36 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801af9:	85 db                	test   %ebx,%ebx
  801afb:	74 04                	je     801b01 <devpipe_read+0x26>
				return i;
  801afd:	89 d8                	mov    %ebx,%eax
  801aff:	eb 44                	jmp    801b45 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b01:	89 f2                	mov    %esi,%edx
  801b03:	89 f8                	mov    %edi,%eax
  801b05:	e8 e5 fe ff ff       	call   8019ef <_pipeisclosed>
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	75 32                	jne    801b40 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b0e:	e8 0e f3 ff ff       	call   800e21 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b13:	8b 06                	mov    (%esi),%eax
  801b15:	3b 46 04             	cmp    0x4(%esi),%eax
  801b18:	74 df                	je     801af9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b1a:	99                   	cltd   
  801b1b:	c1 ea 1b             	shr    $0x1b,%edx
  801b1e:	01 d0                	add    %edx,%eax
  801b20:	83 e0 1f             	and    $0x1f,%eax
  801b23:	29 d0                	sub    %edx,%eax
  801b25:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b2d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b30:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b33:	83 c3 01             	add    $0x1,%ebx
  801b36:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b39:	75 d8                	jne    801b13 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3e:	eb 05                	jmp    801b45 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5f                   	pop    %edi
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b58:	50                   	push   %eax
  801b59:	e8 19 f5 ff ff       	call   801077 <fd_alloc>
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	89 c2                	mov    %eax,%edx
  801b63:	85 c0                	test   %eax,%eax
  801b65:	0f 88 2c 01 00 00    	js     801c97 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6b:	83 ec 04             	sub    $0x4,%esp
  801b6e:	68 07 04 00 00       	push   $0x407
  801b73:	ff 75 f4             	pushl  -0xc(%ebp)
  801b76:	6a 00                	push   $0x0
  801b78:	e8 c3 f2 ff ff       	call   800e40 <sys_page_alloc>
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	89 c2                	mov    %eax,%edx
  801b82:	85 c0                	test   %eax,%eax
  801b84:	0f 88 0d 01 00 00    	js     801c97 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b8a:	83 ec 0c             	sub    $0xc,%esp
  801b8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b90:	50                   	push   %eax
  801b91:	e8 e1 f4 ff ff       	call   801077 <fd_alloc>
  801b96:	89 c3                	mov    %eax,%ebx
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	0f 88 e2 00 00 00    	js     801c85 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba3:	83 ec 04             	sub    $0x4,%esp
  801ba6:	68 07 04 00 00       	push   $0x407
  801bab:	ff 75 f0             	pushl  -0x10(%ebp)
  801bae:	6a 00                	push   $0x0
  801bb0:	e8 8b f2 ff ff       	call   800e40 <sys_page_alloc>
  801bb5:	89 c3                	mov    %eax,%ebx
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	0f 88 c3 00 00 00    	js     801c85 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bc2:	83 ec 0c             	sub    $0xc,%esp
  801bc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc8:	e8 93 f4 ff ff       	call   801060 <fd2data>
  801bcd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcf:	83 c4 0c             	add    $0xc,%esp
  801bd2:	68 07 04 00 00       	push   $0x407
  801bd7:	50                   	push   %eax
  801bd8:	6a 00                	push   $0x0
  801bda:	e8 61 f2 ff ff       	call   800e40 <sys_page_alloc>
  801bdf:	89 c3                	mov    %eax,%ebx
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	85 c0                	test   %eax,%eax
  801be6:	0f 88 89 00 00 00    	js     801c75 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bec:	83 ec 0c             	sub    $0xc,%esp
  801bef:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf2:	e8 69 f4 ff ff       	call   801060 <fd2data>
  801bf7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bfe:	50                   	push   %eax
  801bff:	6a 00                	push   $0x0
  801c01:	56                   	push   %esi
  801c02:	6a 00                	push   $0x0
  801c04:	e8 7a f2 ff ff       	call   800e83 <sys_page_map>
  801c09:	89 c3                	mov    %eax,%ebx
  801c0b:	83 c4 20             	add    $0x20,%esp
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 55                	js     801c67 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c12:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c20:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c27:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c30:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c35:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c3c:	83 ec 0c             	sub    $0xc,%esp
  801c3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c42:	e8 09 f4 ff ff       	call   801050 <fd2num>
  801c47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c4c:	83 c4 04             	add    $0x4,%esp
  801c4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c52:	e8 f9 f3 ff ff       	call   801050 <fd2num>
  801c57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	ba 00 00 00 00       	mov    $0x0,%edx
  801c65:	eb 30                	jmp    801c97 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c67:	83 ec 08             	sub    $0x8,%esp
  801c6a:	56                   	push   %esi
  801c6b:	6a 00                	push   $0x0
  801c6d:	e8 53 f2 ff ff       	call   800ec5 <sys_page_unmap>
  801c72:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c75:	83 ec 08             	sub    $0x8,%esp
  801c78:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7b:	6a 00                	push   $0x0
  801c7d:	e8 43 f2 ff ff       	call   800ec5 <sys_page_unmap>
  801c82:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c85:	83 ec 08             	sub    $0x8,%esp
  801c88:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8b:	6a 00                	push   $0x0
  801c8d:	e8 33 f2 ff ff       	call   800ec5 <sys_page_unmap>
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c97:	89 d0                	mov    %edx,%eax
  801c99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca9:	50                   	push   %eax
  801caa:	ff 75 08             	pushl  0x8(%ebp)
  801cad:	e8 14 f4 ff ff       	call   8010c6 <fd_lookup>
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	78 18                	js     801cd1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cb9:	83 ec 0c             	sub    $0xc,%esp
  801cbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbf:	e8 9c f3 ff ff       	call   801060 <fd2data>
	return _pipeisclosed(fd, p);
  801cc4:	89 c2                	mov    %eax,%edx
  801cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc9:	e8 21 fd ff ff       	call   8019ef <_pipeisclosed>
  801cce:	83 c4 10             	add    $0x10,%esp
}
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801cd9:	68 e2 29 80 00       	push   $0x8029e2
  801cde:	ff 75 0c             	pushl  0xc(%ebp)
  801ce1:	e8 57 ed ff ff       	call   800a3d <strcpy>
	return 0;
}
  801ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	53                   	push   %ebx
  801cf1:	83 ec 10             	sub    $0x10,%esp
  801cf4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cf7:	53                   	push   %ebx
  801cf8:	e8 3b 05 00 00       	call   802238 <pageref>
  801cfd:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d00:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d05:	83 f8 01             	cmp    $0x1,%eax
  801d08:	75 10                	jne    801d1a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801d0a:	83 ec 0c             	sub    $0xc,%esp
  801d0d:	ff 73 0c             	pushl  0xc(%ebx)
  801d10:	e8 c0 02 00 00       	call   801fd5 <nsipc_close>
  801d15:	89 c2                	mov    %eax,%edx
  801d17:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1f:	c9                   	leave  
  801d20:	c3                   	ret    

00801d21 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d27:	6a 00                	push   $0x0
  801d29:	ff 75 10             	pushl  0x10(%ebp)
  801d2c:	ff 75 0c             	pushl  0xc(%ebp)
  801d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d32:	ff 70 0c             	pushl  0xc(%eax)
  801d35:	e8 78 03 00 00       	call   8020b2 <nsipc_send>
}
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d42:	6a 00                	push   $0x0
  801d44:	ff 75 10             	pushl  0x10(%ebp)
  801d47:	ff 75 0c             	pushl  0xc(%ebp)
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	ff 70 0c             	pushl  0xc(%eax)
  801d50:	e8 f1 02 00 00       	call   802046 <nsipc_recv>
}
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    

00801d57 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d5d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d60:	52                   	push   %edx
  801d61:	50                   	push   %eax
  801d62:	e8 5f f3 ff ff       	call   8010c6 <fd_lookup>
  801d67:	83 c4 10             	add    $0x10,%esp
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	78 17                	js     801d85 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d71:	8b 0d 58 30 80 00    	mov    0x803058,%ecx
  801d77:	39 08                	cmp    %ecx,(%eax)
  801d79:	75 05                	jne    801d80 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d7b:	8b 40 0c             	mov    0xc(%eax),%eax
  801d7e:	eb 05                	jmp    801d85 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d80:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d85:	c9                   	leave  
  801d86:	c3                   	ret    

00801d87 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	56                   	push   %esi
  801d8b:	53                   	push   %ebx
  801d8c:	83 ec 1c             	sub    $0x1c,%esp
  801d8f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d94:	50                   	push   %eax
  801d95:	e8 dd f2 ff ff       	call   801077 <fd_alloc>
  801d9a:	89 c3                	mov    %eax,%ebx
  801d9c:	83 c4 10             	add    $0x10,%esp
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	78 1b                	js     801dbe <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801da3:	83 ec 04             	sub    $0x4,%esp
  801da6:	68 07 04 00 00       	push   $0x407
  801dab:	ff 75 f4             	pushl  -0xc(%ebp)
  801dae:	6a 00                	push   $0x0
  801db0:	e8 8b f0 ff ff       	call   800e40 <sys_page_alloc>
  801db5:	89 c3                	mov    %eax,%ebx
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	79 10                	jns    801dce <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801dbe:	83 ec 0c             	sub    $0xc,%esp
  801dc1:	56                   	push   %esi
  801dc2:	e8 0e 02 00 00       	call   801fd5 <nsipc_close>
		return r;
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	89 d8                	mov    %ebx,%eax
  801dcc:	eb 24                	jmp    801df2 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801dce:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd7:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801de3:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801de6:	83 ec 0c             	sub    $0xc,%esp
  801de9:	50                   	push   %eax
  801dea:	e8 61 f2 ff ff       	call   801050 <fd2num>
  801def:	83 c4 10             	add    $0x10,%esp
}
  801df2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df5:	5b                   	pop    %ebx
  801df6:	5e                   	pop    %esi
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    

00801df9 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dff:	8b 45 08             	mov    0x8(%ebp),%eax
  801e02:	e8 50 ff ff ff       	call   801d57 <fd2sockid>
		return r;
  801e07:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	78 1f                	js     801e2c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e0d:	83 ec 04             	sub    $0x4,%esp
  801e10:	ff 75 10             	pushl  0x10(%ebp)
  801e13:	ff 75 0c             	pushl  0xc(%ebp)
  801e16:	50                   	push   %eax
  801e17:	e8 12 01 00 00       	call   801f2e <nsipc_accept>
  801e1c:	83 c4 10             	add    $0x10,%esp
		return r;
  801e1f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e21:	85 c0                	test   %eax,%eax
  801e23:	78 07                	js     801e2c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801e25:	e8 5d ff ff ff       	call   801d87 <alloc_sockfd>
  801e2a:	89 c1                	mov    %eax,%ecx
}
  801e2c:	89 c8                	mov    %ecx,%eax
  801e2e:	c9                   	leave  
  801e2f:	c3                   	ret    

00801e30 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e36:	8b 45 08             	mov    0x8(%ebp),%eax
  801e39:	e8 19 ff ff ff       	call   801d57 <fd2sockid>
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 12                	js     801e54 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e42:	83 ec 04             	sub    $0x4,%esp
  801e45:	ff 75 10             	pushl  0x10(%ebp)
  801e48:	ff 75 0c             	pushl  0xc(%ebp)
  801e4b:	50                   	push   %eax
  801e4c:	e8 2d 01 00 00       	call   801f7e <nsipc_bind>
  801e51:	83 c4 10             	add    $0x10,%esp
}
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <shutdown>:

int
shutdown(int s, int how)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5f:	e8 f3 fe ff ff       	call   801d57 <fd2sockid>
  801e64:	85 c0                	test   %eax,%eax
  801e66:	78 0f                	js     801e77 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e68:	83 ec 08             	sub    $0x8,%esp
  801e6b:	ff 75 0c             	pushl  0xc(%ebp)
  801e6e:	50                   	push   %eax
  801e6f:	e8 3f 01 00 00       	call   801fb3 <nsipc_shutdown>
  801e74:	83 c4 10             	add    $0x10,%esp
}
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e82:	e8 d0 fe ff ff       	call   801d57 <fd2sockid>
  801e87:	85 c0                	test   %eax,%eax
  801e89:	78 12                	js     801e9d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e8b:	83 ec 04             	sub    $0x4,%esp
  801e8e:	ff 75 10             	pushl  0x10(%ebp)
  801e91:	ff 75 0c             	pushl  0xc(%ebp)
  801e94:	50                   	push   %eax
  801e95:	e8 55 01 00 00       	call   801fef <nsipc_connect>
  801e9a:	83 c4 10             	add    $0x10,%esp
}
  801e9d:	c9                   	leave  
  801e9e:	c3                   	ret    

00801e9f <listen>:

int
listen(int s, int backlog)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea8:	e8 aa fe ff ff       	call   801d57 <fd2sockid>
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	78 0f                	js     801ec0 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801eb1:	83 ec 08             	sub    $0x8,%esp
  801eb4:	ff 75 0c             	pushl  0xc(%ebp)
  801eb7:	50                   	push   %eax
  801eb8:	e8 67 01 00 00       	call   802024 <nsipc_listen>
  801ebd:	83 c4 10             	add    $0x10,%esp
}
  801ec0:	c9                   	leave  
  801ec1:	c3                   	ret    

00801ec2 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ec8:	ff 75 10             	pushl  0x10(%ebp)
  801ecb:	ff 75 0c             	pushl  0xc(%ebp)
  801ece:	ff 75 08             	pushl  0x8(%ebp)
  801ed1:	e8 3a 02 00 00       	call   802110 <nsipc_socket>
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 05                	js     801ee2 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801edd:	e8 a5 fe ff ff       	call   801d87 <alloc_sockfd>
}
  801ee2:	c9                   	leave  
  801ee3:	c3                   	ret    

00801ee4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	53                   	push   %ebx
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801eed:	83 3d 04 44 80 00 00 	cmpl   $0x0,0x804404
  801ef4:	75 12                	jne    801f08 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ef6:	83 ec 0c             	sub    $0xc,%esp
  801ef9:	6a 02                	push   $0x2
  801efb:	e8 ff 02 00 00       	call   8021ff <ipc_find_env>
  801f00:	a3 04 44 80 00       	mov    %eax,0x804404
  801f05:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f08:	6a 07                	push   $0x7
  801f0a:	68 00 60 80 00       	push   $0x806000
  801f0f:	53                   	push   %ebx
  801f10:	ff 35 04 44 80 00    	pushl  0x804404
  801f16:	e8 95 02 00 00       	call   8021b0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f1b:	83 c4 0c             	add    $0xc,%esp
  801f1e:	6a 00                	push   $0x0
  801f20:	6a 00                	push   $0x0
  801f22:	6a 00                	push   $0x0
  801f24:	e8 11 02 00 00       	call   80213a <ipc_recv>
}
  801f29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	56                   	push   %esi
  801f32:	53                   	push   %ebx
  801f33:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f36:	8b 45 08             	mov    0x8(%ebp),%eax
  801f39:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f3e:	8b 06                	mov    (%esi),%eax
  801f40:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f45:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4a:	e8 95 ff ff ff       	call   801ee4 <nsipc>
  801f4f:	89 c3                	mov    %eax,%ebx
  801f51:	85 c0                	test   %eax,%eax
  801f53:	78 20                	js     801f75 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f55:	83 ec 04             	sub    $0x4,%esp
  801f58:	ff 35 10 60 80 00    	pushl  0x806010
  801f5e:	68 00 60 80 00       	push   $0x806000
  801f63:	ff 75 0c             	pushl  0xc(%ebp)
  801f66:	e8 64 ec ff ff       	call   800bcf <memmove>
		*addrlen = ret->ret_addrlen;
  801f6b:	a1 10 60 80 00       	mov    0x806010,%eax
  801f70:	89 06                	mov    %eax,(%esi)
  801f72:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f75:	89 d8                	mov    %ebx,%eax
  801f77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	53                   	push   %ebx
  801f82:	83 ec 08             	sub    $0x8,%esp
  801f85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f88:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f90:	53                   	push   %ebx
  801f91:	ff 75 0c             	pushl  0xc(%ebp)
  801f94:	68 04 60 80 00       	push   $0x806004
  801f99:	e8 31 ec ff ff       	call   800bcf <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f9e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801fa4:	b8 02 00 00 00       	mov    $0x2,%eax
  801fa9:	e8 36 ff ff ff       	call   801ee4 <nsipc>
}
  801fae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb1:	c9                   	leave  
  801fb2:	c3                   	ret    

00801fb3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801fc9:	b8 03 00 00 00       	mov    $0x3,%eax
  801fce:	e8 11 ff ff ff       	call   801ee4 <nsipc>
}
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <nsipc_close>:

int
nsipc_close(int s)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fde:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801fe3:	b8 04 00 00 00       	mov    $0x4,%eax
  801fe8:	e8 f7 fe ff ff       	call   801ee4 <nsipc>
}
  801fed:	c9                   	leave  
  801fee:	c3                   	ret    

00801fef <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	53                   	push   %ebx
  801ff3:	83 ec 08             	sub    $0x8,%esp
  801ff6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802001:	53                   	push   %ebx
  802002:	ff 75 0c             	pushl  0xc(%ebp)
  802005:	68 04 60 80 00       	push   $0x806004
  80200a:	e8 c0 eb ff ff       	call   800bcf <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80200f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802015:	b8 05 00 00 00       	mov    $0x5,%eax
  80201a:	e8 c5 fe ff ff       	call   801ee4 <nsipc>
}
  80201f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802022:	c9                   	leave  
  802023:	c3                   	ret    

00802024 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80202a:	8b 45 08             	mov    0x8(%ebp),%eax
  80202d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802032:	8b 45 0c             	mov    0xc(%ebp),%eax
  802035:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80203a:	b8 06 00 00 00       	mov    $0x6,%eax
  80203f:	e8 a0 fe ff ff       	call   801ee4 <nsipc>
}
  802044:	c9                   	leave  
  802045:	c3                   	ret    

00802046 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	56                   	push   %esi
  80204a:	53                   	push   %ebx
  80204b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80204e:	8b 45 08             	mov    0x8(%ebp),%eax
  802051:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802056:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80205c:	8b 45 14             	mov    0x14(%ebp),%eax
  80205f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802064:	b8 07 00 00 00       	mov    $0x7,%eax
  802069:	e8 76 fe ff ff       	call   801ee4 <nsipc>
  80206e:	89 c3                	mov    %eax,%ebx
  802070:	85 c0                	test   %eax,%eax
  802072:	78 35                	js     8020a9 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802074:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802079:	7f 04                	jg     80207f <nsipc_recv+0x39>
  80207b:	39 c6                	cmp    %eax,%esi
  80207d:	7d 16                	jge    802095 <nsipc_recv+0x4f>
  80207f:	68 ee 29 80 00       	push   $0x8029ee
  802084:	68 97 29 80 00       	push   $0x802997
  802089:	6a 62                	push   $0x62
  80208b:	68 03 2a 80 00       	push   $0x802a03
  802090:	e8 37 e2 ff ff       	call   8002cc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802095:	83 ec 04             	sub    $0x4,%esp
  802098:	50                   	push   %eax
  802099:	68 00 60 80 00       	push   $0x806000
  80209e:	ff 75 0c             	pushl  0xc(%ebp)
  8020a1:	e8 29 eb ff ff       	call   800bcf <memmove>
  8020a6:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8020a9:	89 d8                	mov    %ebx,%eax
  8020ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ae:	5b                   	pop    %ebx
  8020af:	5e                   	pop    %esi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    

008020b2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	53                   	push   %ebx
  8020b6:	83 ec 04             	sub    $0x4,%esp
  8020b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bf:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8020c4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020ca:	7e 16                	jle    8020e2 <nsipc_send+0x30>
  8020cc:	68 0f 2a 80 00       	push   $0x802a0f
  8020d1:	68 97 29 80 00       	push   $0x802997
  8020d6:	6a 6d                	push   $0x6d
  8020d8:	68 03 2a 80 00       	push   $0x802a03
  8020dd:	e8 ea e1 ff ff       	call   8002cc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020e2:	83 ec 04             	sub    $0x4,%esp
  8020e5:	53                   	push   %ebx
  8020e6:	ff 75 0c             	pushl  0xc(%ebp)
  8020e9:	68 0c 60 80 00       	push   $0x80600c
  8020ee:	e8 dc ea ff ff       	call   800bcf <memmove>
	nsipcbuf.send.req_size = size;
  8020f3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8020fc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802101:	b8 08 00 00 00       	mov    $0x8,%eax
  802106:	e8 d9 fd ff ff       	call   801ee4 <nsipc>
}
  80210b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80210e:	c9                   	leave  
  80210f:	c3                   	ret    

00802110 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802116:	8b 45 08             	mov    0x8(%ebp),%eax
  802119:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80211e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802121:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802126:	8b 45 10             	mov    0x10(%ebp),%eax
  802129:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80212e:	b8 09 00 00 00       	mov    $0x9,%eax
  802133:	e8 ac fd ff ff       	call   801ee4 <nsipc>
}
  802138:	c9                   	leave  
  802139:	c3                   	ret    

0080213a <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	56                   	push   %esi
  80213e:	53                   	push   %ebx
  80213f:	8b 75 08             	mov    0x8(%ebp),%esi
  802142:	8b 45 0c             	mov    0xc(%ebp),%eax
  802145:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  802148:	85 c0                	test   %eax,%eax
  80214a:	74 0e                	je     80215a <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  80214c:	83 ec 0c             	sub    $0xc,%esp
  80214f:	50                   	push   %eax
  802150:	e8 9b ee ff ff       	call   800ff0 <sys_ipc_recv>
  802155:	83 c4 10             	add    $0x10,%esp
  802158:	eb 10                	jmp    80216a <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  80215a:	83 ec 0c             	sub    $0xc,%esp
  80215d:	68 00 00 c0 ee       	push   $0xeec00000
  802162:	e8 89 ee ff ff       	call   800ff0 <sys_ipc_recv>
  802167:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  80216a:	85 c0                	test   %eax,%eax
  80216c:	79 17                	jns    802185 <ipc_recv+0x4b>
		if(*from_env_store)
  80216e:	83 3e 00             	cmpl   $0x0,(%esi)
  802171:	74 06                	je     802179 <ipc_recv+0x3f>
			*from_env_store = 0;
  802173:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  802179:	85 db                	test   %ebx,%ebx
  80217b:	74 2c                	je     8021a9 <ipc_recv+0x6f>
			*perm_store = 0;
  80217d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802183:	eb 24                	jmp    8021a9 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  802185:	85 f6                	test   %esi,%esi
  802187:	74 0a                	je     802193 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  802189:	a1 08 44 80 00       	mov    0x804408,%eax
  80218e:	8b 40 74             	mov    0x74(%eax),%eax
  802191:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802193:	85 db                	test   %ebx,%ebx
  802195:	74 0a                	je     8021a1 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  802197:	a1 08 44 80 00       	mov    0x804408,%eax
  80219c:	8b 40 78             	mov    0x78(%eax),%eax
  80219f:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8021a1:	a1 08 44 80 00       	mov    0x804408,%eax
  8021a6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ac:	5b                   	pop    %ebx
  8021ad:	5e                   	pop    %esi
  8021ae:	5d                   	pop    %ebp
  8021af:	c3                   	ret    

008021b0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	57                   	push   %edi
  8021b4:	56                   	push   %esi
  8021b5:	53                   	push   %ebx
  8021b6:	83 ec 0c             	sub    $0xc,%esp
  8021b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8021c2:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  8021c4:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  8021c9:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  8021cc:	e8 50 ec ff ff       	call   800e21 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  8021d1:	ff 75 14             	pushl  0x14(%ebp)
  8021d4:	53                   	push   %ebx
  8021d5:	56                   	push   %esi
  8021d6:	57                   	push   %edi
  8021d7:	e8 f1 ed ff ff       	call   800fcd <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  8021dc:	89 c2                	mov    %eax,%edx
  8021de:	f7 d2                	not    %edx
  8021e0:	c1 ea 1f             	shr    $0x1f,%edx
  8021e3:	83 c4 10             	add    $0x10,%esp
  8021e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021e9:	0f 94 c1             	sete   %cl
  8021ec:	09 ca                	or     %ecx,%edx
  8021ee:	85 c0                	test   %eax,%eax
  8021f0:	0f 94 c0             	sete   %al
  8021f3:	38 c2                	cmp    %al,%dl
  8021f5:	77 d5                	ja     8021cc <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8021f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021fa:	5b                   	pop    %ebx
  8021fb:	5e                   	pop    %esi
  8021fc:	5f                   	pop    %edi
  8021fd:	5d                   	pop    %ebp
  8021fe:	c3                   	ret    

008021ff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021ff:	55                   	push   %ebp
  802200:	89 e5                	mov    %esp,%ebp
  802202:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802205:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80220a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80220d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802213:	8b 52 50             	mov    0x50(%edx),%edx
  802216:	39 ca                	cmp    %ecx,%edx
  802218:	75 0d                	jne    802227 <ipc_find_env+0x28>
			return envs[i].env_id;
  80221a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80221d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802222:	8b 40 48             	mov    0x48(%eax),%eax
  802225:	eb 0f                	jmp    802236 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802227:	83 c0 01             	add    $0x1,%eax
  80222a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80222f:	75 d9                	jne    80220a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802231:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    

00802238 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802238:	55                   	push   %ebp
  802239:	89 e5                	mov    %esp,%ebp
  80223b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80223e:	89 d0                	mov    %edx,%eax
  802240:	c1 e8 16             	shr    $0x16,%eax
  802243:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80224a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80224f:	f6 c1 01             	test   $0x1,%cl
  802252:	74 1d                	je     802271 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802254:	c1 ea 0c             	shr    $0xc,%edx
  802257:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80225e:	f6 c2 01             	test   $0x1,%dl
  802261:	74 0e                	je     802271 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802263:	c1 ea 0c             	shr    $0xc,%edx
  802266:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80226d:	ef 
  80226e:	0f b7 c0             	movzwl %ax,%eax
}
  802271:	5d                   	pop    %ebp
  802272:	c3                   	ret    
  802273:	66 90                	xchg   %ax,%ax
  802275:	66 90                	xchg   %ax,%ax
  802277:	66 90                	xchg   %ax,%ax
  802279:	66 90                	xchg   %ax,%ax
  80227b:	66 90                	xchg   %ax,%ax
  80227d:	66 90                	xchg   %ax,%ax
  80227f:	90                   	nop

00802280 <__udivdi3>:
  802280:	55                   	push   %ebp
  802281:	57                   	push   %edi
  802282:	56                   	push   %esi
  802283:	53                   	push   %ebx
  802284:	83 ec 1c             	sub    $0x1c,%esp
  802287:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80228b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80228f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802297:	85 f6                	test   %esi,%esi
  802299:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80229d:	89 ca                	mov    %ecx,%edx
  80229f:	89 f8                	mov    %edi,%eax
  8022a1:	75 3d                	jne    8022e0 <__udivdi3+0x60>
  8022a3:	39 cf                	cmp    %ecx,%edi
  8022a5:	0f 87 c5 00 00 00    	ja     802370 <__udivdi3+0xf0>
  8022ab:	85 ff                	test   %edi,%edi
  8022ad:	89 fd                	mov    %edi,%ebp
  8022af:	75 0b                	jne    8022bc <__udivdi3+0x3c>
  8022b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b6:	31 d2                	xor    %edx,%edx
  8022b8:	f7 f7                	div    %edi
  8022ba:	89 c5                	mov    %eax,%ebp
  8022bc:	89 c8                	mov    %ecx,%eax
  8022be:	31 d2                	xor    %edx,%edx
  8022c0:	f7 f5                	div    %ebp
  8022c2:	89 c1                	mov    %eax,%ecx
  8022c4:	89 d8                	mov    %ebx,%eax
  8022c6:	89 cf                	mov    %ecx,%edi
  8022c8:	f7 f5                	div    %ebp
  8022ca:	89 c3                	mov    %eax,%ebx
  8022cc:	89 d8                	mov    %ebx,%eax
  8022ce:	89 fa                	mov    %edi,%edx
  8022d0:	83 c4 1c             	add    $0x1c,%esp
  8022d3:	5b                   	pop    %ebx
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
  8022d8:	90                   	nop
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	39 ce                	cmp    %ecx,%esi
  8022e2:	77 74                	ja     802358 <__udivdi3+0xd8>
  8022e4:	0f bd fe             	bsr    %esi,%edi
  8022e7:	83 f7 1f             	xor    $0x1f,%edi
  8022ea:	0f 84 98 00 00 00    	je     802388 <__udivdi3+0x108>
  8022f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	89 c5                	mov    %eax,%ebp
  8022f9:	29 fb                	sub    %edi,%ebx
  8022fb:	d3 e6                	shl    %cl,%esi
  8022fd:	89 d9                	mov    %ebx,%ecx
  8022ff:	d3 ed                	shr    %cl,%ebp
  802301:	89 f9                	mov    %edi,%ecx
  802303:	d3 e0                	shl    %cl,%eax
  802305:	09 ee                	or     %ebp,%esi
  802307:	89 d9                	mov    %ebx,%ecx
  802309:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80230d:	89 d5                	mov    %edx,%ebp
  80230f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802313:	d3 ed                	shr    %cl,%ebp
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e2                	shl    %cl,%edx
  802319:	89 d9                	mov    %ebx,%ecx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	09 c2                	or     %eax,%edx
  80231f:	89 d0                	mov    %edx,%eax
  802321:	89 ea                	mov    %ebp,%edx
  802323:	f7 f6                	div    %esi
  802325:	89 d5                	mov    %edx,%ebp
  802327:	89 c3                	mov    %eax,%ebx
  802329:	f7 64 24 0c          	mull   0xc(%esp)
  80232d:	39 d5                	cmp    %edx,%ebp
  80232f:	72 10                	jb     802341 <__udivdi3+0xc1>
  802331:	8b 74 24 08          	mov    0x8(%esp),%esi
  802335:	89 f9                	mov    %edi,%ecx
  802337:	d3 e6                	shl    %cl,%esi
  802339:	39 c6                	cmp    %eax,%esi
  80233b:	73 07                	jae    802344 <__udivdi3+0xc4>
  80233d:	39 d5                	cmp    %edx,%ebp
  80233f:	75 03                	jne    802344 <__udivdi3+0xc4>
  802341:	83 eb 01             	sub    $0x1,%ebx
  802344:	31 ff                	xor    %edi,%edi
  802346:	89 d8                	mov    %ebx,%eax
  802348:	89 fa                	mov    %edi,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	31 ff                	xor    %edi,%edi
  80235a:	31 db                	xor    %ebx,%ebx
  80235c:	89 d8                	mov    %ebx,%eax
  80235e:	89 fa                	mov    %edi,%edx
  802360:	83 c4 1c             	add    $0x1c,%esp
  802363:	5b                   	pop    %ebx
  802364:	5e                   	pop    %esi
  802365:	5f                   	pop    %edi
  802366:	5d                   	pop    %ebp
  802367:	c3                   	ret    
  802368:	90                   	nop
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	89 d8                	mov    %ebx,%eax
  802372:	f7 f7                	div    %edi
  802374:	31 ff                	xor    %edi,%edi
  802376:	89 c3                	mov    %eax,%ebx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 fa                	mov    %edi,%edx
  80237c:	83 c4 1c             	add    $0x1c,%esp
  80237f:	5b                   	pop    %ebx
  802380:	5e                   	pop    %esi
  802381:	5f                   	pop    %edi
  802382:	5d                   	pop    %ebp
  802383:	c3                   	ret    
  802384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802388:	39 ce                	cmp    %ecx,%esi
  80238a:	72 0c                	jb     802398 <__udivdi3+0x118>
  80238c:	31 db                	xor    %ebx,%ebx
  80238e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802392:	0f 87 34 ff ff ff    	ja     8022cc <__udivdi3+0x4c>
  802398:	bb 01 00 00 00       	mov    $0x1,%ebx
  80239d:	e9 2a ff ff ff       	jmp    8022cc <__udivdi3+0x4c>
  8023a2:	66 90                	xchg   %ax,%ax
  8023a4:	66 90                	xchg   %ax,%ax
  8023a6:	66 90                	xchg   %ax,%ax
  8023a8:	66 90                	xchg   %ax,%ax
  8023aa:	66 90                	xchg   %ax,%ax
  8023ac:	66 90                	xchg   %ax,%ax
  8023ae:	66 90                	xchg   %ax,%ax

008023b0 <__umoddi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	53                   	push   %ebx
  8023b4:	83 ec 1c             	sub    $0x1c,%esp
  8023b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023c7:	85 d2                	test   %edx,%edx
  8023c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023d1:	89 f3                	mov    %esi,%ebx
  8023d3:	89 3c 24             	mov    %edi,(%esp)
  8023d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023da:	75 1c                	jne    8023f8 <__umoddi3+0x48>
  8023dc:	39 f7                	cmp    %esi,%edi
  8023de:	76 50                	jbe    802430 <__umoddi3+0x80>
  8023e0:	89 c8                	mov    %ecx,%eax
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	f7 f7                	div    %edi
  8023e6:	89 d0                	mov    %edx,%eax
  8023e8:	31 d2                	xor    %edx,%edx
  8023ea:	83 c4 1c             	add    $0x1c,%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5f                   	pop    %edi
  8023f0:	5d                   	pop    %ebp
  8023f1:	c3                   	ret    
  8023f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023f8:	39 f2                	cmp    %esi,%edx
  8023fa:	89 d0                	mov    %edx,%eax
  8023fc:	77 52                	ja     802450 <__umoddi3+0xa0>
  8023fe:	0f bd ea             	bsr    %edx,%ebp
  802401:	83 f5 1f             	xor    $0x1f,%ebp
  802404:	75 5a                	jne    802460 <__umoddi3+0xb0>
  802406:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80240a:	0f 82 e0 00 00 00    	jb     8024f0 <__umoddi3+0x140>
  802410:	39 0c 24             	cmp    %ecx,(%esp)
  802413:	0f 86 d7 00 00 00    	jbe    8024f0 <__umoddi3+0x140>
  802419:	8b 44 24 08          	mov    0x8(%esp),%eax
  80241d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802421:	83 c4 1c             	add    $0x1c,%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	85 ff                	test   %edi,%edi
  802432:	89 fd                	mov    %edi,%ebp
  802434:	75 0b                	jne    802441 <__umoddi3+0x91>
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	f7 f7                	div    %edi
  80243f:	89 c5                	mov    %eax,%ebp
  802441:	89 f0                	mov    %esi,%eax
  802443:	31 d2                	xor    %edx,%edx
  802445:	f7 f5                	div    %ebp
  802447:	89 c8                	mov    %ecx,%eax
  802449:	f7 f5                	div    %ebp
  80244b:	89 d0                	mov    %edx,%eax
  80244d:	eb 99                	jmp    8023e8 <__umoddi3+0x38>
  80244f:	90                   	nop
  802450:	89 c8                	mov    %ecx,%eax
  802452:	89 f2                	mov    %esi,%edx
  802454:	83 c4 1c             	add    $0x1c,%esp
  802457:	5b                   	pop    %ebx
  802458:	5e                   	pop    %esi
  802459:	5f                   	pop    %edi
  80245a:	5d                   	pop    %ebp
  80245b:	c3                   	ret    
  80245c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802460:	8b 34 24             	mov    (%esp),%esi
  802463:	bf 20 00 00 00       	mov    $0x20,%edi
  802468:	89 e9                	mov    %ebp,%ecx
  80246a:	29 ef                	sub    %ebp,%edi
  80246c:	d3 e0                	shl    %cl,%eax
  80246e:	89 f9                	mov    %edi,%ecx
  802470:	89 f2                	mov    %esi,%edx
  802472:	d3 ea                	shr    %cl,%edx
  802474:	89 e9                	mov    %ebp,%ecx
  802476:	09 c2                	or     %eax,%edx
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	89 14 24             	mov    %edx,(%esp)
  80247d:	89 f2                	mov    %esi,%edx
  80247f:	d3 e2                	shl    %cl,%edx
  802481:	89 f9                	mov    %edi,%ecx
  802483:	89 54 24 04          	mov    %edx,0x4(%esp)
  802487:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80248b:	d3 e8                	shr    %cl,%eax
  80248d:	89 e9                	mov    %ebp,%ecx
  80248f:	89 c6                	mov    %eax,%esi
  802491:	d3 e3                	shl    %cl,%ebx
  802493:	89 f9                	mov    %edi,%ecx
  802495:	89 d0                	mov    %edx,%eax
  802497:	d3 e8                	shr    %cl,%eax
  802499:	89 e9                	mov    %ebp,%ecx
  80249b:	09 d8                	or     %ebx,%eax
  80249d:	89 d3                	mov    %edx,%ebx
  80249f:	89 f2                	mov    %esi,%edx
  8024a1:	f7 34 24             	divl   (%esp)
  8024a4:	89 d6                	mov    %edx,%esi
  8024a6:	d3 e3                	shl    %cl,%ebx
  8024a8:	f7 64 24 04          	mull   0x4(%esp)
  8024ac:	39 d6                	cmp    %edx,%esi
  8024ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024b2:	89 d1                	mov    %edx,%ecx
  8024b4:	89 c3                	mov    %eax,%ebx
  8024b6:	72 08                	jb     8024c0 <__umoddi3+0x110>
  8024b8:	75 11                	jne    8024cb <__umoddi3+0x11b>
  8024ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024be:	73 0b                	jae    8024cb <__umoddi3+0x11b>
  8024c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024c4:	1b 14 24             	sbb    (%esp),%edx
  8024c7:	89 d1                	mov    %edx,%ecx
  8024c9:	89 c3                	mov    %eax,%ebx
  8024cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024cf:	29 da                	sub    %ebx,%edx
  8024d1:	19 ce                	sbb    %ecx,%esi
  8024d3:	89 f9                	mov    %edi,%ecx
  8024d5:	89 f0                	mov    %esi,%eax
  8024d7:	d3 e0                	shl    %cl,%eax
  8024d9:	89 e9                	mov    %ebp,%ecx
  8024db:	d3 ea                	shr    %cl,%edx
  8024dd:	89 e9                	mov    %ebp,%ecx
  8024df:	d3 ee                	shr    %cl,%esi
  8024e1:	09 d0                	or     %edx,%eax
  8024e3:	89 f2                	mov    %esi,%edx
  8024e5:	83 c4 1c             	add    $0x1c,%esp
  8024e8:	5b                   	pop    %ebx
  8024e9:	5e                   	pop    %esi
  8024ea:	5f                   	pop    %edi
  8024eb:	5d                   	pop    %ebp
  8024ec:	c3                   	ret    
  8024ed:	8d 76 00             	lea    0x0(%esi),%esi
  8024f0:	29 f9                	sub    %edi,%ecx
  8024f2:	19 d6                	sbb    %edx,%esi
  8024f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024fc:	e9 18 ff ff ff       	jmp    802419 <__umoddi3+0x69>
