
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 a6 04 00 00       	call   80055c <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 8a 22 80 00       	push   $0x80228a
  80012f:	6a 23                	push   $0x23
  800131:	68 a7 22 80 00       	push   $0x8022a7
  800136:	e8 b3 13 00 00       	call   8014ee <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 8a 22 80 00       	push   $0x80228a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 a7 22 80 00       	push   $0x8022a7
  8001b7:	e8 32 13 00 00       	call   8014ee <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 8a 22 80 00       	push   $0x80228a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 a7 22 80 00       	push   $0x8022a7
  8001f9:	e8 f0 12 00 00       	call   8014ee <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 8a 22 80 00       	push   $0x80228a
  800234:	6a 23                	push   $0x23
  800236:	68 a7 22 80 00       	push   $0x8022a7
  80023b:	e8 ae 12 00 00       	call   8014ee <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 8a 22 80 00       	push   $0x80228a
  800276:	6a 23                	push   $0x23
  800278:	68 a7 22 80 00       	push   $0x8022a7
  80027d:	e8 6c 12 00 00       	call   8014ee <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 8a 22 80 00       	push   $0x80228a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 a7 22 80 00       	push   $0x8022a7
  8002bf:	e8 2a 12 00 00       	call   8014ee <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 8a 22 80 00       	push   $0x80228a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 a7 22 80 00       	push   $0x8022a7
  800301:	e8 e8 11 00 00       	call   8014ee <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 8a 22 80 00       	push   $0x80228a
  80035e:	6a 23                	push   $0x23
  800360:	68 a7 22 80 00       	push   $0x8022a7
  800365:	e8 84 11 00 00       	call   8014ee <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800382:	89 d1                	mov    %edx,%ecx
  800384:	89 d3                	mov    %edx,%ebx
  800386:	89 d7                	mov    %edx,%edi
  800388:	89 d6                	mov    %edx,%esi
  80038a:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
  800397:	05 00 00 00 30       	add    $0x30000000,%eax
  80039c:	c1 e8 0c             	shr    $0xc,%eax
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a7:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c3:	89 c2                	mov    %eax,%edx
  8003c5:	c1 ea 16             	shr    $0x16,%edx
  8003c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003cf:	f6 c2 01             	test   $0x1,%dl
  8003d2:	74 11                	je     8003e5 <fd_alloc+0x2d>
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 0c             	shr    $0xc,%edx
  8003d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	75 09                	jne    8003ee <fd_alloc+0x36>
			*fd_store = fd;
  8003e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ec:	eb 17                	jmp    800405 <fd_alloc+0x4d>
  8003ee:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f8:	75 c9                	jne    8003c3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003fa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800400:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040d:	83 f8 1f             	cmp    $0x1f,%eax
  800410:	77 36                	ja     800448 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800412:	c1 e0 0c             	shl    $0xc,%eax
  800415:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80041a:	89 c2                	mov    %eax,%edx
  80041c:	c1 ea 16             	shr    $0x16,%edx
  80041f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800426:	f6 c2 01             	test   $0x1,%dl
  800429:	74 24                	je     80044f <fd_lookup+0x48>
  80042b:	89 c2                	mov    %eax,%edx
  80042d:	c1 ea 0c             	shr    $0xc,%edx
  800430:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800437:	f6 c2 01             	test   $0x1,%dl
  80043a:	74 1a                	je     800456 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80043c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043f:	89 02                	mov    %eax,(%edx)
	return 0;
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	eb 13                	jmp    80045b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800448:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044d:	eb 0c                	jmp    80045b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800454:	eb 05                	jmp    80045b <fd_lookup+0x54>
  800456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    

0080045d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800466:	ba 34 23 80 00       	mov    $0x802334,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80046b:	eb 13                	jmp    800480 <dev_lookup+0x23>
  80046d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800470:	39 08                	cmp    %ecx,(%eax)
  800472:	75 0c                	jne    800480 <dev_lookup+0x23>
			*dev = devtab[i];
  800474:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800477:	89 01                	mov    %eax,(%ecx)
			return 0;
  800479:	b8 00 00 00 00       	mov    $0x0,%eax
  80047e:	eb 2e                	jmp    8004ae <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800480:	8b 02                	mov    (%edx),%eax
  800482:	85 c0                	test   %eax,%eax
  800484:	75 e7                	jne    80046d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800486:	a1 08 40 80 00       	mov    0x804008,%eax
  80048b:	8b 40 48             	mov    0x48(%eax),%eax
  80048e:	83 ec 04             	sub    $0x4,%esp
  800491:	51                   	push   %ecx
  800492:	50                   	push   %eax
  800493:	68 b8 22 80 00       	push   $0x8022b8
  800498:	e8 2a 11 00 00       	call   8015c7 <cprintf>
	*dev = 0;
  80049d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ae:	c9                   	leave  
  8004af:	c3                   	ret    

008004b0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	56                   	push   %esi
  8004b4:	53                   	push   %ebx
  8004b5:	83 ec 10             	sub    $0x10,%esp
  8004b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c1:	50                   	push   %eax
  8004c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c8:	c1 e8 0c             	shr    $0xc,%eax
  8004cb:	50                   	push   %eax
  8004cc:	e8 36 ff ff ff       	call   800407 <fd_lookup>
  8004d1:	83 c4 08             	add    $0x8,%esp
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	78 05                	js     8004dd <fd_close+0x2d>
	    || fd != fd2)
  8004d8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004db:	74 0c                	je     8004e9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004dd:	84 db                	test   %bl,%bl
  8004df:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e4:	0f 44 c2             	cmove  %edx,%eax
  8004e7:	eb 41                	jmp    80052a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 36                	pushl  (%esi)
  8004f2:	e8 66 ff ff ff       	call   80045d <dev_lookup>
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 1a                	js     80051a <fd_close+0x6a>
		if (dev->dev_close)
  800500:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800503:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800506:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80050b:	85 c0                	test   %eax,%eax
  80050d:	74 0b                	je     80051a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80050f:	83 ec 0c             	sub    $0xc,%esp
  800512:	56                   	push   %esi
  800513:	ff d0                	call   *%eax
  800515:	89 c3                	mov    %eax,%ebx
  800517:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	56                   	push   %esi
  80051e:	6a 00                	push   $0x0
  800520:	e8 e1 fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	89 d8                	mov    %ebx,%eax
}
  80052a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052d:	5b                   	pop    %ebx
  80052e:	5e                   	pop    %esi
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    

00800531 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800537:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053a:	50                   	push   %eax
  80053b:	ff 75 08             	pushl  0x8(%ebp)
  80053e:	e8 c4 fe ff ff       	call   800407 <fd_lookup>
  800543:	83 c4 08             	add    $0x8,%esp
  800546:	85 c0                	test   %eax,%eax
  800548:	78 10                	js     80055a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	6a 01                	push   $0x1
  80054f:	ff 75 f4             	pushl  -0xc(%ebp)
  800552:	e8 59 ff ff ff       	call   8004b0 <fd_close>
  800557:	83 c4 10             	add    $0x10,%esp
}
  80055a:	c9                   	leave  
  80055b:	c3                   	ret    

0080055c <close_all>:

void
close_all(void)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	53                   	push   %ebx
  800560:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800563:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800568:	83 ec 0c             	sub    $0xc,%esp
  80056b:	53                   	push   %ebx
  80056c:	e8 c0 ff ff ff       	call   800531 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800571:	83 c3 01             	add    $0x1,%ebx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	83 fb 20             	cmp    $0x20,%ebx
  80057a:	75 ec                	jne    800568 <close_all+0xc>
		close(i);
}
  80057c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80057f:	c9                   	leave  
  800580:	c3                   	ret    

00800581 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	57                   	push   %edi
  800585:	56                   	push   %esi
  800586:	53                   	push   %ebx
  800587:	83 ec 2c             	sub    $0x2c,%esp
  80058a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800590:	50                   	push   %eax
  800591:	ff 75 08             	pushl  0x8(%ebp)
  800594:	e8 6e fe ff ff       	call   800407 <fd_lookup>
  800599:	83 c4 08             	add    $0x8,%esp
  80059c:	85 c0                	test   %eax,%eax
  80059e:	0f 88 c1 00 00 00    	js     800665 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	56                   	push   %esi
  8005a8:	e8 84 ff ff ff       	call   800531 <close>

	newfd = INDEX2FD(newfdnum);
  8005ad:	89 f3                	mov    %esi,%ebx
  8005af:	c1 e3 0c             	shl    $0xc,%ebx
  8005b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b8:	83 c4 04             	add    $0x4,%esp
  8005bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005be:	e8 de fd ff ff       	call   8003a1 <fd2data>
  8005c3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c5:	89 1c 24             	mov    %ebx,(%esp)
  8005c8:	e8 d4 fd ff ff       	call   8003a1 <fd2data>
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d3:	89 f8                	mov    %edi,%eax
  8005d5:	c1 e8 16             	shr    $0x16,%eax
  8005d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005df:	a8 01                	test   $0x1,%al
  8005e1:	74 37                	je     80061a <dup+0x99>
  8005e3:	89 f8                	mov    %edi,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ef:	f6 c2 01             	test   $0x1,%dl
  8005f2:	74 26                	je     80061a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fb:	83 ec 0c             	sub    $0xc,%esp
  8005fe:	25 07 0e 00 00       	and    $0xe07,%eax
  800603:	50                   	push   %eax
  800604:	ff 75 d4             	pushl  -0x2c(%ebp)
  800607:	6a 00                	push   $0x0
  800609:	57                   	push   %edi
  80060a:	6a 00                	push   $0x0
  80060c:	e8 b3 fb ff ff       	call   8001c4 <sys_page_map>
  800611:	89 c7                	mov    %eax,%edi
  800613:	83 c4 20             	add    $0x20,%esp
  800616:	85 c0                	test   %eax,%eax
  800618:	78 2e                	js     800648 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061d:	89 d0                	mov    %edx,%eax
  80061f:	c1 e8 0c             	shr    $0xc,%eax
  800622:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800629:	83 ec 0c             	sub    $0xc,%esp
  80062c:	25 07 0e 00 00       	and    $0xe07,%eax
  800631:	50                   	push   %eax
  800632:	53                   	push   %ebx
  800633:	6a 00                	push   $0x0
  800635:	52                   	push   %edx
  800636:	6a 00                	push   $0x0
  800638:	e8 87 fb ff ff       	call   8001c4 <sys_page_map>
  80063d:	89 c7                	mov    %eax,%edi
  80063f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800642:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800644:	85 ff                	test   %edi,%edi
  800646:	79 1d                	jns    800665 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 00                	push   $0x0
  80064e:	e8 b3 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800653:	83 c4 08             	add    $0x8,%esp
  800656:	ff 75 d4             	pushl  -0x2c(%ebp)
  800659:	6a 00                	push   $0x0
  80065b:	e8 a6 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	89 f8                	mov    %edi,%eax
}
  800665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800668:	5b                   	pop    %ebx
  800669:	5e                   	pop    %esi
  80066a:	5f                   	pop    %edi
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    

0080066d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	53                   	push   %ebx
  800671:	83 ec 14             	sub    $0x14,%esp
  800674:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800677:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	53                   	push   %ebx
  80067c:	e8 86 fd ff ff       	call   800407 <fd_lookup>
  800681:	83 c4 08             	add    $0x8,%esp
  800684:	89 c2                	mov    %eax,%edx
  800686:	85 c0                	test   %eax,%eax
  800688:	78 6d                	js     8006f7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800690:	50                   	push   %eax
  800691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800694:	ff 30                	pushl  (%eax)
  800696:	e8 c2 fd ff ff       	call   80045d <dev_lookup>
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	78 4c                	js     8006ee <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a5:	8b 42 08             	mov    0x8(%edx),%eax
  8006a8:	83 e0 03             	and    $0x3,%eax
  8006ab:	83 f8 01             	cmp    $0x1,%eax
  8006ae:	75 21                	jne    8006d1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b0:	a1 08 40 80 00       	mov    0x804008,%eax
  8006b5:	8b 40 48             	mov    0x48(%eax),%eax
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	50                   	push   %eax
  8006bd:	68 f9 22 80 00       	push   $0x8022f9
  8006c2:	e8 00 0f 00 00       	call   8015c7 <cprintf>
		return -E_INVAL;
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006cf:	eb 26                	jmp    8006f7 <read+0x8a>
	}
	if (!dev->dev_read)
  8006d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d4:	8b 40 08             	mov    0x8(%eax),%eax
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	74 17                	je     8006f2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006db:	83 ec 04             	sub    $0x4,%esp
  8006de:	ff 75 10             	pushl  0x10(%ebp)
  8006e1:	ff 75 0c             	pushl  0xc(%ebp)
  8006e4:	52                   	push   %edx
  8006e5:	ff d0                	call   *%eax
  8006e7:	89 c2                	mov    %eax,%edx
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	eb 09                	jmp    8006f7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ee:	89 c2                	mov    %eax,%edx
  8006f0:	eb 05                	jmp    8006f7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006f7:	89 d0                	mov    %edx,%eax
  8006f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	57                   	push   %edi
  800702:	56                   	push   %esi
  800703:	53                   	push   %ebx
  800704:	83 ec 0c             	sub    $0xc,%esp
  800707:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800712:	eb 21                	jmp    800735 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800714:	83 ec 04             	sub    $0x4,%esp
  800717:	89 f0                	mov    %esi,%eax
  800719:	29 d8                	sub    %ebx,%eax
  80071b:	50                   	push   %eax
  80071c:	89 d8                	mov    %ebx,%eax
  80071e:	03 45 0c             	add    0xc(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	57                   	push   %edi
  800723:	e8 45 ff ff ff       	call   80066d <read>
		if (m < 0)
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	85 c0                	test   %eax,%eax
  80072d:	78 10                	js     80073f <readn+0x41>
			return m;
		if (m == 0)
  80072f:	85 c0                	test   %eax,%eax
  800731:	74 0a                	je     80073d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800733:	01 c3                	add    %eax,%ebx
  800735:	39 f3                	cmp    %esi,%ebx
  800737:	72 db                	jb     800714 <readn+0x16>
  800739:	89 d8                	mov    %ebx,%eax
  80073b:	eb 02                	jmp    80073f <readn+0x41>
  80073d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	83 ec 14             	sub    $0x14,%esp
  80074e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800751:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800754:	50                   	push   %eax
  800755:	53                   	push   %ebx
  800756:	e8 ac fc ff ff       	call   800407 <fd_lookup>
  80075b:	83 c4 08             	add    $0x8,%esp
  80075e:	89 c2                	mov    %eax,%edx
  800760:	85 c0                	test   %eax,%eax
  800762:	78 68                	js     8007cc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076e:	ff 30                	pushl  (%eax)
  800770:	e8 e8 fc ff ff       	call   80045d <dev_lookup>
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	85 c0                	test   %eax,%eax
  80077a:	78 47                	js     8007c3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800783:	75 21                	jne    8007a6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800785:	a1 08 40 80 00       	mov    0x804008,%eax
  80078a:	8b 40 48             	mov    0x48(%eax),%eax
  80078d:	83 ec 04             	sub    $0x4,%esp
  800790:	53                   	push   %ebx
  800791:	50                   	push   %eax
  800792:	68 15 23 80 00       	push   $0x802315
  800797:	e8 2b 0e 00 00       	call   8015c7 <cprintf>
		return -E_INVAL;
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a4:	eb 26                	jmp    8007cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 17                	je     8007c7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b0:	83 ec 04             	sub    $0x4,%esp
  8007b3:	ff 75 10             	pushl  0x10(%ebp)
  8007b6:	ff 75 0c             	pushl  0xc(%ebp)
  8007b9:	50                   	push   %eax
  8007ba:	ff d2                	call   *%edx
  8007bc:	89 c2                	mov    %eax,%edx
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb 09                	jmp    8007cc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	eb 05                	jmp    8007cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007cc:	89 d0                	mov    %edx,%eax
  8007ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007dc:	50                   	push   %eax
  8007dd:	ff 75 08             	pushl  0x8(%ebp)
  8007e0:	e8 22 fc ff ff       	call   800407 <fd_lookup>
  8007e5:	83 c4 08             	add    $0x8,%esp
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	78 0e                	js     8007fa <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	83 ec 14             	sub    $0x14,%esp
  800803:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800806:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800809:	50                   	push   %eax
  80080a:	53                   	push   %ebx
  80080b:	e8 f7 fb ff ff       	call   800407 <fd_lookup>
  800810:	83 c4 08             	add    $0x8,%esp
  800813:	89 c2                	mov    %eax,%edx
  800815:	85 c0                	test   %eax,%eax
  800817:	78 65                	js     80087e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800823:	ff 30                	pushl  (%eax)
  800825:	e8 33 fc ff ff       	call   80045d <dev_lookup>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	85 c0                	test   %eax,%eax
  80082f:	78 44                	js     800875 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800834:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800838:	75 21                	jne    80085b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083f:	8b 40 48             	mov    0x48(%eax),%eax
  800842:	83 ec 04             	sub    $0x4,%esp
  800845:	53                   	push   %ebx
  800846:	50                   	push   %eax
  800847:	68 d8 22 80 00       	push   $0x8022d8
  80084c:	e8 76 0d 00 00       	call   8015c7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800859:	eb 23                	jmp    80087e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80085b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085e:	8b 52 18             	mov    0x18(%edx),%edx
  800861:	85 d2                	test   %edx,%edx
  800863:	74 14                	je     800879 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	ff 75 0c             	pushl  0xc(%ebp)
  80086b:	50                   	push   %eax
  80086c:	ff d2                	call   *%edx
  80086e:	89 c2                	mov    %eax,%edx
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	eb 09                	jmp    80087e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800875:	89 c2                	mov    %eax,%edx
  800877:	eb 05                	jmp    80087e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800879:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80087e:	89 d0                	mov    %edx,%eax
  800880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	83 ec 14             	sub    $0x14,%esp
  80088c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800892:	50                   	push   %eax
  800893:	ff 75 08             	pushl  0x8(%ebp)
  800896:	e8 6c fb ff ff       	call   800407 <fd_lookup>
  80089b:	83 c4 08             	add    $0x8,%esp
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	85 c0                	test   %eax,%eax
  8008a2:	78 58                	js     8008fc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ae:	ff 30                	pushl  (%eax)
  8008b0:	e8 a8 fb ff ff       	call   80045d <dev_lookup>
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	85 c0                	test   %eax,%eax
  8008ba:	78 37                	js     8008f3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c3:	74 32                	je     8008f7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008cf:	00 00 00 
	stat->st_isdir = 0;
  8008d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d9:	00 00 00 
	stat->st_dev = dev;
  8008dc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e2:	83 ec 08             	sub    $0x8,%esp
  8008e5:	53                   	push   %ebx
  8008e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e9:	ff 50 14             	call   *0x14(%eax)
  8008ec:	89 c2                	mov    %eax,%edx
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	eb 09                	jmp    8008fc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f3:	89 c2                	mov    %eax,%edx
  8008f5:	eb 05                	jmp    8008fc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008fc:	89 d0                	mov    %edx,%eax
  8008fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	6a 00                	push   $0x0
  80090d:	ff 75 08             	pushl  0x8(%ebp)
  800910:	e8 ef 01 00 00       	call   800b04 <open>
  800915:	89 c3                	mov    %eax,%ebx
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 1b                	js     800939 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	ff 75 0c             	pushl  0xc(%ebp)
  800924:	50                   	push   %eax
  800925:	e8 5b ff ff ff       	call   800885 <fstat>
  80092a:	89 c6                	mov    %eax,%esi
	close(fd);
  80092c:	89 1c 24             	mov    %ebx,(%esp)
  80092f:	e8 fd fb ff ff       	call   800531 <close>
	return r;
  800934:	83 c4 10             	add    $0x10,%esp
  800937:	89 f0                	mov    %esi,%eax
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	89 c6                	mov    %eax,%esi
  800947:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800949:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800950:	75 12                	jne    800964 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800952:	83 ec 0c             	sub    $0xc,%esp
  800955:	6a 01                	push   $0x1
  800957:	e8 1c 16 00 00       	call   801f78 <ipc_find_env>
  80095c:	a3 00 40 80 00       	mov    %eax,0x804000
  800961:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800964:	6a 07                	push   $0x7
  800966:	68 00 50 80 00       	push   $0x805000
  80096b:	56                   	push   %esi
  80096c:	ff 35 00 40 80 00    	pushl  0x804000
  800972:	e8 b2 15 00 00       	call   801f29 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800977:	83 c4 0c             	add    $0xc,%esp
  80097a:	6a 00                	push   $0x0
  80097c:	53                   	push   %ebx
  80097d:	6a 00                	push   $0x0
  80097f:	e8 2f 15 00 00       	call   801eb3 <ipc_recv>
}
  800984:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 40 0c             	mov    0xc(%eax),%eax
  800997:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ae:	e8 8d ff ff ff       	call   800940 <fsipc>
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d0:	e8 6b ff ff ff       	call   800940 <fsipc>
}
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	83 ec 04             	sub    $0x4,%esp
  8009de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f6:	e8 45 ff ff ff       	call   800940 <fsipc>
  8009fb:	85 c0                	test   %eax,%eax
  8009fd:	78 2c                	js     800a2b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ff:	83 ec 08             	sub    $0x8,%esp
  800a02:	68 00 50 80 00       	push   $0x805000
  800a07:	53                   	push   %ebx
  800a08:	e8 5f 11 00 00       	call   801b6c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0d:	a1 80 50 80 00       	mov    0x805080,%eax
  800a12:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a18:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a23:	83 c4 10             	add    $0x10,%esp
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	83 ec 08             	sub    $0x8,%esp
  800a37:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3d:	8b 52 0c             	mov    0xc(%edx),%edx
  800a40:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a46:	a3 04 50 80 00       	mov    %eax,0x805004
  800a4b:	3d 08 50 80 00       	cmp    $0x805008,%eax
  800a50:	bb 08 50 80 00       	mov    $0x805008,%ebx
  800a55:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a58:	53                   	push   %ebx
  800a59:	ff 75 0c             	pushl  0xc(%ebp)
  800a5c:	68 08 50 80 00       	push   $0x805008
  800a61:	e8 98 12 00 00       	call   801cfe <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a66:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a70:	e8 cb fe ff ff       	call   800940 <fsipc>
  800a75:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  800a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a90:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a95:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa5:	e8 96 fe ff ff       	call   800940 <fsipc>
  800aaa:	89 c3                	mov    %eax,%ebx
  800aac:	85 c0                	test   %eax,%eax
  800aae:	78 4b                	js     800afb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ab0:	39 c6                	cmp    %eax,%esi
  800ab2:	73 16                	jae    800aca <devfile_read+0x48>
  800ab4:	68 48 23 80 00       	push   $0x802348
  800ab9:	68 4f 23 80 00       	push   $0x80234f
  800abe:	6a 7c                	push   $0x7c
  800ac0:	68 64 23 80 00       	push   $0x802364
  800ac5:	e8 24 0a 00 00       	call   8014ee <_panic>
	assert(r <= PGSIZE);
  800aca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800acf:	7e 16                	jle    800ae7 <devfile_read+0x65>
  800ad1:	68 6f 23 80 00       	push   $0x80236f
  800ad6:	68 4f 23 80 00       	push   $0x80234f
  800adb:	6a 7d                	push   $0x7d
  800add:	68 64 23 80 00       	push   $0x802364
  800ae2:	e8 07 0a 00 00       	call   8014ee <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae7:	83 ec 04             	sub    $0x4,%esp
  800aea:	50                   	push   %eax
  800aeb:	68 00 50 80 00       	push   $0x805000
  800af0:	ff 75 0c             	pushl  0xc(%ebp)
  800af3:	e8 06 12 00 00       	call   801cfe <memmove>
	return r;
  800af8:	83 c4 10             	add    $0x10,%esp
}
  800afb:	89 d8                	mov    %ebx,%eax
  800afd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	53                   	push   %ebx
  800b08:	83 ec 20             	sub    $0x20,%esp
  800b0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b0e:	53                   	push   %ebx
  800b0f:	e8 1f 10 00 00       	call   801b33 <strlen>
  800b14:	83 c4 10             	add    $0x10,%esp
  800b17:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1c:	7f 67                	jg     800b85 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1e:	83 ec 0c             	sub    $0xc,%esp
  800b21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b24:	50                   	push   %eax
  800b25:	e8 8e f8 ff ff       	call   8003b8 <fd_alloc>
  800b2a:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	78 57                	js     800b8a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b33:	83 ec 08             	sub    $0x8,%esp
  800b36:	53                   	push   %ebx
  800b37:	68 00 50 80 00       	push   $0x805000
  800b3c:	e8 2b 10 00 00       	call   801b6c <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b44:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b49:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b51:	e8 ea fd ff ff       	call   800940 <fsipc>
  800b56:	89 c3                	mov    %eax,%ebx
  800b58:	83 c4 10             	add    $0x10,%esp
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	79 14                	jns    800b73 <open+0x6f>
		fd_close(fd, 0);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	6a 00                	push   $0x0
  800b64:	ff 75 f4             	pushl  -0xc(%ebp)
  800b67:	e8 44 f9 ff ff       	call   8004b0 <fd_close>
		return r;
  800b6c:	83 c4 10             	add    $0x10,%esp
  800b6f:	89 da                	mov    %ebx,%edx
  800b71:	eb 17                	jmp    800b8a <open+0x86>
	}

	return fd2num(fd);
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	ff 75 f4             	pushl  -0xc(%ebp)
  800b79:	e8 13 f8 ff ff       	call   800391 <fd2num>
  800b7e:	89 c2                	mov    %eax,%edx
  800b80:	83 c4 10             	add    $0x10,%esp
  800b83:	eb 05                	jmp    800b8a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b85:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b8a:	89 d0                	mov    %edx,%eax
  800b8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba1:	e8 9a fd ff ff       	call   800940 <fsipc>
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bb0:	83 ec 0c             	sub    $0xc,%esp
  800bb3:	ff 75 08             	pushl  0x8(%ebp)
  800bb6:	e8 e6 f7 ff ff       	call   8003a1 <fd2data>
  800bbb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bbd:	83 c4 08             	add    $0x8,%esp
  800bc0:	68 7b 23 80 00       	push   $0x80237b
  800bc5:	53                   	push   %ebx
  800bc6:	e8 a1 0f 00 00       	call   801b6c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bcb:	8b 46 04             	mov    0x4(%esi),%eax
  800bce:	2b 06                	sub    (%esi),%eax
  800bd0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bdd:	00 00 00 
	stat->st_dev = &devpipe;
  800be0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be7:	30 80 00 
	return 0;
}
  800bea:	b8 00 00 00 00       	mov    $0x0,%eax
  800bef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c00:	53                   	push   %ebx
  800c01:	6a 00                	push   $0x0
  800c03:	e8 fe f5 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c08:	89 1c 24             	mov    %ebx,(%esp)
  800c0b:	e8 91 f7 ff ff       	call   8003a1 <fd2data>
  800c10:	83 c4 08             	add    $0x8,%esp
  800c13:	50                   	push   %eax
  800c14:	6a 00                	push   $0x0
  800c16:	e8 eb f5 ff ff       	call   800206 <sys_page_unmap>
}
  800c1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 1c             	sub    $0x1c,%esp
  800c29:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c2e:	a1 08 40 80 00       	mov    0x804008,%eax
  800c33:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3c:	e8 70 13 00 00       	call   801fb1 <pageref>
  800c41:	89 c3                	mov    %eax,%ebx
  800c43:	89 3c 24             	mov    %edi,(%esp)
  800c46:	e8 66 13 00 00       	call   801fb1 <pageref>
  800c4b:	83 c4 10             	add    $0x10,%esp
  800c4e:	39 c3                	cmp    %eax,%ebx
  800c50:	0f 94 c1             	sete   %cl
  800c53:	0f b6 c9             	movzbl %cl,%ecx
  800c56:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c59:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c5f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c62:	39 ce                	cmp    %ecx,%esi
  800c64:	74 1b                	je     800c81 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c66:	39 c3                	cmp    %eax,%ebx
  800c68:	75 c4                	jne    800c2e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c6a:	8b 42 58             	mov    0x58(%edx),%eax
  800c6d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c70:	50                   	push   %eax
  800c71:	56                   	push   %esi
  800c72:	68 82 23 80 00       	push   $0x802382
  800c77:	e8 4b 09 00 00       	call   8015c7 <cprintf>
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	eb ad                	jmp    800c2e <_pipeisclosed+0xe>
	}
}
  800c81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 28             	sub    $0x28,%esp
  800c95:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c98:	56                   	push   %esi
  800c99:	e8 03 f7 ff ff       	call   8003a1 <fd2data>
  800c9e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca0:	83 c4 10             	add    $0x10,%esp
  800ca3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca8:	eb 4b                	jmp    800cf5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800caa:	89 da                	mov    %ebx,%edx
  800cac:	89 f0                	mov    %esi,%eax
  800cae:	e8 6d ff ff ff       	call   800c20 <_pipeisclosed>
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	75 48                	jne    800cff <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cb7:	e8 a6 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cbc:	8b 43 04             	mov    0x4(%ebx),%eax
  800cbf:	8b 0b                	mov    (%ebx),%ecx
  800cc1:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc4:	39 d0                	cmp    %edx,%eax
  800cc6:	73 e2                	jae    800caa <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ccf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd2:	89 c2                	mov    %eax,%edx
  800cd4:	c1 fa 1f             	sar    $0x1f,%edx
  800cd7:	89 d1                	mov    %edx,%ecx
  800cd9:	c1 e9 1b             	shr    $0x1b,%ecx
  800cdc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cdf:	83 e2 1f             	and    $0x1f,%edx
  800ce2:	29 ca                	sub    %ecx,%edx
  800ce4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ce8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cec:	83 c0 01             	add    $0x1,%eax
  800cef:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf2:	83 c7 01             	add    $0x1,%edi
  800cf5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cf8:	75 c2                	jne    800cbc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cfa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfd:	eb 05                	jmp    800d04 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cff:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 18             	sub    $0x18,%esp
  800d15:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d18:	57                   	push   %edi
  800d19:	e8 83 f6 ff ff       	call   8003a1 <fd2data>
  800d1e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d20:	83 c4 10             	add    $0x10,%esp
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d28:	eb 3d                	jmp    800d67 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d2a:	85 db                	test   %ebx,%ebx
  800d2c:	74 04                	je     800d32 <devpipe_read+0x26>
				return i;
  800d2e:	89 d8                	mov    %ebx,%eax
  800d30:	eb 44                	jmp    800d76 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d32:	89 f2                	mov    %esi,%edx
  800d34:	89 f8                	mov    %edi,%eax
  800d36:	e8 e5 fe ff ff       	call   800c20 <_pipeisclosed>
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	75 32                	jne    800d71 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d3f:	e8 1e f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d44:	8b 06                	mov    (%esi),%eax
  800d46:	3b 46 04             	cmp    0x4(%esi),%eax
  800d49:	74 df                	je     800d2a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d4b:	99                   	cltd   
  800d4c:	c1 ea 1b             	shr    $0x1b,%edx
  800d4f:	01 d0                	add    %edx,%eax
  800d51:	83 e0 1f             	and    $0x1f,%eax
  800d54:	29 d0                	sub    %edx,%eax
  800d56:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d61:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d64:	83 c3 01             	add    $0x1,%ebx
  800d67:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d6a:	75 d8                	jne    800d44 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6f:	eb 05                	jmp    800d76 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d89:	50                   	push   %eax
  800d8a:	e8 29 f6 ff ff       	call   8003b8 <fd_alloc>
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	89 c2                	mov    %eax,%edx
  800d94:	85 c0                	test   %eax,%eax
  800d96:	0f 88 2c 01 00 00    	js     800ec8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	68 07 04 00 00       	push   $0x407
  800da4:	ff 75 f4             	pushl  -0xc(%ebp)
  800da7:	6a 00                	push   $0x0
  800da9:	e8 d3 f3 ff ff       	call   800181 <sys_page_alloc>
  800dae:	83 c4 10             	add    $0x10,%esp
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	85 c0                	test   %eax,%eax
  800db5:	0f 88 0d 01 00 00    	js     800ec8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc1:	50                   	push   %eax
  800dc2:	e8 f1 f5 ff ff       	call   8003b8 <fd_alloc>
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	83 c4 10             	add    $0x10,%esp
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	0f 88 e2 00 00 00    	js     800eb6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd4:	83 ec 04             	sub    $0x4,%esp
  800dd7:	68 07 04 00 00       	push   $0x407
  800ddc:	ff 75 f0             	pushl  -0x10(%ebp)
  800ddf:	6a 00                	push   $0x0
  800de1:	e8 9b f3 ff ff       	call   800181 <sys_page_alloc>
  800de6:	89 c3                	mov    %eax,%ebx
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	0f 88 c3 00 00 00    	js     800eb6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	ff 75 f4             	pushl  -0xc(%ebp)
  800df9:	e8 a3 f5 ff ff       	call   8003a1 <fd2data>
  800dfe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e00:	83 c4 0c             	add    $0xc,%esp
  800e03:	68 07 04 00 00       	push   $0x407
  800e08:	50                   	push   %eax
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 71 f3 ff ff       	call   800181 <sys_page_alloc>
  800e10:	89 c3                	mov    %eax,%ebx
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	85 c0                	test   %eax,%eax
  800e17:	0f 88 89 00 00 00    	js     800ea6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	ff 75 f0             	pushl  -0x10(%ebp)
  800e23:	e8 79 f5 ff ff       	call   8003a1 <fd2data>
  800e28:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e2f:	50                   	push   %eax
  800e30:	6a 00                	push   $0x0
  800e32:	56                   	push   %esi
  800e33:	6a 00                	push   $0x0
  800e35:	e8 8a f3 ff ff       	call   8001c4 <sys_page_map>
  800e3a:	89 c3                	mov    %eax,%ebx
  800e3c:	83 c4 20             	add    $0x20,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	78 55                	js     800e98 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e43:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e51:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e58:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e61:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e66:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	ff 75 f4             	pushl  -0xc(%ebp)
  800e73:	e8 19 f5 ff ff       	call   800391 <fd2num>
  800e78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e7d:	83 c4 04             	add    $0x4,%esp
  800e80:	ff 75 f0             	pushl  -0x10(%ebp)
  800e83:	e8 09 f5 ff ff       	call   800391 <fd2num>
  800e88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e8e:	83 c4 10             	add    $0x10,%esp
  800e91:	ba 00 00 00 00       	mov    $0x0,%edx
  800e96:	eb 30                	jmp    800ec8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	56                   	push   %esi
  800e9c:	6a 00                	push   $0x0
  800e9e:	e8 63 f3 ff ff       	call   800206 <sys_page_unmap>
  800ea3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea6:	83 ec 08             	sub    $0x8,%esp
  800ea9:	ff 75 f0             	pushl  -0x10(%ebp)
  800eac:	6a 00                	push   $0x0
  800eae:	e8 53 f3 ff ff       	call   800206 <sys_page_unmap>
  800eb3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb6:	83 ec 08             	sub    $0x8,%esp
  800eb9:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 43 f3 ff ff       	call   800206 <sys_page_unmap>
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ec8:	89 d0                	mov    %edx,%eax
  800eca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eda:	50                   	push   %eax
  800edb:	ff 75 08             	pushl  0x8(%ebp)
  800ede:	e8 24 f5 ff ff       	call   800407 <fd_lookup>
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	78 18                	js     800f02 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eea:	83 ec 0c             	sub    $0xc,%esp
  800eed:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef0:	e8 ac f4 ff ff       	call   8003a1 <fd2data>
	return _pipeisclosed(fd, p);
  800ef5:	89 c2                	mov    %eax,%edx
  800ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800efa:	e8 21 fd ff ff       	call   800c20 <_pipeisclosed>
  800eff:	83 c4 10             	add    $0x10,%esp
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800f0a:	68 9a 23 80 00       	push   $0x80239a
  800f0f:	ff 75 0c             	pushl  0xc(%ebp)
  800f12:	e8 55 0c 00 00       	call   801b6c <strcpy>
	return 0;
}
  800f17:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    

00800f1e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	53                   	push   %ebx
  800f22:	83 ec 10             	sub    $0x10,%esp
  800f25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800f28:	53                   	push   %ebx
  800f29:	e8 83 10 00 00       	call   801fb1 <pageref>
  800f2e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800f31:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800f36:	83 f8 01             	cmp    $0x1,%eax
  800f39:	75 10                	jne    800f4b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800f3b:	83 ec 0c             	sub    $0xc,%esp
  800f3e:	ff 73 0c             	pushl  0xc(%ebx)
  800f41:	e8 c0 02 00 00       	call   801206 <nsipc_close>
  800f46:	89 c2                	mov    %eax,%edx
  800f48:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f58:	6a 00                	push   $0x0
  800f5a:	ff 75 10             	pushl  0x10(%ebp)
  800f5d:	ff 75 0c             	pushl  0xc(%ebp)
  800f60:	8b 45 08             	mov    0x8(%ebp),%eax
  800f63:	ff 70 0c             	pushl  0xc(%eax)
  800f66:	e8 78 03 00 00       	call   8012e3 <nsipc_send>
}
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    

00800f6d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f73:	6a 00                	push   $0x0
  800f75:	ff 75 10             	pushl  0x10(%ebp)
  800f78:	ff 75 0c             	pushl  0xc(%ebp)
  800f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7e:	ff 70 0c             	pushl  0xc(%eax)
  800f81:	e8 f1 02 00 00       	call   801277 <nsipc_recv>
}
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f8e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f91:	52                   	push   %edx
  800f92:	50                   	push   %eax
  800f93:	e8 6f f4 ff ff       	call   800407 <fd_lookup>
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 17                	js     800fb6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa2:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  800fa8:	39 08                	cmp    %ecx,(%eax)
  800faa:	75 05                	jne    800fb1 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800fac:	8b 40 0c             	mov    0xc(%eax),%eax
  800faf:	eb 05                	jmp    800fb6 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800fb1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	56                   	push   %esi
  800fbc:	53                   	push   %ebx
  800fbd:	83 ec 1c             	sub    $0x1c,%esp
  800fc0:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800fc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc5:	50                   	push   %eax
  800fc6:	e8 ed f3 ff ff       	call   8003b8 <fd_alloc>
  800fcb:	89 c3                	mov    %eax,%ebx
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 1b                	js     800fef <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	68 07 04 00 00       	push   $0x407
  800fdc:	ff 75 f4             	pushl  -0xc(%ebp)
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 9b f1 ff ff       	call   800181 <sys_page_alloc>
  800fe6:	89 c3                	mov    %eax,%ebx
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	79 10                	jns    800fff <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	56                   	push   %esi
  800ff3:	e8 0e 02 00 00       	call   801206 <nsipc_close>
		return r;
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	89 d8                	mov    %ebx,%eax
  800ffd:	eb 24                	jmp    801023 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800fff:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801005:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801008:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80100a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801014:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	50                   	push   %eax
  80101b:	e8 71 f3 ff ff       	call   800391 <fd2num>
  801020:	83 c4 10             	add    $0x10,%esp
}
  801023:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801026:	5b                   	pop    %ebx
  801027:	5e                   	pop    %esi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801030:	8b 45 08             	mov    0x8(%ebp),%eax
  801033:	e8 50 ff ff ff       	call   800f88 <fd2sockid>
		return r;
  801038:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80103a:	85 c0                	test   %eax,%eax
  80103c:	78 1f                	js     80105d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80103e:	83 ec 04             	sub    $0x4,%esp
  801041:	ff 75 10             	pushl  0x10(%ebp)
  801044:	ff 75 0c             	pushl  0xc(%ebp)
  801047:	50                   	push   %eax
  801048:	e8 12 01 00 00       	call   80115f <nsipc_accept>
  80104d:	83 c4 10             	add    $0x10,%esp
		return r;
  801050:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801052:	85 c0                	test   %eax,%eax
  801054:	78 07                	js     80105d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801056:	e8 5d ff ff ff       	call   800fb8 <alloc_sockfd>
  80105b:	89 c1                	mov    %eax,%ecx
}
  80105d:	89 c8                	mov    %ecx,%eax
  80105f:	c9                   	leave  
  801060:	c3                   	ret    

00801061 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801067:	8b 45 08             	mov    0x8(%ebp),%eax
  80106a:	e8 19 ff ff ff       	call   800f88 <fd2sockid>
  80106f:	85 c0                	test   %eax,%eax
  801071:	78 12                	js     801085 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801073:	83 ec 04             	sub    $0x4,%esp
  801076:	ff 75 10             	pushl  0x10(%ebp)
  801079:	ff 75 0c             	pushl  0xc(%ebp)
  80107c:	50                   	push   %eax
  80107d:	e8 2d 01 00 00       	call   8011af <nsipc_bind>
  801082:	83 c4 10             	add    $0x10,%esp
}
  801085:	c9                   	leave  
  801086:	c3                   	ret    

00801087 <shutdown>:

int
shutdown(int s, int how)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80108d:	8b 45 08             	mov    0x8(%ebp),%eax
  801090:	e8 f3 fe ff ff       	call   800f88 <fd2sockid>
  801095:	85 c0                	test   %eax,%eax
  801097:	78 0f                	js     8010a8 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801099:	83 ec 08             	sub    $0x8,%esp
  80109c:	ff 75 0c             	pushl  0xc(%ebp)
  80109f:	50                   	push   %eax
  8010a0:	e8 3f 01 00 00       	call   8011e4 <nsipc_shutdown>
  8010a5:	83 c4 10             	add    $0x10,%esp
}
  8010a8:	c9                   	leave  
  8010a9:	c3                   	ret    

008010aa <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b3:	e8 d0 fe ff ff       	call   800f88 <fd2sockid>
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	78 12                	js     8010ce <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8010bc:	83 ec 04             	sub    $0x4,%esp
  8010bf:	ff 75 10             	pushl  0x10(%ebp)
  8010c2:	ff 75 0c             	pushl  0xc(%ebp)
  8010c5:	50                   	push   %eax
  8010c6:	e8 55 01 00 00       	call   801220 <nsipc_connect>
  8010cb:	83 c4 10             	add    $0x10,%esp
}
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <listen>:

int
listen(int s, int backlog)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	e8 aa fe ff ff       	call   800f88 <fd2sockid>
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 0f                	js     8010f1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8010e2:	83 ec 08             	sub    $0x8,%esp
  8010e5:	ff 75 0c             	pushl  0xc(%ebp)
  8010e8:	50                   	push   %eax
  8010e9:	e8 67 01 00 00       	call   801255 <nsipc_listen>
  8010ee:	83 c4 10             	add    $0x10,%esp
}
  8010f1:	c9                   	leave  
  8010f2:	c3                   	ret    

008010f3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8010f9:	ff 75 10             	pushl  0x10(%ebp)
  8010fc:	ff 75 0c             	pushl  0xc(%ebp)
  8010ff:	ff 75 08             	pushl  0x8(%ebp)
  801102:	e8 3a 02 00 00       	call   801341 <nsipc_socket>
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	78 05                	js     801113 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80110e:	e8 a5 fe ff ff       	call   800fb8 <alloc_sockfd>
}
  801113:	c9                   	leave  
  801114:	c3                   	ret    

00801115 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	53                   	push   %ebx
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80111e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801125:	75 12                	jne    801139 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	6a 02                	push   $0x2
  80112c:	e8 47 0e 00 00       	call   801f78 <ipc_find_env>
  801131:	a3 04 40 80 00       	mov    %eax,0x804004
  801136:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801139:	6a 07                	push   $0x7
  80113b:	68 00 60 80 00       	push   $0x806000
  801140:	53                   	push   %ebx
  801141:	ff 35 04 40 80 00    	pushl  0x804004
  801147:	e8 dd 0d 00 00       	call   801f29 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80114c:	83 c4 0c             	add    $0xc,%esp
  80114f:	6a 00                	push   $0x0
  801151:	6a 00                	push   $0x0
  801153:	6a 00                	push   $0x0
  801155:	e8 59 0d 00 00       	call   801eb3 <ipc_recv>
}
  80115a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115d:	c9                   	leave  
  80115e:	c3                   	ret    

0080115f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801167:	8b 45 08             	mov    0x8(%ebp),%eax
  80116a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80116f:	8b 06                	mov    (%esi),%eax
  801171:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801176:	b8 01 00 00 00       	mov    $0x1,%eax
  80117b:	e8 95 ff ff ff       	call   801115 <nsipc>
  801180:	89 c3                	mov    %eax,%ebx
  801182:	85 c0                	test   %eax,%eax
  801184:	78 20                	js     8011a6 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	ff 35 10 60 80 00    	pushl  0x806010
  80118f:	68 00 60 80 00       	push   $0x806000
  801194:	ff 75 0c             	pushl  0xc(%ebp)
  801197:	e8 62 0b 00 00       	call   801cfe <memmove>
		*addrlen = ret->ret_addrlen;
  80119c:	a1 10 60 80 00       	mov    0x806010,%eax
  8011a1:	89 06                	mov    %eax,(%esi)
  8011a3:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8011a6:	89 d8                	mov    %ebx,%eax
  8011a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	53                   	push   %ebx
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8011b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8011c1:	53                   	push   %ebx
  8011c2:	ff 75 0c             	pushl  0xc(%ebp)
  8011c5:	68 04 60 80 00       	push   $0x806004
  8011ca:	e8 2f 0b 00 00       	call   801cfe <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8011cf:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8011d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8011da:	e8 36 ff ff ff       	call   801115 <nsipc>
}
  8011df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e2:	c9                   	leave  
  8011e3:	c3                   	ret    

008011e4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ed:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8011f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8011fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8011ff:	e8 11 ff ff ff       	call   801115 <nsipc>
}
  801204:	c9                   	leave  
  801205:	c3                   	ret    

00801206 <nsipc_close>:

int
nsipc_close(int s)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80120c:	8b 45 08             	mov    0x8(%ebp),%eax
  80120f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801214:	b8 04 00 00 00       	mov    $0x4,%eax
  801219:	e8 f7 fe ff ff       	call   801115 <nsipc>
}
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	53                   	push   %ebx
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80122a:	8b 45 08             	mov    0x8(%ebp),%eax
  80122d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801232:	53                   	push   %ebx
  801233:	ff 75 0c             	pushl  0xc(%ebp)
  801236:	68 04 60 80 00       	push   $0x806004
  80123b:	e8 be 0a 00 00       	call   801cfe <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801240:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801246:	b8 05 00 00 00       	mov    $0x5,%eax
  80124b:	e8 c5 fe ff ff       	call   801115 <nsipc>
}
  801250:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801263:	8b 45 0c             	mov    0xc(%ebp),%eax
  801266:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80126b:	b8 06 00 00 00       	mov    $0x6,%eax
  801270:	e8 a0 fe ff ff       	call   801115 <nsipc>
}
  801275:	c9                   	leave  
  801276:	c3                   	ret    

00801277 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	56                   	push   %esi
  80127b:	53                   	push   %ebx
  80127c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80127f:	8b 45 08             	mov    0x8(%ebp),%eax
  801282:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801287:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80128d:	8b 45 14             	mov    0x14(%ebp),%eax
  801290:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801295:	b8 07 00 00 00       	mov    $0x7,%eax
  80129a:	e8 76 fe ff ff       	call   801115 <nsipc>
  80129f:	89 c3                	mov    %eax,%ebx
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 35                	js     8012da <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8012a5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8012aa:	7f 04                	jg     8012b0 <nsipc_recv+0x39>
  8012ac:	39 c6                	cmp    %eax,%esi
  8012ae:	7d 16                	jge    8012c6 <nsipc_recv+0x4f>
  8012b0:	68 a6 23 80 00       	push   $0x8023a6
  8012b5:	68 4f 23 80 00       	push   $0x80234f
  8012ba:	6a 62                	push   $0x62
  8012bc:	68 bb 23 80 00       	push   $0x8023bb
  8012c1:	e8 28 02 00 00       	call   8014ee <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8012c6:	83 ec 04             	sub    $0x4,%esp
  8012c9:	50                   	push   %eax
  8012ca:	68 00 60 80 00       	push   $0x806000
  8012cf:	ff 75 0c             	pushl  0xc(%ebp)
  8012d2:	e8 27 0a 00 00       	call   801cfe <memmove>
  8012d7:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8012da:	89 d8                	mov    %ebx,%eax
  8012dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5e                   	pop    %esi
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 04             	sub    $0x4,%esp
  8012ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8012ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f0:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8012f5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8012fb:	7e 16                	jle    801313 <nsipc_send+0x30>
  8012fd:	68 c7 23 80 00       	push   $0x8023c7
  801302:	68 4f 23 80 00       	push   $0x80234f
  801307:	6a 6d                	push   $0x6d
  801309:	68 bb 23 80 00       	push   $0x8023bb
  80130e:	e8 db 01 00 00       	call   8014ee <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	53                   	push   %ebx
  801317:	ff 75 0c             	pushl  0xc(%ebp)
  80131a:	68 0c 60 80 00       	push   $0x80600c
  80131f:	e8 da 09 00 00       	call   801cfe <memmove>
	nsipcbuf.send.req_size = size;
  801324:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80132a:	8b 45 14             	mov    0x14(%ebp),%eax
  80132d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801332:	b8 08 00 00 00       	mov    $0x8,%eax
  801337:	e8 d9 fd ff ff       	call   801115 <nsipc>
}
  80133c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133f:	c9                   	leave  
  801340:	c3                   	ret    

00801341 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801347:	8b 45 08             	mov    0x8(%ebp),%eax
  80134a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80134f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801352:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801357:	8b 45 10             	mov    0x10(%ebp),%eax
  80135a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80135f:	b8 09 00 00 00       	mov    $0x9,%eax
  801364:	e8 ac fd ff ff       	call   801115 <nsipc>
}
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80137b:	68 d3 23 80 00       	push   $0x8023d3
  801380:	ff 75 0c             	pushl  0xc(%ebp)
  801383:	e8 e4 07 00 00       	call   801b6c <strcpy>
	return 0;
}
  801388:	b8 00 00 00 00       	mov    $0x0,%eax
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	57                   	push   %edi
  801393:	56                   	push   %esi
  801394:	53                   	push   %ebx
  801395:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80139b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a6:	eb 2d                	jmp    8013d5 <devcons_write+0x46>
		m = n - tot;
  8013a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ab:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013ad:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013b0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013b5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b8:	83 ec 04             	sub    $0x4,%esp
  8013bb:	53                   	push   %ebx
  8013bc:	03 45 0c             	add    0xc(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	57                   	push   %edi
  8013c1:	e8 38 09 00 00       	call   801cfe <memmove>
		sys_cputs(buf, m);
  8013c6:	83 c4 08             	add    $0x8,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	57                   	push   %edi
  8013cb:	e8 f5 ec ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013d0:	01 de                	add    %ebx,%esi
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	89 f0                	mov    %esi,%eax
  8013d7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013da:	72 cc                	jb     8013a8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013df:	5b                   	pop    %ebx
  8013e0:	5e                   	pop    %esi
  8013e1:	5f                   	pop    %edi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    

008013e4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f3:	74 2a                	je     80141f <devcons_read+0x3b>
  8013f5:	eb 05                	jmp    8013fc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013f7:	e8 66 ed ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013fc:	e8 e2 ec ff ff       	call   8000e3 <sys_cgetc>
  801401:	85 c0                	test   %eax,%eax
  801403:	74 f2                	je     8013f7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801405:	85 c0                	test   %eax,%eax
  801407:	78 16                	js     80141f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801409:	83 f8 04             	cmp    $0x4,%eax
  80140c:	74 0c                	je     80141a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80140e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801411:	88 02                	mov    %al,(%edx)
	return 1;
  801413:	b8 01 00 00 00       	mov    $0x1,%eax
  801418:	eb 05                	jmp    80141f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80141a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80141f:	c9                   	leave  
  801420:	c3                   	ret    

00801421 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801427:	8b 45 08             	mov    0x8(%ebp),%eax
  80142a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80142d:	6a 01                	push   $0x1
  80142f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	e8 8d ec ff ff       	call   8000c5 <sys_cputs>
}
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <getchar>:

int
getchar(void)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801443:	6a 01                	push   $0x1
  801445:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	6a 00                	push   $0x0
  80144b:	e8 1d f2 ff ff       	call   80066d <read>
	if (r < 0)
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	78 0f                	js     801466 <getchar+0x29>
		return r;
	if (r < 1)
  801457:	85 c0                	test   %eax,%eax
  801459:	7e 06                	jle    801461 <getchar+0x24>
		return -E_EOF;
	return c;
  80145b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80145f:	eb 05                	jmp    801466 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801461:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	ff 75 08             	pushl  0x8(%ebp)
  801475:	e8 8d ef ff ff       	call   800407 <fd_lookup>
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	85 c0                	test   %eax,%eax
  80147f:	78 11                	js     801492 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801481:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801484:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80148a:	39 10                	cmp    %edx,(%eax)
  80148c:	0f 94 c0             	sete   %al
  80148f:	0f b6 c0             	movzbl %al,%eax
}
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <opencons>:

int
opencons(void)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80149a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	e8 15 ef ff ff       	call   8003b8 <fd_alloc>
  8014a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 3e                	js     8014ea <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ac:	83 ec 04             	sub    $0x4,%esp
  8014af:	68 07 04 00 00       	push   $0x407
  8014b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b7:	6a 00                	push   $0x0
  8014b9:	e8 c3 ec ff ff       	call   800181 <sys_page_alloc>
  8014be:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 23                	js     8014ea <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014c7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014dc:	83 ec 0c             	sub    $0xc,%esp
  8014df:	50                   	push   %eax
  8014e0:	e8 ac ee ff ff       	call   800391 <fd2num>
  8014e5:	89 c2                	mov    %eax,%edx
  8014e7:	83 c4 10             	add    $0x10,%esp
}
  8014ea:	89 d0                	mov    %edx,%eax
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	56                   	push   %esi
  8014f2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014f6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014fc:	e8 42 ec ff ff       	call   800143 <sys_getenvid>
  801501:	83 ec 0c             	sub    $0xc,%esp
  801504:	ff 75 0c             	pushl  0xc(%ebp)
  801507:	ff 75 08             	pushl  0x8(%ebp)
  80150a:	56                   	push   %esi
  80150b:	50                   	push   %eax
  80150c:	68 e0 23 80 00       	push   $0x8023e0
  801511:	e8 b1 00 00 00       	call   8015c7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801516:	83 c4 18             	add    $0x18,%esp
  801519:	53                   	push   %ebx
  80151a:	ff 75 10             	pushl  0x10(%ebp)
  80151d:	e8 54 00 00 00       	call   801576 <vcprintf>
	cprintf("\n");
  801522:	c7 04 24 93 23 80 00 	movl   $0x802393,(%esp)
  801529:	e8 99 00 00 00       	call   8015c7 <cprintf>
  80152e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801531:	cc                   	int3   
  801532:	eb fd                	jmp    801531 <_panic+0x43>

00801534 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 04             	sub    $0x4,%esp
  80153b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80153e:	8b 13                	mov    (%ebx),%edx
  801540:	8d 42 01             	lea    0x1(%edx),%eax
  801543:	89 03                	mov    %eax,(%ebx)
  801545:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801548:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80154c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801551:	75 1a                	jne    80156d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801553:	83 ec 08             	sub    $0x8,%esp
  801556:	68 ff 00 00 00       	push   $0xff
  80155b:	8d 43 08             	lea    0x8(%ebx),%eax
  80155e:	50                   	push   %eax
  80155f:	e8 61 eb ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  801564:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80156a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80156d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80157f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801586:	00 00 00 
	b.cnt = 0;
  801589:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801590:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801593:	ff 75 0c             	pushl  0xc(%ebp)
  801596:	ff 75 08             	pushl  0x8(%ebp)
  801599:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	68 34 15 80 00       	push   $0x801534
  8015a5:	e8 54 01 00 00       	call   8016fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015aa:	83 c4 08             	add    $0x8,%esp
  8015ad:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015b3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	e8 06 eb ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  8015bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015cd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015d0:	50                   	push   %eax
  8015d1:	ff 75 08             	pushl  0x8(%ebp)
  8015d4:	e8 9d ff ff ff       	call   801576 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	57                   	push   %edi
  8015df:	56                   	push   %esi
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 1c             	sub    $0x1c,%esp
  8015e4:	89 c7                	mov    %eax,%edi
  8015e6:	89 d6                	mov    %edx,%esi
  8015e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015ff:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801602:	39 d3                	cmp    %edx,%ebx
  801604:	72 05                	jb     80160b <printnum+0x30>
  801606:	39 45 10             	cmp    %eax,0x10(%ebp)
  801609:	77 45                	ja     801650 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	ff 75 18             	pushl  0x18(%ebp)
  801611:	8b 45 14             	mov    0x14(%ebp),%eax
  801614:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801617:	53                   	push   %ebx
  801618:	ff 75 10             	pushl  0x10(%ebp)
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801621:	ff 75 e0             	pushl  -0x20(%ebp)
  801624:	ff 75 dc             	pushl  -0x24(%ebp)
  801627:	ff 75 d8             	pushl  -0x28(%ebp)
  80162a:	e8 c1 09 00 00       	call   801ff0 <__udivdi3>
  80162f:	83 c4 18             	add    $0x18,%esp
  801632:	52                   	push   %edx
  801633:	50                   	push   %eax
  801634:	89 f2                	mov    %esi,%edx
  801636:	89 f8                	mov    %edi,%eax
  801638:	e8 9e ff ff ff       	call   8015db <printnum>
  80163d:	83 c4 20             	add    $0x20,%esp
  801640:	eb 18                	jmp    80165a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	56                   	push   %esi
  801646:	ff 75 18             	pushl  0x18(%ebp)
  801649:	ff d7                	call   *%edi
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	eb 03                	jmp    801653 <printnum+0x78>
  801650:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801653:	83 eb 01             	sub    $0x1,%ebx
  801656:	85 db                	test   %ebx,%ebx
  801658:	7f e8                	jg     801642 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	56                   	push   %esi
  80165e:	83 ec 04             	sub    $0x4,%esp
  801661:	ff 75 e4             	pushl  -0x1c(%ebp)
  801664:	ff 75 e0             	pushl  -0x20(%ebp)
  801667:	ff 75 dc             	pushl  -0x24(%ebp)
  80166a:	ff 75 d8             	pushl  -0x28(%ebp)
  80166d:	e8 ae 0a 00 00       	call   802120 <__umoddi3>
  801672:	83 c4 14             	add    $0x14,%esp
  801675:	0f be 80 03 24 80 00 	movsbl 0x802403(%eax),%eax
  80167c:	50                   	push   %eax
  80167d:	ff d7                	call   *%edi
}
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5f                   	pop    %edi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    

0080168a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80168d:	83 fa 01             	cmp    $0x1,%edx
  801690:	7e 0e                	jle    8016a0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801692:	8b 10                	mov    (%eax),%edx
  801694:	8d 4a 08             	lea    0x8(%edx),%ecx
  801697:	89 08                	mov    %ecx,(%eax)
  801699:	8b 02                	mov    (%edx),%eax
  80169b:	8b 52 04             	mov    0x4(%edx),%edx
  80169e:	eb 22                	jmp    8016c2 <getuint+0x38>
	else if (lflag)
  8016a0:	85 d2                	test   %edx,%edx
  8016a2:	74 10                	je     8016b4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016a4:	8b 10                	mov    (%eax),%edx
  8016a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a9:	89 08                	mov    %ecx,(%eax)
  8016ab:	8b 02                	mov    (%edx),%eax
  8016ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b2:	eb 0e                	jmp    8016c2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016b4:	8b 10                	mov    (%eax),%edx
  8016b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b9:	89 08                	mov    %ecx,(%eax)
  8016bb:	8b 02                	mov    (%edx),%eax
  8016bd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016ca:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016ce:	8b 10                	mov    (%eax),%edx
  8016d0:	3b 50 04             	cmp    0x4(%eax),%edx
  8016d3:	73 0a                	jae    8016df <sprintputch+0x1b>
		*b->buf++ = ch;
  8016d5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016d8:	89 08                	mov    %ecx,(%eax)
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	88 02                	mov    %al,(%edx)
}
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016e7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016ea:	50                   	push   %eax
  8016eb:	ff 75 10             	pushl  0x10(%ebp)
  8016ee:	ff 75 0c             	pushl  0xc(%ebp)
  8016f1:	ff 75 08             	pushl  0x8(%ebp)
  8016f4:	e8 05 00 00 00       	call   8016fe <vprintfmt>
	va_end(ap);
}
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	57                   	push   %edi
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
  801704:	83 ec 2c             	sub    $0x2c,%esp
  801707:	8b 75 08             	mov    0x8(%ebp),%esi
  80170a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80170d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801710:	eb 12                	jmp    801724 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801712:	85 c0                	test   %eax,%eax
  801714:	0f 84 a9 03 00 00    	je     801ac3 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  80171a:	83 ec 08             	sub    $0x8,%esp
  80171d:	53                   	push   %ebx
  80171e:	50                   	push   %eax
  80171f:	ff d6                	call   *%esi
  801721:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801724:	83 c7 01             	add    $0x1,%edi
  801727:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80172b:	83 f8 25             	cmp    $0x25,%eax
  80172e:	75 e2                	jne    801712 <vprintfmt+0x14>
  801730:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801734:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80173b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801742:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	eb 07                	jmp    801757 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801750:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801753:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801757:	8d 47 01             	lea    0x1(%edi),%eax
  80175a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80175d:	0f b6 07             	movzbl (%edi),%eax
  801760:	0f b6 c8             	movzbl %al,%ecx
  801763:	83 e8 23             	sub    $0x23,%eax
  801766:	3c 55                	cmp    $0x55,%al
  801768:	0f 87 3a 03 00 00    	ja     801aa8 <vprintfmt+0x3aa>
  80176e:	0f b6 c0             	movzbl %al,%eax
  801771:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  801778:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80177b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80177f:	eb d6                	jmp    801757 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
  801789:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80178c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80178f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801793:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801796:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801799:	83 fa 09             	cmp    $0x9,%edx
  80179c:	77 39                	ja     8017d7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80179e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017a1:	eb e9                	jmp    80178c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a6:	8d 48 04             	lea    0x4(%eax),%ecx
  8017a9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017ac:	8b 00                	mov    (%eax),%eax
  8017ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017b4:	eb 27                	jmp    8017dd <vprintfmt+0xdf>
  8017b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017c0:	0f 49 c8             	cmovns %eax,%ecx
  8017c3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c9:	eb 8c                	jmp    801757 <vprintfmt+0x59>
  8017cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017ce:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017d5:	eb 80                	jmp    801757 <vprintfmt+0x59>
  8017d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017da:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017e1:	0f 89 70 ff ff ff    	jns    801757 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ed:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017f4:	e9 5e ff ff ff       	jmp    801757 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017f9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017ff:	e9 53 ff ff ff       	jmp    801757 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801804:	8b 45 14             	mov    0x14(%ebp),%eax
  801807:	8d 50 04             	lea    0x4(%eax),%edx
  80180a:	89 55 14             	mov    %edx,0x14(%ebp)
  80180d:	83 ec 08             	sub    $0x8,%esp
  801810:	53                   	push   %ebx
  801811:	ff 30                	pushl  (%eax)
  801813:	ff d6                	call   *%esi
			break;
  801815:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801818:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80181b:	e9 04 ff ff ff       	jmp    801724 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801820:	8b 45 14             	mov    0x14(%ebp),%eax
  801823:	8d 50 04             	lea    0x4(%eax),%edx
  801826:	89 55 14             	mov    %edx,0x14(%ebp)
  801829:	8b 00                	mov    (%eax),%eax
  80182b:	99                   	cltd   
  80182c:	31 d0                	xor    %edx,%eax
  80182e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801830:	83 f8 0f             	cmp    $0xf,%eax
  801833:	7f 0b                	jg     801840 <vprintfmt+0x142>
  801835:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80183c:	85 d2                	test   %edx,%edx
  80183e:	75 18                	jne    801858 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801840:	50                   	push   %eax
  801841:	68 1b 24 80 00       	push   $0x80241b
  801846:	53                   	push   %ebx
  801847:	56                   	push   %esi
  801848:	e8 94 fe ff ff       	call   8016e1 <printfmt>
  80184d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801853:	e9 cc fe ff ff       	jmp    801724 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801858:	52                   	push   %edx
  801859:	68 61 23 80 00       	push   $0x802361
  80185e:	53                   	push   %ebx
  80185f:	56                   	push   %esi
  801860:	e8 7c fe ff ff       	call   8016e1 <printfmt>
  801865:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801868:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80186b:	e9 b4 fe ff ff       	jmp    801724 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801870:	8b 45 14             	mov    0x14(%ebp),%eax
  801873:	8d 50 04             	lea    0x4(%eax),%edx
  801876:	89 55 14             	mov    %edx,0x14(%ebp)
  801879:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80187b:	85 ff                	test   %edi,%edi
  80187d:	b8 14 24 80 00       	mov    $0x802414,%eax
  801882:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801885:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801889:	0f 8e 94 00 00 00    	jle    801923 <vprintfmt+0x225>
  80188f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801893:	0f 84 98 00 00 00    	je     801931 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801899:	83 ec 08             	sub    $0x8,%esp
  80189c:	ff 75 d0             	pushl  -0x30(%ebp)
  80189f:	57                   	push   %edi
  8018a0:	e8 a6 02 00 00       	call   801b4b <strnlen>
  8018a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018a8:	29 c1                	sub    %eax,%ecx
  8018aa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018ad:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018b0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018ba:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018bc:	eb 0f                	jmp    8018cd <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	53                   	push   %ebx
  8018c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c7:	83 ef 01             	sub    $0x1,%edi
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	85 ff                	test   %edi,%edi
  8018cf:	7f ed                	jg     8018be <vprintfmt+0x1c0>
  8018d1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018d4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018d7:	85 c9                	test   %ecx,%ecx
  8018d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018de:	0f 49 c1             	cmovns %ecx,%eax
  8018e1:	29 c1                	sub    %eax,%ecx
  8018e3:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018ec:	89 cb                	mov    %ecx,%ebx
  8018ee:	eb 4d                	jmp    80193d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018f0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018f4:	74 1b                	je     801911 <vprintfmt+0x213>
  8018f6:	0f be c0             	movsbl %al,%eax
  8018f9:	83 e8 20             	sub    $0x20,%eax
  8018fc:	83 f8 5e             	cmp    $0x5e,%eax
  8018ff:	76 10                	jbe    801911 <vprintfmt+0x213>
					putch('?', putdat);
  801901:	83 ec 08             	sub    $0x8,%esp
  801904:	ff 75 0c             	pushl  0xc(%ebp)
  801907:	6a 3f                	push   $0x3f
  801909:	ff 55 08             	call   *0x8(%ebp)
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	eb 0d                	jmp    80191e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	ff 75 0c             	pushl  0xc(%ebp)
  801917:	52                   	push   %edx
  801918:	ff 55 08             	call   *0x8(%ebp)
  80191b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80191e:	83 eb 01             	sub    $0x1,%ebx
  801921:	eb 1a                	jmp    80193d <vprintfmt+0x23f>
  801923:	89 75 08             	mov    %esi,0x8(%ebp)
  801926:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801929:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80192c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80192f:	eb 0c                	jmp    80193d <vprintfmt+0x23f>
  801931:	89 75 08             	mov    %esi,0x8(%ebp)
  801934:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801937:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80193a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80193d:	83 c7 01             	add    $0x1,%edi
  801940:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801944:	0f be d0             	movsbl %al,%edx
  801947:	85 d2                	test   %edx,%edx
  801949:	74 23                	je     80196e <vprintfmt+0x270>
  80194b:	85 f6                	test   %esi,%esi
  80194d:	78 a1                	js     8018f0 <vprintfmt+0x1f2>
  80194f:	83 ee 01             	sub    $0x1,%esi
  801952:	79 9c                	jns    8018f0 <vprintfmt+0x1f2>
  801954:	89 df                	mov    %ebx,%edi
  801956:	8b 75 08             	mov    0x8(%ebp),%esi
  801959:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80195c:	eb 18                	jmp    801976 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80195e:	83 ec 08             	sub    $0x8,%esp
  801961:	53                   	push   %ebx
  801962:	6a 20                	push   $0x20
  801964:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801966:	83 ef 01             	sub    $0x1,%edi
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	eb 08                	jmp    801976 <vprintfmt+0x278>
  80196e:	89 df                	mov    %ebx,%edi
  801970:	8b 75 08             	mov    0x8(%ebp),%esi
  801973:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801976:	85 ff                	test   %edi,%edi
  801978:	7f e4                	jg     80195e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80197d:	e9 a2 fd ff ff       	jmp    801724 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801982:	83 fa 01             	cmp    $0x1,%edx
  801985:	7e 16                	jle    80199d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801987:	8b 45 14             	mov    0x14(%ebp),%eax
  80198a:	8d 50 08             	lea    0x8(%eax),%edx
  80198d:	89 55 14             	mov    %edx,0x14(%ebp)
  801990:	8b 50 04             	mov    0x4(%eax),%edx
  801993:	8b 00                	mov    (%eax),%eax
  801995:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801998:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80199b:	eb 32                	jmp    8019cf <vprintfmt+0x2d1>
	else if (lflag)
  80199d:	85 d2                	test   %edx,%edx
  80199f:	74 18                	je     8019b9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a4:	8d 50 04             	lea    0x4(%eax),%edx
  8019a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8019aa:	8b 00                	mov    (%eax),%eax
  8019ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019af:	89 c1                	mov    %eax,%ecx
  8019b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019b7:	eb 16                	jmp    8019cf <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bc:	8d 50 04             	lea    0x4(%eax),%edx
  8019bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8019c2:	8b 00                	mov    (%eax),%eax
  8019c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c7:	89 c1                	mov    %eax,%ecx
  8019c9:	c1 f9 1f             	sar    $0x1f,%ecx
  8019cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019de:	0f 89 90 00 00 00    	jns    801a74 <vprintfmt+0x376>
				putch('-', putdat);
  8019e4:	83 ec 08             	sub    $0x8,%esp
  8019e7:	53                   	push   %ebx
  8019e8:	6a 2d                	push   $0x2d
  8019ea:	ff d6                	call   *%esi
				num = -(long long) num;
  8019ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019f2:	f7 d8                	neg    %eax
  8019f4:	83 d2 00             	adc    $0x0,%edx
  8019f7:	f7 da                	neg    %edx
  8019f9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a01:	eb 71                	jmp    801a74 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a03:	8d 45 14             	lea    0x14(%ebp),%eax
  801a06:	e8 7f fc ff ff       	call   80168a <getuint>
			base = 10;
  801a0b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a10:	eb 62                	jmp    801a74 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a12:	8d 45 14             	lea    0x14(%ebp),%eax
  801a15:	e8 70 fc ff ff       	call   80168a <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  801a1a:	83 ec 0c             	sub    $0xc,%esp
  801a1d:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801a21:	51                   	push   %ecx
  801a22:	ff 75 e0             	pushl  -0x20(%ebp)
  801a25:	6a 08                	push   $0x8
  801a27:	52                   	push   %edx
  801a28:	50                   	push   %eax
  801a29:	89 da                	mov    %ebx,%edx
  801a2b:	89 f0                	mov    %esi,%eax
  801a2d:	e8 a9 fb ff ff       	call   8015db <printnum>
			break;
  801a32:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  801a38:	e9 e7 fc ff ff       	jmp    801724 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a3d:	83 ec 08             	sub    $0x8,%esp
  801a40:	53                   	push   %ebx
  801a41:	6a 30                	push   $0x30
  801a43:	ff d6                	call   *%esi
			putch('x', putdat);
  801a45:	83 c4 08             	add    $0x8,%esp
  801a48:	53                   	push   %ebx
  801a49:	6a 78                	push   $0x78
  801a4b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a4d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a50:	8d 50 04             	lea    0x4(%eax),%edx
  801a53:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a56:	8b 00                	mov    (%eax),%eax
  801a58:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a5d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a60:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a65:	eb 0d                	jmp    801a74 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a67:	8d 45 14             	lea    0x14(%ebp),%eax
  801a6a:	e8 1b fc ff ff       	call   80168a <getuint>
			base = 16;
  801a6f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a74:	83 ec 0c             	sub    $0xc,%esp
  801a77:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a7b:	57                   	push   %edi
  801a7c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a7f:	51                   	push   %ecx
  801a80:	52                   	push   %edx
  801a81:	50                   	push   %eax
  801a82:	89 da                	mov    %ebx,%edx
  801a84:	89 f0                	mov    %esi,%eax
  801a86:	e8 50 fb ff ff       	call   8015db <printnum>
			break;
  801a8b:	83 c4 20             	add    $0x20,%esp
  801a8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a91:	e9 8e fc ff ff       	jmp    801724 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a96:	83 ec 08             	sub    $0x8,%esp
  801a99:	53                   	push   %ebx
  801a9a:	51                   	push   %ecx
  801a9b:	ff d6                	call   *%esi
			break;
  801a9d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aa0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801aa3:	e9 7c fc ff ff       	jmp    801724 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801aa8:	83 ec 08             	sub    $0x8,%esp
  801aab:	53                   	push   %ebx
  801aac:	6a 25                	push   $0x25
  801aae:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	eb 03                	jmp    801ab8 <vprintfmt+0x3ba>
  801ab5:	83 ef 01             	sub    $0x1,%edi
  801ab8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801abc:	75 f7                	jne    801ab5 <vprintfmt+0x3b7>
  801abe:	e9 61 fc ff ff       	jmp    801724 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ac3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5f                   	pop    %edi
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	83 ec 18             	sub    $0x18,%esp
  801ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ad7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ada:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ade:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ae1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	74 26                	je     801b12 <vsnprintf+0x47>
  801aec:	85 d2                	test   %edx,%edx
  801aee:	7e 22                	jle    801b12 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801af0:	ff 75 14             	pushl  0x14(%ebp)
  801af3:	ff 75 10             	pushl  0x10(%ebp)
  801af6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801af9:	50                   	push   %eax
  801afa:	68 c4 16 80 00       	push   $0x8016c4
  801aff:	e8 fa fb ff ff       	call   8016fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b07:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	eb 05                	jmp    801b17 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b1f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b22:	50                   	push   %eax
  801b23:	ff 75 10             	pushl  0x10(%ebp)
  801b26:	ff 75 0c             	pushl  0xc(%ebp)
  801b29:	ff 75 08             	pushl  0x8(%ebp)
  801b2c:	e8 9a ff ff ff       	call   801acb <vsnprintf>
	va_end(ap);

	return rc;
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b39:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3e:	eb 03                	jmp    801b43 <strlen+0x10>
		n++;
  801b40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b47:	75 f7                	jne    801b40 <strlen+0xd>
		n++;
	return n;
}
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b51:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b54:	ba 00 00 00 00       	mov    $0x0,%edx
  801b59:	eb 03                	jmp    801b5e <strnlen+0x13>
		n++;
  801b5b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b5e:	39 c2                	cmp    %eax,%edx
  801b60:	74 08                	je     801b6a <strnlen+0x1f>
  801b62:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b66:	75 f3                	jne    801b5b <strnlen+0x10>
  801b68:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	53                   	push   %ebx
  801b70:	8b 45 08             	mov    0x8(%ebp),%eax
  801b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b76:	89 c2                	mov    %eax,%edx
  801b78:	83 c2 01             	add    $0x1,%edx
  801b7b:	83 c1 01             	add    $0x1,%ecx
  801b7e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b82:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b85:	84 db                	test   %bl,%bl
  801b87:	75 ef                	jne    801b78 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b89:	5b                   	pop    %ebx
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    

00801b8c <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	53                   	push   %ebx
  801b90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b93:	53                   	push   %ebx
  801b94:	e8 9a ff ff ff       	call   801b33 <strlen>
  801b99:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b9c:	ff 75 0c             	pushl  0xc(%ebp)
  801b9f:	01 d8                	add    %ebx,%eax
  801ba1:	50                   	push   %eax
  801ba2:	e8 c5 ff ff ff       	call   801b6c <strcpy>
	return dst;
}
  801ba7:	89 d8                	mov    %ebx,%eax
  801ba9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    

00801bae <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	56                   	push   %esi
  801bb2:	53                   	push   %ebx
  801bb3:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb9:	89 f3                	mov    %esi,%ebx
  801bbb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bbe:	89 f2                	mov    %esi,%edx
  801bc0:	eb 0f                	jmp    801bd1 <strncpy+0x23>
		*dst++ = *src;
  801bc2:	83 c2 01             	add    $0x1,%edx
  801bc5:	0f b6 01             	movzbl (%ecx),%eax
  801bc8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bcb:	80 39 01             	cmpb   $0x1,(%ecx)
  801bce:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bd1:	39 da                	cmp    %ebx,%edx
  801bd3:	75 ed                	jne    801bc2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bd5:	89 f0                	mov    %esi,%eax
  801bd7:	5b                   	pop    %ebx
  801bd8:	5e                   	pop    %esi
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	8b 75 08             	mov    0x8(%ebp),%esi
  801be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be6:	8b 55 10             	mov    0x10(%ebp),%edx
  801be9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801beb:	85 d2                	test   %edx,%edx
  801bed:	74 21                	je     801c10 <strlcpy+0x35>
  801bef:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bf3:	89 f2                	mov    %esi,%edx
  801bf5:	eb 09                	jmp    801c00 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bf7:	83 c2 01             	add    $0x1,%edx
  801bfa:	83 c1 01             	add    $0x1,%ecx
  801bfd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c00:	39 c2                	cmp    %eax,%edx
  801c02:	74 09                	je     801c0d <strlcpy+0x32>
  801c04:	0f b6 19             	movzbl (%ecx),%ebx
  801c07:	84 db                	test   %bl,%bl
  801c09:	75 ec                	jne    801bf7 <strlcpy+0x1c>
  801c0b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c0d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c10:	29 f0                	sub    %esi,%eax
}
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c1f:	eb 06                	jmp    801c27 <strcmp+0x11>
		p++, q++;
  801c21:	83 c1 01             	add    $0x1,%ecx
  801c24:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c27:	0f b6 01             	movzbl (%ecx),%eax
  801c2a:	84 c0                	test   %al,%al
  801c2c:	74 04                	je     801c32 <strcmp+0x1c>
  801c2e:	3a 02                	cmp    (%edx),%al
  801c30:	74 ef                	je     801c21 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c32:	0f b6 c0             	movzbl %al,%eax
  801c35:	0f b6 12             	movzbl (%edx),%edx
  801c38:	29 d0                	sub    %edx,%eax
}
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    

00801c3c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	53                   	push   %ebx
  801c40:	8b 45 08             	mov    0x8(%ebp),%eax
  801c43:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c4b:	eb 06                	jmp    801c53 <strncmp+0x17>
		n--, p++, q++;
  801c4d:	83 c0 01             	add    $0x1,%eax
  801c50:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c53:	39 d8                	cmp    %ebx,%eax
  801c55:	74 15                	je     801c6c <strncmp+0x30>
  801c57:	0f b6 08             	movzbl (%eax),%ecx
  801c5a:	84 c9                	test   %cl,%cl
  801c5c:	74 04                	je     801c62 <strncmp+0x26>
  801c5e:	3a 0a                	cmp    (%edx),%cl
  801c60:	74 eb                	je     801c4d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c62:	0f b6 00             	movzbl (%eax),%eax
  801c65:	0f b6 12             	movzbl (%edx),%edx
  801c68:	29 d0                	sub    %edx,%eax
  801c6a:	eb 05                	jmp    801c71 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c6c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c71:	5b                   	pop    %ebx
  801c72:	5d                   	pop    %ebp
  801c73:	c3                   	ret    

00801c74 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c7e:	eb 07                	jmp    801c87 <strchr+0x13>
		if (*s == c)
  801c80:	38 ca                	cmp    %cl,%dl
  801c82:	74 0f                	je     801c93 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c84:	83 c0 01             	add    $0x1,%eax
  801c87:	0f b6 10             	movzbl (%eax),%edx
  801c8a:	84 d2                	test   %dl,%dl
  801c8c:	75 f2                	jne    801c80 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c9f:	eb 03                	jmp    801ca4 <strfind+0xf>
  801ca1:	83 c0 01             	add    $0x1,%eax
  801ca4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801ca7:	38 ca                	cmp    %cl,%dl
  801ca9:	74 04                	je     801caf <strfind+0x1a>
  801cab:	84 d2                	test   %dl,%dl
  801cad:	75 f2                	jne    801ca1 <strfind+0xc>
			break;
	return (char *) s;
}
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	57                   	push   %edi
  801cb5:	56                   	push   %esi
  801cb6:	53                   	push   %ebx
  801cb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cbd:	85 c9                	test   %ecx,%ecx
  801cbf:	74 36                	je     801cf7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cc1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cc7:	75 28                	jne    801cf1 <memset+0x40>
  801cc9:	f6 c1 03             	test   $0x3,%cl
  801ccc:	75 23                	jne    801cf1 <memset+0x40>
		c &= 0xFF;
  801cce:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cd2:	89 d3                	mov    %edx,%ebx
  801cd4:	c1 e3 08             	shl    $0x8,%ebx
  801cd7:	89 d6                	mov    %edx,%esi
  801cd9:	c1 e6 18             	shl    $0x18,%esi
  801cdc:	89 d0                	mov    %edx,%eax
  801cde:	c1 e0 10             	shl    $0x10,%eax
  801ce1:	09 f0                	or     %esi,%eax
  801ce3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801ce5:	89 d8                	mov    %ebx,%eax
  801ce7:	09 d0                	or     %edx,%eax
  801ce9:	c1 e9 02             	shr    $0x2,%ecx
  801cec:	fc                   	cld    
  801ced:	f3 ab                	rep stos %eax,%es:(%edi)
  801cef:	eb 06                	jmp    801cf7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf4:	fc                   	cld    
  801cf5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cf7:	89 f8                	mov    %edi,%eax
  801cf9:	5b                   	pop    %ebx
  801cfa:	5e                   	pop    %esi
  801cfb:	5f                   	pop    %edi
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	8b 45 08             	mov    0x8(%ebp),%eax
  801d06:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d09:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d0c:	39 c6                	cmp    %eax,%esi
  801d0e:	73 35                	jae    801d45 <memmove+0x47>
  801d10:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d13:	39 d0                	cmp    %edx,%eax
  801d15:	73 2e                	jae    801d45 <memmove+0x47>
		s += n;
		d += n;
  801d17:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1a:	89 d6                	mov    %edx,%esi
  801d1c:	09 fe                	or     %edi,%esi
  801d1e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d24:	75 13                	jne    801d39 <memmove+0x3b>
  801d26:	f6 c1 03             	test   $0x3,%cl
  801d29:	75 0e                	jne    801d39 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d2b:	83 ef 04             	sub    $0x4,%edi
  801d2e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d31:	c1 e9 02             	shr    $0x2,%ecx
  801d34:	fd                   	std    
  801d35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d37:	eb 09                	jmp    801d42 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d39:	83 ef 01             	sub    $0x1,%edi
  801d3c:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d3f:	fd                   	std    
  801d40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d42:	fc                   	cld    
  801d43:	eb 1d                	jmp    801d62 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d45:	89 f2                	mov    %esi,%edx
  801d47:	09 c2                	or     %eax,%edx
  801d49:	f6 c2 03             	test   $0x3,%dl
  801d4c:	75 0f                	jne    801d5d <memmove+0x5f>
  801d4e:	f6 c1 03             	test   $0x3,%cl
  801d51:	75 0a                	jne    801d5d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d53:	c1 e9 02             	shr    $0x2,%ecx
  801d56:	89 c7                	mov    %eax,%edi
  801d58:	fc                   	cld    
  801d59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d5b:	eb 05                	jmp    801d62 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d5d:	89 c7                	mov    %eax,%edi
  801d5f:	fc                   	cld    
  801d60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d62:	5e                   	pop    %esi
  801d63:	5f                   	pop    %edi
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d69:	ff 75 10             	pushl  0x10(%ebp)
  801d6c:	ff 75 0c             	pushl  0xc(%ebp)
  801d6f:	ff 75 08             	pushl  0x8(%ebp)
  801d72:	e8 87 ff ff ff       	call   801cfe <memmove>
}
  801d77:	c9                   	leave  
  801d78:	c3                   	ret    

00801d79 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	56                   	push   %esi
  801d7d:	53                   	push   %ebx
  801d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d81:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d84:	89 c6                	mov    %eax,%esi
  801d86:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d89:	eb 1a                	jmp    801da5 <memcmp+0x2c>
		if (*s1 != *s2)
  801d8b:	0f b6 08             	movzbl (%eax),%ecx
  801d8e:	0f b6 1a             	movzbl (%edx),%ebx
  801d91:	38 d9                	cmp    %bl,%cl
  801d93:	74 0a                	je     801d9f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d95:	0f b6 c1             	movzbl %cl,%eax
  801d98:	0f b6 db             	movzbl %bl,%ebx
  801d9b:	29 d8                	sub    %ebx,%eax
  801d9d:	eb 0f                	jmp    801dae <memcmp+0x35>
		s1++, s2++;
  801d9f:	83 c0 01             	add    $0x1,%eax
  801da2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801da5:	39 f0                	cmp    %esi,%eax
  801da7:	75 e2                	jne    801d8b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801da9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dae:	5b                   	pop    %ebx
  801daf:	5e                   	pop    %esi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    

00801db2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	53                   	push   %ebx
  801db6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801db9:	89 c1                	mov    %eax,%ecx
  801dbb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801dbe:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dc2:	eb 0a                	jmp    801dce <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dc4:	0f b6 10             	movzbl (%eax),%edx
  801dc7:	39 da                	cmp    %ebx,%edx
  801dc9:	74 07                	je     801dd2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dcb:	83 c0 01             	add    $0x1,%eax
  801dce:	39 c8                	cmp    %ecx,%eax
  801dd0:	72 f2                	jb     801dc4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dd2:	5b                   	pop    %ebx
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	57                   	push   %edi
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dde:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801de1:	eb 03                	jmp    801de6 <strtol+0x11>
		s++;
  801de3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801de6:	0f b6 01             	movzbl (%ecx),%eax
  801de9:	3c 20                	cmp    $0x20,%al
  801deb:	74 f6                	je     801de3 <strtol+0xe>
  801ded:	3c 09                	cmp    $0x9,%al
  801def:	74 f2                	je     801de3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801df1:	3c 2b                	cmp    $0x2b,%al
  801df3:	75 0a                	jne    801dff <strtol+0x2a>
		s++;
  801df5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801df8:	bf 00 00 00 00       	mov    $0x0,%edi
  801dfd:	eb 11                	jmp    801e10 <strtol+0x3b>
  801dff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e04:	3c 2d                	cmp    $0x2d,%al
  801e06:	75 08                	jne    801e10 <strtol+0x3b>
		s++, neg = 1;
  801e08:	83 c1 01             	add    $0x1,%ecx
  801e0b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e10:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e16:	75 15                	jne    801e2d <strtol+0x58>
  801e18:	80 39 30             	cmpb   $0x30,(%ecx)
  801e1b:	75 10                	jne    801e2d <strtol+0x58>
  801e1d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e21:	75 7c                	jne    801e9f <strtol+0xca>
		s += 2, base = 16;
  801e23:	83 c1 02             	add    $0x2,%ecx
  801e26:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e2b:	eb 16                	jmp    801e43 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e2d:	85 db                	test   %ebx,%ebx
  801e2f:	75 12                	jne    801e43 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e31:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e36:	80 39 30             	cmpb   $0x30,(%ecx)
  801e39:	75 08                	jne    801e43 <strtol+0x6e>
		s++, base = 8;
  801e3b:	83 c1 01             	add    $0x1,%ecx
  801e3e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e43:	b8 00 00 00 00       	mov    $0x0,%eax
  801e48:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e4b:	0f b6 11             	movzbl (%ecx),%edx
  801e4e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e51:	89 f3                	mov    %esi,%ebx
  801e53:	80 fb 09             	cmp    $0x9,%bl
  801e56:	77 08                	ja     801e60 <strtol+0x8b>
			dig = *s - '0';
  801e58:	0f be d2             	movsbl %dl,%edx
  801e5b:	83 ea 30             	sub    $0x30,%edx
  801e5e:	eb 22                	jmp    801e82 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e60:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e63:	89 f3                	mov    %esi,%ebx
  801e65:	80 fb 19             	cmp    $0x19,%bl
  801e68:	77 08                	ja     801e72 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e6a:	0f be d2             	movsbl %dl,%edx
  801e6d:	83 ea 57             	sub    $0x57,%edx
  801e70:	eb 10                	jmp    801e82 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e72:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e75:	89 f3                	mov    %esi,%ebx
  801e77:	80 fb 19             	cmp    $0x19,%bl
  801e7a:	77 16                	ja     801e92 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e7c:	0f be d2             	movsbl %dl,%edx
  801e7f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e82:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e85:	7d 0b                	jge    801e92 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e87:	83 c1 01             	add    $0x1,%ecx
  801e8a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e8e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e90:	eb b9                	jmp    801e4b <strtol+0x76>

	if (endptr)
  801e92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e96:	74 0d                	je     801ea5 <strtol+0xd0>
		*endptr = (char *) s;
  801e98:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e9b:	89 0e                	mov    %ecx,(%esi)
  801e9d:	eb 06                	jmp    801ea5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e9f:	85 db                	test   %ebx,%ebx
  801ea1:	74 98                	je     801e3b <strtol+0x66>
  801ea3:	eb 9e                	jmp    801e43 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ea5:	89 c2                	mov    %eax,%edx
  801ea7:	f7 da                	neg    %edx
  801ea9:	85 ff                	test   %edi,%edi
  801eab:	0f 45 c2             	cmovne %edx,%eax
}
  801eae:	5b                   	pop    %ebx
  801eaf:	5e                   	pop    %esi
  801eb0:	5f                   	pop    %edi
  801eb1:	5d                   	pop    %ebp
  801eb2:	c3                   	ret    

00801eb3 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	56                   	push   %esi
  801eb7:	53                   	push   %ebx
  801eb8:	8b 75 08             	mov    0x8(%ebp),%esi
  801ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	74 0e                	je     801ed3 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801ec5:	83 ec 0c             	sub    $0xc,%esp
  801ec8:	50                   	push   %eax
  801ec9:	e8 63 e4 ff ff       	call   800331 <sys_ipc_recv>
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	eb 10                	jmp    801ee3 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801ed3:	83 ec 0c             	sub    $0xc,%esp
  801ed6:	68 00 00 c0 ee       	push   $0xeec00000
  801edb:	e8 51 e4 ff ff       	call   800331 <sys_ipc_recv>
  801ee0:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	79 17                	jns    801efe <ipc_recv+0x4b>
		if(*from_env_store)
  801ee7:	83 3e 00             	cmpl   $0x0,(%esi)
  801eea:	74 06                	je     801ef2 <ipc_recv+0x3f>
			*from_env_store = 0;
  801eec:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801ef2:	85 db                	test   %ebx,%ebx
  801ef4:	74 2c                	je     801f22 <ipc_recv+0x6f>
			*perm_store = 0;
  801ef6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801efc:	eb 24                	jmp    801f22 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801efe:	85 f6                	test   %esi,%esi
  801f00:	74 0a                	je     801f0c <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801f02:	a1 08 40 80 00       	mov    0x804008,%eax
  801f07:	8b 40 74             	mov    0x74(%eax),%eax
  801f0a:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801f0c:	85 db                	test   %ebx,%ebx
  801f0e:	74 0a                	je     801f1a <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801f10:	a1 08 40 80 00       	mov    0x804008,%eax
  801f15:	8b 40 78             	mov    0x78(%eax),%eax
  801f18:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f1a:	a1 08 40 80 00       	mov    0x804008,%eax
  801f1f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5e                   	pop    %esi
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    

00801f29 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	57                   	push   %edi
  801f2d:	56                   	push   %esi
  801f2e:	53                   	push   %ebx
  801f2f:	83 ec 0c             	sub    $0xc,%esp
  801f32:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f35:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f3b:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f3d:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f42:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f45:	e8 18 e2 ff ff       	call   800162 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f4a:	ff 75 14             	pushl  0x14(%ebp)
  801f4d:	53                   	push   %ebx
  801f4e:	56                   	push   %esi
  801f4f:	57                   	push   %edi
  801f50:	e8 b9 e3 ff ff       	call   80030e <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f55:	89 c2                	mov    %eax,%edx
  801f57:	f7 d2                	not    %edx
  801f59:	c1 ea 1f             	shr    $0x1f,%edx
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f62:	0f 94 c1             	sete   %cl
  801f65:	09 ca                	or     %ecx,%edx
  801f67:	85 c0                	test   %eax,%eax
  801f69:	0f 94 c0             	sete   %al
  801f6c:	38 c2                	cmp    %al,%dl
  801f6e:	77 d5                	ja     801f45 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801f70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f7e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f83:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f86:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f8c:	8b 52 50             	mov    0x50(%edx),%edx
  801f8f:	39 ca                	cmp    %ecx,%edx
  801f91:	75 0d                	jne    801fa0 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f93:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f96:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f9b:	8b 40 48             	mov    0x48(%eax),%eax
  801f9e:	eb 0f                	jmp    801faf <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fa0:	83 c0 01             	add    $0x1,%eax
  801fa3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa8:	75 d9                	jne    801f83 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801faa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801faf:	5d                   	pop    %ebp
  801fb0:	c3                   	ret    

00801fb1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb7:	89 d0                	mov    %edx,%eax
  801fb9:	c1 e8 16             	shr    $0x16,%eax
  801fbc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fc3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc8:	f6 c1 01             	test   $0x1,%cl
  801fcb:	74 1d                	je     801fea <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fcd:	c1 ea 0c             	shr    $0xc,%edx
  801fd0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd7:	f6 c2 01             	test   $0x1,%dl
  801fda:	74 0e                	je     801fea <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fdc:	c1 ea 0c             	shr    $0xc,%edx
  801fdf:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe6:	ef 
  801fe7:	0f b7 c0             	movzwl %ax,%eax
}
  801fea:	5d                   	pop    %ebp
  801feb:	c3                   	ret    
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
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
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
