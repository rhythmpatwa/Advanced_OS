
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 9b 01 00 00       	call   8001cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	envid_t ns_envid = sys_getenvid();
  800038:	e8 32 0c 00 00       	call   800c6f <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80003f:	c7 05 00 30 80 00 c0 	movl   $0x8027c0,0x803000
  800046:	27 80 00 

	output_envid = fork();
  800049:	e8 63 0f 00 00       	call   800fb1 <fork>
  80004e:	a3 00 40 80 00       	mov    %eax,0x804000
	if (output_envid < 0)
  800053:	85 c0                	test   %eax,%eax
  800055:	79 14                	jns    80006b <umain+0x38>
		panic("error forking");
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	68 cb 27 80 00       	push   $0x8027cb
  80005f:	6a 16                	push   $0x16
  800061:	68 d9 27 80 00       	push   $0x8027d9
  800066:	e8 c1 01 00 00       	call   80022c <_panic>
  80006b:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (output_envid == 0) {
  800070:	85 c0                	test   %eax,%eax
  800072:	75 11                	jne    800085 <umain+0x52>
		output(ns_envid);
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	56                   	push   %esi
  800078:	e8 40 01 00 00       	call   8001bd <output>
		return;
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	e9 8f 00 00 00       	jmp    800114 <umain+0xe1>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 07                	push   $0x7
  80008a:	68 00 b0 fe 0f       	push   $0xffeb000
  80008f:	6a 00                	push   $0x0
  800091:	e8 17 0c 00 00       	call   800cad <sys_page_alloc>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x7c>
			panic("sys_page_alloc: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 16 2c 80 00       	push   $0x802c16
  8000a3:	6a 1e                	push   $0x1e
  8000a5:	68 d9 27 80 00       	push   $0x8027d9
  8000aa:	e8 7d 01 00 00       	call   80022c <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000af:	53                   	push   %ebx
  8000b0:	68 ea 27 80 00       	push   $0x8027ea
  8000b5:	68 fc 0f 00 00       	push   $0xffc
  8000ba:	68 04 b0 fe 0f       	push   $0xffeb004
  8000bf:	e8 93 07 00 00       	call   800857 <snprintf>
  8000c4:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000c9:	83 c4 08             	add    $0x8,%esp
  8000cc:	53                   	push   %ebx
  8000cd:	68 f6 27 80 00       	push   $0x8027f6
  8000d2:	e8 2e 02 00 00       	call   800305 <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000d7:	6a 07                	push   $0x7
  8000d9:	68 00 b0 fe 0f       	push   $0xffeb000
  8000de:	6a 0b                	push   $0xb
  8000e0:	ff 35 00 40 80 00    	pushl  0x804000
  8000e6:	e8 74 11 00 00       	call   80125f <ipc_send>
		sys_page_unmap(0, pkt);
  8000eb:	83 c4 18             	add    $0x18,%esp
  8000ee:	68 00 b0 fe 0f       	push   $0xffeb000
  8000f3:	6a 00                	push   $0x0
  8000f5:	e8 38 0c 00 00       	call   800d32 <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  8000fa:	83 c3 01             	add    $0x1,%ebx
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	83 fb 0a             	cmp    $0xa,%ebx
  800103:	75 80                	jne    800085 <umain+0x52>
  800105:	bb 14 00 00 00       	mov    $0x14,%ebx
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  80010a:	e8 7f 0b 00 00       	call   800c8e <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80010f:	83 eb 01             	sub    $0x1,%ebx
  800112:	75 f6                	jne    80010a <umain+0xd7>
		sys_yield();
}
  800114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 1c             	sub    $0x1c,%esp
  800124:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800127:	e8 72 0d 00 00       	call   800e9e <sys_time_msec>
  80012c:	03 45 0c             	add    0xc(%ebp),%eax
  80012f:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  800131:	c7 05 00 30 80 00 0e 	movl   $0x80280e,0x803000
  800138:	28 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  80013b:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80013e:	eb 05                	jmp    800145 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800140:	e8 49 0b 00 00       	call   800c8e <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  800145:	e8 54 0d 00 00       	call   800e9e <sys_time_msec>
  80014a:	89 c2                	mov    %eax,%edx
  80014c:	85 c0                	test   %eax,%eax
  80014e:	78 04                	js     800154 <timer+0x39>
  800150:	39 c3                	cmp    %eax,%ebx
  800152:	77 ec                	ja     800140 <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  800154:	85 c0                	test   %eax,%eax
  800156:	79 12                	jns    80016a <timer+0x4f>
			panic("sys_time_msec: %e", r);
  800158:	52                   	push   %edx
  800159:	68 17 28 80 00       	push   $0x802817
  80015e:	6a 0f                	push   $0xf
  800160:	68 29 28 80 00       	push   $0x802829
  800165:	e8 c2 00 00 00       	call   80022c <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  80016a:	6a 00                	push   $0x0
  80016c:	6a 00                	push   $0x0
  80016e:	6a 0c                	push   $0xc
  800170:	56                   	push   %esi
  800171:	e8 e9 10 00 00       	call   80125f <ipc_send>
  800176:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	57                   	push   %edi
  800181:	e8 63 10 00 00       	call   8011e9 <ipc_recv>
  800186:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	39 f0                	cmp    %esi,%eax
  800190:	74 13                	je     8001a5 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	50                   	push   %eax
  800196:	68 38 28 80 00       	push   $0x802838
  80019b:	e8 65 01 00 00       	call   800305 <cprintf>
				continue;
  8001a0:	83 c4 10             	add    $0x10,%esp
  8001a3:	eb d4                	jmp    800179 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  8001a5:	e8 f4 0c 00 00       	call   800e9e <sys_time_msec>
  8001aa:	01 c3                	add    %eax,%ebx
  8001ac:	eb 97                	jmp    800145 <timer+0x2a>

008001ae <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  8001b1:	c7 05 00 30 80 00 73 	movl   $0x802873,0x803000
  8001b8:	28 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  8001c0:	c7 05 00 30 80 00 7c 	movl   $0x80287c,0x803000
  8001c7:	28 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8001d7:	e8 93 0a 00 00       	call   800c6f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ee:	85 db                	test   %ebx,%ebx
  8001f0:	7e 07                	jle    8001f9 <libmain+0x2d>
		binaryname = argv[0];
  8001f2:	8b 06                	mov    (%esi),%eax
  8001f4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	56                   	push   %esi
  8001fd:	53                   	push   %ebx
  8001fe:	e8 30 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800203:	e8 0a 00 00 00       	call   800212 <exit>
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800218:	e8 95 12 00 00       	call   8014b2 <close_all>
	sys_env_destroy(0);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	6a 00                	push   $0x0
  800222:	e8 07 0a 00 00       	call   800c2e <sys_env_destroy>
}
  800227:	83 c4 10             	add    $0x10,%esp
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800231:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800234:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80023a:	e8 30 0a 00 00       	call   800c6f <sys_getenvid>
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	56                   	push   %esi
  800249:	50                   	push   %eax
  80024a:	68 90 28 80 00       	push   $0x802890
  80024f:	e8 b1 00 00 00       	call   800305 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800254:	83 c4 18             	add    $0x18,%esp
  800257:	53                   	push   %ebx
  800258:	ff 75 10             	pushl  0x10(%ebp)
  80025b:	e8 54 00 00 00       	call   8002b4 <vcprintf>
	cprintf("\n");
  800260:	c7 04 24 0c 28 80 00 	movl   $0x80280c,(%esp)
  800267:	e8 99 00 00 00       	call   800305 <cprintf>
  80026c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026f:	cc                   	int3   
  800270:	eb fd                	jmp    80026f <_panic+0x43>

00800272 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	53                   	push   %ebx
  800276:	83 ec 04             	sub    $0x4,%esp
  800279:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027c:	8b 13                	mov    (%ebx),%edx
  80027e:	8d 42 01             	lea    0x1(%edx),%eax
  800281:	89 03                	mov    %eax,(%ebx)
  800283:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800286:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028f:	75 1a                	jne    8002ab <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	68 ff 00 00 00       	push   $0xff
  800299:	8d 43 08             	lea    0x8(%ebx),%eax
  80029c:	50                   	push   %eax
  80029d:	e8 4f 09 00 00       	call   800bf1 <sys_cputs>
		b->idx = 0;
  8002a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    

008002b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c4:	00 00 00 
	b.cnt = 0;
  8002c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d1:	ff 75 0c             	pushl  0xc(%ebp)
  8002d4:	ff 75 08             	pushl  0x8(%ebp)
  8002d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002dd:	50                   	push   %eax
  8002de:	68 72 02 80 00       	push   $0x800272
  8002e3:	e8 54 01 00 00       	call   80043c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e8:	83 c4 08             	add    $0x8,%esp
  8002eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f7:	50                   	push   %eax
  8002f8:	e8 f4 08 00 00       	call   800bf1 <sys_cputs>

	return b.cnt;
}
  8002fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80030e:	50                   	push   %eax
  80030f:	ff 75 08             	pushl  0x8(%ebp)
  800312:	e8 9d ff ff ff       	call   8002b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 1c             	sub    $0x1c,%esp
  800322:	89 c7                	mov    %eax,%edi
  800324:	89 d6                	mov    %edx,%esi
  800326:	8b 45 08             	mov    0x8(%ebp),%eax
  800329:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80032f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800332:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800335:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80033d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800340:	39 d3                	cmp    %edx,%ebx
  800342:	72 05                	jb     800349 <printnum+0x30>
  800344:	39 45 10             	cmp    %eax,0x10(%ebp)
  800347:	77 45                	ja     80038e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800349:	83 ec 0c             	sub    $0xc,%esp
  80034c:	ff 75 18             	pushl  0x18(%ebp)
  80034f:	8b 45 14             	mov    0x14(%ebp),%eax
  800352:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800355:	53                   	push   %ebx
  800356:	ff 75 10             	pushl  0x10(%ebp)
  800359:	83 ec 08             	sub    $0x8,%esp
  80035c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035f:	ff 75 e0             	pushl  -0x20(%ebp)
  800362:	ff 75 dc             	pushl  -0x24(%ebp)
  800365:	ff 75 d8             	pushl  -0x28(%ebp)
  800368:	e8 b3 21 00 00       	call   802520 <__udivdi3>
  80036d:	83 c4 18             	add    $0x18,%esp
  800370:	52                   	push   %edx
  800371:	50                   	push   %eax
  800372:	89 f2                	mov    %esi,%edx
  800374:	89 f8                	mov    %edi,%eax
  800376:	e8 9e ff ff ff       	call   800319 <printnum>
  80037b:	83 c4 20             	add    $0x20,%esp
  80037e:	eb 18                	jmp    800398 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	56                   	push   %esi
  800384:	ff 75 18             	pushl  0x18(%ebp)
  800387:	ff d7                	call   *%edi
  800389:	83 c4 10             	add    $0x10,%esp
  80038c:	eb 03                	jmp    800391 <printnum+0x78>
  80038e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800391:	83 eb 01             	sub    $0x1,%ebx
  800394:	85 db                	test   %ebx,%ebx
  800396:	7f e8                	jg     800380 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	83 ec 04             	sub    $0x4,%esp
  80039f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ab:	e8 a0 22 00 00       	call   802650 <__umoddi3>
  8003b0:	83 c4 14             	add    $0x14,%esp
  8003b3:	0f be 80 b3 28 80 00 	movsbl 0x8028b3(%eax),%eax
  8003ba:	50                   	push   %eax
  8003bb:	ff d7                	call   *%edi
}
  8003bd:	83 c4 10             	add    $0x10,%esp
  8003c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c3:	5b                   	pop    %ebx
  8003c4:	5e                   	pop    %esi
  8003c5:	5f                   	pop    %edi
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    

008003c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cb:	83 fa 01             	cmp    $0x1,%edx
  8003ce:	7e 0e                	jle    8003de <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d0:	8b 10                	mov    (%eax),%edx
  8003d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 02                	mov    (%edx),%eax
  8003d9:	8b 52 04             	mov    0x4(%edx),%edx
  8003dc:	eb 22                	jmp    800400 <getuint+0x38>
	else if (lflag)
  8003de:	85 d2                	test   %edx,%edx
  8003e0:	74 10                	je     8003f2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e7:	89 08                	mov    %ecx,(%eax)
  8003e9:	8b 02                	mov    (%edx),%eax
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f0:	eb 0e                	jmp    800400 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f7:	89 08                	mov    %ecx,(%eax)
  8003f9:	8b 02                	mov    (%edx),%eax
  8003fb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    

00800402 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800408:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040c:	8b 10                	mov    (%eax),%edx
  80040e:	3b 50 04             	cmp    0x4(%eax),%edx
  800411:	73 0a                	jae    80041d <sprintputch+0x1b>
		*b->buf++ = ch;
  800413:	8d 4a 01             	lea    0x1(%edx),%ecx
  800416:	89 08                	mov    %ecx,(%eax)
  800418:	8b 45 08             	mov    0x8(%ebp),%eax
  80041b:	88 02                	mov    %al,(%edx)
}
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800425:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800428:	50                   	push   %eax
  800429:	ff 75 10             	pushl  0x10(%ebp)
  80042c:	ff 75 0c             	pushl  0xc(%ebp)
  80042f:	ff 75 08             	pushl  0x8(%ebp)
  800432:	e8 05 00 00 00       	call   80043c <vprintfmt>
	va_end(ap);
}
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	c9                   	leave  
  80043b:	c3                   	ret    

0080043c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	57                   	push   %edi
  800440:	56                   	push   %esi
  800441:	53                   	push   %ebx
  800442:	83 ec 2c             	sub    $0x2c,%esp
  800445:	8b 75 08             	mov    0x8(%ebp),%esi
  800448:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80044b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80044e:	eb 12                	jmp    800462 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800450:	85 c0                	test   %eax,%eax
  800452:	0f 84 a9 03 00 00    	je     800801 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	53                   	push   %ebx
  80045c:	50                   	push   %eax
  80045d:	ff d6                	call   *%esi
  80045f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800462:	83 c7 01             	add    $0x1,%edi
  800465:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800469:	83 f8 25             	cmp    $0x25,%eax
  80046c:	75 e2                	jne    800450 <vprintfmt+0x14>
  80046e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800472:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800479:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800480:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800487:	ba 00 00 00 00       	mov    $0x0,%edx
  80048c:	eb 07                	jmp    800495 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800491:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8d 47 01             	lea    0x1(%edi),%eax
  800498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049b:	0f b6 07             	movzbl (%edi),%eax
  80049e:	0f b6 c8             	movzbl %al,%ecx
  8004a1:	83 e8 23             	sub    $0x23,%eax
  8004a4:	3c 55                	cmp    $0x55,%al
  8004a6:	0f 87 3a 03 00 00    	ja     8007e6 <vprintfmt+0x3aa>
  8004ac:	0f b6 c0             	movzbl %al,%eax
  8004af:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004bd:	eb d6                	jmp    800495 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004cd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004d1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004d4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004d7:	83 fa 09             	cmp    $0x9,%edx
  8004da:	77 39                	ja     800515 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004df:	eb e9                	jmp    8004ca <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 48 04             	lea    0x4(%eax),%ecx
  8004e7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f2:	eb 27                	jmp    80051b <vprintfmt+0xdf>
  8004f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004fe:	0f 49 c8             	cmovns %eax,%ecx
  800501:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800507:	eb 8c                	jmp    800495 <vprintfmt+0x59>
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80050c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800513:	eb 80                	jmp    800495 <vprintfmt+0x59>
  800515:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800518:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80051b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051f:	0f 89 70 ff ff ff    	jns    800495 <vprintfmt+0x59>
				width = precision, precision = -1;
  800525:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800528:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800532:	e9 5e ff ff ff       	jmp    800495 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800537:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053d:	e9 53 ff ff ff       	jmp    800495 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	ff 30                	pushl  (%eax)
  800551:	ff d6                	call   *%esi
			break;
  800553:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800559:	e9 04 ff ff ff       	jmp    800462 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 00                	mov    (%eax),%eax
  800569:	99                   	cltd   
  80056a:	31 d0                	xor    %edx,%eax
  80056c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056e:	83 f8 0f             	cmp    $0xf,%eax
  800571:	7f 0b                	jg     80057e <vprintfmt+0x142>
  800573:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  80057a:	85 d2                	test   %edx,%edx
  80057c:	75 18                	jne    800596 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80057e:	50                   	push   %eax
  80057f:	68 cb 28 80 00       	push   $0x8028cb
  800584:	53                   	push   %ebx
  800585:	56                   	push   %esi
  800586:	e8 94 fe ff ff       	call   80041f <printfmt>
  80058b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800591:	e9 cc fe ff ff       	jmp    800462 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800596:	52                   	push   %edx
  800597:	68 6d 2d 80 00       	push   $0x802d6d
  80059c:	53                   	push   %ebx
  80059d:	56                   	push   %esi
  80059e:	e8 7c fe ff ff       	call   80041f <printfmt>
  8005a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a9:	e9 b4 fe ff ff       	jmp    800462 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005b9:	85 ff                	test   %edi,%edi
  8005bb:	b8 c4 28 80 00       	mov    $0x8028c4,%eax
  8005c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c7:	0f 8e 94 00 00 00    	jle    800661 <vprintfmt+0x225>
  8005cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005d1:	0f 84 98 00 00 00    	je     80066f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	ff 75 d0             	pushl  -0x30(%ebp)
  8005dd:	57                   	push   %edi
  8005de:	e8 a6 02 00 00       	call   800889 <strnlen>
  8005e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005e6:	29 c1                	sub    %eax,%ecx
  8005e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fa:	eb 0f                	jmp    80060b <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	ff 75 e0             	pushl  -0x20(%ebp)
  800603:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800605:	83 ef 01             	sub    $0x1,%edi
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	85 ff                	test   %edi,%edi
  80060d:	7f ed                	jg     8005fc <vprintfmt+0x1c0>
  80060f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800612:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800615:	85 c9                	test   %ecx,%ecx
  800617:	b8 00 00 00 00       	mov    $0x0,%eax
  80061c:	0f 49 c1             	cmovns %ecx,%eax
  80061f:	29 c1                	sub    %eax,%ecx
  800621:	89 75 08             	mov    %esi,0x8(%ebp)
  800624:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800627:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80062a:	89 cb                	mov    %ecx,%ebx
  80062c:	eb 4d                	jmp    80067b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80062e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800632:	74 1b                	je     80064f <vprintfmt+0x213>
  800634:	0f be c0             	movsbl %al,%eax
  800637:	83 e8 20             	sub    $0x20,%eax
  80063a:	83 f8 5e             	cmp    $0x5e,%eax
  80063d:	76 10                	jbe    80064f <vprintfmt+0x213>
					putch('?', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	ff 75 0c             	pushl  0xc(%ebp)
  800645:	6a 3f                	push   $0x3f
  800647:	ff 55 08             	call   *0x8(%ebp)
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	eb 0d                	jmp    80065c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	ff 75 0c             	pushl  0xc(%ebp)
  800655:	52                   	push   %edx
  800656:	ff 55 08             	call   *0x8(%ebp)
  800659:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065c:	83 eb 01             	sub    $0x1,%ebx
  80065f:	eb 1a                	jmp    80067b <vprintfmt+0x23f>
  800661:	89 75 08             	mov    %esi,0x8(%ebp)
  800664:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800667:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066d:	eb 0c                	jmp    80067b <vprintfmt+0x23f>
  80066f:	89 75 08             	mov    %esi,0x8(%ebp)
  800672:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800675:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800678:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067b:	83 c7 01             	add    $0x1,%edi
  80067e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800682:	0f be d0             	movsbl %al,%edx
  800685:	85 d2                	test   %edx,%edx
  800687:	74 23                	je     8006ac <vprintfmt+0x270>
  800689:	85 f6                	test   %esi,%esi
  80068b:	78 a1                	js     80062e <vprintfmt+0x1f2>
  80068d:	83 ee 01             	sub    $0x1,%esi
  800690:	79 9c                	jns    80062e <vprintfmt+0x1f2>
  800692:	89 df                	mov    %ebx,%edi
  800694:	8b 75 08             	mov    0x8(%ebp),%esi
  800697:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069a:	eb 18                	jmp    8006b4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 20                	push   $0x20
  8006a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a4:	83 ef 01             	sub    $0x1,%edi
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 08                	jmp    8006b4 <vprintfmt+0x278>
  8006ac:	89 df                	mov    %ebx,%edi
  8006ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b4:	85 ff                	test   %edi,%edi
  8006b6:	7f e4                	jg     80069c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bb:	e9 a2 fd ff ff       	jmp    800462 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c0:	83 fa 01             	cmp    $0x1,%edx
  8006c3:	7e 16                	jle    8006db <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 08             	lea    0x8(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	8b 50 04             	mov    0x4(%eax),%edx
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006d9:	eb 32                	jmp    80070d <vprintfmt+0x2d1>
	else if (lflag)
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	74 18                	je     8006f7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 04             	lea    0x4(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e8:	8b 00                	mov    (%eax),%eax
  8006ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ed:	89 c1                	mov    %eax,%ecx
  8006ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f5:	eb 16                	jmp    80070d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800705:	89 c1                	mov    %eax,%ecx
  800707:	c1 f9 1f             	sar    $0x1f,%ecx
  80070a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800710:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800713:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800718:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80071c:	0f 89 90 00 00 00    	jns    8007b2 <vprintfmt+0x376>
				putch('-', putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	53                   	push   %ebx
  800726:	6a 2d                	push   $0x2d
  800728:	ff d6                	call   *%esi
				num = -(long long) num;
  80072a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800730:	f7 d8                	neg    %eax
  800732:	83 d2 00             	adc    $0x0,%edx
  800735:	f7 da                	neg    %edx
  800737:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80073a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80073f:	eb 71                	jmp    8007b2 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800741:	8d 45 14             	lea    0x14(%ebp),%eax
  800744:	e8 7f fc ff ff       	call   8003c8 <getuint>
			base = 10;
  800749:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80074e:	eb 62                	jmp    8007b2 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800750:	8d 45 14             	lea    0x14(%ebp),%eax
  800753:	e8 70 fc ff ff       	call   8003c8 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800758:	83 ec 0c             	sub    $0xc,%esp
  80075b:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80075f:	51                   	push   %ecx
  800760:	ff 75 e0             	pushl  -0x20(%ebp)
  800763:	6a 08                	push   $0x8
  800765:	52                   	push   %edx
  800766:	50                   	push   %eax
  800767:	89 da                	mov    %ebx,%edx
  800769:	89 f0                	mov    %esi,%eax
  80076b:	e8 a9 fb ff ff       	call   800319 <printnum>
			break;
  800770:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800773:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800776:	e9 e7 fc ff ff       	jmp    800462 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 30                	push   $0x30
  800781:	ff d6                	call   *%esi
			putch('x', putdat);
  800783:	83 c4 08             	add    $0x8,%esp
  800786:	53                   	push   %ebx
  800787:	6a 78                	push   $0x78
  800789:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80078b:	8b 45 14             	mov    0x14(%ebp),%eax
  80078e:	8d 50 04             	lea    0x4(%eax),%edx
  800791:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800794:	8b 00                	mov    (%eax),%eax
  800796:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80079b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80079e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007a3:	eb 0d                	jmp    8007b2 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a8:	e8 1b fc ff ff       	call   8003c8 <getuint>
			base = 16;
  8007ad:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b2:	83 ec 0c             	sub    $0xc,%esp
  8007b5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007b9:	57                   	push   %edi
  8007ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8007bd:	51                   	push   %ecx
  8007be:	52                   	push   %edx
  8007bf:	50                   	push   %eax
  8007c0:	89 da                	mov    %ebx,%edx
  8007c2:	89 f0                	mov    %esi,%eax
  8007c4:	e8 50 fb ff ff       	call   800319 <printnum>
			break;
  8007c9:	83 c4 20             	add    $0x20,%esp
  8007cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007cf:	e9 8e fc ff ff       	jmp    800462 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	53                   	push   %ebx
  8007d8:	51                   	push   %ecx
  8007d9:	ff d6                	call   *%esi
			break;
  8007db:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007e1:	e9 7c fc ff ff       	jmp    800462 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	53                   	push   %ebx
  8007ea:	6a 25                	push   $0x25
  8007ec:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ee:	83 c4 10             	add    $0x10,%esp
  8007f1:	eb 03                	jmp    8007f6 <vprintfmt+0x3ba>
  8007f3:	83 ef 01             	sub    $0x1,%edi
  8007f6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007fa:	75 f7                	jne    8007f3 <vprintfmt+0x3b7>
  8007fc:	e9 61 fc ff ff       	jmp    800462 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800801:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800804:	5b                   	pop    %ebx
  800805:	5e                   	pop    %esi
  800806:	5f                   	pop    %edi
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	83 ec 18             	sub    $0x18,%esp
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800815:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800818:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80081f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800826:	85 c0                	test   %eax,%eax
  800828:	74 26                	je     800850 <vsnprintf+0x47>
  80082a:	85 d2                	test   %edx,%edx
  80082c:	7e 22                	jle    800850 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082e:	ff 75 14             	pushl  0x14(%ebp)
  800831:	ff 75 10             	pushl  0x10(%ebp)
  800834:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800837:	50                   	push   %eax
  800838:	68 02 04 80 00       	push   $0x800402
  80083d:	e8 fa fb ff ff       	call   80043c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800842:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800845:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800848:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084b:	83 c4 10             	add    $0x10,%esp
  80084e:	eb 05                	jmp    800855 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800850:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800860:	50                   	push   %eax
  800861:	ff 75 10             	pushl  0x10(%ebp)
  800864:	ff 75 0c             	pushl  0xc(%ebp)
  800867:	ff 75 08             	pushl  0x8(%ebp)
  80086a:	e8 9a ff ff ff       	call   800809 <vsnprintf>
	va_end(ap);

	return rc;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
  80087c:	eb 03                	jmp    800881 <strlen+0x10>
		n++;
  80087e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800881:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800885:	75 f7                	jne    80087e <strlen+0xd>
		n++;
	return n;
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800892:	ba 00 00 00 00       	mov    $0x0,%edx
  800897:	eb 03                	jmp    80089c <strnlen+0x13>
		n++;
  800899:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089c:	39 c2                	cmp    %eax,%edx
  80089e:	74 08                	je     8008a8 <strnlen+0x1f>
  8008a0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008a4:	75 f3                	jne    800899 <strnlen+0x10>
  8008a6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	53                   	push   %ebx
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b4:	89 c2                	mov    %eax,%edx
  8008b6:	83 c2 01             	add    $0x1,%edx
  8008b9:	83 c1 01             	add    $0x1,%ecx
  8008bc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008c0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c3:	84 db                	test   %bl,%bl
  8008c5:	75 ef                	jne    8008b6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c7:	5b                   	pop    %ebx
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	53                   	push   %ebx
  8008ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d1:	53                   	push   %ebx
  8008d2:	e8 9a ff ff ff       	call   800871 <strlen>
  8008d7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008da:	ff 75 0c             	pushl  0xc(%ebp)
  8008dd:	01 d8                	add    %ebx,%eax
  8008df:	50                   	push   %eax
  8008e0:	e8 c5 ff ff ff       	call   8008aa <strcpy>
	return dst;
}
  8008e5:	89 d8                	mov    %ebx,%eax
  8008e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
  8008f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f7:	89 f3                	mov    %esi,%ebx
  8008f9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fc:	89 f2                	mov    %esi,%edx
  8008fe:	eb 0f                	jmp    80090f <strncpy+0x23>
		*dst++ = *src;
  800900:	83 c2 01             	add    $0x1,%edx
  800903:	0f b6 01             	movzbl (%ecx),%eax
  800906:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800909:	80 39 01             	cmpb   $0x1,(%ecx)
  80090c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090f:	39 da                	cmp    %ebx,%edx
  800911:	75 ed                	jne    800900 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800913:	89 f0                	mov    %esi,%eax
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
  80091e:	8b 75 08             	mov    0x8(%ebp),%esi
  800921:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800924:	8b 55 10             	mov    0x10(%ebp),%edx
  800927:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800929:	85 d2                	test   %edx,%edx
  80092b:	74 21                	je     80094e <strlcpy+0x35>
  80092d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800931:	89 f2                	mov    %esi,%edx
  800933:	eb 09                	jmp    80093e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800935:	83 c2 01             	add    $0x1,%edx
  800938:	83 c1 01             	add    $0x1,%ecx
  80093b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80093e:	39 c2                	cmp    %eax,%edx
  800940:	74 09                	je     80094b <strlcpy+0x32>
  800942:	0f b6 19             	movzbl (%ecx),%ebx
  800945:	84 db                	test   %bl,%bl
  800947:	75 ec                	jne    800935 <strlcpy+0x1c>
  800949:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80094b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80094e:	29 f0                	sub    %esi,%eax
}
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095d:	eb 06                	jmp    800965 <strcmp+0x11>
		p++, q++;
  80095f:	83 c1 01             	add    $0x1,%ecx
  800962:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800965:	0f b6 01             	movzbl (%ecx),%eax
  800968:	84 c0                	test   %al,%al
  80096a:	74 04                	je     800970 <strcmp+0x1c>
  80096c:	3a 02                	cmp    (%edx),%al
  80096e:	74 ef                	je     80095f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800970:	0f b6 c0             	movzbl %al,%eax
  800973:	0f b6 12             	movzbl (%edx),%edx
  800976:	29 d0                	sub    %edx,%eax
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 55 0c             	mov    0xc(%ebp),%edx
  800984:	89 c3                	mov    %eax,%ebx
  800986:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800989:	eb 06                	jmp    800991 <strncmp+0x17>
		n--, p++, q++;
  80098b:	83 c0 01             	add    $0x1,%eax
  80098e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800991:	39 d8                	cmp    %ebx,%eax
  800993:	74 15                	je     8009aa <strncmp+0x30>
  800995:	0f b6 08             	movzbl (%eax),%ecx
  800998:	84 c9                	test   %cl,%cl
  80099a:	74 04                	je     8009a0 <strncmp+0x26>
  80099c:	3a 0a                	cmp    (%edx),%cl
  80099e:	74 eb                	je     80098b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a0:	0f b6 00             	movzbl (%eax),%eax
  8009a3:	0f b6 12             	movzbl (%edx),%edx
  8009a6:	29 d0                	sub    %edx,%eax
  8009a8:	eb 05                	jmp    8009af <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009aa:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009af:	5b                   	pop    %ebx
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009bc:	eb 07                	jmp    8009c5 <strchr+0x13>
		if (*s == c)
  8009be:	38 ca                	cmp    %cl,%dl
  8009c0:	74 0f                	je     8009d1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	0f b6 10             	movzbl (%eax),%edx
  8009c8:	84 d2                	test   %dl,%dl
  8009ca:	75 f2                	jne    8009be <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009dd:	eb 03                	jmp    8009e2 <strfind+0xf>
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009e5:	38 ca                	cmp    %cl,%dl
  8009e7:	74 04                	je     8009ed <strfind+0x1a>
  8009e9:	84 d2                	test   %dl,%dl
  8009eb:	75 f2                	jne    8009df <strfind+0xc>
			break;
	return (char *) s;
}
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	57                   	push   %edi
  8009f3:	56                   	push   %esi
  8009f4:	53                   	push   %ebx
  8009f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009fb:	85 c9                	test   %ecx,%ecx
  8009fd:	74 36                	je     800a35 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a05:	75 28                	jne    800a2f <memset+0x40>
  800a07:	f6 c1 03             	test   $0x3,%cl
  800a0a:	75 23                	jne    800a2f <memset+0x40>
		c &= 0xFF;
  800a0c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a10:	89 d3                	mov    %edx,%ebx
  800a12:	c1 e3 08             	shl    $0x8,%ebx
  800a15:	89 d6                	mov    %edx,%esi
  800a17:	c1 e6 18             	shl    $0x18,%esi
  800a1a:	89 d0                	mov    %edx,%eax
  800a1c:	c1 e0 10             	shl    $0x10,%eax
  800a1f:	09 f0                	or     %esi,%eax
  800a21:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a23:	89 d8                	mov    %ebx,%eax
  800a25:	09 d0                	or     %edx,%eax
  800a27:	c1 e9 02             	shr    $0x2,%ecx
  800a2a:	fc                   	cld    
  800a2b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a2d:	eb 06                	jmp    800a35 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a32:	fc                   	cld    
  800a33:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a35:	89 f8                	mov    %edi,%eax
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5f                   	pop    %edi
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a47:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4a:	39 c6                	cmp    %eax,%esi
  800a4c:	73 35                	jae    800a83 <memmove+0x47>
  800a4e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a51:	39 d0                	cmp    %edx,%eax
  800a53:	73 2e                	jae    800a83 <memmove+0x47>
		s += n;
		d += n;
  800a55:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a58:	89 d6                	mov    %edx,%esi
  800a5a:	09 fe                	or     %edi,%esi
  800a5c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a62:	75 13                	jne    800a77 <memmove+0x3b>
  800a64:	f6 c1 03             	test   $0x3,%cl
  800a67:	75 0e                	jne    800a77 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a69:	83 ef 04             	sub    $0x4,%edi
  800a6c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a6f:	c1 e9 02             	shr    $0x2,%ecx
  800a72:	fd                   	std    
  800a73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a75:	eb 09                	jmp    800a80 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a77:	83 ef 01             	sub    $0x1,%edi
  800a7a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a7d:	fd                   	std    
  800a7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a80:	fc                   	cld    
  800a81:	eb 1d                	jmp    800aa0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a83:	89 f2                	mov    %esi,%edx
  800a85:	09 c2                	or     %eax,%edx
  800a87:	f6 c2 03             	test   $0x3,%dl
  800a8a:	75 0f                	jne    800a9b <memmove+0x5f>
  800a8c:	f6 c1 03             	test   $0x3,%cl
  800a8f:	75 0a                	jne    800a9b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a91:	c1 e9 02             	shr    $0x2,%ecx
  800a94:	89 c7                	mov    %eax,%edi
  800a96:	fc                   	cld    
  800a97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a99:	eb 05                	jmp    800aa0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	fc                   	cld    
  800a9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aa7:	ff 75 10             	pushl  0x10(%ebp)
  800aaa:	ff 75 0c             	pushl  0xc(%ebp)
  800aad:	ff 75 08             	pushl  0x8(%ebp)
  800ab0:	e8 87 ff ff ff       	call   800a3c <memmove>
}
  800ab5:	c9                   	leave  
  800ab6:	c3                   	ret    

00800ab7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac2:	89 c6                	mov    %eax,%esi
  800ac4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac7:	eb 1a                	jmp    800ae3 <memcmp+0x2c>
		if (*s1 != *s2)
  800ac9:	0f b6 08             	movzbl (%eax),%ecx
  800acc:	0f b6 1a             	movzbl (%edx),%ebx
  800acf:	38 d9                	cmp    %bl,%cl
  800ad1:	74 0a                	je     800add <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ad3:	0f b6 c1             	movzbl %cl,%eax
  800ad6:	0f b6 db             	movzbl %bl,%ebx
  800ad9:	29 d8                	sub    %ebx,%eax
  800adb:	eb 0f                	jmp    800aec <memcmp+0x35>
		s1++, s2++;
  800add:	83 c0 01             	add    $0x1,%eax
  800ae0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae3:	39 f0                	cmp    %esi,%eax
  800ae5:	75 e2                	jne    800ac9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	53                   	push   %ebx
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800af7:	89 c1                	mov    %eax,%ecx
  800af9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800afc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b00:	eb 0a                	jmp    800b0c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b02:	0f b6 10             	movzbl (%eax),%edx
  800b05:	39 da                	cmp    %ebx,%edx
  800b07:	74 07                	je     800b10 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b09:	83 c0 01             	add    $0x1,%eax
  800b0c:	39 c8                	cmp    %ecx,%eax
  800b0e:	72 f2                	jb     800b02 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b10:	5b                   	pop    %ebx
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1f:	eb 03                	jmp    800b24 <strtol+0x11>
		s++;
  800b21:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b24:	0f b6 01             	movzbl (%ecx),%eax
  800b27:	3c 20                	cmp    $0x20,%al
  800b29:	74 f6                	je     800b21 <strtol+0xe>
  800b2b:	3c 09                	cmp    $0x9,%al
  800b2d:	74 f2                	je     800b21 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b2f:	3c 2b                	cmp    $0x2b,%al
  800b31:	75 0a                	jne    800b3d <strtol+0x2a>
		s++;
  800b33:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b36:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3b:	eb 11                	jmp    800b4e <strtol+0x3b>
  800b3d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b42:	3c 2d                	cmp    $0x2d,%al
  800b44:	75 08                	jne    800b4e <strtol+0x3b>
		s++, neg = 1;
  800b46:	83 c1 01             	add    $0x1,%ecx
  800b49:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b54:	75 15                	jne    800b6b <strtol+0x58>
  800b56:	80 39 30             	cmpb   $0x30,(%ecx)
  800b59:	75 10                	jne    800b6b <strtol+0x58>
  800b5b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b5f:	75 7c                	jne    800bdd <strtol+0xca>
		s += 2, base = 16;
  800b61:	83 c1 02             	add    $0x2,%ecx
  800b64:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b69:	eb 16                	jmp    800b81 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b6b:	85 db                	test   %ebx,%ebx
  800b6d:	75 12                	jne    800b81 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b6f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b74:	80 39 30             	cmpb   $0x30,(%ecx)
  800b77:	75 08                	jne    800b81 <strtol+0x6e>
		s++, base = 8;
  800b79:	83 c1 01             	add    $0x1,%ecx
  800b7c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b89:	0f b6 11             	movzbl (%ecx),%edx
  800b8c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	80 fb 09             	cmp    $0x9,%bl
  800b94:	77 08                	ja     800b9e <strtol+0x8b>
			dig = *s - '0';
  800b96:	0f be d2             	movsbl %dl,%edx
  800b99:	83 ea 30             	sub    $0x30,%edx
  800b9c:	eb 22                	jmp    800bc0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b9e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ba1:	89 f3                	mov    %esi,%ebx
  800ba3:	80 fb 19             	cmp    $0x19,%bl
  800ba6:	77 08                	ja     800bb0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ba8:	0f be d2             	movsbl %dl,%edx
  800bab:	83 ea 57             	sub    $0x57,%edx
  800bae:	eb 10                	jmp    800bc0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bb0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bb3:	89 f3                	mov    %esi,%ebx
  800bb5:	80 fb 19             	cmp    $0x19,%bl
  800bb8:	77 16                	ja     800bd0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bba:	0f be d2             	movsbl %dl,%edx
  800bbd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bc0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bc3:	7d 0b                	jge    800bd0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bc5:	83 c1 01             	add    $0x1,%ecx
  800bc8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bcc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bce:	eb b9                	jmp    800b89 <strtol+0x76>

	if (endptr)
  800bd0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd4:	74 0d                	je     800be3 <strtol+0xd0>
		*endptr = (char *) s;
  800bd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd9:	89 0e                	mov    %ecx,(%esi)
  800bdb:	eb 06                	jmp    800be3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdd:	85 db                	test   %ebx,%ebx
  800bdf:	74 98                	je     800b79 <strtol+0x66>
  800be1:	eb 9e                	jmp    800b81 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800be3:	89 c2                	mov    %eax,%edx
  800be5:	f7 da                	neg    %edx
  800be7:	85 ff                	test   %edi,%edi
  800be9:	0f 45 c2             	cmovne %edx,%eax
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	89 c3                	mov    %eax,%ebx
  800c04:	89 c7                	mov    %eax,%edi
  800c06:	89 c6                	mov    %eax,%esi
  800c08:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1f:	89 d1                	mov    %edx,%ecx
  800c21:	89 d3                	mov    %edx,%ebx
  800c23:	89 d7                	mov    %edx,%edi
  800c25:	89 d6                	mov    %edx,%esi
  800c27:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 cb                	mov    %ecx,%ebx
  800c46:	89 cf                	mov    %ecx,%edi
  800c48:	89 ce                	mov    %ecx,%esi
  800c4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7e 17                	jle    800c67 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 03                	push   $0x3
  800c56:	68 bf 2b 80 00       	push   $0x802bbf
  800c5b:	6a 23                	push   $0x23
  800c5d:	68 dc 2b 80 00       	push   $0x802bdc
  800c62:	e8 c5 f5 ff ff       	call   80022c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7f:	89 d1                	mov    %edx,%ecx
  800c81:	89 d3                	mov    %edx,%ebx
  800c83:	89 d7                	mov    %edx,%edi
  800c85:	89 d6                	mov    %edx,%esi
  800c87:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_yield>:

void
sys_yield(void)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	ba 00 00 00 00       	mov    $0x0,%edx
  800c99:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9e:	89 d1                	mov    %edx,%ecx
  800ca0:	89 d3                	mov    %edx,%ebx
  800ca2:	89 d7                	mov    %edx,%edi
  800ca4:	89 d6                	mov    %edx,%esi
  800ca6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	be 00 00 00 00       	mov    $0x0,%esi
  800cbb:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc9:	89 f7                	mov    %esi,%edi
  800ccb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	7e 17                	jle    800ce8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	50                   	push   %eax
  800cd5:	6a 04                	push   $0x4
  800cd7:	68 bf 2b 80 00       	push   $0x802bbf
  800cdc:	6a 23                	push   $0x23
  800cde:	68 dc 2b 80 00       	push   $0x802bdc
  800ce3:	e8 44 f5 ff ff       	call   80022c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d01:	8b 55 08             	mov    0x8(%ebp),%edx
  800d04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d07:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0a:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 17                	jle    800d2a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 05                	push   $0x5
  800d19:	68 bf 2b 80 00       	push   $0x802bbf
  800d1e:	6a 23                	push   $0x23
  800d20:	68 dc 2b 80 00       	push   $0x802bdc
  800d25:	e8 02 f5 ff ff       	call   80022c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d40:	b8 06 00 00 00       	mov    $0x6,%eax
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	89 df                	mov    %ebx,%edi
  800d4d:	89 de                	mov    %ebx,%esi
  800d4f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7e 17                	jle    800d6c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	6a 06                	push   $0x6
  800d5b:	68 bf 2b 80 00       	push   $0x802bbf
  800d60:	6a 23                	push   $0x23
  800d62:	68 dc 2b 80 00       	push   $0x802bdc
  800d67:	e8 c0 f4 ff ff       	call   80022c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d82:	b8 08 00 00 00       	mov    $0x8,%eax
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8d:	89 df                	mov    %ebx,%edi
  800d8f:	89 de                	mov    %ebx,%esi
  800d91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7e 17                	jle    800dae <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 08                	push   $0x8
  800d9d:	68 bf 2b 80 00       	push   $0x802bbf
  800da2:	6a 23                	push   $0x23
  800da4:	68 dc 2b 80 00       	push   $0x802bdc
  800da9:	e8 7e f4 ff ff       	call   80022c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	89 df                	mov    %ebx,%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 17                	jle    800df0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	50                   	push   %eax
  800ddd:	6a 09                	push   $0x9
  800ddf:	68 bf 2b 80 00       	push   $0x802bbf
  800de4:	6a 23                	push   $0x23
  800de6:	68 dc 2b 80 00       	push   $0x802bdc
  800deb:	e8 3c f4 ff ff       	call   80022c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e06:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 df                	mov    %ebx,%edi
  800e13:	89 de                	mov    %ebx,%esi
  800e15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 17                	jle    800e32 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	50                   	push   %eax
  800e1f:	6a 0a                	push   $0xa
  800e21:	68 bf 2b 80 00       	push   $0x802bbf
  800e26:	6a 23                	push   $0x23
  800e28:	68 dc 2b 80 00       	push   $0x802bdc
  800e2d:	e8 fa f3 ff ff       	call   80022c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e40:	be 00 00 00 00       	mov    $0x0,%esi
  800e45:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e53:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e56:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 cb                	mov    %ecx,%ebx
  800e75:	89 cf                	mov    %ecx,%edi
  800e77:	89 ce                	mov    %ecx,%esi
  800e79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	7e 17                	jle    800e96 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7f:	83 ec 0c             	sub    $0xc,%esp
  800e82:	50                   	push   %eax
  800e83:	6a 0d                	push   $0xd
  800e85:	68 bf 2b 80 00       	push   $0x802bbf
  800e8a:	6a 23                	push   $0x23
  800e8c:	68 dc 2b 80 00       	push   $0x802bdc
  800e91:	e8 96 f3 ff ff       	call   80022c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e99:	5b                   	pop    %ebx
  800e9a:	5e                   	pop    %esi
  800e9b:	5f                   	pop    %edi
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eae:	89 d1                	mov    %edx,%ecx
  800eb0:	89 d3                	mov    %edx,%ebx
  800eb2:	89 d7                	mov    %edx,%edi
  800eb4:	89 d6                	mov    %edx,%esi
  800eb6:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 04             	sub    $0x4,%esp
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ec7:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800ec9:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ecc:	f6 c1 02             	test   $0x2,%cl
  800ecf:	74 2e                	je     800eff <pgfault+0x42>
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	c1 ea 16             	shr    $0x16,%edx
  800ed6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800edd:	f6 c2 01             	test   $0x1,%dl
  800ee0:	74 1d                	je     800eff <pgfault+0x42>
  800ee2:	89 c2                	mov    %eax,%edx
  800ee4:	c1 ea 0c             	shr    $0xc,%edx
  800ee7:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800eee:	f6 c3 01             	test   $0x1,%bl
  800ef1:	74 0c                	je     800eff <pgfault+0x42>
  800ef3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efa:	f6 c6 08             	test   $0x8,%dh
  800efd:	75 12                	jne    800f11 <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800eff:	51                   	push   %ecx
  800f00:	68 ea 2b 80 00       	push   $0x802bea
  800f05:	6a 1e                	push   $0x1e
  800f07:	68 03 2c 80 00       	push   $0x802c03
  800f0c:	e8 1b f3 ff ff       	call   80022c <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800f11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f16:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800f18:	83 ec 04             	sub    $0x4,%esp
  800f1b:	6a 07                	push   $0x7
  800f1d:	68 00 f0 7f 00       	push   $0x7ff000
  800f22:	6a 00                	push   $0x0
  800f24:	e8 84 fd ff ff       	call   800cad <sys_page_alloc>
  800f29:	83 c4 10             	add    $0x10,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	79 12                	jns    800f42 <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800f30:	50                   	push   %eax
  800f31:	68 0e 2c 80 00       	push   $0x802c0e
  800f36:	6a 29                	push   $0x29
  800f38:	68 03 2c 80 00       	push   $0x802c03
  800f3d:	e8 ea f2 ff ff       	call   80022c <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800f42:	83 ec 04             	sub    $0x4,%esp
  800f45:	68 00 10 00 00       	push   $0x1000
  800f4a:	53                   	push   %ebx
  800f4b:	68 00 f0 7f 00       	push   $0x7ff000
  800f50:	e8 4f fb ff ff       	call   800aa4 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f55:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f5c:	53                   	push   %ebx
  800f5d:	6a 00                	push   $0x0
  800f5f:	68 00 f0 7f 00       	push   $0x7ff000
  800f64:	6a 00                	push   $0x0
  800f66:	e8 85 fd ff ff       	call   800cf0 <sys_page_map>
  800f6b:	83 c4 20             	add    $0x20,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	79 12                	jns    800f84 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800f72:	50                   	push   %eax
  800f73:	68 29 2c 80 00       	push   $0x802c29
  800f78:	6a 2e                	push   $0x2e
  800f7a:	68 03 2c 80 00       	push   $0x802c03
  800f7f:	e8 a8 f2 ff ff       	call   80022c <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800f84:	83 ec 08             	sub    $0x8,%esp
  800f87:	68 00 f0 7f 00       	push   $0x7ff000
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 9f fd ff ff       	call   800d32 <sys_page_unmap>
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	79 12                	jns    800fac <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800f9a:	50                   	push   %eax
  800f9b:	68 42 2c 80 00       	push   $0x802c42
  800fa0:	6a 31                	push   $0x31
  800fa2:	68 03 2c 80 00       	push   $0x802c03
  800fa7:	e8 80 f2 ff ff       	call   80022c <_panic>

}
  800fac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	57                   	push   %edi
  800fb5:	56                   	push   %esi
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800fba:	68 bd 0e 80 00       	push   $0x800ebd
  800fbf:	e8 80 14 00 00       	call   802444 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fc4:	b8 07 00 00 00       	mov    $0x7,%eax
  800fc9:	cd 30                	int    $0x30
  800fcb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	75 21                	jne    800ffe <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fdd:	e8 8d fc ff ff       	call   800c6f <sys_getenvid>
  800fe2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fef:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff9:	e9 c9 01 00 00       	jmp    8011c7 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  800ffe:	89 d8                	mov    %ebx,%eax
  801000:	c1 e8 16             	shr    $0x16,%eax
  801003:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80100a:	a8 01                	test   $0x1,%al
  80100c:	0f 84 1b 01 00 00    	je     80112d <fork+0x17c>
  801012:	89 de                	mov    %ebx,%esi
  801014:	c1 ee 0c             	shr    $0xc,%esi
  801017:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80101e:	a8 01                	test   $0x1,%al
  801020:	0f 84 07 01 00 00    	je     80112d <fork+0x17c>
  801026:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80102d:	a8 04                	test   $0x4,%al
  80102f:	0f 84 f8 00 00 00    	je     80112d <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  801035:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80103c:	f6 c4 04             	test   $0x4,%ah
  80103f:	74 3c                	je     80107d <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  801041:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801048:	c1 e6 0c             	shl    $0xc,%esi
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	25 07 0e 00 00       	and    $0xe07,%eax
  801053:	50                   	push   %eax
  801054:	56                   	push   %esi
  801055:	ff 75 e4             	pushl  -0x1c(%ebp)
  801058:	56                   	push   %esi
  801059:	6a 00                	push   $0x0
  80105b:	e8 90 fc ff ff       	call   800cf0 <sys_page_map>
  801060:	83 c4 20             	add    $0x20,%esp
  801063:	85 c0                	test   %eax,%eax
  801065:	0f 89 c2 00 00 00    	jns    80112d <fork+0x17c>
			panic("duppage: %e", r);
  80106b:	50                   	push   %eax
  80106c:	68 5d 2c 80 00       	push   $0x802c5d
  801071:	6a 48                	push   $0x48
  801073:	68 03 2c 80 00       	push   $0x802c03
  801078:	e8 af f1 ff ff       	call   80022c <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  80107d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801084:	f6 c4 08             	test   $0x8,%ah
  801087:	75 0b                	jne    801094 <fork+0xe3>
  801089:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801090:	a8 02                	test   $0x2,%al
  801092:	74 6c                	je     801100 <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  801094:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109b:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  80109e:	83 f8 01             	cmp    $0x1,%eax
  8010a1:	19 ff                	sbb    %edi,%edi
  8010a3:	83 e7 fc             	and    $0xfffffffc,%edi
  8010a6:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  8010ac:	c1 e6 0c             	shl    $0xc,%esi
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	57                   	push   %edi
  8010b3:	56                   	push   %esi
  8010b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b7:	56                   	push   %esi
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 31 fc ff ff       	call   800cf0 <sys_page_map>
  8010bf:	83 c4 20             	add    $0x20,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	79 12                	jns    8010d8 <fork+0x127>
			panic("duppage: %e", r);
  8010c6:	50                   	push   %eax
  8010c7:	68 5d 2c 80 00       	push   $0x802c5d
  8010cc:	6a 50                	push   $0x50
  8010ce:	68 03 2c 80 00       	push   $0x802c03
  8010d3:	e8 54 f1 ff ff       	call   80022c <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  8010d8:	83 ec 0c             	sub    $0xc,%esp
  8010db:	57                   	push   %edi
  8010dc:	56                   	push   %esi
  8010dd:	6a 00                	push   $0x0
  8010df:	56                   	push   %esi
  8010e0:	6a 00                	push   $0x0
  8010e2:	e8 09 fc ff ff       	call   800cf0 <sys_page_map>
  8010e7:	83 c4 20             	add    $0x20,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	79 3f                	jns    80112d <fork+0x17c>
			panic("duppage: %e", r);
  8010ee:	50                   	push   %eax
  8010ef:	68 5d 2c 80 00       	push   $0x802c5d
  8010f4:	6a 53                	push   $0x53
  8010f6:	68 03 2c 80 00       	push   $0x802c03
  8010fb:	e8 2c f1 ff ff       	call   80022c <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  801100:	c1 e6 0c             	shl    $0xc,%esi
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	6a 05                	push   $0x5
  801108:	56                   	push   %esi
  801109:	ff 75 e4             	pushl  -0x1c(%ebp)
  80110c:	56                   	push   %esi
  80110d:	6a 00                	push   $0x0
  80110f:	e8 dc fb ff ff       	call   800cf0 <sys_page_map>
  801114:	83 c4 20             	add    $0x20,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	79 12                	jns    80112d <fork+0x17c>
			panic("duppage: %e", r);
  80111b:	50                   	push   %eax
  80111c:	68 5d 2c 80 00       	push   $0x802c5d
  801121:	6a 57                	push   $0x57
  801123:	68 03 2c 80 00       	push   $0x802c03
  801128:	e8 ff f0 ff ff       	call   80022c <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  80112d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801133:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801139:	0f 85 bf fe ff ff    	jne    800ffe <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80113f:	83 ec 04             	sub    $0x4,%esp
  801142:	6a 07                	push   $0x7
  801144:	68 00 f0 bf ee       	push   $0xeebff000
  801149:	ff 75 e0             	pushl  -0x20(%ebp)
  80114c:	e8 5c fb ff ff       	call   800cad <sys_page_alloc>
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	74 17                	je     80116f <fork+0x1be>
		panic("sys_page_alloc Error");
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	68 69 2c 80 00       	push   $0x802c69
  801160:	68 83 00 00 00       	push   $0x83
  801165:	68 03 2c 80 00       	push   $0x802c03
  80116a:	e8 bd f0 ff ff       	call   80022c <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  80116f:	83 ec 08             	sub    $0x8,%esp
  801172:	68 b3 24 80 00       	push   $0x8024b3
  801177:	ff 75 e0             	pushl  -0x20(%ebp)
  80117a:	e8 79 fc ff ff       	call   800df8 <sys_env_set_pgfault_upcall>
  80117f:	83 c4 10             	add    $0x10,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	79 15                	jns    80119b <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  801186:	50                   	push   %eax
  801187:	68 7e 2c 80 00       	push   $0x802c7e
  80118c:	68 86 00 00 00       	push   $0x86
  801191:	68 03 2c 80 00       	push   $0x802c03
  801196:	e8 91 f0 ff ff       	call   80022c <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  80119b:	83 ec 08             	sub    $0x8,%esp
  80119e:	6a 02                	push   $0x2
  8011a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a3:	e8 cc fb ff ff       	call   800d74 <sys_env_set_status>
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	79 15                	jns    8011c4 <fork+0x213>
		panic("fork set status: %e", r);
  8011af:	50                   	push   %eax
  8011b0:	68 96 2c 80 00       	push   $0x802c96
  8011b5:	68 89 00 00 00       	push   $0x89
  8011ba:	68 03 2c 80 00       	push   $0x802c03
  8011bf:	e8 68 f0 ff ff       	call   80022c <_panic>
	
	return envid;
  8011c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8011c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ca:	5b                   	pop    %ebx
  8011cb:	5e                   	pop    %esi
  8011cc:	5f                   	pop    %edi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <sfork>:


// Challenge!
int
sfork(void)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011d5:	68 aa 2c 80 00       	push   $0x802caa
  8011da:	68 93 00 00 00       	push   $0x93
  8011df:	68 03 2c 80 00       	push   $0x802c03
  8011e4:	e8 43 f0 ff ff       	call   80022c <_panic>

008011e9 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	56                   	push   %esi
  8011ed:	53                   	push   %ebx
  8011ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	74 0e                	je     801209 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8011fb:	83 ec 0c             	sub    $0xc,%esp
  8011fe:	50                   	push   %eax
  8011ff:	e8 59 fc ff ff       	call   800e5d <sys_ipc_recv>
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	eb 10                	jmp    801219 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801209:	83 ec 0c             	sub    $0xc,%esp
  80120c:	68 00 00 c0 ee       	push   $0xeec00000
  801211:	e8 47 fc ff ff       	call   800e5d <sys_ipc_recv>
  801216:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801219:	85 c0                	test   %eax,%eax
  80121b:	79 17                	jns    801234 <ipc_recv+0x4b>
		if(*from_env_store)
  80121d:	83 3e 00             	cmpl   $0x0,(%esi)
  801220:	74 06                	je     801228 <ipc_recv+0x3f>
			*from_env_store = 0;
  801222:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801228:	85 db                	test   %ebx,%ebx
  80122a:	74 2c                	je     801258 <ipc_recv+0x6f>
			*perm_store = 0;
  80122c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801232:	eb 24                	jmp    801258 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801234:	85 f6                	test   %esi,%esi
  801236:	74 0a                	je     801242 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801238:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80123d:	8b 40 74             	mov    0x74(%eax),%eax
  801240:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801242:	85 db                	test   %ebx,%ebx
  801244:	74 0a                	je     801250 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801246:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80124b:	8b 40 78             	mov    0x78(%eax),%eax
  80124e:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801250:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801255:	8b 40 70             	mov    0x70(%eax),%eax
}
  801258:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80125b:	5b                   	pop    %ebx
  80125c:	5e                   	pop    %esi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	57                   	push   %edi
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 0c             	sub    $0xc,%esp
  801268:	8b 7d 08             	mov    0x8(%ebp),%edi
  80126b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80126e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801271:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801273:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801278:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  80127b:	e8 0e fa ff ff       	call   800c8e <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801280:	ff 75 14             	pushl  0x14(%ebp)
  801283:	53                   	push   %ebx
  801284:	56                   	push   %esi
  801285:	57                   	push   %edi
  801286:	e8 af fb ff ff       	call   800e3a <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  80128b:	89 c2                	mov    %eax,%edx
  80128d:	f7 d2                	not    %edx
  80128f:	c1 ea 1f             	shr    $0x1f,%edx
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801298:	0f 94 c1             	sete   %cl
  80129b:	09 ca                	or     %ecx,%edx
  80129d:	85 c0                	test   %eax,%eax
  80129f:	0f 94 c0             	sete   %al
  8012a2:	38 c2                	cmp    %al,%dl
  8012a4:	77 d5                	ja     80127b <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8012a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a9:	5b                   	pop    %ebx
  8012aa:	5e                   	pop    %esi
  8012ab:	5f                   	pop    %edi
  8012ac:	5d                   	pop    %ebp
  8012ad:	c3                   	ret    

008012ae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
  8012b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012b4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012b9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012bc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012c2:	8b 52 50             	mov    0x50(%edx),%edx
  8012c5:	39 ca                	cmp    %ecx,%edx
  8012c7:	75 0d                	jne    8012d6 <ipc_find_env+0x28>
			return envs[i].env_id;
  8012c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012d1:	8b 40 48             	mov    0x48(%eax),%eax
  8012d4:	eb 0f                	jmp    8012e5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012d6:	83 c0 01             	add    $0x1,%eax
  8012d9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012de:	75 d9                	jne    8012b9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ed:	05 00 00 00 30       	add    $0x30000000,%eax
  8012f2:	c1 e8 0c             	shr    $0xc,%eax
}
  8012f5:	5d                   	pop    %ebp
  8012f6:	c3                   	ret    

008012f7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fd:	05 00 00 00 30       	add    $0x30000000,%eax
  801302:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801307:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801314:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801319:	89 c2                	mov    %eax,%edx
  80131b:	c1 ea 16             	shr    $0x16,%edx
  80131e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801325:	f6 c2 01             	test   $0x1,%dl
  801328:	74 11                	je     80133b <fd_alloc+0x2d>
  80132a:	89 c2                	mov    %eax,%edx
  80132c:	c1 ea 0c             	shr    $0xc,%edx
  80132f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801336:	f6 c2 01             	test   $0x1,%dl
  801339:	75 09                	jne    801344 <fd_alloc+0x36>
			*fd_store = fd;
  80133b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80133d:	b8 00 00 00 00       	mov    $0x0,%eax
  801342:	eb 17                	jmp    80135b <fd_alloc+0x4d>
  801344:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801349:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80134e:	75 c9                	jne    801319 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801350:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801356:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80135b:	5d                   	pop    %ebp
  80135c:	c3                   	ret    

0080135d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801363:	83 f8 1f             	cmp    $0x1f,%eax
  801366:	77 36                	ja     80139e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801368:	c1 e0 0c             	shl    $0xc,%eax
  80136b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801370:	89 c2                	mov    %eax,%edx
  801372:	c1 ea 16             	shr    $0x16,%edx
  801375:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80137c:	f6 c2 01             	test   $0x1,%dl
  80137f:	74 24                	je     8013a5 <fd_lookup+0x48>
  801381:	89 c2                	mov    %eax,%edx
  801383:	c1 ea 0c             	shr    $0xc,%edx
  801386:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80138d:	f6 c2 01             	test   $0x1,%dl
  801390:	74 1a                	je     8013ac <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801392:	8b 55 0c             	mov    0xc(%ebp),%edx
  801395:	89 02                	mov    %eax,(%edx)
	return 0;
  801397:	b8 00 00 00 00       	mov    $0x0,%eax
  80139c:	eb 13                	jmp    8013b1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80139e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a3:	eb 0c                	jmp    8013b1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013aa:	eb 05                	jmp    8013b1 <fd_lookup+0x54>
  8013ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    

008013b3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013bc:	ba 40 2d 80 00       	mov    $0x802d40,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013c1:	eb 13                	jmp    8013d6 <dev_lookup+0x23>
  8013c3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013c6:	39 08                	cmp    %ecx,(%eax)
  8013c8:	75 0c                	jne    8013d6 <dev_lookup+0x23>
			*dev = devtab[i];
  8013ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013cd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d4:	eb 2e                	jmp    801404 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013d6:	8b 02                	mov    (%edx),%eax
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	75 e7                	jne    8013c3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013dc:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8013e1:	8b 40 48             	mov    0x48(%eax),%eax
  8013e4:	83 ec 04             	sub    $0x4,%esp
  8013e7:	51                   	push   %ecx
  8013e8:	50                   	push   %eax
  8013e9:	68 c0 2c 80 00       	push   $0x802cc0
  8013ee:	e8 12 ef ff ff       	call   800305 <cprintf>
	*dev = 0;
  8013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801404:	c9                   	leave  
  801405:	c3                   	ret    

00801406 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	56                   	push   %esi
  80140a:	53                   	push   %ebx
  80140b:	83 ec 10             	sub    $0x10,%esp
  80140e:	8b 75 08             	mov    0x8(%ebp),%esi
  801411:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801414:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80141e:	c1 e8 0c             	shr    $0xc,%eax
  801421:	50                   	push   %eax
  801422:	e8 36 ff ff ff       	call   80135d <fd_lookup>
  801427:	83 c4 08             	add    $0x8,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 05                	js     801433 <fd_close+0x2d>
	    || fd != fd2)
  80142e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801431:	74 0c                	je     80143f <fd_close+0x39>
		return (must_exist ? r : 0);
  801433:	84 db                	test   %bl,%bl
  801435:	ba 00 00 00 00       	mov    $0x0,%edx
  80143a:	0f 44 c2             	cmove  %edx,%eax
  80143d:	eb 41                	jmp    801480 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80143f:	83 ec 08             	sub    $0x8,%esp
  801442:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	ff 36                	pushl  (%esi)
  801448:	e8 66 ff ff ff       	call   8013b3 <dev_lookup>
  80144d:	89 c3                	mov    %eax,%ebx
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 1a                	js     801470 <fd_close+0x6a>
		if (dev->dev_close)
  801456:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801459:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80145c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801461:	85 c0                	test   %eax,%eax
  801463:	74 0b                	je     801470 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	56                   	push   %esi
  801469:	ff d0                	call   *%eax
  80146b:	89 c3                	mov    %eax,%ebx
  80146d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	56                   	push   %esi
  801474:	6a 00                	push   $0x0
  801476:	e8 b7 f8 ff ff       	call   800d32 <sys_page_unmap>
	return r;
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	89 d8                	mov    %ebx,%eax
}
  801480:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80148d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801490:	50                   	push   %eax
  801491:	ff 75 08             	pushl  0x8(%ebp)
  801494:	e8 c4 fe ff ff       	call   80135d <fd_lookup>
  801499:	83 c4 08             	add    $0x8,%esp
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 10                	js     8014b0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	6a 01                	push   $0x1
  8014a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a8:	e8 59 ff ff ff       	call   801406 <fd_close>
  8014ad:	83 c4 10             	add    $0x10,%esp
}
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    

008014b2 <close_all>:

void
close_all(void)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	53                   	push   %ebx
  8014b6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014be:	83 ec 0c             	sub    $0xc,%esp
  8014c1:	53                   	push   %ebx
  8014c2:	e8 c0 ff ff ff       	call   801487 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014c7:	83 c3 01             	add    $0x1,%ebx
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	83 fb 20             	cmp    $0x20,%ebx
  8014d0:	75 ec                	jne    8014be <close_all+0xc>
		close(i);
}
  8014d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    

008014d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	57                   	push   %edi
  8014db:	56                   	push   %esi
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 2c             	sub    $0x2c,%esp
  8014e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014e6:	50                   	push   %eax
  8014e7:	ff 75 08             	pushl  0x8(%ebp)
  8014ea:	e8 6e fe ff ff       	call   80135d <fd_lookup>
  8014ef:	83 c4 08             	add    $0x8,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	0f 88 c1 00 00 00    	js     8015bb <dup+0xe4>
		return r;
	close(newfdnum);
  8014fa:	83 ec 0c             	sub    $0xc,%esp
  8014fd:	56                   	push   %esi
  8014fe:	e8 84 ff ff ff       	call   801487 <close>

	newfd = INDEX2FD(newfdnum);
  801503:	89 f3                	mov    %esi,%ebx
  801505:	c1 e3 0c             	shl    $0xc,%ebx
  801508:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80150e:	83 c4 04             	add    $0x4,%esp
  801511:	ff 75 e4             	pushl  -0x1c(%ebp)
  801514:	e8 de fd ff ff       	call   8012f7 <fd2data>
  801519:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80151b:	89 1c 24             	mov    %ebx,(%esp)
  80151e:	e8 d4 fd ff ff       	call   8012f7 <fd2data>
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801529:	89 f8                	mov    %edi,%eax
  80152b:	c1 e8 16             	shr    $0x16,%eax
  80152e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801535:	a8 01                	test   $0x1,%al
  801537:	74 37                	je     801570 <dup+0x99>
  801539:	89 f8                	mov    %edi,%eax
  80153b:	c1 e8 0c             	shr    $0xc,%eax
  80153e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801545:	f6 c2 01             	test   $0x1,%dl
  801548:	74 26                	je     801570 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80154a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801551:	83 ec 0c             	sub    $0xc,%esp
  801554:	25 07 0e 00 00       	and    $0xe07,%eax
  801559:	50                   	push   %eax
  80155a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80155d:	6a 00                	push   $0x0
  80155f:	57                   	push   %edi
  801560:	6a 00                	push   $0x0
  801562:	e8 89 f7 ff ff       	call   800cf0 <sys_page_map>
  801567:	89 c7                	mov    %eax,%edi
  801569:	83 c4 20             	add    $0x20,%esp
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 2e                	js     80159e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801570:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801573:	89 d0                	mov    %edx,%eax
  801575:	c1 e8 0c             	shr    $0xc,%eax
  801578:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157f:	83 ec 0c             	sub    $0xc,%esp
  801582:	25 07 0e 00 00       	and    $0xe07,%eax
  801587:	50                   	push   %eax
  801588:	53                   	push   %ebx
  801589:	6a 00                	push   $0x0
  80158b:	52                   	push   %edx
  80158c:	6a 00                	push   $0x0
  80158e:	e8 5d f7 ff ff       	call   800cf0 <sys_page_map>
  801593:	89 c7                	mov    %eax,%edi
  801595:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801598:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80159a:	85 ff                	test   %edi,%edi
  80159c:	79 1d                	jns    8015bb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	53                   	push   %ebx
  8015a2:	6a 00                	push   $0x0
  8015a4:	e8 89 f7 ff ff       	call   800d32 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015a9:	83 c4 08             	add    $0x8,%esp
  8015ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015af:	6a 00                	push   $0x0
  8015b1:	e8 7c f7 ff ff       	call   800d32 <sys_page_unmap>
	return r;
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	89 f8                	mov    %edi,%eax
}
  8015bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015be:	5b                   	pop    %ebx
  8015bf:	5e                   	pop    %esi
  8015c0:	5f                   	pop    %edi
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    

008015c3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 14             	sub    $0x14,%esp
  8015ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d0:	50                   	push   %eax
  8015d1:	53                   	push   %ebx
  8015d2:	e8 86 fd ff ff       	call   80135d <fd_lookup>
  8015d7:	83 c4 08             	add    $0x8,%esp
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 6d                	js     80164d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ea:	ff 30                	pushl  (%eax)
  8015ec:	e8 c2 fd ff ff       	call   8013b3 <dev_lookup>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 4c                	js     801644 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015fb:	8b 42 08             	mov    0x8(%edx),%eax
  8015fe:	83 e0 03             	and    $0x3,%eax
  801601:	83 f8 01             	cmp    $0x1,%eax
  801604:	75 21                	jne    801627 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801606:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80160b:	8b 40 48             	mov    0x48(%eax),%eax
  80160e:	83 ec 04             	sub    $0x4,%esp
  801611:	53                   	push   %ebx
  801612:	50                   	push   %eax
  801613:	68 04 2d 80 00       	push   $0x802d04
  801618:	e8 e8 ec ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801625:	eb 26                	jmp    80164d <read+0x8a>
	}
	if (!dev->dev_read)
  801627:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162a:	8b 40 08             	mov    0x8(%eax),%eax
  80162d:	85 c0                	test   %eax,%eax
  80162f:	74 17                	je     801648 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801631:	83 ec 04             	sub    $0x4,%esp
  801634:	ff 75 10             	pushl  0x10(%ebp)
  801637:	ff 75 0c             	pushl  0xc(%ebp)
  80163a:	52                   	push   %edx
  80163b:	ff d0                	call   *%eax
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	eb 09                	jmp    80164d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801644:	89 c2                	mov    %eax,%edx
  801646:	eb 05                	jmp    80164d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801648:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80164d:	89 d0                	mov    %edx,%eax
  80164f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	57                   	push   %edi
  801658:	56                   	push   %esi
  801659:	53                   	push   %ebx
  80165a:	83 ec 0c             	sub    $0xc,%esp
  80165d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801660:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801663:	bb 00 00 00 00       	mov    $0x0,%ebx
  801668:	eb 21                	jmp    80168b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80166a:	83 ec 04             	sub    $0x4,%esp
  80166d:	89 f0                	mov    %esi,%eax
  80166f:	29 d8                	sub    %ebx,%eax
  801671:	50                   	push   %eax
  801672:	89 d8                	mov    %ebx,%eax
  801674:	03 45 0c             	add    0xc(%ebp),%eax
  801677:	50                   	push   %eax
  801678:	57                   	push   %edi
  801679:	e8 45 ff ff ff       	call   8015c3 <read>
		if (m < 0)
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	85 c0                	test   %eax,%eax
  801683:	78 10                	js     801695 <readn+0x41>
			return m;
		if (m == 0)
  801685:	85 c0                	test   %eax,%eax
  801687:	74 0a                	je     801693 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801689:	01 c3                	add    %eax,%ebx
  80168b:	39 f3                	cmp    %esi,%ebx
  80168d:	72 db                	jb     80166a <readn+0x16>
  80168f:	89 d8                	mov    %ebx,%eax
  801691:	eb 02                	jmp    801695 <readn+0x41>
  801693:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801695:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801698:	5b                   	pop    %ebx
  801699:	5e                   	pop    %esi
  80169a:	5f                   	pop    %edi
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	53                   	push   %ebx
  8016a1:	83 ec 14             	sub    $0x14,%esp
  8016a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016aa:	50                   	push   %eax
  8016ab:	53                   	push   %ebx
  8016ac:	e8 ac fc ff ff       	call   80135d <fd_lookup>
  8016b1:	83 c4 08             	add    $0x8,%esp
  8016b4:	89 c2                	mov    %eax,%edx
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 68                	js     801722 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ba:	83 ec 08             	sub    $0x8,%esp
  8016bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c0:	50                   	push   %eax
  8016c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c4:	ff 30                	pushl  (%eax)
  8016c6:	e8 e8 fc ff ff       	call   8013b3 <dev_lookup>
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	78 47                	js     801719 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d9:	75 21                	jne    8016fc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016db:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8016e0:	8b 40 48             	mov    0x48(%eax),%eax
  8016e3:	83 ec 04             	sub    $0x4,%esp
  8016e6:	53                   	push   %ebx
  8016e7:	50                   	push   %eax
  8016e8:	68 20 2d 80 00       	push   $0x802d20
  8016ed:	e8 13 ec ff ff       	call   800305 <cprintf>
		return -E_INVAL;
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016fa:	eb 26                	jmp    801722 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801702:	85 d2                	test   %edx,%edx
  801704:	74 17                	je     80171d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801706:	83 ec 04             	sub    $0x4,%esp
  801709:	ff 75 10             	pushl  0x10(%ebp)
  80170c:	ff 75 0c             	pushl  0xc(%ebp)
  80170f:	50                   	push   %eax
  801710:	ff d2                	call   *%edx
  801712:	89 c2                	mov    %eax,%edx
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	eb 09                	jmp    801722 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801719:	89 c2                	mov    %eax,%edx
  80171b:	eb 05                	jmp    801722 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80171d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801722:	89 d0                	mov    %edx,%eax
  801724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <seek>:

int
seek(int fdnum, off_t offset)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80172f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801732:	50                   	push   %eax
  801733:	ff 75 08             	pushl  0x8(%ebp)
  801736:	e8 22 fc ff ff       	call   80135d <fd_lookup>
  80173b:	83 c4 08             	add    $0x8,%esp
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 0e                	js     801750 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801742:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801745:	8b 55 0c             	mov    0xc(%ebp),%edx
  801748:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80174b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	53                   	push   %ebx
  801756:	83 ec 14             	sub    $0x14,%esp
  801759:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175f:	50                   	push   %eax
  801760:	53                   	push   %ebx
  801761:	e8 f7 fb ff ff       	call   80135d <fd_lookup>
  801766:	83 c4 08             	add    $0x8,%esp
  801769:	89 c2                	mov    %eax,%edx
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 65                	js     8017d4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176f:	83 ec 08             	sub    $0x8,%esp
  801772:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801775:	50                   	push   %eax
  801776:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801779:	ff 30                	pushl  (%eax)
  80177b:	e8 33 fc ff ff       	call   8013b3 <dev_lookup>
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	78 44                	js     8017cb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80178e:	75 21                	jne    8017b1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801790:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801795:	8b 40 48             	mov    0x48(%eax),%eax
  801798:	83 ec 04             	sub    $0x4,%esp
  80179b:	53                   	push   %ebx
  80179c:	50                   	push   %eax
  80179d:	68 e0 2c 80 00       	push   $0x802ce0
  8017a2:	e8 5e eb ff ff       	call   800305 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017af:	eb 23                	jmp    8017d4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b4:	8b 52 18             	mov    0x18(%edx),%edx
  8017b7:	85 d2                	test   %edx,%edx
  8017b9:	74 14                	je     8017cf <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	ff 75 0c             	pushl  0xc(%ebp)
  8017c1:	50                   	push   %eax
  8017c2:	ff d2                	call   *%edx
  8017c4:	89 c2                	mov    %eax,%edx
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	eb 09                	jmp    8017d4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cb:	89 c2                	mov    %eax,%edx
  8017cd:	eb 05                	jmp    8017d4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017d4:	89 d0                	mov    %edx,%eax
  8017d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	53                   	push   %ebx
  8017df:	83 ec 14             	sub    $0x14,%esp
  8017e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e8:	50                   	push   %eax
  8017e9:	ff 75 08             	pushl  0x8(%ebp)
  8017ec:	e8 6c fb ff ff       	call   80135d <fd_lookup>
  8017f1:	83 c4 08             	add    $0x8,%esp
  8017f4:	89 c2                	mov    %eax,%edx
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 58                	js     801852 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801800:	50                   	push   %eax
  801801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801804:	ff 30                	pushl  (%eax)
  801806:	e8 a8 fb ff ff       	call   8013b3 <dev_lookup>
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 37                	js     801849 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801812:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801815:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801819:	74 32                	je     80184d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80181b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80181e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801825:	00 00 00 
	stat->st_isdir = 0;
  801828:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80182f:	00 00 00 
	stat->st_dev = dev;
  801832:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801838:	83 ec 08             	sub    $0x8,%esp
  80183b:	53                   	push   %ebx
  80183c:	ff 75 f0             	pushl  -0x10(%ebp)
  80183f:	ff 50 14             	call   *0x14(%eax)
  801842:	89 c2                	mov    %eax,%edx
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	eb 09                	jmp    801852 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801849:	89 c2                	mov    %eax,%edx
  80184b:	eb 05                	jmp    801852 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80184d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801852:	89 d0                	mov    %edx,%eax
  801854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	56                   	push   %esi
  80185d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	6a 00                	push   $0x0
  801863:	ff 75 08             	pushl  0x8(%ebp)
  801866:	e8 ef 01 00 00       	call   801a5a <open>
  80186b:	89 c3                	mov    %eax,%ebx
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	85 c0                	test   %eax,%eax
  801872:	78 1b                	js     80188f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801874:	83 ec 08             	sub    $0x8,%esp
  801877:	ff 75 0c             	pushl  0xc(%ebp)
  80187a:	50                   	push   %eax
  80187b:	e8 5b ff ff ff       	call   8017db <fstat>
  801880:	89 c6                	mov    %eax,%esi
	close(fd);
  801882:	89 1c 24             	mov    %ebx,(%esp)
  801885:	e8 fd fb ff ff       	call   801487 <close>
	return r;
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	89 f0                	mov    %esi,%eax
}
  80188f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801892:	5b                   	pop    %ebx
  801893:	5e                   	pop    %esi
  801894:	5d                   	pop    %ebp
  801895:	c3                   	ret    

00801896 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	56                   	push   %esi
  80189a:	53                   	push   %ebx
  80189b:	89 c6                	mov    %eax,%esi
  80189d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80189f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018a6:	75 12                	jne    8018ba <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018a8:	83 ec 0c             	sub    $0xc,%esp
  8018ab:	6a 01                	push   $0x1
  8018ad:	e8 fc f9 ff ff       	call   8012ae <ipc_find_env>
  8018b2:	a3 04 40 80 00       	mov    %eax,0x804004
  8018b7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ba:	6a 07                	push   $0x7
  8018bc:	68 00 50 80 00       	push   $0x805000
  8018c1:	56                   	push   %esi
  8018c2:	ff 35 04 40 80 00    	pushl  0x804004
  8018c8:	e8 92 f9 ff ff       	call   80125f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018cd:	83 c4 0c             	add    $0xc,%esp
  8018d0:	6a 00                	push   $0x0
  8018d2:	53                   	push   %ebx
  8018d3:	6a 00                	push   $0x0
  8018d5:	e8 0f f9 ff ff       	call   8011e9 <ipc_recv>
}
  8018da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018dd:	5b                   	pop    %ebx
  8018de:	5e                   	pop    %esi
  8018df:	5d                   	pop    %ebp
  8018e0:	c3                   	ret    

008018e1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ed:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ff:	b8 02 00 00 00       	mov    $0x2,%eax
  801904:	e8 8d ff ff ff       	call   801896 <fsipc>
}
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801911:	8b 45 08             	mov    0x8(%ebp),%eax
  801914:	8b 40 0c             	mov    0xc(%eax),%eax
  801917:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80191c:	ba 00 00 00 00       	mov    $0x0,%edx
  801921:	b8 06 00 00 00       	mov    $0x6,%eax
  801926:	e8 6b ff ff ff       	call   801896 <fsipc>
}
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    

0080192d <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	53                   	push   %ebx
  801931:	83 ec 04             	sub    $0x4,%esp
  801934:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801937:	8b 45 08             	mov    0x8(%ebp),%eax
  80193a:	8b 40 0c             	mov    0xc(%eax),%eax
  80193d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801942:	ba 00 00 00 00       	mov    $0x0,%edx
  801947:	b8 05 00 00 00       	mov    $0x5,%eax
  80194c:	e8 45 ff ff ff       	call   801896 <fsipc>
  801951:	85 c0                	test   %eax,%eax
  801953:	78 2c                	js     801981 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	68 00 50 80 00       	push   $0x805000
  80195d:	53                   	push   %ebx
  80195e:	e8 47 ef ff ff       	call   8008aa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801963:	a1 80 50 80 00       	mov    0x805080,%eax
  801968:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80196e:	a1 84 50 80 00       	mov    0x805084,%eax
  801973:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801981:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	53                   	push   %ebx
  80198a:	83 ec 08             	sub    $0x8,%esp
  80198d:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801990:	8b 55 08             	mov    0x8(%ebp),%edx
  801993:	8b 52 0c             	mov    0xc(%edx),%edx
  801996:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80199c:	a3 04 50 80 00       	mov    %eax,0x805004
  8019a1:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8019a6:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8019ab:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019ae:	53                   	push   %ebx
  8019af:	ff 75 0c             	pushl  0xc(%ebp)
  8019b2:	68 08 50 80 00       	push   $0x805008
  8019b7:	e8 80 f0 ff ff       	call   800a3c <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c1:	b8 04 00 00 00       	mov    $0x4,%eax
  8019c6:	e8 cb fe ff ff       	call   801896 <fsipc>
  8019cb:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8019d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019eb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8019fb:	e8 96 fe ff ff       	call   801896 <fsipc>
  801a00:	89 c3                	mov    %eax,%ebx
  801a02:	85 c0                	test   %eax,%eax
  801a04:	78 4b                	js     801a51 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a06:	39 c6                	cmp    %eax,%esi
  801a08:	73 16                	jae    801a20 <devfile_read+0x48>
  801a0a:	68 54 2d 80 00       	push   $0x802d54
  801a0f:	68 5b 2d 80 00       	push   $0x802d5b
  801a14:	6a 7c                	push   $0x7c
  801a16:	68 70 2d 80 00       	push   $0x802d70
  801a1b:	e8 0c e8 ff ff       	call   80022c <_panic>
	assert(r <= PGSIZE);
  801a20:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a25:	7e 16                	jle    801a3d <devfile_read+0x65>
  801a27:	68 7b 2d 80 00       	push   $0x802d7b
  801a2c:	68 5b 2d 80 00       	push   $0x802d5b
  801a31:	6a 7d                	push   $0x7d
  801a33:	68 70 2d 80 00       	push   $0x802d70
  801a38:	e8 ef e7 ff ff       	call   80022c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a3d:	83 ec 04             	sub    $0x4,%esp
  801a40:	50                   	push   %eax
  801a41:	68 00 50 80 00       	push   $0x805000
  801a46:	ff 75 0c             	pushl  0xc(%ebp)
  801a49:	e8 ee ef ff ff       	call   800a3c <memmove>
	return r;
  801a4e:	83 c4 10             	add    $0x10,%esp
}
  801a51:	89 d8                	mov    %ebx,%eax
  801a53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 20             	sub    $0x20,%esp
  801a61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a64:	53                   	push   %ebx
  801a65:	e8 07 ee ff ff       	call   800871 <strlen>
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a72:	7f 67                	jg     801adb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a74:	83 ec 0c             	sub    $0xc,%esp
  801a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7a:	50                   	push   %eax
  801a7b:	e8 8e f8 ff ff       	call   80130e <fd_alloc>
  801a80:	83 c4 10             	add    $0x10,%esp
		return r;
  801a83:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 57                	js     801ae0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a89:	83 ec 08             	sub    $0x8,%esp
  801a8c:	53                   	push   %ebx
  801a8d:	68 00 50 80 00       	push   $0x805000
  801a92:	e8 13 ee ff ff       	call   8008aa <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa2:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa7:	e8 ea fd ff ff       	call   801896 <fsipc>
  801aac:	89 c3                	mov    %eax,%ebx
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	79 14                	jns    801ac9 <open+0x6f>
		fd_close(fd, 0);
  801ab5:	83 ec 08             	sub    $0x8,%esp
  801ab8:	6a 00                	push   $0x0
  801aba:	ff 75 f4             	pushl  -0xc(%ebp)
  801abd:	e8 44 f9 ff ff       	call   801406 <fd_close>
		return r;
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	89 da                	mov    %ebx,%edx
  801ac7:	eb 17                	jmp    801ae0 <open+0x86>
	}

	return fd2num(fd);
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	ff 75 f4             	pushl  -0xc(%ebp)
  801acf:	e8 13 f8 ff ff       	call   8012e7 <fd2num>
  801ad4:	89 c2                	mov    %eax,%edx
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	eb 05                	jmp    801ae0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801adb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ae0:	89 d0                	mov    %edx,%eax
  801ae2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae5:	c9                   	leave  
  801ae6:	c3                   	ret    

00801ae7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aed:	ba 00 00 00 00       	mov    $0x0,%edx
  801af2:	b8 08 00 00 00       	mov    $0x8,%eax
  801af7:	e8 9a fd ff ff       	call   801896 <fsipc>
}
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	56                   	push   %esi
  801b02:	53                   	push   %ebx
  801b03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b06:	83 ec 0c             	sub    $0xc,%esp
  801b09:	ff 75 08             	pushl  0x8(%ebp)
  801b0c:	e8 e6 f7 ff ff       	call   8012f7 <fd2data>
  801b11:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b13:	83 c4 08             	add    $0x8,%esp
  801b16:	68 87 2d 80 00       	push   $0x802d87
  801b1b:	53                   	push   %ebx
  801b1c:	e8 89 ed ff ff       	call   8008aa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b21:	8b 46 04             	mov    0x4(%esi),%eax
  801b24:	2b 06                	sub    (%esi),%eax
  801b26:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b2c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b33:	00 00 00 
	stat->st_dev = &devpipe;
  801b36:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b3d:	30 80 00 
	return 0;
}
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
  801b45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 0c             	sub    $0xc,%esp
  801b53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b56:	53                   	push   %ebx
  801b57:	6a 00                	push   $0x0
  801b59:	e8 d4 f1 ff ff       	call   800d32 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b5e:	89 1c 24             	mov    %ebx,(%esp)
  801b61:	e8 91 f7 ff ff       	call   8012f7 <fd2data>
  801b66:	83 c4 08             	add    $0x8,%esp
  801b69:	50                   	push   %eax
  801b6a:	6a 00                	push   $0x0
  801b6c:	e8 c1 f1 ff ff       	call   800d32 <sys_page_unmap>
}
  801b71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    

00801b76 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	57                   	push   %edi
  801b7a:	56                   	push   %esi
  801b7b:	53                   	push   %ebx
  801b7c:	83 ec 1c             	sub    $0x1c,%esp
  801b7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b82:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b84:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801b89:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b8c:	83 ec 0c             	sub    $0xc,%esp
  801b8f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b92:	e8 43 09 00 00       	call   8024da <pageref>
  801b97:	89 c3                	mov    %eax,%ebx
  801b99:	89 3c 24             	mov    %edi,(%esp)
  801b9c:	e8 39 09 00 00       	call   8024da <pageref>
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	39 c3                	cmp    %eax,%ebx
  801ba6:	0f 94 c1             	sete   %cl
  801ba9:	0f b6 c9             	movzbl %cl,%ecx
  801bac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801baf:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801bb5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bb8:	39 ce                	cmp    %ecx,%esi
  801bba:	74 1b                	je     801bd7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bbc:	39 c3                	cmp    %eax,%ebx
  801bbe:	75 c4                	jne    801b84 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bc0:	8b 42 58             	mov    0x58(%edx),%eax
  801bc3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bc6:	50                   	push   %eax
  801bc7:	56                   	push   %esi
  801bc8:	68 8e 2d 80 00       	push   $0x802d8e
  801bcd:	e8 33 e7 ff ff       	call   800305 <cprintf>
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	eb ad                	jmp    801b84 <_pipeisclosed+0xe>
	}
}
  801bd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    

00801be2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	57                   	push   %edi
  801be6:	56                   	push   %esi
  801be7:	53                   	push   %ebx
  801be8:	83 ec 28             	sub    $0x28,%esp
  801beb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bee:	56                   	push   %esi
  801bef:	e8 03 f7 ff ff       	call   8012f7 <fd2data>
  801bf4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	bf 00 00 00 00       	mov    $0x0,%edi
  801bfe:	eb 4b                	jmp    801c4b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c00:	89 da                	mov    %ebx,%edx
  801c02:	89 f0                	mov    %esi,%eax
  801c04:	e8 6d ff ff ff       	call   801b76 <_pipeisclosed>
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	75 48                	jne    801c55 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c0d:	e8 7c f0 ff ff       	call   800c8e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c12:	8b 43 04             	mov    0x4(%ebx),%eax
  801c15:	8b 0b                	mov    (%ebx),%ecx
  801c17:	8d 51 20             	lea    0x20(%ecx),%edx
  801c1a:	39 d0                	cmp    %edx,%eax
  801c1c:	73 e2                	jae    801c00 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c21:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c25:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c28:	89 c2                	mov    %eax,%edx
  801c2a:	c1 fa 1f             	sar    $0x1f,%edx
  801c2d:	89 d1                	mov    %edx,%ecx
  801c2f:	c1 e9 1b             	shr    $0x1b,%ecx
  801c32:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c35:	83 e2 1f             	and    $0x1f,%edx
  801c38:	29 ca                	sub    %ecx,%edx
  801c3a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c3e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c42:	83 c0 01             	add    $0x1,%eax
  801c45:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c48:	83 c7 01             	add    $0x1,%edi
  801c4b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c4e:	75 c2                	jne    801c12 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c50:	8b 45 10             	mov    0x10(%ebp),%eax
  801c53:	eb 05                	jmp    801c5a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c55:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	57                   	push   %edi
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 18             	sub    $0x18,%esp
  801c6b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c6e:	57                   	push   %edi
  801c6f:	e8 83 f6 ff ff       	call   8012f7 <fd2data>
  801c74:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c7e:	eb 3d                	jmp    801cbd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c80:	85 db                	test   %ebx,%ebx
  801c82:	74 04                	je     801c88 <devpipe_read+0x26>
				return i;
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	eb 44                	jmp    801ccc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c88:	89 f2                	mov    %esi,%edx
  801c8a:	89 f8                	mov    %edi,%eax
  801c8c:	e8 e5 fe ff ff       	call   801b76 <_pipeisclosed>
  801c91:	85 c0                	test   %eax,%eax
  801c93:	75 32                	jne    801cc7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c95:	e8 f4 ef ff ff       	call   800c8e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c9a:	8b 06                	mov    (%esi),%eax
  801c9c:	3b 46 04             	cmp    0x4(%esi),%eax
  801c9f:	74 df                	je     801c80 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ca1:	99                   	cltd   
  801ca2:	c1 ea 1b             	shr    $0x1b,%edx
  801ca5:	01 d0                	add    %edx,%eax
  801ca7:	83 e0 1f             	and    $0x1f,%eax
  801caa:	29 d0                	sub    %edx,%eax
  801cac:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cb7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cba:	83 c3 01             	add    $0x1,%ebx
  801cbd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cc0:	75 d8                	jne    801c9a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc5:	eb 05                	jmp    801ccc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cc7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    

00801cd4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdf:	50                   	push   %eax
  801ce0:	e8 29 f6 ff ff       	call   80130e <fd_alloc>
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	89 c2                	mov    %eax,%edx
  801cea:	85 c0                	test   %eax,%eax
  801cec:	0f 88 2c 01 00 00    	js     801e1e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf2:	83 ec 04             	sub    $0x4,%esp
  801cf5:	68 07 04 00 00       	push   $0x407
  801cfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfd:	6a 00                	push   $0x0
  801cff:	e8 a9 ef ff ff       	call   800cad <sys_page_alloc>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	89 c2                	mov    %eax,%edx
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	0f 88 0d 01 00 00    	js     801e1e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d17:	50                   	push   %eax
  801d18:	e8 f1 f5 ff ff       	call   80130e <fd_alloc>
  801d1d:	89 c3                	mov    %eax,%ebx
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	85 c0                	test   %eax,%eax
  801d24:	0f 88 e2 00 00 00    	js     801e0c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d2a:	83 ec 04             	sub    $0x4,%esp
  801d2d:	68 07 04 00 00       	push   $0x407
  801d32:	ff 75 f0             	pushl  -0x10(%ebp)
  801d35:	6a 00                	push   $0x0
  801d37:	e8 71 ef ff ff       	call   800cad <sys_page_alloc>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	85 c0                	test   %eax,%eax
  801d43:	0f 88 c3 00 00 00    	js     801e0c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d49:	83 ec 0c             	sub    $0xc,%esp
  801d4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4f:	e8 a3 f5 ff ff       	call   8012f7 <fd2data>
  801d54:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d56:	83 c4 0c             	add    $0xc,%esp
  801d59:	68 07 04 00 00       	push   $0x407
  801d5e:	50                   	push   %eax
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 47 ef ff ff       	call   800cad <sys_page_alloc>
  801d66:	89 c3                	mov    %eax,%ebx
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	0f 88 89 00 00 00    	js     801dfc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d73:	83 ec 0c             	sub    $0xc,%esp
  801d76:	ff 75 f0             	pushl  -0x10(%ebp)
  801d79:	e8 79 f5 ff ff       	call   8012f7 <fd2data>
  801d7e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d85:	50                   	push   %eax
  801d86:	6a 00                	push   $0x0
  801d88:	56                   	push   %esi
  801d89:	6a 00                	push   $0x0
  801d8b:	e8 60 ef ff ff       	call   800cf0 <sys_page_map>
  801d90:	89 c3                	mov    %eax,%ebx
  801d92:	83 c4 20             	add    $0x20,%esp
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 55                	js     801dee <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d99:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dbc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dc3:	83 ec 0c             	sub    $0xc,%esp
  801dc6:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc9:	e8 19 f5 ff ff       	call   8012e7 <fd2num>
  801dce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dd3:	83 c4 04             	add    $0x4,%esp
  801dd6:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd9:	e8 09 f5 ff ff       	call   8012e7 <fd2num>
  801dde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dec:	eb 30                	jmp    801e1e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dee:	83 ec 08             	sub    $0x8,%esp
  801df1:	56                   	push   %esi
  801df2:	6a 00                	push   $0x0
  801df4:	e8 39 ef ff ff       	call   800d32 <sys_page_unmap>
  801df9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	ff 75 f0             	pushl  -0x10(%ebp)
  801e02:	6a 00                	push   $0x0
  801e04:	e8 29 ef ff ff       	call   800d32 <sys_page_unmap>
  801e09:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e0c:	83 ec 08             	sub    $0x8,%esp
  801e0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e12:	6a 00                	push   $0x0
  801e14:	e8 19 ef ff ff       	call   800d32 <sys_page_unmap>
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e1e:	89 d0                	mov    %edx,%eax
  801e20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e23:	5b                   	pop    %ebx
  801e24:	5e                   	pop    %esi
  801e25:	5d                   	pop    %ebp
  801e26:	c3                   	ret    

00801e27 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e30:	50                   	push   %eax
  801e31:	ff 75 08             	pushl  0x8(%ebp)
  801e34:	e8 24 f5 ff ff       	call   80135d <fd_lookup>
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 18                	js     801e58 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e40:	83 ec 0c             	sub    $0xc,%esp
  801e43:	ff 75 f4             	pushl  -0xc(%ebp)
  801e46:	e8 ac f4 ff ff       	call   8012f7 <fd2data>
	return _pipeisclosed(fd, p);
  801e4b:	89 c2                	mov    %eax,%edx
  801e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e50:	e8 21 fd ff ff       	call   801b76 <_pipeisclosed>
  801e55:	83 c4 10             	add    $0x10,%esp
}
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801e60:	68 a6 2d 80 00       	push   $0x802da6
  801e65:	ff 75 0c             	pushl  0xc(%ebp)
  801e68:	e8 3d ea ff ff       	call   8008aa <strcpy>
	return 0;
}
  801e6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e72:	c9                   	leave  
  801e73:	c3                   	ret    

00801e74 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	53                   	push   %ebx
  801e78:	83 ec 10             	sub    $0x10,%esp
  801e7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e7e:	53                   	push   %ebx
  801e7f:	e8 56 06 00 00       	call   8024da <pageref>
  801e84:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801e87:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801e8c:	83 f8 01             	cmp    $0x1,%eax
  801e8f:	75 10                	jne    801ea1 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801e91:	83 ec 0c             	sub    $0xc,%esp
  801e94:	ff 73 0c             	pushl  0xc(%ebx)
  801e97:	e8 c0 02 00 00       	call   80215c <nsipc_close>
  801e9c:	89 c2                	mov    %eax,%edx
  801e9e:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ea1:	89 d0                	mov    %edx,%eax
  801ea3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801eae:	6a 00                	push   $0x0
  801eb0:	ff 75 10             	pushl  0x10(%ebp)
  801eb3:	ff 75 0c             	pushl  0xc(%ebp)
  801eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb9:	ff 70 0c             	pushl  0xc(%eax)
  801ebc:	e8 78 03 00 00       	call   802239 <nsipc_send>
}
  801ec1:	c9                   	leave  
  801ec2:	c3                   	ret    

00801ec3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ec9:	6a 00                	push   $0x0
  801ecb:	ff 75 10             	pushl  0x10(%ebp)
  801ece:	ff 75 0c             	pushl  0xc(%ebp)
  801ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed4:	ff 70 0c             	pushl  0xc(%eax)
  801ed7:	e8 f1 02 00 00       	call   8021cd <nsipc_recv>
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ee4:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ee7:	52                   	push   %edx
  801ee8:	50                   	push   %eax
  801ee9:	e8 6f f4 ff ff       	call   80135d <fd_lookup>
  801eee:	83 c4 10             	add    $0x10,%esp
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	78 17                	js     801f0c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef8:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801efe:	39 08                	cmp    %ecx,(%eax)
  801f00:	75 05                	jne    801f07 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f02:	8b 40 0c             	mov    0xc(%eax),%eax
  801f05:	eb 05                	jmp    801f0c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f07:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f0c:	c9                   	leave  
  801f0d:	c3                   	ret    

00801f0e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	83 ec 1c             	sub    $0x1c,%esp
  801f16:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1b:	50                   	push   %eax
  801f1c:	e8 ed f3 ff ff       	call   80130e <fd_alloc>
  801f21:	89 c3                	mov    %eax,%ebx
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 1b                	js     801f45 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f2a:	83 ec 04             	sub    $0x4,%esp
  801f2d:	68 07 04 00 00       	push   $0x407
  801f32:	ff 75 f4             	pushl  -0xc(%ebp)
  801f35:	6a 00                	push   $0x0
  801f37:	e8 71 ed ff ff       	call   800cad <sys_page_alloc>
  801f3c:	89 c3                	mov    %eax,%ebx
  801f3e:	83 c4 10             	add    $0x10,%esp
  801f41:	85 c0                	test   %eax,%eax
  801f43:	79 10                	jns    801f55 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801f45:	83 ec 0c             	sub    $0xc,%esp
  801f48:	56                   	push   %esi
  801f49:	e8 0e 02 00 00       	call   80215c <nsipc_close>
		return r;
  801f4e:	83 c4 10             	add    $0x10,%esp
  801f51:	89 d8                	mov    %ebx,%eax
  801f53:	eb 24                	jmp    801f79 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f55:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f63:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f6a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f6d:	83 ec 0c             	sub    $0xc,%esp
  801f70:	50                   	push   %eax
  801f71:	e8 71 f3 ff ff       	call   8012e7 <fd2num>
  801f76:	83 c4 10             	add    $0x10,%esp
}
  801f79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7c:	5b                   	pop    %ebx
  801f7d:	5e                   	pop    %esi
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f86:	8b 45 08             	mov    0x8(%ebp),%eax
  801f89:	e8 50 ff ff ff       	call   801ede <fd2sockid>
		return r;
  801f8e:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f90:	85 c0                	test   %eax,%eax
  801f92:	78 1f                	js     801fb3 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f94:	83 ec 04             	sub    $0x4,%esp
  801f97:	ff 75 10             	pushl  0x10(%ebp)
  801f9a:	ff 75 0c             	pushl  0xc(%ebp)
  801f9d:	50                   	push   %eax
  801f9e:	e8 12 01 00 00       	call   8020b5 <nsipc_accept>
  801fa3:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa6:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	78 07                	js     801fb3 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801fac:	e8 5d ff ff ff       	call   801f0e <alloc_sockfd>
  801fb1:	89 c1                	mov    %eax,%ecx
}
  801fb3:	89 c8                	mov    %ecx,%eax
  801fb5:	c9                   	leave  
  801fb6:	c3                   	ret    

00801fb7 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc0:	e8 19 ff ff ff       	call   801ede <fd2sockid>
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	78 12                	js     801fdb <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801fc9:	83 ec 04             	sub    $0x4,%esp
  801fcc:	ff 75 10             	pushl  0x10(%ebp)
  801fcf:	ff 75 0c             	pushl  0xc(%ebp)
  801fd2:	50                   	push   %eax
  801fd3:	e8 2d 01 00 00       	call   802105 <nsipc_bind>
  801fd8:	83 c4 10             	add    $0x10,%esp
}
  801fdb:	c9                   	leave  
  801fdc:	c3                   	ret    

00801fdd <shutdown>:

int
shutdown(int s, int how)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe6:	e8 f3 fe ff ff       	call   801ede <fd2sockid>
  801feb:	85 c0                	test   %eax,%eax
  801fed:	78 0f                	js     801ffe <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801fef:	83 ec 08             	sub    $0x8,%esp
  801ff2:	ff 75 0c             	pushl  0xc(%ebp)
  801ff5:	50                   	push   %eax
  801ff6:	e8 3f 01 00 00       	call   80213a <nsipc_shutdown>
  801ffb:	83 c4 10             	add    $0x10,%esp
}
  801ffe:	c9                   	leave  
  801fff:	c3                   	ret    

00802000 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802006:	8b 45 08             	mov    0x8(%ebp),%eax
  802009:	e8 d0 fe ff ff       	call   801ede <fd2sockid>
  80200e:	85 c0                	test   %eax,%eax
  802010:	78 12                	js     802024 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802012:	83 ec 04             	sub    $0x4,%esp
  802015:	ff 75 10             	pushl  0x10(%ebp)
  802018:	ff 75 0c             	pushl  0xc(%ebp)
  80201b:	50                   	push   %eax
  80201c:	e8 55 01 00 00       	call   802176 <nsipc_connect>
  802021:	83 c4 10             	add    $0x10,%esp
}
  802024:	c9                   	leave  
  802025:	c3                   	ret    

00802026 <listen>:

int
listen(int s, int backlog)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80202c:	8b 45 08             	mov    0x8(%ebp),%eax
  80202f:	e8 aa fe ff ff       	call   801ede <fd2sockid>
  802034:	85 c0                	test   %eax,%eax
  802036:	78 0f                	js     802047 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802038:	83 ec 08             	sub    $0x8,%esp
  80203b:	ff 75 0c             	pushl  0xc(%ebp)
  80203e:	50                   	push   %eax
  80203f:	e8 67 01 00 00       	call   8021ab <nsipc_listen>
  802044:	83 c4 10             	add    $0x10,%esp
}
  802047:	c9                   	leave  
  802048:	c3                   	ret    

00802049 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80204f:	ff 75 10             	pushl  0x10(%ebp)
  802052:	ff 75 0c             	pushl  0xc(%ebp)
  802055:	ff 75 08             	pushl  0x8(%ebp)
  802058:	e8 3a 02 00 00       	call   802297 <nsipc_socket>
  80205d:	83 c4 10             	add    $0x10,%esp
  802060:	85 c0                	test   %eax,%eax
  802062:	78 05                	js     802069 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802064:	e8 a5 fe ff ff       	call   801f0e <alloc_sockfd>
}
  802069:	c9                   	leave  
  80206a:	c3                   	ret    

0080206b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	53                   	push   %ebx
  80206f:	83 ec 04             	sub    $0x4,%esp
  802072:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802074:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  80207b:	75 12                	jne    80208f <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80207d:	83 ec 0c             	sub    $0xc,%esp
  802080:	6a 02                	push   $0x2
  802082:	e8 27 f2 ff ff       	call   8012ae <ipc_find_env>
  802087:	a3 08 40 80 00       	mov    %eax,0x804008
  80208c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80208f:	6a 07                	push   $0x7
  802091:	68 00 60 80 00       	push   $0x806000
  802096:	53                   	push   %ebx
  802097:	ff 35 08 40 80 00    	pushl  0x804008
  80209d:	e8 bd f1 ff ff       	call   80125f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020a2:	83 c4 0c             	add    $0xc,%esp
  8020a5:	6a 00                	push   $0x0
  8020a7:	6a 00                	push   $0x0
  8020a9:	6a 00                	push   $0x0
  8020ab:	e8 39 f1 ff ff       	call   8011e9 <ipc_recv>
}
  8020b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    

008020b5 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	56                   	push   %esi
  8020b9:	53                   	push   %ebx
  8020ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8020bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8020c5:	8b 06                	mov    (%esi),%eax
  8020c7:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8020cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d1:	e8 95 ff ff ff       	call   80206b <nsipc>
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	85 c0                	test   %eax,%eax
  8020da:	78 20                	js     8020fc <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8020dc:	83 ec 04             	sub    $0x4,%esp
  8020df:	ff 35 10 60 80 00    	pushl  0x806010
  8020e5:	68 00 60 80 00       	push   $0x806000
  8020ea:	ff 75 0c             	pushl  0xc(%ebp)
  8020ed:	e8 4a e9 ff ff       	call   800a3c <memmove>
		*addrlen = ret->ret_addrlen;
  8020f2:	a1 10 60 80 00       	mov    0x806010,%eax
  8020f7:	89 06                	mov    %eax,(%esi)
  8020f9:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802101:	5b                   	pop    %ebx
  802102:	5e                   	pop    %esi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	53                   	push   %ebx
  802109:	83 ec 08             	sub    $0x8,%esp
  80210c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80210f:	8b 45 08             	mov    0x8(%ebp),%eax
  802112:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802117:	53                   	push   %ebx
  802118:	ff 75 0c             	pushl  0xc(%ebp)
  80211b:	68 04 60 80 00       	push   $0x806004
  802120:	e8 17 e9 ff ff       	call   800a3c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802125:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80212b:	b8 02 00 00 00       	mov    $0x2,%eax
  802130:	e8 36 ff ff ff       	call   80206b <nsipc>
}
  802135:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802138:	c9                   	leave  
  802139:	c3                   	ret    

0080213a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802140:	8b 45 08             	mov    0x8(%ebp),%eax
  802143:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  802148:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802150:	b8 03 00 00 00       	mov    $0x3,%eax
  802155:	e8 11 ff ff ff       	call   80206b <nsipc>
}
  80215a:	c9                   	leave  
  80215b:	c3                   	ret    

0080215c <nsipc_close>:

int
nsipc_close(int s)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802162:	8b 45 08             	mov    0x8(%ebp),%eax
  802165:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80216a:	b8 04 00 00 00       	mov    $0x4,%eax
  80216f:	e8 f7 fe ff ff       	call   80206b <nsipc>
}
  802174:	c9                   	leave  
  802175:	c3                   	ret    

00802176 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	53                   	push   %ebx
  80217a:	83 ec 08             	sub    $0x8,%esp
  80217d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802180:	8b 45 08             	mov    0x8(%ebp),%eax
  802183:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802188:	53                   	push   %ebx
  802189:	ff 75 0c             	pushl  0xc(%ebp)
  80218c:	68 04 60 80 00       	push   $0x806004
  802191:	e8 a6 e8 ff ff       	call   800a3c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802196:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80219c:	b8 05 00 00 00       	mov    $0x5,%eax
  8021a1:	e8 c5 fe ff ff       	call   80206b <nsipc>
}
  8021a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021a9:	c9                   	leave  
  8021aa:	c3                   	ret    

008021ab <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
  8021ae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8021b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021bc:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8021c1:	b8 06 00 00 00       	mov    $0x6,%eax
  8021c6:	e8 a0 fe ff ff       	call   80206b <nsipc>
}
  8021cb:	c9                   	leave  
  8021cc:	c3                   	ret    

008021cd <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021cd:	55                   	push   %ebp
  8021ce:	89 e5                	mov    %esp,%ebp
  8021d0:	56                   	push   %esi
  8021d1:	53                   	push   %ebx
  8021d2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8021d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8021dd:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8021e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8021e6:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8021eb:	b8 07 00 00 00       	mov    $0x7,%eax
  8021f0:	e8 76 fe ff ff       	call   80206b <nsipc>
  8021f5:	89 c3                	mov    %eax,%ebx
  8021f7:	85 c0                	test   %eax,%eax
  8021f9:	78 35                	js     802230 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8021fb:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802200:	7f 04                	jg     802206 <nsipc_recv+0x39>
  802202:	39 c6                	cmp    %eax,%esi
  802204:	7d 16                	jge    80221c <nsipc_recv+0x4f>
  802206:	68 b2 2d 80 00       	push   $0x802db2
  80220b:	68 5b 2d 80 00       	push   $0x802d5b
  802210:	6a 62                	push   $0x62
  802212:	68 c7 2d 80 00       	push   $0x802dc7
  802217:	e8 10 e0 ff ff       	call   80022c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80221c:	83 ec 04             	sub    $0x4,%esp
  80221f:	50                   	push   %eax
  802220:	68 00 60 80 00       	push   $0x806000
  802225:	ff 75 0c             	pushl  0xc(%ebp)
  802228:	e8 0f e8 ff ff       	call   800a3c <memmove>
  80222d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802230:	89 d8                	mov    %ebx,%eax
  802232:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802235:	5b                   	pop    %ebx
  802236:	5e                   	pop    %esi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    

00802239 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802239:	55                   	push   %ebp
  80223a:	89 e5                	mov    %esp,%ebp
  80223c:	53                   	push   %ebx
  80223d:	83 ec 04             	sub    $0x4,%esp
  802240:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802243:	8b 45 08             	mov    0x8(%ebp),%eax
  802246:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80224b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802251:	7e 16                	jle    802269 <nsipc_send+0x30>
  802253:	68 d3 2d 80 00       	push   $0x802dd3
  802258:	68 5b 2d 80 00       	push   $0x802d5b
  80225d:	6a 6d                	push   $0x6d
  80225f:	68 c7 2d 80 00       	push   $0x802dc7
  802264:	e8 c3 df ff ff       	call   80022c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802269:	83 ec 04             	sub    $0x4,%esp
  80226c:	53                   	push   %ebx
  80226d:	ff 75 0c             	pushl  0xc(%ebp)
  802270:	68 0c 60 80 00       	push   $0x80600c
  802275:	e8 c2 e7 ff ff       	call   800a3c <memmove>
	nsipcbuf.send.req_size = size;
  80227a:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802280:	8b 45 14             	mov    0x14(%ebp),%eax
  802283:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802288:	b8 08 00 00 00       	mov    $0x8,%eax
  80228d:	e8 d9 fd ff ff       	call   80206b <nsipc>
}
  802292:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802295:	c9                   	leave  
  802296:	c3                   	ret    

00802297 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
  80229a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80229d:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8022a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8022ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8022b0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8022b5:	b8 09 00 00 00       	mov    $0x9,%eax
  8022ba:	e8 ac fd ff ff       	call   80206b <nsipc>
}
  8022bf:	c9                   	leave  
  8022c0:	c3                   	ret    

008022c1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022c1:	55                   	push   %ebp
  8022c2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c9:	5d                   	pop    %ebp
  8022ca:	c3                   	ret    

008022cb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022d1:	68 df 2d 80 00       	push   $0x802ddf
  8022d6:	ff 75 0c             	pushl  0xc(%ebp)
  8022d9:	e8 cc e5 ff ff       	call   8008aa <strcpy>
	return 0;
}
  8022de:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e3:	c9                   	leave  
  8022e4:	c3                   	ret    

008022e5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022e5:	55                   	push   %ebp
  8022e6:	89 e5                	mov    %esp,%ebp
  8022e8:	57                   	push   %edi
  8022e9:	56                   	push   %esi
  8022ea:	53                   	push   %ebx
  8022eb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022f6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022fc:	eb 2d                	jmp    80232b <devcons_write+0x46>
		m = n - tot;
  8022fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802301:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802303:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802306:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80230b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80230e:	83 ec 04             	sub    $0x4,%esp
  802311:	53                   	push   %ebx
  802312:	03 45 0c             	add    0xc(%ebp),%eax
  802315:	50                   	push   %eax
  802316:	57                   	push   %edi
  802317:	e8 20 e7 ff ff       	call   800a3c <memmove>
		sys_cputs(buf, m);
  80231c:	83 c4 08             	add    $0x8,%esp
  80231f:	53                   	push   %ebx
  802320:	57                   	push   %edi
  802321:	e8 cb e8 ff ff       	call   800bf1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802326:	01 de                	add    %ebx,%esi
  802328:	83 c4 10             	add    $0x10,%esp
  80232b:	89 f0                	mov    %esi,%eax
  80232d:	3b 75 10             	cmp    0x10(%ebp),%esi
  802330:	72 cc                	jb     8022fe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802332:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802335:	5b                   	pop    %ebx
  802336:	5e                   	pop    %esi
  802337:	5f                   	pop    %edi
  802338:	5d                   	pop    %ebp
  802339:	c3                   	ret    

0080233a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80233a:	55                   	push   %ebp
  80233b:	89 e5                	mov    %esp,%ebp
  80233d:	83 ec 08             	sub    $0x8,%esp
  802340:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802345:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802349:	74 2a                	je     802375 <devcons_read+0x3b>
  80234b:	eb 05                	jmp    802352 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80234d:	e8 3c e9 ff ff       	call   800c8e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802352:	e8 b8 e8 ff ff       	call   800c0f <sys_cgetc>
  802357:	85 c0                	test   %eax,%eax
  802359:	74 f2                	je     80234d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80235b:	85 c0                	test   %eax,%eax
  80235d:	78 16                	js     802375 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80235f:	83 f8 04             	cmp    $0x4,%eax
  802362:	74 0c                	je     802370 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802364:	8b 55 0c             	mov    0xc(%ebp),%edx
  802367:	88 02                	mov    %al,(%edx)
	return 1;
  802369:	b8 01 00 00 00       	mov    $0x1,%eax
  80236e:	eb 05                	jmp    802375 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802370:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802375:	c9                   	leave  
  802376:	c3                   	ret    

00802377 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80237d:	8b 45 08             	mov    0x8(%ebp),%eax
  802380:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802383:	6a 01                	push   $0x1
  802385:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802388:	50                   	push   %eax
  802389:	e8 63 e8 ff ff       	call   800bf1 <sys_cputs>
}
  80238e:	83 c4 10             	add    $0x10,%esp
  802391:	c9                   	leave  
  802392:	c3                   	ret    

00802393 <getchar>:

int
getchar(void)
{
  802393:	55                   	push   %ebp
  802394:	89 e5                	mov    %esp,%ebp
  802396:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802399:	6a 01                	push   $0x1
  80239b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80239e:	50                   	push   %eax
  80239f:	6a 00                	push   $0x0
  8023a1:	e8 1d f2 ff ff       	call   8015c3 <read>
	if (r < 0)
  8023a6:	83 c4 10             	add    $0x10,%esp
  8023a9:	85 c0                	test   %eax,%eax
  8023ab:	78 0f                	js     8023bc <getchar+0x29>
		return r;
	if (r < 1)
  8023ad:	85 c0                	test   %eax,%eax
  8023af:	7e 06                	jle    8023b7 <getchar+0x24>
		return -E_EOF;
	return c;
  8023b1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023b5:	eb 05                	jmp    8023bc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023b7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023bc:	c9                   	leave  
  8023bd:	c3                   	ret    

008023be <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c7:	50                   	push   %eax
  8023c8:	ff 75 08             	pushl  0x8(%ebp)
  8023cb:	e8 8d ef ff ff       	call   80135d <fd_lookup>
  8023d0:	83 c4 10             	add    $0x10,%esp
  8023d3:	85 c0                	test   %eax,%eax
  8023d5:	78 11                	js     8023e8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023da:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023e0:	39 10                	cmp    %edx,(%eax)
  8023e2:	0f 94 c0             	sete   %al
  8023e5:	0f b6 c0             	movzbl %al,%eax
}
  8023e8:	c9                   	leave  
  8023e9:	c3                   	ret    

008023ea <opencons>:

int
opencons(void)
{
  8023ea:	55                   	push   %ebp
  8023eb:	89 e5                	mov    %esp,%ebp
  8023ed:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023f3:	50                   	push   %eax
  8023f4:	e8 15 ef ff ff       	call   80130e <fd_alloc>
  8023f9:	83 c4 10             	add    $0x10,%esp
		return r;
  8023fc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023fe:	85 c0                	test   %eax,%eax
  802400:	78 3e                	js     802440 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802402:	83 ec 04             	sub    $0x4,%esp
  802405:	68 07 04 00 00       	push   $0x407
  80240a:	ff 75 f4             	pushl  -0xc(%ebp)
  80240d:	6a 00                	push   $0x0
  80240f:	e8 99 e8 ff ff       	call   800cad <sys_page_alloc>
  802414:	83 c4 10             	add    $0x10,%esp
		return r;
  802417:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802419:	85 c0                	test   %eax,%eax
  80241b:	78 23                	js     802440 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80241d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802423:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802426:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802428:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802432:	83 ec 0c             	sub    $0xc,%esp
  802435:	50                   	push   %eax
  802436:	e8 ac ee ff ff       	call   8012e7 <fd2num>
  80243b:	89 c2                	mov    %eax,%edx
  80243d:	83 c4 10             	add    $0x10,%esp
}
  802440:	89 d0                	mov    %edx,%eax
  802442:	c9                   	leave  
  802443:	c3                   	ret    

00802444 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802444:	55                   	push   %ebp
  802445:	89 e5                	mov    %esp,%ebp
  802447:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  80244a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802451:	75 56                	jne    8024a9 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  802453:	83 ec 04             	sub    $0x4,%esp
  802456:	6a 07                	push   $0x7
  802458:	68 00 f0 bf ee       	push   $0xeebff000
  80245d:	6a 00                	push   $0x0
  80245f:	e8 49 e8 ff ff       	call   800cad <sys_page_alloc>
  802464:	83 c4 10             	add    $0x10,%esp
  802467:	85 c0                	test   %eax,%eax
  802469:	74 14                	je     80247f <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  80246b:	83 ec 04             	sub    $0x4,%esp
  80246e:	68 69 2c 80 00       	push   $0x802c69
  802473:	6a 21                	push   $0x21
  802475:	68 eb 2d 80 00       	push   $0x802deb
  80247a:	e8 ad dd ff ff       	call   80022c <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  80247f:	83 ec 08             	sub    $0x8,%esp
  802482:	68 b3 24 80 00       	push   $0x8024b3
  802487:	6a 00                	push   $0x0
  802489:	e8 6a e9 ff ff       	call   800df8 <sys_env_set_pgfault_upcall>
  80248e:	83 c4 10             	add    $0x10,%esp
  802491:	85 c0                	test   %eax,%eax
  802493:	74 14                	je     8024a9 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  802495:	83 ec 04             	sub    $0x4,%esp
  802498:	68 f9 2d 80 00       	push   $0x802df9
  80249d:	6a 23                	push   $0x23
  80249f:	68 eb 2d 80 00       	push   $0x802deb
  8024a4:	e8 83 dd ff ff       	call   80022c <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ac:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8024b1:	c9                   	leave  
  8024b2:	c3                   	ret    

008024b3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024b3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024b4:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8024b9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024bb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  8024be:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  8024c0:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  8024c4:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8024c8:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  8024c9:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  8024cb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  8024d0:	83 c4 08             	add    $0x8,%esp
	popal
  8024d3:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8024d4:	83 c4 04             	add    $0x4,%esp
	popfl
  8024d7:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8024d8:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8024d9:	c3                   	ret    

008024da <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
  8024dd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024e0:	89 d0                	mov    %edx,%eax
  8024e2:	c1 e8 16             	shr    $0x16,%eax
  8024e5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024ec:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024f1:	f6 c1 01             	test   $0x1,%cl
  8024f4:	74 1d                	je     802513 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024f6:	c1 ea 0c             	shr    $0xc,%edx
  8024f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802500:	f6 c2 01             	test   $0x1,%dl
  802503:	74 0e                	je     802513 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802505:	c1 ea 0c             	shr    $0xc,%edx
  802508:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80250f:	ef 
  802510:	0f b7 c0             	movzwl %ax,%eax
}
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    
  802515:	66 90                	xchg   %ax,%ax
  802517:	66 90                	xchg   %ax,%ax
  802519:	66 90                	xchg   %ax,%ax
  80251b:	66 90                	xchg   %ax,%ax
  80251d:	66 90                	xchg   %ax,%ax
  80251f:	90                   	nop

00802520 <__udivdi3>:
  802520:	55                   	push   %ebp
  802521:	57                   	push   %edi
  802522:	56                   	push   %esi
  802523:	53                   	push   %ebx
  802524:	83 ec 1c             	sub    $0x1c,%esp
  802527:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80252b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80252f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802533:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802537:	85 f6                	test   %esi,%esi
  802539:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80253d:	89 ca                	mov    %ecx,%edx
  80253f:	89 f8                	mov    %edi,%eax
  802541:	75 3d                	jne    802580 <__udivdi3+0x60>
  802543:	39 cf                	cmp    %ecx,%edi
  802545:	0f 87 c5 00 00 00    	ja     802610 <__udivdi3+0xf0>
  80254b:	85 ff                	test   %edi,%edi
  80254d:	89 fd                	mov    %edi,%ebp
  80254f:	75 0b                	jne    80255c <__udivdi3+0x3c>
  802551:	b8 01 00 00 00       	mov    $0x1,%eax
  802556:	31 d2                	xor    %edx,%edx
  802558:	f7 f7                	div    %edi
  80255a:	89 c5                	mov    %eax,%ebp
  80255c:	89 c8                	mov    %ecx,%eax
  80255e:	31 d2                	xor    %edx,%edx
  802560:	f7 f5                	div    %ebp
  802562:	89 c1                	mov    %eax,%ecx
  802564:	89 d8                	mov    %ebx,%eax
  802566:	89 cf                	mov    %ecx,%edi
  802568:	f7 f5                	div    %ebp
  80256a:	89 c3                	mov    %eax,%ebx
  80256c:	89 d8                	mov    %ebx,%eax
  80256e:	89 fa                	mov    %edi,%edx
  802570:	83 c4 1c             	add    $0x1c,%esp
  802573:	5b                   	pop    %ebx
  802574:	5e                   	pop    %esi
  802575:	5f                   	pop    %edi
  802576:	5d                   	pop    %ebp
  802577:	c3                   	ret    
  802578:	90                   	nop
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802580:	39 ce                	cmp    %ecx,%esi
  802582:	77 74                	ja     8025f8 <__udivdi3+0xd8>
  802584:	0f bd fe             	bsr    %esi,%edi
  802587:	83 f7 1f             	xor    $0x1f,%edi
  80258a:	0f 84 98 00 00 00    	je     802628 <__udivdi3+0x108>
  802590:	bb 20 00 00 00       	mov    $0x20,%ebx
  802595:	89 f9                	mov    %edi,%ecx
  802597:	89 c5                	mov    %eax,%ebp
  802599:	29 fb                	sub    %edi,%ebx
  80259b:	d3 e6                	shl    %cl,%esi
  80259d:	89 d9                	mov    %ebx,%ecx
  80259f:	d3 ed                	shr    %cl,%ebp
  8025a1:	89 f9                	mov    %edi,%ecx
  8025a3:	d3 e0                	shl    %cl,%eax
  8025a5:	09 ee                	or     %ebp,%esi
  8025a7:	89 d9                	mov    %ebx,%ecx
  8025a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025ad:	89 d5                	mov    %edx,%ebp
  8025af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025b3:	d3 ed                	shr    %cl,%ebp
  8025b5:	89 f9                	mov    %edi,%ecx
  8025b7:	d3 e2                	shl    %cl,%edx
  8025b9:	89 d9                	mov    %ebx,%ecx
  8025bb:	d3 e8                	shr    %cl,%eax
  8025bd:	09 c2                	or     %eax,%edx
  8025bf:	89 d0                	mov    %edx,%eax
  8025c1:	89 ea                	mov    %ebp,%edx
  8025c3:	f7 f6                	div    %esi
  8025c5:	89 d5                	mov    %edx,%ebp
  8025c7:	89 c3                	mov    %eax,%ebx
  8025c9:	f7 64 24 0c          	mull   0xc(%esp)
  8025cd:	39 d5                	cmp    %edx,%ebp
  8025cf:	72 10                	jb     8025e1 <__udivdi3+0xc1>
  8025d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025d5:	89 f9                	mov    %edi,%ecx
  8025d7:	d3 e6                	shl    %cl,%esi
  8025d9:	39 c6                	cmp    %eax,%esi
  8025db:	73 07                	jae    8025e4 <__udivdi3+0xc4>
  8025dd:	39 d5                	cmp    %edx,%ebp
  8025df:	75 03                	jne    8025e4 <__udivdi3+0xc4>
  8025e1:	83 eb 01             	sub    $0x1,%ebx
  8025e4:	31 ff                	xor    %edi,%edi
  8025e6:	89 d8                	mov    %ebx,%eax
  8025e8:	89 fa                	mov    %edi,%edx
  8025ea:	83 c4 1c             	add    $0x1c,%esp
  8025ed:	5b                   	pop    %ebx
  8025ee:	5e                   	pop    %esi
  8025ef:	5f                   	pop    %edi
  8025f0:	5d                   	pop    %ebp
  8025f1:	c3                   	ret    
  8025f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025f8:	31 ff                	xor    %edi,%edi
  8025fa:	31 db                	xor    %ebx,%ebx
  8025fc:	89 d8                	mov    %ebx,%eax
  8025fe:	89 fa                	mov    %edi,%edx
  802600:	83 c4 1c             	add    $0x1c,%esp
  802603:	5b                   	pop    %ebx
  802604:	5e                   	pop    %esi
  802605:	5f                   	pop    %edi
  802606:	5d                   	pop    %ebp
  802607:	c3                   	ret    
  802608:	90                   	nop
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	89 d8                	mov    %ebx,%eax
  802612:	f7 f7                	div    %edi
  802614:	31 ff                	xor    %edi,%edi
  802616:	89 c3                	mov    %eax,%ebx
  802618:	89 d8                	mov    %ebx,%eax
  80261a:	89 fa                	mov    %edi,%edx
  80261c:	83 c4 1c             	add    $0x1c,%esp
  80261f:	5b                   	pop    %ebx
  802620:	5e                   	pop    %esi
  802621:	5f                   	pop    %edi
  802622:	5d                   	pop    %ebp
  802623:	c3                   	ret    
  802624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802628:	39 ce                	cmp    %ecx,%esi
  80262a:	72 0c                	jb     802638 <__udivdi3+0x118>
  80262c:	31 db                	xor    %ebx,%ebx
  80262e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802632:	0f 87 34 ff ff ff    	ja     80256c <__udivdi3+0x4c>
  802638:	bb 01 00 00 00       	mov    $0x1,%ebx
  80263d:	e9 2a ff ff ff       	jmp    80256c <__udivdi3+0x4c>
  802642:	66 90                	xchg   %ax,%ax
  802644:	66 90                	xchg   %ax,%ax
  802646:	66 90                	xchg   %ax,%ax
  802648:	66 90                	xchg   %ax,%ax
  80264a:	66 90                	xchg   %ax,%ax
  80264c:	66 90                	xchg   %ax,%ax
  80264e:	66 90                	xchg   %ax,%ax

00802650 <__umoddi3>:
  802650:	55                   	push   %ebp
  802651:	57                   	push   %edi
  802652:	56                   	push   %esi
  802653:	53                   	push   %ebx
  802654:	83 ec 1c             	sub    $0x1c,%esp
  802657:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80265b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80265f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802663:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802667:	85 d2                	test   %edx,%edx
  802669:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80266d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802671:	89 f3                	mov    %esi,%ebx
  802673:	89 3c 24             	mov    %edi,(%esp)
  802676:	89 74 24 04          	mov    %esi,0x4(%esp)
  80267a:	75 1c                	jne    802698 <__umoddi3+0x48>
  80267c:	39 f7                	cmp    %esi,%edi
  80267e:	76 50                	jbe    8026d0 <__umoddi3+0x80>
  802680:	89 c8                	mov    %ecx,%eax
  802682:	89 f2                	mov    %esi,%edx
  802684:	f7 f7                	div    %edi
  802686:	89 d0                	mov    %edx,%eax
  802688:	31 d2                	xor    %edx,%edx
  80268a:	83 c4 1c             	add    $0x1c,%esp
  80268d:	5b                   	pop    %ebx
  80268e:	5e                   	pop    %esi
  80268f:	5f                   	pop    %edi
  802690:	5d                   	pop    %ebp
  802691:	c3                   	ret    
  802692:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802698:	39 f2                	cmp    %esi,%edx
  80269a:	89 d0                	mov    %edx,%eax
  80269c:	77 52                	ja     8026f0 <__umoddi3+0xa0>
  80269e:	0f bd ea             	bsr    %edx,%ebp
  8026a1:	83 f5 1f             	xor    $0x1f,%ebp
  8026a4:	75 5a                	jne    802700 <__umoddi3+0xb0>
  8026a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026aa:	0f 82 e0 00 00 00    	jb     802790 <__umoddi3+0x140>
  8026b0:	39 0c 24             	cmp    %ecx,(%esp)
  8026b3:	0f 86 d7 00 00 00    	jbe    802790 <__umoddi3+0x140>
  8026b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026c1:	83 c4 1c             	add    $0x1c,%esp
  8026c4:	5b                   	pop    %ebx
  8026c5:	5e                   	pop    %esi
  8026c6:	5f                   	pop    %edi
  8026c7:	5d                   	pop    %ebp
  8026c8:	c3                   	ret    
  8026c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	85 ff                	test   %edi,%edi
  8026d2:	89 fd                	mov    %edi,%ebp
  8026d4:	75 0b                	jne    8026e1 <__umoddi3+0x91>
  8026d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026db:	31 d2                	xor    %edx,%edx
  8026dd:	f7 f7                	div    %edi
  8026df:	89 c5                	mov    %eax,%ebp
  8026e1:	89 f0                	mov    %esi,%eax
  8026e3:	31 d2                	xor    %edx,%edx
  8026e5:	f7 f5                	div    %ebp
  8026e7:	89 c8                	mov    %ecx,%eax
  8026e9:	f7 f5                	div    %ebp
  8026eb:	89 d0                	mov    %edx,%eax
  8026ed:	eb 99                	jmp    802688 <__umoddi3+0x38>
  8026ef:	90                   	nop
  8026f0:	89 c8                	mov    %ecx,%eax
  8026f2:	89 f2                	mov    %esi,%edx
  8026f4:	83 c4 1c             	add    $0x1c,%esp
  8026f7:	5b                   	pop    %ebx
  8026f8:	5e                   	pop    %esi
  8026f9:	5f                   	pop    %edi
  8026fa:	5d                   	pop    %ebp
  8026fb:	c3                   	ret    
  8026fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802700:	8b 34 24             	mov    (%esp),%esi
  802703:	bf 20 00 00 00       	mov    $0x20,%edi
  802708:	89 e9                	mov    %ebp,%ecx
  80270a:	29 ef                	sub    %ebp,%edi
  80270c:	d3 e0                	shl    %cl,%eax
  80270e:	89 f9                	mov    %edi,%ecx
  802710:	89 f2                	mov    %esi,%edx
  802712:	d3 ea                	shr    %cl,%edx
  802714:	89 e9                	mov    %ebp,%ecx
  802716:	09 c2                	or     %eax,%edx
  802718:	89 d8                	mov    %ebx,%eax
  80271a:	89 14 24             	mov    %edx,(%esp)
  80271d:	89 f2                	mov    %esi,%edx
  80271f:	d3 e2                	shl    %cl,%edx
  802721:	89 f9                	mov    %edi,%ecx
  802723:	89 54 24 04          	mov    %edx,0x4(%esp)
  802727:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80272b:	d3 e8                	shr    %cl,%eax
  80272d:	89 e9                	mov    %ebp,%ecx
  80272f:	89 c6                	mov    %eax,%esi
  802731:	d3 e3                	shl    %cl,%ebx
  802733:	89 f9                	mov    %edi,%ecx
  802735:	89 d0                	mov    %edx,%eax
  802737:	d3 e8                	shr    %cl,%eax
  802739:	89 e9                	mov    %ebp,%ecx
  80273b:	09 d8                	or     %ebx,%eax
  80273d:	89 d3                	mov    %edx,%ebx
  80273f:	89 f2                	mov    %esi,%edx
  802741:	f7 34 24             	divl   (%esp)
  802744:	89 d6                	mov    %edx,%esi
  802746:	d3 e3                	shl    %cl,%ebx
  802748:	f7 64 24 04          	mull   0x4(%esp)
  80274c:	39 d6                	cmp    %edx,%esi
  80274e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802752:	89 d1                	mov    %edx,%ecx
  802754:	89 c3                	mov    %eax,%ebx
  802756:	72 08                	jb     802760 <__umoddi3+0x110>
  802758:	75 11                	jne    80276b <__umoddi3+0x11b>
  80275a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80275e:	73 0b                	jae    80276b <__umoddi3+0x11b>
  802760:	2b 44 24 04          	sub    0x4(%esp),%eax
  802764:	1b 14 24             	sbb    (%esp),%edx
  802767:	89 d1                	mov    %edx,%ecx
  802769:	89 c3                	mov    %eax,%ebx
  80276b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80276f:	29 da                	sub    %ebx,%edx
  802771:	19 ce                	sbb    %ecx,%esi
  802773:	89 f9                	mov    %edi,%ecx
  802775:	89 f0                	mov    %esi,%eax
  802777:	d3 e0                	shl    %cl,%eax
  802779:	89 e9                	mov    %ebp,%ecx
  80277b:	d3 ea                	shr    %cl,%edx
  80277d:	89 e9                	mov    %ebp,%ecx
  80277f:	d3 ee                	shr    %cl,%esi
  802781:	09 d0                	or     %edx,%eax
  802783:	89 f2                	mov    %esi,%edx
  802785:	83 c4 1c             	add    $0x1c,%esp
  802788:	5b                   	pop    %ebx
  802789:	5e                   	pop    %esi
  80278a:	5f                   	pop    %edi
  80278b:	5d                   	pop    %ebp
  80278c:	c3                   	ret    
  80278d:	8d 76 00             	lea    0x0(%esi),%esi
  802790:	29 f9                	sub    %edi,%ecx
  802792:	19 d6                	sbb    %edx,%esi
  802794:	89 74 24 04          	mov    %esi,0x4(%esp)
  802798:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80279c:	e9 18 ff ff ff       	jmp    8026b9 <__umoddi3+0x69>
