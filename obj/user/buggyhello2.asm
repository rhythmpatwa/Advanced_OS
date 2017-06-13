
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 a6 04 00 00       	call   800545 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 98 22 80 00       	push   $0x802298
  800118:	6a 23                	push   $0x23
  80011a:	68 b5 22 80 00       	push   $0x8022b5
  80011f:	e8 b3 13 00 00       	call   8014d7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 98 22 80 00       	push   $0x802298
  800199:	6a 23                	push   $0x23
  80019b:	68 b5 22 80 00       	push   $0x8022b5
  8001a0:	e8 32 13 00 00       	call   8014d7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 98 22 80 00       	push   $0x802298
  8001db:	6a 23                	push   $0x23
  8001dd:	68 b5 22 80 00       	push   $0x8022b5
  8001e2:	e8 f0 12 00 00       	call   8014d7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 98 22 80 00       	push   $0x802298
  80021d:	6a 23                	push   $0x23
  80021f:	68 b5 22 80 00       	push   $0x8022b5
  800224:	e8 ae 12 00 00       	call   8014d7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 98 22 80 00       	push   $0x802298
  80025f:	6a 23                	push   $0x23
  800261:	68 b5 22 80 00       	push   $0x8022b5
  800266:	e8 6c 12 00 00       	call   8014d7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 98 22 80 00       	push   $0x802298
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 b5 22 80 00       	push   $0x8022b5
  8002a8:	e8 2a 12 00 00       	call   8014d7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 98 22 80 00       	push   $0x802298
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 b5 22 80 00       	push   $0x8022b5
  8002ea:	e8 e8 11 00 00       	call   8014d7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 98 22 80 00       	push   $0x802298
  800347:	6a 23                	push   $0x23
  800349:	68 b5 22 80 00       	push   $0x8022b5
  80034e:	e8 84 11 00 00       	call   8014d7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036b:	89 d1                	mov    %edx,%ecx
  80036d:	89 d3                	mov    %edx,%ebx
  80036f:	89 d7                	mov    %edx,%edi
  800371:	89 d6                	mov    %edx,%esi
  800373:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	05 00 00 00 30       	add    $0x30000000,%eax
  800385:	c1 e8 0c             	shr    $0xc,%eax
}
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	05 00 00 00 30       	add    $0x30000000,%eax
  800395:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80039a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ac:	89 c2                	mov    %eax,%edx
  8003ae:	c1 ea 16             	shr    $0x16,%edx
  8003b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b8:	f6 c2 01             	test   $0x1,%dl
  8003bb:	74 11                	je     8003ce <fd_alloc+0x2d>
  8003bd:	89 c2                	mov    %eax,%edx
  8003bf:	c1 ea 0c             	shr    $0xc,%edx
  8003c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c9:	f6 c2 01             	test   $0x1,%dl
  8003cc:	75 09                	jne    8003d7 <fd_alloc+0x36>
			*fd_store = fd;
  8003ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d5:	eb 17                	jmp    8003ee <fd_alloc+0x4d>
  8003d7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003dc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003e1:	75 c9                	jne    8003ac <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003e3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f6:	83 f8 1f             	cmp    $0x1f,%eax
  8003f9:	77 36                	ja     800431 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003fb:	c1 e0 0c             	shl    $0xc,%eax
  8003fe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800403:	89 c2                	mov    %eax,%edx
  800405:	c1 ea 16             	shr    $0x16,%edx
  800408:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040f:	f6 c2 01             	test   $0x1,%dl
  800412:	74 24                	je     800438 <fd_lookup+0x48>
  800414:	89 c2                	mov    %eax,%edx
  800416:	c1 ea 0c             	shr    $0xc,%edx
  800419:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800420:	f6 c2 01             	test   $0x1,%dl
  800423:	74 1a                	je     80043f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800425:	8b 55 0c             	mov    0xc(%ebp),%edx
  800428:	89 02                	mov    %eax,(%edx)
	return 0;
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	eb 13                	jmp    800444 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800436:	eb 0c                	jmp    800444 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043d:	eb 05                	jmp    800444 <fd_lookup+0x54>
  80043f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044f:	ba 40 23 80 00       	mov    $0x802340,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800454:	eb 13                	jmp    800469 <dev_lookup+0x23>
  800456:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800459:	39 08                	cmp    %ecx,(%eax)
  80045b:	75 0c                	jne    800469 <dev_lookup+0x23>
			*dev = devtab[i];
  80045d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800460:	89 01                	mov    %eax,(%ecx)
			return 0;
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
  800467:	eb 2e                	jmp    800497 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800469:	8b 02                	mov    (%edx),%eax
  80046b:	85 c0                	test   %eax,%eax
  80046d:	75 e7                	jne    800456 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80046f:	a1 08 40 80 00       	mov    0x804008,%eax
  800474:	8b 40 48             	mov    0x48(%eax),%eax
  800477:	83 ec 04             	sub    $0x4,%esp
  80047a:	51                   	push   %ecx
  80047b:	50                   	push   %eax
  80047c:	68 c4 22 80 00       	push   $0x8022c4
  800481:	e8 2a 11 00 00       	call   8015b0 <cprintf>
	*dev = 0;
  800486:	8b 45 0c             	mov    0xc(%ebp),%eax
  800489:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800497:	c9                   	leave  
  800498:	c3                   	ret    

00800499 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	56                   	push   %esi
  80049d:	53                   	push   %ebx
  80049e:	83 ec 10             	sub    $0x10,%esp
  8004a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004aa:	50                   	push   %eax
  8004ab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004b1:	c1 e8 0c             	shr    $0xc,%eax
  8004b4:	50                   	push   %eax
  8004b5:	e8 36 ff ff ff       	call   8003f0 <fd_lookup>
  8004ba:	83 c4 08             	add    $0x8,%esp
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	78 05                	js     8004c6 <fd_close+0x2d>
	    || fd != fd2)
  8004c1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004c4:	74 0c                	je     8004d2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004c6:	84 db                	test   %bl,%bl
  8004c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004cd:	0f 44 c2             	cmove  %edx,%eax
  8004d0:	eb 41                	jmp    800513 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d8:	50                   	push   %eax
  8004d9:	ff 36                	pushl  (%esi)
  8004db:	e8 66 ff ff ff       	call   800446 <dev_lookup>
  8004e0:	89 c3                	mov    %eax,%ebx
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	78 1a                	js     800503 <fd_close+0x6a>
		if (dev->dev_close)
  8004e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004ec:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004ef:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	74 0b                	je     800503 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f8:	83 ec 0c             	sub    $0xc,%esp
  8004fb:	56                   	push   %esi
  8004fc:	ff d0                	call   *%eax
  8004fe:	89 c3                	mov    %eax,%ebx
  800500:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	56                   	push   %esi
  800507:	6a 00                	push   $0x0
  800509:	e8 e1 fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	89 d8                	mov    %ebx,%eax
}
  800513:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800516:	5b                   	pop    %ebx
  800517:	5e                   	pop    %esi
  800518:	5d                   	pop    %ebp
  800519:	c3                   	ret    

0080051a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800520:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800523:	50                   	push   %eax
  800524:	ff 75 08             	pushl  0x8(%ebp)
  800527:	e8 c4 fe ff ff       	call   8003f0 <fd_lookup>
  80052c:	83 c4 08             	add    $0x8,%esp
  80052f:	85 c0                	test   %eax,%eax
  800531:	78 10                	js     800543 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	6a 01                	push   $0x1
  800538:	ff 75 f4             	pushl  -0xc(%ebp)
  80053b:	e8 59 ff ff ff       	call   800499 <fd_close>
  800540:	83 c4 10             	add    $0x10,%esp
}
  800543:	c9                   	leave  
  800544:	c3                   	ret    

00800545 <close_all>:

void
close_all(void)
{
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	53                   	push   %ebx
  800549:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80054c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	53                   	push   %ebx
  800555:	e8 c0 ff ff ff       	call   80051a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80055a:	83 c3 01             	add    $0x1,%ebx
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	83 fb 20             	cmp    $0x20,%ebx
  800563:	75 ec                	jne    800551 <close_all+0xc>
		close(i);
}
  800565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800568:	c9                   	leave  
  800569:	c3                   	ret    

0080056a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	57                   	push   %edi
  80056e:	56                   	push   %esi
  80056f:	53                   	push   %ebx
  800570:	83 ec 2c             	sub    $0x2c,%esp
  800573:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800576:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800579:	50                   	push   %eax
  80057a:	ff 75 08             	pushl  0x8(%ebp)
  80057d:	e8 6e fe ff ff       	call   8003f0 <fd_lookup>
  800582:	83 c4 08             	add    $0x8,%esp
  800585:	85 c0                	test   %eax,%eax
  800587:	0f 88 c1 00 00 00    	js     80064e <dup+0xe4>
		return r;
	close(newfdnum);
  80058d:	83 ec 0c             	sub    $0xc,%esp
  800590:	56                   	push   %esi
  800591:	e8 84 ff ff ff       	call   80051a <close>

	newfd = INDEX2FD(newfdnum);
  800596:	89 f3                	mov    %esi,%ebx
  800598:	c1 e3 0c             	shl    $0xc,%ebx
  80059b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005a1:	83 c4 04             	add    $0x4,%esp
  8005a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a7:	e8 de fd ff ff       	call   80038a <fd2data>
  8005ac:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005ae:	89 1c 24             	mov    %ebx,(%esp)
  8005b1:	e8 d4 fd ff ff       	call   80038a <fd2data>
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005bc:	89 f8                	mov    %edi,%eax
  8005be:	c1 e8 16             	shr    $0x16,%eax
  8005c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c8:	a8 01                	test   $0x1,%al
  8005ca:	74 37                	je     800603 <dup+0x99>
  8005cc:	89 f8                	mov    %edi,%eax
  8005ce:	c1 e8 0c             	shr    $0xc,%eax
  8005d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d8:	f6 c2 01             	test   $0x1,%dl
  8005db:	74 26                	je     800603 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e4:	83 ec 0c             	sub    $0xc,%esp
  8005e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ec:	50                   	push   %eax
  8005ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005f0:	6a 00                	push   $0x0
  8005f2:	57                   	push   %edi
  8005f3:	6a 00                	push   $0x0
  8005f5:	e8 b3 fb ff ff       	call   8001ad <sys_page_map>
  8005fa:	89 c7                	mov    %eax,%edi
  8005fc:	83 c4 20             	add    $0x20,%esp
  8005ff:	85 c0                	test   %eax,%eax
  800601:	78 2e                	js     800631 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800603:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800606:	89 d0                	mov    %edx,%eax
  800608:	c1 e8 0c             	shr    $0xc,%eax
  80060b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800612:	83 ec 0c             	sub    $0xc,%esp
  800615:	25 07 0e 00 00       	and    $0xe07,%eax
  80061a:	50                   	push   %eax
  80061b:	53                   	push   %ebx
  80061c:	6a 00                	push   $0x0
  80061e:	52                   	push   %edx
  80061f:	6a 00                	push   $0x0
  800621:	e8 87 fb ff ff       	call   8001ad <sys_page_map>
  800626:	89 c7                	mov    %eax,%edi
  800628:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80062b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062d:	85 ff                	test   %edi,%edi
  80062f:	79 1d                	jns    80064e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 00                	push   $0x0
  800637:	e8 b3 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80063c:	83 c4 08             	add    $0x8,%esp
  80063f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800642:	6a 00                	push   $0x0
  800644:	e8 a6 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	89 f8                	mov    %edi,%eax
}
  80064e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800651:	5b                   	pop    %ebx
  800652:	5e                   	pop    %esi
  800653:	5f                   	pop    %edi
  800654:	5d                   	pop    %ebp
  800655:	c3                   	ret    

00800656 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
  800659:	53                   	push   %ebx
  80065a:	83 ec 14             	sub    $0x14,%esp
  80065d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800660:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800663:	50                   	push   %eax
  800664:	53                   	push   %ebx
  800665:	e8 86 fd ff ff       	call   8003f0 <fd_lookup>
  80066a:	83 c4 08             	add    $0x8,%esp
  80066d:	89 c2                	mov    %eax,%edx
  80066f:	85 c0                	test   %eax,%eax
  800671:	78 6d                	js     8006e0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800679:	50                   	push   %eax
  80067a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80067d:	ff 30                	pushl  (%eax)
  80067f:	e8 c2 fd ff ff       	call   800446 <dev_lookup>
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	85 c0                	test   %eax,%eax
  800689:	78 4c                	js     8006d7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80068b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068e:	8b 42 08             	mov    0x8(%edx),%eax
  800691:	83 e0 03             	and    $0x3,%eax
  800694:	83 f8 01             	cmp    $0x1,%eax
  800697:	75 21                	jne    8006ba <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800699:	a1 08 40 80 00       	mov    0x804008,%eax
  80069e:	8b 40 48             	mov    0x48(%eax),%eax
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	50                   	push   %eax
  8006a6:	68 05 23 80 00       	push   $0x802305
  8006ab:	e8 00 0f 00 00       	call   8015b0 <cprintf>
		return -E_INVAL;
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b8:	eb 26                	jmp    8006e0 <read+0x8a>
	}
	if (!dev->dev_read)
  8006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bd:	8b 40 08             	mov    0x8(%eax),%eax
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	74 17                	je     8006db <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006c4:	83 ec 04             	sub    $0x4,%esp
  8006c7:	ff 75 10             	pushl  0x10(%ebp)
  8006ca:	ff 75 0c             	pushl  0xc(%ebp)
  8006cd:	52                   	push   %edx
  8006ce:	ff d0                	call   *%eax
  8006d0:	89 c2                	mov    %eax,%edx
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	eb 09                	jmp    8006e0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d7:	89 c2                	mov    %eax,%edx
  8006d9:	eb 05                	jmp    8006e0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006e0:	89 d0                	mov    %edx,%eax
  8006e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e5:	c9                   	leave  
  8006e6:	c3                   	ret    

008006e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	57                   	push   %edi
  8006eb:	56                   	push   %esi
  8006ec:	53                   	push   %ebx
  8006ed:	83 ec 0c             	sub    $0xc,%esp
  8006f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fb:	eb 21                	jmp    80071e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006fd:	83 ec 04             	sub    $0x4,%esp
  800700:	89 f0                	mov    %esi,%eax
  800702:	29 d8                	sub    %ebx,%eax
  800704:	50                   	push   %eax
  800705:	89 d8                	mov    %ebx,%eax
  800707:	03 45 0c             	add    0xc(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	57                   	push   %edi
  80070c:	e8 45 ff ff ff       	call   800656 <read>
		if (m < 0)
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	85 c0                	test   %eax,%eax
  800716:	78 10                	js     800728 <readn+0x41>
			return m;
		if (m == 0)
  800718:	85 c0                	test   %eax,%eax
  80071a:	74 0a                	je     800726 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071c:	01 c3                	add    %eax,%ebx
  80071e:	39 f3                	cmp    %esi,%ebx
  800720:	72 db                	jb     8006fd <readn+0x16>
  800722:	89 d8                	mov    %ebx,%eax
  800724:	eb 02                	jmp    800728 <readn+0x41>
  800726:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800728:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072b:	5b                   	pop    %ebx
  80072c:	5e                   	pop    %esi
  80072d:	5f                   	pop    %edi
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	83 ec 14             	sub    $0x14,%esp
  800737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80073a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80073d:	50                   	push   %eax
  80073e:	53                   	push   %ebx
  80073f:	e8 ac fc ff ff       	call   8003f0 <fd_lookup>
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	89 c2                	mov    %eax,%edx
  800749:	85 c0                	test   %eax,%eax
  80074b:	78 68                	js     8007b5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800757:	ff 30                	pushl  (%eax)
  800759:	e8 e8 fc ff ff       	call   800446 <dev_lookup>
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	85 c0                	test   %eax,%eax
  800763:	78 47                	js     8007ac <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800765:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800768:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80076c:	75 21                	jne    80078f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80076e:	a1 08 40 80 00       	mov    0x804008,%eax
  800773:	8b 40 48             	mov    0x48(%eax),%eax
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	53                   	push   %ebx
  80077a:	50                   	push   %eax
  80077b:	68 21 23 80 00       	push   $0x802321
  800780:	e8 2b 0e 00 00       	call   8015b0 <cprintf>
		return -E_INVAL;
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80078d:	eb 26                	jmp    8007b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800792:	8b 52 0c             	mov    0xc(%edx),%edx
  800795:	85 d2                	test   %edx,%edx
  800797:	74 17                	je     8007b0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800799:	83 ec 04             	sub    $0x4,%esp
  80079c:	ff 75 10             	pushl  0x10(%ebp)
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	50                   	push   %eax
  8007a3:	ff d2                	call   *%edx
  8007a5:	89 c2                	mov    %eax,%edx
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	eb 09                	jmp    8007b5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ac:	89 c2                	mov    %eax,%edx
  8007ae:	eb 05                	jmp    8007b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007b5:	89 d0                	mov    %edx,%eax
  8007b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <seek>:

int
seek(int fdnum, off_t offset)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007c2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007c5:	50                   	push   %eax
  8007c6:	ff 75 08             	pushl  0x8(%ebp)
  8007c9:	e8 22 fc ff ff       	call   8003f0 <fd_lookup>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	78 0e                	js     8007e3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007db:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	83 ec 14             	sub    $0x14,%esp
  8007ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f2:	50                   	push   %eax
  8007f3:	53                   	push   %ebx
  8007f4:	e8 f7 fb ff ff       	call   8003f0 <fd_lookup>
  8007f9:	83 c4 08             	add    $0x8,%esp
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	85 c0                	test   %eax,%eax
  800800:	78 65                	js     800867 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800802:	83 ec 08             	sub    $0x8,%esp
  800805:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800808:	50                   	push   %eax
  800809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080c:	ff 30                	pushl  (%eax)
  80080e:	e8 33 fc ff ff       	call   800446 <dev_lookup>
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	85 c0                	test   %eax,%eax
  800818:	78 44                	js     80085e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80081a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800821:	75 21                	jne    800844 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800823:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800828:	8b 40 48             	mov    0x48(%eax),%eax
  80082b:	83 ec 04             	sub    $0x4,%esp
  80082e:	53                   	push   %ebx
  80082f:	50                   	push   %eax
  800830:	68 e4 22 80 00       	push   $0x8022e4
  800835:	e8 76 0d 00 00       	call   8015b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800842:	eb 23                	jmp    800867 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800844:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800847:	8b 52 18             	mov    0x18(%edx),%edx
  80084a:	85 d2                	test   %edx,%edx
  80084c:	74 14                	je     800862 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	ff 75 0c             	pushl  0xc(%ebp)
  800854:	50                   	push   %eax
  800855:	ff d2                	call   *%edx
  800857:	89 c2                	mov    %eax,%edx
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	eb 09                	jmp    800867 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	89 c2                	mov    %eax,%edx
  800860:	eb 05                	jmp    800867 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800862:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800867:	89 d0                	mov    %edx,%eax
  800869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	53                   	push   %ebx
  800872:	83 ec 14             	sub    $0x14,%esp
  800875:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800878:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80087b:	50                   	push   %eax
  80087c:	ff 75 08             	pushl  0x8(%ebp)
  80087f:	e8 6c fb ff ff       	call   8003f0 <fd_lookup>
  800884:	83 c4 08             	add    $0x8,%esp
  800887:	89 c2                	mov    %eax,%edx
  800889:	85 c0                	test   %eax,%eax
  80088b:	78 58                	js     8008e5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800893:	50                   	push   %eax
  800894:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800897:	ff 30                	pushl  (%eax)
  800899:	e8 a8 fb ff ff       	call   800446 <dev_lookup>
  80089e:	83 c4 10             	add    $0x10,%esp
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	78 37                	js     8008dc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ac:	74 32                	je     8008e0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ae:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008b1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b8:	00 00 00 
	stat->st_isdir = 0;
  8008bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008c2:	00 00 00 
	stat->st_dev = dev;
  8008c5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	53                   	push   %ebx
  8008cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8008d2:	ff 50 14             	call   *0x14(%eax)
  8008d5:	89 c2                	mov    %eax,%edx
  8008d7:	83 c4 10             	add    $0x10,%esp
  8008da:	eb 09                	jmp    8008e5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008dc:	89 c2                	mov    %eax,%edx
  8008de:	eb 05                	jmp    8008e5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e5:	89 d0                	mov    %edx,%eax
  8008e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	6a 00                	push   $0x0
  8008f6:	ff 75 08             	pushl  0x8(%ebp)
  8008f9:	e8 ef 01 00 00       	call   800aed <open>
  8008fe:	89 c3                	mov    %eax,%ebx
  800900:	83 c4 10             	add    $0x10,%esp
  800903:	85 c0                	test   %eax,%eax
  800905:	78 1b                	js     800922 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	50                   	push   %eax
  80090e:	e8 5b ff ff ff       	call   80086e <fstat>
  800913:	89 c6                	mov    %eax,%esi
	close(fd);
  800915:	89 1c 24             	mov    %ebx,(%esp)
  800918:	e8 fd fb ff ff       	call   80051a <close>
	return r;
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	89 f0                	mov    %esi,%eax
}
  800922:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	56                   	push   %esi
  80092d:	53                   	push   %ebx
  80092e:	89 c6                	mov    %eax,%esi
  800930:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800932:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800939:	75 12                	jne    80094d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80093b:	83 ec 0c             	sub    $0xc,%esp
  80093e:	6a 01                	push   $0x1
  800940:	e8 1c 16 00 00       	call   801f61 <ipc_find_env>
  800945:	a3 00 40 80 00       	mov    %eax,0x804000
  80094a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80094d:	6a 07                	push   $0x7
  80094f:	68 00 50 80 00       	push   $0x805000
  800954:	56                   	push   %esi
  800955:	ff 35 00 40 80 00    	pushl  0x804000
  80095b:	e8 b2 15 00 00       	call   801f12 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800960:	83 c4 0c             	add    $0xc,%esp
  800963:	6a 00                	push   $0x0
  800965:	53                   	push   %ebx
  800966:	6a 00                	push   $0x0
  800968:	e8 2f 15 00 00       	call   801e9c <ipc_recv>
}
  80096d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 40 0c             	mov    0xc(%eax),%eax
  800980:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
  800988:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80098d:	ba 00 00 00 00       	mov    $0x0,%edx
  800992:	b8 02 00 00 00       	mov    $0x2,%eax
  800997:	e8 8d ff ff ff       	call   800929 <fsipc>
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b9:	e8 6b ff ff ff       	call   800929 <fsipc>
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	53                   	push   %ebx
  8009c4:	83 ec 04             	sub    $0x4,%esp
  8009c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009da:	b8 05 00 00 00       	mov    $0x5,%eax
  8009df:	e8 45 ff ff ff       	call   800929 <fsipc>
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	78 2c                	js     800a14 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	68 00 50 80 00       	push   $0x805000
  8009f0:	53                   	push   %ebx
  8009f1:	e8 5f 11 00 00       	call   801b55 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009f6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a01:	a1 84 50 80 00       	mov    0x805084,%eax
  800a06:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a0c:	83 c4 10             	add    $0x10,%esp
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	53                   	push   %ebx
  800a1d:	83 ec 08             	sub    $0x8,%esp
  800a20:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
  800a26:	8b 52 0c             	mov    0xc(%edx),%edx
  800a29:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a2f:	a3 04 50 80 00       	mov    %eax,0x805004
  800a34:	3d 08 50 80 00       	cmp    $0x805008,%eax
  800a39:	bb 08 50 80 00       	mov    $0x805008,%ebx
  800a3e:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a41:	53                   	push   %ebx
  800a42:	ff 75 0c             	pushl  0xc(%ebp)
  800a45:	68 08 50 80 00       	push   $0x805008
  800a4a:	e8 98 12 00 00       	call   801ce7 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a54:	b8 04 00 00 00       	mov    $0x4,%eax
  800a59:	e8 cb fe ff ff       	call   800929 <fsipc>
  800a5e:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  800a61:	85 c0                	test   %eax,%eax
  800a63:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  800a66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 40 0c             	mov    0xc(%eax),%eax
  800a79:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8e:	e8 96 fe ff ff       	call   800929 <fsipc>
  800a93:	89 c3                	mov    %eax,%ebx
  800a95:	85 c0                	test   %eax,%eax
  800a97:	78 4b                	js     800ae4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a99:	39 c6                	cmp    %eax,%esi
  800a9b:	73 16                	jae    800ab3 <devfile_read+0x48>
  800a9d:	68 54 23 80 00       	push   $0x802354
  800aa2:	68 5b 23 80 00       	push   $0x80235b
  800aa7:	6a 7c                	push   $0x7c
  800aa9:	68 70 23 80 00       	push   $0x802370
  800aae:	e8 24 0a 00 00       	call   8014d7 <_panic>
	assert(r <= PGSIZE);
  800ab3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab8:	7e 16                	jle    800ad0 <devfile_read+0x65>
  800aba:	68 7b 23 80 00       	push   $0x80237b
  800abf:	68 5b 23 80 00       	push   $0x80235b
  800ac4:	6a 7d                	push   $0x7d
  800ac6:	68 70 23 80 00       	push   $0x802370
  800acb:	e8 07 0a 00 00       	call   8014d7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad0:	83 ec 04             	sub    $0x4,%esp
  800ad3:	50                   	push   %eax
  800ad4:	68 00 50 80 00       	push   $0x805000
  800ad9:	ff 75 0c             	pushl  0xc(%ebp)
  800adc:	e8 06 12 00 00       	call   801ce7 <memmove>
	return r;
  800ae1:	83 c4 10             	add    $0x10,%esp
}
  800ae4:	89 d8                	mov    %ebx,%eax
  800ae6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	53                   	push   %ebx
  800af1:	83 ec 20             	sub    $0x20,%esp
  800af4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800af7:	53                   	push   %ebx
  800af8:	e8 1f 10 00 00       	call   801b1c <strlen>
  800afd:	83 c4 10             	add    $0x10,%esp
  800b00:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b05:	7f 67                	jg     800b6e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0d:	50                   	push   %eax
  800b0e:	e8 8e f8 ff ff       	call   8003a1 <fd_alloc>
  800b13:	83 c4 10             	add    $0x10,%esp
		return r;
  800b16:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	78 57                	js     800b73 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b1c:	83 ec 08             	sub    $0x8,%esp
  800b1f:	53                   	push   %ebx
  800b20:	68 00 50 80 00       	push   $0x805000
  800b25:	e8 2b 10 00 00       	call   801b55 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b35:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3a:	e8 ea fd ff ff       	call   800929 <fsipc>
  800b3f:	89 c3                	mov    %eax,%ebx
  800b41:	83 c4 10             	add    $0x10,%esp
  800b44:	85 c0                	test   %eax,%eax
  800b46:	79 14                	jns    800b5c <open+0x6f>
		fd_close(fd, 0);
  800b48:	83 ec 08             	sub    $0x8,%esp
  800b4b:	6a 00                	push   $0x0
  800b4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b50:	e8 44 f9 ff ff       	call   800499 <fd_close>
		return r;
  800b55:	83 c4 10             	add    $0x10,%esp
  800b58:	89 da                	mov    %ebx,%edx
  800b5a:	eb 17                	jmp    800b73 <open+0x86>
	}

	return fd2num(fd);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b62:	e8 13 f8 ff ff       	call   80037a <fd2num>
  800b67:	89 c2                	mov    %eax,%edx
  800b69:	83 c4 10             	add    $0x10,%esp
  800b6c:	eb 05                	jmp    800b73 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b6e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b73:	89 d0                	mov    %edx,%eax
  800b75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    

00800b7a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 08 00 00 00       	mov    $0x8,%eax
  800b8a:	e8 9a fd ff ff       	call   800929 <fsipc>
}
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b99:	83 ec 0c             	sub    $0xc,%esp
  800b9c:	ff 75 08             	pushl  0x8(%ebp)
  800b9f:	e8 e6 f7 ff ff       	call   80038a <fd2data>
  800ba4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ba6:	83 c4 08             	add    $0x8,%esp
  800ba9:	68 87 23 80 00       	push   $0x802387
  800bae:	53                   	push   %ebx
  800baf:	e8 a1 0f 00 00       	call   801b55 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bb4:	8b 46 04             	mov    0x4(%esi),%eax
  800bb7:	2b 06                	sub    (%esi),%eax
  800bb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bbf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bc6:	00 00 00 
	stat->st_dev = &devpipe;
  800bc9:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800bd0:	30 80 00 
	return 0;
}
  800bd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be9:	53                   	push   %ebx
  800bea:	6a 00                	push   $0x0
  800bec:	e8 fe f5 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bf1:	89 1c 24             	mov    %ebx,(%esp)
  800bf4:	e8 91 f7 ff ff       	call   80038a <fd2data>
  800bf9:	83 c4 08             	add    $0x8,%esp
  800bfc:	50                   	push   %eax
  800bfd:	6a 00                	push   $0x0
  800bff:	e8 eb f5 ff ff       	call   8001ef <sys_page_unmap>
}
  800c04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 1c             	sub    $0x1c,%esp
  800c12:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c15:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c17:	a1 08 40 80 00       	mov    0x804008,%eax
  800c1c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	ff 75 e0             	pushl  -0x20(%ebp)
  800c25:	e8 70 13 00 00       	call   801f9a <pageref>
  800c2a:	89 c3                	mov    %eax,%ebx
  800c2c:	89 3c 24             	mov    %edi,(%esp)
  800c2f:	e8 66 13 00 00       	call   801f9a <pageref>
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	39 c3                	cmp    %eax,%ebx
  800c39:	0f 94 c1             	sete   %cl
  800c3c:	0f b6 c9             	movzbl %cl,%ecx
  800c3f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c42:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c48:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c4b:	39 ce                	cmp    %ecx,%esi
  800c4d:	74 1b                	je     800c6a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c4f:	39 c3                	cmp    %eax,%ebx
  800c51:	75 c4                	jne    800c17 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c53:	8b 42 58             	mov    0x58(%edx),%eax
  800c56:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c59:	50                   	push   %eax
  800c5a:	56                   	push   %esi
  800c5b:	68 8e 23 80 00       	push   $0x80238e
  800c60:	e8 4b 09 00 00       	call   8015b0 <cprintf>
  800c65:	83 c4 10             	add    $0x10,%esp
  800c68:	eb ad                	jmp    800c17 <_pipeisclosed+0xe>
	}
}
  800c6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 28             	sub    $0x28,%esp
  800c7e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c81:	56                   	push   %esi
  800c82:	e8 03 f7 ff ff       	call   80038a <fd2data>
  800c87:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c89:	83 c4 10             	add    $0x10,%esp
  800c8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c91:	eb 4b                	jmp    800cde <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c93:	89 da                	mov    %ebx,%edx
  800c95:	89 f0                	mov    %esi,%eax
  800c97:	e8 6d ff ff ff       	call   800c09 <_pipeisclosed>
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	75 48                	jne    800ce8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ca0:	e8 a6 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ca5:	8b 43 04             	mov    0x4(%ebx),%eax
  800ca8:	8b 0b                	mov    (%ebx),%ecx
  800caa:	8d 51 20             	lea    0x20(%ecx),%edx
  800cad:	39 d0                	cmp    %edx,%eax
  800caf:	73 e2                	jae    800c93 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cb8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cbb:	89 c2                	mov    %eax,%edx
  800cbd:	c1 fa 1f             	sar    $0x1f,%edx
  800cc0:	89 d1                	mov    %edx,%ecx
  800cc2:	c1 e9 1b             	shr    $0x1b,%ecx
  800cc5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cc8:	83 e2 1f             	and    $0x1f,%edx
  800ccb:	29 ca                	sub    %ecx,%edx
  800ccd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cd1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cd5:	83 c0 01             	add    $0x1,%eax
  800cd8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cdb:	83 c7 01             	add    $0x1,%edi
  800cde:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce1:	75 c2                	jne    800ca5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ce3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce6:	eb 05                	jmp    800ced <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	83 ec 18             	sub    $0x18,%esp
  800cfe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d01:	57                   	push   %edi
  800d02:	e8 83 f6 ff ff       	call   80038a <fd2data>
  800d07:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d09:	83 c4 10             	add    $0x10,%esp
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	eb 3d                	jmp    800d50 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d13:	85 db                	test   %ebx,%ebx
  800d15:	74 04                	je     800d1b <devpipe_read+0x26>
				return i;
  800d17:	89 d8                	mov    %ebx,%eax
  800d19:	eb 44                	jmp    800d5f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	89 f8                	mov    %edi,%eax
  800d1f:	e8 e5 fe ff ff       	call   800c09 <_pipeisclosed>
  800d24:	85 c0                	test   %eax,%eax
  800d26:	75 32                	jne    800d5a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d28:	e8 1e f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d2d:	8b 06                	mov    (%esi),%eax
  800d2f:	3b 46 04             	cmp    0x4(%esi),%eax
  800d32:	74 df                	je     800d13 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d34:	99                   	cltd   
  800d35:	c1 ea 1b             	shr    $0x1b,%edx
  800d38:	01 d0                	add    %edx,%eax
  800d3a:	83 e0 1f             	and    $0x1f,%eax
  800d3d:	29 d0                	sub    %edx,%eax
  800d3f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d4a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d4d:	83 c3 01             	add    $0x1,%ebx
  800d50:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d53:	75 d8                	jne    800d2d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d55:	8b 45 10             	mov    0x10(%ebp),%eax
  800d58:	eb 05                	jmp    800d5f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d5a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d72:	50                   	push   %eax
  800d73:	e8 29 f6 ff ff       	call   8003a1 <fd_alloc>
  800d78:	83 c4 10             	add    $0x10,%esp
  800d7b:	89 c2                	mov    %eax,%edx
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	0f 88 2c 01 00 00    	js     800eb1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d85:	83 ec 04             	sub    $0x4,%esp
  800d88:	68 07 04 00 00       	push   $0x407
  800d8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d90:	6a 00                	push   $0x0
  800d92:	e8 d3 f3 ff ff       	call   80016a <sys_page_alloc>
  800d97:	83 c4 10             	add    $0x10,%esp
  800d9a:	89 c2                	mov    %eax,%edx
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	0f 88 0d 01 00 00    	js     800eb1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800daa:	50                   	push   %eax
  800dab:	e8 f1 f5 ff ff       	call   8003a1 <fd_alloc>
  800db0:	89 c3                	mov    %eax,%ebx
  800db2:	83 c4 10             	add    $0x10,%esp
  800db5:	85 c0                	test   %eax,%eax
  800db7:	0f 88 e2 00 00 00    	js     800e9f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbd:	83 ec 04             	sub    $0x4,%esp
  800dc0:	68 07 04 00 00       	push   $0x407
  800dc5:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc8:	6a 00                	push   $0x0
  800dca:	e8 9b f3 ff ff       	call   80016a <sys_page_alloc>
  800dcf:	89 c3                	mov    %eax,%ebx
  800dd1:	83 c4 10             	add    $0x10,%esp
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	0f 88 c3 00 00 00    	js     800e9f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	ff 75 f4             	pushl  -0xc(%ebp)
  800de2:	e8 a3 f5 ff ff       	call   80038a <fd2data>
  800de7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de9:	83 c4 0c             	add    $0xc,%esp
  800dec:	68 07 04 00 00       	push   $0x407
  800df1:	50                   	push   %eax
  800df2:	6a 00                	push   $0x0
  800df4:	e8 71 f3 ff ff       	call   80016a <sys_page_alloc>
  800df9:	89 c3                	mov    %eax,%ebx
  800dfb:	83 c4 10             	add    $0x10,%esp
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	0f 88 89 00 00 00    	js     800e8f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e06:	83 ec 0c             	sub    $0xc,%esp
  800e09:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0c:	e8 79 f5 ff ff       	call   80038a <fd2data>
  800e11:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e18:	50                   	push   %eax
  800e19:	6a 00                	push   $0x0
  800e1b:	56                   	push   %esi
  800e1c:	6a 00                	push   $0x0
  800e1e:	e8 8a f3 ff ff       	call   8001ad <sys_page_map>
  800e23:	89 c3                	mov    %eax,%ebx
  800e25:	83 c4 20             	add    $0x20,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	78 55                	js     800e81 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e2c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e35:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e41:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e4a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e4f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e56:	83 ec 0c             	sub    $0xc,%esp
  800e59:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5c:	e8 19 f5 ff ff       	call   80037a <fd2num>
  800e61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e64:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e66:	83 c4 04             	add    $0x4,%esp
  800e69:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6c:	e8 09 f5 ff ff       	call   80037a <fd2num>
  800e71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e74:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7f:	eb 30                	jmp    800eb1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e81:	83 ec 08             	sub    $0x8,%esp
  800e84:	56                   	push   %esi
  800e85:	6a 00                	push   $0x0
  800e87:	e8 63 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e8c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	ff 75 f0             	pushl  -0x10(%ebp)
  800e95:	6a 00                	push   $0x0
  800e97:	e8 53 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e9c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea5:	6a 00                	push   $0x0
  800ea7:	e8 43 f3 ff ff       	call   8001ef <sys_page_unmap>
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eb1:	89 d0                	mov    %edx,%eax
  800eb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb6:	5b                   	pop    %ebx
  800eb7:	5e                   	pop    %esi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec3:	50                   	push   %eax
  800ec4:	ff 75 08             	pushl  0x8(%ebp)
  800ec7:	e8 24 f5 ff ff       	call   8003f0 <fd_lookup>
  800ecc:	83 c4 10             	add    $0x10,%esp
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	78 18                	js     800eeb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ed3:	83 ec 0c             	sub    $0xc,%esp
  800ed6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed9:	e8 ac f4 ff ff       	call   80038a <fd2data>
	return _pipeisclosed(fd, p);
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee3:	e8 21 fd ff ff       	call   800c09 <_pipeisclosed>
  800ee8:	83 c4 10             	add    $0x10,%esp
}
  800eeb:	c9                   	leave  
  800eec:	c3                   	ret    

00800eed <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ef3:	68 a6 23 80 00       	push   $0x8023a6
  800ef8:	ff 75 0c             	pushl  0xc(%ebp)
  800efb:	e8 55 0c 00 00       	call   801b55 <strcpy>
	return 0;
}
  800f00:	b8 00 00 00 00       	mov    $0x0,%eax
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	53                   	push   %ebx
  800f0b:	83 ec 10             	sub    $0x10,%esp
  800f0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800f11:	53                   	push   %ebx
  800f12:	e8 83 10 00 00       	call   801f9a <pageref>
  800f17:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800f1a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800f1f:	83 f8 01             	cmp    $0x1,%eax
  800f22:	75 10                	jne    800f34 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800f24:	83 ec 0c             	sub    $0xc,%esp
  800f27:	ff 73 0c             	pushl  0xc(%ebx)
  800f2a:	e8 c0 02 00 00       	call   8011ef <nsipc_close>
  800f2f:	89 c2                	mov    %eax,%edx
  800f31:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f34:	89 d0                	mov    %edx,%eax
  800f36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f39:	c9                   	leave  
  800f3a:	c3                   	ret    

00800f3b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f41:	6a 00                	push   $0x0
  800f43:	ff 75 10             	pushl  0x10(%ebp)
  800f46:	ff 75 0c             	pushl  0xc(%ebp)
  800f49:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4c:	ff 70 0c             	pushl  0xc(%eax)
  800f4f:	e8 78 03 00 00       	call   8012cc <nsipc_send>
}
  800f54:	c9                   	leave  
  800f55:	c3                   	ret    

00800f56 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f5c:	6a 00                	push   $0x0
  800f5e:	ff 75 10             	pushl  0x10(%ebp)
  800f61:	ff 75 0c             	pushl  0xc(%ebp)
  800f64:	8b 45 08             	mov    0x8(%ebp),%eax
  800f67:	ff 70 0c             	pushl  0xc(%eax)
  800f6a:	e8 f1 02 00 00       	call   801260 <nsipc_recv>
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f77:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f7a:	52                   	push   %edx
  800f7b:	50                   	push   %eax
  800f7c:	e8 6f f4 ff ff       	call   8003f0 <fd_lookup>
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	78 17                	js     800f9f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8b:	8b 0d 40 30 80 00    	mov    0x803040,%ecx
  800f91:	39 08                	cmp    %ecx,(%eax)
  800f93:	75 05                	jne    800f9a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f95:	8b 40 0c             	mov    0xc(%eax),%eax
  800f98:	eb 05                	jmp    800f9f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800f9a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	56                   	push   %esi
  800fa5:	53                   	push   %ebx
  800fa6:	83 ec 1c             	sub    $0x1c,%esp
  800fa9:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800fab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fae:	50                   	push   %eax
  800faf:	e8 ed f3 ff ff       	call   8003a1 <fd_alloc>
  800fb4:	89 c3                	mov    %eax,%ebx
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 1b                	js     800fd8 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800fbd:	83 ec 04             	sub    $0x4,%esp
  800fc0:	68 07 04 00 00       	push   $0x407
  800fc5:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 9b f1 ff ff       	call   80016a <sys_page_alloc>
  800fcf:	89 c3                	mov    %eax,%ebx
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	79 10                	jns    800fe8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800fd8:	83 ec 0c             	sub    $0xc,%esp
  800fdb:	56                   	push   %esi
  800fdc:	e8 0e 02 00 00       	call   8011ef <nsipc_close>
		return r;
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	eb 24                	jmp    80100c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800fe8:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ffd:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	50                   	push   %eax
  801004:	e8 71 f3 ff ff       	call   80037a <fd2num>
  801009:	83 c4 10             	add    $0x10,%esp
}
  80100c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100f:	5b                   	pop    %ebx
  801010:	5e                   	pop    %esi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801019:	8b 45 08             	mov    0x8(%ebp),%eax
  80101c:	e8 50 ff ff ff       	call   800f71 <fd2sockid>
		return r;
  801021:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801023:	85 c0                	test   %eax,%eax
  801025:	78 1f                	js     801046 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801027:	83 ec 04             	sub    $0x4,%esp
  80102a:	ff 75 10             	pushl  0x10(%ebp)
  80102d:	ff 75 0c             	pushl  0xc(%ebp)
  801030:	50                   	push   %eax
  801031:	e8 12 01 00 00       	call   801148 <nsipc_accept>
  801036:	83 c4 10             	add    $0x10,%esp
		return r;
  801039:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80103b:	85 c0                	test   %eax,%eax
  80103d:	78 07                	js     801046 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80103f:	e8 5d ff ff ff       	call   800fa1 <alloc_sockfd>
  801044:	89 c1                	mov    %eax,%ecx
}
  801046:	89 c8                	mov    %ecx,%eax
  801048:	c9                   	leave  
  801049:	c3                   	ret    

0080104a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801050:	8b 45 08             	mov    0x8(%ebp),%eax
  801053:	e8 19 ff ff ff       	call   800f71 <fd2sockid>
  801058:	85 c0                	test   %eax,%eax
  80105a:	78 12                	js     80106e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	ff 75 10             	pushl  0x10(%ebp)
  801062:	ff 75 0c             	pushl  0xc(%ebp)
  801065:	50                   	push   %eax
  801066:	e8 2d 01 00 00       	call   801198 <nsipc_bind>
  80106b:	83 c4 10             	add    $0x10,%esp
}
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <shutdown>:

int
shutdown(int s, int how)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801076:	8b 45 08             	mov    0x8(%ebp),%eax
  801079:	e8 f3 fe ff ff       	call   800f71 <fd2sockid>
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 0f                	js     801091 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	ff 75 0c             	pushl  0xc(%ebp)
  801088:	50                   	push   %eax
  801089:	e8 3f 01 00 00       	call   8011cd <nsipc_shutdown>
  80108e:	83 c4 10             	add    $0x10,%esp
}
  801091:	c9                   	leave  
  801092:	c3                   	ret    

00801093 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801099:	8b 45 08             	mov    0x8(%ebp),%eax
  80109c:	e8 d0 fe ff ff       	call   800f71 <fd2sockid>
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	78 12                	js     8010b7 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	ff 75 10             	pushl  0x10(%ebp)
  8010ab:	ff 75 0c             	pushl  0xc(%ebp)
  8010ae:	50                   	push   %eax
  8010af:	e8 55 01 00 00       	call   801209 <nsipc_connect>
  8010b4:	83 c4 10             	add    $0x10,%esp
}
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <listen>:

int
listen(int s, int backlog)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c2:	e8 aa fe ff ff       	call   800f71 <fd2sockid>
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 0f                	js     8010da <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8010cb:	83 ec 08             	sub    $0x8,%esp
  8010ce:	ff 75 0c             	pushl  0xc(%ebp)
  8010d1:	50                   	push   %eax
  8010d2:	e8 67 01 00 00       	call   80123e <nsipc_listen>
  8010d7:	83 c4 10             	add    $0x10,%esp
}
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8010e2:	ff 75 10             	pushl  0x10(%ebp)
  8010e5:	ff 75 0c             	pushl  0xc(%ebp)
  8010e8:	ff 75 08             	pushl  0x8(%ebp)
  8010eb:	e8 3a 02 00 00       	call   80132a <nsipc_socket>
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	78 05                	js     8010fc <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8010f7:	e8 a5 fe ff ff       	call   800fa1 <alloc_sockfd>
}
  8010fc:	c9                   	leave  
  8010fd:	c3                   	ret    

008010fe <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	53                   	push   %ebx
  801102:	83 ec 04             	sub    $0x4,%esp
  801105:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801107:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80110e:	75 12                	jne    801122 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801110:	83 ec 0c             	sub    $0xc,%esp
  801113:	6a 02                	push   $0x2
  801115:	e8 47 0e 00 00       	call   801f61 <ipc_find_env>
  80111a:	a3 04 40 80 00       	mov    %eax,0x804004
  80111f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801122:	6a 07                	push   $0x7
  801124:	68 00 60 80 00       	push   $0x806000
  801129:	53                   	push   %ebx
  80112a:	ff 35 04 40 80 00    	pushl  0x804004
  801130:	e8 dd 0d 00 00       	call   801f12 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801135:	83 c4 0c             	add    $0xc,%esp
  801138:	6a 00                	push   $0x0
  80113a:	6a 00                	push   $0x0
  80113c:	6a 00                	push   $0x0
  80113e:	e8 59 0d 00 00       	call   801e9c <ipc_recv>
}
  801143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801146:	c9                   	leave  
  801147:	c3                   	ret    

00801148 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801150:	8b 45 08             	mov    0x8(%ebp),%eax
  801153:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801158:	8b 06                	mov    (%esi),%eax
  80115a:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80115f:	b8 01 00 00 00       	mov    $0x1,%eax
  801164:	e8 95 ff ff ff       	call   8010fe <nsipc>
  801169:	89 c3                	mov    %eax,%ebx
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 20                	js     80118f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	ff 35 10 60 80 00    	pushl  0x806010
  801178:	68 00 60 80 00       	push   $0x806000
  80117d:	ff 75 0c             	pushl  0xc(%ebp)
  801180:	e8 62 0b 00 00       	call   801ce7 <memmove>
		*addrlen = ret->ret_addrlen;
  801185:	a1 10 60 80 00       	mov    0x806010,%eax
  80118a:	89 06                	mov    %eax,(%esi)
  80118c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80118f:	89 d8                	mov    %ebx,%eax
  801191:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	53                   	push   %ebx
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8011a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8011aa:	53                   	push   %ebx
  8011ab:	ff 75 0c             	pushl  0xc(%ebp)
  8011ae:	68 04 60 80 00       	push   $0x806004
  8011b3:	e8 2f 0b 00 00       	call   801ce7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8011b8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8011be:	b8 02 00 00 00       	mov    $0x2,%eax
  8011c3:	e8 36 ff ff ff       	call   8010fe <nsipc>
}
  8011c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8011db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011de:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8011e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8011e8:	e8 11 ff ff ff       	call   8010fe <nsipc>
}
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <nsipc_close>:

int
nsipc_close(int s)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f8:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8011fd:	b8 04 00 00 00       	mov    $0x4,%eax
  801202:	e8 f7 fe ff ff       	call   8010fe <nsipc>
}
  801207:	c9                   	leave  
  801208:	c3                   	ret    

00801209 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	53                   	push   %ebx
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
  801216:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80121b:	53                   	push   %ebx
  80121c:	ff 75 0c             	pushl  0xc(%ebp)
  80121f:	68 04 60 80 00       	push   $0x806004
  801224:	e8 be 0a 00 00       	call   801ce7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801229:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80122f:	b8 05 00 00 00       	mov    $0x5,%eax
  801234:	e8 c5 fe ff ff       	call   8010fe <nsipc>
}
  801239:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123c:	c9                   	leave  
  80123d:	c3                   	ret    

0080123e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801244:	8b 45 08             	mov    0x8(%ebp),%eax
  801247:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80124c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801254:	b8 06 00 00 00       	mov    $0x6,%eax
  801259:	e8 a0 fe ff ff       	call   8010fe <nsipc>
}
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801268:	8b 45 08             	mov    0x8(%ebp),%eax
  80126b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801270:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801276:	8b 45 14             	mov    0x14(%ebp),%eax
  801279:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80127e:	b8 07 00 00 00       	mov    $0x7,%eax
  801283:	e8 76 fe ff ff       	call   8010fe <nsipc>
  801288:	89 c3                	mov    %eax,%ebx
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 35                	js     8012c3 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80128e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801293:	7f 04                	jg     801299 <nsipc_recv+0x39>
  801295:	39 c6                	cmp    %eax,%esi
  801297:	7d 16                	jge    8012af <nsipc_recv+0x4f>
  801299:	68 b2 23 80 00       	push   $0x8023b2
  80129e:	68 5b 23 80 00       	push   $0x80235b
  8012a3:	6a 62                	push   $0x62
  8012a5:	68 c7 23 80 00       	push   $0x8023c7
  8012aa:	e8 28 02 00 00       	call   8014d7 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8012af:	83 ec 04             	sub    $0x4,%esp
  8012b2:	50                   	push   %eax
  8012b3:	68 00 60 80 00       	push   $0x806000
  8012b8:	ff 75 0c             	pushl  0xc(%ebp)
  8012bb:	e8 27 0a 00 00       	call   801ce7 <memmove>
  8012c0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8012c3:	89 d8                	mov    %ebx,%eax
  8012c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    

008012cc <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 04             	sub    $0x4,%esp
  8012d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8012d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d9:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8012de:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8012e4:	7e 16                	jle    8012fc <nsipc_send+0x30>
  8012e6:	68 d3 23 80 00       	push   $0x8023d3
  8012eb:	68 5b 23 80 00       	push   $0x80235b
  8012f0:	6a 6d                	push   $0x6d
  8012f2:	68 c7 23 80 00       	push   $0x8023c7
  8012f7:	e8 db 01 00 00       	call   8014d7 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8012fc:	83 ec 04             	sub    $0x4,%esp
  8012ff:	53                   	push   %ebx
  801300:	ff 75 0c             	pushl  0xc(%ebp)
  801303:	68 0c 60 80 00       	push   $0x80600c
  801308:	e8 da 09 00 00       	call   801ce7 <memmove>
	nsipcbuf.send.req_size = size;
  80130d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801313:	8b 45 14             	mov    0x14(%ebp),%eax
  801316:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80131b:	b8 08 00 00 00       	mov    $0x8,%eax
  801320:	e8 d9 fd ff ff       	call   8010fe <nsipc>
}
  801325:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801328:	c9                   	leave  
  801329:	c3                   	ret    

0080132a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133b:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801340:	8b 45 10             	mov    0x10(%ebp),%eax
  801343:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801348:	b8 09 00 00 00       	mov    $0x9,%eax
  80134d:	e8 ac fd ff ff       	call   8010fe <nsipc>
}
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801357:	b8 00 00 00 00       	mov    $0x0,%eax
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801364:	68 df 23 80 00       	push   $0x8023df
  801369:	ff 75 0c             	pushl  0xc(%ebp)
  80136c:	e8 e4 07 00 00       	call   801b55 <strcpy>
	return 0;
}
  801371:	b8 00 00 00 00       	mov    $0x0,%eax
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	57                   	push   %edi
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
  80137e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801384:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801389:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80138f:	eb 2d                	jmp    8013be <devcons_write+0x46>
		m = n - tot;
  801391:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801394:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801396:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801399:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80139e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a1:	83 ec 04             	sub    $0x4,%esp
  8013a4:	53                   	push   %ebx
  8013a5:	03 45 0c             	add    0xc(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	57                   	push   %edi
  8013aa:	e8 38 09 00 00       	call   801ce7 <memmove>
		sys_cputs(buf, m);
  8013af:	83 c4 08             	add    $0x8,%esp
  8013b2:	53                   	push   %ebx
  8013b3:	57                   	push   %edi
  8013b4:	e8 f5 ec ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b9:	01 de                	add    %ebx,%esi
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	89 f0                	mov    %esi,%eax
  8013c0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013c3:	72 cc                	jb     801391 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5f                   	pop    %edi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    

008013cd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013dc:	74 2a                	je     801408 <devcons_read+0x3b>
  8013de:	eb 05                	jmp    8013e5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013e0:	e8 66 ed ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013e5:	e8 e2 ec ff ff       	call   8000cc <sys_cgetc>
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	74 f2                	je     8013e0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 16                	js     801408 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013f2:	83 f8 04             	cmp    $0x4,%eax
  8013f5:	74 0c                	je     801403 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fa:	88 02                	mov    %al,(%edx)
	return 1;
  8013fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801401:	eb 05                	jmp    801408 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801403:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801416:	6a 01                	push   $0x1
  801418:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80141b:	50                   	push   %eax
  80141c:	e8 8d ec ff ff       	call   8000ae <sys_cputs>
}
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <getchar>:

int
getchar(void)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80142c:	6a 01                	push   $0x1
  80142e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	6a 00                	push   $0x0
  801434:	e8 1d f2 ff ff       	call   800656 <read>
	if (r < 0)
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 0f                	js     80144f <getchar+0x29>
		return r;
	if (r < 1)
  801440:	85 c0                	test   %eax,%eax
  801442:	7e 06                	jle    80144a <getchar+0x24>
		return -E_EOF;
	return c;
  801444:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801448:	eb 05                	jmp    80144f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80144a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801457:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145a:	50                   	push   %eax
  80145b:	ff 75 08             	pushl  0x8(%ebp)
  80145e:	e8 8d ef ff ff       	call   8003f0 <fd_lookup>
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	85 c0                	test   %eax,%eax
  801468:	78 11                	js     80147b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80146a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146d:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  801473:	39 10                	cmp    %edx,(%eax)
  801475:	0f 94 c0             	sete   %al
  801478:	0f b6 c0             	movzbl %al,%eax
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <opencons>:

int
opencons(void)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801483:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801486:	50                   	push   %eax
  801487:	e8 15 ef ff ff       	call   8003a1 <fd_alloc>
  80148c:	83 c4 10             	add    $0x10,%esp
		return r;
  80148f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801491:	85 c0                	test   %eax,%eax
  801493:	78 3e                	js     8014d3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801495:	83 ec 04             	sub    $0x4,%esp
  801498:	68 07 04 00 00       	push   $0x407
  80149d:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a0:	6a 00                	push   $0x0
  8014a2:	e8 c3 ec ff ff       	call   80016a <sys_page_alloc>
  8014a7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014aa:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 23                	js     8014d3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014b0:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8014b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	50                   	push   %eax
  8014c9:	e8 ac ee ff ff       	call   80037a <fd2num>
  8014ce:	89 c2                	mov    %eax,%edx
  8014d0:	83 c4 10             	add    $0x10,%esp
}
  8014d3:	89 d0                	mov    %edx,%eax
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    

008014d7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	56                   	push   %esi
  8014db:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014dc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014df:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8014e5:	e8 42 ec ff ff       	call   80012c <sys_getenvid>
  8014ea:	83 ec 0c             	sub    $0xc,%esp
  8014ed:	ff 75 0c             	pushl  0xc(%ebp)
  8014f0:	ff 75 08             	pushl  0x8(%ebp)
  8014f3:	56                   	push   %esi
  8014f4:	50                   	push   %eax
  8014f5:	68 ec 23 80 00       	push   $0x8023ec
  8014fa:	e8 b1 00 00 00       	call   8015b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014ff:	83 c4 18             	add    $0x18,%esp
  801502:	53                   	push   %ebx
  801503:	ff 75 10             	pushl  0x10(%ebp)
  801506:	e8 54 00 00 00       	call   80155f <vcprintf>
	cprintf("\n");
  80150b:	c7 04 24 9f 23 80 00 	movl   $0x80239f,(%esp)
  801512:	e8 99 00 00 00       	call   8015b0 <cprintf>
  801517:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80151a:	cc                   	int3   
  80151b:	eb fd                	jmp    80151a <_panic+0x43>

0080151d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	53                   	push   %ebx
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801527:	8b 13                	mov    (%ebx),%edx
  801529:	8d 42 01             	lea    0x1(%edx),%eax
  80152c:	89 03                	mov    %eax,(%ebx)
  80152e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801531:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801535:	3d ff 00 00 00       	cmp    $0xff,%eax
  80153a:	75 1a                	jne    801556 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	68 ff 00 00 00       	push   $0xff
  801544:	8d 43 08             	lea    0x8(%ebx),%eax
  801547:	50                   	push   %eax
  801548:	e8 61 eb ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  80154d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801553:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801556:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80155a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801568:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80156f:	00 00 00 
	b.cnt = 0;
  801572:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801579:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80157c:	ff 75 0c             	pushl  0xc(%ebp)
  80157f:	ff 75 08             	pushl  0x8(%ebp)
  801582:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	68 1d 15 80 00       	push   $0x80151d
  80158e:	e8 54 01 00 00       	call   8016e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801593:	83 c4 08             	add    $0x8,%esp
  801596:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80159c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015a2:	50                   	push   %eax
  8015a3:	e8 06 eb ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  8015a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015b9:	50                   	push   %eax
  8015ba:	ff 75 08             	pushl  0x8(%ebp)
  8015bd:	e8 9d ff ff ff       	call   80155f <vcprintf>
	va_end(ap);

	return cnt;
}
  8015c2:	c9                   	leave  
  8015c3:	c3                   	ret    

008015c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	57                   	push   %edi
  8015c8:	56                   	push   %esi
  8015c9:	53                   	push   %ebx
  8015ca:	83 ec 1c             	sub    $0x1c,%esp
  8015cd:	89 c7                	mov    %eax,%edi
  8015cf:	89 d6                	mov    %edx,%esi
  8015d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015da:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015e8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015eb:	39 d3                	cmp    %edx,%ebx
  8015ed:	72 05                	jb     8015f4 <printnum+0x30>
  8015ef:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015f2:	77 45                	ja     801639 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015f4:	83 ec 0c             	sub    $0xc,%esp
  8015f7:	ff 75 18             	pushl  0x18(%ebp)
  8015fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801600:	53                   	push   %ebx
  801601:	ff 75 10             	pushl  0x10(%ebp)
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	ff 75 e4             	pushl  -0x1c(%ebp)
  80160a:	ff 75 e0             	pushl  -0x20(%ebp)
  80160d:	ff 75 dc             	pushl  -0x24(%ebp)
  801610:	ff 75 d8             	pushl  -0x28(%ebp)
  801613:	e8 c8 09 00 00       	call   801fe0 <__udivdi3>
  801618:	83 c4 18             	add    $0x18,%esp
  80161b:	52                   	push   %edx
  80161c:	50                   	push   %eax
  80161d:	89 f2                	mov    %esi,%edx
  80161f:	89 f8                	mov    %edi,%eax
  801621:	e8 9e ff ff ff       	call   8015c4 <printnum>
  801626:	83 c4 20             	add    $0x20,%esp
  801629:	eb 18                	jmp    801643 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	56                   	push   %esi
  80162f:	ff 75 18             	pushl  0x18(%ebp)
  801632:	ff d7                	call   *%edi
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	eb 03                	jmp    80163c <printnum+0x78>
  801639:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80163c:	83 eb 01             	sub    $0x1,%ebx
  80163f:	85 db                	test   %ebx,%ebx
  801641:	7f e8                	jg     80162b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	56                   	push   %esi
  801647:	83 ec 04             	sub    $0x4,%esp
  80164a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164d:	ff 75 e0             	pushl  -0x20(%ebp)
  801650:	ff 75 dc             	pushl  -0x24(%ebp)
  801653:	ff 75 d8             	pushl  -0x28(%ebp)
  801656:	e8 b5 0a 00 00       	call   802110 <__umoddi3>
  80165b:	83 c4 14             	add    $0x14,%esp
  80165e:	0f be 80 0f 24 80 00 	movsbl 0x80240f(%eax),%eax
  801665:	50                   	push   %eax
  801666:	ff d7                	call   *%edi
}
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5f                   	pop    %edi
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801676:	83 fa 01             	cmp    $0x1,%edx
  801679:	7e 0e                	jle    801689 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80167b:	8b 10                	mov    (%eax),%edx
  80167d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801680:	89 08                	mov    %ecx,(%eax)
  801682:	8b 02                	mov    (%edx),%eax
  801684:	8b 52 04             	mov    0x4(%edx),%edx
  801687:	eb 22                	jmp    8016ab <getuint+0x38>
	else if (lflag)
  801689:	85 d2                	test   %edx,%edx
  80168b:	74 10                	je     80169d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80168d:	8b 10                	mov    (%eax),%edx
  80168f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801692:	89 08                	mov    %ecx,(%eax)
  801694:	8b 02                	mov    (%edx),%eax
  801696:	ba 00 00 00 00       	mov    $0x0,%edx
  80169b:	eb 0e                	jmp    8016ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80169d:	8b 10                	mov    (%eax),%edx
  80169f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a2:	89 08                	mov    %ecx,(%eax)
  8016a4:	8b 02                	mov    (%edx),%eax
  8016a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016b7:	8b 10                	mov    (%eax),%edx
  8016b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8016bc:	73 0a                	jae    8016c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016c1:	89 08                	mov    %ecx,(%eax)
  8016c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c6:	88 02                	mov    %al,(%edx)
}
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016d3:	50                   	push   %eax
  8016d4:	ff 75 10             	pushl  0x10(%ebp)
  8016d7:	ff 75 0c             	pushl  0xc(%ebp)
  8016da:	ff 75 08             	pushl  0x8(%ebp)
  8016dd:	e8 05 00 00 00       	call   8016e7 <vprintfmt>
	va_end(ap);
}
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	c9                   	leave  
  8016e6:	c3                   	ret    

008016e7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	57                   	push   %edi
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 2c             	sub    $0x2c,%esp
  8016f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016f9:	eb 12                	jmp    80170d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	0f 84 a9 03 00 00    	je     801aac <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	53                   	push   %ebx
  801707:	50                   	push   %eax
  801708:	ff d6                	call   *%esi
  80170a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80170d:	83 c7 01             	add    $0x1,%edi
  801710:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801714:	83 f8 25             	cmp    $0x25,%eax
  801717:	75 e2                	jne    8016fb <vprintfmt+0x14>
  801719:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80171d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801724:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80172b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801732:	ba 00 00 00 00       	mov    $0x0,%edx
  801737:	eb 07                	jmp    801740 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801739:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80173c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801740:	8d 47 01             	lea    0x1(%edi),%eax
  801743:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801746:	0f b6 07             	movzbl (%edi),%eax
  801749:	0f b6 c8             	movzbl %al,%ecx
  80174c:	83 e8 23             	sub    $0x23,%eax
  80174f:	3c 55                	cmp    $0x55,%al
  801751:	0f 87 3a 03 00 00    	ja     801a91 <vprintfmt+0x3aa>
  801757:	0f b6 c0             	movzbl %al,%eax
  80175a:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  801761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801764:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801768:	eb d6                	jmp    801740 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80176a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80176d:	b8 00 00 00 00       	mov    $0x0,%eax
  801772:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801775:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801778:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80177c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80177f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801782:	83 fa 09             	cmp    $0x9,%edx
  801785:	77 39                	ja     8017c0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801787:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80178a:	eb e9                	jmp    801775 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80178c:	8b 45 14             	mov    0x14(%ebp),%eax
  80178f:	8d 48 04             	lea    0x4(%eax),%ecx
  801792:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801795:	8b 00                	mov    (%eax),%eax
  801797:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80179a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80179d:	eb 27                	jmp    8017c6 <vprintfmt+0xdf>
  80179f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017a9:	0f 49 c8             	cmovns %eax,%ecx
  8017ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017b2:	eb 8c                	jmp    801740 <vprintfmt+0x59>
  8017b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017b7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017be:	eb 80                	jmp    801740 <vprintfmt+0x59>
  8017c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017c3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017ca:	0f 89 70 ff ff ff    	jns    801740 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017d6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017dd:	e9 5e ff ff ff       	jmp    801740 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017e2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017e8:	e9 53 ff ff ff       	jmp    801740 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f0:	8d 50 04             	lea    0x4(%eax),%edx
  8017f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8017f6:	83 ec 08             	sub    $0x8,%esp
  8017f9:	53                   	push   %ebx
  8017fa:	ff 30                	pushl  (%eax)
  8017fc:	ff d6                	call   *%esi
			break;
  8017fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801801:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801804:	e9 04 ff ff ff       	jmp    80170d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801809:	8b 45 14             	mov    0x14(%ebp),%eax
  80180c:	8d 50 04             	lea    0x4(%eax),%edx
  80180f:	89 55 14             	mov    %edx,0x14(%ebp)
  801812:	8b 00                	mov    (%eax),%eax
  801814:	99                   	cltd   
  801815:	31 d0                	xor    %edx,%eax
  801817:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801819:	83 f8 0f             	cmp    $0xf,%eax
  80181c:	7f 0b                	jg     801829 <vprintfmt+0x142>
  80181e:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  801825:	85 d2                	test   %edx,%edx
  801827:	75 18                	jne    801841 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801829:	50                   	push   %eax
  80182a:	68 27 24 80 00       	push   $0x802427
  80182f:	53                   	push   %ebx
  801830:	56                   	push   %esi
  801831:	e8 94 fe ff ff       	call   8016ca <printfmt>
  801836:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801839:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80183c:	e9 cc fe ff ff       	jmp    80170d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801841:	52                   	push   %edx
  801842:	68 6d 23 80 00       	push   $0x80236d
  801847:	53                   	push   %ebx
  801848:	56                   	push   %esi
  801849:	e8 7c fe ff ff       	call   8016ca <printfmt>
  80184e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801851:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801854:	e9 b4 fe ff ff       	jmp    80170d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801859:	8b 45 14             	mov    0x14(%ebp),%eax
  80185c:	8d 50 04             	lea    0x4(%eax),%edx
  80185f:	89 55 14             	mov    %edx,0x14(%ebp)
  801862:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801864:	85 ff                	test   %edi,%edi
  801866:	b8 20 24 80 00       	mov    $0x802420,%eax
  80186b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80186e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801872:	0f 8e 94 00 00 00    	jle    80190c <vprintfmt+0x225>
  801878:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80187c:	0f 84 98 00 00 00    	je     80191a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801882:	83 ec 08             	sub    $0x8,%esp
  801885:	ff 75 d0             	pushl  -0x30(%ebp)
  801888:	57                   	push   %edi
  801889:	e8 a6 02 00 00       	call   801b34 <strnlen>
  80188e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801891:	29 c1                	sub    %eax,%ecx
  801893:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801896:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801899:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80189d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a5:	eb 0f                	jmp    8018b6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	53                   	push   %ebx
  8018ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ae:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b0:	83 ef 01             	sub    $0x1,%edi
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	85 ff                	test   %edi,%edi
  8018b8:	7f ed                	jg     8018a7 <vprintfmt+0x1c0>
  8018ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018bd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018c0:	85 c9                	test   %ecx,%ecx
  8018c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c7:	0f 49 c1             	cmovns %ecx,%eax
  8018ca:	29 c1                	sub    %eax,%ecx
  8018cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8018cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018d5:	89 cb                	mov    %ecx,%ebx
  8018d7:	eb 4d                	jmp    801926 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018dd:	74 1b                	je     8018fa <vprintfmt+0x213>
  8018df:	0f be c0             	movsbl %al,%eax
  8018e2:	83 e8 20             	sub    $0x20,%eax
  8018e5:	83 f8 5e             	cmp    $0x5e,%eax
  8018e8:	76 10                	jbe    8018fa <vprintfmt+0x213>
					putch('?', putdat);
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	ff 75 0c             	pushl  0xc(%ebp)
  8018f0:	6a 3f                	push   $0x3f
  8018f2:	ff 55 08             	call   *0x8(%ebp)
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	eb 0d                	jmp    801907 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	ff 75 0c             	pushl  0xc(%ebp)
  801900:	52                   	push   %edx
  801901:	ff 55 08             	call   *0x8(%ebp)
  801904:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801907:	83 eb 01             	sub    $0x1,%ebx
  80190a:	eb 1a                	jmp    801926 <vprintfmt+0x23f>
  80190c:	89 75 08             	mov    %esi,0x8(%ebp)
  80190f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801912:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801915:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801918:	eb 0c                	jmp    801926 <vprintfmt+0x23f>
  80191a:	89 75 08             	mov    %esi,0x8(%ebp)
  80191d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801920:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801923:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801926:	83 c7 01             	add    $0x1,%edi
  801929:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80192d:	0f be d0             	movsbl %al,%edx
  801930:	85 d2                	test   %edx,%edx
  801932:	74 23                	je     801957 <vprintfmt+0x270>
  801934:	85 f6                	test   %esi,%esi
  801936:	78 a1                	js     8018d9 <vprintfmt+0x1f2>
  801938:	83 ee 01             	sub    $0x1,%esi
  80193b:	79 9c                	jns    8018d9 <vprintfmt+0x1f2>
  80193d:	89 df                	mov    %ebx,%edi
  80193f:	8b 75 08             	mov    0x8(%ebp),%esi
  801942:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801945:	eb 18                	jmp    80195f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	53                   	push   %ebx
  80194b:	6a 20                	push   $0x20
  80194d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80194f:	83 ef 01             	sub    $0x1,%edi
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	eb 08                	jmp    80195f <vprintfmt+0x278>
  801957:	89 df                	mov    %ebx,%edi
  801959:	8b 75 08             	mov    0x8(%ebp),%esi
  80195c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80195f:	85 ff                	test   %edi,%edi
  801961:	7f e4                	jg     801947 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801963:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801966:	e9 a2 fd ff ff       	jmp    80170d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80196b:	83 fa 01             	cmp    $0x1,%edx
  80196e:	7e 16                	jle    801986 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801970:	8b 45 14             	mov    0x14(%ebp),%eax
  801973:	8d 50 08             	lea    0x8(%eax),%edx
  801976:	89 55 14             	mov    %edx,0x14(%ebp)
  801979:	8b 50 04             	mov    0x4(%eax),%edx
  80197c:	8b 00                	mov    (%eax),%eax
  80197e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801981:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801984:	eb 32                	jmp    8019b8 <vprintfmt+0x2d1>
	else if (lflag)
  801986:	85 d2                	test   %edx,%edx
  801988:	74 18                	je     8019a2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80198a:	8b 45 14             	mov    0x14(%ebp),%eax
  80198d:	8d 50 04             	lea    0x4(%eax),%edx
  801990:	89 55 14             	mov    %edx,0x14(%ebp)
  801993:	8b 00                	mov    (%eax),%eax
  801995:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801998:	89 c1                	mov    %eax,%ecx
  80199a:	c1 f9 1f             	sar    $0x1f,%ecx
  80199d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019a0:	eb 16                	jmp    8019b8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a5:	8d 50 04             	lea    0x4(%eax),%edx
  8019a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8019ab:	8b 00                	mov    (%eax),%eax
  8019ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019b0:	89 c1                	mov    %eax,%ecx
  8019b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019c3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019c7:	0f 89 90 00 00 00    	jns    801a5d <vprintfmt+0x376>
				putch('-', putdat);
  8019cd:	83 ec 08             	sub    $0x8,%esp
  8019d0:	53                   	push   %ebx
  8019d1:	6a 2d                	push   $0x2d
  8019d3:	ff d6                	call   *%esi
				num = -(long long) num;
  8019d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019db:	f7 d8                	neg    %eax
  8019dd:	83 d2 00             	adc    $0x0,%edx
  8019e0:	f7 da                	neg    %edx
  8019e2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019ea:	eb 71                	jmp    801a5d <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8019ef:	e8 7f fc ff ff       	call   801673 <getuint>
			base = 10;
  8019f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019f9:	eb 62                	jmp    801a5d <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8019fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8019fe:	e8 70 fc ff ff       	call   801673 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801a0a:	51                   	push   %ecx
  801a0b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a0e:	6a 08                	push   $0x8
  801a10:	52                   	push   %edx
  801a11:	50                   	push   %eax
  801a12:	89 da                	mov    %ebx,%edx
  801a14:	89 f0                	mov    %esi,%eax
  801a16:	e8 a9 fb ff ff       	call   8015c4 <printnum>
			break;
  801a1b:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  801a21:	e9 e7 fc ff ff       	jmp    80170d <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a26:	83 ec 08             	sub    $0x8,%esp
  801a29:	53                   	push   %ebx
  801a2a:	6a 30                	push   $0x30
  801a2c:	ff d6                	call   *%esi
			putch('x', putdat);
  801a2e:	83 c4 08             	add    $0x8,%esp
  801a31:	53                   	push   %ebx
  801a32:	6a 78                	push   $0x78
  801a34:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a36:	8b 45 14             	mov    0x14(%ebp),%eax
  801a39:	8d 50 04             	lea    0x4(%eax),%edx
  801a3c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a3f:	8b 00                	mov    (%eax),%eax
  801a41:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a46:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a49:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a4e:	eb 0d                	jmp    801a5d <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a50:	8d 45 14             	lea    0x14(%ebp),%eax
  801a53:	e8 1b fc ff ff       	call   801673 <getuint>
			base = 16;
  801a58:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a5d:	83 ec 0c             	sub    $0xc,%esp
  801a60:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a64:	57                   	push   %edi
  801a65:	ff 75 e0             	pushl  -0x20(%ebp)
  801a68:	51                   	push   %ecx
  801a69:	52                   	push   %edx
  801a6a:	50                   	push   %eax
  801a6b:	89 da                	mov    %ebx,%edx
  801a6d:	89 f0                	mov    %esi,%eax
  801a6f:	e8 50 fb ff ff       	call   8015c4 <printnum>
			break;
  801a74:	83 c4 20             	add    $0x20,%esp
  801a77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a7a:	e9 8e fc ff ff       	jmp    80170d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a7f:	83 ec 08             	sub    $0x8,%esp
  801a82:	53                   	push   %ebx
  801a83:	51                   	push   %ecx
  801a84:	ff d6                	call   *%esi
			break;
  801a86:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a89:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a8c:	e9 7c fc ff ff       	jmp    80170d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a91:	83 ec 08             	sub    $0x8,%esp
  801a94:	53                   	push   %ebx
  801a95:	6a 25                	push   $0x25
  801a97:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	eb 03                	jmp    801aa1 <vprintfmt+0x3ba>
  801a9e:	83 ef 01             	sub    $0x1,%edi
  801aa1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801aa5:	75 f7                	jne    801a9e <vprintfmt+0x3b7>
  801aa7:	e9 61 fc ff ff       	jmp    80170d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5e                   	pop    %esi
  801ab1:	5f                   	pop    %edi
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 18             	sub    $0x18,%esp
  801aba:	8b 45 08             	mov    0x8(%ebp),%eax
  801abd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ac0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ac3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ac7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801aca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	74 26                	je     801afb <vsnprintf+0x47>
  801ad5:	85 d2                	test   %edx,%edx
  801ad7:	7e 22                	jle    801afb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ad9:	ff 75 14             	pushl  0x14(%ebp)
  801adc:	ff 75 10             	pushl  0x10(%ebp)
  801adf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ae2:	50                   	push   %eax
  801ae3:	68 ad 16 80 00       	push   $0x8016ad
  801ae8:	e8 fa fb ff ff       	call   8016e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801af0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	eb 05                	jmp    801b00 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801afb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    

00801b02 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b08:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b0b:	50                   	push   %eax
  801b0c:	ff 75 10             	pushl  0x10(%ebp)
  801b0f:	ff 75 0c             	pushl  0xc(%ebp)
  801b12:	ff 75 08             	pushl  0x8(%ebp)
  801b15:	e8 9a ff ff ff       	call   801ab4 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b22:	b8 00 00 00 00       	mov    $0x0,%eax
  801b27:	eb 03                	jmp    801b2c <strlen+0x10>
		n++;
  801b29:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b2c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b30:	75 f7                	jne    801b29 <strlen+0xd>
		n++;
	return n;
}
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b42:	eb 03                	jmp    801b47 <strnlen+0x13>
		n++;
  801b44:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b47:	39 c2                	cmp    %eax,%edx
  801b49:	74 08                	je     801b53 <strnlen+0x1f>
  801b4b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b4f:	75 f3                	jne    801b44 <strnlen+0x10>
  801b51:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	53                   	push   %ebx
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b5f:	89 c2                	mov    %eax,%edx
  801b61:	83 c2 01             	add    $0x1,%edx
  801b64:	83 c1 01             	add    $0x1,%ecx
  801b67:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b6b:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b6e:	84 db                	test   %bl,%bl
  801b70:	75 ef                	jne    801b61 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b72:	5b                   	pop    %ebx
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	53                   	push   %ebx
  801b79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b7c:	53                   	push   %ebx
  801b7d:	e8 9a ff ff ff       	call   801b1c <strlen>
  801b82:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b85:	ff 75 0c             	pushl  0xc(%ebp)
  801b88:	01 d8                	add    %ebx,%eax
  801b8a:	50                   	push   %eax
  801b8b:	e8 c5 ff ff ff       	call   801b55 <strcpy>
	return dst;
}
  801b90:	89 d8                	mov    %ebx,%eax
  801b92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b95:	c9                   	leave  
  801b96:	c3                   	ret    

00801b97 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba2:	89 f3                	mov    %esi,%ebx
  801ba4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba7:	89 f2                	mov    %esi,%edx
  801ba9:	eb 0f                	jmp    801bba <strncpy+0x23>
		*dst++ = *src;
  801bab:	83 c2 01             	add    $0x1,%edx
  801bae:	0f b6 01             	movzbl (%ecx),%eax
  801bb1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bb4:	80 39 01             	cmpb   $0x1,(%ecx)
  801bb7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bba:	39 da                	cmp    %ebx,%edx
  801bbc:	75 ed                	jne    801bab <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bbe:	89 f0                	mov    %esi,%eax
  801bc0:	5b                   	pop    %ebx
  801bc1:	5e                   	pop    %esi
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    

00801bc4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	56                   	push   %esi
  801bc8:	53                   	push   %ebx
  801bc9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcf:	8b 55 10             	mov    0x10(%ebp),%edx
  801bd2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bd4:	85 d2                	test   %edx,%edx
  801bd6:	74 21                	je     801bf9 <strlcpy+0x35>
  801bd8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bdc:	89 f2                	mov    %esi,%edx
  801bde:	eb 09                	jmp    801be9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801be0:	83 c2 01             	add    $0x1,%edx
  801be3:	83 c1 01             	add    $0x1,%ecx
  801be6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801be9:	39 c2                	cmp    %eax,%edx
  801beb:	74 09                	je     801bf6 <strlcpy+0x32>
  801bed:	0f b6 19             	movzbl (%ecx),%ebx
  801bf0:	84 db                	test   %bl,%bl
  801bf2:	75 ec                	jne    801be0 <strlcpy+0x1c>
  801bf4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bf6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bf9:	29 f0                	sub    %esi,%eax
}
  801bfb:	5b                   	pop    %ebx
  801bfc:	5e                   	pop    %esi
  801bfd:	5d                   	pop    %ebp
  801bfe:	c3                   	ret    

00801bff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c05:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c08:	eb 06                	jmp    801c10 <strcmp+0x11>
		p++, q++;
  801c0a:	83 c1 01             	add    $0x1,%ecx
  801c0d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c10:	0f b6 01             	movzbl (%ecx),%eax
  801c13:	84 c0                	test   %al,%al
  801c15:	74 04                	je     801c1b <strcmp+0x1c>
  801c17:	3a 02                	cmp    (%edx),%al
  801c19:	74 ef                	je     801c0a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c1b:	0f b6 c0             	movzbl %al,%eax
  801c1e:	0f b6 12             	movzbl (%edx),%edx
  801c21:	29 d0                	sub    %edx,%eax
}
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	53                   	push   %ebx
  801c29:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2f:	89 c3                	mov    %eax,%ebx
  801c31:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c34:	eb 06                	jmp    801c3c <strncmp+0x17>
		n--, p++, q++;
  801c36:	83 c0 01             	add    $0x1,%eax
  801c39:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c3c:	39 d8                	cmp    %ebx,%eax
  801c3e:	74 15                	je     801c55 <strncmp+0x30>
  801c40:	0f b6 08             	movzbl (%eax),%ecx
  801c43:	84 c9                	test   %cl,%cl
  801c45:	74 04                	je     801c4b <strncmp+0x26>
  801c47:	3a 0a                	cmp    (%edx),%cl
  801c49:	74 eb                	je     801c36 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c4b:	0f b6 00             	movzbl (%eax),%eax
  801c4e:	0f b6 12             	movzbl (%edx),%edx
  801c51:	29 d0                	sub    %edx,%eax
  801c53:	eb 05                	jmp    801c5a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c55:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c5a:	5b                   	pop    %ebx
  801c5b:	5d                   	pop    %ebp
  801c5c:	c3                   	ret    

00801c5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c67:	eb 07                	jmp    801c70 <strchr+0x13>
		if (*s == c)
  801c69:	38 ca                	cmp    %cl,%dl
  801c6b:	74 0f                	je     801c7c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c6d:	83 c0 01             	add    $0x1,%eax
  801c70:	0f b6 10             	movzbl (%eax),%edx
  801c73:	84 d2                	test   %dl,%dl
  801c75:	75 f2                	jne    801c69 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	8b 45 08             	mov    0x8(%ebp),%eax
  801c84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c88:	eb 03                	jmp    801c8d <strfind+0xf>
  801c8a:	83 c0 01             	add    $0x1,%eax
  801c8d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c90:	38 ca                	cmp    %cl,%dl
  801c92:	74 04                	je     801c98 <strfind+0x1a>
  801c94:	84 d2                	test   %dl,%dl
  801c96:	75 f2                	jne    801c8a <strfind+0xc>
			break;
	return (char *) s;
}
  801c98:	5d                   	pop    %ebp
  801c99:	c3                   	ret    

00801c9a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
  801c9d:	57                   	push   %edi
  801c9e:	56                   	push   %esi
  801c9f:	53                   	push   %ebx
  801ca0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ca3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ca6:	85 c9                	test   %ecx,%ecx
  801ca8:	74 36                	je     801ce0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801caa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cb0:	75 28                	jne    801cda <memset+0x40>
  801cb2:	f6 c1 03             	test   $0x3,%cl
  801cb5:	75 23                	jne    801cda <memset+0x40>
		c &= 0xFF;
  801cb7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cbb:	89 d3                	mov    %edx,%ebx
  801cbd:	c1 e3 08             	shl    $0x8,%ebx
  801cc0:	89 d6                	mov    %edx,%esi
  801cc2:	c1 e6 18             	shl    $0x18,%esi
  801cc5:	89 d0                	mov    %edx,%eax
  801cc7:	c1 e0 10             	shl    $0x10,%eax
  801cca:	09 f0                	or     %esi,%eax
  801ccc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cce:	89 d8                	mov    %ebx,%eax
  801cd0:	09 d0                	or     %edx,%eax
  801cd2:	c1 e9 02             	shr    $0x2,%ecx
  801cd5:	fc                   	cld    
  801cd6:	f3 ab                	rep stos %eax,%es:(%edi)
  801cd8:	eb 06                	jmp    801ce0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdd:	fc                   	cld    
  801cde:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ce0:	89 f8                	mov    %edi,%eax
  801ce2:	5b                   	pop    %ebx
  801ce3:	5e                   	pop    %esi
  801ce4:	5f                   	pop    %edi
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	57                   	push   %edi
  801ceb:	56                   	push   %esi
  801cec:	8b 45 08             	mov    0x8(%ebp),%eax
  801cef:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cf2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cf5:	39 c6                	cmp    %eax,%esi
  801cf7:	73 35                	jae    801d2e <memmove+0x47>
  801cf9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cfc:	39 d0                	cmp    %edx,%eax
  801cfe:	73 2e                	jae    801d2e <memmove+0x47>
		s += n;
		d += n;
  801d00:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d03:	89 d6                	mov    %edx,%esi
  801d05:	09 fe                	or     %edi,%esi
  801d07:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d0d:	75 13                	jne    801d22 <memmove+0x3b>
  801d0f:	f6 c1 03             	test   $0x3,%cl
  801d12:	75 0e                	jne    801d22 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d14:	83 ef 04             	sub    $0x4,%edi
  801d17:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d1a:	c1 e9 02             	shr    $0x2,%ecx
  801d1d:	fd                   	std    
  801d1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d20:	eb 09                	jmp    801d2b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d22:	83 ef 01             	sub    $0x1,%edi
  801d25:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d28:	fd                   	std    
  801d29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d2b:	fc                   	cld    
  801d2c:	eb 1d                	jmp    801d4b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d2e:	89 f2                	mov    %esi,%edx
  801d30:	09 c2                	or     %eax,%edx
  801d32:	f6 c2 03             	test   $0x3,%dl
  801d35:	75 0f                	jne    801d46 <memmove+0x5f>
  801d37:	f6 c1 03             	test   $0x3,%cl
  801d3a:	75 0a                	jne    801d46 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d3c:	c1 e9 02             	shr    $0x2,%ecx
  801d3f:	89 c7                	mov    %eax,%edi
  801d41:	fc                   	cld    
  801d42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d44:	eb 05                	jmp    801d4b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d46:	89 c7                	mov    %eax,%edi
  801d48:	fc                   	cld    
  801d49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d4b:	5e                   	pop    %esi
  801d4c:	5f                   	pop    %edi
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d52:	ff 75 10             	pushl  0x10(%ebp)
  801d55:	ff 75 0c             	pushl  0xc(%ebp)
  801d58:	ff 75 08             	pushl  0x8(%ebp)
  801d5b:	e8 87 ff ff ff       	call   801ce7 <memmove>
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	56                   	push   %esi
  801d66:	53                   	push   %ebx
  801d67:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6d:	89 c6                	mov    %eax,%esi
  801d6f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d72:	eb 1a                	jmp    801d8e <memcmp+0x2c>
		if (*s1 != *s2)
  801d74:	0f b6 08             	movzbl (%eax),%ecx
  801d77:	0f b6 1a             	movzbl (%edx),%ebx
  801d7a:	38 d9                	cmp    %bl,%cl
  801d7c:	74 0a                	je     801d88 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d7e:	0f b6 c1             	movzbl %cl,%eax
  801d81:	0f b6 db             	movzbl %bl,%ebx
  801d84:	29 d8                	sub    %ebx,%eax
  801d86:	eb 0f                	jmp    801d97 <memcmp+0x35>
		s1++, s2++;
  801d88:	83 c0 01             	add    $0x1,%eax
  801d8b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d8e:	39 f0                	cmp    %esi,%eax
  801d90:	75 e2                	jne    801d74 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	53                   	push   %ebx
  801d9f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801da2:	89 c1                	mov    %eax,%ecx
  801da4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801da7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dab:	eb 0a                	jmp    801db7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dad:	0f b6 10             	movzbl (%eax),%edx
  801db0:	39 da                	cmp    %ebx,%edx
  801db2:	74 07                	je     801dbb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db4:	83 c0 01             	add    $0x1,%eax
  801db7:	39 c8                	cmp    %ecx,%eax
  801db9:	72 f2                	jb     801dad <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dbb:	5b                   	pop    %ebx
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    

00801dbe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dca:	eb 03                	jmp    801dcf <strtol+0x11>
		s++;
  801dcc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dcf:	0f b6 01             	movzbl (%ecx),%eax
  801dd2:	3c 20                	cmp    $0x20,%al
  801dd4:	74 f6                	je     801dcc <strtol+0xe>
  801dd6:	3c 09                	cmp    $0x9,%al
  801dd8:	74 f2                	je     801dcc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dda:	3c 2b                	cmp    $0x2b,%al
  801ddc:	75 0a                	jne    801de8 <strtol+0x2a>
		s++;
  801dde:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801de1:	bf 00 00 00 00       	mov    $0x0,%edi
  801de6:	eb 11                	jmp    801df9 <strtol+0x3b>
  801de8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ded:	3c 2d                	cmp    $0x2d,%al
  801def:	75 08                	jne    801df9 <strtol+0x3b>
		s++, neg = 1;
  801df1:	83 c1 01             	add    $0x1,%ecx
  801df4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dff:	75 15                	jne    801e16 <strtol+0x58>
  801e01:	80 39 30             	cmpb   $0x30,(%ecx)
  801e04:	75 10                	jne    801e16 <strtol+0x58>
  801e06:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e0a:	75 7c                	jne    801e88 <strtol+0xca>
		s += 2, base = 16;
  801e0c:	83 c1 02             	add    $0x2,%ecx
  801e0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e14:	eb 16                	jmp    801e2c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e16:	85 db                	test   %ebx,%ebx
  801e18:	75 12                	jne    801e2c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e1a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e1f:	80 39 30             	cmpb   $0x30,(%ecx)
  801e22:	75 08                	jne    801e2c <strtol+0x6e>
		s++, base = 8;
  801e24:	83 c1 01             	add    $0x1,%ecx
  801e27:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e31:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e34:	0f b6 11             	movzbl (%ecx),%edx
  801e37:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e3a:	89 f3                	mov    %esi,%ebx
  801e3c:	80 fb 09             	cmp    $0x9,%bl
  801e3f:	77 08                	ja     801e49 <strtol+0x8b>
			dig = *s - '0';
  801e41:	0f be d2             	movsbl %dl,%edx
  801e44:	83 ea 30             	sub    $0x30,%edx
  801e47:	eb 22                	jmp    801e6b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e49:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e4c:	89 f3                	mov    %esi,%ebx
  801e4e:	80 fb 19             	cmp    $0x19,%bl
  801e51:	77 08                	ja     801e5b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e53:	0f be d2             	movsbl %dl,%edx
  801e56:	83 ea 57             	sub    $0x57,%edx
  801e59:	eb 10                	jmp    801e6b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e5b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e5e:	89 f3                	mov    %esi,%ebx
  801e60:	80 fb 19             	cmp    $0x19,%bl
  801e63:	77 16                	ja     801e7b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e65:	0f be d2             	movsbl %dl,%edx
  801e68:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e6b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e6e:	7d 0b                	jge    801e7b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e70:	83 c1 01             	add    $0x1,%ecx
  801e73:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e77:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e79:	eb b9                	jmp    801e34 <strtol+0x76>

	if (endptr)
  801e7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e7f:	74 0d                	je     801e8e <strtol+0xd0>
		*endptr = (char *) s;
  801e81:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e84:	89 0e                	mov    %ecx,(%esi)
  801e86:	eb 06                	jmp    801e8e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e88:	85 db                	test   %ebx,%ebx
  801e8a:	74 98                	je     801e24 <strtol+0x66>
  801e8c:	eb 9e                	jmp    801e2c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e8e:	89 c2                	mov    %eax,%edx
  801e90:	f7 da                	neg    %edx
  801e92:	85 ff                	test   %edi,%edi
  801e94:	0f 45 c2             	cmovne %edx,%eax
}
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	56                   	push   %esi
  801ea0:	53                   	push   %ebx
  801ea1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	74 0e                	je     801ebc <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	50                   	push   %eax
  801eb2:	e8 63 e4 ff ff       	call   80031a <sys_ipc_recv>
  801eb7:	83 c4 10             	add    $0x10,%esp
  801eba:	eb 10                	jmp    801ecc <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801ebc:	83 ec 0c             	sub    $0xc,%esp
  801ebf:	68 00 00 c0 ee       	push   $0xeec00000
  801ec4:	e8 51 e4 ff ff       	call   80031a <sys_ipc_recv>
  801ec9:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	79 17                	jns    801ee7 <ipc_recv+0x4b>
		if(*from_env_store)
  801ed0:	83 3e 00             	cmpl   $0x0,(%esi)
  801ed3:	74 06                	je     801edb <ipc_recv+0x3f>
			*from_env_store = 0;
  801ed5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801edb:	85 db                	test   %ebx,%ebx
  801edd:	74 2c                	je     801f0b <ipc_recv+0x6f>
			*perm_store = 0;
  801edf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ee5:	eb 24                	jmp    801f0b <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801ee7:	85 f6                	test   %esi,%esi
  801ee9:	74 0a                	je     801ef5 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801eeb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef0:	8b 40 74             	mov    0x74(%eax),%eax
  801ef3:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801ef5:	85 db                	test   %ebx,%ebx
  801ef7:	74 0a                	je     801f03 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801ef9:	a1 08 40 80 00       	mov    0x804008,%eax
  801efe:	8b 40 78             	mov    0x78(%eax),%eax
  801f01:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f03:	a1 08 40 80 00       	mov    0x804008,%eax
  801f08:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5e                   	pop    %esi
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    

00801f12 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	57                   	push   %edi
  801f16:	56                   	push   %esi
  801f17:	53                   	push   %ebx
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f24:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f26:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f2b:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f2e:	e8 18 e2 ff ff       	call   80014b <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f33:	ff 75 14             	pushl  0x14(%ebp)
  801f36:	53                   	push   %ebx
  801f37:	56                   	push   %esi
  801f38:	57                   	push   %edi
  801f39:	e8 b9 e3 ff ff       	call   8002f7 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f3e:	89 c2                	mov    %eax,%edx
  801f40:	f7 d2                	not    %edx
  801f42:	c1 ea 1f             	shr    $0x1f,%edx
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f4b:	0f 94 c1             	sete   %cl
  801f4e:	09 ca                	or     %ecx,%edx
  801f50:	85 c0                	test   %eax,%eax
  801f52:	0f 94 c0             	sete   %al
  801f55:	38 c2                	cmp    %al,%dl
  801f57:	77 d5                	ja     801f2e <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801f59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5e                   	pop    %esi
  801f5e:	5f                   	pop    %edi
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    

00801f61 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f67:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f6c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f75:	8b 52 50             	mov    0x50(%edx),%edx
  801f78:	39 ca                	cmp    %ecx,%edx
  801f7a:	75 0d                	jne    801f89 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f7c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f7f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f84:	8b 40 48             	mov    0x48(%eax),%eax
  801f87:	eb 0f                	jmp    801f98 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f89:	83 c0 01             	add    $0x1,%eax
  801f8c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f91:	75 d9                	jne    801f6c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa0:	89 d0                	mov    %edx,%eax
  801fa2:	c1 e8 16             	shr    $0x16,%eax
  801fa5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fac:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb1:	f6 c1 01             	test   $0x1,%cl
  801fb4:	74 1d                	je     801fd3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb6:	c1 ea 0c             	shr    $0xc,%edx
  801fb9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fc0:	f6 c2 01             	test   $0x1,%dl
  801fc3:	74 0e                	je     801fd3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc5:	c1 ea 0c             	shr    $0xc,%edx
  801fc8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fcf:	ef 
  801fd0:	0f b7 c0             	movzwl %ax,%eax
}
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    
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
