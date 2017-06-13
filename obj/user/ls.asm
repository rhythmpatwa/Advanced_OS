
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 42 27 80 00       	push   $0x802742
  80005f:	e8 b6 19 00 00       	call   801a1a <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 a8 27 80 00       	mov    $0x8027a8,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 eb 08 00 00       	call   800969 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba a8 27 80 00       	mov    $0x8027a8,%edx
  80008b:	b8 40 27 80 00       	mov    $0x802740,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 4b 27 80 00       	push   $0x80274b
  80009d:	e8 78 19 00 00       	call   801a1a <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 d9 2b 80 00       	push   $0x802bd9
  8000b0:	e8 65 19 00 00       	call   801a1a <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 40 27 80 00       	push   $0x802740
  8000cf:	e8 46 19 00 00       	call   801a1a <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 a7 27 80 00       	push   $0x8027a7
  8000df:	e8 36 19 00 00       	call   801a1a <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 77 17 00 00       	call   80187c <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 50 27 80 00       	push   $0x802750
  800118:	6a 1d                	push   $0x1d
  80011a:	68 5c 27 80 00       	push   $0x80275c
  80011f:	e8 00 02 00 00       	call   800324 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 12 13 00 00       	call   801476 <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 66 27 80 00       	push   $0x802766
  800178:	6a 22                	push   $0x22
  80017a:	68 5c 27 80 00       	push   $0x80275c
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 ac 27 80 00       	push   $0x8027ac
  800192:	6a 24                	push   $0x24
  800194:	68 5c 27 80 00       	push   $0x80275c
  800199:	e8 86 01 00 00       	call   800324 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 bb 14 00 00       	call   80167b <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 81 27 80 00       	push   $0x802781
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 5c 27 80 00       	push   $0x80275c
  8001d8:	e8 47 01 00 00       	call   800324 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 8d 27 80 00       	push   $0x80278d
  800225:	e8 f0 17 00 00       	call   801a1a <printf>
	exit();
  80022a:	e8 db 00 00 00       	call   80030a <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 68 0d 00 00       	call   800fb5 <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 69 0d 00 00       	call   800fe5 <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 a8 27 80 00       	push   $0x8027a8
  800296:	68 40 27 80 00       	push   $0x802740
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8002cf:	e8 93 0a 00 00       	call   800d67 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e1:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7e 07                	jle    8002f1 <libmain+0x2d>
		binaryname = argv[0];
  8002ea:	8b 06                	mov    (%esi),%eax
  8002ec:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	e8 39 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fb:	e8 0a 00 00 00       	call   80030a <exit>
}
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800310:	e8 bf 0f 00 00       	call   8012d4 <close_all>
	sys_env_destroy(0);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	6a 00                	push   $0x0
  80031a:	e8 07 0a 00 00       	call   800d26 <sys_env_destroy>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800329:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800332:	e8 30 0a 00 00       	call   800d67 <sys_getenvid>
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	56                   	push   %esi
  800341:	50                   	push   %eax
  800342:	68 d8 27 80 00       	push   $0x8027d8
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 a7 27 80 00 	movl   $0x8027a7,(%esp)
  80035f:	e8 99 00 00 00       	call   8003fd <cprintf>
  800364:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800367:	cc                   	int3   
  800368:	eb fd                	jmp    800367 <_panic+0x43>

0080036a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	53                   	push   %ebx
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800374:	8b 13                	mov    (%ebx),%edx
  800376:	8d 42 01             	lea    0x1(%edx),%eax
  800379:	89 03                	mov    %eax,(%ebx)
  80037b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800382:	3d ff 00 00 00       	cmp    $0xff,%eax
  800387:	75 1a                	jne    8003a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 4f 09 00 00       	call   800ce9 <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 6a 03 80 00       	push   $0x80036a
  8003db:	e8 54 01 00 00       	call   800534 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 f4 08 00 00       	call   800ce9 <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800435:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800438:	39 d3                	cmp    %edx,%ebx
  80043a:	72 05                	jb     800441 <printnum+0x30>
  80043c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043f:	77 45                	ja     800486 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 4b 20 00 00       	call   8024b0 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 18                	jmp    800490 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb 03                	jmp    800489 <printnum+0x78>
  800486:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f e8                	jg     800478 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049a:	ff 75 e0             	pushl  -0x20(%ebp)
  80049d:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	e8 38 21 00 00       	call   8025e0 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 fb 27 80 00 	movsbl 0x8027fb(%eax),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff d7                	call   *%edi
}
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5e                   	pop    %esi
  8004bd:	5f                   	pop    %edi
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c3:	83 fa 01             	cmp    $0x1,%edx
  8004c6:	7e 0e                	jle    8004d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	8b 52 04             	mov    0x4(%edx),%edx
  8004d4:	eb 22                	jmp    8004f8 <getuint+0x38>
	else if (lflag)
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 10                	je     8004ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e8:	eb 0e                	jmp    8004f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 02                	mov    (%edx),%eax
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f8:	5d                   	pop    %ebp
  8004f9:	c3                   	ret    

008004fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800500:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800504:	8b 10                	mov    (%eax),%edx
  800506:	3b 50 04             	cmp    0x4(%eax),%edx
  800509:	73 0a                	jae    800515 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050e:	89 08                	mov    %ecx,(%eax)
  800510:	8b 45 08             	mov    0x8(%ebp),%eax
  800513:	88 02                	mov    %al,(%edx)
}
  800515:	5d                   	pop    %ebp
  800516:	c3                   	ret    

00800517 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80051d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800520:	50                   	push   %eax
  800521:	ff 75 10             	pushl  0x10(%ebp)
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 05 00 00 00       	call   800534 <vprintfmt>
	va_end(ap);
}
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 2c             	sub    $0x2c,%esp
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	8b 7d 10             	mov    0x10(%ebp),%edi
  800546:	eb 12                	jmp    80055a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800548:	85 c0                	test   %eax,%eax
  80054a:	0f 84 a9 03 00 00    	je     8008f9 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	50                   	push   %eax
  800555:	ff d6                	call   *%esi
  800557:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055a:	83 c7 01             	add    $0x1,%edi
  80055d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800561:	83 f8 25             	cmp    $0x25,%eax
  800564:	75 e2                	jne    800548 <vprintfmt+0x14>
  800566:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800571:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800578:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057f:	ba 00 00 00 00       	mov    $0x0,%edx
  800584:	eb 07                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800589:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8d 47 01             	lea    0x1(%edi),%eax
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800593:	0f b6 07             	movzbl (%edi),%eax
  800596:	0f b6 c8             	movzbl %al,%ecx
  800599:	83 e8 23             	sub    $0x23,%eax
  80059c:	3c 55                	cmp    $0x55,%al
  80059e:	0f 87 3a 03 00 00    	ja     8008de <vprintfmt+0x3aa>
  8005a4:	0f b6 c0             	movzbl %al,%eax
  8005a7:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b5:	eb d6                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005cc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005cf:	83 fa 09             	cmp    $0x9,%edx
  8005d2:	77 39                	ja     80060d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d7:	eb e9                	jmp    8005c2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8005df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ea:	eb 27                	jmp    800613 <vprintfmt+0xdf>
  8005ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f6:	0f 49 c8             	cmovns %eax,%ecx
  8005f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ff:	eb 8c                	jmp    80058d <vprintfmt+0x59>
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800604:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80060b:	eb 80                	jmp    80058d <vprintfmt+0x59>
  80060d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800610:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800613:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800617:	0f 89 70 ff ff ff    	jns    80058d <vprintfmt+0x59>
				width = precision, precision = -1;
  80061d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800620:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800623:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80062a:	e9 5e ff ff ff       	jmp    80058d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800635:	e9 53 ff ff ff       	jmp    80058d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	ff 30                	pushl  (%eax)
  800649:	ff d6                	call   *%esi
			break;
  80064b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800651:	e9 04 ff ff ff       	jmp    80055a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	99                   	cltd   
  800662:	31 d0                	xor    %edx,%eax
  800664:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800666:	83 f8 0f             	cmp    $0xf,%eax
  800669:	7f 0b                	jg     800676 <vprintfmt+0x142>
  80066b:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	75 18                	jne    80068e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800676:	50                   	push   %eax
  800677:	68 13 28 80 00       	push   $0x802813
  80067c:	53                   	push   %ebx
  80067d:	56                   	push   %esi
  80067e:	e8 94 fe ff ff       	call   800517 <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800689:	e9 cc fe ff ff       	jmp    80055a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80068e:	52                   	push   %edx
  80068f:	68 d9 2b 80 00       	push   $0x802bd9
  800694:	53                   	push   %ebx
  800695:	56                   	push   %esi
  800696:	e8 7c fe ff ff       	call   800517 <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a1:	e9 b4 fe ff ff       	jmp    80055a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b1:	85 ff                	test   %edi,%edi
  8006b3:	b8 0c 28 80 00       	mov    $0x80280c,%eax
  8006b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bf:	0f 8e 94 00 00 00    	jle    800759 <vprintfmt+0x225>
  8006c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c9:	0f 84 98 00 00 00    	je     800767 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d5:	57                   	push   %edi
  8006d6:	e8 a6 02 00 00       	call   800981 <strnlen>
  8006db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006de:	29 c1                	sub    %eax,%ecx
  8006e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f2:	eb 0f                	jmp    800703 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fd:	83 ef 01             	sub    $0x1,%edi
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 ff                	test   %edi,%edi
  800705:	7f ed                	jg     8006f4 <vprintfmt+0x1c0>
  800707:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	0f 49 c1             	cmovns %ecx,%eax
  800717:	29 c1                	sub    %eax,%ecx
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	89 cb                	mov    %ecx,%ebx
  800724:	eb 4d                	jmp    800773 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800726:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072a:	74 1b                	je     800747 <vprintfmt+0x213>
  80072c:	0f be c0             	movsbl %al,%eax
  80072f:	83 e8 20             	sub    $0x20,%eax
  800732:	83 f8 5e             	cmp    $0x5e,%eax
  800735:	76 10                	jbe    800747 <vprintfmt+0x213>
					putch('?', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	6a 3f                	push   $0x3f
  80073f:	ff 55 08             	call   *0x8(%ebp)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 0d                	jmp    800754 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	52                   	push   %edx
  80074e:	ff 55 08             	call   *0x8(%ebp)
  800751:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800754:	83 eb 01             	sub    $0x1,%ebx
  800757:	eb 1a                	jmp    800773 <vprintfmt+0x23f>
  800759:	89 75 08             	mov    %esi,0x8(%ebp)
  80075c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800762:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800765:	eb 0c                	jmp    800773 <vprintfmt+0x23f>
  800767:	89 75 08             	mov    %esi,0x8(%ebp)
  80076a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80076d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800770:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800773:	83 c7 01             	add    $0x1,%edi
  800776:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077a:	0f be d0             	movsbl %al,%edx
  80077d:	85 d2                	test   %edx,%edx
  80077f:	74 23                	je     8007a4 <vprintfmt+0x270>
  800781:	85 f6                	test   %esi,%esi
  800783:	78 a1                	js     800726 <vprintfmt+0x1f2>
  800785:	83 ee 01             	sub    $0x1,%esi
  800788:	79 9c                	jns    800726 <vprintfmt+0x1f2>
  80078a:	89 df                	mov    %ebx,%edi
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800792:	eb 18                	jmp    8007ac <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 20                	push   $0x20
  80079a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079c:	83 ef 01             	sub    $0x1,%edi
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 08                	jmp    8007ac <vprintfmt+0x278>
  8007a4:	89 df                	mov    %ebx,%edi
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ac:	85 ff                	test   %edi,%edi
  8007ae:	7f e4                	jg     800794 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b3:	e9 a2 fd ff ff       	jmp    80055a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b8:	83 fa 01             	cmp    $0x1,%edx
  8007bb:	7e 16                	jle    8007d3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 08             	lea    0x8(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c6:	8b 50 04             	mov    0x4(%eax),%edx
  8007c9:	8b 00                	mov    (%eax),%eax
  8007cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d1:	eb 32                	jmp    800805 <vprintfmt+0x2d1>
	else if (lflag)
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	74 18                	je     8007ef <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	89 c1                	mov    %eax,%ecx
  8007e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ed:	eb 16                	jmp    800805 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fd:	89 c1                	mov    %eax,%ecx
  8007ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800802:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800805:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800808:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800810:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800814:	0f 89 90 00 00 00    	jns    8008aa <vprintfmt+0x376>
				putch('-', putdat);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	53                   	push   %ebx
  80081e:	6a 2d                	push   $0x2d
  800820:	ff d6                	call   *%esi
				num = -(long long) num;
  800822:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800825:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800828:	f7 d8                	neg    %eax
  80082a:	83 d2 00             	adc    $0x0,%edx
  80082d:	f7 da                	neg    %edx
  80082f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800832:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800837:	eb 71                	jmp    8008aa <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800839:	8d 45 14             	lea    0x14(%ebp),%eax
  80083c:	e8 7f fc ff ff       	call   8004c0 <getuint>
			base = 10;
  800841:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800846:	eb 62                	jmp    8008aa <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800848:	8d 45 14             	lea    0x14(%ebp),%eax
  80084b:	e8 70 fc ff ff       	call   8004c0 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800850:	83 ec 0c             	sub    $0xc,%esp
  800853:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800857:	51                   	push   %ecx
  800858:	ff 75 e0             	pushl  -0x20(%ebp)
  80085b:	6a 08                	push   $0x8
  80085d:	52                   	push   %edx
  80085e:	50                   	push   %eax
  80085f:	89 da                	mov    %ebx,%edx
  800861:	89 f0                	mov    %esi,%eax
  800863:	e8 a9 fb ff ff       	call   800411 <printnum>
			break;
  800868:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  80086e:	e9 e7 fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800873:	83 ec 08             	sub    $0x8,%esp
  800876:	53                   	push   %ebx
  800877:	6a 30                	push   $0x30
  800879:	ff d6                	call   *%esi
			putch('x', putdat);
  80087b:	83 c4 08             	add    $0x8,%esp
  80087e:	53                   	push   %ebx
  80087f:	6a 78                	push   $0x78
  800881:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	8d 50 04             	lea    0x4(%eax),%edx
  800889:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80088c:	8b 00                	mov    (%eax),%eax
  80088e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800893:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800896:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80089b:	eb 0d                	jmp    8008aa <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80089d:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a0:	e8 1b fc ff ff       	call   8004c0 <getuint>
			base = 16;
  8008a5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008aa:	83 ec 0c             	sub    $0xc,%esp
  8008ad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008b1:	57                   	push   %edi
  8008b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b5:	51                   	push   %ecx
  8008b6:	52                   	push   %edx
  8008b7:	50                   	push   %eax
  8008b8:	89 da                	mov    %ebx,%edx
  8008ba:	89 f0                	mov    %esi,%eax
  8008bc:	e8 50 fb ff ff       	call   800411 <printnum>
			break;
  8008c1:	83 c4 20             	add    $0x20,%esp
  8008c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c7:	e9 8e fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008cc:	83 ec 08             	sub    $0x8,%esp
  8008cf:	53                   	push   %ebx
  8008d0:	51                   	push   %ecx
  8008d1:	ff d6                	call   *%esi
			break;
  8008d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d9:	e9 7c fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008de:	83 ec 08             	sub    $0x8,%esp
  8008e1:	53                   	push   %ebx
  8008e2:	6a 25                	push   $0x25
  8008e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e6:	83 c4 10             	add    $0x10,%esp
  8008e9:	eb 03                	jmp    8008ee <vprintfmt+0x3ba>
  8008eb:	83 ef 01             	sub    $0x1,%edi
  8008ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008f2:	75 f7                	jne    8008eb <vprintfmt+0x3b7>
  8008f4:	e9 61 fc ff ff       	jmp    80055a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008fc:	5b                   	pop    %ebx
  8008fd:	5e                   	pop    %esi
  8008fe:	5f                   	pop    %edi
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	83 ec 18             	sub    $0x18,%esp
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80090d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800910:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800914:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800917:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80091e:	85 c0                	test   %eax,%eax
  800920:	74 26                	je     800948 <vsnprintf+0x47>
  800922:	85 d2                	test   %edx,%edx
  800924:	7e 22                	jle    800948 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800926:	ff 75 14             	pushl  0x14(%ebp)
  800929:	ff 75 10             	pushl  0x10(%ebp)
  80092c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80092f:	50                   	push   %eax
  800930:	68 fa 04 80 00       	push   $0x8004fa
  800935:	e8 fa fb ff ff       	call   800534 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80093a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80093d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800940:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800943:	83 c4 10             	add    $0x10,%esp
  800946:	eb 05                	jmp    80094d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800948:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800955:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800958:	50                   	push   %eax
  800959:	ff 75 10             	pushl  0x10(%ebp)
  80095c:	ff 75 0c             	pushl  0xc(%ebp)
  80095f:	ff 75 08             	pushl  0x8(%ebp)
  800962:	e8 9a ff ff ff       	call   800901 <vsnprintf>
	va_end(ap);

	return rc;
}
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
  800974:	eb 03                	jmp    800979 <strlen+0x10>
		n++;
  800976:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800979:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80097d:	75 f7                	jne    800976 <strlen+0xd>
		n++;
	return n;
}
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800987:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098a:	ba 00 00 00 00       	mov    $0x0,%edx
  80098f:	eb 03                	jmp    800994 <strnlen+0x13>
		n++;
  800991:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800994:	39 c2                	cmp    %eax,%edx
  800996:	74 08                	je     8009a0 <strnlen+0x1f>
  800998:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80099c:	75 f3                	jne    800991 <strnlen+0x10>
  80099e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	83 c2 01             	add    $0x1,%edx
  8009b1:	83 c1 01             	add    $0x1,%ecx
  8009b4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009b8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009bb:	84 db                	test   %bl,%bl
  8009bd:	75 ef                	jne    8009ae <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	53                   	push   %ebx
  8009c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c9:	53                   	push   %ebx
  8009ca:	e8 9a ff ff ff       	call   800969 <strlen>
  8009cf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009d2:	ff 75 0c             	pushl  0xc(%ebp)
  8009d5:	01 d8                	add    %ebx,%eax
  8009d7:	50                   	push   %eax
  8009d8:	e8 c5 ff ff ff       	call   8009a2 <strcpy>
	return dst;
}
  8009dd:	89 d8                	mov    %ebx,%eax
  8009df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ef:	89 f3                	mov    %esi,%ebx
  8009f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f4:	89 f2                	mov    %esi,%edx
  8009f6:	eb 0f                	jmp    800a07 <strncpy+0x23>
		*dst++ = *src;
  8009f8:	83 c2 01             	add    $0x1,%edx
  8009fb:	0f b6 01             	movzbl (%ecx),%eax
  8009fe:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a01:	80 39 01             	cmpb   $0x1,(%ecx)
  800a04:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a07:	39 da                	cmp    %ebx,%edx
  800a09:	75 ed                	jne    8009f8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a0b:	89 f0                	mov    %esi,%eax
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 75 08             	mov    0x8(%ebp),%esi
  800a19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1c:	8b 55 10             	mov    0x10(%ebp),%edx
  800a1f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a21:	85 d2                	test   %edx,%edx
  800a23:	74 21                	je     800a46 <strlcpy+0x35>
  800a25:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a29:	89 f2                	mov    %esi,%edx
  800a2b:	eb 09                	jmp    800a36 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a2d:	83 c2 01             	add    $0x1,%edx
  800a30:	83 c1 01             	add    $0x1,%ecx
  800a33:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a36:	39 c2                	cmp    %eax,%edx
  800a38:	74 09                	je     800a43 <strlcpy+0x32>
  800a3a:	0f b6 19             	movzbl (%ecx),%ebx
  800a3d:	84 db                	test   %bl,%bl
  800a3f:	75 ec                	jne    800a2d <strlcpy+0x1c>
  800a41:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a43:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a46:	29 f0                	sub    %esi,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a55:	eb 06                	jmp    800a5d <strcmp+0x11>
		p++, q++;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a5d:	0f b6 01             	movzbl (%ecx),%eax
  800a60:	84 c0                	test   %al,%al
  800a62:	74 04                	je     800a68 <strcmp+0x1c>
  800a64:	3a 02                	cmp    (%edx),%al
  800a66:	74 ef                	je     800a57 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a68:	0f b6 c0             	movzbl %al,%eax
  800a6b:	0f b6 12             	movzbl (%edx),%edx
  800a6e:	29 d0                	sub    %edx,%eax
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	53                   	push   %ebx
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7c:	89 c3                	mov    %eax,%ebx
  800a7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a81:	eb 06                	jmp    800a89 <strncmp+0x17>
		n--, p++, q++;
  800a83:	83 c0 01             	add    $0x1,%eax
  800a86:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a89:	39 d8                	cmp    %ebx,%eax
  800a8b:	74 15                	je     800aa2 <strncmp+0x30>
  800a8d:	0f b6 08             	movzbl (%eax),%ecx
  800a90:	84 c9                	test   %cl,%cl
  800a92:	74 04                	je     800a98 <strncmp+0x26>
  800a94:	3a 0a                	cmp    (%edx),%cl
  800a96:	74 eb                	je     800a83 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a98:	0f b6 00             	movzbl (%eax),%eax
  800a9b:	0f b6 12             	movzbl (%edx),%edx
  800a9e:	29 d0                	sub    %edx,%eax
  800aa0:	eb 05                	jmp    800aa7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab4:	eb 07                	jmp    800abd <strchr+0x13>
		if (*s == c)
  800ab6:	38 ca                	cmp    %cl,%dl
  800ab8:	74 0f                	je     800ac9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aba:	83 c0 01             	add    $0x1,%eax
  800abd:	0f b6 10             	movzbl (%eax),%edx
  800ac0:	84 d2                	test   %dl,%dl
  800ac2:	75 f2                	jne    800ab6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad5:	eb 03                	jmp    800ada <strfind+0xf>
  800ad7:	83 c0 01             	add    $0x1,%eax
  800ada:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800add:	38 ca                	cmp    %cl,%dl
  800adf:	74 04                	je     800ae5 <strfind+0x1a>
  800ae1:	84 d2                	test   %dl,%dl
  800ae3:	75 f2                	jne    800ad7 <strfind+0xc>
			break;
	return (char *) s;
}
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af3:	85 c9                	test   %ecx,%ecx
  800af5:	74 36                	je     800b2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afd:	75 28                	jne    800b27 <memset+0x40>
  800aff:	f6 c1 03             	test   $0x3,%cl
  800b02:	75 23                	jne    800b27 <memset+0x40>
		c &= 0xFF;
  800b04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	c1 e3 08             	shl    $0x8,%ebx
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	c1 e6 18             	shl    $0x18,%esi
  800b12:	89 d0                	mov    %edx,%eax
  800b14:	c1 e0 10             	shl    $0x10,%eax
  800b17:	09 f0                	or     %esi,%eax
  800b19:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b1b:	89 d8                	mov    %ebx,%eax
  800b1d:	09 d0                	or     %edx,%eax
  800b1f:	c1 e9 02             	shr    $0x2,%ecx
  800b22:	fc                   	cld    
  800b23:	f3 ab                	rep stos %eax,%es:(%edi)
  800b25:	eb 06                	jmp    800b2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2a:	fc                   	cld    
  800b2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2d:	89 f8                	mov    %edi,%eax
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b42:	39 c6                	cmp    %eax,%esi
  800b44:	73 35                	jae    800b7b <memmove+0x47>
  800b46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b49:	39 d0                	cmp    %edx,%eax
  800b4b:	73 2e                	jae    800b7b <memmove+0x47>
		s += n;
		d += n;
  800b4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	09 fe                	or     %edi,%esi
  800b54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5a:	75 13                	jne    800b6f <memmove+0x3b>
  800b5c:	f6 c1 03             	test   $0x3,%cl
  800b5f:	75 0e                	jne    800b6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b61:	83 ef 04             	sub    $0x4,%edi
  800b64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b67:	c1 e9 02             	shr    $0x2,%ecx
  800b6a:	fd                   	std    
  800b6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6d:	eb 09                	jmp    800b78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b6f:	83 ef 01             	sub    $0x1,%edi
  800b72:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b75:	fd                   	std    
  800b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b78:	fc                   	cld    
  800b79:	eb 1d                	jmp    800b98 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7b:	89 f2                	mov    %esi,%edx
  800b7d:	09 c2                	or     %eax,%edx
  800b7f:	f6 c2 03             	test   $0x3,%dl
  800b82:	75 0f                	jne    800b93 <memmove+0x5f>
  800b84:	f6 c1 03             	test   $0x3,%cl
  800b87:	75 0a                	jne    800b93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b89:	c1 e9 02             	shr    $0x2,%ecx
  800b8c:	89 c7                	mov    %eax,%edi
  800b8e:	fc                   	cld    
  800b8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b91:	eb 05                	jmp    800b98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	fc                   	cld    
  800b96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b9f:	ff 75 10             	pushl  0x10(%ebp)
  800ba2:	ff 75 0c             	pushl  0xc(%ebp)
  800ba5:	ff 75 08             	pushl  0x8(%ebp)
  800ba8:	e8 87 ff ff ff       	call   800b34 <memmove>
}
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bba:	89 c6                	mov    %eax,%esi
  800bbc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbf:	eb 1a                	jmp    800bdb <memcmp+0x2c>
		if (*s1 != *s2)
  800bc1:	0f b6 08             	movzbl (%eax),%ecx
  800bc4:	0f b6 1a             	movzbl (%edx),%ebx
  800bc7:	38 d9                	cmp    %bl,%cl
  800bc9:	74 0a                	je     800bd5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bcb:	0f b6 c1             	movzbl %cl,%eax
  800bce:	0f b6 db             	movzbl %bl,%ebx
  800bd1:	29 d8                	sub    %ebx,%eax
  800bd3:	eb 0f                	jmp    800be4 <memcmp+0x35>
		s1++, s2++;
  800bd5:	83 c0 01             	add    $0x1,%eax
  800bd8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdb:	39 f0                	cmp    %esi,%eax
  800bdd:	75 e2                	jne    800bc1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	53                   	push   %ebx
  800bec:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bef:	89 c1                	mov    %eax,%ecx
  800bf1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf8:	eb 0a                	jmp    800c04 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bfa:	0f b6 10             	movzbl (%eax),%edx
  800bfd:	39 da                	cmp    %ebx,%edx
  800bff:	74 07                	je     800c08 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c01:	83 c0 01             	add    $0x1,%eax
  800c04:	39 c8                	cmp    %ecx,%eax
  800c06:	72 f2                	jb     800bfa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c08:	5b                   	pop    %ebx
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c17:	eb 03                	jmp    800c1c <strtol+0x11>
		s++;
  800c19:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1c:	0f b6 01             	movzbl (%ecx),%eax
  800c1f:	3c 20                	cmp    $0x20,%al
  800c21:	74 f6                	je     800c19 <strtol+0xe>
  800c23:	3c 09                	cmp    $0x9,%al
  800c25:	74 f2                	je     800c19 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c27:	3c 2b                	cmp    $0x2b,%al
  800c29:	75 0a                	jne    800c35 <strtol+0x2a>
		s++;
  800c2b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c33:	eb 11                	jmp    800c46 <strtol+0x3b>
  800c35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c3a:	3c 2d                	cmp    $0x2d,%al
  800c3c:	75 08                	jne    800c46 <strtol+0x3b>
		s++, neg = 1;
  800c3e:	83 c1 01             	add    $0x1,%ecx
  800c41:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c4c:	75 15                	jne    800c63 <strtol+0x58>
  800c4e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c51:	75 10                	jne    800c63 <strtol+0x58>
  800c53:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c57:	75 7c                	jne    800cd5 <strtol+0xca>
		s += 2, base = 16;
  800c59:	83 c1 02             	add    $0x2,%ecx
  800c5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c61:	eb 16                	jmp    800c79 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c63:	85 db                	test   %ebx,%ebx
  800c65:	75 12                	jne    800c79 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c67:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c6f:	75 08                	jne    800c79 <strtol+0x6e>
		s++, base = 8;
  800c71:	83 c1 01             	add    $0x1,%ecx
  800c74:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c79:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c81:	0f b6 11             	movzbl (%ecx),%edx
  800c84:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c87:	89 f3                	mov    %esi,%ebx
  800c89:	80 fb 09             	cmp    $0x9,%bl
  800c8c:	77 08                	ja     800c96 <strtol+0x8b>
			dig = *s - '0';
  800c8e:	0f be d2             	movsbl %dl,%edx
  800c91:	83 ea 30             	sub    $0x30,%edx
  800c94:	eb 22                	jmp    800cb8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c96:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c99:	89 f3                	mov    %esi,%ebx
  800c9b:	80 fb 19             	cmp    $0x19,%bl
  800c9e:	77 08                	ja     800ca8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ca0:	0f be d2             	movsbl %dl,%edx
  800ca3:	83 ea 57             	sub    $0x57,%edx
  800ca6:	eb 10                	jmp    800cb8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ca8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cab:	89 f3                	mov    %esi,%ebx
  800cad:	80 fb 19             	cmp    $0x19,%bl
  800cb0:	77 16                	ja     800cc8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cb2:	0f be d2             	movsbl %dl,%edx
  800cb5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cb8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cbb:	7d 0b                	jge    800cc8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cbd:	83 c1 01             	add    $0x1,%ecx
  800cc0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cc4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cc6:	eb b9                	jmp    800c81 <strtol+0x76>

	if (endptr)
  800cc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ccc:	74 0d                	je     800cdb <strtol+0xd0>
		*endptr = (char *) s;
  800cce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd1:	89 0e                	mov    %ecx,(%esi)
  800cd3:	eb 06                	jmp    800cdb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd5:	85 db                	test   %ebx,%ebx
  800cd7:	74 98                	je     800c71 <strtol+0x66>
  800cd9:	eb 9e                	jmp    800c79 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cdb:	89 c2                	mov    %eax,%edx
  800cdd:	f7 da                	neg    %edx
  800cdf:	85 ff                	test   %edi,%edi
  800ce1:	0f 45 c2             	cmovne %edx,%eax
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	89 c3                	mov    %eax,%ebx
  800cfc:	89 c7                	mov    %eax,%edi
  800cfe:	89 c6                	mov    %eax,%esi
  800d00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d12:	b8 01 00 00 00       	mov    $0x1,%eax
  800d17:	89 d1                	mov    %edx,%ecx
  800d19:	89 d3                	mov    %edx,%ebx
  800d1b:	89 d7                	mov    %edx,%edi
  800d1d:	89 d6                	mov    %edx,%esi
  800d1f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d34:	b8 03 00 00 00       	mov    $0x3,%eax
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	89 cb                	mov    %ecx,%ebx
  800d3e:	89 cf                	mov    %ecx,%edi
  800d40:	89 ce                	mov    %ecx,%esi
  800d42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 03                	push   $0x3
  800d4e:	68 ff 2a 80 00       	push   $0x802aff
  800d53:	6a 23                	push   $0x23
  800d55:	68 1c 2b 80 00       	push   $0x802b1c
  800d5a:	e8 c5 f5 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d72:	b8 02 00 00 00       	mov    $0x2,%eax
  800d77:	89 d1                	mov    %edx,%ecx
  800d79:	89 d3                	mov    %edx,%ebx
  800d7b:	89 d7                	mov    %edx,%edi
  800d7d:	89 d6                	mov    %edx,%esi
  800d7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_yield>:

void
sys_yield(void)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d96:	89 d1                	mov    %edx,%ecx
  800d98:	89 d3                	mov    %edx,%ebx
  800d9a:	89 d7                	mov    %edx,%edi
  800d9c:	89 d6                	mov    %edx,%esi
  800d9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	be 00 00 00 00       	mov    $0x0,%esi
  800db3:	b8 04 00 00 00       	mov    $0x4,%eax
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc1:	89 f7                	mov    %esi,%edi
  800dc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	7e 17                	jle    800de0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	50                   	push   %eax
  800dcd:	6a 04                	push   $0x4
  800dcf:	68 ff 2a 80 00       	push   $0x802aff
  800dd4:	6a 23                	push   $0x23
  800dd6:	68 1c 2b 80 00       	push   $0x802b1c
  800ddb:	e8 44 f5 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	b8 05 00 00 00       	mov    $0x5,%eax
  800df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e02:	8b 75 18             	mov    0x18(%ebp),%esi
  800e05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 05                	push   $0x5
  800e11:	68 ff 2a 80 00       	push   $0x802aff
  800e16:	6a 23                	push   $0x23
  800e18:	68 1c 2b 80 00       	push   $0x802b1c
  800e1d:	e8 02 f5 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e38:	b8 06 00 00 00       	mov    $0x6,%eax
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	89 df                	mov    %ebx,%edi
  800e45:	89 de                	mov    %ebx,%esi
  800e47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7e 17                	jle    800e64 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	50                   	push   %eax
  800e51:	6a 06                	push   $0x6
  800e53:	68 ff 2a 80 00       	push   $0x802aff
  800e58:	6a 23                	push   $0x23
  800e5a:	68 1c 2b 80 00       	push   $0x802b1c
  800e5f:	e8 c0 f4 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800e75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7a:	b8 08 00 00 00       	mov    $0x8,%eax
  800e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
  800e85:	89 df                	mov    %ebx,%edi
  800e87:	89 de                	mov    %ebx,%esi
  800e89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	7e 17                	jle    800ea6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8f:	83 ec 0c             	sub    $0xc,%esp
  800e92:	50                   	push   %eax
  800e93:	6a 08                	push   $0x8
  800e95:	68 ff 2a 80 00       	push   $0x802aff
  800e9a:	6a 23                	push   $0x23
  800e9c:	68 1c 2b 80 00       	push   $0x802b1c
  800ea1:	e8 7e f4 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea9:	5b                   	pop    %ebx
  800eaa:	5e                   	pop    %esi
  800eab:	5f                   	pop    %edi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebc:	b8 09 00 00 00       	mov    $0x9,%eax
  800ec1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	89 df                	mov    %ebx,%edi
  800ec9:	89 de                	mov    %ebx,%esi
  800ecb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	7e 17                	jle    800ee8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed1:	83 ec 0c             	sub    $0xc,%esp
  800ed4:	50                   	push   %eax
  800ed5:	6a 09                	push   $0x9
  800ed7:	68 ff 2a 80 00       	push   $0x802aff
  800edc:	6a 23                	push   $0x23
  800ede:	68 1c 2b 80 00       	push   $0x802b1c
  800ee3:	e8 3c f4 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ee8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f06:	8b 55 08             	mov    0x8(%ebp),%edx
  800f09:	89 df                	mov    %ebx,%edi
  800f0b:	89 de                	mov    %ebx,%esi
  800f0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	7e 17                	jle    800f2a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f13:	83 ec 0c             	sub    $0xc,%esp
  800f16:	50                   	push   %eax
  800f17:	6a 0a                	push   $0xa
  800f19:	68 ff 2a 80 00       	push   $0x802aff
  800f1e:	6a 23                	push   $0x23
  800f20:	68 1c 2b 80 00       	push   $0x802b1c
  800f25:	e8 fa f3 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f38:	be 00 00 00 00       	mov    $0x0,%esi
  800f3d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f45:	8b 55 08             	mov    0x8(%ebp),%edx
  800f48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f4e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	57                   	push   %edi
  800f59:	56                   	push   %esi
  800f5a:	53                   	push   %ebx
  800f5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f63:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f68:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6b:	89 cb                	mov    %ecx,%ebx
  800f6d:	89 cf                	mov    %ecx,%edi
  800f6f:	89 ce                	mov    %ecx,%esi
  800f71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	7e 17                	jle    800f8e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f77:	83 ec 0c             	sub    $0xc,%esp
  800f7a:	50                   	push   %eax
  800f7b:	6a 0d                	push   $0xd
  800f7d:	68 ff 2a 80 00       	push   $0x802aff
  800f82:	6a 23                	push   $0x23
  800f84:	68 1c 2b 80 00       	push   $0x802b1c
  800f89:	e8 96 f3 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fa6:	89 d1                	mov    %edx,%ecx
  800fa8:	89 d3                	mov    %edx,%ebx
  800faa:	89 d7                	mov    %edx,%edi
  800fac:	89 d6                	mov    %edx,%esi
  800fae:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    

00800fb5 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbe:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800fc1:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800fc3:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800fc6:	83 3a 01             	cmpl   $0x1,(%edx)
  800fc9:	7e 09                	jle    800fd4 <argstart+0x1f>
  800fcb:	ba a8 27 80 00       	mov    $0x8027a8,%edx
  800fd0:	85 c9                	test   %ecx,%ecx
  800fd2:	75 05                	jne    800fd9 <argstart+0x24>
  800fd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd9:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800fdc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    

00800fe5 <argnext>:

int
argnext(struct Argstate *args)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 04             	sub    $0x4,%esp
  800fec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800fef:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800ff6:	8b 43 08             	mov    0x8(%ebx),%eax
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	74 6f                	je     80106c <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800ffd:	80 38 00             	cmpb   $0x0,(%eax)
  801000:	75 4e                	jne    801050 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801002:	8b 0b                	mov    (%ebx),%ecx
  801004:	83 39 01             	cmpl   $0x1,(%ecx)
  801007:	74 55                	je     80105e <argnext+0x79>
		    || args->argv[1][0] != '-'
  801009:	8b 53 04             	mov    0x4(%ebx),%edx
  80100c:	8b 42 04             	mov    0x4(%edx),%eax
  80100f:	80 38 2d             	cmpb   $0x2d,(%eax)
  801012:	75 4a                	jne    80105e <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801014:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801018:	74 44                	je     80105e <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80101a:	83 c0 01             	add    $0x1,%eax
  80101d:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801020:	83 ec 04             	sub    $0x4,%esp
  801023:	8b 01                	mov    (%ecx),%eax
  801025:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80102c:	50                   	push   %eax
  80102d:	8d 42 08             	lea    0x8(%edx),%eax
  801030:	50                   	push   %eax
  801031:	83 c2 04             	add    $0x4,%edx
  801034:	52                   	push   %edx
  801035:	e8 fa fa ff ff       	call   800b34 <memmove>
		(*args->argc)--;
  80103a:	8b 03                	mov    (%ebx),%eax
  80103c:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80103f:	8b 43 08             	mov    0x8(%ebx),%eax
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	80 38 2d             	cmpb   $0x2d,(%eax)
  801048:	75 06                	jne    801050 <argnext+0x6b>
  80104a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80104e:	74 0e                	je     80105e <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801050:	8b 53 08             	mov    0x8(%ebx),%edx
  801053:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801056:	83 c2 01             	add    $0x1,%edx
  801059:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80105c:	eb 13                	jmp    801071 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  80105e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801065:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80106a:	eb 05                	jmp    801071 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80106c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801071:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	53                   	push   %ebx
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801080:	8b 43 08             	mov    0x8(%ebx),%eax
  801083:	85 c0                	test   %eax,%eax
  801085:	74 58                	je     8010df <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801087:	80 38 00             	cmpb   $0x0,(%eax)
  80108a:	74 0c                	je     801098 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80108c:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  80108f:	c7 43 08 a8 27 80 00 	movl   $0x8027a8,0x8(%ebx)
  801096:	eb 42                	jmp    8010da <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801098:	8b 13                	mov    (%ebx),%edx
  80109a:	83 3a 01             	cmpl   $0x1,(%edx)
  80109d:	7e 2d                	jle    8010cc <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  80109f:	8b 43 04             	mov    0x4(%ebx),%eax
  8010a2:	8b 48 04             	mov    0x4(%eax),%ecx
  8010a5:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8010a8:	83 ec 04             	sub    $0x4,%esp
  8010ab:	8b 12                	mov    (%edx),%edx
  8010ad:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8010b4:	52                   	push   %edx
  8010b5:	8d 50 08             	lea    0x8(%eax),%edx
  8010b8:	52                   	push   %edx
  8010b9:	83 c0 04             	add    $0x4,%eax
  8010bc:	50                   	push   %eax
  8010bd:	e8 72 fa ff ff       	call   800b34 <memmove>
		(*args->argc)--;
  8010c2:	8b 03                	mov    (%ebx),%eax
  8010c4:	83 28 01             	subl   $0x1,(%eax)
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	eb 0e                	jmp    8010da <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8010cc:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8010d3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8010da:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010dd:	eb 05                	jmp    8010e4 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8010df:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8010e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e7:	c9                   	leave  
  8010e8:	c3                   	ret    

008010e9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	83 ec 08             	sub    $0x8,%esp
  8010ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8010f2:	8b 51 0c             	mov    0xc(%ecx),%edx
  8010f5:	89 d0                	mov    %edx,%eax
  8010f7:	85 d2                	test   %edx,%edx
  8010f9:	75 0c                	jne    801107 <argvalue+0x1e>
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	51                   	push   %ecx
  8010ff:	e8 72 ff ff ff       	call   801076 <argnextvalue>
  801104:	83 c4 10             	add    $0x10,%esp
}
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80110c:	8b 45 08             	mov    0x8(%ebp),%eax
  80110f:	05 00 00 00 30       	add    $0x30000000,%eax
  801114:	c1 e8 0c             	shr    $0xc,%eax
}
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80111c:	8b 45 08             	mov    0x8(%ebp),%eax
  80111f:	05 00 00 00 30       	add    $0x30000000,%eax
  801124:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801129:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801136:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	c1 ea 16             	shr    $0x16,%edx
  801140:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801147:	f6 c2 01             	test   $0x1,%dl
  80114a:	74 11                	je     80115d <fd_alloc+0x2d>
  80114c:	89 c2                	mov    %eax,%edx
  80114e:	c1 ea 0c             	shr    $0xc,%edx
  801151:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801158:	f6 c2 01             	test   $0x1,%dl
  80115b:	75 09                	jne    801166 <fd_alloc+0x36>
			*fd_store = fd;
  80115d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80115f:	b8 00 00 00 00       	mov    $0x0,%eax
  801164:	eb 17                	jmp    80117d <fd_alloc+0x4d>
  801166:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80116b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801170:	75 c9                	jne    80113b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801172:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801178:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801185:	83 f8 1f             	cmp    $0x1f,%eax
  801188:	77 36                	ja     8011c0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80118a:	c1 e0 0c             	shl    $0xc,%eax
  80118d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801192:	89 c2                	mov    %eax,%edx
  801194:	c1 ea 16             	shr    $0x16,%edx
  801197:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	74 24                	je     8011c7 <fd_lookup+0x48>
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	c1 ea 0c             	shr    $0xc,%edx
  8011a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011af:	f6 c2 01             	test   $0x1,%dl
  8011b2:	74 1a                	je     8011ce <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b7:	89 02                	mov    %eax,(%edx)
	return 0;
  8011b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011be:	eb 13                	jmp    8011d3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c5:	eb 0c                	jmp    8011d3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011cc:	eb 05                	jmp    8011d3 <fd_lookup+0x54>
  8011ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011de:	ba ac 2b 80 00       	mov    $0x802bac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011e3:	eb 13                	jmp    8011f8 <dev_lookup+0x23>
  8011e5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011e8:	39 08                	cmp    %ecx,(%eax)
  8011ea:	75 0c                	jne    8011f8 <dev_lookup+0x23>
			*dev = devtab[i];
  8011ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ef:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f6:	eb 2e                	jmp    801226 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011f8:	8b 02                	mov    (%edx),%eax
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	75 e7                	jne    8011e5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011fe:	a1 20 44 80 00       	mov    0x804420,%eax
  801203:	8b 40 48             	mov    0x48(%eax),%eax
  801206:	83 ec 04             	sub    $0x4,%esp
  801209:	51                   	push   %ecx
  80120a:	50                   	push   %eax
  80120b:	68 2c 2b 80 00       	push   $0x802b2c
  801210:	e8 e8 f1 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  801215:	8b 45 0c             	mov    0xc(%ebp),%eax
  801218:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	56                   	push   %esi
  80122c:	53                   	push   %ebx
  80122d:	83 ec 10             	sub    $0x10,%esp
  801230:	8b 75 08             	mov    0x8(%ebp),%esi
  801233:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801236:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801239:	50                   	push   %eax
  80123a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801240:	c1 e8 0c             	shr    $0xc,%eax
  801243:	50                   	push   %eax
  801244:	e8 36 ff ff ff       	call   80117f <fd_lookup>
  801249:	83 c4 08             	add    $0x8,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 05                	js     801255 <fd_close+0x2d>
	    || fd != fd2)
  801250:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801253:	74 0c                	je     801261 <fd_close+0x39>
		return (must_exist ? r : 0);
  801255:	84 db                	test   %bl,%bl
  801257:	ba 00 00 00 00       	mov    $0x0,%edx
  80125c:	0f 44 c2             	cmove  %edx,%eax
  80125f:	eb 41                	jmp    8012a2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	ff 36                	pushl  (%esi)
  80126a:	e8 66 ff ff ff       	call   8011d5 <dev_lookup>
  80126f:	89 c3                	mov    %eax,%ebx
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	78 1a                	js     801292 <fd_close+0x6a>
		if (dev->dev_close)
  801278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80127e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801283:	85 c0                	test   %eax,%eax
  801285:	74 0b                	je     801292 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801287:	83 ec 0c             	sub    $0xc,%esp
  80128a:	56                   	push   %esi
  80128b:	ff d0                	call   *%eax
  80128d:	89 c3                	mov    %eax,%ebx
  80128f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	56                   	push   %esi
  801296:	6a 00                	push   $0x0
  801298:	e8 8d fb ff ff       	call   800e2a <sys_page_unmap>
	return r;
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	89 d8                	mov    %ebx,%eax
}
  8012a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5e                   	pop    %esi
  8012a7:	5d                   	pop    %ebp
  8012a8:	c3                   	ret    

008012a9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b2:	50                   	push   %eax
  8012b3:	ff 75 08             	pushl  0x8(%ebp)
  8012b6:	e8 c4 fe ff ff       	call   80117f <fd_lookup>
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 10                	js     8012d2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	6a 01                	push   $0x1
  8012c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ca:	e8 59 ff ff ff       	call   801228 <fd_close>
  8012cf:	83 c4 10             	add    $0x10,%esp
}
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <close_all>:

void
close_all(void)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012db:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012e0:	83 ec 0c             	sub    $0xc,%esp
  8012e3:	53                   	push   %ebx
  8012e4:	e8 c0 ff ff ff       	call   8012a9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e9:	83 c3 01             	add    $0x1,%ebx
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	83 fb 20             	cmp    $0x20,%ebx
  8012f2:	75 ec                	jne    8012e0 <close_all+0xc>
		close(i);
}
  8012f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f7:	c9                   	leave  
  8012f8:	c3                   	ret    

008012f9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	57                   	push   %edi
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	83 ec 2c             	sub    $0x2c,%esp
  801302:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801305:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801308:	50                   	push   %eax
  801309:	ff 75 08             	pushl  0x8(%ebp)
  80130c:	e8 6e fe ff ff       	call   80117f <fd_lookup>
  801311:	83 c4 08             	add    $0x8,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	0f 88 c1 00 00 00    	js     8013dd <dup+0xe4>
		return r;
	close(newfdnum);
  80131c:	83 ec 0c             	sub    $0xc,%esp
  80131f:	56                   	push   %esi
  801320:	e8 84 ff ff ff       	call   8012a9 <close>

	newfd = INDEX2FD(newfdnum);
  801325:	89 f3                	mov    %esi,%ebx
  801327:	c1 e3 0c             	shl    $0xc,%ebx
  80132a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801330:	83 c4 04             	add    $0x4,%esp
  801333:	ff 75 e4             	pushl  -0x1c(%ebp)
  801336:	e8 de fd ff ff       	call   801119 <fd2data>
  80133b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80133d:	89 1c 24             	mov    %ebx,(%esp)
  801340:	e8 d4 fd ff ff       	call   801119 <fd2data>
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80134b:	89 f8                	mov    %edi,%eax
  80134d:	c1 e8 16             	shr    $0x16,%eax
  801350:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801357:	a8 01                	test   $0x1,%al
  801359:	74 37                	je     801392 <dup+0x99>
  80135b:	89 f8                	mov    %edi,%eax
  80135d:	c1 e8 0c             	shr    $0xc,%eax
  801360:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801367:	f6 c2 01             	test   $0x1,%dl
  80136a:	74 26                	je     801392 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80136c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801373:	83 ec 0c             	sub    $0xc,%esp
  801376:	25 07 0e 00 00       	and    $0xe07,%eax
  80137b:	50                   	push   %eax
  80137c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80137f:	6a 00                	push   $0x0
  801381:	57                   	push   %edi
  801382:	6a 00                	push   $0x0
  801384:	e8 5f fa ff ff       	call   800de8 <sys_page_map>
  801389:	89 c7                	mov    %eax,%edi
  80138b:	83 c4 20             	add    $0x20,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 2e                	js     8013c0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801392:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801395:	89 d0                	mov    %edx,%eax
  801397:	c1 e8 0c             	shr    $0xc,%eax
  80139a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a1:	83 ec 0c             	sub    $0xc,%esp
  8013a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a9:	50                   	push   %eax
  8013aa:	53                   	push   %ebx
  8013ab:	6a 00                	push   $0x0
  8013ad:	52                   	push   %edx
  8013ae:	6a 00                	push   $0x0
  8013b0:	e8 33 fa ff ff       	call   800de8 <sys_page_map>
  8013b5:	89 c7                	mov    %eax,%edi
  8013b7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ba:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013bc:	85 ff                	test   %edi,%edi
  8013be:	79 1d                	jns    8013dd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	53                   	push   %ebx
  8013c4:	6a 00                	push   $0x0
  8013c6:	e8 5f fa ff ff       	call   800e2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d1:	6a 00                	push   $0x0
  8013d3:	e8 52 fa ff ff       	call   800e2a <sys_page_unmap>
	return r;
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	89 f8                	mov    %edi,%eax
}
  8013dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 14             	sub    $0x14,%esp
  8013ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f2:	50                   	push   %eax
  8013f3:	53                   	push   %ebx
  8013f4:	e8 86 fd ff ff       	call   80117f <fd_lookup>
  8013f9:	83 c4 08             	add    $0x8,%esp
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 6d                	js     80146f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140c:	ff 30                	pushl  (%eax)
  80140e:	e8 c2 fd ff ff       	call   8011d5 <dev_lookup>
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 4c                	js     801466 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80141a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80141d:	8b 42 08             	mov    0x8(%edx),%eax
  801420:	83 e0 03             	and    $0x3,%eax
  801423:	83 f8 01             	cmp    $0x1,%eax
  801426:	75 21                	jne    801449 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801428:	a1 20 44 80 00       	mov    0x804420,%eax
  80142d:	8b 40 48             	mov    0x48(%eax),%eax
  801430:	83 ec 04             	sub    $0x4,%esp
  801433:	53                   	push   %ebx
  801434:	50                   	push   %eax
  801435:	68 70 2b 80 00       	push   $0x802b70
  80143a:	e8 be ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801447:	eb 26                	jmp    80146f <read+0x8a>
	}
	if (!dev->dev_read)
  801449:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144c:	8b 40 08             	mov    0x8(%eax),%eax
  80144f:	85 c0                	test   %eax,%eax
  801451:	74 17                	je     80146a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801453:	83 ec 04             	sub    $0x4,%esp
  801456:	ff 75 10             	pushl  0x10(%ebp)
  801459:	ff 75 0c             	pushl  0xc(%ebp)
  80145c:	52                   	push   %edx
  80145d:	ff d0                	call   *%eax
  80145f:	89 c2                	mov    %eax,%edx
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	eb 09                	jmp    80146f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801466:	89 c2                	mov    %eax,%edx
  801468:	eb 05                	jmp    80146f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80146a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80146f:	89 d0                	mov    %edx,%eax
  801471:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801474:	c9                   	leave  
  801475:	c3                   	ret    

00801476 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	57                   	push   %edi
  80147a:	56                   	push   %esi
  80147b:	53                   	push   %ebx
  80147c:	83 ec 0c             	sub    $0xc,%esp
  80147f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801482:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801485:	bb 00 00 00 00       	mov    $0x0,%ebx
  80148a:	eb 21                	jmp    8014ad <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	89 f0                	mov    %esi,%eax
  801491:	29 d8                	sub    %ebx,%eax
  801493:	50                   	push   %eax
  801494:	89 d8                	mov    %ebx,%eax
  801496:	03 45 0c             	add    0xc(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	57                   	push   %edi
  80149b:	e8 45 ff ff ff       	call   8013e5 <read>
		if (m < 0)
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 10                	js     8014b7 <readn+0x41>
			return m;
		if (m == 0)
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	74 0a                	je     8014b5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ab:	01 c3                	add    %eax,%ebx
  8014ad:	39 f3                	cmp    %esi,%ebx
  8014af:	72 db                	jb     80148c <readn+0x16>
  8014b1:	89 d8                	mov    %ebx,%eax
  8014b3:	eb 02                	jmp    8014b7 <readn+0x41>
  8014b5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ba:	5b                   	pop    %ebx
  8014bb:	5e                   	pop    %esi
  8014bc:	5f                   	pop    %edi
  8014bd:	5d                   	pop    %ebp
  8014be:	c3                   	ret    

008014bf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 14             	sub    $0x14,%esp
  8014c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	53                   	push   %ebx
  8014ce:	e8 ac fc ff ff       	call   80117f <fd_lookup>
  8014d3:	83 c4 08             	add    $0x8,%esp
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	78 68                	js     801544 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e2:	50                   	push   %eax
  8014e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e6:	ff 30                	pushl  (%eax)
  8014e8:	e8 e8 fc ff ff       	call   8011d5 <dev_lookup>
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 47                	js     80153b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014fb:	75 21                	jne    80151e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014fd:	a1 20 44 80 00       	mov    0x804420,%eax
  801502:	8b 40 48             	mov    0x48(%eax),%eax
  801505:	83 ec 04             	sub    $0x4,%esp
  801508:	53                   	push   %ebx
  801509:	50                   	push   %eax
  80150a:	68 8c 2b 80 00       	push   $0x802b8c
  80150f:	e8 e9 ee ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151c:	eb 26                	jmp    801544 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80151e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801521:	8b 52 0c             	mov    0xc(%edx),%edx
  801524:	85 d2                	test   %edx,%edx
  801526:	74 17                	je     80153f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801528:	83 ec 04             	sub    $0x4,%esp
  80152b:	ff 75 10             	pushl  0x10(%ebp)
  80152e:	ff 75 0c             	pushl  0xc(%ebp)
  801531:	50                   	push   %eax
  801532:	ff d2                	call   *%edx
  801534:	89 c2                	mov    %eax,%edx
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	eb 09                	jmp    801544 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153b:	89 c2                	mov    %eax,%edx
  80153d:	eb 05                	jmp    801544 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80153f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801544:	89 d0                	mov    %edx,%eax
  801546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <seek>:

int
seek(int fdnum, off_t offset)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801551:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	ff 75 08             	pushl  0x8(%ebp)
  801558:	e8 22 fc ff ff       	call   80117f <fd_lookup>
  80155d:	83 c4 08             	add    $0x8,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	78 0e                	js     801572 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801564:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801567:	8b 55 0c             	mov    0xc(%ebp),%edx
  80156a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80156d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801572:	c9                   	leave  
  801573:	c3                   	ret    

00801574 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	53                   	push   %ebx
  801578:	83 ec 14             	sub    $0x14,%esp
  80157b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	53                   	push   %ebx
  801583:	e8 f7 fb ff ff       	call   80117f <fd_lookup>
  801588:	83 c4 08             	add    $0x8,%esp
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 65                	js     8015f6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	ff 30                	pushl  (%eax)
  80159d:	e8 33 fc ff ff       	call   8011d5 <dev_lookup>
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 44                	js     8015ed <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b0:	75 21                	jne    8015d3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015b2:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015b7:	8b 40 48             	mov    0x48(%eax),%eax
  8015ba:	83 ec 04             	sub    $0x4,%esp
  8015bd:	53                   	push   %ebx
  8015be:	50                   	push   %eax
  8015bf:	68 4c 2b 80 00       	push   $0x802b4c
  8015c4:	e8 34 ee ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d1:	eb 23                	jmp    8015f6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d6:	8b 52 18             	mov    0x18(%edx),%edx
  8015d9:	85 d2                	test   %edx,%edx
  8015db:	74 14                	je     8015f1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	ff 75 0c             	pushl  0xc(%ebp)
  8015e3:	50                   	push   %eax
  8015e4:	ff d2                	call   *%edx
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	eb 09                	jmp    8015f6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	eb 05                	jmp    8015f6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015f6:	89 d0                	mov    %edx,%eax
  8015f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	53                   	push   %ebx
  801601:	83 ec 14             	sub    $0x14,%esp
  801604:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801607:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160a:	50                   	push   %eax
  80160b:	ff 75 08             	pushl  0x8(%ebp)
  80160e:	e8 6c fb ff ff       	call   80117f <fd_lookup>
  801613:	83 c4 08             	add    $0x8,%esp
  801616:	89 c2                	mov    %eax,%edx
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 58                	js     801674 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801626:	ff 30                	pushl  (%eax)
  801628:	e8 a8 fb ff ff       	call   8011d5 <dev_lookup>
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	85 c0                	test   %eax,%eax
  801632:	78 37                	js     80166b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801634:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801637:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80163b:	74 32                	je     80166f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80163d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801640:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801647:	00 00 00 
	stat->st_isdir = 0;
  80164a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801651:	00 00 00 
	stat->st_dev = dev;
  801654:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	53                   	push   %ebx
  80165e:	ff 75 f0             	pushl  -0x10(%ebp)
  801661:	ff 50 14             	call   *0x14(%eax)
  801664:	89 c2                	mov    %eax,%edx
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	eb 09                	jmp    801674 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	eb 05                	jmp    801674 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80166f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801674:	89 d0                	mov    %edx,%eax
  801676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	56                   	push   %esi
  80167f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	6a 00                	push   $0x0
  801685:	ff 75 08             	pushl  0x8(%ebp)
  801688:	e8 ef 01 00 00       	call   80187c <open>
  80168d:	89 c3                	mov    %eax,%ebx
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 1b                	js     8016b1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	50                   	push   %eax
  80169d:	e8 5b ff ff ff       	call   8015fd <fstat>
  8016a2:	89 c6                	mov    %eax,%esi
	close(fd);
  8016a4:	89 1c 24             	mov    %ebx,(%esp)
  8016a7:	e8 fd fb ff ff       	call   8012a9 <close>
	return r;
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	89 f0                	mov    %esi,%eax
}
  8016b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b4:	5b                   	pop    %ebx
  8016b5:	5e                   	pop    %esi
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	56                   	push   %esi
  8016bc:	53                   	push   %ebx
  8016bd:	89 c6                	mov    %eax,%esi
  8016bf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016c1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016c8:	75 12                	jne    8016dc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ca:	83 ec 0c             	sub    $0xc,%esp
  8016cd:	6a 01                	push   $0x1
  8016cf:	e8 67 0d 00 00       	call   80243b <ipc_find_env>
  8016d4:	a3 00 40 80 00       	mov    %eax,0x804000
  8016d9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016dc:	6a 07                	push   $0x7
  8016de:	68 00 50 80 00       	push   $0x805000
  8016e3:	56                   	push   %esi
  8016e4:	ff 35 00 40 80 00    	pushl  0x804000
  8016ea:	e8 fd 0c 00 00       	call   8023ec <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016ef:	83 c4 0c             	add    $0xc,%esp
  8016f2:	6a 00                	push   $0x0
  8016f4:	53                   	push   %ebx
  8016f5:	6a 00                	push   $0x0
  8016f7:	e8 7a 0c 00 00       	call   802376 <ipc_recv>
}
  8016fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ff:	5b                   	pop    %ebx
  801700:	5e                   	pop    %esi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801709:	8b 45 08             	mov    0x8(%ebp),%eax
  80170c:	8b 40 0c             	mov    0xc(%eax),%eax
  80170f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801714:	8b 45 0c             	mov    0xc(%ebp),%eax
  801717:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80171c:	ba 00 00 00 00       	mov    $0x0,%edx
  801721:	b8 02 00 00 00       	mov    $0x2,%eax
  801726:	e8 8d ff ff ff       	call   8016b8 <fsipc>
}
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801733:	8b 45 08             	mov    0x8(%ebp),%eax
  801736:	8b 40 0c             	mov    0xc(%eax),%eax
  801739:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80173e:	ba 00 00 00 00       	mov    $0x0,%edx
  801743:	b8 06 00 00 00       	mov    $0x6,%eax
  801748:	e8 6b ff ff ff       	call   8016b8 <fsipc>
}
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	53                   	push   %ebx
  801753:	83 ec 04             	sub    $0x4,%esp
  801756:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801759:	8b 45 08             	mov    0x8(%ebp),%eax
  80175c:	8b 40 0c             	mov    0xc(%eax),%eax
  80175f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801764:	ba 00 00 00 00       	mov    $0x0,%edx
  801769:	b8 05 00 00 00       	mov    $0x5,%eax
  80176e:	e8 45 ff ff ff       	call   8016b8 <fsipc>
  801773:	85 c0                	test   %eax,%eax
  801775:	78 2c                	js     8017a3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801777:	83 ec 08             	sub    $0x8,%esp
  80177a:	68 00 50 80 00       	push   $0x805000
  80177f:	53                   	push   %ebx
  801780:	e8 1d f2 ff ff       	call   8009a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801785:	a1 80 50 80 00       	mov    0x805080,%eax
  80178a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801790:	a1 84 50 80 00       	mov    0x805084,%eax
  801795:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	53                   	push   %ebx
  8017ac:	83 ec 08             	sub    $0x8,%esp
  8017af:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b5:	8b 52 0c             	mov    0xc(%edx),%edx
  8017b8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017be:	a3 04 50 80 00       	mov    %eax,0x805004
  8017c3:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8017c8:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8017cd:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017d0:	53                   	push   %ebx
  8017d1:	ff 75 0c             	pushl  0xc(%ebp)
  8017d4:	68 08 50 80 00       	push   $0x805008
  8017d9:	e8 56 f3 ff ff       	call   800b34 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8017de:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e3:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e8:	e8 cb fe ff ff       	call   8016b8 <fsipc>
  8017ed:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8017f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    

008017fa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	56                   	push   %esi
  8017fe:	53                   	push   %ebx
  8017ff:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	8b 40 0c             	mov    0xc(%eax),%eax
  801808:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80180d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801813:	ba 00 00 00 00       	mov    $0x0,%edx
  801818:	b8 03 00 00 00       	mov    $0x3,%eax
  80181d:	e8 96 fe ff ff       	call   8016b8 <fsipc>
  801822:	89 c3                	mov    %eax,%ebx
  801824:	85 c0                	test   %eax,%eax
  801826:	78 4b                	js     801873 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801828:	39 c6                	cmp    %eax,%esi
  80182a:	73 16                	jae    801842 <devfile_read+0x48>
  80182c:	68 c0 2b 80 00       	push   $0x802bc0
  801831:	68 c7 2b 80 00       	push   $0x802bc7
  801836:	6a 7c                	push   $0x7c
  801838:	68 dc 2b 80 00       	push   $0x802bdc
  80183d:	e8 e2 ea ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  801842:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801847:	7e 16                	jle    80185f <devfile_read+0x65>
  801849:	68 e7 2b 80 00       	push   $0x802be7
  80184e:	68 c7 2b 80 00       	push   $0x802bc7
  801853:	6a 7d                	push   $0x7d
  801855:	68 dc 2b 80 00       	push   $0x802bdc
  80185a:	e8 c5 ea ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80185f:	83 ec 04             	sub    $0x4,%esp
  801862:	50                   	push   %eax
  801863:	68 00 50 80 00       	push   $0x805000
  801868:	ff 75 0c             	pushl  0xc(%ebp)
  80186b:	e8 c4 f2 ff ff       	call   800b34 <memmove>
	return r;
  801870:	83 c4 10             	add    $0x10,%esp
}
  801873:	89 d8                	mov    %ebx,%eax
  801875:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	53                   	push   %ebx
  801880:	83 ec 20             	sub    $0x20,%esp
  801883:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801886:	53                   	push   %ebx
  801887:	e8 dd f0 ff ff       	call   800969 <strlen>
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801894:	7f 67                	jg     8018fd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801896:	83 ec 0c             	sub    $0xc,%esp
  801899:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189c:	50                   	push   %eax
  80189d:	e8 8e f8 ff ff       	call   801130 <fd_alloc>
  8018a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8018a5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	78 57                	js     801902 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018ab:	83 ec 08             	sub    $0x8,%esp
  8018ae:	53                   	push   %ebx
  8018af:	68 00 50 80 00       	push   $0x805000
  8018b4:	e8 e9 f0 ff ff       	call   8009a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c9:	e8 ea fd ff ff       	call   8016b8 <fsipc>
  8018ce:	89 c3                	mov    %eax,%ebx
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	79 14                	jns    8018eb <open+0x6f>
		fd_close(fd, 0);
  8018d7:	83 ec 08             	sub    $0x8,%esp
  8018da:	6a 00                	push   $0x0
  8018dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8018df:	e8 44 f9 ff ff       	call   801228 <fd_close>
		return r;
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	89 da                	mov    %ebx,%edx
  8018e9:	eb 17                	jmp    801902 <open+0x86>
	}

	return fd2num(fd);
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f1:	e8 13 f8 ff ff       	call   801109 <fd2num>
  8018f6:	89 c2                	mov    %eax,%edx
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	eb 05                	jmp    801902 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018fd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801902:	89 d0                	mov    %edx,%eax
  801904:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801907:	c9                   	leave  
  801908:	c3                   	ret    

00801909 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80190f:	ba 00 00 00 00       	mov    $0x0,%edx
  801914:	b8 08 00 00 00       	mov    $0x8,%eax
  801919:	e8 9a fd ff ff       	call   8016b8 <fsipc>
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801920:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801924:	7e 37                	jle    80195d <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	53                   	push   %ebx
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80192f:	ff 70 04             	pushl  0x4(%eax)
  801932:	8d 40 10             	lea    0x10(%eax),%eax
  801935:	50                   	push   %eax
  801936:	ff 33                	pushl  (%ebx)
  801938:	e8 82 fb ff ff       	call   8014bf <write>
		if (result > 0)
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	85 c0                	test   %eax,%eax
  801942:	7e 03                	jle    801947 <writebuf+0x27>
			b->result += result;
  801944:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801947:	3b 43 04             	cmp    0x4(%ebx),%eax
  80194a:	74 0d                	je     801959 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80194c:	85 c0                	test   %eax,%eax
  80194e:	ba 00 00 00 00       	mov    $0x0,%edx
  801953:	0f 4f c2             	cmovg  %edx,%eax
  801956:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801959:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195c:	c9                   	leave  
  80195d:	f3 c3                	repz ret 

0080195f <putch>:

static void
putch(int ch, void *thunk)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	53                   	push   %ebx
  801963:	83 ec 04             	sub    $0x4,%esp
  801966:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801969:	8b 53 04             	mov    0x4(%ebx),%edx
  80196c:	8d 42 01             	lea    0x1(%edx),%eax
  80196f:	89 43 04             	mov    %eax,0x4(%ebx)
  801972:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801975:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801979:	3d 00 01 00 00       	cmp    $0x100,%eax
  80197e:	75 0e                	jne    80198e <putch+0x2f>
		writebuf(b);
  801980:	89 d8                	mov    %ebx,%eax
  801982:	e8 99 ff ff ff       	call   801920 <writebuf>
		b->idx = 0;
  801987:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80198e:	83 c4 04             	add    $0x4,%esp
  801991:	5b                   	pop    %ebx
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019a6:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019ad:	00 00 00 
	b.result = 0;
  8019b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019b7:	00 00 00 
	b.error = 1;
  8019ba:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019c1:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019c4:	ff 75 10             	pushl  0x10(%ebp)
  8019c7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ca:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019d0:	50                   	push   %eax
  8019d1:	68 5f 19 80 00       	push   $0x80195f
  8019d6:	e8 59 eb ff ff       	call   800534 <vprintfmt>
	if (b.idx > 0)
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019e5:	7e 0b                	jle    8019f2 <vfprintf+0x5e>
		writebuf(&b);
  8019e7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019ed:	e8 2e ff ff ff       	call   801920 <writebuf>

	return (b.result ? b.result : b.error);
  8019f2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a09:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a0c:	50                   	push   %eax
  801a0d:	ff 75 0c             	pushl  0xc(%ebp)
  801a10:	ff 75 08             	pushl  0x8(%ebp)
  801a13:	e8 7c ff ff ff       	call   801994 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <printf>:

int
printf(const char *fmt, ...)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a20:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a23:	50                   	push   %eax
  801a24:	ff 75 08             	pushl  0x8(%ebp)
  801a27:	6a 01                	push   $0x1
  801a29:	e8 66 ff ff ff       	call   801994 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a2e:	c9                   	leave  
  801a2f:	c3                   	ret    

00801a30 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	ff 75 08             	pushl  0x8(%ebp)
  801a3e:	e8 d6 f6 ff ff       	call   801119 <fd2data>
  801a43:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a45:	83 c4 08             	add    $0x8,%esp
  801a48:	68 f3 2b 80 00       	push   $0x802bf3
  801a4d:	53                   	push   %ebx
  801a4e:	e8 4f ef ff ff       	call   8009a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a53:	8b 46 04             	mov    0x4(%esi),%eax
  801a56:	2b 06                	sub    (%esi),%eax
  801a58:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a5e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a65:	00 00 00 
	stat->st_dev = &devpipe;
  801a68:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a6f:	30 80 00 
	return 0;
}
  801a72:	b8 00 00 00 00       	mov    $0x0,%eax
  801a77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	53                   	push   %ebx
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a88:	53                   	push   %ebx
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 9a f3 ff ff       	call   800e2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a90:	89 1c 24             	mov    %ebx,(%esp)
  801a93:	e8 81 f6 ff ff       	call   801119 <fd2data>
  801a98:	83 c4 08             	add    $0x8,%esp
  801a9b:	50                   	push   %eax
  801a9c:	6a 00                	push   $0x0
  801a9e:	e8 87 f3 ff ff       	call   800e2a <sys_page_unmap>
}
  801aa3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	57                   	push   %edi
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	83 ec 1c             	sub    $0x1c,%esp
  801ab1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ab4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ab6:	a1 20 44 80 00       	mov    0x804420,%eax
  801abb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801abe:	83 ec 0c             	sub    $0xc,%esp
  801ac1:	ff 75 e0             	pushl  -0x20(%ebp)
  801ac4:	e8 ab 09 00 00       	call   802474 <pageref>
  801ac9:	89 c3                	mov    %eax,%ebx
  801acb:	89 3c 24             	mov    %edi,(%esp)
  801ace:	e8 a1 09 00 00       	call   802474 <pageref>
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	39 c3                	cmp    %eax,%ebx
  801ad8:	0f 94 c1             	sete   %cl
  801adb:	0f b6 c9             	movzbl %cl,%ecx
  801ade:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ae1:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ae7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801aea:	39 ce                	cmp    %ecx,%esi
  801aec:	74 1b                	je     801b09 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aee:	39 c3                	cmp    %eax,%ebx
  801af0:	75 c4                	jne    801ab6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801af2:	8b 42 58             	mov    0x58(%edx),%eax
  801af5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af8:	50                   	push   %eax
  801af9:	56                   	push   %esi
  801afa:	68 fa 2b 80 00       	push   $0x802bfa
  801aff:	e8 f9 e8 ff ff       	call   8003fd <cprintf>
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	eb ad                	jmp    801ab6 <_pipeisclosed+0xe>
	}
}
  801b09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0f:	5b                   	pop    %ebx
  801b10:	5e                   	pop    %esi
  801b11:	5f                   	pop    %edi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	57                   	push   %edi
  801b18:	56                   	push   %esi
  801b19:	53                   	push   %ebx
  801b1a:	83 ec 28             	sub    $0x28,%esp
  801b1d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b20:	56                   	push   %esi
  801b21:	e8 f3 f5 ff ff       	call   801119 <fd2data>
  801b26:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b28:	83 c4 10             	add    $0x10,%esp
  801b2b:	bf 00 00 00 00       	mov    $0x0,%edi
  801b30:	eb 4b                	jmp    801b7d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b32:	89 da                	mov    %ebx,%edx
  801b34:	89 f0                	mov    %esi,%eax
  801b36:	e8 6d ff ff ff       	call   801aa8 <_pipeisclosed>
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	75 48                	jne    801b87 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b3f:	e8 42 f2 ff ff       	call   800d86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b44:	8b 43 04             	mov    0x4(%ebx),%eax
  801b47:	8b 0b                	mov    (%ebx),%ecx
  801b49:	8d 51 20             	lea    0x20(%ecx),%edx
  801b4c:	39 d0                	cmp    %edx,%eax
  801b4e:	73 e2                	jae    801b32 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b53:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b57:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b5a:	89 c2                	mov    %eax,%edx
  801b5c:	c1 fa 1f             	sar    $0x1f,%edx
  801b5f:	89 d1                	mov    %edx,%ecx
  801b61:	c1 e9 1b             	shr    $0x1b,%ecx
  801b64:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b67:	83 e2 1f             	and    $0x1f,%edx
  801b6a:	29 ca                	sub    %ecx,%edx
  801b6c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b70:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b74:	83 c0 01             	add    $0x1,%eax
  801b77:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7a:	83 c7 01             	add    $0x1,%edi
  801b7d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b80:	75 c2                	jne    801b44 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b82:	8b 45 10             	mov    0x10(%ebp),%eax
  801b85:	eb 05                	jmp    801b8c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b87:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8f:	5b                   	pop    %ebx
  801b90:	5e                   	pop    %esi
  801b91:	5f                   	pop    %edi
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	57                   	push   %edi
  801b98:	56                   	push   %esi
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 18             	sub    $0x18,%esp
  801b9d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ba0:	57                   	push   %edi
  801ba1:	e8 73 f5 ff ff       	call   801119 <fd2data>
  801ba6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb0:	eb 3d                	jmp    801bef <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bb2:	85 db                	test   %ebx,%ebx
  801bb4:	74 04                	je     801bba <devpipe_read+0x26>
				return i;
  801bb6:	89 d8                	mov    %ebx,%eax
  801bb8:	eb 44                	jmp    801bfe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bba:	89 f2                	mov    %esi,%edx
  801bbc:	89 f8                	mov    %edi,%eax
  801bbe:	e8 e5 fe ff ff       	call   801aa8 <_pipeisclosed>
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	75 32                	jne    801bf9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bc7:	e8 ba f1 ff ff       	call   800d86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bcc:	8b 06                	mov    (%esi),%eax
  801bce:	3b 46 04             	cmp    0x4(%esi),%eax
  801bd1:	74 df                	je     801bb2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bd3:	99                   	cltd   
  801bd4:	c1 ea 1b             	shr    $0x1b,%edx
  801bd7:	01 d0                	add    %edx,%eax
  801bd9:	83 e0 1f             	and    $0x1f,%eax
  801bdc:	29 d0                	sub    %edx,%eax
  801bde:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801be9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bec:	83 c3 01             	add    $0x1,%ebx
  801bef:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bf2:	75 d8                	jne    801bcc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bf4:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf7:	eb 05                	jmp    801bfe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5f                   	pop    %edi
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	56                   	push   %esi
  801c0a:	53                   	push   %ebx
  801c0b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c11:	50                   	push   %eax
  801c12:	e8 19 f5 ff ff       	call   801130 <fd_alloc>
  801c17:	83 c4 10             	add    $0x10,%esp
  801c1a:	89 c2                	mov    %eax,%edx
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	0f 88 2c 01 00 00    	js     801d50 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c24:	83 ec 04             	sub    $0x4,%esp
  801c27:	68 07 04 00 00       	push   $0x407
  801c2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2f:	6a 00                	push   $0x0
  801c31:	e8 6f f1 ff ff       	call   800da5 <sys_page_alloc>
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	89 c2                	mov    %eax,%edx
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	0f 88 0d 01 00 00    	js     801d50 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c43:	83 ec 0c             	sub    $0xc,%esp
  801c46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c49:	50                   	push   %eax
  801c4a:	e8 e1 f4 ff ff       	call   801130 <fd_alloc>
  801c4f:	89 c3                	mov    %eax,%ebx
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	85 c0                	test   %eax,%eax
  801c56:	0f 88 e2 00 00 00    	js     801d3e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5c:	83 ec 04             	sub    $0x4,%esp
  801c5f:	68 07 04 00 00       	push   $0x407
  801c64:	ff 75 f0             	pushl  -0x10(%ebp)
  801c67:	6a 00                	push   $0x0
  801c69:	e8 37 f1 ff ff       	call   800da5 <sys_page_alloc>
  801c6e:	89 c3                	mov    %eax,%ebx
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	85 c0                	test   %eax,%eax
  801c75:	0f 88 c3 00 00 00    	js     801d3e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c7b:	83 ec 0c             	sub    $0xc,%esp
  801c7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c81:	e8 93 f4 ff ff       	call   801119 <fd2data>
  801c86:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c88:	83 c4 0c             	add    $0xc,%esp
  801c8b:	68 07 04 00 00       	push   $0x407
  801c90:	50                   	push   %eax
  801c91:	6a 00                	push   $0x0
  801c93:	e8 0d f1 ff ff       	call   800da5 <sys_page_alloc>
  801c98:	89 c3                	mov    %eax,%ebx
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	0f 88 89 00 00 00    	js     801d2e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca5:	83 ec 0c             	sub    $0xc,%esp
  801ca8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cab:	e8 69 f4 ff ff       	call   801119 <fd2data>
  801cb0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cb7:	50                   	push   %eax
  801cb8:	6a 00                	push   $0x0
  801cba:	56                   	push   %esi
  801cbb:	6a 00                	push   $0x0
  801cbd:	e8 26 f1 ff ff       	call   800de8 <sys_page_map>
  801cc2:	89 c3                	mov    %eax,%ebx
  801cc4:	83 c4 20             	add    $0x20,%esp
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	78 55                	js     801d20 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ccb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ce0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ceb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cf5:	83 ec 0c             	sub    $0xc,%esp
  801cf8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfb:	e8 09 f4 ff ff       	call   801109 <fd2num>
  801d00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d03:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d05:	83 c4 04             	add    $0x4,%esp
  801d08:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0b:	e8 f9 f3 ff ff       	call   801109 <fd2num>
  801d10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d13:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	ba 00 00 00 00       	mov    $0x0,%edx
  801d1e:	eb 30                	jmp    801d50 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d20:	83 ec 08             	sub    $0x8,%esp
  801d23:	56                   	push   %esi
  801d24:	6a 00                	push   $0x0
  801d26:	e8 ff f0 ff ff       	call   800e2a <sys_page_unmap>
  801d2b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d2e:	83 ec 08             	sub    $0x8,%esp
  801d31:	ff 75 f0             	pushl  -0x10(%ebp)
  801d34:	6a 00                	push   $0x0
  801d36:	e8 ef f0 ff ff       	call   800e2a <sys_page_unmap>
  801d3b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d3e:	83 ec 08             	sub    $0x8,%esp
  801d41:	ff 75 f4             	pushl  -0xc(%ebp)
  801d44:	6a 00                	push   $0x0
  801d46:	e8 df f0 ff ff       	call   800e2a <sys_page_unmap>
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d50:	89 d0                	mov    %edx,%eax
  801d52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d55:	5b                   	pop    %ebx
  801d56:	5e                   	pop    %esi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    

00801d59 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d62:	50                   	push   %eax
  801d63:	ff 75 08             	pushl  0x8(%ebp)
  801d66:	e8 14 f4 ff ff       	call   80117f <fd_lookup>
  801d6b:	83 c4 10             	add    $0x10,%esp
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	78 18                	js     801d8a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d72:	83 ec 0c             	sub    $0xc,%esp
  801d75:	ff 75 f4             	pushl  -0xc(%ebp)
  801d78:	e8 9c f3 ff ff       	call   801119 <fd2data>
	return _pipeisclosed(fd, p);
  801d7d:	89 c2                	mov    %eax,%edx
  801d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d82:	e8 21 fd ff ff       	call   801aa8 <_pipeisclosed>
  801d87:	83 c4 10             	add    $0x10,%esp
}
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d92:	68 12 2c 80 00       	push   $0x802c12
  801d97:	ff 75 0c             	pushl  0xc(%ebp)
  801d9a:	e8 03 ec ff ff       	call   8009a2 <strcpy>
	return 0;
}
  801d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	53                   	push   %ebx
  801daa:	83 ec 10             	sub    $0x10,%esp
  801dad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801db0:	53                   	push   %ebx
  801db1:	e8 be 06 00 00       	call   802474 <pageref>
  801db6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801db9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801dbe:	83 f8 01             	cmp    $0x1,%eax
  801dc1:	75 10                	jne    801dd3 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801dc3:	83 ec 0c             	sub    $0xc,%esp
  801dc6:	ff 73 0c             	pushl  0xc(%ebx)
  801dc9:	e8 c0 02 00 00       	call   80208e <nsipc_close>
  801dce:	89 c2                	mov    %eax,%edx
  801dd0:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801dd3:	89 d0                	mov    %edx,%eax
  801dd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    

00801dda <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801de0:	6a 00                	push   $0x0
  801de2:	ff 75 10             	pushl  0x10(%ebp)
  801de5:	ff 75 0c             	pushl  0xc(%ebp)
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	ff 70 0c             	pushl  0xc(%eax)
  801dee:	e8 78 03 00 00       	call   80216b <nsipc_send>
}
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801dfb:	6a 00                	push   $0x0
  801dfd:	ff 75 10             	pushl  0x10(%ebp)
  801e00:	ff 75 0c             	pushl  0xc(%ebp)
  801e03:	8b 45 08             	mov    0x8(%ebp),%eax
  801e06:	ff 70 0c             	pushl  0xc(%eax)
  801e09:	e8 f1 02 00 00       	call   8020ff <nsipc_recv>
}
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e16:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e19:	52                   	push   %edx
  801e1a:	50                   	push   %eax
  801e1b:	e8 5f f3 ff ff       	call   80117f <fd_lookup>
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 17                	js     801e3e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2a:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801e30:	39 08                	cmp    %ecx,(%eax)
  801e32:	75 05                	jne    801e39 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e34:	8b 40 0c             	mov    0xc(%eax),%eax
  801e37:	eb 05                	jmp    801e3e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e39:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    

00801e40 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	56                   	push   %esi
  801e44:	53                   	push   %ebx
  801e45:	83 ec 1c             	sub    $0x1c,%esp
  801e48:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4d:	50                   	push   %eax
  801e4e:	e8 dd f2 ff ff       	call   801130 <fd_alloc>
  801e53:	89 c3                	mov    %eax,%ebx
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	78 1b                	js     801e77 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e5c:	83 ec 04             	sub    $0x4,%esp
  801e5f:	68 07 04 00 00       	push   $0x407
  801e64:	ff 75 f4             	pushl  -0xc(%ebp)
  801e67:	6a 00                	push   $0x0
  801e69:	e8 37 ef ff ff       	call   800da5 <sys_page_alloc>
  801e6e:	89 c3                	mov    %eax,%ebx
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	79 10                	jns    801e87 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801e77:	83 ec 0c             	sub    $0xc,%esp
  801e7a:	56                   	push   %esi
  801e7b:	e8 0e 02 00 00       	call   80208e <nsipc_close>
		return r;
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	89 d8                	mov    %ebx,%eax
  801e85:	eb 24                	jmp    801eab <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e87:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e90:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e95:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e9c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e9f:	83 ec 0c             	sub    $0xc,%esp
  801ea2:	50                   	push   %eax
  801ea3:	e8 61 f2 ff ff       	call   801109 <fd2num>
  801ea8:	83 c4 10             	add    $0x10,%esp
}
  801eab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eae:	5b                   	pop    %ebx
  801eaf:	5e                   	pop    %esi
  801eb0:	5d                   	pop    %ebp
  801eb1:	c3                   	ret    

00801eb2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebb:	e8 50 ff ff ff       	call   801e10 <fd2sockid>
		return r;
  801ec0:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	78 1f                	js     801ee5 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ec6:	83 ec 04             	sub    $0x4,%esp
  801ec9:	ff 75 10             	pushl  0x10(%ebp)
  801ecc:	ff 75 0c             	pushl  0xc(%ebp)
  801ecf:	50                   	push   %eax
  801ed0:	e8 12 01 00 00       	call   801fe7 <nsipc_accept>
  801ed5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed8:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801eda:	85 c0                	test   %eax,%eax
  801edc:	78 07                	js     801ee5 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ede:	e8 5d ff ff ff       	call   801e40 <alloc_sockfd>
  801ee3:	89 c1                	mov    %eax,%ecx
}
  801ee5:	89 c8                	mov    %ecx,%eax
  801ee7:	c9                   	leave  
  801ee8:	c3                   	ret    

00801ee9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef2:	e8 19 ff ff ff       	call   801e10 <fd2sockid>
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	78 12                	js     801f0d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801efb:	83 ec 04             	sub    $0x4,%esp
  801efe:	ff 75 10             	pushl  0x10(%ebp)
  801f01:	ff 75 0c             	pushl  0xc(%ebp)
  801f04:	50                   	push   %eax
  801f05:	e8 2d 01 00 00       	call   802037 <nsipc_bind>
  801f0a:	83 c4 10             	add    $0x10,%esp
}
  801f0d:	c9                   	leave  
  801f0e:	c3                   	ret    

00801f0f <shutdown>:

int
shutdown(int s, int how)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f15:	8b 45 08             	mov    0x8(%ebp),%eax
  801f18:	e8 f3 fe ff ff       	call   801e10 <fd2sockid>
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	78 0f                	js     801f30 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f21:	83 ec 08             	sub    $0x8,%esp
  801f24:	ff 75 0c             	pushl  0xc(%ebp)
  801f27:	50                   	push   %eax
  801f28:	e8 3f 01 00 00       	call   80206c <nsipc_shutdown>
  801f2d:	83 c4 10             	add    $0x10,%esp
}
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f38:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3b:	e8 d0 fe ff ff       	call   801e10 <fd2sockid>
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 12                	js     801f56 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801f44:	83 ec 04             	sub    $0x4,%esp
  801f47:	ff 75 10             	pushl  0x10(%ebp)
  801f4a:	ff 75 0c             	pushl  0xc(%ebp)
  801f4d:	50                   	push   %eax
  801f4e:	e8 55 01 00 00       	call   8020a8 <nsipc_connect>
  801f53:	83 c4 10             	add    $0x10,%esp
}
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    

00801f58 <listen>:

int
listen(int s, int backlog)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f61:	e8 aa fe ff ff       	call   801e10 <fd2sockid>
  801f66:	85 c0                	test   %eax,%eax
  801f68:	78 0f                	js     801f79 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f6a:	83 ec 08             	sub    $0x8,%esp
  801f6d:	ff 75 0c             	pushl  0xc(%ebp)
  801f70:	50                   	push   %eax
  801f71:	e8 67 01 00 00       	call   8020dd <nsipc_listen>
  801f76:	83 c4 10             	add    $0x10,%esp
}
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    

00801f7b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f81:	ff 75 10             	pushl  0x10(%ebp)
  801f84:	ff 75 0c             	pushl  0xc(%ebp)
  801f87:	ff 75 08             	pushl  0x8(%ebp)
  801f8a:	e8 3a 02 00 00       	call   8021c9 <nsipc_socket>
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	85 c0                	test   %eax,%eax
  801f94:	78 05                	js     801f9b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801f96:	e8 a5 fe ff ff       	call   801e40 <alloc_sockfd>
}
  801f9b:	c9                   	leave  
  801f9c:	c3                   	ret    

00801f9d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	53                   	push   %ebx
  801fa1:	83 ec 04             	sub    $0x4,%esp
  801fa4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fa6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801fad:	75 12                	jne    801fc1 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801faf:	83 ec 0c             	sub    $0xc,%esp
  801fb2:	6a 02                	push   $0x2
  801fb4:	e8 82 04 00 00       	call   80243b <ipc_find_env>
  801fb9:	a3 04 40 80 00       	mov    %eax,0x804004
  801fbe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801fc1:	6a 07                	push   $0x7
  801fc3:	68 00 60 80 00       	push   $0x806000
  801fc8:	53                   	push   %ebx
  801fc9:	ff 35 04 40 80 00    	pushl  0x804004
  801fcf:	e8 18 04 00 00       	call   8023ec <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fd4:	83 c4 0c             	add    $0xc,%esp
  801fd7:	6a 00                	push   $0x0
  801fd9:	6a 00                	push   $0x0
  801fdb:	6a 00                	push   $0x0
  801fdd:	e8 94 03 00 00       	call   802376 <ipc_recv>
}
  801fe2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    

00801fe7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	56                   	push   %esi
  801feb:	53                   	push   %ebx
  801fec:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ff7:	8b 06                	mov    (%esi),%eax
  801ff9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ffe:	b8 01 00 00 00       	mov    $0x1,%eax
  802003:	e8 95 ff ff ff       	call   801f9d <nsipc>
  802008:	89 c3                	mov    %eax,%ebx
  80200a:	85 c0                	test   %eax,%eax
  80200c:	78 20                	js     80202e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80200e:	83 ec 04             	sub    $0x4,%esp
  802011:	ff 35 10 60 80 00    	pushl  0x806010
  802017:	68 00 60 80 00       	push   $0x806000
  80201c:	ff 75 0c             	pushl  0xc(%ebp)
  80201f:	e8 10 eb ff ff       	call   800b34 <memmove>
		*addrlen = ret->ret_addrlen;
  802024:	a1 10 60 80 00       	mov    0x806010,%eax
  802029:	89 06                	mov    %eax,(%esi)
  80202b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80202e:	89 d8                	mov    %ebx,%eax
  802030:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5d                   	pop    %ebp
  802036:	c3                   	ret    

00802037 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	53                   	push   %ebx
  80203b:	83 ec 08             	sub    $0x8,%esp
  80203e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802041:	8b 45 08             	mov    0x8(%ebp),%eax
  802044:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802049:	53                   	push   %ebx
  80204a:	ff 75 0c             	pushl  0xc(%ebp)
  80204d:	68 04 60 80 00       	push   $0x806004
  802052:	e8 dd ea ff ff       	call   800b34 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802057:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80205d:	b8 02 00 00 00       	mov    $0x2,%eax
  802062:	e8 36 ff ff ff       	call   801f9d <nsipc>
}
  802067:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80206a:	c9                   	leave  
  80206b:	c3                   	ret    

0080206c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802072:	8b 45 08             	mov    0x8(%ebp),%eax
  802075:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80207a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802082:	b8 03 00 00 00       	mov    $0x3,%eax
  802087:	e8 11 ff ff ff       	call   801f9d <nsipc>
}
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <nsipc_close>:

int
nsipc_close(int s)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802094:	8b 45 08             	mov    0x8(%ebp),%eax
  802097:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80209c:	b8 04 00 00 00       	mov    $0x4,%eax
  8020a1:	e8 f7 fe ff ff       	call   801f9d <nsipc>
}
  8020a6:	c9                   	leave  
  8020a7:	c3                   	ret    

008020a8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	53                   	push   %ebx
  8020ac:	83 ec 08             	sub    $0x8,%esp
  8020af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020ba:	53                   	push   %ebx
  8020bb:	ff 75 0c             	pushl  0xc(%ebp)
  8020be:	68 04 60 80 00       	push   $0x806004
  8020c3:	e8 6c ea ff ff       	call   800b34 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020c8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8020ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8020d3:	e8 c5 fe ff ff       	call   801f9d <nsipc>
}
  8020d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020db:	c9                   	leave  
  8020dc:	c3                   	ret    

008020dd <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8020eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ee:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8020f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8020f8:	e8 a0 fe ff ff       	call   801f9d <nsipc>
}
  8020fd:	c9                   	leave  
  8020fe:	c3                   	ret    

008020ff <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802107:	8b 45 08             	mov    0x8(%ebp),%eax
  80210a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80210f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802115:	8b 45 14             	mov    0x14(%ebp),%eax
  802118:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80211d:	b8 07 00 00 00       	mov    $0x7,%eax
  802122:	e8 76 fe ff ff       	call   801f9d <nsipc>
  802127:	89 c3                	mov    %eax,%ebx
  802129:	85 c0                	test   %eax,%eax
  80212b:	78 35                	js     802162 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80212d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802132:	7f 04                	jg     802138 <nsipc_recv+0x39>
  802134:	39 c6                	cmp    %eax,%esi
  802136:	7d 16                	jge    80214e <nsipc_recv+0x4f>
  802138:	68 1e 2c 80 00       	push   $0x802c1e
  80213d:	68 c7 2b 80 00       	push   $0x802bc7
  802142:	6a 62                	push   $0x62
  802144:	68 33 2c 80 00       	push   $0x802c33
  802149:	e8 d6 e1 ff ff       	call   800324 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80214e:	83 ec 04             	sub    $0x4,%esp
  802151:	50                   	push   %eax
  802152:	68 00 60 80 00       	push   $0x806000
  802157:	ff 75 0c             	pushl  0xc(%ebp)
  80215a:	e8 d5 e9 ff ff       	call   800b34 <memmove>
  80215f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802162:	89 d8                	mov    %ebx,%eax
  802164:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5d                   	pop    %ebp
  80216a:	c3                   	ret    

0080216b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	53                   	push   %ebx
  80216f:	83 ec 04             	sub    $0x4,%esp
  802172:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802175:	8b 45 08             	mov    0x8(%ebp),%eax
  802178:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80217d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802183:	7e 16                	jle    80219b <nsipc_send+0x30>
  802185:	68 3f 2c 80 00       	push   $0x802c3f
  80218a:	68 c7 2b 80 00       	push   $0x802bc7
  80218f:	6a 6d                	push   $0x6d
  802191:	68 33 2c 80 00       	push   $0x802c33
  802196:	e8 89 e1 ff ff       	call   800324 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80219b:	83 ec 04             	sub    $0x4,%esp
  80219e:	53                   	push   %ebx
  80219f:	ff 75 0c             	pushl  0xc(%ebp)
  8021a2:	68 0c 60 80 00       	push   $0x80600c
  8021a7:	e8 88 e9 ff ff       	call   800b34 <memmove>
	nsipcbuf.send.req_size = size;
  8021ac:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8021b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8021b5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8021ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8021bf:	e8 d9 fd ff ff       	call   801f9d <nsipc>
}
  8021c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c7:	c9                   	leave  
  8021c8:	c3                   	ret    

008021c9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021c9:	55                   	push   %ebp
  8021ca:	89 e5                	mov    %esp,%ebp
  8021cc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8021d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021da:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8021df:	8b 45 10             	mov    0x10(%ebp),%eax
  8021e2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8021e7:	b8 09 00 00 00       	mov    $0x9,%eax
  8021ec:	e8 ac fd ff ff       	call   801f9d <nsipc>
}
  8021f1:	c9                   	leave  
  8021f2:	c3                   	ret    

008021f3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    

008021fd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021fd:	55                   	push   %ebp
  8021fe:	89 e5                	mov    %esp,%ebp
  802200:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802203:	68 4b 2c 80 00       	push   $0x802c4b
  802208:	ff 75 0c             	pushl  0xc(%ebp)
  80220b:	e8 92 e7 ff ff       	call   8009a2 <strcpy>
	return 0;
}
  802210:	b8 00 00 00 00       	mov    $0x0,%eax
  802215:	c9                   	leave  
  802216:	c3                   	ret    

00802217 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	57                   	push   %edi
  80221b:	56                   	push   %esi
  80221c:	53                   	push   %ebx
  80221d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802223:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802228:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80222e:	eb 2d                	jmp    80225d <devcons_write+0x46>
		m = n - tot;
  802230:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802233:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802235:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802238:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80223d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802240:	83 ec 04             	sub    $0x4,%esp
  802243:	53                   	push   %ebx
  802244:	03 45 0c             	add    0xc(%ebp),%eax
  802247:	50                   	push   %eax
  802248:	57                   	push   %edi
  802249:	e8 e6 e8 ff ff       	call   800b34 <memmove>
		sys_cputs(buf, m);
  80224e:	83 c4 08             	add    $0x8,%esp
  802251:	53                   	push   %ebx
  802252:	57                   	push   %edi
  802253:	e8 91 ea ff ff       	call   800ce9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802258:	01 de                	add    %ebx,%esi
  80225a:	83 c4 10             	add    $0x10,%esp
  80225d:	89 f0                	mov    %esi,%eax
  80225f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802262:	72 cc                	jb     802230 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    

0080226c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80226c:	55                   	push   %ebp
  80226d:	89 e5                	mov    %esp,%ebp
  80226f:	83 ec 08             	sub    $0x8,%esp
  802272:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802277:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80227b:	74 2a                	je     8022a7 <devcons_read+0x3b>
  80227d:	eb 05                	jmp    802284 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80227f:	e8 02 eb ff ff       	call   800d86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802284:	e8 7e ea ff ff       	call   800d07 <sys_cgetc>
  802289:	85 c0                	test   %eax,%eax
  80228b:	74 f2                	je     80227f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80228d:	85 c0                	test   %eax,%eax
  80228f:	78 16                	js     8022a7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802291:	83 f8 04             	cmp    $0x4,%eax
  802294:	74 0c                	je     8022a2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802296:	8b 55 0c             	mov    0xc(%ebp),%edx
  802299:	88 02                	mov    %al,(%edx)
	return 1;
  80229b:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a0:	eb 05                	jmp    8022a7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022a2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022a7:	c9                   	leave  
  8022a8:	c3                   	ret    

008022a9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022a9:	55                   	push   %ebp
  8022aa:	89 e5                	mov    %esp,%ebp
  8022ac:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022af:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022b5:	6a 01                	push   $0x1
  8022b7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ba:	50                   	push   %eax
  8022bb:	e8 29 ea ff ff       	call   800ce9 <sys_cputs>
}
  8022c0:	83 c4 10             	add    $0x10,%esp
  8022c3:	c9                   	leave  
  8022c4:	c3                   	ret    

008022c5 <getchar>:

int
getchar(void)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022cb:	6a 01                	push   $0x1
  8022cd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022d0:	50                   	push   %eax
  8022d1:	6a 00                	push   $0x0
  8022d3:	e8 0d f1 ff ff       	call   8013e5 <read>
	if (r < 0)
  8022d8:	83 c4 10             	add    $0x10,%esp
  8022db:	85 c0                	test   %eax,%eax
  8022dd:	78 0f                	js     8022ee <getchar+0x29>
		return r;
	if (r < 1)
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	7e 06                	jle    8022e9 <getchar+0x24>
		return -E_EOF;
	return c;
  8022e3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022e7:	eb 05                	jmp    8022ee <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022e9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022ee:	c9                   	leave  
  8022ef:	c3                   	ret    

008022f0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f9:	50                   	push   %eax
  8022fa:	ff 75 08             	pushl  0x8(%ebp)
  8022fd:	e8 7d ee ff ff       	call   80117f <fd_lookup>
  802302:	83 c4 10             	add    $0x10,%esp
  802305:	85 c0                	test   %eax,%eax
  802307:	78 11                	js     80231a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802309:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802312:	39 10                	cmp    %edx,(%eax)
  802314:	0f 94 c0             	sete   %al
  802317:	0f b6 c0             	movzbl %al,%eax
}
  80231a:	c9                   	leave  
  80231b:	c3                   	ret    

0080231c <opencons>:

int
opencons(void)
{
  80231c:	55                   	push   %ebp
  80231d:	89 e5                	mov    %esp,%ebp
  80231f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802325:	50                   	push   %eax
  802326:	e8 05 ee ff ff       	call   801130 <fd_alloc>
  80232b:	83 c4 10             	add    $0x10,%esp
		return r;
  80232e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802330:	85 c0                	test   %eax,%eax
  802332:	78 3e                	js     802372 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802334:	83 ec 04             	sub    $0x4,%esp
  802337:	68 07 04 00 00       	push   $0x407
  80233c:	ff 75 f4             	pushl  -0xc(%ebp)
  80233f:	6a 00                	push   $0x0
  802341:	e8 5f ea ff ff       	call   800da5 <sys_page_alloc>
  802346:	83 c4 10             	add    $0x10,%esp
		return r;
  802349:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80234b:	85 c0                	test   %eax,%eax
  80234d:	78 23                	js     802372 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80234f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802355:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802358:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80235a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802364:	83 ec 0c             	sub    $0xc,%esp
  802367:	50                   	push   %eax
  802368:	e8 9c ed ff ff       	call   801109 <fd2num>
  80236d:	89 c2                	mov    %eax,%edx
  80236f:	83 c4 10             	add    $0x10,%esp
}
  802372:	89 d0                	mov    %edx,%eax
  802374:	c9                   	leave  
  802375:	c3                   	ret    

00802376 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802376:	55                   	push   %ebp
  802377:	89 e5                	mov    %esp,%ebp
  802379:	56                   	push   %esi
  80237a:	53                   	push   %ebx
  80237b:	8b 75 08             	mov    0x8(%ebp),%esi
  80237e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802381:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  802384:	85 c0                	test   %eax,%eax
  802386:	74 0e                	je     802396 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  802388:	83 ec 0c             	sub    $0xc,%esp
  80238b:	50                   	push   %eax
  80238c:	e8 c4 eb ff ff       	call   800f55 <sys_ipc_recv>
  802391:	83 c4 10             	add    $0x10,%esp
  802394:	eb 10                	jmp    8023a6 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802396:	83 ec 0c             	sub    $0xc,%esp
  802399:	68 00 00 c0 ee       	push   $0xeec00000
  80239e:	e8 b2 eb ff ff       	call   800f55 <sys_ipc_recv>
  8023a3:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8023a6:	85 c0                	test   %eax,%eax
  8023a8:	79 17                	jns    8023c1 <ipc_recv+0x4b>
		if(*from_env_store)
  8023aa:	83 3e 00             	cmpl   $0x0,(%esi)
  8023ad:	74 06                	je     8023b5 <ipc_recv+0x3f>
			*from_env_store = 0;
  8023af:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8023b5:	85 db                	test   %ebx,%ebx
  8023b7:	74 2c                	je     8023e5 <ipc_recv+0x6f>
			*perm_store = 0;
  8023b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8023bf:	eb 24                	jmp    8023e5 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  8023c1:	85 f6                	test   %esi,%esi
  8023c3:	74 0a                	je     8023cf <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  8023c5:	a1 20 44 80 00       	mov    0x804420,%eax
  8023ca:	8b 40 74             	mov    0x74(%eax),%eax
  8023cd:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8023cf:	85 db                	test   %ebx,%ebx
  8023d1:	74 0a                	je     8023dd <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8023d3:	a1 20 44 80 00       	mov    0x804420,%eax
  8023d8:	8b 40 78             	mov    0x78(%eax),%eax
  8023db:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8023dd:	a1 20 44 80 00       	mov    0x804420,%eax
  8023e2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    

008023ec <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	57                   	push   %edi
  8023f0:	56                   	push   %esi
  8023f1:	53                   	push   %ebx
  8023f2:	83 ec 0c             	sub    $0xc,%esp
  8023f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8023fe:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  802400:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802405:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802408:	e8 79 e9 ff ff       	call   800d86 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  80240d:	ff 75 14             	pushl  0x14(%ebp)
  802410:	53                   	push   %ebx
  802411:	56                   	push   %esi
  802412:	57                   	push   %edi
  802413:	e8 1a eb ff ff       	call   800f32 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802418:	89 c2                	mov    %eax,%edx
  80241a:	f7 d2                	not    %edx
  80241c:	c1 ea 1f             	shr    $0x1f,%edx
  80241f:	83 c4 10             	add    $0x10,%esp
  802422:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802425:	0f 94 c1             	sete   %cl
  802428:	09 ca                	or     %ecx,%edx
  80242a:	85 c0                	test   %eax,%eax
  80242c:	0f 94 c0             	sete   %al
  80242f:	38 c2                	cmp    %al,%dl
  802431:	77 d5                	ja     802408 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802433:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802436:	5b                   	pop    %ebx
  802437:	5e                   	pop    %esi
  802438:	5f                   	pop    %edi
  802439:	5d                   	pop    %ebp
  80243a:	c3                   	ret    

0080243b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80243b:	55                   	push   %ebp
  80243c:	89 e5                	mov    %esp,%ebp
  80243e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802441:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802446:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802449:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80244f:	8b 52 50             	mov    0x50(%edx),%edx
  802452:	39 ca                	cmp    %ecx,%edx
  802454:	75 0d                	jne    802463 <ipc_find_env+0x28>
			return envs[i].env_id;
  802456:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802459:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80245e:	8b 40 48             	mov    0x48(%eax),%eax
  802461:	eb 0f                	jmp    802472 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802463:	83 c0 01             	add    $0x1,%eax
  802466:	3d 00 04 00 00       	cmp    $0x400,%eax
  80246b:	75 d9                	jne    802446 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80246d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802472:	5d                   	pop    %ebp
  802473:	c3                   	ret    

00802474 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802474:	55                   	push   %ebp
  802475:	89 e5                	mov    %esp,%ebp
  802477:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80247a:	89 d0                	mov    %edx,%eax
  80247c:	c1 e8 16             	shr    $0x16,%eax
  80247f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802486:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80248b:	f6 c1 01             	test   $0x1,%cl
  80248e:	74 1d                	je     8024ad <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802490:	c1 ea 0c             	shr    $0xc,%edx
  802493:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80249a:	f6 c2 01             	test   $0x1,%dl
  80249d:	74 0e                	je     8024ad <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80249f:	c1 ea 0c             	shr    $0xc,%edx
  8024a2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024a9:	ef 
  8024aa:	0f b7 c0             	movzwl %ax,%eax
}
  8024ad:	5d                   	pop    %ebp
  8024ae:	c3                   	ret    
  8024af:	90                   	nop

008024b0 <__udivdi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 1c             	sub    $0x1c,%esp
  8024b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c7:	85 f6                	test   %esi,%esi
  8024c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024cd:	89 ca                	mov    %ecx,%edx
  8024cf:	89 f8                	mov    %edi,%eax
  8024d1:	75 3d                	jne    802510 <__udivdi3+0x60>
  8024d3:	39 cf                	cmp    %ecx,%edi
  8024d5:	0f 87 c5 00 00 00    	ja     8025a0 <__udivdi3+0xf0>
  8024db:	85 ff                	test   %edi,%edi
  8024dd:	89 fd                	mov    %edi,%ebp
  8024df:	75 0b                	jne    8024ec <__udivdi3+0x3c>
  8024e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e6:	31 d2                	xor    %edx,%edx
  8024e8:	f7 f7                	div    %edi
  8024ea:	89 c5                	mov    %eax,%ebp
  8024ec:	89 c8                	mov    %ecx,%eax
  8024ee:	31 d2                	xor    %edx,%edx
  8024f0:	f7 f5                	div    %ebp
  8024f2:	89 c1                	mov    %eax,%ecx
  8024f4:	89 d8                	mov    %ebx,%eax
  8024f6:	89 cf                	mov    %ecx,%edi
  8024f8:	f7 f5                	div    %ebp
  8024fa:	89 c3                	mov    %eax,%ebx
  8024fc:	89 d8                	mov    %ebx,%eax
  8024fe:	89 fa                	mov    %edi,%edx
  802500:	83 c4 1c             	add    $0x1c,%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    
  802508:	90                   	nop
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	39 ce                	cmp    %ecx,%esi
  802512:	77 74                	ja     802588 <__udivdi3+0xd8>
  802514:	0f bd fe             	bsr    %esi,%edi
  802517:	83 f7 1f             	xor    $0x1f,%edi
  80251a:	0f 84 98 00 00 00    	je     8025b8 <__udivdi3+0x108>
  802520:	bb 20 00 00 00       	mov    $0x20,%ebx
  802525:	89 f9                	mov    %edi,%ecx
  802527:	89 c5                	mov    %eax,%ebp
  802529:	29 fb                	sub    %edi,%ebx
  80252b:	d3 e6                	shl    %cl,%esi
  80252d:	89 d9                	mov    %ebx,%ecx
  80252f:	d3 ed                	shr    %cl,%ebp
  802531:	89 f9                	mov    %edi,%ecx
  802533:	d3 e0                	shl    %cl,%eax
  802535:	09 ee                	or     %ebp,%esi
  802537:	89 d9                	mov    %ebx,%ecx
  802539:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80253d:	89 d5                	mov    %edx,%ebp
  80253f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802543:	d3 ed                	shr    %cl,%ebp
  802545:	89 f9                	mov    %edi,%ecx
  802547:	d3 e2                	shl    %cl,%edx
  802549:	89 d9                	mov    %ebx,%ecx
  80254b:	d3 e8                	shr    %cl,%eax
  80254d:	09 c2                	or     %eax,%edx
  80254f:	89 d0                	mov    %edx,%eax
  802551:	89 ea                	mov    %ebp,%edx
  802553:	f7 f6                	div    %esi
  802555:	89 d5                	mov    %edx,%ebp
  802557:	89 c3                	mov    %eax,%ebx
  802559:	f7 64 24 0c          	mull   0xc(%esp)
  80255d:	39 d5                	cmp    %edx,%ebp
  80255f:	72 10                	jb     802571 <__udivdi3+0xc1>
  802561:	8b 74 24 08          	mov    0x8(%esp),%esi
  802565:	89 f9                	mov    %edi,%ecx
  802567:	d3 e6                	shl    %cl,%esi
  802569:	39 c6                	cmp    %eax,%esi
  80256b:	73 07                	jae    802574 <__udivdi3+0xc4>
  80256d:	39 d5                	cmp    %edx,%ebp
  80256f:	75 03                	jne    802574 <__udivdi3+0xc4>
  802571:	83 eb 01             	sub    $0x1,%ebx
  802574:	31 ff                	xor    %edi,%edi
  802576:	89 d8                	mov    %ebx,%eax
  802578:	89 fa                	mov    %edi,%edx
  80257a:	83 c4 1c             	add    $0x1c,%esp
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	31 ff                	xor    %edi,%edi
  80258a:	31 db                	xor    %ebx,%ebx
  80258c:	89 d8                	mov    %ebx,%eax
  80258e:	89 fa                	mov    %edi,%edx
  802590:	83 c4 1c             	add    $0x1c,%esp
  802593:	5b                   	pop    %ebx
  802594:	5e                   	pop    %esi
  802595:	5f                   	pop    %edi
  802596:	5d                   	pop    %ebp
  802597:	c3                   	ret    
  802598:	90                   	nop
  802599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	89 d8                	mov    %ebx,%eax
  8025a2:	f7 f7                	div    %edi
  8025a4:	31 ff                	xor    %edi,%edi
  8025a6:	89 c3                	mov    %eax,%ebx
  8025a8:	89 d8                	mov    %ebx,%eax
  8025aa:	89 fa                	mov    %edi,%edx
  8025ac:	83 c4 1c             	add    $0x1c,%esp
  8025af:	5b                   	pop    %ebx
  8025b0:	5e                   	pop    %esi
  8025b1:	5f                   	pop    %edi
  8025b2:	5d                   	pop    %ebp
  8025b3:	c3                   	ret    
  8025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	39 ce                	cmp    %ecx,%esi
  8025ba:	72 0c                	jb     8025c8 <__udivdi3+0x118>
  8025bc:	31 db                	xor    %ebx,%ebx
  8025be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025c2:	0f 87 34 ff ff ff    	ja     8024fc <__udivdi3+0x4c>
  8025c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025cd:	e9 2a ff ff ff       	jmp    8024fc <__udivdi3+0x4c>
  8025d2:	66 90                	xchg   %ax,%ax
  8025d4:	66 90                	xchg   %ax,%ax
  8025d6:	66 90                	xchg   %ax,%ax
  8025d8:	66 90                	xchg   %ax,%ax
  8025da:	66 90                	xchg   %ax,%ax
  8025dc:	66 90                	xchg   %ax,%ax
  8025de:	66 90                	xchg   %ax,%ax

008025e0 <__umoddi3>:
  8025e0:	55                   	push   %ebp
  8025e1:	57                   	push   %edi
  8025e2:	56                   	push   %esi
  8025e3:	53                   	push   %ebx
  8025e4:	83 ec 1c             	sub    $0x1c,%esp
  8025e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025f7:	85 d2                	test   %edx,%edx
  8025f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802601:	89 f3                	mov    %esi,%ebx
  802603:	89 3c 24             	mov    %edi,(%esp)
  802606:	89 74 24 04          	mov    %esi,0x4(%esp)
  80260a:	75 1c                	jne    802628 <__umoddi3+0x48>
  80260c:	39 f7                	cmp    %esi,%edi
  80260e:	76 50                	jbe    802660 <__umoddi3+0x80>
  802610:	89 c8                	mov    %ecx,%eax
  802612:	89 f2                	mov    %esi,%edx
  802614:	f7 f7                	div    %edi
  802616:	89 d0                	mov    %edx,%eax
  802618:	31 d2                	xor    %edx,%edx
  80261a:	83 c4 1c             	add    $0x1c,%esp
  80261d:	5b                   	pop    %ebx
  80261e:	5e                   	pop    %esi
  80261f:	5f                   	pop    %edi
  802620:	5d                   	pop    %ebp
  802621:	c3                   	ret    
  802622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802628:	39 f2                	cmp    %esi,%edx
  80262a:	89 d0                	mov    %edx,%eax
  80262c:	77 52                	ja     802680 <__umoddi3+0xa0>
  80262e:	0f bd ea             	bsr    %edx,%ebp
  802631:	83 f5 1f             	xor    $0x1f,%ebp
  802634:	75 5a                	jne    802690 <__umoddi3+0xb0>
  802636:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80263a:	0f 82 e0 00 00 00    	jb     802720 <__umoddi3+0x140>
  802640:	39 0c 24             	cmp    %ecx,(%esp)
  802643:	0f 86 d7 00 00 00    	jbe    802720 <__umoddi3+0x140>
  802649:	8b 44 24 08          	mov    0x8(%esp),%eax
  80264d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802651:	83 c4 1c             	add    $0x1c,%esp
  802654:	5b                   	pop    %ebx
  802655:	5e                   	pop    %esi
  802656:	5f                   	pop    %edi
  802657:	5d                   	pop    %ebp
  802658:	c3                   	ret    
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	85 ff                	test   %edi,%edi
  802662:	89 fd                	mov    %edi,%ebp
  802664:	75 0b                	jne    802671 <__umoddi3+0x91>
  802666:	b8 01 00 00 00       	mov    $0x1,%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	f7 f7                	div    %edi
  80266f:	89 c5                	mov    %eax,%ebp
  802671:	89 f0                	mov    %esi,%eax
  802673:	31 d2                	xor    %edx,%edx
  802675:	f7 f5                	div    %ebp
  802677:	89 c8                	mov    %ecx,%eax
  802679:	f7 f5                	div    %ebp
  80267b:	89 d0                	mov    %edx,%eax
  80267d:	eb 99                	jmp    802618 <__umoddi3+0x38>
  80267f:	90                   	nop
  802680:	89 c8                	mov    %ecx,%eax
  802682:	89 f2                	mov    %esi,%edx
  802684:	83 c4 1c             	add    $0x1c,%esp
  802687:	5b                   	pop    %ebx
  802688:	5e                   	pop    %esi
  802689:	5f                   	pop    %edi
  80268a:	5d                   	pop    %ebp
  80268b:	c3                   	ret    
  80268c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802690:	8b 34 24             	mov    (%esp),%esi
  802693:	bf 20 00 00 00       	mov    $0x20,%edi
  802698:	89 e9                	mov    %ebp,%ecx
  80269a:	29 ef                	sub    %ebp,%edi
  80269c:	d3 e0                	shl    %cl,%eax
  80269e:	89 f9                	mov    %edi,%ecx
  8026a0:	89 f2                	mov    %esi,%edx
  8026a2:	d3 ea                	shr    %cl,%edx
  8026a4:	89 e9                	mov    %ebp,%ecx
  8026a6:	09 c2                	or     %eax,%edx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 14 24             	mov    %edx,(%esp)
  8026ad:	89 f2                	mov    %esi,%edx
  8026af:	d3 e2                	shl    %cl,%edx
  8026b1:	89 f9                	mov    %edi,%ecx
  8026b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026bb:	d3 e8                	shr    %cl,%eax
  8026bd:	89 e9                	mov    %ebp,%ecx
  8026bf:	89 c6                	mov    %eax,%esi
  8026c1:	d3 e3                	shl    %cl,%ebx
  8026c3:	89 f9                	mov    %edi,%ecx
  8026c5:	89 d0                	mov    %edx,%eax
  8026c7:	d3 e8                	shr    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	09 d8                	or     %ebx,%eax
  8026cd:	89 d3                	mov    %edx,%ebx
  8026cf:	89 f2                	mov    %esi,%edx
  8026d1:	f7 34 24             	divl   (%esp)
  8026d4:	89 d6                	mov    %edx,%esi
  8026d6:	d3 e3                	shl    %cl,%ebx
  8026d8:	f7 64 24 04          	mull   0x4(%esp)
  8026dc:	39 d6                	cmp    %edx,%esi
  8026de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026e2:	89 d1                	mov    %edx,%ecx
  8026e4:	89 c3                	mov    %eax,%ebx
  8026e6:	72 08                	jb     8026f0 <__umoddi3+0x110>
  8026e8:	75 11                	jne    8026fb <__umoddi3+0x11b>
  8026ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ee:	73 0b                	jae    8026fb <__umoddi3+0x11b>
  8026f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026f4:	1b 14 24             	sbb    (%esp),%edx
  8026f7:	89 d1                	mov    %edx,%ecx
  8026f9:	89 c3                	mov    %eax,%ebx
  8026fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026ff:	29 da                	sub    %ebx,%edx
  802701:	19 ce                	sbb    %ecx,%esi
  802703:	89 f9                	mov    %edi,%ecx
  802705:	89 f0                	mov    %esi,%eax
  802707:	d3 e0                	shl    %cl,%eax
  802709:	89 e9                	mov    %ebp,%ecx
  80270b:	d3 ea                	shr    %cl,%edx
  80270d:	89 e9                	mov    %ebp,%ecx
  80270f:	d3 ee                	shr    %cl,%esi
  802711:	09 d0                	or     %edx,%eax
  802713:	89 f2                	mov    %esi,%edx
  802715:	83 c4 1c             	add    $0x1c,%esp
  802718:	5b                   	pop    %ebx
  802719:	5e                   	pop    %esi
  80271a:	5f                   	pop    %edi
  80271b:	5d                   	pop    %ebp
  80271c:	c3                   	ret    
  80271d:	8d 76 00             	lea    0x0(%esi),%esi
  802720:	29 f9                	sub    %edi,%ecx
  802722:	19 d6                	sbb    %edx,%esi
  802724:	89 74 24 04          	mov    %esi,0x4(%esp)
  802728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80272c:	e9 18 ff ff ff       	jmp    802649 <__umoddi3+0x69>
