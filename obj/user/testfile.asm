
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 60 80 00       	push   $0x806000
  800042:	e8 bf 0c 00 00       	call   800d06 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 85 13 00 00       	call   8013de <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 27 13 00 00       	call   80138f <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 a0 12 00 00       	call   801319 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 40 28 80 00       	mov    $0x802840,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 4b 28 80 00       	push   $0x80284b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 65 28 80 00       	push   $0x802865
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 00 2a 80 00       	push   $0x802a00
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 65 28 80 00       	push   $0x802865
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 75 28 80 00       	mov    $0x802875,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 7e 28 80 00       	push   $0x80287e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 65 28 80 00       	push   $0x802865
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 24 2a 80 00       	push   $0x802a24
  800119:	6a 27                	push   $0x27
  80011b:	68 65 28 80 00       	push   $0x802865
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 96 28 80 00       	push   $0x802896
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 40 80 00    	call   *0x80401c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 aa 28 80 00       	push   $0x8028aa
  800154:	6a 2b                	push   $0x2b
  800156:	68 65 28 80 00       	push   $0x802865
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 40 80 00    	pushl  0x804000
  800169:	e8 5f 0b 00 00       	call   800ccd <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 40 80 00    	pushl  0x804000
  80017f:	e8 49 0b 00 00       	call   800ccd <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 54 2a 80 00       	push   $0x802a54
  80018f:	6a 2d                	push   $0x2d
  800191:	68 65 28 80 00       	push   $0x802865
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 b8 28 80 00       	push   $0x8028b8
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 8d 0c 00 00       	call   800e4b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 40 80 00    	call   *0x804010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 cb 28 80 00       	push   $0x8028cb
  8001df:	6a 32                	push   $0x32
  8001e1:	68 65 28 80 00       	push   $0x802865
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 40 80 00    	pushl  0x804000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 b0 0b 00 00       	call   800db0 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 d9 28 80 00       	push   $0x8028d9
  80020f:	6a 34                	push   $0x34
  800211:	68 65 28 80 00       	push   $0x802865
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 f7 28 80 00       	push   $0x8028f7
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 40 80 00    	call   *0x804018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 0a 29 80 00       	push   $0x80290a
  800242:	6a 38                	push   $0x38
  800244:	68 65 28 80 00       	push   $0x802865
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 19 29 80 00       	push   $0x802919
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 04 0f 00 00       	call   80118e <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 40 80 00    	call   *0x804010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 7c 2a 80 00       	push   $0x802a7c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 65 28 80 00       	push   $0x802865
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 2d 29 80 00       	push   $0x80292d
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 43 29 80 00       	mov    $0x802943,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 4d 29 80 00       	push   $0x80294d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 65 28 80 00       	push   $0x802865
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 40 80 00    	pushl  0x804000
  800301:	e8 c7 09 00 00       	call   800ccd <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 40 80 00    	pushl  0x804000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 40 80 00    	pushl  0x804000
  800322:	e8 a6 09 00 00       	call   800ccd <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 66 29 80 00       	push   $0x802966
  800334:	6a 4b                	push   $0x4b
  800336:	68 65 28 80 00       	push   $0x802865
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 75 29 80 00       	push   $0x802975
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 de 0a 00 00       	call   800e4b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 40 80 00    	call   *0x804010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 b4 2a 80 00       	push   $0x802ab4
  800390:	6a 51                	push   $0x51
  800392:	68 65 28 80 00       	push   $0x802865
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 40 80 00    	pushl  0x804000
  8003a5:	e8 23 09 00 00       	call   800ccd <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 d4 2a 80 00       	push   $0x802ad4
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 65 28 80 00       	push   $0x802865
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 40 80 00    	pushl  0x804000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 d8 09 00 00       	call   800db0 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 0c 2b 80 00       	push   $0x802b0c
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 65 28 80 00       	push   $0x802865
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 3c 2b 80 00       	push   $0x802b3c
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 40 28 80 00       	push   $0x802840
  80040a:	e8 7b 17 00 00       	call   801b8a <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 51 28 80 00       	push   $0x802851
  800426:	6a 5a                	push   $0x5a
  800428:	68 65 28 80 00       	push   $0x802865
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 89 29 80 00       	push   $0x802989
  80043e:	6a 5c                	push   $0x5c
  800440:	68 65 28 80 00       	push   $0x802865
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 75 28 80 00       	push   $0x802875
  800454:	e8 31 17 00 00       	call   801b8a <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 84 28 80 00       	push   $0x802884
  800466:	6a 5f                	push   $0x5f
  800468:	68 65 28 80 00       	push   $0x802865
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 60 2b 80 00       	push   $0x802b60
  800498:	6a 62                	push   $0x62
  80049a:	68 65 28 80 00       	push   $0x802865
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 9c 28 80 00       	push   $0x80289c
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 a4 29 80 00       	push   $0x8029a4
  8004be:	e8 c7 16 00 00       	call   801b8a <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 a9 29 80 00       	push   $0x8029a9
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 65 28 80 00       	push   $0x802865
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 57 09 00 00       	call   800e4b <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 b6 12 00 00       	call   8017cd <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 b8 29 80 00       	push   $0x8029b8
  800528:	6a 6c                	push   $0x6c
  80052a:	68 65 28 80 00       	push   $0x802865
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 6b 10 00 00       	call   8015b7 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 a4 29 80 00       	push   $0x8029a4
  800556:	e8 2f 16 00 00       	call   801b8a <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 ca 29 80 00       	push   $0x8029ca
  80056a:	6a 71                	push   $0x71
  80056c:	68 65 28 80 00       	push   $0x802865
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 ee 11 00 00       	call   801784 <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 d8 29 80 00       	push   $0x8029d8
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 65 28 80 00       	push   $0x802865
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 88 2b 80 00       	push   $0x802b88
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 65 28 80 00       	push   $0x802865
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 b4 2b 80 00       	push   $0x802bb4
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 65 28 80 00       	push   $0x802865
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 a6 0f 00 00       	call   8015b7 <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 e9 29 80 00 	movl   $0x8029e9,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800633:	e8 93 0a 00 00       	call   8010cb <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 08 50 80 00       	mov    %eax,0x805008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
		binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 69 0f 00 00       	call   8015e2 <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 07 0a 00 00       	call   80108a <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800696:	e8 30 0a 00 00       	call   8010cb <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 0c 2c 80 00       	push   $0x802c0c
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 4b 30 80 00 	movl   $0x80304b,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 4f 09 00 00       	call   80104d <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 54 01 00 00       	call   800898 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 f4 08 00 00       	call   80104d <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 e7 1d 00 00       	call   8025b0 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 d4 1e 00 00       	call   8026e0 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 2f 2c 80 00 	movsbl 0x802c2f(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800827:	83 fa 01             	cmp    $0x1,%edx
  80082a:	7e 0e                	jle    80083a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800831:	89 08                	mov    %ecx,(%eax)
  800833:	8b 02                	mov    (%edx),%eax
  800835:	8b 52 04             	mov    0x4(%edx),%edx
  800838:	eb 22                	jmp    80085c <getuint+0x38>
	else if (lflag)
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 10                	je     80084e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	8d 4a 04             	lea    0x4(%edx),%ecx
  800843:	89 08                	mov    %ecx,(%eax)
  800845:	8b 02                	mov    (%edx),%eax
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 0e                	jmp    80085c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	8d 4a 04             	lea    0x4(%edx),%ecx
  800853:	89 08                	mov    %ecx,(%eax)
  800855:	8b 02                	mov    (%edx),%eax
  800857:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800864:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	3b 50 04             	cmp    0x4(%eax),%edx
  80086d:	73 0a                	jae    800879 <sprintputch+0x1b>
		*b->buf++ = ch;
  80086f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800872:	89 08                	mov    %ecx,(%eax)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	88 02                	mov    %al,(%edx)
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800884:	50                   	push   %eax
  800885:	ff 75 10             	pushl  0x10(%ebp)
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 05 00 00 00       	call   800898 <vprintfmt>
	va_end(ap);
}
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	83 ec 2c             	sub    $0x2c,%esp
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008aa:	eb 12                	jmp    8008be <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	0f 84 a9 03 00 00    	je     800c5d <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	50                   	push   %eax
  8008b9:	ff d6                	call   *%esi
  8008bb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008be:	83 c7 01             	add    $0x1,%edi
  8008c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c5:	83 f8 25             	cmp    $0x25,%eax
  8008c8:	75 e2                	jne    8008ac <vprintfmt+0x14>
  8008ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e8:	eb 07                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008ed:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f1:	8d 47 01             	lea    0x1(%edi),%eax
  8008f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f7:	0f b6 07             	movzbl (%edi),%eax
  8008fa:	0f b6 c8             	movzbl %al,%ecx
  8008fd:	83 e8 23             	sub    $0x23,%eax
  800900:	3c 55                	cmp    $0x55,%al
  800902:	0f 87 3a 03 00 00    	ja     800c42 <vprintfmt+0x3aa>
  800908:	0f b6 c0             	movzbl %al,%eax
  80090b:	ff 24 85 80 2d 80 00 	jmp    *0x802d80(,%eax,4)
  800912:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800915:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800919:	eb d6                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800926:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800929:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80092d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800930:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800933:	83 fa 09             	cmp    $0x9,%edx
  800936:	77 39                	ja     800971 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800938:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80093b:	eb e9                	jmp    800926 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80093d:	8b 45 14             	mov    0x14(%ebp),%eax
  800940:	8d 48 04             	lea    0x4(%eax),%ecx
  800943:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800946:	8b 00                	mov    (%eax),%eax
  800948:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80094e:	eb 27                	jmp    800977 <vprintfmt+0xdf>
  800950:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800953:	85 c0                	test   %eax,%eax
  800955:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095a:	0f 49 c8             	cmovns %eax,%ecx
  80095d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800960:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800963:	eb 8c                	jmp    8008f1 <vprintfmt+0x59>
  800965:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800968:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80096f:	eb 80                	jmp    8008f1 <vprintfmt+0x59>
  800971:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800974:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800977:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80097b:	0f 89 70 ff ff ff    	jns    8008f1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800981:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800984:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800987:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80098e:	e9 5e ff ff ff       	jmp    8008f1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800993:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800996:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800999:	e9 53 ff ff ff       	jmp    8008f1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	8d 50 04             	lea    0x4(%eax),%edx
  8009a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	53                   	push   %ebx
  8009ab:	ff 30                	pushl  (%eax)
  8009ad:	ff d6                	call   *%esi
			break;
  8009af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009b5:	e9 04 ff ff ff       	jmp    8008be <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bd:	8d 50 04             	lea    0x4(%eax),%edx
  8009c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c3:	8b 00                	mov    (%eax),%eax
  8009c5:	99                   	cltd   
  8009c6:	31 d0                	xor    %edx,%eax
  8009c8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ca:	83 f8 0f             	cmp    $0xf,%eax
  8009cd:	7f 0b                	jg     8009da <vprintfmt+0x142>
  8009cf:	8b 14 85 e0 2e 80 00 	mov    0x802ee0(,%eax,4),%edx
  8009d6:	85 d2                	test   %edx,%edx
  8009d8:	75 18                	jne    8009f2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009da:	50                   	push   %eax
  8009db:	68 47 2c 80 00       	push   $0x802c47
  8009e0:	53                   	push   %ebx
  8009e1:	56                   	push   %esi
  8009e2:	e8 94 fe ff ff       	call   80087b <printfmt>
  8009e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009ed:	e9 cc fe ff ff       	jmp    8008be <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009f2:	52                   	push   %edx
  8009f3:	68 19 30 80 00       	push   $0x803019
  8009f8:	53                   	push   %ebx
  8009f9:	56                   	push   %esi
  8009fa:	e8 7c fe ff ff       	call   80087b <printfmt>
  8009ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a05:	e9 b4 fe ff ff       	jmp    8008be <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0d:	8d 50 04             	lea    0x4(%eax),%edx
  800a10:	89 55 14             	mov    %edx,0x14(%ebp)
  800a13:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a15:	85 ff                	test   %edi,%edi
  800a17:	b8 40 2c 80 00       	mov    $0x802c40,%eax
  800a1c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a23:	0f 8e 94 00 00 00    	jle    800abd <vprintfmt+0x225>
  800a29:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a2d:	0f 84 98 00 00 00    	je     800acb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	ff 75 d0             	pushl  -0x30(%ebp)
  800a39:	57                   	push   %edi
  800a3a:	e8 a6 02 00 00       	call   800ce5 <strnlen>
  800a3f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a42:	29 c1                	sub    %eax,%ecx
  800a44:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a47:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a4a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a51:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a54:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a56:	eb 0f                	jmp    800a67 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	53                   	push   %ebx
  800a5c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a5f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	83 c4 10             	add    $0x10,%esp
  800a67:	85 ff                	test   %edi,%edi
  800a69:	7f ed                	jg     800a58 <vprintfmt+0x1c0>
  800a6b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a6e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a71:	85 c9                	test   %ecx,%ecx
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	0f 49 c1             	cmovns %ecx,%eax
  800a7b:	29 c1                	sub    %eax,%ecx
  800a7d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a80:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a83:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a86:	89 cb                	mov    %ecx,%ebx
  800a88:	eb 4d                	jmp    800ad7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a8a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a8e:	74 1b                	je     800aab <vprintfmt+0x213>
  800a90:	0f be c0             	movsbl %al,%eax
  800a93:	83 e8 20             	sub    $0x20,%eax
  800a96:	83 f8 5e             	cmp    $0x5e,%eax
  800a99:	76 10                	jbe    800aab <vprintfmt+0x213>
					putch('?', putdat);
  800a9b:	83 ec 08             	sub    $0x8,%esp
  800a9e:	ff 75 0c             	pushl  0xc(%ebp)
  800aa1:	6a 3f                	push   $0x3f
  800aa3:	ff 55 08             	call   *0x8(%ebp)
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	eb 0d                	jmp    800ab8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	ff 75 0c             	pushl  0xc(%ebp)
  800ab1:	52                   	push   %edx
  800ab2:	ff 55 08             	call   *0x8(%ebp)
  800ab5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab8:	83 eb 01             	sub    $0x1,%ebx
  800abb:	eb 1a                	jmp    800ad7 <vprintfmt+0x23f>
  800abd:	89 75 08             	mov    %esi,0x8(%ebp)
  800ac0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ac3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ac6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ac9:	eb 0c                	jmp    800ad7 <vprintfmt+0x23f>
  800acb:	89 75 08             	mov    %esi,0x8(%ebp)
  800ace:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ad1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ad4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ad7:	83 c7 01             	add    $0x1,%edi
  800ada:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ade:	0f be d0             	movsbl %al,%edx
  800ae1:	85 d2                	test   %edx,%edx
  800ae3:	74 23                	je     800b08 <vprintfmt+0x270>
  800ae5:	85 f6                	test   %esi,%esi
  800ae7:	78 a1                	js     800a8a <vprintfmt+0x1f2>
  800ae9:	83 ee 01             	sub    $0x1,%esi
  800aec:	79 9c                	jns    800a8a <vprintfmt+0x1f2>
  800aee:	89 df                	mov    %ebx,%edi
  800af0:	8b 75 08             	mov    0x8(%ebp),%esi
  800af3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af6:	eb 18                	jmp    800b10 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	53                   	push   %ebx
  800afc:	6a 20                	push   $0x20
  800afe:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b00:	83 ef 01             	sub    $0x1,%edi
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	eb 08                	jmp    800b10 <vprintfmt+0x278>
  800b08:	89 df                	mov    %ebx,%edi
  800b0a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b10:	85 ff                	test   %edi,%edi
  800b12:	7f e4                	jg     800af8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b17:	e9 a2 fd ff ff       	jmp    8008be <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b1c:	83 fa 01             	cmp    $0x1,%edx
  800b1f:	7e 16                	jle    800b37 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b21:	8b 45 14             	mov    0x14(%ebp),%eax
  800b24:	8d 50 08             	lea    0x8(%eax),%edx
  800b27:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2a:	8b 50 04             	mov    0x4(%eax),%edx
  800b2d:	8b 00                	mov    (%eax),%eax
  800b2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b32:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b35:	eb 32                	jmp    800b69 <vprintfmt+0x2d1>
	else if (lflag)
  800b37:	85 d2                	test   %edx,%edx
  800b39:	74 18                	je     800b53 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3e:	8d 50 04             	lea    0x4(%eax),%edx
  800b41:	89 55 14             	mov    %edx,0x14(%ebp)
  800b44:	8b 00                	mov    (%eax),%eax
  800b46:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b49:	89 c1                	mov    %eax,%ecx
  800b4b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b4e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b51:	eb 16                	jmp    800b69 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b53:	8b 45 14             	mov    0x14(%ebp),%eax
  800b56:	8d 50 04             	lea    0x4(%eax),%edx
  800b59:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5c:	8b 00                	mov    (%eax),%eax
  800b5e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b61:	89 c1                	mov    %eax,%ecx
  800b63:	c1 f9 1f             	sar    $0x1f,%ecx
  800b66:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b69:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b6f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b74:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b78:	0f 89 90 00 00 00    	jns    800c0e <vprintfmt+0x376>
				putch('-', putdat);
  800b7e:	83 ec 08             	sub    $0x8,%esp
  800b81:	53                   	push   %ebx
  800b82:	6a 2d                	push   $0x2d
  800b84:	ff d6                	call   *%esi
				num = -(long long) num;
  800b86:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b89:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b8c:	f7 d8                	neg    %eax
  800b8e:	83 d2 00             	adc    $0x0,%edx
  800b91:	f7 da                	neg    %edx
  800b93:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b96:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b9b:	eb 71                	jmp    800c0e <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b9d:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba0:	e8 7f fc ff ff       	call   800824 <getuint>
			base = 10;
  800ba5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800baa:	eb 62                	jmp    800c0e <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800bac:	8d 45 14             	lea    0x14(%ebp),%eax
  800baf:	e8 70 fc ff ff       	call   800824 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800bbb:	51                   	push   %ecx
  800bbc:	ff 75 e0             	pushl  -0x20(%ebp)
  800bbf:	6a 08                	push   $0x8
  800bc1:	52                   	push   %edx
  800bc2:	50                   	push   %eax
  800bc3:	89 da                	mov    %ebx,%edx
  800bc5:	89 f0                	mov    %esi,%eax
  800bc7:	e8 a9 fb ff ff       	call   800775 <printnum>
			break;
  800bcc:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bcf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800bd2:	e9 e7 fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800bd7:	83 ec 08             	sub    $0x8,%esp
  800bda:	53                   	push   %ebx
  800bdb:	6a 30                	push   $0x30
  800bdd:	ff d6                	call   *%esi
			putch('x', putdat);
  800bdf:	83 c4 08             	add    $0x8,%esp
  800be2:	53                   	push   %ebx
  800be3:	6a 78                	push   $0x78
  800be5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800be7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bea:	8d 50 04             	lea    0x4(%eax),%edx
  800bed:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bf0:	8b 00                	mov    (%eax),%eax
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bf7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bfa:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bff:	eb 0d                	jmp    800c0e <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c01:	8d 45 14             	lea    0x14(%ebp),%eax
  800c04:	e8 1b fc ff ff       	call   800824 <getuint>
			base = 16;
  800c09:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c0e:	83 ec 0c             	sub    $0xc,%esp
  800c11:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c15:	57                   	push   %edi
  800c16:	ff 75 e0             	pushl  -0x20(%ebp)
  800c19:	51                   	push   %ecx
  800c1a:	52                   	push   %edx
  800c1b:	50                   	push   %eax
  800c1c:	89 da                	mov    %ebx,%edx
  800c1e:	89 f0                	mov    %esi,%eax
  800c20:	e8 50 fb ff ff       	call   800775 <printnum>
			break;
  800c25:	83 c4 20             	add    $0x20,%esp
  800c28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c2b:	e9 8e fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c30:	83 ec 08             	sub    $0x8,%esp
  800c33:	53                   	push   %ebx
  800c34:	51                   	push   %ecx
  800c35:	ff d6                	call   *%esi
			break;
  800c37:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c3d:	e9 7c fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c42:	83 ec 08             	sub    $0x8,%esp
  800c45:	53                   	push   %ebx
  800c46:	6a 25                	push   $0x25
  800c48:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	eb 03                	jmp    800c52 <vprintfmt+0x3ba>
  800c4f:	83 ef 01             	sub    $0x1,%edi
  800c52:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c56:	75 f7                	jne    800c4f <vprintfmt+0x3b7>
  800c58:	e9 61 fc ff ff       	jmp    8008be <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	83 ec 18             	sub    $0x18,%esp
  800c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c71:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c74:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c78:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	74 26                	je     800cac <vsnprintf+0x47>
  800c86:	85 d2                	test   %edx,%edx
  800c88:	7e 22                	jle    800cac <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c8a:	ff 75 14             	pushl  0x14(%ebp)
  800c8d:	ff 75 10             	pushl  0x10(%ebp)
  800c90:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c93:	50                   	push   %eax
  800c94:	68 5e 08 80 00       	push   $0x80085e
  800c99:	e8 fa fb ff ff       	call   800898 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca7:	83 c4 10             	add    $0x10,%esp
  800caa:	eb 05                	jmp    800cb1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    

00800cb3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cb9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cbc:	50                   	push   %eax
  800cbd:	ff 75 10             	pushl  0x10(%ebp)
  800cc0:	ff 75 0c             	pushl  0xc(%ebp)
  800cc3:	ff 75 08             	pushl  0x8(%ebp)
  800cc6:	e8 9a ff ff ff       	call   800c65 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ccb:	c9                   	leave  
  800ccc:	c3                   	ret    

00800ccd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd8:	eb 03                	jmp    800cdd <strlen+0x10>
		n++;
  800cda:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cdd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ce1:	75 f7                	jne    800cda <strlen+0xd>
		n++;
	return n;
}
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cee:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf3:	eb 03                	jmp    800cf8 <strnlen+0x13>
		n++;
  800cf5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cf8:	39 c2                	cmp    %eax,%edx
  800cfa:	74 08                	je     800d04 <strnlen+0x1f>
  800cfc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800d00:	75 f3                	jne    800cf5 <strnlen+0x10>
  800d02:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	53                   	push   %ebx
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d10:	89 c2                	mov    %eax,%edx
  800d12:	83 c2 01             	add    $0x1,%edx
  800d15:	83 c1 01             	add    $0x1,%ecx
  800d18:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d1c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d1f:	84 db                	test   %bl,%bl
  800d21:	75 ef                	jne    800d12 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d23:	5b                   	pop    %ebx
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	53                   	push   %ebx
  800d2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d2d:	53                   	push   %ebx
  800d2e:	e8 9a ff ff ff       	call   800ccd <strlen>
  800d33:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d36:	ff 75 0c             	pushl  0xc(%ebp)
  800d39:	01 d8                	add    %ebx,%eax
  800d3b:	50                   	push   %eax
  800d3c:	e8 c5 ff ff ff       	call   800d06 <strcpy>
	return dst;
}
  800d41:	89 d8                	mov    %ebx,%eax
  800d43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d46:	c9                   	leave  
  800d47:	c3                   	ret    

00800d48 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	8b 75 08             	mov    0x8(%ebp),%esi
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	89 f3                	mov    %esi,%ebx
  800d55:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d58:	89 f2                	mov    %esi,%edx
  800d5a:	eb 0f                	jmp    800d6b <strncpy+0x23>
		*dst++ = *src;
  800d5c:	83 c2 01             	add    $0x1,%edx
  800d5f:	0f b6 01             	movzbl (%ecx),%eax
  800d62:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d65:	80 39 01             	cmpb   $0x1,(%ecx)
  800d68:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d6b:	39 da                	cmp    %ebx,%edx
  800d6d:	75 ed                	jne    800d5c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d6f:	89 f0                	mov    %esi,%eax
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	8b 55 10             	mov    0x10(%ebp),%edx
  800d83:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d85:	85 d2                	test   %edx,%edx
  800d87:	74 21                	je     800daa <strlcpy+0x35>
  800d89:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d8d:	89 f2                	mov    %esi,%edx
  800d8f:	eb 09                	jmp    800d9a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d91:	83 c2 01             	add    $0x1,%edx
  800d94:	83 c1 01             	add    $0x1,%ecx
  800d97:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d9a:	39 c2                	cmp    %eax,%edx
  800d9c:	74 09                	je     800da7 <strlcpy+0x32>
  800d9e:	0f b6 19             	movzbl (%ecx),%ebx
  800da1:	84 db                	test   %bl,%bl
  800da3:	75 ec                	jne    800d91 <strlcpy+0x1c>
  800da5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800da7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800daa:	29 f0                	sub    %esi,%eax
}
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800db9:	eb 06                	jmp    800dc1 <strcmp+0x11>
		p++, q++;
  800dbb:	83 c1 01             	add    $0x1,%ecx
  800dbe:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dc1:	0f b6 01             	movzbl (%ecx),%eax
  800dc4:	84 c0                	test   %al,%al
  800dc6:	74 04                	je     800dcc <strcmp+0x1c>
  800dc8:	3a 02                	cmp    (%edx),%al
  800dca:	74 ef                	je     800dbb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dcc:	0f b6 c0             	movzbl %al,%eax
  800dcf:	0f b6 12             	movzbl (%edx),%edx
  800dd2:	29 d0                	sub    %edx,%eax
}
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	53                   	push   %ebx
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de0:	89 c3                	mov    %eax,%ebx
  800de2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800de5:	eb 06                	jmp    800ded <strncmp+0x17>
		n--, p++, q++;
  800de7:	83 c0 01             	add    $0x1,%eax
  800dea:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ded:	39 d8                	cmp    %ebx,%eax
  800def:	74 15                	je     800e06 <strncmp+0x30>
  800df1:	0f b6 08             	movzbl (%eax),%ecx
  800df4:	84 c9                	test   %cl,%cl
  800df6:	74 04                	je     800dfc <strncmp+0x26>
  800df8:	3a 0a                	cmp    (%edx),%cl
  800dfa:	74 eb                	je     800de7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dfc:	0f b6 00             	movzbl (%eax),%eax
  800dff:	0f b6 12             	movzbl (%edx),%edx
  800e02:	29 d0                	sub    %edx,%eax
  800e04:	eb 05                	jmp    800e0b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e0b:	5b                   	pop    %ebx
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	8b 45 08             	mov    0x8(%ebp),%eax
  800e14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e18:	eb 07                	jmp    800e21 <strchr+0x13>
		if (*s == c)
  800e1a:	38 ca                	cmp    %cl,%dl
  800e1c:	74 0f                	je     800e2d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e1e:	83 c0 01             	add    $0x1,%eax
  800e21:	0f b6 10             	movzbl (%eax),%edx
  800e24:	84 d2                	test   %dl,%dl
  800e26:	75 f2                	jne    800e1a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e39:	eb 03                	jmp    800e3e <strfind+0xf>
  800e3b:	83 c0 01             	add    $0x1,%eax
  800e3e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e41:	38 ca                	cmp    %cl,%dl
  800e43:	74 04                	je     800e49 <strfind+0x1a>
  800e45:	84 d2                	test   %dl,%dl
  800e47:	75 f2                	jne    800e3b <strfind+0xc>
			break;
	return (char *) s;
}
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e57:	85 c9                	test   %ecx,%ecx
  800e59:	74 36                	je     800e91 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e5b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e61:	75 28                	jne    800e8b <memset+0x40>
  800e63:	f6 c1 03             	test   $0x3,%cl
  800e66:	75 23                	jne    800e8b <memset+0x40>
		c &= 0xFF;
  800e68:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e6c:	89 d3                	mov    %edx,%ebx
  800e6e:	c1 e3 08             	shl    $0x8,%ebx
  800e71:	89 d6                	mov    %edx,%esi
  800e73:	c1 e6 18             	shl    $0x18,%esi
  800e76:	89 d0                	mov    %edx,%eax
  800e78:	c1 e0 10             	shl    $0x10,%eax
  800e7b:	09 f0                	or     %esi,%eax
  800e7d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e7f:	89 d8                	mov    %ebx,%eax
  800e81:	09 d0                	or     %edx,%eax
  800e83:	c1 e9 02             	shr    $0x2,%ecx
  800e86:	fc                   	cld    
  800e87:	f3 ab                	rep stos %eax,%es:(%edi)
  800e89:	eb 06                	jmp    800e91 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8e:	fc                   	cld    
  800e8f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e91:	89 f8                	mov    %edi,%eax
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ea3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ea6:	39 c6                	cmp    %eax,%esi
  800ea8:	73 35                	jae    800edf <memmove+0x47>
  800eaa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ead:	39 d0                	cmp    %edx,%eax
  800eaf:	73 2e                	jae    800edf <memmove+0x47>
		s += n;
		d += n;
  800eb1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eb4:	89 d6                	mov    %edx,%esi
  800eb6:	09 fe                	or     %edi,%esi
  800eb8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ebe:	75 13                	jne    800ed3 <memmove+0x3b>
  800ec0:	f6 c1 03             	test   $0x3,%cl
  800ec3:	75 0e                	jne    800ed3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ec5:	83 ef 04             	sub    $0x4,%edi
  800ec8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ecb:	c1 e9 02             	shr    $0x2,%ecx
  800ece:	fd                   	std    
  800ecf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed1:	eb 09                	jmp    800edc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ed3:	83 ef 01             	sub    $0x1,%edi
  800ed6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ed9:	fd                   	std    
  800eda:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800edc:	fc                   	cld    
  800edd:	eb 1d                	jmp    800efc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800edf:	89 f2                	mov    %esi,%edx
  800ee1:	09 c2                	or     %eax,%edx
  800ee3:	f6 c2 03             	test   $0x3,%dl
  800ee6:	75 0f                	jne    800ef7 <memmove+0x5f>
  800ee8:	f6 c1 03             	test   $0x3,%cl
  800eeb:	75 0a                	jne    800ef7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800eed:	c1 e9 02             	shr    $0x2,%ecx
  800ef0:	89 c7                	mov    %eax,%edi
  800ef2:	fc                   	cld    
  800ef3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ef5:	eb 05                	jmp    800efc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ef7:	89 c7                	mov    %eax,%edi
  800ef9:	fc                   	cld    
  800efa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f03:	ff 75 10             	pushl  0x10(%ebp)
  800f06:	ff 75 0c             	pushl  0xc(%ebp)
  800f09:	ff 75 08             	pushl  0x8(%ebp)
  800f0c:	e8 87 ff ff ff       	call   800e98 <memmove>
}
  800f11:	c9                   	leave  
  800f12:	c3                   	ret    

00800f13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f1e:	89 c6                	mov    %eax,%esi
  800f20:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f23:	eb 1a                	jmp    800f3f <memcmp+0x2c>
		if (*s1 != *s2)
  800f25:	0f b6 08             	movzbl (%eax),%ecx
  800f28:	0f b6 1a             	movzbl (%edx),%ebx
  800f2b:	38 d9                	cmp    %bl,%cl
  800f2d:	74 0a                	je     800f39 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f2f:	0f b6 c1             	movzbl %cl,%eax
  800f32:	0f b6 db             	movzbl %bl,%ebx
  800f35:	29 d8                	sub    %ebx,%eax
  800f37:	eb 0f                	jmp    800f48 <memcmp+0x35>
		s1++, s2++;
  800f39:	83 c0 01             	add    $0x1,%eax
  800f3c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f3f:	39 f0                	cmp    %esi,%eax
  800f41:	75 e2                	jne    800f25 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	53                   	push   %ebx
  800f50:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f53:	89 c1                	mov    %eax,%ecx
  800f55:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f58:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f5c:	eb 0a                	jmp    800f68 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f5e:	0f b6 10             	movzbl (%eax),%edx
  800f61:	39 da                	cmp    %ebx,%edx
  800f63:	74 07                	je     800f6c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f65:	83 c0 01             	add    $0x1,%eax
  800f68:	39 c8                	cmp    %ecx,%eax
  800f6a:	72 f2                	jb     800f5e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f6c:	5b                   	pop    %ebx
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	57                   	push   %edi
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f7b:	eb 03                	jmp    800f80 <strtol+0x11>
		s++;
  800f7d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f80:	0f b6 01             	movzbl (%ecx),%eax
  800f83:	3c 20                	cmp    $0x20,%al
  800f85:	74 f6                	je     800f7d <strtol+0xe>
  800f87:	3c 09                	cmp    $0x9,%al
  800f89:	74 f2                	je     800f7d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f8b:	3c 2b                	cmp    $0x2b,%al
  800f8d:	75 0a                	jne    800f99 <strtol+0x2a>
		s++;
  800f8f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f92:	bf 00 00 00 00       	mov    $0x0,%edi
  800f97:	eb 11                	jmp    800faa <strtol+0x3b>
  800f99:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f9e:	3c 2d                	cmp    $0x2d,%al
  800fa0:	75 08                	jne    800faa <strtol+0x3b>
		s++, neg = 1;
  800fa2:	83 c1 01             	add    $0x1,%ecx
  800fa5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800faa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fb0:	75 15                	jne    800fc7 <strtol+0x58>
  800fb2:	80 39 30             	cmpb   $0x30,(%ecx)
  800fb5:	75 10                	jne    800fc7 <strtol+0x58>
  800fb7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fbb:	75 7c                	jne    801039 <strtol+0xca>
		s += 2, base = 16;
  800fbd:	83 c1 02             	add    $0x2,%ecx
  800fc0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fc5:	eb 16                	jmp    800fdd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fc7:	85 db                	test   %ebx,%ebx
  800fc9:	75 12                	jne    800fdd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fcb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fd0:	80 39 30             	cmpb   $0x30,(%ecx)
  800fd3:	75 08                	jne    800fdd <strtol+0x6e>
		s++, base = 8;
  800fd5:	83 c1 01             	add    $0x1,%ecx
  800fd8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fe5:	0f b6 11             	movzbl (%ecx),%edx
  800fe8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800feb:	89 f3                	mov    %esi,%ebx
  800fed:	80 fb 09             	cmp    $0x9,%bl
  800ff0:	77 08                	ja     800ffa <strtol+0x8b>
			dig = *s - '0';
  800ff2:	0f be d2             	movsbl %dl,%edx
  800ff5:	83 ea 30             	sub    $0x30,%edx
  800ff8:	eb 22                	jmp    80101c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ffa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ffd:	89 f3                	mov    %esi,%ebx
  800fff:	80 fb 19             	cmp    $0x19,%bl
  801002:	77 08                	ja     80100c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801004:	0f be d2             	movsbl %dl,%edx
  801007:	83 ea 57             	sub    $0x57,%edx
  80100a:	eb 10                	jmp    80101c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80100c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80100f:	89 f3                	mov    %esi,%ebx
  801011:	80 fb 19             	cmp    $0x19,%bl
  801014:	77 16                	ja     80102c <strtol+0xbd>
			dig = *s - 'A' + 10;
  801016:	0f be d2             	movsbl %dl,%edx
  801019:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80101c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80101f:	7d 0b                	jge    80102c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801021:	83 c1 01             	add    $0x1,%ecx
  801024:	0f af 45 10          	imul   0x10(%ebp),%eax
  801028:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80102a:	eb b9                	jmp    800fe5 <strtol+0x76>

	if (endptr)
  80102c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801030:	74 0d                	je     80103f <strtol+0xd0>
		*endptr = (char *) s;
  801032:	8b 75 0c             	mov    0xc(%ebp),%esi
  801035:	89 0e                	mov    %ecx,(%esi)
  801037:	eb 06                	jmp    80103f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801039:	85 db                	test   %ebx,%ebx
  80103b:	74 98                	je     800fd5 <strtol+0x66>
  80103d:	eb 9e                	jmp    800fdd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80103f:	89 c2                	mov    %eax,%edx
  801041:	f7 da                	neg    %edx
  801043:	85 ff                	test   %edi,%edi
  801045:	0f 45 c2             	cmovne %edx,%eax
}
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	57                   	push   %edi
  801051:	56                   	push   %esi
  801052:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801053:	b8 00 00 00 00       	mov    $0x0,%eax
  801058:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105b:	8b 55 08             	mov    0x8(%ebp),%edx
  80105e:	89 c3                	mov    %eax,%ebx
  801060:	89 c7                	mov    %eax,%edi
  801062:	89 c6                	mov    %eax,%esi
  801064:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <sys_cgetc>:

int
sys_cgetc(void)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	57                   	push   %edi
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801071:	ba 00 00 00 00       	mov    $0x0,%edx
  801076:	b8 01 00 00 00       	mov    $0x1,%eax
  80107b:	89 d1                	mov    %edx,%ecx
  80107d:	89 d3                	mov    %edx,%ebx
  80107f:	89 d7                	mov    %edx,%edi
  801081:	89 d6                	mov    %edx,%esi
  801083:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801085:	5b                   	pop    %ebx
  801086:	5e                   	pop    %esi
  801087:	5f                   	pop    %edi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	57                   	push   %edi
  80108e:	56                   	push   %esi
  80108f:	53                   	push   %ebx
  801090:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801093:	b9 00 00 00 00       	mov    $0x0,%ecx
  801098:	b8 03 00 00 00       	mov    $0x3,%eax
  80109d:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a0:	89 cb                	mov    %ecx,%ebx
  8010a2:	89 cf                	mov    %ecx,%edi
  8010a4:	89 ce                	mov    %ecx,%esi
  8010a6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	7e 17                	jle    8010c3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	50                   	push   %eax
  8010b0:	6a 03                	push   $0x3
  8010b2:	68 3f 2f 80 00       	push   $0x802f3f
  8010b7:	6a 23                	push   $0x23
  8010b9:	68 5c 2f 80 00       	push   $0x802f5c
  8010be:	e8 c5 f5 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c6:	5b                   	pop    %ebx
  8010c7:	5e                   	pop    %esi
  8010c8:	5f                   	pop    %edi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	57                   	push   %edi
  8010cf:	56                   	push   %esi
  8010d0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d6:	b8 02 00 00 00       	mov    $0x2,%eax
  8010db:	89 d1                	mov    %edx,%ecx
  8010dd:	89 d3                	mov    %edx,%ebx
  8010df:	89 d7                	mov    %edx,%edi
  8010e1:	89 d6                	mov    %edx,%esi
  8010e3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <sys_yield>:

void
sys_yield(void)
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
  8010f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010fa:	89 d1                	mov    %edx,%ecx
  8010fc:	89 d3                	mov    %edx,%ebx
  8010fe:	89 d7                	mov    %edx,%edi
  801100:	89 d6                	mov    %edx,%esi
  801102:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	57                   	push   %edi
  80110d:	56                   	push   %esi
  80110e:	53                   	push   %ebx
  80110f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801112:	be 00 00 00 00       	mov    $0x0,%esi
  801117:	b8 04 00 00 00       	mov    $0x4,%eax
  80111c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111f:	8b 55 08             	mov    0x8(%ebp),%edx
  801122:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801125:	89 f7                	mov    %esi,%edi
  801127:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801129:	85 c0                	test   %eax,%eax
  80112b:	7e 17                	jle    801144 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80112d:	83 ec 0c             	sub    $0xc,%esp
  801130:	50                   	push   %eax
  801131:	6a 04                	push   $0x4
  801133:	68 3f 2f 80 00       	push   $0x802f3f
  801138:	6a 23                	push   $0x23
  80113a:	68 5c 2f 80 00       	push   $0x802f5c
  80113f:	e8 44 f5 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801144:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	57                   	push   %edi
  801150:	56                   	push   %esi
  801151:	53                   	push   %ebx
  801152:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801155:	b8 05 00 00 00       	mov    $0x5,%eax
  80115a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115d:	8b 55 08             	mov    0x8(%ebp),%edx
  801160:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801163:	8b 7d 14             	mov    0x14(%ebp),%edi
  801166:	8b 75 18             	mov    0x18(%ebp),%esi
  801169:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80116b:	85 c0                	test   %eax,%eax
  80116d:	7e 17                	jle    801186 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116f:	83 ec 0c             	sub    $0xc,%esp
  801172:	50                   	push   %eax
  801173:	6a 05                	push   $0x5
  801175:	68 3f 2f 80 00       	push   $0x802f3f
  80117a:	6a 23                	push   $0x23
  80117c:	68 5c 2f 80 00       	push   $0x802f5c
  801181:	e8 02 f5 ff ff       	call   800688 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801186:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5f                   	pop    %edi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  801197:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119c:	b8 06 00 00 00       	mov    $0x6,%eax
  8011a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a7:	89 df                	mov    %ebx,%edi
  8011a9:	89 de                	mov    %ebx,%esi
  8011ab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	7e 17                	jle    8011c8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011b1:	83 ec 0c             	sub    $0xc,%esp
  8011b4:	50                   	push   %eax
  8011b5:	6a 06                	push   $0x6
  8011b7:	68 3f 2f 80 00       	push   $0x802f3f
  8011bc:	6a 23                	push   $0x23
  8011be:	68 5c 2f 80 00       	push   $0x802f5c
  8011c3:	e8 c0 f4 ff ff       	call   800688 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5e                   	pop    %esi
  8011cd:	5f                   	pop    %edi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	57                   	push   %edi
  8011d4:	56                   	push   %esi
  8011d5:	53                   	push   %ebx
  8011d6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011de:	b8 08 00 00 00       	mov    $0x8,%eax
  8011e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e9:	89 df                	mov    %ebx,%edi
  8011eb:	89 de                	mov    %ebx,%esi
  8011ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	7e 17                	jle    80120a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f3:	83 ec 0c             	sub    $0xc,%esp
  8011f6:	50                   	push   %eax
  8011f7:	6a 08                	push   $0x8
  8011f9:	68 3f 2f 80 00       	push   $0x802f3f
  8011fe:	6a 23                	push   $0x23
  801200:	68 5c 2f 80 00       	push   $0x802f5c
  801205:	e8 7e f4 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80120a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120d:	5b                   	pop    %ebx
  80120e:	5e                   	pop    %esi
  80120f:	5f                   	pop    %edi
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    

00801212 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	57                   	push   %edi
  801216:	56                   	push   %esi
  801217:	53                   	push   %ebx
  801218:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80121b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801220:	b8 09 00 00 00       	mov    $0x9,%eax
  801225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801228:	8b 55 08             	mov    0x8(%ebp),%edx
  80122b:	89 df                	mov    %ebx,%edi
  80122d:	89 de                	mov    %ebx,%esi
  80122f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801231:	85 c0                	test   %eax,%eax
  801233:	7e 17                	jle    80124c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801235:	83 ec 0c             	sub    $0xc,%esp
  801238:	50                   	push   %eax
  801239:	6a 09                	push   $0x9
  80123b:	68 3f 2f 80 00       	push   $0x802f3f
  801240:	6a 23                	push   $0x23
  801242:	68 5c 2f 80 00       	push   $0x802f5c
  801247:	e8 3c f4 ff ff       	call   800688 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80124c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	5f                   	pop    %edi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	57                   	push   %edi
  801258:	56                   	push   %esi
  801259:	53                   	push   %ebx
  80125a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801262:	b8 0a 00 00 00       	mov    $0xa,%eax
  801267:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126a:	8b 55 08             	mov    0x8(%ebp),%edx
  80126d:	89 df                	mov    %ebx,%edi
  80126f:	89 de                	mov    %ebx,%esi
  801271:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801273:	85 c0                	test   %eax,%eax
  801275:	7e 17                	jle    80128e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801277:	83 ec 0c             	sub    $0xc,%esp
  80127a:	50                   	push   %eax
  80127b:	6a 0a                	push   $0xa
  80127d:	68 3f 2f 80 00       	push   $0x802f3f
  801282:	6a 23                	push   $0x23
  801284:	68 5c 2f 80 00       	push   $0x802f5c
  801289:	e8 fa f3 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80128e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801291:	5b                   	pop    %ebx
  801292:	5e                   	pop    %esi
  801293:	5f                   	pop    %edi
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    

00801296 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	57                   	push   %edi
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129c:	be 00 00 00 00       	mov    $0x0,%esi
  8012a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012b2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012b4:	5b                   	pop    %ebx
  8012b5:	5e                   	pop    %esi
  8012b6:	5f                   	pop    %edi
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    

008012b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	57                   	push   %edi
  8012bd:	56                   	push   %esi
  8012be:	53                   	push   %ebx
  8012bf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012c7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8012cf:	89 cb                	mov    %ecx,%ebx
  8012d1:	89 cf                	mov    %ecx,%edi
  8012d3:	89 ce                	mov    %ecx,%esi
  8012d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	7e 17                	jle    8012f2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012db:	83 ec 0c             	sub    $0xc,%esp
  8012de:	50                   	push   %eax
  8012df:	6a 0d                	push   $0xd
  8012e1:	68 3f 2f 80 00       	push   $0x802f3f
  8012e6:	6a 23                	push   $0x23
  8012e8:	68 5c 2f 80 00       	push   $0x802f5c
  8012ed:	e8 96 f3 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f5:	5b                   	pop    %ebx
  8012f6:	5e                   	pop    %esi
  8012f7:	5f                   	pop    %edi
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	57                   	push   %edi
  8012fe:	56                   	push   %esi
  8012ff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801300:	ba 00 00 00 00       	mov    $0x0,%edx
  801305:	b8 0e 00 00 00       	mov    $0xe,%eax
  80130a:	89 d1                	mov    %edx,%ecx
  80130c:	89 d3                	mov    %edx,%ebx
  80130e:	89 d7                	mov    %edx,%edi
  801310:	89 d6                	mov    %edx,%esi
  801312:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801314:	5b                   	pop    %ebx
  801315:	5e                   	pop    %esi
  801316:	5f                   	pop    %edi
  801317:	5d                   	pop    %ebp
  801318:	c3                   	ret    

00801319 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
  80131e:	8b 75 08             	mov    0x8(%ebp),%esi
  801321:	8b 45 0c             	mov    0xc(%ebp),%eax
  801324:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801327:	85 c0                	test   %eax,%eax
  801329:	74 0e                	je     801339 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  80132b:	83 ec 0c             	sub    $0xc,%esp
  80132e:	50                   	push   %eax
  80132f:	e8 85 ff ff ff       	call   8012b9 <sys_ipc_recv>
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	eb 10                	jmp    801349 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	68 00 00 c0 ee       	push   $0xeec00000
  801341:	e8 73 ff ff ff       	call   8012b9 <sys_ipc_recv>
  801346:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801349:	85 c0                	test   %eax,%eax
  80134b:	79 17                	jns    801364 <ipc_recv+0x4b>
		if(*from_env_store)
  80134d:	83 3e 00             	cmpl   $0x0,(%esi)
  801350:	74 06                	je     801358 <ipc_recv+0x3f>
			*from_env_store = 0;
  801352:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801358:	85 db                	test   %ebx,%ebx
  80135a:	74 2c                	je     801388 <ipc_recv+0x6f>
			*perm_store = 0;
  80135c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801362:	eb 24                	jmp    801388 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801364:	85 f6                	test   %esi,%esi
  801366:	74 0a                	je     801372 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801368:	a1 08 50 80 00       	mov    0x805008,%eax
  80136d:	8b 40 74             	mov    0x74(%eax),%eax
  801370:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801372:	85 db                	test   %ebx,%ebx
  801374:	74 0a                	je     801380 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801376:	a1 08 50 80 00       	mov    0x805008,%eax
  80137b:	8b 40 78             	mov    0x78(%eax),%eax
  80137e:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801380:	a1 08 50 80 00       	mov    0x805008,%eax
  801385:	8b 40 70             	mov    0x70(%eax),%eax
}
  801388:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	57                   	push   %edi
  801393:	56                   	push   %esi
  801394:	53                   	push   %ebx
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80139e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8013a1:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  8013a3:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  8013a8:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  8013ab:	e8 3a fd ff ff       	call   8010ea <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  8013b0:	ff 75 14             	pushl  0x14(%ebp)
  8013b3:	53                   	push   %ebx
  8013b4:	56                   	push   %esi
  8013b5:	57                   	push   %edi
  8013b6:	e8 db fe ff ff       	call   801296 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  8013bb:	89 c2                	mov    %eax,%edx
  8013bd:	f7 d2                	not    %edx
  8013bf:	c1 ea 1f             	shr    $0x1f,%edx
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013c8:	0f 94 c1             	sete   %cl
  8013cb:	09 ca                	or     %ecx,%edx
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	0f 94 c0             	sete   %al
  8013d2:	38 c2                	cmp    %al,%dl
  8013d4:	77 d5                	ja     8013ab <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013e4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013e9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013ec:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013f2:	8b 52 50             	mov    0x50(%edx),%edx
  8013f5:	39 ca                	cmp    %ecx,%edx
  8013f7:	75 0d                	jne    801406 <ipc_find_env+0x28>
			return envs[i].env_id;
  8013f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801401:	8b 40 48             	mov    0x48(%eax),%eax
  801404:	eb 0f                	jmp    801415 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801406:	83 c0 01             	add    $0x1,%eax
  801409:	3d 00 04 00 00       	cmp    $0x400,%eax
  80140e:	75 d9                	jne    8013e9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801410:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80141a:	8b 45 08             	mov    0x8(%ebp),%eax
  80141d:	05 00 00 00 30       	add    $0x30000000,%eax
  801422:	c1 e8 0c             	shr    $0xc,%eax
}
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80142a:	8b 45 08             	mov    0x8(%ebp),%eax
  80142d:	05 00 00 00 30       	add    $0x30000000,%eax
  801432:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801437:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    

0080143e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801444:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801449:	89 c2                	mov    %eax,%edx
  80144b:	c1 ea 16             	shr    $0x16,%edx
  80144e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801455:	f6 c2 01             	test   $0x1,%dl
  801458:	74 11                	je     80146b <fd_alloc+0x2d>
  80145a:	89 c2                	mov    %eax,%edx
  80145c:	c1 ea 0c             	shr    $0xc,%edx
  80145f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801466:	f6 c2 01             	test   $0x1,%dl
  801469:	75 09                	jne    801474 <fd_alloc+0x36>
			*fd_store = fd;
  80146b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80146d:	b8 00 00 00 00       	mov    $0x0,%eax
  801472:	eb 17                	jmp    80148b <fd_alloc+0x4d>
  801474:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801479:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80147e:	75 c9                	jne    801449 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801480:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801486:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    

0080148d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801493:	83 f8 1f             	cmp    $0x1f,%eax
  801496:	77 36                	ja     8014ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801498:	c1 e0 0c             	shl    $0xc,%eax
  80149b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014a0:	89 c2                	mov    %eax,%edx
  8014a2:	c1 ea 16             	shr    $0x16,%edx
  8014a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014ac:	f6 c2 01             	test   $0x1,%dl
  8014af:	74 24                	je     8014d5 <fd_lookup+0x48>
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	c1 ea 0c             	shr    $0xc,%edx
  8014b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014bd:	f6 c2 01             	test   $0x1,%dl
  8014c0:	74 1a                	je     8014dc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014c5:	89 02                	mov    %eax,(%edx)
	return 0;
  8014c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014cc:	eb 13                	jmp    8014e1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d3:	eb 0c                	jmp    8014e1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014da:	eb 05                	jmp    8014e1 <fd_lookup+0x54>
  8014dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    

008014e3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ec:	ba ec 2f 80 00       	mov    $0x802fec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014f1:	eb 13                	jmp    801506 <dev_lookup+0x23>
  8014f3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014f6:	39 08                	cmp    %ecx,(%eax)
  8014f8:	75 0c                	jne    801506 <dev_lookup+0x23>
			*dev = devtab[i];
  8014fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014fd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801504:	eb 2e                	jmp    801534 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801506:	8b 02                	mov    (%edx),%eax
  801508:	85 c0                	test   %eax,%eax
  80150a:	75 e7                	jne    8014f3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80150c:	a1 08 50 80 00       	mov    0x805008,%eax
  801511:	8b 40 48             	mov    0x48(%eax),%eax
  801514:	83 ec 04             	sub    $0x4,%esp
  801517:	51                   	push   %ecx
  801518:	50                   	push   %eax
  801519:	68 6c 2f 80 00       	push   $0x802f6c
  80151e:	e8 3e f2 ff ff       	call   800761 <cprintf>
	*dev = 0;
  801523:	8b 45 0c             	mov    0xc(%ebp),%eax
  801526:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801534:	c9                   	leave  
  801535:	c3                   	ret    

00801536 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	56                   	push   %esi
  80153a:	53                   	push   %ebx
  80153b:	83 ec 10             	sub    $0x10,%esp
  80153e:	8b 75 08             	mov    0x8(%ebp),%esi
  801541:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801544:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801547:	50                   	push   %eax
  801548:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80154e:	c1 e8 0c             	shr    $0xc,%eax
  801551:	50                   	push   %eax
  801552:	e8 36 ff ff ff       	call   80148d <fd_lookup>
  801557:	83 c4 08             	add    $0x8,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 05                	js     801563 <fd_close+0x2d>
	    || fd != fd2)
  80155e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801561:	74 0c                	je     80156f <fd_close+0x39>
		return (must_exist ? r : 0);
  801563:	84 db                	test   %bl,%bl
  801565:	ba 00 00 00 00       	mov    $0x0,%edx
  80156a:	0f 44 c2             	cmove  %edx,%eax
  80156d:	eb 41                	jmp    8015b0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	ff 36                	pushl  (%esi)
  801578:	e8 66 ff ff ff       	call   8014e3 <dev_lookup>
  80157d:	89 c3                	mov    %eax,%ebx
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 1a                	js     8015a0 <fd_close+0x6a>
		if (dev->dev_close)
  801586:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801589:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80158c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801591:	85 c0                	test   %eax,%eax
  801593:	74 0b                	je     8015a0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801595:	83 ec 0c             	sub    $0xc,%esp
  801598:	56                   	push   %esi
  801599:	ff d0                	call   *%eax
  80159b:	89 c3                	mov    %eax,%ebx
  80159d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	56                   	push   %esi
  8015a4:	6a 00                	push   $0x0
  8015a6:	e8 e3 fb ff ff       	call   80118e <sys_page_unmap>
	return r;
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	89 d8                	mov    %ebx,%eax
}
  8015b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b3:	5b                   	pop    %ebx
  8015b4:	5e                   	pop    %esi
  8015b5:	5d                   	pop    %ebp
  8015b6:	c3                   	ret    

008015b7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	ff 75 08             	pushl  0x8(%ebp)
  8015c4:	e8 c4 fe ff ff       	call   80148d <fd_lookup>
  8015c9:	83 c4 08             	add    $0x8,%esp
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 10                	js     8015e0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	6a 01                	push   $0x1
  8015d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d8:	e8 59 ff ff ff       	call   801536 <fd_close>
  8015dd:	83 c4 10             	add    $0x10,%esp
}
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <close_all>:

void
close_all(void)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015e9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	53                   	push   %ebx
  8015f2:	e8 c0 ff ff ff       	call   8015b7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f7:	83 c3 01             	add    $0x1,%ebx
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	83 fb 20             	cmp    $0x20,%ebx
  801600:	75 ec                	jne    8015ee <close_all+0xc>
		close(i);
}
  801602:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	57                   	push   %edi
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	83 ec 2c             	sub    $0x2c,%esp
  801610:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801613:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801616:	50                   	push   %eax
  801617:	ff 75 08             	pushl  0x8(%ebp)
  80161a:	e8 6e fe ff ff       	call   80148d <fd_lookup>
  80161f:	83 c4 08             	add    $0x8,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	0f 88 c1 00 00 00    	js     8016eb <dup+0xe4>
		return r;
	close(newfdnum);
  80162a:	83 ec 0c             	sub    $0xc,%esp
  80162d:	56                   	push   %esi
  80162e:	e8 84 ff ff ff       	call   8015b7 <close>

	newfd = INDEX2FD(newfdnum);
  801633:	89 f3                	mov    %esi,%ebx
  801635:	c1 e3 0c             	shl    $0xc,%ebx
  801638:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80163e:	83 c4 04             	add    $0x4,%esp
  801641:	ff 75 e4             	pushl  -0x1c(%ebp)
  801644:	e8 de fd ff ff       	call   801427 <fd2data>
  801649:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80164b:	89 1c 24             	mov    %ebx,(%esp)
  80164e:	e8 d4 fd ff ff       	call   801427 <fd2data>
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801659:	89 f8                	mov    %edi,%eax
  80165b:	c1 e8 16             	shr    $0x16,%eax
  80165e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801665:	a8 01                	test   $0x1,%al
  801667:	74 37                	je     8016a0 <dup+0x99>
  801669:	89 f8                	mov    %edi,%eax
  80166b:	c1 e8 0c             	shr    $0xc,%eax
  80166e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801675:	f6 c2 01             	test   $0x1,%dl
  801678:	74 26                	je     8016a0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80167a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801681:	83 ec 0c             	sub    $0xc,%esp
  801684:	25 07 0e 00 00       	and    $0xe07,%eax
  801689:	50                   	push   %eax
  80168a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80168d:	6a 00                	push   $0x0
  80168f:	57                   	push   %edi
  801690:	6a 00                	push   $0x0
  801692:	e8 b5 fa ff ff       	call   80114c <sys_page_map>
  801697:	89 c7                	mov    %eax,%edi
  801699:	83 c4 20             	add    $0x20,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 2e                	js     8016ce <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016a3:	89 d0                	mov    %edx,%eax
  8016a5:	c1 e8 0c             	shr    $0xc,%eax
  8016a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016af:	83 ec 0c             	sub    $0xc,%esp
  8016b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8016b7:	50                   	push   %eax
  8016b8:	53                   	push   %ebx
  8016b9:	6a 00                	push   $0x0
  8016bb:	52                   	push   %edx
  8016bc:	6a 00                	push   $0x0
  8016be:	e8 89 fa ff ff       	call   80114c <sys_page_map>
  8016c3:	89 c7                	mov    %eax,%edi
  8016c5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016c8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016ca:	85 ff                	test   %edi,%edi
  8016cc:	79 1d                	jns    8016eb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	53                   	push   %ebx
  8016d2:	6a 00                	push   $0x0
  8016d4:	e8 b5 fa ff ff       	call   80118e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016d9:	83 c4 08             	add    $0x8,%esp
  8016dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016df:	6a 00                	push   $0x0
  8016e1:	e8 a8 fa ff ff       	call   80118e <sys_page_unmap>
	return r;
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	89 f8                	mov    %edi,%eax
}
  8016eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ee:	5b                   	pop    %ebx
  8016ef:	5e                   	pop    %esi
  8016f0:	5f                   	pop    %edi
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	53                   	push   %ebx
  8016f7:	83 ec 14             	sub    $0x14,%esp
  8016fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801700:	50                   	push   %eax
  801701:	53                   	push   %ebx
  801702:	e8 86 fd ff ff       	call   80148d <fd_lookup>
  801707:	83 c4 08             	add    $0x8,%esp
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 6d                	js     80177d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801716:	50                   	push   %eax
  801717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171a:	ff 30                	pushl  (%eax)
  80171c:	e8 c2 fd ff ff       	call   8014e3 <dev_lookup>
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	78 4c                	js     801774 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801728:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80172b:	8b 42 08             	mov    0x8(%edx),%eax
  80172e:	83 e0 03             	and    $0x3,%eax
  801731:	83 f8 01             	cmp    $0x1,%eax
  801734:	75 21                	jne    801757 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801736:	a1 08 50 80 00       	mov    0x805008,%eax
  80173b:	8b 40 48             	mov    0x48(%eax),%eax
  80173e:	83 ec 04             	sub    $0x4,%esp
  801741:	53                   	push   %ebx
  801742:	50                   	push   %eax
  801743:	68 b0 2f 80 00       	push   $0x802fb0
  801748:	e8 14 f0 ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801755:	eb 26                	jmp    80177d <read+0x8a>
	}
	if (!dev->dev_read)
  801757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175a:	8b 40 08             	mov    0x8(%eax),%eax
  80175d:	85 c0                	test   %eax,%eax
  80175f:	74 17                	je     801778 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801761:	83 ec 04             	sub    $0x4,%esp
  801764:	ff 75 10             	pushl  0x10(%ebp)
  801767:	ff 75 0c             	pushl  0xc(%ebp)
  80176a:	52                   	push   %edx
  80176b:	ff d0                	call   *%eax
  80176d:	89 c2                	mov    %eax,%edx
  80176f:	83 c4 10             	add    $0x10,%esp
  801772:	eb 09                	jmp    80177d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801774:	89 c2                	mov    %eax,%edx
  801776:	eb 05                	jmp    80177d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801778:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80177d:	89 d0                	mov    %edx,%eax
  80177f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	57                   	push   %edi
  801788:	56                   	push   %esi
  801789:	53                   	push   %ebx
  80178a:	83 ec 0c             	sub    $0xc,%esp
  80178d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801790:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801793:	bb 00 00 00 00       	mov    $0x0,%ebx
  801798:	eb 21                	jmp    8017bb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	89 f0                	mov    %esi,%eax
  80179f:	29 d8                	sub    %ebx,%eax
  8017a1:	50                   	push   %eax
  8017a2:	89 d8                	mov    %ebx,%eax
  8017a4:	03 45 0c             	add    0xc(%ebp),%eax
  8017a7:	50                   	push   %eax
  8017a8:	57                   	push   %edi
  8017a9:	e8 45 ff ff ff       	call   8016f3 <read>
		if (m < 0)
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 10                	js     8017c5 <readn+0x41>
			return m;
		if (m == 0)
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	74 0a                	je     8017c3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b9:	01 c3                	add    %eax,%ebx
  8017bb:	39 f3                	cmp    %esi,%ebx
  8017bd:	72 db                	jb     80179a <readn+0x16>
  8017bf:	89 d8                	mov    %ebx,%eax
  8017c1:	eb 02                	jmp    8017c5 <readn+0x41>
  8017c3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	5f                   	pop    %edi
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	53                   	push   %ebx
  8017d1:	83 ec 14             	sub    $0x14,%esp
  8017d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017da:	50                   	push   %eax
  8017db:	53                   	push   %ebx
  8017dc:	e8 ac fc ff ff       	call   80148d <fd_lookup>
  8017e1:	83 c4 08             	add    $0x8,%esp
  8017e4:	89 c2                	mov    %eax,%edx
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 68                	js     801852 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ea:	83 ec 08             	sub    $0x8,%esp
  8017ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f0:	50                   	push   %eax
  8017f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f4:	ff 30                	pushl  (%eax)
  8017f6:	e8 e8 fc ff ff       	call   8014e3 <dev_lookup>
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 47                	js     801849 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801805:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801809:	75 21                	jne    80182c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80180b:	a1 08 50 80 00       	mov    0x805008,%eax
  801810:	8b 40 48             	mov    0x48(%eax),%eax
  801813:	83 ec 04             	sub    $0x4,%esp
  801816:	53                   	push   %ebx
  801817:	50                   	push   %eax
  801818:	68 cc 2f 80 00       	push   $0x802fcc
  80181d:	e8 3f ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80182a:	eb 26                	jmp    801852 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80182c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182f:	8b 52 0c             	mov    0xc(%edx),%edx
  801832:	85 d2                	test   %edx,%edx
  801834:	74 17                	je     80184d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801836:	83 ec 04             	sub    $0x4,%esp
  801839:	ff 75 10             	pushl  0x10(%ebp)
  80183c:	ff 75 0c             	pushl  0xc(%ebp)
  80183f:	50                   	push   %eax
  801840:	ff d2                	call   *%edx
  801842:	89 c2                	mov    %eax,%edx
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	eb 09                	jmp    801852 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801849:	89 c2                	mov    %eax,%edx
  80184b:	eb 05                	jmp    801852 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80184d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801852:	89 d0                	mov    %edx,%eax
  801854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <seek>:

int
seek(int fdnum, off_t offset)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80185f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801862:	50                   	push   %eax
  801863:	ff 75 08             	pushl  0x8(%ebp)
  801866:	e8 22 fc ff ff       	call   80148d <fd_lookup>
  80186b:	83 c4 08             	add    $0x8,%esp
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 0e                	js     801880 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801872:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801875:	8b 55 0c             	mov    0xc(%ebp),%edx
  801878:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80187b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	53                   	push   %ebx
  801886:	83 ec 14             	sub    $0x14,%esp
  801889:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188f:	50                   	push   %eax
  801890:	53                   	push   %ebx
  801891:	e8 f7 fb ff ff       	call   80148d <fd_lookup>
  801896:	83 c4 08             	add    $0x8,%esp
  801899:	89 c2                	mov    %eax,%edx
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 65                	js     801904 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189f:	83 ec 08             	sub    $0x8,%esp
  8018a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a5:	50                   	push   %eax
  8018a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a9:	ff 30                	pushl  (%eax)
  8018ab:	e8 33 fc ff ff       	call   8014e3 <dev_lookup>
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 44                	js     8018fb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018be:	75 21                	jne    8018e1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018c0:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018c5:	8b 40 48             	mov    0x48(%eax),%eax
  8018c8:	83 ec 04             	sub    $0x4,%esp
  8018cb:	53                   	push   %ebx
  8018cc:	50                   	push   %eax
  8018cd:	68 8c 2f 80 00       	push   $0x802f8c
  8018d2:	e8 8a ee ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018df:	eb 23                	jmp    801904 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e4:	8b 52 18             	mov    0x18(%edx),%edx
  8018e7:	85 d2                	test   %edx,%edx
  8018e9:	74 14                	je     8018ff <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018eb:	83 ec 08             	sub    $0x8,%esp
  8018ee:	ff 75 0c             	pushl  0xc(%ebp)
  8018f1:	50                   	push   %eax
  8018f2:	ff d2                	call   *%edx
  8018f4:	89 c2                	mov    %eax,%edx
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	eb 09                	jmp    801904 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fb:	89 c2                	mov    %eax,%edx
  8018fd:	eb 05                	jmp    801904 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801904:	89 d0                	mov    %edx,%eax
  801906:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	53                   	push   %ebx
  80190f:	83 ec 14             	sub    $0x14,%esp
  801912:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801915:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801918:	50                   	push   %eax
  801919:	ff 75 08             	pushl  0x8(%ebp)
  80191c:	e8 6c fb ff ff       	call   80148d <fd_lookup>
  801921:	83 c4 08             	add    $0x8,%esp
  801924:	89 c2                	mov    %eax,%edx
  801926:	85 c0                	test   %eax,%eax
  801928:	78 58                	js     801982 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801930:	50                   	push   %eax
  801931:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801934:	ff 30                	pushl  (%eax)
  801936:	e8 a8 fb ff ff       	call   8014e3 <dev_lookup>
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	85 c0                	test   %eax,%eax
  801940:	78 37                	js     801979 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801942:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801945:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801949:	74 32                	je     80197d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80194b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80194e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801955:	00 00 00 
	stat->st_isdir = 0;
  801958:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80195f:	00 00 00 
	stat->st_dev = dev;
  801962:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801968:	83 ec 08             	sub    $0x8,%esp
  80196b:	53                   	push   %ebx
  80196c:	ff 75 f0             	pushl  -0x10(%ebp)
  80196f:	ff 50 14             	call   *0x14(%eax)
  801972:	89 c2                	mov    %eax,%edx
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	eb 09                	jmp    801982 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801979:	89 c2                	mov    %eax,%edx
  80197b:	eb 05                	jmp    801982 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80197d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801982:	89 d0                	mov    %edx,%eax
  801984:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801987:	c9                   	leave  
  801988:	c3                   	ret    

00801989 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	56                   	push   %esi
  80198d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80198e:	83 ec 08             	sub    $0x8,%esp
  801991:	6a 00                	push   $0x0
  801993:	ff 75 08             	pushl  0x8(%ebp)
  801996:	e8 ef 01 00 00       	call   801b8a <open>
  80199b:	89 c3                	mov    %eax,%ebx
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	78 1b                	js     8019bf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	ff 75 0c             	pushl  0xc(%ebp)
  8019aa:	50                   	push   %eax
  8019ab:	e8 5b ff ff ff       	call   80190b <fstat>
  8019b0:	89 c6                	mov    %eax,%esi
	close(fd);
  8019b2:	89 1c 24             	mov    %ebx,(%esp)
  8019b5:	e8 fd fb ff ff       	call   8015b7 <close>
	return r;
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	89 f0                	mov    %esi,%eax
}
  8019bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c2:	5b                   	pop    %ebx
  8019c3:	5e                   	pop    %esi
  8019c4:	5d                   	pop    %ebp
  8019c5:	c3                   	ret    

008019c6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	89 c6                	mov    %eax,%esi
  8019cd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019cf:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019d6:	75 12                	jne    8019ea <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	6a 01                	push   $0x1
  8019dd:	e8 fc f9 ff ff       	call   8013de <ipc_find_env>
  8019e2:	a3 00 50 80 00       	mov    %eax,0x805000
  8019e7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019ea:	6a 07                	push   $0x7
  8019ec:	68 00 60 80 00       	push   $0x806000
  8019f1:	56                   	push   %esi
  8019f2:	ff 35 00 50 80 00    	pushl  0x805000
  8019f8:	e8 92 f9 ff ff       	call   80138f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019fd:	83 c4 0c             	add    $0xc,%esp
  801a00:	6a 00                	push   $0x0
  801a02:	53                   	push   %ebx
  801a03:	6a 00                	push   $0x0
  801a05:	e8 0f f9 ff ff       	call   801319 <ipc_recv>
}
  801a0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5e                   	pop    %esi
  801a0f:	5d                   	pop    %ebp
  801a10:	c3                   	ret    

00801a11 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a17:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a25:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2f:	b8 02 00 00 00       	mov    $0x2,%eax
  801a34:	e8 8d ff ff ff       	call   8019c6 <fsipc>
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a41:	8b 45 08             	mov    0x8(%ebp),%eax
  801a44:	8b 40 0c             	mov    0xc(%eax),%eax
  801a47:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a51:	b8 06 00 00 00       	mov    $0x6,%eax
  801a56:	e8 6b ff ff ff       	call   8019c6 <fsipc>
}
  801a5b:	c9                   	leave  
  801a5c:	c3                   	ret    

00801a5d <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	53                   	push   %ebx
  801a61:	83 ec 04             	sub    $0x4,%esp
  801a64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a67:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a72:	ba 00 00 00 00       	mov    $0x0,%edx
  801a77:	b8 05 00 00 00       	mov    $0x5,%eax
  801a7c:	e8 45 ff ff ff       	call   8019c6 <fsipc>
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 2c                	js     801ab1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a85:	83 ec 08             	sub    $0x8,%esp
  801a88:	68 00 60 80 00       	push   $0x806000
  801a8d:	53                   	push   %ebx
  801a8e:	e8 73 f2 ff ff       	call   800d06 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a93:	a1 80 60 80 00       	mov    0x806080,%eax
  801a98:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a9e:	a1 84 60 80 00       	mov    0x806084,%eax
  801aa3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	53                   	push   %ebx
  801aba:	83 ec 08             	sub    $0x8,%esp
  801abd:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ac0:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac3:	8b 52 0c             	mov    0xc(%edx),%edx
  801ac6:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801acc:	a3 04 60 80 00       	mov    %eax,0x806004
  801ad1:	3d 08 60 80 00       	cmp    $0x806008,%eax
  801ad6:	bb 08 60 80 00       	mov    $0x806008,%ebx
  801adb:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ade:	53                   	push   %ebx
  801adf:	ff 75 0c             	pushl  0xc(%ebp)
  801ae2:	68 08 60 80 00       	push   $0x806008
  801ae7:	e8 ac f3 ff ff       	call   800e98 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801aec:	ba 00 00 00 00       	mov    $0x0,%edx
  801af1:	b8 04 00 00 00       	mov    $0x4,%eax
  801af6:	e8 cb fe ff ff       	call   8019c6 <fsipc>
  801afb:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801afe:	85 c0                	test   %eax,%eax
  801b00:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801b03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b06:	c9                   	leave  
  801b07:	c3                   	ret    

00801b08 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b10:	8b 45 08             	mov    0x8(%ebp),%eax
  801b13:	8b 40 0c             	mov    0xc(%eax),%eax
  801b16:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b1b:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b21:	ba 00 00 00 00       	mov    $0x0,%edx
  801b26:	b8 03 00 00 00       	mov    $0x3,%eax
  801b2b:	e8 96 fe ff ff       	call   8019c6 <fsipc>
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	85 c0                	test   %eax,%eax
  801b34:	78 4b                	js     801b81 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b36:	39 c6                	cmp    %eax,%esi
  801b38:	73 16                	jae    801b50 <devfile_read+0x48>
  801b3a:	68 00 30 80 00       	push   $0x803000
  801b3f:	68 07 30 80 00       	push   $0x803007
  801b44:	6a 7c                	push   $0x7c
  801b46:	68 1c 30 80 00       	push   $0x80301c
  801b4b:	e8 38 eb ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801b50:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b55:	7e 16                	jle    801b6d <devfile_read+0x65>
  801b57:	68 27 30 80 00       	push   $0x803027
  801b5c:	68 07 30 80 00       	push   $0x803007
  801b61:	6a 7d                	push   $0x7d
  801b63:	68 1c 30 80 00       	push   $0x80301c
  801b68:	e8 1b eb ff ff       	call   800688 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b6d:	83 ec 04             	sub    $0x4,%esp
  801b70:	50                   	push   %eax
  801b71:	68 00 60 80 00       	push   $0x806000
  801b76:	ff 75 0c             	pushl  0xc(%ebp)
  801b79:	e8 1a f3 ff ff       	call   800e98 <memmove>
	return r;
  801b7e:	83 c4 10             	add    $0x10,%esp
}
  801b81:	89 d8                	mov    %ebx,%eax
  801b83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b86:	5b                   	pop    %ebx
  801b87:	5e                   	pop    %esi
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    

00801b8a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 20             	sub    $0x20,%esp
  801b91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b94:	53                   	push   %ebx
  801b95:	e8 33 f1 ff ff       	call   800ccd <strlen>
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ba2:	7f 67                	jg     801c0b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ba4:	83 ec 0c             	sub    $0xc,%esp
  801ba7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801baa:	50                   	push   %eax
  801bab:	e8 8e f8 ff ff       	call   80143e <fd_alloc>
  801bb0:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	78 57                	js     801c10 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bb9:	83 ec 08             	sub    $0x8,%esp
  801bbc:	53                   	push   %ebx
  801bbd:	68 00 60 80 00       	push   $0x806000
  801bc2:	e8 3f f1 ff ff       	call   800d06 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bca:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bcf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd7:	e8 ea fd ff ff       	call   8019c6 <fsipc>
  801bdc:	89 c3                	mov    %eax,%ebx
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	85 c0                	test   %eax,%eax
  801be3:	79 14                	jns    801bf9 <open+0x6f>
		fd_close(fd, 0);
  801be5:	83 ec 08             	sub    $0x8,%esp
  801be8:	6a 00                	push   $0x0
  801bea:	ff 75 f4             	pushl  -0xc(%ebp)
  801bed:	e8 44 f9 ff ff       	call   801536 <fd_close>
		return r;
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	89 da                	mov    %ebx,%edx
  801bf7:	eb 17                	jmp    801c10 <open+0x86>
	}

	return fd2num(fd);
  801bf9:	83 ec 0c             	sub    $0xc,%esp
  801bfc:	ff 75 f4             	pushl  -0xc(%ebp)
  801bff:	e8 13 f8 ff ff       	call   801417 <fd2num>
  801c04:	89 c2                	mov    %eax,%edx
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	eb 05                	jmp    801c10 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c0b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c10:	89 d0                	mov    %edx,%eax
  801c12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c15:	c9                   	leave  
  801c16:	c3                   	ret    

00801c17 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c22:	b8 08 00 00 00       	mov    $0x8,%eax
  801c27:	e8 9a fd ff ff       	call   8019c6 <fsipc>
}
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    

00801c2e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	56                   	push   %esi
  801c32:	53                   	push   %ebx
  801c33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c36:	83 ec 0c             	sub    $0xc,%esp
  801c39:	ff 75 08             	pushl  0x8(%ebp)
  801c3c:	e8 e6 f7 ff ff       	call   801427 <fd2data>
  801c41:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c43:	83 c4 08             	add    $0x8,%esp
  801c46:	68 33 30 80 00       	push   $0x803033
  801c4b:	53                   	push   %ebx
  801c4c:	e8 b5 f0 ff ff       	call   800d06 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c51:	8b 46 04             	mov    0x4(%esi),%eax
  801c54:	2b 06                	sub    (%esi),%eax
  801c56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c5c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c63:	00 00 00 
	stat->st_dev = &devpipe;
  801c66:	c7 83 88 00 00 00 24 	movl   $0x804024,0x88(%ebx)
  801c6d:	40 80 00 
	return 0;
}
  801c70:	b8 00 00 00 00       	mov    $0x0,%eax
  801c75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c78:	5b                   	pop    %ebx
  801c79:	5e                   	pop    %esi
  801c7a:	5d                   	pop    %ebp
  801c7b:	c3                   	ret    

00801c7c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	53                   	push   %ebx
  801c80:	83 ec 0c             	sub    $0xc,%esp
  801c83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c86:	53                   	push   %ebx
  801c87:	6a 00                	push   $0x0
  801c89:	e8 00 f5 ff ff       	call   80118e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c8e:	89 1c 24             	mov    %ebx,(%esp)
  801c91:	e8 91 f7 ff ff       	call   801427 <fd2data>
  801c96:	83 c4 08             	add    $0x8,%esp
  801c99:	50                   	push   %eax
  801c9a:	6a 00                	push   $0x0
  801c9c:	e8 ed f4 ff ff       	call   80118e <sys_page_unmap>
}
  801ca1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	57                   	push   %edi
  801caa:	56                   	push   %esi
  801cab:	53                   	push   %ebx
  801cac:	83 ec 1c             	sub    $0x1c,%esp
  801caf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cb2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cb4:	a1 08 50 80 00       	mov    0x805008,%eax
  801cb9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	ff 75 e0             	pushl  -0x20(%ebp)
  801cc2:	e8 ad 08 00 00       	call   802574 <pageref>
  801cc7:	89 c3                	mov    %eax,%ebx
  801cc9:	89 3c 24             	mov    %edi,(%esp)
  801ccc:	e8 a3 08 00 00       	call   802574 <pageref>
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	39 c3                	cmp    %eax,%ebx
  801cd6:	0f 94 c1             	sete   %cl
  801cd9:	0f b6 c9             	movzbl %cl,%ecx
  801cdc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cdf:	8b 15 08 50 80 00    	mov    0x805008,%edx
  801ce5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ce8:	39 ce                	cmp    %ecx,%esi
  801cea:	74 1b                	je     801d07 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801cec:	39 c3                	cmp    %eax,%ebx
  801cee:	75 c4                	jne    801cb4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cf0:	8b 42 58             	mov    0x58(%edx),%eax
  801cf3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cf6:	50                   	push   %eax
  801cf7:	56                   	push   %esi
  801cf8:	68 3a 30 80 00       	push   $0x80303a
  801cfd:	e8 5f ea ff ff       	call   800761 <cprintf>
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	eb ad                	jmp    801cb4 <_pipeisclosed+0xe>
	}
}
  801d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	57                   	push   %edi
  801d16:	56                   	push   %esi
  801d17:	53                   	push   %ebx
  801d18:	83 ec 28             	sub    $0x28,%esp
  801d1b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d1e:	56                   	push   %esi
  801d1f:	e8 03 f7 ff ff       	call   801427 <fd2data>
  801d24:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	bf 00 00 00 00       	mov    $0x0,%edi
  801d2e:	eb 4b                	jmp    801d7b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d30:	89 da                	mov    %ebx,%edx
  801d32:	89 f0                	mov    %esi,%eax
  801d34:	e8 6d ff ff ff       	call   801ca6 <_pipeisclosed>
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	75 48                	jne    801d85 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d3d:	e8 a8 f3 ff ff       	call   8010ea <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d42:	8b 43 04             	mov    0x4(%ebx),%eax
  801d45:	8b 0b                	mov    (%ebx),%ecx
  801d47:	8d 51 20             	lea    0x20(%ecx),%edx
  801d4a:	39 d0                	cmp    %edx,%eax
  801d4c:	73 e2                	jae    801d30 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d51:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d55:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d58:	89 c2                	mov    %eax,%edx
  801d5a:	c1 fa 1f             	sar    $0x1f,%edx
  801d5d:	89 d1                	mov    %edx,%ecx
  801d5f:	c1 e9 1b             	shr    $0x1b,%ecx
  801d62:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d65:	83 e2 1f             	and    $0x1f,%edx
  801d68:	29 ca                	sub    %ecx,%edx
  801d6a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d6e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d72:	83 c0 01             	add    $0x1,%eax
  801d75:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d78:	83 c7 01             	add    $0x1,%edi
  801d7b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d7e:	75 c2                	jne    801d42 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d80:	8b 45 10             	mov    0x10(%ebp),%eax
  801d83:	eb 05                	jmp    801d8a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d85:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5f                   	pop    %edi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    

00801d92 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	57                   	push   %edi
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 18             	sub    $0x18,%esp
  801d9b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d9e:	57                   	push   %edi
  801d9f:	e8 83 f6 ff ff       	call   801427 <fd2data>
  801da4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dae:	eb 3d                	jmp    801ded <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801db0:	85 db                	test   %ebx,%ebx
  801db2:	74 04                	je     801db8 <devpipe_read+0x26>
				return i;
  801db4:	89 d8                	mov    %ebx,%eax
  801db6:	eb 44                	jmp    801dfc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801db8:	89 f2                	mov    %esi,%edx
  801dba:	89 f8                	mov    %edi,%eax
  801dbc:	e8 e5 fe ff ff       	call   801ca6 <_pipeisclosed>
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	75 32                	jne    801df7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dc5:	e8 20 f3 ff ff       	call   8010ea <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dca:	8b 06                	mov    (%esi),%eax
  801dcc:	3b 46 04             	cmp    0x4(%esi),%eax
  801dcf:	74 df                	je     801db0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dd1:	99                   	cltd   
  801dd2:	c1 ea 1b             	shr    $0x1b,%edx
  801dd5:	01 d0                	add    %edx,%eax
  801dd7:	83 e0 1f             	and    $0x1f,%eax
  801dda:	29 d0                	sub    %edx,%eax
  801ddc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801de4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801de7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dea:	83 c3 01             	add    $0x1,%ebx
  801ded:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801df0:	75 d8                	jne    801dca <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801df2:	8b 45 10             	mov    0x10(%ebp),%eax
  801df5:	eb 05                	jmp    801dfc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801df7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dff:	5b                   	pop    %ebx
  801e00:	5e                   	pop    %esi
  801e01:	5f                   	pop    %edi
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	56                   	push   %esi
  801e08:	53                   	push   %ebx
  801e09:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0f:	50                   	push   %eax
  801e10:	e8 29 f6 ff ff       	call   80143e <fd_alloc>
  801e15:	83 c4 10             	add    $0x10,%esp
  801e18:	89 c2                	mov    %eax,%edx
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	0f 88 2c 01 00 00    	js     801f4e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e22:	83 ec 04             	sub    $0x4,%esp
  801e25:	68 07 04 00 00       	push   $0x407
  801e2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2d:	6a 00                	push   $0x0
  801e2f:	e8 d5 f2 ff ff       	call   801109 <sys_page_alloc>
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	89 c2                	mov    %eax,%edx
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	0f 88 0d 01 00 00    	js     801f4e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	e8 f1 f5 ff ff       	call   80143e <fd_alloc>
  801e4d:	89 c3                	mov    %eax,%ebx
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	0f 88 e2 00 00 00    	js     801f3c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5a:	83 ec 04             	sub    $0x4,%esp
  801e5d:	68 07 04 00 00       	push   $0x407
  801e62:	ff 75 f0             	pushl  -0x10(%ebp)
  801e65:	6a 00                	push   $0x0
  801e67:	e8 9d f2 ff ff       	call   801109 <sys_page_alloc>
  801e6c:	89 c3                	mov    %eax,%ebx
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	85 c0                	test   %eax,%eax
  801e73:	0f 88 c3 00 00 00    	js     801f3c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e79:	83 ec 0c             	sub    $0xc,%esp
  801e7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7f:	e8 a3 f5 ff ff       	call   801427 <fd2data>
  801e84:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e86:	83 c4 0c             	add    $0xc,%esp
  801e89:	68 07 04 00 00       	push   $0x407
  801e8e:	50                   	push   %eax
  801e8f:	6a 00                	push   $0x0
  801e91:	e8 73 f2 ff ff       	call   801109 <sys_page_alloc>
  801e96:	89 c3                	mov    %eax,%ebx
  801e98:	83 c4 10             	add    $0x10,%esp
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	0f 88 89 00 00 00    	js     801f2c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea3:	83 ec 0c             	sub    $0xc,%esp
  801ea6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea9:	e8 79 f5 ff ff       	call   801427 <fd2data>
  801eae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eb5:	50                   	push   %eax
  801eb6:	6a 00                	push   $0x0
  801eb8:	56                   	push   %esi
  801eb9:	6a 00                	push   $0x0
  801ebb:	e8 8c f2 ff ff       	call   80114c <sys_page_map>
  801ec0:	89 c3                	mov    %eax,%ebx
  801ec2:	83 c4 20             	add    $0x20,%esp
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	78 55                	js     801f1e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ec9:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ede:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ef3:	83 ec 0c             	sub    $0xc,%esp
  801ef6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef9:	e8 19 f5 ff ff       	call   801417 <fd2num>
  801efe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f01:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f03:	83 c4 04             	add    $0x4,%esp
  801f06:	ff 75 f0             	pushl  -0x10(%ebp)
  801f09:	e8 09 f5 ff ff       	call   801417 <fd2num>
  801f0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f11:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1c:	eb 30                	jmp    801f4e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f1e:	83 ec 08             	sub    $0x8,%esp
  801f21:	56                   	push   %esi
  801f22:	6a 00                	push   $0x0
  801f24:	e8 65 f2 ff ff       	call   80118e <sys_page_unmap>
  801f29:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f2c:	83 ec 08             	sub    $0x8,%esp
  801f2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801f32:	6a 00                	push   $0x0
  801f34:	e8 55 f2 ff ff       	call   80118e <sys_page_unmap>
  801f39:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f3c:	83 ec 08             	sub    $0x8,%esp
  801f3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f42:	6a 00                	push   $0x0
  801f44:	e8 45 f2 ff ff       	call   80118e <sys_page_unmap>
  801f49:	83 c4 10             	add    $0x10,%esp
  801f4c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f4e:	89 d0                	mov    %edx,%eax
  801f50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f60:	50                   	push   %eax
  801f61:	ff 75 08             	pushl  0x8(%ebp)
  801f64:	e8 24 f5 ff ff       	call   80148d <fd_lookup>
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	78 18                	js     801f88 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	ff 75 f4             	pushl  -0xc(%ebp)
  801f76:	e8 ac f4 ff ff       	call   801427 <fd2data>
	return _pipeisclosed(fd, p);
  801f7b:	89 c2                	mov    %eax,%edx
  801f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f80:	e8 21 fd ff ff       	call   801ca6 <_pipeisclosed>
  801f85:	83 c4 10             	add    $0x10,%esp
}
  801f88:	c9                   	leave  
  801f89:	c3                   	ret    

00801f8a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801f90:	68 52 30 80 00       	push   $0x803052
  801f95:	ff 75 0c             	pushl  0xc(%ebp)
  801f98:	e8 69 ed ff ff       	call   800d06 <strcpy>
	return 0;
}
  801f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa2:	c9                   	leave  
  801fa3:	c3                   	ret    

00801fa4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801fa4:	55                   	push   %ebp
  801fa5:	89 e5                	mov    %esp,%ebp
  801fa7:	53                   	push   %ebx
  801fa8:	83 ec 10             	sub    $0x10,%esp
  801fab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801fae:	53                   	push   %ebx
  801faf:	e8 c0 05 00 00       	call   802574 <pageref>
  801fb4:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801fb7:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801fbc:	83 f8 01             	cmp    $0x1,%eax
  801fbf:	75 10                	jne    801fd1 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801fc1:	83 ec 0c             	sub    $0xc,%esp
  801fc4:	ff 73 0c             	pushl  0xc(%ebx)
  801fc7:	e8 c0 02 00 00       	call   80228c <nsipc_close>
  801fcc:	89 c2                	mov    %eax,%edx
  801fce:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801fd1:	89 d0                	mov    %edx,%eax
  801fd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd6:	c9                   	leave  
  801fd7:	c3                   	ret    

00801fd8 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801fde:	6a 00                	push   $0x0
  801fe0:	ff 75 10             	pushl  0x10(%ebp)
  801fe3:	ff 75 0c             	pushl  0xc(%ebp)
  801fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe9:	ff 70 0c             	pushl  0xc(%eax)
  801fec:	e8 78 03 00 00       	call   802369 <nsipc_send>
}
  801ff1:	c9                   	leave  
  801ff2:	c3                   	ret    

00801ff3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
  801ff6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ff9:	6a 00                	push   $0x0
  801ffb:	ff 75 10             	pushl  0x10(%ebp)
  801ffe:	ff 75 0c             	pushl  0xc(%ebp)
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	ff 70 0c             	pushl  0xc(%eax)
  802007:	e8 f1 02 00 00       	call   8022fd <nsipc_recv>
}
  80200c:	c9                   	leave  
  80200d:	c3                   	ret    

0080200e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802014:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802017:	52                   	push   %edx
  802018:	50                   	push   %eax
  802019:	e8 6f f4 ff ff       	call   80148d <fd_lookup>
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	85 c0                	test   %eax,%eax
  802023:	78 17                	js     80203c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802025:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802028:	8b 0d 40 40 80 00    	mov    0x804040,%ecx
  80202e:	39 08                	cmp    %ecx,(%eax)
  802030:	75 05                	jne    802037 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802032:	8b 40 0c             	mov    0xc(%eax),%eax
  802035:	eb 05                	jmp    80203c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802037:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    

0080203e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	56                   	push   %esi
  802042:	53                   	push   %ebx
  802043:	83 ec 1c             	sub    $0x1c,%esp
  802046:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204b:	50                   	push   %eax
  80204c:	e8 ed f3 ff ff       	call   80143e <fd_alloc>
  802051:	89 c3                	mov    %eax,%ebx
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	85 c0                	test   %eax,%eax
  802058:	78 1b                	js     802075 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80205a:	83 ec 04             	sub    $0x4,%esp
  80205d:	68 07 04 00 00       	push   $0x407
  802062:	ff 75 f4             	pushl  -0xc(%ebp)
  802065:	6a 00                	push   $0x0
  802067:	e8 9d f0 ff ff       	call   801109 <sys_page_alloc>
  80206c:	89 c3                	mov    %eax,%ebx
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	79 10                	jns    802085 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802075:	83 ec 0c             	sub    $0xc,%esp
  802078:	56                   	push   %esi
  802079:	e8 0e 02 00 00       	call   80228c <nsipc_close>
		return r;
  80207e:	83 c4 10             	add    $0x10,%esp
  802081:	89 d8                	mov    %ebx,%eax
  802083:	eb 24                	jmp    8020a9 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802085:	8b 15 40 40 80 00    	mov    0x804040,%edx
  80208b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802090:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802093:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80209a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80209d:	83 ec 0c             	sub    $0xc,%esp
  8020a0:	50                   	push   %eax
  8020a1:	e8 71 f3 ff ff       	call   801417 <fd2num>
  8020a6:	83 c4 10             	add    $0x10,%esp
}
  8020a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ac:	5b                   	pop    %ebx
  8020ad:	5e                   	pop    %esi
  8020ae:	5d                   	pop    %ebp
  8020af:	c3                   	ret    

008020b0 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b9:	e8 50 ff ff ff       	call   80200e <fd2sockid>
		return r;
  8020be:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	78 1f                	js     8020e3 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8020c4:	83 ec 04             	sub    $0x4,%esp
  8020c7:	ff 75 10             	pushl  0x10(%ebp)
  8020ca:	ff 75 0c             	pushl  0xc(%ebp)
  8020cd:	50                   	push   %eax
  8020ce:	e8 12 01 00 00       	call   8021e5 <nsipc_accept>
  8020d3:	83 c4 10             	add    $0x10,%esp
		return r;
  8020d6:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8020d8:	85 c0                	test   %eax,%eax
  8020da:	78 07                	js     8020e3 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8020dc:	e8 5d ff ff ff       	call   80203e <alloc_sockfd>
  8020e1:	89 c1                	mov    %eax,%ecx
}
  8020e3:	89 c8                	mov    %ecx,%eax
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    

008020e7 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f0:	e8 19 ff ff ff       	call   80200e <fd2sockid>
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	78 12                	js     80210b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8020f9:	83 ec 04             	sub    $0x4,%esp
  8020fc:	ff 75 10             	pushl  0x10(%ebp)
  8020ff:	ff 75 0c             	pushl  0xc(%ebp)
  802102:	50                   	push   %eax
  802103:	e8 2d 01 00 00       	call   802235 <nsipc_bind>
  802108:	83 c4 10             	add    $0x10,%esp
}
  80210b:	c9                   	leave  
  80210c:	c3                   	ret    

0080210d <shutdown>:

int
shutdown(int s, int how)
{
  80210d:	55                   	push   %ebp
  80210e:	89 e5                	mov    %esp,%ebp
  802110:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802113:	8b 45 08             	mov    0x8(%ebp),%eax
  802116:	e8 f3 fe ff ff       	call   80200e <fd2sockid>
  80211b:	85 c0                	test   %eax,%eax
  80211d:	78 0f                	js     80212e <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80211f:	83 ec 08             	sub    $0x8,%esp
  802122:	ff 75 0c             	pushl  0xc(%ebp)
  802125:	50                   	push   %eax
  802126:	e8 3f 01 00 00       	call   80226a <nsipc_shutdown>
  80212b:	83 c4 10             	add    $0x10,%esp
}
  80212e:	c9                   	leave  
  80212f:	c3                   	ret    

00802130 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802136:	8b 45 08             	mov    0x8(%ebp),%eax
  802139:	e8 d0 fe ff ff       	call   80200e <fd2sockid>
  80213e:	85 c0                	test   %eax,%eax
  802140:	78 12                	js     802154 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802142:	83 ec 04             	sub    $0x4,%esp
  802145:	ff 75 10             	pushl  0x10(%ebp)
  802148:	ff 75 0c             	pushl  0xc(%ebp)
  80214b:	50                   	push   %eax
  80214c:	e8 55 01 00 00       	call   8022a6 <nsipc_connect>
  802151:	83 c4 10             	add    $0x10,%esp
}
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <listen>:

int
listen(int s, int backlog)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80215c:	8b 45 08             	mov    0x8(%ebp),%eax
  80215f:	e8 aa fe ff ff       	call   80200e <fd2sockid>
  802164:	85 c0                	test   %eax,%eax
  802166:	78 0f                	js     802177 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802168:	83 ec 08             	sub    $0x8,%esp
  80216b:	ff 75 0c             	pushl  0xc(%ebp)
  80216e:	50                   	push   %eax
  80216f:	e8 67 01 00 00       	call   8022db <nsipc_listen>
  802174:	83 c4 10             	add    $0x10,%esp
}
  802177:	c9                   	leave  
  802178:	c3                   	ret    

00802179 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802179:	55                   	push   %ebp
  80217a:	89 e5                	mov    %esp,%ebp
  80217c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80217f:	ff 75 10             	pushl  0x10(%ebp)
  802182:	ff 75 0c             	pushl  0xc(%ebp)
  802185:	ff 75 08             	pushl  0x8(%ebp)
  802188:	e8 3a 02 00 00       	call   8023c7 <nsipc_socket>
  80218d:	83 c4 10             	add    $0x10,%esp
  802190:	85 c0                	test   %eax,%eax
  802192:	78 05                	js     802199 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802194:	e8 a5 fe ff ff       	call   80203e <alloc_sockfd>
}
  802199:	c9                   	leave  
  80219a:	c3                   	ret    

0080219b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	53                   	push   %ebx
  80219f:	83 ec 04             	sub    $0x4,%esp
  8021a2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8021a4:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8021ab:	75 12                	jne    8021bf <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8021ad:	83 ec 0c             	sub    $0xc,%esp
  8021b0:	6a 02                	push   $0x2
  8021b2:	e8 27 f2 ff ff       	call   8013de <ipc_find_env>
  8021b7:	a3 04 50 80 00       	mov    %eax,0x805004
  8021bc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8021bf:	6a 07                	push   $0x7
  8021c1:	68 00 70 80 00       	push   $0x807000
  8021c6:	53                   	push   %ebx
  8021c7:	ff 35 04 50 80 00    	pushl  0x805004
  8021cd:	e8 bd f1 ff ff       	call   80138f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8021d2:	83 c4 0c             	add    $0xc,%esp
  8021d5:	6a 00                	push   $0x0
  8021d7:	6a 00                	push   $0x0
  8021d9:	6a 00                	push   $0x0
  8021db:	e8 39 f1 ff ff       	call   801319 <ipc_recv>
}
  8021e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021e3:	c9                   	leave  
  8021e4:	c3                   	ret    

008021e5 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021e5:	55                   	push   %ebp
  8021e6:	89 e5                	mov    %esp,%ebp
  8021e8:	56                   	push   %esi
  8021e9:	53                   	push   %ebx
  8021ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8021ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8021f5:	8b 06                	mov    (%esi),%eax
  8021f7:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8021fc:	b8 01 00 00 00       	mov    $0x1,%eax
  802201:	e8 95 ff ff ff       	call   80219b <nsipc>
  802206:	89 c3                	mov    %eax,%ebx
  802208:	85 c0                	test   %eax,%eax
  80220a:	78 20                	js     80222c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80220c:	83 ec 04             	sub    $0x4,%esp
  80220f:	ff 35 10 70 80 00    	pushl  0x807010
  802215:	68 00 70 80 00       	push   $0x807000
  80221a:	ff 75 0c             	pushl  0xc(%ebp)
  80221d:	e8 76 ec ff ff       	call   800e98 <memmove>
		*addrlen = ret->ret_addrlen;
  802222:	a1 10 70 80 00       	mov    0x807010,%eax
  802227:	89 06                	mov    %eax,(%esi)
  802229:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802231:	5b                   	pop    %ebx
  802232:	5e                   	pop    %esi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    

00802235 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	53                   	push   %ebx
  802239:	83 ec 08             	sub    $0x8,%esp
  80223c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80223f:	8b 45 08             	mov    0x8(%ebp),%eax
  802242:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802247:	53                   	push   %ebx
  802248:	ff 75 0c             	pushl  0xc(%ebp)
  80224b:	68 04 70 80 00       	push   $0x807004
  802250:	e8 43 ec ff ff       	call   800e98 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802255:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80225b:	b8 02 00 00 00       	mov    $0x2,%eax
  802260:	e8 36 ff ff ff       	call   80219b <nsipc>
}
  802265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802268:	c9                   	leave  
  802269:	c3                   	ret    

0080226a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802270:	8b 45 08             	mov    0x8(%ebp),%eax
  802273:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80227b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802280:	b8 03 00 00 00       	mov    $0x3,%eax
  802285:	e8 11 ff ff ff       	call   80219b <nsipc>
}
  80228a:	c9                   	leave  
  80228b:	c3                   	ret    

0080228c <nsipc_close>:

int
nsipc_close(int s)
{
  80228c:	55                   	push   %ebp
  80228d:	89 e5                	mov    %esp,%ebp
  80228f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802292:	8b 45 08             	mov    0x8(%ebp),%eax
  802295:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80229a:	b8 04 00 00 00       	mov    $0x4,%eax
  80229f:	e8 f7 fe ff ff       	call   80219b <nsipc>
}
  8022a4:	c9                   	leave  
  8022a5:	c3                   	ret    

008022a6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8022a6:	55                   	push   %ebp
  8022a7:	89 e5                	mov    %esp,%ebp
  8022a9:	53                   	push   %ebx
  8022aa:	83 ec 08             	sub    $0x8,%esp
  8022ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8022b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b3:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8022b8:	53                   	push   %ebx
  8022b9:	ff 75 0c             	pushl  0xc(%ebp)
  8022bc:	68 04 70 80 00       	push   $0x807004
  8022c1:	e8 d2 eb ff ff       	call   800e98 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8022c6:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8022cc:	b8 05 00 00 00       	mov    $0x5,%eax
  8022d1:	e8 c5 fe ff ff       	call   80219b <nsipc>
}
  8022d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022d9:	c9                   	leave  
  8022da:	c3                   	ret    

008022db <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8022e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ec:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8022f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8022f6:	e8 a0 fe ff ff       	call   80219b <nsipc>
}
  8022fb:	c9                   	leave  
  8022fc:	c3                   	ret    

008022fd <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	56                   	push   %esi
  802301:	53                   	push   %ebx
  802302:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802305:	8b 45 08             	mov    0x8(%ebp),%eax
  802308:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80230d:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802313:	8b 45 14             	mov    0x14(%ebp),%eax
  802316:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80231b:	b8 07 00 00 00       	mov    $0x7,%eax
  802320:	e8 76 fe ff ff       	call   80219b <nsipc>
  802325:	89 c3                	mov    %eax,%ebx
  802327:	85 c0                	test   %eax,%eax
  802329:	78 35                	js     802360 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80232b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802330:	7f 04                	jg     802336 <nsipc_recv+0x39>
  802332:	39 c6                	cmp    %eax,%esi
  802334:	7d 16                	jge    80234c <nsipc_recv+0x4f>
  802336:	68 5e 30 80 00       	push   $0x80305e
  80233b:	68 07 30 80 00       	push   $0x803007
  802340:	6a 62                	push   $0x62
  802342:	68 73 30 80 00       	push   $0x803073
  802347:	e8 3c e3 ff ff       	call   800688 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80234c:	83 ec 04             	sub    $0x4,%esp
  80234f:	50                   	push   %eax
  802350:	68 00 70 80 00       	push   $0x807000
  802355:	ff 75 0c             	pushl  0xc(%ebp)
  802358:	e8 3b eb ff ff       	call   800e98 <memmove>
  80235d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802360:	89 d8                	mov    %ebx,%eax
  802362:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802365:	5b                   	pop    %ebx
  802366:	5e                   	pop    %esi
  802367:	5d                   	pop    %ebp
  802368:	c3                   	ret    

00802369 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802369:	55                   	push   %ebp
  80236a:	89 e5                	mov    %esp,%ebp
  80236c:	53                   	push   %ebx
  80236d:	83 ec 04             	sub    $0x4,%esp
  802370:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802373:	8b 45 08             	mov    0x8(%ebp),%eax
  802376:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80237b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802381:	7e 16                	jle    802399 <nsipc_send+0x30>
  802383:	68 7f 30 80 00       	push   $0x80307f
  802388:	68 07 30 80 00       	push   $0x803007
  80238d:	6a 6d                	push   $0x6d
  80238f:	68 73 30 80 00       	push   $0x803073
  802394:	e8 ef e2 ff ff       	call   800688 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802399:	83 ec 04             	sub    $0x4,%esp
  80239c:	53                   	push   %ebx
  80239d:	ff 75 0c             	pushl  0xc(%ebp)
  8023a0:	68 0c 70 80 00       	push   $0x80700c
  8023a5:	e8 ee ea ff ff       	call   800e98 <memmove>
	nsipcbuf.send.req_size = size;
  8023aa:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8023b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8023b3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8023b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8023bd:	e8 d9 fd ff ff       	call   80219b <nsipc>
}
  8023c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023c5:	c9                   	leave  
  8023c6:	c3                   	ret    

008023c7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8023c7:	55                   	push   %ebp
  8023c8:	89 e5                	mov    %esp,%ebp
  8023ca:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8023d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d8:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8023dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8023e0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8023e5:	b8 09 00 00 00       	mov    $0x9,%eax
  8023ea:	e8 ac fd ff ff       	call   80219b <nsipc>
}
  8023ef:	c9                   	leave  
  8023f0:	c3                   	ret    

008023f1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8023f9:	5d                   	pop    %ebp
  8023fa:	c3                   	ret    

008023fb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023fb:	55                   	push   %ebp
  8023fc:	89 e5                	mov    %esp,%ebp
  8023fe:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802401:	68 8b 30 80 00       	push   $0x80308b
  802406:	ff 75 0c             	pushl  0xc(%ebp)
  802409:	e8 f8 e8 ff ff       	call   800d06 <strcpy>
	return 0;
}
  80240e:	b8 00 00 00 00       	mov    $0x0,%eax
  802413:	c9                   	leave  
  802414:	c3                   	ret    

00802415 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802415:	55                   	push   %ebp
  802416:	89 e5                	mov    %esp,%ebp
  802418:	57                   	push   %edi
  802419:	56                   	push   %esi
  80241a:	53                   	push   %ebx
  80241b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802421:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802426:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80242c:	eb 2d                	jmp    80245b <devcons_write+0x46>
		m = n - tot;
  80242e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802431:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802433:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802436:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80243b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80243e:	83 ec 04             	sub    $0x4,%esp
  802441:	53                   	push   %ebx
  802442:	03 45 0c             	add    0xc(%ebp),%eax
  802445:	50                   	push   %eax
  802446:	57                   	push   %edi
  802447:	e8 4c ea ff ff       	call   800e98 <memmove>
		sys_cputs(buf, m);
  80244c:	83 c4 08             	add    $0x8,%esp
  80244f:	53                   	push   %ebx
  802450:	57                   	push   %edi
  802451:	e8 f7 eb ff ff       	call   80104d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802456:	01 de                	add    %ebx,%esi
  802458:	83 c4 10             	add    $0x10,%esp
  80245b:	89 f0                	mov    %esi,%eax
  80245d:	3b 75 10             	cmp    0x10(%ebp),%esi
  802460:	72 cc                	jb     80242e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802462:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802465:	5b                   	pop    %ebx
  802466:	5e                   	pop    %esi
  802467:	5f                   	pop    %edi
  802468:	5d                   	pop    %ebp
  802469:	c3                   	ret    

0080246a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80246a:	55                   	push   %ebp
  80246b:	89 e5                	mov    %esp,%ebp
  80246d:	83 ec 08             	sub    $0x8,%esp
  802470:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802475:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802479:	74 2a                	je     8024a5 <devcons_read+0x3b>
  80247b:	eb 05                	jmp    802482 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80247d:	e8 68 ec ff ff       	call   8010ea <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802482:	e8 e4 eb ff ff       	call   80106b <sys_cgetc>
  802487:	85 c0                	test   %eax,%eax
  802489:	74 f2                	je     80247d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80248b:	85 c0                	test   %eax,%eax
  80248d:	78 16                	js     8024a5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80248f:	83 f8 04             	cmp    $0x4,%eax
  802492:	74 0c                	je     8024a0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802494:	8b 55 0c             	mov    0xc(%ebp),%edx
  802497:	88 02                	mov    %al,(%edx)
	return 1;
  802499:	b8 01 00 00 00       	mov    $0x1,%eax
  80249e:	eb 05                	jmp    8024a5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8024a0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8024a5:	c9                   	leave  
  8024a6:	c3                   	ret    

008024a7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8024a7:	55                   	push   %ebp
  8024a8:	89 e5                	mov    %esp,%ebp
  8024aa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8024ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8024b3:	6a 01                	push   $0x1
  8024b5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024b8:	50                   	push   %eax
  8024b9:	e8 8f eb ff ff       	call   80104d <sys_cputs>
}
  8024be:	83 c4 10             	add    $0x10,%esp
  8024c1:	c9                   	leave  
  8024c2:	c3                   	ret    

008024c3 <getchar>:

int
getchar(void)
{
  8024c3:	55                   	push   %ebp
  8024c4:	89 e5                	mov    %esp,%ebp
  8024c6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024c9:	6a 01                	push   $0x1
  8024cb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024ce:	50                   	push   %eax
  8024cf:	6a 00                	push   $0x0
  8024d1:	e8 1d f2 ff ff       	call   8016f3 <read>
	if (r < 0)
  8024d6:	83 c4 10             	add    $0x10,%esp
  8024d9:	85 c0                	test   %eax,%eax
  8024db:	78 0f                	js     8024ec <getchar+0x29>
		return r;
	if (r < 1)
  8024dd:	85 c0                	test   %eax,%eax
  8024df:	7e 06                	jle    8024e7 <getchar+0x24>
		return -E_EOF;
	return c;
  8024e1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024e5:	eb 05                	jmp    8024ec <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024e7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024ec:	c9                   	leave  
  8024ed:	c3                   	ret    

008024ee <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024ee:	55                   	push   %ebp
  8024ef:	89 e5                	mov    %esp,%ebp
  8024f1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024f7:	50                   	push   %eax
  8024f8:	ff 75 08             	pushl  0x8(%ebp)
  8024fb:	e8 8d ef ff ff       	call   80148d <fd_lookup>
  802500:	83 c4 10             	add    $0x10,%esp
  802503:	85 c0                	test   %eax,%eax
  802505:	78 11                	js     802518 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802507:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80250a:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802510:	39 10                	cmp    %edx,(%eax)
  802512:	0f 94 c0             	sete   %al
  802515:	0f b6 c0             	movzbl %al,%eax
}
  802518:	c9                   	leave  
  802519:	c3                   	ret    

0080251a <opencons>:

int
opencons(void)
{
  80251a:	55                   	push   %ebp
  80251b:	89 e5                	mov    %esp,%ebp
  80251d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802520:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802523:	50                   	push   %eax
  802524:	e8 15 ef ff ff       	call   80143e <fd_alloc>
  802529:	83 c4 10             	add    $0x10,%esp
		return r;
  80252c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80252e:	85 c0                	test   %eax,%eax
  802530:	78 3e                	js     802570 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802532:	83 ec 04             	sub    $0x4,%esp
  802535:	68 07 04 00 00       	push   $0x407
  80253a:	ff 75 f4             	pushl  -0xc(%ebp)
  80253d:	6a 00                	push   $0x0
  80253f:	e8 c5 eb ff ff       	call   801109 <sys_page_alloc>
  802544:	83 c4 10             	add    $0x10,%esp
		return r;
  802547:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802549:	85 c0                	test   %eax,%eax
  80254b:	78 23                	js     802570 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80254d:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802553:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802556:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802558:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802562:	83 ec 0c             	sub    $0xc,%esp
  802565:	50                   	push   %eax
  802566:	e8 ac ee ff ff       	call   801417 <fd2num>
  80256b:	89 c2                	mov    %eax,%edx
  80256d:	83 c4 10             	add    $0x10,%esp
}
  802570:	89 d0                	mov    %edx,%eax
  802572:	c9                   	leave  
  802573:	c3                   	ret    

00802574 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802574:	55                   	push   %ebp
  802575:	89 e5                	mov    %esp,%ebp
  802577:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80257a:	89 d0                	mov    %edx,%eax
  80257c:	c1 e8 16             	shr    $0x16,%eax
  80257f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802586:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80258b:	f6 c1 01             	test   $0x1,%cl
  80258e:	74 1d                	je     8025ad <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802590:	c1 ea 0c             	shr    $0xc,%edx
  802593:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80259a:	f6 c2 01             	test   $0x1,%dl
  80259d:	74 0e                	je     8025ad <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80259f:	c1 ea 0c             	shr    $0xc,%edx
  8025a2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025a9:	ef 
  8025aa:	0f b7 c0             	movzwl %ax,%eax
}
  8025ad:	5d                   	pop    %ebp
  8025ae:	c3                   	ret    
  8025af:	90                   	nop

008025b0 <__udivdi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	53                   	push   %ebx
  8025b4:	83 ec 1c             	sub    $0x1c,%esp
  8025b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025c7:	85 f6                	test   %esi,%esi
  8025c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025cd:	89 ca                	mov    %ecx,%edx
  8025cf:	89 f8                	mov    %edi,%eax
  8025d1:	75 3d                	jne    802610 <__udivdi3+0x60>
  8025d3:	39 cf                	cmp    %ecx,%edi
  8025d5:	0f 87 c5 00 00 00    	ja     8026a0 <__udivdi3+0xf0>
  8025db:	85 ff                	test   %edi,%edi
  8025dd:	89 fd                	mov    %edi,%ebp
  8025df:	75 0b                	jne    8025ec <__udivdi3+0x3c>
  8025e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e6:	31 d2                	xor    %edx,%edx
  8025e8:	f7 f7                	div    %edi
  8025ea:	89 c5                	mov    %eax,%ebp
  8025ec:	89 c8                	mov    %ecx,%eax
  8025ee:	31 d2                	xor    %edx,%edx
  8025f0:	f7 f5                	div    %ebp
  8025f2:	89 c1                	mov    %eax,%ecx
  8025f4:	89 d8                	mov    %ebx,%eax
  8025f6:	89 cf                	mov    %ecx,%edi
  8025f8:	f7 f5                	div    %ebp
  8025fa:	89 c3                	mov    %eax,%ebx
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
  802610:	39 ce                	cmp    %ecx,%esi
  802612:	77 74                	ja     802688 <__udivdi3+0xd8>
  802614:	0f bd fe             	bsr    %esi,%edi
  802617:	83 f7 1f             	xor    $0x1f,%edi
  80261a:	0f 84 98 00 00 00    	je     8026b8 <__udivdi3+0x108>
  802620:	bb 20 00 00 00       	mov    $0x20,%ebx
  802625:	89 f9                	mov    %edi,%ecx
  802627:	89 c5                	mov    %eax,%ebp
  802629:	29 fb                	sub    %edi,%ebx
  80262b:	d3 e6                	shl    %cl,%esi
  80262d:	89 d9                	mov    %ebx,%ecx
  80262f:	d3 ed                	shr    %cl,%ebp
  802631:	89 f9                	mov    %edi,%ecx
  802633:	d3 e0                	shl    %cl,%eax
  802635:	09 ee                	or     %ebp,%esi
  802637:	89 d9                	mov    %ebx,%ecx
  802639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263d:	89 d5                	mov    %edx,%ebp
  80263f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802643:	d3 ed                	shr    %cl,%ebp
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e2                	shl    %cl,%edx
  802649:	89 d9                	mov    %ebx,%ecx
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	09 c2                	or     %eax,%edx
  80264f:	89 d0                	mov    %edx,%eax
  802651:	89 ea                	mov    %ebp,%edx
  802653:	f7 f6                	div    %esi
  802655:	89 d5                	mov    %edx,%ebp
  802657:	89 c3                	mov    %eax,%ebx
  802659:	f7 64 24 0c          	mull   0xc(%esp)
  80265d:	39 d5                	cmp    %edx,%ebp
  80265f:	72 10                	jb     802671 <__udivdi3+0xc1>
  802661:	8b 74 24 08          	mov    0x8(%esp),%esi
  802665:	89 f9                	mov    %edi,%ecx
  802667:	d3 e6                	shl    %cl,%esi
  802669:	39 c6                	cmp    %eax,%esi
  80266b:	73 07                	jae    802674 <__udivdi3+0xc4>
  80266d:	39 d5                	cmp    %edx,%ebp
  80266f:	75 03                	jne    802674 <__udivdi3+0xc4>
  802671:	83 eb 01             	sub    $0x1,%ebx
  802674:	31 ff                	xor    %edi,%edi
  802676:	89 d8                	mov    %ebx,%eax
  802678:	89 fa                	mov    %edi,%edx
  80267a:	83 c4 1c             	add    $0x1c,%esp
  80267d:	5b                   	pop    %ebx
  80267e:	5e                   	pop    %esi
  80267f:	5f                   	pop    %edi
  802680:	5d                   	pop    %ebp
  802681:	c3                   	ret    
  802682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802688:	31 ff                	xor    %edi,%edi
  80268a:	31 db                	xor    %ebx,%ebx
  80268c:	89 d8                	mov    %ebx,%eax
  80268e:	89 fa                	mov    %edi,%edx
  802690:	83 c4 1c             	add    $0x1c,%esp
  802693:	5b                   	pop    %ebx
  802694:	5e                   	pop    %esi
  802695:	5f                   	pop    %edi
  802696:	5d                   	pop    %ebp
  802697:	c3                   	ret    
  802698:	90                   	nop
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 d8                	mov    %ebx,%eax
  8026a2:	f7 f7                	div    %edi
  8026a4:	31 ff                	xor    %edi,%edi
  8026a6:	89 c3                	mov    %eax,%ebx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 fa                	mov    %edi,%edx
  8026ac:	83 c4 1c             	add    $0x1c,%esp
  8026af:	5b                   	pop    %ebx
  8026b0:	5e                   	pop    %esi
  8026b1:	5f                   	pop    %edi
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    
  8026b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b8:	39 ce                	cmp    %ecx,%esi
  8026ba:	72 0c                	jb     8026c8 <__udivdi3+0x118>
  8026bc:	31 db                	xor    %ebx,%ebx
  8026be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026c2:	0f 87 34 ff ff ff    	ja     8025fc <__udivdi3+0x4c>
  8026c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026cd:	e9 2a ff ff ff       	jmp    8025fc <__udivdi3+0x4c>
  8026d2:	66 90                	xchg   %ax,%ax
  8026d4:	66 90                	xchg   %ax,%ax
  8026d6:	66 90                	xchg   %ax,%ax
  8026d8:	66 90                	xchg   %ax,%ax
  8026da:	66 90                	xchg   %ax,%ax
  8026dc:	66 90                	xchg   %ax,%ax
  8026de:	66 90                	xchg   %ax,%ax

008026e0 <__umoddi3>:
  8026e0:	55                   	push   %ebp
  8026e1:	57                   	push   %edi
  8026e2:	56                   	push   %esi
  8026e3:	53                   	push   %ebx
  8026e4:	83 ec 1c             	sub    $0x1c,%esp
  8026e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026f7:	85 d2                	test   %edx,%edx
  8026f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802701:	89 f3                	mov    %esi,%ebx
  802703:	89 3c 24             	mov    %edi,(%esp)
  802706:	89 74 24 04          	mov    %esi,0x4(%esp)
  80270a:	75 1c                	jne    802728 <__umoddi3+0x48>
  80270c:	39 f7                	cmp    %esi,%edi
  80270e:	76 50                	jbe    802760 <__umoddi3+0x80>
  802710:	89 c8                	mov    %ecx,%eax
  802712:	89 f2                	mov    %esi,%edx
  802714:	f7 f7                	div    %edi
  802716:	89 d0                	mov    %edx,%eax
  802718:	31 d2                	xor    %edx,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	39 f2                	cmp    %esi,%edx
  80272a:	89 d0                	mov    %edx,%eax
  80272c:	77 52                	ja     802780 <__umoddi3+0xa0>
  80272e:	0f bd ea             	bsr    %edx,%ebp
  802731:	83 f5 1f             	xor    $0x1f,%ebp
  802734:	75 5a                	jne    802790 <__umoddi3+0xb0>
  802736:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80273a:	0f 82 e0 00 00 00    	jb     802820 <__umoddi3+0x140>
  802740:	39 0c 24             	cmp    %ecx,(%esp)
  802743:	0f 86 d7 00 00 00    	jbe    802820 <__umoddi3+0x140>
  802749:	8b 44 24 08          	mov    0x8(%esp),%eax
  80274d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802751:	83 c4 1c             	add    $0x1c,%esp
  802754:	5b                   	pop    %ebx
  802755:	5e                   	pop    %esi
  802756:	5f                   	pop    %edi
  802757:	5d                   	pop    %ebp
  802758:	c3                   	ret    
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	85 ff                	test   %edi,%edi
  802762:	89 fd                	mov    %edi,%ebp
  802764:	75 0b                	jne    802771 <__umoddi3+0x91>
  802766:	b8 01 00 00 00       	mov    $0x1,%eax
  80276b:	31 d2                	xor    %edx,%edx
  80276d:	f7 f7                	div    %edi
  80276f:	89 c5                	mov    %eax,%ebp
  802771:	89 f0                	mov    %esi,%eax
  802773:	31 d2                	xor    %edx,%edx
  802775:	f7 f5                	div    %ebp
  802777:	89 c8                	mov    %ecx,%eax
  802779:	f7 f5                	div    %ebp
  80277b:	89 d0                	mov    %edx,%eax
  80277d:	eb 99                	jmp    802718 <__umoddi3+0x38>
  80277f:	90                   	nop
  802780:	89 c8                	mov    %ecx,%eax
  802782:	89 f2                	mov    %esi,%edx
  802784:	83 c4 1c             	add    $0x1c,%esp
  802787:	5b                   	pop    %ebx
  802788:	5e                   	pop    %esi
  802789:	5f                   	pop    %edi
  80278a:	5d                   	pop    %ebp
  80278b:	c3                   	ret    
  80278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802790:	8b 34 24             	mov    (%esp),%esi
  802793:	bf 20 00 00 00       	mov    $0x20,%edi
  802798:	89 e9                	mov    %ebp,%ecx
  80279a:	29 ef                	sub    %ebp,%edi
  80279c:	d3 e0                	shl    %cl,%eax
  80279e:	89 f9                	mov    %edi,%ecx
  8027a0:	89 f2                	mov    %esi,%edx
  8027a2:	d3 ea                	shr    %cl,%edx
  8027a4:	89 e9                	mov    %ebp,%ecx
  8027a6:	09 c2                	or     %eax,%edx
  8027a8:	89 d8                	mov    %ebx,%eax
  8027aa:	89 14 24             	mov    %edx,(%esp)
  8027ad:	89 f2                	mov    %esi,%edx
  8027af:	d3 e2                	shl    %cl,%edx
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027bb:	d3 e8                	shr    %cl,%eax
  8027bd:	89 e9                	mov    %ebp,%ecx
  8027bf:	89 c6                	mov    %eax,%esi
  8027c1:	d3 e3                	shl    %cl,%ebx
  8027c3:	89 f9                	mov    %edi,%ecx
  8027c5:	89 d0                	mov    %edx,%eax
  8027c7:	d3 e8                	shr    %cl,%eax
  8027c9:	89 e9                	mov    %ebp,%ecx
  8027cb:	09 d8                	or     %ebx,%eax
  8027cd:	89 d3                	mov    %edx,%ebx
  8027cf:	89 f2                	mov    %esi,%edx
  8027d1:	f7 34 24             	divl   (%esp)
  8027d4:	89 d6                	mov    %edx,%esi
  8027d6:	d3 e3                	shl    %cl,%ebx
  8027d8:	f7 64 24 04          	mull   0x4(%esp)
  8027dc:	39 d6                	cmp    %edx,%esi
  8027de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027e2:	89 d1                	mov    %edx,%ecx
  8027e4:	89 c3                	mov    %eax,%ebx
  8027e6:	72 08                	jb     8027f0 <__umoddi3+0x110>
  8027e8:	75 11                	jne    8027fb <__umoddi3+0x11b>
  8027ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ee:	73 0b                	jae    8027fb <__umoddi3+0x11b>
  8027f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027f4:	1b 14 24             	sbb    (%esp),%edx
  8027f7:	89 d1                	mov    %edx,%ecx
  8027f9:	89 c3                	mov    %eax,%ebx
  8027fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027ff:	29 da                	sub    %ebx,%edx
  802801:	19 ce                	sbb    %ecx,%esi
  802803:	89 f9                	mov    %edi,%ecx
  802805:	89 f0                	mov    %esi,%eax
  802807:	d3 e0                	shl    %cl,%eax
  802809:	89 e9                	mov    %ebp,%ecx
  80280b:	d3 ea                	shr    %cl,%edx
  80280d:	89 e9                	mov    %ebp,%ecx
  80280f:	d3 ee                	shr    %cl,%esi
  802811:	09 d0                	or     %edx,%eax
  802813:	89 f2                	mov    %esi,%edx
  802815:	83 c4 1c             	add    $0x1c,%esp
  802818:	5b                   	pop    %ebx
  802819:	5e                   	pop    %esi
  80281a:	5f                   	pop    %edi
  80281b:	5d                   	pop    %ebp
  80281c:	c3                   	ret    
  80281d:	8d 76 00             	lea    0x0(%esi),%esi
  802820:	29 f9                	sub    %edi,%ecx
  802822:	19 d6                	sbb    %edx,%esi
  802824:	89 74 24 04          	mov    %esi,0x4(%esp)
  802828:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80282c:	e9 18 ff ff ff       	jmp    802749 <__umoddi3+0x69>
