
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 fb 06 00 00       	call   80072c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 7c             	sub    $0x7c,%esp
	envid_t ns_envid = sys_getenvid();
  80003c:	e8 8e 11 00 00       	call   8011cf <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800043:	c7 05 00 40 80 00 20 	movl   $0x802d20,0x804000
  80004a:	2d 80 00 

	output_envid = fork();
  80004d:	e8 bf 14 00 00       	call   801511 <fork>
  800052:	a3 04 50 80 00       	mov    %eax,0x805004
	if (output_envid < 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	79 14                	jns    80006f <umain+0x3c>
		panic("error forking");
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	68 2a 2d 80 00       	push   $0x802d2a
  800063:	6a 4d                	push   $0x4d
  800065:	68 38 2d 80 00       	push   $0x802d38
  80006a:	e8 1d 07 00 00       	call   80078c <_panic>
	else if (output_envid == 0) {
  80006f:	85 c0                	test   %eax,%eax
  800071:	75 11                	jne    800084 <umain+0x51>
		output(ns_envid);
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	53                   	push   %ebx
  800077:	e8 bd 03 00 00       	call   800439 <output>
		return;
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	e9 0b 03 00 00       	jmp    80038f <umain+0x35c>
	}

	input_envid = fork();
  800084:	e8 88 14 00 00       	call   801511 <fork>
  800089:	a3 00 50 80 00       	mov    %eax,0x805000
	if (input_envid < 0)
  80008e:	85 c0                	test   %eax,%eax
  800090:	79 14                	jns    8000a6 <umain+0x73>
		panic("error forking");
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	68 2a 2d 80 00       	push   $0x802d2a
  80009a:	6a 55                	push   $0x55
  80009c:	68 38 2d 80 00       	push   $0x802d38
  8000a1:	e8 e6 06 00 00       	call   80078c <_panic>
	else if (input_envid == 0) {
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 11                	jne    8000bb <umain+0x88>
		input(ns_envid);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	53                   	push   %ebx
  8000ae:	e8 77 03 00 00       	call   80042a <input>
		return;
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	e9 d4 02 00 00       	jmp    80038f <umain+0x35c>
	}

	cprintf("Sending ARP announcement...\n");
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 48 2d 80 00       	push   $0x802d48
  8000c3:	e8 9d 07 00 00       	call   800865 <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000c8:	c6 45 98 52          	movb   $0x52,-0x68(%ebp)
  8000cc:	c6 45 99 54          	movb   $0x54,-0x67(%ebp)
  8000d0:	c6 45 9a 00          	movb   $0x0,-0x66(%ebp)
  8000d4:	c6 45 9b 12          	movb   $0x12,-0x65(%ebp)
  8000d8:	c6 45 9c 34          	movb   $0x34,-0x64(%ebp)
  8000dc:	c6 45 9d 56          	movb   $0x56,-0x63(%ebp)
	uint32_t myip = inet_addr(IP);
  8000e0:	c7 04 24 65 2d 80 00 	movl   $0x802d65,(%esp)
  8000e7:	e8 0e 06 00 00       	call   8006fa <inet_addr>
  8000ec:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000ef:	c7 04 24 6f 2d 80 00 	movl   $0x802d6f,(%esp)
  8000f6:	e8 ff 05 00 00       	call   8006fa <inet_addr>
  8000fb:	89 45 94             	mov    %eax,-0x6c(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000fe:	83 c4 0c             	add    $0xc,%esp
  800101:	6a 07                	push   $0x7
  800103:	68 00 b0 fe 0f       	push   $0xffeb000
  800108:	6a 00                	push   $0x0
  80010a:	e8 fe 10 00 00       	call   80120d <sys_page_alloc>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	79 12                	jns    800128 <umain+0xf5>
		panic("sys_page_map: %e", r);
  800116:	50                   	push   %eax
  800117:	68 11 32 80 00       	push   $0x803211
  80011c:	6a 19                	push   $0x19
  80011e:	68 38 2d 80 00       	push   $0x802d38
  800123:	e8 64 06 00 00       	call   80078c <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800128:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  80012f:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800132:	83 ec 04             	sub    $0x4,%esp
  800135:	6a 06                	push   $0x6
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	68 04 b0 fe 0f       	push   $0xffeb004
  800141:	e8 09 0e 00 00       	call   800f4f <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800146:	83 c4 0c             	add    $0xc,%esp
  800149:	6a 06                	push   $0x6
  80014b:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  80014e:	53                   	push   %ebx
  80014f:	68 0a b0 fe 0f       	push   $0xffeb00a
  800154:	e8 ab 0e 00 00       	call   801004 <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800159:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800160:	e8 7c 03 00 00       	call   8004e1 <htons>
  800165:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  80016b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800172:	e8 6a 03 00 00       	call   8004e1 <htons>
  800177:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  80017d:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  800184:	e8 58 03 00 00       	call   8004e1 <htons>
  800189:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  80018f:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  800196:	e8 46 03 00 00       	call   8004e1 <htons>
  80019b:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a8:	e8 34 03 00 00       	call   8004e1 <htons>
  8001ad:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001b3:	83 c4 0c             	add    $0xc,%esp
  8001b6:	6a 06                	push   $0x6
  8001b8:	53                   	push   %ebx
  8001b9:	68 1a b0 fe 0f       	push   $0xffeb01a
  8001be:	e8 41 0e 00 00       	call   801004 <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001c3:	83 c4 0c             	add    $0xc,%esp
  8001c6:	6a 04                	push   $0x4
  8001c8:	8d 45 90             	lea    -0x70(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	68 20 b0 fe 0f       	push   $0xffeb020
  8001d1:	e8 2e 0e 00 00       	call   801004 <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  8001d6:	83 c4 0c             	add    $0xc,%esp
  8001d9:	6a 06                	push   $0x6
  8001db:	6a 00                	push   $0x0
  8001dd:	68 24 b0 fe 0f       	push   $0xffeb024
  8001e2:	e8 68 0d 00 00       	call   800f4f <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  8001e7:	83 c4 0c             	add    $0xc,%esp
  8001ea:	6a 04                	push   $0x4
  8001ec:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 2a b0 fe 0f       	push   $0xffeb02a
  8001f5:	e8 0a 0e 00 00       	call   801004 <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001fa:	6a 07                	push   $0x7
  8001fc:	68 00 b0 fe 0f       	push   $0xffeb000
  800201:	6a 0b                	push   $0xb
  800203:	ff 35 04 50 80 00    	pushl  0x805004
  800209:	e8 b1 15 00 00       	call   8017bf <ipc_send>
	sys_page_unmap(0, pkt);
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	68 00 b0 fe 0f       	push   $0xffeb000
  800216:	6a 00                	push   $0x0
  800218:	e8 75 10 00 00       	call   801292 <sys_page_unmap>
  80021d:	83 c4 10             	add    $0x10,%esp

void
umain(int argc, char **argv)
{
	envid_t ns_envid = sys_getenvid();
	int i, r, first = 1;
  800220:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  800227:	00 00 00 

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800230:	50                   	push   %eax
  800231:	68 00 b0 fe 0f       	push   $0xffeb000
  800236:	8d 45 90             	lea    -0x70(%ebp),%eax
  800239:	50                   	push   %eax
  80023a:	e8 0a 15 00 00       	call   801749 <ipc_recv>
		if (req < 0)
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	85 c0                	test   %eax,%eax
  800244:	79 12                	jns    800258 <umain+0x225>
			panic("ipc_recv: %e", req);
  800246:	50                   	push   %eax
  800247:	68 78 2d 80 00       	push   $0x802d78
  80024c:	6a 64                	push   $0x64
  80024e:	68 38 2d 80 00       	push   $0x802d38
  800253:	e8 34 05 00 00       	call   80078c <_panic>
		if (whom != input_envid)
  800258:	8b 55 90             	mov    -0x70(%ebp),%edx
  80025b:	3b 15 00 50 80 00    	cmp    0x805000,%edx
  800261:	74 12                	je     800275 <umain+0x242>
			panic("IPC from unexpected environment %08x", whom);
  800263:	52                   	push   %edx
  800264:	68 cc 2d 80 00       	push   $0x802dcc
  800269:	6a 66                	push   $0x66
  80026b:	68 38 2d 80 00       	push   $0x802d38
  800270:	e8 17 05 00 00       	call   80078c <_panic>
		if (req != NSREQ_INPUT)
  800275:	83 f8 0a             	cmp    $0xa,%eax
  800278:	74 12                	je     80028c <umain+0x259>
			panic("Unexpected IPC %d", req);
  80027a:	50                   	push   %eax
  80027b:	68 85 2d 80 00       	push   $0x802d85
  800280:	6a 68                	push   $0x68
  800282:	68 38 2d 80 00       	push   $0x802d38
  800287:	e8 00 05 00 00       	call   80078c <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  80028c:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800291:	89 45 84             	mov    %eax,-0x7c(%ebp)
hexdump(const char *prefix, const void *data, int len)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
  800294:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < len; i++) {
  800299:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
		if (i % 16 == 15 || i == len - 1)
  80029e:	83 e8 01             	sub    $0x1,%eax
  8002a1:	89 45 80             	mov    %eax,-0x80(%ebp)
  8002a4:	e9 a5 00 00 00       	jmp    80034e <umain+0x31b>
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
  8002a9:	89 df                	mov    %ebx,%edi
  8002ab:	f6 c3 0f             	test   $0xf,%bl
  8002ae:	75 22                	jne    8002d2 <umain+0x29f>
			out = buf + snprintf(buf, end - buf,
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	53                   	push   %ebx
  8002b4:	68 97 2d 80 00       	push   $0x802d97
  8002b9:	68 9f 2d 80 00       	push   $0x802d9f
  8002be:	6a 50                	push   $0x50
  8002c0:	8d 45 98             	lea    -0x68(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 ee 0a 00 00       	call   800db7 <snprintf>
  8002c9:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  8002cc:	8d 34 01             	lea    (%ecx,%eax,1),%esi
  8002cf:	83 c4 20             	add    $0x20,%esp
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8002d2:	b8 04 b0 fe 0f       	mov    $0xffeb004,%eax
  8002d7:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
  8002db:	50                   	push   %eax
  8002dc:	68 a9 2d 80 00       	push   $0x802da9
  8002e1:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e4:	29 f0                	sub    %esi,%eax
  8002e6:	50                   	push   %eax
  8002e7:	56                   	push   %esi
  8002e8:	e8 ca 0a 00 00       	call   800db7 <snprintf>
  8002ed:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  8002ef:	89 d8                	mov    %ebx,%eax
  8002f1:	c1 f8 1f             	sar    $0x1f,%eax
  8002f4:	c1 e8 1c             	shr    $0x1c,%eax
  8002f7:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
  8002fa:	83 e7 0f             	and    $0xf,%edi
  8002fd:	29 c7                	sub    %eax,%edi
  8002ff:	83 c4 10             	add    $0x10,%esp
  800302:	83 ff 0f             	cmp    $0xf,%edi
  800305:	74 05                	je     80030c <umain+0x2d9>
  800307:	3b 5d 80             	cmp    -0x80(%ebp),%ebx
  80030a:	75 1c                	jne    800328 <umain+0x2f5>
			cprintf("%.*s\n", out - buf, buf);
  80030c:	83 ec 04             	sub    $0x4,%esp
  80030f:	8d 45 98             	lea    -0x68(%ebp),%eax
  800312:	50                   	push   %eax
  800313:	89 f0                	mov    %esi,%eax
  800315:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  800318:	29 c8                	sub    %ecx,%eax
  80031a:	50                   	push   %eax
  80031b:	68 ae 2d 80 00       	push   $0x802dae
  800320:	e8 40 05 00 00       	call   800865 <cprintf>
  800325:	83 c4 10             	add    $0x10,%esp
		if (i % 2 == 1)
  800328:	89 da                	mov    %ebx,%edx
  80032a:	c1 ea 1f             	shr    $0x1f,%edx
  80032d:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800330:	83 e0 01             	and    $0x1,%eax
  800333:	29 d0                	sub    %edx,%eax
  800335:	83 f8 01             	cmp    $0x1,%eax
  800338:	75 06                	jne    800340 <umain+0x30d>
			*(out++) = ' ';
  80033a:	c6 06 20             	movb   $0x20,(%esi)
  80033d:	8d 76 01             	lea    0x1(%esi),%esi
		if (i % 16 == 7)
  800340:	83 ff 07             	cmp    $0x7,%edi
  800343:	75 06                	jne    80034b <umain+0x318>
			*(out++) = ' ';
  800345:	c6 06 20             	movb   $0x20,(%esi)
  800348:	8d 76 01             	lea    0x1(%esi),%esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  80034b:	83 c3 01             	add    $0x1,%ebx
  80034e:	3b 5d 84             	cmp    -0x7c(%ebp),%ebx
  800351:	0f 8c 52 ff ff ff    	jl     8002a9 <umain+0x276>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	68 ca 2d 80 00       	push   $0x802dca
  80035f:	e8 01 05 00 00       	call   800865 <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
  80036e:	74 10                	je     800380 <umain+0x34d>
			cprintf("Waiting for packets...\n");
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	68 b4 2d 80 00       	push   $0x802db4
  800378:	e8 e8 04 00 00       	call   800865 <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp
		first = 0;
  800380:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
  800387:	00 00 00 
	}
  80038a:	e9 9b fe ff ff       	jmp    80022a <umain+0x1f7>
}
  80038f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 1c             	sub    $0x1c,%esp
  8003a0:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  8003a3:	e8 56 10 00 00       	call   8013fe <sys_time_msec>
  8003a8:	03 45 0c             	add    0xc(%ebp),%eax
  8003ab:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003ad:	c7 05 00 40 80 00 f1 	movl   $0x802df1,0x804000
  8003b4:	2d 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003b7:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8003ba:	eb 05                	jmp    8003c1 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  8003bc:	e8 2d 0e 00 00       	call   8011ee <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  8003c1:	e8 38 10 00 00       	call   8013fe <sys_time_msec>
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	78 04                	js     8003d0 <timer+0x39>
  8003cc:	39 c3                	cmp    %eax,%ebx
  8003ce:	77 ec                	ja     8003bc <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	79 12                	jns    8003e6 <timer+0x4f>
			panic("sys_time_msec: %e", r);
  8003d4:	52                   	push   %edx
  8003d5:	68 fa 2d 80 00       	push   $0x802dfa
  8003da:	6a 0f                	push   $0xf
  8003dc:	68 0c 2e 80 00       	push   $0x802e0c
  8003e1:	e8 a6 03 00 00       	call   80078c <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8003e6:	6a 00                	push   $0x0
  8003e8:	6a 00                	push   $0x0
  8003ea:	6a 0c                	push   $0xc
  8003ec:	56                   	push   %esi
  8003ed:	e8 cd 13 00 00       	call   8017bf <ipc_send>
  8003f2:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	6a 00                	push   $0x0
  8003fa:	6a 00                	push   $0x0
  8003fc:	57                   	push   %edi
  8003fd:	e8 47 13 00 00       	call   801749 <ipc_recv>
  800402:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	39 f0                	cmp    %esi,%eax
  80040c:	74 13                	je     800421 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	50                   	push   %eax
  800412:	68 18 2e 80 00       	push   $0x802e18
  800417:	e8 49 04 00 00       	call   800865 <cprintf>
				continue;
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	eb d4                	jmp    8003f5 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  800421:	e8 d8 0f 00 00       	call   8013fe <sys_time_msec>
  800426:	01 c3                	add    %eax,%ebx
  800428:	eb 97                	jmp    8003c1 <timer+0x2a>

0080042a <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  80042d:	c7 05 00 40 80 00 53 	movl   $0x802e53,0x804000
  800434:	2e 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  800437:	5d                   	pop    %ebp
  800438:	c3                   	ret    

00800439 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  80043c:	c7 05 00 40 80 00 5c 	movl   $0x802e5c,0x804000
  800443:	2e 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800451:	8b 45 08             	mov    0x8(%ebp),%eax
  800454:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800457:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  80045a:	c7 45 e0 08 50 80 00 	movl   $0x805008,-0x20(%ebp)
  800461:	0f b6 0f             	movzbl (%edi),%ecx
  800464:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800469:	0f b6 d9             	movzbl %cl,%ebx
  80046c:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  80046f:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800472:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800475:	66 c1 e8 0b          	shr    $0xb,%ax
  800479:	89 c3                	mov    %eax,%ebx
  80047b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047e:	01 c0                	add    %eax,%eax
  800480:	29 c1                	sub    %eax,%ecx
  800482:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  800484:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800486:	8d 72 01             	lea    0x1(%edx),%esi
  800489:	0f b6 d2             	movzbl %dl,%edx
  80048c:	83 c0 30             	add    $0x30,%eax
  80048f:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800493:	89 f2                	mov    %esi,%edx
    } while(*ap);
  800495:	84 db                	test   %bl,%bl
  800497:	75 d0                	jne    800469 <inet_ntoa+0x21>
  800499:	c6 07 00             	movb   $0x0,(%edi)
  80049c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049f:	eb 0d                	jmp    8004ae <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  8004a1:	0f b6 c2             	movzbl %dl,%eax
  8004a4:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  8004a9:	88 01                	mov    %al,(%ecx)
  8004ab:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8004ae:	83 ea 01             	sub    $0x1,%edx
  8004b1:	80 fa ff             	cmp    $0xff,%dl
  8004b4:	75 eb                	jne    8004a1 <inet_ntoa+0x59>
  8004b6:	89 f0                	mov    %esi,%eax
  8004b8:	0f b6 f0             	movzbl %al,%esi
  8004bb:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  8004be:	8d 46 01             	lea    0x1(%esi),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  8004c7:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8004ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004cd:	39 c7                	cmp    %eax,%edi
  8004cf:	75 90                	jne    800461 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  8004d1:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  8004d4:	b8 08 50 80 00       	mov    $0x805008,%eax
  8004d9:	83 c4 14             	add    $0x14,%esp
  8004dc:	5b                   	pop    %ebx
  8004dd:	5e                   	pop    %esi
  8004de:	5f                   	pop    %edi
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8004e4:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8004e8:	66 c1 c0 08          	rol    $0x8,%ax
}
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  return htons(n);
  8004f1:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8004f5:	66 c1 c0 08          	rol    $0x8,%ax
}
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800501:	89 d1                	mov    %edx,%ecx
  800503:	c1 e1 18             	shl    $0x18,%ecx
  800506:	89 d0                	mov    %edx,%eax
  800508:	c1 e8 18             	shr    $0x18,%eax
  80050b:	09 c8                	or     %ecx,%eax
  80050d:	89 d1                	mov    %edx,%ecx
  80050f:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800515:	c1 e1 08             	shl    $0x8,%ecx
  800518:	09 c8                	or     %ecx,%eax
  80051a:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800520:	c1 ea 08             	shr    $0x8,%edx
  800523:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800525:	5d                   	pop    %ebp
  800526:	c3                   	ret    

00800527 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	57                   	push   %edi
  80052b:	56                   	push   %esi
  80052c:	53                   	push   %ebx
  80052d:	83 ec 20             	sub    $0x20,%esp
  800530:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800533:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800536:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  800539:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80053c:	0f b6 ca             	movzbl %dl,%ecx
  80053f:	83 e9 30             	sub    $0x30,%ecx
  800542:	83 f9 09             	cmp    $0x9,%ecx
  800545:	0f 87 94 01 00 00    	ja     8006df <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  80054b:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  800552:	83 fa 30             	cmp    $0x30,%edx
  800555:	75 2b                	jne    800582 <inet_aton+0x5b>
      c = *++cp;
  800557:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  80055b:	89 d1                	mov    %edx,%ecx
  80055d:	83 e1 df             	and    $0xffffffdf,%ecx
  800560:	80 f9 58             	cmp    $0x58,%cl
  800563:	74 0f                	je     800574 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800565:	83 c0 01             	add    $0x1,%eax
  800568:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  80056b:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800572:	eb 0e                	jmp    800582 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800574:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800578:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  80057b:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800582:	83 c0 01             	add    $0x1,%eax
  800585:	be 00 00 00 00       	mov    $0x0,%esi
  80058a:	eb 03                	jmp    80058f <inet_aton+0x68>
  80058c:	83 c0 01             	add    $0x1,%eax
  80058f:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800592:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800595:	0f b6 fa             	movzbl %dl,%edi
  800598:	8d 4f d0             	lea    -0x30(%edi),%ecx
  80059b:	83 f9 09             	cmp    $0x9,%ecx
  80059e:	77 0d                	ja     8005ad <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  8005a0:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8005a4:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8005a8:	0f be 10             	movsbl (%eax),%edx
  8005ab:	eb df                	jmp    80058c <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  8005ad:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8005b1:	75 32                	jne    8005e5 <inet_aton+0xbe>
  8005b3:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  8005b6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8005b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005bc:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  8005c2:	83 e9 41             	sub    $0x41,%ecx
  8005c5:	83 f9 05             	cmp    $0x5,%ecx
  8005c8:	77 1b                	ja     8005e5 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8005ca:	c1 e6 04             	shl    $0x4,%esi
  8005cd:	83 c2 0a             	add    $0xa,%edx
  8005d0:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  8005d4:	19 c9                	sbb    %ecx,%ecx
  8005d6:	83 e1 20             	and    $0x20,%ecx
  8005d9:	83 c1 41             	add    $0x41,%ecx
  8005dc:	29 ca                	sub    %ecx,%edx
  8005de:	09 d6                	or     %edx,%esi
        c = *++cp;
  8005e0:	0f be 10             	movsbl (%eax),%edx
  8005e3:	eb a7                	jmp    80058c <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  8005e5:	83 fa 2e             	cmp    $0x2e,%edx
  8005e8:	75 23                	jne    80060d <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8005ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ed:	8d 7d f0             	lea    -0x10(%ebp),%edi
  8005f0:	39 f8                	cmp    %edi,%eax
  8005f2:	0f 84 ee 00 00 00    	je     8006e6 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  8005f8:	83 c0 04             	add    $0x4,%eax
  8005fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8005fe:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800601:	8d 43 01             	lea    0x1(%ebx),%eax
  800604:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800608:	e9 2f ff ff ff       	jmp    80053c <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80060d:	85 d2                	test   %edx,%edx
  80060f:	74 25                	je     800636 <inet_aton+0x10f>
  800611:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800614:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800619:	83 f9 5f             	cmp    $0x5f,%ecx
  80061c:	0f 87 d0 00 00 00    	ja     8006f2 <inet_aton+0x1cb>
  800622:	83 fa 20             	cmp    $0x20,%edx
  800625:	74 0f                	je     800636 <inet_aton+0x10f>
  800627:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80062a:	83 ea 09             	sub    $0x9,%edx
  80062d:	83 fa 04             	cmp    $0x4,%edx
  800630:	0f 87 bc 00 00 00    	ja     8006f2 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800636:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800639:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80063c:	29 c2                	sub    %eax,%edx
  80063e:	c1 fa 02             	sar    $0x2,%edx
  800641:	83 c2 01             	add    $0x1,%edx
  800644:	83 fa 02             	cmp    $0x2,%edx
  800647:	74 20                	je     800669 <inet_aton+0x142>
  800649:	83 fa 02             	cmp    $0x2,%edx
  80064c:	7f 0f                	jg     80065d <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  80064e:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800653:	85 d2                	test   %edx,%edx
  800655:	0f 84 97 00 00 00    	je     8006f2 <inet_aton+0x1cb>
  80065b:	eb 67                	jmp    8006c4 <inet_aton+0x19d>
  80065d:	83 fa 03             	cmp    $0x3,%edx
  800660:	74 1e                	je     800680 <inet_aton+0x159>
  800662:	83 fa 04             	cmp    $0x4,%edx
  800665:	74 38                	je     80069f <inet_aton+0x178>
  800667:	eb 5b                	jmp    8006c4 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  800669:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  80066e:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  800674:	77 7c                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  800676:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800679:	c1 e0 18             	shl    $0x18,%eax
  80067c:	09 c6                	or     %eax,%esi
    break;
  80067e:	eb 44                	jmp    8006c4 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800680:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800685:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  80068b:	77 65                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80068d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800690:	c1 e2 18             	shl    $0x18,%edx
  800693:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800696:	c1 e0 10             	shl    $0x10,%eax
  800699:	09 d0                	or     %edx,%eax
  80069b:	09 c6                	or     %eax,%esi
    break;
  80069d:	eb 25                	jmp    8006c4 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80069f:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8006a4:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  8006aa:	77 46                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8006ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006af:	c1 e2 18             	shl    $0x18,%edx
  8006b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006b5:	c1 e0 10             	shl    $0x10,%eax
  8006b8:	09 c2                	or     %eax,%edx
  8006ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bd:	c1 e0 08             	shl    $0x8,%eax
  8006c0:	09 d0                	or     %edx,%eax
  8006c2:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  8006c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006c8:	74 23                	je     8006ed <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  8006ca:	56                   	push   %esi
  8006cb:	e8 2b fe ff ff       	call   8004fb <htonl>
  8006d0:	83 c4 04             	add    $0x4,%esp
  8006d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d6:	89 03                	mov    %eax,(%ebx)
  return (1);
  8006d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8006dd:	eb 13                	jmp    8006f2 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	eb 0c                	jmp    8006f2 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 05                	jmp    8006f2 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8006ed:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8006f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5e                   	pop    %esi
  8006f7:	5f                   	pop    %edi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800700:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	ff 75 08             	pushl  0x8(%ebp)
  800707:	e8 1b fe ff ff       	call   800527 <inet_aton>
  80070c:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80070f:	85 c0                	test   %eax,%eax
  800711:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800716:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80071f:	ff 75 08             	pushl  0x8(%ebp)
  800722:	e8 d4 fd ff ff       	call   8004fb <htonl>
  800727:	83 c4 04             	add    $0x4,%esp
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
  800731:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800734:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800737:	e8 93 0a 00 00       	call   8011cf <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80073c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800741:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800744:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800749:	a3 20 50 80 00       	mov    %eax,0x805020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80074e:	85 db                	test   %ebx,%ebx
  800750:	7e 07                	jle    800759 <libmain+0x2d>
		binaryname = argv[0];
  800752:	8b 06                	mov    (%esi),%eax
  800754:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	56                   	push   %esi
  80075d:	53                   	push   %ebx
  80075e:	e8 d0 f8 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800763:	e8 0a 00 00 00       	call   800772 <exit>
}
  800768:	83 c4 10             	add    $0x10,%esp
  80076b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800778:	e8 95 12 00 00       	call   801a12 <close_all>
	sys_env_destroy(0);
  80077d:	83 ec 0c             	sub    $0xc,%esp
  800780:	6a 00                	push   $0x0
  800782:	e8 07 0a 00 00       	call   80118e <sys_env_destroy>
}
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    

0080078c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	56                   	push   %esi
  800790:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800791:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800794:	8b 35 00 40 80 00    	mov    0x804000,%esi
  80079a:	e8 30 0a 00 00       	call   8011cf <sys_getenvid>
  80079f:	83 ec 0c             	sub    $0xc,%esp
  8007a2:	ff 75 0c             	pushl  0xc(%ebp)
  8007a5:	ff 75 08             	pushl  0x8(%ebp)
  8007a8:	56                   	push   %esi
  8007a9:	50                   	push   %eax
  8007aa:	68 70 2e 80 00       	push   $0x802e70
  8007af:	e8 b1 00 00 00       	call   800865 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8007b4:	83 c4 18             	add    $0x18,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	ff 75 10             	pushl  0x10(%ebp)
  8007bb:	e8 54 00 00 00       	call   800814 <vcprintf>
	cprintf("\n");
  8007c0:	c7 04 24 ca 2d 80 00 	movl   $0x802dca,(%esp)
  8007c7:	e8 99 00 00 00       	call   800865 <cprintf>
  8007cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8007cf:	cc                   	int3   
  8007d0:	eb fd                	jmp    8007cf <_panic+0x43>

008007d2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 04             	sub    $0x4,%esp
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8007dc:	8b 13                	mov    (%ebx),%edx
  8007de:	8d 42 01             	lea    0x1(%edx),%eax
  8007e1:	89 03                	mov    %eax,(%ebx)
  8007e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8007ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007ef:	75 1a                	jne    80080b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	68 ff 00 00 00       	push   $0xff
  8007f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8007fc:	50                   	push   %eax
  8007fd:	e8 4f 09 00 00       	call   801151 <sys_cputs>
		b->idx = 0;
  800802:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800808:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80080b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80080f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80081d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800824:	00 00 00 
	b.cnt = 0;
  800827:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80082e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800831:	ff 75 0c             	pushl  0xc(%ebp)
  800834:	ff 75 08             	pushl  0x8(%ebp)
  800837:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80083d:	50                   	push   %eax
  80083e:	68 d2 07 80 00       	push   $0x8007d2
  800843:	e8 54 01 00 00       	call   80099c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800848:	83 c4 08             	add    $0x8,%esp
  80084b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800851:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800857:	50                   	push   %eax
  800858:	e8 f4 08 00 00       	call   801151 <sys_cputs>

	return b.cnt;
}
  80085d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80086b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80086e:	50                   	push   %eax
  80086f:	ff 75 08             	pushl  0x8(%ebp)
  800872:	e8 9d ff ff ff       	call   800814 <vcprintf>
	va_end(ap);

	return cnt;
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	57                   	push   %edi
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	83 ec 1c             	sub    $0x1c,%esp
  800882:	89 c7                	mov    %eax,%edi
  800884:	89 d6                	mov    %edx,%esi
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800892:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800895:	bb 00 00 00 00       	mov    $0x0,%ebx
  80089a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80089d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8008a0:	39 d3                	cmp    %edx,%ebx
  8008a2:	72 05                	jb     8008a9 <printnum+0x30>
  8008a4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8008a7:	77 45                	ja     8008ee <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8008a9:	83 ec 0c             	sub    $0xc,%esp
  8008ac:	ff 75 18             	pushl  0x18(%ebp)
  8008af:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8008b5:	53                   	push   %ebx
  8008b6:	ff 75 10             	pushl  0x10(%ebp)
  8008b9:	83 ec 08             	sub    $0x8,%esp
  8008bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8008c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8008c8:	e8 b3 21 00 00       	call   802a80 <__udivdi3>
  8008cd:	83 c4 18             	add    $0x18,%esp
  8008d0:	52                   	push   %edx
  8008d1:	50                   	push   %eax
  8008d2:	89 f2                	mov    %esi,%edx
  8008d4:	89 f8                	mov    %edi,%eax
  8008d6:	e8 9e ff ff ff       	call   800879 <printnum>
  8008db:	83 c4 20             	add    $0x20,%esp
  8008de:	eb 18                	jmp    8008f8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	56                   	push   %esi
  8008e4:	ff 75 18             	pushl  0x18(%ebp)
  8008e7:	ff d7                	call   *%edi
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	eb 03                	jmp    8008f1 <printnum+0x78>
  8008ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008f1:	83 eb 01             	sub    $0x1,%ebx
  8008f4:	85 db                	test   %ebx,%ebx
  8008f6:	7f e8                	jg     8008e0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	56                   	push   %esi
  8008fc:	83 ec 04             	sub    $0x4,%esp
  8008ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800902:	ff 75 e0             	pushl  -0x20(%ebp)
  800905:	ff 75 dc             	pushl  -0x24(%ebp)
  800908:	ff 75 d8             	pushl  -0x28(%ebp)
  80090b:	e8 a0 22 00 00       	call   802bb0 <__umoddi3>
  800910:	83 c4 14             	add    $0x14,%esp
  800913:	0f be 80 93 2e 80 00 	movsbl 0x802e93(%eax),%eax
  80091a:	50                   	push   %eax
  80091b:	ff d7                	call   *%edi
}
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80092b:	83 fa 01             	cmp    $0x1,%edx
  80092e:	7e 0e                	jle    80093e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800930:	8b 10                	mov    (%eax),%edx
  800932:	8d 4a 08             	lea    0x8(%edx),%ecx
  800935:	89 08                	mov    %ecx,(%eax)
  800937:	8b 02                	mov    (%edx),%eax
  800939:	8b 52 04             	mov    0x4(%edx),%edx
  80093c:	eb 22                	jmp    800960 <getuint+0x38>
	else if (lflag)
  80093e:	85 d2                	test   %edx,%edx
  800940:	74 10                	je     800952 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800942:	8b 10                	mov    (%eax),%edx
  800944:	8d 4a 04             	lea    0x4(%edx),%ecx
  800947:	89 08                	mov    %ecx,(%eax)
  800949:	8b 02                	mov    (%edx),%eax
  80094b:	ba 00 00 00 00       	mov    $0x0,%edx
  800950:	eb 0e                	jmp    800960 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800952:	8b 10                	mov    (%eax),%edx
  800954:	8d 4a 04             	lea    0x4(%edx),%ecx
  800957:	89 08                	mov    %ecx,(%eax)
  800959:	8b 02                	mov    (%edx),%eax
  80095b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800968:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80096c:	8b 10                	mov    (%eax),%edx
  80096e:	3b 50 04             	cmp    0x4(%eax),%edx
  800971:	73 0a                	jae    80097d <sprintputch+0x1b>
		*b->buf++ = ch;
  800973:	8d 4a 01             	lea    0x1(%edx),%ecx
  800976:	89 08                	mov    %ecx,(%eax)
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	88 02                	mov    %al,(%edx)
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800985:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800988:	50                   	push   %eax
  800989:	ff 75 10             	pushl  0x10(%ebp)
  80098c:	ff 75 0c             	pushl  0xc(%ebp)
  80098f:	ff 75 08             	pushl  0x8(%ebp)
  800992:	e8 05 00 00 00       	call   80099c <vprintfmt>
	va_end(ap);
}
  800997:	83 c4 10             	add    $0x10,%esp
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 2c             	sub    $0x2c,%esp
  8009a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009ae:	eb 12                	jmp    8009c2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	0f 84 a9 03 00 00    	je     800d61 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8009b8:	83 ec 08             	sub    $0x8,%esp
  8009bb:	53                   	push   %ebx
  8009bc:	50                   	push   %eax
  8009bd:	ff d6                	call   *%esi
  8009bf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009c2:	83 c7 01             	add    $0x1,%edi
  8009c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009c9:	83 f8 25             	cmp    $0x25,%eax
  8009cc:	75 e2                	jne    8009b0 <vprintfmt+0x14>
  8009ce:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009d2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009d9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8009e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ec:	eb 07                	jmp    8009f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009f1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f5:	8d 47 01             	lea    0x1(%edi),%eax
  8009f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009fb:	0f b6 07             	movzbl (%edi),%eax
  8009fe:	0f b6 c8             	movzbl %al,%ecx
  800a01:	83 e8 23             	sub    $0x23,%eax
  800a04:	3c 55                	cmp    $0x55,%al
  800a06:	0f 87 3a 03 00 00    	ja     800d46 <vprintfmt+0x3aa>
  800a0c:	0f b6 c0             	movzbl %al,%eax
  800a0f:	ff 24 85 e0 2f 80 00 	jmp    *0x802fe0(,%eax,4)
  800a16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a19:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a1d:	eb d6                	jmp    8009f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a2a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800a2d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800a31:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800a34:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800a37:	83 fa 09             	cmp    $0x9,%edx
  800a3a:	77 39                	ja     800a75 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a3c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a3f:	eb e9                	jmp    800a2a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a41:	8b 45 14             	mov    0x14(%ebp),%eax
  800a44:	8d 48 04             	lea    0x4(%eax),%ecx
  800a47:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a4a:	8b 00                	mov    (%eax),%eax
  800a4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a52:	eb 27                	jmp    800a7b <vprintfmt+0xdf>
  800a54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a57:	85 c0                	test   %eax,%eax
  800a59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a5e:	0f 49 c8             	cmovns %eax,%ecx
  800a61:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	eb 8c                	jmp    8009f5 <vprintfmt+0x59>
  800a69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a6c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a73:	eb 80                	jmp    8009f5 <vprintfmt+0x59>
  800a75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a78:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a7f:	0f 89 70 ff ff ff    	jns    8009f5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800a85:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a8b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a92:	e9 5e ff ff ff       	jmp    8009f5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a97:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a9d:	e9 53 ff ff ff       	jmp    8009f5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa5:	8d 50 04             	lea    0x4(%eax),%edx
  800aa8:	89 55 14             	mov    %edx,0x14(%ebp)
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	53                   	push   %ebx
  800aaf:	ff 30                	pushl  (%eax)
  800ab1:	ff d6                	call   *%esi
			break;
  800ab3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ab6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800ab9:	e9 04 ff ff ff       	jmp    8009c2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800abe:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac1:	8d 50 04             	lea    0x4(%eax),%edx
  800ac4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac7:	8b 00                	mov    (%eax),%eax
  800ac9:	99                   	cltd   
  800aca:	31 d0                	xor    %edx,%eax
  800acc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ace:	83 f8 0f             	cmp    $0xf,%eax
  800ad1:	7f 0b                	jg     800ade <vprintfmt+0x142>
  800ad3:	8b 14 85 40 31 80 00 	mov    0x803140(,%eax,4),%edx
  800ada:	85 d2                	test   %edx,%edx
  800adc:	75 18                	jne    800af6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800ade:	50                   	push   %eax
  800adf:	68 ab 2e 80 00       	push   $0x802eab
  800ae4:	53                   	push   %ebx
  800ae5:	56                   	push   %esi
  800ae6:	e8 94 fe ff ff       	call   80097f <printfmt>
  800aeb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800af1:	e9 cc fe ff ff       	jmp    8009c2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800af6:	52                   	push   %edx
  800af7:	68 4d 33 80 00       	push   $0x80334d
  800afc:	53                   	push   %ebx
  800afd:	56                   	push   %esi
  800afe:	e8 7c fe ff ff       	call   80097f <printfmt>
  800b03:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b09:	e9 b4 fe ff ff       	jmp    8009c2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b11:	8d 50 04             	lea    0x4(%eax),%edx
  800b14:	89 55 14             	mov    %edx,0x14(%ebp)
  800b17:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800b19:	85 ff                	test   %edi,%edi
  800b1b:	b8 a4 2e 80 00       	mov    $0x802ea4,%eax
  800b20:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800b23:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b27:	0f 8e 94 00 00 00    	jle    800bc1 <vprintfmt+0x225>
  800b2d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b31:	0f 84 98 00 00 00    	je     800bcf <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b37:	83 ec 08             	sub    $0x8,%esp
  800b3a:	ff 75 d0             	pushl  -0x30(%ebp)
  800b3d:	57                   	push   %edi
  800b3e:	e8 a6 02 00 00       	call   800de9 <strnlen>
  800b43:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b46:	29 c1                	sub    %eax,%ecx
  800b48:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800b4b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800b4e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b52:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b55:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800b58:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b5a:	eb 0f                	jmp    800b6b <vprintfmt+0x1cf>
					putch(padc, putdat);
  800b5c:	83 ec 08             	sub    $0x8,%esp
  800b5f:	53                   	push   %ebx
  800b60:	ff 75 e0             	pushl  -0x20(%ebp)
  800b63:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b65:	83 ef 01             	sub    $0x1,%edi
  800b68:	83 c4 10             	add    $0x10,%esp
  800b6b:	85 ff                	test   %edi,%edi
  800b6d:	7f ed                	jg     800b5c <vprintfmt+0x1c0>
  800b6f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800b72:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800b75:	85 c9                	test   %ecx,%ecx
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	0f 49 c1             	cmovns %ecx,%eax
  800b7f:	29 c1                	sub    %eax,%ecx
  800b81:	89 75 08             	mov    %esi,0x8(%ebp)
  800b84:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b87:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b8a:	89 cb                	mov    %ecx,%ebx
  800b8c:	eb 4d                	jmp    800bdb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b8e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b92:	74 1b                	je     800baf <vprintfmt+0x213>
  800b94:	0f be c0             	movsbl %al,%eax
  800b97:	83 e8 20             	sub    $0x20,%eax
  800b9a:	83 f8 5e             	cmp    $0x5e,%eax
  800b9d:	76 10                	jbe    800baf <vprintfmt+0x213>
					putch('?', putdat);
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	ff 75 0c             	pushl  0xc(%ebp)
  800ba5:	6a 3f                	push   $0x3f
  800ba7:	ff 55 08             	call   *0x8(%ebp)
  800baa:	83 c4 10             	add    $0x10,%esp
  800bad:	eb 0d                	jmp    800bbc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800baf:	83 ec 08             	sub    $0x8,%esp
  800bb2:	ff 75 0c             	pushl  0xc(%ebp)
  800bb5:	52                   	push   %edx
  800bb6:	ff 55 08             	call   *0x8(%ebp)
  800bb9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bbc:	83 eb 01             	sub    $0x1,%ebx
  800bbf:	eb 1a                	jmp    800bdb <vprintfmt+0x23f>
  800bc1:	89 75 08             	mov    %esi,0x8(%ebp)
  800bc4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bc7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800bcd:	eb 0c                	jmp    800bdb <vprintfmt+0x23f>
  800bcf:	89 75 08             	mov    %esi,0x8(%ebp)
  800bd2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bd5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bd8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800bdb:	83 c7 01             	add    $0x1,%edi
  800bde:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800be2:	0f be d0             	movsbl %al,%edx
  800be5:	85 d2                	test   %edx,%edx
  800be7:	74 23                	je     800c0c <vprintfmt+0x270>
  800be9:	85 f6                	test   %esi,%esi
  800beb:	78 a1                	js     800b8e <vprintfmt+0x1f2>
  800bed:	83 ee 01             	sub    $0x1,%esi
  800bf0:	79 9c                	jns    800b8e <vprintfmt+0x1f2>
  800bf2:	89 df                	mov    %ebx,%edi
  800bf4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bfa:	eb 18                	jmp    800c14 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bfc:	83 ec 08             	sub    $0x8,%esp
  800bff:	53                   	push   %ebx
  800c00:	6a 20                	push   $0x20
  800c02:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c04:	83 ef 01             	sub    $0x1,%edi
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	eb 08                	jmp    800c14 <vprintfmt+0x278>
  800c0c:	89 df                	mov    %ebx,%edi
  800c0e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c14:	85 ff                	test   %edi,%edi
  800c16:	7f e4                	jg     800bfc <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c1b:	e9 a2 fd ff ff       	jmp    8009c2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c20:	83 fa 01             	cmp    $0x1,%edx
  800c23:	7e 16                	jle    800c3b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800c25:	8b 45 14             	mov    0x14(%ebp),%eax
  800c28:	8d 50 08             	lea    0x8(%eax),%edx
  800c2b:	89 55 14             	mov    %edx,0x14(%ebp)
  800c2e:	8b 50 04             	mov    0x4(%eax),%edx
  800c31:	8b 00                	mov    (%eax),%eax
  800c33:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c36:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c39:	eb 32                	jmp    800c6d <vprintfmt+0x2d1>
	else if (lflag)
  800c3b:	85 d2                	test   %edx,%edx
  800c3d:	74 18                	je     800c57 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800c3f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c42:	8d 50 04             	lea    0x4(%eax),%edx
  800c45:	89 55 14             	mov    %edx,0x14(%ebp)
  800c48:	8b 00                	mov    (%eax),%eax
  800c4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c4d:	89 c1                	mov    %eax,%ecx
  800c4f:	c1 f9 1f             	sar    $0x1f,%ecx
  800c52:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800c55:	eb 16                	jmp    800c6d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800c57:	8b 45 14             	mov    0x14(%ebp),%eax
  800c5a:	8d 50 04             	lea    0x4(%eax),%edx
  800c5d:	89 55 14             	mov    %edx,0x14(%ebp)
  800c60:	8b 00                	mov    (%eax),%eax
  800c62:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c65:	89 c1                	mov    %eax,%ecx
  800c67:	c1 f9 1f             	sar    $0x1f,%ecx
  800c6a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c6d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c70:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c73:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c78:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c7c:	0f 89 90 00 00 00    	jns    800d12 <vprintfmt+0x376>
				putch('-', putdat);
  800c82:	83 ec 08             	sub    $0x8,%esp
  800c85:	53                   	push   %ebx
  800c86:	6a 2d                	push   $0x2d
  800c88:	ff d6                	call   *%esi
				num = -(long long) num;
  800c8a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c8d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800c90:	f7 d8                	neg    %eax
  800c92:	83 d2 00             	adc    $0x0,%edx
  800c95:	f7 da                	neg    %edx
  800c97:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800c9a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c9f:	eb 71                	jmp    800d12 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ca1:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca4:	e8 7f fc ff ff       	call   800928 <getuint>
			base = 10;
  800ca9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800cae:	eb 62                	jmp    800d12 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800cb0:	8d 45 14             	lea    0x14(%ebp),%eax
  800cb3:	e8 70 fc ff ff       	call   800928 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800cbf:	51                   	push   %ecx
  800cc0:	ff 75 e0             	pushl  -0x20(%ebp)
  800cc3:	6a 08                	push   $0x8
  800cc5:	52                   	push   %edx
  800cc6:	50                   	push   %eax
  800cc7:	89 da                	mov    %ebx,%edx
  800cc9:	89 f0                	mov    %esi,%eax
  800ccb:	e8 a9 fb ff ff       	call   800879 <printnum>
			break;
  800cd0:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800cd6:	e9 e7 fc ff ff       	jmp    8009c2 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800cdb:	83 ec 08             	sub    $0x8,%esp
  800cde:	53                   	push   %ebx
  800cdf:	6a 30                	push   $0x30
  800ce1:	ff d6                	call   *%esi
			putch('x', putdat);
  800ce3:	83 c4 08             	add    $0x8,%esp
  800ce6:	53                   	push   %ebx
  800ce7:	6a 78                	push   $0x78
  800ce9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ceb:	8b 45 14             	mov    0x14(%ebp),%eax
  800cee:	8d 50 04             	lea    0x4(%eax),%edx
  800cf1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cf4:	8b 00                	mov    (%eax),%eax
  800cf6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800cfb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cfe:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800d03:	eb 0d                	jmp    800d12 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d05:	8d 45 14             	lea    0x14(%ebp),%eax
  800d08:	e8 1b fc ff ff       	call   800928 <getuint>
			base = 16;
  800d0d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800d19:	57                   	push   %edi
  800d1a:	ff 75 e0             	pushl  -0x20(%ebp)
  800d1d:	51                   	push   %ecx
  800d1e:	52                   	push   %edx
  800d1f:	50                   	push   %eax
  800d20:	89 da                	mov    %ebx,%edx
  800d22:	89 f0                	mov    %esi,%eax
  800d24:	e8 50 fb ff ff       	call   800879 <printnum>
			break;
  800d29:	83 c4 20             	add    $0x20,%esp
  800d2c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d2f:	e9 8e fc ff ff       	jmp    8009c2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d34:	83 ec 08             	sub    $0x8,%esp
  800d37:	53                   	push   %ebx
  800d38:	51                   	push   %ecx
  800d39:	ff d6                	call   *%esi
			break;
  800d3b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d41:	e9 7c fc ff ff       	jmp    8009c2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d46:	83 ec 08             	sub    $0x8,%esp
  800d49:	53                   	push   %ebx
  800d4a:	6a 25                	push   $0x25
  800d4c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d4e:	83 c4 10             	add    $0x10,%esp
  800d51:	eb 03                	jmp    800d56 <vprintfmt+0x3ba>
  800d53:	83 ef 01             	sub    $0x1,%edi
  800d56:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800d5a:	75 f7                	jne    800d53 <vprintfmt+0x3b7>
  800d5c:	e9 61 fc ff ff       	jmp    8009c2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800d61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 18             	sub    $0x18,%esp
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d75:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d78:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d7c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	74 26                	je     800db0 <vsnprintf+0x47>
  800d8a:	85 d2                	test   %edx,%edx
  800d8c:	7e 22                	jle    800db0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d8e:	ff 75 14             	pushl  0x14(%ebp)
  800d91:	ff 75 10             	pushl  0x10(%ebp)
  800d94:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d97:	50                   	push   %eax
  800d98:	68 62 09 80 00       	push   $0x800962
  800d9d:	e8 fa fb ff ff       	call   80099c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800da2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800da5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dab:	83 c4 10             	add    $0x10,%esp
  800dae:	eb 05                	jmp    800db5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800db0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800dbd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800dc0:	50                   	push   %eax
  800dc1:	ff 75 10             	pushl  0x10(%ebp)
  800dc4:	ff 75 0c             	pushl  0xc(%ebp)
  800dc7:	ff 75 08             	pushl  0x8(%ebp)
  800dca:	e8 9a ff ff ff       	call   800d69 <vsnprintf>
	va_end(ap);

	return rc;
}
  800dcf:	c9                   	leave  
  800dd0:	c3                   	ret    

00800dd1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800dd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddc:	eb 03                	jmp    800de1 <strlen+0x10>
		n++;
  800dde:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800de1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800de5:	75 f7                	jne    800dde <strlen+0xd>
		n++;
	return n;
}
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800def:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800df2:	ba 00 00 00 00       	mov    $0x0,%edx
  800df7:	eb 03                	jmp    800dfc <strnlen+0x13>
		n++;
  800df9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dfc:	39 c2                	cmp    %eax,%edx
  800dfe:	74 08                	je     800e08 <strnlen+0x1f>
  800e00:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800e04:	75 f3                	jne    800df9 <strnlen+0x10>
  800e06:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	53                   	push   %ebx
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e14:	89 c2                	mov    %eax,%edx
  800e16:	83 c2 01             	add    $0x1,%edx
  800e19:	83 c1 01             	add    $0x1,%ecx
  800e1c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800e20:	88 5a ff             	mov    %bl,-0x1(%edx)
  800e23:	84 db                	test   %bl,%bl
  800e25:	75 ef                	jne    800e16 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800e27:	5b                   	pop    %ebx
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	53                   	push   %ebx
  800e2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e31:	53                   	push   %ebx
  800e32:	e8 9a ff ff ff       	call   800dd1 <strlen>
  800e37:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800e3a:	ff 75 0c             	pushl  0xc(%ebp)
  800e3d:	01 d8                	add    %ebx,%eax
  800e3f:	50                   	push   %eax
  800e40:	e8 c5 ff ff ff       	call   800e0a <strcpy>
	return dst;
}
  800e45:	89 d8                	mov    %ebx,%eax
  800e47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	8b 75 08             	mov    0x8(%ebp),%esi
  800e54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e57:	89 f3                	mov    %esi,%ebx
  800e59:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e5c:	89 f2                	mov    %esi,%edx
  800e5e:	eb 0f                	jmp    800e6f <strncpy+0x23>
		*dst++ = *src;
  800e60:	83 c2 01             	add    $0x1,%edx
  800e63:	0f b6 01             	movzbl (%ecx),%eax
  800e66:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e69:	80 39 01             	cmpb   $0x1,(%ecx)
  800e6c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e6f:	39 da                	cmp    %ebx,%edx
  800e71:	75 ed                	jne    800e60 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e73:	89 f0                	mov    %esi,%eax
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	56                   	push   %esi
  800e7d:	53                   	push   %ebx
  800e7e:	8b 75 08             	mov    0x8(%ebp),%esi
  800e81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e84:	8b 55 10             	mov    0x10(%ebp),%edx
  800e87:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e89:	85 d2                	test   %edx,%edx
  800e8b:	74 21                	je     800eae <strlcpy+0x35>
  800e8d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800e91:	89 f2                	mov    %esi,%edx
  800e93:	eb 09                	jmp    800e9e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e95:	83 c2 01             	add    $0x1,%edx
  800e98:	83 c1 01             	add    $0x1,%ecx
  800e9b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e9e:	39 c2                	cmp    %eax,%edx
  800ea0:	74 09                	je     800eab <strlcpy+0x32>
  800ea2:	0f b6 19             	movzbl (%ecx),%ebx
  800ea5:	84 db                	test   %bl,%bl
  800ea7:	75 ec                	jne    800e95 <strlcpy+0x1c>
  800ea9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800eab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800eae:	29 f0                	sub    %esi,%eax
}
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ebd:	eb 06                	jmp    800ec5 <strcmp+0x11>
		p++, q++;
  800ebf:	83 c1 01             	add    $0x1,%ecx
  800ec2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ec5:	0f b6 01             	movzbl (%ecx),%eax
  800ec8:	84 c0                	test   %al,%al
  800eca:	74 04                	je     800ed0 <strcmp+0x1c>
  800ecc:	3a 02                	cmp    (%edx),%al
  800ece:	74 ef                	je     800ebf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ed0:	0f b6 c0             	movzbl %al,%eax
  800ed3:	0f b6 12             	movzbl (%edx),%edx
  800ed6:	29 d0                	sub    %edx,%eax
}
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	53                   	push   %ebx
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee4:	89 c3                	mov    %eax,%ebx
  800ee6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ee9:	eb 06                	jmp    800ef1 <strncmp+0x17>
		n--, p++, q++;
  800eeb:	83 c0 01             	add    $0x1,%eax
  800eee:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ef1:	39 d8                	cmp    %ebx,%eax
  800ef3:	74 15                	je     800f0a <strncmp+0x30>
  800ef5:	0f b6 08             	movzbl (%eax),%ecx
  800ef8:	84 c9                	test   %cl,%cl
  800efa:	74 04                	je     800f00 <strncmp+0x26>
  800efc:	3a 0a                	cmp    (%edx),%cl
  800efe:	74 eb                	je     800eeb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f00:	0f b6 00             	movzbl (%eax),%eax
  800f03:	0f b6 12             	movzbl (%edx),%edx
  800f06:	29 d0                	sub    %edx,%eax
  800f08:	eb 05                	jmp    800f0f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f0a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f0f:	5b                   	pop    %ebx
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	8b 45 08             	mov    0x8(%ebp),%eax
  800f18:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f1c:	eb 07                	jmp    800f25 <strchr+0x13>
		if (*s == c)
  800f1e:	38 ca                	cmp    %cl,%dl
  800f20:	74 0f                	je     800f31 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f22:	83 c0 01             	add    $0x1,%eax
  800f25:	0f b6 10             	movzbl (%eax),%edx
  800f28:	84 d2                	test   %dl,%dl
  800f2a:	75 f2                	jne    800f1e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	8b 45 08             	mov    0x8(%ebp),%eax
  800f39:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f3d:	eb 03                	jmp    800f42 <strfind+0xf>
  800f3f:	83 c0 01             	add    $0x1,%eax
  800f42:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f45:	38 ca                	cmp    %cl,%dl
  800f47:	74 04                	je     800f4d <strfind+0x1a>
  800f49:	84 d2                	test   %dl,%dl
  800f4b:	75 f2                	jne    800f3f <strfind+0xc>
			break;
	return (char *) s;
}
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f5b:	85 c9                	test   %ecx,%ecx
  800f5d:	74 36                	je     800f95 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f65:	75 28                	jne    800f8f <memset+0x40>
  800f67:	f6 c1 03             	test   $0x3,%cl
  800f6a:	75 23                	jne    800f8f <memset+0x40>
		c &= 0xFF;
  800f6c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f70:	89 d3                	mov    %edx,%ebx
  800f72:	c1 e3 08             	shl    $0x8,%ebx
  800f75:	89 d6                	mov    %edx,%esi
  800f77:	c1 e6 18             	shl    $0x18,%esi
  800f7a:	89 d0                	mov    %edx,%eax
  800f7c:	c1 e0 10             	shl    $0x10,%eax
  800f7f:	09 f0                	or     %esi,%eax
  800f81:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f83:	89 d8                	mov    %ebx,%eax
  800f85:	09 d0                	or     %edx,%eax
  800f87:	c1 e9 02             	shr    $0x2,%ecx
  800f8a:	fc                   	cld    
  800f8b:	f3 ab                	rep stos %eax,%es:(%edi)
  800f8d:	eb 06                	jmp    800f95 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f92:	fc                   	cld    
  800f93:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f95:	89 f8                	mov    %edi,%eax
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	57                   	push   %edi
  800fa0:	56                   	push   %esi
  800fa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fa7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800faa:	39 c6                	cmp    %eax,%esi
  800fac:	73 35                	jae    800fe3 <memmove+0x47>
  800fae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800fb1:	39 d0                	cmp    %edx,%eax
  800fb3:	73 2e                	jae    800fe3 <memmove+0x47>
		s += n;
		d += n;
  800fb5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fb8:	89 d6                	mov    %edx,%esi
  800fba:	09 fe                	or     %edi,%esi
  800fbc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fc2:	75 13                	jne    800fd7 <memmove+0x3b>
  800fc4:	f6 c1 03             	test   $0x3,%cl
  800fc7:	75 0e                	jne    800fd7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800fc9:	83 ef 04             	sub    $0x4,%edi
  800fcc:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fcf:	c1 e9 02             	shr    $0x2,%ecx
  800fd2:	fd                   	std    
  800fd3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fd5:	eb 09                	jmp    800fe0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fd7:	83 ef 01             	sub    $0x1,%edi
  800fda:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fdd:	fd                   	std    
  800fde:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fe0:	fc                   	cld    
  800fe1:	eb 1d                	jmp    801000 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fe3:	89 f2                	mov    %esi,%edx
  800fe5:	09 c2                	or     %eax,%edx
  800fe7:	f6 c2 03             	test   $0x3,%dl
  800fea:	75 0f                	jne    800ffb <memmove+0x5f>
  800fec:	f6 c1 03             	test   $0x3,%cl
  800fef:	75 0a                	jne    800ffb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ff1:	c1 e9 02             	shr    $0x2,%ecx
  800ff4:	89 c7                	mov    %eax,%edi
  800ff6:	fc                   	cld    
  800ff7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ff9:	eb 05                	jmp    801000 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ffb:	89 c7                	mov    %eax,%edi
  800ffd:	fc                   	cld    
  800ffe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801007:	ff 75 10             	pushl  0x10(%ebp)
  80100a:	ff 75 0c             	pushl  0xc(%ebp)
  80100d:	ff 75 08             	pushl  0x8(%ebp)
  801010:	e8 87 ff ff ff       	call   800f9c <memmove>
}
  801015:	c9                   	leave  
  801016:	c3                   	ret    

00801017 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	56                   	push   %esi
  80101b:	53                   	push   %ebx
  80101c:	8b 45 08             	mov    0x8(%ebp),%eax
  80101f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801022:	89 c6                	mov    %eax,%esi
  801024:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801027:	eb 1a                	jmp    801043 <memcmp+0x2c>
		if (*s1 != *s2)
  801029:	0f b6 08             	movzbl (%eax),%ecx
  80102c:	0f b6 1a             	movzbl (%edx),%ebx
  80102f:	38 d9                	cmp    %bl,%cl
  801031:	74 0a                	je     80103d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801033:	0f b6 c1             	movzbl %cl,%eax
  801036:	0f b6 db             	movzbl %bl,%ebx
  801039:	29 d8                	sub    %ebx,%eax
  80103b:	eb 0f                	jmp    80104c <memcmp+0x35>
		s1++, s2++;
  80103d:	83 c0 01             	add    $0x1,%eax
  801040:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801043:	39 f0                	cmp    %esi,%eax
  801045:	75 e2                	jne    801029 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801047:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	53                   	push   %ebx
  801054:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801057:	89 c1                	mov    %eax,%ecx
  801059:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80105c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801060:	eb 0a                	jmp    80106c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801062:	0f b6 10             	movzbl (%eax),%edx
  801065:	39 da                	cmp    %ebx,%edx
  801067:	74 07                	je     801070 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801069:	83 c0 01             	add    $0x1,%eax
  80106c:	39 c8                	cmp    %ecx,%eax
  80106e:	72 f2                	jb     801062 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801070:	5b                   	pop    %ebx
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80107f:	eb 03                	jmp    801084 <strtol+0x11>
		s++;
  801081:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801084:	0f b6 01             	movzbl (%ecx),%eax
  801087:	3c 20                	cmp    $0x20,%al
  801089:	74 f6                	je     801081 <strtol+0xe>
  80108b:	3c 09                	cmp    $0x9,%al
  80108d:	74 f2                	je     801081 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80108f:	3c 2b                	cmp    $0x2b,%al
  801091:	75 0a                	jne    80109d <strtol+0x2a>
		s++;
  801093:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801096:	bf 00 00 00 00       	mov    $0x0,%edi
  80109b:	eb 11                	jmp    8010ae <strtol+0x3b>
  80109d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010a2:	3c 2d                	cmp    $0x2d,%al
  8010a4:	75 08                	jne    8010ae <strtol+0x3b>
		s++, neg = 1;
  8010a6:	83 c1 01             	add    $0x1,%ecx
  8010a9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ae:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010b4:	75 15                	jne    8010cb <strtol+0x58>
  8010b6:	80 39 30             	cmpb   $0x30,(%ecx)
  8010b9:	75 10                	jne    8010cb <strtol+0x58>
  8010bb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010bf:	75 7c                	jne    80113d <strtol+0xca>
		s += 2, base = 16;
  8010c1:	83 c1 02             	add    $0x2,%ecx
  8010c4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010c9:	eb 16                	jmp    8010e1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8010cb:	85 db                	test   %ebx,%ebx
  8010cd:	75 12                	jne    8010e1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010cf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010d4:	80 39 30             	cmpb   $0x30,(%ecx)
  8010d7:	75 08                	jne    8010e1 <strtol+0x6e>
		s++, base = 8;
  8010d9:	83 c1 01             	add    $0x1,%ecx
  8010dc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010e9:	0f b6 11             	movzbl (%ecx),%edx
  8010ec:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010ef:	89 f3                	mov    %esi,%ebx
  8010f1:	80 fb 09             	cmp    $0x9,%bl
  8010f4:	77 08                	ja     8010fe <strtol+0x8b>
			dig = *s - '0';
  8010f6:	0f be d2             	movsbl %dl,%edx
  8010f9:	83 ea 30             	sub    $0x30,%edx
  8010fc:	eb 22                	jmp    801120 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8010fe:	8d 72 9f             	lea    -0x61(%edx),%esi
  801101:	89 f3                	mov    %esi,%ebx
  801103:	80 fb 19             	cmp    $0x19,%bl
  801106:	77 08                	ja     801110 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801108:	0f be d2             	movsbl %dl,%edx
  80110b:	83 ea 57             	sub    $0x57,%edx
  80110e:	eb 10                	jmp    801120 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801110:	8d 72 bf             	lea    -0x41(%edx),%esi
  801113:	89 f3                	mov    %esi,%ebx
  801115:	80 fb 19             	cmp    $0x19,%bl
  801118:	77 16                	ja     801130 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80111a:	0f be d2             	movsbl %dl,%edx
  80111d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801120:	3b 55 10             	cmp    0x10(%ebp),%edx
  801123:	7d 0b                	jge    801130 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801125:	83 c1 01             	add    $0x1,%ecx
  801128:	0f af 45 10          	imul   0x10(%ebp),%eax
  80112c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80112e:	eb b9                	jmp    8010e9 <strtol+0x76>

	if (endptr)
  801130:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801134:	74 0d                	je     801143 <strtol+0xd0>
		*endptr = (char *) s;
  801136:	8b 75 0c             	mov    0xc(%ebp),%esi
  801139:	89 0e                	mov    %ecx,(%esi)
  80113b:	eb 06                	jmp    801143 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80113d:	85 db                	test   %ebx,%ebx
  80113f:	74 98                	je     8010d9 <strtol+0x66>
  801141:	eb 9e                	jmp    8010e1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801143:	89 c2                	mov    %eax,%edx
  801145:	f7 da                	neg    %edx
  801147:	85 ff                	test   %edi,%edi
  801149:	0f 45 c2             	cmovne %edx,%eax
}
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	57                   	push   %edi
  801155:	56                   	push   %esi
  801156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
  80115c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115f:	8b 55 08             	mov    0x8(%ebp),%edx
  801162:	89 c3                	mov    %eax,%ebx
  801164:	89 c7                	mov    %eax,%edi
  801166:	89 c6                	mov    %eax,%esi
  801168:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80116a:	5b                   	pop    %ebx
  80116b:	5e                   	pop    %esi
  80116c:	5f                   	pop    %edi
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <sys_cgetc>:

int
sys_cgetc(void)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	57                   	push   %edi
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801175:	ba 00 00 00 00       	mov    $0x0,%edx
  80117a:	b8 01 00 00 00       	mov    $0x1,%eax
  80117f:	89 d1                	mov    %edx,%ecx
  801181:	89 d3                	mov    %edx,%ebx
  801183:	89 d7                	mov    %edx,%edi
  801185:	89 d6                	mov    %edx,%esi
  801187:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5f                   	pop    %edi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	57                   	push   %edi
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801197:	b9 00 00 00 00       	mov    $0x0,%ecx
  80119c:	b8 03 00 00 00       	mov    $0x3,%eax
  8011a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a4:	89 cb                	mov    %ecx,%ebx
  8011a6:	89 cf                	mov    %ecx,%edi
  8011a8:	89 ce                	mov    %ecx,%esi
  8011aa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	7e 17                	jle    8011c7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b0:	83 ec 0c             	sub    $0xc,%esp
  8011b3:	50                   	push   %eax
  8011b4:	6a 03                	push   $0x3
  8011b6:	68 9f 31 80 00       	push   $0x80319f
  8011bb:	6a 23                	push   $0x23
  8011bd:	68 bc 31 80 00       	push   $0x8031bc
  8011c2:	e8 c5 f5 ff ff       	call   80078c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ca:	5b                   	pop    %ebx
  8011cb:	5e                   	pop    %esi
  8011cc:	5f                   	pop    %edi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	57                   	push   %edi
  8011d3:	56                   	push   %esi
  8011d4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011da:	b8 02 00 00 00       	mov    $0x2,%eax
  8011df:	89 d1                	mov    %edx,%ecx
  8011e1:	89 d3                	mov    %edx,%ebx
  8011e3:	89 d7                	mov    %edx,%edi
  8011e5:	89 d6                	mov    %edx,%esi
  8011e7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011e9:	5b                   	pop    %ebx
  8011ea:	5e                   	pop    %esi
  8011eb:	5f                   	pop    %edi
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <sys_yield>:

void
sys_yield(void)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011fe:	89 d1                	mov    %edx,%ecx
  801200:	89 d3                	mov    %edx,%ebx
  801202:	89 d7                	mov    %edx,%edi
  801204:	89 d6                	mov    %edx,%esi
  801206:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	57                   	push   %edi
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801216:	be 00 00 00 00       	mov    $0x0,%esi
  80121b:	b8 04 00 00 00       	mov    $0x4,%eax
  801220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801223:	8b 55 08             	mov    0x8(%ebp),%edx
  801226:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801229:	89 f7                	mov    %esi,%edi
  80122b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80122d:	85 c0                	test   %eax,%eax
  80122f:	7e 17                	jle    801248 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801231:	83 ec 0c             	sub    $0xc,%esp
  801234:	50                   	push   %eax
  801235:	6a 04                	push   $0x4
  801237:	68 9f 31 80 00       	push   $0x80319f
  80123c:	6a 23                	push   $0x23
  80123e:	68 bc 31 80 00       	push   $0x8031bc
  801243:	e8 44 f5 ff ff       	call   80078c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	57                   	push   %edi
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
  801256:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801259:	b8 05 00 00 00       	mov    $0x5,%eax
  80125e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801261:	8b 55 08             	mov    0x8(%ebp),%edx
  801264:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801267:	8b 7d 14             	mov    0x14(%ebp),%edi
  80126a:	8b 75 18             	mov    0x18(%ebp),%esi
  80126d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80126f:	85 c0                	test   %eax,%eax
  801271:	7e 17                	jle    80128a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801273:	83 ec 0c             	sub    $0xc,%esp
  801276:	50                   	push   %eax
  801277:	6a 05                	push   $0x5
  801279:	68 9f 31 80 00       	push   $0x80319f
  80127e:	6a 23                	push   $0x23
  801280:	68 bc 31 80 00       	push   $0x8031bc
  801285:	e8 02 f5 ff ff       	call   80078c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80128a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5f                   	pop    %edi
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8012a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ab:	89 df                	mov    %ebx,%edi
  8012ad:	89 de                	mov    %ebx,%esi
  8012af:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	7e 17                	jle    8012cc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b5:	83 ec 0c             	sub    $0xc,%esp
  8012b8:	50                   	push   %eax
  8012b9:	6a 06                	push   $0x6
  8012bb:	68 9f 31 80 00       	push   $0x80319f
  8012c0:	6a 23                	push   $0x23
  8012c2:	68 bc 31 80 00       	push   $0x8031bc
  8012c7:	e8 c0 f4 ff ff       	call   80078c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5e                   	pop    %esi
  8012d1:	5f                   	pop    %edi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	57                   	push   %edi
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8012e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ed:	89 df                	mov    %ebx,%edi
  8012ef:	89 de                	mov    %ebx,%esi
  8012f1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	7e 17                	jle    80130e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f7:	83 ec 0c             	sub    $0xc,%esp
  8012fa:	50                   	push   %eax
  8012fb:	6a 08                	push   $0x8
  8012fd:	68 9f 31 80 00       	push   $0x80319f
  801302:	6a 23                	push   $0x23
  801304:	68 bc 31 80 00       	push   $0x8031bc
  801309:	e8 7e f4 ff ff       	call   80078c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80130e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801311:	5b                   	pop    %ebx
  801312:	5e                   	pop    %esi
  801313:	5f                   	pop    %edi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	57                   	push   %edi
  80131a:	56                   	push   %esi
  80131b:	53                   	push   %ebx
  80131c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80131f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801324:	b8 09 00 00 00       	mov    $0x9,%eax
  801329:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132c:	8b 55 08             	mov    0x8(%ebp),%edx
  80132f:	89 df                	mov    %ebx,%edi
  801331:	89 de                	mov    %ebx,%esi
  801333:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801335:	85 c0                	test   %eax,%eax
  801337:	7e 17                	jle    801350 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	50                   	push   %eax
  80133d:	6a 09                	push   $0x9
  80133f:	68 9f 31 80 00       	push   $0x80319f
  801344:	6a 23                	push   $0x23
  801346:	68 bc 31 80 00       	push   $0x8031bc
  80134b:	e8 3c f4 ff ff       	call   80078c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801350:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    

00801358 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	57                   	push   %edi
  80135c:	56                   	push   %esi
  80135d:	53                   	push   %ebx
  80135e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801361:	bb 00 00 00 00       	mov    $0x0,%ebx
  801366:	b8 0a 00 00 00       	mov    $0xa,%eax
  80136b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80136e:	8b 55 08             	mov    0x8(%ebp),%edx
  801371:	89 df                	mov    %ebx,%edi
  801373:	89 de                	mov    %ebx,%esi
  801375:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801377:	85 c0                	test   %eax,%eax
  801379:	7e 17                	jle    801392 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80137b:	83 ec 0c             	sub    $0xc,%esp
  80137e:	50                   	push   %eax
  80137f:	6a 0a                	push   $0xa
  801381:	68 9f 31 80 00       	push   $0x80319f
  801386:	6a 23                	push   $0x23
  801388:	68 bc 31 80 00       	push   $0x8031bc
  80138d:	e8 fa f3 ff ff       	call   80078c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801392:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801395:	5b                   	pop    %ebx
  801396:	5e                   	pop    %esi
  801397:	5f                   	pop    %edi
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    

0080139a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	57                   	push   %edi
  80139e:	56                   	push   %esi
  80139f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013a0:	be 00 00 00 00       	mov    $0x0,%esi
  8013a5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013b6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	57                   	push   %edi
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
  8013c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013cb:	b8 0d 00 00 00       	mov    $0xd,%eax
  8013d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d3:	89 cb                	mov    %ecx,%ebx
  8013d5:	89 cf                	mov    %ecx,%edi
  8013d7:	89 ce                	mov    %ecx,%esi
  8013d9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	7e 17                	jle    8013f6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013df:	83 ec 0c             	sub    $0xc,%esp
  8013e2:	50                   	push   %eax
  8013e3:	6a 0d                	push   $0xd
  8013e5:	68 9f 31 80 00       	push   $0x80319f
  8013ea:	6a 23                	push   $0x23
  8013ec:	68 bc 31 80 00       	push   $0x8031bc
  8013f1:	e8 96 f3 ff ff       	call   80078c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f9:	5b                   	pop    %ebx
  8013fa:	5e                   	pop    %esi
  8013fb:	5f                   	pop    %edi
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	57                   	push   %edi
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801404:	ba 00 00 00 00       	mov    $0x0,%edx
  801409:	b8 0e 00 00 00       	mov    $0xe,%eax
  80140e:	89 d1                	mov    %edx,%ecx
  801410:	89 d3                	mov    %edx,%ebx
  801412:	89 d7                	mov    %edx,%edi
  801414:	89 d6                	mov    %edx,%esi
  801416:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5f                   	pop    %edi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	53                   	push   %ebx
  801421:	83 ec 04             	sub    $0x4,%esp
  801424:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801427:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  801429:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  80142c:	f6 c1 02             	test   $0x2,%cl
  80142f:	74 2e                	je     80145f <pgfault+0x42>
  801431:	89 c2                	mov    %eax,%edx
  801433:	c1 ea 16             	shr    $0x16,%edx
  801436:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143d:	f6 c2 01             	test   $0x1,%dl
  801440:	74 1d                	je     80145f <pgfault+0x42>
  801442:	89 c2                	mov    %eax,%edx
  801444:	c1 ea 0c             	shr    $0xc,%edx
  801447:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  80144e:	f6 c3 01             	test   $0x1,%bl
  801451:	74 0c                	je     80145f <pgfault+0x42>
  801453:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80145a:	f6 c6 08             	test   $0x8,%dh
  80145d:	75 12                	jne    801471 <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  80145f:	51                   	push   %ecx
  801460:	68 ca 31 80 00       	push   $0x8031ca
  801465:	6a 1e                	push   $0x1e
  801467:	68 e3 31 80 00       	push   $0x8031e3
  80146c:	e8 1b f3 ff ff       	call   80078c <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  801471:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801476:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	6a 07                	push   $0x7
  80147d:	68 00 f0 7f 00       	push   $0x7ff000
  801482:	6a 00                	push   $0x0
  801484:	e8 84 fd ff ff       	call   80120d <sys_page_alloc>
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	85 c0                	test   %eax,%eax
  80148e:	79 12                	jns    8014a2 <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  801490:	50                   	push   %eax
  801491:	68 ee 31 80 00       	push   $0x8031ee
  801496:	6a 29                	push   $0x29
  801498:	68 e3 31 80 00       	push   $0x8031e3
  80149d:	e8 ea f2 ff ff       	call   80078c <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	68 00 10 00 00       	push   $0x1000
  8014aa:	53                   	push   %ebx
  8014ab:	68 00 f0 7f 00       	push   $0x7ff000
  8014b0:	e8 4f fb ff ff       	call   801004 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  8014b5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8014bc:	53                   	push   %ebx
  8014bd:	6a 00                	push   $0x0
  8014bf:	68 00 f0 7f 00       	push   $0x7ff000
  8014c4:	6a 00                	push   $0x0
  8014c6:	e8 85 fd ff ff       	call   801250 <sys_page_map>
  8014cb:	83 c4 20             	add    $0x20,%esp
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	79 12                	jns    8014e4 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  8014d2:	50                   	push   %eax
  8014d3:	68 09 32 80 00       	push   $0x803209
  8014d8:	6a 2e                	push   $0x2e
  8014da:	68 e3 31 80 00       	push   $0x8031e3
  8014df:	e8 a8 f2 ff ff       	call   80078c <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	68 00 f0 7f 00       	push   $0x7ff000
  8014ec:	6a 00                	push   $0x0
  8014ee:	e8 9f fd ff ff       	call   801292 <sys_page_unmap>
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	79 12                	jns    80150c <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  8014fa:	50                   	push   %eax
  8014fb:	68 22 32 80 00       	push   $0x803222
  801500:	6a 31                	push   $0x31
  801502:	68 e3 31 80 00       	push   $0x8031e3
  801507:	e8 80 f2 ff ff       	call   80078c <_panic>

}
  80150c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150f:	c9                   	leave  
  801510:	c3                   	ret    

00801511 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	57                   	push   %edi
  801515:	56                   	push   %esi
  801516:	53                   	push   %ebx
  801517:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  80151a:	68 1d 14 80 00       	push   $0x80141d
  80151f:	e8 80 14 00 00       	call   8029a4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801524:	b8 07 00 00 00       	mov    $0x7,%eax
  801529:	cd 30                	int    $0x30
  80152b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80152e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	bb 00 00 00 00       	mov    $0x0,%ebx
  801539:	85 c0                	test   %eax,%eax
  80153b:	75 21                	jne    80155e <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  80153d:	e8 8d fc ff ff       	call   8011cf <sys_getenvid>
  801542:	25 ff 03 00 00       	and    $0x3ff,%eax
  801547:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80154a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80154f:	a3 20 50 80 00       	mov    %eax,0x805020
		return 0;
  801554:	b8 00 00 00 00       	mov    $0x0,%eax
  801559:	e9 c9 01 00 00       	jmp    801727 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  80155e:	89 d8                	mov    %ebx,%eax
  801560:	c1 e8 16             	shr    $0x16,%eax
  801563:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80156a:	a8 01                	test   $0x1,%al
  80156c:	0f 84 1b 01 00 00    	je     80168d <fork+0x17c>
  801572:	89 de                	mov    %ebx,%esi
  801574:	c1 ee 0c             	shr    $0xc,%esi
  801577:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80157e:	a8 01                	test   $0x1,%al
  801580:	0f 84 07 01 00 00    	je     80168d <fork+0x17c>
  801586:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80158d:	a8 04                	test   $0x4,%al
  80158f:	0f 84 f8 00 00 00    	je     80168d <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  801595:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80159c:	f6 c4 04             	test   $0x4,%ah
  80159f:	74 3c                	je     8015dd <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  8015a1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8015a8:	c1 e6 0c             	shl    $0xc,%esi
  8015ab:	83 ec 0c             	sub    $0xc,%esp
  8015ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b3:	50                   	push   %eax
  8015b4:	56                   	push   %esi
  8015b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015b8:	56                   	push   %esi
  8015b9:	6a 00                	push   $0x0
  8015bb:	e8 90 fc ff ff       	call   801250 <sys_page_map>
  8015c0:	83 c4 20             	add    $0x20,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	0f 89 c2 00 00 00    	jns    80168d <fork+0x17c>
			panic("duppage: %e", r);
  8015cb:	50                   	push   %eax
  8015cc:	68 3d 32 80 00       	push   $0x80323d
  8015d1:	6a 48                	push   $0x48
  8015d3:	68 e3 31 80 00       	push   $0x8031e3
  8015d8:	e8 af f1 ff ff       	call   80078c <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  8015dd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8015e4:	f6 c4 08             	test   $0x8,%ah
  8015e7:	75 0b                	jne    8015f4 <fork+0xe3>
  8015e9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8015f0:	a8 02                	test   $0x2,%al
  8015f2:	74 6c                	je     801660 <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  8015f4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8015fb:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  8015fe:	83 f8 01             	cmp    $0x1,%eax
  801601:	19 ff                	sbb    %edi,%edi
  801603:	83 e7 fc             	and    $0xfffffffc,%edi
  801606:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  80160c:	c1 e6 0c             	shl    $0xc,%esi
  80160f:	83 ec 0c             	sub    $0xc,%esp
  801612:	57                   	push   %edi
  801613:	56                   	push   %esi
  801614:	ff 75 e4             	pushl  -0x1c(%ebp)
  801617:	56                   	push   %esi
  801618:	6a 00                	push   $0x0
  80161a:	e8 31 fc ff ff       	call   801250 <sys_page_map>
  80161f:	83 c4 20             	add    $0x20,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	79 12                	jns    801638 <fork+0x127>
			panic("duppage: %e", r);
  801626:	50                   	push   %eax
  801627:	68 3d 32 80 00       	push   $0x80323d
  80162c:	6a 50                	push   $0x50
  80162e:	68 e3 31 80 00       	push   $0x8031e3
  801633:	e8 54 f1 ff ff       	call   80078c <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  801638:	83 ec 0c             	sub    $0xc,%esp
  80163b:	57                   	push   %edi
  80163c:	56                   	push   %esi
  80163d:	6a 00                	push   $0x0
  80163f:	56                   	push   %esi
  801640:	6a 00                	push   $0x0
  801642:	e8 09 fc ff ff       	call   801250 <sys_page_map>
  801647:	83 c4 20             	add    $0x20,%esp
  80164a:	85 c0                	test   %eax,%eax
  80164c:	79 3f                	jns    80168d <fork+0x17c>
			panic("duppage: %e", r);
  80164e:	50                   	push   %eax
  80164f:	68 3d 32 80 00       	push   $0x80323d
  801654:	6a 53                	push   $0x53
  801656:	68 e3 31 80 00       	push   $0x8031e3
  80165b:	e8 2c f1 ff ff       	call   80078c <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  801660:	c1 e6 0c             	shl    $0xc,%esi
  801663:	83 ec 0c             	sub    $0xc,%esp
  801666:	6a 05                	push   $0x5
  801668:	56                   	push   %esi
  801669:	ff 75 e4             	pushl  -0x1c(%ebp)
  80166c:	56                   	push   %esi
  80166d:	6a 00                	push   $0x0
  80166f:	e8 dc fb ff ff       	call   801250 <sys_page_map>
  801674:	83 c4 20             	add    $0x20,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	79 12                	jns    80168d <fork+0x17c>
			panic("duppage: %e", r);
  80167b:	50                   	push   %eax
  80167c:	68 3d 32 80 00       	push   $0x80323d
  801681:	6a 57                	push   $0x57
  801683:	68 e3 31 80 00       	push   $0x8031e3
  801688:	e8 ff f0 ff ff       	call   80078c <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  80168d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801693:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801699:	0f 85 bf fe ff ff    	jne    80155e <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	6a 07                	push   $0x7
  8016a4:	68 00 f0 bf ee       	push   $0xeebff000
  8016a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ac:	e8 5c fb ff ff       	call   80120d <sys_page_alloc>
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	74 17                	je     8016cf <fork+0x1be>
		panic("sys_page_alloc Error");
  8016b8:	83 ec 04             	sub    $0x4,%esp
  8016bb:	68 49 32 80 00       	push   $0x803249
  8016c0:	68 83 00 00 00       	push   $0x83
  8016c5:	68 e3 31 80 00       	push   $0x8031e3
  8016ca:	e8 bd f0 ff ff       	call   80078c <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	68 13 2a 80 00       	push   $0x802a13
  8016d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8016da:	e8 79 fc ff ff       	call   801358 <sys_env_set_pgfault_upcall>
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	79 15                	jns    8016fb <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  8016e6:	50                   	push   %eax
  8016e7:	68 5e 32 80 00       	push   $0x80325e
  8016ec:	68 86 00 00 00       	push   $0x86
  8016f1:	68 e3 31 80 00       	push   $0x8031e3
  8016f6:	e8 91 f0 ff ff       	call   80078c <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  8016fb:	83 ec 08             	sub    $0x8,%esp
  8016fe:	6a 02                	push   $0x2
  801700:	ff 75 e0             	pushl  -0x20(%ebp)
  801703:	e8 cc fb ff ff       	call   8012d4 <sys_env_set_status>
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	79 15                	jns    801724 <fork+0x213>
		panic("fork set status: %e", r);
  80170f:	50                   	push   %eax
  801710:	68 76 32 80 00       	push   $0x803276
  801715:	68 89 00 00 00       	push   $0x89
  80171a:	68 e3 31 80 00       	push   $0x8031e3
  80171f:	e8 68 f0 ff ff       	call   80078c <_panic>
	
	return envid;
  801724:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801727:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172a:	5b                   	pop    %ebx
  80172b:	5e                   	pop    %esi
  80172c:	5f                   	pop    %edi
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    

0080172f <sfork>:


// Challenge!
int
sfork(void)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801735:	68 8a 32 80 00       	push   $0x80328a
  80173a:	68 93 00 00 00       	push   $0x93
  80173f:	68 e3 31 80 00       	push   $0x8031e3
  801744:	e8 43 f0 ff ff       	call   80078c <_panic>

00801749 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	56                   	push   %esi
  80174d:	53                   	push   %ebx
  80174e:	8b 75 08             	mov    0x8(%ebp),%esi
  801751:	8b 45 0c             	mov    0xc(%ebp),%eax
  801754:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801757:	85 c0                	test   %eax,%eax
  801759:	74 0e                	je     801769 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  80175b:	83 ec 0c             	sub    $0xc,%esp
  80175e:	50                   	push   %eax
  80175f:	e8 59 fc ff ff       	call   8013bd <sys_ipc_recv>
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	eb 10                	jmp    801779 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801769:	83 ec 0c             	sub    $0xc,%esp
  80176c:	68 00 00 c0 ee       	push   $0xeec00000
  801771:	e8 47 fc ff ff       	call   8013bd <sys_ipc_recv>
  801776:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801779:	85 c0                	test   %eax,%eax
  80177b:	79 17                	jns    801794 <ipc_recv+0x4b>
		if(*from_env_store)
  80177d:	83 3e 00             	cmpl   $0x0,(%esi)
  801780:	74 06                	je     801788 <ipc_recv+0x3f>
			*from_env_store = 0;
  801782:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801788:	85 db                	test   %ebx,%ebx
  80178a:	74 2c                	je     8017b8 <ipc_recv+0x6f>
			*perm_store = 0;
  80178c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801792:	eb 24                	jmp    8017b8 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801794:	85 f6                	test   %esi,%esi
  801796:	74 0a                	je     8017a2 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801798:	a1 20 50 80 00       	mov    0x805020,%eax
  80179d:	8b 40 74             	mov    0x74(%eax),%eax
  8017a0:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8017a2:	85 db                	test   %ebx,%ebx
  8017a4:	74 0a                	je     8017b0 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8017a6:	a1 20 50 80 00       	mov    0x805020,%eax
  8017ab:	8b 40 78             	mov    0x78(%eax),%eax
  8017ae:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8017b0:	a1 20 50 80 00       	mov    0x805020,%eax
  8017b5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8017b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bb:	5b                   	pop    %ebx
  8017bc:	5e                   	pop    %esi
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	57                   	push   %edi
  8017c3:	56                   	push   %esi
  8017c4:	53                   	push   %ebx
  8017c5:	83 ec 0c             	sub    $0xc,%esp
  8017c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8017ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8017d1:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  8017d3:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  8017d8:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  8017db:	e8 0e fa ff ff       	call   8011ee <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  8017e0:	ff 75 14             	pushl  0x14(%ebp)
  8017e3:	53                   	push   %ebx
  8017e4:	56                   	push   %esi
  8017e5:	57                   	push   %edi
  8017e6:	e8 af fb ff ff       	call   80139a <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	f7 d2                	not    %edx
  8017ef:	c1 ea 1f             	shr    $0x1f,%edx
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8017f8:	0f 94 c1             	sete   %cl
  8017fb:	09 ca                	or     %ecx,%edx
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	0f 94 c0             	sete   %al
  801802:	38 c2                	cmp    %al,%dl
  801804:	77 d5                	ja     8017db <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801806:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5f                   	pop    %edi
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    

0080180e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801814:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801819:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80181c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801822:	8b 52 50             	mov    0x50(%edx),%edx
  801825:	39 ca                	cmp    %ecx,%edx
  801827:	75 0d                	jne    801836 <ipc_find_env+0x28>
			return envs[i].env_id;
  801829:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80182c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801831:	8b 40 48             	mov    0x48(%eax),%eax
  801834:	eb 0f                	jmp    801845 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801836:	83 c0 01             	add    $0x1,%eax
  801839:	3d 00 04 00 00       	cmp    $0x400,%eax
  80183e:	75 d9                	jne    801819 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801840:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	05 00 00 00 30       	add    $0x30000000,%eax
  801852:	c1 e8 0c             	shr    $0xc,%eax
}
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	05 00 00 00 30       	add    $0x30000000,%eax
  801862:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801867:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801874:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801879:	89 c2                	mov    %eax,%edx
  80187b:	c1 ea 16             	shr    $0x16,%edx
  80187e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801885:	f6 c2 01             	test   $0x1,%dl
  801888:	74 11                	je     80189b <fd_alloc+0x2d>
  80188a:	89 c2                	mov    %eax,%edx
  80188c:	c1 ea 0c             	shr    $0xc,%edx
  80188f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801896:	f6 c2 01             	test   $0x1,%dl
  801899:	75 09                	jne    8018a4 <fd_alloc+0x36>
			*fd_store = fd;
  80189b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80189d:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a2:	eb 17                	jmp    8018bb <fd_alloc+0x4d>
  8018a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8018a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8018ae:	75 c9                	jne    801879 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8018b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8018b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8018c3:	83 f8 1f             	cmp    $0x1f,%eax
  8018c6:	77 36                	ja     8018fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8018c8:	c1 e0 0c             	shl    $0xc,%eax
  8018cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8018d0:	89 c2                	mov    %eax,%edx
  8018d2:	c1 ea 16             	shr    $0x16,%edx
  8018d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8018dc:	f6 c2 01             	test   $0x1,%dl
  8018df:	74 24                	je     801905 <fd_lookup+0x48>
  8018e1:	89 c2                	mov    %eax,%edx
  8018e3:	c1 ea 0c             	shr    $0xc,%edx
  8018e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018ed:	f6 c2 01             	test   $0x1,%dl
  8018f0:	74 1a                	je     80190c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8018f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8018f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fc:	eb 13                	jmp    801911 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801903:	eb 0c                	jmp    801911 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801905:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80190a:	eb 05                	jmp    801911 <fd_lookup+0x54>
  80190c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801911:	5d                   	pop    %ebp
  801912:	c3                   	ret    

00801913 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80191c:	ba 20 33 80 00       	mov    $0x803320,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801921:	eb 13                	jmp    801936 <dev_lookup+0x23>
  801923:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801926:	39 08                	cmp    %ecx,(%eax)
  801928:	75 0c                	jne    801936 <dev_lookup+0x23>
			*dev = devtab[i];
  80192a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80192d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80192f:	b8 00 00 00 00       	mov    $0x0,%eax
  801934:	eb 2e                	jmp    801964 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801936:	8b 02                	mov    (%edx),%eax
  801938:	85 c0                	test   %eax,%eax
  80193a:	75 e7                	jne    801923 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80193c:	a1 20 50 80 00       	mov    0x805020,%eax
  801941:	8b 40 48             	mov    0x48(%eax),%eax
  801944:	83 ec 04             	sub    $0x4,%esp
  801947:	51                   	push   %ecx
  801948:	50                   	push   %eax
  801949:	68 a0 32 80 00       	push   $0x8032a0
  80194e:	e8 12 ef ff ff       	call   800865 <cprintf>
	*dev = 0;
  801953:	8b 45 0c             	mov    0xc(%ebp),%eax
  801956:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	56                   	push   %esi
  80196a:	53                   	push   %ebx
  80196b:	83 ec 10             	sub    $0x10,%esp
  80196e:	8b 75 08             	mov    0x8(%ebp),%esi
  801971:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801974:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801977:	50                   	push   %eax
  801978:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80197e:	c1 e8 0c             	shr    $0xc,%eax
  801981:	50                   	push   %eax
  801982:	e8 36 ff ff ff       	call   8018bd <fd_lookup>
  801987:	83 c4 08             	add    $0x8,%esp
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 05                	js     801993 <fd_close+0x2d>
	    || fd != fd2)
  80198e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801991:	74 0c                	je     80199f <fd_close+0x39>
		return (must_exist ? r : 0);
  801993:	84 db                	test   %bl,%bl
  801995:	ba 00 00 00 00       	mov    $0x0,%edx
  80199a:	0f 44 c2             	cmove  %edx,%eax
  80199d:	eb 41                	jmp    8019e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80199f:	83 ec 08             	sub    $0x8,%esp
  8019a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019a5:	50                   	push   %eax
  8019a6:	ff 36                	pushl  (%esi)
  8019a8:	e8 66 ff ff ff       	call   801913 <dev_lookup>
  8019ad:	89 c3                	mov    %eax,%ebx
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	78 1a                	js     8019d0 <fd_close+0x6a>
		if (dev->dev_close)
  8019b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8019bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	74 0b                	je     8019d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8019c5:	83 ec 0c             	sub    $0xc,%esp
  8019c8:	56                   	push   %esi
  8019c9:	ff d0                	call   *%eax
  8019cb:	89 c3                	mov    %eax,%ebx
  8019cd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8019d0:	83 ec 08             	sub    $0x8,%esp
  8019d3:	56                   	push   %esi
  8019d4:	6a 00                	push   $0x0
  8019d6:	e8 b7 f8 ff ff       	call   801292 <sys_page_unmap>
	return r;
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	89 d8                	mov    %ebx,%eax
}
  8019e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e3:	5b                   	pop    %ebx
  8019e4:	5e                   	pop    %esi
  8019e5:	5d                   	pop    %ebp
  8019e6:	c3                   	ret    

008019e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f0:	50                   	push   %eax
  8019f1:	ff 75 08             	pushl  0x8(%ebp)
  8019f4:	e8 c4 fe ff ff       	call   8018bd <fd_lookup>
  8019f9:	83 c4 08             	add    $0x8,%esp
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 10                	js     801a10 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	6a 01                	push   $0x1
  801a05:	ff 75 f4             	pushl  -0xc(%ebp)
  801a08:	e8 59 ff ff ff       	call   801966 <fd_close>
  801a0d:	83 c4 10             	add    $0x10,%esp
}
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <close_all>:

void
close_all(void)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	53                   	push   %ebx
  801a16:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801a19:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	53                   	push   %ebx
  801a22:	e8 c0 ff ff ff       	call   8019e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a27:	83 c3 01             	add    $0x1,%ebx
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	83 fb 20             	cmp    $0x20,%ebx
  801a30:	75 ec                	jne    801a1e <close_all+0xc>
		close(i);
}
  801a32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	57                   	push   %edi
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
  801a3d:	83 ec 2c             	sub    $0x2c,%esp
  801a40:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a43:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a46:	50                   	push   %eax
  801a47:	ff 75 08             	pushl  0x8(%ebp)
  801a4a:	e8 6e fe ff ff       	call   8018bd <fd_lookup>
  801a4f:	83 c4 08             	add    $0x8,%esp
  801a52:	85 c0                	test   %eax,%eax
  801a54:	0f 88 c1 00 00 00    	js     801b1b <dup+0xe4>
		return r;
	close(newfdnum);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	56                   	push   %esi
  801a5e:	e8 84 ff ff ff       	call   8019e7 <close>

	newfd = INDEX2FD(newfdnum);
  801a63:	89 f3                	mov    %esi,%ebx
  801a65:	c1 e3 0c             	shl    $0xc,%ebx
  801a68:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801a6e:	83 c4 04             	add    $0x4,%esp
  801a71:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a74:	e8 de fd ff ff       	call   801857 <fd2data>
  801a79:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801a7b:	89 1c 24             	mov    %ebx,(%esp)
  801a7e:	e8 d4 fd ff ff       	call   801857 <fd2data>
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801a89:	89 f8                	mov    %edi,%eax
  801a8b:	c1 e8 16             	shr    $0x16,%eax
  801a8e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a95:	a8 01                	test   $0x1,%al
  801a97:	74 37                	je     801ad0 <dup+0x99>
  801a99:	89 f8                	mov    %edi,%eax
  801a9b:	c1 e8 0c             	shr    $0xc,%eax
  801a9e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801aa5:	f6 c2 01             	test   $0x1,%dl
  801aa8:	74 26                	je     801ad0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801aaa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	25 07 0e 00 00       	and    $0xe07,%eax
  801ab9:	50                   	push   %eax
  801aba:	ff 75 d4             	pushl  -0x2c(%ebp)
  801abd:	6a 00                	push   $0x0
  801abf:	57                   	push   %edi
  801ac0:	6a 00                	push   $0x0
  801ac2:	e8 89 f7 ff ff       	call   801250 <sys_page_map>
  801ac7:	89 c7                	mov    %eax,%edi
  801ac9:	83 c4 20             	add    $0x20,%esp
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 2e                	js     801afe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ad0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ad3:	89 d0                	mov    %edx,%eax
  801ad5:	c1 e8 0c             	shr    $0xc,%eax
  801ad8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	25 07 0e 00 00       	and    $0xe07,%eax
  801ae7:	50                   	push   %eax
  801ae8:	53                   	push   %ebx
  801ae9:	6a 00                	push   $0x0
  801aeb:	52                   	push   %edx
  801aec:	6a 00                	push   $0x0
  801aee:	e8 5d f7 ff ff       	call   801250 <sys_page_map>
  801af3:	89 c7                	mov    %eax,%edi
  801af5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801af8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801afa:	85 ff                	test   %edi,%edi
  801afc:	79 1d                	jns    801b1b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	53                   	push   %ebx
  801b02:	6a 00                	push   $0x0
  801b04:	e8 89 f7 ff ff       	call   801292 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b09:	83 c4 08             	add    $0x8,%esp
  801b0c:	ff 75 d4             	pushl  -0x2c(%ebp)
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 7c f7 ff ff       	call   801292 <sys_page_unmap>
	return r;
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	89 f8                	mov    %edi,%eax
}
  801b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1e:	5b                   	pop    %ebx
  801b1f:	5e                   	pop    %esi
  801b20:	5f                   	pop    %edi
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	53                   	push   %ebx
  801b27:	83 ec 14             	sub    $0x14,%esp
  801b2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b30:	50                   	push   %eax
  801b31:	53                   	push   %ebx
  801b32:	e8 86 fd ff ff       	call   8018bd <fd_lookup>
  801b37:	83 c4 08             	add    $0x8,%esp
  801b3a:	89 c2                	mov    %eax,%edx
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 6d                	js     801bad <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b40:	83 ec 08             	sub    $0x8,%esp
  801b43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b46:	50                   	push   %eax
  801b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4a:	ff 30                	pushl  (%eax)
  801b4c:	e8 c2 fd ff ff       	call   801913 <dev_lookup>
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	85 c0                	test   %eax,%eax
  801b56:	78 4c                	js     801ba4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801b58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b5b:	8b 42 08             	mov    0x8(%edx),%eax
  801b5e:	83 e0 03             	and    $0x3,%eax
  801b61:	83 f8 01             	cmp    $0x1,%eax
  801b64:	75 21                	jne    801b87 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801b66:	a1 20 50 80 00       	mov    0x805020,%eax
  801b6b:	8b 40 48             	mov    0x48(%eax),%eax
  801b6e:	83 ec 04             	sub    $0x4,%esp
  801b71:	53                   	push   %ebx
  801b72:	50                   	push   %eax
  801b73:	68 e4 32 80 00       	push   $0x8032e4
  801b78:	e8 e8 ec ff ff       	call   800865 <cprintf>
		return -E_INVAL;
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801b85:	eb 26                	jmp    801bad <read+0x8a>
	}
	if (!dev->dev_read)
  801b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8a:	8b 40 08             	mov    0x8(%eax),%eax
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	74 17                	je     801ba8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801b91:	83 ec 04             	sub    $0x4,%esp
  801b94:	ff 75 10             	pushl  0x10(%ebp)
  801b97:	ff 75 0c             	pushl  0xc(%ebp)
  801b9a:	52                   	push   %edx
  801b9b:	ff d0                	call   *%eax
  801b9d:	89 c2                	mov    %eax,%edx
  801b9f:	83 c4 10             	add    $0x10,%esp
  801ba2:	eb 09                	jmp    801bad <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ba4:	89 c2                	mov    %eax,%edx
  801ba6:	eb 05                	jmp    801bad <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801ba8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801bad:	89 d0                	mov    %edx,%eax
  801baf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	57                   	push   %edi
  801bb8:	56                   	push   %esi
  801bb9:	53                   	push   %ebx
  801bba:	83 ec 0c             	sub    $0xc,%esp
  801bbd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bc0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bc8:	eb 21                	jmp    801beb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801bca:	83 ec 04             	sub    $0x4,%esp
  801bcd:	89 f0                	mov    %esi,%eax
  801bcf:	29 d8                	sub    %ebx,%eax
  801bd1:	50                   	push   %eax
  801bd2:	89 d8                	mov    %ebx,%eax
  801bd4:	03 45 0c             	add    0xc(%ebp),%eax
  801bd7:	50                   	push   %eax
  801bd8:	57                   	push   %edi
  801bd9:	e8 45 ff ff ff       	call   801b23 <read>
		if (m < 0)
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	85 c0                	test   %eax,%eax
  801be3:	78 10                	js     801bf5 <readn+0x41>
			return m;
		if (m == 0)
  801be5:	85 c0                	test   %eax,%eax
  801be7:	74 0a                	je     801bf3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801be9:	01 c3                	add    %eax,%ebx
  801beb:	39 f3                	cmp    %esi,%ebx
  801bed:	72 db                	jb     801bca <readn+0x16>
  801bef:	89 d8                	mov    %ebx,%eax
  801bf1:	eb 02                	jmp    801bf5 <readn+0x41>
  801bf3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf8:	5b                   	pop    %ebx
  801bf9:	5e                   	pop    %esi
  801bfa:	5f                   	pop    %edi
  801bfb:	5d                   	pop    %ebp
  801bfc:	c3                   	ret    

00801bfd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	53                   	push   %ebx
  801c01:	83 ec 14             	sub    $0x14,%esp
  801c04:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c07:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c0a:	50                   	push   %eax
  801c0b:	53                   	push   %ebx
  801c0c:	e8 ac fc ff ff       	call   8018bd <fd_lookup>
  801c11:	83 c4 08             	add    $0x8,%esp
  801c14:	89 c2                	mov    %eax,%edx
  801c16:	85 c0                	test   %eax,%eax
  801c18:	78 68                	js     801c82 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c1a:	83 ec 08             	sub    $0x8,%esp
  801c1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c20:	50                   	push   %eax
  801c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c24:	ff 30                	pushl  (%eax)
  801c26:	e8 e8 fc ff ff       	call   801913 <dev_lookup>
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 47                	js     801c79 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c35:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c39:	75 21                	jne    801c5c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801c3b:	a1 20 50 80 00       	mov    0x805020,%eax
  801c40:	8b 40 48             	mov    0x48(%eax),%eax
  801c43:	83 ec 04             	sub    $0x4,%esp
  801c46:	53                   	push   %ebx
  801c47:	50                   	push   %eax
  801c48:	68 00 33 80 00       	push   $0x803300
  801c4d:	e8 13 ec ff ff       	call   800865 <cprintf>
		return -E_INVAL;
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801c5a:	eb 26                	jmp    801c82 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801c5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c5f:	8b 52 0c             	mov    0xc(%edx),%edx
  801c62:	85 d2                	test   %edx,%edx
  801c64:	74 17                	je     801c7d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801c66:	83 ec 04             	sub    $0x4,%esp
  801c69:	ff 75 10             	pushl  0x10(%ebp)
  801c6c:	ff 75 0c             	pushl  0xc(%ebp)
  801c6f:	50                   	push   %eax
  801c70:	ff d2                	call   *%edx
  801c72:	89 c2                	mov    %eax,%edx
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	eb 09                	jmp    801c82 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c79:	89 c2                	mov    %eax,%edx
  801c7b:	eb 05                	jmp    801c82 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801c7d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801c82:	89 d0                	mov    %edx,%eax
  801c84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <seek>:

int
seek(int fdnum, off_t offset)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c92:	50                   	push   %eax
  801c93:	ff 75 08             	pushl  0x8(%ebp)
  801c96:	e8 22 fc ff ff       	call   8018bd <fd_lookup>
  801c9b:	83 c4 08             	add    $0x8,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	78 0e                	js     801cb0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801ca2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ca5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ca8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801cab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	53                   	push   %ebx
  801cb6:	83 ec 14             	sub    $0x14,%esp
  801cb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cbc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cbf:	50                   	push   %eax
  801cc0:	53                   	push   %ebx
  801cc1:	e8 f7 fb ff ff       	call   8018bd <fd_lookup>
  801cc6:	83 c4 08             	add    $0x8,%esp
  801cc9:	89 c2                	mov    %eax,%edx
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	78 65                	js     801d34 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ccf:	83 ec 08             	sub    $0x8,%esp
  801cd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd5:	50                   	push   %eax
  801cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd9:	ff 30                	pushl  (%eax)
  801cdb:	e8 33 fc ff ff       	call   801913 <dev_lookup>
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 44                	js     801d2b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ce7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801cee:	75 21                	jne    801d11 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801cf0:	a1 20 50 80 00       	mov    0x805020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801cf5:	8b 40 48             	mov    0x48(%eax),%eax
  801cf8:	83 ec 04             	sub    $0x4,%esp
  801cfb:	53                   	push   %ebx
  801cfc:	50                   	push   %eax
  801cfd:	68 c0 32 80 00       	push   $0x8032c0
  801d02:	e8 5e eb ff ff       	call   800865 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801d0f:	eb 23                	jmp    801d34 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801d11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d14:	8b 52 18             	mov    0x18(%edx),%edx
  801d17:	85 d2                	test   %edx,%edx
  801d19:	74 14                	je     801d2f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801d1b:	83 ec 08             	sub    $0x8,%esp
  801d1e:	ff 75 0c             	pushl  0xc(%ebp)
  801d21:	50                   	push   %eax
  801d22:	ff d2                	call   *%edx
  801d24:	89 c2                	mov    %eax,%edx
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	eb 09                	jmp    801d34 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d2b:	89 c2                	mov    %eax,%edx
  801d2d:	eb 05                	jmp    801d34 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801d2f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801d34:	89 d0                	mov    %edx,%eax
  801d36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d39:	c9                   	leave  
  801d3a:	c3                   	ret    

00801d3b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	53                   	push   %ebx
  801d3f:	83 ec 14             	sub    $0x14,%esp
  801d42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d48:	50                   	push   %eax
  801d49:	ff 75 08             	pushl  0x8(%ebp)
  801d4c:	e8 6c fb ff ff       	call   8018bd <fd_lookup>
  801d51:	83 c4 08             	add    $0x8,%esp
  801d54:	89 c2                	mov    %eax,%edx
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 58                	js     801db2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d5a:	83 ec 08             	sub    $0x8,%esp
  801d5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d60:	50                   	push   %eax
  801d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d64:	ff 30                	pushl  (%eax)
  801d66:	e8 a8 fb ff ff       	call   801913 <dev_lookup>
  801d6b:	83 c4 10             	add    $0x10,%esp
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	78 37                	js     801da9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d75:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801d79:	74 32                	je     801dad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801d7b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801d7e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801d85:	00 00 00 
	stat->st_isdir = 0;
  801d88:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d8f:	00 00 00 
	stat->st_dev = dev;
  801d92:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d98:	83 ec 08             	sub    $0x8,%esp
  801d9b:	53                   	push   %ebx
  801d9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9f:	ff 50 14             	call   *0x14(%eax)
  801da2:	89 c2                	mov    %eax,%edx
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	eb 09                	jmp    801db2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801da9:	89 c2                	mov    %eax,%edx
  801dab:	eb 05                	jmp    801db2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801dad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801db2:	89 d0                	mov    %edx,%eax
  801db4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	56                   	push   %esi
  801dbd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801dbe:	83 ec 08             	sub    $0x8,%esp
  801dc1:	6a 00                	push   $0x0
  801dc3:	ff 75 08             	pushl  0x8(%ebp)
  801dc6:	e8 ef 01 00 00       	call   801fba <open>
  801dcb:	89 c3                	mov    %eax,%ebx
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	78 1b                	js     801def <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801dd4:	83 ec 08             	sub    $0x8,%esp
  801dd7:	ff 75 0c             	pushl  0xc(%ebp)
  801dda:	50                   	push   %eax
  801ddb:	e8 5b ff ff ff       	call   801d3b <fstat>
  801de0:	89 c6                	mov    %eax,%esi
	close(fd);
  801de2:	89 1c 24             	mov    %ebx,(%esp)
  801de5:	e8 fd fb ff ff       	call   8019e7 <close>
	return r;
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	89 f0                	mov    %esi,%eax
}
  801def:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df2:	5b                   	pop    %ebx
  801df3:	5e                   	pop    %esi
  801df4:	5d                   	pop    %ebp
  801df5:	c3                   	ret    

00801df6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	56                   	push   %esi
  801dfa:	53                   	push   %ebx
  801dfb:	89 c6                	mov    %eax,%esi
  801dfd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801dff:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  801e06:	75 12                	jne    801e1a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801e08:	83 ec 0c             	sub    $0xc,%esp
  801e0b:	6a 01                	push   $0x1
  801e0d:	e8 fc f9 ff ff       	call   80180e <ipc_find_env>
  801e12:	a3 18 50 80 00       	mov    %eax,0x805018
  801e17:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801e1a:	6a 07                	push   $0x7
  801e1c:	68 00 60 80 00       	push   $0x806000
  801e21:	56                   	push   %esi
  801e22:	ff 35 18 50 80 00    	pushl  0x805018
  801e28:	e8 92 f9 ff ff       	call   8017bf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801e2d:	83 c4 0c             	add    $0xc,%esp
  801e30:	6a 00                	push   $0x0
  801e32:	53                   	push   %ebx
  801e33:	6a 00                	push   $0x0
  801e35:	e8 0f f9 ff ff       	call   801749 <ipc_recv>
}
  801e3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3d:	5b                   	pop    %ebx
  801e3e:	5e                   	pop    %esi
  801e3f:	5d                   	pop    %ebp
  801e40:	c3                   	ret    

00801e41 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801e47:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e4d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801e52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e55:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801e5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801e5f:	b8 02 00 00 00       	mov    $0x2,%eax
  801e64:	e8 8d ff ff ff       	call   801df6 <fsipc>
}
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e71:	8b 45 08             	mov    0x8(%ebp),%eax
  801e74:	8b 40 0c             	mov    0xc(%eax),%eax
  801e77:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801e7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e81:	b8 06 00 00 00       	mov    $0x6,%eax
  801e86:	e8 6b ff ff ff       	call   801df6 <fsipc>
}
  801e8b:	c9                   	leave  
  801e8c:	c3                   	ret    

00801e8d <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	53                   	push   %ebx
  801e91:	83 ec 04             	sub    $0x4,%esp
  801e94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e97:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e9d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ea2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea7:	b8 05 00 00 00       	mov    $0x5,%eax
  801eac:	e8 45 ff ff ff       	call   801df6 <fsipc>
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 2c                	js     801ee1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801eb5:	83 ec 08             	sub    $0x8,%esp
  801eb8:	68 00 60 80 00       	push   $0x806000
  801ebd:	53                   	push   %ebx
  801ebe:	e8 47 ef ff ff       	call   800e0a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ec3:	a1 80 60 80 00       	mov    0x806080,%eax
  801ec8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ece:	a1 84 60 80 00       	mov    0x806084,%eax
  801ed3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ed9:	83 c4 10             	add    $0x10,%esp
  801edc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee4:	c9                   	leave  
  801ee5:	c3                   	ret    

00801ee6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	53                   	push   %ebx
  801eea:	83 ec 08             	sub    $0x8,%esp
  801eed:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ef0:	8b 55 08             	mov    0x8(%ebp),%edx
  801ef3:	8b 52 0c             	mov    0xc(%edx),%edx
  801ef6:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801efc:	a3 04 60 80 00       	mov    %eax,0x806004
  801f01:	3d 08 60 80 00       	cmp    $0x806008,%eax
  801f06:	bb 08 60 80 00       	mov    $0x806008,%ebx
  801f0b:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801f0e:	53                   	push   %ebx
  801f0f:	ff 75 0c             	pushl  0xc(%ebp)
  801f12:	68 08 60 80 00       	push   $0x806008
  801f17:	e8 80 f0 ff ff       	call   800f9c <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801f1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801f21:	b8 04 00 00 00       	mov    $0x4,%eax
  801f26:	e8 cb fe ff ff       	call   801df6 <fsipc>
  801f2b:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801f33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	56                   	push   %esi
  801f3c:	53                   	push   %ebx
  801f3d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801f40:	8b 45 08             	mov    0x8(%ebp),%eax
  801f43:	8b 40 0c             	mov    0xc(%eax),%eax
  801f46:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801f4b:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801f51:	ba 00 00 00 00       	mov    $0x0,%edx
  801f56:	b8 03 00 00 00       	mov    $0x3,%eax
  801f5b:	e8 96 fe ff ff       	call   801df6 <fsipc>
  801f60:	89 c3                	mov    %eax,%ebx
  801f62:	85 c0                	test   %eax,%eax
  801f64:	78 4b                	js     801fb1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801f66:	39 c6                	cmp    %eax,%esi
  801f68:	73 16                	jae    801f80 <devfile_read+0x48>
  801f6a:	68 34 33 80 00       	push   $0x803334
  801f6f:	68 3b 33 80 00       	push   $0x80333b
  801f74:	6a 7c                	push   $0x7c
  801f76:	68 50 33 80 00       	push   $0x803350
  801f7b:	e8 0c e8 ff ff       	call   80078c <_panic>
	assert(r <= PGSIZE);
  801f80:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f85:	7e 16                	jle    801f9d <devfile_read+0x65>
  801f87:	68 5b 33 80 00       	push   $0x80335b
  801f8c:	68 3b 33 80 00       	push   $0x80333b
  801f91:	6a 7d                	push   $0x7d
  801f93:	68 50 33 80 00       	push   $0x803350
  801f98:	e8 ef e7 ff ff       	call   80078c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801f9d:	83 ec 04             	sub    $0x4,%esp
  801fa0:	50                   	push   %eax
  801fa1:	68 00 60 80 00       	push   $0x806000
  801fa6:	ff 75 0c             	pushl  0xc(%ebp)
  801fa9:	e8 ee ef ff ff       	call   800f9c <memmove>
	return r;
  801fae:	83 c4 10             	add    $0x10,%esp
}
  801fb1:	89 d8                	mov    %ebx,%eax
  801fb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb6:	5b                   	pop    %ebx
  801fb7:	5e                   	pop    %esi
  801fb8:	5d                   	pop    %ebp
  801fb9:	c3                   	ret    

00801fba <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	53                   	push   %ebx
  801fbe:	83 ec 20             	sub    $0x20,%esp
  801fc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801fc4:	53                   	push   %ebx
  801fc5:	e8 07 ee ff ff       	call   800dd1 <strlen>
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801fd2:	7f 67                	jg     80203b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801fd4:	83 ec 0c             	sub    $0xc,%esp
  801fd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fda:	50                   	push   %eax
  801fdb:	e8 8e f8 ff ff       	call   80186e <fd_alloc>
  801fe0:	83 c4 10             	add    $0x10,%esp
		return r;
  801fe3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	78 57                	js     802040 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801fe9:	83 ec 08             	sub    $0x8,%esp
  801fec:	53                   	push   %ebx
  801fed:	68 00 60 80 00       	push   $0x806000
  801ff2:	e8 13 ee ff ff       	call   800e0a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ffa:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801fff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802002:	b8 01 00 00 00       	mov    $0x1,%eax
  802007:	e8 ea fd ff ff       	call   801df6 <fsipc>
  80200c:	89 c3                	mov    %eax,%ebx
  80200e:	83 c4 10             	add    $0x10,%esp
  802011:	85 c0                	test   %eax,%eax
  802013:	79 14                	jns    802029 <open+0x6f>
		fd_close(fd, 0);
  802015:	83 ec 08             	sub    $0x8,%esp
  802018:	6a 00                	push   $0x0
  80201a:	ff 75 f4             	pushl  -0xc(%ebp)
  80201d:	e8 44 f9 ff ff       	call   801966 <fd_close>
		return r;
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	89 da                	mov    %ebx,%edx
  802027:	eb 17                	jmp    802040 <open+0x86>
	}

	return fd2num(fd);
  802029:	83 ec 0c             	sub    $0xc,%esp
  80202c:	ff 75 f4             	pushl  -0xc(%ebp)
  80202f:	e8 13 f8 ff ff       	call   801847 <fd2num>
  802034:	89 c2                	mov    %eax,%edx
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	eb 05                	jmp    802040 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80203b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802040:	89 d0                	mov    %edx,%eax
  802042:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80204d:	ba 00 00 00 00       	mov    $0x0,%edx
  802052:	b8 08 00 00 00       	mov    $0x8,%eax
  802057:	e8 9a fd ff ff       	call   801df6 <fsipc>
}
  80205c:	c9                   	leave  
  80205d:	c3                   	ret    

0080205e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	56                   	push   %esi
  802062:	53                   	push   %ebx
  802063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802066:	83 ec 0c             	sub    $0xc,%esp
  802069:	ff 75 08             	pushl  0x8(%ebp)
  80206c:	e8 e6 f7 ff ff       	call   801857 <fd2data>
  802071:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802073:	83 c4 08             	add    $0x8,%esp
  802076:	68 67 33 80 00       	push   $0x803367
  80207b:	53                   	push   %ebx
  80207c:	e8 89 ed ff ff       	call   800e0a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802081:	8b 46 04             	mov    0x4(%esi),%eax
  802084:	2b 06                	sub    (%esi),%eax
  802086:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80208c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802093:	00 00 00 
	stat->st_dev = &devpipe;
  802096:	c7 83 88 00 00 00 20 	movl   $0x804020,0x88(%ebx)
  80209d:	40 80 00 
	return 0;
}
  8020a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a8:	5b                   	pop    %ebx
  8020a9:	5e                   	pop    %esi
  8020aa:	5d                   	pop    %ebp
  8020ab:	c3                   	ret    

008020ac <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	53                   	push   %ebx
  8020b0:	83 ec 0c             	sub    $0xc,%esp
  8020b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020b6:	53                   	push   %ebx
  8020b7:	6a 00                	push   $0x0
  8020b9:	e8 d4 f1 ff ff       	call   801292 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020be:	89 1c 24             	mov    %ebx,(%esp)
  8020c1:	e8 91 f7 ff ff       	call   801857 <fd2data>
  8020c6:	83 c4 08             	add    $0x8,%esp
  8020c9:	50                   	push   %eax
  8020ca:	6a 00                	push   $0x0
  8020cc:	e8 c1 f1 ff ff       	call   801292 <sys_page_unmap>
}
  8020d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020d4:	c9                   	leave  
  8020d5:	c3                   	ret    

008020d6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	57                   	push   %edi
  8020da:	56                   	push   %esi
  8020db:	53                   	push   %ebx
  8020dc:	83 ec 1c             	sub    $0x1c,%esp
  8020df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8020e2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020e4:	a1 20 50 80 00       	mov    0x805020,%eax
  8020e9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8020ec:	83 ec 0c             	sub    $0xc,%esp
  8020ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8020f2:	e8 43 09 00 00       	call   802a3a <pageref>
  8020f7:	89 c3                	mov    %eax,%ebx
  8020f9:	89 3c 24             	mov    %edi,(%esp)
  8020fc:	e8 39 09 00 00       	call   802a3a <pageref>
  802101:	83 c4 10             	add    $0x10,%esp
  802104:	39 c3                	cmp    %eax,%ebx
  802106:	0f 94 c1             	sete   %cl
  802109:	0f b6 c9             	movzbl %cl,%ecx
  80210c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80210f:	8b 15 20 50 80 00    	mov    0x805020,%edx
  802115:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802118:	39 ce                	cmp    %ecx,%esi
  80211a:	74 1b                	je     802137 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80211c:	39 c3                	cmp    %eax,%ebx
  80211e:	75 c4                	jne    8020e4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802120:	8b 42 58             	mov    0x58(%edx),%eax
  802123:	ff 75 e4             	pushl  -0x1c(%ebp)
  802126:	50                   	push   %eax
  802127:	56                   	push   %esi
  802128:	68 6e 33 80 00       	push   $0x80336e
  80212d:	e8 33 e7 ff ff       	call   800865 <cprintf>
  802132:	83 c4 10             	add    $0x10,%esp
  802135:	eb ad                	jmp    8020e4 <_pipeisclosed+0xe>
	}
}
  802137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80213a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    

00802142 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	57                   	push   %edi
  802146:	56                   	push   %esi
  802147:	53                   	push   %ebx
  802148:	83 ec 28             	sub    $0x28,%esp
  80214b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80214e:	56                   	push   %esi
  80214f:	e8 03 f7 ff ff       	call   801857 <fd2data>
  802154:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802156:	83 c4 10             	add    $0x10,%esp
  802159:	bf 00 00 00 00       	mov    $0x0,%edi
  80215e:	eb 4b                	jmp    8021ab <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802160:	89 da                	mov    %ebx,%edx
  802162:	89 f0                	mov    %esi,%eax
  802164:	e8 6d ff ff ff       	call   8020d6 <_pipeisclosed>
  802169:	85 c0                	test   %eax,%eax
  80216b:	75 48                	jne    8021b5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80216d:	e8 7c f0 ff ff       	call   8011ee <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802172:	8b 43 04             	mov    0x4(%ebx),%eax
  802175:	8b 0b                	mov    (%ebx),%ecx
  802177:	8d 51 20             	lea    0x20(%ecx),%edx
  80217a:	39 d0                	cmp    %edx,%eax
  80217c:	73 e2                	jae    802160 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80217e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802181:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802185:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802188:	89 c2                	mov    %eax,%edx
  80218a:	c1 fa 1f             	sar    $0x1f,%edx
  80218d:	89 d1                	mov    %edx,%ecx
  80218f:	c1 e9 1b             	shr    $0x1b,%ecx
  802192:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802195:	83 e2 1f             	and    $0x1f,%edx
  802198:	29 ca                	sub    %ecx,%edx
  80219a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80219e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021a2:	83 c0 01             	add    $0x1,%eax
  8021a5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021a8:	83 c7 01             	add    $0x1,%edi
  8021ab:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021ae:	75 c2                	jne    802172 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8021b3:	eb 05                	jmp    8021ba <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021b5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    

008021c2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	57                   	push   %edi
  8021c6:	56                   	push   %esi
  8021c7:	53                   	push   %ebx
  8021c8:	83 ec 18             	sub    $0x18,%esp
  8021cb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021ce:	57                   	push   %edi
  8021cf:	e8 83 f6 ff ff       	call   801857 <fd2data>
  8021d4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021d6:	83 c4 10             	add    $0x10,%esp
  8021d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021de:	eb 3d                	jmp    80221d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021e0:	85 db                	test   %ebx,%ebx
  8021e2:	74 04                	je     8021e8 <devpipe_read+0x26>
				return i;
  8021e4:	89 d8                	mov    %ebx,%eax
  8021e6:	eb 44                	jmp    80222c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021e8:	89 f2                	mov    %esi,%edx
  8021ea:	89 f8                	mov    %edi,%eax
  8021ec:	e8 e5 fe ff ff       	call   8020d6 <_pipeisclosed>
  8021f1:	85 c0                	test   %eax,%eax
  8021f3:	75 32                	jne    802227 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021f5:	e8 f4 ef ff ff       	call   8011ee <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021fa:	8b 06                	mov    (%esi),%eax
  8021fc:	3b 46 04             	cmp    0x4(%esi),%eax
  8021ff:	74 df                	je     8021e0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802201:	99                   	cltd   
  802202:	c1 ea 1b             	shr    $0x1b,%edx
  802205:	01 d0                	add    %edx,%eax
  802207:	83 e0 1f             	and    $0x1f,%eax
  80220a:	29 d0                	sub    %edx,%eax
  80220c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802214:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802217:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80221a:	83 c3 01             	add    $0x1,%ebx
  80221d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802220:	75 d8                	jne    8021fa <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802222:	8b 45 10             	mov    0x10(%ebp),%eax
  802225:	eb 05                	jmp    80222c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802227:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80222c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80222f:	5b                   	pop    %ebx
  802230:	5e                   	pop    %esi
  802231:	5f                   	pop    %edi
  802232:	5d                   	pop    %ebp
  802233:	c3                   	ret    

00802234 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802234:	55                   	push   %ebp
  802235:	89 e5                	mov    %esp,%ebp
  802237:	56                   	push   %esi
  802238:	53                   	push   %ebx
  802239:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80223c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80223f:	50                   	push   %eax
  802240:	e8 29 f6 ff ff       	call   80186e <fd_alloc>
  802245:	83 c4 10             	add    $0x10,%esp
  802248:	89 c2                	mov    %eax,%edx
  80224a:	85 c0                	test   %eax,%eax
  80224c:	0f 88 2c 01 00 00    	js     80237e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802252:	83 ec 04             	sub    $0x4,%esp
  802255:	68 07 04 00 00       	push   $0x407
  80225a:	ff 75 f4             	pushl  -0xc(%ebp)
  80225d:	6a 00                	push   $0x0
  80225f:	e8 a9 ef ff ff       	call   80120d <sys_page_alloc>
  802264:	83 c4 10             	add    $0x10,%esp
  802267:	89 c2                	mov    %eax,%edx
  802269:	85 c0                	test   %eax,%eax
  80226b:	0f 88 0d 01 00 00    	js     80237e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802271:	83 ec 0c             	sub    $0xc,%esp
  802274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802277:	50                   	push   %eax
  802278:	e8 f1 f5 ff ff       	call   80186e <fd_alloc>
  80227d:	89 c3                	mov    %eax,%ebx
  80227f:	83 c4 10             	add    $0x10,%esp
  802282:	85 c0                	test   %eax,%eax
  802284:	0f 88 e2 00 00 00    	js     80236c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80228a:	83 ec 04             	sub    $0x4,%esp
  80228d:	68 07 04 00 00       	push   $0x407
  802292:	ff 75 f0             	pushl  -0x10(%ebp)
  802295:	6a 00                	push   $0x0
  802297:	e8 71 ef ff ff       	call   80120d <sys_page_alloc>
  80229c:	89 c3                	mov    %eax,%ebx
  80229e:	83 c4 10             	add    $0x10,%esp
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	0f 88 c3 00 00 00    	js     80236c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022a9:	83 ec 0c             	sub    $0xc,%esp
  8022ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8022af:	e8 a3 f5 ff ff       	call   801857 <fd2data>
  8022b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022b6:	83 c4 0c             	add    $0xc,%esp
  8022b9:	68 07 04 00 00       	push   $0x407
  8022be:	50                   	push   %eax
  8022bf:	6a 00                	push   $0x0
  8022c1:	e8 47 ef ff ff       	call   80120d <sys_page_alloc>
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	83 c4 10             	add    $0x10,%esp
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	0f 88 89 00 00 00    	js     80235c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022d3:	83 ec 0c             	sub    $0xc,%esp
  8022d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8022d9:	e8 79 f5 ff ff       	call   801857 <fd2data>
  8022de:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022e5:	50                   	push   %eax
  8022e6:	6a 00                	push   $0x0
  8022e8:	56                   	push   %esi
  8022e9:	6a 00                	push   $0x0
  8022eb:	e8 60 ef ff ff       	call   801250 <sys_page_map>
  8022f0:	89 c3                	mov    %eax,%ebx
  8022f2:	83 c4 20             	add    $0x20,%esp
  8022f5:	85 c0                	test   %eax,%eax
  8022f7:	78 55                	js     80234e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022f9:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8022ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802302:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802304:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802307:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80230e:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802314:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802317:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80231c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802323:	83 ec 0c             	sub    $0xc,%esp
  802326:	ff 75 f4             	pushl  -0xc(%ebp)
  802329:	e8 19 f5 ff ff       	call   801847 <fd2num>
  80232e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802331:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802333:	83 c4 04             	add    $0x4,%esp
  802336:	ff 75 f0             	pushl  -0x10(%ebp)
  802339:	e8 09 f5 ff ff       	call   801847 <fd2num>
  80233e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802341:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802344:	83 c4 10             	add    $0x10,%esp
  802347:	ba 00 00 00 00       	mov    $0x0,%edx
  80234c:	eb 30                	jmp    80237e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80234e:	83 ec 08             	sub    $0x8,%esp
  802351:	56                   	push   %esi
  802352:	6a 00                	push   $0x0
  802354:	e8 39 ef ff ff       	call   801292 <sys_page_unmap>
  802359:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80235c:	83 ec 08             	sub    $0x8,%esp
  80235f:	ff 75 f0             	pushl  -0x10(%ebp)
  802362:	6a 00                	push   $0x0
  802364:	e8 29 ef ff ff       	call   801292 <sys_page_unmap>
  802369:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80236c:	83 ec 08             	sub    $0x8,%esp
  80236f:	ff 75 f4             	pushl  -0xc(%ebp)
  802372:	6a 00                	push   $0x0
  802374:	e8 19 ef ff ff       	call   801292 <sys_page_unmap>
  802379:	83 c4 10             	add    $0x10,%esp
  80237c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80237e:	89 d0                	mov    %edx,%eax
  802380:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802383:	5b                   	pop    %ebx
  802384:	5e                   	pop    %esi
  802385:	5d                   	pop    %ebp
  802386:	c3                   	ret    

00802387 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802387:	55                   	push   %ebp
  802388:	89 e5                	mov    %esp,%ebp
  80238a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80238d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802390:	50                   	push   %eax
  802391:	ff 75 08             	pushl  0x8(%ebp)
  802394:	e8 24 f5 ff ff       	call   8018bd <fd_lookup>
  802399:	83 c4 10             	add    $0x10,%esp
  80239c:	85 c0                	test   %eax,%eax
  80239e:	78 18                	js     8023b8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023a0:	83 ec 0c             	sub    $0xc,%esp
  8023a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a6:	e8 ac f4 ff ff       	call   801857 <fd2data>
	return _pipeisclosed(fd, p);
  8023ab:	89 c2                	mov    %eax,%edx
  8023ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b0:	e8 21 fd ff ff       	call   8020d6 <_pipeisclosed>
  8023b5:	83 c4 10             	add    $0x10,%esp
}
  8023b8:	c9                   	leave  
  8023b9:	c3                   	ret    

008023ba <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8023ba:	55                   	push   %ebp
  8023bb:	89 e5                	mov    %esp,%ebp
  8023bd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8023c0:	68 86 33 80 00       	push   $0x803386
  8023c5:	ff 75 0c             	pushl  0xc(%ebp)
  8023c8:	e8 3d ea ff ff       	call   800e0a <strcpy>
	return 0;
}
  8023cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8023d2:	c9                   	leave  
  8023d3:	c3                   	ret    

008023d4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	53                   	push   %ebx
  8023d8:	83 ec 10             	sub    $0x10,%esp
  8023db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8023de:	53                   	push   %ebx
  8023df:	e8 56 06 00 00       	call   802a3a <pageref>
  8023e4:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8023e7:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8023ec:	83 f8 01             	cmp    $0x1,%eax
  8023ef:	75 10                	jne    802401 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8023f1:	83 ec 0c             	sub    $0xc,%esp
  8023f4:	ff 73 0c             	pushl  0xc(%ebx)
  8023f7:	e8 c0 02 00 00       	call   8026bc <nsipc_close>
  8023fc:	89 c2                	mov    %eax,%edx
  8023fe:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802401:	89 d0                	mov    %edx,%eax
  802403:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802406:	c9                   	leave  
  802407:	c3                   	ret    

00802408 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802408:	55                   	push   %ebp
  802409:	89 e5                	mov    %esp,%ebp
  80240b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80240e:	6a 00                	push   $0x0
  802410:	ff 75 10             	pushl  0x10(%ebp)
  802413:	ff 75 0c             	pushl  0xc(%ebp)
  802416:	8b 45 08             	mov    0x8(%ebp),%eax
  802419:	ff 70 0c             	pushl  0xc(%eax)
  80241c:	e8 78 03 00 00       	call   802799 <nsipc_send>
}
  802421:	c9                   	leave  
  802422:	c3                   	ret    

00802423 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802423:	55                   	push   %ebp
  802424:	89 e5                	mov    %esp,%ebp
  802426:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802429:	6a 00                	push   $0x0
  80242b:	ff 75 10             	pushl  0x10(%ebp)
  80242e:	ff 75 0c             	pushl  0xc(%ebp)
  802431:	8b 45 08             	mov    0x8(%ebp),%eax
  802434:	ff 70 0c             	pushl  0xc(%eax)
  802437:	e8 f1 02 00 00       	call   80272d <nsipc_recv>
}
  80243c:	c9                   	leave  
  80243d:	c3                   	ret    

0080243e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80243e:	55                   	push   %ebp
  80243f:	89 e5                	mov    %esp,%ebp
  802441:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802444:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802447:	52                   	push   %edx
  802448:	50                   	push   %eax
  802449:	e8 6f f4 ff ff       	call   8018bd <fd_lookup>
  80244e:	83 c4 10             	add    $0x10,%esp
  802451:	85 c0                	test   %eax,%eax
  802453:	78 17                	js     80246c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802455:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802458:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  80245e:	39 08                	cmp    %ecx,(%eax)
  802460:	75 05                	jne    802467 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802462:	8b 40 0c             	mov    0xc(%eax),%eax
  802465:	eb 05                	jmp    80246c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802467:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80246c:	c9                   	leave  
  80246d:	c3                   	ret    

0080246e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80246e:	55                   	push   %ebp
  80246f:	89 e5                	mov    %esp,%ebp
  802471:	56                   	push   %esi
  802472:	53                   	push   %ebx
  802473:	83 ec 1c             	sub    $0x1c,%esp
  802476:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80247b:	50                   	push   %eax
  80247c:	e8 ed f3 ff ff       	call   80186e <fd_alloc>
  802481:	89 c3                	mov    %eax,%ebx
  802483:	83 c4 10             	add    $0x10,%esp
  802486:	85 c0                	test   %eax,%eax
  802488:	78 1b                	js     8024a5 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80248a:	83 ec 04             	sub    $0x4,%esp
  80248d:	68 07 04 00 00       	push   $0x407
  802492:	ff 75 f4             	pushl  -0xc(%ebp)
  802495:	6a 00                	push   $0x0
  802497:	e8 71 ed ff ff       	call   80120d <sys_page_alloc>
  80249c:	89 c3                	mov    %eax,%ebx
  80249e:	83 c4 10             	add    $0x10,%esp
  8024a1:	85 c0                	test   %eax,%eax
  8024a3:	79 10                	jns    8024b5 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8024a5:	83 ec 0c             	sub    $0xc,%esp
  8024a8:	56                   	push   %esi
  8024a9:	e8 0e 02 00 00       	call   8026bc <nsipc_close>
		return r;
  8024ae:	83 c4 10             	add    $0x10,%esp
  8024b1:	89 d8                	mov    %ebx,%eax
  8024b3:	eb 24                	jmp    8024d9 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8024b5:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024be:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8024c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8024ca:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8024cd:	83 ec 0c             	sub    $0xc,%esp
  8024d0:	50                   	push   %eax
  8024d1:	e8 71 f3 ff ff       	call   801847 <fd2num>
  8024d6:	83 c4 10             	add    $0x10,%esp
}
  8024d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024dc:	5b                   	pop    %ebx
  8024dd:	5e                   	pop    %esi
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    

008024e0 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8024e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e9:	e8 50 ff ff ff       	call   80243e <fd2sockid>
		return r;
  8024ee:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8024f0:	85 c0                	test   %eax,%eax
  8024f2:	78 1f                	js     802513 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8024f4:	83 ec 04             	sub    $0x4,%esp
  8024f7:	ff 75 10             	pushl  0x10(%ebp)
  8024fa:	ff 75 0c             	pushl  0xc(%ebp)
  8024fd:	50                   	push   %eax
  8024fe:	e8 12 01 00 00       	call   802615 <nsipc_accept>
  802503:	83 c4 10             	add    $0x10,%esp
		return r;
  802506:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802508:	85 c0                	test   %eax,%eax
  80250a:	78 07                	js     802513 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80250c:	e8 5d ff ff ff       	call   80246e <alloc_sockfd>
  802511:	89 c1                	mov    %eax,%ecx
}
  802513:	89 c8                	mov    %ecx,%eax
  802515:	c9                   	leave  
  802516:	c3                   	ret    

00802517 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802517:	55                   	push   %ebp
  802518:	89 e5                	mov    %esp,%ebp
  80251a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80251d:	8b 45 08             	mov    0x8(%ebp),%eax
  802520:	e8 19 ff ff ff       	call   80243e <fd2sockid>
  802525:	85 c0                	test   %eax,%eax
  802527:	78 12                	js     80253b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802529:	83 ec 04             	sub    $0x4,%esp
  80252c:	ff 75 10             	pushl  0x10(%ebp)
  80252f:	ff 75 0c             	pushl  0xc(%ebp)
  802532:	50                   	push   %eax
  802533:	e8 2d 01 00 00       	call   802665 <nsipc_bind>
  802538:	83 c4 10             	add    $0x10,%esp
}
  80253b:	c9                   	leave  
  80253c:	c3                   	ret    

0080253d <shutdown>:

int
shutdown(int s, int how)
{
  80253d:	55                   	push   %ebp
  80253e:	89 e5                	mov    %esp,%ebp
  802540:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802543:	8b 45 08             	mov    0x8(%ebp),%eax
  802546:	e8 f3 fe ff ff       	call   80243e <fd2sockid>
  80254b:	85 c0                	test   %eax,%eax
  80254d:	78 0f                	js     80255e <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80254f:	83 ec 08             	sub    $0x8,%esp
  802552:	ff 75 0c             	pushl  0xc(%ebp)
  802555:	50                   	push   %eax
  802556:	e8 3f 01 00 00       	call   80269a <nsipc_shutdown>
  80255b:	83 c4 10             	add    $0x10,%esp
}
  80255e:	c9                   	leave  
  80255f:	c3                   	ret    

00802560 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802560:	55                   	push   %ebp
  802561:	89 e5                	mov    %esp,%ebp
  802563:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802566:	8b 45 08             	mov    0x8(%ebp),%eax
  802569:	e8 d0 fe ff ff       	call   80243e <fd2sockid>
  80256e:	85 c0                	test   %eax,%eax
  802570:	78 12                	js     802584 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802572:	83 ec 04             	sub    $0x4,%esp
  802575:	ff 75 10             	pushl  0x10(%ebp)
  802578:	ff 75 0c             	pushl  0xc(%ebp)
  80257b:	50                   	push   %eax
  80257c:	e8 55 01 00 00       	call   8026d6 <nsipc_connect>
  802581:	83 c4 10             	add    $0x10,%esp
}
  802584:	c9                   	leave  
  802585:	c3                   	ret    

00802586 <listen>:

int
listen(int s, int backlog)
{
  802586:	55                   	push   %ebp
  802587:	89 e5                	mov    %esp,%ebp
  802589:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80258c:	8b 45 08             	mov    0x8(%ebp),%eax
  80258f:	e8 aa fe ff ff       	call   80243e <fd2sockid>
  802594:	85 c0                	test   %eax,%eax
  802596:	78 0f                	js     8025a7 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802598:	83 ec 08             	sub    $0x8,%esp
  80259b:	ff 75 0c             	pushl  0xc(%ebp)
  80259e:	50                   	push   %eax
  80259f:	e8 67 01 00 00       	call   80270b <nsipc_listen>
  8025a4:	83 c4 10             	add    $0x10,%esp
}
  8025a7:	c9                   	leave  
  8025a8:	c3                   	ret    

008025a9 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8025a9:	55                   	push   %ebp
  8025aa:	89 e5                	mov    %esp,%ebp
  8025ac:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8025af:	ff 75 10             	pushl  0x10(%ebp)
  8025b2:	ff 75 0c             	pushl  0xc(%ebp)
  8025b5:	ff 75 08             	pushl  0x8(%ebp)
  8025b8:	e8 3a 02 00 00       	call   8027f7 <nsipc_socket>
  8025bd:	83 c4 10             	add    $0x10,%esp
  8025c0:	85 c0                	test   %eax,%eax
  8025c2:	78 05                	js     8025c9 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8025c4:	e8 a5 fe ff ff       	call   80246e <alloc_sockfd>
}
  8025c9:	c9                   	leave  
  8025ca:	c3                   	ret    

008025cb <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8025cb:	55                   	push   %ebp
  8025cc:	89 e5                	mov    %esp,%ebp
  8025ce:	53                   	push   %ebx
  8025cf:	83 ec 04             	sub    $0x4,%esp
  8025d2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8025d4:	83 3d 1c 50 80 00 00 	cmpl   $0x0,0x80501c
  8025db:	75 12                	jne    8025ef <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8025dd:	83 ec 0c             	sub    $0xc,%esp
  8025e0:	6a 02                	push   $0x2
  8025e2:	e8 27 f2 ff ff       	call   80180e <ipc_find_env>
  8025e7:	a3 1c 50 80 00       	mov    %eax,0x80501c
  8025ec:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8025ef:	6a 07                	push   $0x7
  8025f1:	68 00 70 80 00       	push   $0x807000
  8025f6:	53                   	push   %ebx
  8025f7:	ff 35 1c 50 80 00    	pushl  0x80501c
  8025fd:	e8 bd f1 ff ff       	call   8017bf <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802602:	83 c4 0c             	add    $0xc,%esp
  802605:	6a 00                	push   $0x0
  802607:	6a 00                	push   $0x0
  802609:	6a 00                	push   $0x0
  80260b:	e8 39 f1 ff ff       	call   801749 <ipc_recv>
}
  802610:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802613:	c9                   	leave  
  802614:	c3                   	ret    

00802615 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802615:	55                   	push   %ebp
  802616:	89 e5                	mov    %esp,%ebp
  802618:	56                   	push   %esi
  802619:	53                   	push   %ebx
  80261a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80261d:	8b 45 08             	mov    0x8(%ebp),%eax
  802620:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802625:	8b 06                	mov    (%esi),%eax
  802627:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80262c:	b8 01 00 00 00       	mov    $0x1,%eax
  802631:	e8 95 ff ff ff       	call   8025cb <nsipc>
  802636:	89 c3                	mov    %eax,%ebx
  802638:	85 c0                	test   %eax,%eax
  80263a:	78 20                	js     80265c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80263c:	83 ec 04             	sub    $0x4,%esp
  80263f:	ff 35 10 70 80 00    	pushl  0x807010
  802645:	68 00 70 80 00       	push   $0x807000
  80264a:	ff 75 0c             	pushl  0xc(%ebp)
  80264d:	e8 4a e9 ff ff       	call   800f9c <memmove>
		*addrlen = ret->ret_addrlen;
  802652:	a1 10 70 80 00       	mov    0x807010,%eax
  802657:	89 06                	mov    %eax,(%esi)
  802659:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80265c:	89 d8                	mov    %ebx,%eax
  80265e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802661:	5b                   	pop    %ebx
  802662:	5e                   	pop    %esi
  802663:	5d                   	pop    %ebp
  802664:	c3                   	ret    

00802665 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802665:	55                   	push   %ebp
  802666:	89 e5                	mov    %esp,%ebp
  802668:	53                   	push   %ebx
  802669:	83 ec 08             	sub    $0x8,%esp
  80266c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80266f:	8b 45 08             	mov    0x8(%ebp),%eax
  802672:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802677:	53                   	push   %ebx
  802678:	ff 75 0c             	pushl  0xc(%ebp)
  80267b:	68 04 70 80 00       	push   $0x807004
  802680:	e8 17 e9 ff ff       	call   800f9c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802685:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80268b:	b8 02 00 00 00       	mov    $0x2,%eax
  802690:	e8 36 ff ff ff       	call   8025cb <nsipc>
}
  802695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802698:	c9                   	leave  
  802699:	c3                   	ret    

0080269a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80269a:	55                   	push   %ebp
  80269b:	89 e5                	mov    %esp,%ebp
  80269d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8026a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8026a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026ab:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8026b0:	b8 03 00 00 00       	mov    $0x3,%eax
  8026b5:	e8 11 ff ff ff       	call   8025cb <nsipc>
}
  8026ba:	c9                   	leave  
  8026bb:	c3                   	ret    

008026bc <nsipc_close>:

int
nsipc_close(int s)
{
  8026bc:	55                   	push   %ebp
  8026bd:	89 e5                	mov    %esp,%ebp
  8026bf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8026c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8026c5:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8026ca:	b8 04 00 00 00       	mov    $0x4,%eax
  8026cf:	e8 f7 fe ff ff       	call   8025cb <nsipc>
}
  8026d4:	c9                   	leave  
  8026d5:	c3                   	ret    

008026d6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8026d6:	55                   	push   %ebp
  8026d7:	89 e5                	mov    %esp,%ebp
  8026d9:	53                   	push   %ebx
  8026da:	83 ec 08             	sub    $0x8,%esp
  8026dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8026e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8026e3:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8026e8:	53                   	push   %ebx
  8026e9:	ff 75 0c             	pushl  0xc(%ebp)
  8026ec:	68 04 70 80 00       	push   $0x807004
  8026f1:	e8 a6 e8 ff ff       	call   800f9c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8026f6:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8026fc:	b8 05 00 00 00       	mov    $0x5,%eax
  802701:	e8 c5 fe ff ff       	call   8025cb <nsipc>
}
  802706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802709:	c9                   	leave  
  80270a:	c3                   	ret    

0080270b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80270b:	55                   	push   %ebp
  80270c:	89 e5                	mov    %esp,%ebp
  80270e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802711:	8b 45 08             	mov    0x8(%ebp),%eax
  802714:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802719:	8b 45 0c             	mov    0xc(%ebp),%eax
  80271c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802721:	b8 06 00 00 00       	mov    $0x6,%eax
  802726:	e8 a0 fe ff ff       	call   8025cb <nsipc>
}
  80272b:	c9                   	leave  
  80272c:	c3                   	ret    

0080272d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80272d:	55                   	push   %ebp
  80272e:	89 e5                	mov    %esp,%ebp
  802730:	56                   	push   %esi
  802731:	53                   	push   %ebx
  802732:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802735:	8b 45 08             	mov    0x8(%ebp),%eax
  802738:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80273d:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802743:	8b 45 14             	mov    0x14(%ebp),%eax
  802746:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80274b:	b8 07 00 00 00       	mov    $0x7,%eax
  802750:	e8 76 fe ff ff       	call   8025cb <nsipc>
  802755:	89 c3                	mov    %eax,%ebx
  802757:	85 c0                	test   %eax,%eax
  802759:	78 35                	js     802790 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80275b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802760:	7f 04                	jg     802766 <nsipc_recv+0x39>
  802762:	39 c6                	cmp    %eax,%esi
  802764:	7d 16                	jge    80277c <nsipc_recv+0x4f>
  802766:	68 92 33 80 00       	push   $0x803392
  80276b:	68 3b 33 80 00       	push   $0x80333b
  802770:	6a 62                	push   $0x62
  802772:	68 a7 33 80 00       	push   $0x8033a7
  802777:	e8 10 e0 ff ff       	call   80078c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80277c:	83 ec 04             	sub    $0x4,%esp
  80277f:	50                   	push   %eax
  802780:	68 00 70 80 00       	push   $0x807000
  802785:	ff 75 0c             	pushl  0xc(%ebp)
  802788:	e8 0f e8 ff ff       	call   800f9c <memmove>
  80278d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802790:	89 d8                	mov    %ebx,%eax
  802792:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802795:	5b                   	pop    %ebx
  802796:	5e                   	pop    %esi
  802797:	5d                   	pop    %ebp
  802798:	c3                   	ret    

00802799 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802799:	55                   	push   %ebp
  80279a:	89 e5                	mov    %esp,%ebp
  80279c:	53                   	push   %ebx
  80279d:	83 ec 04             	sub    $0x4,%esp
  8027a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8027a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8027a6:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8027ab:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8027b1:	7e 16                	jle    8027c9 <nsipc_send+0x30>
  8027b3:	68 b3 33 80 00       	push   $0x8033b3
  8027b8:	68 3b 33 80 00       	push   $0x80333b
  8027bd:	6a 6d                	push   $0x6d
  8027bf:	68 a7 33 80 00       	push   $0x8033a7
  8027c4:	e8 c3 df ff ff       	call   80078c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8027c9:	83 ec 04             	sub    $0x4,%esp
  8027cc:	53                   	push   %ebx
  8027cd:	ff 75 0c             	pushl  0xc(%ebp)
  8027d0:	68 0c 70 80 00       	push   $0x80700c
  8027d5:	e8 c2 e7 ff ff       	call   800f9c <memmove>
	nsipcbuf.send.req_size = size;
  8027da:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8027e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8027e3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8027e8:	b8 08 00 00 00       	mov    $0x8,%eax
  8027ed:	e8 d9 fd ff ff       	call   8025cb <nsipc>
}
  8027f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8027f5:	c9                   	leave  
  8027f6:	c3                   	ret    

008027f7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8027f7:	55                   	push   %ebp
  8027f8:	89 e5                	mov    %esp,%ebp
  8027fa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8027fd:	8b 45 08             	mov    0x8(%ebp),%eax
  802800:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802805:	8b 45 0c             	mov    0xc(%ebp),%eax
  802808:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80280d:	8b 45 10             	mov    0x10(%ebp),%eax
  802810:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802815:	b8 09 00 00 00       	mov    $0x9,%eax
  80281a:	e8 ac fd ff ff       	call   8025cb <nsipc>
}
  80281f:	c9                   	leave  
  802820:	c3                   	ret    

00802821 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802821:	55                   	push   %ebp
  802822:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802824:	b8 00 00 00 00       	mov    $0x0,%eax
  802829:	5d                   	pop    %ebp
  80282a:	c3                   	ret    

0080282b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80282b:	55                   	push   %ebp
  80282c:	89 e5                	mov    %esp,%ebp
  80282e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802831:	68 bf 33 80 00       	push   $0x8033bf
  802836:	ff 75 0c             	pushl  0xc(%ebp)
  802839:	e8 cc e5 ff ff       	call   800e0a <strcpy>
	return 0;
}
  80283e:	b8 00 00 00 00       	mov    $0x0,%eax
  802843:	c9                   	leave  
  802844:	c3                   	ret    

00802845 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802845:	55                   	push   %ebp
  802846:	89 e5                	mov    %esp,%ebp
  802848:	57                   	push   %edi
  802849:	56                   	push   %esi
  80284a:	53                   	push   %ebx
  80284b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802851:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802856:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80285c:	eb 2d                	jmp    80288b <devcons_write+0x46>
		m = n - tot;
  80285e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802861:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802863:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802866:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80286b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80286e:	83 ec 04             	sub    $0x4,%esp
  802871:	53                   	push   %ebx
  802872:	03 45 0c             	add    0xc(%ebp),%eax
  802875:	50                   	push   %eax
  802876:	57                   	push   %edi
  802877:	e8 20 e7 ff ff       	call   800f9c <memmove>
		sys_cputs(buf, m);
  80287c:	83 c4 08             	add    $0x8,%esp
  80287f:	53                   	push   %ebx
  802880:	57                   	push   %edi
  802881:	e8 cb e8 ff ff       	call   801151 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802886:	01 de                	add    %ebx,%esi
  802888:	83 c4 10             	add    $0x10,%esp
  80288b:	89 f0                	mov    %esi,%eax
  80288d:	3b 75 10             	cmp    0x10(%ebp),%esi
  802890:	72 cc                	jb     80285e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802892:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802895:	5b                   	pop    %ebx
  802896:	5e                   	pop    %esi
  802897:	5f                   	pop    %edi
  802898:	5d                   	pop    %ebp
  802899:	c3                   	ret    

0080289a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80289a:	55                   	push   %ebp
  80289b:	89 e5                	mov    %esp,%ebp
  80289d:	83 ec 08             	sub    $0x8,%esp
  8028a0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8028a5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8028a9:	74 2a                	je     8028d5 <devcons_read+0x3b>
  8028ab:	eb 05                	jmp    8028b2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8028ad:	e8 3c e9 ff ff       	call   8011ee <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8028b2:	e8 b8 e8 ff ff       	call   80116f <sys_cgetc>
  8028b7:	85 c0                	test   %eax,%eax
  8028b9:	74 f2                	je     8028ad <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8028bb:	85 c0                	test   %eax,%eax
  8028bd:	78 16                	js     8028d5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8028bf:	83 f8 04             	cmp    $0x4,%eax
  8028c2:	74 0c                	je     8028d0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8028c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028c7:	88 02                	mov    %al,(%edx)
	return 1;
  8028c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8028ce:	eb 05                	jmp    8028d5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8028d0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8028d5:	c9                   	leave  
  8028d6:	c3                   	ret    

008028d7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8028d7:	55                   	push   %ebp
  8028d8:	89 e5                	mov    %esp,%ebp
  8028da:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8028dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8028e0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8028e3:	6a 01                	push   $0x1
  8028e5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8028e8:	50                   	push   %eax
  8028e9:	e8 63 e8 ff ff       	call   801151 <sys_cputs>
}
  8028ee:	83 c4 10             	add    $0x10,%esp
  8028f1:	c9                   	leave  
  8028f2:	c3                   	ret    

008028f3 <getchar>:

int
getchar(void)
{
  8028f3:	55                   	push   %ebp
  8028f4:	89 e5                	mov    %esp,%ebp
  8028f6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8028f9:	6a 01                	push   $0x1
  8028fb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8028fe:	50                   	push   %eax
  8028ff:	6a 00                	push   $0x0
  802901:	e8 1d f2 ff ff       	call   801b23 <read>
	if (r < 0)
  802906:	83 c4 10             	add    $0x10,%esp
  802909:	85 c0                	test   %eax,%eax
  80290b:	78 0f                	js     80291c <getchar+0x29>
		return r;
	if (r < 1)
  80290d:	85 c0                	test   %eax,%eax
  80290f:	7e 06                	jle    802917 <getchar+0x24>
		return -E_EOF;
	return c;
  802911:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802915:	eb 05                	jmp    80291c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802917:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80291c:	c9                   	leave  
  80291d:	c3                   	ret    

0080291e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80291e:	55                   	push   %ebp
  80291f:	89 e5                	mov    %esp,%ebp
  802921:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802924:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802927:	50                   	push   %eax
  802928:	ff 75 08             	pushl  0x8(%ebp)
  80292b:	e8 8d ef ff ff       	call   8018bd <fd_lookup>
  802930:	83 c4 10             	add    $0x10,%esp
  802933:	85 c0                	test   %eax,%eax
  802935:	78 11                	js     802948 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802937:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80293a:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802940:	39 10                	cmp    %edx,(%eax)
  802942:	0f 94 c0             	sete   %al
  802945:	0f b6 c0             	movzbl %al,%eax
}
  802948:	c9                   	leave  
  802949:	c3                   	ret    

0080294a <opencons>:

int
opencons(void)
{
  80294a:	55                   	push   %ebp
  80294b:	89 e5                	mov    %esp,%ebp
  80294d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802950:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802953:	50                   	push   %eax
  802954:	e8 15 ef ff ff       	call   80186e <fd_alloc>
  802959:	83 c4 10             	add    $0x10,%esp
		return r;
  80295c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80295e:	85 c0                	test   %eax,%eax
  802960:	78 3e                	js     8029a0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802962:	83 ec 04             	sub    $0x4,%esp
  802965:	68 07 04 00 00       	push   $0x407
  80296a:	ff 75 f4             	pushl  -0xc(%ebp)
  80296d:	6a 00                	push   $0x0
  80296f:	e8 99 e8 ff ff       	call   80120d <sys_page_alloc>
  802974:	83 c4 10             	add    $0x10,%esp
		return r;
  802977:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802979:	85 c0                	test   %eax,%eax
  80297b:	78 23                	js     8029a0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80297d:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802983:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802986:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802988:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80298b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802992:	83 ec 0c             	sub    $0xc,%esp
  802995:	50                   	push   %eax
  802996:	e8 ac ee ff ff       	call   801847 <fd2num>
  80299b:	89 c2                	mov    %eax,%edx
  80299d:	83 c4 10             	add    $0x10,%esp
}
  8029a0:	89 d0                	mov    %edx,%eax
  8029a2:	c9                   	leave  
  8029a3:	c3                   	ret    

008029a4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8029a4:	55                   	push   %ebp
  8029a5:	89 e5                	mov    %esp,%ebp
  8029a7:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  8029aa:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8029b1:	75 56                	jne    802a09 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  8029b3:	83 ec 04             	sub    $0x4,%esp
  8029b6:	6a 07                	push   $0x7
  8029b8:	68 00 f0 bf ee       	push   $0xeebff000
  8029bd:	6a 00                	push   $0x0
  8029bf:	e8 49 e8 ff ff       	call   80120d <sys_page_alloc>
  8029c4:	83 c4 10             	add    $0x10,%esp
  8029c7:	85 c0                	test   %eax,%eax
  8029c9:	74 14                	je     8029df <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  8029cb:	83 ec 04             	sub    $0x4,%esp
  8029ce:	68 49 32 80 00       	push   $0x803249
  8029d3:	6a 21                	push   $0x21
  8029d5:	68 cb 33 80 00       	push   $0x8033cb
  8029da:	e8 ad dd ff ff       	call   80078c <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  8029df:	83 ec 08             	sub    $0x8,%esp
  8029e2:	68 13 2a 80 00       	push   $0x802a13
  8029e7:	6a 00                	push   $0x0
  8029e9:	e8 6a e9 ff ff       	call   801358 <sys_env_set_pgfault_upcall>
  8029ee:	83 c4 10             	add    $0x10,%esp
  8029f1:	85 c0                	test   %eax,%eax
  8029f3:	74 14                	je     802a09 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  8029f5:	83 ec 04             	sub    $0x4,%esp
  8029f8:	68 d9 33 80 00       	push   $0x8033d9
  8029fd:	6a 23                	push   $0x23
  8029ff:	68 cb 33 80 00       	push   $0x8033cb
  802a04:	e8 83 dd ff ff       	call   80078c <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a09:	8b 45 08             	mov    0x8(%ebp),%eax
  802a0c:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802a11:	c9                   	leave  
  802a12:	c3                   	ret    

00802a13 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a13:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a14:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802a19:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a1b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  802a1e:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  802a20:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  802a24:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  802a28:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  802a29:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  802a2b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  802a30:	83 c4 08             	add    $0x8,%esp
	popal
  802a33:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802a34:	83 c4 04             	add    $0x4,%esp
	popfl
  802a37:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802a38:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802a39:	c3                   	ret    

00802a3a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a3a:	55                   	push   %ebp
  802a3b:	89 e5                	mov    %esp,%ebp
  802a3d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a40:	89 d0                	mov    %edx,%eax
  802a42:	c1 e8 16             	shr    $0x16,%eax
  802a45:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802a4c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a51:	f6 c1 01             	test   $0x1,%cl
  802a54:	74 1d                	je     802a73 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802a56:	c1 ea 0c             	shr    $0xc,%edx
  802a59:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802a60:	f6 c2 01             	test   $0x1,%dl
  802a63:	74 0e                	je     802a73 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a65:	c1 ea 0c             	shr    $0xc,%edx
  802a68:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802a6f:	ef 
  802a70:	0f b7 c0             	movzwl %ax,%eax
}
  802a73:	5d                   	pop    %ebp
  802a74:	c3                   	ret    
  802a75:	66 90                	xchg   %ax,%ax
  802a77:	66 90                	xchg   %ax,%ax
  802a79:	66 90                	xchg   %ax,%ax
  802a7b:	66 90                	xchg   %ax,%ax
  802a7d:	66 90                	xchg   %ax,%ax
  802a7f:	90                   	nop

00802a80 <__udivdi3>:
  802a80:	55                   	push   %ebp
  802a81:	57                   	push   %edi
  802a82:	56                   	push   %esi
  802a83:	53                   	push   %ebx
  802a84:	83 ec 1c             	sub    $0x1c,%esp
  802a87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802a8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802a8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802a93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a97:	85 f6                	test   %esi,%esi
  802a99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a9d:	89 ca                	mov    %ecx,%edx
  802a9f:	89 f8                	mov    %edi,%eax
  802aa1:	75 3d                	jne    802ae0 <__udivdi3+0x60>
  802aa3:	39 cf                	cmp    %ecx,%edi
  802aa5:	0f 87 c5 00 00 00    	ja     802b70 <__udivdi3+0xf0>
  802aab:	85 ff                	test   %edi,%edi
  802aad:	89 fd                	mov    %edi,%ebp
  802aaf:	75 0b                	jne    802abc <__udivdi3+0x3c>
  802ab1:	b8 01 00 00 00       	mov    $0x1,%eax
  802ab6:	31 d2                	xor    %edx,%edx
  802ab8:	f7 f7                	div    %edi
  802aba:	89 c5                	mov    %eax,%ebp
  802abc:	89 c8                	mov    %ecx,%eax
  802abe:	31 d2                	xor    %edx,%edx
  802ac0:	f7 f5                	div    %ebp
  802ac2:	89 c1                	mov    %eax,%ecx
  802ac4:	89 d8                	mov    %ebx,%eax
  802ac6:	89 cf                	mov    %ecx,%edi
  802ac8:	f7 f5                	div    %ebp
  802aca:	89 c3                	mov    %eax,%ebx
  802acc:	89 d8                	mov    %ebx,%eax
  802ace:	89 fa                	mov    %edi,%edx
  802ad0:	83 c4 1c             	add    $0x1c,%esp
  802ad3:	5b                   	pop    %ebx
  802ad4:	5e                   	pop    %esi
  802ad5:	5f                   	pop    %edi
  802ad6:	5d                   	pop    %ebp
  802ad7:	c3                   	ret    
  802ad8:	90                   	nop
  802ad9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ae0:	39 ce                	cmp    %ecx,%esi
  802ae2:	77 74                	ja     802b58 <__udivdi3+0xd8>
  802ae4:	0f bd fe             	bsr    %esi,%edi
  802ae7:	83 f7 1f             	xor    $0x1f,%edi
  802aea:	0f 84 98 00 00 00    	je     802b88 <__udivdi3+0x108>
  802af0:	bb 20 00 00 00       	mov    $0x20,%ebx
  802af5:	89 f9                	mov    %edi,%ecx
  802af7:	89 c5                	mov    %eax,%ebp
  802af9:	29 fb                	sub    %edi,%ebx
  802afb:	d3 e6                	shl    %cl,%esi
  802afd:	89 d9                	mov    %ebx,%ecx
  802aff:	d3 ed                	shr    %cl,%ebp
  802b01:	89 f9                	mov    %edi,%ecx
  802b03:	d3 e0                	shl    %cl,%eax
  802b05:	09 ee                	or     %ebp,%esi
  802b07:	89 d9                	mov    %ebx,%ecx
  802b09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b0d:	89 d5                	mov    %edx,%ebp
  802b0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b13:	d3 ed                	shr    %cl,%ebp
  802b15:	89 f9                	mov    %edi,%ecx
  802b17:	d3 e2                	shl    %cl,%edx
  802b19:	89 d9                	mov    %ebx,%ecx
  802b1b:	d3 e8                	shr    %cl,%eax
  802b1d:	09 c2                	or     %eax,%edx
  802b1f:	89 d0                	mov    %edx,%eax
  802b21:	89 ea                	mov    %ebp,%edx
  802b23:	f7 f6                	div    %esi
  802b25:	89 d5                	mov    %edx,%ebp
  802b27:	89 c3                	mov    %eax,%ebx
  802b29:	f7 64 24 0c          	mull   0xc(%esp)
  802b2d:	39 d5                	cmp    %edx,%ebp
  802b2f:	72 10                	jb     802b41 <__udivdi3+0xc1>
  802b31:	8b 74 24 08          	mov    0x8(%esp),%esi
  802b35:	89 f9                	mov    %edi,%ecx
  802b37:	d3 e6                	shl    %cl,%esi
  802b39:	39 c6                	cmp    %eax,%esi
  802b3b:	73 07                	jae    802b44 <__udivdi3+0xc4>
  802b3d:	39 d5                	cmp    %edx,%ebp
  802b3f:	75 03                	jne    802b44 <__udivdi3+0xc4>
  802b41:	83 eb 01             	sub    $0x1,%ebx
  802b44:	31 ff                	xor    %edi,%edi
  802b46:	89 d8                	mov    %ebx,%eax
  802b48:	89 fa                	mov    %edi,%edx
  802b4a:	83 c4 1c             	add    $0x1c,%esp
  802b4d:	5b                   	pop    %ebx
  802b4e:	5e                   	pop    %esi
  802b4f:	5f                   	pop    %edi
  802b50:	5d                   	pop    %ebp
  802b51:	c3                   	ret    
  802b52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b58:	31 ff                	xor    %edi,%edi
  802b5a:	31 db                	xor    %ebx,%ebx
  802b5c:	89 d8                	mov    %ebx,%eax
  802b5e:	89 fa                	mov    %edi,%edx
  802b60:	83 c4 1c             	add    $0x1c,%esp
  802b63:	5b                   	pop    %ebx
  802b64:	5e                   	pop    %esi
  802b65:	5f                   	pop    %edi
  802b66:	5d                   	pop    %ebp
  802b67:	c3                   	ret    
  802b68:	90                   	nop
  802b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b70:	89 d8                	mov    %ebx,%eax
  802b72:	f7 f7                	div    %edi
  802b74:	31 ff                	xor    %edi,%edi
  802b76:	89 c3                	mov    %eax,%ebx
  802b78:	89 d8                	mov    %ebx,%eax
  802b7a:	89 fa                	mov    %edi,%edx
  802b7c:	83 c4 1c             	add    $0x1c,%esp
  802b7f:	5b                   	pop    %ebx
  802b80:	5e                   	pop    %esi
  802b81:	5f                   	pop    %edi
  802b82:	5d                   	pop    %ebp
  802b83:	c3                   	ret    
  802b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b88:	39 ce                	cmp    %ecx,%esi
  802b8a:	72 0c                	jb     802b98 <__udivdi3+0x118>
  802b8c:	31 db                	xor    %ebx,%ebx
  802b8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802b92:	0f 87 34 ff ff ff    	ja     802acc <__udivdi3+0x4c>
  802b98:	bb 01 00 00 00       	mov    $0x1,%ebx
  802b9d:	e9 2a ff ff ff       	jmp    802acc <__udivdi3+0x4c>
  802ba2:	66 90                	xchg   %ax,%ax
  802ba4:	66 90                	xchg   %ax,%ax
  802ba6:	66 90                	xchg   %ax,%ax
  802ba8:	66 90                	xchg   %ax,%ax
  802baa:	66 90                	xchg   %ax,%ax
  802bac:	66 90                	xchg   %ax,%ax
  802bae:	66 90                	xchg   %ax,%ax

00802bb0 <__umoddi3>:
  802bb0:	55                   	push   %ebp
  802bb1:	57                   	push   %edi
  802bb2:	56                   	push   %esi
  802bb3:	53                   	push   %ebx
  802bb4:	83 ec 1c             	sub    $0x1c,%esp
  802bb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802bbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802bbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  802bc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802bc7:	85 d2                	test   %edx,%edx
  802bc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802bcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bd1:	89 f3                	mov    %esi,%ebx
  802bd3:	89 3c 24             	mov    %edi,(%esp)
  802bd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802bda:	75 1c                	jne    802bf8 <__umoddi3+0x48>
  802bdc:	39 f7                	cmp    %esi,%edi
  802bde:	76 50                	jbe    802c30 <__umoddi3+0x80>
  802be0:	89 c8                	mov    %ecx,%eax
  802be2:	89 f2                	mov    %esi,%edx
  802be4:	f7 f7                	div    %edi
  802be6:	89 d0                	mov    %edx,%eax
  802be8:	31 d2                	xor    %edx,%edx
  802bea:	83 c4 1c             	add    $0x1c,%esp
  802bed:	5b                   	pop    %ebx
  802bee:	5e                   	pop    %esi
  802bef:	5f                   	pop    %edi
  802bf0:	5d                   	pop    %ebp
  802bf1:	c3                   	ret    
  802bf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802bf8:	39 f2                	cmp    %esi,%edx
  802bfa:	89 d0                	mov    %edx,%eax
  802bfc:	77 52                	ja     802c50 <__umoddi3+0xa0>
  802bfe:	0f bd ea             	bsr    %edx,%ebp
  802c01:	83 f5 1f             	xor    $0x1f,%ebp
  802c04:	75 5a                	jne    802c60 <__umoddi3+0xb0>
  802c06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802c0a:	0f 82 e0 00 00 00    	jb     802cf0 <__umoddi3+0x140>
  802c10:	39 0c 24             	cmp    %ecx,(%esp)
  802c13:	0f 86 d7 00 00 00    	jbe    802cf0 <__umoddi3+0x140>
  802c19:	8b 44 24 08          	mov    0x8(%esp),%eax
  802c1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c21:	83 c4 1c             	add    $0x1c,%esp
  802c24:	5b                   	pop    %ebx
  802c25:	5e                   	pop    %esi
  802c26:	5f                   	pop    %edi
  802c27:	5d                   	pop    %ebp
  802c28:	c3                   	ret    
  802c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c30:	85 ff                	test   %edi,%edi
  802c32:	89 fd                	mov    %edi,%ebp
  802c34:	75 0b                	jne    802c41 <__umoddi3+0x91>
  802c36:	b8 01 00 00 00       	mov    $0x1,%eax
  802c3b:	31 d2                	xor    %edx,%edx
  802c3d:	f7 f7                	div    %edi
  802c3f:	89 c5                	mov    %eax,%ebp
  802c41:	89 f0                	mov    %esi,%eax
  802c43:	31 d2                	xor    %edx,%edx
  802c45:	f7 f5                	div    %ebp
  802c47:	89 c8                	mov    %ecx,%eax
  802c49:	f7 f5                	div    %ebp
  802c4b:	89 d0                	mov    %edx,%eax
  802c4d:	eb 99                	jmp    802be8 <__umoddi3+0x38>
  802c4f:	90                   	nop
  802c50:	89 c8                	mov    %ecx,%eax
  802c52:	89 f2                	mov    %esi,%edx
  802c54:	83 c4 1c             	add    $0x1c,%esp
  802c57:	5b                   	pop    %ebx
  802c58:	5e                   	pop    %esi
  802c59:	5f                   	pop    %edi
  802c5a:	5d                   	pop    %ebp
  802c5b:	c3                   	ret    
  802c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c60:	8b 34 24             	mov    (%esp),%esi
  802c63:	bf 20 00 00 00       	mov    $0x20,%edi
  802c68:	89 e9                	mov    %ebp,%ecx
  802c6a:	29 ef                	sub    %ebp,%edi
  802c6c:	d3 e0                	shl    %cl,%eax
  802c6e:	89 f9                	mov    %edi,%ecx
  802c70:	89 f2                	mov    %esi,%edx
  802c72:	d3 ea                	shr    %cl,%edx
  802c74:	89 e9                	mov    %ebp,%ecx
  802c76:	09 c2                	or     %eax,%edx
  802c78:	89 d8                	mov    %ebx,%eax
  802c7a:	89 14 24             	mov    %edx,(%esp)
  802c7d:	89 f2                	mov    %esi,%edx
  802c7f:	d3 e2                	shl    %cl,%edx
  802c81:	89 f9                	mov    %edi,%ecx
  802c83:	89 54 24 04          	mov    %edx,0x4(%esp)
  802c87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802c8b:	d3 e8                	shr    %cl,%eax
  802c8d:	89 e9                	mov    %ebp,%ecx
  802c8f:	89 c6                	mov    %eax,%esi
  802c91:	d3 e3                	shl    %cl,%ebx
  802c93:	89 f9                	mov    %edi,%ecx
  802c95:	89 d0                	mov    %edx,%eax
  802c97:	d3 e8                	shr    %cl,%eax
  802c99:	89 e9                	mov    %ebp,%ecx
  802c9b:	09 d8                	or     %ebx,%eax
  802c9d:	89 d3                	mov    %edx,%ebx
  802c9f:	89 f2                	mov    %esi,%edx
  802ca1:	f7 34 24             	divl   (%esp)
  802ca4:	89 d6                	mov    %edx,%esi
  802ca6:	d3 e3                	shl    %cl,%ebx
  802ca8:	f7 64 24 04          	mull   0x4(%esp)
  802cac:	39 d6                	cmp    %edx,%esi
  802cae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802cb2:	89 d1                	mov    %edx,%ecx
  802cb4:	89 c3                	mov    %eax,%ebx
  802cb6:	72 08                	jb     802cc0 <__umoddi3+0x110>
  802cb8:	75 11                	jne    802ccb <__umoddi3+0x11b>
  802cba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802cbe:	73 0b                	jae    802ccb <__umoddi3+0x11b>
  802cc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  802cc4:	1b 14 24             	sbb    (%esp),%edx
  802cc7:	89 d1                	mov    %edx,%ecx
  802cc9:	89 c3                	mov    %eax,%ebx
  802ccb:	8b 54 24 08          	mov    0x8(%esp),%edx
  802ccf:	29 da                	sub    %ebx,%edx
  802cd1:	19 ce                	sbb    %ecx,%esi
  802cd3:	89 f9                	mov    %edi,%ecx
  802cd5:	89 f0                	mov    %esi,%eax
  802cd7:	d3 e0                	shl    %cl,%eax
  802cd9:	89 e9                	mov    %ebp,%ecx
  802cdb:	d3 ea                	shr    %cl,%edx
  802cdd:	89 e9                	mov    %ebp,%ecx
  802cdf:	d3 ee                	shr    %cl,%esi
  802ce1:	09 d0                	or     %edx,%eax
  802ce3:	89 f2                	mov    %esi,%edx
  802ce5:	83 c4 1c             	add    $0x1c,%esp
  802ce8:	5b                   	pop    %ebx
  802ce9:	5e                   	pop    %esi
  802cea:	5f                   	pop    %edi
  802ceb:	5d                   	pop    %ebp
  802cec:	c3                   	ret    
  802ced:	8d 76 00             	lea    0x0(%esi),%esi
  802cf0:	29 f9                	sub    %edi,%ecx
  802cf2:	19 d6                	sbb    %edx,%esi
  802cf4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802cf8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cfc:	e9 18 ff ff ff       	jmp    802c19 <__umoddi3+0x69>
