
obj/user/echotest.debug:     file format elf32-i386


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
  80002c:	e8 79 04 00 00       	call   8004aa <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 e0 26 80 00       	push   $0x8026e0
  80003f:	e8 59 05 00 00       	call   80059d <cprintf>
	exit();
  800044:	e8 a7 04 00 00       	call   8004f0 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <umain>:

void umain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 58             	sub    $0x58,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  800057:	68 e4 26 80 00       	push   $0x8026e4
  80005c:	e8 3c 05 00 00       	call   80059d <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800061:	c7 04 24 f4 26 80 00 	movl   $0x8026f4,(%esp)
  800068:	e8 0b 04 00 00       	call   800478 <inet_addr>
  80006d:	83 c4 0c             	add    $0xc,%esp
  800070:	50                   	push   %eax
  800071:	68 f4 26 80 00       	push   $0x8026f4
  800076:	68 fe 26 80 00       	push   $0x8026fe
  80007b:	e8 1d 05 00 00       	call   80059d <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800080:	83 c4 0c             	add    $0xc,%esp
  800083:	6a 06                	push   $0x6
  800085:	6a 01                	push   $0x1
  800087:	6a 02                	push   $0x2
  800089:	e8 29 1e 00 00       	call   801eb7 <socket>
  80008e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	79 0a                	jns    8000a2 <umain+0x54>
		die("Failed to create socket");
  800098:	b8 13 27 80 00       	mov    $0x802713,%eax
  80009d:	e8 91 ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	68 2b 27 80 00       	push   $0x80272b
  8000aa:	e8 ee 04 00 00       	call   80059d <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000af:	83 c4 0c             	add    $0xc,%esp
  8000b2:	6a 10                	push   $0x10
  8000b4:	6a 00                	push   $0x0
  8000b6:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000b9:	53                   	push   %ebx
  8000ba:	e8 c8 0b 00 00       	call   800c87 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000bf:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000c3:	c7 04 24 f4 26 80 00 	movl   $0x8026f4,(%esp)
  8000ca:	e8 a9 03 00 00       	call   800478 <inet_addr>
  8000cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000d2:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000d9:	e8 81 01 00 00       	call   80025f <htons>
  8000de:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  8000e2:	c7 04 24 3a 27 80 00 	movl   $0x80273a,(%esp)
  8000e9:	e8 af 04 00 00       	call   80059d <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  8000ee:	83 c4 0c             	add    $0xc,%esp
  8000f1:	6a 10                	push   $0x10
  8000f3:	53                   	push   %ebx
  8000f4:	ff 75 b4             	pushl  -0x4c(%ebp)
  8000f7:	e8 72 1d 00 00       	call   801e6e <connect>
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	85 c0                	test   %eax,%eax
  800101:	79 0a                	jns    80010d <umain+0xbf>
		die("Failed to connect with server");
  800103:	b8 57 27 80 00       	mov    $0x802757,%eax
  800108:	e8 26 ff ff ff       	call   800033 <die>

	cprintf("connected to server\n");
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	68 75 27 80 00       	push   $0x802775
  800115:	e8 83 04 00 00       	call   80059d <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80011a:	83 c4 04             	add    $0x4,%esp
  80011d:	ff 35 00 30 80 00    	pushl  0x803000
  800123:	e8 e1 09 00 00       	call   800b09 <strlen>
  800128:	89 c7                	mov    %eax,%edi
  80012a:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80012d:	83 c4 0c             	add    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	ff 35 00 30 80 00    	pushl  0x803000
  800137:	ff 75 b4             	pushl  -0x4c(%ebp)
  80013a:	e8 cc 13 00 00       	call   80150b <write>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	39 c7                	cmp    %eax,%edi
  800144:	74 0a                	je     800150 <umain+0x102>
		die("Mismatch in number of sent bytes");
  800146:	b8 a4 27 80 00       	mov    $0x8027a4,%eax
  80014b:	e8 e3 fe ff ff       	call   800033 <die>

	// Receive the word back from the server
	cprintf("Received: \n");
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	68 8a 27 80 00       	push   $0x80278a
  800158:	e8 40 04 00 00       	call   80059d <cprintf>
	while (received < echolen) {
  80015d:	83 c4 10             	add    $0x10,%esp
{
	int sock;
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;
  800160:	be 00 00 00 00       	mov    $0x0,%esi

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  800165:	8d 7d b8             	lea    -0x48(%ebp),%edi
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  800168:	eb 34                	jmp    80019e <umain+0x150>
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80016a:	83 ec 04             	sub    $0x4,%esp
  80016d:	6a 1f                	push   $0x1f
  80016f:	57                   	push   %edi
  800170:	ff 75 b4             	pushl  -0x4c(%ebp)
  800173:	e8 b9 12 00 00       	call   801431 <read>
  800178:	89 c3                	mov    %eax,%ebx
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	85 c0                	test   %eax,%eax
  80017f:	7f 0a                	jg     80018b <umain+0x13d>
			die("Failed to receive bytes from server");
  800181:	b8 c8 27 80 00       	mov    $0x8027c8,%eax
  800186:	e8 a8 fe ff ff       	call   800033 <die>
		}
		received += bytes;
  80018b:	01 de                	add    %ebx,%esi
		buffer[bytes] = '\0';        // Assure null terminated string
  80018d:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	57                   	push   %edi
  800196:	e8 02 04 00 00       	call   80059d <cprintf>
  80019b:	83 c4 10             	add    $0x10,%esp
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  80019e:	39 75 b0             	cmp    %esi,-0x50(%ebp)
  8001a1:	77 c7                	ja     80016a <umain+0x11c>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 94 27 80 00       	push   $0x802794
  8001ab:	e8 ed 03 00 00       	call   80059d <cprintf>

	close(sock);
  8001b0:	83 c4 04             	add    $0x4,%esp
  8001b3:	ff 75 b4             	pushl  -0x4c(%ebp)
  8001b6:	e8 3a 11 00 00       	call   8012f5 <close>
}
  8001bb:	83 c4 10             	add    $0x10,%esp
  8001be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    

008001c6 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001d5:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001d8:	c7 45 e0 00 40 80 00 	movl   $0x804000,-0x20(%ebp)
  8001df:	0f b6 0f             	movzbl (%edi),%ecx
  8001e2:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8001e7:	0f b6 d9             	movzbl %cl,%ebx
  8001ea:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8001ed:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  8001f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001f3:	66 c1 e8 0b          	shr    $0xb,%ax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001fc:	01 c0                	add    %eax,%eax
  8001fe:	29 c1                	sub    %eax,%ecx
  800200:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  800202:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800204:	8d 72 01             	lea    0x1(%edx),%esi
  800207:	0f b6 d2             	movzbl %dl,%edx
  80020a:	83 c0 30             	add    $0x30,%eax
  80020d:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800211:	89 f2                	mov    %esi,%edx
    } while(*ap);
  800213:	84 db                	test   %bl,%bl
  800215:	75 d0                	jne    8001e7 <inet_ntoa+0x21>
  800217:	c6 07 00             	movb   $0x0,(%edi)
  80021a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80021d:	eb 0d                	jmp    80022c <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  80021f:	0f b6 c2             	movzbl %dl,%eax
  800222:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  800227:	88 01                	mov    %al,(%ecx)
  800229:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80022c:	83 ea 01             	sub    $0x1,%edx
  80022f:	80 fa ff             	cmp    $0xff,%dl
  800232:	75 eb                	jne    80021f <inet_ntoa+0x59>
  800234:	89 f0                	mov    %esi,%eax
  800236:	0f b6 f0             	movzbl %al,%esi
  800239:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  80023c:	8d 46 01             	lea    0x1(%esi),%eax
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  800245:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800248:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80024b:	39 c7                	cmp    %eax,%edi
  80024d:	75 90                	jne    8001df <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  80024f:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  800252:	b8 00 40 80 00       	mov    $0x804000,%eax
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800262:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800266:	66 c1 c0 08          	rol    $0x8,%ax
}
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  return htons(n);
  80026f:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800273:	66 c1 c0 08          	rol    $0x8,%ax
}
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  80027f:	89 d1                	mov    %edx,%ecx
  800281:	c1 e1 18             	shl    $0x18,%ecx
  800284:	89 d0                	mov    %edx,%eax
  800286:	c1 e8 18             	shr    $0x18,%eax
  800289:	09 c8                	or     %ecx,%eax
  80028b:	89 d1                	mov    %edx,%ecx
  80028d:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800293:	c1 e1 08             	shl    $0x8,%ecx
  800296:	09 c8                	or     %ecx,%eax
  800298:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80029e:	c1 ea 08             	shr    $0x8,%edx
  8002a1:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 20             	sub    $0x20,%esp
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002b1:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002b4:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8002b7:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002ba:	0f b6 ca             	movzbl %dl,%ecx
  8002bd:	83 e9 30             	sub    $0x30,%ecx
  8002c0:	83 f9 09             	cmp    $0x9,%ecx
  8002c3:	0f 87 94 01 00 00    	ja     80045d <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8002c9:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8002d0:	83 fa 30             	cmp    $0x30,%edx
  8002d3:	75 2b                	jne    800300 <inet_aton+0x5b>
      c = *++cp;
  8002d5:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8002d9:	89 d1                	mov    %edx,%ecx
  8002db:	83 e1 df             	and    $0xffffffdf,%ecx
  8002de:	80 f9 58             	cmp    $0x58,%cl
  8002e1:	74 0f                	je     8002f2 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8002e3:	83 c0 01             	add    $0x1,%eax
  8002e6:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8002e9:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8002f0:	eb 0e                	jmp    800300 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8002f2:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8002f6:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8002f9:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800300:	83 c0 01             	add    $0x1,%eax
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	eb 03                	jmp    80030d <inet_aton+0x68>
  80030a:	83 c0 01             	add    $0x1,%eax
  80030d:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800310:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800313:	0f b6 fa             	movzbl %dl,%edi
  800316:	8d 4f d0             	lea    -0x30(%edi),%ecx
  800319:	83 f9 09             	cmp    $0x9,%ecx
  80031c:	77 0d                	ja     80032b <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  80031e:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  800322:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800326:	0f be 10             	movsbl (%eax),%edx
  800329:	eb df                	jmp    80030a <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  80032b:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  80032f:	75 32                	jne    800363 <inet_aton+0xbe>
  800331:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  800334:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800337:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80033a:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800340:	83 e9 41             	sub    $0x41,%ecx
  800343:	83 f9 05             	cmp    $0x5,%ecx
  800346:	77 1b                	ja     800363 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800348:	c1 e6 04             	shl    $0x4,%esi
  80034b:	83 c2 0a             	add    $0xa,%edx
  80034e:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  800352:	19 c9                	sbb    %ecx,%ecx
  800354:	83 e1 20             	and    $0x20,%ecx
  800357:	83 c1 41             	add    $0x41,%ecx
  80035a:	29 ca                	sub    %ecx,%edx
  80035c:	09 d6                	or     %edx,%esi
        c = *++cp;
  80035e:	0f be 10             	movsbl (%eax),%edx
  800361:	eb a7                	jmp    80030a <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  800363:	83 fa 2e             	cmp    $0x2e,%edx
  800366:	75 23                	jne    80038b <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	8d 7d f0             	lea    -0x10(%ebp),%edi
  80036e:	39 f8                	cmp    %edi,%eax
  800370:	0f 84 ee 00 00 00    	je     800464 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  800376:	83 c0 04             	add    $0x4,%eax
  800379:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80037c:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  80037f:	8d 43 01             	lea    0x1(%ebx),%eax
  800382:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800386:	e9 2f ff ff ff       	jmp    8002ba <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80038b:	85 d2                	test   %edx,%edx
  80038d:	74 25                	je     8003b4 <inet_aton+0x10f>
  80038f:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800397:	83 f9 5f             	cmp    $0x5f,%ecx
  80039a:	0f 87 d0 00 00 00    	ja     800470 <inet_aton+0x1cb>
  8003a0:	83 fa 20             	cmp    $0x20,%edx
  8003a3:	74 0f                	je     8003b4 <inet_aton+0x10f>
  8003a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a8:	83 ea 09             	sub    $0x9,%edx
  8003ab:	83 fa 04             	cmp    $0x4,%edx
  8003ae:	0f 87 bc 00 00 00    	ja     800470 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8003b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003ba:	29 c2                	sub    %eax,%edx
  8003bc:	c1 fa 02             	sar    $0x2,%edx
  8003bf:	83 c2 01             	add    $0x1,%edx
  8003c2:	83 fa 02             	cmp    $0x2,%edx
  8003c5:	74 20                	je     8003e7 <inet_aton+0x142>
  8003c7:	83 fa 02             	cmp    $0x2,%edx
  8003ca:	7f 0f                	jg     8003db <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	0f 84 97 00 00 00    	je     800470 <inet_aton+0x1cb>
  8003d9:	eb 67                	jmp    800442 <inet_aton+0x19d>
  8003db:	83 fa 03             	cmp    $0x3,%edx
  8003de:	74 1e                	je     8003fe <inet_aton+0x159>
  8003e0:	83 fa 04             	cmp    $0x4,%edx
  8003e3:	74 38                	je     80041d <inet_aton+0x178>
  8003e5:	eb 5b                	jmp    800442 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8003ec:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  8003f2:	77 7c                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  8003f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003f7:	c1 e0 18             	shl    $0x18,%eax
  8003fa:	09 c6                	or     %eax,%esi
    break;
  8003fc:	eb 44                	jmp    800442 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8003fe:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800403:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800409:	77 65                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80040b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040e:	c1 e2 18             	shl    $0x18,%edx
  800411:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800414:	c1 e0 10             	shl    $0x10,%eax
  800417:	09 d0                	or     %edx,%eax
  800419:	09 c6                	or     %eax,%esi
    break;
  80041b:	eb 25                	jmp    800442 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800422:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800428:	77 46                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80042a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042d:	c1 e2 18             	shl    $0x18,%edx
  800430:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800433:	c1 e0 10             	shl    $0x10,%eax
  800436:	09 c2                	or     %eax,%edx
  800438:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80043b:	c1 e0 08             	shl    $0x8,%eax
  80043e:	09 d0                	or     %edx,%eax
  800440:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  800442:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800446:	74 23                	je     80046b <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800448:	56                   	push   %esi
  800449:	e8 2b fe ff ff       	call   800279 <htonl>
  80044e:	83 c4 04             	add    $0x4,%esp
  800451:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800454:	89 03                	mov    %eax,(%ebx)
  return (1);
  800456:	b8 01 00 00 00       	mov    $0x1,%eax
  80045b:	eb 13                	jmp    800470 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	eb 0c                	jmp    800470 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800464:	b8 00 00 00 00       	mov    $0x0,%eax
  800469:	eb 05                	jmp    800470 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  80046b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800470:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800473:	5b                   	pop    %ebx
  800474:	5e                   	pop    %esi
  800475:	5f                   	pop    %edi
  800476:	5d                   	pop    %ebp
  800477:	c3                   	ret    

00800478 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  80047e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800481:	50                   	push   %eax
  800482:	ff 75 08             	pushl  0x8(%ebp)
  800485:	e8 1b fe ff ff       	call   8002a5 <inet_aton>
  80048a:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80048d:	85 c0                	test   %eax,%eax
  80048f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800494:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    

0080049a <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80049d:	ff 75 08             	pushl  0x8(%ebp)
  8004a0:	e8 d4 fd ff ff       	call   800279 <htonl>
  8004a5:	83 c4 04             	add    $0x4,%esp
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    

008004aa <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	56                   	push   %esi
  8004ae:	53                   	push   %ebx
  8004af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004b2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8004b5:	e8 4d 0a 00 00       	call   800f07 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8004ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004c7:	a3 18 40 80 00       	mov    %eax,0x804018
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004cc:	85 db                	test   %ebx,%ebx
  8004ce:	7e 07                	jle    8004d7 <libmain+0x2d>
		binaryname = argv[0];
  8004d0:	8b 06                	mov    (%esi),%eax
  8004d2:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
  8004dc:	e8 6d fb ff ff       	call   80004e <umain>

	// exit gracefully
	exit();
  8004e1:	e8 0a 00 00 00       	call   8004f0 <exit>
}
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004ec:	5b                   	pop    %ebx
  8004ed:	5e                   	pop    %esi
  8004ee:	5d                   	pop    %ebp
  8004ef:	c3                   	ret    

008004f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004f6:	e8 25 0e 00 00       	call   801320 <close_all>
	sys_env_destroy(0);
  8004fb:	83 ec 0c             	sub    $0xc,%esp
  8004fe:	6a 00                	push   $0x0
  800500:	e8 c1 09 00 00       	call   800ec6 <sys_env_destroy>
}
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	c9                   	leave  
  800509:	c3                   	ret    

0080050a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	53                   	push   %ebx
  80050e:	83 ec 04             	sub    $0x4,%esp
  800511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800514:	8b 13                	mov    (%ebx),%edx
  800516:	8d 42 01             	lea    0x1(%edx),%eax
  800519:	89 03                	mov    %eax,(%ebx)
  80051b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80051e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800522:	3d ff 00 00 00       	cmp    $0xff,%eax
  800527:	75 1a                	jne    800543 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	68 ff 00 00 00       	push   $0xff
  800531:	8d 43 08             	lea    0x8(%ebx),%eax
  800534:	50                   	push   %eax
  800535:	e8 4f 09 00 00       	call   800e89 <sys_cputs>
		b->idx = 0;
  80053a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800540:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800543:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800547:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800555:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80055c:	00 00 00 
	b.cnt = 0;
  80055f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800566:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800569:	ff 75 0c             	pushl  0xc(%ebp)
  80056c:	ff 75 08             	pushl  0x8(%ebp)
  80056f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800575:	50                   	push   %eax
  800576:	68 0a 05 80 00       	push   $0x80050a
  80057b:	e8 54 01 00 00       	call   8006d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800580:	83 c4 08             	add    $0x8,%esp
  800583:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800589:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80058f:	50                   	push   %eax
  800590:	e8 f4 08 00 00       	call   800e89 <sys_cputs>

	return b.cnt;
}
  800595:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80059b:	c9                   	leave  
  80059c:	c3                   	ret    

0080059d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80059d:	55                   	push   %ebp
  80059e:	89 e5                	mov    %esp,%ebp
  8005a0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005a6:	50                   	push   %eax
  8005a7:	ff 75 08             	pushl  0x8(%ebp)
  8005aa:	e8 9d ff ff ff       	call   80054c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005af:	c9                   	leave  
  8005b0:	c3                   	ret    

008005b1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005b1:	55                   	push   %ebp
  8005b2:	89 e5                	mov    %esp,%ebp
  8005b4:	57                   	push   %edi
  8005b5:	56                   	push   %esi
  8005b6:	53                   	push   %ebx
  8005b7:	83 ec 1c             	sub    $0x1c,%esp
  8005ba:	89 c7                	mov    %eax,%edi
  8005bc:	89 d6                	mov    %edx,%esi
  8005be:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005d5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005d8:	39 d3                	cmp    %edx,%ebx
  8005da:	72 05                	jb     8005e1 <printnum+0x30>
  8005dc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005df:	77 45                	ja     800626 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005e1:	83 ec 0c             	sub    $0xc,%esp
  8005e4:	ff 75 18             	pushl  0x18(%ebp)
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005ed:	53                   	push   %ebx
  8005ee:	ff 75 10             	pushl  0x10(%ebp)
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8005fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800600:	e8 3b 1e 00 00       	call   802440 <__udivdi3>
  800605:	83 c4 18             	add    $0x18,%esp
  800608:	52                   	push   %edx
  800609:	50                   	push   %eax
  80060a:	89 f2                	mov    %esi,%edx
  80060c:	89 f8                	mov    %edi,%eax
  80060e:	e8 9e ff ff ff       	call   8005b1 <printnum>
  800613:	83 c4 20             	add    $0x20,%esp
  800616:	eb 18                	jmp    800630 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	56                   	push   %esi
  80061c:	ff 75 18             	pushl  0x18(%ebp)
  80061f:	ff d7                	call   *%edi
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	eb 03                	jmp    800629 <printnum+0x78>
  800626:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800629:	83 eb 01             	sub    $0x1,%ebx
  80062c:	85 db                	test   %ebx,%ebx
  80062e:	7f e8                	jg     800618 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	56                   	push   %esi
  800634:	83 ec 04             	sub    $0x4,%esp
  800637:	ff 75 e4             	pushl  -0x1c(%ebp)
  80063a:	ff 75 e0             	pushl  -0x20(%ebp)
  80063d:	ff 75 dc             	pushl  -0x24(%ebp)
  800640:	ff 75 d8             	pushl  -0x28(%ebp)
  800643:	e8 28 1f 00 00       	call   802570 <__umoddi3>
  800648:	83 c4 14             	add    $0x14,%esp
  80064b:	0f be 80 f6 27 80 00 	movsbl 0x8027f6(%eax),%eax
  800652:	50                   	push   %eax
  800653:	ff d7                	call   *%edi
}
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065b:	5b                   	pop    %ebx
  80065c:	5e                   	pop    %esi
  80065d:	5f                   	pop    %edi
  80065e:	5d                   	pop    %ebp
  80065f:	c3                   	ret    

00800660 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800663:	83 fa 01             	cmp    $0x1,%edx
  800666:	7e 0e                	jle    800676 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80066d:	89 08                	mov    %ecx,(%eax)
  80066f:	8b 02                	mov    (%edx),%eax
  800671:	8b 52 04             	mov    0x4(%edx),%edx
  800674:	eb 22                	jmp    800698 <getuint+0x38>
	else if (lflag)
  800676:	85 d2                	test   %edx,%edx
  800678:	74 10                	je     80068a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80067f:	89 08                	mov    %ecx,(%eax)
  800681:	8b 02                	mov    (%edx),%eax
  800683:	ba 00 00 00 00       	mov    $0x0,%edx
  800688:	eb 0e                	jmp    800698 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80068f:	89 08                	mov    %ecx,(%eax)
  800691:	8b 02                	mov    (%edx),%eax
  800693:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006a0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006a4:	8b 10                	mov    (%eax),%edx
  8006a6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006a9:	73 0a                	jae    8006b5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ae:	89 08                	mov    %ecx,(%eax)
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	88 02                	mov    %al,(%edx)
}
  8006b5:	5d                   	pop    %ebp
  8006b6:	c3                   	ret    

008006b7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006c0:	50                   	push   %eax
  8006c1:	ff 75 10             	pushl  0x10(%ebp)
  8006c4:	ff 75 0c             	pushl  0xc(%ebp)
  8006c7:	ff 75 08             	pushl  0x8(%ebp)
  8006ca:	e8 05 00 00 00       	call   8006d4 <vprintfmt>
	va_end(ap);
}
  8006cf:	83 c4 10             	add    $0x10,%esp
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	57                   	push   %edi
  8006d8:	56                   	push   %esi
  8006d9:	53                   	push   %ebx
  8006da:	83 ec 2c             	sub    $0x2c,%esp
  8006dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006e6:	eb 12                	jmp    8006fa <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	0f 84 a9 03 00 00    	je     800a99 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8006f0:	83 ec 08             	sub    $0x8,%esp
  8006f3:	53                   	push   %ebx
  8006f4:	50                   	push   %eax
  8006f5:	ff d6                	call   *%esi
  8006f7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006fa:	83 c7 01             	add    $0x1,%edi
  8006fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800701:	83 f8 25             	cmp    $0x25,%eax
  800704:	75 e2                	jne    8006e8 <vprintfmt+0x14>
  800706:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80070a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800711:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800718:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80071f:	ba 00 00 00 00       	mov    $0x0,%edx
  800724:	eb 07                	jmp    80072d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800729:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072d:	8d 47 01             	lea    0x1(%edi),%eax
  800730:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800733:	0f b6 07             	movzbl (%edi),%eax
  800736:	0f b6 c8             	movzbl %al,%ecx
  800739:	83 e8 23             	sub    $0x23,%eax
  80073c:	3c 55                	cmp    $0x55,%al
  80073e:	0f 87 3a 03 00 00    	ja     800a7e <vprintfmt+0x3aa>
  800744:	0f b6 c0             	movzbl %al,%eax
  800747:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  80074e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800751:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800755:	eb d6                	jmp    80072d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800757:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075a:	b8 00 00 00 00       	mov    $0x0,%eax
  80075f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800762:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800765:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800769:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80076c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80076f:	83 fa 09             	cmp    $0x9,%edx
  800772:	77 39                	ja     8007ad <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800774:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800777:	eb e9                	jmp    800762 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8d 48 04             	lea    0x4(%eax),%ecx
  80077f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800782:	8b 00                	mov    (%eax),%eax
  800784:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800787:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80078a:	eb 27                	jmp    8007b3 <vprintfmt+0xdf>
  80078c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80078f:	85 c0                	test   %eax,%eax
  800791:	b9 00 00 00 00       	mov    $0x0,%ecx
  800796:	0f 49 c8             	cmovns %eax,%ecx
  800799:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079f:	eb 8c                	jmp    80072d <vprintfmt+0x59>
  8007a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007ab:	eb 80                	jmp    80072d <vprintfmt+0x59>
  8007ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007b7:	0f 89 70 ff ff ff    	jns    80072d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ca:	e9 5e ff ff ff       	jmp    80072d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007cf:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007d5:	e9 53 ff ff ff       	jmp    80072d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8d 50 04             	lea    0x4(%eax),%edx
  8007e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	53                   	push   %ebx
  8007e7:	ff 30                	pushl  (%eax)
  8007e9:	ff d6                	call   *%esi
			break;
  8007eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007f1:	e9 04 ff ff ff       	jmp    8006fa <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 50 04             	lea    0x4(%eax),%edx
  8007fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	99                   	cltd   
  800802:	31 d0                	xor    %edx,%eax
  800804:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800806:	83 f8 0f             	cmp    $0xf,%eax
  800809:	7f 0b                	jg     800816 <vprintfmt+0x142>
  80080b:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  800812:	85 d2                	test   %edx,%edx
  800814:	75 18                	jne    80082e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800816:	50                   	push   %eax
  800817:	68 0e 28 80 00       	push   $0x80280e
  80081c:	53                   	push   %ebx
  80081d:	56                   	push   %esi
  80081e:	e8 94 fe ff ff       	call   8006b7 <printfmt>
  800823:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800826:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800829:	e9 cc fe ff ff       	jmp    8006fa <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80082e:	52                   	push   %edx
  80082f:	68 d5 2b 80 00       	push   $0x802bd5
  800834:	53                   	push   %ebx
  800835:	56                   	push   %esi
  800836:	e8 7c fe ff ff       	call   8006b7 <printfmt>
  80083b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800841:	e9 b4 fe ff ff       	jmp    8006fa <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8d 50 04             	lea    0x4(%eax),%edx
  80084c:	89 55 14             	mov    %edx,0x14(%ebp)
  80084f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800851:	85 ff                	test   %edi,%edi
  800853:	b8 07 28 80 00       	mov    $0x802807,%eax
  800858:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80085b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80085f:	0f 8e 94 00 00 00    	jle    8008f9 <vprintfmt+0x225>
  800865:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800869:	0f 84 98 00 00 00    	je     800907 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	ff 75 d0             	pushl  -0x30(%ebp)
  800875:	57                   	push   %edi
  800876:	e8 a6 02 00 00       	call   800b21 <strnlen>
  80087b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80087e:	29 c1                	sub    %eax,%ecx
  800880:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800883:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800886:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80088a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80088d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800890:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800892:	eb 0f                	jmp    8008a3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	53                   	push   %ebx
  800898:	ff 75 e0             	pushl  -0x20(%ebp)
  80089b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80089d:	83 ef 01             	sub    $0x1,%edi
  8008a0:	83 c4 10             	add    $0x10,%esp
  8008a3:	85 ff                	test   %edi,%edi
  8008a5:	7f ed                	jg     800894 <vprintfmt+0x1c0>
  8008a7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008aa:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008ad:	85 c9                	test   %ecx,%ecx
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b4:	0f 49 c1             	cmovns %ecx,%eax
  8008b7:	29 c1                	sub    %eax,%ecx
  8008b9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008bc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008bf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008c2:	89 cb                	mov    %ecx,%ebx
  8008c4:	eb 4d                	jmp    800913 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008c6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ca:	74 1b                	je     8008e7 <vprintfmt+0x213>
  8008cc:	0f be c0             	movsbl %al,%eax
  8008cf:	83 e8 20             	sub    $0x20,%eax
  8008d2:	83 f8 5e             	cmp    $0x5e,%eax
  8008d5:	76 10                	jbe    8008e7 <vprintfmt+0x213>
					putch('?', putdat);
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	ff 75 0c             	pushl  0xc(%ebp)
  8008dd:	6a 3f                	push   $0x3f
  8008df:	ff 55 08             	call   *0x8(%ebp)
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	eb 0d                	jmp    8008f4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8008e7:	83 ec 08             	sub    $0x8,%esp
  8008ea:	ff 75 0c             	pushl  0xc(%ebp)
  8008ed:	52                   	push   %edx
  8008ee:	ff 55 08             	call   *0x8(%ebp)
  8008f1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f4:	83 eb 01             	sub    $0x1,%ebx
  8008f7:	eb 1a                	jmp    800913 <vprintfmt+0x23f>
  8008f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800902:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800905:	eb 0c                	jmp    800913 <vprintfmt+0x23f>
  800907:	89 75 08             	mov    %esi,0x8(%ebp)
  80090a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80090d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800910:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800913:	83 c7 01             	add    $0x1,%edi
  800916:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80091a:	0f be d0             	movsbl %al,%edx
  80091d:	85 d2                	test   %edx,%edx
  80091f:	74 23                	je     800944 <vprintfmt+0x270>
  800921:	85 f6                	test   %esi,%esi
  800923:	78 a1                	js     8008c6 <vprintfmt+0x1f2>
  800925:	83 ee 01             	sub    $0x1,%esi
  800928:	79 9c                	jns    8008c6 <vprintfmt+0x1f2>
  80092a:	89 df                	mov    %ebx,%edi
  80092c:	8b 75 08             	mov    0x8(%ebp),%esi
  80092f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800932:	eb 18                	jmp    80094c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800934:	83 ec 08             	sub    $0x8,%esp
  800937:	53                   	push   %ebx
  800938:	6a 20                	push   $0x20
  80093a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80093c:	83 ef 01             	sub    $0x1,%edi
  80093f:	83 c4 10             	add    $0x10,%esp
  800942:	eb 08                	jmp    80094c <vprintfmt+0x278>
  800944:	89 df                	mov    %ebx,%edi
  800946:	8b 75 08             	mov    0x8(%ebp),%esi
  800949:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094c:	85 ff                	test   %edi,%edi
  80094e:	7f e4                	jg     800934 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800950:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800953:	e9 a2 fd ff ff       	jmp    8006fa <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800958:	83 fa 01             	cmp    $0x1,%edx
  80095b:	7e 16                	jle    800973 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80095d:	8b 45 14             	mov    0x14(%ebp),%eax
  800960:	8d 50 08             	lea    0x8(%eax),%edx
  800963:	89 55 14             	mov    %edx,0x14(%ebp)
  800966:	8b 50 04             	mov    0x4(%eax),%edx
  800969:	8b 00                	mov    (%eax),%eax
  80096b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80096e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800971:	eb 32                	jmp    8009a5 <vprintfmt+0x2d1>
	else if (lflag)
  800973:	85 d2                	test   %edx,%edx
  800975:	74 18                	je     80098f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800977:	8b 45 14             	mov    0x14(%ebp),%eax
  80097a:	8d 50 04             	lea    0x4(%eax),%edx
  80097d:	89 55 14             	mov    %edx,0x14(%ebp)
  800980:	8b 00                	mov    (%eax),%eax
  800982:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800985:	89 c1                	mov    %eax,%ecx
  800987:	c1 f9 1f             	sar    $0x1f,%ecx
  80098a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80098d:	eb 16                	jmp    8009a5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 50 04             	lea    0x4(%eax),%edx
  800995:	89 55 14             	mov    %edx,0x14(%ebp)
  800998:	8b 00                	mov    (%eax),%eax
  80099a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80099d:	89 c1                	mov    %eax,%ecx
  80099f:	c1 f9 1f             	sar    $0x1f,%ecx
  8009a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009b4:	0f 89 90 00 00 00    	jns    800a4a <vprintfmt+0x376>
				putch('-', putdat);
  8009ba:	83 ec 08             	sub    $0x8,%esp
  8009bd:	53                   	push   %ebx
  8009be:	6a 2d                	push   $0x2d
  8009c0:	ff d6                	call   *%esi
				num = -(long long) num;
  8009c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009c8:	f7 d8                	neg    %eax
  8009ca:	83 d2 00             	adc    $0x0,%edx
  8009cd:	f7 da                	neg    %edx
  8009cf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009d2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009d7:	eb 71                	jmp    800a4a <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8009dc:	e8 7f fc ff ff       	call   800660 <getuint>
			base = 10;
  8009e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009e6:	eb 62                	jmp    800a4a <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009eb:	e8 70 fc ff ff       	call   800660 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8009f0:	83 ec 0c             	sub    $0xc,%esp
  8009f3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8009f7:	51                   	push   %ecx
  8009f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8009fb:	6a 08                	push   $0x8
  8009fd:	52                   	push   %edx
  8009fe:	50                   	push   %eax
  8009ff:	89 da                	mov    %ebx,%edx
  800a01:	89 f0                	mov    %esi,%eax
  800a03:	e8 a9 fb ff ff       	call   8005b1 <printnum>
			break;
  800a08:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800a0e:	e9 e7 fc ff ff       	jmp    8006fa <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	53                   	push   %ebx
  800a17:	6a 30                	push   $0x30
  800a19:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1b:	83 c4 08             	add    $0x8,%esp
  800a1e:	53                   	push   %ebx
  800a1f:	6a 78                	push   $0x78
  800a21:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8d 50 04             	lea    0x4(%eax),%edx
  800a29:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2c:	8b 00                	mov    (%eax),%eax
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a33:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a36:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a3b:	eb 0d                	jmp    800a4a <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a40:	e8 1b fc ff ff       	call   800660 <getuint>
			base = 16;
  800a45:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a51:	57                   	push   %edi
  800a52:	ff 75 e0             	pushl  -0x20(%ebp)
  800a55:	51                   	push   %ecx
  800a56:	52                   	push   %edx
  800a57:	50                   	push   %eax
  800a58:	89 da                	mov    %ebx,%edx
  800a5a:	89 f0                	mov    %esi,%eax
  800a5c:	e8 50 fb ff ff       	call   8005b1 <printnum>
			break;
  800a61:	83 c4 20             	add    $0x20,%esp
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	e9 8e fc ff ff       	jmp    8006fa <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	53                   	push   %ebx
  800a70:	51                   	push   %ecx
  800a71:	ff d6                	call   *%esi
			break;
  800a73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a79:	e9 7c fc ff ff       	jmp    8006fa <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	53                   	push   %ebx
  800a82:	6a 25                	push   $0x25
  800a84:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a86:	83 c4 10             	add    $0x10,%esp
  800a89:	eb 03                	jmp    800a8e <vprintfmt+0x3ba>
  800a8b:	83 ef 01             	sub    $0x1,%edi
  800a8e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a92:	75 f7                	jne    800a8b <vprintfmt+0x3b7>
  800a94:	e9 61 fc ff ff       	jmp    8006fa <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 18             	sub    $0x18,%esp
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	74 26                	je     800ae8 <vsnprintf+0x47>
  800ac2:	85 d2                	test   %edx,%edx
  800ac4:	7e 22                	jle    800ae8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac6:	ff 75 14             	pushl  0x14(%ebp)
  800ac9:	ff 75 10             	pushl  0x10(%ebp)
  800acc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800acf:	50                   	push   %eax
  800ad0:	68 9a 06 80 00       	push   $0x80069a
  800ad5:	e8 fa fb ff ff       	call   8006d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800add:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	eb 05                	jmp    800aed <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af8:	50                   	push   %eax
  800af9:	ff 75 10             	pushl  0x10(%ebp)
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 9a ff ff ff       	call   800aa1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	eb 03                	jmp    800b19 <strlen+0x10>
		n++;
  800b16:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1d:	75 f7                	jne    800b16 <strlen+0xd>
		n++;
	return n;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	eb 03                	jmp    800b34 <strnlen+0x13>
		n++;
  800b31:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	39 c2                	cmp    %eax,%edx
  800b36:	74 08                	je     800b40 <strnlen+0x1f>
  800b38:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b3c:	75 f3                	jne    800b31 <strnlen+0x10>
  800b3e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4c:	89 c2                	mov    %eax,%edx
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b58:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5b:	84 db                	test   %bl,%bl
  800b5d:	75 ef                	jne    800b4e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b69:	53                   	push   %ebx
  800b6a:	e8 9a ff ff ff       	call   800b09 <strlen>
  800b6f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	01 d8                	add    %ebx,%eax
  800b77:	50                   	push   %eax
  800b78:	e8 c5 ff ff ff       	call   800b42 <strcpy>
	return dst;
}
  800b7d:	89 d8                	mov    %ebx,%eax
  800b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b94:	89 f2                	mov    %esi,%edx
  800b96:	eb 0f                	jmp    800ba7 <strncpy+0x23>
		*dst++ = *src;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba1:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba7:	39 da                	cmp    %ebx,%edx
  800ba9:	75 ed                	jne    800b98 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 10             	mov    0x10(%ebp),%edx
  800bbf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc1:	85 d2                	test   %edx,%edx
  800bc3:	74 21                	je     800be6 <strlcpy+0x35>
  800bc5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc9:	89 f2                	mov    %esi,%edx
  800bcb:	eb 09                	jmp    800bd6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd6:	39 c2                	cmp    %eax,%edx
  800bd8:	74 09                	je     800be3 <strlcpy+0x32>
  800bda:	0f b6 19             	movzbl (%ecx),%ebx
  800bdd:	84 db                	test   %bl,%bl
  800bdf:	75 ec                	jne    800bcd <strlcpy+0x1c>
  800be1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800be3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be6:	29 f0                	sub    %esi,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf5:	eb 06                	jmp    800bfd <strcmp+0x11>
		p++, q++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bfd:	0f b6 01             	movzbl (%ecx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 04                	je     800c08 <strcmp+0x1c>
  800c04:	3a 02                	cmp    (%edx),%al
  800c06:	74 ef                	je     800bf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 c0             	movzbl %al,%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c21:	eb 06                	jmp    800c29 <strncmp+0x17>
		n--, p++, q++;
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c29:	39 d8                	cmp    %ebx,%eax
  800c2b:	74 15                	je     800c42 <strncmp+0x30>
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	74 04                	je     800c38 <strncmp+0x26>
  800c34:	3a 0a                	cmp    (%edx),%cl
  800c36:	74 eb                	je     800c23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c38:	0f b6 00             	movzbl (%eax),%eax
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	29 d0                	sub    %edx,%eax
  800c40:	eb 05                	jmp    800c47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	eb 07                	jmp    800c5d <strchr+0x13>
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 0f                	je     800c69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f2                	jne    800c56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	eb 03                	jmp    800c7a <strfind+0xf>
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7d:	38 ca                	cmp    %cl,%dl
  800c7f:	74 04                	je     800c85 <strfind+0x1a>
  800c81:	84 d2                	test   %dl,%dl
  800c83:	75 f2                	jne    800c77 <strfind+0xc>
			break;
	return (char *) s;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c93:	85 c9                	test   %ecx,%ecx
  800c95:	74 36                	je     800ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9d:	75 28                	jne    800cc7 <memset+0x40>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 23                	jne    800cc7 <memset+0x40>
		c &= 0xFF;
  800ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	c1 e3 08             	shl    $0x8,%ebx
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	c1 e6 18             	shl    $0x18,%esi
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	c1 e0 10             	shl    $0x10,%eax
  800cb7:	09 f0                	or     %esi,%eax
  800cb9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cbb:	89 d8                	mov    %ebx,%eax
  800cbd:	09 d0                	or     %edx,%eax
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
  800cc2:	fc                   	cld    
  800cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc5:	eb 06                	jmp    800ccd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	fc                   	cld    
  800ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce2:	39 c6                	cmp    %eax,%esi
  800ce4:	73 35                	jae    800d1b <memmove+0x47>
  800ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 2e                	jae    800d1b <memmove+0x47>
		s += n;
		d += n;
  800ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	09 fe                	or     %edi,%esi
  800cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfa:	75 13                	jne    800d0f <memmove+0x3b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 1d                	jmp    800d38 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	09 c2                	or     %eax,%edx
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 0f                	jne    800d33 <memmove+0x5f>
  800d24:	f6 c1 03             	test   $0x3,%cl
  800d27:	75 0a                	jne    800d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d29:	c1 e9 02             	shr    $0x2,%ecx
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d31:	eb 05                	jmp    800d38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	fc                   	cld    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d3f:	ff 75 10             	pushl  0x10(%ebp)
  800d42:	ff 75 0c             	pushl  0xc(%ebp)
  800d45:	ff 75 08             	pushl  0x8(%ebp)
  800d48:	e8 87 ff ff ff       	call   800cd4 <memmove>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5a:	89 c6                	mov    %eax,%esi
  800d5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5f:	eb 1a                	jmp    800d7b <memcmp+0x2c>
		if (*s1 != *s2)
  800d61:	0f b6 08             	movzbl (%eax),%ecx
  800d64:	0f b6 1a             	movzbl (%edx),%ebx
  800d67:	38 d9                	cmp    %bl,%cl
  800d69:	74 0a                	je     800d75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d6b:	0f b6 c1             	movzbl %cl,%eax
  800d6e:	0f b6 db             	movzbl %bl,%ebx
  800d71:	29 d8                	sub    %ebx,%eax
  800d73:	eb 0f                	jmp    800d84 <memcmp+0x35>
		s1++, s2++;
  800d75:	83 c0 01             	add    $0x1,%eax
  800d78:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7b:	39 f0                	cmp    %esi,%eax
  800d7d:	75 e2                	jne    800d61 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	53                   	push   %ebx
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d94:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d98:	eb 0a                	jmp    800da4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9a:	0f b6 10             	movzbl (%eax),%edx
  800d9d:	39 da                	cmp    %ebx,%edx
  800d9f:	74 07                	je     800da8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da1:	83 c0 01             	add    $0x1,%eax
  800da4:	39 c8                	cmp    %ecx,%eax
  800da6:	72 f2                	jb     800d9a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da8:	5b                   	pop    %ebx
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db7:	eb 03                	jmp    800dbc <strtol+0x11>
		s++;
  800db9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbc:	0f b6 01             	movzbl (%ecx),%eax
  800dbf:	3c 20                	cmp    $0x20,%al
  800dc1:	74 f6                	je     800db9 <strtol+0xe>
  800dc3:	3c 09                	cmp    $0x9,%al
  800dc5:	74 f2                	je     800db9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc7:	3c 2b                	cmp    $0x2b,%al
  800dc9:	75 0a                	jne    800dd5 <strtol+0x2a>
		s++;
  800dcb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dce:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd3:	eb 11                	jmp    800de6 <strtol+0x3b>
  800dd5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dda:	3c 2d                	cmp    $0x2d,%al
  800ddc:	75 08                	jne    800de6 <strtol+0x3b>
		s++, neg = 1;
  800dde:	83 c1 01             	add    $0x1,%ecx
  800de1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dec:	75 15                	jne    800e03 <strtol+0x58>
  800dee:	80 39 30             	cmpb   $0x30,(%ecx)
  800df1:	75 10                	jne    800e03 <strtol+0x58>
  800df3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800df7:	75 7c                	jne    800e75 <strtol+0xca>
		s += 2, base = 16;
  800df9:	83 c1 02             	add    $0x2,%ecx
  800dfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e01:	eb 16                	jmp    800e19 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	75 12                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e07:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e0f:	75 08                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
  800e11:	83 c1 01             	add    $0x1,%ecx
  800e14:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e19:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e21:	0f b6 11             	movzbl (%ecx),%edx
  800e24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e27:	89 f3                	mov    %esi,%ebx
  800e29:	80 fb 09             	cmp    $0x9,%bl
  800e2c:	77 08                	ja     800e36 <strtol+0x8b>
			dig = *s - '0';
  800e2e:	0f be d2             	movsbl %dl,%edx
  800e31:	83 ea 30             	sub    $0x30,%edx
  800e34:	eb 22                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e36:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e39:	89 f3                	mov    %esi,%ebx
  800e3b:	80 fb 19             	cmp    $0x19,%bl
  800e3e:	77 08                	ja     800e48 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e40:	0f be d2             	movsbl %dl,%edx
  800e43:	83 ea 57             	sub    $0x57,%edx
  800e46:	eb 10                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e48:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e4b:	89 f3                	mov    %esi,%ebx
  800e4d:	80 fb 19             	cmp    $0x19,%bl
  800e50:	77 16                	ja     800e68 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e52:	0f be d2             	movsbl %dl,%edx
  800e55:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e58:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e5b:	7d 0b                	jge    800e68 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e5d:	83 c1 01             	add    $0x1,%ecx
  800e60:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e64:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e66:	eb b9                	jmp    800e21 <strtol+0x76>

	if (endptr)
  800e68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6c:	74 0d                	je     800e7b <strtol+0xd0>
		*endptr = (char *) s;
  800e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e71:	89 0e                	mov    %ecx,(%esi)
  800e73:	eb 06                	jmp    800e7b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e75:	85 db                	test   %ebx,%ebx
  800e77:	74 98                	je     800e11 <strtol+0x66>
  800e79:	eb 9e                	jmp    800e19 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	f7 da                	neg    %edx
  800e7f:	85 ff                	test   %edi,%edi
  800e81:	0f 45 c2             	cmovne %edx,%eax
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	89 d1                	mov    %edx,%ecx
  800eb9:	89 d3                	mov    %edx,%ebx
  800ebb:	89 d7                	mov    %edx,%edi
  800ebd:	89 d6                	mov    %edx,%esi
  800ebf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 03                	push   $0x3
  800eee:	68 ff 2a 80 00       	push   $0x802aff
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 1c 2b 80 00       	push   $0x802b1c
  800efa:	e8 b3 13 00 00       	call   8022b2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f12:	b8 02 00 00 00       	mov    $0x2,%eax
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 d3                	mov    %edx,%ebx
  800f1b:	89 d7                	mov    %edx,%edi
  800f1d:	89 d6                	mov    %edx,%esi
  800f1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_yield>:

void
sys_yield(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	b8 04 00 00 00       	mov    $0x4,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	89 f7                	mov    %esi,%edi
  800f63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 17                	jle    800f80 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	50                   	push   %eax
  800f6d:	6a 04                	push   $0x4
  800f6f:	68 ff 2a 80 00       	push   $0x802aff
  800f74:	6a 23                	push   $0x23
  800f76:	68 1c 2b 80 00       	push   $0x802b1c
  800f7b:	e8 32 13 00 00       	call   8022b2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f91:	b8 05 00 00 00       	mov    $0x5,%eax
  800f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa2:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 17                	jle    800fc2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	50                   	push   %eax
  800faf:	6a 05                	push   $0x5
  800fb1:	68 ff 2a 80 00       	push   $0x802aff
  800fb6:	6a 23                	push   $0x23
  800fb8:	68 1c 2b 80 00       	push   $0x802b1c
  800fbd:	e8 f0 12 00 00       	call   8022b2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 df                	mov    %ebx,%edi
  800fe5:	89 de                	mov    %ebx,%esi
  800fe7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	7e 17                	jle    801004 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	50                   	push   %eax
  800ff1:	6a 06                	push   $0x6
  800ff3:	68 ff 2a 80 00       	push   $0x802aff
  800ff8:	6a 23                	push   $0x23
  800ffa:	68 1c 2b 80 00       	push   $0x802b1c
  800fff:	e8 ae 12 00 00       	call   8022b2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801015:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101a:	b8 08 00 00 00       	mov    $0x8,%eax
  80101f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	89 df                	mov    %ebx,%edi
  801027:	89 de                	mov    %ebx,%esi
  801029:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7e 17                	jle    801046 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	6a 08                	push   $0x8
  801035:	68 ff 2a 80 00       	push   $0x802aff
  80103a:	6a 23                	push   $0x23
  80103c:	68 1c 2b 80 00       	push   $0x802b1c
  801041:	e8 6c 12 00 00       	call   8022b2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105c:	b8 09 00 00 00       	mov    $0x9,%eax
  801061:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	89 df                	mov    %ebx,%edi
  801069:	89 de                	mov    %ebx,%esi
  80106b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7e 17                	jle    801088 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	6a 09                	push   $0x9
  801077:	68 ff 2a 80 00       	push   $0x802aff
  80107c:	6a 23                	push   $0x23
  80107e:	68 1c 2b 80 00       	push   $0x802b1c
  801083:	e8 2a 12 00 00       	call   8022b2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 df                	mov    %ebx,%edi
  8010ab:	89 de                	mov    %ebx,%esi
  8010ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	7e 17                	jle    8010ca <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	50                   	push   %eax
  8010b7:	6a 0a                	push   $0xa
  8010b9:	68 ff 2a 80 00       	push   $0x802aff
  8010be:	6a 23                	push   $0x23
  8010c0:	68 1c 2b 80 00       	push   $0x802b1c
  8010c5:	e8 e8 11 00 00       	call   8022b2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d8:	be 00 00 00 00       	mov    $0x0,%esi
  8010dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ee:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801103:	b8 0d 00 00 00       	mov    $0xd,%eax
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 cb                	mov    %ecx,%ebx
  80110d:	89 cf                	mov    %ecx,%edi
  80110f:	89 ce                	mov    %ecx,%esi
  801111:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	7e 17                	jle    80112e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 0d                	push   $0xd
  80111d:	68 ff 2a 80 00       	push   $0x802aff
  801122:	6a 23                	push   $0x23
  801124:	68 1c 2b 80 00       	push   $0x802b1c
  801129:	e8 84 11 00 00       	call   8022b2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113c:	ba 00 00 00 00       	mov    $0x0,%edx
  801141:	b8 0e 00 00 00       	mov    $0xe,%eax
  801146:	89 d1                	mov    %edx,%ecx
  801148:	89 d3                	mov    %edx,%ebx
  80114a:	89 d7                	mov    %edx,%edi
  80114c:	89 d6                	mov    %edx,%esi
  80114e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801158:	8b 45 08             	mov    0x8(%ebp),%eax
  80115b:	05 00 00 00 30       	add    $0x30000000,%eax
  801160:	c1 e8 0c             	shr    $0xc,%eax
}
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801168:	8b 45 08             	mov    0x8(%ebp),%eax
  80116b:	05 00 00 00 30       	add    $0x30000000,%eax
  801170:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801175:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80117a:	5d                   	pop    %ebp
  80117b:	c3                   	ret    

0080117c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801182:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801187:	89 c2                	mov    %eax,%edx
  801189:	c1 ea 16             	shr    $0x16,%edx
  80118c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801193:	f6 c2 01             	test   $0x1,%dl
  801196:	74 11                	je     8011a9 <fd_alloc+0x2d>
  801198:	89 c2                	mov    %eax,%edx
  80119a:	c1 ea 0c             	shr    $0xc,%edx
  80119d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a4:	f6 c2 01             	test   $0x1,%dl
  8011a7:	75 09                	jne    8011b2 <fd_alloc+0x36>
			*fd_store = fd;
  8011a9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b0:	eb 17                	jmp    8011c9 <fd_alloc+0x4d>
  8011b2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011b7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011bc:	75 c9                	jne    801187 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011be:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011c4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011d1:	83 f8 1f             	cmp    $0x1f,%eax
  8011d4:	77 36                	ja     80120c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d6:	c1 e0 0c             	shl    $0xc,%eax
  8011d9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	c1 ea 16             	shr    $0x16,%edx
  8011e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ea:	f6 c2 01             	test   $0x1,%dl
  8011ed:	74 24                	je     801213 <fd_lookup+0x48>
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	c1 ea 0c             	shr    $0xc,%edx
  8011f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fb:	f6 c2 01             	test   $0x1,%dl
  8011fe:	74 1a                	je     80121a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801200:	8b 55 0c             	mov    0xc(%ebp),%edx
  801203:	89 02                	mov    %eax,(%edx)
	return 0;
  801205:	b8 00 00 00 00       	mov    $0x0,%eax
  80120a:	eb 13                	jmp    80121f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801211:	eb 0c                	jmp    80121f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801213:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801218:	eb 05                	jmp    80121f <fd_lookup+0x54>
  80121a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80122a:	ba a8 2b 80 00       	mov    $0x802ba8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80122f:	eb 13                	jmp    801244 <dev_lookup+0x23>
  801231:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801234:	39 08                	cmp    %ecx,(%eax)
  801236:	75 0c                	jne    801244 <dev_lookup+0x23>
			*dev = devtab[i];
  801238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80123b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
  801242:	eb 2e                	jmp    801272 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801244:	8b 02                	mov    (%edx),%eax
  801246:	85 c0                	test   %eax,%eax
  801248:	75 e7                	jne    801231 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80124a:	a1 18 40 80 00       	mov    0x804018,%eax
  80124f:	8b 40 48             	mov    0x48(%eax),%eax
  801252:	83 ec 04             	sub    $0x4,%esp
  801255:	51                   	push   %ecx
  801256:	50                   	push   %eax
  801257:	68 2c 2b 80 00       	push   $0x802b2c
  80125c:	e8 3c f3 ff ff       	call   80059d <cprintf>
	*dev = 0;
  801261:	8b 45 0c             	mov    0xc(%ebp),%eax
  801264:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	56                   	push   %esi
  801278:	53                   	push   %ebx
  801279:	83 ec 10             	sub    $0x10,%esp
  80127c:	8b 75 08             	mov    0x8(%ebp),%esi
  80127f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80128c:	c1 e8 0c             	shr    $0xc,%eax
  80128f:	50                   	push   %eax
  801290:	e8 36 ff ff ff       	call   8011cb <fd_lookup>
  801295:	83 c4 08             	add    $0x8,%esp
  801298:	85 c0                	test   %eax,%eax
  80129a:	78 05                	js     8012a1 <fd_close+0x2d>
	    || fd != fd2)
  80129c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80129f:	74 0c                	je     8012ad <fd_close+0x39>
		return (must_exist ? r : 0);
  8012a1:	84 db                	test   %bl,%bl
  8012a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a8:	0f 44 c2             	cmove  %edx,%eax
  8012ab:	eb 41                	jmp    8012ee <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	ff 36                	pushl  (%esi)
  8012b6:	e8 66 ff ff ff       	call   801221 <dev_lookup>
  8012bb:	89 c3                	mov    %eax,%ebx
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 1a                	js     8012de <fd_close+0x6a>
		if (dev->dev_close)
  8012c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012ca:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	74 0b                	je     8012de <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012d3:	83 ec 0c             	sub    $0xc,%esp
  8012d6:	56                   	push   %esi
  8012d7:	ff d0                	call   *%eax
  8012d9:	89 c3                	mov    %eax,%ebx
  8012db:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	56                   	push   %esi
  8012e2:	6a 00                	push   $0x0
  8012e4:	e8 e1 fc ff ff       	call   800fca <sys_page_unmap>
	return r;
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	89 d8                	mov    %ebx,%eax
}
  8012ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f1:	5b                   	pop    %ebx
  8012f2:	5e                   	pop    %esi
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fe:	50                   	push   %eax
  8012ff:	ff 75 08             	pushl  0x8(%ebp)
  801302:	e8 c4 fe ff ff       	call   8011cb <fd_lookup>
  801307:	83 c4 08             	add    $0x8,%esp
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 10                	js     80131e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	6a 01                	push   $0x1
  801313:	ff 75 f4             	pushl  -0xc(%ebp)
  801316:	e8 59 ff ff ff       	call   801274 <fd_close>
  80131b:	83 c4 10             	add    $0x10,%esp
}
  80131e:	c9                   	leave  
  80131f:	c3                   	ret    

00801320 <close_all>:

void
close_all(void)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	53                   	push   %ebx
  801324:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801327:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80132c:	83 ec 0c             	sub    $0xc,%esp
  80132f:	53                   	push   %ebx
  801330:	e8 c0 ff ff ff       	call   8012f5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801335:	83 c3 01             	add    $0x1,%ebx
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	83 fb 20             	cmp    $0x20,%ebx
  80133e:	75 ec                	jne    80132c <close_all+0xc>
		close(i);
}
  801340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	57                   	push   %edi
  801349:	56                   	push   %esi
  80134a:	53                   	push   %ebx
  80134b:	83 ec 2c             	sub    $0x2c,%esp
  80134e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801351:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	ff 75 08             	pushl  0x8(%ebp)
  801358:	e8 6e fe ff ff       	call   8011cb <fd_lookup>
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	85 c0                	test   %eax,%eax
  801362:	0f 88 c1 00 00 00    	js     801429 <dup+0xe4>
		return r;
	close(newfdnum);
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	56                   	push   %esi
  80136c:	e8 84 ff ff ff       	call   8012f5 <close>

	newfd = INDEX2FD(newfdnum);
  801371:	89 f3                	mov    %esi,%ebx
  801373:	c1 e3 0c             	shl    $0xc,%ebx
  801376:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80137c:	83 c4 04             	add    $0x4,%esp
  80137f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801382:	e8 de fd ff ff       	call   801165 <fd2data>
  801387:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801389:	89 1c 24             	mov    %ebx,(%esp)
  80138c:	e8 d4 fd ff ff       	call   801165 <fd2data>
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801397:	89 f8                	mov    %edi,%eax
  801399:	c1 e8 16             	shr    $0x16,%eax
  80139c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a3:	a8 01                	test   $0x1,%al
  8013a5:	74 37                	je     8013de <dup+0x99>
  8013a7:	89 f8                	mov    %edi,%eax
  8013a9:	c1 e8 0c             	shr    $0xc,%eax
  8013ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b3:	f6 c2 01             	test   $0x1,%dl
  8013b6:	74 26                	je     8013de <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bf:	83 ec 0c             	sub    $0xc,%esp
  8013c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c7:	50                   	push   %eax
  8013c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013cb:	6a 00                	push   $0x0
  8013cd:	57                   	push   %edi
  8013ce:	6a 00                	push   $0x0
  8013d0:	e8 b3 fb ff ff       	call   800f88 <sys_page_map>
  8013d5:	89 c7                	mov    %eax,%edi
  8013d7:	83 c4 20             	add    $0x20,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 2e                	js     80140c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013e1:	89 d0                	mov    %edx,%eax
  8013e3:	c1 e8 0c             	shr    $0xc,%eax
  8013e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f5:	50                   	push   %eax
  8013f6:	53                   	push   %ebx
  8013f7:	6a 00                	push   $0x0
  8013f9:	52                   	push   %edx
  8013fa:	6a 00                	push   $0x0
  8013fc:	e8 87 fb ff ff       	call   800f88 <sys_page_map>
  801401:	89 c7                	mov    %eax,%edi
  801403:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801406:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801408:	85 ff                	test   %edi,%edi
  80140a:	79 1d                	jns    801429 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	53                   	push   %ebx
  801410:	6a 00                	push   $0x0
  801412:	e8 b3 fb ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  801417:	83 c4 08             	add    $0x8,%esp
  80141a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80141d:	6a 00                	push   $0x0
  80141f:	e8 a6 fb ff ff       	call   800fca <sys_page_unmap>
	return r;
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	89 f8                	mov    %edi,%eax
}
  801429:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5f                   	pop    %edi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	53                   	push   %ebx
  801435:	83 ec 14             	sub    $0x14,%esp
  801438:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143e:	50                   	push   %eax
  80143f:	53                   	push   %ebx
  801440:	e8 86 fd ff ff       	call   8011cb <fd_lookup>
  801445:	83 c4 08             	add    $0x8,%esp
  801448:	89 c2                	mov    %eax,%edx
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 6d                	js     8014bb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801458:	ff 30                	pushl  (%eax)
  80145a:	e8 c2 fd ff ff       	call   801221 <dev_lookup>
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 4c                	js     8014b2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801466:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801469:	8b 42 08             	mov    0x8(%edx),%eax
  80146c:	83 e0 03             	and    $0x3,%eax
  80146f:	83 f8 01             	cmp    $0x1,%eax
  801472:	75 21                	jne    801495 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801474:	a1 18 40 80 00       	mov    0x804018,%eax
  801479:	8b 40 48             	mov    0x48(%eax),%eax
  80147c:	83 ec 04             	sub    $0x4,%esp
  80147f:	53                   	push   %ebx
  801480:	50                   	push   %eax
  801481:	68 6d 2b 80 00       	push   $0x802b6d
  801486:	e8 12 f1 ff ff       	call   80059d <cprintf>
		return -E_INVAL;
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801493:	eb 26                	jmp    8014bb <read+0x8a>
	}
	if (!dev->dev_read)
  801495:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801498:	8b 40 08             	mov    0x8(%eax),%eax
  80149b:	85 c0                	test   %eax,%eax
  80149d:	74 17                	je     8014b6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80149f:	83 ec 04             	sub    $0x4,%esp
  8014a2:	ff 75 10             	pushl  0x10(%ebp)
  8014a5:	ff 75 0c             	pushl  0xc(%ebp)
  8014a8:	52                   	push   %edx
  8014a9:	ff d0                	call   *%eax
  8014ab:	89 c2                	mov    %eax,%edx
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	eb 09                	jmp    8014bb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b2:	89 c2                	mov    %eax,%edx
  8014b4:	eb 05                	jmp    8014bb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014bb:	89 d0                	mov    %edx,%eax
  8014bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c0:	c9                   	leave  
  8014c1:	c3                   	ret    

008014c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	57                   	push   %edi
  8014c6:	56                   	push   %esi
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 0c             	sub    $0xc,%esp
  8014cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d6:	eb 21                	jmp    8014f9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	89 f0                	mov    %esi,%eax
  8014dd:	29 d8                	sub    %ebx,%eax
  8014df:	50                   	push   %eax
  8014e0:	89 d8                	mov    %ebx,%eax
  8014e2:	03 45 0c             	add    0xc(%ebp),%eax
  8014e5:	50                   	push   %eax
  8014e6:	57                   	push   %edi
  8014e7:	e8 45 ff ff ff       	call   801431 <read>
		if (m < 0)
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 10                	js     801503 <readn+0x41>
			return m;
		if (m == 0)
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	74 0a                	je     801501 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f7:	01 c3                	add    %eax,%ebx
  8014f9:	39 f3                	cmp    %esi,%ebx
  8014fb:	72 db                	jb     8014d8 <readn+0x16>
  8014fd:	89 d8                	mov    %ebx,%eax
  8014ff:	eb 02                	jmp    801503 <readn+0x41>
  801501:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801503:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801506:	5b                   	pop    %ebx
  801507:	5e                   	pop    %esi
  801508:	5f                   	pop    %edi
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	53                   	push   %ebx
  80150f:	83 ec 14             	sub    $0x14,%esp
  801512:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801515:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	53                   	push   %ebx
  80151a:	e8 ac fc ff ff       	call   8011cb <fd_lookup>
  80151f:	83 c4 08             	add    $0x8,%esp
  801522:	89 c2                	mov    %eax,%edx
  801524:	85 c0                	test   %eax,%eax
  801526:	78 68                	js     801590 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152e:	50                   	push   %eax
  80152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801532:	ff 30                	pushl  (%eax)
  801534:	e8 e8 fc ff ff       	call   801221 <dev_lookup>
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 47                	js     801587 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801540:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801543:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801547:	75 21                	jne    80156a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801549:	a1 18 40 80 00       	mov    0x804018,%eax
  80154e:	8b 40 48             	mov    0x48(%eax),%eax
  801551:	83 ec 04             	sub    $0x4,%esp
  801554:	53                   	push   %ebx
  801555:	50                   	push   %eax
  801556:	68 89 2b 80 00       	push   $0x802b89
  80155b:	e8 3d f0 ff ff       	call   80059d <cprintf>
		return -E_INVAL;
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801568:	eb 26                	jmp    801590 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80156a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156d:	8b 52 0c             	mov    0xc(%edx),%edx
  801570:	85 d2                	test   %edx,%edx
  801572:	74 17                	je     80158b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801574:	83 ec 04             	sub    $0x4,%esp
  801577:	ff 75 10             	pushl  0x10(%ebp)
  80157a:	ff 75 0c             	pushl  0xc(%ebp)
  80157d:	50                   	push   %eax
  80157e:	ff d2                	call   *%edx
  801580:	89 c2                	mov    %eax,%edx
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	eb 09                	jmp    801590 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801587:	89 c2                	mov    %eax,%edx
  801589:	eb 05                	jmp    801590 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80158b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801590:	89 d0                	mov    %edx,%eax
  801592:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <seek>:

int
seek(int fdnum, off_t offset)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	ff 75 08             	pushl  0x8(%ebp)
  8015a4:	e8 22 fc ff ff       	call   8011cb <fd_lookup>
  8015a9:	83 c4 08             	add    $0x8,%esp
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 0e                	js     8015be <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	53                   	push   %ebx
  8015c4:	83 ec 14             	sub    $0x14,%esp
  8015c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cd:	50                   	push   %eax
  8015ce:	53                   	push   %ebx
  8015cf:	e8 f7 fb ff ff       	call   8011cb <fd_lookup>
  8015d4:	83 c4 08             	add    $0x8,%esp
  8015d7:	89 c2                	mov    %eax,%edx
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 65                	js     801642 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e3:	50                   	push   %eax
  8015e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e7:	ff 30                	pushl  (%eax)
  8015e9:	e8 33 fc ff ff       	call   801221 <dev_lookup>
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 44                	js     801639 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015fc:	75 21                	jne    80161f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015fe:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801603:	8b 40 48             	mov    0x48(%eax),%eax
  801606:	83 ec 04             	sub    $0x4,%esp
  801609:	53                   	push   %ebx
  80160a:	50                   	push   %eax
  80160b:	68 4c 2b 80 00       	push   $0x802b4c
  801610:	e8 88 ef ff ff       	call   80059d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80161d:	eb 23                	jmp    801642 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80161f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801622:	8b 52 18             	mov    0x18(%edx),%edx
  801625:	85 d2                	test   %edx,%edx
  801627:	74 14                	je     80163d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	ff 75 0c             	pushl  0xc(%ebp)
  80162f:	50                   	push   %eax
  801630:	ff d2                	call   *%edx
  801632:	89 c2                	mov    %eax,%edx
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	eb 09                	jmp    801642 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801639:	89 c2                	mov    %eax,%edx
  80163b:	eb 05                	jmp    801642 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80163d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801642:	89 d0                	mov    %edx,%eax
  801644:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	53                   	push   %ebx
  80164d:	83 ec 14             	sub    $0x14,%esp
  801650:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801653:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	ff 75 08             	pushl  0x8(%ebp)
  80165a:	e8 6c fb ff ff       	call   8011cb <fd_lookup>
  80165f:	83 c4 08             	add    $0x8,%esp
  801662:	89 c2                	mov    %eax,%edx
  801664:	85 c0                	test   %eax,%eax
  801666:	78 58                	js     8016c0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801672:	ff 30                	pushl  (%eax)
  801674:	e8 a8 fb ff ff       	call   801221 <dev_lookup>
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 37                	js     8016b7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801680:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801683:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801687:	74 32                	je     8016bb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801689:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80168c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801693:	00 00 00 
	stat->st_isdir = 0;
  801696:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80169d:	00 00 00 
	stat->st_dev = dev;
  8016a0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	53                   	push   %ebx
  8016aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ad:	ff 50 14             	call   *0x14(%eax)
  8016b0:	89 c2                	mov    %eax,%edx
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	eb 09                	jmp    8016c0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	eb 05                	jmp    8016c0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016c0:	89 d0                	mov    %edx,%eax
  8016c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	56                   	push   %esi
  8016cb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016cc:	83 ec 08             	sub    $0x8,%esp
  8016cf:	6a 00                	push   $0x0
  8016d1:	ff 75 08             	pushl  0x8(%ebp)
  8016d4:	e8 ef 01 00 00       	call   8018c8 <open>
  8016d9:	89 c3                	mov    %eax,%ebx
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 1b                	js     8016fd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	ff 75 0c             	pushl  0xc(%ebp)
  8016e8:	50                   	push   %eax
  8016e9:	e8 5b ff ff ff       	call   801649 <fstat>
  8016ee:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f0:	89 1c 24             	mov    %ebx,(%esp)
  8016f3:	e8 fd fb ff ff       	call   8012f5 <close>
	return r;
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	89 f0                	mov    %esi,%eax
}
  8016fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801700:	5b                   	pop    %ebx
  801701:	5e                   	pop    %esi
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    

00801704 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	56                   	push   %esi
  801708:	53                   	push   %ebx
  801709:	89 c6                	mov    %eax,%esi
  80170b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80170d:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  801714:	75 12                	jne    801728 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801716:	83 ec 0c             	sub    $0xc,%esp
  801719:	6a 01                	push   $0x1
  80171b:	e8 9d 0c 00 00       	call   8023bd <ipc_find_env>
  801720:	a3 10 40 80 00       	mov    %eax,0x804010
  801725:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801728:	6a 07                	push   $0x7
  80172a:	68 00 50 80 00       	push   $0x805000
  80172f:	56                   	push   %esi
  801730:	ff 35 10 40 80 00    	pushl  0x804010
  801736:	e8 33 0c 00 00       	call   80236e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80173b:	83 c4 0c             	add    $0xc,%esp
  80173e:	6a 00                	push   $0x0
  801740:	53                   	push   %ebx
  801741:	6a 00                	push   $0x0
  801743:	e8 b0 0b 00 00       	call   8022f8 <ipc_recv>
}
  801748:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174b:	5b                   	pop    %ebx
  80174c:	5e                   	pop    %esi
  80174d:	5d                   	pop    %ebp
  80174e:	c3                   	ret    

0080174f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801755:	8b 45 08             	mov    0x8(%ebp),%eax
  801758:	8b 40 0c             	mov    0xc(%eax),%eax
  80175b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801760:	8b 45 0c             	mov    0xc(%ebp),%eax
  801763:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801768:	ba 00 00 00 00       	mov    $0x0,%edx
  80176d:	b8 02 00 00 00       	mov    $0x2,%eax
  801772:	e8 8d ff ff ff       	call   801704 <fsipc>
}
  801777:	c9                   	leave  
  801778:	c3                   	ret    

00801779 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
  801782:	8b 40 0c             	mov    0xc(%eax),%eax
  801785:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80178a:	ba 00 00 00 00       	mov    $0x0,%edx
  80178f:	b8 06 00 00 00       	mov    $0x6,%eax
  801794:	e8 6b ff ff ff       	call   801704 <fsipc>
}
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	53                   	push   %ebx
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ab:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ba:	e8 45 ff ff ff       	call   801704 <fsipc>
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	78 2c                	js     8017ef <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c3:	83 ec 08             	sub    $0x8,%esp
  8017c6:	68 00 50 80 00       	push   $0x805000
  8017cb:	53                   	push   %ebx
  8017cc:	e8 71 f3 ff ff       	call   800b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d1:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017dc:	a1 84 50 80 00       	mov    0x805084,%eax
  8017e1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    

008017f4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 08             	sub    $0x8,%esp
  8017fb:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801801:	8b 52 0c             	mov    0xc(%edx),%edx
  801804:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80180a:	a3 04 50 80 00       	mov    %eax,0x805004
  80180f:	3d 08 50 80 00       	cmp    $0x805008,%eax
  801814:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801819:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  80181c:	53                   	push   %ebx
  80181d:	ff 75 0c             	pushl  0xc(%ebp)
  801820:	68 08 50 80 00       	push   $0x805008
  801825:	e8 aa f4 ff ff       	call   800cd4 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80182a:	ba 00 00 00 00       	mov    $0x0,%edx
  80182f:	b8 04 00 00 00       	mov    $0x4,%eax
  801834:	e8 cb fe ff ff       	call   801704 <fsipc>
  801839:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  80183c:	85 c0                	test   %eax,%eax
  80183e:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801841:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80184e:	8b 45 08             	mov    0x8(%ebp),%eax
  801851:	8b 40 0c             	mov    0xc(%eax),%eax
  801854:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801859:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80185f:	ba 00 00 00 00       	mov    $0x0,%edx
  801864:	b8 03 00 00 00       	mov    $0x3,%eax
  801869:	e8 96 fe ff ff       	call   801704 <fsipc>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	85 c0                	test   %eax,%eax
  801872:	78 4b                	js     8018bf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801874:	39 c6                	cmp    %eax,%esi
  801876:	73 16                	jae    80188e <devfile_read+0x48>
  801878:	68 bc 2b 80 00       	push   $0x802bbc
  80187d:	68 c3 2b 80 00       	push   $0x802bc3
  801882:	6a 7c                	push   $0x7c
  801884:	68 d8 2b 80 00       	push   $0x802bd8
  801889:	e8 24 0a 00 00       	call   8022b2 <_panic>
	assert(r <= PGSIZE);
  80188e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801893:	7e 16                	jle    8018ab <devfile_read+0x65>
  801895:	68 e3 2b 80 00       	push   $0x802be3
  80189a:	68 c3 2b 80 00       	push   $0x802bc3
  80189f:	6a 7d                	push   $0x7d
  8018a1:	68 d8 2b 80 00       	push   $0x802bd8
  8018a6:	e8 07 0a 00 00       	call   8022b2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	50                   	push   %eax
  8018af:	68 00 50 80 00       	push   $0x805000
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	e8 18 f4 ff ff       	call   800cd4 <memmove>
	return r;
  8018bc:	83 c4 10             	add    $0x10,%esp
}
  8018bf:	89 d8                	mov    %ebx,%eax
  8018c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c4:	5b                   	pop    %ebx
  8018c5:	5e                   	pop    %esi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	53                   	push   %ebx
  8018cc:	83 ec 20             	sub    $0x20,%esp
  8018cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d2:	53                   	push   %ebx
  8018d3:	e8 31 f2 ff ff       	call   800b09 <strlen>
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e0:	7f 67                	jg     801949 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e8:	50                   	push   %eax
  8018e9:	e8 8e f8 ff ff       	call   80117c <fd_alloc>
  8018ee:	83 c4 10             	add    $0x10,%esp
		return r;
  8018f1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 57                	js     80194e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f7:	83 ec 08             	sub    $0x8,%esp
  8018fa:	53                   	push   %ebx
  8018fb:	68 00 50 80 00       	push   $0x805000
  801900:	e8 3d f2 ff ff       	call   800b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801905:	8b 45 0c             	mov    0xc(%ebp),%eax
  801908:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80190d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801910:	b8 01 00 00 00       	mov    $0x1,%eax
  801915:	e8 ea fd ff ff       	call   801704 <fsipc>
  80191a:	89 c3                	mov    %eax,%ebx
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	79 14                	jns    801937 <open+0x6f>
		fd_close(fd, 0);
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	6a 00                	push   $0x0
  801928:	ff 75 f4             	pushl  -0xc(%ebp)
  80192b:	e8 44 f9 ff ff       	call   801274 <fd_close>
		return r;
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	89 da                	mov    %ebx,%edx
  801935:	eb 17                	jmp    80194e <open+0x86>
	}

	return fd2num(fd);
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	ff 75 f4             	pushl  -0xc(%ebp)
  80193d:	e8 13 f8 ff ff       	call   801155 <fd2num>
  801942:	89 c2                	mov    %eax,%edx
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	eb 05                	jmp    80194e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801949:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80194e:	89 d0                	mov    %edx,%eax
  801950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195b:	ba 00 00 00 00       	mov    $0x0,%edx
  801960:	b8 08 00 00 00       	mov    $0x8,%eax
  801965:	e8 9a fd ff ff       	call   801704 <fsipc>
}
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	ff 75 08             	pushl  0x8(%ebp)
  80197a:	e8 e6 f7 ff ff       	call   801165 <fd2data>
  80197f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801981:	83 c4 08             	add    $0x8,%esp
  801984:	68 ef 2b 80 00       	push   $0x802bef
  801989:	53                   	push   %ebx
  80198a:	e8 b3 f1 ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80198f:	8b 46 04             	mov    0x4(%esi),%eax
  801992:	2b 06                	sub    (%esi),%eax
  801994:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80199a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019a1:	00 00 00 
	stat->st_dev = &devpipe;
  8019a4:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8019ab:	30 80 00 
	return 0;
}
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5e                   	pop    %esi
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	53                   	push   %ebx
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c4:	53                   	push   %ebx
  8019c5:	6a 00                	push   $0x0
  8019c7:	e8 fe f5 ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019cc:	89 1c 24             	mov    %ebx,(%esp)
  8019cf:	e8 91 f7 ff ff       	call   801165 <fd2data>
  8019d4:	83 c4 08             	add    $0x8,%esp
  8019d7:	50                   	push   %eax
  8019d8:	6a 00                	push   $0x0
  8019da:	e8 eb f5 ff ff       	call   800fca <sys_page_unmap>
}
  8019df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	57                   	push   %edi
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
  8019ea:	83 ec 1c             	sub    $0x1c,%esp
  8019ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019f0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019f2:	a1 18 40 80 00       	mov    0x804018,%eax
  8019f7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	ff 75 e0             	pushl  -0x20(%ebp)
  801a00:	e8 f1 09 00 00       	call   8023f6 <pageref>
  801a05:	89 c3                	mov    %eax,%ebx
  801a07:	89 3c 24             	mov    %edi,(%esp)
  801a0a:	e8 e7 09 00 00       	call   8023f6 <pageref>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	39 c3                	cmp    %eax,%ebx
  801a14:	0f 94 c1             	sete   %cl
  801a17:	0f b6 c9             	movzbl %cl,%ecx
  801a1a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a1d:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801a23:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a26:	39 ce                	cmp    %ecx,%esi
  801a28:	74 1b                	je     801a45 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a2a:	39 c3                	cmp    %eax,%ebx
  801a2c:	75 c4                	jne    8019f2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a2e:	8b 42 58             	mov    0x58(%edx),%eax
  801a31:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a34:	50                   	push   %eax
  801a35:	56                   	push   %esi
  801a36:	68 f6 2b 80 00       	push   $0x802bf6
  801a3b:	e8 5d eb ff ff       	call   80059d <cprintf>
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	eb ad                	jmp    8019f2 <_pipeisclosed+0xe>
	}
}
  801a45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5e                   	pop    %esi
  801a4d:	5f                   	pop    %edi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	57                   	push   %edi
  801a54:	56                   	push   %esi
  801a55:	53                   	push   %ebx
  801a56:	83 ec 28             	sub    $0x28,%esp
  801a59:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a5c:	56                   	push   %esi
  801a5d:	e8 03 f7 ff ff       	call   801165 <fd2data>
  801a62:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	bf 00 00 00 00       	mov    $0x0,%edi
  801a6c:	eb 4b                	jmp    801ab9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a6e:	89 da                	mov    %ebx,%edx
  801a70:	89 f0                	mov    %esi,%eax
  801a72:	e8 6d ff ff ff       	call   8019e4 <_pipeisclosed>
  801a77:	85 c0                	test   %eax,%eax
  801a79:	75 48                	jne    801ac3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a7b:	e8 a6 f4 ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a80:	8b 43 04             	mov    0x4(%ebx),%eax
  801a83:	8b 0b                	mov    (%ebx),%ecx
  801a85:	8d 51 20             	lea    0x20(%ecx),%edx
  801a88:	39 d0                	cmp    %edx,%eax
  801a8a:	73 e2                	jae    801a6e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a93:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a96:	89 c2                	mov    %eax,%edx
  801a98:	c1 fa 1f             	sar    $0x1f,%edx
  801a9b:	89 d1                	mov    %edx,%ecx
  801a9d:	c1 e9 1b             	shr    $0x1b,%ecx
  801aa0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aa3:	83 e2 1f             	and    $0x1f,%edx
  801aa6:	29 ca                	sub    %ecx,%edx
  801aa8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ab0:	83 c0 01             	add    $0x1,%eax
  801ab3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab6:	83 c7 01             	add    $0x1,%edi
  801ab9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801abc:	75 c2                	jne    801a80 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801abe:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac1:	eb 05                	jmp    801ac8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ac8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5f                   	pop    %edi
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    

00801ad0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	57                   	push   %edi
  801ad4:	56                   	push   %esi
  801ad5:	53                   	push   %ebx
  801ad6:	83 ec 18             	sub    $0x18,%esp
  801ad9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801adc:	57                   	push   %edi
  801add:	e8 83 f6 ff ff       	call   801165 <fd2data>
  801ae2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aec:	eb 3d                	jmp    801b2b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aee:	85 db                	test   %ebx,%ebx
  801af0:	74 04                	je     801af6 <devpipe_read+0x26>
				return i;
  801af2:	89 d8                	mov    %ebx,%eax
  801af4:	eb 44                	jmp    801b3a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801af6:	89 f2                	mov    %esi,%edx
  801af8:	89 f8                	mov    %edi,%eax
  801afa:	e8 e5 fe ff ff       	call   8019e4 <_pipeisclosed>
  801aff:	85 c0                	test   %eax,%eax
  801b01:	75 32                	jne    801b35 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b03:	e8 1e f4 ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b08:	8b 06                	mov    (%esi),%eax
  801b0a:	3b 46 04             	cmp    0x4(%esi),%eax
  801b0d:	74 df                	je     801aee <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b0f:	99                   	cltd   
  801b10:	c1 ea 1b             	shr    $0x1b,%edx
  801b13:	01 d0                	add    %edx,%eax
  801b15:	83 e0 1f             	and    $0x1f,%eax
  801b18:	29 d0                	sub    %edx,%eax
  801b1a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b22:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b25:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b28:	83 c3 01             	add    $0x1,%ebx
  801b2b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b2e:	75 d8                	jne    801b08 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b30:	8b 45 10             	mov    0x10(%ebp),%eax
  801b33:	eb 05                	jmp    801b3a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b35:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3d:	5b                   	pop    %ebx
  801b3e:	5e                   	pop    %esi
  801b3f:	5f                   	pop    %edi
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    

00801b42 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	56                   	push   %esi
  801b46:	53                   	push   %ebx
  801b47:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4d:	50                   	push   %eax
  801b4e:	e8 29 f6 ff ff       	call   80117c <fd_alloc>
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	89 c2                	mov    %eax,%edx
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	0f 88 2c 01 00 00    	js     801c8c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b60:	83 ec 04             	sub    $0x4,%esp
  801b63:	68 07 04 00 00       	push   $0x407
  801b68:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6b:	6a 00                	push   $0x0
  801b6d:	e8 d3 f3 ff ff       	call   800f45 <sys_page_alloc>
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	89 c2                	mov    %eax,%edx
  801b77:	85 c0                	test   %eax,%eax
  801b79:	0f 88 0d 01 00 00    	js     801c8c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b7f:	83 ec 0c             	sub    $0xc,%esp
  801b82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b85:	50                   	push   %eax
  801b86:	e8 f1 f5 ff ff       	call   80117c <fd_alloc>
  801b8b:	89 c3                	mov    %eax,%ebx
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	85 c0                	test   %eax,%eax
  801b92:	0f 88 e2 00 00 00    	js     801c7a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b98:	83 ec 04             	sub    $0x4,%esp
  801b9b:	68 07 04 00 00       	push   $0x407
  801ba0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba3:	6a 00                	push   $0x0
  801ba5:	e8 9b f3 ff ff       	call   800f45 <sys_page_alloc>
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	0f 88 c3 00 00 00    	js     801c7a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bb7:	83 ec 0c             	sub    $0xc,%esp
  801bba:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbd:	e8 a3 f5 ff ff       	call   801165 <fd2data>
  801bc2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc4:	83 c4 0c             	add    $0xc,%esp
  801bc7:	68 07 04 00 00       	push   $0x407
  801bcc:	50                   	push   %eax
  801bcd:	6a 00                	push   $0x0
  801bcf:	e8 71 f3 ff ff       	call   800f45 <sys_page_alloc>
  801bd4:	89 c3                	mov    %eax,%ebx
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	0f 88 89 00 00 00    	js     801c6a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	ff 75 f0             	pushl  -0x10(%ebp)
  801be7:	e8 79 f5 ff ff       	call   801165 <fd2data>
  801bec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bf3:	50                   	push   %eax
  801bf4:	6a 00                	push   $0x0
  801bf6:	56                   	push   %esi
  801bf7:	6a 00                	push   $0x0
  801bf9:	e8 8a f3 ff ff       	call   800f88 <sys_page_map>
  801bfe:	89 c3                	mov    %eax,%ebx
  801c00:	83 c4 20             	add    $0x20,%esp
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 55                	js     801c5c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c07:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c10:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c15:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c1c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c25:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c31:	83 ec 0c             	sub    $0xc,%esp
  801c34:	ff 75 f4             	pushl  -0xc(%ebp)
  801c37:	e8 19 f5 ff ff       	call   801155 <fd2num>
  801c3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c3f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c41:	83 c4 04             	add    $0x4,%esp
  801c44:	ff 75 f0             	pushl  -0x10(%ebp)
  801c47:	e8 09 f5 ff ff       	call   801155 <fd2num>
  801c4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5a:	eb 30                	jmp    801c8c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c5c:	83 ec 08             	sub    $0x8,%esp
  801c5f:	56                   	push   %esi
  801c60:	6a 00                	push   $0x0
  801c62:	e8 63 f3 ff ff       	call   800fca <sys_page_unmap>
  801c67:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c6a:	83 ec 08             	sub    $0x8,%esp
  801c6d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c70:	6a 00                	push   $0x0
  801c72:	e8 53 f3 ff ff       	call   800fca <sys_page_unmap>
  801c77:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c7a:	83 ec 08             	sub    $0x8,%esp
  801c7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c80:	6a 00                	push   $0x0
  801c82:	e8 43 f3 ff ff       	call   800fca <sys_page_unmap>
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c8c:	89 d0                	mov    %edx,%eax
  801c8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c91:	5b                   	pop    %ebx
  801c92:	5e                   	pop    %esi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9e:	50                   	push   %eax
  801c9f:	ff 75 08             	pushl  0x8(%ebp)
  801ca2:	e8 24 f5 ff ff       	call   8011cb <fd_lookup>
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	78 18                	js     801cc6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cae:	83 ec 0c             	sub    $0xc,%esp
  801cb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb4:	e8 ac f4 ff ff       	call   801165 <fd2data>
	return _pipeisclosed(fd, p);
  801cb9:	89 c2                	mov    %eax,%edx
  801cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbe:	e8 21 fd ff ff       	call   8019e4 <_pipeisclosed>
  801cc3:	83 c4 10             	add    $0x10,%esp
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801cce:	68 0e 2c 80 00       	push   $0x802c0e
  801cd3:	ff 75 0c             	pushl  0xc(%ebp)
  801cd6:	e8 67 ee ff ff       	call   800b42 <strcpy>
	return 0;
}
  801cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    

00801ce2 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 10             	sub    $0x10,%esp
  801ce9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cec:	53                   	push   %ebx
  801ced:	e8 04 07 00 00       	call   8023f6 <pageref>
  801cf2:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801cf5:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801cfa:	83 f8 01             	cmp    $0x1,%eax
  801cfd:	75 10                	jne    801d0f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801cff:	83 ec 0c             	sub    $0xc,%esp
  801d02:	ff 73 0c             	pushl  0xc(%ebx)
  801d05:	e8 c0 02 00 00       	call   801fca <nsipc_close>
  801d0a:	89 c2                	mov    %eax,%edx
  801d0c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801d0f:	89 d0                	mov    %edx,%eax
  801d11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d14:	c9                   	leave  
  801d15:	c3                   	ret    

00801d16 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d1c:	6a 00                	push   $0x0
  801d1e:	ff 75 10             	pushl  0x10(%ebp)
  801d21:	ff 75 0c             	pushl  0xc(%ebp)
  801d24:	8b 45 08             	mov    0x8(%ebp),%eax
  801d27:	ff 70 0c             	pushl  0xc(%eax)
  801d2a:	e8 78 03 00 00       	call   8020a7 <nsipc_send>
}
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d37:	6a 00                	push   $0x0
  801d39:	ff 75 10             	pushl  0x10(%ebp)
  801d3c:	ff 75 0c             	pushl  0xc(%ebp)
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	ff 70 0c             	pushl  0xc(%eax)
  801d45:	e8 f1 02 00 00       	call   80203b <nsipc_recv>
}
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d52:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d55:	52                   	push   %edx
  801d56:	50                   	push   %eax
  801d57:	e8 6f f4 ff ff       	call   8011cb <fd_lookup>
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	78 17                	js     801d7a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d66:	8b 0d 40 30 80 00    	mov    0x803040,%ecx
  801d6c:	39 08                	cmp    %ecx,(%eax)
  801d6e:	75 05                	jne    801d75 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d70:	8b 40 0c             	mov    0xc(%eax),%eax
  801d73:	eb 05                	jmp    801d7a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d75:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	56                   	push   %esi
  801d80:	53                   	push   %ebx
  801d81:	83 ec 1c             	sub    $0x1c,%esp
  801d84:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d89:	50                   	push   %eax
  801d8a:	e8 ed f3 ff ff       	call   80117c <fd_alloc>
  801d8f:	89 c3                	mov    %eax,%ebx
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	85 c0                	test   %eax,%eax
  801d96:	78 1b                	js     801db3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d98:	83 ec 04             	sub    $0x4,%esp
  801d9b:	68 07 04 00 00       	push   $0x407
  801da0:	ff 75 f4             	pushl  -0xc(%ebp)
  801da3:	6a 00                	push   $0x0
  801da5:	e8 9b f1 ff ff       	call   800f45 <sys_page_alloc>
  801daa:	89 c3                	mov    %eax,%ebx
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	85 c0                	test   %eax,%eax
  801db1:	79 10                	jns    801dc3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	56                   	push   %esi
  801db7:	e8 0e 02 00 00       	call   801fca <nsipc_close>
		return r;
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	89 d8                	mov    %ebx,%eax
  801dc1:	eb 24                	jmp    801de7 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801dc3:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801dd8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ddb:	83 ec 0c             	sub    $0xc,%esp
  801dde:	50                   	push   %eax
  801ddf:	e8 71 f3 ff ff       	call   801155 <fd2num>
  801de4:	83 c4 10             	add    $0x10,%esp
}
  801de7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dea:	5b                   	pop    %ebx
  801deb:	5e                   	pop    %esi
  801dec:	5d                   	pop    %ebp
  801ded:	c3                   	ret    

00801dee <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	e8 50 ff ff ff       	call   801d4c <fd2sockid>
		return r;
  801dfc:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	78 1f                	js     801e21 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e02:	83 ec 04             	sub    $0x4,%esp
  801e05:	ff 75 10             	pushl  0x10(%ebp)
  801e08:	ff 75 0c             	pushl  0xc(%ebp)
  801e0b:	50                   	push   %eax
  801e0c:	e8 12 01 00 00       	call   801f23 <nsipc_accept>
  801e11:	83 c4 10             	add    $0x10,%esp
		return r;
  801e14:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e16:	85 c0                	test   %eax,%eax
  801e18:	78 07                	js     801e21 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801e1a:	e8 5d ff ff ff       	call   801d7c <alloc_sockfd>
  801e1f:	89 c1                	mov    %eax,%ecx
}
  801e21:	89 c8                	mov    %ecx,%eax
  801e23:	c9                   	leave  
  801e24:	c3                   	ret    

00801e25 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2e:	e8 19 ff ff ff       	call   801d4c <fd2sockid>
  801e33:	85 c0                	test   %eax,%eax
  801e35:	78 12                	js     801e49 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e37:	83 ec 04             	sub    $0x4,%esp
  801e3a:	ff 75 10             	pushl  0x10(%ebp)
  801e3d:	ff 75 0c             	pushl  0xc(%ebp)
  801e40:	50                   	push   %eax
  801e41:	e8 2d 01 00 00       	call   801f73 <nsipc_bind>
  801e46:	83 c4 10             	add    $0x10,%esp
}
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <shutdown>:

int
shutdown(int s, int how)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e51:	8b 45 08             	mov    0x8(%ebp),%eax
  801e54:	e8 f3 fe ff ff       	call   801d4c <fd2sockid>
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	78 0f                	js     801e6c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e5d:	83 ec 08             	sub    $0x8,%esp
  801e60:	ff 75 0c             	pushl  0xc(%ebp)
  801e63:	50                   	push   %eax
  801e64:	e8 3f 01 00 00       	call   801fa8 <nsipc_shutdown>
  801e69:	83 c4 10             	add    $0x10,%esp
}
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e74:	8b 45 08             	mov    0x8(%ebp),%eax
  801e77:	e8 d0 fe ff ff       	call   801d4c <fd2sockid>
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	78 12                	js     801e92 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e80:	83 ec 04             	sub    $0x4,%esp
  801e83:	ff 75 10             	pushl  0x10(%ebp)
  801e86:	ff 75 0c             	pushl  0xc(%ebp)
  801e89:	50                   	push   %eax
  801e8a:	e8 55 01 00 00       	call   801fe4 <nsipc_connect>
  801e8f:	83 c4 10             	add    $0x10,%esp
}
  801e92:	c9                   	leave  
  801e93:	c3                   	ret    

00801e94 <listen>:

int
listen(int s, int backlog)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9d:	e8 aa fe ff ff       	call   801d4c <fd2sockid>
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	78 0f                	js     801eb5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ea6:	83 ec 08             	sub    $0x8,%esp
  801ea9:	ff 75 0c             	pushl  0xc(%ebp)
  801eac:	50                   	push   %eax
  801ead:	e8 67 01 00 00       	call   802019 <nsipc_listen>
  801eb2:	83 c4 10             	add    $0x10,%esp
}
  801eb5:	c9                   	leave  
  801eb6:	c3                   	ret    

00801eb7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ebd:	ff 75 10             	pushl  0x10(%ebp)
  801ec0:	ff 75 0c             	pushl  0xc(%ebp)
  801ec3:	ff 75 08             	pushl  0x8(%ebp)
  801ec6:	e8 3a 02 00 00       	call   802105 <nsipc_socket>
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	78 05                	js     801ed7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ed2:	e8 a5 fe ff ff       	call   801d7c <alloc_sockfd>
}
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	53                   	push   %ebx
  801edd:	83 ec 04             	sub    $0x4,%esp
  801ee0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ee2:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801ee9:	75 12                	jne    801efd <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801eeb:	83 ec 0c             	sub    $0xc,%esp
  801eee:	6a 02                	push   $0x2
  801ef0:	e8 c8 04 00 00       	call   8023bd <ipc_find_env>
  801ef5:	a3 14 40 80 00       	mov    %eax,0x804014
  801efa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801efd:	6a 07                	push   $0x7
  801eff:	68 00 60 80 00       	push   $0x806000
  801f04:	53                   	push   %ebx
  801f05:	ff 35 14 40 80 00    	pushl  0x804014
  801f0b:	e8 5e 04 00 00       	call   80236e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f10:	83 c4 0c             	add    $0xc,%esp
  801f13:	6a 00                	push   $0x0
  801f15:	6a 00                	push   $0x0
  801f17:	6a 00                	push   $0x0
  801f19:	e8 da 03 00 00       	call   8022f8 <ipc_recv>
}
  801f1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f21:	c9                   	leave  
  801f22:	c3                   	ret    

00801f23 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	56                   	push   %esi
  801f27:	53                   	push   %ebx
  801f28:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f33:	8b 06                	mov    (%esi),%eax
  801f35:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f3a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f3f:	e8 95 ff ff ff       	call   801ed9 <nsipc>
  801f44:	89 c3                	mov    %eax,%ebx
  801f46:	85 c0                	test   %eax,%eax
  801f48:	78 20                	js     801f6a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f4a:	83 ec 04             	sub    $0x4,%esp
  801f4d:	ff 35 10 60 80 00    	pushl  0x806010
  801f53:	68 00 60 80 00       	push   $0x806000
  801f58:	ff 75 0c             	pushl  0xc(%ebp)
  801f5b:	e8 74 ed ff ff       	call   800cd4 <memmove>
		*addrlen = ret->ret_addrlen;
  801f60:	a1 10 60 80 00       	mov    0x806010,%eax
  801f65:	89 06                	mov    %eax,(%esi)
  801f67:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f6a:	89 d8                	mov    %ebx,%eax
  801f6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    

00801f73 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	53                   	push   %ebx
  801f77:	83 ec 08             	sub    $0x8,%esp
  801f7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f80:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f85:	53                   	push   %ebx
  801f86:	ff 75 0c             	pushl  0xc(%ebp)
  801f89:	68 04 60 80 00       	push   $0x806004
  801f8e:	e8 41 ed ff ff       	call   800cd4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f93:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f99:	b8 02 00 00 00       	mov    $0x2,%eax
  801f9e:	e8 36 ff ff ff       	call   801ed9 <nsipc>
}
  801fa3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fae:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801fbe:	b8 03 00 00 00       	mov    $0x3,%eax
  801fc3:	e8 11 ff ff ff       	call   801ed9 <nsipc>
}
  801fc8:	c9                   	leave  
  801fc9:	c3                   	ret    

00801fca <nsipc_close>:

int
nsipc_close(int s)
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801fd8:	b8 04 00 00 00       	mov    $0x4,%eax
  801fdd:	e8 f7 fe ff ff       	call   801ed9 <nsipc>
}
  801fe2:	c9                   	leave  
  801fe3:	c3                   	ret    

00801fe4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	53                   	push   %ebx
  801fe8:	83 ec 08             	sub    $0x8,%esp
  801feb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fee:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ff6:	53                   	push   %ebx
  801ff7:	ff 75 0c             	pushl  0xc(%ebp)
  801ffa:	68 04 60 80 00       	push   $0x806004
  801fff:	e8 d0 ec ff ff       	call   800cd4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802004:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80200a:	b8 05 00 00 00       	mov    $0x5,%eax
  80200f:	e8 c5 fe ff ff       	call   801ed9 <nsipc>
}
  802014:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802017:	c9                   	leave  
  802018:	c3                   	ret    

00802019 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80201f:	8b 45 08             	mov    0x8(%ebp),%eax
  802022:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802027:	8b 45 0c             	mov    0xc(%ebp),%eax
  80202a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80202f:	b8 06 00 00 00       	mov    $0x6,%eax
  802034:	e8 a0 fe ff ff       	call   801ed9 <nsipc>
}
  802039:	c9                   	leave  
  80203a:	c3                   	ret    

0080203b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	56                   	push   %esi
  80203f:	53                   	push   %ebx
  802040:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802043:	8b 45 08             	mov    0x8(%ebp),%eax
  802046:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80204b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802051:	8b 45 14             	mov    0x14(%ebp),%eax
  802054:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802059:	b8 07 00 00 00       	mov    $0x7,%eax
  80205e:	e8 76 fe ff ff       	call   801ed9 <nsipc>
  802063:	89 c3                	mov    %eax,%ebx
  802065:	85 c0                	test   %eax,%eax
  802067:	78 35                	js     80209e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802069:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80206e:	7f 04                	jg     802074 <nsipc_recv+0x39>
  802070:	39 c6                	cmp    %eax,%esi
  802072:	7d 16                	jge    80208a <nsipc_recv+0x4f>
  802074:	68 1a 2c 80 00       	push   $0x802c1a
  802079:	68 c3 2b 80 00       	push   $0x802bc3
  80207e:	6a 62                	push   $0x62
  802080:	68 2f 2c 80 00       	push   $0x802c2f
  802085:	e8 28 02 00 00       	call   8022b2 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80208a:	83 ec 04             	sub    $0x4,%esp
  80208d:	50                   	push   %eax
  80208e:	68 00 60 80 00       	push   $0x806000
  802093:	ff 75 0c             	pushl  0xc(%ebp)
  802096:	e8 39 ec ff ff       	call   800cd4 <memmove>
  80209b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80209e:	89 d8                	mov    %ebx,%eax
  8020a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5d                   	pop    %ebp
  8020a6:	c3                   	ret    

008020a7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
  8020aa:	53                   	push   %ebx
  8020ab:	83 ec 04             	sub    $0x4,%esp
  8020ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8020b9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020bf:	7e 16                	jle    8020d7 <nsipc_send+0x30>
  8020c1:	68 3b 2c 80 00       	push   $0x802c3b
  8020c6:	68 c3 2b 80 00       	push   $0x802bc3
  8020cb:	6a 6d                	push   $0x6d
  8020cd:	68 2f 2c 80 00       	push   $0x802c2f
  8020d2:	e8 db 01 00 00       	call   8022b2 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020d7:	83 ec 04             	sub    $0x4,%esp
  8020da:	53                   	push   %ebx
  8020db:	ff 75 0c             	pushl  0xc(%ebp)
  8020de:	68 0c 60 80 00       	push   $0x80600c
  8020e3:	e8 ec eb ff ff       	call   800cd4 <memmove>
	nsipcbuf.send.req_size = size;
  8020e8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8020f1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8020fb:	e8 d9 fd ff ff       	call   801ed9 <nsipc>
}
  802100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802103:	c9                   	leave  
  802104:	c3                   	ret    

00802105 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80210b:	8b 45 08             	mov    0x8(%ebp),%eax
  80210e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802113:	8b 45 0c             	mov    0xc(%ebp),%eax
  802116:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80211b:	8b 45 10             	mov    0x10(%ebp),%eax
  80211e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802123:	b8 09 00 00 00       	mov    $0x9,%eax
  802128:	e8 ac fd ff ff       	call   801ed9 <nsipc>
}
  80212d:	c9                   	leave  
  80212e:	c3                   	ret    

0080212f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80212f:	55                   	push   %ebp
  802130:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802132:	b8 00 00 00 00       	mov    $0x0,%eax
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    

00802139 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802139:	55                   	push   %ebp
  80213a:	89 e5                	mov    %esp,%ebp
  80213c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80213f:	68 47 2c 80 00       	push   $0x802c47
  802144:	ff 75 0c             	pushl  0xc(%ebp)
  802147:	e8 f6 e9 ff ff       	call   800b42 <strcpy>
	return 0;
}
  80214c:	b8 00 00 00 00       	mov    $0x0,%eax
  802151:	c9                   	leave  
  802152:	c3                   	ret    

00802153 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	57                   	push   %edi
  802157:	56                   	push   %esi
  802158:	53                   	push   %ebx
  802159:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80215f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802164:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80216a:	eb 2d                	jmp    802199 <devcons_write+0x46>
		m = n - tot;
  80216c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80216f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802171:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802174:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802179:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80217c:	83 ec 04             	sub    $0x4,%esp
  80217f:	53                   	push   %ebx
  802180:	03 45 0c             	add    0xc(%ebp),%eax
  802183:	50                   	push   %eax
  802184:	57                   	push   %edi
  802185:	e8 4a eb ff ff       	call   800cd4 <memmove>
		sys_cputs(buf, m);
  80218a:	83 c4 08             	add    $0x8,%esp
  80218d:	53                   	push   %ebx
  80218e:	57                   	push   %edi
  80218f:	e8 f5 ec ff ff       	call   800e89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802194:	01 de                	add    %ebx,%esi
  802196:	83 c4 10             	add    $0x10,%esp
  802199:	89 f0                	mov    %esi,%eax
  80219b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80219e:	72 cc                	jb     80216c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    

008021a8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	83 ec 08             	sub    $0x8,%esp
  8021ae:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021b7:	74 2a                	je     8021e3 <devcons_read+0x3b>
  8021b9:	eb 05                	jmp    8021c0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021bb:	e8 66 ed ff ff       	call   800f26 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021c0:	e8 e2 ec ff ff       	call   800ea7 <sys_cgetc>
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	74 f2                	je     8021bb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021c9:	85 c0                	test   %eax,%eax
  8021cb:	78 16                	js     8021e3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021cd:	83 f8 04             	cmp    $0x4,%eax
  8021d0:	74 0c                	je     8021de <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021d5:	88 02                	mov    %al,(%edx)
	return 1;
  8021d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8021dc:	eb 05                	jmp    8021e3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021de:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021e3:	c9                   	leave  
  8021e4:	c3                   	ret    

008021e5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021e5:	55                   	push   %ebp
  8021e6:	89 e5                	mov    %esp,%ebp
  8021e8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ee:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021f1:	6a 01                	push   $0x1
  8021f3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021f6:	50                   	push   %eax
  8021f7:	e8 8d ec ff ff       	call   800e89 <sys_cputs>
}
  8021fc:	83 c4 10             	add    $0x10,%esp
  8021ff:	c9                   	leave  
  802200:	c3                   	ret    

00802201 <getchar>:

int
getchar(void)
{
  802201:	55                   	push   %ebp
  802202:	89 e5                	mov    %esp,%ebp
  802204:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802207:	6a 01                	push   $0x1
  802209:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80220c:	50                   	push   %eax
  80220d:	6a 00                	push   $0x0
  80220f:	e8 1d f2 ff ff       	call   801431 <read>
	if (r < 0)
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	85 c0                	test   %eax,%eax
  802219:	78 0f                	js     80222a <getchar+0x29>
		return r;
	if (r < 1)
  80221b:	85 c0                	test   %eax,%eax
  80221d:	7e 06                	jle    802225 <getchar+0x24>
		return -E_EOF;
	return c;
  80221f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802223:	eb 05                	jmp    80222a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802225:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80222a:	c9                   	leave  
  80222b:	c3                   	ret    

0080222c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802235:	50                   	push   %eax
  802236:	ff 75 08             	pushl  0x8(%ebp)
  802239:	e8 8d ef ff ff       	call   8011cb <fd_lookup>
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	85 c0                	test   %eax,%eax
  802243:	78 11                	js     802256 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802245:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802248:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80224e:	39 10                	cmp    %edx,(%eax)
  802250:	0f 94 c0             	sete   %al
  802253:	0f b6 c0             	movzbl %al,%eax
}
  802256:	c9                   	leave  
  802257:	c3                   	ret    

00802258 <opencons>:

int
opencons(void)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80225e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802261:	50                   	push   %eax
  802262:	e8 15 ef ff ff       	call   80117c <fd_alloc>
  802267:	83 c4 10             	add    $0x10,%esp
		return r;
  80226a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80226c:	85 c0                	test   %eax,%eax
  80226e:	78 3e                	js     8022ae <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802270:	83 ec 04             	sub    $0x4,%esp
  802273:	68 07 04 00 00       	push   $0x407
  802278:	ff 75 f4             	pushl  -0xc(%ebp)
  80227b:	6a 00                	push   $0x0
  80227d:	e8 c3 ec ff ff       	call   800f45 <sys_page_alloc>
  802282:	83 c4 10             	add    $0x10,%esp
		return r;
  802285:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802287:	85 c0                	test   %eax,%eax
  802289:	78 23                	js     8022ae <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80228b:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802291:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802294:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802296:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802299:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022a0:	83 ec 0c             	sub    $0xc,%esp
  8022a3:	50                   	push   %eax
  8022a4:	e8 ac ee ff ff       	call   801155 <fd2num>
  8022a9:	89 c2                	mov    %eax,%edx
  8022ab:	83 c4 10             	add    $0x10,%esp
}
  8022ae:	89 d0                	mov    %edx,%eax
  8022b0:	c9                   	leave  
  8022b1:	c3                   	ret    

008022b2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	56                   	push   %esi
  8022b6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022b7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022ba:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8022c0:	e8 42 ec ff ff       	call   800f07 <sys_getenvid>
  8022c5:	83 ec 0c             	sub    $0xc,%esp
  8022c8:	ff 75 0c             	pushl  0xc(%ebp)
  8022cb:	ff 75 08             	pushl  0x8(%ebp)
  8022ce:	56                   	push   %esi
  8022cf:	50                   	push   %eax
  8022d0:	68 54 2c 80 00       	push   $0x802c54
  8022d5:	e8 c3 e2 ff ff       	call   80059d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022da:	83 c4 18             	add    $0x18,%esp
  8022dd:	53                   	push   %ebx
  8022de:	ff 75 10             	pushl  0x10(%ebp)
  8022e1:	e8 66 e2 ff ff       	call   80054c <vcprintf>
	cprintf("\n");
  8022e6:	c7 04 24 94 27 80 00 	movl   $0x802794,(%esp)
  8022ed:	e8 ab e2 ff ff       	call   80059d <cprintf>
  8022f2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022f5:	cc                   	int3   
  8022f6:	eb fd                	jmp    8022f5 <_panic+0x43>

008022f8 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022f8:	55                   	push   %ebp
  8022f9:	89 e5                	mov    %esp,%ebp
  8022fb:	56                   	push   %esi
  8022fc:	53                   	push   %ebx
  8022fd:	8b 75 08             	mov    0x8(%ebp),%esi
  802300:	8b 45 0c             	mov    0xc(%ebp),%eax
  802303:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  802306:	85 c0                	test   %eax,%eax
  802308:	74 0e                	je     802318 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  80230a:	83 ec 0c             	sub    $0xc,%esp
  80230d:	50                   	push   %eax
  80230e:	e8 e2 ed ff ff       	call   8010f5 <sys_ipc_recv>
  802313:	83 c4 10             	add    $0x10,%esp
  802316:	eb 10                	jmp    802328 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802318:	83 ec 0c             	sub    $0xc,%esp
  80231b:	68 00 00 c0 ee       	push   $0xeec00000
  802320:	e8 d0 ed ff ff       	call   8010f5 <sys_ipc_recv>
  802325:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  802328:	85 c0                	test   %eax,%eax
  80232a:	79 17                	jns    802343 <ipc_recv+0x4b>
		if(*from_env_store)
  80232c:	83 3e 00             	cmpl   $0x0,(%esi)
  80232f:	74 06                	je     802337 <ipc_recv+0x3f>
			*from_env_store = 0;
  802331:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  802337:	85 db                	test   %ebx,%ebx
  802339:	74 2c                	je     802367 <ipc_recv+0x6f>
			*perm_store = 0;
  80233b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802341:	eb 24                	jmp    802367 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  802343:	85 f6                	test   %esi,%esi
  802345:	74 0a                	je     802351 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  802347:	a1 18 40 80 00       	mov    0x804018,%eax
  80234c:	8b 40 74             	mov    0x74(%eax),%eax
  80234f:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802351:	85 db                	test   %ebx,%ebx
  802353:	74 0a                	je     80235f <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  802355:	a1 18 40 80 00       	mov    0x804018,%eax
  80235a:	8b 40 78             	mov    0x78(%eax),%eax
  80235d:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80235f:	a1 18 40 80 00       	mov    0x804018,%eax
  802364:	8b 40 70             	mov    0x70(%eax),%eax
}
  802367:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80236a:	5b                   	pop    %ebx
  80236b:	5e                   	pop    %esi
  80236c:	5d                   	pop    %ebp
  80236d:	c3                   	ret    

0080236e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80236e:	55                   	push   %ebp
  80236f:	89 e5                	mov    %esp,%ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	53                   	push   %ebx
  802374:	83 ec 0c             	sub    $0xc,%esp
  802377:	8b 7d 08             	mov    0x8(%ebp),%edi
  80237a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80237d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802380:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  802382:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802387:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  80238a:	e8 97 eb ff ff       	call   800f26 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  80238f:	ff 75 14             	pushl  0x14(%ebp)
  802392:	53                   	push   %ebx
  802393:	56                   	push   %esi
  802394:	57                   	push   %edi
  802395:	e8 38 ed ff ff       	call   8010d2 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  80239a:	89 c2                	mov    %eax,%edx
  80239c:	f7 d2                	not    %edx
  80239e:	c1 ea 1f             	shr    $0x1f,%edx
  8023a1:	83 c4 10             	add    $0x10,%esp
  8023a4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023a7:	0f 94 c1             	sete   %cl
  8023aa:	09 ca                	or     %ecx,%edx
  8023ac:	85 c0                	test   %eax,%eax
  8023ae:	0f 94 c0             	sete   %al
  8023b1:	38 c2                	cmp    %al,%dl
  8023b3:	77 d5                	ja     80238a <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8023b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023b8:	5b                   	pop    %ebx
  8023b9:	5e                   	pop    %esi
  8023ba:	5f                   	pop    %edi
  8023bb:	5d                   	pop    %ebp
  8023bc:	c3                   	ret    

008023bd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023bd:	55                   	push   %ebp
  8023be:	89 e5                	mov    %esp,%ebp
  8023c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023c3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023c8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023cb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023d1:	8b 52 50             	mov    0x50(%edx),%edx
  8023d4:	39 ca                	cmp    %ecx,%edx
  8023d6:	75 0d                	jne    8023e5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8023d8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023db:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023e0:	8b 40 48             	mov    0x48(%eax),%eax
  8023e3:	eb 0f                	jmp    8023f4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023e5:	83 c0 01             	add    $0x1,%eax
  8023e8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023ed:	75 d9                	jne    8023c8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023f4:	5d                   	pop    %ebp
  8023f5:	c3                   	ret    

008023f6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023f6:	55                   	push   %ebp
  8023f7:	89 e5                	mov    %esp,%ebp
  8023f9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023fc:	89 d0                	mov    %edx,%eax
  8023fe:	c1 e8 16             	shr    $0x16,%eax
  802401:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802408:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80240d:	f6 c1 01             	test   $0x1,%cl
  802410:	74 1d                	je     80242f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802412:	c1 ea 0c             	shr    $0xc,%edx
  802415:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80241c:	f6 c2 01             	test   $0x1,%dl
  80241f:	74 0e                	je     80242f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802421:	c1 ea 0c             	shr    $0xc,%edx
  802424:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80242b:	ef 
  80242c:	0f b7 c0             	movzwl %ax,%eax
}
  80242f:	5d                   	pop    %ebp
  802430:	c3                   	ret    
  802431:	66 90                	xchg   %ax,%ax
  802433:	66 90                	xchg   %ax,%ax
  802435:	66 90                	xchg   %ax,%ax
  802437:	66 90                	xchg   %ax,%ax
  802439:	66 90                	xchg   %ax,%ax
  80243b:	66 90                	xchg   %ax,%ax
  80243d:	66 90                	xchg   %ax,%ax
  80243f:	90                   	nop

00802440 <__udivdi3>:
  802440:	55                   	push   %ebp
  802441:	57                   	push   %edi
  802442:	56                   	push   %esi
  802443:	53                   	push   %ebx
  802444:	83 ec 1c             	sub    $0x1c,%esp
  802447:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80244b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80244f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802453:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802457:	85 f6                	test   %esi,%esi
  802459:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80245d:	89 ca                	mov    %ecx,%edx
  80245f:	89 f8                	mov    %edi,%eax
  802461:	75 3d                	jne    8024a0 <__udivdi3+0x60>
  802463:	39 cf                	cmp    %ecx,%edi
  802465:	0f 87 c5 00 00 00    	ja     802530 <__udivdi3+0xf0>
  80246b:	85 ff                	test   %edi,%edi
  80246d:	89 fd                	mov    %edi,%ebp
  80246f:	75 0b                	jne    80247c <__udivdi3+0x3c>
  802471:	b8 01 00 00 00       	mov    $0x1,%eax
  802476:	31 d2                	xor    %edx,%edx
  802478:	f7 f7                	div    %edi
  80247a:	89 c5                	mov    %eax,%ebp
  80247c:	89 c8                	mov    %ecx,%eax
  80247e:	31 d2                	xor    %edx,%edx
  802480:	f7 f5                	div    %ebp
  802482:	89 c1                	mov    %eax,%ecx
  802484:	89 d8                	mov    %ebx,%eax
  802486:	89 cf                	mov    %ecx,%edi
  802488:	f7 f5                	div    %ebp
  80248a:	89 c3                	mov    %eax,%ebx
  80248c:	89 d8                	mov    %ebx,%eax
  80248e:	89 fa                	mov    %edi,%edx
  802490:	83 c4 1c             	add    $0x1c,%esp
  802493:	5b                   	pop    %ebx
  802494:	5e                   	pop    %esi
  802495:	5f                   	pop    %edi
  802496:	5d                   	pop    %ebp
  802497:	c3                   	ret    
  802498:	90                   	nop
  802499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	39 ce                	cmp    %ecx,%esi
  8024a2:	77 74                	ja     802518 <__udivdi3+0xd8>
  8024a4:	0f bd fe             	bsr    %esi,%edi
  8024a7:	83 f7 1f             	xor    $0x1f,%edi
  8024aa:	0f 84 98 00 00 00    	je     802548 <__udivdi3+0x108>
  8024b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	89 c5                	mov    %eax,%ebp
  8024b9:	29 fb                	sub    %edi,%ebx
  8024bb:	d3 e6                	shl    %cl,%esi
  8024bd:	89 d9                	mov    %ebx,%ecx
  8024bf:	d3 ed                	shr    %cl,%ebp
  8024c1:	89 f9                	mov    %edi,%ecx
  8024c3:	d3 e0                	shl    %cl,%eax
  8024c5:	09 ee                	or     %ebp,%esi
  8024c7:	89 d9                	mov    %ebx,%ecx
  8024c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024cd:	89 d5                	mov    %edx,%ebp
  8024cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024d3:	d3 ed                	shr    %cl,%ebp
  8024d5:	89 f9                	mov    %edi,%ecx
  8024d7:	d3 e2                	shl    %cl,%edx
  8024d9:	89 d9                	mov    %ebx,%ecx
  8024db:	d3 e8                	shr    %cl,%eax
  8024dd:	09 c2                	or     %eax,%edx
  8024df:	89 d0                	mov    %edx,%eax
  8024e1:	89 ea                	mov    %ebp,%edx
  8024e3:	f7 f6                	div    %esi
  8024e5:	89 d5                	mov    %edx,%ebp
  8024e7:	89 c3                	mov    %eax,%ebx
  8024e9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ed:	39 d5                	cmp    %edx,%ebp
  8024ef:	72 10                	jb     802501 <__udivdi3+0xc1>
  8024f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024f5:	89 f9                	mov    %edi,%ecx
  8024f7:	d3 e6                	shl    %cl,%esi
  8024f9:	39 c6                	cmp    %eax,%esi
  8024fb:	73 07                	jae    802504 <__udivdi3+0xc4>
  8024fd:	39 d5                	cmp    %edx,%ebp
  8024ff:	75 03                	jne    802504 <__udivdi3+0xc4>
  802501:	83 eb 01             	sub    $0x1,%ebx
  802504:	31 ff                	xor    %edi,%edi
  802506:	89 d8                	mov    %ebx,%eax
  802508:	89 fa                	mov    %edi,%edx
  80250a:	83 c4 1c             	add    $0x1c,%esp
  80250d:	5b                   	pop    %ebx
  80250e:	5e                   	pop    %esi
  80250f:	5f                   	pop    %edi
  802510:	5d                   	pop    %ebp
  802511:	c3                   	ret    
  802512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802518:	31 ff                	xor    %edi,%edi
  80251a:	31 db                	xor    %ebx,%ebx
  80251c:	89 d8                	mov    %ebx,%eax
  80251e:	89 fa                	mov    %edi,%edx
  802520:	83 c4 1c             	add    $0x1c,%esp
  802523:	5b                   	pop    %ebx
  802524:	5e                   	pop    %esi
  802525:	5f                   	pop    %edi
  802526:	5d                   	pop    %ebp
  802527:	c3                   	ret    
  802528:	90                   	nop
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	89 d8                	mov    %ebx,%eax
  802532:	f7 f7                	div    %edi
  802534:	31 ff                	xor    %edi,%edi
  802536:	89 c3                	mov    %eax,%ebx
  802538:	89 d8                	mov    %ebx,%eax
  80253a:	89 fa                	mov    %edi,%edx
  80253c:	83 c4 1c             	add    $0x1c,%esp
  80253f:	5b                   	pop    %ebx
  802540:	5e                   	pop    %esi
  802541:	5f                   	pop    %edi
  802542:	5d                   	pop    %ebp
  802543:	c3                   	ret    
  802544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802548:	39 ce                	cmp    %ecx,%esi
  80254a:	72 0c                	jb     802558 <__udivdi3+0x118>
  80254c:	31 db                	xor    %ebx,%ebx
  80254e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802552:	0f 87 34 ff ff ff    	ja     80248c <__udivdi3+0x4c>
  802558:	bb 01 00 00 00       	mov    $0x1,%ebx
  80255d:	e9 2a ff ff ff       	jmp    80248c <__udivdi3+0x4c>
  802562:	66 90                	xchg   %ax,%ax
  802564:	66 90                	xchg   %ax,%ax
  802566:	66 90                	xchg   %ax,%ax
  802568:	66 90                	xchg   %ax,%ax
  80256a:	66 90                	xchg   %ax,%ax
  80256c:	66 90                	xchg   %ax,%ax
  80256e:	66 90                	xchg   %ax,%ax

00802570 <__umoddi3>:
  802570:	55                   	push   %ebp
  802571:	57                   	push   %edi
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
  802574:	83 ec 1c             	sub    $0x1c,%esp
  802577:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80257b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80257f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802583:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802587:	85 d2                	test   %edx,%edx
  802589:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80258d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802591:	89 f3                	mov    %esi,%ebx
  802593:	89 3c 24             	mov    %edi,(%esp)
  802596:	89 74 24 04          	mov    %esi,0x4(%esp)
  80259a:	75 1c                	jne    8025b8 <__umoddi3+0x48>
  80259c:	39 f7                	cmp    %esi,%edi
  80259e:	76 50                	jbe    8025f0 <__umoddi3+0x80>
  8025a0:	89 c8                	mov    %ecx,%eax
  8025a2:	89 f2                	mov    %esi,%edx
  8025a4:	f7 f7                	div    %edi
  8025a6:	89 d0                	mov    %edx,%eax
  8025a8:	31 d2                	xor    %edx,%edx
  8025aa:	83 c4 1c             	add    $0x1c,%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5f                   	pop    %edi
  8025b0:	5d                   	pop    %ebp
  8025b1:	c3                   	ret    
  8025b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025b8:	39 f2                	cmp    %esi,%edx
  8025ba:	89 d0                	mov    %edx,%eax
  8025bc:	77 52                	ja     802610 <__umoddi3+0xa0>
  8025be:	0f bd ea             	bsr    %edx,%ebp
  8025c1:	83 f5 1f             	xor    $0x1f,%ebp
  8025c4:	75 5a                	jne    802620 <__umoddi3+0xb0>
  8025c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ca:	0f 82 e0 00 00 00    	jb     8026b0 <__umoddi3+0x140>
  8025d0:	39 0c 24             	cmp    %ecx,(%esp)
  8025d3:	0f 86 d7 00 00 00    	jbe    8026b0 <__umoddi3+0x140>
  8025d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025e1:	83 c4 1c             	add    $0x1c,%esp
  8025e4:	5b                   	pop    %ebx
  8025e5:	5e                   	pop    %esi
  8025e6:	5f                   	pop    %edi
  8025e7:	5d                   	pop    %ebp
  8025e8:	c3                   	ret    
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	85 ff                	test   %edi,%edi
  8025f2:	89 fd                	mov    %edi,%ebp
  8025f4:	75 0b                	jne    802601 <__umoddi3+0x91>
  8025f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025fb:	31 d2                	xor    %edx,%edx
  8025fd:	f7 f7                	div    %edi
  8025ff:	89 c5                	mov    %eax,%ebp
  802601:	89 f0                	mov    %esi,%eax
  802603:	31 d2                	xor    %edx,%edx
  802605:	f7 f5                	div    %ebp
  802607:	89 c8                	mov    %ecx,%eax
  802609:	f7 f5                	div    %ebp
  80260b:	89 d0                	mov    %edx,%eax
  80260d:	eb 99                	jmp    8025a8 <__umoddi3+0x38>
  80260f:	90                   	nop
  802610:	89 c8                	mov    %ecx,%eax
  802612:	89 f2                	mov    %esi,%edx
  802614:	83 c4 1c             	add    $0x1c,%esp
  802617:	5b                   	pop    %ebx
  802618:	5e                   	pop    %esi
  802619:	5f                   	pop    %edi
  80261a:	5d                   	pop    %ebp
  80261b:	c3                   	ret    
  80261c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802620:	8b 34 24             	mov    (%esp),%esi
  802623:	bf 20 00 00 00       	mov    $0x20,%edi
  802628:	89 e9                	mov    %ebp,%ecx
  80262a:	29 ef                	sub    %ebp,%edi
  80262c:	d3 e0                	shl    %cl,%eax
  80262e:	89 f9                	mov    %edi,%ecx
  802630:	89 f2                	mov    %esi,%edx
  802632:	d3 ea                	shr    %cl,%edx
  802634:	89 e9                	mov    %ebp,%ecx
  802636:	09 c2                	or     %eax,%edx
  802638:	89 d8                	mov    %ebx,%eax
  80263a:	89 14 24             	mov    %edx,(%esp)
  80263d:	89 f2                	mov    %esi,%edx
  80263f:	d3 e2                	shl    %cl,%edx
  802641:	89 f9                	mov    %edi,%ecx
  802643:	89 54 24 04          	mov    %edx,0x4(%esp)
  802647:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	89 e9                	mov    %ebp,%ecx
  80264f:	89 c6                	mov    %eax,%esi
  802651:	d3 e3                	shl    %cl,%ebx
  802653:	89 f9                	mov    %edi,%ecx
  802655:	89 d0                	mov    %edx,%eax
  802657:	d3 e8                	shr    %cl,%eax
  802659:	89 e9                	mov    %ebp,%ecx
  80265b:	09 d8                	or     %ebx,%eax
  80265d:	89 d3                	mov    %edx,%ebx
  80265f:	89 f2                	mov    %esi,%edx
  802661:	f7 34 24             	divl   (%esp)
  802664:	89 d6                	mov    %edx,%esi
  802666:	d3 e3                	shl    %cl,%ebx
  802668:	f7 64 24 04          	mull   0x4(%esp)
  80266c:	39 d6                	cmp    %edx,%esi
  80266e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802672:	89 d1                	mov    %edx,%ecx
  802674:	89 c3                	mov    %eax,%ebx
  802676:	72 08                	jb     802680 <__umoddi3+0x110>
  802678:	75 11                	jne    80268b <__umoddi3+0x11b>
  80267a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80267e:	73 0b                	jae    80268b <__umoddi3+0x11b>
  802680:	2b 44 24 04          	sub    0x4(%esp),%eax
  802684:	1b 14 24             	sbb    (%esp),%edx
  802687:	89 d1                	mov    %edx,%ecx
  802689:	89 c3                	mov    %eax,%ebx
  80268b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80268f:	29 da                	sub    %ebx,%edx
  802691:	19 ce                	sbb    %ecx,%esi
  802693:	89 f9                	mov    %edi,%ecx
  802695:	89 f0                	mov    %esi,%eax
  802697:	d3 e0                	shl    %cl,%eax
  802699:	89 e9                	mov    %ebp,%ecx
  80269b:	d3 ea                	shr    %cl,%edx
  80269d:	89 e9                	mov    %ebp,%ecx
  80269f:	d3 ee                	shr    %cl,%esi
  8026a1:	09 d0                	or     %edx,%eax
  8026a3:	89 f2                	mov    %esi,%edx
  8026a5:	83 c4 1c             	add    $0x1c,%esp
  8026a8:	5b                   	pop    %ebx
  8026a9:	5e                   	pop    %esi
  8026aa:	5f                   	pop    %edi
  8026ab:	5d                   	pop    %ebp
  8026ac:	c3                   	ret    
  8026ad:	8d 76 00             	lea    0x0(%esi),%esi
  8026b0:	29 f9                	sub    %edi,%ecx
  8026b2:	19 d6                	sbb    %edx,%esi
  8026b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026bc:	e9 18 ff ff ff       	jmp    8025d9 <__umoddi3+0x69>
