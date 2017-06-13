
obj/user/echosrv.debug:     file format elf32-i386


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
  80002c:	e8 91 04 00 00       	call   8004c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 30 27 80 00       	push   $0x802730
  80003f:	e8 71 05 00 00       	call   8005b5 <cprintf>
	exit();
  800044:	e8 bf 04 00 00       	call   800508 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <handle_client>:

void
handle_client(int sock)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 30             	sub    $0x30,%esp
  800057:	8b 75 08             	mov    0x8(%ebp),%esi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005a:	6a 20                	push   $0x20
  80005c:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	56                   	push   %esi
  800061:	e8 e3 13 00 00       	call   801449 <read>
  800066:	89 c3                	mov    %eax,%ebx
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	79 0a                	jns    800079 <handle_client+0x2b>
		die("Failed to receive initial bytes from client");
  80006f:	b8 34 27 80 00       	mov    $0x802734,%eax
  800074:	e8 ba ff ff ff       	call   800033 <die>

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
		// Send back received data
		if (write(sock, buffer, received) != received)
  800079:	8d 7d c8             	lea    -0x38(%ebp),%edi
  80007c:	eb 3b                	jmp    8000b9 <handle_client+0x6b>
  80007e:	83 ec 04             	sub    $0x4,%esp
  800081:	53                   	push   %ebx
  800082:	57                   	push   %edi
  800083:	56                   	push   %esi
  800084:	e8 9a 14 00 00       	call   801523 <write>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	39 c3                	cmp    %eax,%ebx
  80008e:	74 0a                	je     80009a <handle_client+0x4c>
			die("Failed to send bytes to client");
  800090:	b8 60 27 80 00       	mov    $0x802760,%eax
  800095:	e8 99 ff ff ff       	call   800033 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	6a 20                	push   $0x20
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	e8 a3 13 00 00       	call   801449 <read>
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	79 0a                	jns    8000b9 <handle_client+0x6b>
			die("Failed to receive additional bytes from client");
  8000af:	b8 80 27 80 00       	mov    $0x802780,%eax
  8000b4:	e8 7a ff ff ff       	call   800033 <die>
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  8000b9:	85 db                	test   %ebx,%ebx
  8000bb:	7f c1                	jg     80007e <handle_client+0x30>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  8000bd:	83 ec 0c             	sub    $0xc,%esp
  8000c0:	56                   	push   %esi
  8000c1:	e8 47 12 00 00       	call   80130d <close>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <umain>:

void
umain(int argc, char **argv)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 40             	sub    $0x40,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000da:	6a 06                	push   $0x6
  8000dc:	6a 01                	push   $0x1
  8000de:	6a 02                	push   $0x2
  8000e0:	e8 ea 1d 00 00       	call   801ecf <socket>
  8000e5:	89 c6                	mov    %eax,%esi
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	79 0a                	jns    8000f8 <umain+0x27>
		die("Failed to create socket");
  8000ee:	b8 e0 26 80 00       	mov    $0x8026e0,%eax
  8000f3:	e8 3b ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	68 f8 26 80 00       	push   $0x8026f8
  800100:	e8 b0 04 00 00       	call   8005b5 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800105:	83 c4 0c             	add    $0xc,%esp
  800108:	6a 10                	push   $0x10
  80010a:	6a 00                	push   $0x0
  80010c:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80010f:	53                   	push   %ebx
  800110:	e8 8a 0b 00 00       	call   800c9f <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  800115:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800120:	e8 6c 01 00 00       	call   800291 <htonl>
  800125:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800128:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80012f:	e8 43 01 00 00       	call   800277 <htons>
  800134:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to bind\n");
  800138:	c7 04 24 07 27 80 00 	movl   $0x802707,(%esp)
  80013f:	e8 71 04 00 00       	call   8005b5 <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  800144:	83 c4 0c             	add    $0xc,%esp
  800147:	6a 10                	push   $0x10
  800149:	53                   	push   %ebx
  80014a:	56                   	push   %esi
  80014b:	e8 ed 1c 00 00       	call   801e3d <bind>
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	85 c0                	test   %eax,%eax
  800155:	79 0a                	jns    800161 <umain+0x90>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
  800157:	b8 b0 27 80 00       	mov    $0x8027b0,%eax
  80015c:	e8 d2 fe ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	6a 05                	push   $0x5
  800166:	56                   	push   %esi
  800167:	e8 40 1d 00 00       	call   801eac <listen>
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	85 c0                	test   %eax,%eax
  800171:	79 0a                	jns    80017d <umain+0xac>
		die("Failed to listen on server socket");
  800173:	b8 d4 27 80 00       	mov    $0x8027d4,%eax
  800178:	e8 b6 fe ff ff       	call   800033 <die>

	cprintf("bound\n");
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	68 17 27 80 00       	push   $0x802717
  800185:	e8 2b 04 00 00       	call   8005b5 <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
  80018d:	8d 7d c4             	lea    -0x3c(%ebp),%edi

	cprintf("bound\n");

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
  800190:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock =
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	57                   	push   %edi
  80019b:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	56                   	push   %esi
  8001a0:	e8 61 1c 00 00       	call   801e06 <accept>
  8001a5:	89 c3                	mov    %eax,%ebx
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	79 0a                	jns    8001b8 <umain+0xe7>
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001ae:	b8 f8 27 80 00       	mov    $0x8027f8,%eax
  8001b3:	e8 7b fe ff ff       	call   800033 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	ff 75 cc             	pushl  -0x34(%ebp)
  8001be:	e8 1b 00 00 00       	call   8001de <inet_ntoa>
  8001c3:	83 c4 08             	add    $0x8,%esp
  8001c6:	50                   	push   %eax
  8001c7:	68 1e 27 80 00       	push   $0x80271e
  8001cc:	e8 e4 03 00 00       	call   8005b5 <cprintf>
		handle_client(clientsock);
  8001d1:	89 1c 24             	mov    %ebx,(%esp)
  8001d4:	e8 75 fe ff ff       	call   80004e <handle_client>
	}
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	eb b2                	jmp    800190 <umain+0xbf>

008001de <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	57                   	push   %edi
  8001e2:	56                   	push   %esi
  8001e3:	53                   	push   %ebx
  8001e4:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001ed:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001f0:	c7 45 e0 00 40 80 00 	movl   $0x804000,-0x20(%ebp)
  8001f7:	0f b6 0f             	movzbl (%edi),%ecx
  8001fa:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8001ff:	0f b6 d9             	movzbl %cl,%ebx
  800202:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800205:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800208:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80020b:	66 c1 e8 0b          	shr    $0xb,%ax
  80020f:	89 c3                	mov    %eax,%ebx
  800211:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800214:	01 c0                	add    %eax,%eax
  800216:	29 c1                	sub    %eax,%ecx
  800218:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  80021a:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  80021c:	8d 72 01             	lea    0x1(%edx),%esi
  80021f:	0f b6 d2             	movzbl %dl,%edx
  800222:	83 c0 30             	add    $0x30,%eax
  800225:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800229:	89 f2                	mov    %esi,%edx
    } while(*ap);
  80022b:	84 db                	test   %bl,%bl
  80022d:	75 d0                	jne    8001ff <inet_ntoa+0x21>
  80022f:	c6 07 00             	movb   $0x0,(%edi)
  800232:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800235:	eb 0d                	jmp    800244 <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  800237:	0f b6 c2             	movzbl %dl,%eax
  80023a:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  80023f:	88 01                	mov    %al,(%ecx)
  800241:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800244:	83 ea 01             	sub    $0x1,%edx
  800247:	80 fa ff             	cmp    $0xff,%dl
  80024a:	75 eb                	jne    800237 <inet_ntoa+0x59>
  80024c:	89 f0                	mov    %esi,%eax
  80024e:	0f b6 f0             	movzbl %al,%esi
  800251:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  800254:	8d 46 01             	lea    0x1(%esi),%eax
  800257:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025a:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  80025d:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800260:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800263:	39 c7                	cmp    %eax,%edi
  800265:	75 90                	jne    8001f7 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800267:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  80026a:	b8 00 40 80 00       	mov    $0x804000,%eax
  80026f:	83 c4 14             	add    $0x14,%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  80027a:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80027e:	66 c1 c0 08          	rol    $0x8,%ax
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  return htons(n);
  800287:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80028b:	66 c1 c0 08          	rol    $0x8,%ax
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800297:	89 d1                	mov    %edx,%ecx
  800299:	c1 e1 18             	shl    $0x18,%ecx
  80029c:	89 d0                	mov    %edx,%eax
  80029e:	c1 e8 18             	shr    $0x18,%eax
  8002a1:	09 c8                	or     %ecx,%eax
  8002a3:	89 d1                	mov    %edx,%ecx
  8002a5:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8002ab:	c1 e1 08             	shl    $0x8,%ecx
  8002ae:	09 c8                	or     %ecx,%eax
  8002b0:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8002b6:	c1 ea 08             	shr    $0x8,%edx
  8002b9:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 20             	sub    $0x20,%esp
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002c9:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002cc:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8002cf:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002d2:	0f b6 ca             	movzbl %dl,%ecx
  8002d5:	83 e9 30             	sub    $0x30,%ecx
  8002d8:	83 f9 09             	cmp    $0x9,%ecx
  8002db:	0f 87 94 01 00 00    	ja     800475 <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8002e1:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8002e8:	83 fa 30             	cmp    $0x30,%edx
  8002eb:	75 2b                	jne    800318 <inet_aton+0x5b>
      c = *++cp;
  8002ed:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8002f1:	89 d1                	mov    %edx,%ecx
  8002f3:	83 e1 df             	and    $0xffffffdf,%ecx
  8002f6:	80 f9 58             	cmp    $0x58,%cl
  8002f9:	74 0f                	je     80030a <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8002fb:	83 c0 01             	add    $0x1,%eax
  8002fe:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800301:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800308:	eb 0e                	jmp    800318 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80030a:	0f be 50 02          	movsbl 0x2(%eax),%edx
  80030e:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800311:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800318:	83 c0 01             	add    $0x1,%eax
  80031b:	be 00 00 00 00       	mov    $0x0,%esi
  800320:	eb 03                	jmp    800325 <inet_aton+0x68>
  800322:	83 c0 01             	add    $0x1,%eax
  800325:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800328:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80032b:	0f b6 fa             	movzbl %dl,%edi
  80032e:	8d 4f d0             	lea    -0x30(%edi),%ecx
  800331:	83 f9 09             	cmp    $0x9,%ecx
  800334:	77 0d                	ja     800343 <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  800336:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  80033a:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  80033e:	0f be 10             	movsbl (%eax),%edx
  800341:	eb df                	jmp    800322 <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  800343:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  800347:	75 32                	jne    80037b <inet_aton+0xbe>
  800349:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  80034c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80034f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800352:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800358:	83 e9 41             	sub    $0x41,%ecx
  80035b:	83 f9 05             	cmp    $0x5,%ecx
  80035e:	77 1b                	ja     80037b <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800360:	c1 e6 04             	shl    $0x4,%esi
  800363:	83 c2 0a             	add    $0xa,%edx
  800366:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  80036a:	19 c9                	sbb    %ecx,%ecx
  80036c:	83 e1 20             	and    $0x20,%ecx
  80036f:	83 c1 41             	add    $0x41,%ecx
  800372:	29 ca                	sub    %ecx,%edx
  800374:	09 d6                	or     %edx,%esi
        c = *++cp;
  800376:	0f be 10             	movsbl (%eax),%edx
  800379:	eb a7                	jmp    800322 <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  80037b:	83 fa 2e             	cmp    $0x2e,%edx
  80037e:	75 23                	jne    8003a3 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800380:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800383:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800386:	39 f8                	cmp    %edi,%eax
  800388:	0f 84 ee 00 00 00    	je     80047c <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  80038e:	83 c0 04             	add    $0x4,%eax
  800391:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800394:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800397:	8d 43 01             	lea    0x1(%ebx),%eax
  80039a:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  80039e:	e9 2f ff ff ff       	jmp    8002d2 <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003a3:	85 d2                	test   %edx,%edx
  8003a5:	74 25                	je     8003cc <inet_aton+0x10f>
  8003a7:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003af:	83 f9 5f             	cmp    $0x5f,%ecx
  8003b2:	0f 87 d0 00 00 00    	ja     800488 <inet_aton+0x1cb>
  8003b8:	83 fa 20             	cmp    $0x20,%edx
  8003bb:	74 0f                	je     8003cc <inet_aton+0x10f>
  8003bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c0:	83 ea 09             	sub    $0x9,%edx
  8003c3:	83 fa 04             	cmp    $0x4,%edx
  8003c6:	0f 87 bc 00 00 00    	ja     800488 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8003cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003d2:	29 c2                	sub    %eax,%edx
  8003d4:	c1 fa 02             	sar    $0x2,%edx
  8003d7:	83 c2 01             	add    $0x1,%edx
  8003da:	83 fa 02             	cmp    $0x2,%edx
  8003dd:	74 20                	je     8003ff <inet_aton+0x142>
  8003df:	83 fa 02             	cmp    $0x2,%edx
  8003e2:	7f 0f                	jg     8003f3 <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8003e4:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	0f 84 97 00 00 00    	je     800488 <inet_aton+0x1cb>
  8003f1:	eb 67                	jmp    80045a <inet_aton+0x19d>
  8003f3:	83 fa 03             	cmp    $0x3,%edx
  8003f6:	74 1e                	je     800416 <inet_aton+0x159>
  8003f8:	83 fa 04             	cmp    $0x4,%edx
  8003fb:	74 38                	je     800435 <inet_aton+0x178>
  8003fd:	eb 5b                	jmp    80045a <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800404:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  80040a:	77 7c                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  80040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80040f:	c1 e0 18             	shl    $0x18,%eax
  800412:	09 c6                	or     %eax,%esi
    break;
  800414:	eb 44                	jmp    80045a <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80041b:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800421:	77 65                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800423:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800426:	c1 e2 18             	shl    $0x18,%edx
  800429:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80042c:	c1 e0 10             	shl    $0x10,%eax
  80042f:	09 d0                	or     %edx,%eax
  800431:	09 c6                	or     %eax,%esi
    break;
  800433:	eb 25                	jmp    80045a <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80043a:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800440:	77 46                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800442:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800445:	c1 e2 18             	shl    $0x18,%edx
  800448:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80044b:	c1 e0 10             	shl    $0x10,%eax
  80044e:	09 c2                	or     %eax,%edx
  800450:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800453:	c1 e0 08             	shl    $0x8,%eax
  800456:	09 d0                	or     %edx,%eax
  800458:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  80045a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80045e:	74 23                	je     800483 <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800460:	56                   	push   %esi
  800461:	e8 2b fe ff ff       	call   800291 <htonl>
  800466:	83 c4 04             	add    $0x4,%esp
  800469:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80046c:	89 03                	mov    %eax,(%ebx)
  return (1);
  80046e:	b8 01 00 00 00       	mov    $0x1,%eax
  800473:	eb 13                	jmp    800488 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	eb 0c                	jmp    800488 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	eb 05                	jmp    800488 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800483:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048b:	5b                   	pop    %ebx
  80048c:	5e                   	pop    %esi
  80048d:	5f                   	pop    %edi
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800496:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800499:	50                   	push   %eax
  80049a:	ff 75 08             	pushl  0x8(%ebp)
  80049d:	e8 1b fe ff ff       	call   8002bd <inet_aton>
  8004a2:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004ac:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    

008004b2 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  8004b5:	ff 75 08             	pushl  0x8(%ebp)
  8004b8:	e8 d4 fd ff ff       	call   800291 <htonl>
  8004bd:	83 c4 04             	add    $0x4,%esp
}
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    

008004c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	56                   	push   %esi
  8004c6:	53                   	push   %ebx
  8004c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8004cd:	e8 4d 0a 00 00       	call   800f1f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8004d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004df:	a3 18 40 80 00       	mov    %eax,0x804018
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004e4:	85 db                	test   %ebx,%ebx
  8004e6:	7e 07                	jle    8004ef <libmain+0x2d>
		binaryname = argv[0];
  8004e8:	8b 06                	mov    (%esi),%eax
  8004ea:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	e8 d8 fb ff ff       	call   8000d1 <umain>

	// exit gracefully
	exit();
  8004f9:	e8 0a 00 00 00       	call   800508 <exit>
}
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800504:	5b                   	pop    %ebx
  800505:	5e                   	pop    %esi
  800506:	5d                   	pop    %ebp
  800507:	c3                   	ret    

00800508 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80050e:	e8 25 0e 00 00       	call   801338 <close_all>
	sys_env_destroy(0);
  800513:	83 ec 0c             	sub    $0xc,%esp
  800516:	6a 00                	push   $0x0
  800518:	e8 c1 09 00 00       	call   800ede <sys_env_destroy>
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80052c:	8b 13                	mov    (%ebx),%edx
  80052e:	8d 42 01             	lea    0x1(%edx),%eax
  800531:	89 03                	mov    %eax,(%ebx)
  800533:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800536:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80053a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80053f:	75 1a                	jne    80055b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	68 ff 00 00 00       	push   $0xff
  800549:	8d 43 08             	lea    0x8(%ebx),%eax
  80054c:	50                   	push   %eax
  80054d:	e8 4f 09 00 00       	call   800ea1 <sys_cputs>
		b->idx = 0;
  800552:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800558:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80055b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80055f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80056d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800574:	00 00 00 
	b.cnt = 0;
  800577:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80057e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800581:	ff 75 0c             	pushl  0xc(%ebp)
  800584:	ff 75 08             	pushl  0x8(%ebp)
  800587:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80058d:	50                   	push   %eax
  80058e:	68 22 05 80 00       	push   $0x800522
  800593:	e8 54 01 00 00       	call   8006ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800598:	83 c4 08             	add    $0x8,%esp
  80059b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005a7:	50                   	push   %eax
  8005a8:	e8 f4 08 00 00       	call   800ea1 <sys_cputs>

	return b.cnt;
}
  8005ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005b3:	c9                   	leave  
  8005b4:	c3                   	ret    

008005b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005be:	50                   	push   %eax
  8005bf:	ff 75 08             	pushl  0x8(%ebp)
  8005c2:	e8 9d ff ff ff       	call   800564 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005c7:	c9                   	leave  
  8005c8:	c3                   	ret    

008005c9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005c9:	55                   	push   %ebp
  8005ca:	89 e5                	mov    %esp,%ebp
  8005cc:	57                   	push   %edi
  8005cd:	56                   	push   %esi
  8005ce:	53                   	push   %ebx
  8005cf:	83 ec 1c             	sub    $0x1c,%esp
  8005d2:	89 c7                	mov    %eax,%edi
  8005d4:	89 d6                	mov    %edx,%esi
  8005d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005df:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005ed:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f0:	39 d3                	cmp    %edx,%ebx
  8005f2:	72 05                	jb     8005f9 <printnum+0x30>
  8005f4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005f7:	77 45                	ja     80063e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005f9:	83 ec 0c             	sub    $0xc,%esp
  8005fc:	ff 75 18             	pushl  0x18(%ebp)
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800605:	53                   	push   %ebx
  800606:	ff 75 10             	pushl  0x10(%ebp)
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80060f:	ff 75 e0             	pushl  -0x20(%ebp)
  800612:	ff 75 dc             	pushl  -0x24(%ebp)
  800615:	ff 75 d8             	pushl  -0x28(%ebp)
  800618:	e8 33 1e 00 00       	call   802450 <__udivdi3>
  80061d:	83 c4 18             	add    $0x18,%esp
  800620:	52                   	push   %edx
  800621:	50                   	push   %eax
  800622:	89 f2                	mov    %esi,%edx
  800624:	89 f8                	mov    %edi,%eax
  800626:	e8 9e ff ff ff       	call   8005c9 <printnum>
  80062b:	83 c4 20             	add    $0x20,%esp
  80062e:	eb 18                	jmp    800648 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	56                   	push   %esi
  800634:	ff 75 18             	pushl  0x18(%ebp)
  800637:	ff d7                	call   *%edi
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	eb 03                	jmp    800641 <printnum+0x78>
  80063e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800641:	83 eb 01             	sub    $0x1,%ebx
  800644:	85 db                	test   %ebx,%ebx
  800646:	7f e8                	jg     800630 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	56                   	push   %esi
  80064c:	83 ec 04             	sub    $0x4,%esp
  80064f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800652:	ff 75 e0             	pushl  -0x20(%ebp)
  800655:	ff 75 dc             	pushl  -0x24(%ebp)
  800658:	ff 75 d8             	pushl  -0x28(%ebp)
  80065b:	e8 20 1f 00 00       	call   802580 <__umoddi3>
  800660:	83 c4 14             	add    $0x14,%esp
  800663:	0f be 80 25 28 80 00 	movsbl 0x802825(%eax),%eax
  80066a:	50                   	push   %eax
  80066b:	ff d7                	call   *%edi
}
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80067b:	83 fa 01             	cmp    $0x1,%edx
  80067e:	7e 0e                	jle    80068e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800680:	8b 10                	mov    (%eax),%edx
  800682:	8d 4a 08             	lea    0x8(%edx),%ecx
  800685:	89 08                	mov    %ecx,(%eax)
  800687:	8b 02                	mov    (%edx),%eax
  800689:	8b 52 04             	mov    0x4(%edx),%edx
  80068c:	eb 22                	jmp    8006b0 <getuint+0x38>
	else if (lflag)
  80068e:	85 d2                	test   %edx,%edx
  800690:	74 10                	je     8006a2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800692:	8b 10                	mov    (%eax),%edx
  800694:	8d 4a 04             	lea    0x4(%edx),%ecx
  800697:	89 08                	mov    %ecx,(%eax)
  800699:	8b 02                	mov    (%edx),%eax
  80069b:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a0:	eb 0e                	jmp    8006b0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a7:	89 08                	mov    %ecx,(%eax)
  8006a9:	8b 02                	mov    (%edx),%eax
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006b8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c1:	73 0a                	jae    8006cd <sprintputch+0x1b>
		*b->buf++ = ch;
  8006c3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006c6:	89 08                	mov    %ecx,(%eax)
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	88 02                	mov    %al,(%edx)
}
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006d8:	50                   	push   %eax
  8006d9:	ff 75 10             	pushl  0x10(%ebp)
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	ff 75 08             	pushl  0x8(%ebp)
  8006e2:	e8 05 00 00 00       	call   8006ec <vprintfmt>
	va_end(ap);
}
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	57                   	push   %edi
  8006f0:	56                   	push   %esi
  8006f1:	53                   	push   %ebx
  8006f2:	83 ec 2c             	sub    $0x2c,%esp
  8006f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006fe:	eb 12                	jmp    800712 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800700:	85 c0                	test   %eax,%eax
  800702:	0f 84 a9 03 00 00    	je     800ab1 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	50                   	push   %eax
  80070d:	ff d6                	call   *%esi
  80070f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800712:	83 c7 01             	add    $0x1,%edi
  800715:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800719:	83 f8 25             	cmp    $0x25,%eax
  80071c:	75 e2                	jne    800700 <vprintfmt+0x14>
  80071e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800722:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800729:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800730:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800737:	ba 00 00 00 00       	mov    $0x0,%edx
  80073c:	eb 07                	jmp    800745 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800741:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8d 47 01             	lea    0x1(%edi),%eax
  800748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074b:	0f b6 07             	movzbl (%edi),%eax
  80074e:	0f b6 c8             	movzbl %al,%ecx
  800751:	83 e8 23             	sub    $0x23,%eax
  800754:	3c 55                	cmp    $0x55,%al
  800756:	0f 87 3a 03 00 00    	ja     800a96 <vprintfmt+0x3aa>
  80075c:	0f b6 c0             	movzbl %al,%eax
  80075f:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
  800766:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800769:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80076d:	eb d6                	jmp    800745 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80077a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80077d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800781:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800784:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800787:	83 fa 09             	cmp    $0x9,%edx
  80078a:	77 39                	ja     8007c5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80078c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80078f:	eb e9                	jmp    80077a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 48 04             	lea    0x4(%eax),%ecx
  800797:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80079a:	8b 00                	mov    (%eax),%eax
  80079c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007a2:	eb 27                	jmp    8007cb <vprintfmt+0xdf>
  8007a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ae:	0f 49 c8             	cmovns %eax,%ecx
  8007b1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b7:	eb 8c                	jmp    800745 <vprintfmt+0x59>
  8007b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007bc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007c3:	eb 80                	jmp    800745 <vprintfmt+0x59>
  8007c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007cf:	0f 89 70 ff ff ff    	jns    800745 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007db:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007e2:	e9 5e ff ff ff       	jmp    800745 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007ed:	e9 53 ff ff ff       	jmp    800745 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	ff 30                	pushl  (%eax)
  800801:	ff d6                	call   *%esi
			break;
  800803:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800806:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800809:	e9 04 ff ff ff       	jmp    800712 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080e:	8b 45 14             	mov    0x14(%ebp),%eax
  800811:	8d 50 04             	lea    0x4(%eax),%edx
  800814:	89 55 14             	mov    %edx,0x14(%ebp)
  800817:	8b 00                	mov    (%eax),%eax
  800819:	99                   	cltd   
  80081a:	31 d0                	xor    %edx,%eax
  80081c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80081e:	83 f8 0f             	cmp    $0xf,%eax
  800821:	7f 0b                	jg     80082e <vprintfmt+0x142>
  800823:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  80082a:	85 d2                	test   %edx,%edx
  80082c:	75 18                	jne    800846 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80082e:	50                   	push   %eax
  80082f:	68 3d 28 80 00       	push   $0x80283d
  800834:	53                   	push   %ebx
  800835:	56                   	push   %esi
  800836:	e8 94 fe ff ff       	call   8006cf <printfmt>
  80083b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800841:	e9 cc fe ff ff       	jmp    800712 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800846:	52                   	push   %edx
  800847:	68 f5 2b 80 00       	push   $0x802bf5
  80084c:	53                   	push   %ebx
  80084d:	56                   	push   %esi
  80084e:	e8 7c fe ff ff       	call   8006cf <printfmt>
  800853:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800856:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800859:	e9 b4 fe ff ff       	jmp    800712 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8d 50 04             	lea    0x4(%eax),%edx
  800864:	89 55 14             	mov    %edx,0x14(%ebp)
  800867:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800869:	85 ff                	test   %edi,%edi
  80086b:	b8 36 28 80 00       	mov    $0x802836,%eax
  800870:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800873:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800877:	0f 8e 94 00 00 00    	jle    800911 <vprintfmt+0x225>
  80087d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800881:	0f 84 98 00 00 00    	je     80091f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800887:	83 ec 08             	sub    $0x8,%esp
  80088a:	ff 75 d0             	pushl  -0x30(%ebp)
  80088d:	57                   	push   %edi
  80088e:	e8 a6 02 00 00       	call   800b39 <strnlen>
  800893:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800896:	29 c1                	sub    %eax,%ecx
  800898:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80089b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80089e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008a5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008a8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008aa:	eb 0f                	jmp    8008bb <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b5:	83 ef 01             	sub    $0x1,%edi
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	85 ff                	test   %edi,%edi
  8008bd:	7f ed                	jg     8008ac <vprintfmt+0x1c0>
  8008bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008c2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cc:	0f 49 c1             	cmovns %ecx,%eax
  8008cf:	29 c1                	sub    %eax,%ecx
  8008d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8008d4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008d7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008da:	89 cb                	mov    %ecx,%ebx
  8008dc:	eb 4d                	jmp    80092b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008e2:	74 1b                	je     8008ff <vprintfmt+0x213>
  8008e4:	0f be c0             	movsbl %al,%eax
  8008e7:	83 e8 20             	sub    $0x20,%eax
  8008ea:	83 f8 5e             	cmp    $0x5e,%eax
  8008ed:	76 10                	jbe    8008ff <vprintfmt+0x213>
					putch('?', putdat);
  8008ef:	83 ec 08             	sub    $0x8,%esp
  8008f2:	ff 75 0c             	pushl  0xc(%ebp)
  8008f5:	6a 3f                	push   $0x3f
  8008f7:	ff 55 08             	call   *0x8(%ebp)
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	eb 0d                	jmp    80090c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	52                   	push   %edx
  800906:	ff 55 08             	call   *0x8(%ebp)
  800909:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80090c:	83 eb 01             	sub    $0x1,%ebx
  80090f:	eb 1a                	jmp    80092b <vprintfmt+0x23f>
  800911:	89 75 08             	mov    %esi,0x8(%ebp)
  800914:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800917:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80091a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80091d:	eb 0c                	jmp    80092b <vprintfmt+0x23f>
  80091f:	89 75 08             	mov    %esi,0x8(%ebp)
  800922:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800925:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800928:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80092b:	83 c7 01             	add    $0x1,%edi
  80092e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800932:	0f be d0             	movsbl %al,%edx
  800935:	85 d2                	test   %edx,%edx
  800937:	74 23                	je     80095c <vprintfmt+0x270>
  800939:	85 f6                	test   %esi,%esi
  80093b:	78 a1                	js     8008de <vprintfmt+0x1f2>
  80093d:	83 ee 01             	sub    $0x1,%esi
  800940:	79 9c                	jns    8008de <vprintfmt+0x1f2>
  800942:	89 df                	mov    %ebx,%edi
  800944:	8b 75 08             	mov    0x8(%ebp),%esi
  800947:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094a:	eb 18                	jmp    800964 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80094c:	83 ec 08             	sub    $0x8,%esp
  80094f:	53                   	push   %ebx
  800950:	6a 20                	push   $0x20
  800952:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800954:	83 ef 01             	sub    $0x1,%edi
  800957:	83 c4 10             	add    $0x10,%esp
  80095a:	eb 08                	jmp    800964 <vprintfmt+0x278>
  80095c:	89 df                	mov    %ebx,%edi
  80095e:	8b 75 08             	mov    0x8(%ebp),%esi
  800961:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800964:	85 ff                	test   %edi,%edi
  800966:	7f e4                	jg     80094c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800968:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096b:	e9 a2 fd ff ff       	jmp    800712 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800970:	83 fa 01             	cmp    $0x1,%edx
  800973:	7e 16                	jle    80098b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800975:	8b 45 14             	mov    0x14(%ebp),%eax
  800978:	8d 50 08             	lea    0x8(%eax),%edx
  80097b:	89 55 14             	mov    %edx,0x14(%ebp)
  80097e:	8b 50 04             	mov    0x4(%eax),%edx
  800981:	8b 00                	mov    (%eax),%eax
  800983:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800986:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800989:	eb 32                	jmp    8009bd <vprintfmt+0x2d1>
	else if (lflag)
  80098b:	85 d2                	test   %edx,%edx
  80098d:	74 18                	je     8009a7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 50 04             	lea    0x4(%eax),%edx
  800995:	89 55 14             	mov    %edx,0x14(%ebp)
  800998:	8b 00                	mov    (%eax),%eax
  80099a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80099d:	89 c1                	mov    %eax,%ecx
  80099f:	c1 f9 1f             	sar    $0x1f,%ecx
  8009a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009a5:	eb 16                	jmp    8009bd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	8d 50 04             	lea    0x4(%eax),%edx
  8009ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b0:	8b 00                	mov    (%eax),%eax
  8009b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009b5:	89 c1                	mov    %eax,%ecx
  8009b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009c8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009cc:	0f 89 90 00 00 00    	jns    800a62 <vprintfmt+0x376>
				putch('-', putdat);
  8009d2:	83 ec 08             	sub    $0x8,%esp
  8009d5:	53                   	push   %ebx
  8009d6:	6a 2d                	push   $0x2d
  8009d8:	ff d6                	call   *%esi
				num = -(long long) num;
  8009da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e0:	f7 d8                	neg    %eax
  8009e2:	83 d2 00             	adc    $0x0,%edx
  8009e5:	f7 da                	neg    %edx
  8009e7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009ef:	eb 71                	jmp    800a62 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f4:	e8 7f fc ff ff       	call   800678 <getuint>
			base = 10;
  8009f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009fe:	eb 62                	jmp    800a62 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a00:	8d 45 14             	lea    0x14(%ebp),%eax
  800a03:	e8 70 fc ff ff       	call   800678 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800a08:	83 ec 0c             	sub    $0xc,%esp
  800a0b:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800a0f:	51                   	push   %ecx
  800a10:	ff 75 e0             	pushl  -0x20(%ebp)
  800a13:	6a 08                	push   $0x8
  800a15:	52                   	push   %edx
  800a16:	50                   	push   %eax
  800a17:	89 da                	mov    %ebx,%edx
  800a19:	89 f0                	mov    %esi,%eax
  800a1b:	e8 a9 fb ff ff       	call   8005c9 <printnum>
			break;
  800a20:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800a26:	e9 e7 fc ff ff       	jmp    800712 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800a2b:	83 ec 08             	sub    $0x8,%esp
  800a2e:	53                   	push   %ebx
  800a2f:	6a 30                	push   $0x30
  800a31:	ff d6                	call   *%esi
			putch('x', putdat);
  800a33:	83 c4 08             	add    $0x8,%esp
  800a36:	53                   	push   %ebx
  800a37:	6a 78                	push   $0x78
  800a39:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3e:	8d 50 04             	lea    0x4(%eax),%edx
  800a41:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a44:	8b 00                	mov    (%eax),%eax
  800a46:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a4b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a4e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a53:	eb 0d                	jmp    800a62 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a55:	8d 45 14             	lea    0x14(%ebp),%eax
  800a58:	e8 1b fc ff ff       	call   800678 <getuint>
			base = 16;
  800a5d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a62:	83 ec 0c             	sub    $0xc,%esp
  800a65:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a69:	57                   	push   %edi
  800a6a:	ff 75 e0             	pushl  -0x20(%ebp)
  800a6d:	51                   	push   %ecx
  800a6e:	52                   	push   %edx
  800a6f:	50                   	push   %eax
  800a70:	89 da                	mov    %ebx,%edx
  800a72:	89 f0                	mov    %esi,%eax
  800a74:	e8 50 fb ff ff       	call   8005c9 <printnum>
			break;
  800a79:	83 c4 20             	add    $0x20,%esp
  800a7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7f:	e9 8e fc ff ff       	jmp    800712 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a84:	83 ec 08             	sub    $0x8,%esp
  800a87:	53                   	push   %ebx
  800a88:	51                   	push   %ecx
  800a89:	ff d6                	call   *%esi
			break;
  800a8b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a91:	e9 7c fc ff ff       	jmp    800712 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a96:	83 ec 08             	sub    $0x8,%esp
  800a99:	53                   	push   %ebx
  800a9a:	6a 25                	push   $0x25
  800a9c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a9e:	83 c4 10             	add    $0x10,%esp
  800aa1:	eb 03                	jmp    800aa6 <vprintfmt+0x3ba>
  800aa3:	83 ef 01             	sub    $0x1,%edi
  800aa6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800aaa:	75 f7                	jne    800aa3 <vprintfmt+0x3b7>
  800aac:	e9 61 fc ff ff       	jmp    800712 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ab1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	83 ec 18             	sub    $0x18,%esp
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ac5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ac8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800acc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800acf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	74 26                	je     800b00 <vsnprintf+0x47>
  800ada:	85 d2                	test   %edx,%edx
  800adc:	7e 22                	jle    800b00 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ade:	ff 75 14             	pushl  0x14(%ebp)
  800ae1:	ff 75 10             	pushl  0x10(%ebp)
  800ae4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ae7:	50                   	push   %eax
  800ae8:	68 b2 06 80 00       	push   $0x8006b2
  800aed:	e8 fa fb ff ff       	call   8006ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800af2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800af5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800afb:	83 c4 10             	add    $0x10,%esp
  800afe:	eb 05                	jmp    800b05 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b0d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b10:	50                   	push   %eax
  800b11:	ff 75 10             	pushl  0x10(%ebp)
  800b14:	ff 75 0c             	pushl  0xc(%ebp)
  800b17:	ff 75 08             	pushl  0x8(%ebp)
  800b1a:	e8 9a ff ff ff       	call   800ab9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2c:	eb 03                	jmp    800b31 <strlen+0x10>
		n++;
  800b2e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b31:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b35:	75 f7                	jne    800b2e <strlen+0xd>
		n++;
	return n;
}
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	eb 03                	jmp    800b4c <strnlen+0x13>
		n++;
  800b49:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b4c:	39 c2                	cmp    %eax,%edx
  800b4e:	74 08                	je     800b58 <strnlen+0x1f>
  800b50:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b54:	75 f3                	jne    800b49 <strnlen+0x10>
  800b56:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	53                   	push   %ebx
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b64:	89 c2                	mov    %eax,%edx
  800b66:	83 c2 01             	add    $0x1,%edx
  800b69:	83 c1 01             	add    $0x1,%ecx
  800b6c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b70:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b73:	84 db                	test   %bl,%bl
  800b75:	75 ef                	jne    800b66 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b77:	5b                   	pop    %ebx
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	53                   	push   %ebx
  800b7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b81:	53                   	push   %ebx
  800b82:	e8 9a ff ff ff       	call   800b21 <strlen>
  800b87:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b8a:	ff 75 0c             	pushl  0xc(%ebp)
  800b8d:	01 d8                	add    %ebx,%eax
  800b8f:	50                   	push   %eax
  800b90:	e8 c5 ff ff ff       	call   800b5a <strcpy>
	return dst;
}
  800b95:	89 d8                	mov    %ebx,%eax
  800b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9a:	c9                   	leave  
  800b9b:	c3                   	ret    

00800b9c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba7:	89 f3                	mov    %esi,%ebx
  800ba9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bac:	89 f2                	mov    %esi,%edx
  800bae:	eb 0f                	jmp    800bbf <strncpy+0x23>
		*dst++ = *src;
  800bb0:	83 c2 01             	add    $0x1,%edx
  800bb3:	0f b6 01             	movzbl (%ecx),%eax
  800bb6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bb9:	80 39 01             	cmpb   $0x1,(%ecx)
  800bbc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bbf:	39 da                	cmp    %ebx,%edx
  800bc1:	75 ed                	jne    800bb0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bc3:	89 f0                	mov    %esi,%eax
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	8b 75 08             	mov    0x8(%ebp),%esi
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 10             	mov    0x10(%ebp),%edx
  800bd7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bd9:	85 d2                	test   %edx,%edx
  800bdb:	74 21                	je     800bfe <strlcpy+0x35>
  800bdd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800be1:	89 f2                	mov    %esi,%edx
  800be3:	eb 09                	jmp    800bee <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800be5:	83 c2 01             	add    $0x1,%edx
  800be8:	83 c1 01             	add    $0x1,%ecx
  800beb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bee:	39 c2                	cmp    %eax,%edx
  800bf0:	74 09                	je     800bfb <strlcpy+0x32>
  800bf2:	0f b6 19             	movzbl (%ecx),%ebx
  800bf5:	84 db                	test   %bl,%bl
  800bf7:	75 ec                	jne    800be5 <strlcpy+0x1c>
  800bf9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bfb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bfe:	29 f0                	sub    %esi,%eax
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c0d:	eb 06                	jmp    800c15 <strcmp+0x11>
		p++, q++;
  800c0f:	83 c1 01             	add    $0x1,%ecx
  800c12:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c15:	0f b6 01             	movzbl (%ecx),%eax
  800c18:	84 c0                	test   %al,%al
  800c1a:	74 04                	je     800c20 <strcmp+0x1c>
  800c1c:	3a 02                	cmp    (%edx),%al
  800c1e:	74 ef                	je     800c0f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c20:	0f b6 c0             	movzbl %al,%eax
  800c23:	0f b6 12             	movzbl (%edx),%edx
  800c26:	29 d0                	sub    %edx,%eax
}
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	53                   	push   %ebx
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c34:	89 c3                	mov    %eax,%ebx
  800c36:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c39:	eb 06                	jmp    800c41 <strncmp+0x17>
		n--, p++, q++;
  800c3b:	83 c0 01             	add    $0x1,%eax
  800c3e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c41:	39 d8                	cmp    %ebx,%eax
  800c43:	74 15                	je     800c5a <strncmp+0x30>
  800c45:	0f b6 08             	movzbl (%eax),%ecx
  800c48:	84 c9                	test   %cl,%cl
  800c4a:	74 04                	je     800c50 <strncmp+0x26>
  800c4c:	3a 0a                	cmp    (%edx),%cl
  800c4e:	74 eb                	je     800c3b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c50:	0f b6 00             	movzbl (%eax),%eax
  800c53:	0f b6 12             	movzbl (%edx),%edx
  800c56:	29 d0                	sub    %edx,%eax
  800c58:	eb 05                	jmp    800c5f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c5a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	8b 45 08             	mov    0x8(%ebp),%eax
  800c68:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c6c:	eb 07                	jmp    800c75 <strchr+0x13>
		if (*s == c)
  800c6e:	38 ca                	cmp    %cl,%dl
  800c70:	74 0f                	je     800c81 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c72:	83 c0 01             	add    $0x1,%eax
  800c75:	0f b6 10             	movzbl (%eax),%edx
  800c78:	84 d2                	test   %dl,%dl
  800c7a:	75 f2                	jne    800c6e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	8b 45 08             	mov    0x8(%ebp),%eax
  800c89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c8d:	eb 03                	jmp    800c92 <strfind+0xf>
  800c8f:	83 c0 01             	add    $0x1,%eax
  800c92:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c95:	38 ca                	cmp    %cl,%dl
  800c97:	74 04                	je     800c9d <strfind+0x1a>
  800c99:	84 d2                	test   %dl,%dl
  800c9b:	75 f2                	jne    800c8f <strfind+0xc>
			break;
	return (char *) s;
}
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ca8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cab:	85 c9                	test   %ecx,%ecx
  800cad:	74 36                	je     800ce5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800caf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cb5:	75 28                	jne    800cdf <memset+0x40>
  800cb7:	f6 c1 03             	test   $0x3,%cl
  800cba:	75 23                	jne    800cdf <memset+0x40>
		c &= 0xFF;
  800cbc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cc0:	89 d3                	mov    %edx,%ebx
  800cc2:	c1 e3 08             	shl    $0x8,%ebx
  800cc5:	89 d6                	mov    %edx,%esi
  800cc7:	c1 e6 18             	shl    $0x18,%esi
  800cca:	89 d0                	mov    %edx,%eax
  800ccc:	c1 e0 10             	shl    $0x10,%eax
  800ccf:	09 f0                	or     %esi,%eax
  800cd1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cd3:	89 d8                	mov    %ebx,%eax
  800cd5:	09 d0                	or     %edx,%eax
  800cd7:	c1 e9 02             	shr    $0x2,%ecx
  800cda:	fc                   	cld    
  800cdb:	f3 ab                	rep stos %eax,%es:(%edi)
  800cdd:	eb 06                	jmp    800ce5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce2:	fc                   	cld    
  800ce3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ce5:	89 f8                	mov    %edi,%eax
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cfa:	39 c6                	cmp    %eax,%esi
  800cfc:	73 35                	jae    800d33 <memmove+0x47>
  800cfe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d01:	39 d0                	cmp    %edx,%eax
  800d03:	73 2e                	jae    800d33 <memmove+0x47>
		s += n;
		d += n;
  800d05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d08:	89 d6                	mov    %edx,%esi
  800d0a:	09 fe                	or     %edi,%esi
  800d0c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d12:	75 13                	jne    800d27 <memmove+0x3b>
  800d14:	f6 c1 03             	test   $0x3,%cl
  800d17:	75 0e                	jne    800d27 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d19:	83 ef 04             	sub    $0x4,%edi
  800d1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d1f:	c1 e9 02             	shr    $0x2,%ecx
  800d22:	fd                   	std    
  800d23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d25:	eb 09                	jmp    800d30 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d27:	83 ef 01             	sub    $0x1,%edi
  800d2a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d2d:	fd                   	std    
  800d2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d30:	fc                   	cld    
  800d31:	eb 1d                	jmp    800d50 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d33:	89 f2                	mov    %esi,%edx
  800d35:	09 c2                	or     %eax,%edx
  800d37:	f6 c2 03             	test   $0x3,%dl
  800d3a:	75 0f                	jne    800d4b <memmove+0x5f>
  800d3c:	f6 c1 03             	test   $0x3,%cl
  800d3f:	75 0a                	jne    800d4b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d41:	c1 e9 02             	shr    $0x2,%ecx
  800d44:	89 c7                	mov    %eax,%edi
  800d46:	fc                   	cld    
  800d47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d49:	eb 05                	jmp    800d50 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d4b:	89 c7                	mov    %eax,%edi
  800d4d:	fc                   	cld    
  800d4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d57:	ff 75 10             	pushl  0x10(%ebp)
  800d5a:	ff 75 0c             	pushl  0xc(%ebp)
  800d5d:	ff 75 08             	pushl  0x8(%ebp)
  800d60:	e8 87 ff ff ff       	call   800cec <memmove>
}
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    

00800d67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d72:	89 c6                	mov    %eax,%esi
  800d74:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d77:	eb 1a                	jmp    800d93 <memcmp+0x2c>
		if (*s1 != *s2)
  800d79:	0f b6 08             	movzbl (%eax),%ecx
  800d7c:	0f b6 1a             	movzbl (%edx),%ebx
  800d7f:	38 d9                	cmp    %bl,%cl
  800d81:	74 0a                	je     800d8d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d83:	0f b6 c1             	movzbl %cl,%eax
  800d86:	0f b6 db             	movzbl %bl,%ebx
  800d89:	29 d8                	sub    %ebx,%eax
  800d8b:	eb 0f                	jmp    800d9c <memcmp+0x35>
		s1++, s2++;
  800d8d:	83 c0 01             	add    $0x1,%eax
  800d90:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d93:	39 f0                	cmp    %esi,%eax
  800d95:	75 e2                	jne    800d79 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	53                   	push   %ebx
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800da7:	89 c1                	mov    %eax,%ecx
  800da9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800dac:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800db0:	eb 0a                	jmp    800dbc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800db2:	0f b6 10             	movzbl (%eax),%edx
  800db5:	39 da                	cmp    %ebx,%edx
  800db7:	74 07                	je     800dc0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800db9:	83 c0 01             	add    $0x1,%eax
  800dbc:	39 c8                	cmp    %ecx,%eax
  800dbe:	72 f2                	jb     800db2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dc0:	5b                   	pop    %ebx
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dcf:	eb 03                	jmp    800dd4 <strtol+0x11>
		s++;
  800dd1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dd4:	0f b6 01             	movzbl (%ecx),%eax
  800dd7:	3c 20                	cmp    $0x20,%al
  800dd9:	74 f6                	je     800dd1 <strtol+0xe>
  800ddb:	3c 09                	cmp    $0x9,%al
  800ddd:	74 f2                	je     800dd1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ddf:	3c 2b                	cmp    $0x2b,%al
  800de1:	75 0a                	jne    800ded <strtol+0x2a>
		s++;
  800de3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800de6:	bf 00 00 00 00       	mov    $0x0,%edi
  800deb:	eb 11                	jmp    800dfe <strtol+0x3b>
  800ded:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800df2:	3c 2d                	cmp    $0x2d,%al
  800df4:	75 08                	jne    800dfe <strtol+0x3b>
		s++, neg = 1;
  800df6:	83 c1 01             	add    $0x1,%ecx
  800df9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dfe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e04:	75 15                	jne    800e1b <strtol+0x58>
  800e06:	80 39 30             	cmpb   $0x30,(%ecx)
  800e09:	75 10                	jne    800e1b <strtol+0x58>
  800e0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e0f:	75 7c                	jne    800e8d <strtol+0xca>
		s += 2, base = 16;
  800e11:	83 c1 02             	add    $0x2,%ecx
  800e14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e19:	eb 16                	jmp    800e31 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e1b:	85 db                	test   %ebx,%ebx
  800e1d:	75 12                	jne    800e31 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e1f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e24:	80 39 30             	cmpb   $0x30,(%ecx)
  800e27:	75 08                	jne    800e31 <strtol+0x6e>
		s++, base = 8;
  800e29:	83 c1 01             	add    $0x1,%ecx
  800e2c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e31:	b8 00 00 00 00       	mov    $0x0,%eax
  800e36:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e39:	0f b6 11             	movzbl (%ecx),%edx
  800e3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e3f:	89 f3                	mov    %esi,%ebx
  800e41:	80 fb 09             	cmp    $0x9,%bl
  800e44:	77 08                	ja     800e4e <strtol+0x8b>
			dig = *s - '0';
  800e46:	0f be d2             	movsbl %dl,%edx
  800e49:	83 ea 30             	sub    $0x30,%edx
  800e4c:	eb 22                	jmp    800e70 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e4e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e51:	89 f3                	mov    %esi,%ebx
  800e53:	80 fb 19             	cmp    $0x19,%bl
  800e56:	77 08                	ja     800e60 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e58:	0f be d2             	movsbl %dl,%edx
  800e5b:	83 ea 57             	sub    $0x57,%edx
  800e5e:	eb 10                	jmp    800e70 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e60:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e63:	89 f3                	mov    %esi,%ebx
  800e65:	80 fb 19             	cmp    $0x19,%bl
  800e68:	77 16                	ja     800e80 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e6a:	0f be d2             	movsbl %dl,%edx
  800e6d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e70:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e73:	7d 0b                	jge    800e80 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e75:	83 c1 01             	add    $0x1,%ecx
  800e78:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e7c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e7e:	eb b9                	jmp    800e39 <strtol+0x76>

	if (endptr)
  800e80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e84:	74 0d                	je     800e93 <strtol+0xd0>
		*endptr = (char *) s;
  800e86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e89:	89 0e                	mov    %ecx,(%esi)
  800e8b:	eb 06                	jmp    800e93 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e8d:	85 db                	test   %ebx,%ebx
  800e8f:	74 98                	je     800e29 <strtol+0x66>
  800e91:	eb 9e                	jmp    800e31 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e93:	89 c2                	mov    %eax,%edx
  800e95:	f7 da                	neg    %edx
  800e97:	85 ff                	test   %edi,%edi
  800e99:	0f 45 c2             	cmovne %edx,%eax
}
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb2:	89 c3                	mov    %eax,%ebx
  800eb4:	89 c7                	mov    %eax,%edi
  800eb6:	89 c6                	mov    %eax,%esi
  800eb8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800eba:	5b                   	pop    %ebx
  800ebb:	5e                   	pop    %esi
  800ebc:	5f                   	pop    %edi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <sys_cgetc>:

int
sys_cgetc(void)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	57                   	push   %edi
  800ec3:	56                   	push   %esi
  800ec4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eca:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecf:	89 d1                	mov    %edx,%ecx
  800ed1:	89 d3                	mov    %edx,%ebx
  800ed3:	89 d7                	mov    %edx,%edi
  800ed5:	89 d6                	mov    %edx,%esi
  800ed7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800ee7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eec:	b8 03 00 00 00       	mov    $0x3,%eax
  800ef1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef4:	89 cb                	mov    %ecx,%ebx
  800ef6:	89 cf                	mov    %ecx,%edi
  800ef8:	89 ce                	mov    %ecx,%esi
  800efa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	7e 17                	jle    800f17 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f00:	83 ec 0c             	sub    $0xc,%esp
  800f03:	50                   	push   %eax
  800f04:	6a 03                	push   $0x3
  800f06:	68 1f 2b 80 00       	push   $0x802b1f
  800f0b:	6a 23                	push   $0x23
  800f0d:	68 3c 2b 80 00       	push   $0x802b3c
  800f12:	e8 b3 13 00 00       	call   8022ca <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1a:	5b                   	pop    %ebx
  800f1b:	5e                   	pop    %esi
  800f1c:	5f                   	pop    %edi
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	57                   	push   %edi
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f25:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800f2f:	89 d1                	mov    %edx,%ecx
  800f31:	89 d3                	mov    %edx,%ebx
  800f33:	89 d7                	mov    %edx,%edi
  800f35:	89 d6                	mov    %edx,%esi
  800f37:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f39:	5b                   	pop    %ebx
  800f3a:	5e                   	pop    %esi
  800f3b:	5f                   	pop    %edi
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    

00800f3e <sys_yield>:

void
sys_yield(void)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f44:	ba 00 00 00 00       	mov    $0x0,%edx
  800f49:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f4e:	89 d1                	mov    %edx,%ecx
  800f50:	89 d3                	mov    %edx,%ebx
  800f52:	89 d7                	mov    %edx,%edi
  800f54:	89 d6                	mov    %edx,%esi
  800f56:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	57                   	push   %edi
  800f61:	56                   	push   %esi
  800f62:	53                   	push   %ebx
  800f63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f66:	be 00 00 00 00       	mov    $0x0,%esi
  800f6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800f70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f73:	8b 55 08             	mov    0x8(%ebp),%edx
  800f76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f79:	89 f7                	mov    %esi,%edi
  800f7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	7e 17                	jle    800f98 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	50                   	push   %eax
  800f85:	6a 04                	push   $0x4
  800f87:	68 1f 2b 80 00       	push   $0x802b1f
  800f8c:	6a 23                	push   $0x23
  800f8e:	68 3c 2b 80 00       	push   $0x802b3c
  800f93:	e8 32 13 00 00       	call   8022ca <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9b:	5b                   	pop    %ebx
  800f9c:	5e                   	pop    %esi
  800f9d:	5f                   	pop    %edi
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	57                   	push   %edi
  800fa4:	56                   	push   %esi
  800fa5:	53                   	push   %ebx
  800fa6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa9:	b8 05 00 00 00       	mov    $0x5,%eax
  800fae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fba:	8b 75 18             	mov    0x18(%ebp),%esi
  800fbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	7e 17                	jle    800fda <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	50                   	push   %eax
  800fc7:	6a 05                	push   $0x5
  800fc9:	68 1f 2b 80 00       	push   $0x802b1f
  800fce:	6a 23                	push   $0x23
  800fd0:	68 3c 2b 80 00       	push   $0x802b3c
  800fd5:	e8 f0 12 00 00       	call   8022ca <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5f                   	pop    %edi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800feb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff0:	b8 06 00 00 00       	mov    $0x6,%eax
  800ff5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffb:	89 df                	mov    %ebx,%edi
  800ffd:	89 de                	mov    %ebx,%esi
  800fff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801001:	85 c0                	test   %eax,%eax
  801003:	7e 17                	jle    80101c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	50                   	push   %eax
  801009:	6a 06                	push   $0x6
  80100b:	68 1f 2b 80 00       	push   $0x802b1f
  801010:	6a 23                	push   $0x23
  801012:	68 3c 2b 80 00       	push   $0x802b3c
  801017:	e8 ae 12 00 00       	call   8022ca <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80101c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101f:	5b                   	pop    %ebx
  801020:	5e                   	pop    %esi
  801021:	5f                   	pop    %edi
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	57                   	push   %edi
  801028:	56                   	push   %esi
  801029:	53                   	push   %ebx
  80102a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801032:	b8 08 00 00 00       	mov    $0x8,%eax
  801037:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103a:	8b 55 08             	mov    0x8(%ebp),%edx
  80103d:	89 df                	mov    %ebx,%edi
  80103f:	89 de                	mov    %ebx,%esi
  801041:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801043:	85 c0                	test   %eax,%eax
  801045:	7e 17                	jle    80105e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	50                   	push   %eax
  80104b:	6a 08                	push   $0x8
  80104d:	68 1f 2b 80 00       	push   $0x802b1f
  801052:	6a 23                	push   $0x23
  801054:	68 3c 2b 80 00       	push   $0x802b3c
  801059:	e8 6c 12 00 00       	call   8022ca <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80105e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	53                   	push   %ebx
  80106c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801074:	b8 09 00 00 00       	mov    $0x9,%eax
  801079:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107c:	8b 55 08             	mov    0x8(%ebp),%edx
  80107f:	89 df                	mov    %ebx,%edi
  801081:	89 de                	mov    %ebx,%esi
  801083:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801085:	85 c0                	test   %eax,%eax
  801087:	7e 17                	jle    8010a0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	50                   	push   %eax
  80108d:	6a 09                	push   $0x9
  80108f:	68 1f 2b 80 00       	push   $0x802b1f
  801094:	6a 23                	push   $0x23
  801096:	68 3c 2b 80 00       	push   $0x802b3c
  80109b:	e8 2a 12 00 00       	call   8022ca <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a3:	5b                   	pop    %ebx
  8010a4:	5e                   	pop    %esi
  8010a5:	5f                   	pop    %edi
  8010a6:	5d                   	pop    %ebp
  8010a7:	c3                   	ret    

008010a8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	57                   	push   %edi
  8010ac:	56                   	push   %esi
  8010ad:	53                   	push   %ebx
  8010ae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010be:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c1:	89 df                	mov    %ebx,%edi
  8010c3:	89 de                	mov    %ebx,%esi
  8010c5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	7e 17                	jle    8010e2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	50                   	push   %eax
  8010cf:	6a 0a                	push   $0xa
  8010d1:	68 1f 2b 80 00       	push   $0x802b1f
  8010d6:	6a 23                	push   $0x23
  8010d8:	68 3c 2b 80 00       	push   $0x802b3c
  8010dd:	e8 e8 11 00 00       	call   8022ca <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	57                   	push   %edi
  8010ee:	56                   	push   %esi
  8010ef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f0:	be 00 00 00 00       	mov    $0x0,%esi
  8010f5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801100:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801103:	8b 7d 14             	mov    0x14(%ebp),%edi
  801106:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
  801113:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801116:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801120:	8b 55 08             	mov    0x8(%ebp),%edx
  801123:	89 cb                	mov    %ecx,%ebx
  801125:	89 cf                	mov    %ecx,%edi
  801127:	89 ce                	mov    %ecx,%esi
  801129:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80112b:	85 c0                	test   %eax,%eax
  80112d:	7e 17                	jle    801146 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	50                   	push   %eax
  801133:	6a 0d                	push   $0xd
  801135:	68 1f 2b 80 00       	push   $0x802b1f
  80113a:	6a 23                	push   $0x23
  80113c:	68 3c 2b 80 00       	push   $0x802b3c
  801141:	e8 84 11 00 00       	call   8022ca <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801146:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801149:	5b                   	pop    %ebx
  80114a:	5e                   	pop    %esi
  80114b:	5f                   	pop    %edi
  80114c:	5d                   	pop    %ebp
  80114d:	c3                   	ret    

0080114e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	57                   	push   %edi
  801152:	56                   	push   %esi
  801153:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801154:	ba 00 00 00 00       	mov    $0x0,%edx
  801159:	b8 0e 00 00 00       	mov    $0xe,%eax
  80115e:	89 d1                	mov    %edx,%ecx
  801160:	89 d3                	mov    %edx,%ebx
  801162:	89 d7                	mov    %edx,%edi
  801164:	89 d6                	mov    %edx,%esi
  801166:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5f                   	pop    %edi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	05 00 00 00 30       	add    $0x30000000,%eax
  801178:	c1 e8 0c             	shr    $0xc,%eax
}
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	05 00 00 00 30       	add    $0x30000000,%eax
  801188:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80118d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	c1 ea 16             	shr    $0x16,%edx
  8011a4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ab:	f6 c2 01             	test   $0x1,%dl
  8011ae:	74 11                	je     8011c1 <fd_alloc+0x2d>
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	c1 ea 0c             	shr    $0xc,%edx
  8011b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011bc:	f6 c2 01             	test   $0x1,%dl
  8011bf:	75 09                	jne    8011ca <fd_alloc+0x36>
			*fd_store = fd;
  8011c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c8:	eb 17                	jmp    8011e1 <fd_alloc+0x4d>
  8011ca:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011cf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d4:	75 c9                	jne    80119f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011d6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011dc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011e9:	83 f8 1f             	cmp    $0x1f,%eax
  8011ec:	77 36                	ja     801224 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ee:	c1 e0 0c             	shl    $0xc,%eax
  8011f1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	c1 ea 16             	shr    $0x16,%edx
  8011fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801202:	f6 c2 01             	test   $0x1,%dl
  801205:	74 24                	je     80122b <fd_lookup+0x48>
  801207:	89 c2                	mov    %eax,%edx
  801209:	c1 ea 0c             	shr    $0xc,%edx
  80120c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801213:	f6 c2 01             	test   $0x1,%dl
  801216:	74 1a                	je     801232 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801218:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121b:	89 02                	mov    %eax,(%edx)
	return 0;
  80121d:	b8 00 00 00 00       	mov    $0x0,%eax
  801222:	eb 13                	jmp    801237 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801224:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801229:	eb 0c                	jmp    801237 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801230:	eb 05                	jmp    801237 <fd_lookup+0x54>
  801232:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801242:	ba c8 2b 80 00       	mov    $0x802bc8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801247:	eb 13                	jmp    80125c <dev_lookup+0x23>
  801249:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80124c:	39 08                	cmp    %ecx,(%eax)
  80124e:	75 0c                	jne    80125c <dev_lookup+0x23>
			*dev = devtab[i];
  801250:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801253:	89 01                	mov    %eax,(%ecx)
			return 0;
  801255:	b8 00 00 00 00       	mov    $0x0,%eax
  80125a:	eb 2e                	jmp    80128a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80125c:	8b 02                	mov    (%edx),%eax
  80125e:	85 c0                	test   %eax,%eax
  801260:	75 e7                	jne    801249 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801262:	a1 18 40 80 00       	mov    0x804018,%eax
  801267:	8b 40 48             	mov    0x48(%eax),%eax
  80126a:	83 ec 04             	sub    $0x4,%esp
  80126d:	51                   	push   %ecx
  80126e:	50                   	push   %eax
  80126f:	68 4c 2b 80 00       	push   $0x802b4c
  801274:	e8 3c f3 ff ff       	call   8005b5 <cprintf>
	*dev = 0;
  801279:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80128a:	c9                   	leave  
  80128b:	c3                   	ret    

0080128c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	56                   	push   %esi
  801290:	53                   	push   %ebx
  801291:	83 ec 10             	sub    $0x10,%esp
  801294:	8b 75 08             	mov    0x8(%ebp),%esi
  801297:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012a4:	c1 e8 0c             	shr    $0xc,%eax
  8012a7:	50                   	push   %eax
  8012a8:	e8 36 ff ff ff       	call   8011e3 <fd_lookup>
  8012ad:	83 c4 08             	add    $0x8,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 05                	js     8012b9 <fd_close+0x2d>
	    || fd != fd2)
  8012b4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012b7:	74 0c                	je     8012c5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012b9:	84 db                	test   %bl,%bl
  8012bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c0:	0f 44 c2             	cmove  %edx,%eax
  8012c3:	eb 41                	jmp    801306 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c5:	83 ec 08             	sub    $0x8,%esp
  8012c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cb:	50                   	push   %eax
  8012cc:	ff 36                	pushl  (%esi)
  8012ce:	e8 66 ff ff ff       	call   801239 <dev_lookup>
  8012d3:	89 c3                	mov    %eax,%ebx
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 1a                	js     8012f6 <fd_close+0x6a>
		if (dev->dev_close)
  8012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012df:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012e2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	74 0b                	je     8012f6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012eb:	83 ec 0c             	sub    $0xc,%esp
  8012ee:	56                   	push   %esi
  8012ef:	ff d0                	call   *%eax
  8012f1:	89 c3                	mov    %eax,%ebx
  8012f3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	56                   	push   %esi
  8012fa:	6a 00                	push   $0x0
  8012fc:	e8 e1 fc ff ff       	call   800fe2 <sys_page_unmap>
	return r;
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	89 d8                	mov    %ebx,%eax
}
  801306:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801309:	5b                   	pop    %ebx
  80130a:	5e                   	pop    %esi
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    

0080130d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801313:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801316:	50                   	push   %eax
  801317:	ff 75 08             	pushl  0x8(%ebp)
  80131a:	e8 c4 fe ff ff       	call   8011e3 <fd_lookup>
  80131f:	83 c4 08             	add    $0x8,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 10                	js     801336 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	6a 01                	push   $0x1
  80132b:	ff 75 f4             	pushl  -0xc(%ebp)
  80132e:	e8 59 ff ff ff       	call   80128c <fd_close>
  801333:	83 c4 10             	add    $0x10,%esp
}
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <close_all>:

void
close_all(void)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80133f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801344:	83 ec 0c             	sub    $0xc,%esp
  801347:	53                   	push   %ebx
  801348:	e8 c0 ff ff ff       	call   80130d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80134d:	83 c3 01             	add    $0x1,%ebx
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	83 fb 20             	cmp    $0x20,%ebx
  801356:	75 ec                	jne    801344 <close_all+0xc>
		close(i);
}
  801358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	57                   	push   %edi
  801361:	56                   	push   %esi
  801362:	53                   	push   %ebx
  801363:	83 ec 2c             	sub    $0x2c,%esp
  801366:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801369:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	ff 75 08             	pushl  0x8(%ebp)
  801370:	e8 6e fe ff ff       	call   8011e3 <fd_lookup>
  801375:	83 c4 08             	add    $0x8,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	0f 88 c1 00 00 00    	js     801441 <dup+0xe4>
		return r;
	close(newfdnum);
  801380:	83 ec 0c             	sub    $0xc,%esp
  801383:	56                   	push   %esi
  801384:	e8 84 ff ff ff       	call   80130d <close>

	newfd = INDEX2FD(newfdnum);
  801389:	89 f3                	mov    %esi,%ebx
  80138b:	c1 e3 0c             	shl    $0xc,%ebx
  80138e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801394:	83 c4 04             	add    $0x4,%esp
  801397:	ff 75 e4             	pushl  -0x1c(%ebp)
  80139a:	e8 de fd ff ff       	call   80117d <fd2data>
  80139f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013a1:	89 1c 24             	mov    %ebx,(%esp)
  8013a4:	e8 d4 fd ff ff       	call   80117d <fd2data>
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013af:	89 f8                	mov    %edi,%eax
  8013b1:	c1 e8 16             	shr    $0x16,%eax
  8013b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013bb:	a8 01                	test   $0x1,%al
  8013bd:	74 37                	je     8013f6 <dup+0x99>
  8013bf:	89 f8                	mov    %edi,%eax
  8013c1:	c1 e8 0c             	shr    $0xc,%eax
  8013c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013cb:	f6 c2 01             	test   $0x1,%dl
  8013ce:	74 26                	je     8013f6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d7:	83 ec 0c             	sub    $0xc,%esp
  8013da:	25 07 0e 00 00       	and    $0xe07,%eax
  8013df:	50                   	push   %eax
  8013e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e3:	6a 00                	push   $0x0
  8013e5:	57                   	push   %edi
  8013e6:	6a 00                	push   $0x0
  8013e8:	e8 b3 fb ff ff       	call   800fa0 <sys_page_map>
  8013ed:	89 c7                	mov    %eax,%edi
  8013ef:	83 c4 20             	add    $0x20,%esp
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 2e                	js     801424 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013f9:	89 d0                	mov    %edx,%eax
  8013fb:	c1 e8 0c             	shr    $0xc,%eax
  8013fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801405:	83 ec 0c             	sub    $0xc,%esp
  801408:	25 07 0e 00 00       	and    $0xe07,%eax
  80140d:	50                   	push   %eax
  80140e:	53                   	push   %ebx
  80140f:	6a 00                	push   $0x0
  801411:	52                   	push   %edx
  801412:	6a 00                	push   $0x0
  801414:	e8 87 fb ff ff       	call   800fa0 <sys_page_map>
  801419:	89 c7                	mov    %eax,%edi
  80141b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80141e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801420:	85 ff                	test   %edi,%edi
  801422:	79 1d                	jns    801441 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	53                   	push   %ebx
  801428:	6a 00                	push   $0x0
  80142a:	e8 b3 fb ff ff       	call   800fe2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80142f:	83 c4 08             	add    $0x8,%esp
  801432:	ff 75 d4             	pushl  -0x2c(%ebp)
  801435:	6a 00                	push   $0x0
  801437:	e8 a6 fb ff ff       	call   800fe2 <sys_page_unmap>
	return r;
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	89 f8                	mov    %edi,%eax
}
  801441:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801444:	5b                   	pop    %ebx
  801445:	5e                   	pop    %esi
  801446:	5f                   	pop    %edi
  801447:	5d                   	pop    %ebp
  801448:	c3                   	ret    

00801449 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	53                   	push   %ebx
  80144d:	83 ec 14             	sub    $0x14,%esp
  801450:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801453:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	53                   	push   %ebx
  801458:	e8 86 fd ff ff       	call   8011e3 <fd_lookup>
  80145d:	83 c4 08             	add    $0x8,%esp
  801460:	89 c2                	mov    %eax,%edx
  801462:	85 c0                	test   %eax,%eax
  801464:	78 6d                	js     8014d3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801470:	ff 30                	pushl  (%eax)
  801472:	e8 c2 fd ff ff       	call   801239 <dev_lookup>
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 4c                	js     8014ca <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80147e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801481:	8b 42 08             	mov    0x8(%edx),%eax
  801484:	83 e0 03             	and    $0x3,%eax
  801487:	83 f8 01             	cmp    $0x1,%eax
  80148a:	75 21                	jne    8014ad <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80148c:	a1 18 40 80 00       	mov    0x804018,%eax
  801491:	8b 40 48             	mov    0x48(%eax),%eax
  801494:	83 ec 04             	sub    $0x4,%esp
  801497:	53                   	push   %ebx
  801498:	50                   	push   %eax
  801499:	68 8d 2b 80 00       	push   $0x802b8d
  80149e:	e8 12 f1 ff ff       	call   8005b5 <cprintf>
		return -E_INVAL;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ab:	eb 26                	jmp    8014d3 <read+0x8a>
	}
	if (!dev->dev_read)
  8014ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b0:	8b 40 08             	mov    0x8(%eax),%eax
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	74 17                	je     8014ce <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014b7:	83 ec 04             	sub    $0x4,%esp
  8014ba:	ff 75 10             	pushl  0x10(%ebp)
  8014bd:	ff 75 0c             	pushl  0xc(%ebp)
  8014c0:	52                   	push   %edx
  8014c1:	ff d0                	call   *%eax
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	eb 09                	jmp    8014d3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ca:	89 c2                	mov    %eax,%edx
  8014cc:	eb 05                	jmp    8014d3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014d3:	89 d0                	mov    %edx,%eax
  8014d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    

008014da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	57                   	push   %edi
  8014de:	56                   	push   %esi
  8014df:	53                   	push   %ebx
  8014e0:	83 ec 0c             	sub    $0xc,%esp
  8014e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ee:	eb 21                	jmp    801511 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f0:	83 ec 04             	sub    $0x4,%esp
  8014f3:	89 f0                	mov    %esi,%eax
  8014f5:	29 d8                	sub    %ebx,%eax
  8014f7:	50                   	push   %eax
  8014f8:	89 d8                	mov    %ebx,%eax
  8014fa:	03 45 0c             	add    0xc(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	57                   	push   %edi
  8014ff:	e8 45 ff ff ff       	call   801449 <read>
		if (m < 0)
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 10                	js     80151b <readn+0x41>
			return m;
		if (m == 0)
  80150b:	85 c0                	test   %eax,%eax
  80150d:	74 0a                	je     801519 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150f:	01 c3                	add    %eax,%ebx
  801511:	39 f3                	cmp    %esi,%ebx
  801513:	72 db                	jb     8014f0 <readn+0x16>
  801515:	89 d8                	mov    %ebx,%eax
  801517:	eb 02                	jmp    80151b <readn+0x41>
  801519:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80151b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80151e:	5b                   	pop    %ebx
  80151f:	5e                   	pop    %esi
  801520:	5f                   	pop    %edi
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 14             	sub    $0x14,%esp
  80152a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	53                   	push   %ebx
  801532:	e8 ac fc ff ff       	call   8011e3 <fd_lookup>
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 68                	js     8015a8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	ff 30                	pushl  (%eax)
  80154c:	e8 e8 fc ff ff       	call   801239 <dev_lookup>
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 47                	js     80159f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155f:	75 21                	jne    801582 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801561:	a1 18 40 80 00       	mov    0x804018,%eax
  801566:	8b 40 48             	mov    0x48(%eax),%eax
  801569:	83 ec 04             	sub    $0x4,%esp
  80156c:	53                   	push   %ebx
  80156d:	50                   	push   %eax
  80156e:	68 a9 2b 80 00       	push   $0x802ba9
  801573:	e8 3d f0 ff ff       	call   8005b5 <cprintf>
		return -E_INVAL;
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801580:	eb 26                	jmp    8015a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801585:	8b 52 0c             	mov    0xc(%edx),%edx
  801588:	85 d2                	test   %edx,%edx
  80158a:	74 17                	je     8015a3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80158c:	83 ec 04             	sub    $0x4,%esp
  80158f:	ff 75 10             	pushl  0x10(%ebp)
  801592:	ff 75 0c             	pushl  0xc(%ebp)
  801595:	50                   	push   %eax
  801596:	ff d2                	call   *%edx
  801598:	89 c2                	mov    %eax,%edx
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	eb 09                	jmp    8015a8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159f:	89 c2                	mov    %eax,%edx
  8015a1:	eb 05                	jmp    8015a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015a8:	89 d0                	mov    %edx,%eax
  8015aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <seek>:

int
seek(int fdnum, off_t offset)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	ff 75 08             	pushl  0x8(%ebp)
  8015bc:	e8 22 fc ff ff       	call   8011e3 <fd_lookup>
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 0e                	js     8015d6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ce:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 14             	sub    $0x14,%esp
  8015df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	53                   	push   %ebx
  8015e7:	e8 f7 fb ff ff       	call   8011e3 <fd_lookup>
  8015ec:	83 c4 08             	add    $0x8,%esp
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 65                	js     80165a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ff:	ff 30                	pushl  (%eax)
  801601:	e8 33 fc ff ff       	call   801239 <dev_lookup>
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 44                	js     801651 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801610:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801614:	75 21                	jne    801637 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801616:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161b:	8b 40 48             	mov    0x48(%eax),%eax
  80161e:	83 ec 04             	sub    $0x4,%esp
  801621:	53                   	push   %ebx
  801622:	50                   	push   %eax
  801623:	68 6c 2b 80 00       	push   $0x802b6c
  801628:	e8 88 ef ff ff       	call   8005b5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801635:	eb 23                	jmp    80165a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801637:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163a:	8b 52 18             	mov    0x18(%edx),%edx
  80163d:	85 d2                	test   %edx,%edx
  80163f:	74 14                	je     801655 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	ff 75 0c             	pushl  0xc(%ebp)
  801647:	50                   	push   %eax
  801648:	ff d2                	call   *%edx
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	eb 09                	jmp    80165a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801651:	89 c2                	mov    %eax,%edx
  801653:	eb 05                	jmp    80165a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801655:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80165a:	89 d0                	mov    %edx,%eax
  80165c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	53                   	push   %ebx
  801665:	83 ec 14             	sub    $0x14,%esp
  801668:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	ff 75 08             	pushl  0x8(%ebp)
  801672:	e8 6c fb ff ff       	call   8011e3 <fd_lookup>
  801677:	83 c4 08             	add    $0x8,%esp
  80167a:	89 c2                	mov    %eax,%edx
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 58                	js     8016d8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801686:	50                   	push   %eax
  801687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168a:	ff 30                	pushl  (%eax)
  80168c:	e8 a8 fb ff ff       	call   801239 <dev_lookup>
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	85 c0                	test   %eax,%eax
  801696:	78 37                	js     8016cf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80169f:	74 32                	je     8016d3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016a1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016a4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ab:	00 00 00 
	stat->st_isdir = 0;
  8016ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b5:	00 00 00 
	stat->st_dev = dev;
  8016b8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	53                   	push   %ebx
  8016c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016c5:	ff 50 14             	call   *0x14(%eax)
  8016c8:	89 c2                	mov    %eax,%edx
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	eb 09                	jmp    8016d8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cf:	89 c2                	mov    %eax,%edx
  8016d1:	eb 05                	jmp    8016d8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016d8:	89 d0                	mov    %edx,%eax
  8016da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	56                   	push   %esi
  8016e3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016e4:	83 ec 08             	sub    $0x8,%esp
  8016e7:	6a 00                	push   $0x0
  8016e9:	ff 75 08             	pushl  0x8(%ebp)
  8016ec:	e8 ef 01 00 00       	call   8018e0 <open>
  8016f1:	89 c3                	mov    %eax,%ebx
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 1b                	js     801715 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	ff 75 0c             	pushl  0xc(%ebp)
  801700:	50                   	push   %eax
  801701:	e8 5b ff ff ff       	call   801661 <fstat>
  801706:	89 c6                	mov    %eax,%esi
	close(fd);
  801708:	89 1c 24             	mov    %ebx,(%esp)
  80170b:	e8 fd fb ff ff       	call   80130d <close>
	return r;
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	89 f0                	mov    %esi,%eax
}
  801715:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801718:	5b                   	pop    %ebx
  801719:	5e                   	pop    %esi
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	89 c6                	mov    %eax,%esi
  801723:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801725:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  80172c:	75 12                	jne    801740 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80172e:	83 ec 0c             	sub    $0xc,%esp
  801731:	6a 01                	push   $0x1
  801733:	e8 9d 0c 00 00       	call   8023d5 <ipc_find_env>
  801738:	a3 10 40 80 00       	mov    %eax,0x804010
  80173d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801740:	6a 07                	push   $0x7
  801742:	68 00 50 80 00       	push   $0x805000
  801747:	56                   	push   %esi
  801748:	ff 35 10 40 80 00    	pushl  0x804010
  80174e:	e8 33 0c 00 00       	call   802386 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801753:	83 c4 0c             	add    $0xc,%esp
  801756:	6a 00                	push   $0x0
  801758:	53                   	push   %ebx
  801759:	6a 00                	push   $0x0
  80175b:	e8 b0 0b 00 00       	call   802310 <ipc_recv>
}
  801760:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801763:	5b                   	pop    %ebx
  801764:	5e                   	pop    %esi
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80176d:	8b 45 08             	mov    0x8(%ebp),%eax
  801770:	8b 40 0c             	mov    0xc(%eax),%eax
  801773:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801778:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801780:	ba 00 00 00 00       	mov    $0x0,%edx
  801785:	b8 02 00 00 00       	mov    $0x2,%eax
  80178a:	e8 8d ff ff ff       	call   80171c <fsipc>
}
  80178f:	c9                   	leave  
  801790:	c3                   	ret    

00801791 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801797:	8b 45 08             	mov    0x8(%ebp),%eax
  80179a:	8b 40 0c             	mov    0xc(%eax),%eax
  80179d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ac:	e8 6b ff ff ff       	call   80171c <fsipc>
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d2:	e8 45 ff ff ff       	call   80171c <fsipc>
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	78 2c                	js     801807 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017db:	83 ec 08             	sub    $0x8,%esp
  8017de:	68 00 50 80 00       	push   $0x805000
  8017e3:	53                   	push   %ebx
  8017e4:	e8 71 f3 ff ff       	call   800b5a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017e9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f4:	a1 84 50 80 00       	mov    0x805084,%eax
  8017f9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180a:	c9                   	leave  
  80180b:	c3                   	ret    

0080180c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	53                   	push   %ebx
  801810:	83 ec 08             	sub    $0x8,%esp
  801813:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801816:	8b 55 08             	mov    0x8(%ebp),%edx
  801819:	8b 52 0c             	mov    0xc(%edx),%edx
  80181c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801822:	a3 04 50 80 00       	mov    %eax,0x805004
  801827:	3d 08 50 80 00       	cmp    $0x805008,%eax
  80182c:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801831:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801834:	53                   	push   %ebx
  801835:	ff 75 0c             	pushl  0xc(%ebp)
  801838:	68 08 50 80 00       	push   $0x805008
  80183d:	e8 aa f4 ff ff       	call   800cec <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801842:	ba 00 00 00 00       	mov    $0x0,%edx
  801847:	b8 04 00 00 00       	mov    $0x4,%eax
  80184c:	e8 cb fe ff ff       	call   80171c <fsipc>
  801851:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801854:	85 c0                	test   %eax,%eax
  801856:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	8b 40 0c             	mov    0xc(%eax),%eax
  80186c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801871:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801877:	ba 00 00 00 00       	mov    $0x0,%edx
  80187c:	b8 03 00 00 00       	mov    $0x3,%eax
  801881:	e8 96 fe ff ff       	call   80171c <fsipc>
  801886:	89 c3                	mov    %eax,%ebx
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 4b                	js     8018d7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80188c:	39 c6                	cmp    %eax,%esi
  80188e:	73 16                	jae    8018a6 <devfile_read+0x48>
  801890:	68 dc 2b 80 00       	push   $0x802bdc
  801895:	68 e3 2b 80 00       	push   $0x802be3
  80189a:	6a 7c                	push   $0x7c
  80189c:	68 f8 2b 80 00       	push   $0x802bf8
  8018a1:	e8 24 0a 00 00       	call   8022ca <_panic>
	assert(r <= PGSIZE);
  8018a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ab:	7e 16                	jle    8018c3 <devfile_read+0x65>
  8018ad:	68 03 2c 80 00       	push   $0x802c03
  8018b2:	68 e3 2b 80 00       	push   $0x802be3
  8018b7:	6a 7d                	push   $0x7d
  8018b9:	68 f8 2b 80 00       	push   $0x802bf8
  8018be:	e8 07 0a 00 00       	call   8022ca <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c3:	83 ec 04             	sub    $0x4,%esp
  8018c6:	50                   	push   %eax
  8018c7:	68 00 50 80 00       	push   $0x805000
  8018cc:	ff 75 0c             	pushl  0xc(%ebp)
  8018cf:	e8 18 f4 ff ff       	call   800cec <memmove>
	return r;
  8018d4:	83 c4 10             	add    $0x10,%esp
}
  8018d7:	89 d8                	mov    %ebx,%eax
  8018d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018dc:	5b                   	pop    %ebx
  8018dd:	5e                   	pop    %esi
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	53                   	push   %ebx
  8018e4:	83 ec 20             	sub    $0x20,%esp
  8018e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ea:	53                   	push   %ebx
  8018eb:	e8 31 f2 ff ff       	call   800b21 <strlen>
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018f8:	7f 67                	jg     801961 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018fa:	83 ec 0c             	sub    $0xc,%esp
  8018fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801900:	50                   	push   %eax
  801901:	e8 8e f8 ff ff       	call   801194 <fd_alloc>
  801906:	83 c4 10             	add    $0x10,%esp
		return r;
  801909:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190b:	85 c0                	test   %eax,%eax
  80190d:	78 57                	js     801966 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	53                   	push   %ebx
  801913:	68 00 50 80 00       	push   $0x805000
  801918:	e8 3d f2 ff ff       	call   800b5a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80191d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801920:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801925:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801928:	b8 01 00 00 00       	mov    $0x1,%eax
  80192d:	e8 ea fd ff ff       	call   80171c <fsipc>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	79 14                	jns    80194f <open+0x6f>
		fd_close(fd, 0);
  80193b:	83 ec 08             	sub    $0x8,%esp
  80193e:	6a 00                	push   $0x0
  801940:	ff 75 f4             	pushl  -0xc(%ebp)
  801943:	e8 44 f9 ff ff       	call   80128c <fd_close>
		return r;
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	89 da                	mov    %ebx,%edx
  80194d:	eb 17                	jmp    801966 <open+0x86>
	}

	return fd2num(fd);
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	ff 75 f4             	pushl  -0xc(%ebp)
  801955:	e8 13 f8 ff ff       	call   80116d <fd2num>
  80195a:	89 c2                	mov    %eax,%edx
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	eb 05                	jmp    801966 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801961:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801966:	89 d0                	mov    %edx,%eax
  801968:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    

0080196d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801973:	ba 00 00 00 00       	mov    $0x0,%edx
  801978:	b8 08 00 00 00       	mov    $0x8,%eax
  80197d:	e8 9a fd ff ff       	call   80171c <fsipc>
}
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	56                   	push   %esi
  801988:	53                   	push   %ebx
  801989:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80198c:	83 ec 0c             	sub    $0xc,%esp
  80198f:	ff 75 08             	pushl  0x8(%ebp)
  801992:	e8 e6 f7 ff ff       	call   80117d <fd2data>
  801997:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801999:	83 c4 08             	add    $0x8,%esp
  80199c:	68 0f 2c 80 00       	push   $0x802c0f
  8019a1:	53                   	push   %ebx
  8019a2:	e8 b3 f1 ff ff       	call   800b5a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019a7:	8b 46 04             	mov    0x4(%esi),%eax
  8019aa:	2b 06                	sub    (%esi),%eax
  8019ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b9:	00 00 00 
	stat->st_dev = &devpipe;
  8019bc:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019c3:	30 80 00 
	return 0;
}
  8019c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ce:	5b                   	pop    %ebx
  8019cf:	5e                   	pop    %esi
  8019d0:	5d                   	pop    %ebp
  8019d1:	c3                   	ret    

008019d2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	53                   	push   %ebx
  8019d6:	83 ec 0c             	sub    $0xc,%esp
  8019d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019dc:	53                   	push   %ebx
  8019dd:	6a 00                	push   $0x0
  8019df:	e8 fe f5 ff ff       	call   800fe2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019e4:	89 1c 24             	mov    %ebx,(%esp)
  8019e7:	e8 91 f7 ff ff       	call   80117d <fd2data>
  8019ec:	83 c4 08             	add    $0x8,%esp
  8019ef:	50                   	push   %eax
  8019f0:	6a 00                	push   $0x0
  8019f2:	e8 eb f5 ff ff       	call   800fe2 <sys_page_unmap>
}
  8019f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	57                   	push   %edi
  801a00:	56                   	push   %esi
  801a01:	53                   	push   %ebx
  801a02:	83 ec 1c             	sub    $0x1c,%esp
  801a05:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a08:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a0a:	a1 18 40 80 00       	mov    0x804018,%eax
  801a0f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	ff 75 e0             	pushl  -0x20(%ebp)
  801a18:	e8 f1 09 00 00       	call   80240e <pageref>
  801a1d:	89 c3                	mov    %eax,%ebx
  801a1f:	89 3c 24             	mov    %edi,(%esp)
  801a22:	e8 e7 09 00 00       	call   80240e <pageref>
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	39 c3                	cmp    %eax,%ebx
  801a2c:	0f 94 c1             	sete   %cl
  801a2f:	0f b6 c9             	movzbl %cl,%ecx
  801a32:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a35:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801a3b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a3e:	39 ce                	cmp    %ecx,%esi
  801a40:	74 1b                	je     801a5d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a42:	39 c3                	cmp    %eax,%ebx
  801a44:	75 c4                	jne    801a0a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a46:	8b 42 58             	mov    0x58(%edx),%eax
  801a49:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a4c:	50                   	push   %eax
  801a4d:	56                   	push   %esi
  801a4e:	68 16 2c 80 00       	push   $0x802c16
  801a53:	e8 5d eb ff ff       	call   8005b5 <cprintf>
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	eb ad                	jmp    801a0a <_pipeisclosed+0xe>
	}
}
  801a5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a63:	5b                   	pop    %ebx
  801a64:	5e                   	pop    %esi
  801a65:	5f                   	pop    %edi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	57                   	push   %edi
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 28             	sub    $0x28,%esp
  801a71:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a74:	56                   	push   %esi
  801a75:	e8 03 f7 ff ff       	call   80117d <fd2data>
  801a7a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	bf 00 00 00 00       	mov    $0x0,%edi
  801a84:	eb 4b                	jmp    801ad1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a86:	89 da                	mov    %ebx,%edx
  801a88:	89 f0                	mov    %esi,%eax
  801a8a:	e8 6d ff ff ff       	call   8019fc <_pipeisclosed>
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	75 48                	jne    801adb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a93:	e8 a6 f4 ff ff       	call   800f3e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a98:	8b 43 04             	mov    0x4(%ebx),%eax
  801a9b:	8b 0b                	mov    (%ebx),%ecx
  801a9d:	8d 51 20             	lea    0x20(%ecx),%edx
  801aa0:	39 d0                	cmp    %edx,%eax
  801aa2:	73 e2                	jae    801a86 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aab:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aae:	89 c2                	mov    %eax,%edx
  801ab0:	c1 fa 1f             	sar    $0x1f,%edx
  801ab3:	89 d1                	mov    %edx,%ecx
  801ab5:	c1 e9 1b             	shr    $0x1b,%ecx
  801ab8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801abb:	83 e2 1f             	and    $0x1f,%edx
  801abe:	29 ca                	sub    %ecx,%edx
  801ac0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ac4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ac8:	83 c0 01             	add    $0x1,%eax
  801acb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ace:	83 c7 01             	add    $0x1,%edi
  801ad1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ad4:	75 c2                	jne    801a98 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ad6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad9:	eb 05                	jmp    801ae0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801adb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae3:	5b                   	pop    %ebx
  801ae4:	5e                   	pop    %esi
  801ae5:	5f                   	pop    %edi
  801ae6:	5d                   	pop    %ebp
  801ae7:	c3                   	ret    

00801ae8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	57                   	push   %edi
  801aec:	56                   	push   %esi
  801aed:	53                   	push   %ebx
  801aee:	83 ec 18             	sub    $0x18,%esp
  801af1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801af4:	57                   	push   %edi
  801af5:	e8 83 f6 ff ff       	call   80117d <fd2data>
  801afa:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b04:	eb 3d                	jmp    801b43 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b06:	85 db                	test   %ebx,%ebx
  801b08:	74 04                	je     801b0e <devpipe_read+0x26>
				return i;
  801b0a:	89 d8                	mov    %ebx,%eax
  801b0c:	eb 44                	jmp    801b52 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b0e:	89 f2                	mov    %esi,%edx
  801b10:	89 f8                	mov    %edi,%eax
  801b12:	e8 e5 fe ff ff       	call   8019fc <_pipeisclosed>
  801b17:	85 c0                	test   %eax,%eax
  801b19:	75 32                	jne    801b4d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b1b:	e8 1e f4 ff ff       	call   800f3e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b20:	8b 06                	mov    (%esi),%eax
  801b22:	3b 46 04             	cmp    0x4(%esi),%eax
  801b25:	74 df                	je     801b06 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b27:	99                   	cltd   
  801b28:	c1 ea 1b             	shr    $0x1b,%edx
  801b2b:	01 d0                	add    %edx,%eax
  801b2d:	83 e0 1f             	and    $0x1f,%eax
  801b30:	29 d0                	sub    %edx,%eax
  801b32:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b3d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b40:	83 c3 01             	add    $0x1,%ebx
  801b43:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b46:	75 d8                	jne    801b20 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b48:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4b:	eb 05                	jmp    801b52 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b4d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5f                   	pop    %edi
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    

00801b5a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	56                   	push   %esi
  801b5e:	53                   	push   %ebx
  801b5f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b65:	50                   	push   %eax
  801b66:	e8 29 f6 ff ff       	call   801194 <fd_alloc>
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	89 c2                	mov    %eax,%edx
  801b70:	85 c0                	test   %eax,%eax
  801b72:	0f 88 2c 01 00 00    	js     801ca4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b78:	83 ec 04             	sub    $0x4,%esp
  801b7b:	68 07 04 00 00       	push   $0x407
  801b80:	ff 75 f4             	pushl  -0xc(%ebp)
  801b83:	6a 00                	push   $0x0
  801b85:	e8 d3 f3 ff ff       	call   800f5d <sys_page_alloc>
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	89 c2                	mov    %eax,%edx
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	0f 88 0d 01 00 00    	js     801ca4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b97:	83 ec 0c             	sub    $0xc,%esp
  801b9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b9d:	50                   	push   %eax
  801b9e:	e8 f1 f5 ff ff       	call   801194 <fd_alloc>
  801ba3:	89 c3                	mov    %eax,%ebx
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	0f 88 e2 00 00 00    	js     801c92 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb0:	83 ec 04             	sub    $0x4,%esp
  801bb3:	68 07 04 00 00       	push   $0x407
  801bb8:	ff 75 f0             	pushl  -0x10(%ebp)
  801bbb:	6a 00                	push   $0x0
  801bbd:	e8 9b f3 ff ff       	call   800f5d <sys_page_alloc>
  801bc2:	89 c3                	mov    %eax,%ebx
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	0f 88 c3 00 00 00    	js     801c92 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bcf:	83 ec 0c             	sub    $0xc,%esp
  801bd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd5:	e8 a3 f5 ff ff       	call   80117d <fd2data>
  801bda:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdc:	83 c4 0c             	add    $0xc,%esp
  801bdf:	68 07 04 00 00       	push   $0x407
  801be4:	50                   	push   %eax
  801be5:	6a 00                	push   $0x0
  801be7:	e8 71 f3 ff ff       	call   800f5d <sys_page_alloc>
  801bec:	89 c3                	mov    %eax,%ebx
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	0f 88 89 00 00 00    	js     801c82 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf9:	83 ec 0c             	sub    $0xc,%esp
  801bfc:	ff 75 f0             	pushl  -0x10(%ebp)
  801bff:	e8 79 f5 ff ff       	call   80117d <fd2data>
  801c04:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c0b:	50                   	push   %eax
  801c0c:	6a 00                	push   $0x0
  801c0e:	56                   	push   %esi
  801c0f:	6a 00                	push   $0x0
  801c11:	e8 8a f3 ff ff       	call   800fa0 <sys_page_map>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	83 c4 20             	add    $0x20,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 55                	js     801c74 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c1f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c28:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c34:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c3d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c42:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c49:	83 ec 0c             	sub    $0xc,%esp
  801c4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4f:	e8 19 f5 ff ff       	call   80116d <fd2num>
  801c54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c57:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c59:	83 c4 04             	add    $0x4,%esp
  801c5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c5f:	e8 09 f5 ff ff       	call   80116d <fd2num>
  801c64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c67:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c72:	eb 30                	jmp    801ca4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c74:	83 ec 08             	sub    $0x8,%esp
  801c77:	56                   	push   %esi
  801c78:	6a 00                	push   $0x0
  801c7a:	e8 63 f3 ff ff       	call   800fe2 <sys_page_unmap>
  801c7f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c82:	83 ec 08             	sub    $0x8,%esp
  801c85:	ff 75 f0             	pushl  -0x10(%ebp)
  801c88:	6a 00                	push   $0x0
  801c8a:	e8 53 f3 ff ff       	call   800fe2 <sys_page_unmap>
  801c8f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c92:	83 ec 08             	sub    $0x8,%esp
  801c95:	ff 75 f4             	pushl  -0xc(%ebp)
  801c98:	6a 00                	push   $0x0
  801c9a:	e8 43 f3 ff ff       	call   800fe2 <sys_page_unmap>
  801c9f:	83 c4 10             	add    $0x10,%esp
  801ca2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ca4:	89 d0                	mov    %edx,%eax
  801ca6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca9:	5b                   	pop    %ebx
  801caa:	5e                   	pop    %esi
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    

00801cad <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb6:	50                   	push   %eax
  801cb7:	ff 75 08             	pushl  0x8(%ebp)
  801cba:	e8 24 f5 ff ff       	call   8011e3 <fd_lookup>
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	78 18                	js     801cde <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cc6:	83 ec 0c             	sub    $0xc,%esp
  801cc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccc:	e8 ac f4 ff ff       	call   80117d <fd2data>
	return _pipeisclosed(fd, p);
  801cd1:	89 c2                	mov    %eax,%edx
  801cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd6:	e8 21 fd ff ff       	call   8019fc <_pipeisclosed>
  801cdb:	83 c4 10             	add    $0x10,%esp
}
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ce6:	68 2e 2c 80 00       	push   $0x802c2e
  801ceb:	ff 75 0c             	pushl  0xc(%ebp)
  801cee:	e8 67 ee ff ff       	call   800b5a <strcpy>
	return 0;
}
  801cf3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	53                   	push   %ebx
  801cfe:	83 ec 10             	sub    $0x10,%esp
  801d01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d04:	53                   	push   %ebx
  801d05:	e8 04 07 00 00       	call   80240e <pageref>
  801d0a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d0d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d12:	83 f8 01             	cmp    $0x1,%eax
  801d15:	75 10                	jne    801d27 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801d17:	83 ec 0c             	sub    $0xc,%esp
  801d1a:	ff 73 0c             	pushl  0xc(%ebx)
  801d1d:	e8 c0 02 00 00       	call   801fe2 <nsipc_close>
  801d22:	89 c2                	mov    %eax,%edx
  801d24:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801d27:	89 d0                	mov    %edx,%eax
  801d29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d34:	6a 00                	push   $0x0
  801d36:	ff 75 10             	pushl  0x10(%ebp)
  801d39:	ff 75 0c             	pushl  0xc(%ebp)
  801d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3f:	ff 70 0c             	pushl  0xc(%eax)
  801d42:	e8 78 03 00 00       	call   8020bf <nsipc_send>
}
  801d47:	c9                   	leave  
  801d48:	c3                   	ret    

00801d49 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d4f:	6a 00                	push   $0x0
  801d51:	ff 75 10             	pushl  0x10(%ebp)
  801d54:	ff 75 0c             	pushl  0xc(%ebp)
  801d57:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5a:	ff 70 0c             	pushl  0xc(%eax)
  801d5d:	e8 f1 02 00 00       	call   802053 <nsipc_recv>
}
  801d62:	c9                   	leave  
  801d63:	c3                   	ret    

00801d64 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d6a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d6d:	52                   	push   %edx
  801d6e:	50                   	push   %eax
  801d6f:	e8 6f f4 ff ff       	call   8011e3 <fd_lookup>
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	78 17                	js     801d92 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7e:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801d84:	39 08                	cmp    %ecx,(%eax)
  801d86:	75 05                	jne    801d8d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d88:	8b 40 0c             	mov    0xc(%eax),%eax
  801d8b:	eb 05                	jmp    801d92 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d8d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d92:	c9                   	leave  
  801d93:	c3                   	ret    

00801d94 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	56                   	push   %esi
  801d98:	53                   	push   %ebx
  801d99:	83 ec 1c             	sub    $0x1c,%esp
  801d9c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da1:	50                   	push   %eax
  801da2:	e8 ed f3 ff ff       	call   801194 <fd_alloc>
  801da7:	89 c3                	mov    %eax,%ebx
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	78 1b                	js     801dcb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801db0:	83 ec 04             	sub    $0x4,%esp
  801db3:	68 07 04 00 00       	push   $0x407
  801db8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbb:	6a 00                	push   $0x0
  801dbd:	e8 9b f1 ff ff       	call   800f5d <sys_page_alloc>
  801dc2:	89 c3                	mov    %eax,%ebx
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	79 10                	jns    801ddb <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801dcb:	83 ec 0c             	sub    $0xc,%esp
  801dce:	56                   	push   %esi
  801dcf:	e8 0e 02 00 00       	call   801fe2 <nsipc_close>
		return r;
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	89 d8                	mov    %ebx,%eax
  801dd9:	eb 24                	jmp    801dff <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ddb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801df0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801df3:	83 ec 0c             	sub    $0xc,%esp
  801df6:	50                   	push   %eax
  801df7:	e8 71 f3 ff ff       	call   80116d <fd2num>
  801dfc:	83 c4 10             	add    $0x10,%esp
}
  801dff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e02:	5b                   	pop    %ebx
  801e03:	5e                   	pop    %esi
  801e04:	5d                   	pop    %ebp
  801e05:	c3                   	ret    

00801e06 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0f:	e8 50 ff ff ff       	call   801d64 <fd2sockid>
		return r;
  801e14:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e16:	85 c0                	test   %eax,%eax
  801e18:	78 1f                	js     801e39 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e1a:	83 ec 04             	sub    $0x4,%esp
  801e1d:	ff 75 10             	pushl  0x10(%ebp)
  801e20:	ff 75 0c             	pushl  0xc(%ebp)
  801e23:	50                   	push   %eax
  801e24:	e8 12 01 00 00       	call   801f3b <nsipc_accept>
  801e29:	83 c4 10             	add    $0x10,%esp
		return r;
  801e2c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 07                	js     801e39 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801e32:	e8 5d ff ff ff       	call   801d94 <alloc_sockfd>
  801e37:	89 c1                	mov    %eax,%ecx
}
  801e39:	89 c8                	mov    %ecx,%eax
  801e3b:	c9                   	leave  
  801e3c:	c3                   	ret    

00801e3d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e3d:	55                   	push   %ebp
  801e3e:	89 e5                	mov    %esp,%ebp
  801e40:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e43:	8b 45 08             	mov    0x8(%ebp),%eax
  801e46:	e8 19 ff ff ff       	call   801d64 <fd2sockid>
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	78 12                	js     801e61 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e4f:	83 ec 04             	sub    $0x4,%esp
  801e52:	ff 75 10             	pushl  0x10(%ebp)
  801e55:	ff 75 0c             	pushl  0xc(%ebp)
  801e58:	50                   	push   %eax
  801e59:	e8 2d 01 00 00       	call   801f8b <nsipc_bind>
  801e5e:	83 c4 10             	add    $0x10,%esp
}
  801e61:	c9                   	leave  
  801e62:	c3                   	ret    

00801e63 <shutdown>:

int
shutdown(int s, int how)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e69:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6c:	e8 f3 fe ff ff       	call   801d64 <fd2sockid>
  801e71:	85 c0                	test   %eax,%eax
  801e73:	78 0f                	js     801e84 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e75:	83 ec 08             	sub    $0x8,%esp
  801e78:	ff 75 0c             	pushl  0xc(%ebp)
  801e7b:	50                   	push   %eax
  801e7c:	e8 3f 01 00 00       	call   801fc0 <nsipc_shutdown>
  801e81:	83 c4 10             	add    $0x10,%esp
}
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8f:	e8 d0 fe ff ff       	call   801d64 <fd2sockid>
  801e94:	85 c0                	test   %eax,%eax
  801e96:	78 12                	js     801eaa <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e98:	83 ec 04             	sub    $0x4,%esp
  801e9b:	ff 75 10             	pushl  0x10(%ebp)
  801e9e:	ff 75 0c             	pushl  0xc(%ebp)
  801ea1:	50                   	push   %eax
  801ea2:	e8 55 01 00 00       	call   801ffc <nsipc_connect>
  801ea7:	83 c4 10             	add    $0x10,%esp
}
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <listen>:

int
listen(int s, int backlog)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb5:	e8 aa fe ff ff       	call   801d64 <fd2sockid>
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	78 0f                	js     801ecd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ebe:	83 ec 08             	sub    $0x8,%esp
  801ec1:	ff 75 0c             	pushl  0xc(%ebp)
  801ec4:	50                   	push   %eax
  801ec5:	e8 67 01 00 00       	call   802031 <nsipc_listen>
  801eca:	83 c4 10             	add    $0x10,%esp
}
  801ecd:	c9                   	leave  
  801ece:	c3                   	ret    

00801ecf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ed5:	ff 75 10             	pushl  0x10(%ebp)
  801ed8:	ff 75 0c             	pushl  0xc(%ebp)
  801edb:	ff 75 08             	pushl  0x8(%ebp)
  801ede:	e8 3a 02 00 00       	call   80211d <nsipc_socket>
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	78 05                	js     801eef <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801eea:	e8 a5 fe ff ff       	call   801d94 <alloc_sockfd>
}
  801eef:	c9                   	leave  
  801ef0:	c3                   	ret    

00801ef1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	53                   	push   %ebx
  801ef5:	83 ec 04             	sub    $0x4,%esp
  801ef8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801efa:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801f01:	75 12                	jne    801f15 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f03:	83 ec 0c             	sub    $0xc,%esp
  801f06:	6a 02                	push   $0x2
  801f08:	e8 c8 04 00 00       	call   8023d5 <ipc_find_env>
  801f0d:	a3 14 40 80 00       	mov    %eax,0x804014
  801f12:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f15:	6a 07                	push   $0x7
  801f17:	68 00 60 80 00       	push   $0x806000
  801f1c:	53                   	push   %ebx
  801f1d:	ff 35 14 40 80 00    	pushl  0x804014
  801f23:	e8 5e 04 00 00       	call   802386 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f28:	83 c4 0c             	add    $0xc,%esp
  801f2b:	6a 00                	push   $0x0
  801f2d:	6a 00                	push   $0x0
  801f2f:	6a 00                	push   $0x0
  801f31:	e8 da 03 00 00       	call   802310 <ipc_recv>
}
  801f36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f39:	c9                   	leave  
  801f3a:	c3                   	ret    

00801f3b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f3b:	55                   	push   %ebp
  801f3c:	89 e5                	mov    %esp,%ebp
  801f3e:	56                   	push   %esi
  801f3f:	53                   	push   %ebx
  801f40:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f43:	8b 45 08             	mov    0x8(%ebp),%eax
  801f46:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f4b:	8b 06                	mov    (%esi),%eax
  801f4d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f52:	b8 01 00 00 00       	mov    $0x1,%eax
  801f57:	e8 95 ff ff ff       	call   801ef1 <nsipc>
  801f5c:	89 c3                	mov    %eax,%ebx
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	78 20                	js     801f82 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f62:	83 ec 04             	sub    $0x4,%esp
  801f65:	ff 35 10 60 80 00    	pushl  0x806010
  801f6b:	68 00 60 80 00       	push   $0x806000
  801f70:	ff 75 0c             	pushl  0xc(%ebp)
  801f73:	e8 74 ed ff ff       	call   800cec <memmove>
		*addrlen = ret->ret_addrlen;
  801f78:	a1 10 60 80 00       	mov    0x806010,%eax
  801f7d:	89 06                	mov    %eax,(%esi)
  801f7f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f82:	89 d8                	mov    %ebx,%eax
  801f84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f87:	5b                   	pop    %ebx
  801f88:	5e                   	pop    %esi
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    

00801f8b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	53                   	push   %ebx
  801f8f:	83 ec 08             	sub    $0x8,%esp
  801f92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f95:	8b 45 08             	mov    0x8(%ebp),%eax
  801f98:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f9d:	53                   	push   %ebx
  801f9e:	ff 75 0c             	pushl  0xc(%ebp)
  801fa1:	68 04 60 80 00       	push   $0x806004
  801fa6:	e8 41 ed ff ff       	call   800cec <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fab:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801fb1:	b8 02 00 00 00       	mov    $0x2,%eax
  801fb6:	e8 36 ff ff ff       	call   801ef1 <nsipc>
}
  801fbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fbe:	c9                   	leave  
  801fbf:	c3                   	ret    

00801fc0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801fce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801fd6:	b8 03 00 00 00       	mov    $0x3,%eax
  801fdb:	e8 11 ff ff ff       	call   801ef1 <nsipc>
}
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <nsipc_close>:

int
nsipc_close(int s)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ff0:	b8 04 00 00 00       	mov    $0x4,%eax
  801ff5:	e8 f7 fe ff ff       	call   801ef1 <nsipc>
}
  801ffa:	c9                   	leave  
  801ffb:	c3                   	ret    

00801ffc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	53                   	push   %ebx
  802000:	83 ec 08             	sub    $0x8,%esp
  802003:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802006:	8b 45 08             	mov    0x8(%ebp),%eax
  802009:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80200e:	53                   	push   %ebx
  80200f:	ff 75 0c             	pushl  0xc(%ebp)
  802012:	68 04 60 80 00       	push   $0x806004
  802017:	e8 d0 ec ff ff       	call   800cec <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80201c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802022:	b8 05 00 00 00       	mov    $0x5,%eax
  802027:	e8 c5 fe ff ff       	call   801ef1 <nsipc>
}
  80202c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80202f:	c9                   	leave  
  802030:	c3                   	ret    

00802031 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802037:	8b 45 08             	mov    0x8(%ebp),%eax
  80203a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80203f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802042:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802047:	b8 06 00 00 00       	mov    $0x6,%eax
  80204c:	e8 a0 fe ff ff       	call   801ef1 <nsipc>
}
  802051:	c9                   	leave  
  802052:	c3                   	ret    

00802053 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	56                   	push   %esi
  802057:	53                   	push   %ebx
  802058:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80205b:	8b 45 08             	mov    0x8(%ebp),%eax
  80205e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802063:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802069:	8b 45 14             	mov    0x14(%ebp),%eax
  80206c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802071:	b8 07 00 00 00       	mov    $0x7,%eax
  802076:	e8 76 fe ff ff       	call   801ef1 <nsipc>
  80207b:	89 c3                	mov    %eax,%ebx
  80207d:	85 c0                	test   %eax,%eax
  80207f:	78 35                	js     8020b6 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802081:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802086:	7f 04                	jg     80208c <nsipc_recv+0x39>
  802088:	39 c6                	cmp    %eax,%esi
  80208a:	7d 16                	jge    8020a2 <nsipc_recv+0x4f>
  80208c:	68 3a 2c 80 00       	push   $0x802c3a
  802091:	68 e3 2b 80 00       	push   $0x802be3
  802096:	6a 62                	push   $0x62
  802098:	68 4f 2c 80 00       	push   $0x802c4f
  80209d:	e8 28 02 00 00       	call   8022ca <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020a2:	83 ec 04             	sub    $0x4,%esp
  8020a5:	50                   	push   %eax
  8020a6:	68 00 60 80 00       	push   $0x806000
  8020ab:	ff 75 0c             	pushl  0xc(%ebp)
  8020ae:	e8 39 ec ff ff       	call   800cec <memmove>
  8020b3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020bb:	5b                   	pop    %ebx
  8020bc:	5e                   	pop    %esi
  8020bd:	5d                   	pop    %ebp
  8020be:	c3                   	ret    

008020bf <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	53                   	push   %ebx
  8020c3:	83 ec 04             	sub    $0x4,%esp
  8020c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cc:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8020d1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020d7:	7e 16                	jle    8020ef <nsipc_send+0x30>
  8020d9:	68 5b 2c 80 00       	push   $0x802c5b
  8020de:	68 e3 2b 80 00       	push   $0x802be3
  8020e3:	6a 6d                	push   $0x6d
  8020e5:	68 4f 2c 80 00       	push   $0x802c4f
  8020ea:	e8 db 01 00 00       	call   8022ca <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020ef:	83 ec 04             	sub    $0x4,%esp
  8020f2:	53                   	push   %ebx
  8020f3:	ff 75 0c             	pushl  0xc(%ebp)
  8020f6:	68 0c 60 80 00       	push   $0x80600c
  8020fb:	e8 ec eb ff ff       	call   800cec <memmove>
	nsipcbuf.send.req_size = size;
  802100:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802106:	8b 45 14             	mov    0x14(%ebp),%eax
  802109:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80210e:	b8 08 00 00 00       	mov    $0x8,%eax
  802113:	e8 d9 fd ff ff       	call   801ef1 <nsipc>
}
  802118:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80211b:	c9                   	leave  
  80211c:	c3                   	ret    

0080211d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80211d:	55                   	push   %ebp
  80211e:	89 e5                	mov    %esp,%ebp
  802120:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802123:	8b 45 08             	mov    0x8(%ebp),%eax
  802126:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80212b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802133:	8b 45 10             	mov    0x10(%ebp),%eax
  802136:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80213b:	b8 09 00 00 00       	mov    $0x9,%eax
  802140:	e8 ac fd ff ff       	call   801ef1 <nsipc>
}
  802145:	c9                   	leave  
  802146:	c3                   	ret    

00802147 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80214a:	b8 00 00 00 00       	mov    $0x0,%eax
  80214f:	5d                   	pop    %ebp
  802150:	c3                   	ret    

00802151 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802151:	55                   	push   %ebp
  802152:	89 e5                	mov    %esp,%ebp
  802154:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802157:	68 67 2c 80 00       	push   $0x802c67
  80215c:	ff 75 0c             	pushl  0xc(%ebp)
  80215f:	e8 f6 e9 ff ff       	call   800b5a <strcpy>
	return 0;
}
  802164:	b8 00 00 00 00       	mov    $0x0,%eax
  802169:	c9                   	leave  
  80216a:	c3                   	ret    

0080216b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	57                   	push   %edi
  80216f:	56                   	push   %esi
  802170:	53                   	push   %ebx
  802171:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802177:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80217c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802182:	eb 2d                	jmp    8021b1 <devcons_write+0x46>
		m = n - tot;
  802184:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802187:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802189:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80218c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802191:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802194:	83 ec 04             	sub    $0x4,%esp
  802197:	53                   	push   %ebx
  802198:	03 45 0c             	add    0xc(%ebp),%eax
  80219b:	50                   	push   %eax
  80219c:	57                   	push   %edi
  80219d:	e8 4a eb ff ff       	call   800cec <memmove>
		sys_cputs(buf, m);
  8021a2:	83 c4 08             	add    $0x8,%esp
  8021a5:	53                   	push   %ebx
  8021a6:	57                   	push   %edi
  8021a7:	e8 f5 ec ff ff       	call   800ea1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ac:	01 de                	add    %ebx,%esi
  8021ae:	83 c4 10             	add    $0x10,%esp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021b6:	72 cc                	jb     802184 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021bb:	5b                   	pop    %ebx
  8021bc:	5e                   	pop    %esi
  8021bd:	5f                   	pop    %edi
  8021be:	5d                   	pop    %ebp
  8021bf:	c3                   	ret    

008021c0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	83 ec 08             	sub    $0x8,%esp
  8021c6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021cf:	74 2a                	je     8021fb <devcons_read+0x3b>
  8021d1:	eb 05                	jmp    8021d8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021d3:	e8 66 ed ff ff       	call   800f3e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021d8:	e8 e2 ec ff ff       	call   800ebf <sys_cgetc>
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	74 f2                	je     8021d3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	78 16                	js     8021fb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021e5:	83 f8 04             	cmp    $0x4,%eax
  8021e8:	74 0c                	je     8021f6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021ed:	88 02                	mov    %al,(%edx)
	return 1;
  8021ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f4:	eb 05                	jmp    8021fb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021f6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021fb:	c9                   	leave  
  8021fc:	c3                   	ret    

008021fd <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021fd:	55                   	push   %ebp
  8021fe:	89 e5                	mov    %esp,%ebp
  802200:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802203:	8b 45 08             	mov    0x8(%ebp),%eax
  802206:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802209:	6a 01                	push   $0x1
  80220b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80220e:	50                   	push   %eax
  80220f:	e8 8d ec ff ff       	call   800ea1 <sys_cputs>
}
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	c9                   	leave  
  802218:	c3                   	ret    

00802219 <getchar>:

int
getchar(void)
{
  802219:	55                   	push   %ebp
  80221a:	89 e5                	mov    %esp,%ebp
  80221c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80221f:	6a 01                	push   $0x1
  802221:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802224:	50                   	push   %eax
  802225:	6a 00                	push   $0x0
  802227:	e8 1d f2 ff ff       	call   801449 <read>
	if (r < 0)
  80222c:	83 c4 10             	add    $0x10,%esp
  80222f:	85 c0                	test   %eax,%eax
  802231:	78 0f                	js     802242 <getchar+0x29>
		return r;
	if (r < 1)
  802233:	85 c0                	test   %eax,%eax
  802235:	7e 06                	jle    80223d <getchar+0x24>
		return -E_EOF;
	return c;
  802237:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80223b:	eb 05                	jmp    802242 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80223d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802242:	c9                   	leave  
  802243:	c3                   	ret    

00802244 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802244:	55                   	push   %ebp
  802245:	89 e5                	mov    %esp,%ebp
  802247:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80224a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224d:	50                   	push   %eax
  80224e:	ff 75 08             	pushl  0x8(%ebp)
  802251:	e8 8d ef ff ff       	call   8011e3 <fd_lookup>
  802256:	83 c4 10             	add    $0x10,%esp
  802259:	85 c0                	test   %eax,%eax
  80225b:	78 11                	js     80226e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80225d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802260:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802266:	39 10                	cmp    %edx,(%eax)
  802268:	0f 94 c0             	sete   %al
  80226b:	0f b6 c0             	movzbl %al,%eax
}
  80226e:	c9                   	leave  
  80226f:	c3                   	ret    

00802270 <opencons>:

int
opencons(void)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802276:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802279:	50                   	push   %eax
  80227a:	e8 15 ef ff ff       	call   801194 <fd_alloc>
  80227f:	83 c4 10             	add    $0x10,%esp
		return r;
  802282:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802284:	85 c0                	test   %eax,%eax
  802286:	78 3e                	js     8022c6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802288:	83 ec 04             	sub    $0x4,%esp
  80228b:	68 07 04 00 00       	push   $0x407
  802290:	ff 75 f4             	pushl  -0xc(%ebp)
  802293:	6a 00                	push   $0x0
  802295:	e8 c3 ec ff ff       	call   800f5d <sys_page_alloc>
  80229a:	83 c4 10             	add    $0x10,%esp
		return r;
  80229d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80229f:	85 c0                	test   %eax,%eax
  8022a1:	78 23                	js     8022c6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022a3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022b8:	83 ec 0c             	sub    $0xc,%esp
  8022bb:	50                   	push   %eax
  8022bc:	e8 ac ee ff ff       	call   80116d <fd2num>
  8022c1:	89 c2                	mov    %eax,%edx
  8022c3:	83 c4 10             	add    $0x10,%esp
}
  8022c6:	89 d0                	mov    %edx,%eax
  8022c8:	c9                   	leave  
  8022c9:	c3                   	ret    

008022ca <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022ca:	55                   	push   %ebp
  8022cb:	89 e5                	mov    %esp,%ebp
  8022cd:	56                   	push   %esi
  8022ce:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022cf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022d2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022d8:	e8 42 ec ff ff       	call   800f1f <sys_getenvid>
  8022dd:	83 ec 0c             	sub    $0xc,%esp
  8022e0:	ff 75 0c             	pushl  0xc(%ebp)
  8022e3:	ff 75 08             	pushl  0x8(%ebp)
  8022e6:	56                   	push   %esi
  8022e7:	50                   	push   %eax
  8022e8:	68 74 2c 80 00       	push   $0x802c74
  8022ed:	e8 c3 e2 ff ff       	call   8005b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022f2:	83 c4 18             	add    $0x18,%esp
  8022f5:	53                   	push   %ebx
  8022f6:	ff 75 10             	pushl  0x10(%ebp)
  8022f9:	e8 66 e2 ff ff       	call   800564 <vcprintf>
	cprintf("\n");
  8022fe:	c7 04 24 27 2c 80 00 	movl   $0x802c27,(%esp)
  802305:	e8 ab e2 ff ff       	call   8005b5 <cprintf>
  80230a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80230d:	cc                   	int3   
  80230e:	eb fd                	jmp    80230d <_panic+0x43>

00802310 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	56                   	push   %esi
  802314:	53                   	push   %ebx
  802315:	8b 75 08             	mov    0x8(%ebp),%esi
  802318:	8b 45 0c             	mov    0xc(%ebp),%eax
  80231b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  80231e:	85 c0                	test   %eax,%eax
  802320:	74 0e                	je     802330 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  802322:	83 ec 0c             	sub    $0xc,%esp
  802325:	50                   	push   %eax
  802326:	e8 e2 ed ff ff       	call   80110d <sys_ipc_recv>
  80232b:	83 c4 10             	add    $0x10,%esp
  80232e:	eb 10                	jmp    802340 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802330:	83 ec 0c             	sub    $0xc,%esp
  802333:	68 00 00 c0 ee       	push   $0xeec00000
  802338:	e8 d0 ed ff ff       	call   80110d <sys_ipc_recv>
  80233d:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  802340:	85 c0                	test   %eax,%eax
  802342:	79 17                	jns    80235b <ipc_recv+0x4b>
		if(*from_env_store)
  802344:	83 3e 00             	cmpl   $0x0,(%esi)
  802347:	74 06                	je     80234f <ipc_recv+0x3f>
			*from_env_store = 0;
  802349:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  80234f:	85 db                	test   %ebx,%ebx
  802351:	74 2c                	je     80237f <ipc_recv+0x6f>
			*perm_store = 0;
  802353:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802359:	eb 24                	jmp    80237f <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  80235b:	85 f6                	test   %esi,%esi
  80235d:	74 0a                	je     802369 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  80235f:	a1 18 40 80 00       	mov    0x804018,%eax
  802364:	8b 40 74             	mov    0x74(%eax),%eax
  802367:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802369:	85 db                	test   %ebx,%ebx
  80236b:	74 0a                	je     802377 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  80236d:	a1 18 40 80 00       	mov    0x804018,%eax
  802372:	8b 40 78             	mov    0x78(%eax),%eax
  802375:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802377:	a1 18 40 80 00       	mov    0x804018,%eax
  80237c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80237f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802382:	5b                   	pop    %ebx
  802383:	5e                   	pop    %esi
  802384:	5d                   	pop    %ebp
  802385:	c3                   	ret    

00802386 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802386:	55                   	push   %ebp
  802387:	89 e5                	mov    %esp,%ebp
  802389:	57                   	push   %edi
  80238a:	56                   	push   %esi
  80238b:	53                   	push   %ebx
  80238c:	83 ec 0c             	sub    $0xc,%esp
  80238f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802392:	8b 75 0c             	mov    0xc(%ebp),%esi
  802395:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802398:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80239a:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  80239f:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  8023a2:	e8 97 eb ff ff       	call   800f3e <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  8023a7:	ff 75 14             	pushl  0x14(%ebp)
  8023aa:	53                   	push   %ebx
  8023ab:	56                   	push   %esi
  8023ac:	57                   	push   %edi
  8023ad:	e8 38 ed ff ff       	call   8010ea <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  8023b2:	89 c2                	mov    %eax,%edx
  8023b4:	f7 d2                	not    %edx
  8023b6:	c1 ea 1f             	shr    $0x1f,%edx
  8023b9:	83 c4 10             	add    $0x10,%esp
  8023bc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023bf:	0f 94 c1             	sete   %cl
  8023c2:	09 ca                	or     %ecx,%edx
  8023c4:	85 c0                	test   %eax,%eax
  8023c6:	0f 94 c0             	sete   %al
  8023c9:	38 c2                	cmp    %al,%dl
  8023cb:	77 d5                	ja     8023a2 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8023cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023d0:	5b                   	pop    %ebx
  8023d1:	5e                   	pop    %esi
  8023d2:	5f                   	pop    %edi
  8023d3:	5d                   	pop    %ebp
  8023d4:	c3                   	ret    

008023d5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023db:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023e0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023e3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023e9:	8b 52 50             	mov    0x50(%edx),%edx
  8023ec:	39 ca                	cmp    %ecx,%edx
  8023ee:	75 0d                	jne    8023fd <ipc_find_env+0x28>
			return envs[i].env_id;
  8023f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023f8:	8b 40 48             	mov    0x48(%eax),%eax
  8023fb:	eb 0f                	jmp    80240c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023fd:	83 c0 01             	add    $0x1,%eax
  802400:	3d 00 04 00 00       	cmp    $0x400,%eax
  802405:	75 d9                	jne    8023e0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802407:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80240c:	5d                   	pop    %ebp
  80240d:	c3                   	ret    

0080240e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80240e:	55                   	push   %ebp
  80240f:	89 e5                	mov    %esp,%ebp
  802411:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802414:	89 d0                	mov    %edx,%eax
  802416:	c1 e8 16             	shr    $0x16,%eax
  802419:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802420:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802425:	f6 c1 01             	test   $0x1,%cl
  802428:	74 1d                	je     802447 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80242a:	c1 ea 0c             	shr    $0xc,%edx
  80242d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802434:	f6 c2 01             	test   $0x1,%dl
  802437:	74 0e                	je     802447 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802439:	c1 ea 0c             	shr    $0xc,%edx
  80243c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802443:	ef 
  802444:	0f b7 c0             	movzwl %ax,%eax
}
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    
  802449:	66 90                	xchg   %ax,%ax
  80244b:	66 90                	xchg   %ax,%ax
  80244d:	66 90                	xchg   %ax,%ax
  80244f:	90                   	nop

00802450 <__udivdi3>:
  802450:	55                   	push   %ebp
  802451:	57                   	push   %edi
  802452:	56                   	push   %esi
  802453:	53                   	push   %ebx
  802454:	83 ec 1c             	sub    $0x1c,%esp
  802457:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80245b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80245f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802463:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802467:	85 f6                	test   %esi,%esi
  802469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80246d:	89 ca                	mov    %ecx,%edx
  80246f:	89 f8                	mov    %edi,%eax
  802471:	75 3d                	jne    8024b0 <__udivdi3+0x60>
  802473:	39 cf                	cmp    %ecx,%edi
  802475:	0f 87 c5 00 00 00    	ja     802540 <__udivdi3+0xf0>
  80247b:	85 ff                	test   %edi,%edi
  80247d:	89 fd                	mov    %edi,%ebp
  80247f:	75 0b                	jne    80248c <__udivdi3+0x3c>
  802481:	b8 01 00 00 00       	mov    $0x1,%eax
  802486:	31 d2                	xor    %edx,%edx
  802488:	f7 f7                	div    %edi
  80248a:	89 c5                	mov    %eax,%ebp
  80248c:	89 c8                	mov    %ecx,%eax
  80248e:	31 d2                	xor    %edx,%edx
  802490:	f7 f5                	div    %ebp
  802492:	89 c1                	mov    %eax,%ecx
  802494:	89 d8                	mov    %ebx,%eax
  802496:	89 cf                	mov    %ecx,%edi
  802498:	f7 f5                	div    %ebp
  80249a:	89 c3                	mov    %eax,%ebx
  80249c:	89 d8                	mov    %ebx,%eax
  80249e:	89 fa                	mov    %edi,%edx
  8024a0:	83 c4 1c             	add    $0x1c,%esp
  8024a3:	5b                   	pop    %ebx
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    
  8024a8:	90                   	nop
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	39 ce                	cmp    %ecx,%esi
  8024b2:	77 74                	ja     802528 <__udivdi3+0xd8>
  8024b4:	0f bd fe             	bsr    %esi,%edi
  8024b7:	83 f7 1f             	xor    $0x1f,%edi
  8024ba:	0f 84 98 00 00 00    	je     802558 <__udivdi3+0x108>
  8024c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	89 c5                	mov    %eax,%ebp
  8024c9:	29 fb                	sub    %edi,%ebx
  8024cb:	d3 e6                	shl    %cl,%esi
  8024cd:	89 d9                	mov    %ebx,%ecx
  8024cf:	d3 ed                	shr    %cl,%ebp
  8024d1:	89 f9                	mov    %edi,%ecx
  8024d3:	d3 e0                	shl    %cl,%eax
  8024d5:	09 ee                	or     %ebp,%esi
  8024d7:	89 d9                	mov    %ebx,%ecx
  8024d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024dd:	89 d5                	mov    %edx,%ebp
  8024df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024e3:	d3 ed                	shr    %cl,%ebp
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e2                	shl    %cl,%edx
  8024e9:	89 d9                	mov    %ebx,%ecx
  8024eb:	d3 e8                	shr    %cl,%eax
  8024ed:	09 c2                	or     %eax,%edx
  8024ef:	89 d0                	mov    %edx,%eax
  8024f1:	89 ea                	mov    %ebp,%edx
  8024f3:	f7 f6                	div    %esi
  8024f5:	89 d5                	mov    %edx,%ebp
  8024f7:	89 c3                	mov    %eax,%ebx
  8024f9:	f7 64 24 0c          	mull   0xc(%esp)
  8024fd:	39 d5                	cmp    %edx,%ebp
  8024ff:	72 10                	jb     802511 <__udivdi3+0xc1>
  802501:	8b 74 24 08          	mov    0x8(%esp),%esi
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e6                	shl    %cl,%esi
  802509:	39 c6                	cmp    %eax,%esi
  80250b:	73 07                	jae    802514 <__udivdi3+0xc4>
  80250d:	39 d5                	cmp    %edx,%ebp
  80250f:	75 03                	jne    802514 <__udivdi3+0xc4>
  802511:	83 eb 01             	sub    $0x1,%ebx
  802514:	31 ff                	xor    %edi,%edi
  802516:	89 d8                	mov    %ebx,%eax
  802518:	89 fa                	mov    %edi,%edx
  80251a:	83 c4 1c             	add    $0x1c,%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5f                   	pop    %edi
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    
  802522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802528:	31 ff                	xor    %edi,%edi
  80252a:	31 db                	xor    %ebx,%ebx
  80252c:	89 d8                	mov    %ebx,%eax
  80252e:	89 fa                	mov    %edi,%edx
  802530:	83 c4 1c             	add    $0x1c,%esp
  802533:	5b                   	pop    %ebx
  802534:	5e                   	pop    %esi
  802535:	5f                   	pop    %edi
  802536:	5d                   	pop    %ebp
  802537:	c3                   	ret    
  802538:	90                   	nop
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 d8                	mov    %ebx,%eax
  802542:	f7 f7                	div    %edi
  802544:	31 ff                	xor    %edi,%edi
  802546:	89 c3                	mov    %eax,%ebx
  802548:	89 d8                	mov    %ebx,%eax
  80254a:	89 fa                	mov    %edi,%edx
  80254c:	83 c4 1c             	add    $0x1c,%esp
  80254f:	5b                   	pop    %ebx
  802550:	5e                   	pop    %esi
  802551:	5f                   	pop    %edi
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    
  802554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802558:	39 ce                	cmp    %ecx,%esi
  80255a:	72 0c                	jb     802568 <__udivdi3+0x118>
  80255c:	31 db                	xor    %ebx,%ebx
  80255e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802562:	0f 87 34 ff ff ff    	ja     80249c <__udivdi3+0x4c>
  802568:	bb 01 00 00 00       	mov    $0x1,%ebx
  80256d:	e9 2a ff ff ff       	jmp    80249c <__udivdi3+0x4c>
  802572:	66 90                	xchg   %ax,%ax
  802574:	66 90                	xchg   %ax,%ax
  802576:	66 90                	xchg   %ax,%ax
  802578:	66 90                	xchg   %ax,%ax
  80257a:	66 90                	xchg   %ax,%ax
  80257c:	66 90                	xchg   %ax,%ax
  80257e:	66 90                	xchg   %ax,%ax

00802580 <__umoddi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	83 ec 1c             	sub    $0x1c,%esp
  802587:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80258b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80258f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802593:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802597:	85 d2                	test   %edx,%edx
  802599:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80259d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025a1:	89 f3                	mov    %esi,%ebx
  8025a3:	89 3c 24             	mov    %edi,(%esp)
  8025a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025aa:	75 1c                	jne    8025c8 <__umoddi3+0x48>
  8025ac:	39 f7                	cmp    %esi,%edi
  8025ae:	76 50                	jbe    802600 <__umoddi3+0x80>
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 f2                	mov    %esi,%edx
  8025b4:	f7 f7                	div    %edi
  8025b6:	89 d0                	mov    %edx,%eax
  8025b8:	31 d2                	xor    %edx,%edx
  8025ba:	83 c4 1c             	add    $0x1c,%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5f                   	pop    %edi
  8025c0:	5d                   	pop    %ebp
  8025c1:	c3                   	ret    
  8025c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025c8:	39 f2                	cmp    %esi,%edx
  8025ca:	89 d0                	mov    %edx,%eax
  8025cc:	77 52                	ja     802620 <__umoddi3+0xa0>
  8025ce:	0f bd ea             	bsr    %edx,%ebp
  8025d1:	83 f5 1f             	xor    $0x1f,%ebp
  8025d4:	75 5a                	jne    802630 <__umoddi3+0xb0>
  8025d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025da:	0f 82 e0 00 00 00    	jb     8026c0 <__umoddi3+0x140>
  8025e0:	39 0c 24             	cmp    %ecx,(%esp)
  8025e3:	0f 86 d7 00 00 00    	jbe    8026c0 <__umoddi3+0x140>
  8025e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025f1:	83 c4 1c             	add    $0x1c,%esp
  8025f4:	5b                   	pop    %ebx
  8025f5:	5e                   	pop    %esi
  8025f6:	5f                   	pop    %edi
  8025f7:	5d                   	pop    %ebp
  8025f8:	c3                   	ret    
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	85 ff                	test   %edi,%edi
  802602:	89 fd                	mov    %edi,%ebp
  802604:	75 0b                	jne    802611 <__umoddi3+0x91>
  802606:	b8 01 00 00 00       	mov    $0x1,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	f7 f7                	div    %edi
  80260f:	89 c5                	mov    %eax,%ebp
  802611:	89 f0                	mov    %esi,%eax
  802613:	31 d2                	xor    %edx,%edx
  802615:	f7 f5                	div    %ebp
  802617:	89 c8                	mov    %ecx,%eax
  802619:	f7 f5                	div    %ebp
  80261b:	89 d0                	mov    %edx,%eax
  80261d:	eb 99                	jmp    8025b8 <__umoddi3+0x38>
  80261f:	90                   	nop
  802620:	89 c8                	mov    %ecx,%eax
  802622:	89 f2                	mov    %esi,%edx
  802624:	83 c4 1c             	add    $0x1c,%esp
  802627:	5b                   	pop    %ebx
  802628:	5e                   	pop    %esi
  802629:	5f                   	pop    %edi
  80262a:	5d                   	pop    %ebp
  80262b:	c3                   	ret    
  80262c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802630:	8b 34 24             	mov    (%esp),%esi
  802633:	bf 20 00 00 00       	mov    $0x20,%edi
  802638:	89 e9                	mov    %ebp,%ecx
  80263a:	29 ef                	sub    %ebp,%edi
  80263c:	d3 e0                	shl    %cl,%eax
  80263e:	89 f9                	mov    %edi,%ecx
  802640:	89 f2                	mov    %esi,%edx
  802642:	d3 ea                	shr    %cl,%edx
  802644:	89 e9                	mov    %ebp,%ecx
  802646:	09 c2                	or     %eax,%edx
  802648:	89 d8                	mov    %ebx,%eax
  80264a:	89 14 24             	mov    %edx,(%esp)
  80264d:	89 f2                	mov    %esi,%edx
  80264f:	d3 e2                	shl    %cl,%edx
  802651:	89 f9                	mov    %edi,%ecx
  802653:	89 54 24 04          	mov    %edx,0x4(%esp)
  802657:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80265b:	d3 e8                	shr    %cl,%eax
  80265d:	89 e9                	mov    %ebp,%ecx
  80265f:	89 c6                	mov    %eax,%esi
  802661:	d3 e3                	shl    %cl,%ebx
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 d0                	mov    %edx,%eax
  802667:	d3 e8                	shr    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	09 d8                	or     %ebx,%eax
  80266d:	89 d3                	mov    %edx,%ebx
  80266f:	89 f2                	mov    %esi,%edx
  802671:	f7 34 24             	divl   (%esp)
  802674:	89 d6                	mov    %edx,%esi
  802676:	d3 e3                	shl    %cl,%ebx
  802678:	f7 64 24 04          	mull   0x4(%esp)
  80267c:	39 d6                	cmp    %edx,%esi
  80267e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802682:	89 d1                	mov    %edx,%ecx
  802684:	89 c3                	mov    %eax,%ebx
  802686:	72 08                	jb     802690 <__umoddi3+0x110>
  802688:	75 11                	jne    80269b <__umoddi3+0x11b>
  80268a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80268e:	73 0b                	jae    80269b <__umoddi3+0x11b>
  802690:	2b 44 24 04          	sub    0x4(%esp),%eax
  802694:	1b 14 24             	sbb    (%esp),%edx
  802697:	89 d1                	mov    %edx,%ecx
  802699:	89 c3                	mov    %eax,%ebx
  80269b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80269f:	29 da                	sub    %ebx,%edx
  8026a1:	19 ce                	sbb    %ecx,%esi
  8026a3:	89 f9                	mov    %edi,%ecx
  8026a5:	89 f0                	mov    %esi,%eax
  8026a7:	d3 e0                	shl    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	d3 ea                	shr    %cl,%edx
  8026ad:	89 e9                	mov    %ebp,%ecx
  8026af:	d3 ee                	shr    %cl,%esi
  8026b1:	09 d0                	or     %edx,%eax
  8026b3:	89 f2                	mov    %esi,%edx
  8026b5:	83 c4 1c             	add    $0x1c,%esp
  8026b8:	5b                   	pop    %ebx
  8026b9:	5e                   	pop    %esi
  8026ba:	5f                   	pop    %edi
  8026bb:	5d                   	pop    %ebp
  8026bc:	c3                   	ret    
  8026bd:	8d 76 00             	lea    0x0(%esi),%esi
  8026c0:	29 f9                	sub    %edi,%ecx
  8026c2:	19 d6                	sbb    %edx,%esi
  8026c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026cc:	e9 18 ff ff ff       	jmp    8025e9 <__umoddi3+0x69>
