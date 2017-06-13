
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 65 00 00 00       	call   8000aa <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 a6 04 00 00       	call   800541 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 8a 22 80 00       	push   $0x80228a
  800114:	6a 23                	push   $0x23
  800116:	68 a7 22 80 00       	push   $0x8022a7
  80011b:	e8 b3 13 00 00       	call   8014d3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 8a 22 80 00       	push   $0x80228a
  800195:	6a 23                	push   $0x23
  800197:	68 a7 22 80 00       	push   $0x8022a7
  80019c:	e8 32 13 00 00       	call   8014d3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 8a 22 80 00       	push   $0x80228a
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 a7 22 80 00       	push   $0x8022a7
  8001de:	e8 f0 12 00 00       	call   8014d3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 8a 22 80 00       	push   $0x80228a
  800219:	6a 23                	push   $0x23
  80021b:	68 a7 22 80 00       	push   $0x8022a7
  800220:	e8 ae 12 00 00       	call   8014d3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 8a 22 80 00       	push   $0x80228a
  80025b:	6a 23                	push   $0x23
  80025d:	68 a7 22 80 00       	push   $0x8022a7
  800262:	e8 6c 12 00 00       	call   8014d3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 8a 22 80 00       	push   $0x80228a
  80029d:	6a 23                	push   $0x23
  80029f:	68 a7 22 80 00       	push   $0x8022a7
  8002a4:	e8 2a 12 00 00       	call   8014d3 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 8a 22 80 00       	push   $0x80228a
  8002df:	6a 23                	push   $0x23
  8002e1:	68 a7 22 80 00       	push   $0x8022a7
  8002e6:	e8 e8 11 00 00       	call   8014d3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 8a 22 80 00       	push   $0x80228a
  800343:	6a 23                	push   $0x23
  800345:	68 a7 22 80 00       	push   $0x8022a7
  80034a:	e8 84 11 00 00       	call   8014d3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	b8 0e 00 00 00       	mov    $0xe,%eax
  800367:	89 d1                	mov    %edx,%ecx
  800369:	89 d3                	mov    %edx,%ebx
  80036b:	89 d7                	mov    %edx,%edi
  80036d:	89 d6                	mov    %edx,%esi
  80036f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	05 00 00 00 30       	add    $0x30000000,%eax
  800381:	c1 e8 0c             	shr    $0xc,%eax
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	05 00 00 00 30       	add    $0x30000000,%eax
  800391:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800396:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 ea 16             	shr    $0x16,%edx
  8003ad:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b4:	f6 c2 01             	test   $0x1,%dl
  8003b7:	74 11                	je     8003ca <fd_alloc+0x2d>
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	c1 ea 0c             	shr    $0xc,%edx
  8003be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c5:	f6 c2 01             	test   $0x1,%dl
  8003c8:	75 09                	jne    8003d3 <fd_alloc+0x36>
			*fd_store = fd;
  8003ca:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d1:	eb 17                	jmp    8003ea <fd_alloc+0x4d>
  8003d3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003dd:	75 c9                	jne    8003a8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003df:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f2:	83 f8 1f             	cmp    $0x1f,%eax
  8003f5:	77 36                	ja     80042d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f7:	c1 e0 0c             	shl    $0xc,%eax
  8003fa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 16             	shr    $0x16,%edx
  800404:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 24                	je     800434 <fd_lookup+0x48>
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 ea 0c             	shr    $0xc,%edx
  800415:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041c:	f6 c2 01             	test   $0x1,%dl
  80041f:	74 1a                	je     80043b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 02                	mov    %eax,(%edx)
	return 0;
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	eb 13                	jmp    800440 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800432:	eb 0c                	jmp    800440 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800439:	eb 05                	jmp    800440 <fd_lookup+0x54>
  80043b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044b:	ba 34 23 80 00       	mov    $0x802334,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800450:	eb 13                	jmp    800465 <dev_lookup+0x23>
  800452:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800455:	39 08                	cmp    %ecx,(%eax)
  800457:	75 0c                	jne    800465 <dev_lookup+0x23>
			*dev = devtab[i];
  800459:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
  800463:	eb 2e                	jmp    800493 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	85 c0                	test   %eax,%eax
  800469:	75 e7                	jne    800452 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80046b:	a1 08 40 80 00       	mov    0x804008,%eax
  800470:	8b 40 48             	mov    0x48(%eax),%eax
  800473:	83 ec 04             	sub    $0x4,%esp
  800476:	51                   	push   %ecx
  800477:	50                   	push   %eax
  800478:	68 b8 22 80 00       	push   $0x8022b8
  80047d:	e8 2a 11 00 00       	call   8015ac <cprintf>
	*dev = 0;
  800482:	8b 45 0c             	mov    0xc(%ebp),%eax
  800485:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800493:	c9                   	leave  
  800494:	c3                   	ret    

00800495 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	83 ec 10             	sub    $0x10,%esp
  80049d:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a6:	50                   	push   %eax
  8004a7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ad:	c1 e8 0c             	shr    $0xc,%eax
  8004b0:	50                   	push   %eax
  8004b1:	e8 36 ff ff ff       	call   8003ec <fd_lookup>
  8004b6:	83 c4 08             	add    $0x8,%esp
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	78 05                	js     8004c2 <fd_close+0x2d>
	    || fd != fd2)
  8004bd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004c0:	74 0c                	je     8004ce <fd_close+0x39>
		return (must_exist ? r : 0);
  8004c2:	84 db                	test   %bl,%bl
  8004c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c9:	0f 44 c2             	cmove  %edx,%eax
  8004cc:	eb 41                	jmp    80050f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d4:	50                   	push   %eax
  8004d5:	ff 36                	pushl  (%esi)
  8004d7:	e8 66 ff ff ff       	call   800442 <dev_lookup>
  8004dc:	89 c3                	mov    %eax,%ebx
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	78 1a                	js     8004ff <fd_close+0x6a>
		if (dev->dev_close)
  8004e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004eb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	74 0b                	je     8004ff <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f4:	83 ec 0c             	sub    $0xc,%esp
  8004f7:	56                   	push   %esi
  8004f8:	ff d0                	call   *%eax
  8004fa:	89 c3                	mov    %eax,%ebx
  8004fc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	56                   	push   %esi
  800503:	6a 00                	push   $0x0
  800505:	e8 e1 fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	89 d8                	mov    %ebx,%eax
}
  80050f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800512:	5b                   	pop    %ebx
  800513:	5e                   	pop    %esi
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80051c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051f:	50                   	push   %eax
  800520:	ff 75 08             	pushl  0x8(%ebp)
  800523:	e8 c4 fe ff ff       	call   8003ec <fd_lookup>
  800528:	83 c4 08             	add    $0x8,%esp
  80052b:	85 c0                	test   %eax,%eax
  80052d:	78 10                	js     80053f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	6a 01                	push   $0x1
  800534:	ff 75 f4             	pushl  -0xc(%ebp)
  800537:	e8 59 ff ff ff       	call   800495 <fd_close>
  80053c:	83 c4 10             	add    $0x10,%esp
}
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <close_all>:

void
close_all(void)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	53                   	push   %ebx
  800545:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800548:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80054d:	83 ec 0c             	sub    $0xc,%esp
  800550:	53                   	push   %ebx
  800551:	e8 c0 ff ff ff       	call   800516 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800556:	83 c3 01             	add    $0x1,%ebx
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	83 fb 20             	cmp    $0x20,%ebx
  80055f:	75 ec                	jne    80054d <close_all+0xc>
		close(i);
}
  800561:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800564:	c9                   	leave  
  800565:	c3                   	ret    

00800566 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
  800569:	57                   	push   %edi
  80056a:	56                   	push   %esi
  80056b:	53                   	push   %ebx
  80056c:	83 ec 2c             	sub    $0x2c,%esp
  80056f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800572:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800575:	50                   	push   %eax
  800576:	ff 75 08             	pushl  0x8(%ebp)
  800579:	e8 6e fe ff ff       	call   8003ec <fd_lookup>
  80057e:	83 c4 08             	add    $0x8,%esp
  800581:	85 c0                	test   %eax,%eax
  800583:	0f 88 c1 00 00 00    	js     80064a <dup+0xe4>
		return r;
	close(newfdnum);
  800589:	83 ec 0c             	sub    $0xc,%esp
  80058c:	56                   	push   %esi
  80058d:	e8 84 ff ff ff       	call   800516 <close>

	newfd = INDEX2FD(newfdnum);
  800592:	89 f3                	mov    %esi,%ebx
  800594:	c1 e3 0c             	shl    $0xc,%ebx
  800597:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80059d:	83 c4 04             	add    $0x4,%esp
  8005a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a3:	e8 de fd ff ff       	call   800386 <fd2data>
  8005a8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005aa:	89 1c 24             	mov    %ebx,(%esp)
  8005ad:	e8 d4 fd ff ff       	call   800386 <fd2data>
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b8:	89 f8                	mov    %edi,%eax
  8005ba:	c1 e8 16             	shr    $0x16,%eax
  8005bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c4:	a8 01                	test   $0x1,%al
  8005c6:	74 37                	je     8005ff <dup+0x99>
  8005c8:	89 f8                	mov    %edi,%eax
  8005ca:	c1 e8 0c             	shr    $0xc,%eax
  8005cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d4:	f6 c2 01             	test   $0x1,%dl
  8005d7:	74 26                	je     8005ff <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e8:	50                   	push   %eax
  8005e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ec:	6a 00                	push   $0x0
  8005ee:	57                   	push   %edi
  8005ef:	6a 00                	push   $0x0
  8005f1:	e8 b3 fb ff ff       	call   8001a9 <sys_page_map>
  8005f6:	89 c7                	mov    %eax,%edi
  8005f8:	83 c4 20             	add    $0x20,%esp
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	78 2e                	js     80062d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800602:	89 d0                	mov    %edx,%eax
  800604:	c1 e8 0c             	shr    $0xc,%eax
  800607:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060e:	83 ec 0c             	sub    $0xc,%esp
  800611:	25 07 0e 00 00       	and    $0xe07,%eax
  800616:	50                   	push   %eax
  800617:	53                   	push   %ebx
  800618:	6a 00                	push   $0x0
  80061a:	52                   	push   %edx
  80061b:	6a 00                	push   $0x0
  80061d:	e8 87 fb ff ff       	call   8001a9 <sys_page_map>
  800622:	89 c7                	mov    %eax,%edi
  800624:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800627:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800629:	85 ff                	test   %edi,%edi
  80062b:	79 1d                	jns    80064a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 00                	push   $0x0
  800633:	e8 b3 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800638:	83 c4 08             	add    $0x8,%esp
  80063b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063e:	6a 00                	push   $0x0
  800640:	e8 a6 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	89 f8                	mov    %edi,%eax
}
  80064a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	53                   	push   %ebx
  800656:	83 ec 14             	sub    $0x14,%esp
  800659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80065c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065f:	50                   	push   %eax
  800660:	53                   	push   %ebx
  800661:	e8 86 fd ff ff       	call   8003ec <fd_lookup>
  800666:	83 c4 08             	add    $0x8,%esp
  800669:	89 c2                	mov    %eax,%edx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	78 6d                	js     8006dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800675:	50                   	push   %eax
  800676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800679:	ff 30                	pushl  (%eax)
  80067b:	e8 c2 fd ff ff       	call   800442 <dev_lookup>
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	78 4c                	js     8006d3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800687:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068a:	8b 42 08             	mov    0x8(%edx),%eax
  80068d:	83 e0 03             	and    $0x3,%eax
  800690:	83 f8 01             	cmp    $0x1,%eax
  800693:	75 21                	jne    8006b6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800695:	a1 08 40 80 00       	mov    0x804008,%eax
  80069a:	8b 40 48             	mov    0x48(%eax),%eax
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	50                   	push   %eax
  8006a2:	68 f9 22 80 00       	push   $0x8022f9
  8006a7:	e8 00 0f 00 00       	call   8015ac <cprintf>
		return -E_INVAL;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b4:	eb 26                	jmp    8006dc <read+0x8a>
	}
	if (!dev->dev_read)
  8006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b9:	8b 40 08             	mov    0x8(%eax),%eax
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	74 17                	je     8006d7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	ff 75 10             	pushl  0x10(%ebp)
  8006c6:	ff 75 0c             	pushl  0xc(%ebp)
  8006c9:	52                   	push   %edx
  8006ca:	ff d0                	call   *%eax
  8006cc:	89 c2                	mov    %eax,%edx
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 09                	jmp    8006dc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d3:	89 c2                	mov    %eax,%edx
  8006d5:	eb 05                	jmp    8006dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006dc:	89 d0                	mov    %edx,%eax
  8006de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	57                   	push   %edi
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 0c             	sub    $0xc,%esp
  8006ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ef:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f7:	eb 21                	jmp    80071a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f9:	83 ec 04             	sub    $0x4,%esp
  8006fc:	89 f0                	mov    %esi,%eax
  8006fe:	29 d8                	sub    %ebx,%eax
  800700:	50                   	push   %eax
  800701:	89 d8                	mov    %ebx,%eax
  800703:	03 45 0c             	add    0xc(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	57                   	push   %edi
  800708:	e8 45 ff ff ff       	call   800652 <read>
		if (m < 0)
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	85 c0                	test   %eax,%eax
  800712:	78 10                	js     800724 <readn+0x41>
			return m;
		if (m == 0)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 0a                	je     800722 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800718:	01 c3                	add    %eax,%ebx
  80071a:	39 f3                	cmp    %esi,%ebx
  80071c:	72 db                	jb     8006f9 <readn+0x16>
  80071e:	89 d8                	mov    %ebx,%eax
  800720:	eb 02                	jmp    800724 <readn+0x41>
  800722:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800724:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800727:	5b                   	pop    %ebx
  800728:	5e                   	pop    %esi
  800729:	5f                   	pop    %edi
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	53                   	push   %ebx
  800730:	83 ec 14             	sub    $0x14,%esp
  800733:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800736:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	53                   	push   %ebx
  80073b:	e8 ac fc ff ff       	call   8003ec <fd_lookup>
  800740:	83 c4 08             	add    $0x8,%esp
  800743:	89 c2                	mov    %eax,%edx
  800745:	85 c0                	test   %eax,%eax
  800747:	78 68                	js     8007b1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074f:	50                   	push   %eax
  800750:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800753:	ff 30                	pushl  (%eax)
  800755:	e8 e8 fc ff ff       	call   800442 <dev_lookup>
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	85 c0                	test   %eax,%eax
  80075f:	78 47                	js     8007a8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800761:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800764:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800768:	75 21                	jne    80078b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80076a:	a1 08 40 80 00       	mov    0x804008,%eax
  80076f:	8b 40 48             	mov    0x48(%eax),%eax
  800772:	83 ec 04             	sub    $0x4,%esp
  800775:	53                   	push   %ebx
  800776:	50                   	push   %eax
  800777:	68 15 23 80 00       	push   $0x802315
  80077c:	e8 2b 0e 00 00       	call   8015ac <cprintf>
		return -E_INVAL;
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800789:	eb 26                	jmp    8007b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078e:	8b 52 0c             	mov    0xc(%edx),%edx
  800791:	85 d2                	test   %edx,%edx
  800793:	74 17                	je     8007ac <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800795:	83 ec 04             	sub    $0x4,%esp
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	ff 75 0c             	pushl  0xc(%ebp)
  80079e:	50                   	push   %eax
  80079f:	ff d2                	call   *%edx
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	eb 09                	jmp    8007b1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a8:	89 c2                	mov    %eax,%edx
  8007aa:	eb 05                	jmp    8007b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007b1:	89 d0                	mov    %edx,%eax
  8007b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007c1:	50                   	push   %eax
  8007c2:	ff 75 08             	pushl  0x8(%ebp)
  8007c5:	e8 22 fc ff ff       	call   8003ec <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	78 0e                	js     8007df <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 14             	sub    $0x14,%esp
  8007e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ee:	50                   	push   %eax
  8007ef:	53                   	push   %ebx
  8007f0:	e8 f7 fb ff ff       	call   8003ec <fd_lookup>
  8007f5:	83 c4 08             	add    $0x8,%esp
  8007f8:	89 c2                	mov    %eax,%edx
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	78 65                	js     800863 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800804:	50                   	push   %eax
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	ff 30                	pushl  (%eax)
  80080a:	e8 33 fc ff ff       	call   800442 <dev_lookup>
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	85 c0                	test   %eax,%eax
  800814:	78 44                	js     80085a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800819:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081d:	75 21                	jne    800840 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800824:	8b 40 48             	mov    0x48(%eax),%eax
  800827:	83 ec 04             	sub    $0x4,%esp
  80082a:	53                   	push   %ebx
  80082b:	50                   	push   %eax
  80082c:	68 d8 22 80 00       	push   $0x8022d8
  800831:	e8 76 0d 00 00       	call   8015ac <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083e:	eb 23                	jmp    800863 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800840:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800843:	8b 52 18             	mov    0x18(%edx),%edx
  800846:	85 d2                	test   %edx,%edx
  800848:	74 14                	je     80085e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	ff 75 0c             	pushl  0xc(%ebp)
  800850:	50                   	push   %eax
  800851:	ff d2                	call   *%edx
  800853:	89 c2                	mov    %eax,%edx
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	eb 09                	jmp    800863 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	89 c2                	mov    %eax,%edx
  80085c:	eb 05                	jmp    800863 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800863:	89 d0                	mov    %edx,%eax
  800865:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800868:	c9                   	leave  
  800869:	c3                   	ret    

0080086a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	83 ec 14             	sub    $0x14,%esp
  800871:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800874:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800877:	50                   	push   %eax
  800878:	ff 75 08             	pushl  0x8(%ebp)
  80087b:	e8 6c fb ff ff       	call   8003ec <fd_lookup>
  800880:	83 c4 08             	add    $0x8,%esp
  800883:	89 c2                	mov    %eax,%edx
  800885:	85 c0                	test   %eax,%eax
  800887:	78 58                	js     8008e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088f:	50                   	push   %eax
  800890:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800893:	ff 30                	pushl  (%eax)
  800895:	e8 a8 fb ff ff       	call   800442 <dev_lookup>
  80089a:	83 c4 10             	add    $0x10,%esp
  80089d:	85 c0                	test   %eax,%eax
  80089f:	78 37                	js     8008d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a8:	74 32                	je     8008dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b4:	00 00 00 
	stat->st_isdir = 0;
  8008b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008be:	00 00 00 
	stat->st_dev = dev;
  8008c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c7:	83 ec 08             	sub    $0x8,%esp
  8008ca:	53                   	push   %ebx
  8008cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ce:	ff 50 14             	call   *0x14(%eax)
  8008d1:	89 c2                	mov    %eax,%edx
  8008d3:	83 c4 10             	add    $0x10,%esp
  8008d6:	eb 09                	jmp    8008e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d8:	89 c2                	mov    %eax,%edx
  8008da:	eb 05                	jmp    8008e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e1:	89 d0                	mov    %edx,%eax
  8008e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ed:	83 ec 08             	sub    $0x8,%esp
  8008f0:	6a 00                	push   $0x0
  8008f2:	ff 75 08             	pushl  0x8(%ebp)
  8008f5:	e8 ef 01 00 00       	call   800ae9 <open>
  8008fa:	89 c3                	mov    %eax,%ebx
  8008fc:	83 c4 10             	add    $0x10,%esp
  8008ff:	85 c0                	test   %eax,%eax
  800901:	78 1b                	js     80091e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800903:	83 ec 08             	sub    $0x8,%esp
  800906:	ff 75 0c             	pushl  0xc(%ebp)
  800909:	50                   	push   %eax
  80090a:	e8 5b ff ff ff       	call   80086a <fstat>
  80090f:	89 c6                	mov    %eax,%esi
	close(fd);
  800911:	89 1c 24             	mov    %ebx,(%esp)
  800914:	e8 fd fb ff ff       	call   800516 <close>
	return r;
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	89 f0                	mov    %esi,%eax
}
  80091e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	89 c6                	mov    %eax,%esi
  80092c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800935:	75 12                	jne    800949 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800937:	83 ec 0c             	sub    $0xc,%esp
  80093a:	6a 01                	push   $0x1
  80093c:	e8 1c 16 00 00       	call   801f5d <ipc_find_env>
  800941:	a3 00 40 80 00       	mov    %eax,0x804000
  800946:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800949:	6a 07                	push   $0x7
  80094b:	68 00 50 80 00       	push   $0x805000
  800950:	56                   	push   %esi
  800951:	ff 35 00 40 80 00    	pushl  0x804000
  800957:	e8 b2 15 00 00       	call   801f0e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80095c:	83 c4 0c             	add    $0xc,%esp
  80095f:	6a 00                	push   $0x0
  800961:	53                   	push   %ebx
  800962:	6a 00                	push   $0x0
  800964:	e8 2f 15 00 00       	call   801e98 <ipc_recv>
}
  800969:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 40 0c             	mov    0xc(%eax),%eax
  80097c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
  800984:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 02 00 00 00       	mov    $0x2,%eax
  800993:	e8 8d ff ff ff       	call   800925 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b5:	e8 6b ff ff ff       	call   800925 <fsipc>
}
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	83 ec 04             	sub    $0x4,%esp
  8009c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009db:	e8 45 ff ff ff       	call   800925 <fsipc>
  8009e0:	85 c0                	test   %eax,%eax
  8009e2:	78 2c                	js     800a10 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e4:	83 ec 08             	sub    $0x8,%esp
  8009e7:	68 00 50 80 00       	push   $0x805000
  8009ec:	53                   	push   %ebx
  8009ed:	e8 5f 11 00 00       	call   801b51 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009fd:	a1 84 50 80 00       	mov    0x805084,%eax
  800a02:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a08:	83 c4 10             	add    $0x10,%esp
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	53                   	push   %ebx
  800a19:	83 ec 08             	sub    $0x8,%esp
  800a1c:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a22:	8b 52 0c             	mov    0xc(%edx),%edx
  800a25:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a2b:	a3 04 50 80 00       	mov    %eax,0x805004
  800a30:	3d 08 50 80 00       	cmp    $0x805008,%eax
  800a35:	bb 08 50 80 00       	mov    $0x805008,%ebx
  800a3a:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a3d:	53                   	push   %ebx
  800a3e:	ff 75 0c             	pushl  0xc(%ebp)
  800a41:	68 08 50 80 00       	push   $0x805008
  800a46:	e8 98 12 00 00       	call   801ce3 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a50:	b8 04 00 00 00       	mov    $0x4,%eax
  800a55:	e8 cb fe ff ff       	call   800925 <fsipc>
  800a5a:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  800a5d:	85 c0                	test   %eax,%eax
  800a5f:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  800a62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 40 0c             	mov    0xc(%eax),%eax
  800a75:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a80:	ba 00 00 00 00       	mov    $0x0,%edx
  800a85:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8a:	e8 96 fe ff ff       	call   800925 <fsipc>
  800a8f:	89 c3                	mov    %eax,%ebx
  800a91:	85 c0                	test   %eax,%eax
  800a93:	78 4b                	js     800ae0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a95:	39 c6                	cmp    %eax,%esi
  800a97:	73 16                	jae    800aaf <devfile_read+0x48>
  800a99:	68 48 23 80 00       	push   $0x802348
  800a9e:	68 4f 23 80 00       	push   $0x80234f
  800aa3:	6a 7c                	push   $0x7c
  800aa5:	68 64 23 80 00       	push   $0x802364
  800aaa:	e8 24 0a 00 00       	call   8014d3 <_panic>
	assert(r <= PGSIZE);
  800aaf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab4:	7e 16                	jle    800acc <devfile_read+0x65>
  800ab6:	68 6f 23 80 00       	push   $0x80236f
  800abb:	68 4f 23 80 00       	push   $0x80234f
  800ac0:	6a 7d                	push   $0x7d
  800ac2:	68 64 23 80 00       	push   $0x802364
  800ac7:	e8 07 0a 00 00       	call   8014d3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800acc:	83 ec 04             	sub    $0x4,%esp
  800acf:	50                   	push   %eax
  800ad0:	68 00 50 80 00       	push   $0x805000
  800ad5:	ff 75 0c             	pushl  0xc(%ebp)
  800ad8:	e8 06 12 00 00       	call   801ce3 <memmove>
	return r;
  800add:	83 c4 10             	add    $0x10,%esp
}
  800ae0:	89 d8                	mov    %ebx,%eax
  800ae2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	53                   	push   %ebx
  800aed:	83 ec 20             	sub    $0x20,%esp
  800af0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800af3:	53                   	push   %ebx
  800af4:	e8 1f 10 00 00       	call   801b18 <strlen>
  800af9:	83 c4 10             	add    $0x10,%esp
  800afc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b01:	7f 67                	jg     800b6a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b03:	83 ec 0c             	sub    $0xc,%esp
  800b06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b09:	50                   	push   %eax
  800b0a:	e8 8e f8 ff ff       	call   80039d <fd_alloc>
  800b0f:	83 c4 10             	add    $0x10,%esp
		return r;
  800b12:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b14:	85 c0                	test   %eax,%eax
  800b16:	78 57                	js     800b6f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b18:	83 ec 08             	sub    $0x8,%esp
  800b1b:	53                   	push   %ebx
  800b1c:	68 00 50 80 00       	push   $0x805000
  800b21:	e8 2b 10 00 00       	call   801b51 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b29:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b31:	b8 01 00 00 00       	mov    $0x1,%eax
  800b36:	e8 ea fd ff ff       	call   800925 <fsipc>
  800b3b:	89 c3                	mov    %eax,%ebx
  800b3d:	83 c4 10             	add    $0x10,%esp
  800b40:	85 c0                	test   %eax,%eax
  800b42:	79 14                	jns    800b58 <open+0x6f>
		fd_close(fd, 0);
  800b44:	83 ec 08             	sub    $0x8,%esp
  800b47:	6a 00                	push   $0x0
  800b49:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4c:	e8 44 f9 ff ff       	call   800495 <fd_close>
		return r;
  800b51:	83 c4 10             	add    $0x10,%esp
  800b54:	89 da                	mov    %ebx,%edx
  800b56:	eb 17                	jmp    800b6f <open+0x86>
	}

	return fd2num(fd);
  800b58:	83 ec 0c             	sub    $0xc,%esp
  800b5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5e:	e8 13 f8 ff ff       	call   800376 <fd2num>
  800b63:	89 c2                	mov    %eax,%edx
  800b65:	83 c4 10             	add    $0x10,%esp
  800b68:	eb 05                	jmp    800b6f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b6a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b6f:	89 d0                	mov    %edx,%eax
  800b71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 08 00 00 00       	mov    $0x8,%eax
  800b86:	e8 9a fd ff ff       	call   800925 <fsipc>
}
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b95:	83 ec 0c             	sub    $0xc,%esp
  800b98:	ff 75 08             	pushl  0x8(%ebp)
  800b9b:	e8 e6 f7 ff ff       	call   800386 <fd2data>
  800ba0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ba2:	83 c4 08             	add    $0x8,%esp
  800ba5:	68 7b 23 80 00       	push   $0x80237b
  800baa:	53                   	push   %ebx
  800bab:	e8 a1 0f 00 00       	call   801b51 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bb0:	8b 46 04             	mov    0x4(%esi),%eax
  800bb3:	2b 06                	sub    (%esi),%eax
  800bb5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bbb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bc2:	00 00 00 
	stat->st_dev = &devpipe;
  800bc5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bcc:	30 80 00 
	return 0;
}
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be5:	53                   	push   %ebx
  800be6:	6a 00                	push   $0x0
  800be8:	e8 fe f5 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bed:	89 1c 24             	mov    %ebx,(%esp)
  800bf0:	e8 91 f7 ff ff       	call   800386 <fd2data>
  800bf5:	83 c4 08             	add    $0x8,%esp
  800bf8:	50                   	push   %eax
  800bf9:	6a 00                	push   $0x0
  800bfb:	e8 eb f5 ff ff       	call   8001eb <sys_page_unmap>
}
  800c00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c03:	c9                   	leave  
  800c04:	c3                   	ret    

00800c05 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 1c             	sub    $0x1c,%esp
  800c0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c11:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c13:	a1 08 40 80 00       	mov    0x804008,%eax
  800c18:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c1b:	83 ec 0c             	sub    $0xc,%esp
  800c1e:	ff 75 e0             	pushl  -0x20(%ebp)
  800c21:	e8 70 13 00 00       	call   801f96 <pageref>
  800c26:	89 c3                	mov    %eax,%ebx
  800c28:	89 3c 24             	mov    %edi,(%esp)
  800c2b:	e8 66 13 00 00       	call   801f96 <pageref>
  800c30:	83 c4 10             	add    $0x10,%esp
  800c33:	39 c3                	cmp    %eax,%ebx
  800c35:	0f 94 c1             	sete   %cl
  800c38:	0f b6 c9             	movzbl %cl,%ecx
  800c3b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c3e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c44:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c47:	39 ce                	cmp    %ecx,%esi
  800c49:	74 1b                	je     800c66 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c4b:	39 c3                	cmp    %eax,%ebx
  800c4d:	75 c4                	jne    800c13 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c4f:	8b 42 58             	mov    0x58(%edx),%eax
  800c52:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c55:	50                   	push   %eax
  800c56:	56                   	push   %esi
  800c57:	68 82 23 80 00       	push   $0x802382
  800c5c:	e8 4b 09 00 00       	call   8015ac <cprintf>
  800c61:	83 c4 10             	add    $0x10,%esp
  800c64:	eb ad                	jmp    800c13 <_pipeisclosed+0xe>
	}
}
  800c66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	83 ec 28             	sub    $0x28,%esp
  800c7a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c7d:	56                   	push   %esi
  800c7e:	e8 03 f7 ff ff       	call   800386 <fd2data>
  800c83:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c85:	83 c4 10             	add    $0x10,%esp
  800c88:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8d:	eb 4b                	jmp    800cda <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c8f:	89 da                	mov    %ebx,%edx
  800c91:	89 f0                	mov    %esi,%eax
  800c93:	e8 6d ff ff ff       	call   800c05 <_pipeisclosed>
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	75 48                	jne    800ce4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c9c:	e8 a6 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ca1:	8b 43 04             	mov    0x4(%ebx),%eax
  800ca4:	8b 0b                	mov    (%ebx),%ecx
  800ca6:	8d 51 20             	lea    0x20(%ecx),%edx
  800ca9:	39 d0                	cmp    %edx,%eax
  800cab:	73 e2                	jae    800c8f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cb4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cb7:	89 c2                	mov    %eax,%edx
  800cb9:	c1 fa 1f             	sar    $0x1f,%edx
  800cbc:	89 d1                	mov    %edx,%ecx
  800cbe:	c1 e9 1b             	shr    $0x1b,%ecx
  800cc1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cc4:	83 e2 1f             	and    $0x1f,%edx
  800cc7:	29 ca                	sub    %ecx,%edx
  800cc9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ccd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cd1:	83 c0 01             	add    $0x1,%eax
  800cd4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd7:	83 c7 01             	add    $0x1,%edi
  800cda:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cdd:	75 c2                	jne    800ca1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cdf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce2:	eb 05                	jmp    800ce9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 18             	sub    $0x18,%esp
  800cfa:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cfd:	57                   	push   %edi
  800cfe:	e8 83 f6 ff ff       	call   800386 <fd2data>
  800d03:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d05:	83 c4 10             	add    $0x10,%esp
  800d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0d:	eb 3d                	jmp    800d4c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d0f:	85 db                	test   %ebx,%ebx
  800d11:	74 04                	je     800d17 <devpipe_read+0x26>
				return i;
  800d13:	89 d8                	mov    %ebx,%eax
  800d15:	eb 44                	jmp    800d5b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d17:	89 f2                	mov    %esi,%edx
  800d19:	89 f8                	mov    %edi,%eax
  800d1b:	e8 e5 fe ff ff       	call   800c05 <_pipeisclosed>
  800d20:	85 c0                	test   %eax,%eax
  800d22:	75 32                	jne    800d56 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d24:	e8 1e f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d29:	8b 06                	mov    (%esi),%eax
  800d2b:	3b 46 04             	cmp    0x4(%esi),%eax
  800d2e:	74 df                	je     800d0f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d30:	99                   	cltd   
  800d31:	c1 ea 1b             	shr    $0x1b,%edx
  800d34:	01 d0                	add    %edx,%eax
  800d36:	83 e0 1f             	and    $0x1f,%eax
  800d39:	29 d0                	sub    %edx,%eax
  800d3b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d46:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d49:	83 c3 01             	add    $0x1,%ebx
  800d4c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d4f:	75 d8                	jne    800d29 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d51:	8b 45 10             	mov    0x10(%ebp),%eax
  800d54:	eb 05                	jmp    800d5b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d56:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d6e:	50                   	push   %eax
  800d6f:	e8 29 f6 ff ff       	call   80039d <fd_alloc>
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	89 c2                	mov    %eax,%edx
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	0f 88 2c 01 00 00    	js     800ead <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d81:	83 ec 04             	sub    $0x4,%esp
  800d84:	68 07 04 00 00       	push   $0x407
  800d89:	ff 75 f4             	pushl  -0xc(%ebp)
  800d8c:	6a 00                	push   $0x0
  800d8e:	e8 d3 f3 ff ff       	call   800166 <sys_page_alloc>
  800d93:	83 c4 10             	add    $0x10,%esp
  800d96:	89 c2                	mov    %eax,%edx
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	0f 88 0d 01 00 00    	js     800ead <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da6:	50                   	push   %eax
  800da7:	e8 f1 f5 ff ff       	call   80039d <fd_alloc>
  800dac:	89 c3                	mov    %eax,%ebx
  800dae:	83 c4 10             	add    $0x10,%esp
  800db1:	85 c0                	test   %eax,%eax
  800db3:	0f 88 e2 00 00 00    	js     800e9b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db9:	83 ec 04             	sub    $0x4,%esp
  800dbc:	68 07 04 00 00       	push   $0x407
  800dc1:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc4:	6a 00                	push   $0x0
  800dc6:	e8 9b f3 ff ff       	call   800166 <sys_page_alloc>
  800dcb:	89 c3                	mov    %eax,%ebx
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	0f 88 c3 00 00 00    	js     800e9b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	ff 75 f4             	pushl  -0xc(%ebp)
  800dde:	e8 a3 f5 ff ff       	call   800386 <fd2data>
  800de3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de5:	83 c4 0c             	add    $0xc,%esp
  800de8:	68 07 04 00 00       	push   $0x407
  800ded:	50                   	push   %eax
  800dee:	6a 00                	push   $0x0
  800df0:	e8 71 f3 ff ff       	call   800166 <sys_page_alloc>
  800df5:	89 c3                	mov    %eax,%ebx
  800df7:	83 c4 10             	add    $0x10,%esp
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	0f 88 89 00 00 00    	js     800e8b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e02:	83 ec 0c             	sub    $0xc,%esp
  800e05:	ff 75 f0             	pushl  -0x10(%ebp)
  800e08:	e8 79 f5 ff ff       	call   800386 <fd2data>
  800e0d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e14:	50                   	push   %eax
  800e15:	6a 00                	push   $0x0
  800e17:	56                   	push   %esi
  800e18:	6a 00                	push   $0x0
  800e1a:	e8 8a f3 ff ff       	call   8001a9 <sys_page_map>
  800e1f:	89 c3                	mov    %eax,%ebx
  800e21:	83 c4 20             	add    $0x20,%esp
  800e24:	85 c0                	test   %eax,%eax
  800e26:	78 55                	js     800e7d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e28:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e31:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e36:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e3d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e46:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e4b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e52:	83 ec 0c             	sub    $0xc,%esp
  800e55:	ff 75 f4             	pushl  -0xc(%ebp)
  800e58:	e8 19 f5 ff ff       	call   800376 <fd2num>
  800e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e60:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e62:	83 c4 04             	add    $0x4,%esp
  800e65:	ff 75 f0             	pushl  -0x10(%ebp)
  800e68:	e8 09 f5 ff ff       	call   800376 <fd2num>
  800e6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e70:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7b:	eb 30                	jmp    800ead <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e7d:	83 ec 08             	sub    $0x8,%esp
  800e80:	56                   	push   %esi
  800e81:	6a 00                	push   $0x0
  800e83:	e8 63 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e88:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e8b:	83 ec 08             	sub    $0x8,%esp
  800e8e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e91:	6a 00                	push   $0x0
  800e93:	e8 53 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e98:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e9b:	83 ec 08             	sub    $0x8,%esp
  800e9e:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea1:	6a 00                	push   $0x0
  800ea3:	e8 43 f3 ff ff       	call   8001eb <sys_page_unmap>
  800ea8:	83 c4 10             	add    $0x10,%esp
  800eab:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ead:	89 d0                	mov    %edx,%eax
  800eaf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb2:	5b                   	pop    %ebx
  800eb3:	5e                   	pop    %esi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ebc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebf:	50                   	push   %eax
  800ec0:	ff 75 08             	pushl  0x8(%ebp)
  800ec3:	e8 24 f5 ff ff       	call   8003ec <fd_lookup>
  800ec8:	83 c4 10             	add    $0x10,%esp
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	78 18                	js     800ee7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ecf:	83 ec 0c             	sub    $0xc,%esp
  800ed2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed5:	e8 ac f4 ff ff       	call   800386 <fd2data>
	return _pipeisclosed(fd, p);
  800eda:	89 c2                	mov    %eax,%edx
  800edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800edf:	e8 21 fd ff ff       	call   800c05 <_pipeisclosed>
  800ee4:	83 c4 10             	add    $0x10,%esp
}
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    

00800ee9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800eef:	68 9a 23 80 00       	push   $0x80239a
  800ef4:	ff 75 0c             	pushl  0xc(%ebp)
  800ef7:	e8 55 0c 00 00       	call   801b51 <strcpy>
	return 0;
}
  800efc:	b8 00 00 00 00       	mov    $0x0,%eax
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	53                   	push   %ebx
  800f07:	83 ec 10             	sub    $0x10,%esp
  800f0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800f0d:	53                   	push   %ebx
  800f0e:	e8 83 10 00 00       	call   801f96 <pageref>
  800f13:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800f16:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800f1b:	83 f8 01             	cmp    $0x1,%eax
  800f1e:	75 10                	jne    800f30 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	ff 73 0c             	pushl  0xc(%ebx)
  800f26:	e8 c0 02 00 00       	call   8011eb <nsipc_close>
  800f2b:	89 c2                	mov    %eax,%edx
  800f2d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f30:	89 d0                	mov    %edx,%eax
  800f32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    

00800f37 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f3d:	6a 00                	push   $0x0
  800f3f:	ff 75 10             	pushl  0x10(%ebp)
  800f42:	ff 75 0c             	pushl  0xc(%ebp)
  800f45:	8b 45 08             	mov    0x8(%ebp),%eax
  800f48:	ff 70 0c             	pushl  0xc(%eax)
  800f4b:	e8 78 03 00 00       	call   8012c8 <nsipc_send>
}
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f58:	6a 00                	push   $0x0
  800f5a:	ff 75 10             	pushl  0x10(%ebp)
  800f5d:	ff 75 0c             	pushl  0xc(%ebp)
  800f60:	8b 45 08             	mov    0x8(%ebp),%eax
  800f63:	ff 70 0c             	pushl  0xc(%eax)
  800f66:	e8 f1 02 00 00       	call   80125c <nsipc_recv>
}
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    

00800f6d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f73:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f76:	52                   	push   %edx
  800f77:	50                   	push   %eax
  800f78:	e8 6f f4 ff ff       	call   8003ec <fd_lookup>
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 17                	js     800f9b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f87:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  800f8d:	39 08                	cmp    %ecx,(%eax)
  800f8f:	75 05                	jne    800f96 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f91:	8b 40 0c             	mov    0xc(%eax),%eax
  800f94:	eb 05                	jmp    800f9b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800f96:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	56                   	push   %esi
  800fa1:	53                   	push   %ebx
  800fa2:	83 ec 1c             	sub    $0x1c,%esp
  800fa5:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800fa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800faa:	50                   	push   %eax
  800fab:	e8 ed f3 ff ff       	call   80039d <fd_alloc>
  800fb0:	89 c3                	mov    %eax,%ebx
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	78 1b                	js     800fd4 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	68 07 04 00 00       	push   $0x407
  800fc1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 9b f1 ff ff       	call   800166 <sys_page_alloc>
  800fcb:	89 c3                	mov    %eax,%ebx
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 10                	jns    800fe4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800fd4:	83 ec 0c             	sub    $0xc,%esp
  800fd7:	56                   	push   %esi
  800fd8:	e8 0e 02 00 00       	call   8011eb <nsipc_close>
		return r;
  800fdd:	83 c4 10             	add    $0x10,%esp
  800fe0:	89 d8                	mov    %ebx,%eax
  800fe2:	eb 24                	jmp    801008 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800fe4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fed:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ff9:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	50                   	push   %eax
  801000:	e8 71 f3 ff ff       	call   800376 <fd2num>
  801005:	83 c4 10             	add    $0x10,%esp
}
  801008:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801015:	8b 45 08             	mov    0x8(%ebp),%eax
  801018:	e8 50 ff ff ff       	call   800f6d <fd2sockid>
		return r;
  80101d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80101f:	85 c0                	test   %eax,%eax
  801021:	78 1f                	js     801042 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	ff 75 10             	pushl  0x10(%ebp)
  801029:	ff 75 0c             	pushl  0xc(%ebp)
  80102c:	50                   	push   %eax
  80102d:	e8 12 01 00 00       	call   801144 <nsipc_accept>
  801032:	83 c4 10             	add    $0x10,%esp
		return r;
  801035:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801037:	85 c0                	test   %eax,%eax
  801039:	78 07                	js     801042 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80103b:	e8 5d ff ff ff       	call   800f9d <alloc_sockfd>
  801040:	89 c1                	mov    %eax,%ecx
}
  801042:	89 c8                	mov    %ecx,%eax
  801044:	c9                   	leave  
  801045:	c3                   	ret    

00801046 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80104c:	8b 45 08             	mov    0x8(%ebp),%eax
  80104f:	e8 19 ff ff ff       	call   800f6d <fd2sockid>
  801054:	85 c0                	test   %eax,%eax
  801056:	78 12                	js     80106a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801058:	83 ec 04             	sub    $0x4,%esp
  80105b:	ff 75 10             	pushl  0x10(%ebp)
  80105e:	ff 75 0c             	pushl  0xc(%ebp)
  801061:	50                   	push   %eax
  801062:	e8 2d 01 00 00       	call   801194 <nsipc_bind>
  801067:	83 c4 10             	add    $0x10,%esp
}
  80106a:	c9                   	leave  
  80106b:	c3                   	ret    

0080106c <shutdown>:

int
shutdown(int s, int how)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801072:	8b 45 08             	mov    0x8(%ebp),%eax
  801075:	e8 f3 fe ff ff       	call   800f6d <fd2sockid>
  80107a:	85 c0                	test   %eax,%eax
  80107c:	78 0f                	js     80108d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80107e:	83 ec 08             	sub    $0x8,%esp
  801081:	ff 75 0c             	pushl  0xc(%ebp)
  801084:	50                   	push   %eax
  801085:	e8 3f 01 00 00       	call   8011c9 <nsipc_shutdown>
  80108a:	83 c4 10             	add    $0x10,%esp
}
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    

0080108f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801095:	8b 45 08             	mov    0x8(%ebp),%eax
  801098:	e8 d0 fe ff ff       	call   800f6d <fd2sockid>
  80109d:	85 c0                	test   %eax,%eax
  80109f:	78 12                	js     8010b3 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8010a1:	83 ec 04             	sub    $0x4,%esp
  8010a4:	ff 75 10             	pushl  0x10(%ebp)
  8010a7:	ff 75 0c             	pushl  0xc(%ebp)
  8010aa:	50                   	push   %eax
  8010ab:	e8 55 01 00 00       	call   801205 <nsipc_connect>
  8010b0:	83 c4 10             	add    $0x10,%esp
}
  8010b3:	c9                   	leave  
  8010b4:	c3                   	ret    

008010b5 <listen>:

int
listen(int s, int backlog)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	e8 aa fe ff ff       	call   800f6d <fd2sockid>
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	78 0f                	js     8010d6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	ff 75 0c             	pushl  0xc(%ebp)
  8010cd:	50                   	push   %eax
  8010ce:	e8 67 01 00 00       	call   80123a <nsipc_listen>
  8010d3:	83 c4 10             	add    $0x10,%esp
}
  8010d6:	c9                   	leave  
  8010d7:	c3                   	ret    

008010d8 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8010de:	ff 75 10             	pushl  0x10(%ebp)
  8010e1:	ff 75 0c             	pushl  0xc(%ebp)
  8010e4:	ff 75 08             	pushl  0x8(%ebp)
  8010e7:	e8 3a 02 00 00       	call   801326 <nsipc_socket>
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	78 05                	js     8010f8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8010f3:	e8 a5 fe ff ff       	call   800f9d <alloc_sockfd>
}
  8010f8:	c9                   	leave  
  8010f9:	c3                   	ret    

008010fa <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 04             	sub    $0x4,%esp
  801101:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801103:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80110a:	75 12                	jne    80111e <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	6a 02                	push   $0x2
  801111:	e8 47 0e 00 00       	call   801f5d <ipc_find_env>
  801116:	a3 04 40 80 00       	mov    %eax,0x804004
  80111b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80111e:	6a 07                	push   $0x7
  801120:	68 00 60 80 00       	push   $0x806000
  801125:	53                   	push   %ebx
  801126:	ff 35 04 40 80 00    	pushl  0x804004
  80112c:	e8 dd 0d 00 00       	call   801f0e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801131:	83 c4 0c             	add    $0xc,%esp
  801134:	6a 00                	push   $0x0
  801136:	6a 00                	push   $0x0
  801138:	6a 00                	push   $0x0
  80113a:	e8 59 0d 00 00       	call   801e98 <ipc_recv>
}
  80113f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801142:	c9                   	leave  
  801143:	c3                   	ret    

00801144 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80114c:	8b 45 08             	mov    0x8(%ebp),%eax
  80114f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801154:	8b 06                	mov    (%esi),%eax
  801156:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80115b:	b8 01 00 00 00       	mov    $0x1,%eax
  801160:	e8 95 ff ff ff       	call   8010fa <nsipc>
  801165:	89 c3                	mov    %eax,%ebx
  801167:	85 c0                	test   %eax,%eax
  801169:	78 20                	js     80118b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80116b:	83 ec 04             	sub    $0x4,%esp
  80116e:	ff 35 10 60 80 00    	pushl  0x806010
  801174:	68 00 60 80 00       	push   $0x806000
  801179:	ff 75 0c             	pushl  0xc(%ebp)
  80117c:	e8 62 0b 00 00       	call   801ce3 <memmove>
		*addrlen = ret->ret_addrlen;
  801181:	a1 10 60 80 00       	mov    0x806010,%eax
  801186:	89 06                	mov    %eax,(%esi)
  801188:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80118b:	89 d8                	mov    %ebx,%eax
  80118d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801190:	5b                   	pop    %ebx
  801191:	5e                   	pop    %esi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	53                   	push   %ebx
  801198:	83 ec 08             	sub    $0x8,%esp
  80119b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80119e:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8011a6:	53                   	push   %ebx
  8011a7:	ff 75 0c             	pushl  0xc(%ebp)
  8011aa:	68 04 60 80 00       	push   $0x806004
  8011af:	e8 2f 0b 00 00       	call   801ce3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8011b4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8011ba:	b8 02 00 00 00       	mov    $0x2,%eax
  8011bf:	e8 36 ff ff ff       	call   8010fa <nsipc>
}
  8011c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c7:	c9                   	leave  
  8011c8:	c3                   	ret    

008011c9 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8011d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011da:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8011df:	b8 03 00 00 00       	mov    $0x3,%eax
  8011e4:	e8 11 ff ff ff       	call   8010fa <nsipc>
}
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <nsipc_close>:

int
nsipc_close(int s)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f4:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8011f9:	b8 04 00 00 00       	mov    $0x4,%eax
  8011fe:	e8 f7 fe ff ff       	call   8010fa <nsipc>
}
  801203:	c9                   	leave  
  801204:	c3                   	ret    

00801205 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	53                   	push   %ebx
  801209:	83 ec 08             	sub    $0x8,%esp
  80120c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80120f:	8b 45 08             	mov    0x8(%ebp),%eax
  801212:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801217:	53                   	push   %ebx
  801218:	ff 75 0c             	pushl  0xc(%ebp)
  80121b:	68 04 60 80 00       	push   $0x806004
  801220:	e8 be 0a 00 00       	call   801ce3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801225:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80122b:	b8 05 00 00 00       	mov    $0x5,%eax
  801230:	e8 c5 fe ff ff       	call   8010fa <nsipc>
}
  801235:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801240:	8b 45 08             	mov    0x8(%ebp),%eax
  801243:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801248:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801250:	b8 06 00 00 00       	mov    $0x6,%eax
  801255:	e8 a0 fe ff ff       	call   8010fa <nsipc>
}
  80125a:	c9                   	leave  
  80125b:	c3                   	ret    

0080125c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	56                   	push   %esi
  801260:	53                   	push   %ebx
  801261:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801264:	8b 45 08             	mov    0x8(%ebp),%eax
  801267:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80126c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801272:	8b 45 14             	mov    0x14(%ebp),%eax
  801275:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80127a:	b8 07 00 00 00       	mov    $0x7,%eax
  80127f:	e8 76 fe ff ff       	call   8010fa <nsipc>
  801284:	89 c3                	mov    %eax,%ebx
  801286:	85 c0                	test   %eax,%eax
  801288:	78 35                	js     8012bf <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80128a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80128f:	7f 04                	jg     801295 <nsipc_recv+0x39>
  801291:	39 c6                	cmp    %eax,%esi
  801293:	7d 16                	jge    8012ab <nsipc_recv+0x4f>
  801295:	68 a6 23 80 00       	push   $0x8023a6
  80129a:	68 4f 23 80 00       	push   $0x80234f
  80129f:	6a 62                	push   $0x62
  8012a1:	68 bb 23 80 00       	push   $0x8023bb
  8012a6:	e8 28 02 00 00       	call   8014d3 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8012ab:	83 ec 04             	sub    $0x4,%esp
  8012ae:	50                   	push   %eax
  8012af:	68 00 60 80 00       	push   $0x806000
  8012b4:	ff 75 0c             	pushl  0xc(%ebp)
  8012b7:	e8 27 0a 00 00       	call   801ce3 <memmove>
  8012bc:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8012bf:	89 d8                	mov    %ebx,%eax
  8012c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 04             	sub    $0x4,%esp
  8012cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8012d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d5:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8012da:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8012e0:	7e 16                	jle    8012f8 <nsipc_send+0x30>
  8012e2:	68 c7 23 80 00       	push   $0x8023c7
  8012e7:	68 4f 23 80 00       	push   $0x80234f
  8012ec:	6a 6d                	push   $0x6d
  8012ee:	68 bb 23 80 00       	push   $0x8023bb
  8012f3:	e8 db 01 00 00       	call   8014d3 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8012f8:	83 ec 04             	sub    $0x4,%esp
  8012fb:	53                   	push   %ebx
  8012fc:	ff 75 0c             	pushl  0xc(%ebp)
  8012ff:	68 0c 60 80 00       	push   $0x80600c
  801304:	e8 da 09 00 00       	call   801ce3 <memmove>
	nsipcbuf.send.req_size = size;
  801309:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80130f:	8b 45 14             	mov    0x14(%ebp),%eax
  801312:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801317:	b8 08 00 00 00       	mov    $0x8,%eax
  80131c:	e8 d9 fd ff ff       	call   8010fa <nsipc>
}
  801321:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80132c:	8b 45 08             	mov    0x8(%ebp),%eax
  80132f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801334:	8b 45 0c             	mov    0xc(%ebp),%eax
  801337:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80133c:	8b 45 10             	mov    0x10(%ebp),%eax
  80133f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801344:	b8 09 00 00 00       	mov    $0x9,%eax
  801349:	e8 ac fd ff ff       	call   8010fa <nsipc>
}
  80134e:	c9                   	leave  
  80134f:	c3                   	ret    

00801350 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801353:	b8 00 00 00 00       	mov    $0x0,%eax
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801360:	68 d3 23 80 00       	push   $0x8023d3
  801365:	ff 75 0c             	pushl  0xc(%ebp)
  801368:	e8 e4 07 00 00       	call   801b51 <strcpy>
	return 0;
}
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
  801372:	c9                   	leave  
  801373:	c3                   	ret    

00801374 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	57                   	push   %edi
  801378:	56                   	push   %esi
  801379:	53                   	push   %ebx
  80137a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801380:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801385:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80138b:	eb 2d                	jmp    8013ba <devcons_write+0x46>
		m = n - tot;
  80138d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801390:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801392:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801395:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80139a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80139d:	83 ec 04             	sub    $0x4,%esp
  8013a0:	53                   	push   %ebx
  8013a1:	03 45 0c             	add    0xc(%ebp),%eax
  8013a4:	50                   	push   %eax
  8013a5:	57                   	push   %edi
  8013a6:	e8 38 09 00 00       	call   801ce3 <memmove>
		sys_cputs(buf, m);
  8013ab:	83 c4 08             	add    $0x8,%esp
  8013ae:	53                   	push   %ebx
  8013af:	57                   	push   %edi
  8013b0:	e8 f5 ec ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b5:	01 de                	add    %ebx,%esi
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	89 f0                	mov    %esi,%eax
  8013bc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013bf:	72 cc                	jb     80138d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c4:	5b                   	pop    %ebx
  8013c5:	5e                   	pop    %esi
  8013c6:	5f                   	pop    %edi
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    

008013c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013d8:	74 2a                	je     801404 <devcons_read+0x3b>
  8013da:	eb 05                	jmp    8013e1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013dc:	e8 66 ed ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013e1:	e8 e2 ec ff ff       	call   8000c8 <sys_cgetc>
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	74 f2                	je     8013dc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 16                	js     801404 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013ee:	83 f8 04             	cmp    $0x4,%eax
  8013f1:	74 0c                	je     8013ff <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f6:	88 02                	mov    %al,(%edx)
	return 1;
  8013f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8013fd:	eb 05                	jmp    801404 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013ff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801404:	c9                   	leave  
  801405:	c3                   	ret    

00801406 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80140c:	8b 45 08             	mov    0x8(%ebp),%eax
  80140f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801412:	6a 01                	push   $0x1
  801414:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	e8 8d ec ff ff       	call   8000aa <sys_cputs>
}
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	c9                   	leave  
  801421:	c3                   	ret    

00801422 <getchar>:

int
getchar(void)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801428:	6a 01                	push   $0x1
  80142a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	6a 00                	push   $0x0
  801430:	e8 1d f2 ff ff       	call   800652 <read>
	if (r < 0)
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 0f                	js     80144b <getchar+0x29>
		return r;
	if (r < 1)
  80143c:	85 c0                	test   %eax,%eax
  80143e:	7e 06                	jle    801446 <getchar+0x24>
		return -E_EOF;
	return c;
  801440:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801444:	eb 05                	jmp    80144b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801446:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80144b:	c9                   	leave  
  80144c:	c3                   	ret    

0080144d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801453:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	ff 75 08             	pushl  0x8(%ebp)
  80145a:	e8 8d ef ff ff       	call   8003ec <fd_lookup>
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 11                	js     801477 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801466:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801469:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80146f:	39 10                	cmp    %edx,(%eax)
  801471:	0f 94 c0             	sete   %al
  801474:	0f b6 c0             	movzbl %al,%eax
}
  801477:	c9                   	leave  
  801478:	c3                   	ret    

00801479 <opencons>:

int
opencons(void)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80147f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	e8 15 ef ff ff       	call   80039d <fd_alloc>
  801488:	83 c4 10             	add    $0x10,%esp
		return r;
  80148b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 3e                	js     8014cf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801491:	83 ec 04             	sub    $0x4,%esp
  801494:	68 07 04 00 00       	push   $0x407
  801499:	ff 75 f4             	pushl  -0xc(%ebp)
  80149c:	6a 00                	push   $0x0
  80149e:	e8 c3 ec ff ff       	call   800166 <sys_page_alloc>
  8014a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 23                	js     8014cf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014ac:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014c1:	83 ec 0c             	sub    $0xc,%esp
  8014c4:	50                   	push   %eax
  8014c5:	e8 ac ee ff ff       	call   800376 <fd2num>
  8014ca:	89 c2                	mov    %eax,%edx
  8014cc:	83 c4 10             	add    $0x10,%esp
}
  8014cf:	89 d0                	mov    %edx,%eax
  8014d1:	c9                   	leave  
  8014d2:	c3                   	ret    

008014d3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	56                   	push   %esi
  8014d7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014d8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014db:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014e1:	e8 42 ec ff ff       	call   800128 <sys_getenvid>
  8014e6:	83 ec 0c             	sub    $0xc,%esp
  8014e9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ec:	ff 75 08             	pushl  0x8(%ebp)
  8014ef:	56                   	push   %esi
  8014f0:	50                   	push   %eax
  8014f1:	68 e0 23 80 00       	push   $0x8023e0
  8014f6:	e8 b1 00 00 00       	call   8015ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014fb:	83 c4 18             	add    $0x18,%esp
  8014fe:	53                   	push   %ebx
  8014ff:	ff 75 10             	pushl  0x10(%ebp)
  801502:	e8 54 00 00 00       	call   80155b <vcprintf>
	cprintf("\n");
  801507:	c7 04 24 93 23 80 00 	movl   $0x802393,(%esp)
  80150e:	e8 99 00 00 00       	call   8015ac <cprintf>
  801513:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801516:	cc                   	int3   
  801517:	eb fd                	jmp    801516 <_panic+0x43>

00801519 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	53                   	push   %ebx
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801523:	8b 13                	mov    (%ebx),%edx
  801525:	8d 42 01             	lea    0x1(%edx),%eax
  801528:	89 03                	mov    %eax,(%ebx)
  80152a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80152d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801531:	3d ff 00 00 00       	cmp    $0xff,%eax
  801536:	75 1a                	jne    801552 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	68 ff 00 00 00       	push   $0xff
  801540:	8d 43 08             	lea    0x8(%ebx),%eax
  801543:	50                   	push   %eax
  801544:	e8 61 eb ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  801549:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80154f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801552:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801556:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801564:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80156b:	00 00 00 
	b.cnt = 0;
  80156e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801575:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801578:	ff 75 0c             	pushl  0xc(%ebp)
  80157b:	ff 75 08             	pushl  0x8(%ebp)
  80157e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	68 19 15 80 00       	push   $0x801519
  80158a:	e8 54 01 00 00       	call   8016e3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80158f:	83 c4 08             	add    $0x8,%esp
  801592:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801598:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80159e:	50                   	push   %eax
  80159f:	e8 06 eb ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  8015a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015b5:	50                   	push   %eax
  8015b6:	ff 75 08             	pushl  0x8(%ebp)
  8015b9:	e8 9d ff ff ff       	call   80155b <vcprintf>
	va_end(ap);

	return cnt;
}
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	57                   	push   %edi
  8015c4:	56                   	push   %esi
  8015c5:	53                   	push   %ebx
  8015c6:	83 ec 1c             	sub    $0x1c,%esp
  8015c9:	89 c7                	mov    %eax,%edi
  8015cb:	89 d6                	mov    %edx,%esi
  8015cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015e4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015e7:	39 d3                	cmp    %edx,%ebx
  8015e9:	72 05                	jb     8015f0 <printnum+0x30>
  8015eb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015ee:	77 45                	ja     801635 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015f0:	83 ec 0c             	sub    $0xc,%esp
  8015f3:	ff 75 18             	pushl  0x18(%ebp)
  8015f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015fc:	53                   	push   %ebx
  8015fd:	ff 75 10             	pushl  0x10(%ebp)
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	ff 75 e4             	pushl  -0x1c(%ebp)
  801606:	ff 75 e0             	pushl  -0x20(%ebp)
  801609:	ff 75 dc             	pushl  -0x24(%ebp)
  80160c:	ff 75 d8             	pushl  -0x28(%ebp)
  80160f:	e8 cc 09 00 00       	call   801fe0 <__udivdi3>
  801614:	83 c4 18             	add    $0x18,%esp
  801617:	52                   	push   %edx
  801618:	50                   	push   %eax
  801619:	89 f2                	mov    %esi,%edx
  80161b:	89 f8                	mov    %edi,%eax
  80161d:	e8 9e ff ff ff       	call   8015c0 <printnum>
  801622:	83 c4 20             	add    $0x20,%esp
  801625:	eb 18                	jmp    80163f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	56                   	push   %esi
  80162b:	ff 75 18             	pushl  0x18(%ebp)
  80162e:	ff d7                	call   *%edi
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	eb 03                	jmp    801638 <printnum+0x78>
  801635:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801638:	83 eb 01             	sub    $0x1,%ebx
  80163b:	85 db                	test   %ebx,%ebx
  80163d:	7f e8                	jg     801627 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	56                   	push   %esi
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	ff 75 e4             	pushl  -0x1c(%ebp)
  801649:	ff 75 e0             	pushl  -0x20(%ebp)
  80164c:	ff 75 dc             	pushl  -0x24(%ebp)
  80164f:	ff 75 d8             	pushl  -0x28(%ebp)
  801652:	e8 b9 0a 00 00       	call   802110 <__umoddi3>
  801657:	83 c4 14             	add    $0x14,%esp
  80165a:	0f be 80 03 24 80 00 	movsbl 0x802403(%eax),%eax
  801661:	50                   	push   %eax
  801662:	ff d7                	call   *%edi
}
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166a:	5b                   	pop    %ebx
  80166b:	5e                   	pop    %esi
  80166c:	5f                   	pop    %edi
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    

0080166f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801672:	83 fa 01             	cmp    $0x1,%edx
  801675:	7e 0e                	jle    801685 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801677:	8b 10                	mov    (%eax),%edx
  801679:	8d 4a 08             	lea    0x8(%edx),%ecx
  80167c:	89 08                	mov    %ecx,(%eax)
  80167e:	8b 02                	mov    (%edx),%eax
  801680:	8b 52 04             	mov    0x4(%edx),%edx
  801683:	eb 22                	jmp    8016a7 <getuint+0x38>
	else if (lflag)
  801685:	85 d2                	test   %edx,%edx
  801687:	74 10                	je     801699 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801689:	8b 10                	mov    (%eax),%edx
  80168b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80168e:	89 08                	mov    %ecx,(%eax)
  801690:	8b 02                	mov    (%edx),%eax
  801692:	ba 00 00 00 00       	mov    $0x0,%edx
  801697:	eb 0e                	jmp    8016a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801699:	8b 10                	mov    (%eax),%edx
  80169b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80169e:	89 08                	mov    %ecx,(%eax)
  8016a0:	8b 02                	mov    (%edx),%eax
  8016a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    

008016a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016b3:	8b 10                	mov    (%eax),%edx
  8016b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8016b8:	73 0a                	jae    8016c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016bd:	89 08                	mov    %ecx,(%eax)
  8016bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c2:	88 02                	mov    %al,(%edx)
}
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016cf:	50                   	push   %eax
  8016d0:	ff 75 10             	pushl  0x10(%ebp)
  8016d3:	ff 75 0c             	pushl  0xc(%ebp)
  8016d6:	ff 75 08             	pushl  0x8(%ebp)
  8016d9:	e8 05 00 00 00       	call   8016e3 <vprintfmt>
	va_end(ap);
}
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	57                   	push   %edi
  8016e7:	56                   	push   %esi
  8016e8:	53                   	push   %ebx
  8016e9:	83 ec 2c             	sub    $0x2c,%esp
  8016ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016f2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016f5:	eb 12                	jmp    801709 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	0f 84 a9 03 00 00    	je     801aa8 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	53                   	push   %ebx
  801703:	50                   	push   %eax
  801704:	ff d6                	call   *%esi
  801706:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801709:	83 c7 01             	add    $0x1,%edi
  80170c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801710:	83 f8 25             	cmp    $0x25,%eax
  801713:	75 e2                	jne    8016f7 <vprintfmt+0x14>
  801715:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801719:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801720:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801727:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80172e:	ba 00 00 00 00       	mov    $0x0,%edx
  801733:	eb 07                	jmp    80173c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801735:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801738:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80173c:	8d 47 01             	lea    0x1(%edi),%eax
  80173f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801742:	0f b6 07             	movzbl (%edi),%eax
  801745:	0f b6 c8             	movzbl %al,%ecx
  801748:	83 e8 23             	sub    $0x23,%eax
  80174b:	3c 55                	cmp    $0x55,%al
  80174d:	0f 87 3a 03 00 00    	ja     801a8d <vprintfmt+0x3aa>
  801753:	0f b6 c0             	movzbl %al,%eax
  801756:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  80175d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801760:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801764:	eb d6                	jmp    80173c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801766:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801769:	b8 00 00 00 00       	mov    $0x0,%eax
  80176e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801771:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801774:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801778:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80177b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80177e:	83 fa 09             	cmp    $0x9,%edx
  801781:	77 39                	ja     8017bc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801783:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801786:	eb e9                	jmp    801771 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801788:	8b 45 14             	mov    0x14(%ebp),%eax
  80178b:	8d 48 04             	lea    0x4(%eax),%ecx
  80178e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801791:	8b 00                	mov    (%eax),%eax
  801793:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801796:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801799:	eb 27                	jmp    8017c2 <vprintfmt+0xdf>
  80179b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017a5:	0f 49 c8             	cmovns %eax,%ecx
  8017a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ae:	eb 8c                	jmp    80173c <vprintfmt+0x59>
  8017b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017b3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017ba:	eb 80                	jmp    80173c <vprintfmt+0x59>
  8017bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017bf:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017c6:	0f 89 70 ff ff ff    	jns    80173c <vprintfmt+0x59>
				width = precision, precision = -1;
  8017cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017d9:	e9 5e ff ff ff       	jmp    80173c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017de:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017e4:	e9 53 ff ff ff       	jmp    80173c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ec:	8d 50 04             	lea    0x4(%eax),%edx
  8017ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	53                   	push   %ebx
  8017f6:	ff 30                	pushl  (%eax)
  8017f8:	ff d6                	call   *%esi
			break;
  8017fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801800:	e9 04 ff ff ff       	jmp    801709 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801805:	8b 45 14             	mov    0x14(%ebp),%eax
  801808:	8d 50 04             	lea    0x4(%eax),%edx
  80180b:	89 55 14             	mov    %edx,0x14(%ebp)
  80180e:	8b 00                	mov    (%eax),%eax
  801810:	99                   	cltd   
  801811:	31 d0                	xor    %edx,%eax
  801813:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801815:	83 f8 0f             	cmp    $0xf,%eax
  801818:	7f 0b                	jg     801825 <vprintfmt+0x142>
  80181a:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  801821:	85 d2                	test   %edx,%edx
  801823:	75 18                	jne    80183d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801825:	50                   	push   %eax
  801826:	68 1b 24 80 00       	push   $0x80241b
  80182b:	53                   	push   %ebx
  80182c:	56                   	push   %esi
  80182d:	e8 94 fe ff ff       	call   8016c6 <printfmt>
  801832:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801835:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801838:	e9 cc fe ff ff       	jmp    801709 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80183d:	52                   	push   %edx
  80183e:	68 61 23 80 00       	push   $0x802361
  801843:	53                   	push   %ebx
  801844:	56                   	push   %esi
  801845:	e8 7c fe ff ff       	call   8016c6 <printfmt>
  80184a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801850:	e9 b4 fe ff ff       	jmp    801709 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801855:	8b 45 14             	mov    0x14(%ebp),%eax
  801858:	8d 50 04             	lea    0x4(%eax),%edx
  80185b:	89 55 14             	mov    %edx,0x14(%ebp)
  80185e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801860:	85 ff                	test   %edi,%edi
  801862:	b8 14 24 80 00       	mov    $0x802414,%eax
  801867:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80186a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80186e:	0f 8e 94 00 00 00    	jle    801908 <vprintfmt+0x225>
  801874:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801878:	0f 84 98 00 00 00    	je     801916 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80187e:	83 ec 08             	sub    $0x8,%esp
  801881:	ff 75 d0             	pushl  -0x30(%ebp)
  801884:	57                   	push   %edi
  801885:	e8 a6 02 00 00       	call   801b30 <strnlen>
  80188a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80188d:	29 c1                	sub    %eax,%ecx
  80188f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801892:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801895:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801899:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80189c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80189f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a1:	eb 0f                	jmp    8018b2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	53                   	push   %ebx
  8018a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8018aa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ac:	83 ef 01             	sub    $0x1,%edi
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	85 ff                	test   %edi,%edi
  8018b4:	7f ed                	jg     8018a3 <vprintfmt+0x1c0>
  8018b6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018b9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018bc:	85 c9                	test   %ecx,%ecx
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c3:	0f 49 c1             	cmovns %ecx,%eax
  8018c6:	29 c1                	sub    %eax,%ecx
  8018c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8018cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018d1:	89 cb                	mov    %ecx,%ebx
  8018d3:	eb 4d                	jmp    801922 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018d5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018d9:	74 1b                	je     8018f6 <vprintfmt+0x213>
  8018db:	0f be c0             	movsbl %al,%eax
  8018de:	83 e8 20             	sub    $0x20,%eax
  8018e1:	83 f8 5e             	cmp    $0x5e,%eax
  8018e4:	76 10                	jbe    8018f6 <vprintfmt+0x213>
					putch('?', putdat);
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	ff 75 0c             	pushl  0xc(%ebp)
  8018ec:	6a 3f                	push   $0x3f
  8018ee:	ff 55 08             	call   *0x8(%ebp)
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	eb 0d                	jmp    801903 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018f6:	83 ec 08             	sub    $0x8,%esp
  8018f9:	ff 75 0c             	pushl  0xc(%ebp)
  8018fc:	52                   	push   %edx
  8018fd:	ff 55 08             	call   *0x8(%ebp)
  801900:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801903:	83 eb 01             	sub    $0x1,%ebx
  801906:	eb 1a                	jmp    801922 <vprintfmt+0x23f>
  801908:	89 75 08             	mov    %esi,0x8(%ebp)
  80190b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80190e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801911:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801914:	eb 0c                	jmp    801922 <vprintfmt+0x23f>
  801916:	89 75 08             	mov    %esi,0x8(%ebp)
  801919:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80191c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80191f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801922:	83 c7 01             	add    $0x1,%edi
  801925:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801929:	0f be d0             	movsbl %al,%edx
  80192c:	85 d2                	test   %edx,%edx
  80192e:	74 23                	je     801953 <vprintfmt+0x270>
  801930:	85 f6                	test   %esi,%esi
  801932:	78 a1                	js     8018d5 <vprintfmt+0x1f2>
  801934:	83 ee 01             	sub    $0x1,%esi
  801937:	79 9c                	jns    8018d5 <vprintfmt+0x1f2>
  801939:	89 df                	mov    %ebx,%edi
  80193b:	8b 75 08             	mov    0x8(%ebp),%esi
  80193e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801941:	eb 18                	jmp    80195b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801943:	83 ec 08             	sub    $0x8,%esp
  801946:	53                   	push   %ebx
  801947:	6a 20                	push   $0x20
  801949:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80194b:	83 ef 01             	sub    $0x1,%edi
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	eb 08                	jmp    80195b <vprintfmt+0x278>
  801953:	89 df                	mov    %ebx,%edi
  801955:	8b 75 08             	mov    0x8(%ebp),%esi
  801958:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80195b:	85 ff                	test   %edi,%edi
  80195d:	7f e4                	jg     801943 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80195f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801962:	e9 a2 fd ff ff       	jmp    801709 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801967:	83 fa 01             	cmp    $0x1,%edx
  80196a:	7e 16                	jle    801982 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80196c:	8b 45 14             	mov    0x14(%ebp),%eax
  80196f:	8d 50 08             	lea    0x8(%eax),%edx
  801972:	89 55 14             	mov    %edx,0x14(%ebp)
  801975:	8b 50 04             	mov    0x4(%eax),%edx
  801978:	8b 00                	mov    (%eax),%eax
  80197a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80197d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801980:	eb 32                	jmp    8019b4 <vprintfmt+0x2d1>
	else if (lflag)
  801982:	85 d2                	test   %edx,%edx
  801984:	74 18                	je     80199e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801986:	8b 45 14             	mov    0x14(%ebp),%eax
  801989:	8d 50 04             	lea    0x4(%eax),%edx
  80198c:	89 55 14             	mov    %edx,0x14(%ebp)
  80198f:	8b 00                	mov    (%eax),%eax
  801991:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801994:	89 c1                	mov    %eax,%ecx
  801996:	c1 f9 1f             	sar    $0x1f,%ecx
  801999:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80199c:	eb 16                	jmp    8019b4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80199e:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a1:	8d 50 04             	lea    0x4(%eax),%edx
  8019a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a7:	8b 00                	mov    (%eax),%eax
  8019a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ac:	89 c1                	mov    %eax,%ecx
  8019ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019ba:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019bf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019c3:	0f 89 90 00 00 00    	jns    801a59 <vprintfmt+0x376>
				putch('-', putdat);
  8019c9:	83 ec 08             	sub    $0x8,%esp
  8019cc:	53                   	push   %ebx
  8019cd:	6a 2d                	push   $0x2d
  8019cf:	ff d6                	call   *%esi
				num = -(long long) num;
  8019d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019d7:	f7 d8                	neg    %eax
  8019d9:	83 d2 00             	adc    $0x0,%edx
  8019dc:	f7 da                	neg    %edx
  8019de:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019e6:	eb 71                	jmp    801a59 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8019eb:	e8 7f fc ff ff       	call   80166f <getuint>
			base = 10;
  8019f0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019f5:	eb 62                	jmp    801a59 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8019f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8019fa:	e8 70 fc ff ff       	call   80166f <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8019ff:	83 ec 0c             	sub    $0xc,%esp
  801a02:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801a06:	51                   	push   %ecx
  801a07:	ff 75 e0             	pushl  -0x20(%ebp)
  801a0a:	6a 08                	push   $0x8
  801a0c:	52                   	push   %edx
  801a0d:	50                   	push   %eax
  801a0e:	89 da                	mov    %ebx,%edx
  801a10:	89 f0                	mov    %esi,%eax
  801a12:	e8 a9 fb ff ff       	call   8015c0 <printnum>
			break;
  801a17:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  801a1d:	e9 e7 fc ff ff       	jmp    801709 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a22:	83 ec 08             	sub    $0x8,%esp
  801a25:	53                   	push   %ebx
  801a26:	6a 30                	push   $0x30
  801a28:	ff d6                	call   *%esi
			putch('x', putdat);
  801a2a:	83 c4 08             	add    $0x8,%esp
  801a2d:	53                   	push   %ebx
  801a2e:	6a 78                	push   $0x78
  801a30:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a32:	8b 45 14             	mov    0x14(%ebp),%eax
  801a35:	8d 50 04             	lea    0x4(%eax),%edx
  801a38:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a3b:	8b 00                	mov    (%eax),%eax
  801a3d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a42:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a45:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a4a:	eb 0d                	jmp    801a59 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a4c:	8d 45 14             	lea    0x14(%ebp),%eax
  801a4f:	e8 1b fc ff ff       	call   80166f <getuint>
			base = 16;
  801a54:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a59:	83 ec 0c             	sub    $0xc,%esp
  801a5c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a60:	57                   	push   %edi
  801a61:	ff 75 e0             	pushl  -0x20(%ebp)
  801a64:	51                   	push   %ecx
  801a65:	52                   	push   %edx
  801a66:	50                   	push   %eax
  801a67:	89 da                	mov    %ebx,%edx
  801a69:	89 f0                	mov    %esi,%eax
  801a6b:	e8 50 fb ff ff       	call   8015c0 <printnum>
			break;
  801a70:	83 c4 20             	add    $0x20,%esp
  801a73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a76:	e9 8e fc ff ff       	jmp    801709 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a7b:	83 ec 08             	sub    $0x8,%esp
  801a7e:	53                   	push   %ebx
  801a7f:	51                   	push   %ecx
  801a80:	ff d6                	call   *%esi
			break;
  801a82:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a88:	e9 7c fc ff ff       	jmp    801709 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a8d:	83 ec 08             	sub    $0x8,%esp
  801a90:	53                   	push   %ebx
  801a91:	6a 25                	push   $0x25
  801a93:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	eb 03                	jmp    801a9d <vprintfmt+0x3ba>
  801a9a:	83 ef 01             	sub    $0x1,%edi
  801a9d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801aa1:	75 f7                	jne    801a9a <vprintfmt+0x3b7>
  801aa3:	e9 61 fc ff ff       	jmp    801709 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aab:	5b                   	pop    %ebx
  801aac:	5e                   	pop    %esi
  801aad:	5f                   	pop    %edi
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	83 ec 18             	sub    $0x18,%esp
  801ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801abf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ac3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ac6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801acd:	85 c0                	test   %eax,%eax
  801acf:	74 26                	je     801af7 <vsnprintf+0x47>
  801ad1:	85 d2                	test   %edx,%edx
  801ad3:	7e 22                	jle    801af7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ad5:	ff 75 14             	pushl  0x14(%ebp)
  801ad8:	ff 75 10             	pushl  0x10(%ebp)
  801adb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ade:	50                   	push   %eax
  801adf:	68 a9 16 80 00       	push   $0x8016a9
  801ae4:	e8 fa fb ff ff       	call   8016e3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ae9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	eb 05                	jmp    801afc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801af7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b04:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b07:	50                   	push   %eax
  801b08:	ff 75 10             	pushl  0x10(%ebp)
  801b0b:	ff 75 0c             	pushl  0xc(%ebp)
  801b0e:	ff 75 08             	pushl  0x8(%ebp)
  801b11:	e8 9a ff ff ff       	call   801ab0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b16:	c9                   	leave  
  801b17:	c3                   	ret    

00801b18 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b23:	eb 03                	jmp    801b28 <strlen+0x10>
		n++;
  801b25:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b28:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b2c:	75 f7                	jne    801b25 <strlen+0xd>
		n++;
	return n;
}
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b36:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b39:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3e:	eb 03                	jmp    801b43 <strnlen+0x13>
		n++;
  801b40:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b43:	39 c2                	cmp    %eax,%edx
  801b45:	74 08                	je     801b4f <strnlen+0x1f>
  801b47:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b4b:	75 f3                	jne    801b40 <strnlen+0x10>
  801b4d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	53                   	push   %ebx
  801b55:	8b 45 08             	mov    0x8(%ebp),%eax
  801b58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b5b:	89 c2                	mov    %eax,%edx
  801b5d:	83 c2 01             	add    $0x1,%edx
  801b60:	83 c1 01             	add    $0x1,%ecx
  801b63:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b67:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b6a:	84 db                	test   %bl,%bl
  801b6c:	75 ef                	jne    801b5d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b6e:	5b                   	pop    %ebx
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	53                   	push   %ebx
  801b75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b78:	53                   	push   %ebx
  801b79:	e8 9a ff ff ff       	call   801b18 <strlen>
  801b7e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b81:	ff 75 0c             	pushl  0xc(%ebp)
  801b84:	01 d8                	add    %ebx,%eax
  801b86:	50                   	push   %eax
  801b87:	e8 c5 ff ff ff       	call   801b51 <strcpy>
	return dst;
}
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	56                   	push   %esi
  801b97:	53                   	push   %ebx
  801b98:	8b 75 08             	mov    0x8(%ebp),%esi
  801b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9e:	89 f3                	mov    %esi,%ebx
  801ba0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba3:	89 f2                	mov    %esi,%edx
  801ba5:	eb 0f                	jmp    801bb6 <strncpy+0x23>
		*dst++ = *src;
  801ba7:	83 c2 01             	add    $0x1,%edx
  801baa:	0f b6 01             	movzbl (%ecx),%eax
  801bad:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bb0:	80 39 01             	cmpb   $0x1,(%ecx)
  801bb3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bb6:	39 da                	cmp    %ebx,%edx
  801bb8:	75 ed                	jne    801ba7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bba:	89 f0                	mov    %esi,%eax
  801bbc:	5b                   	pop    %ebx
  801bbd:	5e                   	pop    %esi
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcb:	8b 55 10             	mov    0x10(%ebp),%edx
  801bce:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bd0:	85 d2                	test   %edx,%edx
  801bd2:	74 21                	je     801bf5 <strlcpy+0x35>
  801bd4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bd8:	89 f2                	mov    %esi,%edx
  801bda:	eb 09                	jmp    801be5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bdc:	83 c2 01             	add    $0x1,%edx
  801bdf:	83 c1 01             	add    $0x1,%ecx
  801be2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801be5:	39 c2                	cmp    %eax,%edx
  801be7:	74 09                	je     801bf2 <strlcpy+0x32>
  801be9:	0f b6 19             	movzbl (%ecx),%ebx
  801bec:	84 db                	test   %bl,%bl
  801bee:	75 ec                	jne    801bdc <strlcpy+0x1c>
  801bf0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bf2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bf5:	29 f0                	sub    %esi,%eax
}
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c01:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c04:	eb 06                	jmp    801c0c <strcmp+0x11>
		p++, q++;
  801c06:	83 c1 01             	add    $0x1,%ecx
  801c09:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c0c:	0f b6 01             	movzbl (%ecx),%eax
  801c0f:	84 c0                	test   %al,%al
  801c11:	74 04                	je     801c17 <strcmp+0x1c>
  801c13:	3a 02                	cmp    (%edx),%al
  801c15:	74 ef                	je     801c06 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c17:	0f b6 c0             	movzbl %al,%eax
  801c1a:	0f b6 12             	movzbl (%edx),%edx
  801c1d:	29 d0                	sub    %edx,%eax
}
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    

00801c21 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	53                   	push   %ebx
  801c25:	8b 45 08             	mov    0x8(%ebp),%eax
  801c28:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2b:	89 c3                	mov    %eax,%ebx
  801c2d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c30:	eb 06                	jmp    801c38 <strncmp+0x17>
		n--, p++, q++;
  801c32:	83 c0 01             	add    $0x1,%eax
  801c35:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c38:	39 d8                	cmp    %ebx,%eax
  801c3a:	74 15                	je     801c51 <strncmp+0x30>
  801c3c:	0f b6 08             	movzbl (%eax),%ecx
  801c3f:	84 c9                	test   %cl,%cl
  801c41:	74 04                	je     801c47 <strncmp+0x26>
  801c43:	3a 0a                	cmp    (%edx),%cl
  801c45:	74 eb                	je     801c32 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c47:	0f b6 00             	movzbl (%eax),%eax
  801c4a:	0f b6 12             	movzbl (%edx),%edx
  801c4d:	29 d0                	sub    %edx,%eax
  801c4f:	eb 05                	jmp    801c56 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c51:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c56:	5b                   	pop    %ebx
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c63:	eb 07                	jmp    801c6c <strchr+0x13>
		if (*s == c)
  801c65:	38 ca                	cmp    %cl,%dl
  801c67:	74 0f                	je     801c78 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c69:	83 c0 01             	add    $0x1,%eax
  801c6c:	0f b6 10             	movzbl (%eax),%edx
  801c6f:	84 d2                	test   %dl,%dl
  801c71:	75 f2                	jne    801c65 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    

00801c7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c84:	eb 03                	jmp    801c89 <strfind+0xf>
  801c86:	83 c0 01             	add    $0x1,%eax
  801c89:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c8c:	38 ca                	cmp    %cl,%dl
  801c8e:	74 04                	je     801c94 <strfind+0x1a>
  801c90:	84 d2                	test   %dl,%dl
  801c92:	75 f2                	jne    801c86 <strfind+0xc>
			break;
	return (char *) s;
}
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    

00801c96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	57                   	push   %edi
  801c9a:	56                   	push   %esi
  801c9b:	53                   	push   %ebx
  801c9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ca2:	85 c9                	test   %ecx,%ecx
  801ca4:	74 36                	je     801cdc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ca6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cac:	75 28                	jne    801cd6 <memset+0x40>
  801cae:	f6 c1 03             	test   $0x3,%cl
  801cb1:	75 23                	jne    801cd6 <memset+0x40>
		c &= 0xFF;
  801cb3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cb7:	89 d3                	mov    %edx,%ebx
  801cb9:	c1 e3 08             	shl    $0x8,%ebx
  801cbc:	89 d6                	mov    %edx,%esi
  801cbe:	c1 e6 18             	shl    $0x18,%esi
  801cc1:	89 d0                	mov    %edx,%eax
  801cc3:	c1 e0 10             	shl    $0x10,%eax
  801cc6:	09 f0                	or     %esi,%eax
  801cc8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cca:	89 d8                	mov    %ebx,%eax
  801ccc:	09 d0                	or     %edx,%eax
  801cce:	c1 e9 02             	shr    $0x2,%ecx
  801cd1:	fc                   	cld    
  801cd2:	f3 ab                	rep stos %eax,%es:(%edi)
  801cd4:	eb 06                	jmp    801cdc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd9:	fc                   	cld    
  801cda:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cdc:	89 f8                	mov    %edi,%eax
  801cde:	5b                   	pop    %ebx
  801cdf:	5e                   	pop    %esi
  801ce0:	5f                   	pop    %edi
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    

00801ce3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	57                   	push   %edi
  801ce7:	56                   	push   %esi
  801ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ceb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cf1:	39 c6                	cmp    %eax,%esi
  801cf3:	73 35                	jae    801d2a <memmove+0x47>
  801cf5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf8:	39 d0                	cmp    %edx,%eax
  801cfa:	73 2e                	jae    801d2a <memmove+0x47>
		s += n;
		d += n;
  801cfc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cff:	89 d6                	mov    %edx,%esi
  801d01:	09 fe                	or     %edi,%esi
  801d03:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d09:	75 13                	jne    801d1e <memmove+0x3b>
  801d0b:	f6 c1 03             	test   $0x3,%cl
  801d0e:	75 0e                	jne    801d1e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d10:	83 ef 04             	sub    $0x4,%edi
  801d13:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d16:	c1 e9 02             	shr    $0x2,%ecx
  801d19:	fd                   	std    
  801d1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d1c:	eb 09                	jmp    801d27 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d1e:	83 ef 01             	sub    $0x1,%edi
  801d21:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d24:	fd                   	std    
  801d25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d27:	fc                   	cld    
  801d28:	eb 1d                	jmp    801d47 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d2a:	89 f2                	mov    %esi,%edx
  801d2c:	09 c2                	or     %eax,%edx
  801d2e:	f6 c2 03             	test   $0x3,%dl
  801d31:	75 0f                	jne    801d42 <memmove+0x5f>
  801d33:	f6 c1 03             	test   $0x3,%cl
  801d36:	75 0a                	jne    801d42 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d38:	c1 e9 02             	shr    $0x2,%ecx
  801d3b:	89 c7                	mov    %eax,%edi
  801d3d:	fc                   	cld    
  801d3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d40:	eb 05                	jmp    801d47 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d42:	89 c7                	mov    %eax,%edi
  801d44:	fc                   	cld    
  801d45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d47:	5e                   	pop    %esi
  801d48:	5f                   	pop    %edi
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    

00801d4b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d4e:	ff 75 10             	pushl  0x10(%ebp)
  801d51:	ff 75 0c             	pushl  0xc(%ebp)
  801d54:	ff 75 08             	pushl  0x8(%ebp)
  801d57:	e8 87 ff ff ff       	call   801ce3 <memmove>
}
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	56                   	push   %esi
  801d62:	53                   	push   %ebx
  801d63:	8b 45 08             	mov    0x8(%ebp),%eax
  801d66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d69:	89 c6                	mov    %eax,%esi
  801d6b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d6e:	eb 1a                	jmp    801d8a <memcmp+0x2c>
		if (*s1 != *s2)
  801d70:	0f b6 08             	movzbl (%eax),%ecx
  801d73:	0f b6 1a             	movzbl (%edx),%ebx
  801d76:	38 d9                	cmp    %bl,%cl
  801d78:	74 0a                	je     801d84 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d7a:	0f b6 c1             	movzbl %cl,%eax
  801d7d:	0f b6 db             	movzbl %bl,%ebx
  801d80:	29 d8                	sub    %ebx,%eax
  801d82:	eb 0f                	jmp    801d93 <memcmp+0x35>
		s1++, s2++;
  801d84:	83 c0 01             	add    $0x1,%eax
  801d87:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d8a:	39 f0                	cmp    %esi,%eax
  801d8c:	75 e2                	jne    801d70 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	53                   	push   %ebx
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d9e:	89 c1                	mov    %eax,%ecx
  801da0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801da3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da7:	eb 0a                	jmp    801db3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801da9:	0f b6 10             	movzbl (%eax),%edx
  801dac:	39 da                	cmp    %ebx,%edx
  801dae:	74 07                	je     801db7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db0:	83 c0 01             	add    $0x1,%eax
  801db3:	39 c8                	cmp    %ecx,%eax
  801db5:	72 f2                	jb     801da9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801db7:	5b                   	pop    %ebx
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    

00801dba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	57                   	push   %edi
  801dbe:	56                   	push   %esi
  801dbf:	53                   	push   %ebx
  801dc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc6:	eb 03                	jmp    801dcb <strtol+0x11>
		s++;
  801dc8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dcb:	0f b6 01             	movzbl (%ecx),%eax
  801dce:	3c 20                	cmp    $0x20,%al
  801dd0:	74 f6                	je     801dc8 <strtol+0xe>
  801dd2:	3c 09                	cmp    $0x9,%al
  801dd4:	74 f2                	je     801dc8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dd6:	3c 2b                	cmp    $0x2b,%al
  801dd8:	75 0a                	jne    801de4 <strtol+0x2a>
		s++;
  801dda:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ddd:	bf 00 00 00 00       	mov    $0x0,%edi
  801de2:	eb 11                	jmp    801df5 <strtol+0x3b>
  801de4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801de9:	3c 2d                	cmp    $0x2d,%al
  801deb:	75 08                	jne    801df5 <strtol+0x3b>
		s++, neg = 1;
  801ded:	83 c1 01             	add    $0x1,%ecx
  801df0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dfb:	75 15                	jne    801e12 <strtol+0x58>
  801dfd:	80 39 30             	cmpb   $0x30,(%ecx)
  801e00:	75 10                	jne    801e12 <strtol+0x58>
  801e02:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e06:	75 7c                	jne    801e84 <strtol+0xca>
		s += 2, base = 16;
  801e08:	83 c1 02             	add    $0x2,%ecx
  801e0b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e10:	eb 16                	jmp    801e28 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e12:	85 db                	test   %ebx,%ebx
  801e14:	75 12                	jne    801e28 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e16:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e1b:	80 39 30             	cmpb   $0x30,(%ecx)
  801e1e:	75 08                	jne    801e28 <strtol+0x6e>
		s++, base = 8;
  801e20:	83 c1 01             	add    $0x1,%ecx
  801e23:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e28:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e30:	0f b6 11             	movzbl (%ecx),%edx
  801e33:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e36:	89 f3                	mov    %esi,%ebx
  801e38:	80 fb 09             	cmp    $0x9,%bl
  801e3b:	77 08                	ja     801e45 <strtol+0x8b>
			dig = *s - '0';
  801e3d:	0f be d2             	movsbl %dl,%edx
  801e40:	83 ea 30             	sub    $0x30,%edx
  801e43:	eb 22                	jmp    801e67 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e45:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e48:	89 f3                	mov    %esi,%ebx
  801e4a:	80 fb 19             	cmp    $0x19,%bl
  801e4d:	77 08                	ja     801e57 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e4f:	0f be d2             	movsbl %dl,%edx
  801e52:	83 ea 57             	sub    $0x57,%edx
  801e55:	eb 10                	jmp    801e67 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e57:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e5a:	89 f3                	mov    %esi,%ebx
  801e5c:	80 fb 19             	cmp    $0x19,%bl
  801e5f:	77 16                	ja     801e77 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e61:	0f be d2             	movsbl %dl,%edx
  801e64:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e67:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e6a:	7d 0b                	jge    801e77 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e6c:	83 c1 01             	add    $0x1,%ecx
  801e6f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e73:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e75:	eb b9                	jmp    801e30 <strtol+0x76>

	if (endptr)
  801e77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e7b:	74 0d                	je     801e8a <strtol+0xd0>
		*endptr = (char *) s;
  801e7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e80:	89 0e                	mov    %ecx,(%esi)
  801e82:	eb 06                	jmp    801e8a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e84:	85 db                	test   %ebx,%ebx
  801e86:	74 98                	je     801e20 <strtol+0x66>
  801e88:	eb 9e                	jmp    801e28 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e8a:	89 c2                	mov    %eax,%edx
  801e8c:	f7 da                	neg    %edx
  801e8e:	85 ff                	test   %edi,%edi
  801e90:	0f 45 c2             	cmovne %edx,%eax
}
  801e93:	5b                   	pop    %ebx
  801e94:	5e                   	pop    %esi
  801e95:	5f                   	pop    %edi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    

00801e98 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	56                   	push   %esi
  801e9c:	53                   	push   %ebx
  801e9d:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	74 0e                	je     801eb8 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	50                   	push   %eax
  801eae:	e8 63 e4 ff ff       	call   800316 <sys_ipc_recv>
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	eb 10                	jmp    801ec8 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801eb8:	83 ec 0c             	sub    $0xc,%esp
  801ebb:	68 00 00 c0 ee       	push   $0xeec00000
  801ec0:	e8 51 e4 ff ff       	call   800316 <sys_ipc_recv>
  801ec5:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	79 17                	jns    801ee3 <ipc_recv+0x4b>
		if(*from_env_store)
  801ecc:	83 3e 00             	cmpl   $0x0,(%esi)
  801ecf:	74 06                	je     801ed7 <ipc_recv+0x3f>
			*from_env_store = 0;
  801ed1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801ed7:	85 db                	test   %ebx,%ebx
  801ed9:	74 2c                	je     801f07 <ipc_recv+0x6f>
			*perm_store = 0;
  801edb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ee1:	eb 24                	jmp    801f07 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801ee3:	85 f6                	test   %esi,%esi
  801ee5:	74 0a                	je     801ef1 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801ee7:	a1 08 40 80 00       	mov    0x804008,%eax
  801eec:	8b 40 74             	mov    0x74(%eax),%eax
  801eef:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801ef1:	85 db                	test   %ebx,%ebx
  801ef3:	74 0a                	je     801eff <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801ef5:	a1 08 40 80 00       	mov    0x804008,%eax
  801efa:	8b 40 78             	mov    0x78(%eax),%eax
  801efd:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801eff:	a1 08 40 80 00       	mov    0x804008,%eax
  801f04:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    

00801f0e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	53                   	push   %ebx
  801f14:	83 ec 0c             	sub    $0xc,%esp
  801f17:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f20:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f22:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f27:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f2a:	e8 18 e2 ff ff       	call   800147 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f2f:	ff 75 14             	pushl  0x14(%ebp)
  801f32:	53                   	push   %ebx
  801f33:	56                   	push   %esi
  801f34:	57                   	push   %edi
  801f35:	e8 b9 e3 ff ff       	call   8002f3 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f3a:	89 c2                	mov    %eax,%edx
  801f3c:	f7 d2                	not    %edx
  801f3e:	c1 ea 1f             	shr    $0x1f,%edx
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f47:	0f 94 c1             	sete   %cl
  801f4a:	09 ca                	or     %ecx,%edx
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	0f 94 c0             	sete   %al
  801f51:	38 c2                	cmp    %al,%dl
  801f53:	77 d5                	ja     801f2a <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f58:	5b                   	pop    %ebx
  801f59:	5e                   	pop    %esi
  801f5a:	5f                   	pop    %edi
  801f5b:	5d                   	pop    %ebp
  801f5c:	c3                   	ret    

00801f5d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f68:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f71:	8b 52 50             	mov    0x50(%edx),%edx
  801f74:	39 ca                	cmp    %ecx,%edx
  801f76:	75 0d                	jne    801f85 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f78:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f7b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f80:	8b 40 48             	mov    0x48(%eax),%eax
  801f83:	eb 0f                	jmp    801f94 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f85:	83 c0 01             	add    $0x1,%eax
  801f88:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f8d:	75 d9                	jne    801f68 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f94:	5d                   	pop    %ebp
  801f95:	c3                   	ret    

00801f96 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9c:	89 d0                	mov    %edx,%eax
  801f9e:	c1 e8 16             	shr    $0x16,%eax
  801fa1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fad:	f6 c1 01             	test   $0x1,%cl
  801fb0:	74 1d                	je     801fcf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb2:	c1 ea 0c             	shr    $0xc,%edx
  801fb5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fbc:	f6 c2 01             	test   $0x1,%dl
  801fbf:	74 0e                	je     801fcf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc1:	c1 ea 0c             	shr    $0xc,%edx
  801fc4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fcb:	ef 
  801fcc:	0f b7 c0             	movzwl %ax,%eax
}
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    
  801fd1:	66 90                	xchg   %ax,%ax
  801fd3:	66 90                	xchg   %ax,%ax
  801fd5:	66 90                	xchg   %ax,%ax
  801fd7:	66 90                	xchg   %ax,%ax
  801fd9:	66 90                	xchg   %ax,%ax
  801fdb:	66 90                	xchg   %ax,%ax
  801fdd:	66 90                	xchg   %ax,%ax
  801fdf:	90                   	nop

00801fe0 <__udivdi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801feb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 f6                	test   %esi,%esi
  801ff9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ffd:	89 ca                	mov    %ecx,%edx
  801fff:	89 f8                	mov    %edi,%eax
  802001:	75 3d                	jne    802040 <__udivdi3+0x60>
  802003:	39 cf                	cmp    %ecx,%edi
  802005:	0f 87 c5 00 00 00    	ja     8020d0 <__udivdi3+0xf0>
  80200b:	85 ff                	test   %edi,%edi
  80200d:	89 fd                	mov    %edi,%ebp
  80200f:	75 0b                	jne    80201c <__udivdi3+0x3c>
  802011:	b8 01 00 00 00       	mov    $0x1,%eax
  802016:	31 d2                	xor    %edx,%edx
  802018:	f7 f7                	div    %edi
  80201a:	89 c5                	mov    %eax,%ebp
  80201c:	89 c8                	mov    %ecx,%eax
  80201e:	31 d2                	xor    %edx,%edx
  802020:	f7 f5                	div    %ebp
  802022:	89 c1                	mov    %eax,%ecx
  802024:	89 d8                	mov    %ebx,%eax
  802026:	89 cf                	mov    %ecx,%edi
  802028:	f7 f5                	div    %ebp
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	89 fa                	mov    %edi,%edx
  802030:	83 c4 1c             	add    $0x1c,%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
  802038:	90                   	nop
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	39 ce                	cmp    %ecx,%esi
  802042:	77 74                	ja     8020b8 <__udivdi3+0xd8>
  802044:	0f bd fe             	bsr    %esi,%edi
  802047:	83 f7 1f             	xor    $0x1f,%edi
  80204a:	0f 84 98 00 00 00    	je     8020e8 <__udivdi3+0x108>
  802050:	bb 20 00 00 00       	mov    $0x20,%ebx
  802055:	89 f9                	mov    %edi,%ecx
  802057:	89 c5                	mov    %eax,%ebp
  802059:	29 fb                	sub    %edi,%ebx
  80205b:	d3 e6                	shl    %cl,%esi
  80205d:	89 d9                	mov    %ebx,%ecx
  80205f:	d3 ed                	shr    %cl,%ebp
  802061:	89 f9                	mov    %edi,%ecx
  802063:	d3 e0                	shl    %cl,%eax
  802065:	09 ee                	or     %ebp,%esi
  802067:	89 d9                	mov    %ebx,%ecx
  802069:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206d:	89 d5                	mov    %edx,%ebp
  80206f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802073:	d3 ed                	shr    %cl,%ebp
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e2                	shl    %cl,%edx
  802079:	89 d9                	mov    %ebx,%ecx
  80207b:	d3 e8                	shr    %cl,%eax
  80207d:	09 c2                	or     %eax,%edx
  80207f:	89 d0                	mov    %edx,%eax
  802081:	89 ea                	mov    %ebp,%edx
  802083:	f7 f6                	div    %esi
  802085:	89 d5                	mov    %edx,%ebp
  802087:	89 c3                	mov    %eax,%ebx
  802089:	f7 64 24 0c          	mull   0xc(%esp)
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	72 10                	jb     8020a1 <__udivdi3+0xc1>
  802091:	8b 74 24 08          	mov    0x8(%esp),%esi
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e6                	shl    %cl,%esi
  802099:	39 c6                	cmp    %eax,%esi
  80209b:	73 07                	jae    8020a4 <__udivdi3+0xc4>
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	75 03                	jne    8020a4 <__udivdi3+0xc4>
  8020a1:	83 eb 01             	sub    $0x1,%ebx
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 d8                	mov    %ebx,%eax
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	31 ff                	xor    %edi,%edi
  8020ba:	31 db                	xor    %ebx,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 d8                	mov    %ebx,%eax
  8020d2:	f7 f7                	div    %edi
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 fa                	mov    %edi,%edx
  8020dc:	83 c4 1c             	add    $0x1c,%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	39 ce                	cmp    %ecx,%esi
  8020ea:	72 0c                	jb     8020f8 <__udivdi3+0x118>
  8020ec:	31 db                	xor    %ebx,%ebx
  8020ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020f2:	0f 87 34 ff ff ff    	ja     80202c <__udivdi3+0x4c>
  8020f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020fd:	e9 2a ff ff ff       	jmp    80202c <__udivdi3+0x4c>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80211f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 d2                	test   %edx,%edx
  802129:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80212d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802131:	89 f3                	mov    %esi,%ebx
  802133:	89 3c 24             	mov    %edi,(%esp)
  802136:	89 74 24 04          	mov    %esi,0x4(%esp)
  80213a:	75 1c                	jne    802158 <__umoddi3+0x48>
  80213c:	39 f7                	cmp    %esi,%edi
  80213e:	76 50                	jbe    802190 <__umoddi3+0x80>
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	f7 f7                	div    %edi
  802146:	89 d0                	mov    %edx,%eax
  802148:	31 d2                	xor    %edx,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	77 52                	ja     8021b0 <__umoddi3+0xa0>
  80215e:	0f bd ea             	bsr    %edx,%ebp
  802161:	83 f5 1f             	xor    $0x1f,%ebp
  802164:	75 5a                	jne    8021c0 <__umoddi3+0xb0>
  802166:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80216a:	0f 82 e0 00 00 00    	jb     802250 <__umoddi3+0x140>
  802170:	39 0c 24             	cmp    %ecx,(%esp)
  802173:	0f 86 d7 00 00 00    	jbe    802250 <__umoddi3+0x140>
  802179:	8b 44 24 08          	mov    0x8(%esp),%eax
  80217d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	85 ff                	test   %edi,%edi
  802192:	89 fd                	mov    %edi,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x91>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f7                	div    %edi
  80219f:	89 c5                	mov    %eax,%ebp
  8021a1:	89 f0                	mov    %esi,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f5                	div    %ebp
  8021a7:	89 c8                	mov    %ecx,%eax
  8021a9:	f7 f5                	div    %ebp
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	eb 99                	jmp    802148 <__umoddi3+0x38>
  8021af:	90                   	nop
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	83 c4 1c             	add    $0x1c,%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    
  8021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	8b 34 24             	mov    (%esp),%esi
  8021c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021c8:	89 e9                	mov    %ebp,%ecx
  8021ca:	29 ef                	sub    %ebp,%edi
  8021cc:	d3 e0                	shl    %cl,%eax
  8021ce:	89 f9                	mov    %edi,%ecx
  8021d0:	89 f2                	mov    %esi,%edx
  8021d2:	d3 ea                	shr    %cl,%edx
  8021d4:	89 e9                	mov    %ebp,%ecx
  8021d6:	09 c2                	or     %eax,%edx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 14 24             	mov    %edx,(%esp)
  8021dd:	89 f2                	mov    %esi,%edx
  8021df:	d3 e2                	shl    %cl,%edx
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	89 c6                	mov    %eax,%esi
  8021f1:	d3 e3                	shl    %cl,%ebx
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	09 d8                	or     %ebx,%eax
  8021fd:	89 d3                	mov    %edx,%ebx
  8021ff:	89 f2                	mov    %esi,%edx
  802201:	f7 34 24             	divl   (%esp)
  802204:	89 d6                	mov    %edx,%esi
  802206:	d3 e3                	shl    %cl,%ebx
  802208:	f7 64 24 04          	mull   0x4(%esp)
  80220c:	39 d6                	cmp    %edx,%esi
  80220e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802212:	89 d1                	mov    %edx,%ecx
  802214:	89 c3                	mov    %eax,%ebx
  802216:	72 08                	jb     802220 <__umoddi3+0x110>
  802218:	75 11                	jne    80222b <__umoddi3+0x11b>
  80221a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80221e:	73 0b                	jae    80222b <__umoddi3+0x11b>
  802220:	2b 44 24 04          	sub    0x4(%esp),%eax
  802224:	1b 14 24             	sbb    (%esp),%edx
  802227:	89 d1                	mov    %edx,%ecx
  802229:	89 c3                	mov    %eax,%ebx
  80222b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80222f:	29 da                	sub    %ebx,%edx
  802231:	19 ce                	sbb    %ecx,%esi
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 f0                	mov    %esi,%eax
  802237:	d3 e0                	shl    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	d3 ea                	shr    %cl,%edx
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	d3 ee                	shr    %cl,%esi
  802241:	09 d0                	or     %edx,%eax
  802243:	89 f2                	mov    %esi,%edx
  802245:	83 c4 1c             	add    $0x1c,%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	29 f9                	sub    %edi,%ecx
  802252:	19 d6                	sbb    %edx,%esi
  802254:	89 74 24 04          	mov    %esi,0x4(%esp)
  802258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225c:	e9 18 ff ff ff       	jmp    802179 <__umoddi3+0x69>
