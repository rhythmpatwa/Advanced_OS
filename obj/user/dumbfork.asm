
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 72 0c 00 00       	call   800cbc <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 00 24 80 00       	push   $0x802400
  800057:	6a 20                	push   $0x20
  800059:	68 13 24 80 00       	push   $0x802413
  80005e:	e8 d8 01 00 00       	call   80023b <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 89 0c 00 00       	call   800cff <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 23 24 80 00       	push   $0x802423
  800083:	6a 22                	push   $0x22
  800085:	68 13 24 80 00       	push   $0x802413
  80008a:	e8 ac 01 00 00       	call   80023b <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 a9 09 00 00       	call   800a4b <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 90 0c 00 00       	call   800d41 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 34 24 80 00       	push   $0x802434
  8000be:	6a 25                	push   $0x25
  8000c0:	68 13 24 80 00       	push   $0x802413
  8000c5:	e8 71 01 00 00       	call   80023b <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 47 24 80 00       	push   $0x802447
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 13 24 80 00       	push   $0x802413
  8000f3:	e8 43 01 00 00       	call   80023b <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 7b 0b 00 00       	call   800c7e <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 70 80 00    	cmp    $0x807000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 22 0c 00 00       	call   800d83 <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 57 24 80 00       	push   $0x802457
  80016e:	6a 4c                	push   $0x4c
  800170:	68 13 24 80 00       	push   $0x802413
  800175:	e8 c1 00 00 00       	call   80023b <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be 75 24 80 00       	mov    $0x802475,%esi
  80019a:	b8 6e 24 80 00       	mov    $0x80246e,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 7b 24 80 00       	push   $0x80247b
  8001b3:	e8 5c 01 00 00       	call   800314 <cprintf>
		sys_yield();
  8001b8:	e8 e0 0a 00 00       	call   800c9d <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8001e6:	e8 93 0a 00 00       	call   800c7e <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f8:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7e 07                	jle    800208 <libmain+0x2d>
		binaryname = argv[0];
  800201:	8b 06                	mov    (%esi),%eax
  800203:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	e8 71 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  800212:	e8 0a 00 00 00       	call   800221 <exit>
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800227:	e8 6b 0e 00 00       	call   801097 <close_all>
	sys_env_destroy(0);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	6a 00                	push   $0x0
  800231:	e8 07 0a 00 00       	call   800c3d <sys_env_destroy>
}
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800240:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800243:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800249:	e8 30 0a 00 00       	call   800c7e <sys_getenvid>
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	56                   	push   %esi
  800258:	50                   	push   %eax
  800259:	68 98 24 80 00       	push   $0x802498
  80025e:	e8 b1 00 00 00       	call   800314 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	53                   	push   %ebx
  800267:	ff 75 10             	pushl  0x10(%ebp)
  80026a:	e8 54 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  80026f:	c7 04 24 8b 24 80 00 	movl   $0x80248b,(%esp)
  800276:	e8 99 00 00 00       	call   800314 <cprintf>
  80027b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027e:	cc                   	int3   
  80027f:	eb fd                	jmp    80027e <_panic+0x43>

00800281 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	53                   	push   %ebx
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028b:	8b 13                	mov    (%ebx),%edx
  80028d:	8d 42 01             	lea    0x1(%edx),%eax
  800290:	89 03                	mov    %eax,(%ebx)
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800299:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029e:	75 1a                	jne    8002ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	68 ff 00 00 00       	push   $0xff
  8002a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 4f 09 00 00       	call   800c00 <sys_cputs>
		b->idx = 0;
  8002b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	ff 75 0c             	pushl  0xc(%ebp)
  8002e3:	ff 75 08             	pushl  0x8(%ebp)
  8002e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ec:	50                   	push   %eax
  8002ed:	68 81 02 80 00       	push   $0x800281
  8002f2:	e8 54 01 00 00       	call   80044b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f7:	83 c4 08             	add    $0x8,%esp
  8002fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800300:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800306:	50                   	push   %eax
  800307:	e8 f4 08 00 00       	call   800c00 <sys_cputs>

	return b.cnt;
}
  80030c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	e8 9d ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 1c             	sub    $0x1c,%esp
  800331:	89 c7                	mov    %eax,%edi
  800333:	89 d6                	mov    %edx,%esi
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80034c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034f:	39 d3                	cmp    %edx,%ebx
  800351:	72 05                	jb     800358 <printnum+0x30>
  800353:	39 45 10             	cmp    %eax,0x10(%ebp)
  800356:	77 45                	ja     80039d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036e:	ff 75 e0             	pushl  -0x20(%ebp)
  800371:	ff 75 dc             	pushl  -0x24(%ebp)
  800374:	ff 75 d8             	pushl  -0x28(%ebp)
  800377:	e8 f4 1d 00 00       	call   802170 <__udivdi3>
  80037c:	83 c4 18             	add    $0x18,%esp
  80037f:	52                   	push   %edx
  800380:	50                   	push   %eax
  800381:	89 f2                	mov    %esi,%edx
  800383:	89 f8                	mov    %edi,%eax
  800385:	e8 9e ff ff ff       	call   800328 <printnum>
  80038a:	83 c4 20             	add    $0x20,%esp
  80038d:	eb 18                	jmp    8003a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	56                   	push   %esi
  800393:	ff 75 18             	pushl  0x18(%ebp)
  800396:	ff d7                	call   *%edi
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	eb 03                	jmp    8003a0 <printnum+0x78>
  80039d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a0:	83 eb 01             	sub    $0x1,%ebx
  8003a3:	85 db                	test   %ebx,%ebx
  8003a5:	7f e8                	jg     80038f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	56                   	push   %esi
  8003ab:	83 ec 04             	sub    $0x4,%esp
  8003ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ba:	e8 e1 1e 00 00       	call   8022a0 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 bb 24 80 00 	movsbl 0x8024bb(%eax),%eax
  8003c9:	50                   	push   %eax
  8003ca:	ff d7                	call   *%edi
}
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d2:	5b                   	pop    %ebx
  8003d3:	5e                   	pop    %esi
  8003d4:	5f                   	pop    %edi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003da:	83 fa 01             	cmp    $0x1,%edx
  8003dd:	7e 0e                	jle    8003ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	8b 52 04             	mov    0x4(%edx),%edx
  8003eb:	eb 22                	jmp    80040f <getuint+0x38>
	else if (lflag)
  8003ed:	85 d2                	test   %edx,%edx
  8003ef:	74 10                	je     800401 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f6:	89 08                	mov    %ecx,(%eax)
  8003f8:	8b 02                	mov    (%edx),%eax
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ff:	eb 0e                	jmp    80040f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800401:	8b 10                	mov    (%eax),%edx
  800403:	8d 4a 04             	lea    0x4(%edx),%ecx
  800406:	89 08                	mov    %ecx,(%eax)
  800408:	8b 02                	mov    (%edx),%eax
  80040a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800417:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041b:	8b 10                	mov    (%eax),%edx
  80041d:	3b 50 04             	cmp    0x4(%eax),%edx
  800420:	73 0a                	jae    80042c <sprintputch+0x1b>
		*b->buf++ = ch;
  800422:	8d 4a 01             	lea    0x1(%edx),%ecx
  800425:	89 08                	mov    %ecx,(%eax)
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	88 02                	mov    %al,(%edx)
}
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800434:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800437:	50                   	push   %eax
  800438:	ff 75 10             	pushl  0x10(%ebp)
  80043b:	ff 75 0c             	pushl  0xc(%ebp)
  80043e:	ff 75 08             	pushl  0x8(%ebp)
  800441:	e8 05 00 00 00       	call   80044b <vprintfmt>
	va_end(ap);
}
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	57                   	push   %edi
  80044f:	56                   	push   %esi
  800450:	53                   	push   %ebx
  800451:	83 ec 2c             	sub    $0x2c,%esp
  800454:	8b 75 08             	mov    0x8(%ebp),%esi
  800457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80045d:	eb 12                	jmp    800471 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045f:	85 c0                	test   %eax,%eax
  800461:	0f 84 a9 03 00 00    	je     800810 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	53                   	push   %ebx
  80046b:	50                   	push   %eax
  80046c:	ff d6                	call   *%esi
  80046e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800471:	83 c7 01             	add    $0x1,%edi
  800474:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800478:	83 f8 25             	cmp    $0x25,%eax
  80047b:	75 e2                	jne    80045f <vprintfmt+0x14>
  80047d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800481:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800488:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800496:	ba 00 00 00 00       	mov    $0x0,%edx
  80049b:	eb 07                	jmp    8004a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8d 47 01             	lea    0x1(%edi),%eax
  8004a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004aa:	0f b6 07             	movzbl (%edi),%eax
  8004ad:	0f b6 c8             	movzbl %al,%ecx
  8004b0:	83 e8 23             	sub    $0x23,%eax
  8004b3:	3c 55                	cmp    $0x55,%al
  8004b5:	0f 87 3a 03 00 00    	ja     8007f5 <vprintfmt+0x3aa>
  8004bb:	0f b6 c0             	movzbl %al,%eax
  8004be:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004cc:	eb d6                	jmp    8004a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004dc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004e3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e6:	83 fa 09             	cmp    $0x9,%edx
  8004e9:	77 39                	ja     800524 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004eb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004ee:	eb e9                	jmp    8004d9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800501:	eb 27                	jmp    80052a <vprintfmt+0xdf>
  800503:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800506:	85 c0                	test   %eax,%eax
  800508:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050d:	0f 49 c8             	cmovns %eax,%ecx
  800510:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800516:	eb 8c                	jmp    8004a4 <vprintfmt+0x59>
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800522:	eb 80                	jmp    8004a4 <vprintfmt+0x59>
  800524:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800527:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	0f 89 70 ff ff ff    	jns    8004a4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800534:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800537:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800541:	e9 5e ff ff ff       	jmp    8004a4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800546:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054c:	e9 53 ff ff ff       	jmp    8004a4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	ff 30                	pushl  (%eax)
  800560:	ff d6                	call   *%esi
			break;
  800562:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800568:	e9 04 ff ff ff       	jmp    800471 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	8b 00                	mov    (%eax),%eax
  800578:	99                   	cltd   
  800579:	31 d0                	xor    %edx,%eax
  80057b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057d:	83 f8 0f             	cmp    $0xf,%eax
  800580:	7f 0b                	jg     80058d <vprintfmt+0x142>
  800582:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  800589:	85 d2                	test   %edx,%edx
  80058b:	75 18                	jne    8005a5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80058d:	50                   	push   %eax
  80058e:	68 d3 24 80 00       	push   $0x8024d3
  800593:	53                   	push   %ebx
  800594:	56                   	push   %esi
  800595:	e8 94 fe ff ff       	call   80042e <printfmt>
  80059a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a0:	e9 cc fe ff ff       	jmp    800471 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a5:	52                   	push   %edx
  8005a6:	68 99 28 80 00       	push   $0x802899
  8005ab:	53                   	push   %ebx
  8005ac:	56                   	push   %esi
  8005ad:	e8 7c fe ff ff       	call   80042e <printfmt>
  8005b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b8:	e9 b4 fe ff ff       	jmp    800471 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c8:	85 ff                	test   %edi,%edi
  8005ca:	b8 cc 24 80 00       	mov    $0x8024cc,%eax
  8005cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d6:	0f 8e 94 00 00 00    	jle    800670 <vprintfmt+0x225>
  8005dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e0:	0f 84 98 00 00 00    	je     80067e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8005ec:	57                   	push   %edi
  8005ed:	e8 a6 02 00 00       	call   800898 <strnlen>
  8005f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f5:	29 c1                	sub    %eax,%ecx
  8005f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005fa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005fd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800601:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800604:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800607:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	eb 0f                	jmp    80061a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	ff 75 e0             	pushl  -0x20(%ebp)
  800612:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800614:	83 ef 01             	sub    $0x1,%edi
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	85 ff                	test   %edi,%edi
  80061c:	7f ed                	jg     80060b <vprintfmt+0x1c0>
  80061e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800621:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800624:	85 c9                	test   %ecx,%ecx
  800626:	b8 00 00 00 00       	mov    $0x0,%eax
  80062b:	0f 49 c1             	cmovns %ecx,%eax
  80062e:	29 c1                	sub    %eax,%ecx
  800630:	89 75 08             	mov    %esi,0x8(%ebp)
  800633:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800636:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800639:	89 cb                	mov    %ecx,%ebx
  80063b:	eb 4d                	jmp    80068a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800641:	74 1b                	je     80065e <vprintfmt+0x213>
  800643:	0f be c0             	movsbl %al,%eax
  800646:	83 e8 20             	sub    $0x20,%eax
  800649:	83 f8 5e             	cmp    $0x5e,%eax
  80064c:	76 10                	jbe    80065e <vprintfmt+0x213>
					putch('?', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	ff 75 0c             	pushl  0xc(%ebp)
  800654:	6a 3f                	push   $0x3f
  800656:	ff 55 08             	call   *0x8(%ebp)
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	eb 0d                	jmp    80066b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	ff 75 0c             	pushl  0xc(%ebp)
  800664:	52                   	push   %edx
  800665:	ff 55 08             	call   *0x8(%ebp)
  800668:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066b:	83 eb 01             	sub    $0x1,%ebx
  80066e:	eb 1a                	jmp    80068a <vprintfmt+0x23f>
  800670:	89 75 08             	mov    %esi,0x8(%ebp)
  800673:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800676:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800679:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067c:	eb 0c                	jmp    80068a <vprintfmt+0x23f>
  80067e:	89 75 08             	mov    %esi,0x8(%ebp)
  800681:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800684:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800687:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80068a:	83 c7 01             	add    $0x1,%edi
  80068d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800691:	0f be d0             	movsbl %al,%edx
  800694:	85 d2                	test   %edx,%edx
  800696:	74 23                	je     8006bb <vprintfmt+0x270>
  800698:	85 f6                	test   %esi,%esi
  80069a:	78 a1                	js     80063d <vprintfmt+0x1f2>
  80069c:	83 ee 01             	sub    $0x1,%esi
  80069f:	79 9c                	jns    80063d <vprintfmt+0x1f2>
  8006a1:	89 df                	mov    %ebx,%edi
  8006a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a9:	eb 18                	jmp    8006c3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 20                	push   $0x20
  8006b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b3:	83 ef 01             	sub    $0x1,%edi
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 08                	jmp    8006c3 <vprintfmt+0x278>
  8006bb:	89 df                	mov    %ebx,%edi
  8006bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	7f e4                	jg     8006ab <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ca:	e9 a2 fd ff ff       	jmp    800471 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cf:	83 fa 01             	cmp    $0x1,%edx
  8006d2:	7e 16                	jle    8006ea <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 08             	lea    0x8(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dd:	8b 50 04             	mov    0x4(%eax),%edx
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e8:	eb 32                	jmp    80071c <vprintfmt+0x2d1>
	else if (lflag)
  8006ea:	85 d2                	test   %edx,%edx
  8006ec:	74 18                	je     800706 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8d 50 04             	lea    0x4(%eax),%edx
  8006f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f7:	8b 00                	mov    (%eax),%eax
  8006f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fc:	89 c1                	mov    %eax,%ecx
  8006fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800701:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800704:	eb 16                	jmp    80071c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800714:	89 c1                	mov    %eax,%ecx
  800716:	c1 f9 1f             	sar    $0x1f,%ecx
  800719:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800727:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80072b:	0f 89 90 00 00 00    	jns    8007c1 <vprintfmt+0x376>
				putch('-', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	6a 2d                	push   $0x2d
  800737:	ff d6                	call   *%esi
				num = -(long long) num;
  800739:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80073c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80073f:	f7 d8                	neg    %eax
  800741:	83 d2 00             	adc    $0x0,%edx
  800744:	f7 da                	neg    %edx
  800746:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800749:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80074e:	eb 71                	jmp    8007c1 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800750:	8d 45 14             	lea    0x14(%ebp),%eax
  800753:	e8 7f fc ff ff       	call   8003d7 <getuint>
			base = 10;
  800758:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80075d:	eb 62                	jmp    8007c1 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
  800762:	e8 70 fc ff ff       	call   8003d7 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800767:	83 ec 0c             	sub    $0xc,%esp
  80076a:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80076e:	51                   	push   %ecx
  80076f:	ff 75 e0             	pushl  -0x20(%ebp)
  800772:	6a 08                	push   $0x8
  800774:	52                   	push   %edx
  800775:	50                   	push   %eax
  800776:	89 da                	mov    %ebx,%edx
  800778:	89 f0                	mov    %esi,%eax
  80077a:	e8 a9 fb ff ff       	call   800328 <printnum>
			break;
  80077f:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800782:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800785:	e9 e7 fc ff ff       	jmp    800471 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	53                   	push   %ebx
  80078e:	6a 30                	push   $0x30
  800790:	ff d6                	call   *%esi
			putch('x', putdat);
  800792:	83 c4 08             	add    $0x8,%esp
  800795:	53                   	push   %ebx
  800796:	6a 78                	push   $0x78
  800798:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8d 50 04             	lea    0x4(%eax),%edx
  8007a0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007aa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ad:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007b2:	eb 0d                	jmp    8007c1 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b7:	e8 1b fc ff ff       	call   8003d7 <getuint>
			base = 16;
  8007bc:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c1:	83 ec 0c             	sub    $0xc,%esp
  8007c4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c8:	57                   	push   %edi
  8007c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8007cc:	51                   	push   %ecx
  8007cd:	52                   	push   %edx
  8007ce:	50                   	push   %eax
  8007cf:	89 da                	mov    %ebx,%edx
  8007d1:	89 f0                	mov    %esi,%eax
  8007d3:	e8 50 fb ff ff       	call   800328 <printnum>
			break;
  8007d8:	83 c4 20             	add    $0x20,%esp
  8007db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007de:	e9 8e fc ff ff       	jmp    800471 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	53                   	push   %ebx
  8007e7:	51                   	push   %ecx
  8007e8:	ff d6                	call   *%esi
			break;
  8007ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f0:	e9 7c fc ff ff       	jmp    800471 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	53                   	push   %ebx
  8007f9:	6a 25                	push   $0x25
  8007fb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fd:	83 c4 10             	add    $0x10,%esp
  800800:	eb 03                	jmp    800805 <vprintfmt+0x3ba>
  800802:	83 ef 01             	sub    $0x1,%edi
  800805:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800809:	75 f7                	jne    800802 <vprintfmt+0x3b7>
  80080b:	e9 61 fc ff ff       	jmp    800471 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800810:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800813:	5b                   	pop    %ebx
  800814:	5e                   	pop    %esi
  800815:	5f                   	pop    %edi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	83 ec 18             	sub    $0x18,%esp
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800824:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800827:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80082b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800835:	85 c0                	test   %eax,%eax
  800837:	74 26                	je     80085f <vsnprintf+0x47>
  800839:	85 d2                	test   %edx,%edx
  80083b:	7e 22                	jle    80085f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083d:	ff 75 14             	pushl  0x14(%ebp)
  800840:	ff 75 10             	pushl  0x10(%ebp)
  800843:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800846:	50                   	push   %eax
  800847:	68 11 04 80 00       	push   $0x800411
  80084c:	e8 fa fb ff ff       	call   80044b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800851:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800854:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085a:	83 c4 10             	add    $0x10,%esp
  80085d:	eb 05                	jmp    800864 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80086c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086f:	50                   	push   %eax
  800870:	ff 75 10             	pushl  0x10(%ebp)
  800873:	ff 75 0c             	pushl  0xc(%ebp)
  800876:	ff 75 08             	pushl  0x8(%ebp)
  800879:	e8 9a ff ff ff       	call   800818 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	eb 03                	jmp    800890 <strlen+0x10>
		n++;
  80088d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800890:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800894:	75 f7                	jne    80088d <strlen+0xd>
		n++;
	return n;
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a6:	eb 03                	jmp    8008ab <strnlen+0x13>
		n++;
  8008a8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ab:	39 c2                	cmp    %eax,%edx
  8008ad:	74 08                	je     8008b7 <strnlen+0x1f>
  8008af:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008b3:	75 f3                	jne    8008a8 <strnlen+0x10>
  8008b5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c3:	89 c2                	mov    %eax,%edx
  8008c5:	83 c2 01             	add    $0x1,%edx
  8008c8:	83 c1 01             	add    $0x1,%ecx
  8008cb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008cf:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d2:	84 db                	test   %bl,%bl
  8008d4:	75 ef                	jne    8008c5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d6:	5b                   	pop    %ebx
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	53                   	push   %ebx
  8008dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e0:	53                   	push   %ebx
  8008e1:	e8 9a ff ff ff       	call   800880 <strlen>
  8008e6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e9:	ff 75 0c             	pushl  0xc(%ebp)
  8008ec:	01 d8                	add    %ebx,%eax
  8008ee:	50                   	push   %eax
  8008ef:	e8 c5 ff ff ff       	call   8008b9 <strcpy>
	return dst;
}
  8008f4:	89 d8                	mov    %ebx,%eax
  8008f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f9:	c9                   	leave  
  8008fa:	c3                   	ret    

008008fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 75 08             	mov    0x8(%ebp),%esi
  800903:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800906:	89 f3                	mov    %esi,%ebx
  800908:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090b:	89 f2                	mov    %esi,%edx
  80090d:	eb 0f                	jmp    80091e <strncpy+0x23>
		*dst++ = *src;
  80090f:	83 c2 01             	add    $0x1,%edx
  800912:	0f b6 01             	movzbl (%ecx),%eax
  800915:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800918:	80 39 01             	cmpb   $0x1,(%ecx)
  80091b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091e:	39 da                	cmp    %ebx,%edx
  800920:	75 ed                	jne    80090f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800922:	89 f0                	mov    %esi,%eax
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 75 08             	mov    0x8(%ebp),%esi
  800930:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800933:	8b 55 10             	mov    0x10(%ebp),%edx
  800936:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800938:	85 d2                	test   %edx,%edx
  80093a:	74 21                	je     80095d <strlcpy+0x35>
  80093c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800940:	89 f2                	mov    %esi,%edx
  800942:	eb 09                	jmp    80094d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800944:	83 c2 01             	add    $0x1,%edx
  800947:	83 c1 01             	add    $0x1,%ecx
  80094a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80094d:	39 c2                	cmp    %eax,%edx
  80094f:	74 09                	je     80095a <strlcpy+0x32>
  800951:	0f b6 19             	movzbl (%ecx),%ebx
  800954:	84 db                	test   %bl,%bl
  800956:	75 ec                	jne    800944 <strlcpy+0x1c>
  800958:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80095a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095d:	29 f0                	sub    %esi,%eax
}
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096c:	eb 06                	jmp    800974 <strcmp+0x11>
		p++, q++;
  80096e:	83 c1 01             	add    $0x1,%ecx
  800971:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800974:	0f b6 01             	movzbl (%ecx),%eax
  800977:	84 c0                	test   %al,%al
  800979:	74 04                	je     80097f <strcmp+0x1c>
  80097b:	3a 02                	cmp    (%edx),%al
  80097d:	74 ef                	je     80096e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097f:	0f b6 c0             	movzbl %al,%eax
  800982:	0f b6 12             	movzbl (%edx),%edx
  800985:	29 d0                	sub    %edx,%eax
}
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	53                   	push   %ebx
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 55 0c             	mov    0xc(%ebp),%edx
  800993:	89 c3                	mov    %eax,%ebx
  800995:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800998:	eb 06                	jmp    8009a0 <strncmp+0x17>
		n--, p++, q++;
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a0:	39 d8                	cmp    %ebx,%eax
  8009a2:	74 15                	je     8009b9 <strncmp+0x30>
  8009a4:	0f b6 08             	movzbl (%eax),%ecx
  8009a7:	84 c9                	test   %cl,%cl
  8009a9:	74 04                	je     8009af <strncmp+0x26>
  8009ab:	3a 0a                	cmp    (%edx),%cl
  8009ad:	74 eb                	je     80099a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009af:	0f b6 00             	movzbl (%eax),%eax
  8009b2:	0f b6 12             	movzbl (%edx),%edx
  8009b5:	29 d0                	sub    %edx,%eax
  8009b7:	eb 05                	jmp    8009be <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cb:	eb 07                	jmp    8009d4 <strchr+0x13>
		if (*s == c)
  8009cd:	38 ca                	cmp    %cl,%dl
  8009cf:	74 0f                	je     8009e0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d1:	83 c0 01             	add    $0x1,%eax
  8009d4:	0f b6 10             	movzbl (%eax),%edx
  8009d7:	84 d2                	test   %dl,%dl
  8009d9:	75 f2                	jne    8009cd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ec:	eb 03                	jmp    8009f1 <strfind+0xf>
  8009ee:	83 c0 01             	add    $0x1,%eax
  8009f1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f4:	38 ca                	cmp    %cl,%dl
  8009f6:	74 04                	je     8009fc <strfind+0x1a>
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	75 f2                	jne    8009ee <strfind+0xc>
			break;
	return (char *) s;
}
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	57                   	push   %edi
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a0a:	85 c9                	test   %ecx,%ecx
  800a0c:	74 36                	je     800a44 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a14:	75 28                	jne    800a3e <memset+0x40>
  800a16:	f6 c1 03             	test   $0x3,%cl
  800a19:	75 23                	jne    800a3e <memset+0x40>
		c &= 0xFF;
  800a1b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1f:	89 d3                	mov    %edx,%ebx
  800a21:	c1 e3 08             	shl    $0x8,%ebx
  800a24:	89 d6                	mov    %edx,%esi
  800a26:	c1 e6 18             	shl    $0x18,%esi
  800a29:	89 d0                	mov    %edx,%eax
  800a2b:	c1 e0 10             	shl    $0x10,%eax
  800a2e:	09 f0                	or     %esi,%eax
  800a30:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a32:	89 d8                	mov    %ebx,%eax
  800a34:	09 d0                	or     %edx,%eax
  800a36:	c1 e9 02             	shr    $0x2,%ecx
  800a39:	fc                   	cld    
  800a3a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3c:	eb 06                	jmp    800a44 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a41:	fc                   	cld    
  800a42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a44:	89 f8                	mov    %edi,%eax
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5f                   	pop    %edi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	57                   	push   %edi
  800a4f:	56                   	push   %esi
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a59:	39 c6                	cmp    %eax,%esi
  800a5b:	73 35                	jae    800a92 <memmove+0x47>
  800a5d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a60:	39 d0                	cmp    %edx,%eax
  800a62:	73 2e                	jae    800a92 <memmove+0x47>
		s += n;
		d += n;
  800a64:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a67:	89 d6                	mov    %edx,%esi
  800a69:	09 fe                	or     %edi,%esi
  800a6b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a71:	75 13                	jne    800a86 <memmove+0x3b>
  800a73:	f6 c1 03             	test   $0x3,%cl
  800a76:	75 0e                	jne    800a86 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a78:	83 ef 04             	sub    $0x4,%edi
  800a7b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7e:	c1 e9 02             	shr    $0x2,%ecx
  800a81:	fd                   	std    
  800a82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a84:	eb 09                	jmp    800a8f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a86:	83 ef 01             	sub    $0x1,%edi
  800a89:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a8c:	fd                   	std    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8f:	fc                   	cld    
  800a90:	eb 1d                	jmp    800aaf <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	89 f2                	mov    %esi,%edx
  800a94:	09 c2                	or     %eax,%edx
  800a96:	f6 c2 03             	test   $0x3,%dl
  800a99:	75 0f                	jne    800aaa <memmove+0x5f>
  800a9b:	f6 c1 03             	test   $0x3,%cl
  800a9e:	75 0a                	jne    800aaa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aa0:	c1 e9 02             	shr    $0x2,%ecx
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	fc                   	cld    
  800aa6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa8:	eb 05                	jmp    800aaf <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aaa:	89 c7                	mov    %eax,%edi
  800aac:	fc                   	cld    
  800aad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ab6:	ff 75 10             	pushl  0x10(%ebp)
  800ab9:	ff 75 0c             	pushl  0xc(%ebp)
  800abc:	ff 75 08             	pushl  0x8(%ebp)
  800abf:	e8 87 ff ff ff       	call   800a4b <memmove>
}
  800ac4:	c9                   	leave  
  800ac5:	c3                   	ret    

00800ac6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad1:	89 c6                	mov    %eax,%esi
  800ad3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad6:	eb 1a                	jmp    800af2 <memcmp+0x2c>
		if (*s1 != *s2)
  800ad8:	0f b6 08             	movzbl (%eax),%ecx
  800adb:	0f b6 1a             	movzbl (%edx),%ebx
  800ade:	38 d9                	cmp    %bl,%cl
  800ae0:	74 0a                	je     800aec <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae2:	0f b6 c1             	movzbl %cl,%eax
  800ae5:	0f b6 db             	movzbl %bl,%ebx
  800ae8:	29 d8                	sub    %ebx,%eax
  800aea:	eb 0f                	jmp    800afb <memcmp+0x35>
		s1++, s2++;
  800aec:	83 c0 01             	add    $0x1,%eax
  800aef:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af2:	39 f0                	cmp    %esi,%eax
  800af4:	75 e2                	jne    800ad8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	53                   	push   %ebx
  800b03:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b06:	89 c1                	mov    %eax,%ecx
  800b08:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0f:	eb 0a                	jmp    800b1b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b11:	0f b6 10             	movzbl (%eax),%edx
  800b14:	39 da                	cmp    %ebx,%edx
  800b16:	74 07                	je     800b1f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b18:	83 c0 01             	add    $0x1,%eax
  800b1b:	39 c8                	cmp    %ecx,%eax
  800b1d:	72 f2                	jb     800b11 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2e:	eb 03                	jmp    800b33 <strtol+0x11>
		s++;
  800b30:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b33:	0f b6 01             	movzbl (%ecx),%eax
  800b36:	3c 20                	cmp    $0x20,%al
  800b38:	74 f6                	je     800b30 <strtol+0xe>
  800b3a:	3c 09                	cmp    $0x9,%al
  800b3c:	74 f2                	je     800b30 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3e:	3c 2b                	cmp    $0x2b,%al
  800b40:	75 0a                	jne    800b4c <strtol+0x2a>
		s++;
  800b42:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b45:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4a:	eb 11                	jmp    800b5d <strtol+0x3b>
  800b4c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b51:	3c 2d                	cmp    $0x2d,%al
  800b53:	75 08                	jne    800b5d <strtol+0x3b>
		s++, neg = 1;
  800b55:	83 c1 01             	add    $0x1,%ecx
  800b58:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b63:	75 15                	jne    800b7a <strtol+0x58>
  800b65:	80 39 30             	cmpb   $0x30,(%ecx)
  800b68:	75 10                	jne    800b7a <strtol+0x58>
  800b6a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6e:	75 7c                	jne    800bec <strtol+0xca>
		s += 2, base = 16;
  800b70:	83 c1 02             	add    $0x2,%ecx
  800b73:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b78:	eb 16                	jmp    800b90 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b7a:	85 db                	test   %ebx,%ebx
  800b7c:	75 12                	jne    800b90 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b83:	80 39 30             	cmpb   $0x30,(%ecx)
  800b86:	75 08                	jne    800b90 <strtol+0x6e>
		s++, base = 8;
  800b88:	83 c1 01             	add    $0x1,%ecx
  800b8b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b90:	b8 00 00 00 00       	mov    $0x0,%eax
  800b95:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b98:	0f b6 11             	movzbl (%ecx),%edx
  800b9b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b9e:	89 f3                	mov    %esi,%ebx
  800ba0:	80 fb 09             	cmp    $0x9,%bl
  800ba3:	77 08                	ja     800bad <strtol+0x8b>
			dig = *s - '0';
  800ba5:	0f be d2             	movsbl %dl,%edx
  800ba8:	83 ea 30             	sub    $0x30,%edx
  800bab:	eb 22                	jmp    800bcf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bad:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb0:	89 f3                	mov    %esi,%ebx
  800bb2:	80 fb 19             	cmp    $0x19,%bl
  800bb5:	77 08                	ja     800bbf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bb7:	0f be d2             	movsbl %dl,%edx
  800bba:	83 ea 57             	sub    $0x57,%edx
  800bbd:	eb 10                	jmp    800bcf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bbf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc2:	89 f3                	mov    %esi,%ebx
  800bc4:	80 fb 19             	cmp    $0x19,%bl
  800bc7:	77 16                	ja     800bdf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bc9:	0f be d2             	movsbl %dl,%edx
  800bcc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bcf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd2:	7d 0b                	jge    800bdf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bd4:	83 c1 01             	add    $0x1,%ecx
  800bd7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bdb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bdd:	eb b9                	jmp    800b98 <strtol+0x76>

	if (endptr)
  800bdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be3:	74 0d                	je     800bf2 <strtol+0xd0>
		*endptr = (char *) s;
  800be5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be8:	89 0e                	mov    %ecx,(%esi)
  800bea:	eb 06                	jmp    800bf2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bec:	85 db                	test   %ebx,%ebx
  800bee:	74 98                	je     800b88 <strtol+0x66>
  800bf0:	eb 9e                	jmp    800b90 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bf2:	89 c2                	mov    %eax,%edx
  800bf4:	f7 da                	neg    %edx
  800bf6:	85 ff                	test   %edi,%edi
  800bf8:	0f 45 c2             	cmovne %edx,%eax
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	89 c3                	mov    %eax,%ebx
  800c13:	89 c7                	mov    %eax,%edi
  800c15:	89 c6                	mov    %eax,%esi
  800c17:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	ba 00 00 00 00       	mov    $0x0,%edx
  800c29:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2e:	89 d1                	mov    %edx,%ecx
  800c30:	89 d3                	mov    %edx,%ebx
  800c32:	89 d7                	mov    %edx,%edi
  800c34:	89 d6                	mov    %edx,%esi
  800c36:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c50:	8b 55 08             	mov    0x8(%ebp),%edx
  800c53:	89 cb                	mov    %ecx,%ebx
  800c55:	89 cf                	mov    %ecx,%edi
  800c57:	89 ce                	mov    %ecx,%esi
  800c59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7e 17                	jle    800c76 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	50                   	push   %eax
  800c63:	6a 03                	push   $0x3
  800c65:	68 bf 27 80 00       	push   $0x8027bf
  800c6a:	6a 23                	push   $0x23
  800c6c:	68 dc 27 80 00       	push   $0x8027dc
  800c71:	e8 c5 f5 ff ff       	call   80023b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	ba 00 00 00 00       	mov    $0x0,%edx
  800c89:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8e:	89 d1                	mov    %edx,%ecx
  800c90:	89 d3                	mov    %edx,%ebx
  800c92:	89 d7                	mov    %edx,%edi
  800c94:	89 d6                	mov    %edx,%esi
  800c96:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_yield>:

void
sys_yield(void)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cad:	89 d1                	mov    %edx,%ecx
  800caf:	89 d3                	mov    %edx,%ebx
  800cb1:	89 d7                	mov    %edx,%edi
  800cb3:	89 d6                	mov    %edx,%esi
  800cb5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	be 00 00 00 00       	mov    $0x0,%esi
  800cca:	b8 04 00 00 00       	mov    $0x4,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd8:	89 f7                	mov    %esi,%edi
  800cda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	7e 17                	jle    800cf7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	83 ec 0c             	sub    $0xc,%esp
  800ce3:	50                   	push   %eax
  800ce4:	6a 04                	push   $0x4
  800ce6:	68 bf 27 80 00       	push   $0x8027bf
  800ceb:	6a 23                	push   $0x23
  800ced:	68 dc 27 80 00       	push   $0x8027dc
  800cf2:	e8 44 f5 ff ff       	call   80023b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d16:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d19:	8b 75 18             	mov    0x18(%ebp),%esi
  800d1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	7e 17                	jle    800d39 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	50                   	push   %eax
  800d26:	6a 05                	push   $0x5
  800d28:	68 bf 27 80 00       	push   $0x8027bf
  800d2d:	6a 23                	push   $0x23
  800d2f:	68 dc 27 80 00       	push   $0x8027dc
  800d34:	e8 02 f5 ff ff       	call   80023b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4f:	b8 06 00 00 00       	mov    $0x6,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 df                	mov    %ebx,%edi
  800d5c:	89 de                	mov    %ebx,%esi
  800d5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d60:	85 c0                	test   %eax,%eax
  800d62:	7e 17                	jle    800d7b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	50                   	push   %eax
  800d68:	6a 06                	push   $0x6
  800d6a:	68 bf 27 80 00       	push   $0x8027bf
  800d6f:	6a 23                	push   $0x23
  800d71:	68 dc 27 80 00       	push   $0x8027dc
  800d76:	e8 c0 f4 ff ff       	call   80023b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d91:	b8 08 00 00 00       	mov    $0x8,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 df                	mov    %ebx,%edi
  800d9e:	89 de                	mov    %ebx,%esi
  800da0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da2:	85 c0                	test   %eax,%eax
  800da4:	7e 17                	jle    800dbd <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	50                   	push   %eax
  800daa:	6a 08                	push   $0x8
  800dac:	68 bf 27 80 00       	push   $0x8027bf
  800db1:	6a 23                	push   $0x23
  800db3:	68 dc 27 80 00       	push   $0x8027dc
  800db8:	e8 7e f4 ff ff       	call   80023b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd3:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	89 df                	mov    %ebx,%edi
  800de0:	89 de                	mov    %ebx,%esi
  800de2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de4:	85 c0                	test   %eax,%eax
  800de6:	7e 17                	jle    800dff <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	50                   	push   %eax
  800dec:	6a 09                	push   $0x9
  800dee:	68 bf 27 80 00       	push   $0x8027bf
  800df3:	6a 23                	push   $0x23
  800df5:	68 dc 27 80 00       	push   $0x8027dc
  800dfa:	e8 3c f4 ff ff       	call   80023b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	89 df                	mov    %ebx,%edi
  800e22:	89 de                	mov    %ebx,%esi
  800e24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7e 17                	jle    800e41 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	83 ec 0c             	sub    $0xc,%esp
  800e2d:	50                   	push   %eax
  800e2e:	6a 0a                	push   $0xa
  800e30:	68 bf 27 80 00       	push   $0x8027bf
  800e35:	6a 23                	push   $0x23
  800e37:	68 dc 27 80 00       	push   $0x8027dc
  800e3c:	e8 fa f3 ff ff       	call   80023b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	be 00 00 00 00       	mov    $0x0,%esi
  800e54:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e65:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
  800e72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e75:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e82:	89 cb                	mov    %ecx,%ebx
  800e84:	89 cf                	mov    %ecx,%edi
  800e86:	89 ce                	mov    %ecx,%esi
  800e88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	7e 17                	jle    800ea5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8e:	83 ec 0c             	sub    $0xc,%esp
  800e91:	50                   	push   %eax
  800e92:	6a 0d                	push   $0xd
  800e94:	68 bf 27 80 00       	push   $0x8027bf
  800e99:	6a 23                	push   $0x23
  800e9b:	68 dc 27 80 00       	push   $0x8027dc
  800ea0:	e8 96 f3 ff ff       	call   80023b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ebd:	89 d1                	mov    %edx,%ecx
  800ebf:	89 d3                	mov    %edx,%ebx
  800ec1:	89 d7                	mov    %edx,%edi
  800ec3:	89 d6                	mov    %edx,%esi
  800ec5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed7:	c1 e8 0c             	shr    $0xc,%eax
}
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eec:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800efe:	89 c2                	mov    %eax,%edx
  800f00:	c1 ea 16             	shr    $0x16,%edx
  800f03:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f0a:	f6 c2 01             	test   $0x1,%dl
  800f0d:	74 11                	je     800f20 <fd_alloc+0x2d>
  800f0f:	89 c2                	mov    %eax,%edx
  800f11:	c1 ea 0c             	shr    $0xc,%edx
  800f14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1b:	f6 c2 01             	test   $0x1,%dl
  800f1e:	75 09                	jne    800f29 <fd_alloc+0x36>
			*fd_store = fd;
  800f20:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
  800f27:	eb 17                	jmp    800f40 <fd_alloc+0x4d>
  800f29:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f2e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f33:	75 c9                	jne    800efe <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f35:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f3b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f48:	83 f8 1f             	cmp    $0x1f,%eax
  800f4b:	77 36                	ja     800f83 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f4d:	c1 e0 0c             	shl    $0xc,%eax
  800f50:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f55:	89 c2                	mov    %eax,%edx
  800f57:	c1 ea 16             	shr    $0x16,%edx
  800f5a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f61:	f6 c2 01             	test   $0x1,%dl
  800f64:	74 24                	je     800f8a <fd_lookup+0x48>
  800f66:	89 c2                	mov    %eax,%edx
  800f68:	c1 ea 0c             	shr    $0xc,%edx
  800f6b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f72:	f6 c2 01             	test   $0x1,%dl
  800f75:	74 1a                	je     800f91 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7a:	89 02                	mov    %eax,(%edx)
	return 0;
  800f7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f81:	eb 13                	jmp    800f96 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f88:	eb 0c                	jmp    800f96 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8f:	eb 05                	jmp    800f96 <fd_lookup+0x54>
  800f91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	83 ec 08             	sub    $0x8,%esp
  800f9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa1:	ba 6c 28 80 00       	mov    $0x80286c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fa6:	eb 13                	jmp    800fbb <dev_lookup+0x23>
  800fa8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fab:	39 08                	cmp    %ecx,(%eax)
  800fad:	75 0c                	jne    800fbb <dev_lookup+0x23>
			*dev = devtab[i];
  800faf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb9:	eb 2e                	jmp    800fe9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fbb:	8b 02                	mov    (%edx),%eax
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	75 e7                	jne    800fa8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fc1:	a1 08 40 80 00       	mov    0x804008,%eax
  800fc6:	8b 40 48             	mov    0x48(%eax),%eax
  800fc9:	83 ec 04             	sub    $0x4,%esp
  800fcc:	51                   	push   %ecx
  800fcd:	50                   	push   %eax
  800fce:	68 ec 27 80 00       	push   $0x8027ec
  800fd3:	e8 3c f3 ff ff       	call   800314 <cprintf>
	*dev = 0;
  800fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
  800ff0:	83 ec 10             	sub    $0x10,%esp
  800ff3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffc:	50                   	push   %eax
  800ffd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801003:	c1 e8 0c             	shr    $0xc,%eax
  801006:	50                   	push   %eax
  801007:	e8 36 ff ff ff       	call   800f42 <fd_lookup>
  80100c:	83 c4 08             	add    $0x8,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 05                	js     801018 <fd_close+0x2d>
	    || fd != fd2)
  801013:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801016:	74 0c                	je     801024 <fd_close+0x39>
		return (must_exist ? r : 0);
  801018:	84 db                	test   %bl,%bl
  80101a:	ba 00 00 00 00       	mov    $0x0,%edx
  80101f:	0f 44 c2             	cmove  %edx,%eax
  801022:	eb 41                	jmp    801065 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801024:	83 ec 08             	sub    $0x8,%esp
  801027:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80102a:	50                   	push   %eax
  80102b:	ff 36                	pushl  (%esi)
  80102d:	e8 66 ff ff ff       	call   800f98 <dev_lookup>
  801032:	89 c3                	mov    %eax,%ebx
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	78 1a                	js     801055 <fd_close+0x6a>
		if (dev->dev_close)
  80103b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801041:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801046:	85 c0                	test   %eax,%eax
  801048:	74 0b                	je     801055 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	56                   	push   %esi
  80104e:	ff d0                	call   *%eax
  801050:	89 c3                	mov    %eax,%ebx
  801052:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801055:	83 ec 08             	sub    $0x8,%esp
  801058:	56                   	push   %esi
  801059:	6a 00                	push   $0x0
  80105b:	e8 e1 fc ff ff       	call   800d41 <sys_page_unmap>
	return r;
  801060:	83 c4 10             	add    $0x10,%esp
  801063:	89 d8                	mov    %ebx,%eax
}
  801065:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801072:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801075:	50                   	push   %eax
  801076:	ff 75 08             	pushl  0x8(%ebp)
  801079:	e8 c4 fe ff ff       	call   800f42 <fd_lookup>
  80107e:	83 c4 08             	add    $0x8,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	78 10                	js     801095 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801085:	83 ec 08             	sub    $0x8,%esp
  801088:	6a 01                	push   $0x1
  80108a:	ff 75 f4             	pushl  -0xc(%ebp)
  80108d:	e8 59 ff ff ff       	call   800feb <fd_close>
  801092:	83 c4 10             	add    $0x10,%esp
}
  801095:	c9                   	leave  
  801096:	c3                   	ret    

00801097 <close_all>:

void
close_all(void)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	53                   	push   %ebx
  80109b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80109e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	53                   	push   %ebx
  8010a7:	e8 c0 ff ff ff       	call   80106c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ac:	83 c3 01             	add    $0x1,%ebx
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	83 fb 20             	cmp    $0x20,%ebx
  8010b5:	75 ec                	jne    8010a3 <close_all+0xc>
		close(i);
}
  8010b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	57                   	push   %edi
  8010c0:	56                   	push   %esi
  8010c1:	53                   	push   %ebx
  8010c2:	83 ec 2c             	sub    $0x2c,%esp
  8010c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010cb:	50                   	push   %eax
  8010cc:	ff 75 08             	pushl  0x8(%ebp)
  8010cf:	e8 6e fe ff ff       	call   800f42 <fd_lookup>
  8010d4:	83 c4 08             	add    $0x8,%esp
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	0f 88 c1 00 00 00    	js     8011a0 <dup+0xe4>
		return r;
	close(newfdnum);
  8010df:	83 ec 0c             	sub    $0xc,%esp
  8010e2:	56                   	push   %esi
  8010e3:	e8 84 ff ff ff       	call   80106c <close>

	newfd = INDEX2FD(newfdnum);
  8010e8:	89 f3                	mov    %esi,%ebx
  8010ea:	c1 e3 0c             	shl    $0xc,%ebx
  8010ed:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010f3:	83 c4 04             	add    $0x4,%esp
  8010f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f9:	e8 de fd ff ff       	call   800edc <fd2data>
  8010fe:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801100:	89 1c 24             	mov    %ebx,(%esp)
  801103:	e8 d4 fd ff ff       	call   800edc <fd2data>
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80110e:	89 f8                	mov    %edi,%eax
  801110:	c1 e8 16             	shr    $0x16,%eax
  801113:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80111a:	a8 01                	test   $0x1,%al
  80111c:	74 37                	je     801155 <dup+0x99>
  80111e:	89 f8                	mov    %edi,%eax
  801120:	c1 e8 0c             	shr    $0xc,%eax
  801123:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80112a:	f6 c2 01             	test   $0x1,%dl
  80112d:	74 26                	je     801155 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80112f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	25 07 0e 00 00       	and    $0xe07,%eax
  80113e:	50                   	push   %eax
  80113f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801142:	6a 00                	push   $0x0
  801144:	57                   	push   %edi
  801145:	6a 00                	push   $0x0
  801147:	e8 b3 fb ff ff       	call   800cff <sys_page_map>
  80114c:	89 c7                	mov    %eax,%edi
  80114e:	83 c4 20             	add    $0x20,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	78 2e                	js     801183 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801155:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801158:	89 d0                	mov    %edx,%eax
  80115a:	c1 e8 0c             	shr    $0xc,%eax
  80115d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801164:	83 ec 0c             	sub    $0xc,%esp
  801167:	25 07 0e 00 00       	and    $0xe07,%eax
  80116c:	50                   	push   %eax
  80116d:	53                   	push   %ebx
  80116e:	6a 00                	push   $0x0
  801170:	52                   	push   %edx
  801171:	6a 00                	push   $0x0
  801173:	e8 87 fb ff ff       	call   800cff <sys_page_map>
  801178:	89 c7                	mov    %eax,%edi
  80117a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80117d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80117f:	85 ff                	test   %edi,%edi
  801181:	79 1d                	jns    8011a0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801183:	83 ec 08             	sub    $0x8,%esp
  801186:	53                   	push   %ebx
  801187:	6a 00                	push   $0x0
  801189:	e8 b3 fb ff ff       	call   800d41 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80118e:	83 c4 08             	add    $0x8,%esp
  801191:	ff 75 d4             	pushl  -0x2c(%ebp)
  801194:	6a 00                	push   $0x0
  801196:	e8 a6 fb ff ff       	call   800d41 <sys_page_unmap>
	return r;
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	89 f8                	mov    %edi,%eax
}
  8011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	53                   	push   %ebx
  8011ac:	83 ec 14             	sub    $0x14,%esp
  8011af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b5:	50                   	push   %eax
  8011b6:	53                   	push   %ebx
  8011b7:	e8 86 fd ff ff       	call   800f42 <fd_lookup>
  8011bc:	83 c4 08             	add    $0x8,%esp
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	78 6d                	js     801232 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c5:	83 ec 08             	sub    $0x8,%esp
  8011c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cf:	ff 30                	pushl  (%eax)
  8011d1:	e8 c2 fd ff ff       	call   800f98 <dev_lookup>
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 4c                	js     801229 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011e0:	8b 42 08             	mov    0x8(%edx),%eax
  8011e3:	83 e0 03             	and    $0x3,%eax
  8011e6:	83 f8 01             	cmp    $0x1,%eax
  8011e9:	75 21                	jne    80120c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011eb:	a1 08 40 80 00       	mov    0x804008,%eax
  8011f0:	8b 40 48             	mov    0x48(%eax),%eax
  8011f3:	83 ec 04             	sub    $0x4,%esp
  8011f6:	53                   	push   %ebx
  8011f7:	50                   	push   %eax
  8011f8:	68 30 28 80 00       	push   $0x802830
  8011fd:	e8 12 f1 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80120a:	eb 26                	jmp    801232 <read+0x8a>
	}
	if (!dev->dev_read)
  80120c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120f:	8b 40 08             	mov    0x8(%eax),%eax
  801212:	85 c0                	test   %eax,%eax
  801214:	74 17                	je     80122d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801216:	83 ec 04             	sub    $0x4,%esp
  801219:	ff 75 10             	pushl  0x10(%ebp)
  80121c:	ff 75 0c             	pushl  0xc(%ebp)
  80121f:	52                   	push   %edx
  801220:	ff d0                	call   *%eax
  801222:	89 c2                	mov    %eax,%edx
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	eb 09                	jmp    801232 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801229:	89 c2                	mov    %eax,%edx
  80122b:	eb 05                	jmp    801232 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80122d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801232:	89 d0                	mov    %edx,%eax
  801234:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801237:	c9                   	leave  
  801238:	c3                   	ret    

00801239 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	57                   	push   %edi
  80123d:	56                   	push   %esi
  80123e:	53                   	push   %ebx
  80123f:	83 ec 0c             	sub    $0xc,%esp
  801242:	8b 7d 08             	mov    0x8(%ebp),%edi
  801245:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801248:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124d:	eb 21                	jmp    801270 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124f:	83 ec 04             	sub    $0x4,%esp
  801252:	89 f0                	mov    %esi,%eax
  801254:	29 d8                	sub    %ebx,%eax
  801256:	50                   	push   %eax
  801257:	89 d8                	mov    %ebx,%eax
  801259:	03 45 0c             	add    0xc(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	57                   	push   %edi
  80125e:	e8 45 ff ff ff       	call   8011a8 <read>
		if (m < 0)
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 10                	js     80127a <readn+0x41>
			return m;
		if (m == 0)
  80126a:	85 c0                	test   %eax,%eax
  80126c:	74 0a                	je     801278 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80126e:	01 c3                	add    %eax,%ebx
  801270:	39 f3                	cmp    %esi,%ebx
  801272:	72 db                	jb     80124f <readn+0x16>
  801274:	89 d8                	mov    %ebx,%eax
  801276:	eb 02                	jmp    80127a <readn+0x41>
  801278:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80127a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127d:	5b                   	pop    %ebx
  80127e:	5e                   	pop    %esi
  80127f:	5f                   	pop    %edi
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	53                   	push   %ebx
  801286:	83 ec 14             	sub    $0x14,%esp
  801289:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	53                   	push   %ebx
  801291:	e8 ac fc ff ff       	call   800f42 <fd_lookup>
  801296:	83 c4 08             	add    $0x8,%esp
  801299:	89 c2                	mov    %eax,%edx
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 68                	js     801307 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a5:	50                   	push   %eax
  8012a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a9:	ff 30                	pushl  (%eax)
  8012ab:	e8 e8 fc ff ff       	call   800f98 <dev_lookup>
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 47                	js     8012fe <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012be:	75 21                	jne    8012e1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012c0:	a1 08 40 80 00       	mov    0x804008,%eax
  8012c5:	8b 40 48             	mov    0x48(%eax),%eax
  8012c8:	83 ec 04             	sub    $0x4,%esp
  8012cb:	53                   	push   %ebx
  8012cc:	50                   	push   %eax
  8012cd:	68 4c 28 80 00       	push   $0x80284c
  8012d2:	e8 3d f0 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012df:	eb 26                	jmp    801307 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e4:	8b 52 0c             	mov    0xc(%edx),%edx
  8012e7:	85 d2                	test   %edx,%edx
  8012e9:	74 17                	je     801302 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012eb:	83 ec 04             	sub    $0x4,%esp
  8012ee:	ff 75 10             	pushl  0x10(%ebp)
  8012f1:	ff 75 0c             	pushl  0xc(%ebp)
  8012f4:	50                   	push   %eax
  8012f5:	ff d2                	call   *%edx
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	eb 09                	jmp    801307 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	eb 05                	jmp    801307 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801302:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801307:	89 d0                	mov    %edx,%eax
  801309:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130c:	c9                   	leave  
  80130d:	c3                   	ret    

0080130e <seek>:

int
seek(int fdnum, off_t offset)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801314:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801317:	50                   	push   %eax
  801318:	ff 75 08             	pushl  0x8(%ebp)
  80131b:	e8 22 fc ff ff       	call   800f42 <fd_lookup>
  801320:	83 c4 08             	add    $0x8,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	78 0e                	js     801335 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801327:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80132a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801330:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	53                   	push   %ebx
  80133b:	83 ec 14             	sub    $0x14,%esp
  80133e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801341:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801344:	50                   	push   %eax
  801345:	53                   	push   %ebx
  801346:	e8 f7 fb ff ff       	call   800f42 <fd_lookup>
  80134b:	83 c4 08             	add    $0x8,%esp
  80134e:	89 c2                	mov    %eax,%edx
  801350:	85 c0                	test   %eax,%eax
  801352:	78 65                	js     8013b9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801354:	83 ec 08             	sub    $0x8,%esp
  801357:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135a:	50                   	push   %eax
  80135b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135e:	ff 30                	pushl  (%eax)
  801360:	e8 33 fc ff ff       	call   800f98 <dev_lookup>
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 44                	js     8013b0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80136c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801373:	75 21                	jne    801396 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801375:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80137a:	8b 40 48             	mov    0x48(%eax),%eax
  80137d:	83 ec 04             	sub    $0x4,%esp
  801380:	53                   	push   %ebx
  801381:	50                   	push   %eax
  801382:	68 0c 28 80 00       	push   $0x80280c
  801387:	e8 88 ef ff ff       	call   800314 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801394:	eb 23                	jmp    8013b9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801396:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801399:	8b 52 18             	mov    0x18(%edx),%edx
  80139c:	85 d2                	test   %edx,%edx
  80139e:	74 14                	je     8013b4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	ff 75 0c             	pushl  0xc(%ebp)
  8013a6:	50                   	push   %eax
  8013a7:	ff d2                	call   *%edx
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	eb 09                	jmp    8013b9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b0:	89 c2                	mov    %eax,%edx
  8013b2:	eb 05                	jmp    8013b9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013b9:	89 d0                	mov    %edx,%eax
  8013bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013be:	c9                   	leave  
  8013bf:	c3                   	ret    

008013c0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 14             	sub    $0x14,%esp
  8013c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cd:	50                   	push   %eax
  8013ce:	ff 75 08             	pushl  0x8(%ebp)
  8013d1:	e8 6c fb ff ff       	call   800f42 <fd_lookup>
  8013d6:	83 c4 08             	add    $0x8,%esp
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 58                	js     801437 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e5:	50                   	push   %eax
  8013e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e9:	ff 30                	pushl  (%eax)
  8013eb:	e8 a8 fb ff ff       	call   800f98 <dev_lookup>
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 37                	js     80142e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013fe:	74 32                	je     801432 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801400:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801403:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80140a:	00 00 00 
	stat->st_isdir = 0;
  80140d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801414:	00 00 00 
	stat->st_dev = dev;
  801417:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	53                   	push   %ebx
  801421:	ff 75 f0             	pushl  -0x10(%ebp)
  801424:	ff 50 14             	call   *0x14(%eax)
  801427:	89 c2                	mov    %eax,%edx
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	eb 09                	jmp    801437 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142e:	89 c2                	mov    %eax,%edx
  801430:	eb 05                	jmp    801437 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801432:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801437:	89 d0                	mov    %edx,%eax
  801439:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	56                   	push   %esi
  801442:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	6a 00                	push   $0x0
  801448:	ff 75 08             	pushl  0x8(%ebp)
  80144b:	e8 ef 01 00 00       	call   80163f <open>
  801450:	89 c3                	mov    %eax,%ebx
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	85 c0                	test   %eax,%eax
  801457:	78 1b                	js     801474 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	ff 75 0c             	pushl  0xc(%ebp)
  80145f:	50                   	push   %eax
  801460:	e8 5b ff ff ff       	call   8013c0 <fstat>
  801465:	89 c6                	mov    %eax,%esi
	close(fd);
  801467:	89 1c 24             	mov    %ebx,(%esp)
  80146a:	e8 fd fb ff ff       	call   80106c <close>
	return r;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	89 f0                	mov    %esi,%eax
}
  801474:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	56                   	push   %esi
  80147f:	53                   	push   %ebx
  801480:	89 c6                	mov    %eax,%esi
  801482:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801484:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80148b:	75 12                	jne    80149f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	6a 01                	push   $0x1
  801492:	e8 57 0c 00 00       	call   8020ee <ipc_find_env>
  801497:	a3 00 40 80 00       	mov    %eax,0x804000
  80149c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80149f:	6a 07                	push   $0x7
  8014a1:	68 00 50 80 00       	push   $0x805000
  8014a6:	56                   	push   %esi
  8014a7:	ff 35 00 40 80 00    	pushl  0x804000
  8014ad:	e8 ed 0b 00 00       	call   80209f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014b2:	83 c4 0c             	add    $0xc,%esp
  8014b5:	6a 00                	push   $0x0
  8014b7:	53                   	push   %ebx
  8014b8:	6a 00                	push   $0x0
  8014ba:	e8 6a 0b 00 00       	call   802029 <ipc_recv>
}
  8014bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c2:	5b                   	pop    %ebx
  8014c3:	5e                   	pop    %esi
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    

008014c6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014da:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014df:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e4:	b8 02 00 00 00       	mov    $0x2,%eax
  8014e9:	e8 8d ff ff ff       	call   80147b <fsipc>
}
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801501:	ba 00 00 00 00       	mov    $0x0,%edx
  801506:	b8 06 00 00 00       	mov    $0x6,%eax
  80150b:	e8 6b ff ff ff       	call   80147b <fsipc>
}
  801510:	c9                   	leave  
  801511:	c3                   	ret    

00801512 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	53                   	push   %ebx
  801516:	83 ec 04             	sub    $0x4,%esp
  801519:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80151c:	8b 45 08             	mov    0x8(%ebp),%eax
  80151f:	8b 40 0c             	mov    0xc(%eax),%eax
  801522:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801527:	ba 00 00 00 00       	mov    $0x0,%edx
  80152c:	b8 05 00 00 00       	mov    $0x5,%eax
  801531:	e8 45 ff ff ff       	call   80147b <fsipc>
  801536:	85 c0                	test   %eax,%eax
  801538:	78 2c                	js     801566 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	68 00 50 80 00       	push   $0x805000
  801542:	53                   	push   %ebx
  801543:	e8 71 f3 ff ff       	call   8008b9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801548:	a1 80 50 80 00       	mov    0x805080,%eax
  80154d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801553:	a1 84 50 80 00       	mov    0x805084,%eax
  801558:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801575:	8b 55 08             	mov    0x8(%ebp),%edx
  801578:	8b 52 0c             	mov    0xc(%edx),%edx
  80157b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801581:	a3 04 50 80 00       	mov    %eax,0x805004
  801586:	3d 08 50 80 00       	cmp    $0x805008,%eax
  80158b:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801590:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801593:	53                   	push   %ebx
  801594:	ff 75 0c             	pushl  0xc(%ebp)
  801597:	68 08 50 80 00       	push   $0x805008
  80159c:	e8 aa f4 ff ff       	call   800a4b <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8015a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a6:	b8 04 00 00 00       	mov    $0x4,%eax
  8015ab:	e8 cb fe ff ff       	call   80147b <fsipc>
  8015b0:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8015b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	56                   	push   %esi
  8015c1:	53                   	push   %ebx
  8015c2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8015cb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015d0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015db:	b8 03 00 00 00       	mov    $0x3,%eax
  8015e0:	e8 96 fe ff ff       	call   80147b <fsipc>
  8015e5:	89 c3                	mov    %eax,%ebx
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 4b                	js     801636 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015eb:	39 c6                	cmp    %eax,%esi
  8015ed:	73 16                	jae    801605 <devfile_read+0x48>
  8015ef:	68 80 28 80 00       	push   $0x802880
  8015f4:	68 87 28 80 00       	push   $0x802887
  8015f9:	6a 7c                	push   $0x7c
  8015fb:	68 9c 28 80 00       	push   $0x80289c
  801600:	e8 36 ec ff ff       	call   80023b <_panic>
	assert(r <= PGSIZE);
  801605:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80160a:	7e 16                	jle    801622 <devfile_read+0x65>
  80160c:	68 a7 28 80 00       	push   $0x8028a7
  801611:	68 87 28 80 00       	push   $0x802887
  801616:	6a 7d                	push   $0x7d
  801618:	68 9c 28 80 00       	push   $0x80289c
  80161d:	e8 19 ec ff ff       	call   80023b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801622:	83 ec 04             	sub    $0x4,%esp
  801625:	50                   	push   %eax
  801626:	68 00 50 80 00       	push   $0x805000
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	e8 18 f4 ff ff       	call   800a4b <memmove>
	return r;
  801633:	83 c4 10             	add    $0x10,%esp
}
  801636:	89 d8                	mov    %ebx,%eax
  801638:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	83 ec 20             	sub    $0x20,%esp
  801646:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801649:	53                   	push   %ebx
  80164a:	e8 31 f2 ff ff       	call   800880 <strlen>
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801657:	7f 67                	jg     8016c0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801659:	83 ec 0c             	sub    $0xc,%esp
  80165c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165f:	50                   	push   %eax
  801660:	e8 8e f8 ff ff       	call   800ef3 <fd_alloc>
  801665:	83 c4 10             	add    $0x10,%esp
		return r;
  801668:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 57                	js     8016c5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	53                   	push   %ebx
  801672:	68 00 50 80 00       	push   $0x805000
  801677:	e8 3d f2 ff ff       	call   8008b9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80167c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801684:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801687:	b8 01 00 00 00       	mov    $0x1,%eax
  80168c:	e8 ea fd ff ff       	call   80147b <fsipc>
  801691:	89 c3                	mov    %eax,%ebx
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	85 c0                	test   %eax,%eax
  801698:	79 14                	jns    8016ae <open+0x6f>
		fd_close(fd, 0);
  80169a:	83 ec 08             	sub    $0x8,%esp
  80169d:	6a 00                	push   $0x0
  80169f:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a2:	e8 44 f9 ff ff       	call   800feb <fd_close>
		return r;
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	89 da                	mov    %ebx,%edx
  8016ac:	eb 17                	jmp    8016c5 <open+0x86>
	}

	return fd2num(fd);
  8016ae:	83 ec 0c             	sub    $0xc,%esp
  8016b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b4:	e8 13 f8 ff ff       	call   800ecc <fd2num>
  8016b9:	89 c2                	mov    %eax,%edx
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	eb 05                	jmp    8016c5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016c0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016c5:	89 d0                	mov    %edx,%eax
  8016c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d7:	b8 08 00 00 00       	mov    $0x8,%eax
  8016dc:	e8 9a fd ff ff       	call   80147b <fsipc>
}
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
  8016e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016eb:	83 ec 0c             	sub    $0xc,%esp
  8016ee:	ff 75 08             	pushl  0x8(%ebp)
  8016f1:	e8 e6 f7 ff ff       	call   800edc <fd2data>
  8016f6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016f8:	83 c4 08             	add    $0x8,%esp
  8016fb:	68 b3 28 80 00       	push   $0x8028b3
  801700:	53                   	push   %ebx
  801701:	e8 b3 f1 ff ff       	call   8008b9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801706:	8b 46 04             	mov    0x4(%esi),%eax
  801709:	2b 06                	sub    (%esi),%eax
  80170b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801711:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801718:	00 00 00 
	stat->st_dev = &devpipe;
  80171b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801722:	30 80 00 
	return 0;
}
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
  80172a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	53                   	push   %ebx
  801735:	83 ec 0c             	sub    $0xc,%esp
  801738:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80173b:	53                   	push   %ebx
  80173c:	6a 00                	push   $0x0
  80173e:	e8 fe f5 ff ff       	call   800d41 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801743:	89 1c 24             	mov    %ebx,(%esp)
  801746:	e8 91 f7 ff ff       	call   800edc <fd2data>
  80174b:	83 c4 08             	add    $0x8,%esp
  80174e:	50                   	push   %eax
  80174f:	6a 00                	push   $0x0
  801751:	e8 eb f5 ff ff       	call   800d41 <sys_page_unmap>
}
  801756:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	57                   	push   %edi
  80175f:	56                   	push   %esi
  801760:	53                   	push   %ebx
  801761:	83 ec 1c             	sub    $0x1c,%esp
  801764:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801767:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801769:	a1 08 40 80 00       	mov    0x804008,%eax
  80176e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801771:	83 ec 0c             	sub    $0xc,%esp
  801774:	ff 75 e0             	pushl  -0x20(%ebp)
  801777:	e8 ab 09 00 00       	call   802127 <pageref>
  80177c:	89 c3                	mov    %eax,%ebx
  80177e:	89 3c 24             	mov    %edi,(%esp)
  801781:	e8 a1 09 00 00       	call   802127 <pageref>
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	39 c3                	cmp    %eax,%ebx
  80178b:	0f 94 c1             	sete   %cl
  80178e:	0f b6 c9             	movzbl %cl,%ecx
  801791:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801794:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80179a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80179d:	39 ce                	cmp    %ecx,%esi
  80179f:	74 1b                	je     8017bc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8017a1:	39 c3                	cmp    %eax,%ebx
  8017a3:	75 c4                	jne    801769 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017a5:	8b 42 58             	mov    0x58(%edx),%eax
  8017a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017ab:	50                   	push   %eax
  8017ac:	56                   	push   %esi
  8017ad:	68 ba 28 80 00       	push   $0x8028ba
  8017b2:	e8 5d eb ff ff       	call   800314 <cprintf>
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	eb ad                	jmp    801769 <_pipeisclosed+0xe>
	}
}
  8017bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	5f                   	pop    %edi
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	57                   	push   %edi
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 28             	sub    $0x28,%esp
  8017d0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017d3:	56                   	push   %esi
  8017d4:	e8 03 f7 ff ff       	call   800edc <fd2data>
  8017d9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	bf 00 00 00 00       	mov    $0x0,%edi
  8017e3:	eb 4b                	jmp    801830 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017e5:	89 da                	mov    %ebx,%edx
  8017e7:	89 f0                	mov    %esi,%eax
  8017e9:	e8 6d ff ff ff       	call   80175b <_pipeisclosed>
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	75 48                	jne    80183a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017f2:	e8 a6 f4 ff ff       	call   800c9d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017f7:	8b 43 04             	mov    0x4(%ebx),%eax
  8017fa:	8b 0b                	mov    (%ebx),%ecx
  8017fc:	8d 51 20             	lea    0x20(%ecx),%edx
  8017ff:	39 d0                	cmp    %edx,%eax
  801801:	73 e2                	jae    8017e5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801803:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801806:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80180a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80180d:	89 c2                	mov    %eax,%edx
  80180f:	c1 fa 1f             	sar    $0x1f,%edx
  801812:	89 d1                	mov    %edx,%ecx
  801814:	c1 e9 1b             	shr    $0x1b,%ecx
  801817:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80181a:	83 e2 1f             	and    $0x1f,%edx
  80181d:	29 ca                	sub    %ecx,%edx
  80181f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801823:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801827:	83 c0 01             	add    $0x1,%eax
  80182a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80182d:	83 c7 01             	add    $0x1,%edi
  801830:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801833:	75 c2                	jne    8017f7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801835:	8b 45 10             	mov    0x10(%ebp),%eax
  801838:	eb 05                	jmp    80183f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80183a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80183f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5f                   	pop    %edi
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	57                   	push   %edi
  80184b:	56                   	push   %esi
  80184c:	53                   	push   %ebx
  80184d:	83 ec 18             	sub    $0x18,%esp
  801850:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801853:	57                   	push   %edi
  801854:	e8 83 f6 ff ff       	call   800edc <fd2data>
  801859:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801863:	eb 3d                	jmp    8018a2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801865:	85 db                	test   %ebx,%ebx
  801867:	74 04                	je     80186d <devpipe_read+0x26>
				return i;
  801869:	89 d8                	mov    %ebx,%eax
  80186b:	eb 44                	jmp    8018b1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80186d:	89 f2                	mov    %esi,%edx
  80186f:	89 f8                	mov    %edi,%eax
  801871:	e8 e5 fe ff ff       	call   80175b <_pipeisclosed>
  801876:	85 c0                	test   %eax,%eax
  801878:	75 32                	jne    8018ac <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80187a:	e8 1e f4 ff ff       	call   800c9d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80187f:	8b 06                	mov    (%esi),%eax
  801881:	3b 46 04             	cmp    0x4(%esi),%eax
  801884:	74 df                	je     801865 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801886:	99                   	cltd   
  801887:	c1 ea 1b             	shr    $0x1b,%edx
  80188a:	01 d0                	add    %edx,%eax
  80188c:	83 e0 1f             	and    $0x1f,%eax
  80188f:	29 d0                	sub    %edx,%eax
  801891:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801896:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801899:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80189c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80189f:	83 c3 01             	add    $0x1,%ebx
  8018a2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018a5:	75 d8                	jne    80187f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8018aa:	eb 05                	jmp    8018b1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018ac:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b4:	5b                   	pop    %ebx
  8018b5:	5e                   	pop    %esi
  8018b6:	5f                   	pop    %edi
  8018b7:	5d                   	pop    %ebp
  8018b8:	c3                   	ret    

008018b9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	56                   	push   %esi
  8018bd:	53                   	push   %ebx
  8018be:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c4:	50                   	push   %eax
  8018c5:	e8 29 f6 ff ff       	call   800ef3 <fd_alloc>
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	89 c2                	mov    %eax,%edx
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	0f 88 2c 01 00 00    	js     801a03 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d7:	83 ec 04             	sub    $0x4,%esp
  8018da:	68 07 04 00 00       	push   $0x407
  8018df:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e2:	6a 00                	push   $0x0
  8018e4:	e8 d3 f3 ff ff       	call   800cbc <sys_page_alloc>
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	89 c2                	mov    %eax,%edx
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	0f 88 0d 01 00 00    	js     801a03 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018f6:	83 ec 0c             	sub    $0xc,%esp
  8018f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018fc:	50                   	push   %eax
  8018fd:	e8 f1 f5 ff ff       	call   800ef3 <fd_alloc>
  801902:	89 c3                	mov    %eax,%ebx
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	0f 88 e2 00 00 00    	js     8019f1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80190f:	83 ec 04             	sub    $0x4,%esp
  801912:	68 07 04 00 00       	push   $0x407
  801917:	ff 75 f0             	pushl  -0x10(%ebp)
  80191a:	6a 00                	push   $0x0
  80191c:	e8 9b f3 ff ff       	call   800cbc <sys_page_alloc>
  801921:	89 c3                	mov    %eax,%ebx
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	85 c0                	test   %eax,%eax
  801928:	0f 88 c3 00 00 00    	js     8019f1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80192e:	83 ec 0c             	sub    $0xc,%esp
  801931:	ff 75 f4             	pushl  -0xc(%ebp)
  801934:	e8 a3 f5 ff ff       	call   800edc <fd2data>
  801939:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80193b:	83 c4 0c             	add    $0xc,%esp
  80193e:	68 07 04 00 00       	push   $0x407
  801943:	50                   	push   %eax
  801944:	6a 00                	push   $0x0
  801946:	e8 71 f3 ff ff       	call   800cbc <sys_page_alloc>
  80194b:	89 c3                	mov    %eax,%ebx
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	85 c0                	test   %eax,%eax
  801952:	0f 88 89 00 00 00    	js     8019e1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	ff 75 f0             	pushl  -0x10(%ebp)
  80195e:	e8 79 f5 ff ff       	call   800edc <fd2data>
  801963:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80196a:	50                   	push   %eax
  80196b:	6a 00                	push   $0x0
  80196d:	56                   	push   %esi
  80196e:	6a 00                	push   $0x0
  801970:	e8 8a f3 ff ff       	call   800cff <sys_page_map>
  801975:	89 c3                	mov    %eax,%ebx
  801977:	83 c4 20             	add    $0x20,%esp
  80197a:	85 c0                	test   %eax,%eax
  80197c:	78 55                	js     8019d3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80197e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801984:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801987:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801989:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801993:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801999:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80199e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019a8:	83 ec 0c             	sub    $0xc,%esp
  8019ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ae:	e8 19 f5 ff ff       	call   800ecc <fd2num>
  8019b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019b6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019b8:	83 c4 04             	add    $0x4,%esp
  8019bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8019be:	e8 09 f5 ff ff       	call   800ecc <fd2num>
  8019c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019c6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019c9:	83 c4 10             	add    $0x10,%esp
  8019cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d1:	eb 30                	jmp    801a03 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8019d3:	83 ec 08             	sub    $0x8,%esp
  8019d6:	56                   	push   %esi
  8019d7:	6a 00                	push   $0x0
  8019d9:	e8 63 f3 ff ff       	call   800d41 <sys_page_unmap>
  8019de:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8019e7:	6a 00                	push   $0x0
  8019e9:	e8 53 f3 ff ff       	call   800d41 <sys_page_unmap>
  8019ee:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019f1:	83 ec 08             	sub    $0x8,%esp
  8019f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f7:	6a 00                	push   $0x0
  8019f9:	e8 43 f3 ff ff       	call   800d41 <sys_page_unmap>
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a03:	89 d0                	mov    %edx,%eax
  801a05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a08:	5b                   	pop    %ebx
  801a09:	5e                   	pop    %esi
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a15:	50                   	push   %eax
  801a16:	ff 75 08             	pushl  0x8(%ebp)
  801a19:	e8 24 f5 ff ff       	call   800f42 <fd_lookup>
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	85 c0                	test   %eax,%eax
  801a23:	78 18                	js     801a3d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a25:	83 ec 0c             	sub    $0xc,%esp
  801a28:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2b:	e8 ac f4 ff ff       	call   800edc <fd2data>
	return _pipeisclosed(fd, p);
  801a30:	89 c2                	mov    %eax,%edx
  801a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a35:	e8 21 fd ff ff       	call   80175b <_pipeisclosed>
  801a3a:	83 c4 10             	add    $0x10,%esp
}
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a45:	68 d2 28 80 00       	push   $0x8028d2
  801a4a:	ff 75 0c             	pushl  0xc(%ebp)
  801a4d:	e8 67 ee ff ff       	call   8008b9 <strcpy>
	return 0;
}
  801a52:	b8 00 00 00 00       	mov    $0x0,%eax
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	53                   	push   %ebx
  801a5d:	83 ec 10             	sub    $0x10,%esp
  801a60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a63:	53                   	push   %ebx
  801a64:	e8 be 06 00 00       	call   802127 <pageref>
  801a69:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a6c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a71:	83 f8 01             	cmp    $0x1,%eax
  801a74:	75 10                	jne    801a86 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a76:	83 ec 0c             	sub    $0xc,%esp
  801a79:	ff 73 0c             	pushl  0xc(%ebx)
  801a7c:	e8 c0 02 00 00       	call   801d41 <nsipc_close>
  801a81:	89 c2                	mov    %eax,%edx
  801a83:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a86:	89 d0                	mov    %edx,%eax
  801a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a93:	6a 00                	push   $0x0
  801a95:	ff 75 10             	pushl  0x10(%ebp)
  801a98:	ff 75 0c             	pushl  0xc(%ebp)
  801a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9e:	ff 70 0c             	pushl  0xc(%eax)
  801aa1:	e8 78 03 00 00       	call   801e1e <nsipc_send>
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801aae:	6a 00                	push   $0x0
  801ab0:	ff 75 10             	pushl  0x10(%ebp)
  801ab3:	ff 75 0c             	pushl  0xc(%ebp)
  801ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab9:	ff 70 0c             	pushl  0xc(%eax)
  801abc:	e8 f1 02 00 00       	call   801db2 <nsipc_recv>
}
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ac9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801acc:	52                   	push   %edx
  801acd:	50                   	push   %eax
  801ace:	e8 6f f4 ff ff       	call   800f42 <fd_lookup>
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 17                	js     801af1 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801add:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801ae3:	39 08                	cmp    %ecx,(%eax)
  801ae5:	75 05                	jne    801aec <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ae7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aea:	eb 05                	jmp    801af1 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801aec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	56                   	push   %esi
  801af7:	53                   	push   %ebx
  801af8:	83 ec 1c             	sub    $0x1c,%esp
  801afb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801afd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b00:	50                   	push   %eax
  801b01:	e8 ed f3 ff ff       	call   800ef3 <fd_alloc>
  801b06:	89 c3                	mov    %eax,%ebx
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 1b                	js     801b2a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b0f:	83 ec 04             	sub    $0x4,%esp
  801b12:	68 07 04 00 00       	push   $0x407
  801b17:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1a:	6a 00                	push   $0x0
  801b1c:	e8 9b f1 ff ff       	call   800cbc <sys_page_alloc>
  801b21:	89 c3                	mov    %eax,%ebx
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	85 c0                	test   %eax,%eax
  801b28:	79 10                	jns    801b3a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	56                   	push   %esi
  801b2e:	e8 0e 02 00 00       	call   801d41 <nsipc_close>
		return r;
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	89 d8                	mov    %ebx,%eax
  801b38:	eb 24                	jmp    801b5e <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b3a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b43:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b48:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b4f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b52:	83 ec 0c             	sub    $0xc,%esp
  801b55:	50                   	push   %eax
  801b56:	e8 71 f3 ff ff       	call   800ecc <fd2num>
  801b5b:	83 c4 10             	add    $0x10,%esp
}
  801b5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6e:	e8 50 ff ff ff       	call   801ac3 <fd2sockid>
		return r;
  801b73:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b75:	85 c0                	test   %eax,%eax
  801b77:	78 1f                	js     801b98 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b79:	83 ec 04             	sub    $0x4,%esp
  801b7c:	ff 75 10             	pushl  0x10(%ebp)
  801b7f:	ff 75 0c             	pushl  0xc(%ebp)
  801b82:	50                   	push   %eax
  801b83:	e8 12 01 00 00       	call   801c9a <nsipc_accept>
  801b88:	83 c4 10             	add    $0x10,%esp
		return r;
  801b8b:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	78 07                	js     801b98 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b91:	e8 5d ff ff ff       	call   801af3 <alloc_sockfd>
  801b96:	89 c1                	mov    %eax,%ecx
}
  801b98:	89 c8                	mov    %ecx,%eax
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba5:	e8 19 ff ff ff       	call   801ac3 <fd2sockid>
  801baa:	85 c0                	test   %eax,%eax
  801bac:	78 12                	js     801bc0 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801bae:	83 ec 04             	sub    $0x4,%esp
  801bb1:	ff 75 10             	pushl  0x10(%ebp)
  801bb4:	ff 75 0c             	pushl  0xc(%ebp)
  801bb7:	50                   	push   %eax
  801bb8:	e8 2d 01 00 00       	call   801cea <nsipc_bind>
  801bbd:	83 c4 10             	add    $0x10,%esp
}
  801bc0:	c9                   	leave  
  801bc1:	c3                   	ret    

00801bc2 <shutdown>:

int
shutdown(int s, int how)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcb:	e8 f3 fe ff ff       	call   801ac3 <fd2sockid>
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	78 0f                	js     801be3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801bd4:	83 ec 08             	sub    $0x8,%esp
  801bd7:	ff 75 0c             	pushl  0xc(%ebp)
  801bda:	50                   	push   %eax
  801bdb:	e8 3f 01 00 00       	call   801d1f <nsipc_shutdown>
  801be0:	83 c4 10             	add    $0x10,%esp
}
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    

00801be5 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bee:	e8 d0 fe ff ff       	call   801ac3 <fd2sockid>
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	78 12                	js     801c09 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801bf7:	83 ec 04             	sub    $0x4,%esp
  801bfa:	ff 75 10             	pushl  0x10(%ebp)
  801bfd:	ff 75 0c             	pushl  0xc(%ebp)
  801c00:	50                   	push   %eax
  801c01:	e8 55 01 00 00       	call   801d5b <nsipc_connect>
  801c06:	83 c4 10             	add    $0x10,%esp
}
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    

00801c0b <listen>:

int
listen(int s, int backlog)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c11:	8b 45 08             	mov    0x8(%ebp),%eax
  801c14:	e8 aa fe ff ff       	call   801ac3 <fd2sockid>
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	78 0f                	js     801c2c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c1d:	83 ec 08             	sub    $0x8,%esp
  801c20:	ff 75 0c             	pushl  0xc(%ebp)
  801c23:	50                   	push   %eax
  801c24:	e8 67 01 00 00       	call   801d90 <nsipc_listen>
  801c29:	83 c4 10             	add    $0x10,%esp
}
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    

00801c2e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c34:	ff 75 10             	pushl  0x10(%ebp)
  801c37:	ff 75 0c             	pushl  0xc(%ebp)
  801c3a:	ff 75 08             	pushl  0x8(%ebp)
  801c3d:	e8 3a 02 00 00       	call   801e7c <nsipc_socket>
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 05                	js     801c4e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c49:	e8 a5 fe ff ff       	call   801af3 <alloc_sockfd>
}
  801c4e:	c9                   	leave  
  801c4f:	c3                   	ret    

00801c50 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	53                   	push   %ebx
  801c54:	83 ec 04             	sub    $0x4,%esp
  801c57:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c59:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c60:	75 12                	jne    801c74 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c62:	83 ec 0c             	sub    $0xc,%esp
  801c65:	6a 02                	push   $0x2
  801c67:	e8 82 04 00 00       	call   8020ee <ipc_find_env>
  801c6c:	a3 04 40 80 00       	mov    %eax,0x804004
  801c71:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c74:	6a 07                	push   $0x7
  801c76:	68 00 60 80 00       	push   $0x806000
  801c7b:	53                   	push   %ebx
  801c7c:	ff 35 04 40 80 00    	pushl  0x804004
  801c82:	e8 18 04 00 00       	call   80209f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c87:	83 c4 0c             	add    $0xc,%esp
  801c8a:	6a 00                	push   $0x0
  801c8c:	6a 00                	push   $0x0
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 94 03 00 00       	call   802029 <ipc_recv>
}
  801c95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c98:	c9                   	leave  
  801c99:	c3                   	ret    

00801c9a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
  801c9d:	56                   	push   %esi
  801c9e:	53                   	push   %ebx
  801c9f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801caa:	8b 06                	mov    (%esi),%eax
  801cac:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb6:	e8 95 ff ff ff       	call   801c50 <nsipc>
  801cbb:	89 c3                	mov    %eax,%ebx
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	78 20                	js     801ce1 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cc1:	83 ec 04             	sub    $0x4,%esp
  801cc4:	ff 35 10 60 80 00    	pushl  0x806010
  801cca:	68 00 60 80 00       	push   $0x806000
  801ccf:	ff 75 0c             	pushl  0xc(%ebp)
  801cd2:	e8 74 ed ff ff       	call   800a4b <memmove>
		*addrlen = ret->ret_addrlen;
  801cd7:	a1 10 60 80 00       	mov    0x806010,%eax
  801cdc:	89 06                	mov    %eax,(%esi)
  801cde:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ce1:	89 d8                	mov    %ebx,%eax
  801ce3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce6:	5b                   	pop    %ebx
  801ce7:	5e                   	pop    %esi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    

00801cea <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	53                   	push   %ebx
  801cee:	83 ec 08             	sub    $0x8,%esp
  801cf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cfc:	53                   	push   %ebx
  801cfd:	ff 75 0c             	pushl  0xc(%ebp)
  801d00:	68 04 60 80 00       	push   $0x806004
  801d05:	e8 41 ed ff ff       	call   800a4b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d0a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d10:	b8 02 00 00 00       	mov    $0x2,%eax
  801d15:	e8 36 ff ff ff       	call   801c50 <nsipc>
}
  801d1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1d:	c9                   	leave  
  801d1e:	c3                   	ret    

00801d1f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d25:	8b 45 08             	mov    0x8(%ebp),%eax
  801d28:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d30:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d35:	b8 03 00 00 00       	mov    $0x3,%eax
  801d3a:	e8 11 ff ff ff       	call   801c50 <nsipc>
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <nsipc_close>:

int
nsipc_close(int s)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d4f:	b8 04 00 00 00       	mov    $0x4,%eax
  801d54:	e8 f7 fe ff ff       	call   801c50 <nsipc>
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	53                   	push   %ebx
  801d5f:	83 ec 08             	sub    $0x8,%esp
  801d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d65:	8b 45 08             	mov    0x8(%ebp),%eax
  801d68:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d6d:	53                   	push   %ebx
  801d6e:	ff 75 0c             	pushl  0xc(%ebp)
  801d71:	68 04 60 80 00       	push   $0x806004
  801d76:	e8 d0 ec ff ff       	call   800a4b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d7b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d81:	b8 05 00 00 00       	mov    $0x5,%eax
  801d86:	e8 c5 fe ff ff       	call   801c50 <nsipc>
}
  801d8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d96:	8b 45 08             	mov    0x8(%ebp),%eax
  801d99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801da6:	b8 06 00 00 00       	mov    $0x6,%eax
  801dab:	e8 a0 fe ff ff       	call   801c50 <nsipc>
}
  801db0:	c9                   	leave  
  801db1:	c3                   	ret    

00801db2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	56                   	push   %esi
  801db6:	53                   	push   %ebx
  801db7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dba:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dc2:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dc8:	8b 45 14             	mov    0x14(%ebp),%eax
  801dcb:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dd0:	b8 07 00 00 00       	mov    $0x7,%eax
  801dd5:	e8 76 fe ff ff       	call   801c50 <nsipc>
  801dda:	89 c3                	mov    %eax,%ebx
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 35                	js     801e15 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801de0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801de5:	7f 04                	jg     801deb <nsipc_recv+0x39>
  801de7:	39 c6                	cmp    %eax,%esi
  801de9:	7d 16                	jge    801e01 <nsipc_recv+0x4f>
  801deb:	68 de 28 80 00       	push   $0x8028de
  801df0:	68 87 28 80 00       	push   $0x802887
  801df5:	6a 62                	push   $0x62
  801df7:	68 f3 28 80 00       	push   $0x8028f3
  801dfc:	e8 3a e4 ff ff       	call   80023b <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e01:	83 ec 04             	sub    $0x4,%esp
  801e04:	50                   	push   %eax
  801e05:	68 00 60 80 00       	push   $0x806000
  801e0a:	ff 75 0c             	pushl  0xc(%ebp)
  801e0d:	e8 39 ec ff ff       	call   800a4b <memmove>
  801e12:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e15:	89 d8                	mov    %ebx,%eax
  801e17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e1a:	5b                   	pop    %ebx
  801e1b:	5e                   	pop    %esi
  801e1c:	5d                   	pop    %ebp
  801e1d:	c3                   	ret    

00801e1e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	53                   	push   %ebx
  801e22:	83 ec 04             	sub    $0x4,%esp
  801e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e28:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e30:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e36:	7e 16                	jle    801e4e <nsipc_send+0x30>
  801e38:	68 ff 28 80 00       	push   $0x8028ff
  801e3d:	68 87 28 80 00       	push   $0x802887
  801e42:	6a 6d                	push   $0x6d
  801e44:	68 f3 28 80 00       	push   $0x8028f3
  801e49:	e8 ed e3 ff ff       	call   80023b <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e4e:	83 ec 04             	sub    $0x4,%esp
  801e51:	53                   	push   %ebx
  801e52:	ff 75 0c             	pushl  0xc(%ebp)
  801e55:	68 0c 60 80 00       	push   $0x80600c
  801e5a:	e8 ec eb ff ff       	call   800a4b <memmove>
	nsipcbuf.send.req_size = size;
  801e5f:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e65:	8b 45 14             	mov    0x14(%ebp),%eax
  801e68:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e6d:	b8 08 00 00 00       	mov    $0x8,%eax
  801e72:	e8 d9 fd ff ff       	call   801c50 <nsipc>
}
  801e77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e82:	8b 45 08             	mov    0x8(%ebp),%eax
  801e85:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8d:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e92:	8b 45 10             	mov    0x10(%ebp),%eax
  801e95:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e9a:	b8 09 00 00 00       	mov    $0x9,%eax
  801e9f:	e8 ac fd ff ff       	call   801c50 <nsipc>
}
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  801eae:	5d                   	pop    %ebp
  801eaf:	c3                   	ret    

00801eb0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eb6:	68 0b 29 80 00       	push   $0x80290b
  801ebb:	ff 75 0c             	pushl  0xc(%ebp)
  801ebe:	e8 f6 e9 ff ff       	call   8008b9 <strcpy>
	return 0;
}
  801ec3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec8:	c9                   	leave  
  801ec9:	c3                   	ret    

00801eca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	57                   	push   %edi
  801ece:	56                   	push   %esi
  801ecf:	53                   	push   %ebx
  801ed0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801edb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee1:	eb 2d                	jmp    801f10 <devcons_write+0x46>
		m = n - tot;
  801ee3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ee8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eeb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ef0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef3:	83 ec 04             	sub    $0x4,%esp
  801ef6:	53                   	push   %ebx
  801ef7:	03 45 0c             	add    0xc(%ebp),%eax
  801efa:	50                   	push   %eax
  801efb:	57                   	push   %edi
  801efc:	e8 4a eb ff ff       	call   800a4b <memmove>
		sys_cputs(buf, m);
  801f01:	83 c4 08             	add    $0x8,%esp
  801f04:	53                   	push   %ebx
  801f05:	57                   	push   %edi
  801f06:	e8 f5 ec ff ff       	call   800c00 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f0b:	01 de                	add    %ebx,%esi
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	89 f0                	mov    %esi,%eax
  801f12:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f15:	72 cc                	jb     801ee3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5f                   	pop    %edi
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    

00801f1f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	83 ec 08             	sub    $0x8,%esp
  801f25:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f2e:	74 2a                	je     801f5a <devcons_read+0x3b>
  801f30:	eb 05                	jmp    801f37 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f32:	e8 66 ed ff ff       	call   800c9d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f37:	e8 e2 ec ff ff       	call   800c1e <sys_cgetc>
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	74 f2                	je     801f32 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 16                	js     801f5a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f44:	83 f8 04             	cmp    $0x4,%eax
  801f47:	74 0c                	je     801f55 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f49:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f4c:	88 02                	mov    %al,(%edx)
	return 1;
  801f4e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f53:	eb 05                	jmp    801f5a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f55:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f5a:	c9                   	leave  
  801f5b:	c3                   	ret    

00801f5c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f62:	8b 45 08             	mov    0x8(%ebp),%eax
  801f65:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f68:	6a 01                	push   $0x1
  801f6a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f6d:	50                   	push   %eax
  801f6e:	e8 8d ec ff ff       	call   800c00 <sys_cputs>
}
  801f73:	83 c4 10             	add    $0x10,%esp
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <getchar>:

int
getchar(void)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f7e:	6a 01                	push   $0x1
  801f80:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f83:	50                   	push   %eax
  801f84:	6a 00                	push   $0x0
  801f86:	e8 1d f2 ff ff       	call   8011a8 <read>
	if (r < 0)
  801f8b:	83 c4 10             	add    $0x10,%esp
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 0f                	js     801fa1 <getchar+0x29>
		return r;
	if (r < 1)
  801f92:	85 c0                	test   %eax,%eax
  801f94:	7e 06                	jle    801f9c <getchar+0x24>
		return -E_EOF;
	return c;
  801f96:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f9a:	eb 05                	jmp    801fa1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f9c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fa1:	c9                   	leave  
  801fa2:	c3                   	ret    

00801fa3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fac:	50                   	push   %eax
  801fad:	ff 75 08             	pushl  0x8(%ebp)
  801fb0:	e8 8d ef ff ff       	call   800f42 <fd_lookup>
  801fb5:	83 c4 10             	add    $0x10,%esp
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	78 11                	js     801fcd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbf:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fc5:	39 10                	cmp    %edx,(%eax)
  801fc7:	0f 94 c0             	sete   %al
  801fca:	0f b6 c0             	movzbl %al,%eax
}
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    

00801fcf <opencons>:

int
opencons(void)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd8:	50                   	push   %eax
  801fd9:	e8 15 ef ff ff       	call   800ef3 <fd_alloc>
  801fde:	83 c4 10             	add    $0x10,%esp
		return r;
  801fe1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	78 3e                	js     802025 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe7:	83 ec 04             	sub    $0x4,%esp
  801fea:	68 07 04 00 00       	push   $0x407
  801fef:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff2:	6a 00                	push   $0x0
  801ff4:	e8 c3 ec ff ff       	call   800cbc <sys_page_alloc>
  801ff9:	83 c4 10             	add    $0x10,%esp
		return r;
  801ffc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ffe:	85 c0                	test   %eax,%eax
  802000:	78 23                	js     802025 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802002:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802008:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80200d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802010:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802017:	83 ec 0c             	sub    $0xc,%esp
  80201a:	50                   	push   %eax
  80201b:	e8 ac ee ff ff       	call   800ecc <fd2num>
  802020:	89 c2                	mov    %eax,%edx
  802022:	83 c4 10             	add    $0x10,%esp
}
  802025:	89 d0                	mov    %edx,%eax
  802027:	c9                   	leave  
  802028:	c3                   	ret    

00802029 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	56                   	push   %esi
  80202d:	53                   	push   %ebx
  80202e:	8b 75 08             	mov    0x8(%ebp),%esi
  802031:	8b 45 0c             	mov    0xc(%ebp),%eax
  802034:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  802037:	85 c0                	test   %eax,%eax
  802039:	74 0e                	je     802049 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  80203b:	83 ec 0c             	sub    $0xc,%esp
  80203e:	50                   	push   %eax
  80203f:	e8 28 ee ff ff       	call   800e6c <sys_ipc_recv>
  802044:	83 c4 10             	add    $0x10,%esp
  802047:	eb 10                	jmp    802059 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802049:	83 ec 0c             	sub    $0xc,%esp
  80204c:	68 00 00 c0 ee       	push   $0xeec00000
  802051:	e8 16 ee ff ff       	call   800e6c <sys_ipc_recv>
  802056:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  802059:	85 c0                	test   %eax,%eax
  80205b:	79 17                	jns    802074 <ipc_recv+0x4b>
		if(*from_env_store)
  80205d:	83 3e 00             	cmpl   $0x0,(%esi)
  802060:	74 06                	je     802068 <ipc_recv+0x3f>
			*from_env_store = 0;
  802062:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  802068:	85 db                	test   %ebx,%ebx
  80206a:	74 2c                	je     802098 <ipc_recv+0x6f>
			*perm_store = 0;
  80206c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802072:	eb 24                	jmp    802098 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  802074:	85 f6                	test   %esi,%esi
  802076:	74 0a                	je     802082 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  802078:	a1 08 40 80 00       	mov    0x804008,%eax
  80207d:	8b 40 74             	mov    0x74(%eax),%eax
  802080:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802082:	85 db                	test   %ebx,%ebx
  802084:	74 0a                	je     802090 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  802086:	a1 08 40 80 00       	mov    0x804008,%eax
  80208b:	8b 40 78             	mov    0x78(%eax),%eax
  80208e:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802090:	a1 08 40 80 00       	mov    0x804008,%eax
  802095:	8b 40 70             	mov    0x70(%eax),%eax
}
  802098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209b:	5b                   	pop    %ebx
  80209c:	5e                   	pop    %esi
  80209d:	5d                   	pop    %ebp
  80209e:	c3                   	ret    

0080209f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80209f:	55                   	push   %ebp
  8020a0:	89 e5                	mov    %esp,%ebp
  8020a2:	57                   	push   %edi
  8020a3:	56                   	push   %esi
  8020a4:	53                   	push   %ebx
  8020a5:	83 ec 0c             	sub    $0xc,%esp
  8020a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8020b1:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  8020b3:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  8020b8:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  8020bb:	e8 dd eb ff ff       	call   800c9d <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  8020c0:	ff 75 14             	pushl  0x14(%ebp)
  8020c3:	53                   	push   %ebx
  8020c4:	56                   	push   %esi
  8020c5:	57                   	push   %edi
  8020c6:	e8 7e ed ff ff       	call   800e49 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  8020cb:	89 c2                	mov    %eax,%edx
  8020cd:	f7 d2                	not    %edx
  8020cf:	c1 ea 1f             	shr    $0x1f,%edx
  8020d2:	83 c4 10             	add    $0x10,%esp
  8020d5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d8:	0f 94 c1             	sete   %cl
  8020db:	09 ca                	or     %ecx,%edx
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	0f 94 c0             	sete   %al
  8020e2:	38 c2                	cmp    %al,%dl
  8020e4:	77 d5                	ja     8020bb <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8020e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e9:	5b                   	pop    %ebx
  8020ea:	5e                   	pop    %esi
  8020eb:	5f                   	pop    %edi
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    

008020ee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020f4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020f9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020fc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802102:	8b 52 50             	mov    0x50(%edx),%edx
  802105:	39 ca                	cmp    %ecx,%edx
  802107:	75 0d                	jne    802116 <ipc_find_env+0x28>
			return envs[i].env_id;
  802109:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80210c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802111:	8b 40 48             	mov    0x48(%eax),%eax
  802114:	eb 0f                	jmp    802125 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802116:	83 c0 01             	add    $0x1,%eax
  802119:	3d 00 04 00 00       	cmp    $0x400,%eax
  80211e:	75 d9                	jne    8020f9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802120:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802125:	5d                   	pop    %ebp
  802126:	c3                   	ret    

00802127 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802127:	55                   	push   %ebp
  802128:	89 e5                	mov    %esp,%ebp
  80212a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212d:	89 d0                	mov    %edx,%eax
  80212f:	c1 e8 16             	shr    $0x16,%eax
  802132:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802139:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80213e:	f6 c1 01             	test   $0x1,%cl
  802141:	74 1d                	je     802160 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802143:	c1 ea 0c             	shr    $0xc,%edx
  802146:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80214d:	f6 c2 01             	test   $0x1,%dl
  802150:	74 0e                	je     802160 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802152:	c1 ea 0c             	shr    $0xc,%edx
  802155:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80215c:	ef 
  80215d:	0f b7 c0             	movzwl %ax,%eax
}
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	66 90                	xchg   %ax,%ax
  802164:	66 90                	xchg   %ax,%ax
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80217b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80217f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 f6                	test   %esi,%esi
  802189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80218d:	89 ca                	mov    %ecx,%edx
  80218f:	89 f8                	mov    %edi,%eax
  802191:	75 3d                	jne    8021d0 <__udivdi3+0x60>
  802193:	39 cf                	cmp    %ecx,%edi
  802195:	0f 87 c5 00 00 00    	ja     802260 <__udivdi3+0xf0>
  80219b:	85 ff                	test   %edi,%edi
  80219d:	89 fd                	mov    %edi,%ebp
  80219f:	75 0b                	jne    8021ac <__udivdi3+0x3c>
  8021a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a6:	31 d2                	xor    %edx,%edx
  8021a8:	f7 f7                	div    %edi
  8021aa:	89 c5                	mov    %eax,%ebp
  8021ac:	89 c8                	mov    %ecx,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	f7 f5                	div    %ebp
  8021b2:	89 c1                	mov    %eax,%ecx
  8021b4:	89 d8                	mov    %ebx,%eax
  8021b6:	89 cf                	mov    %ecx,%edi
  8021b8:	f7 f5                	div    %ebp
  8021ba:	89 c3                	mov    %eax,%ebx
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
  8021d0:	39 ce                	cmp    %ecx,%esi
  8021d2:	77 74                	ja     802248 <__udivdi3+0xd8>
  8021d4:	0f bd fe             	bsr    %esi,%edi
  8021d7:	83 f7 1f             	xor    $0x1f,%edi
  8021da:	0f 84 98 00 00 00    	je     802278 <__udivdi3+0x108>
  8021e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	89 c5                	mov    %eax,%ebp
  8021e9:	29 fb                	sub    %edi,%ebx
  8021eb:	d3 e6                	shl    %cl,%esi
  8021ed:	89 d9                	mov    %ebx,%ecx
  8021ef:	d3 ed                	shr    %cl,%ebp
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	d3 e0                	shl    %cl,%eax
  8021f5:	09 ee                	or     %ebp,%esi
  8021f7:	89 d9                	mov    %ebx,%ecx
  8021f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fd:	89 d5                	mov    %edx,%ebp
  8021ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802203:	d3 ed                	shr    %cl,%ebp
  802205:	89 f9                	mov    %edi,%ecx
  802207:	d3 e2                	shl    %cl,%edx
  802209:	89 d9                	mov    %ebx,%ecx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	09 c2                	or     %eax,%edx
  80220f:	89 d0                	mov    %edx,%eax
  802211:	89 ea                	mov    %ebp,%edx
  802213:	f7 f6                	div    %esi
  802215:	89 d5                	mov    %edx,%ebp
  802217:	89 c3                	mov    %eax,%ebx
  802219:	f7 64 24 0c          	mull   0xc(%esp)
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	72 10                	jb     802231 <__udivdi3+0xc1>
  802221:	8b 74 24 08          	mov    0x8(%esp),%esi
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e6                	shl    %cl,%esi
  802229:	39 c6                	cmp    %eax,%esi
  80222b:	73 07                	jae    802234 <__udivdi3+0xc4>
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	75 03                	jne    802234 <__udivdi3+0xc4>
  802231:	83 eb 01             	sub    $0x1,%ebx
  802234:	31 ff                	xor    %edi,%edi
  802236:	89 d8                	mov    %ebx,%eax
  802238:	89 fa                	mov    %edi,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	31 ff                	xor    %edi,%edi
  80224a:	31 db                	xor    %ebx,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	89 d8                	mov    %ebx,%eax
  802262:	f7 f7                	div    %edi
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 c3                	mov    %eax,%ebx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 fa                	mov    %edi,%edx
  80226c:	83 c4 1c             	add    $0x1c,%esp
  80226f:	5b                   	pop    %ebx
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	5d                   	pop    %ebp
  802273:	c3                   	ret    
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	39 ce                	cmp    %ecx,%esi
  80227a:	72 0c                	jb     802288 <__udivdi3+0x118>
  80227c:	31 db                	xor    %ebx,%ebx
  80227e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802282:	0f 87 34 ff ff ff    	ja     8021bc <__udivdi3+0x4c>
  802288:	bb 01 00 00 00       	mov    $0x1,%ebx
  80228d:	e9 2a ff ff ff       	jmp    8021bc <__udivdi3+0x4c>
  802292:	66 90                	xchg   %ax,%ax
  802294:	66 90                	xchg   %ax,%ax
  802296:	66 90                	xchg   %ax,%ax
  802298:	66 90                	xchg   %ax,%ax
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
  8022a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b7:	85 d2                	test   %edx,%edx
  8022b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c1:	89 f3                	mov    %esi,%ebx
  8022c3:	89 3c 24             	mov    %edi,(%esp)
  8022c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ca:	75 1c                	jne    8022e8 <__umoddi3+0x48>
  8022cc:	39 f7                	cmp    %esi,%edi
  8022ce:	76 50                	jbe    802320 <__umoddi3+0x80>
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	f7 f7                	div    %edi
  8022d6:	89 d0                	mov    %edx,%eax
  8022d8:	31 d2                	xor    %edx,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	89 d0                	mov    %edx,%eax
  8022ec:	77 52                	ja     802340 <__umoddi3+0xa0>
  8022ee:	0f bd ea             	bsr    %edx,%ebp
  8022f1:	83 f5 1f             	xor    $0x1f,%ebp
  8022f4:	75 5a                	jne    802350 <__umoddi3+0xb0>
  8022f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022fa:	0f 82 e0 00 00 00    	jb     8023e0 <__umoddi3+0x140>
  802300:	39 0c 24             	cmp    %ecx,(%esp)
  802303:	0f 86 d7 00 00 00    	jbe    8023e0 <__umoddi3+0x140>
  802309:	8b 44 24 08          	mov    0x8(%esp),%eax
  80230d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802311:	83 c4 1c             	add    $0x1c,%esp
  802314:	5b                   	pop    %ebx
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	85 ff                	test   %edi,%edi
  802322:	89 fd                	mov    %edi,%ebp
  802324:	75 0b                	jne    802331 <__umoddi3+0x91>
  802326:	b8 01 00 00 00       	mov    $0x1,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	f7 f7                	div    %edi
  80232f:	89 c5                	mov    %eax,%ebp
  802331:	89 f0                	mov    %esi,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f5                	div    %ebp
  802337:	89 c8                	mov    %ecx,%eax
  802339:	f7 f5                	div    %ebp
  80233b:	89 d0                	mov    %edx,%eax
  80233d:	eb 99                	jmp    8022d8 <__umoddi3+0x38>
  80233f:	90                   	nop
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	83 c4 1c             	add    $0x1c,%esp
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    
  80234c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802350:	8b 34 24             	mov    (%esp),%esi
  802353:	bf 20 00 00 00       	mov    $0x20,%edi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	29 ef                	sub    %ebp,%edi
  80235c:	d3 e0                	shl    %cl,%eax
  80235e:	89 f9                	mov    %edi,%ecx
  802360:	89 f2                	mov    %esi,%edx
  802362:	d3 ea                	shr    %cl,%edx
  802364:	89 e9                	mov    %ebp,%ecx
  802366:	09 c2                	or     %eax,%edx
  802368:	89 d8                	mov    %ebx,%eax
  80236a:	89 14 24             	mov    %edx,(%esp)
  80236d:	89 f2                	mov    %esi,%edx
  80236f:	d3 e2                	shl    %cl,%edx
  802371:	89 f9                	mov    %edi,%ecx
  802373:	89 54 24 04          	mov    %edx,0x4(%esp)
  802377:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	89 c6                	mov    %eax,%esi
  802381:	d3 e3                	shl    %cl,%ebx
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 d0                	mov    %edx,%eax
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	09 d8                	or     %ebx,%eax
  80238d:	89 d3                	mov    %edx,%ebx
  80238f:	89 f2                	mov    %esi,%edx
  802391:	f7 34 24             	divl   (%esp)
  802394:	89 d6                	mov    %edx,%esi
  802396:	d3 e3                	shl    %cl,%ebx
  802398:	f7 64 24 04          	mull   0x4(%esp)
  80239c:	39 d6                	cmp    %edx,%esi
  80239e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a2:	89 d1                	mov    %edx,%ecx
  8023a4:	89 c3                	mov    %eax,%ebx
  8023a6:	72 08                	jb     8023b0 <__umoddi3+0x110>
  8023a8:	75 11                	jne    8023bb <__umoddi3+0x11b>
  8023aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ae:	73 0b                	jae    8023bb <__umoddi3+0x11b>
  8023b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023b4:	1b 14 24             	sbb    (%esp),%edx
  8023b7:	89 d1                	mov    %edx,%ecx
  8023b9:	89 c3                	mov    %eax,%ebx
  8023bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023bf:	29 da                	sub    %ebx,%edx
  8023c1:	19 ce                	sbb    %ecx,%esi
  8023c3:	89 f9                	mov    %edi,%ecx
  8023c5:	89 f0                	mov    %esi,%eax
  8023c7:	d3 e0                	shl    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	d3 ea                	shr    %cl,%edx
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	d3 ee                	shr    %cl,%esi
  8023d1:	09 d0                	or     %edx,%eax
  8023d3:	89 f2                	mov    %esi,%edx
  8023d5:	83 c4 1c             	add    $0x1c,%esp
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5f                   	pop    %edi
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	29 f9                	sub    %edi,%ecx
  8023e2:	19 d6                	sbb    %edx,%esi
  8023e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ec:	e9 18 ff ff ff       	jmp    802309 <__umoddi3+0x69>
