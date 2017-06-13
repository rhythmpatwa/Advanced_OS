
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 a6 04 00 00       	call   800539 <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 6a 22 80 00       	push   $0x80226a
  80010c:	6a 23                	push   $0x23
  80010e:	68 87 22 80 00       	push   $0x802287
  800113:	e8 b3 13 00 00       	call   8014cb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 6a 22 80 00       	push   $0x80226a
  80018d:	6a 23                	push   $0x23
  80018f:	68 87 22 80 00       	push   $0x802287
  800194:	e8 32 13 00 00       	call   8014cb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 6a 22 80 00       	push   $0x80226a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 87 22 80 00       	push   $0x802287
  8001d6:	e8 f0 12 00 00       	call   8014cb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 6a 22 80 00       	push   $0x80226a
  800211:	6a 23                	push   $0x23
  800213:	68 87 22 80 00       	push   $0x802287
  800218:	e8 ae 12 00 00       	call   8014cb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 6a 22 80 00       	push   $0x80226a
  800253:	6a 23                	push   $0x23
  800255:	68 87 22 80 00       	push   $0x802287
  80025a:	e8 6c 12 00 00       	call   8014cb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 6a 22 80 00       	push   $0x80226a
  800295:	6a 23                	push   $0x23
  800297:	68 87 22 80 00       	push   $0x802287
  80029c:	e8 2a 12 00 00       	call   8014cb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 6a 22 80 00       	push   $0x80226a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 87 22 80 00       	push   $0x802287
  8002de:	e8 e8 11 00 00       	call   8014cb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 6a 22 80 00       	push   $0x80226a
  80033b:	6a 23                	push   $0x23
  80033d:	68 87 22 80 00       	push   $0x802287
  800342:	e8 84 11 00 00       	call   8014cb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035f:	89 d1                	mov    %edx,%ecx
  800361:	89 d3                	mov    %edx,%ebx
  800363:	89 d7                	mov    %edx,%edi
  800365:	89 d6                	mov    %edx,%esi
  800367:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	05 00 00 00 30       	add    $0x30000000,%eax
  800379:	c1 e8 0c             	shr    $0xc,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800381:	8b 45 08             	mov    0x8(%ebp),%eax
  800384:	05 00 00 00 30       	add    $0x30000000,%eax
  800389:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80038e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a0:	89 c2                	mov    %eax,%edx
  8003a2:	c1 ea 16             	shr    $0x16,%edx
  8003a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ac:	f6 c2 01             	test   $0x1,%dl
  8003af:	74 11                	je     8003c2 <fd_alloc+0x2d>
  8003b1:	89 c2                	mov    %eax,%edx
  8003b3:	c1 ea 0c             	shr    $0xc,%edx
  8003b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003bd:	f6 c2 01             	test   $0x1,%dl
  8003c0:	75 09                	jne    8003cb <fd_alloc+0x36>
			*fd_store = fd;
  8003c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c9:	eb 17                	jmp    8003e2 <fd_alloc+0x4d>
  8003cb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d5:	75 c9                	jne    8003a0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003d7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003dd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e2:	5d                   	pop    %ebp
  8003e3:	c3                   	ret    

008003e4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ea:	83 f8 1f             	cmp    $0x1f,%eax
  8003ed:	77 36                	ja     800425 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003ef:	c1 e0 0c             	shl    $0xc,%eax
  8003f2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003f7:	89 c2                	mov    %eax,%edx
  8003f9:	c1 ea 16             	shr    $0x16,%edx
  8003fc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800403:	f6 c2 01             	test   $0x1,%dl
  800406:	74 24                	je     80042c <fd_lookup+0x48>
  800408:	89 c2                	mov    %eax,%edx
  80040a:	c1 ea 0c             	shr    $0xc,%edx
  80040d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800414:	f6 c2 01             	test   $0x1,%dl
  800417:	74 1a                	je     800433 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800419:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041c:	89 02                	mov    %eax,(%edx)
	return 0;
  80041e:	b8 00 00 00 00       	mov    $0x0,%eax
  800423:	eb 13                	jmp    800438 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800425:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042a:	eb 0c                	jmp    800438 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800431:	eb 05                	jmp    800438 <fd_lookup+0x54>
  800433:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800438:	5d                   	pop    %ebp
  800439:	c3                   	ret    

0080043a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800443:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800448:	eb 13                	jmp    80045d <dev_lookup+0x23>
  80044a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80044d:	39 08                	cmp    %ecx,(%eax)
  80044f:	75 0c                	jne    80045d <dev_lookup+0x23>
			*dev = devtab[i];
  800451:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800454:	89 01                	mov    %eax,(%ecx)
			return 0;
  800456:	b8 00 00 00 00       	mov    $0x0,%eax
  80045b:	eb 2e                	jmp    80048b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80045d:	8b 02                	mov    (%edx),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	75 e7                	jne    80044a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800463:	a1 08 40 80 00       	mov    0x804008,%eax
  800468:	8b 40 48             	mov    0x48(%eax),%eax
  80046b:	83 ec 04             	sub    $0x4,%esp
  80046e:	51                   	push   %ecx
  80046f:	50                   	push   %eax
  800470:	68 98 22 80 00       	push   $0x802298
  800475:	e8 2a 11 00 00       	call   8015a4 <cprintf>
	*dev = 0;
  80047a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80047d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048b:	c9                   	leave  
  80048c:	c3                   	ret    

0080048d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	56                   	push   %esi
  800491:	53                   	push   %ebx
  800492:	83 ec 10             	sub    $0x10,%esp
  800495:	8b 75 08             	mov    0x8(%ebp),%esi
  800498:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80049e:	50                   	push   %eax
  80049f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a5:	c1 e8 0c             	shr    $0xc,%eax
  8004a8:	50                   	push   %eax
  8004a9:	e8 36 ff ff ff       	call   8003e4 <fd_lookup>
  8004ae:	83 c4 08             	add    $0x8,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 05                	js     8004ba <fd_close+0x2d>
	    || fd != fd2)
  8004b5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b8:	74 0c                	je     8004c6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004ba:	84 db                	test   %bl,%bl
  8004bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c1:	0f 44 c2             	cmove  %edx,%eax
  8004c4:	eb 41                	jmp    800507 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004cc:	50                   	push   %eax
  8004cd:	ff 36                	pushl  (%esi)
  8004cf:	e8 66 ff ff ff       	call   80043a <dev_lookup>
  8004d4:	89 c3                	mov    %eax,%ebx
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	78 1a                	js     8004f7 <fd_close+0x6a>
		if (dev->dev_close)
  8004dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	74 0b                	je     8004f7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004ec:	83 ec 0c             	sub    $0xc,%esp
  8004ef:	56                   	push   %esi
  8004f0:	ff d0                	call   *%eax
  8004f2:	89 c3                	mov    %eax,%ebx
  8004f4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	56                   	push   %esi
  8004fb:	6a 00                	push   $0x0
  8004fd:	e8 e1 fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	89 d8                	mov    %ebx,%eax
}
  800507:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050a:	5b                   	pop    %ebx
  80050b:	5e                   	pop    %esi
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    

0080050e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800517:	50                   	push   %eax
  800518:	ff 75 08             	pushl  0x8(%ebp)
  80051b:	e8 c4 fe ff ff       	call   8003e4 <fd_lookup>
  800520:	83 c4 08             	add    $0x8,%esp
  800523:	85 c0                	test   %eax,%eax
  800525:	78 10                	js     800537 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	6a 01                	push   $0x1
  80052c:	ff 75 f4             	pushl  -0xc(%ebp)
  80052f:	e8 59 ff ff ff       	call   80048d <fd_close>
  800534:	83 c4 10             	add    $0x10,%esp
}
  800537:	c9                   	leave  
  800538:	c3                   	ret    

00800539 <close_all>:

void
close_all(void)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	53                   	push   %ebx
  80053d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800540:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800545:	83 ec 0c             	sub    $0xc,%esp
  800548:	53                   	push   %ebx
  800549:	e8 c0 ff ff ff       	call   80050e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80054e:	83 c3 01             	add    $0x1,%ebx
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	83 fb 20             	cmp    $0x20,%ebx
  800557:	75 ec                	jne    800545 <close_all+0xc>
		close(i);
}
  800559:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    

0080055e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	57                   	push   %edi
  800562:	56                   	push   %esi
  800563:	53                   	push   %ebx
  800564:	83 ec 2c             	sub    $0x2c,%esp
  800567:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80056d:	50                   	push   %eax
  80056e:	ff 75 08             	pushl  0x8(%ebp)
  800571:	e8 6e fe ff ff       	call   8003e4 <fd_lookup>
  800576:	83 c4 08             	add    $0x8,%esp
  800579:	85 c0                	test   %eax,%eax
  80057b:	0f 88 c1 00 00 00    	js     800642 <dup+0xe4>
		return r;
	close(newfdnum);
  800581:	83 ec 0c             	sub    $0xc,%esp
  800584:	56                   	push   %esi
  800585:	e8 84 ff ff ff       	call   80050e <close>

	newfd = INDEX2FD(newfdnum);
  80058a:	89 f3                	mov    %esi,%ebx
  80058c:	c1 e3 0c             	shl    $0xc,%ebx
  80058f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800595:	83 c4 04             	add    $0x4,%esp
  800598:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059b:	e8 de fd ff ff       	call   80037e <fd2data>
  8005a0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a2:	89 1c 24             	mov    %ebx,(%esp)
  8005a5:	e8 d4 fd ff ff       	call   80037e <fd2data>
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b0:	89 f8                	mov    %edi,%eax
  8005b2:	c1 e8 16             	shr    $0x16,%eax
  8005b5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005bc:	a8 01                	test   $0x1,%al
  8005be:	74 37                	je     8005f7 <dup+0x99>
  8005c0:	89 f8                	mov    %edi,%eax
  8005c2:	c1 e8 0c             	shr    $0xc,%eax
  8005c5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005cc:	f6 c2 01             	test   $0x1,%dl
  8005cf:	74 26                	je     8005f7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e0:	50                   	push   %eax
  8005e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e4:	6a 00                	push   $0x0
  8005e6:	57                   	push   %edi
  8005e7:	6a 00                	push   $0x0
  8005e9:	e8 b3 fb ff ff       	call   8001a1 <sys_page_map>
  8005ee:	89 c7                	mov    %eax,%edi
  8005f0:	83 c4 20             	add    $0x20,%esp
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	78 2e                	js     800625 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fa:	89 d0                	mov    %edx,%eax
  8005fc:	c1 e8 0c             	shr    $0xc,%eax
  8005ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	25 07 0e 00 00       	and    $0xe07,%eax
  80060e:	50                   	push   %eax
  80060f:	53                   	push   %ebx
  800610:	6a 00                	push   $0x0
  800612:	52                   	push   %edx
  800613:	6a 00                	push   $0x0
  800615:	e8 87 fb ff ff       	call   8001a1 <sys_page_map>
  80061a:	89 c7                	mov    %eax,%edi
  80061c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80061f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800621:	85 ff                	test   %edi,%edi
  800623:	79 1d                	jns    800642 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 00                	push   $0x0
  80062b:	e8 b3 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800630:	83 c4 08             	add    $0x8,%esp
  800633:	ff 75 d4             	pushl  -0x2c(%ebp)
  800636:	6a 00                	push   $0x0
  800638:	e8 a6 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	89 f8                	mov    %edi,%eax
}
  800642:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800645:	5b                   	pop    %ebx
  800646:	5e                   	pop    %esi
  800647:	5f                   	pop    %edi
  800648:	5d                   	pop    %ebp
  800649:	c3                   	ret    

0080064a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	53                   	push   %ebx
  80064e:	83 ec 14             	sub    $0x14,%esp
  800651:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800654:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800657:	50                   	push   %eax
  800658:	53                   	push   %ebx
  800659:	e8 86 fd ff ff       	call   8003e4 <fd_lookup>
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	89 c2                	mov    %eax,%edx
  800663:	85 c0                	test   %eax,%eax
  800665:	78 6d                	js     8006d4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80066d:	50                   	push   %eax
  80066e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800671:	ff 30                	pushl  (%eax)
  800673:	e8 c2 fd ff ff       	call   80043a <dev_lookup>
  800678:	83 c4 10             	add    $0x10,%esp
  80067b:	85 c0                	test   %eax,%eax
  80067d:	78 4c                	js     8006cb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80067f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800682:	8b 42 08             	mov    0x8(%edx),%eax
  800685:	83 e0 03             	and    $0x3,%eax
  800688:	83 f8 01             	cmp    $0x1,%eax
  80068b:	75 21                	jne    8006ae <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068d:	a1 08 40 80 00       	mov    0x804008,%eax
  800692:	8b 40 48             	mov    0x48(%eax),%eax
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	53                   	push   %ebx
  800699:	50                   	push   %eax
  80069a:	68 d9 22 80 00       	push   $0x8022d9
  80069f:	e8 00 0f 00 00       	call   8015a4 <cprintf>
		return -E_INVAL;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006ac:	eb 26                	jmp    8006d4 <read+0x8a>
	}
	if (!dev->dev_read)
  8006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b1:	8b 40 08             	mov    0x8(%eax),%eax
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	74 17                	je     8006cf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	ff 75 10             	pushl  0x10(%ebp)
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	52                   	push   %edx
  8006c2:	ff d0                	call   *%eax
  8006c4:	89 c2                	mov    %eax,%edx
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	eb 09                	jmp    8006d4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cb:	89 c2                	mov    %eax,%edx
  8006cd:	eb 05                	jmp    8006d4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d4:	89 d0                	mov    %edx,%eax
  8006d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d9:	c9                   	leave  
  8006da:	c3                   	ret    

008006db <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	57                   	push   %edi
  8006df:	56                   	push   %esi
  8006e0:	53                   	push   %ebx
  8006e1:	83 ec 0c             	sub    $0xc,%esp
  8006e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ef:	eb 21                	jmp    800712 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f1:	83 ec 04             	sub    $0x4,%esp
  8006f4:	89 f0                	mov    %esi,%eax
  8006f6:	29 d8                	sub    %ebx,%eax
  8006f8:	50                   	push   %eax
  8006f9:	89 d8                	mov    %ebx,%eax
  8006fb:	03 45 0c             	add    0xc(%ebp),%eax
  8006fe:	50                   	push   %eax
  8006ff:	57                   	push   %edi
  800700:	e8 45 ff ff ff       	call   80064a <read>
		if (m < 0)
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	85 c0                	test   %eax,%eax
  80070a:	78 10                	js     80071c <readn+0x41>
			return m;
		if (m == 0)
  80070c:	85 c0                	test   %eax,%eax
  80070e:	74 0a                	je     80071a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800710:	01 c3                	add    %eax,%ebx
  800712:	39 f3                	cmp    %esi,%ebx
  800714:	72 db                	jb     8006f1 <readn+0x16>
  800716:	89 d8                	mov    %ebx,%eax
  800718:	eb 02                	jmp    80071c <readn+0x41>
  80071a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80071c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071f:	5b                   	pop    %ebx
  800720:	5e                   	pop    %esi
  800721:	5f                   	pop    %edi
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	53                   	push   %ebx
  800728:	83 ec 14             	sub    $0x14,%esp
  80072b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	53                   	push   %ebx
  800733:	e8 ac fc ff ff       	call   8003e4 <fd_lookup>
  800738:	83 c4 08             	add    $0x8,%esp
  80073b:	89 c2                	mov    %eax,%edx
  80073d:	85 c0                	test   %eax,%eax
  80073f:	78 68                	js     8007a9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800747:	50                   	push   %eax
  800748:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074b:	ff 30                	pushl  (%eax)
  80074d:	e8 e8 fc ff ff       	call   80043a <dev_lookup>
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	85 c0                	test   %eax,%eax
  800757:	78 47                	js     8007a0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800759:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800760:	75 21                	jne    800783 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800762:	a1 08 40 80 00       	mov    0x804008,%eax
  800767:	8b 40 48             	mov    0x48(%eax),%eax
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	53                   	push   %ebx
  80076e:	50                   	push   %eax
  80076f:	68 f5 22 80 00       	push   $0x8022f5
  800774:	e8 2b 0e 00 00       	call   8015a4 <cprintf>
		return -E_INVAL;
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800781:	eb 26                	jmp    8007a9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800783:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800786:	8b 52 0c             	mov    0xc(%edx),%edx
  800789:	85 d2                	test   %edx,%edx
  80078b:	74 17                	je     8007a4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80078d:	83 ec 04             	sub    $0x4,%esp
  800790:	ff 75 10             	pushl  0x10(%ebp)
  800793:	ff 75 0c             	pushl  0xc(%ebp)
  800796:	50                   	push   %eax
  800797:	ff d2                	call   *%edx
  800799:	89 c2                	mov    %eax,%edx
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	eb 09                	jmp    8007a9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a0:	89 c2                	mov    %eax,%edx
  8007a2:	eb 05                	jmp    8007a9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a9:	89 d0                	mov    %edx,%eax
  8007ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007b6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b9:	50                   	push   %eax
  8007ba:	ff 75 08             	pushl  0x8(%ebp)
  8007bd:	e8 22 fc ff ff       	call   8003e4 <fd_lookup>
  8007c2:	83 c4 08             	add    $0x8,%esp
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	78 0e                	js     8007d7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cf:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	83 ec 14             	sub    $0x14,%esp
  8007e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e6:	50                   	push   %eax
  8007e7:	53                   	push   %ebx
  8007e8:	e8 f7 fb ff ff       	call   8003e4 <fd_lookup>
  8007ed:	83 c4 08             	add    $0x8,%esp
  8007f0:	89 c2                	mov    %eax,%edx
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	78 65                	js     80085b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007fc:	50                   	push   %eax
  8007fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800800:	ff 30                	pushl  (%eax)
  800802:	e8 33 fc ff ff       	call   80043a <dev_lookup>
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 44                	js     800852 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80080e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800811:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800815:	75 21                	jne    800838 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800817:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80081c:	8b 40 48             	mov    0x48(%eax),%eax
  80081f:	83 ec 04             	sub    $0x4,%esp
  800822:	53                   	push   %ebx
  800823:	50                   	push   %eax
  800824:	68 b8 22 80 00       	push   $0x8022b8
  800829:	e8 76 0d 00 00       	call   8015a4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800836:	eb 23                	jmp    80085b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800838:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083b:	8b 52 18             	mov    0x18(%edx),%edx
  80083e:	85 d2                	test   %edx,%edx
  800840:	74 14                	je     800856 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	ff 75 0c             	pushl  0xc(%ebp)
  800848:	50                   	push   %eax
  800849:	ff d2                	call   *%edx
  80084b:	89 c2                	mov    %eax,%edx
  80084d:	83 c4 10             	add    $0x10,%esp
  800850:	eb 09                	jmp    80085b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800852:	89 c2                	mov    %eax,%edx
  800854:	eb 05                	jmp    80085b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800856:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085b:	89 d0                	mov    %edx,%eax
  80085d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	83 ec 14             	sub    $0x14,%esp
  800869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80086c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086f:	50                   	push   %eax
  800870:	ff 75 08             	pushl  0x8(%ebp)
  800873:	e8 6c fb ff ff       	call   8003e4 <fd_lookup>
  800878:	83 c4 08             	add    $0x8,%esp
  80087b:	89 c2                	mov    %eax,%edx
  80087d:	85 c0                	test   %eax,%eax
  80087f:	78 58                	js     8008d9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800887:	50                   	push   %eax
  800888:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088b:	ff 30                	pushl  (%eax)
  80088d:	e8 a8 fb ff ff       	call   80043a <dev_lookup>
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	85 c0                	test   %eax,%eax
  800897:	78 37                	js     8008d0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a0:	74 32                	je     8008d4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ac:	00 00 00 
	stat->st_isdir = 0;
  8008af:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008b6:	00 00 00 
	stat->st_dev = dev;
  8008b9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	53                   	push   %ebx
  8008c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8008c6:	ff 50 14             	call   *0x14(%eax)
  8008c9:	89 c2                	mov    %eax,%edx
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	eb 09                	jmp    8008d9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d0:	89 c2                	mov    %eax,%edx
  8008d2:	eb 05                	jmp    8008d9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d9:	89 d0                	mov    %edx,%eax
  8008db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	6a 00                	push   $0x0
  8008ea:	ff 75 08             	pushl  0x8(%ebp)
  8008ed:	e8 ef 01 00 00       	call   800ae1 <open>
  8008f2:	89 c3                	mov    %eax,%ebx
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	85 c0                	test   %eax,%eax
  8008f9:	78 1b                	js     800916 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	ff 75 0c             	pushl  0xc(%ebp)
  800901:	50                   	push   %eax
  800902:	e8 5b ff ff ff       	call   800862 <fstat>
  800907:	89 c6                	mov    %eax,%esi
	close(fd);
  800909:	89 1c 24             	mov    %ebx,(%esp)
  80090c:	e8 fd fb ff ff       	call   80050e <close>
	return r;
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	89 f0                	mov    %esi,%eax
}
  800916:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	89 c6                	mov    %eax,%esi
  800924:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800926:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80092d:	75 12                	jne    800941 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80092f:	83 ec 0c             	sub    $0xc,%esp
  800932:	6a 01                	push   $0x1
  800934:	e8 1c 16 00 00       	call   801f55 <ipc_find_env>
  800939:	a3 00 40 80 00       	mov    %eax,0x804000
  80093e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800941:	6a 07                	push   $0x7
  800943:	68 00 50 80 00       	push   $0x805000
  800948:	56                   	push   %esi
  800949:	ff 35 00 40 80 00    	pushl  0x804000
  80094f:	e8 b2 15 00 00       	call   801f06 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800954:	83 c4 0c             	add    $0xc,%esp
  800957:	6a 00                	push   $0x0
  800959:	53                   	push   %ebx
  80095a:	6a 00                	push   $0x0
  80095c:	e8 2f 15 00 00       	call   801e90 <ipc_recv>
}
  800961:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 40 0c             	mov    0xc(%eax),%eax
  800974:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800979:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800981:	ba 00 00 00 00       	mov    $0x0,%edx
  800986:	b8 02 00 00 00       	mov    $0x2,%eax
  80098b:	e8 8d ff ff ff       	call   80091d <fsipc>
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8b 40 0c             	mov    0xc(%eax),%eax
  80099e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a8:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ad:	e8 6b ff ff ff       	call   80091d <fsipc>
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	53                   	push   %ebx
  8009b8:	83 ec 04             	sub    $0x4,%esp
  8009bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d3:	e8 45 ff ff ff       	call   80091d <fsipc>
  8009d8:	85 c0                	test   %eax,%eax
  8009da:	78 2c                	js     800a08 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009dc:	83 ec 08             	sub    $0x8,%esp
  8009df:	68 00 50 80 00       	push   $0x805000
  8009e4:	53                   	push   %ebx
  8009e5:	e8 5f 11 00 00       	call   801b49 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ea:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f5:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	53                   	push   %ebx
  800a11:	83 ec 08             	sub    $0x8,%esp
  800a14:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a17:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1a:	8b 52 0c             	mov    0xc(%edx),%edx
  800a1d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a23:	a3 04 50 80 00       	mov    %eax,0x805004
  800a28:	3d 08 50 80 00       	cmp    $0x805008,%eax
  800a2d:	bb 08 50 80 00       	mov    $0x805008,%ebx
  800a32:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a35:	53                   	push   %ebx
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	68 08 50 80 00       	push   $0x805008
  800a3e:	e8 98 12 00 00       	call   801cdb <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a43:	ba 00 00 00 00       	mov    $0x0,%edx
  800a48:	b8 04 00 00 00       	mov    $0x4,%eax
  800a4d:	e8 cb fe ff ff       	call   80091d <fsipc>
  800a52:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  800a55:	85 c0                	test   %eax,%eax
  800a57:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  800a5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a72:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a78:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a82:	e8 96 fe ff ff       	call   80091d <fsipc>
  800a87:	89 c3                	mov    %eax,%ebx
  800a89:	85 c0                	test   %eax,%eax
  800a8b:	78 4b                	js     800ad8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a8d:	39 c6                	cmp    %eax,%esi
  800a8f:	73 16                	jae    800aa7 <devfile_read+0x48>
  800a91:	68 28 23 80 00       	push   $0x802328
  800a96:	68 2f 23 80 00       	push   $0x80232f
  800a9b:	6a 7c                	push   $0x7c
  800a9d:	68 44 23 80 00       	push   $0x802344
  800aa2:	e8 24 0a 00 00       	call   8014cb <_panic>
	assert(r <= PGSIZE);
  800aa7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aac:	7e 16                	jle    800ac4 <devfile_read+0x65>
  800aae:	68 4f 23 80 00       	push   $0x80234f
  800ab3:	68 2f 23 80 00       	push   $0x80232f
  800ab8:	6a 7d                	push   $0x7d
  800aba:	68 44 23 80 00       	push   $0x802344
  800abf:	e8 07 0a 00 00       	call   8014cb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ac4:	83 ec 04             	sub    $0x4,%esp
  800ac7:	50                   	push   %eax
  800ac8:	68 00 50 80 00       	push   $0x805000
  800acd:	ff 75 0c             	pushl  0xc(%ebp)
  800ad0:	e8 06 12 00 00       	call   801cdb <memmove>
	return r;
  800ad5:	83 c4 10             	add    $0x10,%esp
}
  800ad8:	89 d8                	mov    %ebx,%eax
  800ada:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	53                   	push   %ebx
  800ae5:	83 ec 20             	sub    $0x20,%esp
  800ae8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aeb:	53                   	push   %ebx
  800aec:	e8 1f 10 00 00       	call   801b10 <strlen>
  800af1:	83 c4 10             	add    $0x10,%esp
  800af4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af9:	7f 67                	jg     800b62 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800afb:	83 ec 0c             	sub    $0xc,%esp
  800afe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b01:	50                   	push   %eax
  800b02:	e8 8e f8 ff ff       	call   800395 <fd_alloc>
  800b07:	83 c4 10             	add    $0x10,%esp
		return r;
  800b0a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0c:	85 c0                	test   %eax,%eax
  800b0e:	78 57                	js     800b67 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b10:	83 ec 08             	sub    $0x8,%esp
  800b13:	53                   	push   %ebx
  800b14:	68 00 50 80 00       	push   $0x805000
  800b19:	e8 2b 10 00 00       	call   801b49 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b21:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b29:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2e:	e8 ea fd ff ff       	call   80091d <fsipc>
  800b33:	89 c3                	mov    %eax,%ebx
  800b35:	83 c4 10             	add    $0x10,%esp
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	79 14                	jns    800b50 <open+0x6f>
		fd_close(fd, 0);
  800b3c:	83 ec 08             	sub    $0x8,%esp
  800b3f:	6a 00                	push   $0x0
  800b41:	ff 75 f4             	pushl  -0xc(%ebp)
  800b44:	e8 44 f9 ff ff       	call   80048d <fd_close>
		return r;
  800b49:	83 c4 10             	add    $0x10,%esp
  800b4c:	89 da                	mov    %ebx,%edx
  800b4e:	eb 17                	jmp    800b67 <open+0x86>
	}

	return fd2num(fd);
  800b50:	83 ec 0c             	sub    $0xc,%esp
  800b53:	ff 75 f4             	pushl  -0xc(%ebp)
  800b56:	e8 13 f8 ff ff       	call   80036e <fd2num>
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	83 c4 10             	add    $0x10,%esp
  800b60:	eb 05                	jmp    800b67 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b62:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b67:	89 d0                	mov    %edx,%eax
  800b69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 08 00 00 00       	mov    $0x8,%eax
  800b7e:	e8 9a fd ff ff       	call   80091d <fsipc>
}
  800b83:	c9                   	leave  
  800b84:	c3                   	ret    

00800b85 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b8d:	83 ec 0c             	sub    $0xc,%esp
  800b90:	ff 75 08             	pushl  0x8(%ebp)
  800b93:	e8 e6 f7 ff ff       	call   80037e <fd2data>
  800b98:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b9a:	83 c4 08             	add    $0x8,%esp
  800b9d:	68 5b 23 80 00       	push   $0x80235b
  800ba2:	53                   	push   %ebx
  800ba3:	e8 a1 0f 00 00       	call   801b49 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba8:	8b 46 04             	mov    0x4(%esi),%eax
  800bab:	2b 06                	sub    (%esi),%eax
  800bad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bba:	00 00 00 
	stat->st_dev = &devpipe;
  800bbd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc4:	30 80 00 
	return 0;
}
  800bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bdd:	53                   	push   %ebx
  800bde:	6a 00                	push   $0x0
  800be0:	e8 fe f5 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be5:	89 1c 24             	mov    %ebx,(%esp)
  800be8:	e8 91 f7 ff ff       	call   80037e <fd2data>
  800bed:	83 c4 08             	add    $0x8,%esp
  800bf0:	50                   	push   %eax
  800bf1:	6a 00                	push   $0x0
  800bf3:	e8 eb f5 ff ff       	call   8001e3 <sys_page_unmap>
}
  800bf8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 1c             	sub    $0x1c,%esp
  800c06:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c09:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c0b:	a1 08 40 80 00       	mov    0x804008,%eax
  800c10:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	ff 75 e0             	pushl  -0x20(%ebp)
  800c19:	e8 70 13 00 00       	call   801f8e <pageref>
  800c1e:	89 c3                	mov    %eax,%ebx
  800c20:	89 3c 24             	mov    %edi,(%esp)
  800c23:	e8 66 13 00 00       	call   801f8e <pageref>
  800c28:	83 c4 10             	add    $0x10,%esp
  800c2b:	39 c3                	cmp    %eax,%ebx
  800c2d:	0f 94 c1             	sete   %cl
  800c30:	0f b6 c9             	movzbl %cl,%ecx
  800c33:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c36:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c3c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c3f:	39 ce                	cmp    %ecx,%esi
  800c41:	74 1b                	je     800c5e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c43:	39 c3                	cmp    %eax,%ebx
  800c45:	75 c4                	jne    800c0b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c47:	8b 42 58             	mov    0x58(%edx),%eax
  800c4a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c4d:	50                   	push   %eax
  800c4e:	56                   	push   %esi
  800c4f:	68 62 23 80 00       	push   $0x802362
  800c54:	e8 4b 09 00 00       	call   8015a4 <cprintf>
  800c59:	83 c4 10             	add    $0x10,%esp
  800c5c:	eb ad                	jmp    800c0b <_pipeisclosed+0xe>
	}
}
  800c5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 28             	sub    $0x28,%esp
  800c72:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c75:	56                   	push   %esi
  800c76:	e8 03 f7 ff ff       	call   80037e <fd2data>
  800c7b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c7d:	83 c4 10             	add    $0x10,%esp
  800c80:	bf 00 00 00 00       	mov    $0x0,%edi
  800c85:	eb 4b                	jmp    800cd2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c87:	89 da                	mov    %ebx,%edx
  800c89:	89 f0                	mov    %esi,%eax
  800c8b:	e8 6d ff ff ff       	call   800bfd <_pipeisclosed>
  800c90:	85 c0                	test   %eax,%eax
  800c92:	75 48                	jne    800cdc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c94:	e8 a6 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c99:	8b 43 04             	mov    0x4(%ebx),%eax
  800c9c:	8b 0b                	mov    (%ebx),%ecx
  800c9e:	8d 51 20             	lea    0x20(%ecx),%edx
  800ca1:	39 d0                	cmp    %edx,%eax
  800ca3:	73 e2                	jae    800c87 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cac:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800caf:	89 c2                	mov    %eax,%edx
  800cb1:	c1 fa 1f             	sar    $0x1f,%edx
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cbc:	83 e2 1f             	and    $0x1f,%edx
  800cbf:	29 ca                	sub    %ecx,%edx
  800cc1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cc5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc9:	83 c0 01             	add    $0x1,%eax
  800ccc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ccf:	83 c7 01             	add    $0x1,%edi
  800cd2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cd5:	75 c2                	jne    800c99 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cda:	eb 05                	jmp    800ce1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cdc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 18             	sub    $0x18,%esp
  800cf2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cf5:	57                   	push   %edi
  800cf6:	e8 83 f6 ff ff       	call   80037e <fd2data>
  800cfb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cfd:	83 c4 10             	add    $0x10,%esp
  800d00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d05:	eb 3d                	jmp    800d44 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d07:	85 db                	test   %ebx,%ebx
  800d09:	74 04                	je     800d0f <devpipe_read+0x26>
				return i;
  800d0b:	89 d8                	mov    %ebx,%eax
  800d0d:	eb 44                	jmp    800d53 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d0f:	89 f2                	mov    %esi,%edx
  800d11:	89 f8                	mov    %edi,%eax
  800d13:	e8 e5 fe ff ff       	call   800bfd <_pipeisclosed>
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	75 32                	jne    800d4e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d1c:	e8 1e f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d21:	8b 06                	mov    (%esi),%eax
  800d23:	3b 46 04             	cmp    0x4(%esi),%eax
  800d26:	74 df                	je     800d07 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d28:	99                   	cltd   
  800d29:	c1 ea 1b             	shr    $0x1b,%edx
  800d2c:	01 d0                	add    %edx,%eax
  800d2e:	83 e0 1f             	and    $0x1f,%eax
  800d31:	29 d0                	sub    %edx,%eax
  800d33:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d3e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d41:	83 c3 01             	add    $0x1,%ebx
  800d44:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d47:	75 d8                	jne    800d21 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d49:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4c:	eb 05                	jmp    800d53 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d4e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d66:	50                   	push   %eax
  800d67:	e8 29 f6 ff ff       	call   800395 <fd_alloc>
  800d6c:	83 c4 10             	add    $0x10,%esp
  800d6f:	89 c2                	mov    %eax,%edx
  800d71:	85 c0                	test   %eax,%eax
  800d73:	0f 88 2c 01 00 00    	js     800ea5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d79:	83 ec 04             	sub    $0x4,%esp
  800d7c:	68 07 04 00 00       	push   $0x407
  800d81:	ff 75 f4             	pushl  -0xc(%ebp)
  800d84:	6a 00                	push   $0x0
  800d86:	e8 d3 f3 ff ff       	call   80015e <sys_page_alloc>
  800d8b:	83 c4 10             	add    $0x10,%esp
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	85 c0                	test   %eax,%eax
  800d92:	0f 88 0d 01 00 00    	js     800ea5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d9e:	50                   	push   %eax
  800d9f:	e8 f1 f5 ff ff       	call   800395 <fd_alloc>
  800da4:	89 c3                	mov    %eax,%ebx
  800da6:	83 c4 10             	add    $0x10,%esp
  800da9:	85 c0                	test   %eax,%eax
  800dab:	0f 88 e2 00 00 00    	js     800e93 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db1:	83 ec 04             	sub    $0x4,%esp
  800db4:	68 07 04 00 00       	push   $0x407
  800db9:	ff 75 f0             	pushl  -0x10(%ebp)
  800dbc:	6a 00                	push   $0x0
  800dbe:	e8 9b f3 ff ff       	call   80015e <sys_page_alloc>
  800dc3:	89 c3                	mov    %eax,%ebx
  800dc5:	83 c4 10             	add    $0x10,%esp
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	0f 88 c3 00 00 00    	js     800e93 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dd0:	83 ec 0c             	sub    $0xc,%esp
  800dd3:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd6:	e8 a3 f5 ff ff       	call   80037e <fd2data>
  800ddb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddd:	83 c4 0c             	add    $0xc,%esp
  800de0:	68 07 04 00 00       	push   $0x407
  800de5:	50                   	push   %eax
  800de6:	6a 00                	push   $0x0
  800de8:	e8 71 f3 ff ff       	call   80015e <sys_page_alloc>
  800ded:	89 c3                	mov    %eax,%ebx
  800def:	83 c4 10             	add    $0x10,%esp
  800df2:	85 c0                	test   %eax,%eax
  800df4:	0f 88 89 00 00 00    	js     800e83 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dfa:	83 ec 0c             	sub    $0xc,%esp
  800dfd:	ff 75 f0             	pushl  -0x10(%ebp)
  800e00:	e8 79 f5 ff ff       	call   80037e <fd2data>
  800e05:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e0c:	50                   	push   %eax
  800e0d:	6a 00                	push   $0x0
  800e0f:	56                   	push   %esi
  800e10:	6a 00                	push   $0x0
  800e12:	e8 8a f3 ff ff       	call   8001a1 <sys_page_map>
  800e17:	89 c3                	mov    %eax,%ebx
  800e19:	83 c4 20             	add    $0x20,%esp
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	78 55                	js     800e75 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e20:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e29:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e35:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e43:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e4a:	83 ec 0c             	sub    $0xc,%esp
  800e4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e50:	e8 19 f5 ff ff       	call   80036e <fd2num>
  800e55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e58:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e5a:	83 c4 04             	add    $0x4,%esp
  800e5d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e60:	e8 09 f5 ff ff       	call   80036e <fd2num>
  800e65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e68:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e6b:	83 c4 10             	add    $0x10,%esp
  800e6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e73:	eb 30                	jmp    800ea5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e75:	83 ec 08             	sub    $0x8,%esp
  800e78:	56                   	push   %esi
  800e79:	6a 00                	push   $0x0
  800e7b:	e8 63 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e80:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e83:	83 ec 08             	sub    $0x8,%esp
  800e86:	ff 75 f0             	pushl  -0x10(%ebp)
  800e89:	6a 00                	push   $0x0
  800e8b:	e8 53 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e90:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e93:	83 ec 08             	sub    $0x8,%esp
  800e96:	ff 75 f4             	pushl  -0xc(%ebp)
  800e99:	6a 00                	push   $0x0
  800e9b:	e8 43 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ea5:	89 d0                	mov    %edx,%eax
  800ea7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb7:	50                   	push   %eax
  800eb8:	ff 75 08             	pushl  0x8(%ebp)
  800ebb:	e8 24 f5 ff ff       	call   8003e4 <fd_lookup>
  800ec0:	83 c4 10             	add    $0x10,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	78 18                	js     800edf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	ff 75 f4             	pushl  -0xc(%ebp)
  800ecd:	e8 ac f4 ff ff       	call   80037e <fd2data>
	return _pipeisclosed(fd, p);
  800ed2:	89 c2                	mov    %eax,%edx
  800ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed7:	e8 21 fd ff ff       	call   800bfd <_pipeisclosed>
  800edc:	83 c4 10             	add    $0x10,%esp
}
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ee7:	68 7a 23 80 00       	push   $0x80237a
  800eec:	ff 75 0c             	pushl  0xc(%ebp)
  800eef:	e8 55 0c 00 00       	call   801b49 <strcpy>
	return 0;
}
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	53                   	push   %ebx
  800eff:	83 ec 10             	sub    $0x10,%esp
  800f02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800f05:	53                   	push   %ebx
  800f06:	e8 83 10 00 00       	call   801f8e <pageref>
  800f0b:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800f0e:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800f13:	83 f8 01             	cmp    $0x1,%eax
  800f16:	75 10                	jne    800f28 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800f18:	83 ec 0c             	sub    $0xc,%esp
  800f1b:	ff 73 0c             	pushl  0xc(%ebx)
  800f1e:	e8 c0 02 00 00       	call   8011e3 <nsipc_close>
  800f23:	89 c2                	mov    %eax,%edx
  800f25:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f28:	89 d0                	mov    %edx,%eax
  800f2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f35:	6a 00                	push   $0x0
  800f37:	ff 75 10             	pushl  0x10(%ebp)
  800f3a:	ff 75 0c             	pushl  0xc(%ebp)
  800f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f40:	ff 70 0c             	pushl  0xc(%eax)
  800f43:	e8 78 03 00 00       	call   8012c0 <nsipc_send>
}
  800f48:	c9                   	leave  
  800f49:	c3                   	ret    

00800f4a <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f50:	6a 00                	push   $0x0
  800f52:	ff 75 10             	pushl  0x10(%ebp)
  800f55:	ff 75 0c             	pushl  0xc(%ebp)
  800f58:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5b:	ff 70 0c             	pushl  0xc(%eax)
  800f5e:	e8 f1 02 00 00       	call   801254 <nsipc_recv>
}
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f6b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f6e:	52                   	push   %edx
  800f6f:	50                   	push   %eax
  800f70:	e8 6f f4 ff ff       	call   8003e4 <fd_lookup>
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 17                	js     800f93 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f7f:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  800f85:	39 08                	cmp    %ecx,(%eax)
  800f87:	75 05                	jne    800f8e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f89:	8b 40 0c             	mov    0xc(%eax),%eax
  800f8c:	eb 05                	jmp    800f93 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800f8e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 1c             	sub    $0x1c,%esp
  800f9d:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800f9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa2:	50                   	push   %eax
  800fa3:	e8 ed f3 ff ff       	call   800395 <fd_alloc>
  800fa8:	89 c3                	mov    %eax,%ebx
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	85 c0                	test   %eax,%eax
  800faf:	78 1b                	js     800fcc <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800fb1:	83 ec 04             	sub    $0x4,%esp
  800fb4:	68 07 04 00 00       	push   $0x407
  800fb9:	ff 75 f4             	pushl  -0xc(%ebp)
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 9b f1 ff ff       	call   80015e <sys_page_alloc>
  800fc3:	89 c3                	mov    %eax,%ebx
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	79 10                	jns    800fdc <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800fcc:	83 ec 0c             	sub    $0xc,%esp
  800fcf:	56                   	push   %esi
  800fd0:	e8 0e 02 00 00       	call   8011e3 <nsipc_close>
		return r;
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	89 d8                	mov    %ebx,%eax
  800fda:	eb 24                	jmp    801000 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800fdc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ff1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	50                   	push   %eax
  800ff8:	e8 71 f3 ff ff       	call   80036e <fd2num>
  800ffd:	83 c4 10             	add    $0x10,%esp
}
  801000:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801003:	5b                   	pop    %ebx
  801004:	5e                   	pop    %esi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80100d:	8b 45 08             	mov    0x8(%ebp),%eax
  801010:	e8 50 ff ff ff       	call   800f65 <fd2sockid>
		return r;
  801015:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801017:	85 c0                	test   %eax,%eax
  801019:	78 1f                	js     80103a <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80101b:	83 ec 04             	sub    $0x4,%esp
  80101e:	ff 75 10             	pushl  0x10(%ebp)
  801021:	ff 75 0c             	pushl  0xc(%ebp)
  801024:	50                   	push   %eax
  801025:	e8 12 01 00 00       	call   80113c <nsipc_accept>
  80102a:	83 c4 10             	add    $0x10,%esp
		return r;
  80102d:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 07                	js     80103a <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801033:	e8 5d ff ff ff       	call   800f95 <alloc_sockfd>
  801038:	89 c1                	mov    %eax,%ecx
}
  80103a:	89 c8                	mov    %ecx,%eax
  80103c:	c9                   	leave  
  80103d:	c3                   	ret    

0080103e <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801044:	8b 45 08             	mov    0x8(%ebp),%eax
  801047:	e8 19 ff ff ff       	call   800f65 <fd2sockid>
  80104c:	85 c0                	test   %eax,%eax
  80104e:	78 12                	js     801062 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801050:	83 ec 04             	sub    $0x4,%esp
  801053:	ff 75 10             	pushl  0x10(%ebp)
  801056:	ff 75 0c             	pushl  0xc(%ebp)
  801059:	50                   	push   %eax
  80105a:	e8 2d 01 00 00       	call   80118c <nsipc_bind>
  80105f:	83 c4 10             	add    $0x10,%esp
}
  801062:	c9                   	leave  
  801063:	c3                   	ret    

00801064 <shutdown>:

int
shutdown(int s, int how)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80106a:	8b 45 08             	mov    0x8(%ebp),%eax
  80106d:	e8 f3 fe ff ff       	call   800f65 <fd2sockid>
  801072:	85 c0                	test   %eax,%eax
  801074:	78 0f                	js     801085 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801076:	83 ec 08             	sub    $0x8,%esp
  801079:	ff 75 0c             	pushl  0xc(%ebp)
  80107c:	50                   	push   %eax
  80107d:	e8 3f 01 00 00       	call   8011c1 <nsipc_shutdown>
  801082:	83 c4 10             	add    $0x10,%esp
}
  801085:	c9                   	leave  
  801086:	c3                   	ret    

00801087 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80108d:	8b 45 08             	mov    0x8(%ebp),%eax
  801090:	e8 d0 fe ff ff       	call   800f65 <fd2sockid>
  801095:	85 c0                	test   %eax,%eax
  801097:	78 12                	js     8010ab <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801099:	83 ec 04             	sub    $0x4,%esp
  80109c:	ff 75 10             	pushl  0x10(%ebp)
  80109f:	ff 75 0c             	pushl  0xc(%ebp)
  8010a2:	50                   	push   %eax
  8010a3:	e8 55 01 00 00       	call   8011fd <nsipc_connect>
  8010a8:	83 c4 10             	add    $0x10,%esp
}
  8010ab:	c9                   	leave  
  8010ac:	c3                   	ret    

008010ad <listen>:

int
listen(int s, int backlog)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b6:	e8 aa fe ff ff       	call   800f65 <fd2sockid>
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	78 0f                	js     8010ce <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8010bf:	83 ec 08             	sub    $0x8,%esp
  8010c2:	ff 75 0c             	pushl  0xc(%ebp)
  8010c5:	50                   	push   %eax
  8010c6:	e8 67 01 00 00       	call   801232 <nsipc_listen>
  8010cb:	83 c4 10             	add    $0x10,%esp
}
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8010d6:	ff 75 10             	pushl  0x10(%ebp)
  8010d9:	ff 75 0c             	pushl  0xc(%ebp)
  8010dc:	ff 75 08             	pushl  0x8(%ebp)
  8010df:	e8 3a 02 00 00       	call   80131e <nsipc_socket>
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 05                	js     8010f0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8010eb:	e8 a5 fe ff ff       	call   800f95 <alloc_sockfd>
}
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 04             	sub    $0x4,%esp
  8010f9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8010fb:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801102:	75 12                	jne    801116 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801104:	83 ec 0c             	sub    $0xc,%esp
  801107:	6a 02                	push   $0x2
  801109:	e8 47 0e 00 00       	call   801f55 <ipc_find_env>
  80110e:	a3 04 40 80 00       	mov    %eax,0x804004
  801113:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801116:	6a 07                	push   $0x7
  801118:	68 00 60 80 00       	push   $0x806000
  80111d:	53                   	push   %ebx
  80111e:	ff 35 04 40 80 00    	pushl  0x804004
  801124:	e8 dd 0d 00 00       	call   801f06 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801129:	83 c4 0c             	add    $0xc,%esp
  80112c:	6a 00                	push   $0x0
  80112e:	6a 00                	push   $0x0
  801130:	6a 00                	push   $0x0
  801132:	e8 59 0d 00 00       	call   801e90 <ipc_recv>
}
  801137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113a:	c9                   	leave  
  80113b:	c3                   	ret    

0080113c <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	56                   	push   %esi
  801140:	53                   	push   %ebx
  801141:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801144:	8b 45 08             	mov    0x8(%ebp),%eax
  801147:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80114c:	8b 06                	mov    (%esi),%eax
  80114e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801153:	b8 01 00 00 00       	mov    $0x1,%eax
  801158:	e8 95 ff ff ff       	call   8010f2 <nsipc>
  80115d:	89 c3                	mov    %eax,%ebx
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 20                	js     801183 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801163:	83 ec 04             	sub    $0x4,%esp
  801166:	ff 35 10 60 80 00    	pushl  0x806010
  80116c:	68 00 60 80 00       	push   $0x806000
  801171:	ff 75 0c             	pushl  0xc(%ebp)
  801174:	e8 62 0b 00 00       	call   801cdb <memmove>
		*addrlen = ret->ret_addrlen;
  801179:	a1 10 60 80 00       	mov    0x806010,%eax
  80117e:	89 06                	mov    %eax,(%esi)
  801180:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801183:	89 d8                	mov    %ebx,%eax
  801185:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	53                   	push   %ebx
  801190:	83 ec 08             	sub    $0x8,%esp
  801193:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
  801199:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80119e:	53                   	push   %ebx
  80119f:	ff 75 0c             	pushl  0xc(%ebp)
  8011a2:	68 04 60 80 00       	push   $0x806004
  8011a7:	e8 2f 0b 00 00       	call   801cdb <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8011ac:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8011b2:	b8 02 00 00 00       	mov    $0x2,%eax
  8011b7:	e8 36 ff ff ff       	call   8010f2 <nsipc>
}
  8011bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011bf:	c9                   	leave  
  8011c0:	c3                   	ret    

008011c1 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ca:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8011cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8011d7:	b8 03 00 00 00       	mov    $0x3,%eax
  8011dc:	e8 11 ff ff ff       	call   8010f2 <nsipc>
}
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <nsipc_close>:

int
nsipc_close(int s)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8011e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ec:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8011f1:	b8 04 00 00 00       	mov    $0x4,%eax
  8011f6:	e8 f7 fe ff ff       	call   8010f2 <nsipc>
}
  8011fb:	c9                   	leave  
  8011fc:	c3                   	ret    

008011fd <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	53                   	push   %ebx
  801201:	83 ec 08             	sub    $0x8,%esp
  801204:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801207:	8b 45 08             	mov    0x8(%ebp),%eax
  80120a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80120f:	53                   	push   %ebx
  801210:	ff 75 0c             	pushl  0xc(%ebp)
  801213:	68 04 60 80 00       	push   $0x806004
  801218:	e8 be 0a 00 00       	call   801cdb <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80121d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801223:	b8 05 00 00 00       	mov    $0x5,%eax
  801228:	e8 c5 fe ff ff       	call   8010f2 <nsipc>
}
  80122d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801238:	8b 45 08             	mov    0x8(%ebp),%eax
  80123b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801240:	8b 45 0c             	mov    0xc(%ebp),%eax
  801243:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801248:	b8 06 00 00 00       	mov    $0x6,%eax
  80124d:	e8 a0 fe ff ff       	call   8010f2 <nsipc>
}
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80125c:	8b 45 08             	mov    0x8(%ebp),%eax
  80125f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801264:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80126a:	8b 45 14             	mov    0x14(%ebp),%eax
  80126d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801272:	b8 07 00 00 00       	mov    $0x7,%eax
  801277:	e8 76 fe ff ff       	call   8010f2 <nsipc>
  80127c:	89 c3                	mov    %eax,%ebx
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 35                	js     8012b7 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801282:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801287:	7f 04                	jg     80128d <nsipc_recv+0x39>
  801289:	39 c6                	cmp    %eax,%esi
  80128b:	7d 16                	jge    8012a3 <nsipc_recv+0x4f>
  80128d:	68 86 23 80 00       	push   $0x802386
  801292:	68 2f 23 80 00       	push   $0x80232f
  801297:	6a 62                	push   $0x62
  801299:	68 9b 23 80 00       	push   $0x80239b
  80129e:	e8 28 02 00 00       	call   8014cb <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8012a3:	83 ec 04             	sub    $0x4,%esp
  8012a6:	50                   	push   %eax
  8012a7:	68 00 60 80 00       	push   $0x806000
  8012ac:	ff 75 0c             	pushl  0xc(%ebp)
  8012af:	e8 27 0a 00 00       	call   801cdb <memmove>
  8012b4:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8012b7:	89 d8                	mov    %ebx,%eax
  8012b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012bc:	5b                   	pop    %ebx
  8012bd:	5e                   	pop    %esi
  8012be:	5d                   	pop    %ebp
  8012bf:	c3                   	ret    

008012c0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 04             	sub    $0x4,%esp
  8012c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8012ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cd:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8012d2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8012d8:	7e 16                	jle    8012f0 <nsipc_send+0x30>
  8012da:	68 a7 23 80 00       	push   $0x8023a7
  8012df:	68 2f 23 80 00       	push   $0x80232f
  8012e4:	6a 6d                	push   $0x6d
  8012e6:	68 9b 23 80 00       	push   $0x80239b
  8012eb:	e8 db 01 00 00       	call   8014cb <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8012f0:	83 ec 04             	sub    $0x4,%esp
  8012f3:	53                   	push   %ebx
  8012f4:	ff 75 0c             	pushl  0xc(%ebp)
  8012f7:	68 0c 60 80 00       	push   $0x80600c
  8012fc:	e8 da 09 00 00       	call   801cdb <memmove>
	nsipcbuf.send.req_size = size;
  801301:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801307:	8b 45 14             	mov    0x14(%ebp),%eax
  80130a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80130f:	b8 08 00 00 00       	mov    $0x8,%eax
  801314:	e8 d9 fd ff ff       	call   8010f2 <nsipc>
}
  801319:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801324:	8b 45 08             	mov    0x8(%ebp),%eax
  801327:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80132c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801334:	8b 45 10             	mov    0x10(%ebp),%eax
  801337:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80133c:	b8 09 00 00 00       	mov    $0x9,%eax
  801341:	e8 ac fd ff ff       	call   8010f2 <nsipc>
}
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80134b:	b8 00 00 00 00       	mov    $0x0,%eax
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801358:	68 b3 23 80 00       	push   $0x8023b3
  80135d:	ff 75 0c             	pushl  0xc(%ebp)
  801360:	e8 e4 07 00 00       	call   801b49 <strcpy>
	return 0;
}
  801365:	b8 00 00 00 00       	mov    $0x0,%eax
  80136a:	c9                   	leave  
  80136b:	c3                   	ret    

0080136c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	57                   	push   %edi
  801370:	56                   	push   %esi
  801371:	53                   	push   %ebx
  801372:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801378:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80137d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801383:	eb 2d                	jmp    8013b2 <devcons_write+0x46>
		m = n - tot;
  801385:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801388:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80138a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80138d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801392:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801395:	83 ec 04             	sub    $0x4,%esp
  801398:	53                   	push   %ebx
  801399:	03 45 0c             	add    0xc(%ebp),%eax
  80139c:	50                   	push   %eax
  80139d:	57                   	push   %edi
  80139e:	e8 38 09 00 00       	call   801cdb <memmove>
		sys_cputs(buf, m);
  8013a3:	83 c4 08             	add    $0x8,%esp
  8013a6:	53                   	push   %ebx
  8013a7:	57                   	push   %edi
  8013a8:	e8 f5 ec ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ad:	01 de                	add    %ebx,%esi
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	89 f0                	mov    %esi,%eax
  8013b4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013b7:	72 cc                	jb     801385 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5e                   	pop    %esi
  8013be:	5f                   	pop    %edi
  8013bf:	5d                   	pop    %ebp
  8013c0:	c3                   	ret    

008013c1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013d0:	74 2a                	je     8013fc <devcons_read+0x3b>
  8013d2:	eb 05                	jmp    8013d9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013d4:	e8 66 ed ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013d9:	e8 e2 ec ff ff       	call   8000c0 <sys_cgetc>
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	74 f2                	je     8013d4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 16                	js     8013fc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013e6:	83 f8 04             	cmp    $0x4,%eax
  8013e9:	74 0c                	je     8013f7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ee:	88 02                	mov    %al,(%edx)
	return 1;
  8013f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8013f5:	eb 05                	jmp    8013fc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013f7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801404:	8b 45 08             	mov    0x8(%ebp),%eax
  801407:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80140a:	6a 01                	push   $0x1
  80140c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80140f:	50                   	push   %eax
  801410:	e8 8d ec ff ff       	call   8000a2 <sys_cputs>
}
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <getchar>:

int
getchar(void)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801420:	6a 01                	push   $0x1
  801422:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801425:	50                   	push   %eax
  801426:	6a 00                	push   $0x0
  801428:	e8 1d f2 ff ff       	call   80064a <read>
	if (r < 0)
  80142d:	83 c4 10             	add    $0x10,%esp
  801430:	85 c0                	test   %eax,%eax
  801432:	78 0f                	js     801443 <getchar+0x29>
		return r;
	if (r < 1)
  801434:	85 c0                	test   %eax,%eax
  801436:	7e 06                	jle    80143e <getchar+0x24>
		return -E_EOF;
	return c;
  801438:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80143c:	eb 05                	jmp    801443 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80143e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144e:	50                   	push   %eax
  80144f:	ff 75 08             	pushl  0x8(%ebp)
  801452:	e8 8d ef ff ff       	call   8003e4 <fd_lookup>
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 11                	js     80146f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80145e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801461:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801467:	39 10                	cmp    %edx,(%eax)
  801469:	0f 94 c0             	sete   %al
  80146c:	0f b6 c0             	movzbl %al,%eax
}
  80146f:	c9                   	leave  
  801470:	c3                   	ret    

00801471 <opencons>:

int
opencons(void)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801477:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	e8 15 ef ff ff       	call   800395 <fd_alloc>
  801480:	83 c4 10             	add    $0x10,%esp
		return r;
  801483:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801485:	85 c0                	test   %eax,%eax
  801487:	78 3e                	js     8014c7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801489:	83 ec 04             	sub    $0x4,%esp
  80148c:	68 07 04 00 00       	push   $0x407
  801491:	ff 75 f4             	pushl  -0xc(%ebp)
  801494:	6a 00                	push   $0x0
  801496:	e8 c3 ec ff ff       	call   80015e <sys_page_alloc>
  80149b:	83 c4 10             	add    $0x10,%esp
		return r;
  80149e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 23                	js     8014c7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014a4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ad:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014b9:	83 ec 0c             	sub    $0xc,%esp
  8014bc:	50                   	push   %eax
  8014bd:	e8 ac ee ff ff       	call   80036e <fd2num>
  8014c2:	89 c2                	mov    %eax,%edx
  8014c4:	83 c4 10             	add    $0x10,%esp
}
  8014c7:	89 d0                	mov    %edx,%eax
  8014c9:	c9                   	leave  
  8014ca:	c3                   	ret    

008014cb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	56                   	push   %esi
  8014cf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014d0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014d3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014d9:	e8 42 ec ff ff       	call   800120 <sys_getenvid>
  8014de:	83 ec 0c             	sub    $0xc,%esp
  8014e1:	ff 75 0c             	pushl  0xc(%ebp)
  8014e4:	ff 75 08             	pushl  0x8(%ebp)
  8014e7:	56                   	push   %esi
  8014e8:	50                   	push   %eax
  8014e9:	68 c0 23 80 00       	push   $0x8023c0
  8014ee:	e8 b1 00 00 00       	call   8015a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014f3:	83 c4 18             	add    $0x18,%esp
  8014f6:	53                   	push   %ebx
  8014f7:	ff 75 10             	pushl  0x10(%ebp)
  8014fa:	e8 54 00 00 00       	call   801553 <vcprintf>
	cprintf("\n");
  8014ff:	c7 04 24 73 23 80 00 	movl   $0x802373,(%esp)
  801506:	e8 99 00 00 00       	call   8015a4 <cprintf>
  80150b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80150e:	cc                   	int3   
  80150f:	eb fd                	jmp    80150e <_panic+0x43>

00801511 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	53                   	push   %ebx
  801515:	83 ec 04             	sub    $0x4,%esp
  801518:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80151b:	8b 13                	mov    (%ebx),%edx
  80151d:	8d 42 01             	lea    0x1(%edx),%eax
  801520:	89 03                	mov    %eax,(%ebx)
  801522:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801525:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801529:	3d ff 00 00 00       	cmp    $0xff,%eax
  80152e:	75 1a                	jne    80154a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	68 ff 00 00 00       	push   $0xff
  801538:	8d 43 08             	lea    0x8(%ebx),%eax
  80153b:	50                   	push   %eax
  80153c:	e8 61 eb ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  801541:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801547:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80154a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80154e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80155c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801563:	00 00 00 
	b.cnt = 0;
  801566:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80156d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801570:	ff 75 0c             	pushl  0xc(%ebp)
  801573:	ff 75 08             	pushl  0x8(%ebp)
  801576:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80157c:	50                   	push   %eax
  80157d:	68 11 15 80 00       	push   $0x801511
  801582:	e8 54 01 00 00       	call   8016db <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801587:	83 c4 08             	add    $0x8,%esp
  80158a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801590:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801596:	50                   	push   %eax
  801597:	e8 06 eb ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  80159c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015ad:	50                   	push   %eax
  8015ae:	ff 75 08             	pushl  0x8(%ebp)
  8015b1:	e8 9d ff ff ff       	call   801553 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	57                   	push   %edi
  8015bc:	56                   	push   %esi
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 1c             	sub    $0x1c,%esp
  8015c1:	89 c7                	mov    %eax,%edi
  8015c3:	89 d6                	mov    %edx,%esi
  8015c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015dc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015df:	39 d3                	cmp    %edx,%ebx
  8015e1:	72 05                	jb     8015e8 <printnum+0x30>
  8015e3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015e6:	77 45                	ja     80162d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	ff 75 18             	pushl  0x18(%ebp)
  8015ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015f4:	53                   	push   %ebx
  8015f5:	ff 75 10             	pushl  0x10(%ebp)
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801601:	ff 75 dc             	pushl  -0x24(%ebp)
  801604:	ff 75 d8             	pushl  -0x28(%ebp)
  801607:	e8 c4 09 00 00       	call   801fd0 <__udivdi3>
  80160c:	83 c4 18             	add    $0x18,%esp
  80160f:	52                   	push   %edx
  801610:	50                   	push   %eax
  801611:	89 f2                	mov    %esi,%edx
  801613:	89 f8                	mov    %edi,%eax
  801615:	e8 9e ff ff ff       	call   8015b8 <printnum>
  80161a:	83 c4 20             	add    $0x20,%esp
  80161d:	eb 18                	jmp    801637 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	56                   	push   %esi
  801623:	ff 75 18             	pushl  0x18(%ebp)
  801626:	ff d7                	call   *%edi
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	eb 03                	jmp    801630 <printnum+0x78>
  80162d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801630:	83 eb 01             	sub    $0x1,%ebx
  801633:	85 db                	test   %ebx,%ebx
  801635:	7f e8                	jg     80161f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	56                   	push   %esi
  80163b:	83 ec 04             	sub    $0x4,%esp
  80163e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801641:	ff 75 e0             	pushl  -0x20(%ebp)
  801644:	ff 75 dc             	pushl  -0x24(%ebp)
  801647:	ff 75 d8             	pushl  -0x28(%ebp)
  80164a:	e8 b1 0a 00 00       	call   802100 <__umoddi3>
  80164f:	83 c4 14             	add    $0x14,%esp
  801652:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801659:	50                   	push   %eax
  80165a:	ff d7                	call   *%edi
}
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801662:	5b                   	pop    %ebx
  801663:	5e                   	pop    %esi
  801664:	5f                   	pop    %edi
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80166a:	83 fa 01             	cmp    $0x1,%edx
  80166d:	7e 0e                	jle    80167d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80166f:	8b 10                	mov    (%eax),%edx
  801671:	8d 4a 08             	lea    0x8(%edx),%ecx
  801674:	89 08                	mov    %ecx,(%eax)
  801676:	8b 02                	mov    (%edx),%eax
  801678:	8b 52 04             	mov    0x4(%edx),%edx
  80167b:	eb 22                	jmp    80169f <getuint+0x38>
	else if (lflag)
  80167d:	85 d2                	test   %edx,%edx
  80167f:	74 10                	je     801691 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801681:	8b 10                	mov    (%eax),%edx
  801683:	8d 4a 04             	lea    0x4(%edx),%ecx
  801686:	89 08                	mov    %ecx,(%eax)
  801688:	8b 02                	mov    (%edx),%eax
  80168a:	ba 00 00 00 00       	mov    $0x0,%edx
  80168f:	eb 0e                	jmp    80169f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801691:	8b 10                	mov    (%eax),%edx
  801693:	8d 4a 04             	lea    0x4(%edx),%ecx
  801696:	89 08                	mov    %ecx,(%eax)
  801698:	8b 02                	mov    (%edx),%eax
  80169a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016a7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016ab:	8b 10                	mov    (%eax),%edx
  8016ad:	3b 50 04             	cmp    0x4(%eax),%edx
  8016b0:	73 0a                	jae    8016bc <sprintputch+0x1b>
		*b->buf++ = ch;
  8016b2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016b5:	89 08                	mov    %ecx,(%eax)
  8016b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ba:	88 02                	mov    %al,(%edx)
}
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016c7:	50                   	push   %eax
  8016c8:	ff 75 10             	pushl  0x10(%ebp)
  8016cb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ce:	ff 75 08             	pushl  0x8(%ebp)
  8016d1:	e8 05 00 00 00       	call   8016db <vprintfmt>
	va_end(ap);
}
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	57                   	push   %edi
  8016df:	56                   	push   %esi
  8016e0:	53                   	push   %ebx
  8016e1:	83 ec 2c             	sub    $0x2c,%esp
  8016e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8016e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016ea:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016ed:	eb 12                	jmp    801701 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	0f 84 a9 03 00 00    	je     801aa0 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	53                   	push   %ebx
  8016fb:	50                   	push   %eax
  8016fc:	ff d6                	call   *%esi
  8016fe:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801701:	83 c7 01             	add    $0x1,%edi
  801704:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801708:	83 f8 25             	cmp    $0x25,%eax
  80170b:	75 e2                	jne    8016ef <vprintfmt+0x14>
  80170d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801711:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801718:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80171f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801726:	ba 00 00 00 00       	mov    $0x0,%edx
  80172b:	eb 07                	jmp    801734 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80172d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801730:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801734:	8d 47 01             	lea    0x1(%edi),%eax
  801737:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80173a:	0f b6 07             	movzbl (%edi),%eax
  80173d:	0f b6 c8             	movzbl %al,%ecx
  801740:	83 e8 23             	sub    $0x23,%eax
  801743:	3c 55                	cmp    $0x55,%al
  801745:	0f 87 3a 03 00 00    	ja     801a85 <vprintfmt+0x3aa>
  80174b:	0f b6 c0             	movzbl %al,%eax
  80174e:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801755:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801758:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80175c:	eb d6                	jmp    801734 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801761:	b8 00 00 00 00       	mov    $0x0,%eax
  801766:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801769:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80176c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801770:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801773:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801776:	83 fa 09             	cmp    $0x9,%edx
  801779:	77 39                	ja     8017b4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80177b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80177e:	eb e9                	jmp    801769 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801780:	8b 45 14             	mov    0x14(%ebp),%eax
  801783:	8d 48 04             	lea    0x4(%eax),%ecx
  801786:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801789:	8b 00                	mov    (%eax),%eax
  80178b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801791:	eb 27                	jmp    8017ba <vprintfmt+0xdf>
  801793:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801796:	85 c0                	test   %eax,%eax
  801798:	b9 00 00 00 00       	mov    $0x0,%ecx
  80179d:	0f 49 c8             	cmovns %eax,%ecx
  8017a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017a6:	eb 8c                	jmp    801734 <vprintfmt+0x59>
  8017a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017ab:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017b2:	eb 80                	jmp    801734 <vprintfmt+0x59>
  8017b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017b7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017be:	0f 89 70 ff ff ff    	jns    801734 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017d1:	e9 5e ff ff ff       	jmp    801734 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017d6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017dc:	e9 53 ff ff ff       	jmp    801734 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e4:	8d 50 04             	lea    0x4(%eax),%edx
  8017e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8017ea:	83 ec 08             	sub    $0x8,%esp
  8017ed:	53                   	push   %ebx
  8017ee:	ff 30                	pushl  (%eax)
  8017f0:	ff d6                	call   *%esi
			break;
  8017f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017f8:	e9 04 ff ff ff       	jmp    801701 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801800:	8d 50 04             	lea    0x4(%eax),%edx
  801803:	89 55 14             	mov    %edx,0x14(%ebp)
  801806:	8b 00                	mov    (%eax),%eax
  801808:	99                   	cltd   
  801809:	31 d0                	xor    %edx,%eax
  80180b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80180d:	83 f8 0f             	cmp    $0xf,%eax
  801810:	7f 0b                	jg     80181d <vprintfmt+0x142>
  801812:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801819:	85 d2                	test   %edx,%edx
  80181b:	75 18                	jne    801835 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80181d:	50                   	push   %eax
  80181e:	68 fb 23 80 00       	push   $0x8023fb
  801823:	53                   	push   %ebx
  801824:	56                   	push   %esi
  801825:	e8 94 fe ff ff       	call   8016be <printfmt>
  80182a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801830:	e9 cc fe ff ff       	jmp    801701 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801835:	52                   	push   %edx
  801836:	68 41 23 80 00       	push   $0x802341
  80183b:	53                   	push   %ebx
  80183c:	56                   	push   %esi
  80183d:	e8 7c fe ff ff       	call   8016be <printfmt>
  801842:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801845:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801848:	e9 b4 fe ff ff       	jmp    801701 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80184d:	8b 45 14             	mov    0x14(%ebp),%eax
  801850:	8d 50 04             	lea    0x4(%eax),%edx
  801853:	89 55 14             	mov    %edx,0x14(%ebp)
  801856:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801858:	85 ff                	test   %edi,%edi
  80185a:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  80185f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801862:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801866:	0f 8e 94 00 00 00    	jle    801900 <vprintfmt+0x225>
  80186c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801870:	0f 84 98 00 00 00    	je     80190e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801876:	83 ec 08             	sub    $0x8,%esp
  801879:	ff 75 d0             	pushl  -0x30(%ebp)
  80187c:	57                   	push   %edi
  80187d:	e8 a6 02 00 00       	call   801b28 <strnlen>
  801882:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801885:	29 c1                	sub    %eax,%ecx
  801887:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80188a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80188d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801891:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801894:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801897:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801899:	eb 0f                	jmp    8018aa <vprintfmt+0x1cf>
					putch(padc, putdat);
  80189b:	83 ec 08             	sub    $0x8,%esp
  80189e:	53                   	push   %ebx
  80189f:	ff 75 e0             	pushl  -0x20(%ebp)
  8018a2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a4:	83 ef 01             	sub    $0x1,%edi
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	85 ff                	test   %edi,%edi
  8018ac:	7f ed                	jg     80189b <vprintfmt+0x1c0>
  8018ae:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018b1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018b4:	85 c9                	test   %ecx,%ecx
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bb:	0f 49 c1             	cmovns %ecx,%eax
  8018be:	29 c1                	sub    %eax,%ecx
  8018c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8018c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018c9:	89 cb                	mov    %ecx,%ebx
  8018cb:	eb 4d                	jmp    80191a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018cd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018d1:	74 1b                	je     8018ee <vprintfmt+0x213>
  8018d3:	0f be c0             	movsbl %al,%eax
  8018d6:	83 e8 20             	sub    $0x20,%eax
  8018d9:	83 f8 5e             	cmp    $0x5e,%eax
  8018dc:	76 10                	jbe    8018ee <vprintfmt+0x213>
					putch('?', putdat);
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	ff 75 0c             	pushl  0xc(%ebp)
  8018e4:	6a 3f                	push   $0x3f
  8018e6:	ff 55 08             	call   *0x8(%ebp)
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	eb 0d                	jmp    8018fb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	ff 75 0c             	pushl  0xc(%ebp)
  8018f4:	52                   	push   %edx
  8018f5:	ff 55 08             	call   *0x8(%ebp)
  8018f8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018fb:	83 eb 01             	sub    $0x1,%ebx
  8018fe:	eb 1a                	jmp    80191a <vprintfmt+0x23f>
  801900:	89 75 08             	mov    %esi,0x8(%ebp)
  801903:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801906:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801909:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80190c:	eb 0c                	jmp    80191a <vprintfmt+0x23f>
  80190e:	89 75 08             	mov    %esi,0x8(%ebp)
  801911:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801914:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801917:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80191a:	83 c7 01             	add    $0x1,%edi
  80191d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801921:	0f be d0             	movsbl %al,%edx
  801924:	85 d2                	test   %edx,%edx
  801926:	74 23                	je     80194b <vprintfmt+0x270>
  801928:	85 f6                	test   %esi,%esi
  80192a:	78 a1                	js     8018cd <vprintfmt+0x1f2>
  80192c:	83 ee 01             	sub    $0x1,%esi
  80192f:	79 9c                	jns    8018cd <vprintfmt+0x1f2>
  801931:	89 df                	mov    %ebx,%edi
  801933:	8b 75 08             	mov    0x8(%ebp),%esi
  801936:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801939:	eb 18                	jmp    801953 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80193b:	83 ec 08             	sub    $0x8,%esp
  80193e:	53                   	push   %ebx
  80193f:	6a 20                	push   $0x20
  801941:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801943:	83 ef 01             	sub    $0x1,%edi
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	eb 08                	jmp    801953 <vprintfmt+0x278>
  80194b:	89 df                	mov    %ebx,%edi
  80194d:	8b 75 08             	mov    0x8(%ebp),%esi
  801950:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801953:	85 ff                	test   %edi,%edi
  801955:	7f e4                	jg     80193b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801957:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80195a:	e9 a2 fd ff ff       	jmp    801701 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80195f:	83 fa 01             	cmp    $0x1,%edx
  801962:	7e 16                	jle    80197a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801964:	8b 45 14             	mov    0x14(%ebp),%eax
  801967:	8d 50 08             	lea    0x8(%eax),%edx
  80196a:	89 55 14             	mov    %edx,0x14(%ebp)
  80196d:	8b 50 04             	mov    0x4(%eax),%edx
  801970:	8b 00                	mov    (%eax),%eax
  801972:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801975:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801978:	eb 32                	jmp    8019ac <vprintfmt+0x2d1>
	else if (lflag)
  80197a:	85 d2                	test   %edx,%edx
  80197c:	74 18                	je     801996 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80197e:	8b 45 14             	mov    0x14(%ebp),%eax
  801981:	8d 50 04             	lea    0x4(%eax),%edx
  801984:	89 55 14             	mov    %edx,0x14(%ebp)
  801987:	8b 00                	mov    (%eax),%eax
  801989:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80198c:	89 c1                	mov    %eax,%ecx
  80198e:	c1 f9 1f             	sar    $0x1f,%ecx
  801991:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801994:	eb 16                	jmp    8019ac <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801996:	8b 45 14             	mov    0x14(%ebp),%eax
  801999:	8d 50 04             	lea    0x4(%eax),%edx
  80199c:	89 55 14             	mov    %edx,0x14(%ebp)
  80199f:	8b 00                	mov    (%eax),%eax
  8019a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a4:	89 c1                	mov    %eax,%ecx
  8019a6:	c1 f9 1f             	sar    $0x1f,%ecx
  8019a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019af:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019b2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019b7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019bb:	0f 89 90 00 00 00    	jns    801a51 <vprintfmt+0x376>
				putch('-', putdat);
  8019c1:	83 ec 08             	sub    $0x8,%esp
  8019c4:	53                   	push   %ebx
  8019c5:	6a 2d                	push   $0x2d
  8019c7:	ff d6                	call   *%esi
				num = -(long long) num;
  8019c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019cf:	f7 d8                	neg    %eax
  8019d1:	83 d2 00             	adc    $0x0,%edx
  8019d4:	f7 da                	neg    %edx
  8019d6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019de:	eb 71                	jmp    801a51 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8019e3:	e8 7f fc ff ff       	call   801667 <getuint>
			base = 10;
  8019e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019ed:	eb 62                	jmp    801a51 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8019ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8019f2:	e8 70 fc ff ff       	call   801667 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8019f7:	83 ec 0c             	sub    $0xc,%esp
  8019fa:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8019fe:	51                   	push   %ecx
  8019ff:	ff 75 e0             	pushl  -0x20(%ebp)
  801a02:	6a 08                	push   $0x8
  801a04:	52                   	push   %edx
  801a05:	50                   	push   %eax
  801a06:	89 da                	mov    %ebx,%edx
  801a08:	89 f0                	mov    %esi,%eax
  801a0a:	e8 a9 fb ff ff       	call   8015b8 <printnum>
			break;
  801a0f:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  801a15:	e9 e7 fc ff ff       	jmp    801701 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a1a:	83 ec 08             	sub    $0x8,%esp
  801a1d:	53                   	push   %ebx
  801a1e:	6a 30                	push   $0x30
  801a20:	ff d6                	call   *%esi
			putch('x', putdat);
  801a22:	83 c4 08             	add    $0x8,%esp
  801a25:	53                   	push   %ebx
  801a26:	6a 78                	push   $0x78
  801a28:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2d:	8d 50 04             	lea    0x4(%eax),%edx
  801a30:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a33:	8b 00                	mov    (%eax),%eax
  801a35:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a3a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a3d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a42:	eb 0d                	jmp    801a51 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a44:	8d 45 14             	lea    0x14(%ebp),%eax
  801a47:	e8 1b fc ff ff       	call   801667 <getuint>
			base = 16;
  801a4c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a51:	83 ec 0c             	sub    $0xc,%esp
  801a54:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a58:	57                   	push   %edi
  801a59:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5c:	51                   	push   %ecx
  801a5d:	52                   	push   %edx
  801a5e:	50                   	push   %eax
  801a5f:	89 da                	mov    %ebx,%edx
  801a61:	89 f0                	mov    %esi,%eax
  801a63:	e8 50 fb ff ff       	call   8015b8 <printnum>
			break;
  801a68:	83 c4 20             	add    $0x20,%esp
  801a6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a6e:	e9 8e fc ff ff       	jmp    801701 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a73:	83 ec 08             	sub    $0x8,%esp
  801a76:	53                   	push   %ebx
  801a77:	51                   	push   %ecx
  801a78:	ff d6                	call   *%esi
			break;
  801a7a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a80:	e9 7c fc ff ff       	jmp    801701 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a85:	83 ec 08             	sub    $0x8,%esp
  801a88:	53                   	push   %ebx
  801a89:	6a 25                	push   $0x25
  801a8b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	eb 03                	jmp    801a95 <vprintfmt+0x3ba>
  801a92:	83 ef 01             	sub    $0x1,%edi
  801a95:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a99:	75 f7                	jne    801a92 <vprintfmt+0x3b7>
  801a9b:	e9 61 fc ff ff       	jmp    801701 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa3:	5b                   	pop    %ebx
  801aa4:	5e                   	pop    %esi
  801aa5:	5f                   	pop    %edi
  801aa6:	5d                   	pop    %ebp
  801aa7:	c3                   	ret    

00801aa8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 18             	sub    $0x18,%esp
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801abb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801abe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	74 26                	je     801aef <vsnprintf+0x47>
  801ac9:	85 d2                	test   %edx,%edx
  801acb:	7e 22                	jle    801aef <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801acd:	ff 75 14             	pushl  0x14(%ebp)
  801ad0:	ff 75 10             	pushl  0x10(%ebp)
  801ad3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad6:	50                   	push   %eax
  801ad7:	68 a1 16 80 00       	push   $0x8016a1
  801adc:	e8 fa fb ff ff       	call   8016db <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ae1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	eb 05                	jmp    801af4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801aef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801afc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801aff:	50                   	push   %eax
  801b00:	ff 75 10             	pushl  0x10(%ebp)
  801b03:	ff 75 0c             	pushl  0xc(%ebp)
  801b06:	ff 75 08             	pushl  0x8(%ebp)
  801b09:	e8 9a ff ff ff       	call   801aa8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b16:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1b:	eb 03                	jmp    801b20 <strlen+0x10>
		n++;
  801b1d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b24:	75 f7                	jne    801b1d <strlen+0xd>
		n++;
	return n;
}
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b31:	ba 00 00 00 00       	mov    $0x0,%edx
  801b36:	eb 03                	jmp    801b3b <strnlen+0x13>
		n++;
  801b38:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b3b:	39 c2                	cmp    %eax,%edx
  801b3d:	74 08                	je     801b47 <strnlen+0x1f>
  801b3f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b43:	75 f3                	jne    801b38 <strnlen+0x10>
  801b45:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b47:	5d                   	pop    %ebp
  801b48:	c3                   	ret    

00801b49 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	53                   	push   %ebx
  801b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b53:	89 c2                	mov    %eax,%edx
  801b55:	83 c2 01             	add    $0x1,%edx
  801b58:	83 c1 01             	add    $0x1,%ecx
  801b5b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b5f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b62:	84 db                	test   %bl,%bl
  801b64:	75 ef                	jne    801b55 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b66:	5b                   	pop    %ebx
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	53                   	push   %ebx
  801b6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b70:	53                   	push   %ebx
  801b71:	e8 9a ff ff ff       	call   801b10 <strlen>
  801b76:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b79:	ff 75 0c             	pushl  0xc(%ebp)
  801b7c:	01 d8                	add    %ebx,%eax
  801b7e:	50                   	push   %eax
  801b7f:	e8 c5 ff ff ff       	call   801b49 <strcpy>
	return dst;
}
  801b84:	89 d8                	mov    %ebx,%eax
  801b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	56                   	push   %esi
  801b8f:	53                   	push   %ebx
  801b90:	8b 75 08             	mov    0x8(%ebp),%esi
  801b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b96:	89 f3                	mov    %esi,%ebx
  801b98:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b9b:	89 f2                	mov    %esi,%edx
  801b9d:	eb 0f                	jmp    801bae <strncpy+0x23>
		*dst++ = *src;
  801b9f:	83 c2 01             	add    $0x1,%edx
  801ba2:	0f b6 01             	movzbl (%ecx),%eax
  801ba5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba8:	80 39 01             	cmpb   $0x1,(%ecx)
  801bab:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bae:	39 da                	cmp    %ebx,%edx
  801bb0:	75 ed                	jne    801b9f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bb2:	89 f0                	mov    %esi,%eax
  801bb4:	5b                   	pop    %ebx
  801bb5:	5e                   	pop    %esi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    

00801bb8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	56                   	push   %esi
  801bbc:	53                   	push   %ebx
  801bbd:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc3:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc8:	85 d2                	test   %edx,%edx
  801bca:	74 21                	je     801bed <strlcpy+0x35>
  801bcc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bd0:	89 f2                	mov    %esi,%edx
  801bd2:	eb 09                	jmp    801bdd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bd4:	83 c2 01             	add    $0x1,%edx
  801bd7:	83 c1 01             	add    $0x1,%ecx
  801bda:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bdd:	39 c2                	cmp    %eax,%edx
  801bdf:	74 09                	je     801bea <strlcpy+0x32>
  801be1:	0f b6 19             	movzbl (%ecx),%ebx
  801be4:	84 db                	test   %bl,%bl
  801be6:	75 ec                	jne    801bd4 <strlcpy+0x1c>
  801be8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bea:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bed:	29 f0                	sub    %esi,%eax
}
  801bef:	5b                   	pop    %ebx
  801bf0:	5e                   	pop    %esi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bfc:	eb 06                	jmp    801c04 <strcmp+0x11>
		p++, q++;
  801bfe:	83 c1 01             	add    $0x1,%ecx
  801c01:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c04:	0f b6 01             	movzbl (%ecx),%eax
  801c07:	84 c0                	test   %al,%al
  801c09:	74 04                	je     801c0f <strcmp+0x1c>
  801c0b:	3a 02                	cmp    (%edx),%al
  801c0d:	74 ef                	je     801bfe <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c0f:	0f b6 c0             	movzbl %al,%eax
  801c12:	0f b6 12             	movzbl (%edx),%edx
  801c15:	29 d0                	sub    %edx,%eax
}
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	53                   	push   %ebx
  801c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c20:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c23:	89 c3                	mov    %eax,%ebx
  801c25:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c28:	eb 06                	jmp    801c30 <strncmp+0x17>
		n--, p++, q++;
  801c2a:	83 c0 01             	add    $0x1,%eax
  801c2d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c30:	39 d8                	cmp    %ebx,%eax
  801c32:	74 15                	je     801c49 <strncmp+0x30>
  801c34:	0f b6 08             	movzbl (%eax),%ecx
  801c37:	84 c9                	test   %cl,%cl
  801c39:	74 04                	je     801c3f <strncmp+0x26>
  801c3b:	3a 0a                	cmp    (%edx),%cl
  801c3d:	74 eb                	je     801c2a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3f:	0f b6 00             	movzbl (%eax),%eax
  801c42:	0f b6 12             	movzbl (%edx),%edx
  801c45:	29 d0                	sub    %edx,%eax
  801c47:	eb 05                	jmp    801c4e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c49:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c4e:	5b                   	pop    %ebx
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	8b 45 08             	mov    0x8(%ebp),%eax
  801c57:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c5b:	eb 07                	jmp    801c64 <strchr+0x13>
		if (*s == c)
  801c5d:	38 ca                	cmp    %cl,%dl
  801c5f:	74 0f                	je     801c70 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c61:	83 c0 01             	add    $0x1,%eax
  801c64:	0f b6 10             	movzbl (%eax),%edx
  801c67:	84 d2                	test   %dl,%dl
  801c69:	75 f2                	jne    801c5d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    

00801c72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	8b 45 08             	mov    0x8(%ebp),%eax
  801c78:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c7c:	eb 03                	jmp    801c81 <strfind+0xf>
  801c7e:	83 c0 01             	add    $0x1,%eax
  801c81:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c84:	38 ca                	cmp    %cl,%dl
  801c86:	74 04                	je     801c8c <strfind+0x1a>
  801c88:	84 d2                	test   %dl,%dl
  801c8a:	75 f2                	jne    801c7e <strfind+0xc>
			break;
	return (char *) s;
}
  801c8c:	5d                   	pop    %ebp
  801c8d:	c3                   	ret    

00801c8e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c97:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c9a:	85 c9                	test   %ecx,%ecx
  801c9c:	74 36                	je     801cd4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ca4:	75 28                	jne    801cce <memset+0x40>
  801ca6:	f6 c1 03             	test   $0x3,%cl
  801ca9:	75 23                	jne    801cce <memset+0x40>
		c &= 0xFF;
  801cab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801caf:	89 d3                	mov    %edx,%ebx
  801cb1:	c1 e3 08             	shl    $0x8,%ebx
  801cb4:	89 d6                	mov    %edx,%esi
  801cb6:	c1 e6 18             	shl    $0x18,%esi
  801cb9:	89 d0                	mov    %edx,%eax
  801cbb:	c1 e0 10             	shl    $0x10,%eax
  801cbe:	09 f0                	or     %esi,%eax
  801cc0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cc2:	89 d8                	mov    %ebx,%eax
  801cc4:	09 d0                	or     %edx,%eax
  801cc6:	c1 e9 02             	shr    $0x2,%ecx
  801cc9:	fc                   	cld    
  801cca:	f3 ab                	rep stos %eax,%es:(%edi)
  801ccc:	eb 06                	jmp    801cd4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd1:	fc                   	cld    
  801cd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cd4:	89 f8                	mov    %edi,%eax
  801cd6:	5b                   	pop    %ebx
  801cd7:	5e                   	pop    %esi
  801cd8:	5f                   	pop    %edi
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	57                   	push   %edi
  801cdf:	56                   	push   %esi
  801ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce9:	39 c6                	cmp    %eax,%esi
  801ceb:	73 35                	jae    801d22 <memmove+0x47>
  801ced:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf0:	39 d0                	cmp    %edx,%eax
  801cf2:	73 2e                	jae    801d22 <memmove+0x47>
		s += n;
		d += n;
  801cf4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf7:	89 d6                	mov    %edx,%esi
  801cf9:	09 fe                	or     %edi,%esi
  801cfb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d01:	75 13                	jne    801d16 <memmove+0x3b>
  801d03:	f6 c1 03             	test   $0x3,%cl
  801d06:	75 0e                	jne    801d16 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d08:	83 ef 04             	sub    $0x4,%edi
  801d0b:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d0e:	c1 e9 02             	shr    $0x2,%ecx
  801d11:	fd                   	std    
  801d12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d14:	eb 09                	jmp    801d1f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d16:	83 ef 01             	sub    $0x1,%edi
  801d19:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d1c:	fd                   	std    
  801d1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d1f:	fc                   	cld    
  801d20:	eb 1d                	jmp    801d3f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	09 c2                	or     %eax,%edx
  801d26:	f6 c2 03             	test   $0x3,%dl
  801d29:	75 0f                	jne    801d3a <memmove+0x5f>
  801d2b:	f6 c1 03             	test   $0x3,%cl
  801d2e:	75 0a                	jne    801d3a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d30:	c1 e9 02             	shr    $0x2,%ecx
  801d33:	89 c7                	mov    %eax,%edi
  801d35:	fc                   	cld    
  801d36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d38:	eb 05                	jmp    801d3f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d3a:	89 c7                	mov    %eax,%edi
  801d3c:	fc                   	cld    
  801d3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d46:	ff 75 10             	pushl  0x10(%ebp)
  801d49:	ff 75 0c             	pushl  0xc(%ebp)
  801d4c:	ff 75 08             	pushl  0x8(%ebp)
  801d4f:	e8 87 ff ff ff       	call   801cdb <memmove>
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	56                   	push   %esi
  801d5a:	53                   	push   %ebx
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d61:	89 c6                	mov    %eax,%esi
  801d63:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d66:	eb 1a                	jmp    801d82 <memcmp+0x2c>
		if (*s1 != *s2)
  801d68:	0f b6 08             	movzbl (%eax),%ecx
  801d6b:	0f b6 1a             	movzbl (%edx),%ebx
  801d6e:	38 d9                	cmp    %bl,%cl
  801d70:	74 0a                	je     801d7c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d72:	0f b6 c1             	movzbl %cl,%eax
  801d75:	0f b6 db             	movzbl %bl,%ebx
  801d78:	29 d8                	sub    %ebx,%eax
  801d7a:	eb 0f                	jmp    801d8b <memcmp+0x35>
		s1++, s2++;
  801d7c:	83 c0 01             	add    $0x1,%eax
  801d7f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d82:	39 f0                	cmp    %esi,%eax
  801d84:	75 e2                	jne    801d68 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d8b:	5b                   	pop    %ebx
  801d8c:	5e                   	pop    %esi
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    

00801d8f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	53                   	push   %ebx
  801d93:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d96:	89 c1                	mov    %eax,%ecx
  801d98:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d9f:	eb 0a                	jmp    801dab <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801da1:	0f b6 10             	movzbl (%eax),%edx
  801da4:	39 da                	cmp    %ebx,%edx
  801da6:	74 07                	je     801daf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da8:	83 c0 01             	add    $0x1,%eax
  801dab:	39 c8                	cmp    %ecx,%eax
  801dad:	72 f2                	jb     801da1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801daf:	5b                   	pop    %ebx
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    

00801db2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	57                   	push   %edi
  801db6:	56                   	push   %esi
  801db7:	53                   	push   %ebx
  801db8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dbe:	eb 03                	jmp    801dc3 <strtol+0x11>
		s++;
  801dc0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc3:	0f b6 01             	movzbl (%ecx),%eax
  801dc6:	3c 20                	cmp    $0x20,%al
  801dc8:	74 f6                	je     801dc0 <strtol+0xe>
  801dca:	3c 09                	cmp    $0x9,%al
  801dcc:	74 f2                	je     801dc0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dce:	3c 2b                	cmp    $0x2b,%al
  801dd0:	75 0a                	jne    801ddc <strtol+0x2a>
		s++;
  801dd2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dd5:	bf 00 00 00 00       	mov    $0x0,%edi
  801dda:	eb 11                	jmp    801ded <strtol+0x3b>
  801ddc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801de1:	3c 2d                	cmp    $0x2d,%al
  801de3:	75 08                	jne    801ded <strtol+0x3b>
		s++, neg = 1;
  801de5:	83 c1 01             	add    $0x1,%ecx
  801de8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ded:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801df3:	75 15                	jne    801e0a <strtol+0x58>
  801df5:	80 39 30             	cmpb   $0x30,(%ecx)
  801df8:	75 10                	jne    801e0a <strtol+0x58>
  801dfa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dfe:	75 7c                	jne    801e7c <strtol+0xca>
		s += 2, base = 16;
  801e00:	83 c1 02             	add    $0x2,%ecx
  801e03:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e08:	eb 16                	jmp    801e20 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e0a:	85 db                	test   %ebx,%ebx
  801e0c:	75 12                	jne    801e20 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e0e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e13:	80 39 30             	cmpb   $0x30,(%ecx)
  801e16:	75 08                	jne    801e20 <strtol+0x6e>
		s++, base = 8;
  801e18:	83 c1 01             	add    $0x1,%ecx
  801e1b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e20:	b8 00 00 00 00       	mov    $0x0,%eax
  801e25:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e28:	0f b6 11             	movzbl (%ecx),%edx
  801e2b:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e2e:	89 f3                	mov    %esi,%ebx
  801e30:	80 fb 09             	cmp    $0x9,%bl
  801e33:	77 08                	ja     801e3d <strtol+0x8b>
			dig = *s - '0';
  801e35:	0f be d2             	movsbl %dl,%edx
  801e38:	83 ea 30             	sub    $0x30,%edx
  801e3b:	eb 22                	jmp    801e5f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e3d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e40:	89 f3                	mov    %esi,%ebx
  801e42:	80 fb 19             	cmp    $0x19,%bl
  801e45:	77 08                	ja     801e4f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e47:	0f be d2             	movsbl %dl,%edx
  801e4a:	83 ea 57             	sub    $0x57,%edx
  801e4d:	eb 10                	jmp    801e5f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e4f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e52:	89 f3                	mov    %esi,%ebx
  801e54:	80 fb 19             	cmp    $0x19,%bl
  801e57:	77 16                	ja     801e6f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e59:	0f be d2             	movsbl %dl,%edx
  801e5c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e5f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e62:	7d 0b                	jge    801e6f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e64:	83 c1 01             	add    $0x1,%ecx
  801e67:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e6b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e6d:	eb b9                	jmp    801e28 <strtol+0x76>

	if (endptr)
  801e6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e73:	74 0d                	je     801e82 <strtol+0xd0>
		*endptr = (char *) s;
  801e75:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e78:	89 0e                	mov    %ecx,(%esi)
  801e7a:	eb 06                	jmp    801e82 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e7c:	85 db                	test   %ebx,%ebx
  801e7e:	74 98                	je     801e18 <strtol+0x66>
  801e80:	eb 9e                	jmp    801e20 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e82:	89 c2                	mov    %eax,%edx
  801e84:	f7 da                	neg    %edx
  801e86:	85 ff                	test   %edi,%edi
  801e88:	0f 45 c2             	cmovne %edx,%eax
}
  801e8b:	5b                   	pop    %ebx
  801e8c:	5e                   	pop    %esi
  801e8d:	5f                   	pop    %edi
  801e8e:	5d                   	pop    %ebp
  801e8f:	c3                   	ret    

00801e90 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	56                   	push   %esi
  801e94:	53                   	push   %ebx
  801e95:	8b 75 08             	mov    0x8(%ebp),%esi
  801e98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	74 0e                	je     801eb0 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801ea2:	83 ec 0c             	sub    $0xc,%esp
  801ea5:	50                   	push   %eax
  801ea6:	e8 63 e4 ff ff       	call   80030e <sys_ipc_recv>
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	eb 10                	jmp    801ec0 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801eb0:	83 ec 0c             	sub    $0xc,%esp
  801eb3:	68 00 00 c0 ee       	push   $0xeec00000
  801eb8:	e8 51 e4 ff ff       	call   80030e <sys_ipc_recv>
  801ebd:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	79 17                	jns    801edb <ipc_recv+0x4b>
		if(*from_env_store)
  801ec4:	83 3e 00             	cmpl   $0x0,(%esi)
  801ec7:	74 06                	je     801ecf <ipc_recv+0x3f>
			*from_env_store = 0;
  801ec9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801ecf:	85 db                	test   %ebx,%ebx
  801ed1:	74 2c                	je     801eff <ipc_recv+0x6f>
			*perm_store = 0;
  801ed3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ed9:	eb 24                	jmp    801eff <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801edb:	85 f6                	test   %esi,%esi
  801edd:	74 0a                	je     801ee9 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801edf:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee4:	8b 40 74             	mov    0x74(%eax),%eax
  801ee7:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801ee9:	85 db                	test   %ebx,%ebx
  801eeb:	74 0a                	je     801ef7 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801eed:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef2:	8b 40 78             	mov    0x78(%eax),%eax
  801ef5:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ef7:	a1 08 40 80 00       	mov    0x804008,%eax
  801efc:	8b 40 70             	mov    0x70(%eax),%eax
}
  801eff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f02:	5b                   	pop    %ebx
  801f03:	5e                   	pop    %esi
  801f04:	5d                   	pop    %ebp
  801f05:	c3                   	ret    

00801f06 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	57                   	push   %edi
  801f0a:	56                   	push   %esi
  801f0b:	53                   	push   %ebx
  801f0c:	83 ec 0c             	sub    $0xc,%esp
  801f0f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f12:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f18:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f1a:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f1f:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f22:	e8 18 e2 ff ff       	call   80013f <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f27:	ff 75 14             	pushl  0x14(%ebp)
  801f2a:	53                   	push   %ebx
  801f2b:	56                   	push   %esi
  801f2c:	57                   	push   %edi
  801f2d:	e8 b9 e3 ff ff       	call   8002eb <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f32:	89 c2                	mov    %eax,%edx
  801f34:	f7 d2                	not    %edx
  801f36:	c1 ea 1f             	shr    $0x1f,%edx
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f3f:	0f 94 c1             	sete   %cl
  801f42:	09 ca                	or     %ecx,%edx
  801f44:	85 c0                	test   %eax,%eax
  801f46:	0f 94 c0             	sete   %al
  801f49:	38 c2                	cmp    %al,%dl
  801f4b:	77 d5                	ja     801f22 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801f4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f50:	5b                   	pop    %ebx
  801f51:	5e                   	pop    %esi
  801f52:	5f                   	pop    %edi
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f5b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f60:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f63:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f69:	8b 52 50             	mov    0x50(%edx),%edx
  801f6c:	39 ca                	cmp    %ecx,%edx
  801f6e:	75 0d                	jne    801f7d <ipc_find_env+0x28>
			return envs[i].env_id;
  801f70:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f73:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f78:	8b 40 48             	mov    0x48(%eax),%eax
  801f7b:	eb 0f                	jmp    801f8c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7d:	83 c0 01             	add    $0x1,%eax
  801f80:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f85:	75 d9                	jne    801f60 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    

00801f8e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f94:	89 d0                	mov    %edx,%eax
  801f96:	c1 e8 16             	shr    $0x16,%eax
  801f99:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa5:	f6 c1 01             	test   $0x1,%cl
  801fa8:	74 1d                	je     801fc7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801faa:	c1 ea 0c             	shr    $0xc,%edx
  801fad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb4:	f6 c2 01             	test   $0x1,%dl
  801fb7:	74 0e                	je     801fc7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb9:	c1 ea 0c             	shr    $0xc,%edx
  801fbc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc3:	ef 
  801fc4:	0f b7 c0             	movzwl %ax,%eax
}
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    
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
