
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 71 28 80 00       	push   $0x802871
  800049:	68 40 28 80 00       	push   $0x802840
  80004e:	e8 77 06 00 00       	call   8006ca <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 50 28 80 00       	push   $0x802850
  80005c:	68 54 28 80 00       	push   $0x802854
  800061:	e8 64 06 00 00       	call   8006ca <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 64 28 80 00       	push   $0x802864
  800077:	e8 4e 06 00 00       	call   8006ca <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 68 28 80 00       	push   $0x802868
  80008e:	e8 37 06 00 00       	call   8006ca <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 72 28 80 00       	push   $0x802872
  8000a6:	68 54 28 80 00       	push   $0x802854
  8000ab:	e8 1a 06 00 00       	call   8006ca <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 64 28 80 00       	push   $0x802864
  8000c3:	e8 02 06 00 00       	call   8006ca <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 68 28 80 00       	push   $0x802868
  8000d5:	e8 f0 05 00 00       	call   8006ca <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 76 28 80 00       	push   $0x802876
  8000ed:	68 54 28 80 00       	push   $0x802854
  8000f2:	e8 d3 05 00 00       	call   8006ca <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 64 28 80 00       	push   $0x802864
  80010a:	e8 bb 05 00 00       	call   8006ca <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 68 28 80 00       	push   $0x802868
  80011c:	e8 a9 05 00 00       	call   8006ca <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 7a 28 80 00       	push   $0x80287a
  800134:	68 54 28 80 00       	push   $0x802854
  800139:	e8 8c 05 00 00       	call   8006ca <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 64 28 80 00       	push   $0x802864
  800151:	e8 74 05 00 00       	call   8006ca <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 68 28 80 00       	push   $0x802868
  800163:	e8 62 05 00 00       	call   8006ca <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 7e 28 80 00       	push   $0x80287e
  80017b:	68 54 28 80 00       	push   $0x802854
  800180:	e8 45 05 00 00       	call   8006ca <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 64 28 80 00       	push   $0x802864
  800198:	e8 2d 05 00 00       	call   8006ca <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 68 28 80 00       	push   $0x802868
  8001aa:	e8 1b 05 00 00       	call   8006ca <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 82 28 80 00       	push   $0x802882
  8001c2:	68 54 28 80 00       	push   $0x802854
  8001c7:	e8 fe 04 00 00       	call   8006ca <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 64 28 80 00       	push   $0x802864
  8001df:	e8 e6 04 00 00       	call   8006ca <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 68 28 80 00       	push   $0x802868
  8001f1:	e8 d4 04 00 00       	call   8006ca <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 86 28 80 00       	push   $0x802886
  800209:	68 54 28 80 00       	push   $0x802854
  80020e:	e8 b7 04 00 00       	call   8006ca <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 64 28 80 00       	push   $0x802864
  800226:	e8 9f 04 00 00       	call   8006ca <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 68 28 80 00       	push   $0x802868
  800238:	e8 8d 04 00 00       	call   8006ca <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 8a 28 80 00       	push   $0x80288a
  800250:	68 54 28 80 00       	push   $0x802854
  800255:	e8 70 04 00 00       	call   8006ca <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 64 28 80 00       	push   $0x802864
  80026d:	e8 58 04 00 00       	call   8006ca <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 68 28 80 00       	push   $0x802868
  80027f:	e8 46 04 00 00       	call   8006ca <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 8e 28 80 00       	push   $0x80288e
  800297:	68 54 28 80 00       	push   $0x802854
  80029c:	e8 29 04 00 00       	call   8006ca <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 64 28 80 00       	push   $0x802864
  8002b4:	e8 11 04 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 95 28 80 00       	push   $0x802895
  8002c4:	68 54 28 80 00       	push   $0x802854
  8002c9:	e8 fc 03 00 00       	call   8006ca <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 68 28 80 00       	push   $0x802868
  8002e3:	e8 e2 03 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 95 28 80 00       	push   $0x802895
  8002f3:	68 54 28 80 00       	push   $0x802854
  8002f8:	e8 cd 03 00 00       	call   8006ca <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 64 28 80 00       	push   $0x802864
  800312:	e8 b3 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 99 28 80 00       	push   $0x802899
  800322:	e8 a3 03 00 00       	call   8006ca <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 68 28 80 00       	push   $0x802868
  800338:	e8 8d 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 99 28 80 00       	push   $0x802899
  800348:	e8 7d 03 00 00       	call   8006ca <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 64 28 80 00       	push   $0x802864
  80035a:	e8 6b 03 00 00       	call   8006ca <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 68 28 80 00       	push   $0x802868
  80036c:	e8 59 03 00 00       	call   8006ca <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 64 28 80 00       	push   $0x802864
  80037e:	e8 47 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 99 28 80 00       	push   $0x802899
  80038e:	e8 37 03 00 00       	call   8006ca <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 00 29 80 00       	push   $0x802900
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 a7 28 80 00       	push   $0x8028a7
  8003c6:	e8 26 02 00 00       	call   8005f1 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 bf 28 80 00       	push   $0x8028bf
  800435:	68 cd 28 80 00       	push   $0x8028cd
  80043a:	b9 40 40 80 00       	mov    $0x804040,%ecx
  80043f:	ba b8 28 80 00       	mov    $0x8028b8,%edx
  800444:	b8 80 40 80 00       	mov    $0x804080,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 13 0c 00 00       	call   801072 <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 d4 28 80 00       	push   $0x8028d4
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 a7 28 80 00       	push   $0x8028a7
  800473:	e8 79 01 00 00       	call   8005f1 <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 f8 0d 00 00       	call   801282 <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004ab:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b1:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004b7:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004bd:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c3:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004c9:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004ce:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004e4:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004ea:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f0:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004f6:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004fc:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800502:	a3 1c 40 80 00       	mov    %eax,0x80401c
  800507:	89 25 28 40 80 00    	mov    %esp,0x804028
  80050d:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800513:	8b 35 84 40 80 00    	mov    0x804084,%esi
  800519:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  80051f:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  800525:	8b 15 94 40 80 00    	mov    0x804094,%edx
  80052b:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800531:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800536:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 24 40 80 00       	mov    %eax,0x804024
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 34 29 80 00       	push   $0x802934
  800559:	e8 6c 01 00 00       	call   8006ca <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  800566:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 e7 28 80 00       	push   $0x8028e7
  800573:	68 f8 28 80 00       	push   $0x8028f8
  800578:	b9 00 40 80 00       	mov    $0x804000,%ecx
  80057d:	ba b8 28 80 00       	mov    $0x8028b8,%edx
  800582:	b8 80 40 80 00       	mov    $0x804080,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
}
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80059c:	e8 93 0a 00 00       	call   801034 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8005a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005ae:	a3 b4 40 80 00       	mov    %eax,0x8040b4
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b3:	85 db                	test   %ebx,%ebx
  8005b5:	7e 07                	jle    8005be <libmain+0x2d>
		binaryname = argv[0];
  8005b7:	8b 06                	mov    (%esi),%eax
  8005b9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	e8 b2 fe ff ff       	call   80047a <umain>

	// exit gracefully
	exit();
  8005c8:	e8 0a 00 00 00       	call   8005d7 <exit>
}
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d3:	5b                   	pop    %ebx
  8005d4:	5e                   	pop    %esi
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005dd:	e8 01 0f 00 00       	call   8014e3 <close_all>
	sys_env_destroy(0);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	6a 00                	push   $0x0
  8005e7:	e8 07 0a 00 00       	call   800ff3 <sys_env_destroy>
}
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	c9                   	leave  
  8005f0:	c3                   	ret    

008005f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f1:	55                   	push   %ebp
  8005f2:	89 e5                	mov    %esp,%ebp
  8005f4:	56                   	push   %esi
  8005f5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005f6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8005ff:	e8 30 0a 00 00       	call   801034 <sys_getenvid>
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	ff 75 0c             	pushl  0xc(%ebp)
  80060a:	ff 75 08             	pushl  0x8(%ebp)
  80060d:	56                   	push   %esi
  80060e:	50                   	push   %eax
  80060f:	68 60 29 80 00       	push   $0x802960
  800614:	e8 b1 00 00 00       	call   8006ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800619:	83 c4 18             	add    $0x18,%esp
  80061c:	53                   	push   %ebx
  80061d:	ff 75 10             	pushl  0x10(%ebp)
  800620:	e8 54 00 00 00       	call   800679 <vcprintf>
	cprintf("\n");
  800625:	c7 04 24 70 28 80 00 	movl   $0x802870,(%esp)
  80062c:	e8 99 00 00 00       	call   8006ca <cprintf>
  800631:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800634:	cc                   	int3   
  800635:	eb fd                	jmp    800634 <_panic+0x43>

00800637 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 04             	sub    $0x4,%esp
  80063e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800641:	8b 13                	mov    (%ebx),%edx
  800643:	8d 42 01             	lea    0x1(%edx),%eax
  800646:	89 03                	mov    %eax,(%ebx)
  800648:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80064b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80064f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800654:	75 1a                	jne    800670 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	68 ff 00 00 00       	push   $0xff
  80065e:	8d 43 08             	lea    0x8(%ebx),%eax
  800661:	50                   	push   %eax
  800662:	e8 4f 09 00 00       	call   800fb6 <sys_cputs>
		b->idx = 0;
  800667:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80066d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800670:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800677:	c9                   	leave  
  800678:	c3                   	ret    

00800679 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800682:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800689:	00 00 00 
	b.cnt = 0;
  80068c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800693:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	ff 75 08             	pushl  0x8(%ebp)
  80069c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a2:	50                   	push   %eax
  8006a3:	68 37 06 80 00       	push   $0x800637
  8006a8:	e8 54 01 00 00       	call   800801 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ad:	83 c4 08             	add    $0x8,%esp
  8006b0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006bc:	50                   	push   %eax
  8006bd:	e8 f4 08 00 00       	call   800fb6 <sys_cputs>

	return b.cnt;
}
  8006c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d3:	50                   	push   %eax
  8006d4:	ff 75 08             	pushl  0x8(%ebp)
  8006d7:	e8 9d ff ff ff       	call   800679 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	57                   	push   %edi
  8006e2:	56                   	push   %esi
  8006e3:	53                   	push   %ebx
  8006e4:	83 ec 1c             	sub    $0x1c,%esp
  8006e7:	89 c7                	mov    %eax,%edi
  8006e9:	89 d6                	mov    %edx,%esi
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800702:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800705:	39 d3                	cmp    %edx,%ebx
  800707:	72 05                	jb     80070e <printnum+0x30>
  800709:	39 45 10             	cmp    %eax,0x10(%ebp)
  80070c:	77 45                	ja     800753 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80070e:	83 ec 0c             	sub    $0xc,%esp
  800711:	ff 75 18             	pushl  0x18(%ebp)
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80071a:	53                   	push   %ebx
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	ff 75 e4             	pushl  -0x1c(%ebp)
  800724:	ff 75 e0             	pushl  -0x20(%ebp)
  800727:	ff 75 dc             	pushl  -0x24(%ebp)
  80072a:	ff 75 d8             	pushl  -0x28(%ebp)
  80072d:	e8 7e 1e 00 00       	call   8025b0 <__udivdi3>
  800732:	83 c4 18             	add    $0x18,%esp
  800735:	52                   	push   %edx
  800736:	50                   	push   %eax
  800737:	89 f2                	mov    %esi,%edx
  800739:	89 f8                	mov    %edi,%eax
  80073b:	e8 9e ff ff ff       	call   8006de <printnum>
  800740:	83 c4 20             	add    $0x20,%esp
  800743:	eb 18                	jmp    80075d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	56                   	push   %esi
  800749:	ff 75 18             	pushl  0x18(%ebp)
  80074c:	ff d7                	call   *%edi
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	eb 03                	jmp    800756 <printnum+0x78>
  800753:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800756:	83 eb 01             	sub    $0x1,%ebx
  800759:	85 db                	test   %ebx,%ebx
  80075b:	7f e8                	jg     800745 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	56                   	push   %esi
  800761:	83 ec 04             	sub    $0x4,%esp
  800764:	ff 75 e4             	pushl  -0x1c(%ebp)
  800767:	ff 75 e0             	pushl  -0x20(%ebp)
  80076a:	ff 75 dc             	pushl  -0x24(%ebp)
  80076d:	ff 75 d8             	pushl  -0x28(%ebp)
  800770:	e8 6b 1f 00 00       	call   8026e0 <__umoddi3>
  800775:	83 c4 14             	add    $0x14,%esp
  800778:	0f be 80 83 29 80 00 	movsbl 0x802983(%eax),%eax
  80077f:	50                   	push   %eax
  800780:	ff d7                	call   *%edi
}
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5f                   	pop    %edi
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800790:	83 fa 01             	cmp    $0x1,%edx
  800793:	7e 0e                	jle    8007a3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800795:	8b 10                	mov    (%eax),%edx
  800797:	8d 4a 08             	lea    0x8(%edx),%ecx
  80079a:	89 08                	mov    %ecx,(%eax)
  80079c:	8b 02                	mov    (%edx),%eax
  80079e:	8b 52 04             	mov    0x4(%edx),%edx
  8007a1:	eb 22                	jmp    8007c5 <getuint+0x38>
	else if (lflag)
  8007a3:	85 d2                	test   %edx,%edx
  8007a5:	74 10                	je     8007b7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007ac:	89 08                	mov    %ecx,(%eax)
  8007ae:	8b 02                	mov    (%edx),%eax
  8007b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b5:	eb 0e                	jmp    8007c5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b7:	8b 10                	mov    (%eax),%edx
  8007b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007bc:	89 08                	mov    %ecx,(%eax)
  8007be:	8b 02                	mov    (%edx),%eax
  8007c0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007cd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d1:	8b 10                	mov    (%eax),%edx
  8007d3:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d6:	73 0a                	jae    8007e2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007db:	89 08                	mov    %ecx,(%eax)
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	88 02                	mov    %al,(%edx)
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007ea:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007ed:	50                   	push   %eax
  8007ee:	ff 75 10             	pushl  0x10(%ebp)
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	ff 75 08             	pushl  0x8(%ebp)
  8007f7:	e8 05 00 00 00       	call   800801 <vprintfmt>
	va_end(ap);
}
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	57                   	push   %edi
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	83 ec 2c             	sub    $0x2c,%esp
  80080a:	8b 75 08             	mov    0x8(%ebp),%esi
  80080d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800810:	8b 7d 10             	mov    0x10(%ebp),%edi
  800813:	eb 12                	jmp    800827 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800815:	85 c0                	test   %eax,%eax
  800817:	0f 84 a9 03 00 00    	je     800bc6 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	53                   	push   %ebx
  800821:	50                   	push   %eax
  800822:	ff d6                	call   *%esi
  800824:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800827:	83 c7 01             	add    $0x1,%edi
  80082a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80082e:	83 f8 25             	cmp    $0x25,%eax
  800831:	75 e2                	jne    800815 <vprintfmt+0x14>
  800833:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800837:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80083e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800845:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80084c:	ba 00 00 00 00       	mov    $0x0,%edx
  800851:	eb 07                	jmp    80085a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800853:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800856:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	8d 47 01             	lea    0x1(%edi),%eax
  80085d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800860:	0f b6 07             	movzbl (%edi),%eax
  800863:	0f b6 c8             	movzbl %al,%ecx
  800866:	83 e8 23             	sub    $0x23,%eax
  800869:	3c 55                	cmp    $0x55,%al
  80086b:	0f 87 3a 03 00 00    	ja     800bab <vprintfmt+0x3aa>
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	ff 24 85 c0 2a 80 00 	jmp    *0x802ac0(,%eax,4)
  80087b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80087e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800882:	eb d6                	jmp    80085a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800884:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
  80088c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800892:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800896:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800899:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80089c:	83 fa 09             	cmp    $0x9,%edx
  80089f:	77 39                	ja     8008da <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008a4:	eb e9                	jmp    80088f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8d 48 04             	lea    0x4(%eax),%ecx
  8008ac:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008af:	8b 00                	mov    (%eax),%eax
  8008b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b7:	eb 27                	jmp    8008e0 <vprintfmt+0xdf>
  8008b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008bc:	85 c0                	test   %eax,%eax
  8008be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c3:	0f 49 c8             	cmovns %eax,%ecx
  8008c6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008cc:	eb 8c                	jmp    80085a <vprintfmt+0x59>
  8008ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d8:	eb 80                	jmp    80085a <vprintfmt+0x59>
  8008da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008dd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e4:	0f 89 70 ff ff ff    	jns    80085a <vprintfmt+0x59>
				width = precision, precision = -1;
  8008ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008f7:	e9 5e ff ff ff       	jmp    80085a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008fc:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800902:	e9 53 ff ff ff       	jmp    80085a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800907:	8b 45 14             	mov    0x14(%ebp),%eax
  80090a:	8d 50 04             	lea    0x4(%eax),%edx
  80090d:	89 55 14             	mov    %edx,0x14(%ebp)
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	53                   	push   %ebx
  800914:	ff 30                	pushl  (%eax)
  800916:	ff d6                	call   *%esi
			break;
  800918:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80091e:	e9 04 ff ff ff       	jmp    800827 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8d 50 04             	lea    0x4(%eax),%edx
  800929:	89 55 14             	mov    %edx,0x14(%ebp)
  80092c:	8b 00                	mov    (%eax),%eax
  80092e:	99                   	cltd   
  80092f:	31 d0                	xor    %edx,%eax
  800931:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800933:	83 f8 0f             	cmp    $0xf,%eax
  800936:	7f 0b                	jg     800943 <vprintfmt+0x142>
  800938:	8b 14 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%edx
  80093f:	85 d2                	test   %edx,%edx
  800941:	75 18                	jne    80095b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800943:	50                   	push   %eax
  800944:	68 9b 29 80 00       	push   $0x80299b
  800949:	53                   	push   %ebx
  80094a:	56                   	push   %esi
  80094b:	e8 94 fe ff ff       	call   8007e4 <printfmt>
  800950:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800953:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800956:	e9 cc fe ff ff       	jmp    800827 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80095b:	52                   	push   %edx
  80095c:	68 91 2d 80 00       	push   $0x802d91
  800961:	53                   	push   %ebx
  800962:	56                   	push   %esi
  800963:	e8 7c fe ff ff       	call   8007e4 <printfmt>
  800968:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096e:	e9 b4 fe ff ff       	jmp    800827 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800973:	8b 45 14             	mov    0x14(%ebp),%eax
  800976:	8d 50 04             	lea    0x4(%eax),%edx
  800979:	89 55 14             	mov    %edx,0x14(%ebp)
  80097c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80097e:	85 ff                	test   %edi,%edi
  800980:	b8 94 29 80 00       	mov    $0x802994,%eax
  800985:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800988:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098c:	0f 8e 94 00 00 00    	jle    800a26 <vprintfmt+0x225>
  800992:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800996:	0f 84 98 00 00 00    	je     800a34 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80099c:	83 ec 08             	sub    $0x8,%esp
  80099f:	ff 75 d0             	pushl  -0x30(%ebp)
  8009a2:	57                   	push   %edi
  8009a3:	e8 a6 02 00 00       	call   800c4e <strnlen>
  8009a8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009ab:	29 c1                	sub    %eax,%ecx
  8009ad:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009b0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009ba:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009bd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bf:	eb 0f                	jmp    8009d0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009c1:	83 ec 08             	sub    $0x8,%esp
  8009c4:	53                   	push   %ebx
  8009c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ca:	83 ef 01             	sub    $0x1,%edi
  8009cd:	83 c4 10             	add    $0x10,%esp
  8009d0:	85 ff                	test   %edi,%edi
  8009d2:	7f ed                	jg     8009c1 <vprintfmt+0x1c0>
  8009d4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009da:	85 c9                	test   %ecx,%ecx
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e1:	0f 49 c1             	cmovns %ecx,%eax
  8009e4:	29 c1                	sub    %eax,%ecx
  8009e6:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009ec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009ef:	89 cb                	mov    %ecx,%ebx
  8009f1:	eb 4d                	jmp    800a40 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f7:	74 1b                	je     800a14 <vprintfmt+0x213>
  8009f9:	0f be c0             	movsbl %al,%eax
  8009fc:	83 e8 20             	sub    $0x20,%eax
  8009ff:	83 f8 5e             	cmp    $0x5e,%eax
  800a02:	76 10                	jbe    800a14 <vprintfmt+0x213>
					putch('?', putdat);
  800a04:	83 ec 08             	sub    $0x8,%esp
  800a07:	ff 75 0c             	pushl  0xc(%ebp)
  800a0a:	6a 3f                	push   $0x3f
  800a0c:	ff 55 08             	call   *0x8(%ebp)
  800a0f:	83 c4 10             	add    $0x10,%esp
  800a12:	eb 0d                	jmp    800a21 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a14:	83 ec 08             	sub    $0x8,%esp
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	52                   	push   %edx
  800a1b:	ff 55 08             	call   *0x8(%ebp)
  800a1e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a21:	83 eb 01             	sub    $0x1,%ebx
  800a24:	eb 1a                	jmp    800a40 <vprintfmt+0x23f>
  800a26:	89 75 08             	mov    %esi,0x8(%ebp)
  800a29:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a2c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a2f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a32:	eb 0c                	jmp    800a40 <vprintfmt+0x23f>
  800a34:	89 75 08             	mov    %esi,0x8(%ebp)
  800a37:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a3a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a3d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a40:	83 c7 01             	add    $0x1,%edi
  800a43:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a47:	0f be d0             	movsbl %al,%edx
  800a4a:	85 d2                	test   %edx,%edx
  800a4c:	74 23                	je     800a71 <vprintfmt+0x270>
  800a4e:	85 f6                	test   %esi,%esi
  800a50:	78 a1                	js     8009f3 <vprintfmt+0x1f2>
  800a52:	83 ee 01             	sub    $0x1,%esi
  800a55:	79 9c                	jns    8009f3 <vprintfmt+0x1f2>
  800a57:	89 df                	mov    %ebx,%edi
  800a59:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5f:	eb 18                	jmp    800a79 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a61:	83 ec 08             	sub    $0x8,%esp
  800a64:	53                   	push   %ebx
  800a65:	6a 20                	push   $0x20
  800a67:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a69:	83 ef 01             	sub    $0x1,%edi
  800a6c:	83 c4 10             	add    $0x10,%esp
  800a6f:	eb 08                	jmp    800a79 <vprintfmt+0x278>
  800a71:	89 df                	mov    %ebx,%edi
  800a73:	8b 75 08             	mov    0x8(%ebp),%esi
  800a76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a79:	85 ff                	test   %edi,%edi
  800a7b:	7f e4                	jg     800a61 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a80:	e9 a2 fd ff ff       	jmp    800827 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a85:	83 fa 01             	cmp    $0x1,%edx
  800a88:	7e 16                	jle    800aa0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8d:	8d 50 08             	lea    0x8(%eax),%edx
  800a90:	89 55 14             	mov    %edx,0x14(%ebp)
  800a93:	8b 50 04             	mov    0x4(%eax),%edx
  800a96:	8b 00                	mov    (%eax),%eax
  800a98:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a9b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a9e:	eb 32                	jmp    800ad2 <vprintfmt+0x2d1>
	else if (lflag)
  800aa0:	85 d2                	test   %edx,%edx
  800aa2:	74 18                	je     800abc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800aa4:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa7:	8d 50 04             	lea    0x4(%eax),%edx
  800aaa:	89 55 14             	mov    %edx,0x14(%ebp)
  800aad:	8b 00                	mov    (%eax),%eax
  800aaf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab2:	89 c1                	mov    %eax,%ecx
  800ab4:	c1 f9 1f             	sar    $0x1f,%ecx
  800ab7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800aba:	eb 16                	jmp    800ad2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800abc:	8b 45 14             	mov    0x14(%ebp),%eax
  800abf:	8d 50 04             	lea    0x4(%eax),%edx
  800ac2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac5:	8b 00                	mov    (%eax),%eax
  800ac7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aca:	89 c1                	mov    %eax,%ecx
  800acc:	c1 f9 1f             	sar    $0x1f,%ecx
  800acf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ad5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ad8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800add:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ae1:	0f 89 90 00 00 00    	jns    800b77 <vprintfmt+0x376>
				putch('-', putdat);
  800ae7:	83 ec 08             	sub    $0x8,%esp
  800aea:	53                   	push   %ebx
  800aeb:	6a 2d                	push   $0x2d
  800aed:	ff d6                	call   *%esi
				num = -(long long) num;
  800aef:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800af2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800af5:	f7 d8                	neg    %eax
  800af7:	83 d2 00             	adc    $0x0,%edx
  800afa:	f7 da                	neg    %edx
  800afc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800aff:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b04:	eb 71                	jmp    800b77 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b06:	8d 45 14             	lea    0x14(%ebp),%eax
  800b09:	e8 7f fc ff ff       	call   80078d <getuint>
			base = 10;
  800b0e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b13:	eb 62                	jmp    800b77 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b15:	8d 45 14             	lea    0x14(%ebp),%eax
  800b18:	e8 70 fc ff ff       	call   80078d <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800b24:	51                   	push   %ecx
  800b25:	ff 75 e0             	pushl  -0x20(%ebp)
  800b28:	6a 08                	push   $0x8
  800b2a:	52                   	push   %edx
  800b2b:	50                   	push   %eax
  800b2c:	89 da                	mov    %ebx,%edx
  800b2e:	89 f0                	mov    %esi,%eax
  800b30:	e8 a9 fb ff ff       	call   8006de <printnum>
			break;
  800b35:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800b3b:	e9 e7 fc ff ff       	jmp    800827 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800b40:	83 ec 08             	sub    $0x8,%esp
  800b43:	53                   	push   %ebx
  800b44:	6a 30                	push   $0x30
  800b46:	ff d6                	call   *%esi
			putch('x', putdat);
  800b48:	83 c4 08             	add    $0x8,%esp
  800b4b:	53                   	push   %ebx
  800b4c:	6a 78                	push   $0x78
  800b4e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b50:	8b 45 14             	mov    0x14(%ebp),%eax
  800b53:	8d 50 04             	lea    0x4(%eax),%edx
  800b56:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b59:	8b 00                	mov    (%eax),%eax
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b60:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b63:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b68:	eb 0d                	jmp    800b77 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b6a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b6d:	e8 1b fc ff ff       	call   80078d <getuint>
			base = 16;
  800b72:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b7e:	57                   	push   %edi
  800b7f:	ff 75 e0             	pushl  -0x20(%ebp)
  800b82:	51                   	push   %ecx
  800b83:	52                   	push   %edx
  800b84:	50                   	push   %eax
  800b85:	89 da                	mov    %ebx,%edx
  800b87:	89 f0                	mov    %esi,%eax
  800b89:	e8 50 fb ff ff       	call   8006de <printnum>
			break;
  800b8e:	83 c4 20             	add    $0x20,%esp
  800b91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b94:	e9 8e fc ff ff       	jmp    800827 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b99:	83 ec 08             	sub    $0x8,%esp
  800b9c:	53                   	push   %ebx
  800b9d:	51                   	push   %ecx
  800b9e:	ff d6                	call   *%esi
			break;
  800ba0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ba3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ba6:	e9 7c fc ff ff       	jmp    800827 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bab:	83 ec 08             	sub    $0x8,%esp
  800bae:	53                   	push   %ebx
  800baf:	6a 25                	push   $0x25
  800bb1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bb3:	83 c4 10             	add    $0x10,%esp
  800bb6:	eb 03                	jmp    800bbb <vprintfmt+0x3ba>
  800bb8:	83 ef 01             	sub    $0x1,%edi
  800bbb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800bbf:	75 f7                	jne    800bb8 <vprintfmt+0x3b7>
  800bc1:	e9 61 fc ff ff       	jmp    800827 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	83 ec 18             	sub    $0x18,%esp
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bda:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bdd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800be1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800be4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800beb:	85 c0                	test   %eax,%eax
  800bed:	74 26                	je     800c15 <vsnprintf+0x47>
  800bef:	85 d2                	test   %edx,%edx
  800bf1:	7e 22                	jle    800c15 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bf3:	ff 75 14             	pushl  0x14(%ebp)
  800bf6:	ff 75 10             	pushl  0x10(%ebp)
  800bf9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bfc:	50                   	push   %eax
  800bfd:	68 c7 07 80 00       	push   $0x8007c7
  800c02:	e8 fa fb ff ff       	call   800801 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c0a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c10:	83 c4 10             	add    $0x10,%esp
  800c13:	eb 05                	jmp    800c1a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    

00800c1c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c22:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c25:	50                   	push   %eax
  800c26:	ff 75 10             	pushl  0x10(%ebp)
  800c29:	ff 75 0c             	pushl  0xc(%ebp)
  800c2c:	ff 75 08             	pushl  0x8(%ebp)
  800c2f:	e8 9a ff ff ff       	call   800bce <vsnprintf>
	va_end(ap);

	return rc;
}
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c41:	eb 03                	jmp    800c46 <strlen+0x10>
		n++;
  800c43:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c46:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c4a:	75 f7                	jne    800c43 <strlen+0xd>
		n++;
	return n;
}
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c54:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c57:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5c:	eb 03                	jmp    800c61 <strnlen+0x13>
		n++;
  800c5e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c61:	39 c2                	cmp    %eax,%edx
  800c63:	74 08                	je     800c6d <strnlen+0x1f>
  800c65:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c69:	75 f3                	jne    800c5e <strnlen+0x10>
  800c6b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	53                   	push   %ebx
  800c73:	8b 45 08             	mov    0x8(%ebp),%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c79:	89 c2                	mov    %eax,%edx
  800c7b:	83 c2 01             	add    $0x1,%edx
  800c7e:	83 c1 01             	add    $0x1,%ecx
  800c81:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c85:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c88:	84 db                	test   %bl,%bl
  800c8a:	75 ef                	jne    800c7b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	53                   	push   %ebx
  800c93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c96:	53                   	push   %ebx
  800c97:	e8 9a ff ff ff       	call   800c36 <strlen>
  800c9c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c9f:	ff 75 0c             	pushl  0xc(%ebp)
  800ca2:	01 d8                	add    %ebx,%eax
  800ca4:	50                   	push   %eax
  800ca5:	e8 c5 ff ff ff       	call   800c6f <strcpy>
	return dst;
}
  800caa:	89 d8                	mov    %ebx,%eax
  800cac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
  800cb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	89 f3                	mov    %esi,%ebx
  800cbe:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cc1:	89 f2                	mov    %esi,%edx
  800cc3:	eb 0f                	jmp    800cd4 <strncpy+0x23>
		*dst++ = *src;
  800cc5:	83 c2 01             	add    $0x1,%edx
  800cc8:	0f b6 01             	movzbl (%ecx),%eax
  800ccb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cce:	80 39 01             	cmpb   $0x1,(%ecx)
  800cd1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd4:	39 da                	cmp    %ebx,%edx
  800cd6:	75 ed                	jne    800cc5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cd8:	89 f0                	mov    %esi,%eax
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	8b 55 10             	mov    0x10(%ebp),%edx
  800cec:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cee:	85 d2                	test   %edx,%edx
  800cf0:	74 21                	je     800d13 <strlcpy+0x35>
  800cf2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cf6:	89 f2                	mov    %esi,%edx
  800cf8:	eb 09                	jmp    800d03 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cfa:	83 c2 01             	add    $0x1,%edx
  800cfd:	83 c1 01             	add    $0x1,%ecx
  800d00:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d03:	39 c2                	cmp    %eax,%edx
  800d05:	74 09                	je     800d10 <strlcpy+0x32>
  800d07:	0f b6 19             	movzbl (%ecx),%ebx
  800d0a:	84 db                	test   %bl,%bl
  800d0c:	75 ec                	jne    800cfa <strlcpy+0x1c>
  800d0e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d10:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d13:	29 f0                	sub    %esi,%eax
}
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d22:	eb 06                	jmp    800d2a <strcmp+0x11>
		p++, q++;
  800d24:	83 c1 01             	add    $0x1,%ecx
  800d27:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d2a:	0f b6 01             	movzbl (%ecx),%eax
  800d2d:	84 c0                	test   %al,%al
  800d2f:	74 04                	je     800d35 <strcmp+0x1c>
  800d31:	3a 02                	cmp    (%edx),%al
  800d33:	74 ef                	je     800d24 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d35:	0f b6 c0             	movzbl %al,%eax
  800d38:	0f b6 12             	movzbl (%edx),%edx
  800d3b:	29 d0                	sub    %edx,%eax
}
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	53                   	push   %ebx
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d49:	89 c3                	mov    %eax,%ebx
  800d4b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d4e:	eb 06                	jmp    800d56 <strncmp+0x17>
		n--, p++, q++;
  800d50:	83 c0 01             	add    $0x1,%eax
  800d53:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d56:	39 d8                	cmp    %ebx,%eax
  800d58:	74 15                	je     800d6f <strncmp+0x30>
  800d5a:	0f b6 08             	movzbl (%eax),%ecx
  800d5d:	84 c9                	test   %cl,%cl
  800d5f:	74 04                	je     800d65 <strncmp+0x26>
  800d61:	3a 0a                	cmp    (%edx),%cl
  800d63:	74 eb                	je     800d50 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d65:	0f b6 00             	movzbl (%eax),%eax
  800d68:	0f b6 12             	movzbl (%edx),%edx
  800d6b:	29 d0                	sub    %edx,%eax
  800d6d:	eb 05                	jmp    800d74 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d6f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d74:	5b                   	pop    %ebx
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d81:	eb 07                	jmp    800d8a <strchr+0x13>
		if (*s == c)
  800d83:	38 ca                	cmp    %cl,%dl
  800d85:	74 0f                	je     800d96 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d87:	83 c0 01             	add    $0x1,%eax
  800d8a:	0f b6 10             	movzbl (%eax),%edx
  800d8d:	84 d2                	test   %dl,%dl
  800d8f:	75 f2                	jne    800d83 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800da2:	eb 03                	jmp    800da7 <strfind+0xf>
  800da4:	83 c0 01             	add    $0x1,%eax
  800da7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800daa:	38 ca                	cmp    %cl,%dl
  800dac:	74 04                	je     800db2 <strfind+0x1a>
  800dae:	84 d2                	test   %dl,%dl
  800db0:	75 f2                	jne    800da4 <strfind+0xc>
			break;
	return (char *) s;
}
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dc0:	85 c9                	test   %ecx,%ecx
  800dc2:	74 36                	je     800dfa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dc4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dca:	75 28                	jne    800df4 <memset+0x40>
  800dcc:	f6 c1 03             	test   $0x3,%cl
  800dcf:	75 23                	jne    800df4 <memset+0x40>
		c &= 0xFF;
  800dd1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dd5:	89 d3                	mov    %edx,%ebx
  800dd7:	c1 e3 08             	shl    $0x8,%ebx
  800dda:	89 d6                	mov    %edx,%esi
  800ddc:	c1 e6 18             	shl    $0x18,%esi
  800ddf:	89 d0                	mov    %edx,%eax
  800de1:	c1 e0 10             	shl    $0x10,%eax
  800de4:	09 f0                	or     %esi,%eax
  800de6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800de8:	89 d8                	mov    %ebx,%eax
  800dea:	09 d0                	or     %edx,%eax
  800dec:	c1 e9 02             	shr    $0x2,%ecx
  800def:	fc                   	cld    
  800df0:	f3 ab                	rep stos %eax,%es:(%edi)
  800df2:	eb 06                	jmp    800dfa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800df4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df7:	fc                   	cld    
  800df8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dfa:	89 f8                	mov    %edi,%eax
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e0f:	39 c6                	cmp    %eax,%esi
  800e11:	73 35                	jae    800e48 <memmove+0x47>
  800e13:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e16:	39 d0                	cmp    %edx,%eax
  800e18:	73 2e                	jae    800e48 <memmove+0x47>
		s += n;
		d += n;
  800e1a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e1d:	89 d6                	mov    %edx,%esi
  800e1f:	09 fe                	or     %edi,%esi
  800e21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e27:	75 13                	jne    800e3c <memmove+0x3b>
  800e29:	f6 c1 03             	test   $0x3,%cl
  800e2c:	75 0e                	jne    800e3c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e2e:	83 ef 04             	sub    $0x4,%edi
  800e31:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e34:	c1 e9 02             	shr    $0x2,%ecx
  800e37:	fd                   	std    
  800e38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e3a:	eb 09                	jmp    800e45 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e3c:	83 ef 01             	sub    $0x1,%edi
  800e3f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e42:	fd                   	std    
  800e43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e45:	fc                   	cld    
  800e46:	eb 1d                	jmp    800e65 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e48:	89 f2                	mov    %esi,%edx
  800e4a:	09 c2                	or     %eax,%edx
  800e4c:	f6 c2 03             	test   $0x3,%dl
  800e4f:	75 0f                	jne    800e60 <memmove+0x5f>
  800e51:	f6 c1 03             	test   $0x3,%cl
  800e54:	75 0a                	jne    800e60 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e56:	c1 e9 02             	shr    $0x2,%ecx
  800e59:	89 c7                	mov    %eax,%edi
  800e5b:	fc                   	cld    
  800e5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e5e:	eb 05                	jmp    800e65 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e60:	89 c7                	mov    %eax,%edi
  800e62:	fc                   	cld    
  800e63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e6c:	ff 75 10             	pushl  0x10(%ebp)
  800e6f:	ff 75 0c             	pushl  0xc(%ebp)
  800e72:	ff 75 08             	pushl  0x8(%ebp)
  800e75:	e8 87 ff ff ff       	call   800e01 <memmove>
}
  800e7a:	c9                   	leave  
  800e7b:	c3                   	ret    

00800e7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
  800e81:	8b 45 08             	mov    0x8(%ebp),%eax
  800e84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e87:	89 c6                	mov    %eax,%esi
  800e89:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e8c:	eb 1a                	jmp    800ea8 <memcmp+0x2c>
		if (*s1 != *s2)
  800e8e:	0f b6 08             	movzbl (%eax),%ecx
  800e91:	0f b6 1a             	movzbl (%edx),%ebx
  800e94:	38 d9                	cmp    %bl,%cl
  800e96:	74 0a                	je     800ea2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e98:	0f b6 c1             	movzbl %cl,%eax
  800e9b:	0f b6 db             	movzbl %bl,%ebx
  800e9e:	29 d8                	sub    %ebx,%eax
  800ea0:	eb 0f                	jmp    800eb1 <memcmp+0x35>
		s1++, s2++;
  800ea2:	83 c0 01             	add    $0x1,%eax
  800ea5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ea8:	39 f0                	cmp    %esi,%eax
  800eaa:	75 e2                	jne    800e8e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	53                   	push   %ebx
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ebc:	89 c1                	mov    %eax,%ecx
  800ebe:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ec1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ec5:	eb 0a                	jmp    800ed1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ec7:	0f b6 10             	movzbl (%eax),%edx
  800eca:	39 da                	cmp    %ebx,%edx
  800ecc:	74 07                	je     800ed5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ece:	83 c0 01             	add    $0x1,%eax
  800ed1:	39 c8                	cmp    %ecx,%eax
  800ed3:	72 f2                	jb     800ec7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ed5:	5b                   	pop    %ebx
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee4:	eb 03                	jmp    800ee9 <strtol+0x11>
		s++;
  800ee6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee9:	0f b6 01             	movzbl (%ecx),%eax
  800eec:	3c 20                	cmp    $0x20,%al
  800eee:	74 f6                	je     800ee6 <strtol+0xe>
  800ef0:	3c 09                	cmp    $0x9,%al
  800ef2:	74 f2                	je     800ee6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ef4:	3c 2b                	cmp    $0x2b,%al
  800ef6:	75 0a                	jne    800f02 <strtol+0x2a>
		s++;
  800ef8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800efb:	bf 00 00 00 00       	mov    $0x0,%edi
  800f00:	eb 11                	jmp    800f13 <strtol+0x3b>
  800f02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f07:	3c 2d                	cmp    $0x2d,%al
  800f09:	75 08                	jne    800f13 <strtol+0x3b>
		s++, neg = 1;
  800f0b:	83 c1 01             	add    $0x1,%ecx
  800f0e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f13:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f19:	75 15                	jne    800f30 <strtol+0x58>
  800f1b:	80 39 30             	cmpb   $0x30,(%ecx)
  800f1e:	75 10                	jne    800f30 <strtol+0x58>
  800f20:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f24:	75 7c                	jne    800fa2 <strtol+0xca>
		s += 2, base = 16;
  800f26:	83 c1 02             	add    $0x2,%ecx
  800f29:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f2e:	eb 16                	jmp    800f46 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f30:	85 db                	test   %ebx,%ebx
  800f32:	75 12                	jne    800f46 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f34:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f39:	80 39 30             	cmpb   $0x30,(%ecx)
  800f3c:	75 08                	jne    800f46 <strtol+0x6e>
		s++, base = 8;
  800f3e:	83 c1 01             	add    $0x1,%ecx
  800f41:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f46:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f4e:	0f b6 11             	movzbl (%ecx),%edx
  800f51:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f54:	89 f3                	mov    %esi,%ebx
  800f56:	80 fb 09             	cmp    $0x9,%bl
  800f59:	77 08                	ja     800f63 <strtol+0x8b>
			dig = *s - '0';
  800f5b:	0f be d2             	movsbl %dl,%edx
  800f5e:	83 ea 30             	sub    $0x30,%edx
  800f61:	eb 22                	jmp    800f85 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f63:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f66:	89 f3                	mov    %esi,%ebx
  800f68:	80 fb 19             	cmp    $0x19,%bl
  800f6b:	77 08                	ja     800f75 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f6d:	0f be d2             	movsbl %dl,%edx
  800f70:	83 ea 57             	sub    $0x57,%edx
  800f73:	eb 10                	jmp    800f85 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f75:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f78:	89 f3                	mov    %esi,%ebx
  800f7a:	80 fb 19             	cmp    $0x19,%bl
  800f7d:	77 16                	ja     800f95 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f7f:	0f be d2             	movsbl %dl,%edx
  800f82:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f85:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f88:	7d 0b                	jge    800f95 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f8a:	83 c1 01             	add    $0x1,%ecx
  800f8d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f91:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f93:	eb b9                	jmp    800f4e <strtol+0x76>

	if (endptr)
  800f95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f99:	74 0d                	je     800fa8 <strtol+0xd0>
		*endptr = (char *) s;
  800f9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f9e:	89 0e                	mov    %ecx,(%esi)
  800fa0:	eb 06                	jmp    800fa8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fa2:	85 db                	test   %ebx,%ebx
  800fa4:	74 98                	je     800f3e <strtol+0x66>
  800fa6:	eb 9e                	jmp    800f46 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fa8:	89 c2                	mov    %eax,%edx
  800faa:	f7 da                	neg    %edx
  800fac:	85 ff                	test   %edi,%edi
  800fae:	0f 45 c2             	cmovne %edx,%eax
}
  800fb1:	5b                   	pop    %ebx
  800fb2:	5e                   	pop    %esi
  800fb3:	5f                   	pop    %edi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	57                   	push   %edi
  800fba:	56                   	push   %esi
  800fbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc7:	89 c3                	mov    %eax,%ebx
  800fc9:	89 c7                	mov    %eax,%edi
  800fcb:	89 c6                	mov    %eax,%esi
  800fcd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fda:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe4:	89 d1                	mov    %edx,%ecx
  800fe6:	89 d3                	mov    %edx,%ebx
  800fe8:	89 d7                	mov    %edx,%edi
  800fea:	89 d6                	mov    %edx,%esi
  800fec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5f                   	pop    %edi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801001:	b8 03 00 00 00       	mov    $0x3,%eax
  801006:	8b 55 08             	mov    0x8(%ebp),%edx
  801009:	89 cb                	mov    %ecx,%ebx
  80100b:	89 cf                	mov    %ecx,%edi
  80100d:	89 ce                	mov    %ecx,%esi
  80100f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801011:	85 c0                	test   %eax,%eax
  801013:	7e 17                	jle    80102c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	50                   	push   %eax
  801019:	6a 03                	push   $0x3
  80101b:	68 7f 2c 80 00       	push   $0x802c7f
  801020:	6a 23                	push   $0x23
  801022:	68 9c 2c 80 00       	push   $0x802c9c
  801027:	e8 c5 f5 ff ff       	call   8005f1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80102c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103a:	ba 00 00 00 00       	mov    $0x0,%edx
  80103f:	b8 02 00 00 00       	mov    $0x2,%eax
  801044:	89 d1                	mov    %edx,%ecx
  801046:	89 d3                	mov    %edx,%ebx
  801048:	89 d7                	mov    %edx,%edi
  80104a:	89 d6                	mov    %edx,%esi
  80104c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <sys_yield>:

void
sys_yield(void)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801059:	ba 00 00 00 00       	mov    $0x0,%edx
  80105e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801063:	89 d1                	mov    %edx,%ecx
  801065:	89 d3                	mov    %edx,%ebx
  801067:	89 d7                	mov    %edx,%edi
  801069:	89 d6                	mov    %edx,%esi
  80106b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80106d:	5b                   	pop    %ebx
  80106e:	5e                   	pop    %esi
  80106f:	5f                   	pop    %edi
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	57                   	push   %edi
  801076:	56                   	push   %esi
  801077:	53                   	push   %ebx
  801078:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107b:	be 00 00 00 00       	mov    $0x0,%esi
  801080:	b8 04 00 00 00       	mov    $0x4,%eax
  801085:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801088:	8b 55 08             	mov    0x8(%ebp),%edx
  80108b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80108e:	89 f7                	mov    %esi,%edi
  801090:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801092:	85 c0                	test   %eax,%eax
  801094:	7e 17                	jle    8010ad <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	50                   	push   %eax
  80109a:	6a 04                	push   $0x4
  80109c:	68 7f 2c 80 00       	push   $0x802c7f
  8010a1:	6a 23                	push   $0x23
  8010a3:	68 9c 2c 80 00       	push   $0x802c9c
  8010a8:	e8 44 f5 ff ff       	call   8005f1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	57                   	push   %edi
  8010b9:	56                   	push   %esi
  8010ba:	53                   	push   %ebx
  8010bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010be:	b8 05 00 00 00       	mov    $0x5,%eax
  8010c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8010d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	7e 17                	jle    8010ef <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d8:	83 ec 0c             	sub    $0xc,%esp
  8010db:	50                   	push   %eax
  8010dc:	6a 05                	push   $0x5
  8010de:	68 7f 2c 80 00       	push   $0x802c7f
  8010e3:	6a 23                	push   $0x23
  8010e5:	68 9c 2c 80 00       	push   $0x802c9c
  8010ea:	e8 02 f5 ff ff       	call   8005f1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	57                   	push   %edi
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801100:	bb 00 00 00 00       	mov    $0x0,%ebx
  801105:	b8 06 00 00 00       	mov    $0x6,%eax
  80110a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110d:	8b 55 08             	mov    0x8(%ebp),%edx
  801110:	89 df                	mov    %ebx,%edi
  801112:	89 de                	mov    %ebx,%esi
  801114:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801116:	85 c0                	test   %eax,%eax
  801118:	7e 17                	jle    801131 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111a:	83 ec 0c             	sub    $0xc,%esp
  80111d:	50                   	push   %eax
  80111e:	6a 06                	push   $0x6
  801120:	68 7f 2c 80 00       	push   $0x802c7f
  801125:	6a 23                	push   $0x23
  801127:	68 9c 2c 80 00       	push   $0x802c9c
  80112c:	e8 c0 f4 ff ff       	call   8005f1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801131:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801134:	5b                   	pop    %ebx
  801135:	5e                   	pop    %esi
  801136:	5f                   	pop    %edi
  801137:	5d                   	pop    %ebp
  801138:	c3                   	ret    

00801139 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	57                   	push   %edi
  80113d:	56                   	push   %esi
  80113e:	53                   	push   %ebx
  80113f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801142:	bb 00 00 00 00       	mov    $0x0,%ebx
  801147:	b8 08 00 00 00       	mov    $0x8,%eax
  80114c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114f:	8b 55 08             	mov    0x8(%ebp),%edx
  801152:	89 df                	mov    %ebx,%edi
  801154:	89 de                	mov    %ebx,%esi
  801156:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801158:	85 c0                	test   %eax,%eax
  80115a:	7e 17                	jle    801173 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	50                   	push   %eax
  801160:	6a 08                	push   $0x8
  801162:	68 7f 2c 80 00       	push   $0x802c7f
  801167:	6a 23                	push   $0x23
  801169:	68 9c 2c 80 00       	push   $0x802c9c
  80116e:	e8 7e f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	57                   	push   %edi
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801184:	bb 00 00 00 00       	mov    $0x0,%ebx
  801189:	b8 09 00 00 00       	mov    $0x9,%eax
  80118e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801191:	8b 55 08             	mov    0x8(%ebp),%edx
  801194:	89 df                	mov    %ebx,%edi
  801196:	89 de                	mov    %ebx,%esi
  801198:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80119a:	85 c0                	test   %eax,%eax
  80119c:	7e 17                	jle    8011b5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119e:	83 ec 0c             	sub    $0xc,%esp
  8011a1:	50                   	push   %eax
  8011a2:	6a 09                	push   $0x9
  8011a4:	68 7f 2c 80 00       	push   $0x802c7f
  8011a9:	6a 23                	push   $0x23
  8011ab:	68 9c 2c 80 00       	push   $0x802c9c
  8011b0:	e8 3c f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b8:	5b                   	pop    %ebx
  8011b9:	5e                   	pop    %esi
  8011ba:	5f                   	pop    %edi
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	57                   	push   %edi
  8011c1:	56                   	push   %esi
  8011c2:	53                   	push   %ebx
  8011c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d6:	89 df                	mov    %ebx,%edi
  8011d8:	89 de                	mov    %ebx,%esi
  8011da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	7e 17                	jle    8011f7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e0:	83 ec 0c             	sub    $0xc,%esp
  8011e3:	50                   	push   %eax
  8011e4:	6a 0a                	push   $0xa
  8011e6:	68 7f 2c 80 00       	push   $0x802c7f
  8011eb:	6a 23                	push   $0x23
  8011ed:	68 9c 2c 80 00       	push   $0x802c9c
  8011f2:	e8 fa f3 ff ff       	call   8005f1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fa:	5b                   	pop    %ebx
  8011fb:	5e                   	pop    %esi
  8011fc:	5f                   	pop    %edi
  8011fd:	5d                   	pop    %ebp
  8011fe:	c3                   	ret    

008011ff <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	57                   	push   %edi
  801203:	56                   	push   %esi
  801204:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801205:	be 00 00 00 00       	mov    $0x0,%esi
  80120a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80120f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801212:	8b 55 08             	mov    0x8(%ebp),%edx
  801215:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801218:	8b 7d 14             	mov    0x14(%ebp),%edi
  80121b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5f                   	pop    %edi
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	57                   	push   %edi
  801226:	56                   	push   %esi
  801227:	53                   	push   %ebx
  801228:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801230:	b8 0d 00 00 00       	mov    $0xd,%eax
  801235:	8b 55 08             	mov    0x8(%ebp),%edx
  801238:	89 cb                	mov    %ecx,%ebx
  80123a:	89 cf                	mov    %ecx,%edi
  80123c:	89 ce                	mov    %ecx,%esi
  80123e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801240:	85 c0                	test   %eax,%eax
  801242:	7e 17                	jle    80125b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801244:	83 ec 0c             	sub    $0xc,%esp
  801247:	50                   	push   %eax
  801248:	6a 0d                	push   $0xd
  80124a:	68 7f 2c 80 00       	push   $0x802c7f
  80124f:	6a 23                	push   $0x23
  801251:	68 9c 2c 80 00       	push   $0x802c9c
  801256:	e8 96 f3 ff ff       	call   8005f1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80125b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125e:	5b                   	pop    %ebx
  80125f:	5e                   	pop    %esi
  801260:	5f                   	pop    %edi
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	57                   	push   %edi
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801269:	ba 00 00 00 00       	mov    $0x0,%edx
  80126e:	b8 0e 00 00 00       	mov    $0xe,%eax
  801273:	89 d1                	mov    %edx,%ecx
  801275:	89 d3                	mov    %edx,%ebx
  801277:	89 d7                	mov    %edx,%edi
  801279:	89 d6                	mov    %edx,%esi
  80127b:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80127d:	5b                   	pop    %ebx
  80127e:	5e                   	pop    %esi
  80127f:	5f                   	pop    %edi
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  801288:	83 3d b8 40 80 00 00 	cmpl   $0x0,0x8040b8
  80128f:	75 56                	jne    8012e7 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  801291:	83 ec 04             	sub    $0x4,%esp
  801294:	6a 07                	push   $0x7
  801296:	68 00 f0 bf ee       	push   $0xeebff000
  80129b:	6a 00                	push   $0x0
  80129d:	e8 d0 fd ff ff       	call   801072 <sys_page_alloc>
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	74 14                	je     8012bd <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  8012a9:	83 ec 04             	sub    $0x4,%esp
  8012ac:	68 aa 2c 80 00       	push   $0x802caa
  8012b1:	6a 21                	push   $0x21
  8012b3:	68 bf 2c 80 00       	push   $0x802cbf
  8012b8:	e8 34 f3 ff ff       	call   8005f1 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  8012bd:	83 ec 08             	sub    $0x8,%esp
  8012c0:	68 f1 12 80 00       	push   $0x8012f1
  8012c5:	6a 00                	push   $0x0
  8012c7:	e8 f1 fe ff ff       	call   8011bd <sys_env_set_pgfault_upcall>
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	74 14                	je     8012e7 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  8012d3:	83 ec 04             	sub    $0x4,%esp
  8012d6:	68 cd 2c 80 00       	push   $0x802ccd
  8012db:	6a 23                	push   $0x23
  8012dd:	68 bf 2c 80 00       	push   $0x802cbf
  8012e2:	e8 0a f3 ff ff       	call   8005f1 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ea:	a3 b8 40 80 00       	mov    %eax,0x8040b8
}
  8012ef:	c9                   	leave  
  8012f0:	c3                   	ret    

008012f1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012f1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012f2:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	call *%eax
  8012f7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012f9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  8012fc:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  8012fe:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  801302:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801306:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  801307:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  801309:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  80130e:	83 c4 08             	add    $0x8,%esp
	popal
  801311:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801312:	83 c4 04             	add    $0x4,%esp
	popfl
  801315:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801316:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801317:	c3                   	ret    

00801318 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80131b:	8b 45 08             	mov    0x8(%ebp),%eax
  80131e:	05 00 00 00 30       	add    $0x30000000,%eax
  801323:	c1 e8 0c             	shr    $0xc,%eax
}
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    

00801328 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80132b:	8b 45 08             	mov    0x8(%ebp),%eax
  80132e:	05 00 00 00 30       	add    $0x30000000,%eax
  801333:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801338:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80133d:	5d                   	pop    %ebp
  80133e:	c3                   	ret    

0080133f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801345:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80134a:	89 c2                	mov    %eax,%edx
  80134c:	c1 ea 16             	shr    $0x16,%edx
  80134f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801356:	f6 c2 01             	test   $0x1,%dl
  801359:	74 11                	je     80136c <fd_alloc+0x2d>
  80135b:	89 c2                	mov    %eax,%edx
  80135d:	c1 ea 0c             	shr    $0xc,%edx
  801360:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801367:	f6 c2 01             	test   $0x1,%dl
  80136a:	75 09                	jne    801375 <fd_alloc+0x36>
			*fd_store = fd;
  80136c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
  801373:	eb 17                	jmp    80138c <fd_alloc+0x4d>
  801375:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80137a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80137f:	75 c9                	jne    80134a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801381:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801387:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801394:	83 f8 1f             	cmp    $0x1f,%eax
  801397:	77 36                	ja     8013cf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801399:	c1 e0 0c             	shl    $0xc,%eax
  80139c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a1:	89 c2                	mov    %eax,%edx
  8013a3:	c1 ea 16             	shr    $0x16,%edx
  8013a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ad:	f6 c2 01             	test   $0x1,%dl
  8013b0:	74 24                	je     8013d6 <fd_lookup+0x48>
  8013b2:	89 c2                	mov    %eax,%edx
  8013b4:	c1 ea 0c             	shr    $0xc,%edx
  8013b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013be:	f6 c2 01             	test   $0x1,%dl
  8013c1:	74 1a                	je     8013dd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c6:	89 02                	mov    %eax,(%edx)
	return 0;
  8013c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013cd:	eb 13                	jmp    8013e2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d4:	eb 0c                	jmp    8013e2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013db:	eb 05                	jmp    8013e2 <fd_lookup+0x54>
  8013dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    

008013e4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ed:	ba 64 2d 80 00       	mov    $0x802d64,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013f2:	eb 13                	jmp    801407 <dev_lookup+0x23>
  8013f4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013f7:	39 08                	cmp    %ecx,(%eax)
  8013f9:	75 0c                	jne    801407 <dev_lookup+0x23>
			*dev = devtab[i];
  8013fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013fe:	89 01                	mov    %eax,(%ecx)
			return 0;
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
  801405:	eb 2e                	jmp    801435 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801407:	8b 02                	mov    (%edx),%eax
  801409:	85 c0                	test   %eax,%eax
  80140b:	75 e7                	jne    8013f4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80140d:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801412:	8b 40 48             	mov    0x48(%eax),%eax
  801415:	83 ec 04             	sub    $0x4,%esp
  801418:	51                   	push   %ecx
  801419:	50                   	push   %eax
  80141a:	68 e4 2c 80 00       	push   $0x802ce4
  80141f:	e8 a6 f2 ff ff       	call   8006ca <cprintf>
	*dev = 0;
  801424:	8b 45 0c             	mov    0xc(%ebp),%eax
  801427:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80142d:	83 c4 10             	add    $0x10,%esp
  801430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	56                   	push   %esi
  80143b:	53                   	push   %ebx
  80143c:	83 ec 10             	sub    $0x10,%esp
  80143f:	8b 75 08             	mov    0x8(%ebp),%esi
  801442:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801445:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80144f:	c1 e8 0c             	shr    $0xc,%eax
  801452:	50                   	push   %eax
  801453:	e8 36 ff ff ff       	call   80138e <fd_lookup>
  801458:	83 c4 08             	add    $0x8,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 05                	js     801464 <fd_close+0x2d>
	    || fd != fd2)
  80145f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801462:	74 0c                	je     801470 <fd_close+0x39>
		return (must_exist ? r : 0);
  801464:	84 db                	test   %bl,%bl
  801466:	ba 00 00 00 00       	mov    $0x0,%edx
  80146b:	0f 44 c2             	cmove  %edx,%eax
  80146e:	eb 41                	jmp    8014b1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	ff 36                	pushl  (%esi)
  801479:	e8 66 ff ff ff       	call   8013e4 <dev_lookup>
  80147e:	89 c3                	mov    %eax,%ebx
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 1a                	js     8014a1 <fd_close+0x6a>
		if (dev->dev_close)
  801487:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80148d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801492:	85 c0                	test   %eax,%eax
  801494:	74 0b                	je     8014a1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	56                   	push   %esi
  80149a:	ff d0                	call   *%eax
  80149c:	89 c3                	mov    %eax,%ebx
  80149e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	56                   	push   %esi
  8014a5:	6a 00                	push   $0x0
  8014a7:	e8 4b fc ff ff       	call   8010f7 <sys_page_unmap>
	return r;
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	89 d8                	mov    %ebx,%eax
}
  8014b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    

008014b8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	ff 75 08             	pushl  0x8(%ebp)
  8014c5:	e8 c4 fe ff ff       	call   80138e <fd_lookup>
  8014ca:	83 c4 08             	add    $0x8,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 10                	js     8014e1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	6a 01                	push   $0x1
  8014d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d9:	e8 59 ff ff ff       	call   801437 <fd_close>
  8014de:	83 c4 10             	add    $0x10,%esp
}
  8014e1:	c9                   	leave  
  8014e2:	c3                   	ret    

008014e3 <close_all>:

void
close_all(void)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	53                   	push   %ebx
  8014f3:	e8 c0 ff ff ff       	call   8014b8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f8:	83 c3 01             	add    $0x1,%ebx
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	83 fb 20             	cmp    $0x20,%ebx
  801501:	75 ec                	jne    8014ef <close_all+0xc>
		close(i);
}
  801503:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	57                   	push   %edi
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	83 ec 2c             	sub    $0x2c,%esp
  801511:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801514:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801517:	50                   	push   %eax
  801518:	ff 75 08             	pushl  0x8(%ebp)
  80151b:	e8 6e fe ff ff       	call   80138e <fd_lookup>
  801520:	83 c4 08             	add    $0x8,%esp
  801523:	85 c0                	test   %eax,%eax
  801525:	0f 88 c1 00 00 00    	js     8015ec <dup+0xe4>
		return r;
	close(newfdnum);
  80152b:	83 ec 0c             	sub    $0xc,%esp
  80152e:	56                   	push   %esi
  80152f:	e8 84 ff ff ff       	call   8014b8 <close>

	newfd = INDEX2FD(newfdnum);
  801534:	89 f3                	mov    %esi,%ebx
  801536:	c1 e3 0c             	shl    $0xc,%ebx
  801539:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80153f:	83 c4 04             	add    $0x4,%esp
  801542:	ff 75 e4             	pushl  -0x1c(%ebp)
  801545:	e8 de fd ff ff       	call   801328 <fd2data>
  80154a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80154c:	89 1c 24             	mov    %ebx,(%esp)
  80154f:	e8 d4 fd ff ff       	call   801328 <fd2data>
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80155a:	89 f8                	mov    %edi,%eax
  80155c:	c1 e8 16             	shr    $0x16,%eax
  80155f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801566:	a8 01                	test   $0x1,%al
  801568:	74 37                	je     8015a1 <dup+0x99>
  80156a:	89 f8                	mov    %edi,%eax
  80156c:	c1 e8 0c             	shr    $0xc,%eax
  80156f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801576:	f6 c2 01             	test   $0x1,%dl
  801579:	74 26                	je     8015a1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80157b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	25 07 0e 00 00       	and    $0xe07,%eax
  80158a:	50                   	push   %eax
  80158b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80158e:	6a 00                	push   $0x0
  801590:	57                   	push   %edi
  801591:	6a 00                	push   $0x0
  801593:	e8 1d fb ff ff       	call   8010b5 <sys_page_map>
  801598:	89 c7                	mov    %eax,%edi
  80159a:	83 c4 20             	add    $0x20,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 2e                	js     8015cf <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015a4:	89 d0                	mov    %edx,%eax
  8015a6:	c1 e8 0c             	shr    $0xc,%eax
  8015a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b0:	83 ec 0c             	sub    $0xc,%esp
  8015b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b8:	50                   	push   %eax
  8015b9:	53                   	push   %ebx
  8015ba:	6a 00                	push   $0x0
  8015bc:	52                   	push   %edx
  8015bd:	6a 00                	push   $0x0
  8015bf:	e8 f1 fa ff ff       	call   8010b5 <sys_page_map>
  8015c4:	89 c7                	mov    %eax,%edi
  8015c6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015c9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015cb:	85 ff                	test   %edi,%edi
  8015cd:	79 1d                	jns    8015ec <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	53                   	push   %ebx
  8015d3:	6a 00                	push   $0x0
  8015d5:	e8 1d fb ff ff       	call   8010f7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015da:	83 c4 08             	add    $0x8,%esp
  8015dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015e0:	6a 00                	push   $0x0
  8015e2:	e8 10 fb ff ff       	call   8010f7 <sys_page_unmap>
	return r;
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	89 f8                	mov    %edi,%eax
}
  8015ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ef:	5b                   	pop    %ebx
  8015f0:	5e                   	pop    %esi
  8015f1:	5f                   	pop    %edi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	53                   	push   %ebx
  8015f8:	83 ec 14             	sub    $0x14,%esp
  8015fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	53                   	push   %ebx
  801603:	e8 86 fd ff ff       	call   80138e <fd_lookup>
  801608:	83 c4 08             	add    $0x8,%esp
  80160b:	89 c2                	mov    %eax,%edx
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 6d                	js     80167e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161b:	ff 30                	pushl  (%eax)
  80161d:	e8 c2 fd ff ff       	call   8013e4 <dev_lookup>
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	85 c0                	test   %eax,%eax
  801627:	78 4c                	js     801675 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801629:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80162c:	8b 42 08             	mov    0x8(%edx),%eax
  80162f:	83 e0 03             	and    $0x3,%eax
  801632:	83 f8 01             	cmp    $0x1,%eax
  801635:	75 21                	jne    801658 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801637:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80163c:	8b 40 48             	mov    0x48(%eax),%eax
  80163f:	83 ec 04             	sub    $0x4,%esp
  801642:	53                   	push   %ebx
  801643:	50                   	push   %eax
  801644:	68 28 2d 80 00       	push   $0x802d28
  801649:	e8 7c f0 ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801656:	eb 26                	jmp    80167e <read+0x8a>
	}
	if (!dev->dev_read)
  801658:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165b:	8b 40 08             	mov    0x8(%eax),%eax
  80165e:	85 c0                	test   %eax,%eax
  801660:	74 17                	je     801679 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801662:	83 ec 04             	sub    $0x4,%esp
  801665:	ff 75 10             	pushl  0x10(%ebp)
  801668:	ff 75 0c             	pushl  0xc(%ebp)
  80166b:	52                   	push   %edx
  80166c:	ff d0                	call   *%eax
  80166e:	89 c2                	mov    %eax,%edx
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	eb 09                	jmp    80167e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801675:	89 c2                	mov    %eax,%edx
  801677:	eb 05                	jmp    80167e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801679:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80167e:	89 d0                	mov    %edx,%eax
  801680:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	57                   	push   %edi
  801689:	56                   	push   %esi
  80168a:	53                   	push   %ebx
  80168b:	83 ec 0c             	sub    $0xc,%esp
  80168e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801691:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801694:	bb 00 00 00 00       	mov    $0x0,%ebx
  801699:	eb 21                	jmp    8016bc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80169b:	83 ec 04             	sub    $0x4,%esp
  80169e:	89 f0                	mov    %esi,%eax
  8016a0:	29 d8                	sub    %ebx,%eax
  8016a2:	50                   	push   %eax
  8016a3:	89 d8                	mov    %ebx,%eax
  8016a5:	03 45 0c             	add    0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	57                   	push   %edi
  8016aa:	e8 45 ff ff ff       	call   8015f4 <read>
		if (m < 0)
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	78 10                	js     8016c6 <readn+0x41>
			return m;
		if (m == 0)
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	74 0a                	je     8016c4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ba:	01 c3                	add    %eax,%ebx
  8016bc:	39 f3                	cmp    %esi,%ebx
  8016be:	72 db                	jb     80169b <readn+0x16>
  8016c0:	89 d8                	mov    %ebx,%eax
  8016c2:	eb 02                	jmp    8016c6 <readn+0x41>
  8016c4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5f                   	pop    %edi
  8016cc:	5d                   	pop    %ebp
  8016cd:	c3                   	ret    

008016ce <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	53                   	push   %ebx
  8016d2:	83 ec 14             	sub    $0x14,%esp
  8016d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016db:	50                   	push   %eax
  8016dc:	53                   	push   %ebx
  8016dd:	e8 ac fc ff ff       	call   80138e <fd_lookup>
  8016e2:	83 c4 08             	add    $0x8,%esp
  8016e5:	89 c2                	mov    %eax,%edx
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 68                	js     801753 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f1:	50                   	push   %eax
  8016f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f5:	ff 30                	pushl  (%eax)
  8016f7:	e8 e8 fc ff ff       	call   8013e4 <dev_lookup>
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 47                	js     80174a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801703:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801706:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80170a:	75 21                	jne    80172d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80170c:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801711:	8b 40 48             	mov    0x48(%eax),%eax
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	53                   	push   %ebx
  801718:	50                   	push   %eax
  801719:	68 44 2d 80 00       	push   $0x802d44
  80171e:	e8 a7 ef ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80172b:	eb 26                	jmp    801753 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80172d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801730:	8b 52 0c             	mov    0xc(%edx),%edx
  801733:	85 d2                	test   %edx,%edx
  801735:	74 17                	je     80174e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801737:	83 ec 04             	sub    $0x4,%esp
  80173a:	ff 75 10             	pushl  0x10(%ebp)
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	50                   	push   %eax
  801741:	ff d2                	call   *%edx
  801743:	89 c2                	mov    %eax,%edx
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	eb 09                	jmp    801753 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174a:	89 c2                	mov    %eax,%edx
  80174c:	eb 05                	jmp    801753 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80174e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801753:	89 d0                	mov    %edx,%eax
  801755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <seek>:

int
seek(int fdnum, off_t offset)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801760:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	ff 75 08             	pushl  0x8(%ebp)
  801767:	e8 22 fc ff ff       	call   80138e <fd_lookup>
  80176c:	83 c4 08             	add    $0x8,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 0e                	js     801781 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801773:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801776:	8b 55 0c             	mov    0xc(%ebp),%edx
  801779:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80177c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801781:	c9                   	leave  
  801782:	c3                   	ret    

00801783 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	53                   	push   %ebx
  801787:	83 ec 14             	sub    $0x14,%esp
  80178a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801790:	50                   	push   %eax
  801791:	53                   	push   %ebx
  801792:	e8 f7 fb ff ff       	call   80138e <fd_lookup>
  801797:	83 c4 08             	add    $0x8,%esp
  80179a:	89 c2                	mov    %eax,%edx
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 65                	js     801805 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a6:	50                   	push   %eax
  8017a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017aa:	ff 30                	pushl  (%eax)
  8017ac:	e8 33 fc ff ff       	call   8013e4 <dev_lookup>
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 44                	js     8017fc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017bf:	75 21                	jne    8017e2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017c1:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c6:	8b 40 48             	mov    0x48(%eax),%eax
  8017c9:	83 ec 04             	sub    $0x4,%esp
  8017cc:	53                   	push   %ebx
  8017cd:	50                   	push   %eax
  8017ce:	68 04 2d 80 00       	push   $0x802d04
  8017d3:	e8 f2 ee ff ff       	call   8006ca <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e0:	eb 23                	jmp    801805 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e5:	8b 52 18             	mov    0x18(%edx),%edx
  8017e8:	85 d2                	test   %edx,%edx
  8017ea:	74 14                	je     801800 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	ff 75 0c             	pushl  0xc(%ebp)
  8017f2:	50                   	push   %eax
  8017f3:	ff d2                	call   *%edx
  8017f5:	89 c2                	mov    %eax,%edx
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	eb 09                	jmp    801805 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fc:	89 c2                	mov    %eax,%edx
  8017fe:	eb 05                	jmp    801805 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801800:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801805:	89 d0                	mov    %edx,%eax
  801807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180a:	c9                   	leave  
  80180b:	c3                   	ret    

0080180c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	53                   	push   %ebx
  801810:	83 ec 14             	sub    $0x14,%esp
  801813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801816:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801819:	50                   	push   %eax
  80181a:	ff 75 08             	pushl  0x8(%ebp)
  80181d:	e8 6c fb ff ff       	call   80138e <fd_lookup>
  801822:	83 c4 08             	add    $0x8,%esp
  801825:	89 c2                	mov    %eax,%edx
  801827:	85 c0                	test   %eax,%eax
  801829:	78 58                	js     801883 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801835:	ff 30                	pushl  (%eax)
  801837:	e8 a8 fb ff ff       	call   8013e4 <dev_lookup>
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 37                	js     80187a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801843:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801846:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80184a:	74 32                	je     80187e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80184c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80184f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801856:	00 00 00 
	stat->st_isdir = 0;
  801859:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801860:	00 00 00 
	stat->st_dev = dev;
  801863:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801869:	83 ec 08             	sub    $0x8,%esp
  80186c:	53                   	push   %ebx
  80186d:	ff 75 f0             	pushl  -0x10(%ebp)
  801870:	ff 50 14             	call   *0x14(%eax)
  801873:	89 c2                	mov    %eax,%edx
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	eb 09                	jmp    801883 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187a:	89 c2                	mov    %eax,%edx
  80187c:	eb 05                	jmp    801883 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80187e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801883:	89 d0                	mov    %edx,%eax
  801885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	56                   	push   %esi
  80188e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	6a 00                	push   $0x0
  801894:	ff 75 08             	pushl  0x8(%ebp)
  801897:	e8 ef 01 00 00       	call   801a8b <open>
  80189c:	89 c3                	mov    %eax,%ebx
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 1b                	js     8018c0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	ff 75 0c             	pushl  0xc(%ebp)
  8018ab:	50                   	push   %eax
  8018ac:	e8 5b ff ff ff       	call   80180c <fstat>
  8018b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b3:	89 1c 24             	mov    %ebx,(%esp)
  8018b6:	e8 fd fb ff ff       	call   8014b8 <close>
	return r;
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	89 f0                	mov    %esi,%eax
}
  8018c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	56                   	push   %esi
  8018cb:	53                   	push   %ebx
  8018cc:	89 c6                	mov    %eax,%esi
  8018ce:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d0:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8018d7:	75 12                	jne    8018eb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018d9:	83 ec 0c             	sub    $0xc,%esp
  8018dc:	6a 01                	push   $0x1
  8018de:	e8 57 0c 00 00       	call   80253a <ipc_find_env>
  8018e3:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018e8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018eb:	6a 07                	push   $0x7
  8018ed:	68 00 50 80 00       	push   $0x805000
  8018f2:	56                   	push   %esi
  8018f3:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018f9:	e8 ed 0b 00 00       	call   8024eb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018fe:	83 c4 0c             	add    $0xc,%esp
  801901:	6a 00                	push   $0x0
  801903:	53                   	push   %ebx
  801904:	6a 00                	push   $0x0
  801906:	e8 6a 0b 00 00       	call   802475 <ipc_recv>
}
  80190b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190e:	5b                   	pop    %ebx
  80190f:	5e                   	pop    %esi
  801910:	5d                   	pop    %ebp
  801911:	c3                   	ret    

00801912 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801918:	8b 45 08             	mov    0x8(%ebp),%eax
  80191b:	8b 40 0c             	mov    0xc(%eax),%eax
  80191e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801923:	8b 45 0c             	mov    0xc(%ebp),%eax
  801926:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80192b:	ba 00 00 00 00       	mov    $0x0,%edx
  801930:	b8 02 00 00 00       	mov    $0x2,%eax
  801935:	e8 8d ff ff ff       	call   8018c7 <fsipc>
}
  80193a:	c9                   	leave  
  80193b:	c3                   	ret    

0080193c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	8b 40 0c             	mov    0xc(%eax),%eax
  801948:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80194d:	ba 00 00 00 00       	mov    $0x0,%edx
  801952:	b8 06 00 00 00       	mov    $0x6,%eax
  801957:	e8 6b ff ff ff       	call   8018c7 <fsipc>
}
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	53                   	push   %ebx
  801962:	83 ec 04             	sub    $0x4,%esp
  801965:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	8b 40 0c             	mov    0xc(%eax),%eax
  80196e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801973:	ba 00 00 00 00       	mov    $0x0,%edx
  801978:	b8 05 00 00 00       	mov    $0x5,%eax
  80197d:	e8 45 ff ff ff       	call   8018c7 <fsipc>
  801982:	85 c0                	test   %eax,%eax
  801984:	78 2c                	js     8019b2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	68 00 50 80 00       	push   $0x805000
  80198e:	53                   	push   %ebx
  80198f:	e8 db f2 ff ff       	call   800c6f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801994:	a1 80 50 80 00       	mov    0x805080,%eax
  801999:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80199f:	a1 84 50 80 00       	mov    0x805084,%eax
  8019a4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	53                   	push   %ebx
  8019bb:	83 ec 08             	sub    $0x8,%esp
  8019be:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8019c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8019c7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019cd:	a3 04 50 80 00       	mov    %eax,0x805004
  8019d2:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8019d7:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8019dc:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019df:	53                   	push   %ebx
  8019e0:	ff 75 0c             	pushl  0xc(%ebp)
  8019e3:	68 08 50 80 00       	push   $0x805008
  8019e8:	e8 14 f4 ff ff       	call   800e01 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f2:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f7:	e8 cb fe ff ff       	call   8018c7 <fsipc>
  8019fc:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    

00801a09 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	8b 40 0c             	mov    0xc(%eax),%eax
  801a17:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a1c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a22:	ba 00 00 00 00       	mov    $0x0,%edx
  801a27:	b8 03 00 00 00       	mov    $0x3,%eax
  801a2c:	e8 96 fe ff ff       	call   8018c7 <fsipc>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 4b                	js     801a82 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a37:	39 c6                	cmp    %eax,%esi
  801a39:	73 16                	jae    801a51 <devfile_read+0x48>
  801a3b:	68 78 2d 80 00       	push   $0x802d78
  801a40:	68 7f 2d 80 00       	push   $0x802d7f
  801a45:	6a 7c                	push   $0x7c
  801a47:	68 94 2d 80 00       	push   $0x802d94
  801a4c:	e8 a0 eb ff ff       	call   8005f1 <_panic>
	assert(r <= PGSIZE);
  801a51:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a56:	7e 16                	jle    801a6e <devfile_read+0x65>
  801a58:	68 9f 2d 80 00       	push   $0x802d9f
  801a5d:	68 7f 2d 80 00       	push   $0x802d7f
  801a62:	6a 7d                	push   $0x7d
  801a64:	68 94 2d 80 00       	push   $0x802d94
  801a69:	e8 83 eb ff ff       	call   8005f1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a6e:	83 ec 04             	sub    $0x4,%esp
  801a71:	50                   	push   %eax
  801a72:	68 00 50 80 00       	push   $0x805000
  801a77:	ff 75 0c             	pushl  0xc(%ebp)
  801a7a:	e8 82 f3 ff ff       	call   800e01 <memmove>
	return r;
  801a7f:	83 c4 10             	add    $0x10,%esp
}
  801a82:	89 d8                	mov    %ebx,%eax
  801a84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a87:	5b                   	pop    %ebx
  801a88:	5e                   	pop    %esi
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	53                   	push   %ebx
  801a8f:	83 ec 20             	sub    $0x20,%esp
  801a92:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a95:	53                   	push   %ebx
  801a96:	e8 9b f1 ff ff       	call   800c36 <strlen>
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aa3:	7f 67                	jg     801b0c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aab:	50                   	push   %eax
  801aac:	e8 8e f8 ff ff       	call   80133f <fd_alloc>
  801ab1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ab4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 57                	js     801b11 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aba:	83 ec 08             	sub    $0x8,%esp
  801abd:	53                   	push   %ebx
  801abe:	68 00 50 80 00       	push   $0x805000
  801ac3:	e8 a7 f1 ff ff       	call   800c6f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ac8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ad0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad8:	e8 ea fd ff ff       	call   8018c7 <fsipc>
  801add:	89 c3                	mov    %eax,%ebx
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	79 14                	jns    801afa <open+0x6f>
		fd_close(fd, 0);
  801ae6:	83 ec 08             	sub    $0x8,%esp
  801ae9:	6a 00                	push   $0x0
  801aeb:	ff 75 f4             	pushl  -0xc(%ebp)
  801aee:	e8 44 f9 ff ff       	call   801437 <fd_close>
		return r;
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	89 da                	mov    %ebx,%edx
  801af8:	eb 17                	jmp    801b11 <open+0x86>
	}

	return fd2num(fd);
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	ff 75 f4             	pushl  -0xc(%ebp)
  801b00:	e8 13 f8 ff ff       	call   801318 <fd2num>
  801b05:	89 c2                	mov    %eax,%edx
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	eb 05                	jmp    801b11 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b0c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b11:	89 d0                	mov    %edx,%eax
  801b13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b16:	c9                   	leave  
  801b17:	c3                   	ret    

00801b18 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b23:	b8 08 00 00 00       	mov    $0x8,%eax
  801b28:	e8 9a fd ff ff       	call   8018c7 <fsipc>
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	ff 75 08             	pushl  0x8(%ebp)
  801b3d:	e8 e6 f7 ff ff       	call   801328 <fd2data>
  801b42:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b44:	83 c4 08             	add    $0x8,%esp
  801b47:	68 ab 2d 80 00       	push   $0x802dab
  801b4c:	53                   	push   %ebx
  801b4d:	e8 1d f1 ff ff       	call   800c6f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b52:	8b 46 04             	mov    0x4(%esi),%eax
  801b55:	2b 06                	sub    (%esi),%eax
  801b57:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b5d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b64:	00 00 00 
	stat->st_dev = &devpipe;
  801b67:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b6e:	30 80 00 
	return 0;
}
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
  801b76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b79:	5b                   	pop    %ebx
  801b7a:	5e                   	pop    %esi
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	53                   	push   %ebx
  801b81:	83 ec 0c             	sub    $0xc,%esp
  801b84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b87:	53                   	push   %ebx
  801b88:	6a 00                	push   $0x0
  801b8a:	e8 68 f5 ff ff       	call   8010f7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b8f:	89 1c 24             	mov    %ebx,(%esp)
  801b92:	e8 91 f7 ff ff       	call   801328 <fd2data>
  801b97:	83 c4 08             	add    $0x8,%esp
  801b9a:	50                   	push   %eax
  801b9b:	6a 00                	push   $0x0
  801b9d:	e8 55 f5 ff ff       	call   8010f7 <sys_page_unmap>
}
  801ba2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba5:	c9                   	leave  
  801ba6:	c3                   	ret    

00801ba7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	57                   	push   %edi
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
  801bad:	83 ec 1c             	sub    $0x1c,%esp
  801bb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bb3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bb5:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801bba:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	ff 75 e0             	pushl  -0x20(%ebp)
  801bc3:	e8 ab 09 00 00       	call   802573 <pageref>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	89 3c 24             	mov    %edi,(%esp)
  801bcd:	e8 a1 09 00 00       	call   802573 <pageref>
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	39 c3                	cmp    %eax,%ebx
  801bd7:	0f 94 c1             	sete   %cl
  801bda:	0f b6 c9             	movzbl %cl,%ecx
  801bdd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801be0:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  801be6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801be9:	39 ce                	cmp    %ecx,%esi
  801beb:	74 1b                	je     801c08 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bed:	39 c3                	cmp    %eax,%ebx
  801bef:	75 c4                	jne    801bb5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bf1:	8b 42 58             	mov    0x58(%edx),%eax
  801bf4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bf7:	50                   	push   %eax
  801bf8:	56                   	push   %esi
  801bf9:	68 b2 2d 80 00       	push   $0x802db2
  801bfe:	e8 c7 ea ff ff       	call   8006ca <cprintf>
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	eb ad                	jmp    801bb5 <_pipeisclosed+0xe>
	}
}
  801c08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0e:	5b                   	pop    %ebx
  801c0f:	5e                   	pop    %esi
  801c10:	5f                   	pop    %edi
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    

00801c13 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	57                   	push   %edi
  801c17:	56                   	push   %esi
  801c18:	53                   	push   %ebx
  801c19:	83 ec 28             	sub    $0x28,%esp
  801c1c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c1f:	56                   	push   %esi
  801c20:	e8 03 f7 ff ff       	call   801328 <fd2data>
  801c25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	bf 00 00 00 00       	mov    $0x0,%edi
  801c2f:	eb 4b                	jmp    801c7c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c31:	89 da                	mov    %ebx,%edx
  801c33:	89 f0                	mov    %esi,%eax
  801c35:	e8 6d ff ff ff       	call   801ba7 <_pipeisclosed>
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	75 48                	jne    801c86 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c3e:	e8 10 f4 ff ff       	call   801053 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c43:	8b 43 04             	mov    0x4(%ebx),%eax
  801c46:	8b 0b                	mov    (%ebx),%ecx
  801c48:	8d 51 20             	lea    0x20(%ecx),%edx
  801c4b:	39 d0                	cmp    %edx,%eax
  801c4d:	73 e2                	jae    801c31 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c52:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c56:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c59:	89 c2                	mov    %eax,%edx
  801c5b:	c1 fa 1f             	sar    $0x1f,%edx
  801c5e:	89 d1                	mov    %edx,%ecx
  801c60:	c1 e9 1b             	shr    $0x1b,%ecx
  801c63:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c66:	83 e2 1f             	and    $0x1f,%edx
  801c69:	29 ca                	sub    %ecx,%edx
  801c6b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c73:	83 c0 01             	add    $0x1,%eax
  801c76:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c79:	83 c7 01             	add    $0x1,%edi
  801c7c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c7f:	75 c2                	jne    801c43 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c81:	8b 45 10             	mov    0x10(%ebp),%eax
  801c84:	eb 05                	jmp    801c8b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c86:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5e                   	pop    %esi
  801c90:	5f                   	pop    %edi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	57                   	push   %edi
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	83 ec 18             	sub    $0x18,%esp
  801c9c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c9f:	57                   	push   %edi
  801ca0:	e8 83 f6 ff ff       	call   801328 <fd2data>
  801ca5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801caf:	eb 3d                	jmp    801cee <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cb1:	85 db                	test   %ebx,%ebx
  801cb3:	74 04                	je     801cb9 <devpipe_read+0x26>
				return i;
  801cb5:	89 d8                	mov    %ebx,%eax
  801cb7:	eb 44                	jmp    801cfd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cb9:	89 f2                	mov    %esi,%edx
  801cbb:	89 f8                	mov    %edi,%eax
  801cbd:	e8 e5 fe ff ff       	call   801ba7 <_pipeisclosed>
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	75 32                	jne    801cf8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cc6:	e8 88 f3 ff ff       	call   801053 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ccb:	8b 06                	mov    (%esi),%eax
  801ccd:	3b 46 04             	cmp    0x4(%esi),%eax
  801cd0:	74 df                	je     801cb1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cd2:	99                   	cltd   
  801cd3:	c1 ea 1b             	shr    $0x1b,%edx
  801cd6:	01 d0                	add    %edx,%eax
  801cd8:	83 e0 1f             	and    $0x1f,%eax
  801cdb:	29 d0                	sub    %edx,%eax
  801cdd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ce8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ceb:	83 c3 01             	add    $0x1,%ebx
  801cee:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cf1:	75 d8                	jne    801ccb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cf3:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf6:	eb 05                	jmp    801cfd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5f                   	pop    %edi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    

00801d05 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	56                   	push   %esi
  801d09:	53                   	push   %ebx
  801d0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d10:	50                   	push   %eax
  801d11:	e8 29 f6 ff ff       	call   80133f <fd_alloc>
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	89 c2                	mov    %eax,%edx
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	0f 88 2c 01 00 00    	js     801e4f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d23:	83 ec 04             	sub    $0x4,%esp
  801d26:	68 07 04 00 00       	push   $0x407
  801d2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2e:	6a 00                	push   $0x0
  801d30:	e8 3d f3 ff ff       	call   801072 <sys_page_alloc>
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	89 c2                	mov    %eax,%edx
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	0f 88 0d 01 00 00    	js     801e4f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d42:	83 ec 0c             	sub    $0xc,%esp
  801d45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d48:	50                   	push   %eax
  801d49:	e8 f1 f5 ff ff       	call   80133f <fd_alloc>
  801d4e:	89 c3                	mov    %eax,%ebx
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	85 c0                	test   %eax,%eax
  801d55:	0f 88 e2 00 00 00    	js     801e3d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5b:	83 ec 04             	sub    $0x4,%esp
  801d5e:	68 07 04 00 00       	push   $0x407
  801d63:	ff 75 f0             	pushl  -0x10(%ebp)
  801d66:	6a 00                	push   $0x0
  801d68:	e8 05 f3 ff ff       	call   801072 <sys_page_alloc>
  801d6d:	89 c3                	mov    %eax,%ebx
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	85 c0                	test   %eax,%eax
  801d74:	0f 88 c3 00 00 00    	js     801e3d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d7a:	83 ec 0c             	sub    $0xc,%esp
  801d7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d80:	e8 a3 f5 ff ff       	call   801328 <fd2data>
  801d85:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d87:	83 c4 0c             	add    $0xc,%esp
  801d8a:	68 07 04 00 00       	push   $0x407
  801d8f:	50                   	push   %eax
  801d90:	6a 00                	push   $0x0
  801d92:	e8 db f2 ff ff       	call   801072 <sys_page_alloc>
  801d97:	89 c3                	mov    %eax,%ebx
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	0f 88 89 00 00 00    	js     801e2d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	ff 75 f0             	pushl  -0x10(%ebp)
  801daa:	e8 79 f5 ff ff       	call   801328 <fd2data>
  801daf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801db6:	50                   	push   %eax
  801db7:	6a 00                	push   $0x0
  801db9:	56                   	push   %esi
  801dba:	6a 00                	push   $0x0
  801dbc:	e8 f4 f2 ff ff       	call   8010b5 <sys_page_map>
  801dc1:	89 c3                	mov    %eax,%ebx
  801dc3:	83 c4 20             	add    $0x20,%esp
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	78 55                	js     801e1f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ddf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ded:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df4:	83 ec 0c             	sub    $0xc,%esp
  801df7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfa:	e8 19 f5 ff ff       	call   801318 <fd2num>
  801dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e02:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e04:	83 c4 04             	add    $0x4,%esp
  801e07:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0a:	e8 09 f5 ff ff       	call   801318 <fd2num>
  801e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e12:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e15:	83 c4 10             	add    $0x10,%esp
  801e18:	ba 00 00 00 00       	mov    $0x0,%edx
  801e1d:	eb 30                	jmp    801e4f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e1f:	83 ec 08             	sub    $0x8,%esp
  801e22:	56                   	push   %esi
  801e23:	6a 00                	push   $0x0
  801e25:	e8 cd f2 ff ff       	call   8010f7 <sys_page_unmap>
  801e2a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e2d:	83 ec 08             	sub    $0x8,%esp
  801e30:	ff 75 f0             	pushl  -0x10(%ebp)
  801e33:	6a 00                	push   $0x0
  801e35:	e8 bd f2 ff ff       	call   8010f7 <sys_page_unmap>
  801e3a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	ff 75 f4             	pushl  -0xc(%ebp)
  801e43:	6a 00                	push   $0x0
  801e45:	e8 ad f2 ff ff       	call   8010f7 <sys_page_unmap>
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e4f:	89 d0                	mov    %edx,%eax
  801e51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e61:	50                   	push   %eax
  801e62:	ff 75 08             	pushl  0x8(%ebp)
  801e65:	e8 24 f5 ff ff       	call   80138e <fd_lookup>
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	78 18                	js     801e89 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e71:	83 ec 0c             	sub    $0xc,%esp
  801e74:	ff 75 f4             	pushl  -0xc(%ebp)
  801e77:	e8 ac f4 ff ff       	call   801328 <fd2data>
	return _pipeisclosed(fd, p);
  801e7c:	89 c2                	mov    %eax,%edx
  801e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e81:	e8 21 fd ff ff       	call   801ba7 <_pipeisclosed>
  801e86:	83 c4 10             	add    $0x10,%esp
}
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    

00801e8b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801e91:	68 ca 2d 80 00       	push   $0x802dca
  801e96:	ff 75 0c             	pushl  0xc(%ebp)
  801e99:	e8 d1 ed ff ff       	call   800c6f <strcpy>
	return 0;
}
  801e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea3:	c9                   	leave  
  801ea4:	c3                   	ret    

00801ea5 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	53                   	push   %ebx
  801ea9:	83 ec 10             	sub    $0x10,%esp
  801eac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801eaf:	53                   	push   %ebx
  801eb0:	e8 be 06 00 00       	call   802573 <pageref>
  801eb5:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801eb8:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ebd:	83 f8 01             	cmp    $0x1,%eax
  801ec0:	75 10                	jne    801ed2 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ec2:	83 ec 0c             	sub    $0xc,%esp
  801ec5:	ff 73 0c             	pushl  0xc(%ebx)
  801ec8:	e8 c0 02 00 00       	call   80218d <nsipc_close>
  801ecd:	89 c2                	mov    %eax,%edx
  801ecf:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ed2:	89 d0                	mov    %edx,%eax
  801ed4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801edf:	6a 00                	push   $0x0
  801ee1:	ff 75 10             	pushl  0x10(%ebp)
  801ee4:	ff 75 0c             	pushl  0xc(%ebp)
  801ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eea:	ff 70 0c             	pushl  0xc(%eax)
  801eed:	e8 78 03 00 00       	call   80226a <nsipc_send>
}
  801ef2:	c9                   	leave  
  801ef3:	c3                   	ret    

00801ef4 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ef4:	55                   	push   %ebp
  801ef5:	89 e5                	mov    %esp,%ebp
  801ef7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801efa:	6a 00                	push   $0x0
  801efc:	ff 75 10             	pushl  0x10(%ebp)
  801eff:	ff 75 0c             	pushl  0xc(%ebp)
  801f02:	8b 45 08             	mov    0x8(%ebp),%eax
  801f05:	ff 70 0c             	pushl  0xc(%eax)
  801f08:	e8 f1 02 00 00       	call   8021fe <nsipc_recv>
}
  801f0d:	c9                   	leave  
  801f0e:	c3                   	ret    

00801f0f <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f15:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f18:	52                   	push   %edx
  801f19:	50                   	push   %eax
  801f1a:	e8 6f f4 ff ff       	call   80138e <fd_lookup>
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	85 c0                	test   %eax,%eax
  801f24:	78 17                	js     801f3d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f29:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801f2f:	39 08                	cmp    %ecx,(%eax)
  801f31:	75 05                	jne    801f38 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f33:	8b 40 0c             	mov    0xc(%eax),%eax
  801f36:	eb 05                	jmp    801f3d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f38:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 1c             	sub    $0x1c,%esp
  801f47:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4c:	50                   	push   %eax
  801f4d:	e8 ed f3 ff ff       	call   80133f <fd_alloc>
  801f52:	89 c3                	mov    %eax,%ebx
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	85 c0                	test   %eax,%eax
  801f59:	78 1b                	js     801f76 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f5b:	83 ec 04             	sub    $0x4,%esp
  801f5e:	68 07 04 00 00       	push   $0x407
  801f63:	ff 75 f4             	pushl  -0xc(%ebp)
  801f66:	6a 00                	push   $0x0
  801f68:	e8 05 f1 ff ff       	call   801072 <sys_page_alloc>
  801f6d:	89 c3                	mov    %eax,%ebx
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	85 c0                	test   %eax,%eax
  801f74:	79 10                	jns    801f86 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801f76:	83 ec 0c             	sub    $0xc,%esp
  801f79:	56                   	push   %esi
  801f7a:	e8 0e 02 00 00       	call   80218d <nsipc_close>
		return r;
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	89 d8                	mov    %ebx,%eax
  801f84:	eb 24                	jmp    801faa <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f86:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f94:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f9b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f9e:	83 ec 0c             	sub    $0xc,%esp
  801fa1:	50                   	push   %eax
  801fa2:	e8 71 f3 ff ff       	call   801318 <fd2num>
  801fa7:	83 c4 10             	add    $0x10,%esp
}
  801faa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5d                   	pop    %ebp
  801fb0:	c3                   	ret    

00801fb1 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fba:	e8 50 ff ff ff       	call   801f0f <fd2sockid>
		return r;
  801fbf:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	78 1f                	js     801fe4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fc5:	83 ec 04             	sub    $0x4,%esp
  801fc8:	ff 75 10             	pushl  0x10(%ebp)
  801fcb:	ff 75 0c             	pushl  0xc(%ebp)
  801fce:	50                   	push   %eax
  801fcf:	e8 12 01 00 00       	call   8020e6 <nsipc_accept>
  801fd4:	83 c4 10             	add    $0x10,%esp
		return r;
  801fd7:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 07                	js     801fe4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801fdd:	e8 5d ff ff ff       	call   801f3f <alloc_sockfd>
  801fe2:	89 c1                	mov    %eax,%ecx
}
  801fe4:	89 c8                	mov    %ecx,%eax
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    

00801fe8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fee:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff1:	e8 19 ff ff ff       	call   801f0f <fd2sockid>
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	78 12                	js     80200c <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ffa:	83 ec 04             	sub    $0x4,%esp
  801ffd:	ff 75 10             	pushl  0x10(%ebp)
  802000:	ff 75 0c             	pushl  0xc(%ebp)
  802003:	50                   	push   %eax
  802004:	e8 2d 01 00 00       	call   802136 <nsipc_bind>
  802009:	83 c4 10             	add    $0x10,%esp
}
  80200c:	c9                   	leave  
  80200d:	c3                   	ret    

0080200e <shutdown>:

int
shutdown(int s, int how)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802014:	8b 45 08             	mov    0x8(%ebp),%eax
  802017:	e8 f3 fe ff ff       	call   801f0f <fd2sockid>
  80201c:	85 c0                	test   %eax,%eax
  80201e:	78 0f                	js     80202f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802020:	83 ec 08             	sub    $0x8,%esp
  802023:	ff 75 0c             	pushl  0xc(%ebp)
  802026:	50                   	push   %eax
  802027:	e8 3f 01 00 00       	call   80216b <nsipc_shutdown>
  80202c:	83 c4 10             	add    $0x10,%esp
}
  80202f:	c9                   	leave  
  802030:	c3                   	ret    

00802031 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802037:	8b 45 08             	mov    0x8(%ebp),%eax
  80203a:	e8 d0 fe ff ff       	call   801f0f <fd2sockid>
  80203f:	85 c0                	test   %eax,%eax
  802041:	78 12                	js     802055 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802043:	83 ec 04             	sub    $0x4,%esp
  802046:	ff 75 10             	pushl  0x10(%ebp)
  802049:	ff 75 0c             	pushl  0xc(%ebp)
  80204c:	50                   	push   %eax
  80204d:	e8 55 01 00 00       	call   8021a7 <nsipc_connect>
  802052:	83 c4 10             	add    $0x10,%esp
}
  802055:	c9                   	leave  
  802056:	c3                   	ret    

00802057 <listen>:

int
listen(int s, int backlog)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80205d:	8b 45 08             	mov    0x8(%ebp),%eax
  802060:	e8 aa fe ff ff       	call   801f0f <fd2sockid>
  802065:	85 c0                	test   %eax,%eax
  802067:	78 0f                	js     802078 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802069:	83 ec 08             	sub    $0x8,%esp
  80206c:	ff 75 0c             	pushl  0xc(%ebp)
  80206f:	50                   	push   %eax
  802070:	e8 67 01 00 00       	call   8021dc <nsipc_listen>
  802075:	83 c4 10             	add    $0x10,%esp
}
  802078:	c9                   	leave  
  802079:	c3                   	ret    

0080207a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802080:	ff 75 10             	pushl  0x10(%ebp)
  802083:	ff 75 0c             	pushl  0xc(%ebp)
  802086:	ff 75 08             	pushl  0x8(%ebp)
  802089:	e8 3a 02 00 00       	call   8022c8 <nsipc_socket>
  80208e:	83 c4 10             	add    $0x10,%esp
  802091:	85 c0                	test   %eax,%eax
  802093:	78 05                	js     80209a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802095:	e8 a5 fe ff ff       	call   801f3f <alloc_sockfd>
}
  80209a:	c9                   	leave  
  80209b:	c3                   	ret    

0080209c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	53                   	push   %ebx
  8020a0:	83 ec 04             	sub    $0x4,%esp
  8020a3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020a5:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  8020ac:	75 12                	jne    8020c0 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8020ae:	83 ec 0c             	sub    $0xc,%esp
  8020b1:	6a 02                	push   $0x2
  8020b3:	e8 82 04 00 00       	call   80253a <ipc_find_env>
  8020b8:	a3 b0 40 80 00       	mov    %eax,0x8040b0
  8020bd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8020c0:	6a 07                	push   $0x7
  8020c2:	68 00 60 80 00       	push   $0x806000
  8020c7:	53                   	push   %ebx
  8020c8:	ff 35 b0 40 80 00    	pushl  0x8040b0
  8020ce:	e8 18 04 00 00       	call   8024eb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020d3:	83 c4 0c             	add    $0xc,%esp
  8020d6:	6a 00                	push   $0x0
  8020d8:	6a 00                	push   $0x0
  8020da:	6a 00                	push   $0x0
  8020dc:	e8 94 03 00 00       	call   802475 <ipc_recv>
}
  8020e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020e4:	c9                   	leave  
  8020e5:	c3                   	ret    

008020e6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	56                   	push   %esi
  8020ea:	53                   	push   %ebx
  8020eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8020ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8020f6:	8b 06                	mov    (%esi),%eax
  8020f8:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8020fd:	b8 01 00 00 00       	mov    $0x1,%eax
  802102:	e8 95 ff ff ff       	call   80209c <nsipc>
  802107:	89 c3                	mov    %eax,%ebx
  802109:	85 c0                	test   %eax,%eax
  80210b:	78 20                	js     80212d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80210d:	83 ec 04             	sub    $0x4,%esp
  802110:	ff 35 10 60 80 00    	pushl  0x806010
  802116:	68 00 60 80 00       	push   $0x806000
  80211b:	ff 75 0c             	pushl  0xc(%ebp)
  80211e:	e8 de ec ff ff       	call   800e01 <memmove>
		*addrlen = ret->ret_addrlen;
  802123:	a1 10 60 80 00       	mov    0x806010,%eax
  802128:	89 06                	mov    %eax,(%esi)
  80212a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80212d:	89 d8                	mov    %ebx,%eax
  80212f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802132:	5b                   	pop    %ebx
  802133:	5e                   	pop    %esi
  802134:	5d                   	pop    %ebp
  802135:	c3                   	ret    

00802136 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802136:	55                   	push   %ebp
  802137:	89 e5                	mov    %esp,%ebp
  802139:	53                   	push   %ebx
  80213a:	83 ec 08             	sub    $0x8,%esp
  80213d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802140:	8b 45 08             	mov    0x8(%ebp),%eax
  802143:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802148:	53                   	push   %ebx
  802149:	ff 75 0c             	pushl  0xc(%ebp)
  80214c:	68 04 60 80 00       	push   $0x806004
  802151:	e8 ab ec ff ff       	call   800e01 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802156:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80215c:	b8 02 00 00 00       	mov    $0x2,%eax
  802161:	e8 36 ff ff ff       	call   80209c <nsipc>
}
  802166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802169:	c9                   	leave  
  80216a:	c3                   	ret    

0080216b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802171:	8b 45 08             	mov    0x8(%ebp),%eax
  802174:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  802179:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802181:	b8 03 00 00 00       	mov    $0x3,%eax
  802186:	e8 11 ff ff ff       	call   80209c <nsipc>
}
  80218b:	c9                   	leave  
  80218c:	c3                   	ret    

0080218d <nsipc_close>:

int
nsipc_close(int s)
{
  80218d:	55                   	push   %ebp
  80218e:	89 e5                	mov    %esp,%ebp
  802190:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802193:	8b 45 08             	mov    0x8(%ebp),%eax
  802196:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80219b:	b8 04 00 00 00       	mov    $0x4,%eax
  8021a0:	e8 f7 fe ff ff       	call   80209c <nsipc>
}
  8021a5:	c9                   	leave  
  8021a6:	c3                   	ret    

008021a7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	53                   	push   %ebx
  8021ab:	83 ec 08             	sub    $0x8,%esp
  8021ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8021b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8021b9:	53                   	push   %ebx
  8021ba:	ff 75 0c             	pushl  0xc(%ebp)
  8021bd:	68 04 60 80 00       	push   $0x806004
  8021c2:	e8 3a ec ff ff       	call   800e01 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8021c7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8021cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8021d2:	e8 c5 fe ff ff       	call   80209c <nsipc>
}
  8021d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021da:	c9                   	leave  
  8021db:	c3                   	ret    

008021dc <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8021ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ed:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8021f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8021f7:	e8 a0 fe ff ff       	call   80209c <nsipc>
}
  8021fc:	c9                   	leave  
  8021fd:	c3                   	ret    

008021fe <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	56                   	push   %esi
  802202:	53                   	push   %ebx
  802203:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802206:	8b 45 08             	mov    0x8(%ebp),%eax
  802209:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80220e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802214:	8b 45 14             	mov    0x14(%ebp),%eax
  802217:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80221c:	b8 07 00 00 00       	mov    $0x7,%eax
  802221:	e8 76 fe ff ff       	call   80209c <nsipc>
  802226:	89 c3                	mov    %eax,%ebx
  802228:	85 c0                	test   %eax,%eax
  80222a:	78 35                	js     802261 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80222c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802231:	7f 04                	jg     802237 <nsipc_recv+0x39>
  802233:	39 c6                	cmp    %eax,%esi
  802235:	7d 16                	jge    80224d <nsipc_recv+0x4f>
  802237:	68 d6 2d 80 00       	push   $0x802dd6
  80223c:	68 7f 2d 80 00       	push   $0x802d7f
  802241:	6a 62                	push   $0x62
  802243:	68 eb 2d 80 00       	push   $0x802deb
  802248:	e8 a4 e3 ff ff       	call   8005f1 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80224d:	83 ec 04             	sub    $0x4,%esp
  802250:	50                   	push   %eax
  802251:	68 00 60 80 00       	push   $0x806000
  802256:	ff 75 0c             	pushl  0xc(%ebp)
  802259:	e8 a3 eb ff ff       	call   800e01 <memmove>
  80225e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802261:	89 d8                	mov    %ebx,%eax
  802263:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802266:	5b                   	pop    %ebx
  802267:	5e                   	pop    %esi
  802268:	5d                   	pop    %ebp
  802269:	c3                   	ret    

0080226a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	53                   	push   %ebx
  80226e:	83 ec 04             	sub    $0x4,%esp
  802271:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802274:	8b 45 08             	mov    0x8(%ebp),%eax
  802277:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80227c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802282:	7e 16                	jle    80229a <nsipc_send+0x30>
  802284:	68 f7 2d 80 00       	push   $0x802df7
  802289:	68 7f 2d 80 00       	push   $0x802d7f
  80228e:	6a 6d                	push   $0x6d
  802290:	68 eb 2d 80 00       	push   $0x802deb
  802295:	e8 57 e3 ff ff       	call   8005f1 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80229a:	83 ec 04             	sub    $0x4,%esp
  80229d:	53                   	push   %ebx
  80229e:	ff 75 0c             	pushl  0xc(%ebp)
  8022a1:	68 0c 60 80 00       	push   $0x80600c
  8022a6:	e8 56 eb ff ff       	call   800e01 <memmove>
	nsipcbuf.send.req_size = size;
  8022ab:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8022b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8022b4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8022b9:	b8 08 00 00 00       	mov    $0x8,%eax
  8022be:	e8 d9 fd ff ff       	call   80209c <nsipc>
}
  8022c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022c6:	c9                   	leave  
  8022c7:	c3                   	ret    

008022c8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8022d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d9:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8022de:	8b 45 10             	mov    0x10(%ebp),%eax
  8022e1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8022e6:	b8 09 00 00 00       	mov    $0x9,%eax
  8022eb:	e8 ac fd ff ff       	call   80209c <nsipc>
}
  8022f0:	c9                   	leave  
  8022f1:	c3                   	ret    

008022f2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022f2:	55                   	push   %ebp
  8022f3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    

008022fc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022fc:	55                   	push   %ebp
  8022fd:	89 e5                	mov    %esp,%ebp
  8022ff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802302:	68 03 2e 80 00       	push   $0x802e03
  802307:	ff 75 0c             	pushl  0xc(%ebp)
  80230a:	e8 60 e9 ff ff       	call   800c6f <strcpy>
	return 0;
}
  80230f:	b8 00 00 00 00       	mov    $0x0,%eax
  802314:	c9                   	leave  
  802315:	c3                   	ret    

00802316 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802316:	55                   	push   %ebp
  802317:	89 e5                	mov    %esp,%ebp
  802319:	57                   	push   %edi
  80231a:	56                   	push   %esi
  80231b:	53                   	push   %ebx
  80231c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802322:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802327:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80232d:	eb 2d                	jmp    80235c <devcons_write+0x46>
		m = n - tot;
  80232f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802332:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802334:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802337:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80233c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80233f:	83 ec 04             	sub    $0x4,%esp
  802342:	53                   	push   %ebx
  802343:	03 45 0c             	add    0xc(%ebp),%eax
  802346:	50                   	push   %eax
  802347:	57                   	push   %edi
  802348:	e8 b4 ea ff ff       	call   800e01 <memmove>
		sys_cputs(buf, m);
  80234d:	83 c4 08             	add    $0x8,%esp
  802350:	53                   	push   %ebx
  802351:	57                   	push   %edi
  802352:	e8 5f ec ff ff       	call   800fb6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802357:	01 de                	add    %ebx,%esi
  802359:	83 c4 10             	add    $0x10,%esp
  80235c:	89 f0                	mov    %esi,%eax
  80235e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802361:	72 cc                	jb     80232f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802363:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802366:	5b                   	pop    %ebx
  802367:	5e                   	pop    %esi
  802368:	5f                   	pop    %edi
  802369:	5d                   	pop    %ebp
  80236a:	c3                   	ret    

0080236b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80236b:	55                   	push   %ebp
  80236c:	89 e5                	mov    %esp,%ebp
  80236e:	83 ec 08             	sub    $0x8,%esp
  802371:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802376:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80237a:	74 2a                	je     8023a6 <devcons_read+0x3b>
  80237c:	eb 05                	jmp    802383 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80237e:	e8 d0 ec ff ff       	call   801053 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802383:	e8 4c ec ff ff       	call   800fd4 <sys_cgetc>
  802388:	85 c0                	test   %eax,%eax
  80238a:	74 f2                	je     80237e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80238c:	85 c0                	test   %eax,%eax
  80238e:	78 16                	js     8023a6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802390:	83 f8 04             	cmp    $0x4,%eax
  802393:	74 0c                	je     8023a1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802395:	8b 55 0c             	mov    0xc(%ebp),%edx
  802398:	88 02                	mov    %al,(%edx)
	return 1;
  80239a:	b8 01 00 00 00       	mov    $0x1,%eax
  80239f:	eb 05                	jmp    8023a6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023a1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023a6:	c9                   	leave  
  8023a7:	c3                   	ret    

008023a8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
  8023ab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023b4:	6a 01                	push   $0x1
  8023b6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023b9:	50                   	push   %eax
  8023ba:	e8 f7 eb ff ff       	call   800fb6 <sys_cputs>
}
  8023bf:	83 c4 10             	add    $0x10,%esp
  8023c2:	c9                   	leave  
  8023c3:	c3                   	ret    

008023c4 <getchar>:

int
getchar(void)
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
  8023c7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023ca:	6a 01                	push   $0x1
  8023cc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023cf:	50                   	push   %eax
  8023d0:	6a 00                	push   $0x0
  8023d2:	e8 1d f2 ff ff       	call   8015f4 <read>
	if (r < 0)
  8023d7:	83 c4 10             	add    $0x10,%esp
  8023da:	85 c0                	test   %eax,%eax
  8023dc:	78 0f                	js     8023ed <getchar+0x29>
		return r;
	if (r < 1)
  8023de:	85 c0                	test   %eax,%eax
  8023e0:	7e 06                	jle    8023e8 <getchar+0x24>
		return -E_EOF;
	return c;
  8023e2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023e6:	eb 05                	jmp    8023ed <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023e8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023ed:	c9                   	leave  
  8023ee:	c3                   	ret    

008023ef <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023ef:	55                   	push   %ebp
  8023f0:	89 e5                	mov    %esp,%ebp
  8023f2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023f8:	50                   	push   %eax
  8023f9:	ff 75 08             	pushl  0x8(%ebp)
  8023fc:	e8 8d ef ff ff       	call   80138e <fd_lookup>
  802401:	83 c4 10             	add    $0x10,%esp
  802404:	85 c0                	test   %eax,%eax
  802406:	78 11                	js     802419 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802408:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802411:	39 10                	cmp    %edx,(%eax)
  802413:	0f 94 c0             	sete   %al
  802416:	0f b6 c0             	movzbl %al,%eax
}
  802419:	c9                   	leave  
  80241a:	c3                   	ret    

0080241b <opencons>:

int
opencons(void)
{
  80241b:	55                   	push   %ebp
  80241c:	89 e5                	mov    %esp,%ebp
  80241e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802421:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802424:	50                   	push   %eax
  802425:	e8 15 ef ff ff       	call   80133f <fd_alloc>
  80242a:	83 c4 10             	add    $0x10,%esp
		return r;
  80242d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80242f:	85 c0                	test   %eax,%eax
  802431:	78 3e                	js     802471 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802433:	83 ec 04             	sub    $0x4,%esp
  802436:	68 07 04 00 00       	push   $0x407
  80243b:	ff 75 f4             	pushl  -0xc(%ebp)
  80243e:	6a 00                	push   $0x0
  802440:	e8 2d ec ff ff       	call   801072 <sys_page_alloc>
  802445:	83 c4 10             	add    $0x10,%esp
		return r;
  802448:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80244a:	85 c0                	test   %eax,%eax
  80244c:	78 23                	js     802471 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80244e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802454:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802457:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802459:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802463:	83 ec 0c             	sub    $0xc,%esp
  802466:	50                   	push   %eax
  802467:	e8 ac ee ff ff       	call   801318 <fd2num>
  80246c:	89 c2                	mov    %eax,%edx
  80246e:	83 c4 10             	add    $0x10,%esp
}
  802471:	89 d0                	mov    %edx,%eax
  802473:	c9                   	leave  
  802474:	c3                   	ret    

00802475 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802475:	55                   	push   %ebp
  802476:	89 e5                	mov    %esp,%ebp
  802478:	56                   	push   %esi
  802479:	53                   	push   %ebx
  80247a:	8b 75 08             	mov    0x8(%ebp),%esi
  80247d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802480:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  802483:	85 c0                	test   %eax,%eax
  802485:	74 0e                	je     802495 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  802487:	83 ec 0c             	sub    $0xc,%esp
  80248a:	50                   	push   %eax
  80248b:	e8 92 ed ff ff       	call   801222 <sys_ipc_recv>
  802490:	83 c4 10             	add    $0x10,%esp
  802493:	eb 10                	jmp    8024a5 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802495:	83 ec 0c             	sub    $0xc,%esp
  802498:	68 00 00 c0 ee       	push   $0xeec00000
  80249d:	e8 80 ed ff ff       	call   801222 <sys_ipc_recv>
  8024a2:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8024a5:	85 c0                	test   %eax,%eax
  8024a7:	79 17                	jns    8024c0 <ipc_recv+0x4b>
		if(*from_env_store)
  8024a9:	83 3e 00             	cmpl   $0x0,(%esi)
  8024ac:	74 06                	je     8024b4 <ipc_recv+0x3f>
			*from_env_store = 0;
  8024ae:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8024b4:	85 db                	test   %ebx,%ebx
  8024b6:	74 2c                	je     8024e4 <ipc_recv+0x6f>
			*perm_store = 0;
  8024b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024be:	eb 24                	jmp    8024e4 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  8024c0:	85 f6                	test   %esi,%esi
  8024c2:	74 0a                	je     8024ce <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  8024c4:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8024c9:	8b 40 74             	mov    0x74(%eax),%eax
  8024cc:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8024ce:	85 db                	test   %ebx,%ebx
  8024d0:	74 0a                	je     8024dc <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8024d2:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8024d7:	8b 40 78             	mov    0x78(%eax),%eax
  8024da:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8024dc:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8024e1:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024e7:	5b                   	pop    %ebx
  8024e8:	5e                   	pop    %esi
  8024e9:	5d                   	pop    %ebp
  8024ea:	c3                   	ret    

008024eb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024eb:	55                   	push   %ebp
  8024ec:	89 e5                	mov    %esp,%ebp
  8024ee:	57                   	push   %edi
  8024ef:	56                   	push   %esi
  8024f0:	53                   	push   %ebx
  8024f1:	83 ec 0c             	sub    $0xc,%esp
  8024f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8024fd:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  8024ff:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802504:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802507:	e8 47 eb ff ff       	call   801053 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  80250c:	ff 75 14             	pushl  0x14(%ebp)
  80250f:	53                   	push   %ebx
  802510:	56                   	push   %esi
  802511:	57                   	push   %edi
  802512:	e8 e8 ec ff ff       	call   8011ff <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802517:	89 c2                	mov    %eax,%edx
  802519:	f7 d2                	not    %edx
  80251b:	c1 ea 1f             	shr    $0x1f,%edx
  80251e:	83 c4 10             	add    $0x10,%esp
  802521:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802524:	0f 94 c1             	sete   %cl
  802527:	09 ca                	or     %ecx,%edx
  802529:	85 c0                	test   %eax,%eax
  80252b:	0f 94 c0             	sete   %al
  80252e:	38 c2                	cmp    %al,%dl
  802530:	77 d5                	ja     802507 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802532:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802535:	5b                   	pop    %ebx
  802536:	5e                   	pop    %esi
  802537:	5f                   	pop    %edi
  802538:	5d                   	pop    %ebp
  802539:	c3                   	ret    

0080253a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80253a:	55                   	push   %ebp
  80253b:	89 e5                	mov    %esp,%ebp
  80253d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802540:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802545:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802548:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80254e:	8b 52 50             	mov    0x50(%edx),%edx
  802551:	39 ca                	cmp    %ecx,%edx
  802553:	75 0d                	jne    802562 <ipc_find_env+0x28>
			return envs[i].env_id;
  802555:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802558:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80255d:	8b 40 48             	mov    0x48(%eax),%eax
  802560:	eb 0f                	jmp    802571 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802562:	83 c0 01             	add    $0x1,%eax
  802565:	3d 00 04 00 00       	cmp    $0x400,%eax
  80256a:	75 d9                	jne    802545 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80256c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802571:	5d                   	pop    %ebp
  802572:	c3                   	ret    

00802573 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802573:	55                   	push   %ebp
  802574:	89 e5                	mov    %esp,%ebp
  802576:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802579:	89 d0                	mov    %edx,%eax
  80257b:	c1 e8 16             	shr    $0x16,%eax
  80257e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802585:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80258a:	f6 c1 01             	test   $0x1,%cl
  80258d:	74 1d                	je     8025ac <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80258f:	c1 ea 0c             	shr    $0xc,%edx
  802592:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802599:	f6 c2 01             	test   $0x1,%dl
  80259c:	74 0e                	je     8025ac <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80259e:	c1 ea 0c             	shr    $0xc,%edx
  8025a1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025a8:	ef 
  8025a9:	0f b7 c0             	movzwl %ax,%eax
}
  8025ac:	5d                   	pop    %ebp
  8025ad:	c3                   	ret    
  8025ae:	66 90                	xchg   %ax,%ax

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
