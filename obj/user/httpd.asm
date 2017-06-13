
obj/user/httpd.debug:     file format elf32-i386


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
  80002c:	e8 5b 05 00 00       	call   80058c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 40 2a 80 00       	push   $0x802a40
  80003f:	e8 81 06 00 00       	call   8006c5 <cprintf>
	exit();
  800044:	e8 89 05 00 00       	call   8005d2 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	81 ec 20 04 00 00    	sub    $0x420,%esp
  80005a:	89 c3                	mov    %eax,%ebx
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005c:	68 00 02 00 00       	push   $0x200
  800061:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  800067:	50                   	push   %eax
  800068:	53                   	push   %ebx
  800069:	e8 eb 14 00 00       	call   801559 <read>
  80006e:	83 c4 10             	add    $0x10,%esp
  800071:	85 c0                	test   %eax,%eax
  800073:	79 17                	jns    80008c <handle_client+0x3e>
			panic("failed to read");
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	68 44 2a 80 00       	push   $0x802a44
  80007d:	68 04 01 00 00       	push   $0x104
  800082:	68 53 2a 80 00       	push   $0x802a53
  800087:	e8 60 05 00 00       	call   8005ec <_panic>

		memset(req, 0, sizeof(req));
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 04                	push   $0x4
  800091:	6a 00                	push   $0x0
  800093:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800096:	50                   	push   %eax
  800097:	e8 13 0d 00 00       	call   800daf <memset>

		req->sock = sock;
  80009c:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  80009f:	83 c4 0c             	add    $0xc,%esp
  8000a2:	6a 04                	push   $0x4
  8000a4:	68 60 2a 80 00       	push   $0x802a60
  8000a9:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  8000af:	50                   	push   %eax
  8000b0:	e8 85 0c 00 00       	call   800d3a <strncmp>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	0f 85 95 00 00 00    	jne    800155 <handle_client+0x107>
  8000c0:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  8000c6:	eb 03                	jmp    8000cb <handle_client+0x7d>
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
  8000c8:	83 c3 01             	add    $0x1,%ebx
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  8000cb:	f6 03 df             	testb  $0xdf,(%ebx)
  8000ce:	75 f8                	jne    8000c8 <handle_client+0x7a>
		request++;
	url_len = request - url;
  8000d0:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
  8000d6:	89 de                	mov    %ebx,%esi
  8000d8:	29 fe                	sub    %edi,%esi

	req->url = malloc(url_len + 1);
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	8d 46 01             	lea    0x1(%esi),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 1f 22 00 00       	call   802305 <malloc>
  8000e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  8000e9:	83 c4 0c             	add    $0xc,%esp
  8000ec:	56                   	push   %esi
  8000ed:	57                   	push   %edi
  8000ee:	50                   	push   %eax
  8000ef:	e8 08 0d 00 00       	call   800dfc <memmove>
	req->url[url_len] = '\0';
  8000f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000f7:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)

	// skip space
	request++;
  8000fb:	8d 73 01             	lea    0x1(%ebx),%esi
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	89 f0                	mov    %esi,%eax
  800103:	eb 03                	jmp    800108 <handle_client+0xba>

	version = request;
	while (*request && *request != '\n')
		request++;
  800105:	83 c0 01             	add    $0x1,%eax

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  800108:	0f b6 10             	movzbl (%eax),%edx
  80010b:	84 d2                	test   %dl,%dl
  80010d:	74 05                	je     800114 <handle_client+0xc6>
  80010f:	80 fa 0a             	cmp    $0xa,%dl
  800112:	75 f1                	jne    800105 <handle_client+0xb7>
		request++;
	version_len = request - version;
  800114:	29 f0                	sub    %esi,%eax
  800116:	89 c3                	mov    %eax,%ebx

	req->version = malloc(version_len + 1);
  800118:	83 ec 0c             	sub    $0xc,%esp
  80011b:	8d 40 01             	lea    0x1(%eax),%eax
  80011e:	50                   	push   %eax
  80011f:	e8 e1 21 00 00       	call   802305 <malloc>
  800124:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  800127:	83 c4 0c             	add    $0xc,%esp
  80012a:	53                   	push   %ebx
  80012b:	56                   	push   %esi
  80012c:	50                   	push   %eax
  80012d:	e8 ca 0c 00 00       	call   800dfc <memmove>
	req->version[version_len] = '\0';
  800132:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800135:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
	// if the file does not exist, send a 404 error using send_error
	// if the file is a directory, send a 404 error using send_error
	// set file_size to the size of the file

	// LAB 6: Your code here.
	panic("send_file not implemented");
  800139:	83 c4 0c             	add    $0xc,%esp
  80013c:	68 65 2a 80 00       	push   $0x802a65
  800141:	68 e2 00 00 00       	push   $0xe2
  800146:	68 53 2a 80 00       	push   $0x802a53
  80014b:	e8 9c 04 00 00       	call   8005ec <_panic>

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
		if (e->code == code)
			break;
		e++;
  800150:	83 c0 08             	add    $0x8,%eax
  800153:	eb 05                	jmp    80015a <handle_client+0x10c>
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  800155:	b8 00 40 80 00       	mov    $0x804000,%eax
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  80015a:	8b 10                	mov    (%eax),%edx
  80015c:	85 d2                	test   %edx,%edx
  80015e:	74 3e                	je     80019e <handle_client+0x150>
		if (e->code == code)
  800160:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800164:	74 08                	je     80016e <handle_client+0x120>
  800166:	81 fa 90 01 00 00    	cmp    $0x190,%edx
  80016c:	75 e2                	jne    800150 <handle_client+0x102>
	}

	if (e->code == 0)
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  80016e:	8b 40 04             	mov    0x4(%eax),%eax
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	50                   	push   %eax
  800175:	52                   	push   %edx
  800176:	50                   	push   %eax
  800177:	52                   	push   %edx
  800178:	68 b4 2a 80 00       	push   $0x802ab4
  80017d:	68 00 02 00 00       	push   $0x200
  800182:	8d b5 dc fb ff ff    	lea    -0x424(%ebp),%esi
  800188:	56                   	push   %esi
  800189:	e8 89 0a 00 00       	call   800c17 <snprintf>
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  80018e:	83 c4 1c             	add    $0x1c,%esp
  800191:	50                   	push   %eax
  800192:	56                   	push   %esi
  800193:	ff 75 dc             	pushl  -0x24(%ebp)
  800196:	e8 98 14 00 00       	call   801633 <write>
  80019b:	83 c4 10             	add    $0x10,%esp
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a4:	e8 ae 20 00 00       	call   802257 <free>
	free(req->version);
  8001a9:	83 c4 04             	add    $0x4,%esp
  8001ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001af:	e8 a3 20 00 00       	call   802257 <free>

		// no keep alive
		break;
	}

	close(sock);
  8001b4:	89 1c 24             	mov    %ebx,(%esp)
  8001b7:	e8 61 12 00 00       	call   80141d <close>
}
  8001bc:	83 c4 10             	add    $0x10,%esp
  8001bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c2:	5b                   	pop    %ebx
  8001c3:	5e                   	pop    %esi
  8001c4:	5f                   	pop    %edi
  8001c5:	5d                   	pop    %ebp
  8001c6:	c3                   	ret    

008001c7 <umain>:

void
umain(int argc, char **argv)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	57                   	push   %edi
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 40             	sub    $0x40,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  8001d0:	c7 05 20 40 80 00 7f 	movl   $0x802a7f,0x804020
  8001d7:	2a 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8001da:	6a 06                	push   $0x6
  8001dc:	6a 01                	push   $0x1
  8001de:	6a 02                	push   $0x2
  8001e0:	e8 fa 1d 00 00       	call   801fdf <socket>
  8001e5:	89 c6                	mov    %eax,%esi
  8001e7:	83 c4 10             	add    $0x10,%esp
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	79 0a                	jns    8001f8 <umain+0x31>
		die("Failed to create socket");
  8001ee:	b8 86 2a 80 00       	mov    $0x802a86,%eax
  8001f3:	e8 3b fe ff ff       	call   800033 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  8001f8:	83 ec 04             	sub    $0x4,%esp
  8001fb:	6a 10                	push   $0x10
  8001fd:	6a 00                	push   $0x0
  8001ff:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800202:	53                   	push   %ebx
  800203:	e8 a7 0b 00 00       	call   800daf <memset>
	server.sin_family = AF_INET;			// Internet/IP
  800208:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  80020c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800213:	e8 43 01 00 00       	call   80035b <htonl>
  800218:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  80021b:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  800222:	e8 1a 01 00 00       	call   800341 <htons>
  800227:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  80022b:	83 c4 0c             	add    $0xc,%esp
  80022e:	6a 10                	push   $0x10
  800230:	53                   	push   %ebx
  800231:	56                   	push   %esi
  800232:	e8 16 1d 00 00       	call   801f4d <bind>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	85 c0                	test   %eax,%eax
  80023c:	79 0a                	jns    800248 <umain+0x81>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  80023e:	b8 30 2b 80 00       	mov    $0x802b30,%eax
  800243:	e8 eb fd ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800248:	83 ec 08             	sub    $0x8,%esp
  80024b:	6a 05                	push   $0x5
  80024d:	56                   	push   %esi
  80024e:	e8 69 1d 00 00       	call   801fbc <listen>
  800253:	83 c4 10             	add    $0x10,%esp
  800256:	85 c0                	test   %eax,%eax
  800258:	79 0a                	jns    800264 <umain+0x9d>
		die("Failed to listen on server socket");
  80025a:	b8 54 2b 80 00       	mov    $0x802b54,%eax
  80025f:	e8 cf fd ff ff       	call   800033 <die>

	cprintf("Waiting for http connections...\n");
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	68 78 2b 80 00       	push   $0x802b78
  80026c:	e8 54 04 00 00       	call   8006c5 <cprintf>
  800271:	83 c4 10             	add    $0x10,%esp

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800274:	8d 7d c4             	lea    -0x3c(%ebp),%edi
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
  800277:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
  80027e:	83 ec 04             	sub    $0x4,%esp
  800281:	57                   	push   %edi
  800282:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800285:	50                   	push   %eax
  800286:	56                   	push   %esi
  800287:	e8 8a 1c 00 00       	call   801f16 <accept>
  80028c:	89 c3                	mov    %eax,%ebx
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	85 c0                	test   %eax,%eax
  800293:	79 0a                	jns    80029f <umain+0xd8>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  800295:	b8 9c 2b 80 00       	mov    $0x802b9c,%eax
  80029a:	e8 94 fd ff ff       	call   800033 <die>
		}
		handle_client(clientsock);
  80029f:	89 d8                	mov    %ebx,%eax
  8002a1:	e8 a8 fd ff ff       	call   80004e <handle_client>
	}
  8002a6:	eb cf                	jmp    800277 <umain+0xb0>

008002a8 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8002b7:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8002ba:	c7 45 e0 00 50 80 00 	movl   $0x805000,-0x20(%ebp)
  8002c1:	0f b6 0f             	movzbl (%edi),%ecx
  8002c4:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8002c9:	0f b6 d9             	movzbl %cl,%ebx
  8002cc:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8002cf:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  8002d2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002d5:	66 c1 e8 0b          	shr    $0xb,%ax
  8002d9:	89 c3                	mov    %eax,%ebx
  8002db:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002de:	01 c0                	add    %eax,%eax
  8002e0:	29 c1                	sub    %eax,%ecx
  8002e2:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  8002e4:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  8002e6:	8d 72 01             	lea    0x1(%edx),%esi
  8002e9:	0f b6 d2             	movzbl %dl,%edx
  8002ec:	83 c0 30             	add    $0x30,%eax
  8002ef:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  8002f3:	89 f2                	mov    %esi,%edx
    } while(*ap);
  8002f5:	84 db                	test   %bl,%bl
  8002f7:	75 d0                	jne    8002c9 <inet_ntoa+0x21>
  8002f9:	c6 07 00             	movb   $0x0,(%edi)
  8002fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002ff:	eb 0d                	jmp    80030e <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  800301:	0f b6 c2             	movzbl %dl,%eax
  800304:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  800309:	88 01                	mov    %al,(%ecx)
  80030b:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80030e:	83 ea 01             	sub    $0x1,%edx
  800311:	80 fa ff             	cmp    $0xff,%dl
  800314:	75 eb                	jne    800301 <inet_ntoa+0x59>
  800316:	89 f0                	mov    %esi,%eax
  800318:	0f b6 f0             	movzbl %al,%esi
  80031b:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  80031e:	8d 46 01             	lea    0x1(%esi),%eax
  800321:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800324:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  800327:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80032a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80032d:	39 c7                	cmp    %eax,%edi
  80032f:	75 90                	jne    8002c1 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800331:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  800334:	b8 00 50 80 00       	mov    $0x805000,%eax
  800339:	83 c4 14             	add    $0x14,%esp
  80033c:	5b                   	pop    %ebx
  80033d:	5e                   	pop    %esi
  80033e:	5f                   	pop    %edi
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    

00800341 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800344:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800348:	66 c1 c0 08          	rol    $0x8,%ax
}
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  return htons(n);
  800351:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800355:	66 c1 c0 08          	rol    $0x8,%ax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800361:	89 d1                	mov    %edx,%ecx
  800363:	c1 e1 18             	shl    $0x18,%ecx
  800366:	89 d0                	mov    %edx,%eax
  800368:	c1 e8 18             	shr    $0x18,%eax
  80036b:	09 c8                	or     %ecx,%eax
  80036d:	89 d1                	mov    %edx,%ecx
  80036f:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800375:	c1 e1 08             	shl    $0x8,%ecx
  800378:	09 c8                	or     %ecx,%eax
  80037a:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800380:	c1 ea 08             	shr    $0x8,%edx
  800383:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	57                   	push   %edi
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
  80038d:	83 ec 20             	sub    $0x20,%esp
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800393:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800396:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  800399:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80039c:	0f b6 ca             	movzbl %dl,%ecx
  80039f:	83 e9 30             	sub    $0x30,%ecx
  8003a2:	83 f9 09             	cmp    $0x9,%ecx
  8003a5:	0f 87 94 01 00 00    	ja     80053f <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8003ab:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8003b2:	83 fa 30             	cmp    $0x30,%edx
  8003b5:	75 2b                	jne    8003e2 <inet_aton+0x5b>
      c = *++cp;
  8003b7:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8003bb:	89 d1                	mov    %edx,%ecx
  8003bd:	83 e1 df             	and    $0xffffffdf,%ecx
  8003c0:	80 f9 58             	cmp    $0x58,%cl
  8003c3:	74 0f                	je     8003d4 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8003c5:	83 c0 01             	add    $0x1,%eax
  8003c8:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8003cb:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8003d2:	eb 0e                	jmp    8003e2 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8003d4:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8003d8:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8003db:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  8003e2:	83 c0 01             	add    $0x1,%eax
  8003e5:	be 00 00 00 00       	mov    $0x0,%esi
  8003ea:	eb 03                	jmp    8003ef <inet_aton+0x68>
  8003ec:	83 c0 01             	add    $0x1,%eax
  8003ef:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8003f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003f5:	0f b6 fa             	movzbl %dl,%edi
  8003f8:	8d 4f d0             	lea    -0x30(%edi),%ecx
  8003fb:	83 f9 09             	cmp    $0x9,%ecx
  8003fe:	77 0d                	ja     80040d <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  800400:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  800404:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800408:	0f be 10             	movsbl (%eax),%edx
  80040b:	eb df                	jmp    8003ec <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  80040d:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  800411:	75 32                	jne    800445 <inet_aton+0xbe>
  800413:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  800416:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800419:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041c:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800422:	83 e9 41             	sub    $0x41,%ecx
  800425:	83 f9 05             	cmp    $0x5,%ecx
  800428:	77 1b                	ja     800445 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  80042a:	c1 e6 04             	shl    $0x4,%esi
  80042d:	83 c2 0a             	add    $0xa,%edx
  800430:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  800434:	19 c9                	sbb    %ecx,%ecx
  800436:	83 e1 20             	and    $0x20,%ecx
  800439:	83 c1 41             	add    $0x41,%ecx
  80043c:	29 ca                	sub    %ecx,%edx
  80043e:	09 d6                	or     %edx,%esi
        c = *++cp;
  800440:	0f be 10             	movsbl (%eax),%edx
  800443:	eb a7                	jmp    8003ec <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  800445:	83 fa 2e             	cmp    $0x2e,%edx
  800448:	75 23                	jne    80046d <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  80044a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80044d:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800450:	39 f8                	cmp    %edi,%eax
  800452:	0f 84 ee 00 00 00    	je     800546 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  800458:	83 c0 04             	add    $0x4,%eax
  80045b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80045e:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800461:	8d 43 01             	lea    0x1(%ebx),%eax
  800464:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800468:	e9 2f ff ff ff       	jmp    80039c <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80046d:	85 d2                	test   %edx,%edx
  80046f:	74 25                	je     800496 <inet_aton+0x10f>
  800471:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800479:	83 f9 5f             	cmp    $0x5f,%ecx
  80047c:	0f 87 d0 00 00 00    	ja     800552 <inet_aton+0x1cb>
  800482:	83 fa 20             	cmp    $0x20,%edx
  800485:	74 0f                	je     800496 <inet_aton+0x10f>
  800487:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80048a:	83 ea 09             	sub    $0x9,%edx
  80048d:	83 fa 04             	cmp    $0x4,%edx
  800490:	0f 87 bc 00 00 00    	ja     800552 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800496:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800499:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80049c:	29 c2                	sub    %eax,%edx
  80049e:	c1 fa 02             	sar    $0x2,%edx
  8004a1:	83 c2 01             	add    $0x1,%edx
  8004a4:	83 fa 02             	cmp    $0x2,%edx
  8004a7:	74 20                	je     8004c9 <inet_aton+0x142>
  8004a9:	83 fa 02             	cmp    $0x2,%edx
  8004ac:	7f 0f                	jg     8004bd <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8004b3:	85 d2                	test   %edx,%edx
  8004b5:	0f 84 97 00 00 00    	je     800552 <inet_aton+0x1cb>
  8004bb:	eb 67                	jmp    800524 <inet_aton+0x19d>
  8004bd:	83 fa 03             	cmp    $0x3,%edx
  8004c0:	74 1e                	je     8004e0 <inet_aton+0x159>
  8004c2:	83 fa 04             	cmp    $0x4,%edx
  8004c5:	74 38                	je     8004ff <inet_aton+0x178>
  8004c7:	eb 5b                	jmp    800524 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8004c9:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8004ce:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  8004d4:	77 7c                	ja     800552 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  8004d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d9:	c1 e0 18             	shl    $0x18,%eax
  8004dc:	09 c6                	or     %eax,%esi
    break;
  8004de:	eb 44                	jmp    800524 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8004e0:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8004e5:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  8004eb:	77 65                	ja     800552 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8004ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004f0:	c1 e2 18             	shl    $0x18,%edx
  8004f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8004f6:	c1 e0 10             	shl    $0x10,%eax
  8004f9:	09 d0                	or     %edx,%eax
  8004fb:	09 c6                	or     %eax,%esi
    break;
  8004fd:	eb 25                	jmp    800524 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8004ff:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800504:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  80050a:	77 46                	ja     800552 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80050c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80050f:	c1 e2 18             	shl    $0x18,%edx
  800512:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800515:	c1 e0 10             	shl    $0x10,%eax
  800518:	09 c2                	or     %eax,%edx
  80051a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80051d:	c1 e0 08             	shl    $0x8,%eax
  800520:	09 d0                	or     %edx,%eax
  800522:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  800524:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800528:	74 23                	je     80054d <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  80052a:	56                   	push   %esi
  80052b:	e8 2b fe ff ff       	call   80035b <htonl>
  800530:	83 c4 04             	add    $0x4,%esp
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800536:	89 03                	mov    %eax,(%ebx)
  return (1);
  800538:	b8 01 00 00 00       	mov    $0x1,%eax
  80053d:	eb 13                	jmp    800552 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80053f:	b8 00 00 00 00       	mov    $0x0,%eax
  800544:	eb 0c                	jmp    800552 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800546:	b8 00 00 00 00       	mov    $0x0,%eax
  80054b:	eb 05                	jmp    800552 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  80054d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800552:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800555:	5b                   	pop    %ebx
  800556:	5e                   	pop    %esi
  800557:	5f                   	pop    %edi
  800558:	5d                   	pop    %ebp
  800559:	c3                   	ret    

0080055a <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800560:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800563:	50                   	push   %eax
  800564:	ff 75 08             	pushl  0x8(%ebp)
  800567:	e8 1b fe ff ff       	call   800387 <inet_aton>
  80056c:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80056f:	85 c0                	test   %eax,%eax
  800571:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800576:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  80057a:	c9                   	leave  
  80057b:	c3                   	ret    

0080057c <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80057f:	ff 75 08             	pushl  0x8(%ebp)
  800582:	e8 d4 fd ff ff       	call   80035b <htonl>
  800587:	83 c4 04             	add    $0x4,%esp
}
  80058a:	c9                   	leave  
  80058b:	c3                   	ret    

0080058c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	56                   	push   %esi
  800590:	53                   	push   %ebx
  800591:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800594:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800597:	e8 93 0a 00 00       	call   80102f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80059c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005a9:	a3 1c 50 80 00       	mov    %eax,0x80501c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005ae:	85 db                	test   %ebx,%ebx
  8005b0:	7e 07                	jle    8005b9 <libmain+0x2d>
		binaryname = argv[0];
  8005b2:	8b 06                	mov    (%esi),%eax
  8005b4:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	56                   	push   %esi
  8005bd:	53                   	push   %ebx
  8005be:	e8 04 fc ff ff       	call   8001c7 <umain>

	// exit gracefully
	exit();
  8005c3:	e8 0a 00 00 00       	call   8005d2 <exit>
}
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005ce:	5b                   	pop    %ebx
  8005cf:	5e                   	pop    %esi
  8005d0:	5d                   	pop    %ebp
  8005d1:	c3                   	ret    

008005d2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d2:	55                   	push   %ebp
  8005d3:	89 e5                	mov    %esp,%ebp
  8005d5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005d8:	e8 6b 0e 00 00       	call   801448 <close_all>
	sys_env_destroy(0);
  8005dd:	83 ec 0c             	sub    $0xc,%esp
  8005e0:	6a 00                	push   $0x0
  8005e2:	e8 07 0a 00 00       	call   800fee <sys_env_destroy>
}
  8005e7:	83 c4 10             	add    $0x10,%esp
  8005ea:	c9                   	leave  
  8005eb:	c3                   	ret    

008005ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005ec:	55                   	push   %ebp
  8005ed:	89 e5                	mov    %esp,%ebp
  8005ef:	56                   	push   %esi
  8005f0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005f1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f4:	8b 35 20 40 80 00    	mov    0x804020,%esi
  8005fa:	e8 30 0a 00 00       	call   80102f <sys_getenvid>
  8005ff:	83 ec 0c             	sub    $0xc,%esp
  800602:	ff 75 0c             	pushl  0xc(%ebp)
  800605:	ff 75 08             	pushl  0x8(%ebp)
  800608:	56                   	push   %esi
  800609:	50                   	push   %eax
  80060a:	68 f0 2b 80 00       	push   $0x802bf0
  80060f:	e8 b1 00 00 00       	call   8006c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800614:	83 c4 18             	add    $0x18,%esp
  800617:	53                   	push   %ebx
  800618:	ff 75 10             	pushl  0x10(%ebp)
  80061b:	e8 54 00 00 00       	call   800674 <vcprintf>
	cprintf("\n");
  800620:	c7 04 24 27 30 80 00 	movl   $0x803027,(%esp)
  800627:	e8 99 00 00 00       	call   8006c5 <cprintf>
  80062c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80062f:	cc                   	int3   
  800630:	eb fd                	jmp    80062f <_panic+0x43>

00800632 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
  800635:	53                   	push   %ebx
  800636:	83 ec 04             	sub    $0x4,%esp
  800639:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80063c:	8b 13                	mov    (%ebx),%edx
  80063e:	8d 42 01             	lea    0x1(%edx),%eax
  800641:	89 03                	mov    %eax,(%ebx)
  800643:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800646:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80064a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80064f:	75 1a                	jne    80066b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	68 ff 00 00 00       	push   $0xff
  800659:	8d 43 08             	lea    0x8(%ebx),%eax
  80065c:	50                   	push   %eax
  80065d:	e8 4f 09 00 00       	call   800fb1 <sys_cputs>
		b->idx = 0;
  800662:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800668:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80066b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80066f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800672:	c9                   	leave  
  800673:	c3                   	ret    

00800674 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800674:	55                   	push   %ebp
  800675:	89 e5                	mov    %esp,%ebp
  800677:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80067d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800684:	00 00 00 
	b.cnt = 0;
  800687:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80068e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800691:	ff 75 0c             	pushl  0xc(%ebp)
  800694:	ff 75 08             	pushl  0x8(%ebp)
  800697:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80069d:	50                   	push   %eax
  80069e:	68 32 06 80 00       	push   $0x800632
  8006a3:	e8 54 01 00 00       	call   8007fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006a8:	83 c4 08             	add    $0x8,%esp
  8006ab:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006b1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006b7:	50                   	push   %eax
  8006b8:	e8 f4 08 00 00       	call   800fb1 <sys_cputs>

	return b.cnt;
}
  8006bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    

008006c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006ce:	50                   	push   %eax
  8006cf:	ff 75 08             	pushl  0x8(%ebp)
  8006d2:	e8 9d ff ff ff       	call   800674 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	57                   	push   %edi
  8006dd:	56                   	push   %esi
  8006de:	53                   	push   %ebx
  8006df:	83 ec 1c             	sub    $0x1c,%esp
  8006e2:	89 c7                	mov    %eax,%edi
  8006e4:	89 d6                	mov    %edx,%esi
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006fd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800700:	39 d3                	cmp    %edx,%ebx
  800702:	72 05                	jb     800709 <printnum+0x30>
  800704:	39 45 10             	cmp    %eax,0x10(%ebp)
  800707:	77 45                	ja     80074e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800709:	83 ec 0c             	sub    $0xc,%esp
  80070c:	ff 75 18             	pushl  0x18(%ebp)
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800715:	53                   	push   %ebx
  800716:	ff 75 10             	pushl  0x10(%ebp)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80071f:	ff 75 e0             	pushl  -0x20(%ebp)
  800722:	ff 75 dc             	pushl  -0x24(%ebp)
  800725:	ff 75 d8             	pushl  -0x28(%ebp)
  800728:	e8 83 20 00 00       	call   8027b0 <__udivdi3>
  80072d:	83 c4 18             	add    $0x18,%esp
  800730:	52                   	push   %edx
  800731:	50                   	push   %eax
  800732:	89 f2                	mov    %esi,%edx
  800734:	89 f8                	mov    %edi,%eax
  800736:	e8 9e ff ff ff       	call   8006d9 <printnum>
  80073b:	83 c4 20             	add    $0x20,%esp
  80073e:	eb 18                	jmp    800758 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	56                   	push   %esi
  800744:	ff 75 18             	pushl  0x18(%ebp)
  800747:	ff d7                	call   *%edi
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb 03                	jmp    800751 <printnum+0x78>
  80074e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800751:	83 eb 01             	sub    $0x1,%ebx
  800754:	85 db                	test   %ebx,%ebx
  800756:	7f e8                	jg     800740 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	56                   	push   %esi
  80075c:	83 ec 04             	sub    $0x4,%esp
  80075f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800762:	ff 75 e0             	pushl  -0x20(%ebp)
  800765:	ff 75 dc             	pushl  -0x24(%ebp)
  800768:	ff 75 d8             	pushl  -0x28(%ebp)
  80076b:	e8 70 21 00 00       	call   8028e0 <__umoddi3>
  800770:	83 c4 14             	add    $0x14,%esp
  800773:	0f be 80 13 2c 80 00 	movsbl 0x802c13(%eax),%eax
  80077a:	50                   	push   %eax
  80077b:	ff d7                	call   *%edi
}
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800783:	5b                   	pop    %ebx
  800784:	5e                   	pop    %esi
  800785:	5f                   	pop    %edi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80078b:	83 fa 01             	cmp    $0x1,%edx
  80078e:	7e 0e                	jle    80079e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800790:	8b 10                	mov    (%eax),%edx
  800792:	8d 4a 08             	lea    0x8(%edx),%ecx
  800795:	89 08                	mov    %ecx,(%eax)
  800797:	8b 02                	mov    (%edx),%eax
  800799:	8b 52 04             	mov    0x4(%edx),%edx
  80079c:	eb 22                	jmp    8007c0 <getuint+0x38>
	else if (lflag)
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	74 10                	je     8007b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a2:	8b 10                	mov    (%eax),%edx
  8007a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a7:	89 08                	mov    %ecx,(%eax)
  8007a9:	8b 02                	mov    (%edx),%eax
  8007ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b0:	eb 0e                	jmp    8007c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b2:	8b 10                	mov    (%eax),%edx
  8007b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b7:	89 08                	mov    %ecx,(%eax)
  8007b9:	8b 02                	mov    (%edx),%eax
  8007bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007cc:	8b 10                	mov    (%eax),%edx
  8007ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d1:	73 0a                	jae    8007dd <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007d6:	89 08                	mov    %ecx,(%eax)
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	88 02                	mov    %al,(%edx)
}
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007e8:	50                   	push   %eax
  8007e9:	ff 75 10             	pushl  0x10(%ebp)
  8007ec:	ff 75 0c             	pushl  0xc(%ebp)
  8007ef:	ff 75 08             	pushl  0x8(%ebp)
  8007f2:	e8 05 00 00 00       	call   8007fc <vprintfmt>
	va_end(ap);
}
  8007f7:	83 c4 10             	add    $0x10,%esp
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	57                   	push   %edi
  800800:	56                   	push   %esi
  800801:	53                   	push   %ebx
  800802:	83 ec 2c             	sub    $0x2c,%esp
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80080e:	eb 12                	jmp    800822 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800810:	85 c0                	test   %eax,%eax
  800812:	0f 84 a9 03 00 00    	je     800bc1 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	50                   	push   %eax
  80081d:	ff d6                	call   *%esi
  80081f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800822:	83 c7 01             	add    $0x1,%edi
  800825:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800829:	83 f8 25             	cmp    $0x25,%eax
  80082c:	75 e2                	jne    800810 <vprintfmt+0x14>
  80082e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800832:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800839:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800840:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 07                	jmp    800855 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800851:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8d 47 01             	lea    0x1(%edi),%eax
  800858:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80085b:	0f b6 07             	movzbl (%edi),%eax
  80085e:	0f b6 c8             	movzbl %al,%ecx
  800861:	83 e8 23             	sub    $0x23,%eax
  800864:	3c 55                	cmp    $0x55,%al
  800866:	0f 87 3a 03 00 00    	ja     800ba6 <vprintfmt+0x3aa>
  80086c:	0f b6 c0             	movzbl %al,%eax
  80086f:	ff 24 85 60 2d 80 00 	jmp    *0x802d60(,%eax,4)
  800876:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800879:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80087d:	eb d6                	jmp    800855 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  800887:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80088d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800891:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800894:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800897:	83 fa 09             	cmp    $0x9,%edx
  80089a:	77 39                	ja     8008d5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80089c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80089f:	eb e9                	jmp    80088a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8d 48 04             	lea    0x4(%eax),%ecx
  8008a7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008aa:	8b 00                	mov    (%eax),%eax
  8008ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b2:	eb 27                	jmp    8008db <vprintfmt+0xdf>
  8008b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008be:	0f 49 c8             	cmovns %eax,%ecx
  8008c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c7:	eb 8c                	jmp    800855 <vprintfmt+0x59>
  8008c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008cc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d3:	eb 80                	jmp    800855 <vprintfmt+0x59>
  8008d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008d8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008df:	0f 89 70 ff ff ff    	jns    800855 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008f2:	e9 5e ff ff ff       	jmp    800855 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008f7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008fd:	e9 53 ff ff ff       	jmp    800855 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8d 50 04             	lea    0x4(%eax),%edx
  800908:	89 55 14             	mov    %edx,0x14(%ebp)
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	53                   	push   %ebx
  80090f:	ff 30                	pushl  (%eax)
  800911:	ff d6                	call   *%esi
			break;
  800913:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800916:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800919:	e9 04 ff ff ff       	jmp    800822 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80091e:	8b 45 14             	mov    0x14(%ebp),%eax
  800921:	8d 50 04             	lea    0x4(%eax),%edx
  800924:	89 55 14             	mov    %edx,0x14(%ebp)
  800927:	8b 00                	mov    (%eax),%eax
  800929:	99                   	cltd   
  80092a:	31 d0                	xor    %edx,%eax
  80092c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80092e:	83 f8 0f             	cmp    $0xf,%eax
  800931:	7f 0b                	jg     80093e <vprintfmt+0x142>
  800933:	8b 14 85 c0 2e 80 00 	mov    0x802ec0(,%eax,4),%edx
  80093a:	85 d2                	test   %edx,%edx
  80093c:	75 18                	jne    800956 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80093e:	50                   	push   %eax
  80093f:	68 2b 2c 80 00       	push   $0x802c2b
  800944:	53                   	push   %ebx
  800945:	56                   	push   %esi
  800946:	e8 94 fe ff ff       	call   8007df <printfmt>
  80094b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800951:	e9 cc fe ff ff       	jmp    800822 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800956:	52                   	push   %edx
  800957:	68 f5 2f 80 00       	push   $0x802ff5
  80095c:	53                   	push   %ebx
  80095d:	56                   	push   %esi
  80095e:	e8 7c fe ff ff       	call   8007df <printfmt>
  800963:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800966:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800969:	e9 b4 fe ff ff       	jmp    800822 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80096e:	8b 45 14             	mov    0x14(%ebp),%eax
  800971:	8d 50 04             	lea    0x4(%eax),%edx
  800974:	89 55 14             	mov    %edx,0x14(%ebp)
  800977:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800979:	85 ff                	test   %edi,%edi
  80097b:	b8 24 2c 80 00       	mov    $0x802c24,%eax
  800980:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800983:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800987:	0f 8e 94 00 00 00    	jle    800a21 <vprintfmt+0x225>
  80098d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800991:	0f 84 98 00 00 00    	je     800a2f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800997:	83 ec 08             	sub    $0x8,%esp
  80099a:	ff 75 d0             	pushl  -0x30(%ebp)
  80099d:	57                   	push   %edi
  80099e:	e8 a6 02 00 00       	call   800c49 <strnlen>
  8009a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009a6:	29 c1                	sub    %eax,%ecx
  8009a8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009ab:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009ae:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009b5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009b8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ba:	eb 0f                	jmp    8009cb <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009bc:	83 ec 08             	sub    $0x8,%esp
  8009bf:	53                   	push   %ebx
  8009c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c5:	83 ef 01             	sub    $0x1,%edi
  8009c8:	83 c4 10             	add    $0x10,%esp
  8009cb:	85 ff                	test   %edi,%edi
  8009cd:	7f ed                	jg     8009bc <vprintfmt+0x1c0>
  8009cf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009d5:	85 c9                	test   %ecx,%ecx
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	0f 49 c1             	cmovns %ecx,%eax
  8009df:	29 c1                	sub    %eax,%ecx
  8009e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009ea:	89 cb                	mov    %ecx,%ebx
  8009ec:	eb 4d                	jmp    800a3b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009ee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f2:	74 1b                	je     800a0f <vprintfmt+0x213>
  8009f4:	0f be c0             	movsbl %al,%eax
  8009f7:	83 e8 20             	sub    $0x20,%eax
  8009fa:	83 f8 5e             	cmp    $0x5e,%eax
  8009fd:	76 10                	jbe    800a0f <vprintfmt+0x213>
					putch('?', putdat);
  8009ff:	83 ec 08             	sub    $0x8,%esp
  800a02:	ff 75 0c             	pushl  0xc(%ebp)
  800a05:	6a 3f                	push   $0x3f
  800a07:	ff 55 08             	call   *0x8(%ebp)
  800a0a:	83 c4 10             	add    $0x10,%esp
  800a0d:	eb 0d                	jmp    800a1c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a0f:	83 ec 08             	sub    $0x8,%esp
  800a12:	ff 75 0c             	pushl  0xc(%ebp)
  800a15:	52                   	push   %edx
  800a16:	ff 55 08             	call   *0x8(%ebp)
  800a19:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1c:	83 eb 01             	sub    $0x1,%ebx
  800a1f:	eb 1a                	jmp    800a3b <vprintfmt+0x23f>
  800a21:	89 75 08             	mov    %esi,0x8(%ebp)
  800a24:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a27:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a2a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a2d:	eb 0c                	jmp    800a3b <vprintfmt+0x23f>
  800a2f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a32:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a35:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a38:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a3b:	83 c7 01             	add    $0x1,%edi
  800a3e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a42:	0f be d0             	movsbl %al,%edx
  800a45:	85 d2                	test   %edx,%edx
  800a47:	74 23                	je     800a6c <vprintfmt+0x270>
  800a49:	85 f6                	test   %esi,%esi
  800a4b:	78 a1                	js     8009ee <vprintfmt+0x1f2>
  800a4d:	83 ee 01             	sub    $0x1,%esi
  800a50:	79 9c                	jns    8009ee <vprintfmt+0x1f2>
  800a52:	89 df                	mov    %ebx,%edi
  800a54:	8b 75 08             	mov    0x8(%ebp),%esi
  800a57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5a:	eb 18                	jmp    800a74 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a5c:	83 ec 08             	sub    $0x8,%esp
  800a5f:	53                   	push   %ebx
  800a60:	6a 20                	push   $0x20
  800a62:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a64:	83 ef 01             	sub    $0x1,%edi
  800a67:	83 c4 10             	add    $0x10,%esp
  800a6a:	eb 08                	jmp    800a74 <vprintfmt+0x278>
  800a6c:	89 df                	mov    %ebx,%edi
  800a6e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a74:	85 ff                	test   %edi,%edi
  800a76:	7f e4                	jg     800a5c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7b:	e9 a2 fd ff ff       	jmp    800822 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a80:	83 fa 01             	cmp    $0x1,%edx
  800a83:	7e 16                	jle    800a9b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a85:	8b 45 14             	mov    0x14(%ebp),%eax
  800a88:	8d 50 08             	lea    0x8(%eax),%edx
  800a8b:	89 55 14             	mov    %edx,0x14(%ebp)
  800a8e:	8b 50 04             	mov    0x4(%eax),%edx
  800a91:	8b 00                	mov    (%eax),%eax
  800a93:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a96:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a99:	eb 32                	jmp    800acd <vprintfmt+0x2d1>
	else if (lflag)
  800a9b:	85 d2                	test   %edx,%edx
  800a9d:	74 18                	je     800ab7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800a9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa2:	8d 50 04             	lea    0x4(%eax),%edx
  800aa5:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa8:	8b 00                	mov    (%eax),%eax
  800aaa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aad:	89 c1                	mov    %eax,%ecx
  800aaf:	c1 f9 1f             	sar    $0x1f,%ecx
  800ab2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ab5:	eb 16                	jmp    800acd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ab7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aba:	8d 50 04             	lea    0x4(%eax),%edx
  800abd:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac0:	8b 00                	mov    (%eax),%eax
  800ac2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ac5:	89 c1                	mov    %eax,%ecx
  800ac7:	c1 f9 1f             	sar    $0x1f,%ecx
  800aca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800acd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ad0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ad3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ad8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800adc:	0f 89 90 00 00 00    	jns    800b72 <vprintfmt+0x376>
				putch('-', putdat);
  800ae2:	83 ec 08             	sub    $0x8,%esp
  800ae5:	53                   	push   %ebx
  800ae6:	6a 2d                	push   $0x2d
  800ae8:	ff d6                	call   *%esi
				num = -(long long) num;
  800aea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800aed:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800af0:	f7 d8                	neg    %eax
  800af2:	83 d2 00             	adc    $0x0,%edx
  800af5:	f7 da                	neg    %edx
  800af7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800afa:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800aff:	eb 71                	jmp    800b72 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b01:	8d 45 14             	lea    0x14(%ebp),%eax
  800b04:	e8 7f fc ff ff       	call   800788 <getuint>
			base = 10;
  800b09:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b0e:	eb 62                	jmp    800b72 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b10:	8d 45 14             	lea    0x14(%ebp),%eax
  800b13:	e8 70 fc ff ff       	call   800788 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800b1f:	51                   	push   %ecx
  800b20:	ff 75 e0             	pushl  -0x20(%ebp)
  800b23:	6a 08                	push   $0x8
  800b25:	52                   	push   %edx
  800b26:	50                   	push   %eax
  800b27:	89 da                	mov    %ebx,%edx
  800b29:	89 f0                	mov    %esi,%eax
  800b2b:	e8 a9 fb ff ff       	call   8006d9 <printnum>
			break;
  800b30:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800b36:	e9 e7 fc ff ff       	jmp    800822 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800b3b:	83 ec 08             	sub    $0x8,%esp
  800b3e:	53                   	push   %ebx
  800b3f:	6a 30                	push   $0x30
  800b41:	ff d6                	call   *%esi
			putch('x', putdat);
  800b43:	83 c4 08             	add    $0x8,%esp
  800b46:	53                   	push   %ebx
  800b47:	6a 78                	push   $0x78
  800b49:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4e:	8d 50 04             	lea    0x4(%eax),%edx
  800b51:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b54:	8b 00                	mov    (%eax),%eax
  800b56:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b5b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b5e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b63:	eb 0d                	jmp    800b72 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b65:	8d 45 14             	lea    0x14(%ebp),%eax
  800b68:	e8 1b fc ff ff       	call   800788 <getuint>
			base = 16;
  800b6d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b79:	57                   	push   %edi
  800b7a:	ff 75 e0             	pushl  -0x20(%ebp)
  800b7d:	51                   	push   %ecx
  800b7e:	52                   	push   %edx
  800b7f:	50                   	push   %eax
  800b80:	89 da                	mov    %ebx,%edx
  800b82:	89 f0                	mov    %esi,%eax
  800b84:	e8 50 fb ff ff       	call   8006d9 <printnum>
			break;
  800b89:	83 c4 20             	add    $0x20,%esp
  800b8c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b8f:	e9 8e fc ff ff       	jmp    800822 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b94:	83 ec 08             	sub    $0x8,%esp
  800b97:	53                   	push   %ebx
  800b98:	51                   	push   %ecx
  800b99:	ff d6                	call   *%esi
			break;
  800b9b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ba1:	e9 7c fc ff ff       	jmp    800822 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ba6:	83 ec 08             	sub    $0x8,%esp
  800ba9:	53                   	push   %ebx
  800baa:	6a 25                	push   $0x25
  800bac:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bae:	83 c4 10             	add    $0x10,%esp
  800bb1:	eb 03                	jmp    800bb6 <vprintfmt+0x3ba>
  800bb3:	83 ef 01             	sub    $0x1,%edi
  800bb6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800bba:	75 f7                	jne    800bb3 <vprintfmt+0x3b7>
  800bbc:	e9 61 fc ff ff       	jmp    800822 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	83 ec 18             	sub    $0x18,%esp
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bd8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bdc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bdf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800be6:	85 c0                	test   %eax,%eax
  800be8:	74 26                	je     800c10 <vsnprintf+0x47>
  800bea:	85 d2                	test   %edx,%edx
  800bec:	7e 22                	jle    800c10 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bee:	ff 75 14             	pushl  0x14(%ebp)
  800bf1:	ff 75 10             	pushl  0x10(%ebp)
  800bf4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bf7:	50                   	push   %eax
  800bf8:	68 c2 07 80 00       	push   $0x8007c2
  800bfd:	e8 fa fb ff ff       	call   8007fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c02:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c05:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c0b:	83 c4 10             	add    $0x10,%esp
  800c0e:	eb 05                	jmp    800c15 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c1d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c20:	50                   	push   %eax
  800c21:	ff 75 10             	pushl  0x10(%ebp)
  800c24:	ff 75 0c             	pushl  0xc(%ebp)
  800c27:	ff 75 08             	pushl  0x8(%ebp)
  800c2a:	e8 9a ff ff ff       	call   800bc9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c2f:	c9                   	leave  
  800c30:	c3                   	ret    

00800c31 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c37:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3c:	eb 03                	jmp    800c41 <strlen+0x10>
		n++;
  800c3e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c41:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c45:	75 f7                	jne    800c3e <strlen+0xd>
		n++;
	return n;
}
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c52:	ba 00 00 00 00       	mov    $0x0,%edx
  800c57:	eb 03                	jmp    800c5c <strnlen+0x13>
		n++;
  800c59:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c5c:	39 c2                	cmp    %eax,%edx
  800c5e:	74 08                	je     800c68 <strnlen+0x1f>
  800c60:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c64:	75 f3                	jne    800c59 <strnlen+0x10>
  800c66:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	53                   	push   %ebx
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c74:	89 c2                	mov    %eax,%edx
  800c76:	83 c2 01             	add    $0x1,%edx
  800c79:	83 c1 01             	add    $0x1,%ecx
  800c7c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c80:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c83:	84 db                	test   %bl,%bl
  800c85:	75 ef                	jne    800c76 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c87:	5b                   	pop    %ebx
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	53                   	push   %ebx
  800c8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c91:	53                   	push   %ebx
  800c92:	e8 9a ff ff ff       	call   800c31 <strlen>
  800c97:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c9a:	ff 75 0c             	pushl  0xc(%ebp)
  800c9d:	01 d8                	add    %ebx,%eax
  800c9f:	50                   	push   %eax
  800ca0:	e8 c5 ff ff ff       	call   800c6a <strcpy>
	return dst;
}
  800ca5:	89 d8                	mov    %ebx,%eax
  800ca7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800caa:	c9                   	leave  
  800cab:	c3                   	ret    

00800cac <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	8b 75 08             	mov    0x8(%ebp),%esi
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	89 f3                	mov    %esi,%ebx
  800cb9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cbc:	89 f2                	mov    %esi,%edx
  800cbe:	eb 0f                	jmp    800ccf <strncpy+0x23>
		*dst++ = *src;
  800cc0:	83 c2 01             	add    $0x1,%edx
  800cc3:	0f b6 01             	movzbl (%ecx),%eax
  800cc6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cc9:	80 39 01             	cmpb   $0x1,(%ecx)
  800ccc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ccf:	39 da                	cmp    %ebx,%edx
  800cd1:	75 ed                	jne    800cc0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cd3:	89 f0                	mov    %esi,%eax
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	8b 75 08             	mov    0x8(%ebp),%esi
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	8b 55 10             	mov    0x10(%ebp),%edx
  800ce7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ce9:	85 d2                	test   %edx,%edx
  800ceb:	74 21                	je     800d0e <strlcpy+0x35>
  800ced:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cf1:	89 f2                	mov    %esi,%edx
  800cf3:	eb 09                	jmp    800cfe <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cf5:	83 c2 01             	add    $0x1,%edx
  800cf8:	83 c1 01             	add    $0x1,%ecx
  800cfb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cfe:	39 c2                	cmp    %eax,%edx
  800d00:	74 09                	je     800d0b <strlcpy+0x32>
  800d02:	0f b6 19             	movzbl (%ecx),%ebx
  800d05:	84 db                	test   %bl,%bl
  800d07:	75 ec                	jne    800cf5 <strlcpy+0x1c>
  800d09:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d0b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d0e:	29 f0                	sub    %esi,%eax
}
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d1d:	eb 06                	jmp    800d25 <strcmp+0x11>
		p++, q++;
  800d1f:	83 c1 01             	add    $0x1,%ecx
  800d22:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d25:	0f b6 01             	movzbl (%ecx),%eax
  800d28:	84 c0                	test   %al,%al
  800d2a:	74 04                	je     800d30 <strcmp+0x1c>
  800d2c:	3a 02                	cmp    (%edx),%al
  800d2e:	74 ef                	je     800d1f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d30:	0f b6 c0             	movzbl %al,%eax
  800d33:	0f b6 12             	movzbl (%edx),%edx
  800d36:	29 d0                	sub    %edx,%eax
}
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	53                   	push   %ebx
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d44:	89 c3                	mov    %eax,%ebx
  800d46:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d49:	eb 06                	jmp    800d51 <strncmp+0x17>
		n--, p++, q++;
  800d4b:	83 c0 01             	add    $0x1,%eax
  800d4e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d51:	39 d8                	cmp    %ebx,%eax
  800d53:	74 15                	je     800d6a <strncmp+0x30>
  800d55:	0f b6 08             	movzbl (%eax),%ecx
  800d58:	84 c9                	test   %cl,%cl
  800d5a:	74 04                	je     800d60 <strncmp+0x26>
  800d5c:	3a 0a                	cmp    (%edx),%cl
  800d5e:	74 eb                	je     800d4b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d60:	0f b6 00             	movzbl (%eax),%eax
  800d63:	0f b6 12             	movzbl (%edx),%edx
  800d66:	29 d0                	sub    %edx,%eax
  800d68:	eb 05                	jmp    800d6f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d6a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d7c:	eb 07                	jmp    800d85 <strchr+0x13>
		if (*s == c)
  800d7e:	38 ca                	cmp    %cl,%dl
  800d80:	74 0f                	je     800d91 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d82:	83 c0 01             	add    $0x1,%eax
  800d85:	0f b6 10             	movzbl (%eax),%edx
  800d88:	84 d2                	test   %dl,%dl
  800d8a:	75 f2                	jne    800d7e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
  800d99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d9d:	eb 03                	jmp    800da2 <strfind+0xf>
  800d9f:	83 c0 01             	add    $0x1,%eax
  800da2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800da5:	38 ca                	cmp    %cl,%dl
  800da7:	74 04                	je     800dad <strfind+0x1a>
  800da9:	84 d2                	test   %dl,%dl
  800dab:	75 f2                	jne    800d9f <strfind+0xc>
			break;
	return (char *) s;
}
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800db8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dbb:	85 c9                	test   %ecx,%ecx
  800dbd:	74 36                	je     800df5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dbf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dc5:	75 28                	jne    800def <memset+0x40>
  800dc7:	f6 c1 03             	test   $0x3,%cl
  800dca:	75 23                	jne    800def <memset+0x40>
		c &= 0xFF;
  800dcc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dd0:	89 d3                	mov    %edx,%ebx
  800dd2:	c1 e3 08             	shl    $0x8,%ebx
  800dd5:	89 d6                	mov    %edx,%esi
  800dd7:	c1 e6 18             	shl    $0x18,%esi
  800dda:	89 d0                	mov    %edx,%eax
  800ddc:	c1 e0 10             	shl    $0x10,%eax
  800ddf:	09 f0                	or     %esi,%eax
  800de1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800de3:	89 d8                	mov    %ebx,%eax
  800de5:	09 d0                	or     %edx,%eax
  800de7:	c1 e9 02             	shr    $0x2,%ecx
  800dea:	fc                   	cld    
  800deb:	f3 ab                	rep stos %eax,%es:(%edi)
  800ded:	eb 06                	jmp    800df5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800def:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df2:	fc                   	cld    
  800df3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800df5:	89 f8                	mov    %edi,%eax
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e0a:	39 c6                	cmp    %eax,%esi
  800e0c:	73 35                	jae    800e43 <memmove+0x47>
  800e0e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e11:	39 d0                	cmp    %edx,%eax
  800e13:	73 2e                	jae    800e43 <memmove+0x47>
		s += n;
		d += n;
  800e15:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e18:	89 d6                	mov    %edx,%esi
  800e1a:	09 fe                	or     %edi,%esi
  800e1c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e22:	75 13                	jne    800e37 <memmove+0x3b>
  800e24:	f6 c1 03             	test   $0x3,%cl
  800e27:	75 0e                	jne    800e37 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e29:	83 ef 04             	sub    $0x4,%edi
  800e2c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e2f:	c1 e9 02             	shr    $0x2,%ecx
  800e32:	fd                   	std    
  800e33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e35:	eb 09                	jmp    800e40 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e37:	83 ef 01             	sub    $0x1,%edi
  800e3a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e3d:	fd                   	std    
  800e3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e40:	fc                   	cld    
  800e41:	eb 1d                	jmp    800e60 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e43:	89 f2                	mov    %esi,%edx
  800e45:	09 c2                	or     %eax,%edx
  800e47:	f6 c2 03             	test   $0x3,%dl
  800e4a:	75 0f                	jne    800e5b <memmove+0x5f>
  800e4c:	f6 c1 03             	test   $0x3,%cl
  800e4f:	75 0a                	jne    800e5b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e51:	c1 e9 02             	shr    $0x2,%ecx
  800e54:	89 c7                	mov    %eax,%edi
  800e56:	fc                   	cld    
  800e57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e59:	eb 05                	jmp    800e60 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e5b:	89 c7                	mov    %eax,%edi
  800e5d:	fc                   	cld    
  800e5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e67:	ff 75 10             	pushl  0x10(%ebp)
  800e6a:	ff 75 0c             	pushl  0xc(%ebp)
  800e6d:	ff 75 08             	pushl  0x8(%ebp)
  800e70:	e8 87 ff ff ff       	call   800dfc <memmove>
}
  800e75:	c9                   	leave  
  800e76:	c3                   	ret    

00800e77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
  800e7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e82:	89 c6                	mov    %eax,%esi
  800e84:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e87:	eb 1a                	jmp    800ea3 <memcmp+0x2c>
		if (*s1 != *s2)
  800e89:	0f b6 08             	movzbl (%eax),%ecx
  800e8c:	0f b6 1a             	movzbl (%edx),%ebx
  800e8f:	38 d9                	cmp    %bl,%cl
  800e91:	74 0a                	je     800e9d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e93:	0f b6 c1             	movzbl %cl,%eax
  800e96:	0f b6 db             	movzbl %bl,%ebx
  800e99:	29 d8                	sub    %ebx,%eax
  800e9b:	eb 0f                	jmp    800eac <memcmp+0x35>
		s1++, s2++;
  800e9d:	83 c0 01             	add    $0x1,%eax
  800ea0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ea3:	39 f0                	cmp    %esi,%eax
  800ea5:	75 e2                	jne    800e89 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ea7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	53                   	push   %ebx
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800eb7:	89 c1                	mov    %eax,%ecx
  800eb9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ebc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ec0:	eb 0a                	jmp    800ecc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ec2:	0f b6 10             	movzbl (%eax),%edx
  800ec5:	39 da                	cmp    %ebx,%edx
  800ec7:	74 07                	je     800ed0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ec9:	83 c0 01             	add    $0x1,%eax
  800ecc:	39 c8                	cmp    %ecx,%eax
  800ece:	72 f2                	jb     800ec2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ed0:	5b                   	pop    %ebx
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800edc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800edf:	eb 03                	jmp    800ee4 <strtol+0x11>
		s++;
  800ee1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee4:	0f b6 01             	movzbl (%ecx),%eax
  800ee7:	3c 20                	cmp    $0x20,%al
  800ee9:	74 f6                	je     800ee1 <strtol+0xe>
  800eeb:	3c 09                	cmp    $0x9,%al
  800eed:	74 f2                	je     800ee1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eef:	3c 2b                	cmp    $0x2b,%al
  800ef1:	75 0a                	jne    800efd <strtol+0x2a>
		s++;
  800ef3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ef6:	bf 00 00 00 00       	mov    $0x0,%edi
  800efb:	eb 11                	jmp    800f0e <strtol+0x3b>
  800efd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f02:	3c 2d                	cmp    $0x2d,%al
  800f04:	75 08                	jne    800f0e <strtol+0x3b>
		s++, neg = 1;
  800f06:	83 c1 01             	add    $0x1,%ecx
  800f09:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f0e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f14:	75 15                	jne    800f2b <strtol+0x58>
  800f16:	80 39 30             	cmpb   $0x30,(%ecx)
  800f19:	75 10                	jne    800f2b <strtol+0x58>
  800f1b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f1f:	75 7c                	jne    800f9d <strtol+0xca>
		s += 2, base = 16;
  800f21:	83 c1 02             	add    $0x2,%ecx
  800f24:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f29:	eb 16                	jmp    800f41 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f2b:	85 db                	test   %ebx,%ebx
  800f2d:	75 12                	jne    800f41 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f2f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f34:	80 39 30             	cmpb   $0x30,(%ecx)
  800f37:	75 08                	jne    800f41 <strtol+0x6e>
		s++, base = 8;
  800f39:	83 c1 01             	add    $0x1,%ecx
  800f3c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f49:	0f b6 11             	movzbl (%ecx),%edx
  800f4c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f4f:	89 f3                	mov    %esi,%ebx
  800f51:	80 fb 09             	cmp    $0x9,%bl
  800f54:	77 08                	ja     800f5e <strtol+0x8b>
			dig = *s - '0';
  800f56:	0f be d2             	movsbl %dl,%edx
  800f59:	83 ea 30             	sub    $0x30,%edx
  800f5c:	eb 22                	jmp    800f80 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f5e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f61:	89 f3                	mov    %esi,%ebx
  800f63:	80 fb 19             	cmp    $0x19,%bl
  800f66:	77 08                	ja     800f70 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f68:	0f be d2             	movsbl %dl,%edx
  800f6b:	83 ea 57             	sub    $0x57,%edx
  800f6e:	eb 10                	jmp    800f80 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f70:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f73:	89 f3                	mov    %esi,%ebx
  800f75:	80 fb 19             	cmp    $0x19,%bl
  800f78:	77 16                	ja     800f90 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f7a:	0f be d2             	movsbl %dl,%edx
  800f7d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f80:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f83:	7d 0b                	jge    800f90 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f85:	83 c1 01             	add    $0x1,%ecx
  800f88:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f8c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f8e:	eb b9                	jmp    800f49 <strtol+0x76>

	if (endptr)
  800f90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f94:	74 0d                	je     800fa3 <strtol+0xd0>
		*endptr = (char *) s;
  800f96:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f99:	89 0e                	mov    %ecx,(%esi)
  800f9b:	eb 06                	jmp    800fa3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f9d:	85 db                	test   %ebx,%ebx
  800f9f:	74 98                	je     800f39 <strtol+0x66>
  800fa1:	eb 9e                	jmp    800f41 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fa3:	89 c2                	mov    %eax,%edx
  800fa5:	f7 da                	neg    %edx
  800fa7:	85 ff                	test   %edi,%edi
  800fa9:	0f 45 c2             	cmovne %edx,%eax
}
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	57                   	push   %edi
  800fb5:	56                   	push   %esi
  800fb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc2:	89 c3                	mov    %eax,%ebx
  800fc4:	89 c7                	mov    %eax,%edi
  800fc6:	89 c6                	mov    %eax,%esi
  800fc8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fca:	5b                   	pop    %ebx
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <sys_cgetc>:

int
sys_cgetc(void)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fda:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdf:	89 d1                	mov    %edx,%ecx
  800fe1:	89 d3                	mov    %edx,%ebx
  800fe3:	89 d7                	mov    %edx,%edi
  800fe5:	89 d6                	mov    %edx,%esi
  800fe7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffc:	b8 03 00 00 00       	mov    $0x3,%eax
  801001:	8b 55 08             	mov    0x8(%ebp),%edx
  801004:	89 cb                	mov    %ecx,%ebx
  801006:	89 cf                	mov    %ecx,%edi
  801008:	89 ce                	mov    %ecx,%esi
  80100a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	7e 17                	jle    801027 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	50                   	push   %eax
  801014:	6a 03                	push   $0x3
  801016:	68 1f 2f 80 00       	push   $0x802f1f
  80101b:	6a 23                	push   $0x23
  80101d:	68 3c 2f 80 00       	push   $0x802f3c
  801022:	e8 c5 f5 ff ff       	call   8005ec <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801027:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801035:	ba 00 00 00 00       	mov    $0x0,%edx
  80103a:	b8 02 00 00 00       	mov    $0x2,%eax
  80103f:	89 d1                	mov    %edx,%ecx
  801041:	89 d3                	mov    %edx,%ebx
  801043:	89 d7                	mov    %edx,%edi
  801045:	89 d6                	mov    %edx,%esi
  801047:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_yield>:

void
sys_yield(void)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801054:	ba 00 00 00 00       	mov    $0x0,%edx
  801059:	b8 0b 00 00 00       	mov    $0xb,%eax
  80105e:	89 d1                	mov    %edx,%ecx
  801060:	89 d3                	mov    %edx,%ebx
  801062:	89 d7                	mov    %edx,%edi
  801064:	89 d6                	mov    %edx,%esi
  801066:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	57                   	push   %edi
  801071:	56                   	push   %esi
  801072:	53                   	push   %ebx
  801073:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801076:	be 00 00 00 00       	mov    $0x0,%esi
  80107b:	b8 04 00 00 00       	mov    $0x4,%eax
  801080:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801083:	8b 55 08             	mov    0x8(%ebp),%edx
  801086:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801089:	89 f7                	mov    %esi,%edi
  80108b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80108d:	85 c0                	test   %eax,%eax
  80108f:	7e 17                	jle    8010a8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	50                   	push   %eax
  801095:	6a 04                	push   $0x4
  801097:	68 1f 2f 80 00       	push   $0x802f1f
  80109c:	6a 23                	push   $0x23
  80109e:	68 3c 2f 80 00       	push   $0x802f3c
  8010a3:	e8 44 f5 ff ff       	call   8005ec <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ab:	5b                   	pop    %ebx
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  8010b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8010be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010c7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ca:	8b 75 18             	mov    0x18(%ebp),%esi
  8010cd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	7e 17                	jle    8010ea <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	50                   	push   %eax
  8010d7:	6a 05                	push   $0x5
  8010d9:	68 1f 2f 80 00       	push   $0x802f1f
  8010de:	6a 23                	push   $0x23
  8010e0:	68 3c 2f 80 00       	push   $0x802f3c
  8010e5:	e8 02 f5 ff ff       	call   8005ec <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801100:	b8 06 00 00 00       	mov    $0x6,%eax
  801105:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 df                	mov    %ebx,%edi
  80110d:	89 de                	mov    %ebx,%esi
  80110f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801111:	85 c0                	test   %eax,%eax
  801113:	7e 17                	jle    80112c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801115:	83 ec 0c             	sub    $0xc,%esp
  801118:	50                   	push   %eax
  801119:	6a 06                	push   $0x6
  80111b:	68 1f 2f 80 00       	push   $0x802f1f
  801120:	6a 23                	push   $0x23
  801122:	68 3c 2f 80 00       	push   $0x802f3c
  801127:	e8 c0 f4 ff ff       	call   8005ec <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80112c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	53                   	push   %ebx
  80113a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801142:	b8 08 00 00 00       	mov    $0x8,%eax
  801147:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114a:	8b 55 08             	mov    0x8(%ebp),%edx
  80114d:	89 df                	mov    %ebx,%edi
  80114f:	89 de                	mov    %ebx,%esi
  801151:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801153:	85 c0                	test   %eax,%eax
  801155:	7e 17                	jle    80116e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801157:	83 ec 0c             	sub    $0xc,%esp
  80115a:	50                   	push   %eax
  80115b:	6a 08                	push   $0x8
  80115d:	68 1f 2f 80 00       	push   $0x802f1f
  801162:	6a 23                	push   $0x23
  801164:	68 3c 2f 80 00       	push   $0x802f3c
  801169:	e8 7e f4 ff ff       	call   8005ec <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80116e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801171:	5b                   	pop    %ebx
  801172:	5e                   	pop    %esi
  801173:	5f                   	pop    %edi
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	57                   	push   %edi
  80117a:	56                   	push   %esi
  80117b:	53                   	push   %ebx
  80117c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801184:	b8 09 00 00 00       	mov    $0x9,%eax
  801189:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118c:	8b 55 08             	mov    0x8(%ebp),%edx
  80118f:	89 df                	mov    %ebx,%edi
  801191:	89 de                	mov    %ebx,%esi
  801193:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801195:	85 c0                	test   %eax,%eax
  801197:	7e 17                	jle    8011b0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801199:	83 ec 0c             	sub    $0xc,%esp
  80119c:	50                   	push   %eax
  80119d:	6a 09                	push   $0x9
  80119f:	68 1f 2f 80 00       	push   $0x802f1f
  8011a4:	6a 23                	push   $0x23
  8011a6:	68 3c 2f 80 00       	push   $0x802f3c
  8011ab:	e8 3c f4 ff ff       	call   8005ec <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5e                   	pop    %esi
  8011b5:	5f                   	pop    %edi
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	57                   	push   %edi
  8011bc:	56                   	push   %esi
  8011bd:	53                   	push   %ebx
  8011be:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d1:	89 df                	mov    %ebx,%edi
  8011d3:	89 de                	mov    %ebx,%esi
  8011d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	7e 17                	jle    8011f2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011db:	83 ec 0c             	sub    $0xc,%esp
  8011de:	50                   	push   %eax
  8011df:	6a 0a                	push   $0xa
  8011e1:	68 1f 2f 80 00       	push   $0x802f1f
  8011e6:	6a 23                	push   $0x23
  8011e8:	68 3c 2f 80 00       	push   $0x802f3c
  8011ed:	e8 fa f3 ff ff       	call   8005ec <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5f                   	pop    %edi
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	57                   	push   %edi
  8011fe:	56                   	push   %esi
  8011ff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801200:	be 00 00 00 00       	mov    $0x0,%esi
  801205:	b8 0c 00 00 00       	mov    $0xc,%eax
  80120a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120d:	8b 55 08             	mov    0x8(%ebp),%edx
  801210:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801213:	8b 7d 14             	mov    0x14(%ebp),%edi
  801216:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801218:	5b                   	pop    %ebx
  801219:	5e                   	pop    %esi
  80121a:	5f                   	pop    %edi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	57                   	push   %edi
  801221:	56                   	push   %esi
  801222:	53                   	push   %ebx
  801223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801226:	b9 00 00 00 00       	mov    $0x0,%ecx
  80122b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801230:	8b 55 08             	mov    0x8(%ebp),%edx
  801233:	89 cb                	mov    %ecx,%ebx
  801235:	89 cf                	mov    %ecx,%edi
  801237:	89 ce                	mov    %ecx,%esi
  801239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80123b:	85 c0                	test   %eax,%eax
  80123d:	7e 17                	jle    801256 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80123f:	83 ec 0c             	sub    $0xc,%esp
  801242:	50                   	push   %eax
  801243:	6a 0d                	push   $0xd
  801245:	68 1f 2f 80 00       	push   $0x802f1f
  80124a:	6a 23                	push   $0x23
  80124c:	68 3c 2f 80 00       	push   $0x802f3c
  801251:	e8 96 f3 ff ff       	call   8005ec <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801259:	5b                   	pop    %ebx
  80125a:	5e                   	pop    %esi
  80125b:	5f                   	pop    %edi
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    

0080125e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801264:	ba 00 00 00 00       	mov    $0x0,%edx
  801269:	b8 0e 00 00 00       	mov    $0xe,%eax
  80126e:	89 d1                	mov    %edx,%ecx
  801270:	89 d3                	mov    %edx,%ebx
  801272:	89 d7                	mov    %edx,%edi
  801274:	89 d6                	mov    %edx,%esi
  801276:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801280:	8b 45 08             	mov    0x8(%ebp),%eax
  801283:	05 00 00 00 30       	add    $0x30000000,%eax
  801288:	c1 e8 0c             	shr    $0xc,%eax
}
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
  801293:	05 00 00 00 30       	add    $0x30000000,%eax
  801298:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80129d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    

008012a4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012aa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012af:	89 c2                	mov    %eax,%edx
  8012b1:	c1 ea 16             	shr    $0x16,%edx
  8012b4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012bb:	f6 c2 01             	test   $0x1,%dl
  8012be:	74 11                	je     8012d1 <fd_alloc+0x2d>
  8012c0:	89 c2                	mov    %eax,%edx
  8012c2:	c1 ea 0c             	shr    $0xc,%edx
  8012c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012cc:	f6 c2 01             	test   $0x1,%dl
  8012cf:	75 09                	jne    8012da <fd_alloc+0x36>
			*fd_store = fd;
  8012d1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d8:	eb 17                	jmp    8012f1 <fd_alloc+0x4d>
  8012da:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012df:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012e4:	75 c9                	jne    8012af <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012e6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012ec:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012f9:	83 f8 1f             	cmp    $0x1f,%eax
  8012fc:	77 36                	ja     801334 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012fe:	c1 e0 0c             	shl    $0xc,%eax
  801301:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801306:	89 c2                	mov    %eax,%edx
  801308:	c1 ea 16             	shr    $0x16,%edx
  80130b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801312:	f6 c2 01             	test   $0x1,%dl
  801315:	74 24                	je     80133b <fd_lookup+0x48>
  801317:	89 c2                	mov    %eax,%edx
  801319:	c1 ea 0c             	shr    $0xc,%edx
  80131c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801323:	f6 c2 01             	test   $0x1,%dl
  801326:	74 1a                	je     801342 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801328:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132b:	89 02                	mov    %eax,(%edx)
	return 0;
  80132d:	b8 00 00 00 00       	mov    $0x0,%eax
  801332:	eb 13                	jmp    801347 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801334:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801339:	eb 0c                	jmp    801347 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80133b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801340:	eb 05                	jmp    801347 <fd_lookup+0x54>
  801342:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	83 ec 08             	sub    $0x8,%esp
  80134f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801352:	ba c8 2f 80 00       	mov    $0x802fc8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801357:	eb 13                	jmp    80136c <dev_lookup+0x23>
  801359:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80135c:	39 08                	cmp    %ecx,(%eax)
  80135e:	75 0c                	jne    80136c <dev_lookup+0x23>
			*dev = devtab[i];
  801360:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801363:	89 01                	mov    %eax,(%ecx)
			return 0;
  801365:	b8 00 00 00 00       	mov    $0x0,%eax
  80136a:	eb 2e                	jmp    80139a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80136c:	8b 02                	mov    (%edx),%eax
  80136e:	85 c0                	test   %eax,%eax
  801370:	75 e7                	jne    801359 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801372:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801377:	8b 40 48             	mov    0x48(%eax),%eax
  80137a:	83 ec 04             	sub    $0x4,%esp
  80137d:	51                   	push   %ecx
  80137e:	50                   	push   %eax
  80137f:	68 4c 2f 80 00       	push   $0x802f4c
  801384:	e8 3c f3 ff ff       	call   8006c5 <cprintf>
	*dev = 0;
  801389:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80139a:	c9                   	leave  
  80139b:	c3                   	ret    

0080139c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	56                   	push   %esi
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 10             	sub    $0x10,%esp
  8013a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8013a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013b4:	c1 e8 0c             	shr    $0xc,%eax
  8013b7:	50                   	push   %eax
  8013b8:	e8 36 ff ff ff       	call   8012f3 <fd_lookup>
  8013bd:	83 c4 08             	add    $0x8,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 05                	js     8013c9 <fd_close+0x2d>
	    || fd != fd2)
  8013c4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013c7:	74 0c                	je     8013d5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013c9:	84 db                	test   %bl,%bl
  8013cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d0:	0f 44 c2             	cmove  %edx,%eax
  8013d3:	eb 41                	jmp    801416 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013db:	50                   	push   %eax
  8013dc:	ff 36                	pushl  (%esi)
  8013de:	e8 66 ff ff ff       	call   801349 <dev_lookup>
  8013e3:	89 c3                	mov    %eax,%ebx
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 1a                	js     801406 <fd_close+0x6a>
		if (dev->dev_close)
  8013ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ef:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013f2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	74 0b                	je     801406 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013fb:	83 ec 0c             	sub    $0xc,%esp
  8013fe:	56                   	push   %esi
  8013ff:	ff d0                	call   *%eax
  801401:	89 c3                	mov    %eax,%ebx
  801403:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801406:	83 ec 08             	sub    $0x8,%esp
  801409:	56                   	push   %esi
  80140a:	6a 00                	push   $0x0
  80140c:	e8 e1 fc ff ff       	call   8010f2 <sys_page_unmap>
	return r;
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	89 d8                	mov    %ebx,%eax
}
  801416:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801419:	5b                   	pop    %ebx
  80141a:	5e                   	pop    %esi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801423:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801426:	50                   	push   %eax
  801427:	ff 75 08             	pushl  0x8(%ebp)
  80142a:	e8 c4 fe ff ff       	call   8012f3 <fd_lookup>
  80142f:	83 c4 08             	add    $0x8,%esp
  801432:	85 c0                	test   %eax,%eax
  801434:	78 10                	js     801446 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	6a 01                	push   $0x1
  80143b:	ff 75 f4             	pushl  -0xc(%ebp)
  80143e:	e8 59 ff ff ff       	call   80139c <fd_close>
  801443:	83 c4 10             	add    $0x10,%esp
}
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <close_all>:

void
close_all(void)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	53                   	push   %ebx
  80144c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80144f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801454:	83 ec 0c             	sub    $0xc,%esp
  801457:	53                   	push   %ebx
  801458:	e8 c0 ff ff ff       	call   80141d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80145d:	83 c3 01             	add    $0x1,%ebx
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	83 fb 20             	cmp    $0x20,%ebx
  801466:	75 ec                	jne    801454 <close_all+0xc>
		close(i);
}
  801468:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146b:	c9                   	leave  
  80146c:	c3                   	ret    

0080146d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	57                   	push   %edi
  801471:	56                   	push   %esi
  801472:	53                   	push   %ebx
  801473:	83 ec 2c             	sub    $0x2c,%esp
  801476:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801479:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	ff 75 08             	pushl  0x8(%ebp)
  801480:	e8 6e fe ff ff       	call   8012f3 <fd_lookup>
  801485:	83 c4 08             	add    $0x8,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	0f 88 c1 00 00 00    	js     801551 <dup+0xe4>
		return r;
	close(newfdnum);
  801490:	83 ec 0c             	sub    $0xc,%esp
  801493:	56                   	push   %esi
  801494:	e8 84 ff ff ff       	call   80141d <close>

	newfd = INDEX2FD(newfdnum);
  801499:	89 f3                	mov    %esi,%ebx
  80149b:	c1 e3 0c             	shl    $0xc,%ebx
  80149e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014a4:	83 c4 04             	add    $0x4,%esp
  8014a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014aa:	e8 de fd ff ff       	call   80128d <fd2data>
  8014af:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014b1:	89 1c 24             	mov    %ebx,(%esp)
  8014b4:	e8 d4 fd ff ff       	call   80128d <fd2data>
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014bf:	89 f8                	mov    %edi,%eax
  8014c1:	c1 e8 16             	shr    $0x16,%eax
  8014c4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014cb:	a8 01                	test   $0x1,%al
  8014cd:	74 37                	je     801506 <dup+0x99>
  8014cf:	89 f8                	mov    %edi,%eax
  8014d1:	c1 e8 0c             	shr    $0xc,%eax
  8014d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014db:	f6 c2 01             	test   $0x1,%dl
  8014de:	74 26                	je     801506 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e7:	83 ec 0c             	sub    $0xc,%esp
  8014ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ef:	50                   	push   %eax
  8014f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f3:	6a 00                	push   $0x0
  8014f5:	57                   	push   %edi
  8014f6:	6a 00                	push   $0x0
  8014f8:	e8 b3 fb ff ff       	call   8010b0 <sys_page_map>
  8014fd:	89 c7                	mov    %eax,%edi
  8014ff:	83 c4 20             	add    $0x20,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	78 2e                	js     801534 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801506:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801509:	89 d0                	mov    %edx,%eax
  80150b:	c1 e8 0c             	shr    $0xc,%eax
  80150e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801515:	83 ec 0c             	sub    $0xc,%esp
  801518:	25 07 0e 00 00       	and    $0xe07,%eax
  80151d:	50                   	push   %eax
  80151e:	53                   	push   %ebx
  80151f:	6a 00                	push   $0x0
  801521:	52                   	push   %edx
  801522:	6a 00                	push   $0x0
  801524:	e8 87 fb ff ff       	call   8010b0 <sys_page_map>
  801529:	89 c7                	mov    %eax,%edi
  80152b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80152e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801530:	85 ff                	test   %edi,%edi
  801532:	79 1d                	jns    801551 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801534:	83 ec 08             	sub    $0x8,%esp
  801537:	53                   	push   %ebx
  801538:	6a 00                	push   $0x0
  80153a:	e8 b3 fb ff ff       	call   8010f2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80153f:	83 c4 08             	add    $0x8,%esp
  801542:	ff 75 d4             	pushl  -0x2c(%ebp)
  801545:	6a 00                	push   $0x0
  801547:	e8 a6 fb ff ff       	call   8010f2 <sys_page_unmap>
	return r;
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	89 f8                	mov    %edi,%eax
}
  801551:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801554:	5b                   	pop    %ebx
  801555:	5e                   	pop    %esi
  801556:	5f                   	pop    %edi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	53                   	push   %ebx
  80155d:	83 ec 14             	sub    $0x14,%esp
  801560:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801563:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801566:	50                   	push   %eax
  801567:	53                   	push   %ebx
  801568:	e8 86 fd ff ff       	call   8012f3 <fd_lookup>
  80156d:	83 c4 08             	add    $0x8,%esp
  801570:	89 c2                	mov    %eax,%edx
  801572:	85 c0                	test   %eax,%eax
  801574:	78 6d                	js     8015e3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157c:	50                   	push   %eax
  80157d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801580:	ff 30                	pushl  (%eax)
  801582:	e8 c2 fd ff ff       	call   801349 <dev_lookup>
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 4c                	js     8015da <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80158e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801591:	8b 42 08             	mov    0x8(%edx),%eax
  801594:	83 e0 03             	and    $0x3,%eax
  801597:	83 f8 01             	cmp    $0x1,%eax
  80159a:	75 21                	jne    8015bd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80159c:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8015a1:	8b 40 48             	mov    0x48(%eax),%eax
  8015a4:	83 ec 04             	sub    $0x4,%esp
  8015a7:	53                   	push   %ebx
  8015a8:	50                   	push   %eax
  8015a9:	68 8d 2f 80 00       	push   $0x802f8d
  8015ae:	e8 12 f1 ff ff       	call   8006c5 <cprintf>
		return -E_INVAL;
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015bb:	eb 26                	jmp    8015e3 <read+0x8a>
	}
	if (!dev->dev_read)
  8015bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c0:	8b 40 08             	mov    0x8(%eax),%eax
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	74 17                	je     8015de <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015c7:	83 ec 04             	sub    $0x4,%esp
  8015ca:	ff 75 10             	pushl  0x10(%ebp)
  8015cd:	ff 75 0c             	pushl  0xc(%ebp)
  8015d0:	52                   	push   %edx
  8015d1:	ff d0                	call   *%eax
  8015d3:	89 c2                	mov    %eax,%edx
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	eb 09                	jmp    8015e3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	eb 05                	jmp    8015e3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015e3:	89 d0                	mov    %edx,%eax
  8015e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	57                   	push   %edi
  8015ee:	56                   	push   %esi
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 0c             	sub    $0xc,%esp
  8015f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fe:	eb 21                	jmp    801621 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	89 f0                	mov    %esi,%eax
  801605:	29 d8                	sub    %ebx,%eax
  801607:	50                   	push   %eax
  801608:	89 d8                	mov    %ebx,%eax
  80160a:	03 45 0c             	add    0xc(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	57                   	push   %edi
  80160f:	e8 45 ff ff ff       	call   801559 <read>
		if (m < 0)
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	78 10                	js     80162b <readn+0x41>
			return m;
		if (m == 0)
  80161b:	85 c0                	test   %eax,%eax
  80161d:	74 0a                	je     801629 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80161f:	01 c3                	add    %eax,%ebx
  801621:	39 f3                	cmp    %esi,%ebx
  801623:	72 db                	jb     801600 <readn+0x16>
  801625:	89 d8                	mov    %ebx,%eax
  801627:	eb 02                	jmp    80162b <readn+0x41>
  801629:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80162b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162e:	5b                   	pop    %ebx
  80162f:	5e                   	pop    %esi
  801630:	5f                   	pop    %edi
  801631:	5d                   	pop    %ebp
  801632:	c3                   	ret    

00801633 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	53                   	push   %ebx
  801637:	83 ec 14             	sub    $0x14,%esp
  80163a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801640:	50                   	push   %eax
  801641:	53                   	push   %ebx
  801642:	e8 ac fc ff ff       	call   8012f3 <fd_lookup>
  801647:	83 c4 08             	add    $0x8,%esp
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 68                	js     8016b8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165a:	ff 30                	pushl  (%eax)
  80165c:	e8 e8 fc ff ff       	call   801349 <dev_lookup>
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	85 c0                	test   %eax,%eax
  801666:	78 47                	js     8016af <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801668:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80166f:	75 21                	jne    801692 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801671:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801676:	8b 40 48             	mov    0x48(%eax),%eax
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	53                   	push   %ebx
  80167d:	50                   	push   %eax
  80167e:	68 a9 2f 80 00       	push   $0x802fa9
  801683:	e8 3d f0 ff ff       	call   8006c5 <cprintf>
		return -E_INVAL;
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801690:	eb 26                	jmp    8016b8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801692:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801695:	8b 52 0c             	mov    0xc(%edx),%edx
  801698:	85 d2                	test   %edx,%edx
  80169a:	74 17                	je     8016b3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80169c:	83 ec 04             	sub    $0x4,%esp
  80169f:	ff 75 10             	pushl  0x10(%ebp)
  8016a2:	ff 75 0c             	pushl  0xc(%ebp)
  8016a5:	50                   	push   %eax
  8016a6:	ff d2                	call   *%edx
  8016a8:	89 c2                	mov    %eax,%edx
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	eb 09                	jmp    8016b8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	eb 05                	jmp    8016b8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016b8:	89 d0                	mov    %edx,%eax
  8016ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <seek>:

int
seek(int fdnum, off_t offset)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016c5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	ff 75 08             	pushl  0x8(%ebp)
  8016cc:	e8 22 fc ff ff       	call   8012f3 <fd_lookup>
  8016d1:	83 c4 08             	add    $0x8,%esp
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 0e                	js     8016e6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016de:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 14             	sub    $0x14,%esp
  8016ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f5:	50                   	push   %eax
  8016f6:	53                   	push   %ebx
  8016f7:	e8 f7 fb ff ff       	call   8012f3 <fd_lookup>
  8016fc:	83 c4 08             	add    $0x8,%esp
  8016ff:	89 c2                	mov    %eax,%edx
  801701:	85 c0                	test   %eax,%eax
  801703:	78 65                	js     80176a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801705:	83 ec 08             	sub    $0x8,%esp
  801708:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170b:	50                   	push   %eax
  80170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170f:	ff 30                	pushl  (%eax)
  801711:	e8 33 fc ff ff       	call   801349 <dev_lookup>
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 44                	js     801761 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801720:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801724:	75 21                	jne    801747 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801726:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80172b:	8b 40 48             	mov    0x48(%eax),%eax
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	53                   	push   %ebx
  801732:	50                   	push   %eax
  801733:	68 6c 2f 80 00       	push   $0x802f6c
  801738:	e8 88 ef ff ff       	call   8006c5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801745:	eb 23                	jmp    80176a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801747:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80174a:	8b 52 18             	mov    0x18(%edx),%edx
  80174d:	85 d2                	test   %edx,%edx
  80174f:	74 14                	je     801765 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	ff 75 0c             	pushl  0xc(%ebp)
  801757:	50                   	push   %eax
  801758:	ff d2                	call   *%edx
  80175a:	89 c2                	mov    %eax,%edx
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	eb 09                	jmp    80176a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801761:	89 c2                	mov    %eax,%edx
  801763:	eb 05                	jmp    80176a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801765:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80176a:	89 d0                	mov    %edx,%eax
  80176c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	53                   	push   %ebx
  801775:	83 ec 14             	sub    $0x14,%esp
  801778:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177e:	50                   	push   %eax
  80177f:	ff 75 08             	pushl  0x8(%ebp)
  801782:	e8 6c fb ff ff       	call   8012f3 <fd_lookup>
  801787:	83 c4 08             	add    $0x8,%esp
  80178a:	89 c2                	mov    %eax,%edx
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 58                	js     8017e8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801790:	83 ec 08             	sub    $0x8,%esp
  801793:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801796:	50                   	push   %eax
  801797:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179a:	ff 30                	pushl  (%eax)
  80179c:	e8 a8 fb ff ff       	call   801349 <dev_lookup>
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 37                	js     8017df <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ab:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017af:	74 32                	je     8017e3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017b1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017b4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017bb:	00 00 00 
	stat->st_isdir = 0;
  8017be:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017c5:	00 00 00 
	stat->st_dev = dev;
  8017c8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ce:	83 ec 08             	sub    $0x8,%esp
  8017d1:	53                   	push   %ebx
  8017d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d5:	ff 50 14             	call   *0x14(%eax)
  8017d8:	89 c2                	mov    %eax,%edx
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	eb 09                	jmp    8017e8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017df:	89 c2                	mov    %eax,%edx
  8017e1:	eb 05                	jmp    8017e8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017e8:	89 d0                	mov    %edx,%eax
  8017ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ed:	c9                   	leave  
  8017ee:	c3                   	ret    

008017ef <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	56                   	push   %esi
  8017f3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017f4:	83 ec 08             	sub    $0x8,%esp
  8017f7:	6a 00                	push   $0x0
  8017f9:	ff 75 08             	pushl  0x8(%ebp)
  8017fc:	e8 ef 01 00 00       	call   8019f0 <open>
  801801:	89 c3                	mov    %eax,%ebx
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	85 c0                	test   %eax,%eax
  801808:	78 1b                	js     801825 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80180a:	83 ec 08             	sub    $0x8,%esp
  80180d:	ff 75 0c             	pushl  0xc(%ebp)
  801810:	50                   	push   %eax
  801811:	e8 5b ff ff ff       	call   801771 <fstat>
  801816:	89 c6                	mov    %eax,%esi
	close(fd);
  801818:	89 1c 24             	mov    %ebx,(%esp)
  80181b:	e8 fd fb ff ff       	call   80141d <close>
	return r;
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	89 f0                	mov    %esi,%eax
}
  801825:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801828:	5b                   	pop    %ebx
  801829:	5e                   	pop    %esi
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    

0080182c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	56                   	push   %esi
  801830:	53                   	push   %ebx
  801831:	89 c6                	mov    %eax,%esi
  801833:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801835:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  80183c:	75 12                	jne    801850 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80183e:	83 ec 0c             	sub    $0xc,%esp
  801841:	6a 01                	push   $0x1
  801843:	e8 e5 0e 00 00       	call   80272d <ipc_find_env>
  801848:	a3 10 50 80 00       	mov    %eax,0x805010
  80184d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801850:	6a 07                	push   $0x7
  801852:	68 00 60 80 00       	push   $0x806000
  801857:	56                   	push   %esi
  801858:	ff 35 10 50 80 00    	pushl  0x805010
  80185e:	e8 7b 0e 00 00       	call   8026de <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801863:	83 c4 0c             	add    $0xc,%esp
  801866:	6a 00                	push   $0x0
  801868:	53                   	push   %ebx
  801869:	6a 00                	push   $0x0
  80186b:	e8 f8 0d 00 00       	call   802668 <ipc_recv>
}
  801870:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801873:	5b                   	pop    %ebx
  801874:	5e                   	pop    %esi
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80187d:	8b 45 08             	mov    0x8(%ebp),%eax
  801880:	8b 40 0c             	mov    0xc(%eax),%eax
  801883:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188b:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801890:	ba 00 00 00 00       	mov    $0x0,%edx
  801895:	b8 02 00 00 00       	mov    $0x2,%eax
  80189a:	e8 8d ff ff ff       	call   80182c <fsipc>
}
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    

008018a1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ad:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b7:	b8 06 00 00 00       	mov    $0x6,%eax
  8018bc:	e8 6b ff ff ff       	call   80182c <fsipc>
}
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	53                   	push   %ebx
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d3:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dd:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e2:	e8 45 ff ff ff       	call   80182c <fsipc>
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 2c                	js     801917 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018eb:	83 ec 08             	sub    $0x8,%esp
  8018ee:	68 00 60 80 00       	push   $0x806000
  8018f3:	53                   	push   %ebx
  8018f4:	e8 71 f3 ff ff       	call   800c6a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f9:	a1 80 60 80 00       	mov    0x806080,%eax
  8018fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801904:	a1 84 60 80 00       	mov    0x806084,%eax
  801909:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801917:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	53                   	push   %ebx
  801920:	83 ec 08             	sub    $0x8,%esp
  801923:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801926:	8b 55 08             	mov    0x8(%ebp),%edx
  801929:	8b 52 0c             	mov    0xc(%edx),%edx
  80192c:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801932:	a3 04 60 80 00       	mov    %eax,0x806004
  801937:	3d 08 60 80 00       	cmp    $0x806008,%eax
  80193c:	bb 08 60 80 00       	mov    $0x806008,%ebx
  801941:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801944:	53                   	push   %ebx
  801945:	ff 75 0c             	pushl  0xc(%ebp)
  801948:	68 08 60 80 00       	push   $0x806008
  80194d:	e8 aa f4 ff ff       	call   800dfc <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801952:	ba 00 00 00 00       	mov    $0x0,%edx
  801957:	b8 04 00 00 00       	mov    $0x4,%eax
  80195c:	e8 cb fe ff ff       	call   80182c <fsipc>
  801961:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801964:	85 c0                	test   %eax,%eax
  801966:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801969:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    

0080196e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	56                   	push   %esi
  801972:	53                   	push   %ebx
  801973:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801976:	8b 45 08             	mov    0x8(%ebp),%eax
  801979:	8b 40 0c             	mov    0xc(%eax),%eax
  80197c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801981:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801987:	ba 00 00 00 00       	mov    $0x0,%edx
  80198c:	b8 03 00 00 00       	mov    $0x3,%eax
  801991:	e8 96 fe ff ff       	call   80182c <fsipc>
  801996:	89 c3                	mov    %eax,%ebx
  801998:	85 c0                	test   %eax,%eax
  80199a:	78 4b                	js     8019e7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80199c:	39 c6                	cmp    %eax,%esi
  80199e:	73 16                	jae    8019b6 <devfile_read+0x48>
  8019a0:	68 dc 2f 80 00       	push   $0x802fdc
  8019a5:	68 e3 2f 80 00       	push   $0x802fe3
  8019aa:	6a 7c                	push   $0x7c
  8019ac:	68 f8 2f 80 00       	push   $0x802ff8
  8019b1:	e8 36 ec ff ff       	call   8005ec <_panic>
	assert(r <= PGSIZE);
  8019b6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019bb:	7e 16                	jle    8019d3 <devfile_read+0x65>
  8019bd:	68 03 30 80 00       	push   $0x803003
  8019c2:	68 e3 2f 80 00       	push   $0x802fe3
  8019c7:	6a 7d                	push   $0x7d
  8019c9:	68 f8 2f 80 00       	push   $0x802ff8
  8019ce:	e8 19 ec ff ff       	call   8005ec <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019d3:	83 ec 04             	sub    $0x4,%esp
  8019d6:	50                   	push   %eax
  8019d7:	68 00 60 80 00       	push   $0x806000
  8019dc:	ff 75 0c             	pushl  0xc(%ebp)
  8019df:	e8 18 f4 ff ff       	call   800dfc <memmove>
	return r;
  8019e4:	83 c4 10             	add    $0x10,%esp
}
  8019e7:	89 d8                	mov    %ebx,%eax
  8019e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ec:	5b                   	pop    %ebx
  8019ed:	5e                   	pop    %esi
  8019ee:	5d                   	pop    %ebp
  8019ef:	c3                   	ret    

008019f0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	53                   	push   %ebx
  8019f4:	83 ec 20             	sub    $0x20,%esp
  8019f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019fa:	53                   	push   %ebx
  8019fb:	e8 31 f2 ff ff       	call   800c31 <strlen>
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a08:	7f 67                	jg     801a71 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a10:	50                   	push   %eax
  801a11:	e8 8e f8 ff ff       	call   8012a4 <fd_alloc>
  801a16:	83 c4 10             	add    $0x10,%esp
		return r;
  801a19:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	78 57                	js     801a76 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a1f:	83 ec 08             	sub    $0x8,%esp
  801a22:	53                   	push   %ebx
  801a23:	68 00 60 80 00       	push   $0x806000
  801a28:	e8 3d f2 ff ff       	call   800c6a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a30:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a38:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3d:	e8 ea fd ff ff       	call   80182c <fsipc>
  801a42:	89 c3                	mov    %eax,%ebx
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	85 c0                	test   %eax,%eax
  801a49:	79 14                	jns    801a5f <open+0x6f>
		fd_close(fd, 0);
  801a4b:	83 ec 08             	sub    $0x8,%esp
  801a4e:	6a 00                	push   $0x0
  801a50:	ff 75 f4             	pushl  -0xc(%ebp)
  801a53:	e8 44 f9 ff ff       	call   80139c <fd_close>
		return r;
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	89 da                	mov    %ebx,%edx
  801a5d:	eb 17                	jmp    801a76 <open+0x86>
	}

	return fd2num(fd);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	ff 75 f4             	pushl  -0xc(%ebp)
  801a65:	e8 13 f8 ff ff       	call   80127d <fd2num>
  801a6a:	89 c2                	mov    %eax,%edx
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	eb 05                	jmp    801a76 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a71:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a76:	89 d0                	mov    %edx,%eax
  801a78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7b:	c9                   	leave  
  801a7c:	c3                   	ret    

00801a7d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a83:	ba 00 00 00 00       	mov    $0x0,%edx
  801a88:	b8 08 00 00 00       	mov    $0x8,%eax
  801a8d:	e8 9a fd ff ff       	call   80182c <fsipc>
}
  801a92:	c9                   	leave  
  801a93:	c3                   	ret    

00801a94 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	56                   	push   %esi
  801a98:	53                   	push   %ebx
  801a99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	ff 75 08             	pushl  0x8(%ebp)
  801aa2:	e8 e6 f7 ff ff       	call   80128d <fd2data>
  801aa7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aa9:	83 c4 08             	add    $0x8,%esp
  801aac:	68 0f 30 80 00       	push   $0x80300f
  801ab1:	53                   	push   %ebx
  801ab2:	e8 b3 f1 ff ff       	call   800c6a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ab7:	8b 46 04             	mov    0x4(%esi),%eax
  801aba:	2b 06                	sub    (%esi),%eax
  801abc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ac2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ac9:	00 00 00 
	stat->st_dev = &devpipe;
  801acc:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  801ad3:	40 80 00 
	return 0;
}
  801ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  801adb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ade:	5b                   	pop    %ebx
  801adf:	5e                   	pop    %esi
  801ae0:	5d                   	pop    %ebp
  801ae1:	c3                   	ret    

00801ae2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	53                   	push   %ebx
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aec:	53                   	push   %ebx
  801aed:	6a 00                	push   $0x0
  801aef:	e8 fe f5 ff ff       	call   8010f2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801af4:	89 1c 24             	mov    %ebx,(%esp)
  801af7:	e8 91 f7 ff ff       	call   80128d <fd2data>
  801afc:	83 c4 08             	add    $0x8,%esp
  801aff:	50                   	push   %eax
  801b00:	6a 00                	push   $0x0
  801b02:	e8 eb f5 ff ff       	call   8010f2 <sys_page_unmap>
}
  801b07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	57                   	push   %edi
  801b10:	56                   	push   %esi
  801b11:	53                   	push   %ebx
  801b12:	83 ec 1c             	sub    $0x1c,%esp
  801b15:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b18:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b1a:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801b1f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	ff 75 e0             	pushl  -0x20(%ebp)
  801b28:	e8 39 0c 00 00       	call   802766 <pageref>
  801b2d:	89 c3                	mov    %eax,%ebx
  801b2f:	89 3c 24             	mov    %edi,(%esp)
  801b32:	e8 2f 0c 00 00       	call   802766 <pageref>
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	39 c3                	cmp    %eax,%ebx
  801b3c:	0f 94 c1             	sete   %cl
  801b3f:	0f b6 c9             	movzbl %cl,%ecx
  801b42:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b45:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  801b4b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b4e:	39 ce                	cmp    %ecx,%esi
  801b50:	74 1b                	je     801b6d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b52:	39 c3                	cmp    %eax,%ebx
  801b54:	75 c4                	jne    801b1a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b56:	8b 42 58             	mov    0x58(%edx),%eax
  801b59:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b5c:	50                   	push   %eax
  801b5d:	56                   	push   %esi
  801b5e:	68 16 30 80 00       	push   $0x803016
  801b63:	e8 5d eb ff ff       	call   8006c5 <cprintf>
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	eb ad                	jmp    801b1a <_pipeisclosed+0xe>
	}
}
  801b6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b73:	5b                   	pop    %ebx
  801b74:	5e                   	pop    %esi
  801b75:	5f                   	pop    %edi
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	57                   	push   %edi
  801b7c:	56                   	push   %esi
  801b7d:	53                   	push   %ebx
  801b7e:	83 ec 28             	sub    $0x28,%esp
  801b81:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b84:	56                   	push   %esi
  801b85:	e8 03 f7 ff ff       	call   80128d <fd2data>
  801b8a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	bf 00 00 00 00       	mov    $0x0,%edi
  801b94:	eb 4b                	jmp    801be1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b96:	89 da                	mov    %ebx,%edx
  801b98:	89 f0                	mov    %esi,%eax
  801b9a:	e8 6d ff ff ff       	call   801b0c <_pipeisclosed>
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	75 48                	jne    801beb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ba3:	e8 a6 f4 ff ff       	call   80104e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ba8:	8b 43 04             	mov    0x4(%ebx),%eax
  801bab:	8b 0b                	mov    (%ebx),%ecx
  801bad:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb0:	39 d0                	cmp    %edx,%eax
  801bb2:	73 e2                	jae    801b96 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bbb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bbe:	89 c2                	mov    %eax,%edx
  801bc0:	c1 fa 1f             	sar    $0x1f,%edx
  801bc3:	89 d1                	mov    %edx,%ecx
  801bc5:	c1 e9 1b             	shr    $0x1b,%ecx
  801bc8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bcb:	83 e2 1f             	and    $0x1f,%edx
  801bce:	29 ca                	sub    %ecx,%edx
  801bd0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bd4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bd8:	83 c0 01             	add    $0x1,%eax
  801bdb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bde:	83 c7 01             	add    $0x1,%edi
  801be1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801be4:	75 c2                	jne    801ba8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801be6:	8b 45 10             	mov    0x10(%ebp),%eax
  801be9:	eb 05                	jmp    801bf0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801beb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	57                   	push   %edi
  801bfc:	56                   	push   %esi
  801bfd:	53                   	push   %ebx
  801bfe:	83 ec 18             	sub    $0x18,%esp
  801c01:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c04:	57                   	push   %edi
  801c05:	e8 83 f6 ff ff       	call   80128d <fd2data>
  801c0a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c14:	eb 3d                	jmp    801c53 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c16:	85 db                	test   %ebx,%ebx
  801c18:	74 04                	je     801c1e <devpipe_read+0x26>
				return i;
  801c1a:	89 d8                	mov    %ebx,%eax
  801c1c:	eb 44                	jmp    801c62 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c1e:	89 f2                	mov    %esi,%edx
  801c20:	89 f8                	mov    %edi,%eax
  801c22:	e8 e5 fe ff ff       	call   801b0c <_pipeisclosed>
  801c27:	85 c0                	test   %eax,%eax
  801c29:	75 32                	jne    801c5d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c2b:	e8 1e f4 ff ff       	call   80104e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c30:	8b 06                	mov    (%esi),%eax
  801c32:	3b 46 04             	cmp    0x4(%esi),%eax
  801c35:	74 df                	je     801c16 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c37:	99                   	cltd   
  801c38:	c1 ea 1b             	shr    $0x1b,%edx
  801c3b:	01 d0                	add    %edx,%eax
  801c3d:	83 e0 1f             	and    $0x1f,%eax
  801c40:	29 d0                	sub    %edx,%eax
  801c42:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c4d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c50:	83 c3 01             	add    $0x1,%ebx
  801c53:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c56:	75 d8                	jne    801c30 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c58:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5b:	eb 05                	jmp    801c62 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c65:	5b                   	pop    %ebx
  801c66:	5e                   	pop    %esi
  801c67:	5f                   	pop    %edi
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	56                   	push   %esi
  801c6e:	53                   	push   %ebx
  801c6f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c75:	50                   	push   %eax
  801c76:	e8 29 f6 ff ff       	call   8012a4 <fd_alloc>
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	89 c2                	mov    %eax,%edx
  801c80:	85 c0                	test   %eax,%eax
  801c82:	0f 88 2c 01 00 00    	js     801db4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c88:	83 ec 04             	sub    $0x4,%esp
  801c8b:	68 07 04 00 00       	push   $0x407
  801c90:	ff 75 f4             	pushl  -0xc(%ebp)
  801c93:	6a 00                	push   $0x0
  801c95:	e8 d3 f3 ff ff       	call   80106d <sys_page_alloc>
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	89 c2                	mov    %eax,%edx
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	0f 88 0d 01 00 00    	js     801db4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ca7:	83 ec 0c             	sub    $0xc,%esp
  801caa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cad:	50                   	push   %eax
  801cae:	e8 f1 f5 ff ff       	call   8012a4 <fd_alloc>
  801cb3:	89 c3                	mov    %eax,%ebx
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	0f 88 e2 00 00 00    	js     801da2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc0:	83 ec 04             	sub    $0x4,%esp
  801cc3:	68 07 04 00 00       	push   $0x407
  801cc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccb:	6a 00                	push   $0x0
  801ccd:	e8 9b f3 ff ff       	call   80106d <sys_page_alloc>
  801cd2:	89 c3                	mov    %eax,%ebx
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	0f 88 c3 00 00 00    	js     801da2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce5:	e8 a3 f5 ff ff       	call   80128d <fd2data>
  801cea:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cec:	83 c4 0c             	add    $0xc,%esp
  801cef:	68 07 04 00 00       	push   $0x407
  801cf4:	50                   	push   %eax
  801cf5:	6a 00                	push   $0x0
  801cf7:	e8 71 f3 ff ff       	call   80106d <sys_page_alloc>
  801cfc:	89 c3                	mov    %eax,%ebx
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	85 c0                	test   %eax,%eax
  801d03:	0f 88 89 00 00 00    	js     801d92 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d09:	83 ec 0c             	sub    $0xc,%esp
  801d0c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0f:	e8 79 f5 ff ff       	call   80128d <fd2data>
  801d14:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d1b:	50                   	push   %eax
  801d1c:	6a 00                	push   $0x0
  801d1e:	56                   	push   %esi
  801d1f:	6a 00                	push   $0x0
  801d21:	e8 8a f3 ff ff       	call   8010b0 <sys_page_map>
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	83 c4 20             	add    $0x20,%esp
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	78 55                	js     801d84 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d2f:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d38:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d44:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801d4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d52:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d59:	83 ec 0c             	sub    $0xc,%esp
  801d5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5f:	e8 19 f5 ff ff       	call   80127d <fd2num>
  801d64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d67:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d69:	83 c4 04             	add    $0x4,%esp
  801d6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6f:	e8 09 f5 ff ff       	call   80127d <fd2num>
  801d74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d77:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d82:	eb 30                	jmp    801db4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d84:	83 ec 08             	sub    $0x8,%esp
  801d87:	56                   	push   %esi
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 63 f3 ff ff       	call   8010f2 <sys_page_unmap>
  801d8f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d92:	83 ec 08             	sub    $0x8,%esp
  801d95:	ff 75 f0             	pushl  -0x10(%ebp)
  801d98:	6a 00                	push   $0x0
  801d9a:	e8 53 f3 ff ff       	call   8010f2 <sys_page_unmap>
  801d9f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801da2:	83 ec 08             	sub    $0x8,%esp
  801da5:	ff 75 f4             	pushl  -0xc(%ebp)
  801da8:	6a 00                	push   $0x0
  801daa:	e8 43 f3 ff ff       	call   8010f2 <sys_page_unmap>
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801db4:	89 d0                	mov    %edx,%eax
  801db6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db9:	5b                   	pop    %ebx
  801dba:	5e                   	pop    %esi
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    

00801dbd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc6:	50                   	push   %eax
  801dc7:	ff 75 08             	pushl  0x8(%ebp)
  801dca:	e8 24 f5 ff ff       	call   8012f3 <fd_lookup>
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	78 18                	js     801dee <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dd6:	83 ec 0c             	sub    $0xc,%esp
  801dd9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddc:	e8 ac f4 ff ff       	call   80128d <fd2data>
	return _pipeisclosed(fd, p);
  801de1:	89 c2                	mov    %eax,%edx
  801de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de6:	e8 21 fd ff ff       	call   801b0c <_pipeisclosed>
  801deb:	83 c4 10             	add    $0x10,%esp
}
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801df6:	68 2e 30 80 00       	push   $0x80302e
  801dfb:	ff 75 0c             	pushl  0xc(%ebp)
  801dfe:	e8 67 ee ff ff       	call   800c6a <strcpy>
	return 0;
}
  801e03:	b8 00 00 00 00       	mov    $0x0,%eax
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	53                   	push   %ebx
  801e0e:	83 ec 10             	sub    $0x10,%esp
  801e11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e14:	53                   	push   %ebx
  801e15:	e8 4c 09 00 00       	call   802766 <pageref>
  801e1a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801e1d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801e22:	83 f8 01             	cmp    $0x1,%eax
  801e25:	75 10                	jne    801e37 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801e27:	83 ec 0c             	sub    $0xc,%esp
  801e2a:	ff 73 0c             	pushl  0xc(%ebx)
  801e2d:	e8 c0 02 00 00       	call   8020f2 <nsipc_close>
  801e32:	89 c2                	mov    %eax,%edx
  801e34:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801e37:	89 d0                	mov    %edx,%eax
  801e39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e44:	6a 00                	push   $0x0
  801e46:	ff 75 10             	pushl  0x10(%ebp)
  801e49:	ff 75 0c             	pushl  0xc(%ebp)
  801e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4f:	ff 70 0c             	pushl  0xc(%eax)
  801e52:	e8 78 03 00 00       	call   8021cf <nsipc_send>
}
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e5f:	6a 00                	push   $0x0
  801e61:	ff 75 10             	pushl  0x10(%ebp)
  801e64:	ff 75 0c             	pushl  0xc(%ebp)
  801e67:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6a:	ff 70 0c             	pushl  0xc(%eax)
  801e6d:	e8 f1 02 00 00       	call   802163 <nsipc_recv>
}
  801e72:	c9                   	leave  
  801e73:	c3                   	ret    

00801e74 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e7a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e7d:	52                   	push   %edx
  801e7e:	50                   	push   %eax
  801e7f:	e8 6f f4 ff ff       	call   8012f3 <fd_lookup>
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	85 c0                	test   %eax,%eax
  801e89:	78 17                	js     801ea2 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8e:	8b 0d 5c 40 80 00    	mov    0x80405c,%ecx
  801e94:	39 08                	cmp    %ecx,(%eax)
  801e96:	75 05                	jne    801e9d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e98:	8b 40 0c             	mov    0xc(%eax),%eax
  801e9b:	eb 05                	jmp    801ea2 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e9d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ea2:	c9                   	leave  
  801ea3:	c3                   	ret    

00801ea4 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	56                   	push   %esi
  801ea8:	53                   	push   %ebx
  801ea9:	83 ec 1c             	sub    $0x1c,%esp
  801eac:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801eae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb1:	50                   	push   %eax
  801eb2:	e8 ed f3 ff ff       	call   8012a4 <fd_alloc>
  801eb7:	89 c3                	mov    %eax,%ebx
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 1b                	js     801edb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ec0:	83 ec 04             	sub    $0x4,%esp
  801ec3:	68 07 04 00 00       	push   $0x407
  801ec8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecb:	6a 00                	push   $0x0
  801ecd:	e8 9b f1 ff ff       	call   80106d <sys_page_alloc>
  801ed2:	89 c3                	mov    %eax,%ebx
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	79 10                	jns    801eeb <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801edb:	83 ec 0c             	sub    $0xc,%esp
  801ede:	56                   	push   %esi
  801edf:	e8 0e 02 00 00       	call   8020f2 <nsipc_close>
		return r;
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	89 d8                	mov    %ebx,%eax
  801ee9:	eb 24                	jmp    801f0f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801eeb:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  801ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f00:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f03:	83 ec 0c             	sub    $0xc,%esp
  801f06:	50                   	push   %eax
  801f07:	e8 71 f3 ff ff       	call   80127d <fd2num>
  801f0c:	83 c4 10             	add    $0x10,%esp
}
  801f0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f12:	5b                   	pop    %ebx
  801f13:	5e                   	pop    %esi
  801f14:	5d                   	pop    %ebp
  801f15:	c3                   	ret    

00801f16 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1f:	e8 50 ff ff ff       	call   801e74 <fd2sockid>
		return r;
  801f24:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 1f                	js     801f49 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f2a:	83 ec 04             	sub    $0x4,%esp
  801f2d:	ff 75 10             	pushl  0x10(%ebp)
  801f30:	ff 75 0c             	pushl  0xc(%ebp)
  801f33:	50                   	push   %eax
  801f34:	e8 12 01 00 00       	call   80204b <nsipc_accept>
  801f39:	83 c4 10             	add    $0x10,%esp
		return r;
  801f3c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	78 07                	js     801f49 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801f42:	e8 5d ff ff ff       	call   801ea4 <alloc_sockfd>
  801f47:	89 c1                	mov    %eax,%ecx
}
  801f49:	89 c8                	mov    %ecx,%eax
  801f4b:	c9                   	leave  
  801f4c:	c3                   	ret    

00801f4d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f53:	8b 45 08             	mov    0x8(%ebp),%eax
  801f56:	e8 19 ff ff ff       	call   801e74 <fd2sockid>
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	78 12                	js     801f71 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801f5f:	83 ec 04             	sub    $0x4,%esp
  801f62:	ff 75 10             	pushl  0x10(%ebp)
  801f65:	ff 75 0c             	pushl  0xc(%ebp)
  801f68:	50                   	push   %eax
  801f69:	e8 2d 01 00 00       	call   80209b <nsipc_bind>
  801f6e:	83 c4 10             	add    $0x10,%esp
}
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    

00801f73 <shutdown>:

int
shutdown(int s, int how)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f79:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7c:	e8 f3 fe ff ff       	call   801e74 <fd2sockid>
  801f81:	85 c0                	test   %eax,%eax
  801f83:	78 0f                	js     801f94 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f85:	83 ec 08             	sub    $0x8,%esp
  801f88:	ff 75 0c             	pushl  0xc(%ebp)
  801f8b:	50                   	push   %eax
  801f8c:	e8 3f 01 00 00       	call   8020d0 <nsipc_shutdown>
  801f91:	83 c4 10             	add    $0x10,%esp
}
  801f94:	c9                   	leave  
  801f95:	c3                   	ret    

00801f96 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9f:	e8 d0 fe ff ff       	call   801e74 <fd2sockid>
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	78 12                	js     801fba <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801fa8:	83 ec 04             	sub    $0x4,%esp
  801fab:	ff 75 10             	pushl  0x10(%ebp)
  801fae:	ff 75 0c             	pushl  0xc(%ebp)
  801fb1:	50                   	push   %eax
  801fb2:	e8 55 01 00 00       	call   80210c <nsipc_connect>
  801fb7:	83 c4 10             	add    $0x10,%esp
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <listen>:

int
listen(int s, int backlog)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc5:	e8 aa fe ff ff       	call   801e74 <fd2sockid>
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	78 0f                	js     801fdd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801fce:	83 ec 08             	sub    $0x8,%esp
  801fd1:	ff 75 0c             	pushl  0xc(%ebp)
  801fd4:	50                   	push   %eax
  801fd5:	e8 67 01 00 00       	call   802141 <nsipc_listen>
  801fda:	83 c4 10             	add    $0x10,%esp
}
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    

00801fdf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801fe5:	ff 75 10             	pushl  0x10(%ebp)
  801fe8:	ff 75 0c             	pushl  0xc(%ebp)
  801feb:	ff 75 08             	pushl  0x8(%ebp)
  801fee:	e8 3a 02 00 00       	call   80222d <nsipc_socket>
  801ff3:	83 c4 10             	add    $0x10,%esp
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	78 05                	js     801fff <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ffa:	e8 a5 fe ff ff       	call   801ea4 <alloc_sockfd>
}
  801fff:	c9                   	leave  
  802000:	c3                   	ret    

00802001 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	53                   	push   %ebx
  802005:	83 ec 04             	sub    $0x4,%esp
  802008:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80200a:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  802011:	75 12                	jne    802025 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802013:	83 ec 0c             	sub    $0xc,%esp
  802016:	6a 02                	push   $0x2
  802018:	e8 10 07 00 00       	call   80272d <ipc_find_env>
  80201d:	a3 14 50 80 00       	mov    %eax,0x805014
  802022:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802025:	6a 07                	push   $0x7
  802027:	68 00 70 80 00       	push   $0x807000
  80202c:	53                   	push   %ebx
  80202d:	ff 35 14 50 80 00    	pushl  0x805014
  802033:	e8 a6 06 00 00       	call   8026de <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802038:	83 c4 0c             	add    $0xc,%esp
  80203b:	6a 00                	push   $0x0
  80203d:	6a 00                	push   $0x0
  80203f:	6a 00                	push   $0x0
  802041:	e8 22 06 00 00       	call   802668 <ipc_recv>
}
  802046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802049:	c9                   	leave  
  80204a:	c3                   	ret    

0080204b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	56                   	push   %esi
  80204f:	53                   	push   %ebx
  802050:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802053:	8b 45 08             	mov    0x8(%ebp),%eax
  802056:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80205b:	8b 06                	mov    (%esi),%eax
  80205d:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802062:	b8 01 00 00 00       	mov    $0x1,%eax
  802067:	e8 95 ff ff ff       	call   802001 <nsipc>
  80206c:	89 c3                	mov    %eax,%ebx
  80206e:	85 c0                	test   %eax,%eax
  802070:	78 20                	js     802092 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802072:	83 ec 04             	sub    $0x4,%esp
  802075:	ff 35 10 70 80 00    	pushl  0x807010
  80207b:	68 00 70 80 00       	push   $0x807000
  802080:	ff 75 0c             	pushl  0xc(%ebp)
  802083:	e8 74 ed ff ff       	call   800dfc <memmove>
		*addrlen = ret->ret_addrlen;
  802088:	a1 10 70 80 00       	mov    0x807010,%eax
  80208d:	89 06                	mov    %eax,(%esi)
  80208f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802092:	89 d8                	mov    %ebx,%eax
  802094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802097:	5b                   	pop    %ebx
  802098:	5e                   	pop    %esi
  802099:	5d                   	pop    %ebp
  80209a:	c3                   	ret    

0080209b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	53                   	push   %ebx
  80209f:	83 ec 08             	sub    $0x8,%esp
  8020a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8020a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8020ad:	53                   	push   %ebx
  8020ae:	ff 75 0c             	pushl  0xc(%ebp)
  8020b1:	68 04 70 80 00       	push   $0x807004
  8020b6:	e8 41 ed ff ff       	call   800dfc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8020bb:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8020c1:	b8 02 00 00 00       	mov    $0x2,%eax
  8020c6:	e8 36 ff ff ff       	call   802001 <nsipc>
}
  8020cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ce:	c9                   	leave  
  8020cf:	c3                   	ret    

008020d0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8020d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8020de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8020e6:	b8 03 00 00 00       	mov    $0x3,%eax
  8020eb:	e8 11 ff ff ff       	call   802001 <nsipc>
}
  8020f0:	c9                   	leave  
  8020f1:	c3                   	ret    

008020f2 <nsipc_close>:

int
nsipc_close(int s)
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8020f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fb:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802100:	b8 04 00 00 00       	mov    $0x4,%eax
  802105:	e8 f7 fe ff ff       	call   802001 <nsipc>
}
  80210a:	c9                   	leave  
  80210b:	c3                   	ret    

0080210c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	53                   	push   %ebx
  802110:	83 ec 08             	sub    $0x8,%esp
  802113:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802116:	8b 45 08             	mov    0x8(%ebp),%eax
  802119:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80211e:	53                   	push   %ebx
  80211f:	ff 75 0c             	pushl  0xc(%ebp)
  802122:	68 04 70 80 00       	push   $0x807004
  802127:	e8 d0 ec ff ff       	call   800dfc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80212c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802132:	b8 05 00 00 00       	mov    $0x5,%eax
  802137:	e8 c5 fe ff ff       	call   802001 <nsipc>
}
  80213c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80213f:	c9                   	leave  
  802140:	c3                   	ret    

00802141 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802141:	55                   	push   %ebp
  802142:	89 e5                	mov    %esp,%ebp
  802144:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802147:	8b 45 08             	mov    0x8(%ebp),%eax
  80214a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80214f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802152:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802157:	b8 06 00 00 00       	mov    $0x6,%eax
  80215c:	e8 a0 fe ff ff       	call   802001 <nsipc>
}
  802161:	c9                   	leave  
  802162:	c3                   	ret    

00802163 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	56                   	push   %esi
  802167:	53                   	push   %ebx
  802168:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80216b:	8b 45 08             	mov    0x8(%ebp),%eax
  80216e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802173:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802179:	8b 45 14             	mov    0x14(%ebp),%eax
  80217c:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802181:	b8 07 00 00 00       	mov    $0x7,%eax
  802186:	e8 76 fe ff ff       	call   802001 <nsipc>
  80218b:	89 c3                	mov    %eax,%ebx
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 35                	js     8021c6 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802191:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802196:	7f 04                	jg     80219c <nsipc_recv+0x39>
  802198:	39 c6                	cmp    %eax,%esi
  80219a:	7d 16                	jge    8021b2 <nsipc_recv+0x4f>
  80219c:	68 3a 30 80 00       	push   $0x80303a
  8021a1:	68 e3 2f 80 00       	push   $0x802fe3
  8021a6:	6a 62                	push   $0x62
  8021a8:	68 4f 30 80 00       	push   $0x80304f
  8021ad:	e8 3a e4 ff ff       	call   8005ec <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8021b2:	83 ec 04             	sub    $0x4,%esp
  8021b5:	50                   	push   %eax
  8021b6:	68 00 70 80 00       	push   $0x807000
  8021bb:	ff 75 0c             	pushl  0xc(%ebp)
  8021be:	e8 39 ec ff ff       	call   800dfc <memmove>
  8021c3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8021c6:	89 d8                	mov    %ebx,%eax
  8021c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021cb:	5b                   	pop    %ebx
  8021cc:	5e                   	pop    %esi
  8021cd:	5d                   	pop    %ebp
  8021ce:	c3                   	ret    

008021cf <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	53                   	push   %ebx
  8021d3:	83 ec 04             	sub    $0x4,%esp
  8021d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021dc:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8021e1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021e7:	7e 16                	jle    8021ff <nsipc_send+0x30>
  8021e9:	68 5b 30 80 00       	push   $0x80305b
  8021ee:	68 e3 2f 80 00       	push   $0x802fe3
  8021f3:	6a 6d                	push   $0x6d
  8021f5:	68 4f 30 80 00       	push   $0x80304f
  8021fa:	e8 ed e3 ff ff       	call   8005ec <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021ff:	83 ec 04             	sub    $0x4,%esp
  802202:	53                   	push   %ebx
  802203:	ff 75 0c             	pushl  0xc(%ebp)
  802206:	68 0c 70 80 00       	push   $0x80700c
  80220b:	e8 ec eb ff ff       	call   800dfc <memmove>
	nsipcbuf.send.req_size = size;
  802210:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802216:	8b 45 14             	mov    0x14(%ebp),%eax
  802219:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80221e:	b8 08 00 00 00       	mov    $0x8,%eax
  802223:	e8 d9 fd ff ff       	call   802001 <nsipc>
}
  802228:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80222b:	c9                   	leave  
  80222c:	c3                   	ret    

0080222d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80222d:	55                   	push   %ebp
  80222e:	89 e5                	mov    %esp,%ebp
  802230:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802233:	8b 45 08             	mov    0x8(%ebp),%eax
  802236:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80223b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80223e:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802243:	8b 45 10             	mov    0x10(%ebp),%eax
  802246:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80224b:	b8 09 00 00 00       	mov    $0x9,%eax
  802250:	e8 ac fd ff ff       	call   802001 <nsipc>
}
  802255:	c9                   	leave  
  802256:	c3                   	ret    

00802257 <free>:
	return v;
}

void
free(void *v)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	53                   	push   %ebx
  80225b:	83 ec 04             	sub    $0x4,%esp
  80225e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  802261:	85 db                	test   %ebx,%ebx
  802263:	0f 84 97 00 00 00    	je     802300 <free+0xa9>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  802269:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  80226f:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  802274:	76 16                	jbe    80228c <free+0x35>
  802276:	68 68 30 80 00       	push   $0x803068
  80227b:	68 e3 2f 80 00       	push   $0x802fe3
  802280:	6a 7a                	push   $0x7a
  802282:	68 98 30 80 00       	push   $0x803098
  802287:	e8 60 e3 ff ff       	call   8005ec <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  80228c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  802292:	eb 3a                	jmp    8022ce <free+0x77>
		sys_page_unmap(0, c);
  802294:	83 ec 08             	sub    $0x8,%esp
  802297:	53                   	push   %ebx
  802298:	6a 00                	push   $0x0
  80229a:	e8 53 ee ff ff       	call   8010f2 <sys_page_unmap>
		c += PGSIZE;
  80229f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  8022a5:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  8022ab:	83 c4 10             	add    $0x10,%esp
  8022ae:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  8022b3:	76 19                	jbe    8022ce <free+0x77>
  8022b5:	68 a5 30 80 00       	push   $0x8030a5
  8022ba:	68 e3 2f 80 00       	push   $0x802fe3
  8022bf:	68 81 00 00 00       	push   $0x81
  8022c4:	68 98 30 80 00       	push   $0x803098
  8022c9:	e8 1e e3 ff ff       	call   8005ec <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  8022ce:	89 d8                	mov    %ebx,%eax
  8022d0:	c1 e8 0c             	shr    $0xc,%eax
  8022d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8022da:	f6 c4 02             	test   $0x2,%ah
  8022dd:	75 b5                	jne    802294 <free+0x3d>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  8022df:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  8022e5:	83 e8 01             	sub    $0x1,%eax
  8022e8:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	75 0e                	jne    802300 <free+0xa9>
		sys_page_unmap(0, c);
  8022f2:	83 ec 08             	sub    $0x8,%esp
  8022f5:	53                   	push   %ebx
  8022f6:	6a 00                	push   $0x0
  8022f8:	e8 f5 ed ff ff       	call   8010f2 <sys_page_unmap>
  8022fd:	83 c4 10             	add    $0x10,%esp
}
  802300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802303:	c9                   	leave  
  802304:	c3                   	ret    

00802305 <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  802305:	55                   	push   %ebp
  802306:	89 e5                	mov    %esp,%ebp
  802308:	57                   	push   %edi
  802309:	56                   	push   %esi
  80230a:	53                   	push   %ebx
  80230b:	83 ec 1c             	sub    $0x1c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  80230e:	a1 18 50 80 00       	mov    0x805018,%eax
  802313:	85 c0                	test   %eax,%eax
  802315:	75 22                	jne    802339 <malloc+0x34>
		mptr = mbegin;
  802317:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  80231e:	00 00 08 

	n = ROUNDUP(n, 4);
  802321:	8b 45 08             	mov    0x8(%ebp),%eax
  802324:	83 c0 03             	add    $0x3,%eax
  802327:	83 e0 fc             	and    $0xfffffffc,%eax
  80232a:	89 45 dc             	mov    %eax,-0x24(%ebp)

	if (n >= MAXMALLOC)
  80232d:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  802332:	76 74                	jbe    8023a8 <malloc+0xa3>
  802334:	e9 7a 01 00 00       	jmp    8024b3 <malloc+0x1ae>
	void *v;

	if (mptr == 0)
		mptr = mbegin;

	n = ROUNDUP(n, 4);
  802339:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80233c:	8d 53 03             	lea    0x3(%ebx),%edx
  80233f:	83 e2 fc             	and    $0xfffffffc,%edx
  802342:	89 55 dc             	mov    %edx,-0x24(%ebp)

	if (n >= MAXMALLOC)
  802345:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  80234b:	0f 87 69 01 00 00    	ja     8024ba <malloc+0x1b5>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  802351:	a9 ff 0f 00 00       	test   $0xfff,%eax
  802356:	74 50                	je     8023a8 <malloc+0xa3>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  802358:	89 c1                	mov    %eax,%ecx
  80235a:	c1 e9 0c             	shr    $0xc,%ecx
  80235d:	8d 54 10 03          	lea    0x3(%eax,%edx,1),%edx
  802361:	c1 ea 0c             	shr    $0xc,%edx
  802364:	39 d1                	cmp    %edx,%ecx
  802366:	75 20                	jne    802388 <malloc+0x83>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  802368:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80236e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  802374:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			v = mptr;
			mptr += n;
  802378:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80237b:	01 c2                	add    %eax,%edx
  80237d:	89 15 18 50 80 00    	mov    %edx,0x805018
			return v;
  802383:	e9 55 01 00 00       	jmp    8024dd <malloc+0x1d8>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  802388:	83 ec 0c             	sub    $0xc,%esp
  80238b:	50                   	push   %eax
  80238c:	e8 c6 fe ff ff       	call   802257 <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  802391:	a1 18 50 80 00       	mov    0x805018,%eax
  802396:	05 00 10 00 00       	add    $0x1000,%eax
  80239b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8023a0:	a3 18 50 80 00       	mov    %eax,0x805018
  8023a5:	83 c4 10             	add    $0x10,%esp
  8023a8:	8b 35 18 50 80 00    	mov    0x805018,%esi
	return 1;
}

void*
malloc(size_t n)
{
  8023ae:	c7 45 d8 02 00 00 00 	movl   $0x2,-0x28(%ebp)
  8023b5:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  8023b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8023bc:	8d 78 04             	lea    0x4(%eax),%edi
  8023bf:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8023c2:	89 fb                	mov    %edi,%ebx
  8023c4:	8d 0c 37             	lea    (%edi,%esi,1),%ecx
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8023c7:	89 f0                	mov    %esi,%eax
  8023c9:	eb 36                	jmp    802401 <malloc+0xfc>
		if (va >= (uintptr_t) mend
  8023cb:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  8023d0:	0f 87 eb 00 00 00    	ja     8024c1 <malloc+0x1bc>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  8023d6:	89 c2                	mov    %eax,%edx
  8023d8:	c1 ea 16             	shr    $0x16,%edx
  8023db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023e2:	f6 c2 01             	test   $0x1,%dl
  8023e5:	74 15                	je     8023fc <malloc+0xf7>
  8023e7:	89 c2                	mov    %eax,%edx
  8023e9:	c1 ea 0c             	shr    $0xc,%edx
  8023ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8023f3:	f6 c2 01             	test   $0x1,%dl
  8023f6:	0f 85 c5 00 00 00    	jne    8024c1 <malloc+0x1bc>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8023fc:	05 00 10 00 00       	add    $0x1000,%eax
  802401:	39 c8                	cmp    %ecx,%eax
  802403:	72 c6                	jb     8023cb <malloc+0xc6>
  802405:	eb 79                	jmp    802480 <malloc+0x17b>
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
  802407:	be 00 00 00 08       	mov    $0x8000000,%esi
  80240c:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
			if (++nwrap == 2)
  802410:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  802414:	75 a9                	jne    8023bf <malloc+0xba>
  802416:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  80241d:	00 00 08 
				return 0;	/* out of address space */
  802420:	b8 00 00 00 00       	mov    $0x0,%eax
  802425:	e9 b3 00 00 00       	jmp    8024dd <malloc+0x1d8>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  80242a:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
  802430:	39 df                	cmp    %ebx,%edi
  802432:	19 c0                	sbb    %eax,%eax
  802434:	25 00 02 00 00       	and    $0x200,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  802439:	83 ec 04             	sub    $0x4,%esp
  80243c:	83 c8 07             	or     $0x7,%eax
  80243f:	50                   	push   %eax
  802440:	03 15 18 50 80 00    	add    0x805018,%edx
  802446:	52                   	push   %edx
  802447:	6a 00                	push   $0x0
  802449:	e8 1f ec ff ff       	call   80106d <sys_page_alloc>
  80244e:	83 c4 10             	add    $0x10,%esp
  802451:	85 c0                	test   %eax,%eax
  802453:	78 20                	js     802475 <malloc+0x170>
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  802455:	89 fe                	mov    %edi,%esi
  802457:	eb 3a                	jmp    802493 <malloc+0x18e>
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
				sys_page_unmap(0, mptr + i);
  802459:	83 ec 08             	sub    $0x8,%esp
  80245c:	89 f0                	mov    %esi,%eax
  80245e:	03 05 18 50 80 00    	add    0x805018,%eax
  802464:	50                   	push   %eax
  802465:	6a 00                	push   $0x0
  802467:	e8 86 ec ff ff       	call   8010f2 <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  80246c:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	85 f6                	test   %esi,%esi
  802477:	79 e0                	jns    802459 <malloc+0x154>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
  802479:	b8 00 00 00 00       	mov    $0x0,%eax
  80247e:	eb 5d                	jmp    8024dd <malloc+0x1d8>
  802480:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  802484:	74 08                	je     80248e <malloc+0x189>
  802486:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802489:	a3 18 50 80 00       	mov    %eax,0x805018

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  80248e:	be 00 00 00 00       	mov    $0x0,%esi
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  802493:	89 f2                	mov    %esi,%edx
  802495:	39 f3                	cmp    %esi,%ebx
  802497:	77 91                	ja     80242a <malloc+0x125>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  802499:	a1 18 50 80 00       	mov    0x805018,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  80249e:	c7 44 30 fc 02 00 00 	movl   $0x2,-0x4(%eax,%esi,1)
  8024a5:	00 
	v = mptr;
	mptr += n;
  8024a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8024a9:	01 c2                	add    %eax,%edx
  8024ab:	89 15 18 50 80 00    	mov    %edx,0x805018
	return v;
  8024b1:	eb 2a                	jmp    8024dd <malloc+0x1d8>
		mptr = mbegin;

	n = ROUNDUP(n, 4);

	if (n >= MAXMALLOC)
		return 0;
  8024b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b8:	eb 23                	jmp    8024dd <malloc+0x1d8>
  8024ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8024bf:	eb 1c                	jmp    8024dd <malloc+0x1d8>
  8024c1:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
  8024c7:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
  8024cb:	89 c6                	mov    %eax,%esi
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  8024cd:	3d 00 00 00 10       	cmp    $0x10000000,%eax
  8024d2:	0f 85 e7 fe ff ff    	jne    8023bf <malloc+0xba>
  8024d8:	e9 2a ff ff ff       	jmp    802407 <malloc+0x102>
	ref = (uint32_t*) (mptr + i - 4);
	*ref = 2;	/* reference for mptr, reference for returned block */
	v = mptr;
	mptr += n;
	return v;
}
  8024dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e0:	5b                   	pop    %ebx
  8024e1:	5e                   	pop    %esi
  8024e2:	5f                   	pop    %edi
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    

008024e5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024e5:	55                   	push   %ebp
  8024e6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8024ed:	5d                   	pop    %ebp
  8024ee:	c3                   	ret    

008024ef <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024ef:	55                   	push   %ebp
  8024f0:	89 e5                	mov    %esp,%ebp
  8024f2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8024f5:	68 bd 30 80 00       	push   $0x8030bd
  8024fa:	ff 75 0c             	pushl  0xc(%ebp)
  8024fd:	e8 68 e7 ff ff       	call   800c6a <strcpy>
	return 0;
}
  802502:	b8 00 00 00 00       	mov    $0x0,%eax
  802507:	c9                   	leave  
  802508:	c3                   	ret    

00802509 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802509:	55                   	push   %ebp
  80250a:	89 e5                	mov    %esp,%ebp
  80250c:	57                   	push   %edi
  80250d:	56                   	push   %esi
  80250e:	53                   	push   %ebx
  80250f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802515:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80251a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802520:	eb 2d                	jmp    80254f <devcons_write+0x46>
		m = n - tot;
  802522:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802525:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802527:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80252a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80252f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802532:	83 ec 04             	sub    $0x4,%esp
  802535:	53                   	push   %ebx
  802536:	03 45 0c             	add    0xc(%ebp),%eax
  802539:	50                   	push   %eax
  80253a:	57                   	push   %edi
  80253b:	e8 bc e8 ff ff       	call   800dfc <memmove>
		sys_cputs(buf, m);
  802540:	83 c4 08             	add    $0x8,%esp
  802543:	53                   	push   %ebx
  802544:	57                   	push   %edi
  802545:	e8 67 ea ff ff       	call   800fb1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80254a:	01 de                	add    %ebx,%esi
  80254c:	83 c4 10             	add    $0x10,%esp
  80254f:	89 f0                	mov    %esi,%eax
  802551:	3b 75 10             	cmp    0x10(%ebp),%esi
  802554:	72 cc                	jb     802522 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802556:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802559:	5b                   	pop    %ebx
  80255a:	5e                   	pop    %esi
  80255b:	5f                   	pop    %edi
  80255c:	5d                   	pop    %ebp
  80255d:	c3                   	ret    

0080255e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80255e:	55                   	push   %ebp
  80255f:	89 e5                	mov    %esp,%ebp
  802561:	83 ec 08             	sub    $0x8,%esp
  802564:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802569:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80256d:	74 2a                	je     802599 <devcons_read+0x3b>
  80256f:	eb 05                	jmp    802576 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802571:	e8 d8 ea ff ff       	call   80104e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802576:	e8 54 ea ff ff       	call   800fcf <sys_cgetc>
  80257b:	85 c0                	test   %eax,%eax
  80257d:	74 f2                	je     802571 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80257f:	85 c0                	test   %eax,%eax
  802581:	78 16                	js     802599 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802583:	83 f8 04             	cmp    $0x4,%eax
  802586:	74 0c                	je     802594 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802588:	8b 55 0c             	mov    0xc(%ebp),%edx
  80258b:	88 02                	mov    %al,(%edx)
	return 1;
  80258d:	b8 01 00 00 00       	mov    $0x1,%eax
  802592:	eb 05                	jmp    802599 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802594:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802599:	c9                   	leave  
  80259a:	c3                   	ret    

0080259b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80259b:	55                   	push   %ebp
  80259c:	89 e5                	mov    %esp,%ebp
  80259e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8025a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025a7:	6a 01                	push   $0x1
  8025a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025ac:	50                   	push   %eax
  8025ad:	e8 ff e9 ff ff       	call   800fb1 <sys_cputs>
}
  8025b2:	83 c4 10             	add    $0x10,%esp
  8025b5:	c9                   	leave  
  8025b6:	c3                   	ret    

008025b7 <getchar>:

int
getchar(void)
{
  8025b7:	55                   	push   %ebp
  8025b8:	89 e5                	mov    %esp,%ebp
  8025ba:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025bd:	6a 01                	push   $0x1
  8025bf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025c2:	50                   	push   %eax
  8025c3:	6a 00                	push   $0x0
  8025c5:	e8 8f ef ff ff       	call   801559 <read>
	if (r < 0)
  8025ca:	83 c4 10             	add    $0x10,%esp
  8025cd:	85 c0                	test   %eax,%eax
  8025cf:	78 0f                	js     8025e0 <getchar+0x29>
		return r;
	if (r < 1)
  8025d1:	85 c0                	test   %eax,%eax
  8025d3:	7e 06                	jle    8025db <getchar+0x24>
		return -E_EOF;
	return c;
  8025d5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025d9:	eb 05                	jmp    8025e0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025db:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025e0:	c9                   	leave  
  8025e1:	c3                   	ret    

008025e2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025e2:	55                   	push   %ebp
  8025e3:	89 e5                	mov    %esp,%ebp
  8025e5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025eb:	50                   	push   %eax
  8025ec:	ff 75 08             	pushl  0x8(%ebp)
  8025ef:	e8 ff ec ff ff       	call   8012f3 <fd_lookup>
  8025f4:	83 c4 10             	add    $0x10,%esp
  8025f7:	85 c0                	test   %eax,%eax
  8025f9:	78 11                	js     80260c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025fe:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802604:	39 10                	cmp    %edx,(%eax)
  802606:	0f 94 c0             	sete   %al
  802609:	0f b6 c0             	movzbl %al,%eax
}
  80260c:	c9                   	leave  
  80260d:	c3                   	ret    

0080260e <opencons>:

int
opencons(void)
{
  80260e:	55                   	push   %ebp
  80260f:	89 e5                	mov    %esp,%ebp
  802611:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802617:	50                   	push   %eax
  802618:	e8 87 ec ff ff       	call   8012a4 <fd_alloc>
  80261d:	83 c4 10             	add    $0x10,%esp
		return r;
  802620:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802622:	85 c0                	test   %eax,%eax
  802624:	78 3e                	js     802664 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802626:	83 ec 04             	sub    $0x4,%esp
  802629:	68 07 04 00 00       	push   $0x407
  80262e:	ff 75 f4             	pushl  -0xc(%ebp)
  802631:	6a 00                	push   $0x0
  802633:	e8 35 ea ff ff       	call   80106d <sys_page_alloc>
  802638:	83 c4 10             	add    $0x10,%esp
		return r;
  80263b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80263d:	85 c0                	test   %eax,%eax
  80263f:	78 23                	js     802664 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802641:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802647:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80264a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80264c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80264f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802656:	83 ec 0c             	sub    $0xc,%esp
  802659:	50                   	push   %eax
  80265a:	e8 1e ec ff ff       	call   80127d <fd2num>
  80265f:	89 c2                	mov    %eax,%edx
  802661:	83 c4 10             	add    $0x10,%esp
}
  802664:	89 d0                	mov    %edx,%eax
  802666:	c9                   	leave  
  802667:	c3                   	ret    

00802668 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802668:	55                   	push   %ebp
  802669:	89 e5                	mov    %esp,%ebp
  80266b:	56                   	push   %esi
  80266c:	53                   	push   %ebx
  80266d:	8b 75 08             	mov    0x8(%ebp),%esi
  802670:	8b 45 0c             	mov    0xc(%ebp),%eax
  802673:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  802676:	85 c0                	test   %eax,%eax
  802678:	74 0e                	je     802688 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  80267a:	83 ec 0c             	sub    $0xc,%esp
  80267d:	50                   	push   %eax
  80267e:	e8 9a eb ff ff       	call   80121d <sys_ipc_recv>
  802683:	83 c4 10             	add    $0x10,%esp
  802686:	eb 10                	jmp    802698 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802688:	83 ec 0c             	sub    $0xc,%esp
  80268b:	68 00 00 c0 ee       	push   $0xeec00000
  802690:	e8 88 eb ff ff       	call   80121d <sys_ipc_recv>
  802695:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  802698:	85 c0                	test   %eax,%eax
  80269a:	79 17                	jns    8026b3 <ipc_recv+0x4b>
		if(*from_env_store)
  80269c:	83 3e 00             	cmpl   $0x0,(%esi)
  80269f:	74 06                	je     8026a7 <ipc_recv+0x3f>
			*from_env_store = 0;
  8026a1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8026a7:	85 db                	test   %ebx,%ebx
  8026a9:	74 2c                	je     8026d7 <ipc_recv+0x6f>
			*perm_store = 0;
  8026ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026b1:	eb 24                	jmp    8026d7 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  8026b3:	85 f6                	test   %esi,%esi
  8026b5:	74 0a                	je     8026c1 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  8026b7:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8026bc:	8b 40 74             	mov    0x74(%eax),%eax
  8026bf:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8026c1:	85 db                	test   %ebx,%ebx
  8026c3:	74 0a                	je     8026cf <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8026c5:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8026ca:	8b 40 78             	mov    0x78(%eax),%eax
  8026cd:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8026cf:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8026d4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8026d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026da:	5b                   	pop    %ebx
  8026db:	5e                   	pop    %esi
  8026dc:	5d                   	pop    %ebp
  8026dd:	c3                   	ret    

008026de <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026de:	55                   	push   %ebp
  8026df:	89 e5                	mov    %esp,%ebp
  8026e1:	57                   	push   %edi
  8026e2:	56                   	push   %esi
  8026e3:	53                   	push   %ebx
  8026e4:	83 ec 0c             	sub    $0xc,%esp
  8026e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026ea:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8026f0:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  8026f2:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  8026f7:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  8026fa:	e8 4f e9 ff ff       	call   80104e <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  8026ff:	ff 75 14             	pushl  0x14(%ebp)
  802702:	53                   	push   %ebx
  802703:	56                   	push   %esi
  802704:	57                   	push   %edi
  802705:	e8 f0 ea ff ff       	call   8011fa <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  80270a:	89 c2                	mov    %eax,%edx
  80270c:	f7 d2                	not    %edx
  80270e:	c1 ea 1f             	shr    $0x1f,%edx
  802711:	83 c4 10             	add    $0x10,%esp
  802714:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802717:	0f 94 c1             	sete   %cl
  80271a:	09 ca                	or     %ecx,%edx
  80271c:	85 c0                	test   %eax,%eax
  80271e:	0f 94 c0             	sete   %al
  802721:	38 c2                	cmp    %al,%dl
  802723:	77 d5                	ja     8026fa <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802725:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802728:	5b                   	pop    %ebx
  802729:	5e                   	pop    %esi
  80272a:	5f                   	pop    %edi
  80272b:	5d                   	pop    %ebp
  80272c:	c3                   	ret    

0080272d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80272d:	55                   	push   %ebp
  80272e:	89 e5                	mov    %esp,%ebp
  802730:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802733:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802738:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80273b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802741:	8b 52 50             	mov    0x50(%edx),%edx
  802744:	39 ca                	cmp    %ecx,%edx
  802746:	75 0d                	jne    802755 <ipc_find_env+0x28>
			return envs[i].env_id;
  802748:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80274b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802750:	8b 40 48             	mov    0x48(%eax),%eax
  802753:	eb 0f                	jmp    802764 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802755:	83 c0 01             	add    $0x1,%eax
  802758:	3d 00 04 00 00       	cmp    $0x400,%eax
  80275d:	75 d9                	jne    802738 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80275f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802764:	5d                   	pop    %ebp
  802765:	c3                   	ret    

00802766 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802766:	55                   	push   %ebp
  802767:	89 e5                	mov    %esp,%ebp
  802769:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80276c:	89 d0                	mov    %edx,%eax
  80276e:	c1 e8 16             	shr    $0x16,%eax
  802771:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802778:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80277d:	f6 c1 01             	test   $0x1,%cl
  802780:	74 1d                	je     80279f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802782:	c1 ea 0c             	shr    $0xc,%edx
  802785:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80278c:	f6 c2 01             	test   $0x1,%dl
  80278f:	74 0e                	je     80279f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802791:	c1 ea 0c             	shr    $0xc,%edx
  802794:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80279b:	ef 
  80279c:	0f b7 c0             	movzwl %ax,%eax
}
  80279f:	5d                   	pop    %ebp
  8027a0:	c3                   	ret    
  8027a1:	66 90                	xchg   %ax,%ax
  8027a3:	66 90                	xchg   %ax,%ax
  8027a5:	66 90                	xchg   %ax,%ax
  8027a7:	66 90                	xchg   %ax,%ax
  8027a9:	66 90                	xchg   %ax,%ax
  8027ab:	66 90                	xchg   %ax,%ax
  8027ad:	66 90                	xchg   %ax,%ax
  8027af:	90                   	nop

008027b0 <__udivdi3>:
  8027b0:	55                   	push   %ebp
  8027b1:	57                   	push   %edi
  8027b2:	56                   	push   %esi
  8027b3:	53                   	push   %ebx
  8027b4:	83 ec 1c             	sub    $0x1c,%esp
  8027b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027c7:	85 f6                	test   %esi,%esi
  8027c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027cd:	89 ca                	mov    %ecx,%edx
  8027cf:	89 f8                	mov    %edi,%eax
  8027d1:	75 3d                	jne    802810 <__udivdi3+0x60>
  8027d3:	39 cf                	cmp    %ecx,%edi
  8027d5:	0f 87 c5 00 00 00    	ja     8028a0 <__udivdi3+0xf0>
  8027db:	85 ff                	test   %edi,%edi
  8027dd:	89 fd                	mov    %edi,%ebp
  8027df:	75 0b                	jne    8027ec <__udivdi3+0x3c>
  8027e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027e6:	31 d2                	xor    %edx,%edx
  8027e8:	f7 f7                	div    %edi
  8027ea:	89 c5                	mov    %eax,%ebp
  8027ec:	89 c8                	mov    %ecx,%eax
  8027ee:	31 d2                	xor    %edx,%edx
  8027f0:	f7 f5                	div    %ebp
  8027f2:	89 c1                	mov    %eax,%ecx
  8027f4:	89 d8                	mov    %ebx,%eax
  8027f6:	89 cf                	mov    %ecx,%edi
  8027f8:	f7 f5                	div    %ebp
  8027fa:	89 c3                	mov    %eax,%ebx
  8027fc:	89 d8                	mov    %ebx,%eax
  8027fe:	89 fa                	mov    %edi,%edx
  802800:	83 c4 1c             	add    $0x1c,%esp
  802803:	5b                   	pop    %ebx
  802804:	5e                   	pop    %esi
  802805:	5f                   	pop    %edi
  802806:	5d                   	pop    %ebp
  802807:	c3                   	ret    
  802808:	90                   	nop
  802809:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802810:	39 ce                	cmp    %ecx,%esi
  802812:	77 74                	ja     802888 <__udivdi3+0xd8>
  802814:	0f bd fe             	bsr    %esi,%edi
  802817:	83 f7 1f             	xor    $0x1f,%edi
  80281a:	0f 84 98 00 00 00    	je     8028b8 <__udivdi3+0x108>
  802820:	bb 20 00 00 00       	mov    $0x20,%ebx
  802825:	89 f9                	mov    %edi,%ecx
  802827:	89 c5                	mov    %eax,%ebp
  802829:	29 fb                	sub    %edi,%ebx
  80282b:	d3 e6                	shl    %cl,%esi
  80282d:	89 d9                	mov    %ebx,%ecx
  80282f:	d3 ed                	shr    %cl,%ebp
  802831:	89 f9                	mov    %edi,%ecx
  802833:	d3 e0                	shl    %cl,%eax
  802835:	09 ee                	or     %ebp,%esi
  802837:	89 d9                	mov    %ebx,%ecx
  802839:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80283d:	89 d5                	mov    %edx,%ebp
  80283f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802843:	d3 ed                	shr    %cl,%ebp
  802845:	89 f9                	mov    %edi,%ecx
  802847:	d3 e2                	shl    %cl,%edx
  802849:	89 d9                	mov    %ebx,%ecx
  80284b:	d3 e8                	shr    %cl,%eax
  80284d:	09 c2                	or     %eax,%edx
  80284f:	89 d0                	mov    %edx,%eax
  802851:	89 ea                	mov    %ebp,%edx
  802853:	f7 f6                	div    %esi
  802855:	89 d5                	mov    %edx,%ebp
  802857:	89 c3                	mov    %eax,%ebx
  802859:	f7 64 24 0c          	mull   0xc(%esp)
  80285d:	39 d5                	cmp    %edx,%ebp
  80285f:	72 10                	jb     802871 <__udivdi3+0xc1>
  802861:	8b 74 24 08          	mov    0x8(%esp),%esi
  802865:	89 f9                	mov    %edi,%ecx
  802867:	d3 e6                	shl    %cl,%esi
  802869:	39 c6                	cmp    %eax,%esi
  80286b:	73 07                	jae    802874 <__udivdi3+0xc4>
  80286d:	39 d5                	cmp    %edx,%ebp
  80286f:	75 03                	jne    802874 <__udivdi3+0xc4>
  802871:	83 eb 01             	sub    $0x1,%ebx
  802874:	31 ff                	xor    %edi,%edi
  802876:	89 d8                	mov    %ebx,%eax
  802878:	89 fa                	mov    %edi,%edx
  80287a:	83 c4 1c             	add    $0x1c,%esp
  80287d:	5b                   	pop    %ebx
  80287e:	5e                   	pop    %esi
  80287f:	5f                   	pop    %edi
  802880:	5d                   	pop    %ebp
  802881:	c3                   	ret    
  802882:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802888:	31 ff                	xor    %edi,%edi
  80288a:	31 db                	xor    %ebx,%ebx
  80288c:	89 d8                	mov    %ebx,%eax
  80288e:	89 fa                	mov    %edi,%edx
  802890:	83 c4 1c             	add    $0x1c,%esp
  802893:	5b                   	pop    %ebx
  802894:	5e                   	pop    %esi
  802895:	5f                   	pop    %edi
  802896:	5d                   	pop    %ebp
  802897:	c3                   	ret    
  802898:	90                   	nop
  802899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028a0:	89 d8                	mov    %ebx,%eax
  8028a2:	f7 f7                	div    %edi
  8028a4:	31 ff                	xor    %edi,%edi
  8028a6:	89 c3                	mov    %eax,%ebx
  8028a8:	89 d8                	mov    %ebx,%eax
  8028aa:	89 fa                	mov    %edi,%edx
  8028ac:	83 c4 1c             	add    $0x1c,%esp
  8028af:	5b                   	pop    %ebx
  8028b0:	5e                   	pop    %esi
  8028b1:	5f                   	pop    %edi
  8028b2:	5d                   	pop    %ebp
  8028b3:	c3                   	ret    
  8028b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028b8:	39 ce                	cmp    %ecx,%esi
  8028ba:	72 0c                	jb     8028c8 <__udivdi3+0x118>
  8028bc:	31 db                	xor    %ebx,%ebx
  8028be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028c2:	0f 87 34 ff ff ff    	ja     8027fc <__udivdi3+0x4c>
  8028c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028cd:	e9 2a ff ff ff       	jmp    8027fc <__udivdi3+0x4c>
  8028d2:	66 90                	xchg   %ax,%ax
  8028d4:	66 90                	xchg   %ax,%ax
  8028d6:	66 90                	xchg   %ax,%ax
  8028d8:	66 90                	xchg   %ax,%ax
  8028da:	66 90                	xchg   %ax,%ax
  8028dc:	66 90                	xchg   %ax,%ax
  8028de:	66 90                	xchg   %ax,%ax

008028e0 <__umoddi3>:
  8028e0:	55                   	push   %ebp
  8028e1:	57                   	push   %edi
  8028e2:	56                   	push   %esi
  8028e3:	53                   	push   %ebx
  8028e4:	83 ec 1c             	sub    $0x1c,%esp
  8028e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028f7:	85 d2                	test   %edx,%edx
  8028f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802901:	89 f3                	mov    %esi,%ebx
  802903:	89 3c 24             	mov    %edi,(%esp)
  802906:	89 74 24 04          	mov    %esi,0x4(%esp)
  80290a:	75 1c                	jne    802928 <__umoddi3+0x48>
  80290c:	39 f7                	cmp    %esi,%edi
  80290e:	76 50                	jbe    802960 <__umoddi3+0x80>
  802910:	89 c8                	mov    %ecx,%eax
  802912:	89 f2                	mov    %esi,%edx
  802914:	f7 f7                	div    %edi
  802916:	89 d0                	mov    %edx,%eax
  802918:	31 d2                	xor    %edx,%edx
  80291a:	83 c4 1c             	add    $0x1c,%esp
  80291d:	5b                   	pop    %ebx
  80291e:	5e                   	pop    %esi
  80291f:	5f                   	pop    %edi
  802920:	5d                   	pop    %ebp
  802921:	c3                   	ret    
  802922:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802928:	39 f2                	cmp    %esi,%edx
  80292a:	89 d0                	mov    %edx,%eax
  80292c:	77 52                	ja     802980 <__umoddi3+0xa0>
  80292e:	0f bd ea             	bsr    %edx,%ebp
  802931:	83 f5 1f             	xor    $0x1f,%ebp
  802934:	75 5a                	jne    802990 <__umoddi3+0xb0>
  802936:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80293a:	0f 82 e0 00 00 00    	jb     802a20 <__umoddi3+0x140>
  802940:	39 0c 24             	cmp    %ecx,(%esp)
  802943:	0f 86 d7 00 00 00    	jbe    802a20 <__umoddi3+0x140>
  802949:	8b 44 24 08          	mov    0x8(%esp),%eax
  80294d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802951:	83 c4 1c             	add    $0x1c,%esp
  802954:	5b                   	pop    %ebx
  802955:	5e                   	pop    %esi
  802956:	5f                   	pop    %edi
  802957:	5d                   	pop    %ebp
  802958:	c3                   	ret    
  802959:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802960:	85 ff                	test   %edi,%edi
  802962:	89 fd                	mov    %edi,%ebp
  802964:	75 0b                	jne    802971 <__umoddi3+0x91>
  802966:	b8 01 00 00 00       	mov    $0x1,%eax
  80296b:	31 d2                	xor    %edx,%edx
  80296d:	f7 f7                	div    %edi
  80296f:	89 c5                	mov    %eax,%ebp
  802971:	89 f0                	mov    %esi,%eax
  802973:	31 d2                	xor    %edx,%edx
  802975:	f7 f5                	div    %ebp
  802977:	89 c8                	mov    %ecx,%eax
  802979:	f7 f5                	div    %ebp
  80297b:	89 d0                	mov    %edx,%eax
  80297d:	eb 99                	jmp    802918 <__umoddi3+0x38>
  80297f:	90                   	nop
  802980:	89 c8                	mov    %ecx,%eax
  802982:	89 f2                	mov    %esi,%edx
  802984:	83 c4 1c             	add    $0x1c,%esp
  802987:	5b                   	pop    %ebx
  802988:	5e                   	pop    %esi
  802989:	5f                   	pop    %edi
  80298a:	5d                   	pop    %ebp
  80298b:	c3                   	ret    
  80298c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802990:	8b 34 24             	mov    (%esp),%esi
  802993:	bf 20 00 00 00       	mov    $0x20,%edi
  802998:	89 e9                	mov    %ebp,%ecx
  80299a:	29 ef                	sub    %ebp,%edi
  80299c:	d3 e0                	shl    %cl,%eax
  80299e:	89 f9                	mov    %edi,%ecx
  8029a0:	89 f2                	mov    %esi,%edx
  8029a2:	d3 ea                	shr    %cl,%edx
  8029a4:	89 e9                	mov    %ebp,%ecx
  8029a6:	09 c2                	or     %eax,%edx
  8029a8:	89 d8                	mov    %ebx,%eax
  8029aa:	89 14 24             	mov    %edx,(%esp)
  8029ad:	89 f2                	mov    %esi,%edx
  8029af:	d3 e2                	shl    %cl,%edx
  8029b1:	89 f9                	mov    %edi,%ecx
  8029b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029bb:	d3 e8                	shr    %cl,%eax
  8029bd:	89 e9                	mov    %ebp,%ecx
  8029bf:	89 c6                	mov    %eax,%esi
  8029c1:	d3 e3                	shl    %cl,%ebx
  8029c3:	89 f9                	mov    %edi,%ecx
  8029c5:	89 d0                	mov    %edx,%eax
  8029c7:	d3 e8                	shr    %cl,%eax
  8029c9:	89 e9                	mov    %ebp,%ecx
  8029cb:	09 d8                	or     %ebx,%eax
  8029cd:	89 d3                	mov    %edx,%ebx
  8029cf:	89 f2                	mov    %esi,%edx
  8029d1:	f7 34 24             	divl   (%esp)
  8029d4:	89 d6                	mov    %edx,%esi
  8029d6:	d3 e3                	shl    %cl,%ebx
  8029d8:	f7 64 24 04          	mull   0x4(%esp)
  8029dc:	39 d6                	cmp    %edx,%esi
  8029de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029e2:	89 d1                	mov    %edx,%ecx
  8029e4:	89 c3                	mov    %eax,%ebx
  8029e6:	72 08                	jb     8029f0 <__umoddi3+0x110>
  8029e8:	75 11                	jne    8029fb <__umoddi3+0x11b>
  8029ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029ee:	73 0b                	jae    8029fb <__umoddi3+0x11b>
  8029f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029f4:	1b 14 24             	sbb    (%esp),%edx
  8029f7:	89 d1                	mov    %edx,%ecx
  8029f9:	89 c3                	mov    %eax,%ebx
  8029fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029ff:	29 da                	sub    %ebx,%edx
  802a01:	19 ce                	sbb    %ecx,%esi
  802a03:	89 f9                	mov    %edi,%ecx
  802a05:	89 f0                	mov    %esi,%eax
  802a07:	d3 e0                	shl    %cl,%eax
  802a09:	89 e9                	mov    %ebp,%ecx
  802a0b:	d3 ea                	shr    %cl,%edx
  802a0d:	89 e9                	mov    %ebp,%ecx
  802a0f:	d3 ee                	shr    %cl,%esi
  802a11:	09 d0                	or     %edx,%eax
  802a13:	89 f2                	mov    %esi,%edx
  802a15:	83 c4 1c             	add    $0x1c,%esp
  802a18:	5b                   	pop    %ebx
  802a19:	5e                   	pop    %esi
  802a1a:	5f                   	pop    %edi
  802a1b:	5d                   	pop    %ebp
  802a1c:	c3                   	ret    
  802a1d:	8d 76 00             	lea    0x0(%esi),%esi
  802a20:	29 f9                	sub    %edi,%ecx
  802a22:	19 d6                	sbb    %edx,%esi
  802a24:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a2c:	e9 18 ff ff ff       	jmp    802949 <__umoddi3+0x69>
