
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 a6 04 00 00       	call   800531 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 6a 22 80 00       	push   $0x80226a
  800104:	6a 23                	push   $0x23
  800106:	68 87 22 80 00       	push   $0x802287
  80010b:	e8 b3 13 00 00       	call   8014c3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 6a 22 80 00       	push   $0x80226a
  800185:	6a 23                	push   $0x23
  800187:	68 87 22 80 00       	push   $0x802287
  80018c:	e8 32 13 00 00       	call   8014c3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 6a 22 80 00       	push   $0x80226a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 87 22 80 00       	push   $0x802287
  8001ce:	e8 f0 12 00 00       	call   8014c3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 6a 22 80 00       	push   $0x80226a
  800209:	6a 23                	push   $0x23
  80020b:	68 87 22 80 00       	push   $0x802287
  800210:	e8 ae 12 00 00       	call   8014c3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 6a 22 80 00       	push   $0x80226a
  80024b:	6a 23                	push   $0x23
  80024d:	68 87 22 80 00       	push   $0x802287
  800252:	e8 6c 12 00 00       	call   8014c3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 6a 22 80 00       	push   $0x80226a
  80028d:	6a 23                	push   $0x23
  80028f:	68 87 22 80 00       	push   $0x802287
  800294:	e8 2a 12 00 00       	call   8014c3 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 6a 22 80 00       	push   $0x80226a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 87 22 80 00       	push   $0x802287
  8002d6:	e8 e8 11 00 00       	call   8014c3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 6a 22 80 00       	push   $0x80226a
  800333:	6a 23                	push   $0x23
  800335:	68 87 22 80 00       	push   $0x802287
  80033a:	e8 84 11 00 00       	call   8014c3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	b8 0e 00 00 00       	mov    $0xe,%eax
  800357:	89 d1                	mov    %edx,%ecx
  800359:	89 d3                	mov    %edx,%ebx
  80035b:	89 d7                	mov    %edx,%edi
  80035d:	89 d6                	mov    %edx,%esi
  80035f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	05 00 00 00 30       	add    $0x30000000,%eax
  800371:	c1 e8 0c             	shr    $0xc,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	05 00 00 00 30       	add    $0x30000000,%eax
  800381:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800386:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800393:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800398:	89 c2                	mov    %eax,%edx
  80039a:	c1 ea 16             	shr    $0x16,%edx
  80039d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a4:	f6 c2 01             	test   $0x1,%dl
  8003a7:	74 11                	je     8003ba <fd_alloc+0x2d>
  8003a9:	89 c2                	mov    %eax,%edx
  8003ab:	c1 ea 0c             	shr    $0xc,%edx
  8003ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b5:	f6 c2 01             	test   $0x1,%dl
  8003b8:	75 09                	jne    8003c3 <fd_alloc+0x36>
			*fd_store = fd;
  8003ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c1:	eb 17                	jmp    8003da <fd_alloc+0x4d>
  8003c3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003c8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003cd:	75 c9                	jne    800398 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003cf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e2:	83 f8 1f             	cmp    $0x1f,%eax
  8003e5:	77 36                	ja     80041d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003e7:	c1 e0 0c             	shl    $0xc,%eax
  8003ea:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ef:	89 c2                	mov    %eax,%edx
  8003f1:	c1 ea 16             	shr    $0x16,%edx
  8003f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fb:	f6 c2 01             	test   $0x1,%dl
  8003fe:	74 24                	je     800424 <fd_lookup+0x48>
  800400:	89 c2                	mov    %eax,%edx
  800402:	c1 ea 0c             	shr    $0xc,%edx
  800405:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040c:	f6 c2 01             	test   $0x1,%dl
  80040f:	74 1a                	je     80042b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800411:	8b 55 0c             	mov    0xc(%ebp),%edx
  800414:	89 02                	mov    %eax,(%edx)
	return 0;
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
  80041b:	eb 13                	jmp    800430 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80041d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800422:	eb 0c                	jmp    800430 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800424:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800429:	eb 05                	jmp    800430 <fd_lookup+0x54>
  80042b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043b:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800440:	eb 13                	jmp    800455 <dev_lookup+0x23>
  800442:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800445:	39 08                	cmp    %ecx,(%eax)
  800447:	75 0c                	jne    800455 <dev_lookup+0x23>
			*dev = devtab[i];
  800449:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	eb 2e                	jmp    800483 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	75 e7                	jne    800442 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045b:	a1 08 40 80 00       	mov    0x804008,%eax
  800460:	8b 40 48             	mov    0x48(%eax),%eax
  800463:	83 ec 04             	sub    $0x4,%esp
  800466:	51                   	push   %ecx
  800467:	50                   	push   %eax
  800468:	68 98 22 80 00       	push   $0x802298
  80046d:	e8 2a 11 00 00       	call   80159c <cprintf>
	*dev = 0;
  800472:	8b 45 0c             	mov    0xc(%ebp),%eax
  800475:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	56                   	push   %esi
  800489:	53                   	push   %ebx
  80048a:	83 ec 10             	sub    $0x10,%esp
  80048d:	8b 75 08             	mov    0x8(%ebp),%esi
  800490:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800496:	50                   	push   %eax
  800497:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80049d:	c1 e8 0c             	shr    $0xc,%eax
  8004a0:	50                   	push   %eax
  8004a1:	e8 36 ff ff ff       	call   8003dc <fd_lookup>
  8004a6:	83 c4 08             	add    $0x8,%esp
  8004a9:	85 c0                	test   %eax,%eax
  8004ab:	78 05                	js     8004b2 <fd_close+0x2d>
	    || fd != fd2)
  8004ad:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b0:	74 0c                	je     8004be <fd_close+0x39>
		return (must_exist ? r : 0);
  8004b2:	84 db                	test   %bl,%bl
  8004b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b9:	0f 44 c2             	cmove  %edx,%eax
  8004bc:	eb 41                	jmp    8004ff <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c4:	50                   	push   %eax
  8004c5:	ff 36                	pushl  (%esi)
  8004c7:	e8 66 ff ff ff       	call   800432 <dev_lookup>
  8004cc:	89 c3                	mov    %eax,%ebx
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	78 1a                	js     8004ef <fd_close+0x6a>
		if (dev->dev_close)
  8004d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004db:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	74 0b                	je     8004ef <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004e4:	83 ec 0c             	sub    $0xc,%esp
  8004e7:	56                   	push   %esi
  8004e8:	ff d0                	call   *%eax
  8004ea:	89 c3                	mov    %eax,%ebx
  8004ec:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	6a 00                	push   $0x0
  8004f5:	e8 e1 fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	89 d8                	mov    %ebx,%eax
}
  8004ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800502:	5b                   	pop    %ebx
  800503:	5e                   	pop    %esi
  800504:	5d                   	pop    %ebp
  800505:	c3                   	ret    

00800506 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050f:	50                   	push   %eax
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 c4 fe ff ff       	call   8003dc <fd_lookup>
  800518:	83 c4 08             	add    $0x8,%esp
  80051b:	85 c0                	test   %eax,%eax
  80051d:	78 10                	js     80052f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	6a 01                	push   $0x1
  800524:	ff 75 f4             	pushl  -0xc(%ebp)
  800527:	e8 59 ff ff ff       	call   800485 <fd_close>
  80052c:	83 c4 10             	add    $0x10,%esp
}
  80052f:	c9                   	leave  
  800530:	c3                   	ret    

00800531 <close_all>:

void
close_all(void)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	53                   	push   %ebx
  800535:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800538:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	53                   	push   %ebx
  800541:	e8 c0 ff ff ff       	call   800506 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800546:	83 c3 01             	add    $0x1,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	83 fb 20             	cmp    $0x20,%ebx
  80054f:	75 ec                	jne    80053d <close_all+0xc>
		close(i);
}
  800551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	57                   	push   %edi
  80055a:	56                   	push   %esi
  80055b:	53                   	push   %ebx
  80055c:	83 ec 2c             	sub    $0x2c,%esp
  80055f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800562:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800565:	50                   	push   %eax
  800566:	ff 75 08             	pushl  0x8(%ebp)
  800569:	e8 6e fe ff ff       	call   8003dc <fd_lookup>
  80056e:	83 c4 08             	add    $0x8,%esp
  800571:	85 c0                	test   %eax,%eax
  800573:	0f 88 c1 00 00 00    	js     80063a <dup+0xe4>
		return r;
	close(newfdnum);
  800579:	83 ec 0c             	sub    $0xc,%esp
  80057c:	56                   	push   %esi
  80057d:	e8 84 ff ff ff       	call   800506 <close>

	newfd = INDEX2FD(newfdnum);
  800582:	89 f3                	mov    %esi,%ebx
  800584:	c1 e3 0c             	shl    $0xc,%ebx
  800587:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80058d:	83 c4 04             	add    $0x4,%esp
  800590:	ff 75 e4             	pushl  -0x1c(%ebp)
  800593:	e8 de fd ff ff       	call   800376 <fd2data>
  800598:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80059a:	89 1c 24             	mov    %ebx,(%esp)
  80059d:	e8 d4 fd ff ff       	call   800376 <fd2data>
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a8:	89 f8                	mov    %edi,%eax
  8005aa:	c1 e8 16             	shr    $0x16,%eax
  8005ad:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b4:	a8 01                	test   $0x1,%al
  8005b6:	74 37                	je     8005ef <dup+0x99>
  8005b8:	89 f8                	mov    %edi,%eax
  8005ba:	c1 e8 0c             	shr    $0xc,%eax
  8005bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c4:	f6 c2 01             	test   $0x1,%dl
  8005c7:	74 26                	je     8005ef <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d0:	83 ec 0c             	sub    $0xc,%esp
  8005d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d8:	50                   	push   %eax
  8005d9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005dc:	6a 00                	push   $0x0
  8005de:	57                   	push   %edi
  8005df:	6a 00                	push   $0x0
  8005e1:	e8 b3 fb ff ff       	call   800199 <sys_page_map>
  8005e6:	89 c7                	mov    %eax,%edi
  8005e8:	83 c4 20             	add    $0x20,%esp
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	78 2e                	js     80061d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f2:	89 d0                	mov    %edx,%eax
  8005f4:	c1 e8 0c             	shr    $0xc,%eax
  8005f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fe:	83 ec 0c             	sub    $0xc,%esp
  800601:	25 07 0e 00 00       	and    $0xe07,%eax
  800606:	50                   	push   %eax
  800607:	53                   	push   %ebx
  800608:	6a 00                	push   $0x0
  80060a:	52                   	push   %edx
  80060b:	6a 00                	push   $0x0
  80060d:	e8 87 fb ff ff       	call   800199 <sys_page_map>
  800612:	89 c7                	mov    %eax,%edi
  800614:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800617:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800619:	85 ff                	test   %edi,%edi
  80061b:	79 1d                	jns    80063a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	53                   	push   %ebx
  800621:	6a 00                	push   $0x0
  800623:	e8 b3 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800628:	83 c4 08             	add    $0x8,%esp
  80062b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80062e:	6a 00                	push   $0x0
  800630:	e8 a6 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	89 f8                	mov    %edi,%eax
}
  80063a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063d:	5b                   	pop    %ebx
  80063e:	5e                   	pop    %esi
  80063f:	5f                   	pop    %edi
  800640:	5d                   	pop    %ebp
  800641:	c3                   	ret    

00800642 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	53                   	push   %ebx
  800646:	83 ec 14             	sub    $0x14,%esp
  800649:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064f:	50                   	push   %eax
  800650:	53                   	push   %ebx
  800651:	e8 86 fd ff ff       	call   8003dc <fd_lookup>
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	89 c2                	mov    %eax,%edx
  80065b:	85 c0                	test   %eax,%eax
  80065d:	78 6d                	js     8006cc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800665:	50                   	push   %eax
  800666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800669:	ff 30                	pushl  (%eax)
  80066b:	e8 c2 fd ff ff       	call   800432 <dev_lookup>
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	85 c0                	test   %eax,%eax
  800675:	78 4c                	js     8006c3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800677:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80067a:	8b 42 08             	mov    0x8(%edx),%eax
  80067d:	83 e0 03             	and    $0x3,%eax
  800680:	83 f8 01             	cmp    $0x1,%eax
  800683:	75 21                	jne    8006a6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800685:	a1 08 40 80 00       	mov    0x804008,%eax
  80068a:	8b 40 48             	mov    0x48(%eax),%eax
  80068d:	83 ec 04             	sub    $0x4,%esp
  800690:	53                   	push   %ebx
  800691:	50                   	push   %eax
  800692:	68 d9 22 80 00       	push   $0x8022d9
  800697:	e8 00 0f 00 00       	call   80159c <cprintf>
		return -E_INVAL;
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006a4:	eb 26                	jmp    8006cc <read+0x8a>
	}
	if (!dev->dev_read)
  8006a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a9:	8b 40 08             	mov    0x8(%eax),%eax
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	74 17                	je     8006c7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b0:	83 ec 04             	sub    $0x4,%esp
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	ff 75 0c             	pushl  0xc(%ebp)
  8006b9:	52                   	push   %edx
  8006ba:	ff d0                	call   *%eax
  8006bc:	89 c2                	mov    %eax,%edx
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb 09                	jmp    8006cc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c3:	89 c2                	mov    %eax,%edx
  8006c5:	eb 05                	jmp    8006cc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006cc:	89 d0                	mov    %edx,%eax
  8006ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d1:	c9                   	leave  
  8006d2:	c3                   	ret    

008006d3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	57                   	push   %edi
  8006d7:	56                   	push   %esi
  8006d8:	53                   	push   %ebx
  8006d9:	83 ec 0c             	sub    $0xc,%esp
  8006dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006df:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e7:	eb 21                	jmp    80070a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e9:	83 ec 04             	sub    $0x4,%esp
  8006ec:	89 f0                	mov    %esi,%eax
  8006ee:	29 d8                	sub    %ebx,%eax
  8006f0:	50                   	push   %eax
  8006f1:	89 d8                	mov    %ebx,%eax
  8006f3:	03 45 0c             	add    0xc(%ebp),%eax
  8006f6:	50                   	push   %eax
  8006f7:	57                   	push   %edi
  8006f8:	e8 45 ff ff ff       	call   800642 <read>
		if (m < 0)
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	85 c0                	test   %eax,%eax
  800702:	78 10                	js     800714 <readn+0x41>
			return m;
		if (m == 0)
  800704:	85 c0                	test   %eax,%eax
  800706:	74 0a                	je     800712 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800708:	01 c3                	add    %eax,%ebx
  80070a:	39 f3                	cmp    %esi,%ebx
  80070c:	72 db                	jb     8006e9 <readn+0x16>
  80070e:	89 d8                	mov    %ebx,%eax
  800710:	eb 02                	jmp    800714 <readn+0x41>
  800712:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800714:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800717:	5b                   	pop    %ebx
  800718:	5e                   	pop    %esi
  800719:	5f                   	pop    %edi
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	83 ec 14             	sub    $0x14,%esp
  800723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800726:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	53                   	push   %ebx
  80072b:	e8 ac fc ff ff       	call   8003dc <fd_lookup>
  800730:	83 c4 08             	add    $0x8,%esp
  800733:	89 c2                	mov    %eax,%edx
  800735:	85 c0                	test   %eax,%eax
  800737:	78 68                	js     8007a1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073f:	50                   	push   %eax
  800740:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800743:	ff 30                	pushl  (%eax)
  800745:	e8 e8 fc ff ff       	call   800432 <dev_lookup>
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	85 c0                	test   %eax,%eax
  80074f:	78 47                	js     800798 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800751:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800754:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800758:	75 21                	jne    80077b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075a:	a1 08 40 80 00       	mov    0x804008,%eax
  80075f:	8b 40 48             	mov    0x48(%eax),%eax
  800762:	83 ec 04             	sub    $0x4,%esp
  800765:	53                   	push   %ebx
  800766:	50                   	push   %eax
  800767:	68 f5 22 80 00       	push   $0x8022f5
  80076c:	e8 2b 0e 00 00       	call   80159c <cprintf>
		return -E_INVAL;
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800779:	eb 26                	jmp    8007a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077e:	8b 52 0c             	mov    0xc(%edx),%edx
  800781:	85 d2                	test   %edx,%edx
  800783:	74 17                	je     80079c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800785:	83 ec 04             	sub    $0x4,%esp
  800788:	ff 75 10             	pushl  0x10(%ebp)
  80078b:	ff 75 0c             	pushl  0xc(%ebp)
  80078e:	50                   	push   %eax
  80078f:	ff d2                	call   *%edx
  800791:	89 c2                	mov    %eax,%edx
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 09                	jmp    8007a1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800798:	89 c2                	mov    %eax,%edx
  80079a:	eb 05                	jmp    8007a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80079c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a1:	89 d0                	mov    %edx,%eax
  8007a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ae:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	ff 75 08             	pushl  0x8(%ebp)
  8007b5:	e8 22 fc ff ff       	call   8003dc <fd_lookup>
  8007ba:	83 c4 08             	add    $0x8,%esp
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	78 0e                	js     8007cf <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	53                   	push   %ebx
  8007d5:	83 ec 14             	sub    $0x14,%esp
  8007d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007de:	50                   	push   %eax
  8007df:	53                   	push   %ebx
  8007e0:	e8 f7 fb ff ff       	call   8003dc <fd_lookup>
  8007e5:	83 c4 08             	add    $0x8,%esp
  8007e8:	89 c2                	mov    %eax,%edx
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	78 65                	js     800853 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f4:	50                   	push   %eax
  8007f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f8:	ff 30                	pushl  (%eax)
  8007fa:	e8 33 fc ff ff       	call   800432 <dev_lookup>
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	85 c0                	test   %eax,%eax
  800804:	78 44                	js     80084a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800806:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800809:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080d:	75 21                	jne    800830 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80080f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800814:	8b 40 48             	mov    0x48(%eax),%eax
  800817:	83 ec 04             	sub    $0x4,%esp
  80081a:	53                   	push   %ebx
  80081b:	50                   	push   %eax
  80081c:	68 b8 22 80 00       	push   $0x8022b8
  800821:	e8 76 0d 00 00       	call   80159c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80082e:	eb 23                	jmp    800853 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800830:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800833:	8b 52 18             	mov    0x18(%edx),%edx
  800836:	85 d2                	test   %edx,%edx
  800838:	74 14                	je     80084e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	ff 75 0c             	pushl  0xc(%ebp)
  800840:	50                   	push   %eax
  800841:	ff d2                	call   *%edx
  800843:	89 c2                	mov    %eax,%edx
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	eb 09                	jmp    800853 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084a:	89 c2                	mov    %eax,%edx
  80084c:	eb 05                	jmp    800853 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80084e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800853:	89 d0                	mov    %edx,%eax
  800855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	83 ec 14             	sub    $0x14,%esp
  800861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800864:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800867:	50                   	push   %eax
  800868:	ff 75 08             	pushl  0x8(%ebp)
  80086b:	e8 6c fb ff ff       	call   8003dc <fd_lookup>
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	89 c2                	mov    %eax,%edx
  800875:	85 c0                	test   %eax,%eax
  800877:	78 58                	js     8008d1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800879:	83 ec 08             	sub    $0x8,%esp
  80087c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087f:	50                   	push   %eax
  800880:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800883:	ff 30                	pushl  (%eax)
  800885:	e8 a8 fb ff ff       	call   800432 <dev_lookup>
  80088a:	83 c4 10             	add    $0x10,%esp
  80088d:	85 c0                	test   %eax,%eax
  80088f:	78 37                	js     8008c8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800891:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800894:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800898:	74 32                	je     8008cc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80089a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80089d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a4:	00 00 00 
	stat->st_isdir = 0;
  8008a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ae:	00 00 00 
	stat->st_dev = dev;
  8008b1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8008be:	ff 50 14             	call   *0x14(%eax)
  8008c1:	89 c2                	mov    %eax,%edx
  8008c3:	83 c4 10             	add    $0x10,%esp
  8008c6:	eb 09                	jmp    8008d1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c8:	89 c2                	mov    %eax,%edx
  8008ca:	eb 05                	jmp    8008d1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d1:	89 d0                	mov    %edx,%eax
  8008d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008dd:	83 ec 08             	sub    $0x8,%esp
  8008e0:	6a 00                	push   $0x0
  8008e2:	ff 75 08             	pushl  0x8(%ebp)
  8008e5:	e8 ef 01 00 00       	call   800ad9 <open>
  8008ea:	89 c3                	mov    %eax,%ebx
  8008ec:	83 c4 10             	add    $0x10,%esp
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	78 1b                	js     80090e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f3:	83 ec 08             	sub    $0x8,%esp
  8008f6:	ff 75 0c             	pushl  0xc(%ebp)
  8008f9:	50                   	push   %eax
  8008fa:	e8 5b ff ff ff       	call   80085a <fstat>
  8008ff:	89 c6                	mov    %eax,%esi
	close(fd);
  800901:	89 1c 24             	mov    %ebx,(%esp)
  800904:	e8 fd fb ff ff       	call   800506 <close>
	return r;
  800909:	83 c4 10             	add    $0x10,%esp
  80090c:	89 f0                	mov    %esi,%eax
}
  80090e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	89 c6                	mov    %eax,%esi
  80091c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80091e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800925:	75 12                	jne    800939 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800927:	83 ec 0c             	sub    $0xc,%esp
  80092a:	6a 01                	push   $0x1
  80092c:	e8 1c 16 00 00       	call   801f4d <ipc_find_env>
  800931:	a3 00 40 80 00       	mov    %eax,0x804000
  800936:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800939:	6a 07                	push   $0x7
  80093b:	68 00 50 80 00       	push   $0x805000
  800940:	56                   	push   %esi
  800941:	ff 35 00 40 80 00    	pushl  0x804000
  800947:	e8 b2 15 00 00       	call   801efe <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80094c:	83 c4 0c             	add    $0xc,%esp
  80094f:	6a 00                	push   $0x0
  800951:	53                   	push   %ebx
  800952:	6a 00                	push   $0x0
  800954:	e8 2f 15 00 00       	call   801e88 <ipc_recv>
}
  800959:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 40 0c             	mov    0xc(%eax),%eax
  80096c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800971:	8b 45 0c             	mov    0xc(%ebp),%eax
  800974:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800979:	ba 00 00 00 00       	mov    $0x0,%edx
  80097e:	b8 02 00 00 00       	mov    $0x2,%eax
  800983:	e8 8d ff ff ff       	call   800915 <fsipc>
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 40 0c             	mov    0xc(%eax),%eax
  800996:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099b:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a5:	e8 6b ff ff ff       	call   800915 <fsipc>
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	53                   	push   %ebx
  8009b0:	83 ec 04             	sub    $0x4,%esp
  8009b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009cb:	e8 45 ff ff ff       	call   800915 <fsipc>
  8009d0:	85 c0                	test   %eax,%eax
  8009d2:	78 2c                	js     800a00 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d4:	83 ec 08             	sub    $0x8,%esp
  8009d7:	68 00 50 80 00       	push   $0x805000
  8009dc:	53                   	push   %ebx
  8009dd:	e8 5f 11 00 00       	call   801b41 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ed:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009f8:	83 c4 10             	add    $0x10,%esp
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    

00800a05 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	53                   	push   %ebx
  800a09:	83 ec 08             	sub    $0x8,%esp
  800a0c:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a12:	8b 52 0c             	mov    0xc(%edx),%edx
  800a15:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a1b:	a3 04 50 80 00       	mov    %eax,0x805004
  800a20:	3d 08 50 80 00       	cmp    $0x805008,%eax
  800a25:	bb 08 50 80 00       	mov    $0x805008,%ebx
  800a2a:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a2d:	53                   	push   %ebx
  800a2e:	ff 75 0c             	pushl  0xc(%ebp)
  800a31:	68 08 50 80 00       	push   $0x805008
  800a36:	e8 98 12 00 00       	call   801cd3 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a40:	b8 04 00 00 00       	mov    $0x4,%eax
  800a45:	e8 cb fe ff ff       	call   800915 <fsipc>
  800a4a:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  800a52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 40 0c             	mov    0xc(%eax),%eax
  800a65:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a6a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a70:	ba 00 00 00 00       	mov    $0x0,%edx
  800a75:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7a:	e8 96 fe ff ff       	call   800915 <fsipc>
  800a7f:	89 c3                	mov    %eax,%ebx
  800a81:	85 c0                	test   %eax,%eax
  800a83:	78 4b                	js     800ad0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a85:	39 c6                	cmp    %eax,%esi
  800a87:	73 16                	jae    800a9f <devfile_read+0x48>
  800a89:	68 28 23 80 00       	push   $0x802328
  800a8e:	68 2f 23 80 00       	push   $0x80232f
  800a93:	6a 7c                	push   $0x7c
  800a95:	68 44 23 80 00       	push   $0x802344
  800a9a:	e8 24 0a 00 00       	call   8014c3 <_panic>
	assert(r <= PGSIZE);
  800a9f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa4:	7e 16                	jle    800abc <devfile_read+0x65>
  800aa6:	68 4f 23 80 00       	push   $0x80234f
  800aab:	68 2f 23 80 00       	push   $0x80232f
  800ab0:	6a 7d                	push   $0x7d
  800ab2:	68 44 23 80 00       	push   $0x802344
  800ab7:	e8 07 0a 00 00       	call   8014c3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800abc:	83 ec 04             	sub    $0x4,%esp
  800abf:	50                   	push   %eax
  800ac0:	68 00 50 80 00       	push   $0x805000
  800ac5:	ff 75 0c             	pushl  0xc(%ebp)
  800ac8:	e8 06 12 00 00       	call   801cd3 <memmove>
	return r;
  800acd:	83 c4 10             	add    $0x10,%esp
}
  800ad0:	89 d8                	mov    %ebx,%eax
  800ad2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	53                   	push   %ebx
  800add:	83 ec 20             	sub    $0x20,%esp
  800ae0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae3:	53                   	push   %ebx
  800ae4:	e8 1f 10 00 00       	call   801b08 <strlen>
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af1:	7f 67                	jg     800b5a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af3:	83 ec 0c             	sub    $0xc,%esp
  800af6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af9:	50                   	push   %eax
  800afa:	e8 8e f8 ff ff       	call   80038d <fd_alloc>
  800aff:	83 c4 10             	add    $0x10,%esp
		return r;
  800b02:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b04:	85 c0                	test   %eax,%eax
  800b06:	78 57                	js     800b5f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	53                   	push   %ebx
  800b0c:	68 00 50 80 00       	push   $0x805000
  800b11:	e8 2b 10 00 00       	call   801b41 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b19:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b21:	b8 01 00 00 00       	mov    $0x1,%eax
  800b26:	e8 ea fd ff ff       	call   800915 <fsipc>
  800b2b:	89 c3                	mov    %eax,%ebx
  800b2d:	83 c4 10             	add    $0x10,%esp
  800b30:	85 c0                	test   %eax,%eax
  800b32:	79 14                	jns    800b48 <open+0x6f>
		fd_close(fd, 0);
  800b34:	83 ec 08             	sub    $0x8,%esp
  800b37:	6a 00                	push   $0x0
  800b39:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3c:	e8 44 f9 ff ff       	call   800485 <fd_close>
		return r;
  800b41:	83 c4 10             	add    $0x10,%esp
  800b44:	89 da                	mov    %ebx,%edx
  800b46:	eb 17                	jmp    800b5f <open+0x86>
	}

	return fd2num(fd);
  800b48:	83 ec 0c             	sub    $0xc,%esp
  800b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4e:	e8 13 f8 ff ff       	call   800366 <fd2num>
  800b53:	89 c2                	mov    %eax,%edx
  800b55:	83 c4 10             	add    $0x10,%esp
  800b58:	eb 05                	jmp    800b5f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b5a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b5f:	89 d0                	mov    %edx,%eax
  800b61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 08 00 00 00       	mov    $0x8,%eax
  800b76:	e8 9a fd ff ff       	call   800915 <fsipc>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	ff 75 08             	pushl  0x8(%ebp)
  800b8b:	e8 e6 f7 ff ff       	call   800376 <fd2data>
  800b90:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b92:	83 c4 08             	add    $0x8,%esp
  800b95:	68 5b 23 80 00       	push   $0x80235b
  800b9a:	53                   	push   %ebx
  800b9b:	e8 a1 0f 00 00       	call   801b41 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba0:	8b 46 04             	mov    0x4(%esi),%eax
  800ba3:	2b 06                	sub    (%esi),%eax
  800ba5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb2:	00 00 00 
	stat->st_dev = &devpipe;
  800bb5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bbc:	30 80 00 
	return 0;
}
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 0c             	sub    $0xc,%esp
  800bd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd5:	53                   	push   %ebx
  800bd6:	6a 00                	push   $0x0
  800bd8:	e8 fe f5 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bdd:	89 1c 24             	mov    %ebx,(%esp)
  800be0:	e8 91 f7 ff ff       	call   800376 <fd2data>
  800be5:	83 c4 08             	add    $0x8,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 00                	push   $0x0
  800beb:	e8 eb f5 ff ff       	call   8001db <sys_page_unmap>
}
  800bf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 1c             	sub    $0x1c,%esp
  800bfe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c01:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c03:	a1 08 40 80 00       	mov    0x804008,%eax
  800c08:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	ff 75 e0             	pushl  -0x20(%ebp)
  800c11:	e8 70 13 00 00       	call   801f86 <pageref>
  800c16:	89 c3                	mov    %eax,%ebx
  800c18:	89 3c 24             	mov    %edi,(%esp)
  800c1b:	e8 66 13 00 00       	call   801f86 <pageref>
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	39 c3                	cmp    %eax,%ebx
  800c25:	0f 94 c1             	sete   %cl
  800c28:	0f b6 c9             	movzbl %cl,%ecx
  800c2b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c2e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c34:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c37:	39 ce                	cmp    %ecx,%esi
  800c39:	74 1b                	je     800c56 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c3b:	39 c3                	cmp    %eax,%ebx
  800c3d:	75 c4                	jne    800c03 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c3f:	8b 42 58             	mov    0x58(%edx),%eax
  800c42:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c45:	50                   	push   %eax
  800c46:	56                   	push   %esi
  800c47:	68 62 23 80 00       	push   $0x802362
  800c4c:	e8 4b 09 00 00       	call   80159c <cprintf>
  800c51:	83 c4 10             	add    $0x10,%esp
  800c54:	eb ad                	jmp    800c03 <_pipeisclosed+0xe>
	}
}
  800c56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 28             	sub    $0x28,%esp
  800c6a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c6d:	56                   	push   %esi
  800c6e:	e8 03 f7 ff ff       	call   800376 <fd2data>
  800c73:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7d:	eb 4b                	jmp    800cca <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c7f:	89 da                	mov    %ebx,%edx
  800c81:	89 f0                	mov    %esi,%eax
  800c83:	e8 6d ff ff ff       	call   800bf5 <_pipeisclosed>
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	75 48                	jne    800cd4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c8c:	e8 a6 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c91:	8b 43 04             	mov    0x4(%ebx),%eax
  800c94:	8b 0b                	mov    (%ebx),%ecx
  800c96:	8d 51 20             	lea    0x20(%ecx),%edx
  800c99:	39 d0                	cmp    %edx,%eax
  800c9b:	73 e2                	jae    800c7f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca7:	89 c2                	mov    %eax,%edx
  800ca9:	c1 fa 1f             	sar    $0x1f,%edx
  800cac:	89 d1                	mov    %edx,%ecx
  800cae:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb4:	83 e2 1f             	and    $0x1f,%edx
  800cb7:	29 ca                	sub    %ecx,%edx
  800cb9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cbd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc1:	83 c0 01             	add    $0x1,%eax
  800cc4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc7:	83 c7 01             	add    $0x1,%edi
  800cca:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ccd:	75 c2                	jne    800c91 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ccf:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd2:	eb 05                	jmp    800cd9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 18             	sub    $0x18,%esp
  800cea:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ced:	57                   	push   %edi
  800cee:	e8 83 f6 ff ff       	call   800376 <fd2data>
  800cf3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf5:	83 c4 10             	add    $0x10,%esp
  800cf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfd:	eb 3d                	jmp    800d3c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cff:	85 db                	test   %ebx,%ebx
  800d01:	74 04                	je     800d07 <devpipe_read+0x26>
				return i;
  800d03:	89 d8                	mov    %ebx,%eax
  800d05:	eb 44                	jmp    800d4b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d07:	89 f2                	mov    %esi,%edx
  800d09:	89 f8                	mov    %edi,%eax
  800d0b:	e8 e5 fe ff ff       	call   800bf5 <_pipeisclosed>
  800d10:	85 c0                	test   %eax,%eax
  800d12:	75 32                	jne    800d46 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d14:	e8 1e f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d19:	8b 06                	mov    (%esi),%eax
  800d1b:	3b 46 04             	cmp    0x4(%esi),%eax
  800d1e:	74 df                	je     800cff <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d20:	99                   	cltd   
  800d21:	c1 ea 1b             	shr    $0x1b,%edx
  800d24:	01 d0                	add    %edx,%eax
  800d26:	83 e0 1f             	and    $0x1f,%eax
  800d29:	29 d0                	sub    %edx,%eax
  800d2b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d36:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d39:	83 c3 01             	add    $0x1,%ebx
  800d3c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d3f:	75 d8                	jne    800d19 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d41:	8b 45 10             	mov    0x10(%ebp),%eax
  800d44:	eb 05                	jmp    800d4b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5e:	50                   	push   %eax
  800d5f:	e8 29 f6 ff ff       	call   80038d <fd_alloc>
  800d64:	83 c4 10             	add    $0x10,%esp
  800d67:	89 c2                	mov    %eax,%edx
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	0f 88 2c 01 00 00    	js     800e9d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d71:	83 ec 04             	sub    $0x4,%esp
  800d74:	68 07 04 00 00       	push   $0x407
  800d79:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7c:	6a 00                	push   $0x0
  800d7e:	e8 d3 f3 ff ff       	call   800156 <sys_page_alloc>
  800d83:	83 c4 10             	add    $0x10,%esp
  800d86:	89 c2                	mov    %eax,%edx
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	0f 88 0d 01 00 00    	js     800e9d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d96:	50                   	push   %eax
  800d97:	e8 f1 f5 ff ff       	call   80038d <fd_alloc>
  800d9c:	89 c3                	mov    %eax,%ebx
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	85 c0                	test   %eax,%eax
  800da3:	0f 88 e2 00 00 00    	js     800e8b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da9:	83 ec 04             	sub    $0x4,%esp
  800dac:	68 07 04 00 00       	push   $0x407
  800db1:	ff 75 f0             	pushl  -0x10(%ebp)
  800db4:	6a 00                	push   $0x0
  800db6:	e8 9b f3 ff ff       	call   800156 <sys_page_alloc>
  800dbb:	89 c3                	mov    %eax,%ebx
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	0f 88 c3 00 00 00    	js     800e8b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	ff 75 f4             	pushl  -0xc(%ebp)
  800dce:	e8 a3 f5 ff ff       	call   800376 <fd2data>
  800dd3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd5:	83 c4 0c             	add    $0xc,%esp
  800dd8:	68 07 04 00 00       	push   $0x407
  800ddd:	50                   	push   %eax
  800dde:	6a 00                	push   $0x0
  800de0:	e8 71 f3 ff ff       	call   800156 <sys_page_alloc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 88 89 00 00 00    	js     800e7b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	ff 75 f0             	pushl  -0x10(%ebp)
  800df8:	e8 79 f5 ff ff       	call   800376 <fd2data>
  800dfd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e04:	50                   	push   %eax
  800e05:	6a 00                	push   $0x0
  800e07:	56                   	push   %esi
  800e08:	6a 00                	push   $0x0
  800e0a:	e8 8a f3 ff ff       	call   800199 <sys_page_map>
  800e0f:	89 c3                	mov    %eax,%ebx
  800e11:	83 c4 20             	add    $0x20,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	78 55                	js     800e6d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e21:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e36:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	ff 75 f4             	pushl  -0xc(%ebp)
  800e48:	e8 19 f5 ff ff       	call   800366 <fd2num>
  800e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e50:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e52:	83 c4 04             	add    $0x4,%esp
  800e55:	ff 75 f0             	pushl  -0x10(%ebp)
  800e58:	e8 09 f5 ff ff       	call   800366 <fd2num>
  800e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e60:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6b:	eb 30                	jmp    800e9d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	56                   	push   %esi
  800e71:	6a 00                	push   $0x0
  800e73:	e8 63 f3 ff ff       	call   8001db <sys_page_unmap>
  800e78:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e7b:	83 ec 08             	sub    $0x8,%esp
  800e7e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e81:	6a 00                	push   $0x0
  800e83:	e8 53 f3 ff ff       	call   8001db <sys_page_unmap>
  800e88:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e8b:	83 ec 08             	sub    $0x8,%esp
  800e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e91:	6a 00                	push   $0x0
  800e93:	e8 43 f3 ff ff       	call   8001db <sys_page_unmap>
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e9d:	89 d0                	mov    %edx,%eax
  800e9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eaf:	50                   	push   %eax
  800eb0:	ff 75 08             	pushl  0x8(%ebp)
  800eb3:	e8 24 f5 ff ff       	call   8003dc <fd_lookup>
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 18                	js     800ed7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec5:	e8 ac f4 ff ff       	call   800376 <fd2data>
	return _pipeisclosed(fd, p);
  800eca:	89 c2                	mov    %eax,%edx
  800ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ecf:	e8 21 fd ff ff       	call   800bf5 <_pipeisclosed>
  800ed4:	83 c4 10             	add    $0x10,%esp
}
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800edf:	68 7a 23 80 00       	push   $0x80237a
  800ee4:	ff 75 0c             	pushl  0xc(%ebp)
  800ee7:	e8 55 0c 00 00       	call   801b41 <strcpy>
	return 0;
}
  800eec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	53                   	push   %ebx
  800ef7:	83 ec 10             	sub    $0x10,%esp
  800efa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800efd:	53                   	push   %ebx
  800efe:	e8 83 10 00 00       	call   801f86 <pageref>
  800f03:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800f06:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800f0b:	83 f8 01             	cmp    $0x1,%eax
  800f0e:	75 10                	jne    800f20 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	ff 73 0c             	pushl  0xc(%ebx)
  800f16:	e8 c0 02 00 00       	call   8011db <nsipc_close>
  800f1b:	89 c2                	mov    %eax,%edx
  800f1d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f20:	89 d0                	mov    %edx,%eax
  800f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f2d:	6a 00                	push   $0x0
  800f2f:	ff 75 10             	pushl  0x10(%ebp)
  800f32:	ff 75 0c             	pushl  0xc(%ebp)
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
  800f38:	ff 70 0c             	pushl  0xc(%eax)
  800f3b:	e8 78 03 00 00       	call   8012b8 <nsipc_send>
}
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f48:	6a 00                	push   $0x0
  800f4a:	ff 75 10             	pushl  0x10(%ebp)
  800f4d:	ff 75 0c             	pushl  0xc(%ebp)
  800f50:	8b 45 08             	mov    0x8(%ebp),%eax
  800f53:	ff 70 0c             	pushl  0xc(%eax)
  800f56:	e8 f1 02 00 00       	call   80124c <nsipc_recv>
}
  800f5b:	c9                   	leave  
  800f5c:	c3                   	ret    

00800f5d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f63:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f66:	52                   	push   %edx
  800f67:	50                   	push   %eax
  800f68:	e8 6f f4 ff ff       	call   8003dc <fd_lookup>
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	78 17                	js     800f8b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f77:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  800f7d:	39 08                	cmp    %ecx,(%eax)
  800f7f:	75 05                	jne    800f86 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f81:	8b 40 0c             	mov    0xc(%eax),%eax
  800f84:	eb 05                	jmp    800f8b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800f86:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	83 ec 1c             	sub    $0x1c,%esp
  800f95:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800f97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9a:	50                   	push   %eax
  800f9b:	e8 ed f3 ff ff       	call   80038d <fd_alloc>
  800fa0:	89 c3                	mov    %eax,%ebx
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 1b                	js     800fc4 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	68 07 04 00 00       	push   $0x407
  800fb1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb4:	6a 00                	push   $0x0
  800fb6:	e8 9b f1 ff ff       	call   800156 <sys_page_alloc>
  800fbb:	89 c3                	mov    %eax,%ebx
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	79 10                	jns    800fd4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	56                   	push   %esi
  800fc8:	e8 0e 02 00 00       	call   8011db <nsipc_close>
		return r;
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	89 d8                	mov    %ebx,%eax
  800fd2:	eb 24                	jmp    800ff8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800fd4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800fe9:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800fec:	83 ec 0c             	sub    $0xc,%esp
  800fef:	50                   	push   %eax
  800ff0:	e8 71 f3 ff ff       	call   800366 <fd2num>
  800ff5:	83 c4 10             	add    $0x10,%esp
}
  800ff8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ffb:	5b                   	pop    %ebx
  800ffc:	5e                   	pop    %esi
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801005:	8b 45 08             	mov    0x8(%ebp),%eax
  801008:	e8 50 ff ff ff       	call   800f5d <fd2sockid>
		return r;
  80100d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 1f                	js     801032 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801013:	83 ec 04             	sub    $0x4,%esp
  801016:	ff 75 10             	pushl  0x10(%ebp)
  801019:	ff 75 0c             	pushl  0xc(%ebp)
  80101c:	50                   	push   %eax
  80101d:	e8 12 01 00 00       	call   801134 <nsipc_accept>
  801022:	83 c4 10             	add    $0x10,%esp
		return r;
  801025:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801027:	85 c0                	test   %eax,%eax
  801029:	78 07                	js     801032 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80102b:	e8 5d ff ff ff       	call   800f8d <alloc_sockfd>
  801030:	89 c1                	mov    %eax,%ecx
}
  801032:	89 c8                	mov    %ecx,%eax
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80103c:	8b 45 08             	mov    0x8(%ebp),%eax
  80103f:	e8 19 ff ff ff       	call   800f5d <fd2sockid>
  801044:	85 c0                	test   %eax,%eax
  801046:	78 12                	js     80105a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801048:	83 ec 04             	sub    $0x4,%esp
  80104b:	ff 75 10             	pushl  0x10(%ebp)
  80104e:	ff 75 0c             	pushl  0xc(%ebp)
  801051:	50                   	push   %eax
  801052:	e8 2d 01 00 00       	call   801184 <nsipc_bind>
  801057:	83 c4 10             	add    $0x10,%esp
}
  80105a:	c9                   	leave  
  80105b:	c3                   	ret    

0080105c <shutdown>:

int
shutdown(int s, int how)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801062:	8b 45 08             	mov    0x8(%ebp),%eax
  801065:	e8 f3 fe ff ff       	call   800f5d <fd2sockid>
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 0f                	js     80107d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80106e:	83 ec 08             	sub    $0x8,%esp
  801071:	ff 75 0c             	pushl  0xc(%ebp)
  801074:	50                   	push   %eax
  801075:	e8 3f 01 00 00       	call   8011b9 <nsipc_shutdown>
  80107a:	83 c4 10             	add    $0x10,%esp
}
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801085:	8b 45 08             	mov    0x8(%ebp),%eax
  801088:	e8 d0 fe ff ff       	call   800f5d <fd2sockid>
  80108d:	85 c0                	test   %eax,%eax
  80108f:	78 12                	js     8010a3 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	ff 75 10             	pushl  0x10(%ebp)
  801097:	ff 75 0c             	pushl  0xc(%ebp)
  80109a:	50                   	push   %eax
  80109b:	e8 55 01 00 00       	call   8011f5 <nsipc_connect>
  8010a0:	83 c4 10             	add    $0x10,%esp
}
  8010a3:	c9                   	leave  
  8010a4:	c3                   	ret    

008010a5 <listen>:

int
listen(int s, int backlog)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ae:	e8 aa fe ff ff       	call   800f5d <fd2sockid>
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	78 0f                	js     8010c6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8010b7:	83 ec 08             	sub    $0x8,%esp
  8010ba:	ff 75 0c             	pushl  0xc(%ebp)
  8010bd:	50                   	push   %eax
  8010be:	e8 67 01 00 00       	call   80122a <nsipc_listen>
  8010c3:	83 c4 10             	add    $0x10,%esp
}
  8010c6:	c9                   	leave  
  8010c7:	c3                   	ret    

008010c8 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8010ce:	ff 75 10             	pushl  0x10(%ebp)
  8010d1:	ff 75 0c             	pushl  0xc(%ebp)
  8010d4:	ff 75 08             	pushl  0x8(%ebp)
  8010d7:	e8 3a 02 00 00       	call   801316 <nsipc_socket>
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	78 05                	js     8010e8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8010e3:	e8 a5 fe ff ff       	call   800f8d <alloc_sockfd>
}
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8010f3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8010fa:	75 12                	jne    80110e <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8010fc:	83 ec 0c             	sub    $0xc,%esp
  8010ff:	6a 02                	push   $0x2
  801101:	e8 47 0e 00 00       	call   801f4d <ipc_find_env>
  801106:	a3 04 40 80 00       	mov    %eax,0x804004
  80110b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80110e:	6a 07                	push   $0x7
  801110:	68 00 60 80 00       	push   $0x806000
  801115:	53                   	push   %ebx
  801116:	ff 35 04 40 80 00    	pushl  0x804004
  80111c:	e8 dd 0d 00 00       	call   801efe <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801121:	83 c4 0c             	add    $0xc,%esp
  801124:	6a 00                	push   $0x0
  801126:	6a 00                	push   $0x0
  801128:	6a 00                	push   $0x0
  80112a:	e8 59 0d 00 00       	call   801e88 <ipc_recv>
}
  80112f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801132:	c9                   	leave  
  801133:	c3                   	ret    

00801134 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80113c:	8b 45 08             	mov    0x8(%ebp),%eax
  80113f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801144:	8b 06                	mov    (%esi),%eax
  801146:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80114b:	b8 01 00 00 00       	mov    $0x1,%eax
  801150:	e8 95 ff ff ff       	call   8010ea <nsipc>
  801155:	89 c3                	mov    %eax,%ebx
  801157:	85 c0                	test   %eax,%eax
  801159:	78 20                	js     80117b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	ff 35 10 60 80 00    	pushl  0x806010
  801164:	68 00 60 80 00       	push   $0x806000
  801169:	ff 75 0c             	pushl  0xc(%ebp)
  80116c:	e8 62 0b 00 00       	call   801cd3 <memmove>
		*addrlen = ret->ret_addrlen;
  801171:	a1 10 60 80 00       	mov    0x806010,%eax
  801176:	89 06                	mov    %eax,(%esi)
  801178:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80117b:	89 d8                	mov    %ebx,%eax
  80117d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	53                   	push   %ebx
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
  801191:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801196:	53                   	push   %ebx
  801197:	ff 75 0c             	pushl  0xc(%ebp)
  80119a:	68 04 60 80 00       	push   $0x806004
  80119f:	e8 2f 0b 00 00       	call   801cd3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8011a4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8011aa:	b8 02 00 00 00       	mov    $0x2,%eax
  8011af:	e8 36 ff ff ff       	call   8010ea <nsipc>
}
  8011b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8011c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ca:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8011cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8011d4:	e8 11 ff ff ff       	call   8010ea <nsipc>
}
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <nsipc_close>:

int
nsipc_close(int s)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8011e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e4:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8011e9:	b8 04 00 00 00       	mov    $0x4,%eax
  8011ee:	e8 f7 fe ff ff       	call   8010ea <nsipc>
}
  8011f3:	c9                   	leave  
  8011f4:	c3                   	ret    

008011f5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8011ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801202:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801207:	53                   	push   %ebx
  801208:	ff 75 0c             	pushl  0xc(%ebp)
  80120b:	68 04 60 80 00       	push   $0x806004
  801210:	e8 be 0a 00 00       	call   801cd3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801215:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80121b:	b8 05 00 00 00       	mov    $0x5,%eax
  801220:	e8 c5 fe ff ff       	call   8010ea <nsipc>
}
  801225:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801228:	c9                   	leave  
  801229:	c3                   	ret    

0080122a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801230:	8b 45 08             	mov    0x8(%ebp),%eax
  801233:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801238:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801240:	b8 06 00 00 00       	mov    $0x6,%eax
  801245:	e8 a0 fe ff ff       	call   8010ea <nsipc>
}
  80124a:	c9                   	leave  
  80124b:	c3                   	ret    

0080124c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801254:	8b 45 08             	mov    0x8(%ebp),%eax
  801257:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80125c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801262:	8b 45 14             	mov    0x14(%ebp),%eax
  801265:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80126a:	b8 07 00 00 00       	mov    $0x7,%eax
  80126f:	e8 76 fe ff ff       	call   8010ea <nsipc>
  801274:	89 c3                	mov    %eax,%ebx
  801276:	85 c0                	test   %eax,%eax
  801278:	78 35                	js     8012af <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80127a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80127f:	7f 04                	jg     801285 <nsipc_recv+0x39>
  801281:	39 c6                	cmp    %eax,%esi
  801283:	7d 16                	jge    80129b <nsipc_recv+0x4f>
  801285:	68 86 23 80 00       	push   $0x802386
  80128a:	68 2f 23 80 00       	push   $0x80232f
  80128f:	6a 62                	push   $0x62
  801291:	68 9b 23 80 00       	push   $0x80239b
  801296:	e8 28 02 00 00       	call   8014c3 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80129b:	83 ec 04             	sub    $0x4,%esp
  80129e:	50                   	push   %eax
  80129f:	68 00 60 80 00       	push   $0x806000
  8012a4:	ff 75 0c             	pushl  0xc(%ebp)
  8012a7:	e8 27 0a 00 00       	call   801cd3 <memmove>
  8012ac:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8012af:	89 d8                	mov    %ebx,%eax
  8012b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b4:	5b                   	pop    %ebx
  8012b5:	5e                   	pop    %esi
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 04             	sub    $0x4,%esp
  8012bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8012c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c5:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8012ca:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8012d0:	7e 16                	jle    8012e8 <nsipc_send+0x30>
  8012d2:	68 a7 23 80 00       	push   $0x8023a7
  8012d7:	68 2f 23 80 00       	push   $0x80232f
  8012dc:	6a 6d                	push   $0x6d
  8012de:	68 9b 23 80 00       	push   $0x80239b
  8012e3:	e8 db 01 00 00       	call   8014c3 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8012e8:	83 ec 04             	sub    $0x4,%esp
  8012eb:	53                   	push   %ebx
  8012ec:	ff 75 0c             	pushl  0xc(%ebp)
  8012ef:	68 0c 60 80 00       	push   $0x80600c
  8012f4:	e8 da 09 00 00       	call   801cd3 <memmove>
	nsipcbuf.send.req_size = size;
  8012f9:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8012ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801302:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801307:	b8 08 00 00 00       	mov    $0x8,%eax
  80130c:	e8 d9 fd ff ff       	call   8010ea <nsipc>
}
  801311:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80131c:	8b 45 08             	mov    0x8(%ebp),%eax
  80131f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801324:	8b 45 0c             	mov    0xc(%ebp),%eax
  801327:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80132c:	8b 45 10             	mov    0x10(%ebp),%eax
  80132f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801334:	b8 09 00 00 00       	mov    $0x9,%eax
  801339:	e8 ac fd ff ff       	call   8010ea <nsipc>
}
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801343:	b8 00 00 00 00       	mov    $0x0,%eax
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801350:	68 b3 23 80 00       	push   $0x8023b3
  801355:	ff 75 0c             	pushl  0xc(%ebp)
  801358:	e8 e4 07 00 00       	call   801b41 <strcpy>
	return 0;
}
  80135d:	b8 00 00 00 00       	mov    $0x0,%eax
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	57                   	push   %edi
  801368:	56                   	push   %esi
  801369:	53                   	push   %ebx
  80136a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801370:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801375:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80137b:	eb 2d                	jmp    8013aa <devcons_write+0x46>
		m = n - tot;
  80137d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801380:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801382:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801385:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80138a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	53                   	push   %ebx
  801391:	03 45 0c             	add    0xc(%ebp),%eax
  801394:	50                   	push   %eax
  801395:	57                   	push   %edi
  801396:	e8 38 09 00 00       	call   801cd3 <memmove>
		sys_cputs(buf, m);
  80139b:	83 c4 08             	add    $0x8,%esp
  80139e:	53                   	push   %ebx
  80139f:	57                   	push   %edi
  8013a0:	e8 f5 ec ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a5:	01 de                	add    %ebx,%esi
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	89 f0                	mov    %esi,%eax
  8013ac:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013af:	72 cc                	jb     80137d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5e                   	pop    %esi
  8013b6:	5f                   	pop    %edi
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    

008013b9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013c8:	74 2a                	je     8013f4 <devcons_read+0x3b>
  8013ca:	eb 05                	jmp    8013d1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013cc:	e8 66 ed ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013d1:	e8 e2 ec ff ff       	call   8000b8 <sys_cgetc>
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	74 f2                	je     8013cc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 16                	js     8013f4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013de:	83 f8 04             	cmp    $0x4,%eax
  8013e1:	74 0c                	je     8013ef <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e6:	88 02                	mov    %al,(%edx)
	return 1;
  8013e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ed:	eb 05                	jmp    8013f4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013ef:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    

008013f6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ff:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801402:	6a 01                	push   $0x1
  801404:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801407:	50                   	push   %eax
  801408:	e8 8d ec ff ff       	call   80009a <sys_cputs>
}
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <getchar>:

int
getchar(void)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801418:	6a 01                	push   $0x1
  80141a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80141d:	50                   	push   %eax
  80141e:	6a 00                	push   $0x0
  801420:	e8 1d f2 ff ff       	call   800642 <read>
	if (r < 0)
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 0f                	js     80143b <getchar+0x29>
		return r;
	if (r < 1)
  80142c:	85 c0                	test   %eax,%eax
  80142e:	7e 06                	jle    801436 <getchar+0x24>
		return -E_EOF;
	return c;
  801430:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801434:	eb 05                	jmp    80143b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801436:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801443:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801446:	50                   	push   %eax
  801447:	ff 75 08             	pushl  0x8(%ebp)
  80144a:	e8 8d ef ff ff       	call   8003dc <fd_lookup>
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 11                	js     801467 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801456:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801459:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80145f:	39 10                	cmp    %edx,(%eax)
  801461:	0f 94 c0             	sete   %al
  801464:	0f b6 c0             	movzbl %al,%eax
}
  801467:	c9                   	leave  
  801468:	c3                   	ret    

00801469 <opencons>:

int
opencons(void)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80146f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801472:	50                   	push   %eax
  801473:	e8 15 ef ff ff       	call   80038d <fd_alloc>
  801478:	83 c4 10             	add    $0x10,%esp
		return r;
  80147b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80147d:	85 c0                	test   %eax,%eax
  80147f:	78 3e                	js     8014bf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801481:	83 ec 04             	sub    $0x4,%esp
  801484:	68 07 04 00 00       	push   $0x407
  801489:	ff 75 f4             	pushl  -0xc(%ebp)
  80148c:	6a 00                	push   $0x0
  80148e:	e8 c3 ec ff ff       	call   800156 <sys_page_alloc>
  801493:	83 c4 10             	add    $0x10,%esp
		return r;
  801496:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 23                	js     8014bf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80149c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014b1:	83 ec 0c             	sub    $0xc,%esp
  8014b4:	50                   	push   %eax
  8014b5:	e8 ac ee ff ff       	call   800366 <fd2num>
  8014ba:	89 c2                	mov    %eax,%edx
  8014bc:	83 c4 10             	add    $0x10,%esp
}
  8014bf:	89 d0                	mov    %edx,%eax
  8014c1:	c9                   	leave  
  8014c2:	c3                   	ret    

008014c3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	56                   	push   %esi
  8014c7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014c8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014cb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014d1:	e8 42 ec ff ff       	call   800118 <sys_getenvid>
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	ff 75 0c             	pushl  0xc(%ebp)
  8014dc:	ff 75 08             	pushl  0x8(%ebp)
  8014df:	56                   	push   %esi
  8014e0:	50                   	push   %eax
  8014e1:	68 c0 23 80 00       	push   $0x8023c0
  8014e6:	e8 b1 00 00 00       	call   80159c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014eb:	83 c4 18             	add    $0x18,%esp
  8014ee:	53                   	push   %ebx
  8014ef:	ff 75 10             	pushl  0x10(%ebp)
  8014f2:	e8 54 00 00 00       	call   80154b <vcprintf>
	cprintf("\n");
  8014f7:	c7 04 24 73 23 80 00 	movl   $0x802373,(%esp)
  8014fe:	e8 99 00 00 00       	call   80159c <cprintf>
  801503:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801506:	cc                   	int3   
  801507:	eb fd                	jmp    801506 <_panic+0x43>

00801509 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	53                   	push   %ebx
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801513:	8b 13                	mov    (%ebx),%edx
  801515:	8d 42 01             	lea    0x1(%edx),%eax
  801518:	89 03                	mov    %eax,(%ebx)
  80151a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80151d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801521:	3d ff 00 00 00       	cmp    $0xff,%eax
  801526:	75 1a                	jne    801542 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	68 ff 00 00 00       	push   $0xff
  801530:	8d 43 08             	lea    0x8(%ebx),%eax
  801533:	50                   	push   %eax
  801534:	e8 61 eb ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  801539:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80153f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801542:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801554:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80155b:	00 00 00 
	b.cnt = 0;
  80155e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801565:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801568:	ff 75 0c             	pushl  0xc(%ebp)
  80156b:	ff 75 08             	pushl  0x8(%ebp)
  80156e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	68 09 15 80 00       	push   $0x801509
  80157a:	e8 54 01 00 00       	call   8016d3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80157f:	83 c4 08             	add    $0x8,%esp
  801582:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801588:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80158e:	50                   	push   %eax
  80158f:	e8 06 eb ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  801594:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80159a:	c9                   	leave  
  80159b:	c3                   	ret    

0080159c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015a5:	50                   	push   %eax
  8015a6:	ff 75 08             	pushl  0x8(%ebp)
  8015a9:	e8 9d ff ff ff       	call   80154b <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	57                   	push   %edi
  8015b4:	56                   	push   %esi
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 1c             	sub    $0x1c,%esp
  8015b9:	89 c7                	mov    %eax,%edi
  8015bb:	89 d6                	mov    %edx,%esi
  8015bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015d4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015d7:	39 d3                	cmp    %edx,%ebx
  8015d9:	72 05                	jb     8015e0 <printnum+0x30>
  8015db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015de:	77 45                	ja     801625 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	ff 75 18             	pushl  0x18(%ebp)
  8015e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015ec:	53                   	push   %ebx
  8015ed:	ff 75 10             	pushl  0x10(%ebp)
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8015fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8015ff:	e8 cc 09 00 00       	call   801fd0 <__udivdi3>
  801604:	83 c4 18             	add    $0x18,%esp
  801607:	52                   	push   %edx
  801608:	50                   	push   %eax
  801609:	89 f2                	mov    %esi,%edx
  80160b:	89 f8                	mov    %edi,%eax
  80160d:	e8 9e ff ff ff       	call   8015b0 <printnum>
  801612:	83 c4 20             	add    $0x20,%esp
  801615:	eb 18                	jmp    80162f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	56                   	push   %esi
  80161b:	ff 75 18             	pushl  0x18(%ebp)
  80161e:	ff d7                	call   *%edi
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	eb 03                	jmp    801628 <printnum+0x78>
  801625:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801628:	83 eb 01             	sub    $0x1,%ebx
  80162b:	85 db                	test   %ebx,%ebx
  80162d:	7f e8                	jg     801617 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	56                   	push   %esi
  801633:	83 ec 04             	sub    $0x4,%esp
  801636:	ff 75 e4             	pushl  -0x1c(%ebp)
  801639:	ff 75 e0             	pushl  -0x20(%ebp)
  80163c:	ff 75 dc             	pushl  -0x24(%ebp)
  80163f:	ff 75 d8             	pushl  -0x28(%ebp)
  801642:	e8 b9 0a 00 00       	call   802100 <__umoddi3>
  801647:	83 c4 14             	add    $0x14,%esp
  80164a:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801651:	50                   	push   %eax
  801652:	ff d7                	call   *%edi
}
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165a:	5b                   	pop    %ebx
  80165b:	5e                   	pop    %esi
  80165c:	5f                   	pop    %edi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    

0080165f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801662:	83 fa 01             	cmp    $0x1,%edx
  801665:	7e 0e                	jle    801675 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801667:	8b 10                	mov    (%eax),%edx
  801669:	8d 4a 08             	lea    0x8(%edx),%ecx
  80166c:	89 08                	mov    %ecx,(%eax)
  80166e:	8b 02                	mov    (%edx),%eax
  801670:	8b 52 04             	mov    0x4(%edx),%edx
  801673:	eb 22                	jmp    801697 <getuint+0x38>
	else if (lflag)
  801675:	85 d2                	test   %edx,%edx
  801677:	74 10                	je     801689 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801679:	8b 10                	mov    (%eax),%edx
  80167b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80167e:	89 08                	mov    %ecx,(%eax)
  801680:	8b 02                	mov    (%edx),%eax
  801682:	ba 00 00 00 00       	mov    $0x0,%edx
  801687:	eb 0e                	jmp    801697 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801689:	8b 10                	mov    (%eax),%edx
  80168b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80168e:	89 08                	mov    %ecx,(%eax)
  801690:	8b 02                	mov    (%edx),%eax
  801692:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80169f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016a3:	8b 10                	mov    (%eax),%edx
  8016a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8016a8:	73 0a                	jae    8016b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016ad:	89 08                	mov    %ecx,(%eax)
  8016af:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b2:	88 02                	mov    %al,(%edx)
}
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016bf:	50                   	push   %eax
  8016c0:	ff 75 10             	pushl  0x10(%ebp)
  8016c3:	ff 75 0c             	pushl  0xc(%ebp)
  8016c6:	ff 75 08             	pushl  0x8(%ebp)
  8016c9:	e8 05 00 00 00       	call   8016d3 <vprintfmt>
	va_end(ap);
}
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	c9                   	leave  
  8016d2:	c3                   	ret    

008016d3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	57                   	push   %edi
  8016d7:	56                   	push   %esi
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 2c             	sub    $0x2c,%esp
  8016dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8016df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016e2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016e5:	eb 12                	jmp    8016f9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	0f 84 a9 03 00 00    	je     801a98 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	53                   	push   %ebx
  8016f3:	50                   	push   %eax
  8016f4:	ff d6                	call   *%esi
  8016f6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016f9:	83 c7 01             	add    $0x1,%edi
  8016fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801700:	83 f8 25             	cmp    $0x25,%eax
  801703:	75 e2                	jne    8016e7 <vprintfmt+0x14>
  801705:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801709:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801710:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801717:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80171e:	ba 00 00 00 00       	mov    $0x0,%edx
  801723:	eb 07                	jmp    80172c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801725:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801728:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80172c:	8d 47 01             	lea    0x1(%edi),%eax
  80172f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801732:	0f b6 07             	movzbl (%edi),%eax
  801735:	0f b6 c8             	movzbl %al,%ecx
  801738:	83 e8 23             	sub    $0x23,%eax
  80173b:	3c 55                	cmp    $0x55,%al
  80173d:	0f 87 3a 03 00 00    	ja     801a7d <vprintfmt+0x3aa>
  801743:	0f b6 c0             	movzbl %al,%eax
  801746:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80174d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801750:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801754:	eb d6                	jmp    80172c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801756:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801759:	b8 00 00 00 00       	mov    $0x0,%eax
  80175e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801761:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801764:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801768:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80176b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80176e:	83 fa 09             	cmp    $0x9,%edx
  801771:	77 39                	ja     8017ac <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801773:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801776:	eb e9                	jmp    801761 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801778:	8b 45 14             	mov    0x14(%ebp),%eax
  80177b:	8d 48 04             	lea    0x4(%eax),%ecx
  80177e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801781:	8b 00                	mov    (%eax),%eax
  801783:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801786:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801789:	eb 27                	jmp    8017b2 <vprintfmt+0xdf>
  80178b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80178e:	85 c0                	test   %eax,%eax
  801790:	b9 00 00 00 00       	mov    $0x0,%ecx
  801795:	0f 49 c8             	cmovns %eax,%ecx
  801798:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80179b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80179e:	eb 8c                	jmp    80172c <vprintfmt+0x59>
  8017a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017aa:	eb 80                	jmp    80172c <vprintfmt+0x59>
  8017ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017af:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017b6:	0f 89 70 ff ff ff    	jns    80172c <vprintfmt+0x59>
				width = precision, precision = -1;
  8017bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017c9:	e9 5e ff ff ff       	jmp    80172c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017ce:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017d4:	e9 53 ff ff ff       	jmp    80172c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017dc:	8d 50 04             	lea    0x4(%eax),%edx
  8017df:	89 55 14             	mov    %edx,0x14(%ebp)
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	53                   	push   %ebx
  8017e6:	ff 30                	pushl  (%eax)
  8017e8:	ff d6                	call   *%esi
			break;
  8017ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017f0:	e9 04 ff ff ff       	jmp    8016f9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f8:	8d 50 04             	lea    0x4(%eax),%edx
  8017fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8017fe:	8b 00                	mov    (%eax),%eax
  801800:	99                   	cltd   
  801801:	31 d0                	xor    %edx,%eax
  801803:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801805:	83 f8 0f             	cmp    $0xf,%eax
  801808:	7f 0b                	jg     801815 <vprintfmt+0x142>
  80180a:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801811:	85 d2                	test   %edx,%edx
  801813:	75 18                	jne    80182d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801815:	50                   	push   %eax
  801816:	68 fb 23 80 00       	push   $0x8023fb
  80181b:	53                   	push   %ebx
  80181c:	56                   	push   %esi
  80181d:	e8 94 fe ff ff       	call   8016b6 <printfmt>
  801822:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801825:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801828:	e9 cc fe ff ff       	jmp    8016f9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80182d:	52                   	push   %edx
  80182e:	68 41 23 80 00       	push   $0x802341
  801833:	53                   	push   %ebx
  801834:	56                   	push   %esi
  801835:	e8 7c fe ff ff       	call   8016b6 <printfmt>
  80183a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801840:	e9 b4 fe ff ff       	jmp    8016f9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801845:	8b 45 14             	mov    0x14(%ebp),%eax
  801848:	8d 50 04             	lea    0x4(%eax),%edx
  80184b:	89 55 14             	mov    %edx,0x14(%ebp)
  80184e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801850:	85 ff                	test   %edi,%edi
  801852:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  801857:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80185a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80185e:	0f 8e 94 00 00 00    	jle    8018f8 <vprintfmt+0x225>
  801864:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801868:	0f 84 98 00 00 00    	je     801906 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80186e:	83 ec 08             	sub    $0x8,%esp
  801871:	ff 75 d0             	pushl  -0x30(%ebp)
  801874:	57                   	push   %edi
  801875:	e8 a6 02 00 00       	call   801b20 <strnlen>
  80187a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80187d:	29 c1                	sub    %eax,%ecx
  80187f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801882:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801885:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801889:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80188c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80188f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801891:	eb 0f                	jmp    8018a2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	53                   	push   %ebx
  801897:	ff 75 e0             	pushl  -0x20(%ebp)
  80189a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80189c:	83 ef 01             	sub    $0x1,%edi
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 ff                	test   %edi,%edi
  8018a4:	7f ed                	jg     801893 <vprintfmt+0x1c0>
  8018a6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018a9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018ac:	85 c9                	test   %ecx,%ecx
  8018ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b3:	0f 49 c1             	cmovns %ecx,%eax
  8018b6:	29 c1                	sub    %eax,%ecx
  8018b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8018bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018c1:	89 cb                	mov    %ecx,%ebx
  8018c3:	eb 4d                	jmp    801912 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018c9:	74 1b                	je     8018e6 <vprintfmt+0x213>
  8018cb:	0f be c0             	movsbl %al,%eax
  8018ce:	83 e8 20             	sub    $0x20,%eax
  8018d1:	83 f8 5e             	cmp    $0x5e,%eax
  8018d4:	76 10                	jbe    8018e6 <vprintfmt+0x213>
					putch('?', putdat);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	ff 75 0c             	pushl  0xc(%ebp)
  8018dc:	6a 3f                	push   $0x3f
  8018de:	ff 55 08             	call   *0x8(%ebp)
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	eb 0d                	jmp    8018f3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	ff 75 0c             	pushl  0xc(%ebp)
  8018ec:	52                   	push   %edx
  8018ed:	ff 55 08             	call   *0x8(%ebp)
  8018f0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018f3:	83 eb 01             	sub    $0x1,%ebx
  8018f6:	eb 1a                	jmp    801912 <vprintfmt+0x23f>
  8018f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8018fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801901:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801904:	eb 0c                	jmp    801912 <vprintfmt+0x23f>
  801906:	89 75 08             	mov    %esi,0x8(%ebp)
  801909:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80190c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80190f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801912:	83 c7 01             	add    $0x1,%edi
  801915:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801919:	0f be d0             	movsbl %al,%edx
  80191c:	85 d2                	test   %edx,%edx
  80191e:	74 23                	je     801943 <vprintfmt+0x270>
  801920:	85 f6                	test   %esi,%esi
  801922:	78 a1                	js     8018c5 <vprintfmt+0x1f2>
  801924:	83 ee 01             	sub    $0x1,%esi
  801927:	79 9c                	jns    8018c5 <vprintfmt+0x1f2>
  801929:	89 df                	mov    %ebx,%edi
  80192b:	8b 75 08             	mov    0x8(%ebp),%esi
  80192e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801931:	eb 18                	jmp    80194b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	53                   	push   %ebx
  801937:	6a 20                	push   $0x20
  801939:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80193b:	83 ef 01             	sub    $0x1,%edi
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	eb 08                	jmp    80194b <vprintfmt+0x278>
  801943:	89 df                	mov    %ebx,%edi
  801945:	8b 75 08             	mov    0x8(%ebp),%esi
  801948:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80194b:	85 ff                	test   %edi,%edi
  80194d:	7f e4                	jg     801933 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80194f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801952:	e9 a2 fd ff ff       	jmp    8016f9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801957:	83 fa 01             	cmp    $0x1,%edx
  80195a:	7e 16                	jle    801972 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80195c:	8b 45 14             	mov    0x14(%ebp),%eax
  80195f:	8d 50 08             	lea    0x8(%eax),%edx
  801962:	89 55 14             	mov    %edx,0x14(%ebp)
  801965:	8b 50 04             	mov    0x4(%eax),%edx
  801968:	8b 00                	mov    (%eax),%eax
  80196a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80196d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801970:	eb 32                	jmp    8019a4 <vprintfmt+0x2d1>
	else if (lflag)
  801972:	85 d2                	test   %edx,%edx
  801974:	74 18                	je     80198e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801976:	8b 45 14             	mov    0x14(%ebp),%eax
  801979:	8d 50 04             	lea    0x4(%eax),%edx
  80197c:	89 55 14             	mov    %edx,0x14(%ebp)
  80197f:	8b 00                	mov    (%eax),%eax
  801981:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801984:	89 c1                	mov    %eax,%ecx
  801986:	c1 f9 1f             	sar    $0x1f,%ecx
  801989:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80198c:	eb 16                	jmp    8019a4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80198e:	8b 45 14             	mov    0x14(%ebp),%eax
  801991:	8d 50 04             	lea    0x4(%eax),%edx
  801994:	89 55 14             	mov    %edx,0x14(%ebp)
  801997:	8b 00                	mov    (%eax),%eax
  801999:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80199c:	89 c1                	mov    %eax,%ecx
  80199e:	c1 f9 1f             	sar    $0x1f,%ecx
  8019a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019aa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019b3:	0f 89 90 00 00 00    	jns    801a49 <vprintfmt+0x376>
				putch('-', putdat);
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	53                   	push   %ebx
  8019bd:	6a 2d                	push   $0x2d
  8019bf:	ff d6                	call   *%esi
				num = -(long long) num;
  8019c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019c7:	f7 d8                	neg    %eax
  8019c9:	83 d2 00             	adc    $0x0,%edx
  8019cc:	f7 da                	neg    %edx
  8019ce:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019d6:	eb 71                	jmp    801a49 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8019db:	e8 7f fc ff ff       	call   80165f <getuint>
			base = 10;
  8019e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019e5:	eb 62                	jmp    801a49 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8019e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8019ea:	e8 70 fc ff ff       	call   80165f <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8019ef:	83 ec 0c             	sub    $0xc,%esp
  8019f2:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8019f6:	51                   	push   %ecx
  8019f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8019fa:	6a 08                	push   $0x8
  8019fc:	52                   	push   %edx
  8019fd:	50                   	push   %eax
  8019fe:	89 da                	mov    %ebx,%edx
  801a00:	89 f0                	mov    %esi,%eax
  801a02:	e8 a9 fb ff ff       	call   8015b0 <printnum>
			break;
  801a07:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  801a0d:	e9 e7 fc ff ff       	jmp    8016f9 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a12:	83 ec 08             	sub    $0x8,%esp
  801a15:	53                   	push   %ebx
  801a16:	6a 30                	push   $0x30
  801a18:	ff d6                	call   *%esi
			putch('x', putdat);
  801a1a:	83 c4 08             	add    $0x8,%esp
  801a1d:	53                   	push   %ebx
  801a1e:	6a 78                	push   $0x78
  801a20:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a22:	8b 45 14             	mov    0x14(%ebp),%eax
  801a25:	8d 50 04             	lea    0x4(%eax),%edx
  801a28:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a2b:	8b 00                	mov    (%eax),%eax
  801a2d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a32:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a35:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a3a:	eb 0d                	jmp    801a49 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a3c:	8d 45 14             	lea    0x14(%ebp),%eax
  801a3f:	e8 1b fc ff ff       	call   80165f <getuint>
			base = 16;
  801a44:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a49:	83 ec 0c             	sub    $0xc,%esp
  801a4c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a50:	57                   	push   %edi
  801a51:	ff 75 e0             	pushl  -0x20(%ebp)
  801a54:	51                   	push   %ecx
  801a55:	52                   	push   %edx
  801a56:	50                   	push   %eax
  801a57:	89 da                	mov    %ebx,%edx
  801a59:	89 f0                	mov    %esi,%eax
  801a5b:	e8 50 fb ff ff       	call   8015b0 <printnum>
			break;
  801a60:	83 c4 20             	add    $0x20,%esp
  801a63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a66:	e9 8e fc ff ff       	jmp    8016f9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a6b:	83 ec 08             	sub    $0x8,%esp
  801a6e:	53                   	push   %ebx
  801a6f:	51                   	push   %ecx
  801a70:	ff d6                	call   *%esi
			break;
  801a72:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a75:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a78:	e9 7c fc ff ff       	jmp    8016f9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a7d:	83 ec 08             	sub    $0x8,%esp
  801a80:	53                   	push   %ebx
  801a81:	6a 25                	push   $0x25
  801a83:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	eb 03                	jmp    801a8d <vprintfmt+0x3ba>
  801a8a:	83 ef 01             	sub    $0x1,%edi
  801a8d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a91:	75 f7                	jne    801a8a <vprintfmt+0x3b7>
  801a93:	e9 61 fc ff ff       	jmp    8016f9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9b:	5b                   	pop    %ebx
  801a9c:	5e                   	pop    %esi
  801a9d:	5f                   	pop    %edi
  801a9e:	5d                   	pop    %ebp
  801a9f:	c3                   	ret    

00801aa0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 18             	sub    $0x18,%esp
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801aaf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ab3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ab6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801abd:	85 c0                	test   %eax,%eax
  801abf:	74 26                	je     801ae7 <vsnprintf+0x47>
  801ac1:	85 d2                	test   %edx,%edx
  801ac3:	7e 22                	jle    801ae7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ac5:	ff 75 14             	pushl  0x14(%ebp)
  801ac8:	ff 75 10             	pushl  0x10(%ebp)
  801acb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ace:	50                   	push   %eax
  801acf:	68 99 16 80 00       	push   $0x801699
  801ad4:	e8 fa fb ff ff       	call   8016d3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ad9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801adc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	eb 05                	jmp    801aec <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ae7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    

00801aee <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801af4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801af7:	50                   	push   %eax
  801af8:	ff 75 10             	pushl  0x10(%ebp)
  801afb:	ff 75 0c             	pushl  0xc(%ebp)
  801afe:	ff 75 08             	pushl  0x8(%ebp)
  801b01:	e8 9a ff ff ff       	call   801aa0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b06:	c9                   	leave  
  801b07:	c3                   	ret    

00801b08 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b13:	eb 03                	jmp    801b18 <strlen+0x10>
		n++;
  801b15:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b18:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b1c:	75 f7                	jne    801b15 <strlen+0xd>
		n++;
	return n;
}
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b26:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b29:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2e:	eb 03                	jmp    801b33 <strnlen+0x13>
		n++;
  801b30:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b33:	39 c2                	cmp    %eax,%edx
  801b35:	74 08                	je     801b3f <strnlen+0x1f>
  801b37:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b3b:	75 f3                	jne    801b30 <strnlen+0x10>
  801b3d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	53                   	push   %ebx
  801b45:	8b 45 08             	mov    0x8(%ebp),%eax
  801b48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b4b:	89 c2                	mov    %eax,%edx
  801b4d:	83 c2 01             	add    $0x1,%edx
  801b50:	83 c1 01             	add    $0x1,%ecx
  801b53:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b57:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b5a:	84 db                	test   %bl,%bl
  801b5c:	75 ef                	jne    801b4d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b5e:	5b                   	pop    %ebx
  801b5f:	5d                   	pop    %ebp
  801b60:	c3                   	ret    

00801b61 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	53                   	push   %ebx
  801b65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b68:	53                   	push   %ebx
  801b69:	e8 9a ff ff ff       	call   801b08 <strlen>
  801b6e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b71:	ff 75 0c             	pushl  0xc(%ebp)
  801b74:	01 d8                	add    %ebx,%eax
  801b76:	50                   	push   %eax
  801b77:	e8 c5 ff ff ff       	call   801b41 <strcpy>
	return dst;
}
  801b7c:	89 d8                	mov    %ebx,%eax
  801b7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b81:	c9                   	leave  
  801b82:	c3                   	ret    

00801b83 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	56                   	push   %esi
  801b87:	53                   	push   %ebx
  801b88:	8b 75 08             	mov    0x8(%ebp),%esi
  801b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8e:	89 f3                	mov    %esi,%ebx
  801b90:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b93:	89 f2                	mov    %esi,%edx
  801b95:	eb 0f                	jmp    801ba6 <strncpy+0x23>
		*dst++ = *src;
  801b97:	83 c2 01             	add    $0x1,%edx
  801b9a:	0f b6 01             	movzbl (%ecx),%eax
  801b9d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba0:	80 39 01             	cmpb   $0x1,(%ecx)
  801ba3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba6:	39 da                	cmp    %ebx,%edx
  801ba8:	75 ed                	jne    801b97 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801baa:	89 f0                	mov    %esi,%eax
  801bac:	5b                   	pop    %ebx
  801bad:	5e                   	pop    %esi
  801bae:	5d                   	pop    %ebp
  801baf:	c3                   	ret    

00801bb0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	56                   	push   %esi
  801bb4:	53                   	push   %ebx
  801bb5:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbb:	8b 55 10             	mov    0x10(%ebp),%edx
  801bbe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc0:	85 d2                	test   %edx,%edx
  801bc2:	74 21                	je     801be5 <strlcpy+0x35>
  801bc4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bc8:	89 f2                	mov    %esi,%edx
  801bca:	eb 09                	jmp    801bd5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bcc:	83 c2 01             	add    $0x1,%edx
  801bcf:	83 c1 01             	add    $0x1,%ecx
  801bd2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bd5:	39 c2                	cmp    %eax,%edx
  801bd7:	74 09                	je     801be2 <strlcpy+0x32>
  801bd9:	0f b6 19             	movzbl (%ecx),%ebx
  801bdc:	84 db                	test   %bl,%bl
  801bde:	75 ec                	jne    801bcc <strlcpy+0x1c>
  801be0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801be2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801be5:	29 f0                	sub    %esi,%eax
}
  801be7:	5b                   	pop    %ebx
  801be8:	5e                   	pop    %esi
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    

00801beb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bf4:	eb 06                	jmp    801bfc <strcmp+0x11>
		p++, q++;
  801bf6:	83 c1 01             	add    $0x1,%ecx
  801bf9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bfc:	0f b6 01             	movzbl (%ecx),%eax
  801bff:	84 c0                	test   %al,%al
  801c01:	74 04                	je     801c07 <strcmp+0x1c>
  801c03:	3a 02                	cmp    (%edx),%al
  801c05:	74 ef                	je     801bf6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c07:	0f b6 c0             	movzbl %al,%eax
  801c0a:	0f b6 12             	movzbl (%edx),%edx
  801c0d:	29 d0                	sub    %edx,%eax
}
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	53                   	push   %ebx
  801c15:	8b 45 08             	mov    0x8(%ebp),%eax
  801c18:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c20:	eb 06                	jmp    801c28 <strncmp+0x17>
		n--, p++, q++;
  801c22:	83 c0 01             	add    $0x1,%eax
  801c25:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c28:	39 d8                	cmp    %ebx,%eax
  801c2a:	74 15                	je     801c41 <strncmp+0x30>
  801c2c:	0f b6 08             	movzbl (%eax),%ecx
  801c2f:	84 c9                	test   %cl,%cl
  801c31:	74 04                	je     801c37 <strncmp+0x26>
  801c33:	3a 0a                	cmp    (%edx),%cl
  801c35:	74 eb                	je     801c22 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c37:	0f b6 00             	movzbl (%eax),%eax
  801c3a:	0f b6 12             	movzbl (%edx),%edx
  801c3d:	29 d0                	sub    %edx,%eax
  801c3f:	eb 05                	jmp    801c46 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c41:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c46:	5b                   	pop    %ebx
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c53:	eb 07                	jmp    801c5c <strchr+0x13>
		if (*s == c)
  801c55:	38 ca                	cmp    %cl,%dl
  801c57:	74 0f                	je     801c68 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c59:	83 c0 01             	add    $0x1,%eax
  801c5c:	0f b6 10             	movzbl (%eax),%edx
  801c5f:	84 d2                	test   %dl,%dl
  801c61:	75 f2                	jne    801c55 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c74:	eb 03                	jmp    801c79 <strfind+0xf>
  801c76:	83 c0 01             	add    $0x1,%eax
  801c79:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c7c:	38 ca                	cmp    %cl,%dl
  801c7e:	74 04                	je     801c84 <strfind+0x1a>
  801c80:	84 d2                	test   %dl,%dl
  801c82:	75 f2                	jne    801c76 <strfind+0xc>
			break;
	return (char *) s;
}
  801c84:	5d                   	pop    %ebp
  801c85:	c3                   	ret    

00801c86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	57                   	push   %edi
  801c8a:	56                   	push   %esi
  801c8b:	53                   	push   %ebx
  801c8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c92:	85 c9                	test   %ecx,%ecx
  801c94:	74 36                	je     801ccc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c96:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c9c:	75 28                	jne    801cc6 <memset+0x40>
  801c9e:	f6 c1 03             	test   $0x3,%cl
  801ca1:	75 23                	jne    801cc6 <memset+0x40>
		c &= 0xFF;
  801ca3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ca7:	89 d3                	mov    %edx,%ebx
  801ca9:	c1 e3 08             	shl    $0x8,%ebx
  801cac:	89 d6                	mov    %edx,%esi
  801cae:	c1 e6 18             	shl    $0x18,%esi
  801cb1:	89 d0                	mov    %edx,%eax
  801cb3:	c1 e0 10             	shl    $0x10,%eax
  801cb6:	09 f0                	or     %esi,%eax
  801cb8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cba:	89 d8                	mov    %ebx,%eax
  801cbc:	09 d0                	or     %edx,%eax
  801cbe:	c1 e9 02             	shr    $0x2,%ecx
  801cc1:	fc                   	cld    
  801cc2:	f3 ab                	rep stos %eax,%es:(%edi)
  801cc4:	eb 06                	jmp    801ccc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc9:	fc                   	cld    
  801cca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ccc:	89 f8                	mov    %edi,%eax
  801cce:	5b                   	pop    %ebx
  801ccf:	5e                   	pop    %esi
  801cd0:	5f                   	pop    %edi
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    

00801cd3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	57                   	push   %edi
  801cd7:	56                   	push   %esi
  801cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce1:	39 c6                	cmp    %eax,%esi
  801ce3:	73 35                	jae    801d1a <memmove+0x47>
  801ce5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ce8:	39 d0                	cmp    %edx,%eax
  801cea:	73 2e                	jae    801d1a <memmove+0x47>
		s += n;
		d += n;
  801cec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cef:	89 d6                	mov    %edx,%esi
  801cf1:	09 fe                	or     %edi,%esi
  801cf3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cf9:	75 13                	jne    801d0e <memmove+0x3b>
  801cfb:	f6 c1 03             	test   $0x3,%cl
  801cfe:	75 0e                	jne    801d0e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d00:	83 ef 04             	sub    $0x4,%edi
  801d03:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d06:	c1 e9 02             	shr    $0x2,%ecx
  801d09:	fd                   	std    
  801d0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d0c:	eb 09                	jmp    801d17 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d0e:	83 ef 01             	sub    $0x1,%edi
  801d11:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d14:	fd                   	std    
  801d15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d17:	fc                   	cld    
  801d18:	eb 1d                	jmp    801d37 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1a:	89 f2                	mov    %esi,%edx
  801d1c:	09 c2                	or     %eax,%edx
  801d1e:	f6 c2 03             	test   $0x3,%dl
  801d21:	75 0f                	jne    801d32 <memmove+0x5f>
  801d23:	f6 c1 03             	test   $0x3,%cl
  801d26:	75 0a                	jne    801d32 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d28:	c1 e9 02             	shr    $0x2,%ecx
  801d2b:	89 c7                	mov    %eax,%edi
  801d2d:	fc                   	cld    
  801d2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d30:	eb 05                	jmp    801d37 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d32:	89 c7                	mov    %eax,%edi
  801d34:	fc                   	cld    
  801d35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d37:	5e                   	pop    %esi
  801d38:	5f                   	pop    %edi
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    

00801d3b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d3e:	ff 75 10             	pushl  0x10(%ebp)
  801d41:	ff 75 0c             	pushl  0xc(%ebp)
  801d44:	ff 75 08             	pushl  0x8(%ebp)
  801d47:	e8 87 ff ff ff       	call   801cd3 <memmove>
}
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	56                   	push   %esi
  801d52:	53                   	push   %ebx
  801d53:	8b 45 08             	mov    0x8(%ebp),%eax
  801d56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d59:	89 c6                	mov    %eax,%esi
  801d5b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d5e:	eb 1a                	jmp    801d7a <memcmp+0x2c>
		if (*s1 != *s2)
  801d60:	0f b6 08             	movzbl (%eax),%ecx
  801d63:	0f b6 1a             	movzbl (%edx),%ebx
  801d66:	38 d9                	cmp    %bl,%cl
  801d68:	74 0a                	je     801d74 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d6a:	0f b6 c1             	movzbl %cl,%eax
  801d6d:	0f b6 db             	movzbl %bl,%ebx
  801d70:	29 d8                	sub    %ebx,%eax
  801d72:	eb 0f                	jmp    801d83 <memcmp+0x35>
		s1++, s2++;
  801d74:	83 c0 01             	add    $0x1,%eax
  801d77:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d7a:	39 f0                	cmp    %esi,%eax
  801d7c:	75 e2                	jne    801d60 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d83:	5b                   	pop    %ebx
  801d84:	5e                   	pop    %esi
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    

00801d87 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	53                   	push   %ebx
  801d8b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d8e:	89 c1                	mov    %eax,%ecx
  801d90:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d93:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d97:	eb 0a                	jmp    801da3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d99:	0f b6 10             	movzbl (%eax),%edx
  801d9c:	39 da                	cmp    %ebx,%edx
  801d9e:	74 07                	je     801da7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da0:	83 c0 01             	add    $0x1,%eax
  801da3:	39 c8                	cmp    %ecx,%eax
  801da5:	72 f2                	jb     801d99 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801da7:	5b                   	pop    %ebx
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    

00801daa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	57                   	push   %edi
  801dae:	56                   	push   %esi
  801daf:	53                   	push   %ebx
  801db0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801db6:	eb 03                	jmp    801dbb <strtol+0x11>
		s++;
  801db8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dbb:	0f b6 01             	movzbl (%ecx),%eax
  801dbe:	3c 20                	cmp    $0x20,%al
  801dc0:	74 f6                	je     801db8 <strtol+0xe>
  801dc2:	3c 09                	cmp    $0x9,%al
  801dc4:	74 f2                	je     801db8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dc6:	3c 2b                	cmp    $0x2b,%al
  801dc8:	75 0a                	jne    801dd4 <strtol+0x2a>
		s++;
  801dca:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dcd:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd2:	eb 11                	jmp    801de5 <strtol+0x3b>
  801dd4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dd9:	3c 2d                	cmp    $0x2d,%al
  801ddb:	75 08                	jne    801de5 <strtol+0x3b>
		s++, neg = 1;
  801ddd:	83 c1 01             	add    $0x1,%ecx
  801de0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801de5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801deb:	75 15                	jne    801e02 <strtol+0x58>
  801ded:	80 39 30             	cmpb   $0x30,(%ecx)
  801df0:	75 10                	jne    801e02 <strtol+0x58>
  801df2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801df6:	75 7c                	jne    801e74 <strtol+0xca>
		s += 2, base = 16;
  801df8:	83 c1 02             	add    $0x2,%ecx
  801dfb:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e00:	eb 16                	jmp    801e18 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e02:	85 db                	test   %ebx,%ebx
  801e04:	75 12                	jne    801e18 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e06:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e0b:	80 39 30             	cmpb   $0x30,(%ecx)
  801e0e:	75 08                	jne    801e18 <strtol+0x6e>
		s++, base = 8;
  801e10:	83 c1 01             	add    $0x1,%ecx
  801e13:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e18:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e20:	0f b6 11             	movzbl (%ecx),%edx
  801e23:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e26:	89 f3                	mov    %esi,%ebx
  801e28:	80 fb 09             	cmp    $0x9,%bl
  801e2b:	77 08                	ja     801e35 <strtol+0x8b>
			dig = *s - '0';
  801e2d:	0f be d2             	movsbl %dl,%edx
  801e30:	83 ea 30             	sub    $0x30,%edx
  801e33:	eb 22                	jmp    801e57 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e35:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e38:	89 f3                	mov    %esi,%ebx
  801e3a:	80 fb 19             	cmp    $0x19,%bl
  801e3d:	77 08                	ja     801e47 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e3f:	0f be d2             	movsbl %dl,%edx
  801e42:	83 ea 57             	sub    $0x57,%edx
  801e45:	eb 10                	jmp    801e57 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e47:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e4a:	89 f3                	mov    %esi,%ebx
  801e4c:	80 fb 19             	cmp    $0x19,%bl
  801e4f:	77 16                	ja     801e67 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e51:	0f be d2             	movsbl %dl,%edx
  801e54:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e57:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e5a:	7d 0b                	jge    801e67 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e5c:	83 c1 01             	add    $0x1,%ecx
  801e5f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e63:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e65:	eb b9                	jmp    801e20 <strtol+0x76>

	if (endptr)
  801e67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e6b:	74 0d                	je     801e7a <strtol+0xd0>
		*endptr = (char *) s;
  801e6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e70:	89 0e                	mov    %ecx,(%esi)
  801e72:	eb 06                	jmp    801e7a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e74:	85 db                	test   %ebx,%ebx
  801e76:	74 98                	je     801e10 <strtol+0x66>
  801e78:	eb 9e                	jmp    801e18 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e7a:	89 c2                	mov    %eax,%edx
  801e7c:	f7 da                	neg    %edx
  801e7e:	85 ff                	test   %edi,%edi
  801e80:	0f 45 c2             	cmovne %edx,%eax
}
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5f                   	pop    %edi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    

00801e88 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	56                   	push   %esi
  801e8c:	53                   	push   %ebx
  801e8d:	8b 75 08             	mov    0x8(%ebp),%esi
  801e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801e96:	85 c0                	test   %eax,%eax
  801e98:	74 0e                	je     801ea8 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801e9a:	83 ec 0c             	sub    $0xc,%esp
  801e9d:	50                   	push   %eax
  801e9e:	e8 63 e4 ff ff       	call   800306 <sys_ipc_recv>
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	eb 10                	jmp    801eb8 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801ea8:	83 ec 0c             	sub    $0xc,%esp
  801eab:	68 00 00 c0 ee       	push   $0xeec00000
  801eb0:	e8 51 e4 ff ff       	call   800306 <sys_ipc_recv>
  801eb5:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	79 17                	jns    801ed3 <ipc_recv+0x4b>
		if(*from_env_store)
  801ebc:	83 3e 00             	cmpl   $0x0,(%esi)
  801ebf:	74 06                	je     801ec7 <ipc_recv+0x3f>
			*from_env_store = 0;
  801ec1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801ec7:	85 db                	test   %ebx,%ebx
  801ec9:	74 2c                	je     801ef7 <ipc_recv+0x6f>
			*perm_store = 0;
  801ecb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ed1:	eb 24                	jmp    801ef7 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801ed3:	85 f6                	test   %esi,%esi
  801ed5:	74 0a                	je     801ee1 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801ed7:	a1 08 40 80 00       	mov    0x804008,%eax
  801edc:	8b 40 74             	mov    0x74(%eax),%eax
  801edf:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801ee1:	85 db                	test   %ebx,%ebx
  801ee3:	74 0a                	je     801eef <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801ee5:	a1 08 40 80 00       	mov    0x804008,%eax
  801eea:	8b 40 78             	mov    0x78(%eax),%eax
  801eed:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801eef:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ef7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efa:	5b                   	pop    %ebx
  801efb:	5e                   	pop    %esi
  801efc:	5d                   	pop    %ebp
  801efd:	c3                   	ret    

00801efe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	83 ec 0c             	sub    $0xc,%esp
  801f07:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f10:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f12:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f17:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f1a:	e8 18 e2 ff ff       	call   800137 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f1f:	ff 75 14             	pushl  0x14(%ebp)
  801f22:	53                   	push   %ebx
  801f23:	56                   	push   %esi
  801f24:	57                   	push   %edi
  801f25:	e8 b9 e3 ff ff       	call   8002e3 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f2a:	89 c2                	mov    %eax,%edx
  801f2c:	f7 d2                	not    %edx
  801f2e:	c1 ea 1f             	shr    $0x1f,%edx
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f37:	0f 94 c1             	sete   %cl
  801f3a:	09 ca                	or     %ecx,%edx
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	0f 94 c0             	sete   %al
  801f41:	38 c2                	cmp    %al,%dl
  801f43:	77 d5                	ja     801f1a <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801f45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f48:	5b                   	pop    %ebx
  801f49:	5e                   	pop    %esi
  801f4a:	5f                   	pop    %edi
  801f4b:	5d                   	pop    %ebp
  801f4c:	c3                   	ret    

00801f4d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f53:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f58:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f5b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f61:	8b 52 50             	mov    0x50(%edx),%edx
  801f64:	39 ca                	cmp    %ecx,%edx
  801f66:	75 0d                	jne    801f75 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f68:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f6b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f70:	8b 40 48             	mov    0x48(%eax),%eax
  801f73:	eb 0f                	jmp    801f84 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f75:	83 c0 01             	add    $0x1,%eax
  801f78:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f7d:	75 d9                	jne    801f58 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    

00801f86 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8c:	89 d0                	mov    %edx,%eax
  801f8e:	c1 e8 16             	shr    $0x16,%eax
  801f91:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f98:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9d:	f6 c1 01             	test   $0x1,%cl
  801fa0:	74 1d                	je     801fbf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa2:	c1 ea 0c             	shr    $0xc,%edx
  801fa5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fac:	f6 c2 01             	test   $0x1,%dl
  801faf:	74 0e                	je     801fbf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb1:	c1 ea 0c             	shr    $0xc,%edx
  801fb4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fbb:	ef 
  801fbc:	0f b7 c0             	movzwl %ax,%eax
}
  801fbf:	5d                   	pop    %ebp
  801fc0:	c3                   	ret    
  801fc1:	66 90                	xchg   %ax,%ax
  801fc3:	66 90                	xchg   %ax,%ax
  801fc5:	66 90                	xchg   %ax,%ax
  801fc7:	66 90                	xchg   %ax,%ax
  801fc9:	66 90                	xchg   %ax,%ax
  801fcb:	66 90                	xchg   %ax,%ax
  801fcd:	66 90                	xchg   %ax,%ax
  801fcf:	90                   	nop

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
