
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 80 03 80 00       	push   $0x800380
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 cd 04 00 00       	call   800572 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 2a 23 80 00       	push   $0x80232a
  80011e:	6a 23                	push   $0x23
  800120:	68 47 23 80 00       	push   $0x802347
  800125:	e8 da 13 00 00       	call   801504 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 2a 23 80 00       	push   $0x80232a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 47 23 80 00       	push   $0x802347
  8001a6:	e8 59 13 00 00       	call   801504 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 2a 23 80 00       	push   $0x80232a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 47 23 80 00       	push   $0x802347
  8001e8:	e8 17 13 00 00       	call   801504 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 2a 23 80 00       	push   $0x80232a
  800223:	6a 23                	push   $0x23
  800225:	68 47 23 80 00       	push   $0x802347
  80022a:	e8 d5 12 00 00       	call   801504 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 2a 23 80 00       	push   $0x80232a
  800265:	6a 23                	push   $0x23
  800267:	68 47 23 80 00       	push   $0x802347
  80026c:	e8 93 12 00 00       	call   801504 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 2a 23 80 00       	push   $0x80232a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 47 23 80 00       	push   $0x802347
  8002ae:	e8 51 12 00 00       	call   801504 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 2a 23 80 00       	push   $0x80232a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 47 23 80 00       	push   $0x802347
  8002f0:	e8 0f 12 00 00       	call   801504 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 2a 23 80 00       	push   $0x80232a
  80034d:	6a 23                	push   $0x23
  80034f:	68 47 23 80 00       	push   $0x802347
  800354:	e8 ab 11 00 00       	call   801504 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800367:	ba 00 00 00 00       	mov    $0x0,%edx
  80036c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800371:	89 d1                	mov    %edx,%ecx
  800373:	89 d3                	mov    %edx,%ebx
  800375:	89 d7                	mov    %edx,%edi
  800377:	89 d6                	mov    %edx,%esi
  800379:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800380:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800381:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  800386:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800388:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  80038b:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  80038d:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  800391:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  800395:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  800396:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  800398:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  80039d:	83 c4 08             	add    $0x8,%esp
	popal
  8003a0:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8003a1:	83 c4 04             	add    $0x4,%esp
	popfl
  8003a4:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8003a5:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8003a6:	c3                   	ret    

008003a7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ad:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b2:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bd:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d9:	89 c2                	mov    %eax,%edx
  8003db:	c1 ea 16             	shr    $0x16,%edx
  8003de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e5:	f6 c2 01             	test   $0x1,%dl
  8003e8:	74 11                	je     8003fb <fd_alloc+0x2d>
  8003ea:	89 c2                	mov    %eax,%edx
  8003ec:	c1 ea 0c             	shr    $0xc,%edx
  8003ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f6:	f6 c2 01             	test   $0x1,%dl
  8003f9:	75 09                	jne    800404 <fd_alloc+0x36>
			*fd_store = fd;
  8003fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800402:	eb 17                	jmp    80041b <fd_alloc+0x4d>
  800404:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800409:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80040e:	75 c9                	jne    8003d9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800410:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800416:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    

0080041d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800423:	83 f8 1f             	cmp    $0x1f,%eax
  800426:	77 36                	ja     80045e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800428:	c1 e0 0c             	shl    $0xc,%eax
  80042b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800430:	89 c2                	mov    %eax,%edx
  800432:	c1 ea 16             	shr    $0x16,%edx
  800435:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80043c:	f6 c2 01             	test   $0x1,%dl
  80043f:	74 24                	je     800465 <fd_lookup+0x48>
  800441:	89 c2                	mov    %eax,%edx
  800443:	c1 ea 0c             	shr    $0xc,%edx
  800446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044d:	f6 c2 01             	test   $0x1,%dl
  800450:	74 1a                	je     80046c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	89 02                	mov    %eax,(%edx)
	return 0;
  800457:	b8 00 00 00 00       	mov    $0x0,%eax
  80045c:	eb 13                	jmp    800471 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800463:	eb 0c                	jmp    800471 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046a:	eb 05                	jmp    800471 <fd_lookup+0x54>
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800471:	5d                   	pop    %ebp
  800472:	c3                   	ret    

00800473 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80047c:	ba d4 23 80 00       	mov    $0x8023d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800481:	eb 13                	jmp    800496 <dev_lookup+0x23>
  800483:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800486:	39 08                	cmp    %ecx,(%eax)
  800488:	75 0c                	jne    800496 <dev_lookup+0x23>
			*dev = devtab[i];
  80048a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80048d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80048f:	b8 00 00 00 00       	mov    $0x0,%eax
  800494:	eb 2e                	jmp    8004c4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800496:	8b 02                	mov    (%edx),%eax
  800498:	85 c0                	test   %eax,%eax
  80049a:	75 e7                	jne    800483 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80049c:	a1 08 40 80 00       	mov    0x804008,%eax
  8004a1:	8b 40 48             	mov    0x48(%eax),%eax
  8004a4:	83 ec 04             	sub    $0x4,%esp
  8004a7:	51                   	push   %ecx
  8004a8:	50                   	push   %eax
  8004a9:	68 58 23 80 00       	push   $0x802358
  8004ae:	e8 2a 11 00 00       	call   8015dd <cprintf>
	*dev = 0;
  8004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004c4:	c9                   	leave  
  8004c5:	c3                   	ret    

008004c6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	56                   	push   %esi
  8004ca:	53                   	push   %ebx
  8004cb:	83 ec 10             	sub    $0x10,%esp
  8004ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d7:	50                   	push   %eax
  8004d8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004de:	c1 e8 0c             	shr    $0xc,%eax
  8004e1:	50                   	push   %eax
  8004e2:	e8 36 ff ff ff       	call   80041d <fd_lookup>
  8004e7:	83 c4 08             	add    $0x8,%esp
  8004ea:	85 c0                	test   %eax,%eax
  8004ec:	78 05                	js     8004f3 <fd_close+0x2d>
	    || fd != fd2)
  8004ee:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004f1:	74 0c                	je     8004ff <fd_close+0x39>
		return (must_exist ? r : 0);
  8004f3:	84 db                	test   %bl,%bl
  8004f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fa:	0f 44 c2             	cmove  %edx,%eax
  8004fd:	eb 41                	jmp    800540 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800505:	50                   	push   %eax
  800506:	ff 36                	pushl  (%esi)
  800508:	e8 66 ff ff ff       	call   800473 <dev_lookup>
  80050d:	89 c3                	mov    %eax,%ebx
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	85 c0                	test   %eax,%eax
  800514:	78 1a                	js     800530 <fd_close+0x6a>
		if (dev->dev_close)
  800516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800519:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80051c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800521:	85 c0                	test   %eax,%eax
  800523:	74 0b                	je     800530 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800525:	83 ec 0c             	sub    $0xc,%esp
  800528:	56                   	push   %esi
  800529:	ff d0                	call   *%eax
  80052b:	89 c3                	mov    %eax,%ebx
  80052d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	56                   	push   %esi
  800534:	6a 00                	push   $0x0
  800536:	e8 ba fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	89 d8                	mov    %ebx,%eax
}
  800540:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800543:	5b                   	pop    %ebx
  800544:	5e                   	pop    %esi
  800545:	5d                   	pop    %ebp
  800546:	c3                   	ret    

00800547 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80054d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800550:	50                   	push   %eax
  800551:	ff 75 08             	pushl  0x8(%ebp)
  800554:	e8 c4 fe ff ff       	call   80041d <fd_lookup>
  800559:	83 c4 08             	add    $0x8,%esp
  80055c:	85 c0                	test   %eax,%eax
  80055e:	78 10                	js     800570 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	6a 01                	push   $0x1
  800565:	ff 75 f4             	pushl  -0xc(%ebp)
  800568:	e8 59 ff ff ff       	call   8004c6 <fd_close>
  80056d:	83 c4 10             	add    $0x10,%esp
}
  800570:	c9                   	leave  
  800571:	c3                   	ret    

00800572 <close_all>:

void
close_all(void)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	53                   	push   %ebx
  800576:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800579:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80057e:	83 ec 0c             	sub    $0xc,%esp
  800581:	53                   	push   %ebx
  800582:	e8 c0 ff ff ff       	call   800547 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800587:	83 c3 01             	add    $0x1,%ebx
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	83 fb 20             	cmp    $0x20,%ebx
  800590:	75 ec                	jne    80057e <close_all+0xc>
		close(i);
}
  800592:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	57                   	push   %edi
  80059b:	56                   	push   %esi
  80059c:	53                   	push   %ebx
  80059d:	83 ec 2c             	sub    $0x2c,%esp
  8005a0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a6:	50                   	push   %eax
  8005a7:	ff 75 08             	pushl  0x8(%ebp)
  8005aa:	e8 6e fe ff ff       	call   80041d <fd_lookup>
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	85 c0                	test   %eax,%eax
  8005b4:	0f 88 c1 00 00 00    	js     80067b <dup+0xe4>
		return r;
	close(newfdnum);
  8005ba:	83 ec 0c             	sub    $0xc,%esp
  8005bd:	56                   	push   %esi
  8005be:	e8 84 ff ff ff       	call   800547 <close>

	newfd = INDEX2FD(newfdnum);
  8005c3:	89 f3                	mov    %esi,%ebx
  8005c5:	c1 e3 0c             	shl    $0xc,%ebx
  8005c8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ce:	83 c4 04             	add    $0x4,%esp
  8005d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005d4:	e8 de fd ff ff       	call   8003b7 <fd2data>
  8005d9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005db:	89 1c 24             	mov    %ebx,(%esp)
  8005de:	e8 d4 fd ff ff       	call   8003b7 <fd2data>
  8005e3:	83 c4 10             	add    $0x10,%esp
  8005e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e9:	89 f8                	mov    %edi,%eax
  8005eb:	c1 e8 16             	shr    $0x16,%eax
  8005ee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f5:	a8 01                	test   $0x1,%al
  8005f7:	74 37                	je     800630 <dup+0x99>
  8005f9:	89 f8                	mov    %edi,%eax
  8005fb:	c1 e8 0c             	shr    $0xc,%eax
  8005fe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800605:	f6 c2 01             	test   $0x1,%dl
  800608:	74 26                	je     800630 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80060a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	25 07 0e 00 00       	and    $0xe07,%eax
  800619:	50                   	push   %eax
  80061a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061d:	6a 00                	push   $0x0
  80061f:	57                   	push   %edi
  800620:	6a 00                	push   $0x0
  800622:	e8 8c fb ff ff       	call   8001b3 <sys_page_map>
  800627:	89 c7                	mov    %eax,%edi
  800629:	83 c4 20             	add    $0x20,%esp
  80062c:	85 c0                	test   %eax,%eax
  80062e:	78 2e                	js     80065e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800633:	89 d0                	mov    %edx,%eax
  800635:	c1 e8 0c             	shr    $0xc,%eax
  800638:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80063f:	83 ec 0c             	sub    $0xc,%esp
  800642:	25 07 0e 00 00       	and    $0xe07,%eax
  800647:	50                   	push   %eax
  800648:	53                   	push   %ebx
  800649:	6a 00                	push   $0x0
  80064b:	52                   	push   %edx
  80064c:	6a 00                	push   $0x0
  80064e:	e8 60 fb ff ff       	call   8001b3 <sys_page_map>
  800653:	89 c7                	mov    %eax,%edi
  800655:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800658:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80065a:	85 ff                	test   %edi,%edi
  80065c:	79 1d                	jns    80067b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 00                	push   $0x0
  800664:	e8 8c fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800669:	83 c4 08             	add    $0x8,%esp
  80066c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80066f:	6a 00                	push   $0x0
  800671:	e8 7f fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	89 f8                	mov    %edi,%eax
}
  80067b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5e                   	pop    %esi
  800680:	5f                   	pop    %edi
  800681:	5d                   	pop    %ebp
  800682:	c3                   	ret    

00800683 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	53                   	push   %ebx
  800687:	83 ec 14             	sub    $0x14,%esp
  80068a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80068d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800690:	50                   	push   %eax
  800691:	53                   	push   %ebx
  800692:	e8 86 fd ff ff       	call   80041d <fd_lookup>
  800697:	83 c4 08             	add    $0x8,%esp
  80069a:	89 c2                	mov    %eax,%edx
  80069c:	85 c0                	test   %eax,%eax
  80069e:	78 6d                	js     80070d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a6:	50                   	push   %eax
  8006a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006aa:	ff 30                	pushl  (%eax)
  8006ac:	e8 c2 fd ff ff       	call   800473 <dev_lookup>
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	78 4c                	js     800704 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006bb:	8b 42 08             	mov    0x8(%edx),%eax
  8006be:	83 e0 03             	and    $0x3,%eax
  8006c1:	83 f8 01             	cmp    $0x1,%eax
  8006c4:	75 21                	jne    8006e7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006c6:	a1 08 40 80 00       	mov    0x804008,%eax
  8006cb:	8b 40 48             	mov    0x48(%eax),%eax
  8006ce:	83 ec 04             	sub    $0x4,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	50                   	push   %eax
  8006d3:	68 99 23 80 00       	push   $0x802399
  8006d8:	e8 00 0f 00 00       	call   8015dd <cprintf>
		return -E_INVAL;
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006e5:	eb 26                	jmp    80070d <read+0x8a>
	}
	if (!dev->dev_read)
  8006e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ea:	8b 40 08             	mov    0x8(%eax),%eax
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 17                	je     800708 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006f1:	83 ec 04             	sub    $0x4,%esp
  8006f4:	ff 75 10             	pushl  0x10(%ebp)
  8006f7:	ff 75 0c             	pushl  0xc(%ebp)
  8006fa:	52                   	push   %edx
  8006fb:	ff d0                	call   *%eax
  8006fd:	89 c2                	mov    %eax,%edx
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	eb 09                	jmp    80070d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800704:	89 c2                	mov    %eax,%edx
  800706:	eb 05                	jmp    80070d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800708:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80070d:	89 d0                	mov    %edx,%eax
  80070f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	57                   	push   %edi
  800718:	56                   	push   %esi
  800719:	53                   	push   %ebx
  80071a:	83 ec 0c             	sub    $0xc,%esp
  80071d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800720:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800723:	bb 00 00 00 00       	mov    $0x0,%ebx
  800728:	eb 21                	jmp    80074b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80072a:	83 ec 04             	sub    $0x4,%esp
  80072d:	89 f0                	mov    %esi,%eax
  80072f:	29 d8                	sub    %ebx,%eax
  800731:	50                   	push   %eax
  800732:	89 d8                	mov    %ebx,%eax
  800734:	03 45 0c             	add    0xc(%ebp),%eax
  800737:	50                   	push   %eax
  800738:	57                   	push   %edi
  800739:	e8 45 ff ff ff       	call   800683 <read>
		if (m < 0)
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	85 c0                	test   %eax,%eax
  800743:	78 10                	js     800755 <readn+0x41>
			return m;
		if (m == 0)
  800745:	85 c0                	test   %eax,%eax
  800747:	74 0a                	je     800753 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800749:	01 c3                	add    %eax,%ebx
  80074b:	39 f3                	cmp    %esi,%ebx
  80074d:	72 db                	jb     80072a <readn+0x16>
  80074f:	89 d8                	mov    %ebx,%eax
  800751:	eb 02                	jmp    800755 <readn+0x41>
  800753:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800755:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5f                   	pop    %edi
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	53                   	push   %ebx
  800761:	83 ec 14             	sub    $0x14,%esp
  800764:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800767:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	53                   	push   %ebx
  80076c:	e8 ac fc ff ff       	call   80041d <fd_lookup>
  800771:	83 c4 08             	add    $0x8,%esp
  800774:	89 c2                	mov    %eax,%edx
  800776:	85 c0                	test   %eax,%eax
  800778:	78 68                	js     8007e2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077a:	83 ec 08             	sub    $0x8,%esp
  80077d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800784:	ff 30                	pushl  (%eax)
  800786:	e8 e8 fc ff ff       	call   800473 <dev_lookup>
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	85 c0                	test   %eax,%eax
  800790:	78 47                	js     8007d9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800792:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800795:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800799:	75 21                	jne    8007bc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80079b:	a1 08 40 80 00       	mov    0x804008,%eax
  8007a0:	8b 40 48             	mov    0x48(%eax),%eax
  8007a3:	83 ec 04             	sub    $0x4,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	50                   	push   %eax
  8007a8:	68 b5 23 80 00       	push   $0x8023b5
  8007ad:	e8 2b 0e 00 00       	call   8015dd <cprintf>
		return -E_INVAL;
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007ba:	eb 26                	jmp    8007e2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8007c2:	85 d2                	test   %edx,%edx
  8007c4:	74 17                	je     8007dd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c6:	83 ec 04             	sub    $0x4,%esp
  8007c9:	ff 75 10             	pushl  0x10(%ebp)
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	50                   	push   %eax
  8007d0:	ff d2                	call   *%edx
  8007d2:	89 c2                	mov    %eax,%edx
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	eb 09                	jmp    8007e2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	eb 05                	jmp    8007e2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007e2:	89 d0                	mov    %edx,%eax
  8007e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ef:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007f2:	50                   	push   %eax
  8007f3:	ff 75 08             	pushl  0x8(%ebp)
  8007f6:	e8 22 fc ff ff       	call   80041d <fd_lookup>
  8007fb:	83 c4 08             	add    $0x8,%esp
  8007fe:	85 c0                	test   %eax,%eax
  800800:	78 0e                	js     800810 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800802:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
  800808:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	83 ec 14             	sub    $0x14,%esp
  800819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	53                   	push   %ebx
  800821:	e8 f7 fb ff ff       	call   80041d <fd_lookup>
  800826:	83 c4 08             	add    $0x8,%esp
  800829:	89 c2                	mov    %eax,%edx
  80082b:	85 c0                	test   %eax,%eax
  80082d:	78 65                	js     800894 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800835:	50                   	push   %eax
  800836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800839:	ff 30                	pushl  (%eax)
  80083b:	e8 33 fc ff ff       	call   800473 <dev_lookup>
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	85 c0                	test   %eax,%eax
  800845:	78 44                	js     80088b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80084e:	75 21                	jne    800871 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800850:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800855:	8b 40 48             	mov    0x48(%eax),%eax
  800858:	83 ec 04             	sub    $0x4,%esp
  80085b:	53                   	push   %ebx
  80085c:	50                   	push   %eax
  80085d:	68 78 23 80 00       	push   $0x802378
  800862:	e8 76 0d 00 00       	call   8015dd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80086f:	eb 23                	jmp    800894 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800871:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800874:	8b 52 18             	mov    0x18(%edx),%edx
  800877:	85 d2                	test   %edx,%edx
  800879:	74 14                	je     80088f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	ff 75 0c             	pushl  0xc(%ebp)
  800881:	50                   	push   %eax
  800882:	ff d2                	call   *%edx
  800884:	89 c2                	mov    %eax,%edx
  800886:	83 c4 10             	add    $0x10,%esp
  800889:	eb 09                	jmp    800894 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088b:	89 c2                	mov    %eax,%edx
  80088d:	eb 05                	jmp    800894 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80088f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800894:	89 d0                	mov    %edx,%eax
  800896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	83 ec 14             	sub    $0x14,%esp
  8008a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a8:	50                   	push   %eax
  8008a9:	ff 75 08             	pushl  0x8(%ebp)
  8008ac:	e8 6c fb ff ff       	call   80041d <fd_lookup>
  8008b1:	83 c4 08             	add    $0x8,%esp
  8008b4:	89 c2                	mov    %eax,%edx
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 58                	js     800912 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c0:	50                   	push   %eax
  8008c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c4:	ff 30                	pushl  (%eax)
  8008c6:	e8 a8 fb ff ff       	call   800473 <dev_lookup>
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	85 c0                	test   %eax,%eax
  8008d0:	78 37                	js     800909 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d9:	74 32                	je     80090d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008db:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008de:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008e5:	00 00 00 
	stat->st_isdir = 0;
  8008e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ef:	00 00 00 
	stat->st_dev = dev;
  8008f2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	53                   	push   %ebx
  8008fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ff:	ff 50 14             	call   *0x14(%eax)
  800902:	89 c2                	mov    %eax,%edx
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb 09                	jmp    800912 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800909:	89 c2                	mov    %eax,%edx
  80090b:	eb 05                	jmp    800912 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80090d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800912:	89 d0                	mov    %edx,%eax
  800914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800917:	c9                   	leave  
  800918:	c3                   	ret    

00800919 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	6a 00                	push   $0x0
  800923:	ff 75 08             	pushl  0x8(%ebp)
  800926:	e8 ef 01 00 00       	call   800b1a <open>
  80092b:	89 c3                	mov    %eax,%ebx
  80092d:	83 c4 10             	add    $0x10,%esp
  800930:	85 c0                	test   %eax,%eax
  800932:	78 1b                	js     80094f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800934:	83 ec 08             	sub    $0x8,%esp
  800937:	ff 75 0c             	pushl  0xc(%ebp)
  80093a:	50                   	push   %eax
  80093b:	e8 5b ff ff ff       	call   80089b <fstat>
  800940:	89 c6                	mov    %eax,%esi
	close(fd);
  800942:	89 1c 24             	mov    %ebx,(%esp)
  800945:	e8 fd fb ff ff       	call   800547 <close>
	return r;
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	89 f0                	mov    %esi,%eax
}
  80094f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	89 c6                	mov    %eax,%esi
  80095d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80095f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800966:	75 12                	jne    80097a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800968:	83 ec 0c             	sub    $0xc,%esp
  80096b:	6a 01                	push   $0x1
  80096d:	e8 8b 16 00 00       	call   801ffd <ipc_find_env>
  800972:	a3 00 40 80 00       	mov    %eax,0x804000
  800977:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80097a:	6a 07                	push   $0x7
  80097c:	68 00 50 80 00       	push   $0x805000
  800981:	56                   	push   %esi
  800982:	ff 35 00 40 80 00    	pushl  0x804000
  800988:	e8 21 16 00 00       	call   801fae <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80098d:	83 c4 0c             	add    $0xc,%esp
  800990:	6a 00                	push   $0x0
  800992:	53                   	push   %ebx
  800993:	6a 00                	push   $0x0
  800995:	e8 9e 15 00 00       	call   801f38 <ipc_recv>
}
  80099a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	b8 02 00 00 00       	mov    $0x2,%eax
  8009c4:	e8 8d ff ff ff       	call   800956 <fsipc>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e1:	b8 06 00 00 00       	mov    $0x6,%eax
  8009e6:	e8 6b ff ff ff       	call   800956 <fsipc>
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	53                   	push   %ebx
  8009f1:	83 ec 04             	sub    $0x4,%esp
  8009f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a02:	ba 00 00 00 00       	mov    $0x0,%edx
  800a07:	b8 05 00 00 00       	mov    $0x5,%eax
  800a0c:	e8 45 ff ff ff       	call   800956 <fsipc>
  800a11:	85 c0                	test   %eax,%eax
  800a13:	78 2c                	js     800a41 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a15:	83 ec 08             	sub    $0x8,%esp
  800a18:	68 00 50 80 00       	push   $0x805000
  800a1d:	53                   	push   %ebx
  800a1e:	e8 5f 11 00 00       	call   801b82 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a23:	a1 80 50 80 00       	mov    0x805080,%eax
  800a28:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a2e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a33:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a44:	c9                   	leave  
  800a45:	c3                   	ret    

00800a46 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	53                   	push   %ebx
  800a4a:	83 ec 08             	sub    $0x8,%esp
  800a4d:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a50:	8b 55 08             	mov    0x8(%ebp),%edx
  800a53:	8b 52 0c             	mov    0xc(%edx),%edx
  800a56:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a5c:	a3 04 50 80 00       	mov    %eax,0x805004
  800a61:	3d 08 50 80 00       	cmp    $0x805008,%eax
  800a66:	bb 08 50 80 00       	mov    $0x805008,%ebx
  800a6b:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a6e:	53                   	push   %ebx
  800a6f:	ff 75 0c             	pushl  0xc(%ebp)
  800a72:	68 08 50 80 00       	push   $0x805008
  800a77:	e8 98 12 00 00       	call   801d14 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a81:	b8 04 00 00 00       	mov    $0x4,%eax
  800a86:	e8 cb fe ff ff       	call   800956 <fsipc>
  800a8b:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  800a8e:	85 c0                	test   %eax,%eax
  800a90:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  800a93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a96:	c9                   	leave  
  800a97:	c3                   	ret    

00800a98 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aab:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab6:	b8 03 00 00 00       	mov    $0x3,%eax
  800abb:	e8 96 fe ff ff       	call   800956 <fsipc>
  800ac0:	89 c3                	mov    %eax,%ebx
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	78 4b                	js     800b11 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ac6:	39 c6                	cmp    %eax,%esi
  800ac8:	73 16                	jae    800ae0 <devfile_read+0x48>
  800aca:	68 e8 23 80 00       	push   $0x8023e8
  800acf:	68 ef 23 80 00       	push   $0x8023ef
  800ad4:	6a 7c                	push   $0x7c
  800ad6:	68 04 24 80 00       	push   $0x802404
  800adb:	e8 24 0a 00 00       	call   801504 <_panic>
	assert(r <= PGSIZE);
  800ae0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ae5:	7e 16                	jle    800afd <devfile_read+0x65>
  800ae7:	68 0f 24 80 00       	push   $0x80240f
  800aec:	68 ef 23 80 00       	push   $0x8023ef
  800af1:	6a 7d                	push   $0x7d
  800af3:	68 04 24 80 00       	push   $0x802404
  800af8:	e8 07 0a 00 00       	call   801504 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800afd:	83 ec 04             	sub    $0x4,%esp
  800b00:	50                   	push   %eax
  800b01:	68 00 50 80 00       	push   $0x805000
  800b06:	ff 75 0c             	pushl  0xc(%ebp)
  800b09:	e8 06 12 00 00       	call   801d14 <memmove>
	return r;
  800b0e:	83 c4 10             	add    $0x10,%esp
}
  800b11:	89 d8                	mov    %ebx,%eax
  800b13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 20             	sub    $0x20,%esp
  800b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b24:	53                   	push   %ebx
  800b25:	e8 1f 10 00 00       	call   801b49 <strlen>
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b32:	7f 67                	jg     800b9b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b34:	83 ec 0c             	sub    $0xc,%esp
  800b37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b3a:	50                   	push   %eax
  800b3b:	e8 8e f8 ff ff       	call   8003ce <fd_alloc>
  800b40:	83 c4 10             	add    $0x10,%esp
		return r;
  800b43:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	78 57                	js     800ba0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b49:	83 ec 08             	sub    $0x8,%esp
  800b4c:	53                   	push   %ebx
  800b4d:	68 00 50 80 00       	push   $0x805000
  800b52:	e8 2b 10 00 00       	call   801b82 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b62:	b8 01 00 00 00       	mov    $0x1,%eax
  800b67:	e8 ea fd ff ff       	call   800956 <fsipc>
  800b6c:	89 c3                	mov    %eax,%ebx
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	85 c0                	test   %eax,%eax
  800b73:	79 14                	jns    800b89 <open+0x6f>
		fd_close(fd, 0);
  800b75:	83 ec 08             	sub    $0x8,%esp
  800b78:	6a 00                	push   $0x0
  800b7a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7d:	e8 44 f9 ff ff       	call   8004c6 <fd_close>
		return r;
  800b82:	83 c4 10             	add    $0x10,%esp
  800b85:	89 da                	mov    %ebx,%edx
  800b87:	eb 17                	jmp    800ba0 <open+0x86>
	}

	return fd2num(fd);
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b8f:	e8 13 f8 ff ff       	call   8003a7 <fd2num>
  800b94:	89 c2                	mov    %eax,%edx
  800b96:	83 c4 10             	add    $0x10,%esp
  800b99:	eb 05                	jmp    800ba0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b9b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ba0:	89 d0                	mov    %edx,%eax
  800ba2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb7:	e8 9a fd ff ff       	call   800956 <fsipc>
}
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bc6:	83 ec 0c             	sub    $0xc,%esp
  800bc9:	ff 75 08             	pushl  0x8(%ebp)
  800bcc:	e8 e6 f7 ff ff       	call   8003b7 <fd2data>
  800bd1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bd3:	83 c4 08             	add    $0x8,%esp
  800bd6:	68 1b 24 80 00       	push   $0x80241b
  800bdb:	53                   	push   %ebx
  800bdc:	e8 a1 0f 00 00       	call   801b82 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800be1:	8b 46 04             	mov    0x4(%esi),%eax
  800be4:	2b 06                	sub    (%esi),%eax
  800be6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bf3:	00 00 00 
	stat->st_dev = &devpipe;
  800bf6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bfd:	30 80 00 
	return 0;
}
  800c00:	b8 00 00 00 00       	mov    $0x0,%eax
  800c05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c16:	53                   	push   %ebx
  800c17:	6a 00                	push   $0x0
  800c19:	e8 d7 f5 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c1e:	89 1c 24             	mov    %ebx,(%esp)
  800c21:	e8 91 f7 ff ff       	call   8003b7 <fd2data>
  800c26:	83 c4 08             	add    $0x8,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 00                	push   $0x0
  800c2c:	e8 c4 f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800c31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 1c             	sub    $0x1c,%esp
  800c3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c42:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c44:	a1 08 40 80 00       	mov    0x804008,%eax
  800c49:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	ff 75 e0             	pushl  -0x20(%ebp)
  800c52:	e8 df 13 00 00       	call   802036 <pageref>
  800c57:	89 c3                	mov    %eax,%ebx
  800c59:	89 3c 24             	mov    %edi,(%esp)
  800c5c:	e8 d5 13 00 00       	call   802036 <pageref>
  800c61:	83 c4 10             	add    $0x10,%esp
  800c64:	39 c3                	cmp    %eax,%ebx
  800c66:	0f 94 c1             	sete   %cl
  800c69:	0f b6 c9             	movzbl %cl,%ecx
  800c6c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c6f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c75:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c78:	39 ce                	cmp    %ecx,%esi
  800c7a:	74 1b                	je     800c97 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c7c:	39 c3                	cmp    %eax,%ebx
  800c7e:	75 c4                	jne    800c44 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c80:	8b 42 58             	mov    0x58(%edx),%eax
  800c83:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c86:	50                   	push   %eax
  800c87:	56                   	push   %esi
  800c88:	68 22 24 80 00       	push   $0x802422
  800c8d:	e8 4b 09 00 00       	call   8015dd <cprintf>
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	eb ad                	jmp    800c44 <_pipeisclosed+0xe>
	}
}
  800c97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 28             	sub    $0x28,%esp
  800cab:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800cae:	56                   	push   %esi
  800caf:	e8 03 f7 ff ff       	call   8003b7 <fd2data>
  800cb4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb6:	83 c4 10             	add    $0x10,%esp
  800cb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbe:	eb 4b                	jmp    800d0b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cc0:	89 da                	mov    %ebx,%edx
  800cc2:	89 f0                	mov    %esi,%eax
  800cc4:	e8 6d ff ff ff       	call   800c36 <_pipeisclosed>
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	75 48                	jne    800d15 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ccd:	e8 7f f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cd2:	8b 43 04             	mov    0x4(%ebx),%eax
  800cd5:	8b 0b                	mov    (%ebx),%ecx
  800cd7:	8d 51 20             	lea    0x20(%ecx),%edx
  800cda:	39 d0                	cmp    %edx,%eax
  800cdc:	73 e2                	jae    800cc0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ce5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ce8:	89 c2                	mov    %eax,%edx
  800cea:	c1 fa 1f             	sar    $0x1f,%edx
  800ced:	89 d1                	mov    %edx,%ecx
  800cef:	c1 e9 1b             	shr    $0x1b,%ecx
  800cf2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cf5:	83 e2 1f             	and    $0x1f,%edx
  800cf8:	29 ca                	sub    %ecx,%edx
  800cfa:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cfe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d02:	83 c0 01             	add    $0x1,%eax
  800d05:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d08:	83 c7 01             	add    $0x1,%edi
  800d0b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d0e:	75 c2                	jne    800cd2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d10:	8b 45 10             	mov    0x10(%ebp),%eax
  800d13:	eb 05                	jmp    800d1a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d15:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 18             	sub    $0x18,%esp
  800d2b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d2e:	57                   	push   %edi
  800d2f:	e8 83 f6 ff ff       	call   8003b7 <fd2data>
  800d34:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d36:	83 c4 10             	add    $0x10,%esp
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	eb 3d                	jmp    800d7d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d40:	85 db                	test   %ebx,%ebx
  800d42:	74 04                	je     800d48 <devpipe_read+0x26>
				return i;
  800d44:	89 d8                	mov    %ebx,%eax
  800d46:	eb 44                	jmp    800d8c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d48:	89 f2                	mov    %esi,%edx
  800d4a:	89 f8                	mov    %edi,%eax
  800d4c:	e8 e5 fe ff ff       	call   800c36 <_pipeisclosed>
  800d51:	85 c0                	test   %eax,%eax
  800d53:	75 32                	jne    800d87 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d55:	e8 f7 f3 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d5a:	8b 06                	mov    (%esi),%eax
  800d5c:	3b 46 04             	cmp    0x4(%esi),%eax
  800d5f:	74 df                	je     800d40 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d61:	99                   	cltd   
  800d62:	c1 ea 1b             	shr    $0x1b,%edx
  800d65:	01 d0                	add    %edx,%eax
  800d67:	83 e0 1f             	and    $0x1f,%eax
  800d6a:	29 d0                	sub    %edx,%eax
  800d6c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d77:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d7a:	83 c3 01             	add    $0x1,%ebx
  800d7d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d80:	75 d8                	jne    800d5a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d82:	8b 45 10             	mov    0x10(%ebp),%eax
  800d85:	eb 05                	jmp    800d8c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d87:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d9f:	50                   	push   %eax
  800da0:	e8 29 f6 ff ff       	call   8003ce <fd_alloc>
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	89 c2                	mov    %eax,%edx
  800daa:	85 c0                	test   %eax,%eax
  800dac:	0f 88 2c 01 00 00    	js     800ede <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db2:	83 ec 04             	sub    $0x4,%esp
  800db5:	68 07 04 00 00       	push   $0x407
  800dba:	ff 75 f4             	pushl  -0xc(%ebp)
  800dbd:	6a 00                	push   $0x0
  800dbf:	e8 ac f3 ff ff       	call   800170 <sys_page_alloc>
  800dc4:	83 c4 10             	add    $0x10,%esp
  800dc7:	89 c2                	mov    %eax,%edx
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	0f 88 0d 01 00 00    	js     800ede <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd7:	50                   	push   %eax
  800dd8:	e8 f1 f5 ff ff       	call   8003ce <fd_alloc>
  800ddd:	89 c3                	mov    %eax,%ebx
  800ddf:	83 c4 10             	add    $0x10,%esp
  800de2:	85 c0                	test   %eax,%eax
  800de4:	0f 88 e2 00 00 00    	js     800ecc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dea:	83 ec 04             	sub    $0x4,%esp
  800ded:	68 07 04 00 00       	push   $0x407
  800df2:	ff 75 f0             	pushl  -0x10(%ebp)
  800df5:	6a 00                	push   $0x0
  800df7:	e8 74 f3 ff ff       	call   800170 <sys_page_alloc>
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	83 c4 10             	add    $0x10,%esp
  800e01:	85 c0                	test   %eax,%eax
  800e03:	0f 88 c3 00 00 00    	js     800ecc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e0f:	e8 a3 f5 ff ff       	call   8003b7 <fd2data>
  800e14:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e16:	83 c4 0c             	add    $0xc,%esp
  800e19:	68 07 04 00 00       	push   $0x407
  800e1e:	50                   	push   %eax
  800e1f:	6a 00                	push   $0x0
  800e21:	e8 4a f3 ff ff       	call   800170 <sys_page_alloc>
  800e26:	89 c3                	mov    %eax,%ebx
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	0f 88 89 00 00 00    	js     800ebc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	ff 75 f0             	pushl  -0x10(%ebp)
  800e39:	e8 79 f5 ff ff       	call   8003b7 <fd2data>
  800e3e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e45:	50                   	push   %eax
  800e46:	6a 00                	push   $0x0
  800e48:	56                   	push   %esi
  800e49:	6a 00                	push   $0x0
  800e4b:	e8 63 f3 ff ff       	call   8001b3 <sys_page_map>
  800e50:	89 c3                	mov    %eax,%ebx
  800e52:	83 c4 20             	add    $0x20,%esp
  800e55:	85 c0                	test   %eax,%eax
  800e57:	78 55                	js     800eae <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e59:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e62:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e67:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e6e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e77:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	ff 75 f4             	pushl  -0xc(%ebp)
  800e89:	e8 19 f5 ff ff       	call   8003a7 <fd2num>
  800e8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e91:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e93:	83 c4 04             	add    $0x4,%esp
  800e96:	ff 75 f0             	pushl  -0x10(%ebp)
  800e99:	e8 09 f5 ff ff       	call   8003a7 <fd2num>
  800e9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eac:	eb 30                	jmp    800ede <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800eae:	83 ec 08             	sub    $0x8,%esp
  800eb1:	56                   	push   %esi
  800eb2:	6a 00                	push   $0x0
  800eb4:	e8 3c f3 ff ff       	call   8001f5 <sys_page_unmap>
  800eb9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ebc:	83 ec 08             	sub    $0x8,%esp
  800ebf:	ff 75 f0             	pushl  -0x10(%ebp)
  800ec2:	6a 00                	push   $0x0
  800ec4:	e8 2c f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ec9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ecc:	83 ec 08             	sub    $0x8,%esp
  800ecf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed2:	6a 00                	push   $0x0
  800ed4:	e8 1c f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ede:	89 d0                	mov    %edx,%eax
  800ee0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef0:	50                   	push   %eax
  800ef1:	ff 75 08             	pushl  0x8(%ebp)
  800ef4:	e8 24 f5 ff ff       	call   80041d <fd_lookup>
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	85 c0                	test   %eax,%eax
  800efe:	78 18                	js     800f18 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800f00:	83 ec 0c             	sub    $0xc,%esp
  800f03:	ff 75 f4             	pushl  -0xc(%ebp)
  800f06:	e8 ac f4 ff ff       	call   8003b7 <fd2data>
	return _pipeisclosed(fd, p);
  800f0b:	89 c2                	mov    %eax,%edx
  800f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f10:	e8 21 fd ff ff       	call   800c36 <_pipeisclosed>
  800f15:	83 c4 10             	add    $0x10,%esp
}
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800f20:	68 3a 24 80 00       	push   $0x80243a
  800f25:	ff 75 0c             	pushl  0xc(%ebp)
  800f28:	e8 55 0c 00 00       	call   801b82 <strcpy>
	return 0;
}
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	53                   	push   %ebx
  800f38:	83 ec 10             	sub    $0x10,%esp
  800f3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800f3e:	53                   	push   %ebx
  800f3f:	e8 f2 10 00 00       	call   802036 <pageref>
  800f44:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800f47:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800f4c:	83 f8 01             	cmp    $0x1,%eax
  800f4f:	75 10                	jne    800f61 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800f51:	83 ec 0c             	sub    $0xc,%esp
  800f54:	ff 73 0c             	pushl  0xc(%ebx)
  800f57:	e8 c0 02 00 00       	call   80121c <nsipc_close>
  800f5c:	89 c2                	mov    %eax,%edx
  800f5e:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f61:	89 d0                	mov    %edx,%eax
  800f63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f6e:	6a 00                	push   $0x0
  800f70:	ff 75 10             	pushl  0x10(%ebp)
  800f73:	ff 75 0c             	pushl  0xc(%ebp)
  800f76:	8b 45 08             	mov    0x8(%ebp),%eax
  800f79:	ff 70 0c             	pushl  0xc(%eax)
  800f7c:	e8 78 03 00 00       	call   8012f9 <nsipc_send>
}
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f89:	6a 00                	push   $0x0
  800f8b:	ff 75 10             	pushl  0x10(%ebp)
  800f8e:	ff 75 0c             	pushl  0xc(%ebp)
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
  800f94:	ff 70 0c             	pushl  0xc(%eax)
  800f97:	e8 f1 02 00 00       	call   80128d <nsipc_recv>
}
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800fa4:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fa7:	52                   	push   %edx
  800fa8:	50                   	push   %eax
  800fa9:	e8 6f f4 ff ff       	call   80041d <fd_lookup>
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	78 17                	js     800fcc <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb8:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  800fbe:	39 08                	cmp    %ecx,(%eax)
  800fc0:	75 05                	jne    800fc7 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800fc2:	8b 40 0c             	mov    0xc(%eax),%eax
  800fc5:	eb 05                	jmp    800fcc <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800fc7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 1c             	sub    $0x1c,%esp
  800fd6:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800fd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	e8 ed f3 ff ff       	call   8003ce <fd_alloc>
  800fe1:	89 c3                	mov    %eax,%ebx
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 1b                	js     801005 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800fea:	83 ec 04             	sub    $0x4,%esp
  800fed:	68 07 04 00 00       	push   $0x407
  800ff2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 74 f1 ff ff       	call   800170 <sys_page_alloc>
  800ffc:	89 c3                	mov    %eax,%ebx
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	79 10                	jns    801015 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	56                   	push   %esi
  801009:	e8 0e 02 00 00       	call   80121c <nsipc_close>
		return r;
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	89 d8                	mov    %ebx,%eax
  801013:	eb 24                	jmp    801039 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801015:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801023:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80102a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	50                   	push   %eax
  801031:	e8 71 f3 ff ff       	call   8003a7 <fd2num>
  801036:	83 c4 10             	add    $0x10,%esp
}
  801039:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801046:	8b 45 08             	mov    0x8(%ebp),%eax
  801049:	e8 50 ff ff ff       	call   800f9e <fd2sockid>
		return r;
  80104e:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801050:	85 c0                	test   %eax,%eax
  801052:	78 1f                	js     801073 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801054:	83 ec 04             	sub    $0x4,%esp
  801057:	ff 75 10             	pushl  0x10(%ebp)
  80105a:	ff 75 0c             	pushl  0xc(%ebp)
  80105d:	50                   	push   %eax
  80105e:	e8 12 01 00 00       	call   801175 <nsipc_accept>
  801063:	83 c4 10             	add    $0x10,%esp
		return r;
  801066:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801068:	85 c0                	test   %eax,%eax
  80106a:	78 07                	js     801073 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80106c:	e8 5d ff ff ff       	call   800fce <alloc_sockfd>
  801071:	89 c1                	mov    %eax,%ecx
}
  801073:	89 c8                	mov    %ecx,%eax
  801075:	c9                   	leave  
  801076:	c3                   	ret    

00801077 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80107d:	8b 45 08             	mov    0x8(%ebp),%eax
  801080:	e8 19 ff ff ff       	call   800f9e <fd2sockid>
  801085:	85 c0                	test   %eax,%eax
  801087:	78 12                	js     80109b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801089:	83 ec 04             	sub    $0x4,%esp
  80108c:	ff 75 10             	pushl  0x10(%ebp)
  80108f:	ff 75 0c             	pushl  0xc(%ebp)
  801092:	50                   	push   %eax
  801093:	e8 2d 01 00 00       	call   8011c5 <nsipc_bind>
  801098:	83 c4 10             	add    $0x10,%esp
}
  80109b:	c9                   	leave  
  80109c:	c3                   	ret    

0080109d <shutdown>:

int
shutdown(int s, int how)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a6:	e8 f3 fe ff ff       	call   800f9e <fd2sockid>
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	78 0f                	js     8010be <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8010af:	83 ec 08             	sub    $0x8,%esp
  8010b2:	ff 75 0c             	pushl  0xc(%ebp)
  8010b5:	50                   	push   %eax
  8010b6:	e8 3f 01 00 00       	call   8011fa <nsipc_shutdown>
  8010bb:	83 c4 10             	add    $0x10,%esp
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	e8 d0 fe ff ff       	call   800f9e <fd2sockid>
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	78 12                	js     8010e4 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8010d2:	83 ec 04             	sub    $0x4,%esp
  8010d5:	ff 75 10             	pushl  0x10(%ebp)
  8010d8:	ff 75 0c             	pushl  0xc(%ebp)
  8010db:	50                   	push   %eax
  8010dc:	e8 55 01 00 00       	call   801236 <nsipc_connect>
  8010e1:	83 c4 10             	add    $0x10,%esp
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <listen>:

int
listen(int s, int backlog)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	e8 aa fe ff ff       	call   800f9e <fd2sockid>
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 0f                	js     801107 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8010f8:	83 ec 08             	sub    $0x8,%esp
  8010fb:	ff 75 0c             	pushl  0xc(%ebp)
  8010fe:	50                   	push   %eax
  8010ff:	e8 67 01 00 00       	call   80126b <nsipc_listen>
  801104:	83 c4 10             	add    $0x10,%esp
}
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80110f:	ff 75 10             	pushl  0x10(%ebp)
  801112:	ff 75 0c             	pushl  0xc(%ebp)
  801115:	ff 75 08             	pushl  0x8(%ebp)
  801118:	e8 3a 02 00 00       	call   801357 <nsipc_socket>
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	78 05                	js     801129 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801124:	e8 a5 fe ff ff       	call   800fce <alloc_sockfd>
}
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	53                   	push   %ebx
  80112f:	83 ec 04             	sub    $0x4,%esp
  801132:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801134:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80113b:	75 12                	jne    80114f <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80113d:	83 ec 0c             	sub    $0xc,%esp
  801140:	6a 02                	push   $0x2
  801142:	e8 b6 0e 00 00       	call   801ffd <ipc_find_env>
  801147:	a3 04 40 80 00       	mov    %eax,0x804004
  80114c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80114f:	6a 07                	push   $0x7
  801151:	68 00 60 80 00       	push   $0x806000
  801156:	53                   	push   %ebx
  801157:	ff 35 04 40 80 00    	pushl  0x804004
  80115d:	e8 4c 0e 00 00       	call   801fae <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801162:	83 c4 0c             	add    $0xc,%esp
  801165:	6a 00                	push   $0x0
  801167:	6a 00                	push   $0x0
  801169:	6a 00                	push   $0x0
  80116b:	e8 c8 0d 00 00       	call   801f38 <ipc_recv>
}
  801170:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801173:	c9                   	leave  
  801174:	c3                   	ret    

00801175 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	56                   	push   %esi
  801179:	53                   	push   %ebx
  80117a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80117d:	8b 45 08             	mov    0x8(%ebp),%eax
  801180:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801185:	8b 06                	mov    (%esi),%eax
  801187:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80118c:	b8 01 00 00 00       	mov    $0x1,%eax
  801191:	e8 95 ff ff ff       	call   80112b <nsipc>
  801196:	89 c3                	mov    %eax,%ebx
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 20                	js     8011bc <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80119c:	83 ec 04             	sub    $0x4,%esp
  80119f:	ff 35 10 60 80 00    	pushl  0x806010
  8011a5:	68 00 60 80 00       	push   $0x806000
  8011aa:	ff 75 0c             	pushl  0xc(%ebp)
  8011ad:	e8 62 0b 00 00       	call   801d14 <memmove>
		*addrlen = ret->ret_addrlen;
  8011b2:	a1 10 60 80 00       	mov    0x806010,%eax
  8011b7:	89 06                	mov    %eax,(%esi)
  8011b9:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8011bc:	89 d8                	mov    %ebx,%eax
  8011be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	53                   	push   %ebx
  8011c9:	83 ec 08             	sub    $0x8,%esp
  8011cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8011cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8011d7:	53                   	push   %ebx
  8011d8:	ff 75 0c             	pushl  0xc(%ebp)
  8011db:	68 04 60 80 00       	push   $0x806004
  8011e0:	e8 2f 0b 00 00       	call   801d14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8011e5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8011eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8011f0:	e8 36 ff ff ff       	call   80112b <nsipc>
}
  8011f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801200:	8b 45 08             	mov    0x8(%ebp),%eax
  801203:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801210:	b8 03 00 00 00       	mov    $0x3,%eax
  801215:	e8 11 ff ff ff       	call   80112b <nsipc>
}
  80121a:	c9                   	leave  
  80121b:	c3                   	ret    

0080121c <nsipc_close>:

int
nsipc_close(int s)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801222:	8b 45 08             	mov    0x8(%ebp),%eax
  801225:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80122a:	b8 04 00 00 00       	mov    $0x4,%eax
  80122f:	e8 f7 fe ff ff       	call   80112b <nsipc>
}
  801234:	c9                   	leave  
  801235:	c3                   	ret    

00801236 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	53                   	push   %ebx
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801240:	8b 45 08             	mov    0x8(%ebp),%eax
  801243:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801248:	53                   	push   %ebx
  801249:	ff 75 0c             	pushl  0xc(%ebp)
  80124c:	68 04 60 80 00       	push   $0x806004
  801251:	e8 be 0a 00 00       	call   801d14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801256:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80125c:	b8 05 00 00 00       	mov    $0x5,%eax
  801261:	e8 c5 fe ff ff       	call   80112b <nsipc>
}
  801266:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801269:	c9                   	leave  
  80126a:	c3                   	ret    

0080126b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801271:	8b 45 08             	mov    0x8(%ebp),%eax
  801274:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801279:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801281:	b8 06 00 00 00       	mov    $0x6,%eax
  801286:	e8 a0 fe ff ff       	call   80112b <nsipc>
}
  80128b:	c9                   	leave  
  80128c:	c3                   	ret    

0080128d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	56                   	push   %esi
  801291:	53                   	push   %ebx
  801292:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801295:	8b 45 08             	mov    0x8(%ebp),%eax
  801298:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80129d:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8012a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a6:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8012ab:	b8 07 00 00 00       	mov    $0x7,%eax
  8012b0:	e8 76 fe ff ff       	call   80112b <nsipc>
  8012b5:	89 c3                	mov    %eax,%ebx
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	78 35                	js     8012f0 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8012bb:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8012c0:	7f 04                	jg     8012c6 <nsipc_recv+0x39>
  8012c2:	39 c6                	cmp    %eax,%esi
  8012c4:	7d 16                	jge    8012dc <nsipc_recv+0x4f>
  8012c6:	68 46 24 80 00       	push   $0x802446
  8012cb:	68 ef 23 80 00       	push   $0x8023ef
  8012d0:	6a 62                	push   $0x62
  8012d2:	68 5b 24 80 00       	push   $0x80245b
  8012d7:	e8 28 02 00 00       	call   801504 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8012dc:	83 ec 04             	sub    $0x4,%esp
  8012df:	50                   	push   %eax
  8012e0:	68 00 60 80 00       	push   $0x806000
  8012e5:	ff 75 0c             	pushl  0xc(%ebp)
  8012e8:	e8 27 0a 00 00       	call   801d14 <memmove>
  8012ed:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8012f0:	89 d8                	mov    %ebx,%eax
  8012f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f5:	5b                   	pop    %ebx
  8012f6:	5e                   	pop    %esi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 04             	sub    $0x4,%esp
  801300:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801303:	8b 45 08             	mov    0x8(%ebp),%eax
  801306:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80130b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801311:	7e 16                	jle    801329 <nsipc_send+0x30>
  801313:	68 67 24 80 00       	push   $0x802467
  801318:	68 ef 23 80 00       	push   $0x8023ef
  80131d:	6a 6d                	push   $0x6d
  80131f:	68 5b 24 80 00       	push   $0x80245b
  801324:	e8 db 01 00 00       	call   801504 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801329:	83 ec 04             	sub    $0x4,%esp
  80132c:	53                   	push   %ebx
  80132d:	ff 75 0c             	pushl  0xc(%ebp)
  801330:	68 0c 60 80 00       	push   $0x80600c
  801335:	e8 da 09 00 00       	call   801d14 <memmove>
	nsipcbuf.send.req_size = size;
  80133a:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801340:	8b 45 14             	mov    0x14(%ebp),%eax
  801343:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801348:	b8 08 00 00 00       	mov    $0x8,%eax
  80134d:	e8 d9 fd ff ff       	call   80112b <nsipc>
}
  801352:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80135d:	8b 45 08             	mov    0x8(%ebp),%eax
  801360:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801365:	8b 45 0c             	mov    0xc(%ebp),%eax
  801368:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80136d:	8b 45 10             	mov    0x10(%ebp),%eax
  801370:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801375:	b8 09 00 00 00       	mov    $0x9,%eax
  80137a:	e8 ac fd ff ff       	call   80112b <nsipc>
}
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801384:	b8 00 00 00 00       	mov    $0x0,%eax
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    

0080138b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801391:	68 73 24 80 00       	push   $0x802473
  801396:	ff 75 0c             	pushl  0xc(%ebp)
  801399:	e8 e4 07 00 00       	call   801b82 <strcpy>
	return 0;
}
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	57                   	push   %edi
  8013a9:	56                   	push   %esi
  8013aa:	53                   	push   %ebx
  8013ab:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013bc:	eb 2d                	jmp    8013eb <devcons_write+0x46>
		m = n - tot;
  8013be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013c1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013c3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013c6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013cb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013ce:	83 ec 04             	sub    $0x4,%esp
  8013d1:	53                   	push   %ebx
  8013d2:	03 45 0c             	add    0xc(%ebp),%eax
  8013d5:	50                   	push   %eax
  8013d6:	57                   	push   %edi
  8013d7:	e8 38 09 00 00       	call   801d14 <memmove>
		sys_cputs(buf, m);
  8013dc:	83 c4 08             	add    $0x8,%esp
  8013df:	53                   	push   %ebx
  8013e0:	57                   	push   %edi
  8013e1:	e8 ce ec ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013e6:	01 de                	add    %ebx,%esi
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	89 f0                	mov    %esi,%eax
  8013ed:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013f0:	72 cc                	jb     8013be <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5e                   	pop    %esi
  8013f7:	5f                   	pop    %edi
  8013f8:	5d                   	pop    %ebp
  8013f9:	c3                   	ret    

008013fa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	83 ec 08             	sub    $0x8,%esp
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801405:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801409:	74 2a                	je     801435 <devcons_read+0x3b>
  80140b:	eb 05                	jmp    801412 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80140d:	e8 3f ed ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801412:	e8 bb ec ff ff       	call   8000d2 <sys_cgetc>
  801417:	85 c0                	test   %eax,%eax
  801419:	74 f2                	je     80140d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 16                	js     801435 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80141f:	83 f8 04             	cmp    $0x4,%eax
  801422:	74 0c                	je     801430 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801424:	8b 55 0c             	mov    0xc(%ebp),%edx
  801427:	88 02                	mov    %al,(%edx)
	return 1;
  801429:	b8 01 00 00 00       	mov    $0x1,%eax
  80142e:	eb 05                	jmp    801435 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801430:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80143d:	8b 45 08             	mov    0x8(%ebp),%eax
  801440:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801443:	6a 01                	push   $0x1
  801445:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	e8 66 ec ff ff       	call   8000b4 <sys_cputs>
}
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <getchar>:

int
getchar(void)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801459:	6a 01                	push   $0x1
  80145b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80145e:	50                   	push   %eax
  80145f:	6a 00                	push   $0x0
  801461:	e8 1d f2 ff ff       	call   800683 <read>
	if (r < 0)
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 0f                	js     80147c <getchar+0x29>
		return r;
	if (r < 1)
  80146d:	85 c0                	test   %eax,%eax
  80146f:	7e 06                	jle    801477 <getchar+0x24>
		return -E_EOF;
	return c;
  801471:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801475:	eb 05                	jmp    80147c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801477:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	ff 75 08             	pushl  0x8(%ebp)
  80148b:	e8 8d ef ff ff       	call   80041d <fd_lookup>
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	85 c0                	test   %eax,%eax
  801495:	78 11                	js     8014a8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801497:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014a0:	39 10                	cmp    %edx,(%eax)
  8014a2:	0f 94 c0             	sete   %al
  8014a5:	0f b6 c0             	movzbl %al,%eax
}
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <opencons>:

int
opencons(void)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b3:	50                   	push   %eax
  8014b4:	e8 15 ef ff ff       	call   8003ce <fd_alloc>
  8014b9:	83 c4 10             	add    $0x10,%esp
		return r;
  8014bc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 3e                	js     801500 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	68 07 04 00 00       	push   $0x407
  8014ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cd:	6a 00                	push   $0x0
  8014cf:	e8 9c ec ff ff       	call   800170 <sys_page_alloc>
  8014d4:	83 c4 10             	add    $0x10,%esp
		return r;
  8014d7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 23                	js     801500 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014dd:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014eb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014f2:	83 ec 0c             	sub    $0xc,%esp
  8014f5:	50                   	push   %eax
  8014f6:	e8 ac ee ff ff       	call   8003a7 <fd2num>
  8014fb:	89 c2                	mov    %eax,%edx
  8014fd:	83 c4 10             	add    $0x10,%esp
}
  801500:	89 d0                	mov    %edx,%eax
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	56                   	push   %esi
  801508:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801509:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80150c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801512:	e8 1b ec ff ff       	call   800132 <sys_getenvid>
  801517:	83 ec 0c             	sub    $0xc,%esp
  80151a:	ff 75 0c             	pushl  0xc(%ebp)
  80151d:	ff 75 08             	pushl  0x8(%ebp)
  801520:	56                   	push   %esi
  801521:	50                   	push   %eax
  801522:	68 80 24 80 00       	push   $0x802480
  801527:	e8 b1 00 00 00       	call   8015dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80152c:	83 c4 18             	add    $0x18,%esp
  80152f:	53                   	push   %ebx
  801530:	ff 75 10             	pushl  0x10(%ebp)
  801533:	e8 54 00 00 00       	call   80158c <vcprintf>
	cprintf("\n");
  801538:	c7 04 24 33 24 80 00 	movl   $0x802433,(%esp)
  80153f:	e8 99 00 00 00       	call   8015dd <cprintf>
  801544:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801547:	cc                   	int3   
  801548:	eb fd                	jmp    801547 <_panic+0x43>

0080154a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	53                   	push   %ebx
  80154e:	83 ec 04             	sub    $0x4,%esp
  801551:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801554:	8b 13                	mov    (%ebx),%edx
  801556:	8d 42 01             	lea    0x1(%edx),%eax
  801559:	89 03                	mov    %eax,(%ebx)
  80155b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80155e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801562:	3d ff 00 00 00       	cmp    $0xff,%eax
  801567:	75 1a                	jne    801583 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801569:	83 ec 08             	sub    $0x8,%esp
  80156c:	68 ff 00 00 00       	push   $0xff
  801571:	8d 43 08             	lea    0x8(%ebx),%eax
  801574:	50                   	push   %eax
  801575:	e8 3a eb ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  80157a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801580:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801583:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801587:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801595:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80159c:	00 00 00 
	b.cnt = 0;
  80159f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015a6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015a9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ac:	ff 75 08             	pushl  0x8(%ebp)
  8015af:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	68 4a 15 80 00       	push   $0x80154a
  8015bb:	e8 54 01 00 00       	call   801714 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015c0:	83 c4 08             	add    $0x8,%esp
  8015c3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015c9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015cf:	50                   	push   %eax
  8015d0:	e8 df ea ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8015d5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015e3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015e6:	50                   	push   %eax
  8015e7:	ff 75 08             	pushl  0x8(%ebp)
  8015ea:	e8 9d ff ff ff       	call   80158c <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ef:	c9                   	leave  
  8015f0:	c3                   	ret    

008015f1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	57                   	push   %edi
  8015f5:	56                   	push   %esi
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 1c             	sub    $0x1c,%esp
  8015fa:	89 c7                	mov    %eax,%edi
  8015fc:	89 d6                	mov    %edx,%esi
  8015fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801601:	8b 55 0c             	mov    0xc(%ebp),%edx
  801604:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801607:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80160a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80160d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801612:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801615:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801618:	39 d3                	cmp    %edx,%ebx
  80161a:	72 05                	jb     801621 <printnum+0x30>
  80161c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80161f:	77 45                	ja     801666 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801621:	83 ec 0c             	sub    $0xc,%esp
  801624:	ff 75 18             	pushl  0x18(%ebp)
  801627:	8b 45 14             	mov    0x14(%ebp),%eax
  80162a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80162d:	53                   	push   %ebx
  80162e:	ff 75 10             	pushl  0x10(%ebp)
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	ff 75 e4             	pushl  -0x1c(%ebp)
  801637:	ff 75 e0             	pushl  -0x20(%ebp)
  80163a:	ff 75 dc             	pushl  -0x24(%ebp)
  80163d:	ff 75 d8             	pushl  -0x28(%ebp)
  801640:	e8 3b 0a 00 00       	call   802080 <__udivdi3>
  801645:	83 c4 18             	add    $0x18,%esp
  801648:	52                   	push   %edx
  801649:	50                   	push   %eax
  80164a:	89 f2                	mov    %esi,%edx
  80164c:	89 f8                	mov    %edi,%eax
  80164e:	e8 9e ff ff ff       	call   8015f1 <printnum>
  801653:	83 c4 20             	add    $0x20,%esp
  801656:	eb 18                	jmp    801670 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	56                   	push   %esi
  80165c:	ff 75 18             	pushl  0x18(%ebp)
  80165f:	ff d7                	call   *%edi
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	eb 03                	jmp    801669 <printnum+0x78>
  801666:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801669:	83 eb 01             	sub    $0x1,%ebx
  80166c:	85 db                	test   %ebx,%ebx
  80166e:	7f e8                	jg     801658 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801670:	83 ec 08             	sub    $0x8,%esp
  801673:	56                   	push   %esi
  801674:	83 ec 04             	sub    $0x4,%esp
  801677:	ff 75 e4             	pushl  -0x1c(%ebp)
  80167a:	ff 75 e0             	pushl  -0x20(%ebp)
  80167d:	ff 75 dc             	pushl  -0x24(%ebp)
  801680:	ff 75 d8             	pushl  -0x28(%ebp)
  801683:	e8 28 0b 00 00       	call   8021b0 <__umoddi3>
  801688:	83 c4 14             	add    $0x14,%esp
  80168b:	0f be 80 a3 24 80 00 	movsbl 0x8024a3(%eax),%eax
  801692:	50                   	push   %eax
  801693:	ff d7                	call   *%edi
}
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169b:	5b                   	pop    %ebx
  80169c:	5e                   	pop    %esi
  80169d:	5f                   	pop    %edi
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016a3:	83 fa 01             	cmp    $0x1,%edx
  8016a6:	7e 0e                	jle    8016b6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016a8:	8b 10                	mov    (%eax),%edx
  8016aa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016ad:	89 08                	mov    %ecx,(%eax)
  8016af:	8b 02                	mov    (%edx),%eax
  8016b1:	8b 52 04             	mov    0x4(%edx),%edx
  8016b4:	eb 22                	jmp    8016d8 <getuint+0x38>
	else if (lflag)
  8016b6:	85 d2                	test   %edx,%edx
  8016b8:	74 10                	je     8016ca <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016ba:	8b 10                	mov    (%eax),%edx
  8016bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016bf:	89 08                	mov    %ecx,(%eax)
  8016c1:	8b 02                	mov    (%edx),%eax
  8016c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c8:	eb 0e                	jmp    8016d8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016ca:	8b 10                	mov    (%eax),%edx
  8016cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016cf:	89 08                	mov    %ecx,(%eax)
  8016d1:	8b 02                	mov    (%edx),%eax
  8016d3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016e0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016e4:	8b 10                	mov    (%eax),%edx
  8016e6:	3b 50 04             	cmp    0x4(%eax),%edx
  8016e9:	73 0a                	jae    8016f5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016eb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016ee:	89 08                	mov    %ecx,(%eax)
  8016f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f3:	88 02                	mov    %al,(%edx)
}
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016fd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801700:	50                   	push   %eax
  801701:	ff 75 10             	pushl  0x10(%ebp)
  801704:	ff 75 0c             	pushl  0xc(%ebp)
  801707:	ff 75 08             	pushl  0x8(%ebp)
  80170a:	e8 05 00 00 00       	call   801714 <vprintfmt>
	va_end(ap);
}
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	c9                   	leave  
  801713:	c3                   	ret    

00801714 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	57                   	push   %edi
  801718:	56                   	push   %esi
  801719:	53                   	push   %ebx
  80171a:	83 ec 2c             	sub    $0x2c,%esp
  80171d:	8b 75 08             	mov    0x8(%ebp),%esi
  801720:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801723:	8b 7d 10             	mov    0x10(%ebp),%edi
  801726:	eb 12                	jmp    80173a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801728:	85 c0                	test   %eax,%eax
  80172a:	0f 84 a9 03 00 00    	je     801ad9 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  801730:	83 ec 08             	sub    $0x8,%esp
  801733:	53                   	push   %ebx
  801734:	50                   	push   %eax
  801735:	ff d6                	call   *%esi
  801737:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80173a:	83 c7 01             	add    $0x1,%edi
  80173d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801741:	83 f8 25             	cmp    $0x25,%eax
  801744:	75 e2                	jne    801728 <vprintfmt+0x14>
  801746:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80174a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801751:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801758:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80175f:	ba 00 00 00 00       	mov    $0x0,%edx
  801764:	eb 07                	jmp    80176d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801766:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801769:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80176d:	8d 47 01             	lea    0x1(%edi),%eax
  801770:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801773:	0f b6 07             	movzbl (%edi),%eax
  801776:	0f b6 c8             	movzbl %al,%ecx
  801779:	83 e8 23             	sub    $0x23,%eax
  80177c:	3c 55                	cmp    $0x55,%al
  80177e:	0f 87 3a 03 00 00    	ja     801abe <vprintfmt+0x3aa>
  801784:	0f b6 c0             	movzbl %al,%eax
  801787:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  80178e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801791:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801795:	eb d6                	jmp    80176d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801797:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80179a:	b8 00 00 00 00       	mov    $0x0,%eax
  80179f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017a2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017a5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017a9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017ac:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017af:	83 fa 09             	cmp    $0x9,%edx
  8017b2:	77 39                	ja     8017ed <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017b4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017b7:	eb e9                	jmp    8017a2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017bc:	8d 48 04             	lea    0x4(%eax),%ecx
  8017bf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017c2:	8b 00                	mov    (%eax),%eax
  8017c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017ca:	eb 27                	jmp    8017f3 <vprintfmt+0xdf>
  8017cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017d6:	0f 49 c8             	cmovns %eax,%ecx
  8017d9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017df:	eb 8c                	jmp    80176d <vprintfmt+0x59>
  8017e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017e4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017eb:	eb 80                	jmp    80176d <vprintfmt+0x59>
  8017ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017f0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017f3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017f7:	0f 89 70 ff ff ff    	jns    80176d <vprintfmt+0x59>
				width = precision, precision = -1;
  8017fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801800:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801803:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80180a:	e9 5e ff ff ff       	jmp    80176d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80180f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801812:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801815:	e9 53 ff ff ff       	jmp    80176d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80181a:	8b 45 14             	mov    0x14(%ebp),%eax
  80181d:	8d 50 04             	lea    0x4(%eax),%edx
  801820:	89 55 14             	mov    %edx,0x14(%ebp)
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	53                   	push   %ebx
  801827:	ff 30                	pushl  (%eax)
  801829:	ff d6                	call   *%esi
			break;
  80182b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801831:	e9 04 ff ff ff       	jmp    80173a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801836:	8b 45 14             	mov    0x14(%ebp),%eax
  801839:	8d 50 04             	lea    0x4(%eax),%edx
  80183c:	89 55 14             	mov    %edx,0x14(%ebp)
  80183f:	8b 00                	mov    (%eax),%eax
  801841:	99                   	cltd   
  801842:	31 d0                	xor    %edx,%eax
  801844:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801846:	83 f8 0f             	cmp    $0xf,%eax
  801849:	7f 0b                	jg     801856 <vprintfmt+0x142>
  80184b:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  801852:	85 d2                	test   %edx,%edx
  801854:	75 18                	jne    80186e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801856:	50                   	push   %eax
  801857:	68 bb 24 80 00       	push   $0x8024bb
  80185c:	53                   	push   %ebx
  80185d:	56                   	push   %esi
  80185e:	e8 94 fe ff ff       	call   8016f7 <printfmt>
  801863:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801866:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801869:	e9 cc fe ff ff       	jmp    80173a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80186e:	52                   	push   %edx
  80186f:	68 01 24 80 00       	push   $0x802401
  801874:	53                   	push   %ebx
  801875:	56                   	push   %esi
  801876:	e8 7c fe ff ff       	call   8016f7 <printfmt>
  80187b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80187e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801881:	e9 b4 fe ff ff       	jmp    80173a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801886:	8b 45 14             	mov    0x14(%ebp),%eax
  801889:	8d 50 04             	lea    0x4(%eax),%edx
  80188c:	89 55 14             	mov    %edx,0x14(%ebp)
  80188f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801891:	85 ff                	test   %edi,%edi
  801893:	b8 b4 24 80 00       	mov    $0x8024b4,%eax
  801898:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80189b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80189f:	0f 8e 94 00 00 00    	jle    801939 <vprintfmt+0x225>
  8018a5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018a9:	0f 84 98 00 00 00    	je     801947 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	ff 75 d0             	pushl  -0x30(%ebp)
  8018b5:	57                   	push   %edi
  8018b6:	e8 a6 02 00 00       	call   801b61 <strnlen>
  8018bb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018be:	29 c1                	sub    %eax,%ecx
  8018c0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018c3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018c6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018cd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018d0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018d2:	eb 0f                	jmp    8018e3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	53                   	push   %ebx
  8018d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018db:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018dd:	83 ef 01             	sub    $0x1,%edi
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	85 ff                	test   %edi,%edi
  8018e5:	7f ed                	jg     8018d4 <vprintfmt+0x1c0>
  8018e7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018ea:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018ed:	85 c9                	test   %ecx,%ecx
  8018ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f4:	0f 49 c1             	cmovns %ecx,%eax
  8018f7:	29 c1                	sub    %eax,%ecx
  8018f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8018fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801902:	89 cb                	mov    %ecx,%ebx
  801904:	eb 4d                	jmp    801953 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801906:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80190a:	74 1b                	je     801927 <vprintfmt+0x213>
  80190c:	0f be c0             	movsbl %al,%eax
  80190f:	83 e8 20             	sub    $0x20,%eax
  801912:	83 f8 5e             	cmp    $0x5e,%eax
  801915:	76 10                	jbe    801927 <vprintfmt+0x213>
					putch('?', putdat);
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	ff 75 0c             	pushl  0xc(%ebp)
  80191d:	6a 3f                	push   $0x3f
  80191f:	ff 55 08             	call   *0x8(%ebp)
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	eb 0d                	jmp    801934 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	ff 75 0c             	pushl  0xc(%ebp)
  80192d:	52                   	push   %edx
  80192e:	ff 55 08             	call   *0x8(%ebp)
  801931:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801934:	83 eb 01             	sub    $0x1,%ebx
  801937:	eb 1a                	jmp    801953 <vprintfmt+0x23f>
  801939:	89 75 08             	mov    %esi,0x8(%ebp)
  80193c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80193f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801942:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801945:	eb 0c                	jmp    801953 <vprintfmt+0x23f>
  801947:	89 75 08             	mov    %esi,0x8(%ebp)
  80194a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80194d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801950:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801953:	83 c7 01             	add    $0x1,%edi
  801956:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80195a:	0f be d0             	movsbl %al,%edx
  80195d:	85 d2                	test   %edx,%edx
  80195f:	74 23                	je     801984 <vprintfmt+0x270>
  801961:	85 f6                	test   %esi,%esi
  801963:	78 a1                	js     801906 <vprintfmt+0x1f2>
  801965:	83 ee 01             	sub    $0x1,%esi
  801968:	79 9c                	jns    801906 <vprintfmt+0x1f2>
  80196a:	89 df                	mov    %ebx,%edi
  80196c:	8b 75 08             	mov    0x8(%ebp),%esi
  80196f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801972:	eb 18                	jmp    80198c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801974:	83 ec 08             	sub    $0x8,%esp
  801977:	53                   	push   %ebx
  801978:	6a 20                	push   $0x20
  80197a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80197c:	83 ef 01             	sub    $0x1,%edi
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	eb 08                	jmp    80198c <vprintfmt+0x278>
  801984:	89 df                	mov    %ebx,%edi
  801986:	8b 75 08             	mov    0x8(%ebp),%esi
  801989:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80198c:	85 ff                	test   %edi,%edi
  80198e:	7f e4                	jg     801974 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801990:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801993:	e9 a2 fd ff ff       	jmp    80173a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801998:	83 fa 01             	cmp    $0x1,%edx
  80199b:	7e 16                	jle    8019b3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80199d:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a0:	8d 50 08             	lea    0x8(%eax),%edx
  8019a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a6:	8b 50 04             	mov    0x4(%eax),%edx
  8019a9:	8b 00                	mov    (%eax),%eax
  8019ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019b1:	eb 32                	jmp    8019e5 <vprintfmt+0x2d1>
	else if (lflag)
  8019b3:	85 d2                	test   %edx,%edx
  8019b5:	74 18                	je     8019cf <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ba:	8d 50 04             	lea    0x4(%eax),%edx
  8019bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8019c0:	8b 00                	mov    (%eax),%eax
  8019c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c5:	89 c1                	mov    %eax,%ecx
  8019c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019cd:	eb 16                	jmp    8019e5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d2:	8d 50 04             	lea    0x4(%eax),%edx
  8019d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d8:	8b 00                	mov    (%eax),%eax
  8019da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019dd:	89 c1                	mov    %eax,%ecx
  8019df:	c1 f9 1f             	sar    $0x1f,%ecx
  8019e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019f4:	0f 89 90 00 00 00    	jns    801a8a <vprintfmt+0x376>
				putch('-', putdat);
  8019fa:	83 ec 08             	sub    $0x8,%esp
  8019fd:	53                   	push   %ebx
  8019fe:	6a 2d                	push   $0x2d
  801a00:	ff d6                	call   *%esi
				num = -(long long) num;
  801a02:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a05:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a08:	f7 d8                	neg    %eax
  801a0a:	83 d2 00             	adc    $0x0,%edx
  801a0d:	f7 da                	neg    %edx
  801a0f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a12:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a17:	eb 71                	jmp    801a8a <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a19:	8d 45 14             	lea    0x14(%ebp),%eax
  801a1c:	e8 7f fc ff ff       	call   8016a0 <getuint>
			base = 10;
  801a21:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a26:	eb 62                	jmp    801a8a <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a28:	8d 45 14             	lea    0x14(%ebp),%eax
  801a2b:	e8 70 fc ff ff       	call   8016a0 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801a37:	51                   	push   %ecx
  801a38:	ff 75 e0             	pushl  -0x20(%ebp)
  801a3b:	6a 08                	push   $0x8
  801a3d:	52                   	push   %edx
  801a3e:	50                   	push   %eax
  801a3f:	89 da                	mov    %ebx,%edx
  801a41:	89 f0                	mov    %esi,%eax
  801a43:	e8 a9 fb ff ff       	call   8015f1 <printnum>
			break;
  801a48:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a4b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  801a4e:	e9 e7 fc ff ff       	jmp    80173a <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a53:	83 ec 08             	sub    $0x8,%esp
  801a56:	53                   	push   %ebx
  801a57:	6a 30                	push   $0x30
  801a59:	ff d6                	call   *%esi
			putch('x', putdat);
  801a5b:	83 c4 08             	add    $0x8,%esp
  801a5e:	53                   	push   %ebx
  801a5f:	6a 78                	push   $0x78
  801a61:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a63:	8b 45 14             	mov    0x14(%ebp),%eax
  801a66:	8d 50 04             	lea    0x4(%eax),%edx
  801a69:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a6c:	8b 00                	mov    (%eax),%eax
  801a6e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a73:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a76:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a7b:	eb 0d                	jmp    801a8a <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a7d:	8d 45 14             	lea    0x14(%ebp),%eax
  801a80:	e8 1b fc ff ff       	call   8016a0 <getuint>
			base = 16;
  801a85:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a91:	57                   	push   %edi
  801a92:	ff 75 e0             	pushl  -0x20(%ebp)
  801a95:	51                   	push   %ecx
  801a96:	52                   	push   %edx
  801a97:	50                   	push   %eax
  801a98:	89 da                	mov    %ebx,%edx
  801a9a:	89 f0                	mov    %esi,%eax
  801a9c:	e8 50 fb ff ff       	call   8015f1 <printnum>
			break;
  801aa1:	83 c4 20             	add    $0x20,%esp
  801aa4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801aa7:	e9 8e fc ff ff       	jmp    80173a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801aac:	83 ec 08             	sub    $0x8,%esp
  801aaf:	53                   	push   %ebx
  801ab0:	51                   	push   %ecx
  801ab1:	ff d6                	call   *%esi
			break;
  801ab3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ab6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ab9:	e9 7c fc ff ff       	jmp    80173a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801abe:	83 ec 08             	sub    $0x8,%esp
  801ac1:	53                   	push   %ebx
  801ac2:	6a 25                	push   $0x25
  801ac4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	eb 03                	jmp    801ace <vprintfmt+0x3ba>
  801acb:	83 ef 01             	sub    $0x1,%edi
  801ace:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801ad2:	75 f7                	jne    801acb <vprintfmt+0x3b7>
  801ad4:	e9 61 fc ff ff       	jmp    80173a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5f                   	pop    %edi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	83 ec 18             	sub    $0x18,%esp
  801ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801af0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801af4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801af7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801afe:	85 c0                	test   %eax,%eax
  801b00:	74 26                	je     801b28 <vsnprintf+0x47>
  801b02:	85 d2                	test   %edx,%edx
  801b04:	7e 22                	jle    801b28 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b06:	ff 75 14             	pushl  0x14(%ebp)
  801b09:	ff 75 10             	pushl  0x10(%ebp)
  801b0c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b0f:	50                   	push   %eax
  801b10:	68 da 16 80 00       	push   $0x8016da
  801b15:	e8 fa fb ff ff       	call   801714 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b1d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	eb 05                	jmp    801b2d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b28:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b35:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b38:	50                   	push   %eax
  801b39:	ff 75 10             	pushl  0x10(%ebp)
  801b3c:	ff 75 0c             	pushl  0xc(%ebp)
  801b3f:	ff 75 08             	pushl  0x8(%ebp)
  801b42:	e8 9a ff ff ff       	call   801ae1 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b54:	eb 03                	jmp    801b59 <strlen+0x10>
		n++;
  801b56:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b59:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b5d:	75 f7                	jne    801b56 <strlen+0xd>
		n++;
	return n;
}
  801b5f:	5d                   	pop    %ebp
  801b60:	c3                   	ret    

00801b61 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b67:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6f:	eb 03                	jmp    801b74 <strnlen+0x13>
		n++;
  801b71:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b74:	39 c2                	cmp    %eax,%edx
  801b76:	74 08                	je     801b80 <strnlen+0x1f>
  801b78:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b7c:	75 f3                	jne    801b71 <strnlen+0x10>
  801b7e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b80:	5d                   	pop    %ebp
  801b81:	c3                   	ret    

00801b82 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	53                   	push   %ebx
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b8c:	89 c2                	mov    %eax,%edx
  801b8e:	83 c2 01             	add    $0x1,%edx
  801b91:	83 c1 01             	add    $0x1,%ecx
  801b94:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b98:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b9b:	84 db                	test   %bl,%bl
  801b9d:	75 ef                	jne    801b8e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b9f:	5b                   	pop    %ebx
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    

00801ba2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	53                   	push   %ebx
  801ba6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ba9:	53                   	push   %ebx
  801baa:	e8 9a ff ff ff       	call   801b49 <strlen>
  801baf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bb2:	ff 75 0c             	pushl  0xc(%ebp)
  801bb5:	01 d8                	add    %ebx,%eax
  801bb7:	50                   	push   %eax
  801bb8:	e8 c5 ff ff ff       	call   801b82 <strcpy>
	return dst;
}
  801bbd:	89 d8                	mov    %ebx,%eax
  801bbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc2:	c9                   	leave  
  801bc3:	c3                   	ret    

00801bc4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	56                   	push   %esi
  801bc8:	53                   	push   %ebx
  801bc9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcf:	89 f3                	mov    %esi,%ebx
  801bd1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bd4:	89 f2                	mov    %esi,%edx
  801bd6:	eb 0f                	jmp    801be7 <strncpy+0x23>
		*dst++ = *src;
  801bd8:	83 c2 01             	add    $0x1,%edx
  801bdb:	0f b6 01             	movzbl (%ecx),%eax
  801bde:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801be1:	80 39 01             	cmpb   $0x1,(%ecx)
  801be4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801be7:	39 da                	cmp    %ebx,%edx
  801be9:	75 ed                	jne    801bd8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801beb:	89 f0                	mov    %esi,%eax
  801bed:	5b                   	pop    %ebx
  801bee:	5e                   	pop    %esi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	56                   	push   %esi
  801bf5:	53                   	push   %ebx
  801bf6:	8b 75 08             	mov    0x8(%ebp),%esi
  801bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfc:	8b 55 10             	mov    0x10(%ebp),%edx
  801bff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c01:	85 d2                	test   %edx,%edx
  801c03:	74 21                	je     801c26 <strlcpy+0x35>
  801c05:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c09:	89 f2                	mov    %esi,%edx
  801c0b:	eb 09                	jmp    801c16 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c0d:	83 c2 01             	add    $0x1,%edx
  801c10:	83 c1 01             	add    $0x1,%ecx
  801c13:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c16:	39 c2                	cmp    %eax,%edx
  801c18:	74 09                	je     801c23 <strlcpy+0x32>
  801c1a:	0f b6 19             	movzbl (%ecx),%ebx
  801c1d:	84 db                	test   %bl,%bl
  801c1f:	75 ec                	jne    801c0d <strlcpy+0x1c>
  801c21:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c23:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c26:	29 f0                	sub    %esi,%eax
}
  801c28:	5b                   	pop    %ebx
  801c29:	5e                   	pop    %esi
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    

00801c2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c35:	eb 06                	jmp    801c3d <strcmp+0x11>
		p++, q++;
  801c37:	83 c1 01             	add    $0x1,%ecx
  801c3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c3d:	0f b6 01             	movzbl (%ecx),%eax
  801c40:	84 c0                	test   %al,%al
  801c42:	74 04                	je     801c48 <strcmp+0x1c>
  801c44:	3a 02                	cmp    (%edx),%al
  801c46:	74 ef                	je     801c37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c48:	0f b6 c0             	movzbl %al,%eax
  801c4b:	0f b6 12             	movzbl (%edx),%edx
  801c4e:	29 d0                	sub    %edx,%eax
}
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	53                   	push   %ebx
  801c56:	8b 45 08             	mov    0x8(%ebp),%eax
  801c59:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5c:	89 c3                	mov    %eax,%ebx
  801c5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c61:	eb 06                	jmp    801c69 <strncmp+0x17>
		n--, p++, q++;
  801c63:	83 c0 01             	add    $0x1,%eax
  801c66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c69:	39 d8                	cmp    %ebx,%eax
  801c6b:	74 15                	je     801c82 <strncmp+0x30>
  801c6d:	0f b6 08             	movzbl (%eax),%ecx
  801c70:	84 c9                	test   %cl,%cl
  801c72:	74 04                	je     801c78 <strncmp+0x26>
  801c74:	3a 0a                	cmp    (%edx),%cl
  801c76:	74 eb                	je     801c63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c78:	0f b6 00             	movzbl (%eax),%eax
  801c7b:	0f b6 12             	movzbl (%edx),%edx
  801c7e:	29 d0                	sub    %edx,%eax
  801c80:	eb 05                	jmp    801c87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c87:	5b                   	pop    %ebx
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c94:	eb 07                	jmp    801c9d <strchr+0x13>
		if (*s == c)
  801c96:	38 ca                	cmp    %cl,%dl
  801c98:	74 0f                	je     801ca9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c9a:	83 c0 01             	add    $0x1,%eax
  801c9d:	0f b6 10             	movzbl (%eax),%edx
  801ca0:	84 d2                	test   %dl,%dl
  801ca2:	75 f2                	jne    801c96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cb5:	eb 03                	jmp    801cba <strfind+0xf>
  801cb7:	83 c0 01             	add    $0x1,%eax
  801cba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cbd:	38 ca                	cmp    %cl,%dl
  801cbf:	74 04                	je     801cc5 <strfind+0x1a>
  801cc1:	84 d2                	test   %dl,%dl
  801cc3:	75 f2                	jne    801cb7 <strfind+0xc>
			break;
	return (char *) s;
}
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	57                   	push   %edi
  801ccb:	56                   	push   %esi
  801ccc:	53                   	push   %ebx
  801ccd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cd3:	85 c9                	test   %ecx,%ecx
  801cd5:	74 36                	je     801d0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cd7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cdd:	75 28                	jne    801d07 <memset+0x40>
  801cdf:	f6 c1 03             	test   $0x3,%cl
  801ce2:	75 23                	jne    801d07 <memset+0x40>
		c &= 0xFF;
  801ce4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ce8:	89 d3                	mov    %edx,%ebx
  801cea:	c1 e3 08             	shl    $0x8,%ebx
  801ced:	89 d6                	mov    %edx,%esi
  801cef:	c1 e6 18             	shl    $0x18,%esi
  801cf2:	89 d0                	mov    %edx,%eax
  801cf4:	c1 e0 10             	shl    $0x10,%eax
  801cf7:	09 f0                	or     %esi,%eax
  801cf9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cfb:	89 d8                	mov    %ebx,%eax
  801cfd:	09 d0                	or     %edx,%eax
  801cff:	c1 e9 02             	shr    $0x2,%ecx
  801d02:	fc                   	cld    
  801d03:	f3 ab                	rep stos %eax,%es:(%edi)
  801d05:	eb 06                	jmp    801d0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0a:	fc                   	cld    
  801d0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d0d:	89 f8                	mov    %edi,%eax
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    

00801d14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	57                   	push   %edi
  801d18:	56                   	push   %esi
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d22:	39 c6                	cmp    %eax,%esi
  801d24:	73 35                	jae    801d5b <memmove+0x47>
  801d26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d29:	39 d0                	cmp    %edx,%eax
  801d2b:	73 2e                	jae    801d5b <memmove+0x47>
		s += n;
		d += n;
  801d2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d30:	89 d6                	mov    %edx,%esi
  801d32:	09 fe                	or     %edi,%esi
  801d34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d3a:	75 13                	jne    801d4f <memmove+0x3b>
  801d3c:	f6 c1 03             	test   $0x3,%cl
  801d3f:	75 0e                	jne    801d4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d41:	83 ef 04             	sub    $0x4,%edi
  801d44:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d47:	c1 e9 02             	shr    $0x2,%ecx
  801d4a:	fd                   	std    
  801d4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d4d:	eb 09                	jmp    801d58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d4f:	83 ef 01             	sub    $0x1,%edi
  801d52:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d55:	fd                   	std    
  801d56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d58:	fc                   	cld    
  801d59:	eb 1d                	jmp    801d78 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d5b:	89 f2                	mov    %esi,%edx
  801d5d:	09 c2                	or     %eax,%edx
  801d5f:	f6 c2 03             	test   $0x3,%dl
  801d62:	75 0f                	jne    801d73 <memmove+0x5f>
  801d64:	f6 c1 03             	test   $0x3,%cl
  801d67:	75 0a                	jne    801d73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d69:	c1 e9 02             	shr    $0x2,%ecx
  801d6c:	89 c7                	mov    %eax,%edi
  801d6e:	fc                   	cld    
  801d6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d71:	eb 05                	jmp    801d78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d73:	89 c7                	mov    %eax,%edi
  801d75:	fc                   	cld    
  801d76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d78:	5e                   	pop    %esi
  801d79:	5f                   	pop    %edi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    

00801d7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d7f:	ff 75 10             	pushl  0x10(%ebp)
  801d82:	ff 75 0c             	pushl  0xc(%ebp)
  801d85:	ff 75 08             	pushl  0x8(%ebp)
  801d88:	e8 87 ff ff ff       	call   801d14 <memmove>
}
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	8b 45 08             	mov    0x8(%ebp),%eax
  801d97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9a:	89 c6                	mov    %eax,%esi
  801d9c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d9f:	eb 1a                	jmp    801dbb <memcmp+0x2c>
		if (*s1 != *s2)
  801da1:	0f b6 08             	movzbl (%eax),%ecx
  801da4:	0f b6 1a             	movzbl (%edx),%ebx
  801da7:	38 d9                	cmp    %bl,%cl
  801da9:	74 0a                	je     801db5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801dab:	0f b6 c1             	movzbl %cl,%eax
  801dae:	0f b6 db             	movzbl %bl,%ebx
  801db1:	29 d8                	sub    %ebx,%eax
  801db3:	eb 0f                	jmp    801dc4 <memcmp+0x35>
		s1++, s2++;
  801db5:	83 c0 01             	add    $0x1,%eax
  801db8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dbb:	39 f0                	cmp    %esi,%eax
  801dbd:	75 e2                	jne    801da1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc4:	5b                   	pop    %ebx
  801dc5:	5e                   	pop    %esi
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    

00801dc8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	53                   	push   %ebx
  801dcc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801dcf:	89 c1                	mov    %eax,%ecx
  801dd1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801dd4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dd8:	eb 0a                	jmp    801de4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dda:	0f b6 10             	movzbl (%eax),%edx
  801ddd:	39 da                	cmp    %ebx,%edx
  801ddf:	74 07                	je     801de8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801de1:	83 c0 01             	add    $0x1,%eax
  801de4:	39 c8                	cmp    %ecx,%eax
  801de6:	72 f2                	jb     801dda <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801de8:	5b                   	pop    %ebx
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	57                   	push   %edi
  801def:	56                   	push   %esi
  801df0:	53                   	push   %ebx
  801df1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801df4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801df7:	eb 03                	jmp    801dfc <strtol+0x11>
		s++;
  801df9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dfc:	0f b6 01             	movzbl (%ecx),%eax
  801dff:	3c 20                	cmp    $0x20,%al
  801e01:	74 f6                	je     801df9 <strtol+0xe>
  801e03:	3c 09                	cmp    $0x9,%al
  801e05:	74 f2                	je     801df9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e07:	3c 2b                	cmp    $0x2b,%al
  801e09:	75 0a                	jne    801e15 <strtol+0x2a>
		s++;
  801e0b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e0e:	bf 00 00 00 00       	mov    $0x0,%edi
  801e13:	eb 11                	jmp    801e26 <strtol+0x3b>
  801e15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e1a:	3c 2d                	cmp    $0x2d,%al
  801e1c:	75 08                	jne    801e26 <strtol+0x3b>
		s++, neg = 1;
  801e1e:	83 c1 01             	add    $0x1,%ecx
  801e21:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e2c:	75 15                	jne    801e43 <strtol+0x58>
  801e2e:	80 39 30             	cmpb   $0x30,(%ecx)
  801e31:	75 10                	jne    801e43 <strtol+0x58>
  801e33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e37:	75 7c                	jne    801eb5 <strtol+0xca>
		s += 2, base = 16;
  801e39:	83 c1 02             	add    $0x2,%ecx
  801e3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e41:	eb 16                	jmp    801e59 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e43:	85 db                	test   %ebx,%ebx
  801e45:	75 12                	jne    801e59 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e47:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e4c:	80 39 30             	cmpb   $0x30,(%ecx)
  801e4f:	75 08                	jne    801e59 <strtol+0x6e>
		s++, base = 8;
  801e51:	83 c1 01             	add    $0x1,%ecx
  801e54:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e59:	b8 00 00 00 00       	mov    $0x0,%eax
  801e5e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e61:	0f b6 11             	movzbl (%ecx),%edx
  801e64:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e67:	89 f3                	mov    %esi,%ebx
  801e69:	80 fb 09             	cmp    $0x9,%bl
  801e6c:	77 08                	ja     801e76 <strtol+0x8b>
			dig = *s - '0';
  801e6e:	0f be d2             	movsbl %dl,%edx
  801e71:	83 ea 30             	sub    $0x30,%edx
  801e74:	eb 22                	jmp    801e98 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e76:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e79:	89 f3                	mov    %esi,%ebx
  801e7b:	80 fb 19             	cmp    $0x19,%bl
  801e7e:	77 08                	ja     801e88 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e80:	0f be d2             	movsbl %dl,%edx
  801e83:	83 ea 57             	sub    $0x57,%edx
  801e86:	eb 10                	jmp    801e98 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e88:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e8b:	89 f3                	mov    %esi,%ebx
  801e8d:	80 fb 19             	cmp    $0x19,%bl
  801e90:	77 16                	ja     801ea8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e92:	0f be d2             	movsbl %dl,%edx
  801e95:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e98:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e9b:	7d 0b                	jge    801ea8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e9d:	83 c1 01             	add    $0x1,%ecx
  801ea0:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ea4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ea6:	eb b9                	jmp    801e61 <strtol+0x76>

	if (endptr)
  801ea8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eac:	74 0d                	je     801ebb <strtol+0xd0>
		*endptr = (char *) s;
  801eae:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eb1:	89 0e                	mov    %ecx,(%esi)
  801eb3:	eb 06                	jmp    801ebb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eb5:	85 db                	test   %ebx,%ebx
  801eb7:	74 98                	je     801e51 <strtol+0x66>
  801eb9:	eb 9e                	jmp    801e59 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ebb:	89 c2                	mov    %eax,%edx
  801ebd:	f7 da                	neg    %edx
  801ebf:	85 ff                	test   %edi,%edi
  801ec1:	0f 45 c2             	cmovne %edx,%eax
}
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    

00801ec9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  801ecf:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801ed6:	75 56                	jne    801f2e <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  801ed8:	83 ec 04             	sub    $0x4,%esp
  801edb:	6a 07                	push   $0x7
  801edd:	68 00 f0 bf ee       	push   $0xeebff000
  801ee2:	6a 00                	push   $0x0
  801ee4:	e8 87 e2 ff ff       	call   800170 <sys_page_alloc>
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	85 c0                	test   %eax,%eax
  801eee:	74 14                	je     801f04 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  801ef0:	83 ec 04             	sub    $0x4,%esp
  801ef3:	68 a0 27 80 00       	push   $0x8027a0
  801ef8:	6a 21                	push   $0x21
  801efa:	68 b5 27 80 00       	push   $0x8027b5
  801eff:	e8 00 f6 ff ff       	call   801504 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  801f04:	83 ec 08             	sub    $0x8,%esp
  801f07:	68 80 03 80 00       	push   $0x800380
  801f0c:	6a 00                	push   $0x0
  801f0e:	e8 a8 e3 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	85 c0                	test   %eax,%eax
  801f18:	74 14                	je     801f2e <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  801f1a:	83 ec 04             	sub    $0x4,%esp
  801f1d:	68 c3 27 80 00       	push   $0x8027c3
  801f22:	6a 23                	push   $0x23
  801f24:	68 b5 27 80 00       	push   $0x8027b5
  801f29:	e8 d6 f5 ff ff       	call   801504 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f31:	a3 00 70 80 00       	mov    %eax,0x807000
}
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	56                   	push   %esi
  801f3c:	53                   	push   %ebx
  801f3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801f46:	85 c0                	test   %eax,%eax
  801f48:	74 0e                	je     801f58 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801f4a:	83 ec 0c             	sub    $0xc,%esp
  801f4d:	50                   	push   %eax
  801f4e:	e8 cd e3 ff ff       	call   800320 <sys_ipc_recv>
  801f53:	83 c4 10             	add    $0x10,%esp
  801f56:	eb 10                	jmp    801f68 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801f58:	83 ec 0c             	sub    $0xc,%esp
  801f5b:	68 00 00 c0 ee       	push   $0xeec00000
  801f60:	e8 bb e3 ff ff       	call   800320 <sys_ipc_recv>
  801f65:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	79 17                	jns    801f83 <ipc_recv+0x4b>
		if(*from_env_store)
  801f6c:	83 3e 00             	cmpl   $0x0,(%esi)
  801f6f:	74 06                	je     801f77 <ipc_recv+0x3f>
			*from_env_store = 0;
  801f71:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801f77:	85 db                	test   %ebx,%ebx
  801f79:	74 2c                	je     801fa7 <ipc_recv+0x6f>
			*perm_store = 0;
  801f7b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f81:	eb 24                	jmp    801fa7 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801f83:	85 f6                	test   %esi,%esi
  801f85:	74 0a                	je     801f91 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801f87:	a1 08 40 80 00       	mov    0x804008,%eax
  801f8c:	8b 40 74             	mov    0x74(%eax),%eax
  801f8f:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801f91:	85 db                	test   %ebx,%ebx
  801f93:	74 0a                	je     801f9f <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801f95:	a1 08 40 80 00       	mov    0x804008,%eax
  801f9a:	8b 40 78             	mov    0x78(%eax),%eax
  801f9d:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f9f:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801faa:	5b                   	pop    %ebx
  801fab:	5e                   	pop    %esi
  801fac:	5d                   	pop    %ebp
  801fad:	c3                   	ret    

00801fae <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 0c             	sub    $0xc,%esp
  801fb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fba:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801fc0:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801fc2:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801fc7:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801fca:	e8 82 e1 ff ff       	call   800151 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801fcf:	ff 75 14             	pushl  0x14(%ebp)
  801fd2:	53                   	push   %ebx
  801fd3:	56                   	push   %esi
  801fd4:	57                   	push   %edi
  801fd5:	e8 23 e3 ff ff       	call   8002fd <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801fda:	89 c2                	mov    %eax,%edx
  801fdc:	f7 d2                	not    %edx
  801fde:	c1 ea 1f             	shr    $0x1f,%edx
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fe7:	0f 94 c1             	sete   %cl
  801fea:	09 ca                	or     %ecx,%edx
  801fec:	85 c0                	test   %eax,%eax
  801fee:	0f 94 c0             	sete   %al
  801ff1:	38 c2                	cmp    %al,%dl
  801ff3:	77 d5                	ja     801fca <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801ff5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff8:	5b                   	pop    %ebx
  801ff9:	5e                   	pop    %esi
  801ffa:	5f                   	pop    %edi
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    

00801ffd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802003:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802008:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80200b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802011:	8b 52 50             	mov    0x50(%edx),%edx
  802014:	39 ca                	cmp    %ecx,%edx
  802016:	75 0d                	jne    802025 <ipc_find_env+0x28>
			return envs[i].env_id;
  802018:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80201b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802020:	8b 40 48             	mov    0x48(%eax),%eax
  802023:	eb 0f                	jmp    802034 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802025:	83 c0 01             	add    $0x1,%eax
  802028:	3d 00 04 00 00       	cmp    $0x400,%eax
  80202d:	75 d9                	jne    802008 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80202f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    

00802036 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203c:	89 d0                	mov    %edx,%eax
  80203e:	c1 e8 16             	shr    $0x16,%eax
  802041:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802048:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204d:	f6 c1 01             	test   $0x1,%cl
  802050:	74 1d                	je     80206f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802052:	c1 ea 0c             	shr    $0xc,%edx
  802055:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80205c:	f6 c2 01             	test   $0x1,%dl
  80205f:	74 0e                	je     80206f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802061:	c1 ea 0c             	shr    $0xc,%edx
  802064:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80206b:	ef 
  80206c:	0f b7 c0             	movzwl %ax,%eax
}
  80206f:	5d                   	pop    %ebp
  802070:	c3                   	ret    
  802071:	66 90                	xchg   %ax,%ax
  802073:	66 90                	xchg   %ax,%ax
  802075:	66 90                	xchg   %ax,%ax
  802077:	66 90                	xchg   %ax,%ax
  802079:	66 90                	xchg   %ax,%ax
  80207b:	66 90                	xchg   %ax,%ax
  80207d:	66 90                	xchg   %ax,%ax
  80207f:	90                   	nop

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
