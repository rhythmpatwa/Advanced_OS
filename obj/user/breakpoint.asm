
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 a6 04 00 00       	call   800530 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 6a 22 80 00       	push   $0x80226a
  800103:	6a 23                	push   $0x23
  800105:	68 87 22 80 00       	push   $0x802287
  80010a:	e8 b3 13 00 00       	call   8014c2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 6a 22 80 00       	push   $0x80226a
  800184:	6a 23                	push   $0x23
  800186:	68 87 22 80 00       	push   $0x802287
  80018b:	e8 32 13 00 00       	call   8014c2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 6a 22 80 00       	push   $0x80226a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 87 22 80 00       	push   $0x802287
  8001cd:	e8 f0 12 00 00       	call   8014c2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 6a 22 80 00       	push   $0x80226a
  800208:	6a 23                	push   $0x23
  80020a:	68 87 22 80 00       	push   $0x802287
  80020f:	e8 ae 12 00 00       	call   8014c2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 6a 22 80 00       	push   $0x80226a
  80024a:	6a 23                	push   $0x23
  80024c:	68 87 22 80 00       	push   $0x802287
  800251:	e8 6c 12 00 00       	call   8014c2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 6a 22 80 00       	push   $0x80226a
  80028c:	6a 23                	push   $0x23
  80028e:	68 87 22 80 00       	push   $0x802287
  800293:	e8 2a 12 00 00       	call   8014c2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 6a 22 80 00       	push   $0x80226a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 87 22 80 00       	push   $0x802287
  8002d5:	e8 e8 11 00 00       	call   8014c2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 6a 22 80 00       	push   $0x80226a
  800332:	6a 23                	push   $0x23
  800334:	68 87 22 80 00       	push   $0x802287
  800339:	e8 84 11 00 00       	call   8014c2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	b8 0e 00 00 00       	mov    $0xe,%eax
  800356:	89 d1                	mov    %edx,%ecx
  800358:	89 d3                	mov    %edx,%ebx
  80035a:	89 d7                	mov    %edx,%edi
  80035c:	89 d6                	mov    %edx,%esi
  80035e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800368:	8b 45 08             	mov    0x8(%ebp),%eax
  80036b:	05 00 00 00 30       	add    $0x30000000,%eax
  800370:	c1 e8 0c             	shr    $0xc,%eax
}
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	05 00 00 00 30       	add    $0x30000000,%eax
  800380:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800385:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800392:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 16             	shr    $0x16,%edx
  80039c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	74 11                	je     8003b9 <fd_alloc+0x2d>
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 ea 0c             	shr    $0xc,%edx
  8003ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b4:	f6 c2 01             	test   $0x1,%dl
  8003b7:	75 09                	jne    8003c2 <fd_alloc+0x36>
			*fd_store = fd;
  8003b9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c0:	eb 17                	jmp    8003d9 <fd_alloc+0x4d>
  8003c2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003c7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003cc:	75 c9                	jne    800397 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ce:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e1:	83 f8 1f             	cmp    $0x1f,%eax
  8003e4:	77 36                	ja     80041c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003e6:	c1 e0 0c             	shl    $0xc,%eax
  8003e9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 16             	shr    $0x16,%edx
  8003f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 24                	je     800423 <fd_lookup+0x48>
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 0c             	shr    $0xc,%edx
  800404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 1a                	je     80042a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800410:	8b 55 0c             	mov    0xc(%ebp),%edx
  800413:	89 02                	mov    %eax,(%edx)
	return 0;
  800415:	b8 00 00 00 00       	mov    $0x0,%eax
  80041a:	eb 13                	jmp    80042f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800421:	eb 0c                	jmp    80042f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800428:	eb 05                	jmp    80042f <fd_lookup+0x54>
  80042a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043a:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80043f:	eb 13                	jmp    800454 <dev_lookup+0x23>
  800441:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800444:	39 08                	cmp    %ecx,(%eax)
  800446:	75 0c                	jne    800454 <dev_lookup+0x23>
			*dev = devtab[i];
  800448:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044d:	b8 00 00 00 00       	mov    $0x0,%eax
  800452:	eb 2e                	jmp    800482 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800454:	8b 02                	mov    (%edx),%eax
  800456:	85 c0                	test   %eax,%eax
  800458:	75 e7                	jne    800441 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045a:	a1 08 40 80 00       	mov    0x804008,%eax
  80045f:	8b 40 48             	mov    0x48(%eax),%eax
  800462:	83 ec 04             	sub    $0x4,%esp
  800465:	51                   	push   %ecx
  800466:	50                   	push   %eax
  800467:	68 98 22 80 00       	push   $0x802298
  80046c:	e8 2a 11 00 00       	call   80159b <cprintf>
	*dev = 0;
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
  800474:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	83 ec 10             	sub    $0x10,%esp
  80048c:	8b 75 08             	mov    0x8(%ebp),%esi
  80048f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800492:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800495:	50                   	push   %eax
  800496:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80049c:	c1 e8 0c             	shr    $0xc,%eax
  80049f:	50                   	push   %eax
  8004a0:	e8 36 ff ff ff       	call   8003db <fd_lookup>
  8004a5:	83 c4 08             	add    $0x8,%esp
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	78 05                	js     8004b1 <fd_close+0x2d>
	    || fd != fd2)
  8004ac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004af:	74 0c                	je     8004bd <fd_close+0x39>
		return (must_exist ? r : 0);
  8004b1:	84 db                	test   %bl,%bl
  8004b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b8:	0f 44 c2             	cmove  %edx,%eax
  8004bb:	eb 41                	jmp    8004fe <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c3:	50                   	push   %eax
  8004c4:	ff 36                	pushl  (%esi)
  8004c6:	e8 66 ff ff ff       	call   800431 <dev_lookup>
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	78 1a                	js     8004ee <fd_close+0x6a>
		if (dev->dev_close)
  8004d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004da:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	74 0b                	je     8004ee <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004e3:	83 ec 0c             	sub    $0xc,%esp
  8004e6:	56                   	push   %esi
  8004e7:	ff d0                	call   *%eax
  8004e9:	89 c3                	mov    %eax,%ebx
  8004eb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	56                   	push   %esi
  8004f2:	6a 00                	push   $0x0
  8004f4:	e8 e1 fc ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	89 d8                	mov    %ebx,%eax
}
  8004fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800501:	5b                   	pop    %ebx
  800502:	5e                   	pop    %esi
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050e:	50                   	push   %eax
  80050f:	ff 75 08             	pushl  0x8(%ebp)
  800512:	e8 c4 fe ff ff       	call   8003db <fd_lookup>
  800517:	83 c4 08             	add    $0x8,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	78 10                	js     80052e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	6a 01                	push   $0x1
  800523:	ff 75 f4             	pushl  -0xc(%ebp)
  800526:	e8 59 ff ff ff       	call   800484 <fd_close>
  80052b:	83 c4 10             	add    $0x10,%esp
}
  80052e:	c9                   	leave  
  80052f:	c3                   	ret    

00800530 <close_all>:

void
close_all(void)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	53                   	push   %ebx
  800534:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053c:	83 ec 0c             	sub    $0xc,%esp
  80053f:	53                   	push   %ebx
  800540:	e8 c0 ff ff ff       	call   800505 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800545:	83 c3 01             	add    $0x1,%ebx
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	83 fb 20             	cmp    $0x20,%ebx
  80054e:	75 ec                	jne    80053c <close_all+0xc>
		close(i);
}
  800550:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800553:	c9                   	leave  
  800554:	c3                   	ret    

00800555 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	57                   	push   %edi
  800559:	56                   	push   %esi
  80055a:	53                   	push   %ebx
  80055b:	83 ec 2c             	sub    $0x2c,%esp
  80055e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800561:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800564:	50                   	push   %eax
  800565:	ff 75 08             	pushl  0x8(%ebp)
  800568:	e8 6e fe ff ff       	call   8003db <fd_lookup>
  80056d:	83 c4 08             	add    $0x8,%esp
  800570:	85 c0                	test   %eax,%eax
  800572:	0f 88 c1 00 00 00    	js     800639 <dup+0xe4>
		return r;
	close(newfdnum);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	56                   	push   %esi
  80057c:	e8 84 ff ff ff       	call   800505 <close>

	newfd = INDEX2FD(newfdnum);
  800581:	89 f3                	mov    %esi,%ebx
  800583:	c1 e3 0c             	shl    $0xc,%ebx
  800586:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80058c:	83 c4 04             	add    $0x4,%esp
  80058f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800592:	e8 de fd ff ff       	call   800375 <fd2data>
  800597:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800599:	89 1c 24             	mov    %ebx,(%esp)
  80059c:	e8 d4 fd ff ff       	call   800375 <fd2data>
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a7:	89 f8                	mov    %edi,%eax
  8005a9:	c1 e8 16             	shr    $0x16,%eax
  8005ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b3:	a8 01                	test   $0x1,%al
  8005b5:	74 37                	je     8005ee <dup+0x99>
  8005b7:	89 f8                	mov    %edi,%eax
  8005b9:	c1 e8 0c             	shr    $0xc,%eax
  8005bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c3:	f6 c2 01             	test   $0x1,%dl
  8005c6:	74 26                	je     8005ee <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d7:	50                   	push   %eax
  8005d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005db:	6a 00                	push   $0x0
  8005dd:	57                   	push   %edi
  8005de:	6a 00                	push   $0x0
  8005e0:	e8 b3 fb ff ff       	call   800198 <sys_page_map>
  8005e5:	89 c7                	mov    %eax,%edi
  8005e7:	83 c4 20             	add    $0x20,%esp
  8005ea:	85 c0                	test   %eax,%eax
  8005ec:	78 2e                	js     80061c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f1:	89 d0                	mov    %edx,%eax
  8005f3:	c1 e8 0c             	shr    $0xc,%eax
  8005f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fd:	83 ec 0c             	sub    $0xc,%esp
  800600:	25 07 0e 00 00       	and    $0xe07,%eax
  800605:	50                   	push   %eax
  800606:	53                   	push   %ebx
  800607:	6a 00                	push   $0x0
  800609:	52                   	push   %edx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 87 fb ff ff       	call   800198 <sys_page_map>
  800611:	89 c7                	mov    %eax,%edi
  800613:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800616:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800618:	85 ff                	test   %edi,%edi
  80061a:	79 1d                	jns    800639 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 00                	push   $0x0
  800622:	e8 b3 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80062d:	6a 00                	push   $0x0
  80062f:	e8 a6 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	89 f8                	mov    %edi,%eax
}
  800639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5e                   	pop    %esi
  80063e:	5f                   	pop    %edi
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	53                   	push   %ebx
  800645:	83 ec 14             	sub    $0x14,%esp
  800648:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	53                   	push   %ebx
  800650:	e8 86 fd ff ff       	call   8003db <fd_lookup>
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	89 c2                	mov    %eax,%edx
  80065a:	85 c0                	test   %eax,%eax
  80065c:	78 6d                	js     8006cb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800664:	50                   	push   %eax
  800665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800668:	ff 30                	pushl  (%eax)
  80066a:	e8 c2 fd ff ff       	call   800431 <dev_lookup>
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	85 c0                	test   %eax,%eax
  800674:	78 4c                	js     8006c2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800676:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800679:	8b 42 08             	mov    0x8(%edx),%eax
  80067c:	83 e0 03             	and    $0x3,%eax
  80067f:	83 f8 01             	cmp    $0x1,%eax
  800682:	75 21                	jne    8006a5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800684:	a1 08 40 80 00       	mov    0x804008,%eax
  800689:	8b 40 48             	mov    0x48(%eax),%eax
  80068c:	83 ec 04             	sub    $0x4,%esp
  80068f:	53                   	push   %ebx
  800690:	50                   	push   %eax
  800691:	68 d9 22 80 00       	push   $0x8022d9
  800696:	e8 00 0f 00 00       	call   80159b <cprintf>
		return -E_INVAL;
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006a3:	eb 26                	jmp    8006cb <read+0x8a>
	}
	if (!dev->dev_read)
  8006a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a8:	8b 40 08             	mov    0x8(%eax),%eax
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	74 17                	je     8006c6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006af:	83 ec 04             	sub    $0x4,%esp
  8006b2:	ff 75 10             	pushl  0x10(%ebp)
  8006b5:	ff 75 0c             	pushl  0xc(%ebp)
  8006b8:	52                   	push   %edx
  8006b9:	ff d0                	call   *%eax
  8006bb:	89 c2                	mov    %eax,%edx
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	eb 09                	jmp    8006cb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c2:	89 c2                	mov    %eax,%edx
  8006c4:	eb 05                	jmp    8006cb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006cb:	89 d0                	mov    %edx,%eax
  8006cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d0:	c9                   	leave  
  8006d1:	c3                   	ret    

008006d2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	57                   	push   %edi
  8006d6:	56                   	push   %esi
  8006d7:	53                   	push   %ebx
  8006d8:	83 ec 0c             	sub    $0xc,%esp
  8006db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006de:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e6:	eb 21                	jmp    800709 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e8:	83 ec 04             	sub    $0x4,%esp
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	29 d8                	sub    %ebx,%eax
  8006ef:	50                   	push   %eax
  8006f0:	89 d8                	mov    %ebx,%eax
  8006f2:	03 45 0c             	add    0xc(%ebp),%eax
  8006f5:	50                   	push   %eax
  8006f6:	57                   	push   %edi
  8006f7:	e8 45 ff ff ff       	call   800641 <read>
		if (m < 0)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	85 c0                	test   %eax,%eax
  800701:	78 10                	js     800713 <readn+0x41>
			return m;
		if (m == 0)
  800703:	85 c0                	test   %eax,%eax
  800705:	74 0a                	je     800711 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800707:	01 c3                	add    %eax,%ebx
  800709:	39 f3                	cmp    %esi,%ebx
  80070b:	72 db                	jb     8006e8 <readn+0x16>
  80070d:	89 d8                	mov    %ebx,%eax
  80070f:	eb 02                	jmp    800713 <readn+0x41>
  800711:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800713:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800716:	5b                   	pop    %ebx
  800717:	5e                   	pop    %esi
  800718:	5f                   	pop    %edi
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	83 ec 14             	sub    $0x14,%esp
  800722:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800725:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	53                   	push   %ebx
  80072a:	e8 ac fc ff ff       	call   8003db <fd_lookup>
  80072f:	83 c4 08             	add    $0x8,%esp
  800732:	89 c2                	mov    %eax,%edx
  800734:	85 c0                	test   %eax,%eax
  800736:	78 68                	js     8007a0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	ff 30                	pushl  (%eax)
  800744:	e8 e8 fc ff ff       	call   800431 <dev_lookup>
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	85 c0                	test   %eax,%eax
  80074e:	78 47                	js     800797 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800750:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800753:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800757:	75 21                	jne    80077a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800759:	a1 08 40 80 00       	mov    0x804008,%eax
  80075e:	8b 40 48             	mov    0x48(%eax),%eax
  800761:	83 ec 04             	sub    $0x4,%esp
  800764:	53                   	push   %ebx
  800765:	50                   	push   %eax
  800766:	68 f5 22 80 00       	push   $0x8022f5
  80076b:	e8 2b 0e 00 00       	call   80159b <cprintf>
		return -E_INVAL;
  800770:	83 c4 10             	add    $0x10,%esp
  800773:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800778:	eb 26                	jmp    8007a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077d:	8b 52 0c             	mov    0xc(%edx),%edx
  800780:	85 d2                	test   %edx,%edx
  800782:	74 17                	je     80079b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800784:	83 ec 04             	sub    $0x4,%esp
  800787:	ff 75 10             	pushl  0x10(%ebp)
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	50                   	push   %eax
  80078e:	ff d2                	call   *%edx
  800790:	89 c2                	mov    %eax,%edx
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 09                	jmp    8007a0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800797:	89 c2                	mov    %eax,%edx
  800799:	eb 05                	jmp    8007a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80079b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a0:	89 d0                	mov    %edx,%eax
  8007a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ad:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	ff 75 08             	pushl  0x8(%ebp)
  8007b4:	e8 22 fc ff ff       	call   8003db <fd_lookup>
  8007b9:	83 c4 08             	add    $0x8,%esp
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	78 0e                	js     8007ce <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	83 ec 14             	sub    $0x14,%esp
  8007d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	53                   	push   %ebx
  8007df:	e8 f7 fb ff ff       	call   8003db <fd_lookup>
  8007e4:	83 c4 08             	add    $0x8,%esp
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	78 65                	js     800852 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f3:	50                   	push   %eax
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	ff 30                	pushl  (%eax)
  8007f9:	e8 33 fc ff ff       	call   800431 <dev_lookup>
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	85 c0                	test   %eax,%eax
  800803:	78 44                	js     800849 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080c:	75 21                	jne    80082f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80080e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800813:	8b 40 48             	mov    0x48(%eax),%eax
  800816:	83 ec 04             	sub    $0x4,%esp
  800819:	53                   	push   %ebx
  80081a:	50                   	push   %eax
  80081b:	68 b8 22 80 00       	push   $0x8022b8
  800820:	e8 76 0d 00 00       	call   80159b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80082d:	eb 23                	jmp    800852 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80082f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800832:	8b 52 18             	mov    0x18(%edx),%edx
  800835:	85 d2                	test   %edx,%edx
  800837:	74 14                	je     80084d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	ff 75 0c             	pushl  0xc(%ebp)
  80083f:	50                   	push   %eax
  800840:	ff d2                	call   *%edx
  800842:	89 c2                	mov    %eax,%edx
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	eb 09                	jmp    800852 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800849:	89 c2                	mov    %eax,%edx
  80084b:	eb 05                	jmp    800852 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80084d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800852:	89 d0                	mov    %edx,%eax
  800854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	83 ec 14             	sub    $0x14,%esp
  800860:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800863:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800866:	50                   	push   %eax
  800867:	ff 75 08             	pushl  0x8(%ebp)
  80086a:	e8 6c fb ff ff       	call   8003db <fd_lookup>
  80086f:	83 c4 08             	add    $0x8,%esp
  800872:	89 c2                	mov    %eax,%edx
  800874:	85 c0                	test   %eax,%eax
  800876:	78 58                	js     8008d0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087e:	50                   	push   %eax
  80087f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800882:	ff 30                	pushl  (%eax)
  800884:	e8 a8 fb ff ff       	call   800431 <dev_lookup>
  800889:	83 c4 10             	add    $0x10,%esp
  80088c:	85 c0                	test   %eax,%eax
  80088e:	78 37                	js     8008c7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800893:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800897:	74 32                	je     8008cb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800899:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80089c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a3:	00 00 00 
	stat->st_isdir = 0;
  8008a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ad:	00 00 00 
	stat->st_dev = dev;
  8008b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	53                   	push   %ebx
  8008ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8008bd:	ff 50 14             	call   *0x14(%eax)
  8008c0:	89 c2                	mov    %eax,%edx
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	eb 09                	jmp    8008d0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c7:	89 c2                	mov    %eax,%edx
  8008c9:	eb 05                	jmp    8008d0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d0:	89 d0                	mov    %edx,%eax
  8008d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	6a 00                	push   $0x0
  8008e1:	ff 75 08             	pushl  0x8(%ebp)
  8008e4:	e8 ef 01 00 00       	call   800ad8 <open>
  8008e9:	89 c3                	mov    %eax,%ebx
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	78 1b                	js     80090d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f2:	83 ec 08             	sub    $0x8,%esp
  8008f5:	ff 75 0c             	pushl  0xc(%ebp)
  8008f8:	50                   	push   %eax
  8008f9:	e8 5b ff ff ff       	call   800859 <fstat>
  8008fe:	89 c6                	mov    %eax,%esi
	close(fd);
  800900:	89 1c 24             	mov    %ebx,(%esp)
  800903:	e8 fd fb ff ff       	call   800505 <close>
	return r;
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	89 f0                	mov    %esi,%eax
}
  80090d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	89 c6                	mov    %eax,%esi
  80091b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80091d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800924:	75 12                	jne    800938 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800926:	83 ec 0c             	sub    $0xc,%esp
  800929:	6a 01                	push   $0x1
  80092b:	e8 1c 16 00 00       	call   801f4c <ipc_find_env>
  800930:	a3 00 40 80 00       	mov    %eax,0x804000
  800935:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800938:	6a 07                	push   $0x7
  80093a:	68 00 50 80 00       	push   $0x805000
  80093f:	56                   	push   %esi
  800940:	ff 35 00 40 80 00    	pushl  0x804000
  800946:	e8 b2 15 00 00       	call   801efd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80094b:	83 c4 0c             	add    $0xc,%esp
  80094e:	6a 00                	push   $0x0
  800950:	53                   	push   %ebx
  800951:	6a 00                	push   $0x0
  800953:	e8 2f 15 00 00       	call   801e87 <ipc_recv>
}
  800958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 40 0c             	mov    0xc(%eax),%eax
  80096b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800970:	8b 45 0c             	mov    0xc(%ebp),%eax
  800973:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
  80097d:	b8 02 00 00 00       	mov    $0x2,%eax
  800982:	e8 8d ff ff ff       	call   800914 <fsipc>
}
  800987:	c9                   	leave  
  800988:	c3                   	ret    

00800989 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 40 0c             	mov    0xc(%eax),%eax
  800995:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099a:	ba 00 00 00 00       	mov    $0x0,%edx
  80099f:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a4:	e8 6b ff ff ff       	call   800914 <fsipc>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	83 ec 04             	sub    $0x4,%esp
  8009b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ca:	e8 45 ff ff ff       	call   800914 <fsipc>
  8009cf:	85 c0                	test   %eax,%eax
  8009d1:	78 2c                	js     8009ff <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d3:	83 ec 08             	sub    $0x8,%esp
  8009d6:	68 00 50 80 00       	push   $0x805000
  8009db:	53                   	push   %ebx
  8009dc:	e8 5f 11 00 00       	call   801b40 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e1:	a1 80 50 80 00       	mov    0x805080,%eax
  8009e6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ec:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009f7:	83 c4 10             	add    $0x10,%esp
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	53                   	push   %ebx
  800a08:	83 ec 08             	sub    $0x8,%esp
  800a0b:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a11:	8b 52 0c             	mov    0xc(%edx),%edx
  800a14:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a1a:	a3 04 50 80 00       	mov    %eax,0x805004
  800a1f:	3d 08 50 80 00       	cmp    $0x805008,%eax
  800a24:	bb 08 50 80 00       	mov    $0x805008,%ebx
  800a29:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a2c:	53                   	push   %ebx
  800a2d:	ff 75 0c             	pushl  0xc(%ebp)
  800a30:	68 08 50 80 00       	push   $0x805008
  800a35:	e8 98 12 00 00       	call   801cd2 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a44:	e8 cb fe ff ff       	call   800914 <fsipc>
  800a49:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  800a4c:	85 c0                	test   %eax,%eax
  800a4e:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  800a51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a54:	c9                   	leave  
  800a55:	c3                   	ret    

00800a56 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 40 0c             	mov    0xc(%eax),%eax
  800a64:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a69:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a74:	b8 03 00 00 00       	mov    $0x3,%eax
  800a79:	e8 96 fe ff ff       	call   800914 <fsipc>
  800a7e:	89 c3                	mov    %eax,%ebx
  800a80:	85 c0                	test   %eax,%eax
  800a82:	78 4b                	js     800acf <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a84:	39 c6                	cmp    %eax,%esi
  800a86:	73 16                	jae    800a9e <devfile_read+0x48>
  800a88:	68 28 23 80 00       	push   $0x802328
  800a8d:	68 2f 23 80 00       	push   $0x80232f
  800a92:	6a 7c                	push   $0x7c
  800a94:	68 44 23 80 00       	push   $0x802344
  800a99:	e8 24 0a 00 00       	call   8014c2 <_panic>
	assert(r <= PGSIZE);
  800a9e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa3:	7e 16                	jle    800abb <devfile_read+0x65>
  800aa5:	68 4f 23 80 00       	push   $0x80234f
  800aaa:	68 2f 23 80 00       	push   $0x80232f
  800aaf:	6a 7d                	push   $0x7d
  800ab1:	68 44 23 80 00       	push   $0x802344
  800ab6:	e8 07 0a 00 00       	call   8014c2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800abb:	83 ec 04             	sub    $0x4,%esp
  800abe:	50                   	push   %eax
  800abf:	68 00 50 80 00       	push   $0x805000
  800ac4:	ff 75 0c             	pushl  0xc(%ebp)
  800ac7:	e8 06 12 00 00       	call   801cd2 <memmove>
	return r;
  800acc:	83 c4 10             	add    $0x10,%esp
}
  800acf:	89 d8                	mov    %ebx,%eax
  800ad1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	53                   	push   %ebx
  800adc:	83 ec 20             	sub    $0x20,%esp
  800adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae2:	53                   	push   %ebx
  800ae3:	e8 1f 10 00 00       	call   801b07 <strlen>
  800ae8:	83 c4 10             	add    $0x10,%esp
  800aeb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af0:	7f 67                	jg     800b59 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af2:	83 ec 0c             	sub    $0xc,%esp
  800af5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af8:	50                   	push   %eax
  800af9:	e8 8e f8 ff ff       	call   80038c <fd_alloc>
  800afe:	83 c4 10             	add    $0x10,%esp
		return r;
  800b01:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	78 57                	js     800b5e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b07:	83 ec 08             	sub    $0x8,%esp
  800b0a:	53                   	push   %ebx
  800b0b:	68 00 50 80 00       	push   $0x805000
  800b10:	e8 2b 10 00 00       	call   801b40 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b18:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b20:	b8 01 00 00 00       	mov    $0x1,%eax
  800b25:	e8 ea fd ff ff       	call   800914 <fsipc>
  800b2a:	89 c3                	mov    %eax,%ebx
  800b2c:	83 c4 10             	add    $0x10,%esp
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	79 14                	jns    800b47 <open+0x6f>
		fd_close(fd, 0);
  800b33:	83 ec 08             	sub    $0x8,%esp
  800b36:	6a 00                	push   $0x0
  800b38:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3b:	e8 44 f9 ff ff       	call   800484 <fd_close>
		return r;
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	89 da                	mov    %ebx,%edx
  800b45:	eb 17                	jmp    800b5e <open+0x86>
	}

	return fd2num(fd);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4d:	e8 13 f8 ff ff       	call   800365 <fd2num>
  800b52:	89 c2                	mov    %eax,%edx
  800b54:	83 c4 10             	add    $0x10,%esp
  800b57:	eb 05                	jmp    800b5e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b59:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b5e:	89 d0                	mov    %edx,%eax
  800b60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	b8 08 00 00 00       	mov    $0x8,%eax
  800b75:	e8 9a fd ff ff       	call   800914 <fsipc>
}
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b84:	83 ec 0c             	sub    $0xc,%esp
  800b87:	ff 75 08             	pushl  0x8(%ebp)
  800b8a:	e8 e6 f7 ff ff       	call   800375 <fd2data>
  800b8f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b91:	83 c4 08             	add    $0x8,%esp
  800b94:	68 5b 23 80 00       	push   $0x80235b
  800b99:	53                   	push   %ebx
  800b9a:	e8 a1 0f 00 00       	call   801b40 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b9f:	8b 46 04             	mov    0x4(%esi),%eax
  800ba2:	2b 06                	sub    (%esi),%eax
  800ba4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800baa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb1:	00 00 00 
	stat->st_dev = &devpipe;
  800bb4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bbb:	30 80 00 
	return 0;
}
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd4:	53                   	push   %ebx
  800bd5:	6a 00                	push   $0x0
  800bd7:	e8 fe f5 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bdc:	89 1c 24             	mov    %ebx,(%esp)
  800bdf:	e8 91 f7 ff ff       	call   800375 <fd2data>
  800be4:	83 c4 08             	add    $0x8,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 00                	push   $0x0
  800bea:	e8 eb f5 ff ff       	call   8001da <sys_page_unmap>
}
  800bef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 1c             	sub    $0x1c,%esp
  800bfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c00:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c02:	a1 08 40 80 00       	mov    0x804008,%eax
  800c07:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	ff 75 e0             	pushl  -0x20(%ebp)
  800c10:	e8 70 13 00 00       	call   801f85 <pageref>
  800c15:	89 c3                	mov    %eax,%ebx
  800c17:	89 3c 24             	mov    %edi,(%esp)
  800c1a:	e8 66 13 00 00       	call   801f85 <pageref>
  800c1f:	83 c4 10             	add    $0x10,%esp
  800c22:	39 c3                	cmp    %eax,%ebx
  800c24:	0f 94 c1             	sete   %cl
  800c27:	0f b6 c9             	movzbl %cl,%ecx
  800c2a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c2d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c33:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c36:	39 ce                	cmp    %ecx,%esi
  800c38:	74 1b                	je     800c55 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c3a:	39 c3                	cmp    %eax,%ebx
  800c3c:	75 c4                	jne    800c02 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c3e:	8b 42 58             	mov    0x58(%edx),%eax
  800c41:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c44:	50                   	push   %eax
  800c45:	56                   	push   %esi
  800c46:	68 62 23 80 00       	push   $0x802362
  800c4b:	e8 4b 09 00 00       	call   80159b <cprintf>
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	eb ad                	jmp    800c02 <_pipeisclosed+0xe>
	}
}
  800c55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 28             	sub    $0x28,%esp
  800c69:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c6c:	56                   	push   %esi
  800c6d:	e8 03 f7 ff ff       	call   800375 <fd2data>
  800c72:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c74:	83 c4 10             	add    $0x10,%esp
  800c77:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7c:	eb 4b                	jmp    800cc9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c7e:	89 da                	mov    %ebx,%edx
  800c80:	89 f0                	mov    %esi,%eax
  800c82:	e8 6d ff ff ff       	call   800bf4 <_pipeisclosed>
  800c87:	85 c0                	test   %eax,%eax
  800c89:	75 48                	jne    800cd3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c8b:	e8 a6 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c90:	8b 43 04             	mov    0x4(%ebx),%eax
  800c93:	8b 0b                	mov    (%ebx),%ecx
  800c95:	8d 51 20             	lea    0x20(%ecx),%edx
  800c98:	39 d0                	cmp    %edx,%eax
  800c9a:	73 e2                	jae    800c7e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca6:	89 c2                	mov    %eax,%edx
  800ca8:	c1 fa 1f             	sar    $0x1f,%edx
  800cab:	89 d1                	mov    %edx,%ecx
  800cad:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb3:	83 e2 1f             	and    $0x1f,%edx
  800cb6:	29 ca                	sub    %ecx,%edx
  800cb8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cbc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc0:	83 c0 01             	add    $0x1,%eax
  800cc3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc6:	83 c7 01             	add    $0x1,%edi
  800cc9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ccc:	75 c2                	jne    800c90 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cce:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd1:	eb 05                	jmp    800cd8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 18             	sub    $0x18,%esp
  800ce9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cec:	57                   	push   %edi
  800ced:	e8 83 f6 ff ff       	call   800375 <fd2data>
  800cf2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf4:	83 c4 10             	add    $0x10,%esp
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	eb 3d                	jmp    800d3b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cfe:	85 db                	test   %ebx,%ebx
  800d00:	74 04                	je     800d06 <devpipe_read+0x26>
				return i;
  800d02:	89 d8                	mov    %ebx,%eax
  800d04:	eb 44                	jmp    800d4a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d06:	89 f2                	mov    %esi,%edx
  800d08:	89 f8                	mov    %edi,%eax
  800d0a:	e8 e5 fe ff ff       	call   800bf4 <_pipeisclosed>
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	75 32                	jne    800d45 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d13:	e8 1e f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d18:	8b 06                	mov    (%esi),%eax
  800d1a:	3b 46 04             	cmp    0x4(%esi),%eax
  800d1d:	74 df                	je     800cfe <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d1f:	99                   	cltd   
  800d20:	c1 ea 1b             	shr    $0x1b,%edx
  800d23:	01 d0                	add    %edx,%eax
  800d25:	83 e0 1f             	and    $0x1f,%eax
  800d28:	29 d0                	sub    %edx,%eax
  800d2a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d35:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d38:	83 c3 01             	add    $0x1,%ebx
  800d3b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d3e:	75 d8                	jne    800d18 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d40:	8b 45 10             	mov    0x10(%ebp),%eax
  800d43:	eb 05                	jmp    800d4a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d45:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
  800d57:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5d:	50                   	push   %eax
  800d5e:	e8 29 f6 ff ff       	call   80038c <fd_alloc>
  800d63:	83 c4 10             	add    $0x10,%esp
  800d66:	89 c2                	mov    %eax,%edx
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	0f 88 2c 01 00 00    	js     800e9c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d70:	83 ec 04             	sub    $0x4,%esp
  800d73:	68 07 04 00 00       	push   $0x407
  800d78:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7b:	6a 00                	push   $0x0
  800d7d:	e8 d3 f3 ff ff       	call   800155 <sys_page_alloc>
  800d82:	83 c4 10             	add    $0x10,%esp
  800d85:	89 c2                	mov    %eax,%edx
  800d87:	85 c0                	test   %eax,%eax
  800d89:	0f 88 0d 01 00 00    	js     800e9c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d95:	50                   	push   %eax
  800d96:	e8 f1 f5 ff ff       	call   80038c <fd_alloc>
  800d9b:	89 c3                	mov    %eax,%ebx
  800d9d:	83 c4 10             	add    $0x10,%esp
  800da0:	85 c0                	test   %eax,%eax
  800da2:	0f 88 e2 00 00 00    	js     800e8a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da8:	83 ec 04             	sub    $0x4,%esp
  800dab:	68 07 04 00 00       	push   $0x407
  800db0:	ff 75 f0             	pushl  -0x10(%ebp)
  800db3:	6a 00                	push   $0x0
  800db5:	e8 9b f3 ff ff       	call   800155 <sys_page_alloc>
  800dba:	89 c3                	mov    %eax,%ebx
  800dbc:	83 c4 10             	add    $0x10,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	0f 88 c3 00 00 00    	js     800e8a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	ff 75 f4             	pushl  -0xc(%ebp)
  800dcd:	e8 a3 f5 ff ff       	call   800375 <fd2data>
  800dd2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd4:	83 c4 0c             	add    $0xc,%esp
  800dd7:	68 07 04 00 00       	push   $0x407
  800ddc:	50                   	push   %eax
  800ddd:	6a 00                	push   $0x0
  800ddf:	e8 71 f3 ff ff       	call   800155 <sys_page_alloc>
  800de4:	89 c3                	mov    %eax,%ebx
  800de6:	83 c4 10             	add    $0x10,%esp
  800de9:	85 c0                	test   %eax,%eax
  800deb:	0f 88 89 00 00 00    	js     800e7a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	ff 75 f0             	pushl  -0x10(%ebp)
  800df7:	e8 79 f5 ff ff       	call   800375 <fd2data>
  800dfc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e03:	50                   	push   %eax
  800e04:	6a 00                	push   $0x0
  800e06:	56                   	push   %esi
  800e07:	6a 00                	push   $0x0
  800e09:	e8 8a f3 ff ff       	call   800198 <sys_page_map>
  800e0e:	89 c3                	mov    %eax,%ebx
  800e10:	83 c4 20             	add    $0x20,%esp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	78 55                	js     800e6c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e17:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e20:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e25:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e2c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e35:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e41:	83 ec 0c             	sub    $0xc,%esp
  800e44:	ff 75 f4             	pushl  -0xc(%ebp)
  800e47:	e8 19 f5 ff ff       	call   800365 <fd2num>
  800e4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e51:	83 c4 04             	add    $0x4,%esp
  800e54:	ff 75 f0             	pushl  -0x10(%ebp)
  800e57:	e8 09 f5 ff ff       	call   800365 <fd2num>
  800e5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6a:	eb 30                	jmp    800e9c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e6c:	83 ec 08             	sub    $0x8,%esp
  800e6f:	56                   	push   %esi
  800e70:	6a 00                	push   $0x0
  800e72:	e8 63 f3 ff ff       	call   8001da <sys_page_unmap>
  800e77:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e7a:	83 ec 08             	sub    $0x8,%esp
  800e7d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e80:	6a 00                	push   $0x0
  800e82:	e8 53 f3 ff ff       	call   8001da <sys_page_unmap>
  800e87:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e8a:	83 ec 08             	sub    $0x8,%esp
  800e8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e90:	6a 00                	push   $0x0
  800e92:	e8 43 f3 ff ff       	call   8001da <sys_page_unmap>
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e9c:	89 d0                	mov    %edx,%eax
  800e9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eae:	50                   	push   %eax
  800eaf:	ff 75 08             	pushl  0x8(%ebp)
  800eb2:	e8 24 f5 ff ff       	call   8003db <fd_lookup>
  800eb7:	83 c4 10             	add    $0x10,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	78 18                	js     800ed6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ebe:	83 ec 0c             	sub    $0xc,%esp
  800ec1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec4:	e8 ac f4 ff ff       	call   800375 <fd2data>
	return _pipeisclosed(fd, p);
  800ec9:	89 c2                	mov    %eax,%edx
  800ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ece:	e8 21 fd ff ff       	call   800bf4 <_pipeisclosed>
  800ed3:	83 c4 10             	add    $0x10,%esp
}
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ede:	68 7a 23 80 00       	push   $0x80237a
  800ee3:	ff 75 0c             	pushl  0xc(%ebp)
  800ee6:	e8 55 0c 00 00       	call   801b40 <strcpy>
	return 0;
}
  800eeb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 10             	sub    $0x10,%esp
  800ef9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800efc:	53                   	push   %ebx
  800efd:	e8 83 10 00 00       	call   801f85 <pageref>
  800f02:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800f05:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800f0a:	83 f8 01             	cmp    $0x1,%eax
  800f0d:	75 10                	jne    800f1f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	ff 73 0c             	pushl  0xc(%ebx)
  800f15:	e8 c0 02 00 00       	call   8011da <nsipc_close>
  800f1a:	89 c2                	mov    %eax,%edx
  800f1c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f1f:	89 d0                	mov    %edx,%eax
  800f21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f2c:	6a 00                	push   $0x0
  800f2e:	ff 75 10             	pushl  0x10(%ebp)
  800f31:	ff 75 0c             	pushl  0xc(%ebp)
  800f34:	8b 45 08             	mov    0x8(%ebp),%eax
  800f37:	ff 70 0c             	pushl  0xc(%eax)
  800f3a:	e8 78 03 00 00       	call   8012b7 <nsipc_send>
}
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f47:	6a 00                	push   $0x0
  800f49:	ff 75 10             	pushl  0x10(%ebp)
  800f4c:	ff 75 0c             	pushl  0xc(%ebp)
  800f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f52:	ff 70 0c             	pushl  0xc(%eax)
  800f55:	e8 f1 02 00 00       	call   80124b <nsipc_recv>
}
  800f5a:	c9                   	leave  
  800f5b:	c3                   	ret    

00800f5c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f62:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f65:	52                   	push   %edx
  800f66:	50                   	push   %eax
  800f67:	e8 6f f4 ff ff       	call   8003db <fd_lookup>
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 17                	js     800f8a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f76:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  800f7c:	39 08                	cmp    %ecx,(%eax)
  800f7e:	75 05                	jne    800f85 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f80:	8b 40 0c             	mov    0xc(%eax),%eax
  800f83:	eb 05                	jmp    800f8a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800f85:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
  800f91:	83 ec 1c             	sub    $0x1c,%esp
  800f94:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800f96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f99:	50                   	push   %eax
  800f9a:	e8 ed f3 ff ff       	call   80038c <fd_alloc>
  800f9f:	89 c3                	mov    %eax,%ebx
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 1b                	js     800fc3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	68 07 04 00 00       	push   $0x407
  800fb0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 9b f1 ff ff       	call   800155 <sys_page_alloc>
  800fba:	89 c3                	mov    %eax,%ebx
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	79 10                	jns    800fd3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	56                   	push   %esi
  800fc7:	e8 0e 02 00 00       	call   8011da <nsipc_close>
		return r;
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	89 d8                	mov    %ebx,%eax
  800fd1:	eb 24                	jmp    800ff7 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800fd3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800fe8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	50                   	push   %eax
  800fef:	e8 71 f3 ff ff       	call   800365 <fd2num>
  800ff4:	83 c4 10             	add    $0x10,%esp
}
  800ff7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ffa:	5b                   	pop    %ebx
  800ffb:	5e                   	pop    %esi
  800ffc:	5d                   	pop    %ebp
  800ffd:	c3                   	ret    

00800ffe <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801004:	8b 45 08             	mov    0x8(%ebp),%eax
  801007:	e8 50 ff ff ff       	call   800f5c <fd2sockid>
		return r;
  80100c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 1f                	js     801031 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801012:	83 ec 04             	sub    $0x4,%esp
  801015:	ff 75 10             	pushl  0x10(%ebp)
  801018:	ff 75 0c             	pushl  0xc(%ebp)
  80101b:	50                   	push   %eax
  80101c:	e8 12 01 00 00       	call   801133 <nsipc_accept>
  801021:	83 c4 10             	add    $0x10,%esp
		return r;
  801024:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801026:	85 c0                	test   %eax,%eax
  801028:	78 07                	js     801031 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80102a:	e8 5d ff ff ff       	call   800f8c <alloc_sockfd>
  80102f:	89 c1                	mov    %eax,%ecx
}
  801031:	89 c8                	mov    %ecx,%eax
  801033:	c9                   	leave  
  801034:	c3                   	ret    

00801035 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
  80103e:	e8 19 ff ff ff       	call   800f5c <fd2sockid>
  801043:	85 c0                	test   %eax,%eax
  801045:	78 12                	js     801059 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801047:	83 ec 04             	sub    $0x4,%esp
  80104a:	ff 75 10             	pushl  0x10(%ebp)
  80104d:	ff 75 0c             	pushl  0xc(%ebp)
  801050:	50                   	push   %eax
  801051:	e8 2d 01 00 00       	call   801183 <nsipc_bind>
  801056:	83 c4 10             	add    $0x10,%esp
}
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <shutdown>:

int
shutdown(int s, int how)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
  801064:	e8 f3 fe ff ff       	call   800f5c <fd2sockid>
  801069:	85 c0                	test   %eax,%eax
  80106b:	78 0f                	js     80107c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80106d:	83 ec 08             	sub    $0x8,%esp
  801070:	ff 75 0c             	pushl  0xc(%ebp)
  801073:	50                   	push   %eax
  801074:	e8 3f 01 00 00       	call   8011b8 <nsipc_shutdown>
  801079:	83 c4 10             	add    $0x10,%esp
}
  80107c:	c9                   	leave  
  80107d:	c3                   	ret    

0080107e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801084:	8b 45 08             	mov    0x8(%ebp),%eax
  801087:	e8 d0 fe ff ff       	call   800f5c <fd2sockid>
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 12                	js     8010a2 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801090:	83 ec 04             	sub    $0x4,%esp
  801093:	ff 75 10             	pushl  0x10(%ebp)
  801096:	ff 75 0c             	pushl  0xc(%ebp)
  801099:	50                   	push   %eax
  80109a:	e8 55 01 00 00       	call   8011f4 <nsipc_connect>
  80109f:	83 c4 10             	add    $0x10,%esp
}
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    

008010a4 <listen>:

int
listen(int s, int backlog)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ad:	e8 aa fe ff ff       	call   800f5c <fd2sockid>
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	78 0f                	js     8010c5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8010b6:	83 ec 08             	sub    $0x8,%esp
  8010b9:	ff 75 0c             	pushl  0xc(%ebp)
  8010bc:	50                   	push   %eax
  8010bd:	e8 67 01 00 00       	call   801229 <nsipc_listen>
  8010c2:	83 c4 10             	add    $0x10,%esp
}
  8010c5:	c9                   	leave  
  8010c6:	c3                   	ret    

008010c7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8010cd:	ff 75 10             	pushl  0x10(%ebp)
  8010d0:	ff 75 0c             	pushl  0xc(%ebp)
  8010d3:	ff 75 08             	pushl  0x8(%ebp)
  8010d6:	e8 3a 02 00 00       	call   801315 <nsipc_socket>
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 05                	js     8010e7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8010e2:	e8 a5 fe ff ff       	call   800f8c <alloc_sockfd>
}
  8010e7:	c9                   	leave  
  8010e8:	c3                   	ret    

008010e9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 04             	sub    $0x4,%esp
  8010f0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8010f2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8010f9:	75 12                	jne    80110d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	6a 02                	push   $0x2
  801100:	e8 47 0e 00 00       	call   801f4c <ipc_find_env>
  801105:	a3 04 40 80 00       	mov    %eax,0x804004
  80110a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80110d:	6a 07                	push   $0x7
  80110f:	68 00 60 80 00       	push   $0x806000
  801114:	53                   	push   %ebx
  801115:	ff 35 04 40 80 00    	pushl  0x804004
  80111b:	e8 dd 0d 00 00       	call   801efd <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801120:	83 c4 0c             	add    $0xc,%esp
  801123:	6a 00                	push   $0x0
  801125:	6a 00                	push   $0x0
  801127:	6a 00                	push   $0x0
  801129:	e8 59 0d 00 00       	call   801e87 <ipc_recv>
}
  80112e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801131:	c9                   	leave  
  801132:	c3                   	ret    

00801133 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
  80113e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801143:	8b 06                	mov    (%esi),%eax
  801145:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80114a:	b8 01 00 00 00       	mov    $0x1,%eax
  80114f:	e8 95 ff ff ff       	call   8010e9 <nsipc>
  801154:	89 c3                	mov    %eax,%ebx
  801156:	85 c0                	test   %eax,%eax
  801158:	78 20                	js     80117a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80115a:	83 ec 04             	sub    $0x4,%esp
  80115d:	ff 35 10 60 80 00    	pushl  0x806010
  801163:	68 00 60 80 00       	push   $0x806000
  801168:	ff 75 0c             	pushl  0xc(%ebp)
  80116b:	e8 62 0b 00 00       	call   801cd2 <memmove>
		*addrlen = ret->ret_addrlen;
  801170:	a1 10 60 80 00       	mov    0x806010,%eax
  801175:	89 06                	mov    %eax,(%esi)
  801177:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80117a:	89 d8                	mov    %ebx,%eax
  80117c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	53                   	push   %ebx
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80118d:	8b 45 08             	mov    0x8(%ebp),%eax
  801190:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801195:	53                   	push   %ebx
  801196:	ff 75 0c             	pushl  0xc(%ebp)
  801199:	68 04 60 80 00       	push   $0x806004
  80119e:	e8 2f 0b 00 00       	call   801cd2 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8011a3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8011a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8011ae:	e8 36 ff ff ff       	call   8010e9 <nsipc>
}
  8011b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b6:	c9                   	leave  
  8011b7:	c3                   	ret    

008011b8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011be:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8011c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8011ce:	b8 03 00 00 00       	mov    $0x3,%eax
  8011d3:	e8 11 ff ff ff       	call   8010e9 <nsipc>
}
  8011d8:	c9                   	leave  
  8011d9:	c3                   	ret    

008011da <nsipc_close>:

int
nsipc_close(int s)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8011e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8011e8:	b8 04 00 00 00       	mov    $0x4,%eax
  8011ed:	e8 f7 fe ff ff       	call   8010e9 <nsipc>
}
  8011f2:	c9                   	leave  
  8011f3:	c3                   	ret    

008011f4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8011fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801201:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801206:	53                   	push   %ebx
  801207:	ff 75 0c             	pushl  0xc(%ebp)
  80120a:	68 04 60 80 00       	push   $0x806004
  80120f:	e8 be 0a 00 00       	call   801cd2 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801214:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80121a:	b8 05 00 00 00       	mov    $0x5,%eax
  80121f:	e8 c5 fe ff ff       	call   8010e9 <nsipc>
}
  801224:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801227:	c9                   	leave  
  801228:	c3                   	ret    

00801229 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80123f:	b8 06 00 00 00       	mov    $0x6,%eax
  801244:	e8 a0 fe ff ff       	call   8010e9 <nsipc>
}
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
  801250:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80125b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801261:	8b 45 14             	mov    0x14(%ebp),%eax
  801264:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801269:	b8 07 00 00 00       	mov    $0x7,%eax
  80126e:	e8 76 fe ff ff       	call   8010e9 <nsipc>
  801273:	89 c3                	mov    %eax,%ebx
  801275:	85 c0                	test   %eax,%eax
  801277:	78 35                	js     8012ae <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801279:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80127e:	7f 04                	jg     801284 <nsipc_recv+0x39>
  801280:	39 c6                	cmp    %eax,%esi
  801282:	7d 16                	jge    80129a <nsipc_recv+0x4f>
  801284:	68 86 23 80 00       	push   $0x802386
  801289:	68 2f 23 80 00       	push   $0x80232f
  80128e:	6a 62                	push   $0x62
  801290:	68 9b 23 80 00       	push   $0x80239b
  801295:	e8 28 02 00 00       	call   8014c2 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80129a:	83 ec 04             	sub    $0x4,%esp
  80129d:	50                   	push   %eax
  80129e:	68 00 60 80 00       	push   $0x806000
  8012a3:	ff 75 0c             	pushl  0xc(%ebp)
  8012a6:	e8 27 0a 00 00       	call   801cd2 <memmove>
  8012ab:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8012ae:	89 d8                	mov    %ebx,%eax
  8012b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b3:	5b                   	pop    %ebx
  8012b4:	5e                   	pop    %esi
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    

008012b7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	53                   	push   %ebx
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8012c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8012c9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8012cf:	7e 16                	jle    8012e7 <nsipc_send+0x30>
  8012d1:	68 a7 23 80 00       	push   $0x8023a7
  8012d6:	68 2f 23 80 00       	push   $0x80232f
  8012db:	6a 6d                	push   $0x6d
  8012dd:	68 9b 23 80 00       	push   $0x80239b
  8012e2:	e8 db 01 00 00       	call   8014c2 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8012e7:	83 ec 04             	sub    $0x4,%esp
  8012ea:	53                   	push   %ebx
  8012eb:	ff 75 0c             	pushl  0xc(%ebp)
  8012ee:	68 0c 60 80 00       	push   $0x80600c
  8012f3:	e8 da 09 00 00       	call   801cd2 <memmove>
	nsipcbuf.send.req_size = size;
  8012f8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8012fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801301:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801306:	b8 08 00 00 00       	mov    $0x8,%eax
  80130b:	e8 d9 fd ff ff       	call   8010e9 <nsipc>
}
  801310:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801313:	c9                   	leave  
  801314:	c3                   	ret    

00801315 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80131b:	8b 45 08             	mov    0x8(%ebp),%eax
  80131e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801323:	8b 45 0c             	mov    0xc(%ebp),%eax
  801326:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80132b:	8b 45 10             	mov    0x10(%ebp),%eax
  80132e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801333:	b8 09 00 00 00       	mov    $0x9,%eax
  801338:	e8 ac fd ff ff       	call   8010e9 <nsipc>
}
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801342:	b8 00 00 00 00       	mov    $0x0,%eax
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80134f:	68 b3 23 80 00       	push   $0x8023b3
  801354:	ff 75 0c             	pushl  0xc(%ebp)
  801357:	e8 e4 07 00 00       	call   801b40 <strcpy>
	return 0;
}
  80135c:	b8 00 00 00 00       	mov    $0x0,%eax
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	57                   	push   %edi
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80136f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801374:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80137a:	eb 2d                	jmp    8013a9 <devcons_write+0x46>
		m = n - tot;
  80137c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80137f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801381:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801384:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801389:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80138c:	83 ec 04             	sub    $0x4,%esp
  80138f:	53                   	push   %ebx
  801390:	03 45 0c             	add    0xc(%ebp),%eax
  801393:	50                   	push   %eax
  801394:	57                   	push   %edi
  801395:	e8 38 09 00 00       	call   801cd2 <memmove>
		sys_cputs(buf, m);
  80139a:	83 c4 08             	add    $0x8,%esp
  80139d:	53                   	push   %ebx
  80139e:	57                   	push   %edi
  80139f:	e8 f5 ec ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a4:	01 de                	add    %ebx,%esi
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	89 f0                	mov    %esi,%eax
  8013ab:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013ae:	72 cc                	jb     80137c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b3:	5b                   	pop    %ebx
  8013b4:	5e                   	pop    %esi
  8013b5:	5f                   	pop    %edi
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013c7:	74 2a                	je     8013f3 <devcons_read+0x3b>
  8013c9:	eb 05                	jmp    8013d0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013cb:	e8 66 ed ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013d0:	e8 e2 ec ff ff       	call   8000b7 <sys_cgetc>
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	74 f2                	je     8013cb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 16                	js     8013f3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013dd:	83 f8 04             	cmp    $0x4,%eax
  8013e0:	74 0c                	je     8013ee <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e5:	88 02                	mov    %al,(%edx)
	return 1;
  8013e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ec:	eb 05                	jmp    8013f3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013ee:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013f3:	c9                   	leave  
  8013f4:	c3                   	ret    

008013f5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801401:	6a 01                	push   $0x1
  801403:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801406:	50                   	push   %eax
  801407:	e8 8d ec ff ff       	call   800099 <sys_cputs>
}
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <getchar>:

int
getchar(void)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801417:	6a 01                	push   $0x1
  801419:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80141c:	50                   	push   %eax
  80141d:	6a 00                	push   $0x0
  80141f:	e8 1d f2 ff ff       	call   800641 <read>
	if (r < 0)
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	85 c0                	test   %eax,%eax
  801429:	78 0f                	js     80143a <getchar+0x29>
		return r;
	if (r < 1)
  80142b:	85 c0                	test   %eax,%eax
  80142d:	7e 06                	jle    801435 <getchar+0x24>
		return -E_EOF;
	return c;
  80142f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801433:	eb 05                	jmp    80143a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801435:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801442:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	ff 75 08             	pushl  0x8(%ebp)
  801449:	e8 8d ef ff ff       	call   8003db <fd_lookup>
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	78 11                	js     801466 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801455:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801458:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80145e:	39 10                	cmp    %edx,(%eax)
  801460:	0f 94 c0             	sete   %al
  801463:	0f b6 c0             	movzbl %al,%eax
}
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <opencons>:

int
opencons(void)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80146e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	e8 15 ef ff ff       	call   80038c <fd_alloc>
  801477:	83 c4 10             	add    $0x10,%esp
		return r;
  80147a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 3e                	js     8014be <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801480:	83 ec 04             	sub    $0x4,%esp
  801483:	68 07 04 00 00       	push   $0x407
  801488:	ff 75 f4             	pushl  -0xc(%ebp)
  80148b:	6a 00                	push   $0x0
  80148d:	e8 c3 ec ff ff       	call   800155 <sys_page_alloc>
  801492:	83 c4 10             	add    $0x10,%esp
		return r;
  801495:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801497:	85 c0                	test   %eax,%eax
  801499:	78 23                	js     8014be <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80149b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014b0:	83 ec 0c             	sub    $0xc,%esp
  8014b3:	50                   	push   %eax
  8014b4:	e8 ac ee ff ff       	call   800365 <fd2num>
  8014b9:	89 c2                	mov    %eax,%edx
  8014bb:	83 c4 10             	add    $0x10,%esp
}
  8014be:	89 d0                	mov    %edx,%eax
  8014c0:	c9                   	leave  
  8014c1:	c3                   	ret    

008014c2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	56                   	push   %esi
  8014c6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014c7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014ca:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014d0:	e8 42 ec ff ff       	call   800117 <sys_getenvid>
  8014d5:	83 ec 0c             	sub    $0xc,%esp
  8014d8:	ff 75 0c             	pushl  0xc(%ebp)
  8014db:	ff 75 08             	pushl  0x8(%ebp)
  8014de:	56                   	push   %esi
  8014df:	50                   	push   %eax
  8014e0:	68 c0 23 80 00       	push   $0x8023c0
  8014e5:	e8 b1 00 00 00       	call   80159b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014ea:	83 c4 18             	add    $0x18,%esp
  8014ed:	53                   	push   %ebx
  8014ee:	ff 75 10             	pushl  0x10(%ebp)
  8014f1:	e8 54 00 00 00       	call   80154a <vcprintf>
	cprintf("\n");
  8014f6:	c7 04 24 73 23 80 00 	movl   $0x802373,(%esp)
  8014fd:	e8 99 00 00 00       	call   80159b <cprintf>
  801502:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801505:	cc                   	int3   
  801506:	eb fd                	jmp    801505 <_panic+0x43>

00801508 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	53                   	push   %ebx
  80150c:	83 ec 04             	sub    $0x4,%esp
  80150f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801512:	8b 13                	mov    (%ebx),%edx
  801514:	8d 42 01             	lea    0x1(%edx),%eax
  801517:	89 03                	mov    %eax,(%ebx)
  801519:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80151c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801520:	3d ff 00 00 00       	cmp    $0xff,%eax
  801525:	75 1a                	jne    801541 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801527:	83 ec 08             	sub    $0x8,%esp
  80152a:	68 ff 00 00 00       	push   $0xff
  80152f:	8d 43 08             	lea    0x8(%ebx),%eax
  801532:	50                   	push   %eax
  801533:	e8 61 eb ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  801538:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80153e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801541:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801545:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801553:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80155a:	00 00 00 
	b.cnt = 0;
  80155d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801564:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801567:	ff 75 0c             	pushl  0xc(%ebp)
  80156a:	ff 75 08             	pushl  0x8(%ebp)
  80156d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801573:	50                   	push   %eax
  801574:	68 08 15 80 00       	push   $0x801508
  801579:	e8 54 01 00 00       	call   8016d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80157e:	83 c4 08             	add    $0x8,%esp
  801581:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801587:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	e8 06 eb ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  801593:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015a1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015a4:	50                   	push   %eax
  8015a5:	ff 75 08             	pushl  0x8(%ebp)
  8015a8:	e8 9d ff ff ff       	call   80154a <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	57                   	push   %edi
  8015b3:	56                   	push   %esi
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 1c             	sub    $0x1c,%esp
  8015b8:	89 c7                	mov    %eax,%edi
  8015ba:	89 d6                	mov    %edx,%esi
  8015bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015d3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015d6:	39 d3                	cmp    %edx,%ebx
  8015d8:	72 05                	jb     8015df <printnum+0x30>
  8015da:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015dd:	77 45                	ja     801624 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015df:	83 ec 0c             	sub    $0xc,%esp
  8015e2:	ff 75 18             	pushl  0x18(%ebp)
  8015e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015eb:	53                   	push   %ebx
  8015ec:	ff 75 10             	pushl  0x10(%ebp)
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f8:	ff 75 dc             	pushl  -0x24(%ebp)
  8015fb:	ff 75 d8             	pushl  -0x28(%ebp)
  8015fe:	e8 bd 09 00 00       	call   801fc0 <__udivdi3>
  801603:	83 c4 18             	add    $0x18,%esp
  801606:	52                   	push   %edx
  801607:	50                   	push   %eax
  801608:	89 f2                	mov    %esi,%edx
  80160a:	89 f8                	mov    %edi,%eax
  80160c:	e8 9e ff ff ff       	call   8015af <printnum>
  801611:	83 c4 20             	add    $0x20,%esp
  801614:	eb 18                	jmp    80162e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	56                   	push   %esi
  80161a:	ff 75 18             	pushl  0x18(%ebp)
  80161d:	ff d7                	call   *%edi
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	eb 03                	jmp    801627 <printnum+0x78>
  801624:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801627:	83 eb 01             	sub    $0x1,%ebx
  80162a:	85 db                	test   %ebx,%ebx
  80162c:	7f e8                	jg     801616 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80162e:	83 ec 08             	sub    $0x8,%esp
  801631:	56                   	push   %esi
  801632:	83 ec 04             	sub    $0x4,%esp
  801635:	ff 75 e4             	pushl  -0x1c(%ebp)
  801638:	ff 75 e0             	pushl  -0x20(%ebp)
  80163b:	ff 75 dc             	pushl  -0x24(%ebp)
  80163e:	ff 75 d8             	pushl  -0x28(%ebp)
  801641:	e8 aa 0a 00 00       	call   8020f0 <__umoddi3>
  801646:	83 c4 14             	add    $0x14,%esp
  801649:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801650:	50                   	push   %eax
  801651:	ff d7                	call   *%edi
}
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801659:	5b                   	pop    %ebx
  80165a:	5e                   	pop    %esi
  80165b:	5f                   	pop    %edi
  80165c:	5d                   	pop    %ebp
  80165d:	c3                   	ret    

0080165e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801661:	83 fa 01             	cmp    $0x1,%edx
  801664:	7e 0e                	jle    801674 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801666:	8b 10                	mov    (%eax),%edx
  801668:	8d 4a 08             	lea    0x8(%edx),%ecx
  80166b:	89 08                	mov    %ecx,(%eax)
  80166d:	8b 02                	mov    (%edx),%eax
  80166f:	8b 52 04             	mov    0x4(%edx),%edx
  801672:	eb 22                	jmp    801696 <getuint+0x38>
	else if (lflag)
  801674:	85 d2                	test   %edx,%edx
  801676:	74 10                	je     801688 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801678:	8b 10                	mov    (%eax),%edx
  80167a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80167d:	89 08                	mov    %ecx,(%eax)
  80167f:	8b 02                	mov    (%edx),%eax
  801681:	ba 00 00 00 00       	mov    $0x0,%edx
  801686:	eb 0e                	jmp    801696 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801688:	8b 10                	mov    (%eax),%edx
  80168a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80168d:	89 08                	mov    %ecx,(%eax)
  80168f:	8b 02                	mov    (%edx),%eax
  801691:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80169e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016a2:	8b 10                	mov    (%eax),%edx
  8016a4:	3b 50 04             	cmp    0x4(%eax),%edx
  8016a7:	73 0a                	jae    8016b3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016a9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016ac:	89 08                	mov    %ecx,(%eax)
  8016ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b1:	88 02                	mov    %al,(%edx)
}
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016bb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016be:	50                   	push   %eax
  8016bf:	ff 75 10             	pushl  0x10(%ebp)
  8016c2:	ff 75 0c             	pushl  0xc(%ebp)
  8016c5:	ff 75 08             	pushl  0x8(%ebp)
  8016c8:	e8 05 00 00 00       	call   8016d2 <vprintfmt>
	va_end(ap);
}
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	c9                   	leave  
  8016d1:	c3                   	ret    

008016d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	57                   	push   %edi
  8016d6:	56                   	push   %esi
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 2c             	sub    $0x2c,%esp
  8016db:	8b 75 08             	mov    0x8(%ebp),%esi
  8016de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016e1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016e4:	eb 12                	jmp    8016f8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	0f 84 a9 03 00 00    	je     801a97 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	53                   	push   %ebx
  8016f2:	50                   	push   %eax
  8016f3:	ff d6                	call   *%esi
  8016f5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016f8:	83 c7 01             	add    $0x1,%edi
  8016fb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016ff:	83 f8 25             	cmp    $0x25,%eax
  801702:	75 e2                	jne    8016e6 <vprintfmt+0x14>
  801704:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801708:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80170f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801716:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80171d:	ba 00 00 00 00       	mov    $0x0,%edx
  801722:	eb 07                	jmp    80172b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801724:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801727:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80172b:	8d 47 01             	lea    0x1(%edi),%eax
  80172e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801731:	0f b6 07             	movzbl (%edi),%eax
  801734:	0f b6 c8             	movzbl %al,%ecx
  801737:	83 e8 23             	sub    $0x23,%eax
  80173a:	3c 55                	cmp    $0x55,%al
  80173c:	0f 87 3a 03 00 00    	ja     801a7c <vprintfmt+0x3aa>
  801742:	0f b6 c0             	movzbl %al,%eax
  801745:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80174c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80174f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801753:	eb d6                	jmp    80172b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801755:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801758:	b8 00 00 00 00       	mov    $0x0,%eax
  80175d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801760:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801763:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801767:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80176a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80176d:	83 fa 09             	cmp    $0x9,%edx
  801770:	77 39                	ja     8017ab <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801772:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801775:	eb e9                	jmp    801760 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801777:	8b 45 14             	mov    0x14(%ebp),%eax
  80177a:	8d 48 04             	lea    0x4(%eax),%ecx
  80177d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801780:	8b 00                	mov    (%eax),%eax
  801782:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801788:	eb 27                	jmp    8017b1 <vprintfmt+0xdf>
  80178a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80178d:	85 c0                	test   %eax,%eax
  80178f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801794:	0f 49 c8             	cmovns %eax,%ecx
  801797:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80179a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80179d:	eb 8c                	jmp    80172b <vprintfmt+0x59>
  80179f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017a2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017a9:	eb 80                	jmp    80172b <vprintfmt+0x59>
  8017ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017ae:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017b5:	0f 89 70 ff ff ff    	jns    80172b <vprintfmt+0x59>
				width = precision, precision = -1;
  8017bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017c1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017c8:	e9 5e ff ff ff       	jmp    80172b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017cd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017d3:	e9 53 ff ff ff       	jmp    80172b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8017db:	8d 50 04             	lea    0x4(%eax),%edx
  8017de:	89 55 14             	mov    %edx,0x14(%ebp)
  8017e1:	83 ec 08             	sub    $0x8,%esp
  8017e4:	53                   	push   %ebx
  8017e5:	ff 30                	pushl  (%eax)
  8017e7:	ff d6                	call   *%esi
			break;
  8017e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017ef:	e9 04 ff ff ff       	jmp    8016f8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f7:	8d 50 04             	lea    0x4(%eax),%edx
  8017fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8017fd:	8b 00                	mov    (%eax),%eax
  8017ff:	99                   	cltd   
  801800:	31 d0                	xor    %edx,%eax
  801802:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801804:	83 f8 0f             	cmp    $0xf,%eax
  801807:	7f 0b                	jg     801814 <vprintfmt+0x142>
  801809:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801810:	85 d2                	test   %edx,%edx
  801812:	75 18                	jne    80182c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801814:	50                   	push   %eax
  801815:	68 fb 23 80 00       	push   $0x8023fb
  80181a:	53                   	push   %ebx
  80181b:	56                   	push   %esi
  80181c:	e8 94 fe ff ff       	call   8016b5 <printfmt>
  801821:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801824:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801827:	e9 cc fe ff ff       	jmp    8016f8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80182c:	52                   	push   %edx
  80182d:	68 41 23 80 00       	push   $0x802341
  801832:	53                   	push   %ebx
  801833:	56                   	push   %esi
  801834:	e8 7c fe ff ff       	call   8016b5 <printfmt>
  801839:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80183f:	e9 b4 fe ff ff       	jmp    8016f8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801844:	8b 45 14             	mov    0x14(%ebp),%eax
  801847:	8d 50 04             	lea    0x4(%eax),%edx
  80184a:	89 55 14             	mov    %edx,0x14(%ebp)
  80184d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80184f:	85 ff                	test   %edi,%edi
  801851:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  801856:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801859:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80185d:	0f 8e 94 00 00 00    	jle    8018f7 <vprintfmt+0x225>
  801863:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801867:	0f 84 98 00 00 00    	je     801905 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	ff 75 d0             	pushl  -0x30(%ebp)
  801873:	57                   	push   %edi
  801874:	e8 a6 02 00 00       	call   801b1f <strnlen>
  801879:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80187c:	29 c1                	sub    %eax,%ecx
  80187e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801881:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801884:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801888:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80188b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80188e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801890:	eb 0f                	jmp    8018a1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	53                   	push   %ebx
  801896:	ff 75 e0             	pushl  -0x20(%ebp)
  801899:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80189b:	83 ef 01             	sub    $0x1,%edi
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	85 ff                	test   %edi,%edi
  8018a3:	7f ed                	jg     801892 <vprintfmt+0x1c0>
  8018a5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018a8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018ab:	85 c9                	test   %ecx,%ecx
  8018ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b2:	0f 49 c1             	cmovns %ecx,%eax
  8018b5:	29 c1                	sub    %eax,%ecx
  8018b7:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ba:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018bd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018c0:	89 cb                	mov    %ecx,%ebx
  8018c2:	eb 4d                	jmp    801911 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018c4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018c8:	74 1b                	je     8018e5 <vprintfmt+0x213>
  8018ca:	0f be c0             	movsbl %al,%eax
  8018cd:	83 e8 20             	sub    $0x20,%eax
  8018d0:	83 f8 5e             	cmp    $0x5e,%eax
  8018d3:	76 10                	jbe    8018e5 <vprintfmt+0x213>
					putch('?', putdat);
  8018d5:	83 ec 08             	sub    $0x8,%esp
  8018d8:	ff 75 0c             	pushl  0xc(%ebp)
  8018db:	6a 3f                	push   $0x3f
  8018dd:	ff 55 08             	call   *0x8(%ebp)
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	eb 0d                	jmp    8018f2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	ff 75 0c             	pushl  0xc(%ebp)
  8018eb:	52                   	push   %edx
  8018ec:	ff 55 08             	call   *0x8(%ebp)
  8018ef:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018f2:	83 eb 01             	sub    $0x1,%ebx
  8018f5:	eb 1a                	jmp    801911 <vprintfmt+0x23f>
  8018f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8018fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801900:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801903:	eb 0c                	jmp    801911 <vprintfmt+0x23f>
  801905:	89 75 08             	mov    %esi,0x8(%ebp)
  801908:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80190b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80190e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801911:	83 c7 01             	add    $0x1,%edi
  801914:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801918:	0f be d0             	movsbl %al,%edx
  80191b:	85 d2                	test   %edx,%edx
  80191d:	74 23                	je     801942 <vprintfmt+0x270>
  80191f:	85 f6                	test   %esi,%esi
  801921:	78 a1                	js     8018c4 <vprintfmt+0x1f2>
  801923:	83 ee 01             	sub    $0x1,%esi
  801926:	79 9c                	jns    8018c4 <vprintfmt+0x1f2>
  801928:	89 df                	mov    %ebx,%edi
  80192a:	8b 75 08             	mov    0x8(%ebp),%esi
  80192d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801930:	eb 18                	jmp    80194a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	53                   	push   %ebx
  801936:	6a 20                	push   $0x20
  801938:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80193a:	83 ef 01             	sub    $0x1,%edi
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	eb 08                	jmp    80194a <vprintfmt+0x278>
  801942:	89 df                	mov    %ebx,%edi
  801944:	8b 75 08             	mov    0x8(%ebp),%esi
  801947:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80194a:	85 ff                	test   %edi,%edi
  80194c:	7f e4                	jg     801932 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80194e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801951:	e9 a2 fd ff ff       	jmp    8016f8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801956:	83 fa 01             	cmp    $0x1,%edx
  801959:	7e 16                	jle    801971 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80195b:	8b 45 14             	mov    0x14(%ebp),%eax
  80195e:	8d 50 08             	lea    0x8(%eax),%edx
  801961:	89 55 14             	mov    %edx,0x14(%ebp)
  801964:	8b 50 04             	mov    0x4(%eax),%edx
  801967:	8b 00                	mov    (%eax),%eax
  801969:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80196c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80196f:	eb 32                	jmp    8019a3 <vprintfmt+0x2d1>
	else if (lflag)
  801971:	85 d2                	test   %edx,%edx
  801973:	74 18                	je     80198d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801975:	8b 45 14             	mov    0x14(%ebp),%eax
  801978:	8d 50 04             	lea    0x4(%eax),%edx
  80197b:	89 55 14             	mov    %edx,0x14(%ebp)
  80197e:	8b 00                	mov    (%eax),%eax
  801980:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801983:	89 c1                	mov    %eax,%ecx
  801985:	c1 f9 1f             	sar    $0x1f,%ecx
  801988:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80198b:	eb 16                	jmp    8019a3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80198d:	8b 45 14             	mov    0x14(%ebp),%eax
  801990:	8d 50 04             	lea    0x4(%eax),%edx
  801993:	89 55 14             	mov    %edx,0x14(%ebp)
  801996:	8b 00                	mov    (%eax),%eax
  801998:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80199b:	89 c1                	mov    %eax,%ecx
  80199d:	c1 f9 1f             	sar    $0x1f,%ecx
  8019a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019a9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019b2:	0f 89 90 00 00 00    	jns    801a48 <vprintfmt+0x376>
				putch('-', putdat);
  8019b8:	83 ec 08             	sub    $0x8,%esp
  8019bb:	53                   	push   %ebx
  8019bc:	6a 2d                	push   $0x2d
  8019be:	ff d6                	call   *%esi
				num = -(long long) num;
  8019c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019c6:	f7 d8                	neg    %eax
  8019c8:	83 d2 00             	adc    $0x0,%edx
  8019cb:	f7 da                	neg    %edx
  8019cd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019d5:	eb 71                	jmp    801a48 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8019da:	e8 7f fc ff ff       	call   80165e <getuint>
			base = 10;
  8019df:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019e4:	eb 62                	jmp    801a48 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8019e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8019e9:	e8 70 fc ff ff       	call   80165e <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8019f5:	51                   	push   %ecx
  8019f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8019f9:	6a 08                	push   $0x8
  8019fb:	52                   	push   %edx
  8019fc:	50                   	push   %eax
  8019fd:	89 da                	mov    %ebx,%edx
  8019ff:	89 f0                	mov    %esi,%eax
  801a01:	e8 a9 fb ff ff       	call   8015af <printnum>
			break;
  801a06:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  801a0c:	e9 e7 fc ff ff       	jmp    8016f8 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	53                   	push   %ebx
  801a15:	6a 30                	push   $0x30
  801a17:	ff d6                	call   *%esi
			putch('x', putdat);
  801a19:	83 c4 08             	add    $0x8,%esp
  801a1c:	53                   	push   %ebx
  801a1d:	6a 78                	push   $0x78
  801a1f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a21:	8b 45 14             	mov    0x14(%ebp),%eax
  801a24:	8d 50 04             	lea    0x4(%eax),%edx
  801a27:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a2a:	8b 00                	mov    (%eax),%eax
  801a2c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a31:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a34:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a39:	eb 0d                	jmp    801a48 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a3b:	8d 45 14             	lea    0x14(%ebp),%eax
  801a3e:	e8 1b fc ff ff       	call   80165e <getuint>
			base = 16;
  801a43:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a48:	83 ec 0c             	sub    $0xc,%esp
  801a4b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a4f:	57                   	push   %edi
  801a50:	ff 75 e0             	pushl  -0x20(%ebp)
  801a53:	51                   	push   %ecx
  801a54:	52                   	push   %edx
  801a55:	50                   	push   %eax
  801a56:	89 da                	mov    %ebx,%edx
  801a58:	89 f0                	mov    %esi,%eax
  801a5a:	e8 50 fb ff ff       	call   8015af <printnum>
			break;
  801a5f:	83 c4 20             	add    $0x20,%esp
  801a62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a65:	e9 8e fc ff ff       	jmp    8016f8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a6a:	83 ec 08             	sub    $0x8,%esp
  801a6d:	53                   	push   %ebx
  801a6e:	51                   	push   %ecx
  801a6f:	ff d6                	call   *%esi
			break;
  801a71:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a77:	e9 7c fc ff ff       	jmp    8016f8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a7c:	83 ec 08             	sub    $0x8,%esp
  801a7f:	53                   	push   %ebx
  801a80:	6a 25                	push   $0x25
  801a82:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	eb 03                	jmp    801a8c <vprintfmt+0x3ba>
  801a89:	83 ef 01             	sub    $0x1,%edi
  801a8c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a90:	75 f7                	jne    801a89 <vprintfmt+0x3b7>
  801a92:	e9 61 fc ff ff       	jmp    8016f8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9a:	5b                   	pop    %ebx
  801a9b:	5e                   	pop    %esi
  801a9c:	5f                   	pop    %edi
  801a9d:	5d                   	pop    %ebp
  801a9e:	c3                   	ret    

00801a9f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 18             	sub    $0x18,%esp
  801aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801aae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ab2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ab5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801abc:	85 c0                	test   %eax,%eax
  801abe:	74 26                	je     801ae6 <vsnprintf+0x47>
  801ac0:	85 d2                	test   %edx,%edx
  801ac2:	7e 22                	jle    801ae6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ac4:	ff 75 14             	pushl  0x14(%ebp)
  801ac7:	ff 75 10             	pushl  0x10(%ebp)
  801aca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801acd:	50                   	push   %eax
  801ace:	68 98 16 80 00       	push   $0x801698
  801ad3:	e8 fa fb ff ff       	call   8016d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ad8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801adb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	eb 05                	jmp    801aeb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ae6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801aeb:	c9                   	leave  
  801aec:	c3                   	ret    

00801aed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801af3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801af6:	50                   	push   %eax
  801af7:	ff 75 10             	pushl  0x10(%ebp)
  801afa:	ff 75 0c             	pushl  0xc(%ebp)
  801afd:	ff 75 08             	pushl  0x8(%ebp)
  801b00:	e8 9a ff ff ff       	call   801a9f <vsnprintf>
	va_end(ap);

	return rc;
}
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b12:	eb 03                	jmp    801b17 <strlen+0x10>
		n++;
  801b14:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b17:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b1b:	75 f7                	jne    801b14 <strlen+0xd>
		n++;
	return n;
}
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    

00801b1f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b25:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b28:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2d:	eb 03                	jmp    801b32 <strnlen+0x13>
		n++;
  801b2f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b32:	39 c2                	cmp    %eax,%edx
  801b34:	74 08                	je     801b3e <strnlen+0x1f>
  801b36:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b3a:	75 f3                	jne    801b2f <strnlen+0x10>
  801b3c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b3e:	5d                   	pop    %ebp
  801b3f:	c3                   	ret    

00801b40 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	53                   	push   %ebx
  801b44:	8b 45 08             	mov    0x8(%ebp),%eax
  801b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b4a:	89 c2                	mov    %eax,%edx
  801b4c:	83 c2 01             	add    $0x1,%edx
  801b4f:	83 c1 01             	add    $0x1,%ecx
  801b52:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b56:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b59:	84 db                	test   %bl,%bl
  801b5b:	75 ef                	jne    801b4c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b5d:	5b                   	pop    %ebx
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	53                   	push   %ebx
  801b64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b67:	53                   	push   %ebx
  801b68:	e8 9a ff ff ff       	call   801b07 <strlen>
  801b6d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b70:	ff 75 0c             	pushl  0xc(%ebp)
  801b73:	01 d8                	add    %ebx,%eax
  801b75:	50                   	push   %eax
  801b76:	e8 c5 ff ff ff       	call   801b40 <strcpy>
	return dst;
}
  801b7b:	89 d8                	mov    %ebx,%eax
  801b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	56                   	push   %esi
  801b86:	53                   	push   %ebx
  801b87:	8b 75 08             	mov    0x8(%ebp),%esi
  801b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8d:	89 f3                	mov    %esi,%ebx
  801b8f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b92:	89 f2                	mov    %esi,%edx
  801b94:	eb 0f                	jmp    801ba5 <strncpy+0x23>
		*dst++ = *src;
  801b96:	83 c2 01             	add    $0x1,%edx
  801b99:	0f b6 01             	movzbl (%ecx),%eax
  801b9c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b9f:	80 39 01             	cmpb   $0x1,(%ecx)
  801ba2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba5:	39 da                	cmp    %ebx,%edx
  801ba7:	75 ed                	jne    801b96 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ba9:	89 f0                	mov    %esi,%eax
  801bab:	5b                   	pop    %ebx
  801bac:	5e                   	pop    %esi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bba:	8b 55 10             	mov    0x10(%ebp),%edx
  801bbd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bbf:	85 d2                	test   %edx,%edx
  801bc1:	74 21                	je     801be4 <strlcpy+0x35>
  801bc3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bc7:	89 f2                	mov    %esi,%edx
  801bc9:	eb 09                	jmp    801bd4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bcb:	83 c2 01             	add    $0x1,%edx
  801bce:	83 c1 01             	add    $0x1,%ecx
  801bd1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bd4:	39 c2                	cmp    %eax,%edx
  801bd6:	74 09                	je     801be1 <strlcpy+0x32>
  801bd8:	0f b6 19             	movzbl (%ecx),%ebx
  801bdb:	84 db                	test   %bl,%bl
  801bdd:	75 ec                	jne    801bcb <strlcpy+0x1c>
  801bdf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801be1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801be4:	29 f0                	sub    %esi,%eax
}
  801be6:	5b                   	pop    %ebx
  801be7:	5e                   	pop    %esi
  801be8:	5d                   	pop    %ebp
  801be9:	c3                   	ret    

00801bea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bf3:	eb 06                	jmp    801bfb <strcmp+0x11>
		p++, q++;
  801bf5:	83 c1 01             	add    $0x1,%ecx
  801bf8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bfb:	0f b6 01             	movzbl (%ecx),%eax
  801bfe:	84 c0                	test   %al,%al
  801c00:	74 04                	je     801c06 <strcmp+0x1c>
  801c02:	3a 02                	cmp    (%edx),%al
  801c04:	74 ef                	je     801bf5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c06:	0f b6 c0             	movzbl %al,%eax
  801c09:	0f b6 12             	movzbl (%edx),%edx
  801c0c:	29 d0                	sub    %edx,%eax
}
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    

00801c10 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	53                   	push   %ebx
  801c14:	8b 45 08             	mov    0x8(%ebp),%eax
  801c17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c1f:	eb 06                	jmp    801c27 <strncmp+0x17>
		n--, p++, q++;
  801c21:	83 c0 01             	add    $0x1,%eax
  801c24:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c27:	39 d8                	cmp    %ebx,%eax
  801c29:	74 15                	je     801c40 <strncmp+0x30>
  801c2b:	0f b6 08             	movzbl (%eax),%ecx
  801c2e:	84 c9                	test   %cl,%cl
  801c30:	74 04                	je     801c36 <strncmp+0x26>
  801c32:	3a 0a                	cmp    (%edx),%cl
  801c34:	74 eb                	je     801c21 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c36:	0f b6 00             	movzbl (%eax),%eax
  801c39:	0f b6 12             	movzbl (%edx),%edx
  801c3c:	29 d0                	sub    %edx,%eax
  801c3e:	eb 05                	jmp    801c45 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c40:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c45:	5b                   	pop    %ebx
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    

00801c48 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c52:	eb 07                	jmp    801c5b <strchr+0x13>
		if (*s == c)
  801c54:	38 ca                	cmp    %cl,%dl
  801c56:	74 0f                	je     801c67 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c58:	83 c0 01             	add    $0x1,%eax
  801c5b:	0f b6 10             	movzbl (%eax),%edx
  801c5e:	84 d2                	test   %dl,%dl
  801c60:	75 f2                	jne    801c54 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c73:	eb 03                	jmp    801c78 <strfind+0xf>
  801c75:	83 c0 01             	add    $0x1,%eax
  801c78:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c7b:	38 ca                	cmp    %cl,%dl
  801c7d:	74 04                	je     801c83 <strfind+0x1a>
  801c7f:	84 d2                	test   %dl,%dl
  801c81:	75 f2                	jne    801c75 <strfind+0xc>
			break;
	return (char *) s;
}
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    

00801c85 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	57                   	push   %edi
  801c89:	56                   	push   %esi
  801c8a:	53                   	push   %ebx
  801c8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c91:	85 c9                	test   %ecx,%ecx
  801c93:	74 36                	je     801ccb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c9b:	75 28                	jne    801cc5 <memset+0x40>
  801c9d:	f6 c1 03             	test   $0x3,%cl
  801ca0:	75 23                	jne    801cc5 <memset+0x40>
		c &= 0xFF;
  801ca2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ca6:	89 d3                	mov    %edx,%ebx
  801ca8:	c1 e3 08             	shl    $0x8,%ebx
  801cab:	89 d6                	mov    %edx,%esi
  801cad:	c1 e6 18             	shl    $0x18,%esi
  801cb0:	89 d0                	mov    %edx,%eax
  801cb2:	c1 e0 10             	shl    $0x10,%eax
  801cb5:	09 f0                	or     %esi,%eax
  801cb7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cb9:	89 d8                	mov    %ebx,%eax
  801cbb:	09 d0                	or     %edx,%eax
  801cbd:	c1 e9 02             	shr    $0x2,%ecx
  801cc0:	fc                   	cld    
  801cc1:	f3 ab                	rep stos %eax,%es:(%edi)
  801cc3:	eb 06                	jmp    801ccb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc8:	fc                   	cld    
  801cc9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ccb:	89 f8                	mov    %edi,%eax
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	57                   	push   %edi
  801cd6:	56                   	push   %esi
  801cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cda:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce0:	39 c6                	cmp    %eax,%esi
  801ce2:	73 35                	jae    801d19 <memmove+0x47>
  801ce4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ce7:	39 d0                	cmp    %edx,%eax
  801ce9:	73 2e                	jae    801d19 <memmove+0x47>
		s += n;
		d += n;
  801ceb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cee:	89 d6                	mov    %edx,%esi
  801cf0:	09 fe                	or     %edi,%esi
  801cf2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cf8:	75 13                	jne    801d0d <memmove+0x3b>
  801cfa:	f6 c1 03             	test   $0x3,%cl
  801cfd:	75 0e                	jne    801d0d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801cff:	83 ef 04             	sub    $0x4,%edi
  801d02:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d05:	c1 e9 02             	shr    $0x2,%ecx
  801d08:	fd                   	std    
  801d09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d0b:	eb 09                	jmp    801d16 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d0d:	83 ef 01             	sub    $0x1,%edi
  801d10:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d13:	fd                   	std    
  801d14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d16:	fc                   	cld    
  801d17:	eb 1d                	jmp    801d36 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d19:	89 f2                	mov    %esi,%edx
  801d1b:	09 c2                	or     %eax,%edx
  801d1d:	f6 c2 03             	test   $0x3,%dl
  801d20:	75 0f                	jne    801d31 <memmove+0x5f>
  801d22:	f6 c1 03             	test   $0x3,%cl
  801d25:	75 0a                	jne    801d31 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d27:	c1 e9 02             	shr    $0x2,%ecx
  801d2a:	89 c7                	mov    %eax,%edi
  801d2c:	fc                   	cld    
  801d2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d2f:	eb 05                	jmp    801d36 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d31:	89 c7                	mov    %eax,%edi
  801d33:	fc                   	cld    
  801d34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d36:	5e                   	pop    %esi
  801d37:	5f                   	pop    %edi
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d3d:	ff 75 10             	pushl  0x10(%ebp)
  801d40:	ff 75 0c             	pushl  0xc(%ebp)
  801d43:	ff 75 08             	pushl  0x8(%ebp)
  801d46:	e8 87 ff ff ff       	call   801cd2 <memmove>
}
  801d4b:	c9                   	leave  
  801d4c:	c3                   	ret    

00801d4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	56                   	push   %esi
  801d51:	53                   	push   %ebx
  801d52:	8b 45 08             	mov    0x8(%ebp),%eax
  801d55:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d58:	89 c6                	mov    %eax,%esi
  801d5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d5d:	eb 1a                	jmp    801d79 <memcmp+0x2c>
		if (*s1 != *s2)
  801d5f:	0f b6 08             	movzbl (%eax),%ecx
  801d62:	0f b6 1a             	movzbl (%edx),%ebx
  801d65:	38 d9                	cmp    %bl,%cl
  801d67:	74 0a                	je     801d73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d69:	0f b6 c1             	movzbl %cl,%eax
  801d6c:	0f b6 db             	movzbl %bl,%ebx
  801d6f:	29 d8                	sub    %ebx,%eax
  801d71:	eb 0f                	jmp    801d82 <memcmp+0x35>
		s1++, s2++;
  801d73:	83 c0 01             	add    $0x1,%eax
  801d76:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d79:	39 f0                	cmp    %esi,%eax
  801d7b:	75 e2                	jne    801d5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d82:	5b                   	pop    %ebx
  801d83:	5e                   	pop    %esi
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    

00801d86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	53                   	push   %ebx
  801d8a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d8d:	89 c1                	mov    %eax,%ecx
  801d8f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d92:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d96:	eb 0a                	jmp    801da2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d98:	0f b6 10             	movzbl (%eax),%edx
  801d9b:	39 da                	cmp    %ebx,%edx
  801d9d:	74 07                	je     801da6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d9f:	83 c0 01             	add    $0x1,%eax
  801da2:	39 c8                	cmp    %ecx,%eax
  801da4:	72 f2                	jb     801d98 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801da6:	5b                   	pop    %ebx
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    

00801da9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	57                   	push   %edi
  801dad:	56                   	push   %esi
  801dae:	53                   	push   %ebx
  801daf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801db5:	eb 03                	jmp    801dba <strtol+0x11>
		s++;
  801db7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dba:	0f b6 01             	movzbl (%ecx),%eax
  801dbd:	3c 20                	cmp    $0x20,%al
  801dbf:	74 f6                	je     801db7 <strtol+0xe>
  801dc1:	3c 09                	cmp    $0x9,%al
  801dc3:	74 f2                	je     801db7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dc5:	3c 2b                	cmp    $0x2b,%al
  801dc7:	75 0a                	jne    801dd3 <strtol+0x2a>
		s++;
  801dc9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dcc:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd1:	eb 11                	jmp    801de4 <strtol+0x3b>
  801dd3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dd8:	3c 2d                	cmp    $0x2d,%al
  801dda:	75 08                	jne    801de4 <strtol+0x3b>
		s++, neg = 1;
  801ddc:	83 c1 01             	add    $0x1,%ecx
  801ddf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801de4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dea:	75 15                	jne    801e01 <strtol+0x58>
  801dec:	80 39 30             	cmpb   $0x30,(%ecx)
  801def:	75 10                	jne    801e01 <strtol+0x58>
  801df1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801df5:	75 7c                	jne    801e73 <strtol+0xca>
		s += 2, base = 16;
  801df7:	83 c1 02             	add    $0x2,%ecx
  801dfa:	bb 10 00 00 00       	mov    $0x10,%ebx
  801dff:	eb 16                	jmp    801e17 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e01:	85 db                	test   %ebx,%ebx
  801e03:	75 12                	jne    801e17 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e05:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e0a:	80 39 30             	cmpb   $0x30,(%ecx)
  801e0d:	75 08                	jne    801e17 <strtol+0x6e>
		s++, base = 8;
  801e0f:	83 c1 01             	add    $0x1,%ecx
  801e12:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e17:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e1f:	0f b6 11             	movzbl (%ecx),%edx
  801e22:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e25:	89 f3                	mov    %esi,%ebx
  801e27:	80 fb 09             	cmp    $0x9,%bl
  801e2a:	77 08                	ja     801e34 <strtol+0x8b>
			dig = *s - '0';
  801e2c:	0f be d2             	movsbl %dl,%edx
  801e2f:	83 ea 30             	sub    $0x30,%edx
  801e32:	eb 22                	jmp    801e56 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e34:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e37:	89 f3                	mov    %esi,%ebx
  801e39:	80 fb 19             	cmp    $0x19,%bl
  801e3c:	77 08                	ja     801e46 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e3e:	0f be d2             	movsbl %dl,%edx
  801e41:	83 ea 57             	sub    $0x57,%edx
  801e44:	eb 10                	jmp    801e56 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e46:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e49:	89 f3                	mov    %esi,%ebx
  801e4b:	80 fb 19             	cmp    $0x19,%bl
  801e4e:	77 16                	ja     801e66 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e50:	0f be d2             	movsbl %dl,%edx
  801e53:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e56:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e59:	7d 0b                	jge    801e66 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e5b:	83 c1 01             	add    $0x1,%ecx
  801e5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e62:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e64:	eb b9                	jmp    801e1f <strtol+0x76>

	if (endptr)
  801e66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e6a:	74 0d                	je     801e79 <strtol+0xd0>
		*endptr = (char *) s;
  801e6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e6f:	89 0e                	mov    %ecx,(%esi)
  801e71:	eb 06                	jmp    801e79 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e73:	85 db                	test   %ebx,%ebx
  801e75:	74 98                	je     801e0f <strtol+0x66>
  801e77:	eb 9e                	jmp    801e17 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e79:	89 c2                	mov    %eax,%edx
  801e7b:	f7 da                	neg    %edx
  801e7d:	85 ff                	test   %edi,%edi
  801e7f:	0f 45 c2             	cmovne %edx,%eax
}
  801e82:	5b                   	pop    %ebx
  801e83:	5e                   	pop    %esi
  801e84:	5f                   	pop    %edi
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	56                   	push   %esi
  801e8b:	53                   	push   %ebx
  801e8c:	8b 75 08             	mov    0x8(%ebp),%esi
  801e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801e95:	85 c0                	test   %eax,%eax
  801e97:	74 0e                	je     801ea7 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801e99:	83 ec 0c             	sub    $0xc,%esp
  801e9c:	50                   	push   %eax
  801e9d:	e8 63 e4 ff ff       	call   800305 <sys_ipc_recv>
  801ea2:	83 c4 10             	add    $0x10,%esp
  801ea5:	eb 10                	jmp    801eb7 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801ea7:	83 ec 0c             	sub    $0xc,%esp
  801eaa:	68 00 00 c0 ee       	push   $0xeec00000
  801eaf:	e8 51 e4 ff ff       	call   800305 <sys_ipc_recv>
  801eb4:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	79 17                	jns    801ed2 <ipc_recv+0x4b>
		if(*from_env_store)
  801ebb:	83 3e 00             	cmpl   $0x0,(%esi)
  801ebe:	74 06                	je     801ec6 <ipc_recv+0x3f>
			*from_env_store = 0;
  801ec0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801ec6:	85 db                	test   %ebx,%ebx
  801ec8:	74 2c                	je     801ef6 <ipc_recv+0x6f>
			*perm_store = 0;
  801eca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ed0:	eb 24                	jmp    801ef6 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801ed2:	85 f6                	test   %esi,%esi
  801ed4:	74 0a                	je     801ee0 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801ed6:	a1 08 40 80 00       	mov    0x804008,%eax
  801edb:	8b 40 74             	mov    0x74(%eax),%eax
  801ede:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801ee0:	85 db                	test   %ebx,%ebx
  801ee2:	74 0a                	je     801eee <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801ee4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee9:	8b 40 78             	mov    0x78(%eax),%eax
  801eec:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801eee:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef3:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ef6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef9:	5b                   	pop    %ebx
  801efa:	5e                   	pop    %esi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    

00801efd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	57                   	push   %edi
  801f01:	56                   	push   %esi
  801f02:	53                   	push   %ebx
  801f03:	83 ec 0c             	sub    $0xc,%esp
  801f06:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f09:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f0f:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f11:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f16:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f19:	e8 18 e2 ff ff       	call   800136 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f1e:	ff 75 14             	pushl  0x14(%ebp)
  801f21:	53                   	push   %ebx
  801f22:	56                   	push   %esi
  801f23:	57                   	push   %edi
  801f24:	e8 b9 e3 ff ff       	call   8002e2 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f29:	89 c2                	mov    %eax,%edx
  801f2b:	f7 d2                	not    %edx
  801f2d:	c1 ea 1f             	shr    $0x1f,%edx
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f36:	0f 94 c1             	sete   %cl
  801f39:	09 ca                	or     %ecx,%edx
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	0f 94 c0             	sete   %al
  801f40:	38 c2                	cmp    %al,%dl
  801f42:	77 d5                	ja     801f19 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801f44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f47:	5b                   	pop    %ebx
  801f48:	5e                   	pop    %esi
  801f49:	5f                   	pop    %edi
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    

00801f4c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f52:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f57:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f5a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f60:	8b 52 50             	mov    0x50(%edx),%edx
  801f63:	39 ca                	cmp    %ecx,%edx
  801f65:	75 0d                	jne    801f74 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f67:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f6a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f6f:	8b 40 48             	mov    0x48(%eax),%eax
  801f72:	eb 0f                	jmp    801f83 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f74:	83 c0 01             	add    $0x1,%eax
  801f77:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f7c:	75 d9                	jne    801f57 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f83:	5d                   	pop    %ebp
  801f84:	c3                   	ret    

00801f85 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8b:	89 d0                	mov    %edx,%eax
  801f8d:	c1 e8 16             	shr    $0x16,%eax
  801f90:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9c:	f6 c1 01             	test   $0x1,%cl
  801f9f:	74 1d                	je     801fbe <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa1:	c1 ea 0c             	shr    $0xc,%edx
  801fa4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fab:	f6 c2 01             	test   $0x1,%dl
  801fae:	74 0e                	je     801fbe <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb0:	c1 ea 0c             	shr    $0xc,%edx
  801fb3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fba:	ef 
  801fbb:	0f b7 c0             	movzwl %ax,%eax
}
  801fbe:	5d                   	pop    %ebp
  801fbf:	c3                   	ret    

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
