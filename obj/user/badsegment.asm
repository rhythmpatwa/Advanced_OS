
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 a6 04 00 00       	call   800535 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 6a 22 80 00       	push   $0x80226a
  800108:	6a 23                	push   $0x23
  80010a:	68 87 22 80 00       	push   $0x802287
  80010f:	e8 b3 13 00 00       	call   8014c7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 6a 22 80 00       	push   $0x80226a
  800189:	6a 23                	push   $0x23
  80018b:	68 87 22 80 00       	push   $0x802287
  800190:	e8 32 13 00 00       	call   8014c7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 6a 22 80 00       	push   $0x80226a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 87 22 80 00       	push   $0x802287
  8001d2:	e8 f0 12 00 00       	call   8014c7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 6a 22 80 00       	push   $0x80226a
  80020d:	6a 23                	push   $0x23
  80020f:	68 87 22 80 00       	push   $0x802287
  800214:	e8 ae 12 00 00       	call   8014c7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 6a 22 80 00       	push   $0x80226a
  80024f:	6a 23                	push   $0x23
  800251:	68 87 22 80 00       	push   $0x802287
  800256:	e8 6c 12 00 00       	call   8014c7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 6a 22 80 00       	push   $0x80226a
  800291:	6a 23                	push   $0x23
  800293:	68 87 22 80 00       	push   $0x802287
  800298:	e8 2a 12 00 00       	call   8014c7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 6a 22 80 00       	push   $0x80226a
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 87 22 80 00       	push   $0x802287
  8002da:	e8 e8 11 00 00       	call   8014c7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 6a 22 80 00       	push   $0x80226a
  800337:	6a 23                	push   $0x23
  800339:	68 87 22 80 00       	push   $0x802287
  80033e:	e8 84 11 00 00       	call   8014c7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035b:	89 d1                	mov    %edx,%ecx
  80035d:	89 d3                	mov    %edx,%ebx
  80035f:	89 d7                	mov    %edx,%edi
  800361:	89 d6                	mov    %edx,%esi
  800363:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036d:	8b 45 08             	mov    0x8(%ebp),%eax
  800370:	05 00 00 00 30       	add    $0x30000000,%eax
  800375:	c1 e8 0c             	shr    $0xc,%eax
}
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	05 00 00 00 30       	add    $0x30000000,%eax
  800385:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80038a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80039c:	89 c2                	mov    %eax,%edx
  80039e:	c1 ea 16             	shr    $0x16,%edx
  8003a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a8:	f6 c2 01             	test   $0x1,%dl
  8003ab:	74 11                	je     8003be <fd_alloc+0x2d>
  8003ad:	89 c2                	mov    %eax,%edx
  8003af:	c1 ea 0c             	shr    $0xc,%edx
  8003b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b9:	f6 c2 01             	test   $0x1,%dl
  8003bc:	75 09                	jne    8003c7 <fd_alloc+0x36>
			*fd_store = fd;
  8003be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	eb 17                	jmp    8003de <fd_alloc+0x4d>
  8003c7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003cc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d1:	75 c9                	jne    80039c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003d3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e6:	83 f8 1f             	cmp    $0x1f,%eax
  8003e9:	77 36                	ja     800421 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003eb:	c1 e0 0c             	shl    $0xc,%eax
  8003ee:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003f3:	89 c2                	mov    %eax,%edx
  8003f5:	c1 ea 16             	shr    $0x16,%edx
  8003f8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ff:	f6 c2 01             	test   $0x1,%dl
  800402:	74 24                	je     800428 <fd_lookup+0x48>
  800404:	89 c2                	mov    %eax,%edx
  800406:	c1 ea 0c             	shr    $0xc,%edx
  800409:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800410:	f6 c2 01             	test   $0x1,%dl
  800413:	74 1a                	je     80042f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800415:	8b 55 0c             	mov    0xc(%ebp),%edx
  800418:	89 02                	mov    %eax,(%edx)
	return 0;
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	eb 13                	jmp    800434 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800421:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800426:	eb 0c                	jmp    800434 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800428:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042d:	eb 05                	jmp    800434 <fd_lookup+0x54>
  80042f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043f:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800444:	eb 13                	jmp    800459 <dev_lookup+0x23>
  800446:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800449:	39 08                	cmp    %ecx,(%eax)
  80044b:	75 0c                	jne    800459 <dev_lookup+0x23>
			*dev = devtab[i];
  80044d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800450:	89 01                	mov    %eax,(%ecx)
			return 0;
  800452:	b8 00 00 00 00       	mov    $0x0,%eax
  800457:	eb 2e                	jmp    800487 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800459:	8b 02                	mov    (%edx),%eax
  80045b:	85 c0                	test   %eax,%eax
  80045d:	75 e7                	jne    800446 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045f:	a1 08 40 80 00       	mov    0x804008,%eax
  800464:	8b 40 48             	mov    0x48(%eax),%eax
  800467:	83 ec 04             	sub    $0x4,%esp
  80046a:	51                   	push   %ecx
  80046b:	50                   	push   %eax
  80046c:	68 98 22 80 00       	push   $0x802298
  800471:	e8 2a 11 00 00       	call   8015a0 <cprintf>
	*dev = 0;
  800476:	8b 45 0c             	mov    0xc(%ebp),%eax
  800479:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800487:	c9                   	leave  
  800488:	c3                   	ret    

00800489 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	56                   	push   %esi
  80048d:	53                   	push   %ebx
  80048e:	83 ec 10             	sub    $0x10,%esp
  800491:	8b 75 08             	mov    0x8(%ebp),%esi
  800494:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800497:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80049a:	50                   	push   %eax
  80049b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a1:	c1 e8 0c             	shr    $0xc,%eax
  8004a4:	50                   	push   %eax
  8004a5:	e8 36 ff ff ff       	call   8003e0 <fd_lookup>
  8004aa:	83 c4 08             	add    $0x8,%esp
  8004ad:	85 c0                	test   %eax,%eax
  8004af:	78 05                	js     8004b6 <fd_close+0x2d>
	    || fd != fd2)
  8004b1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b4:	74 0c                	je     8004c2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004b6:	84 db                	test   %bl,%bl
  8004b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004bd:	0f 44 c2             	cmove  %edx,%eax
  8004c0:	eb 41                	jmp    800503 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c8:	50                   	push   %eax
  8004c9:	ff 36                	pushl  (%esi)
  8004cb:	e8 66 ff ff ff       	call   800436 <dev_lookup>
  8004d0:	89 c3                	mov    %eax,%ebx
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	78 1a                	js     8004f3 <fd_close+0x6a>
		if (dev->dev_close)
  8004d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004dc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004df:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004e4:	85 c0                	test   %eax,%eax
  8004e6:	74 0b                	je     8004f3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004e8:	83 ec 0c             	sub    $0xc,%esp
  8004eb:	56                   	push   %esi
  8004ec:	ff d0                	call   *%eax
  8004ee:	89 c3                	mov    %eax,%ebx
  8004f0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	56                   	push   %esi
  8004f7:	6a 00                	push   $0x0
  8004f9:	e8 e1 fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	89 d8                	mov    %ebx,%eax
}
  800503:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800506:	5b                   	pop    %ebx
  800507:	5e                   	pop    %esi
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800510:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800513:	50                   	push   %eax
  800514:	ff 75 08             	pushl  0x8(%ebp)
  800517:	e8 c4 fe ff ff       	call   8003e0 <fd_lookup>
  80051c:	83 c4 08             	add    $0x8,%esp
  80051f:	85 c0                	test   %eax,%eax
  800521:	78 10                	js     800533 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	6a 01                	push   $0x1
  800528:	ff 75 f4             	pushl  -0xc(%ebp)
  80052b:	e8 59 ff ff ff       	call   800489 <fd_close>
  800530:	83 c4 10             	add    $0x10,%esp
}
  800533:	c9                   	leave  
  800534:	c3                   	ret    

00800535 <close_all>:

void
close_all(void)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	53                   	push   %ebx
  800539:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80053c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800541:	83 ec 0c             	sub    $0xc,%esp
  800544:	53                   	push   %ebx
  800545:	e8 c0 ff ff ff       	call   80050a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80054a:	83 c3 01             	add    $0x1,%ebx
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	83 fb 20             	cmp    $0x20,%ebx
  800553:	75 ec                	jne    800541 <close_all+0xc>
		close(i);
}
  800555:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800558:	c9                   	leave  
  800559:	c3                   	ret    

0080055a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	57                   	push   %edi
  80055e:	56                   	push   %esi
  80055f:	53                   	push   %ebx
  800560:	83 ec 2c             	sub    $0x2c,%esp
  800563:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800566:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800569:	50                   	push   %eax
  80056a:	ff 75 08             	pushl  0x8(%ebp)
  80056d:	e8 6e fe ff ff       	call   8003e0 <fd_lookup>
  800572:	83 c4 08             	add    $0x8,%esp
  800575:	85 c0                	test   %eax,%eax
  800577:	0f 88 c1 00 00 00    	js     80063e <dup+0xe4>
		return r;
	close(newfdnum);
  80057d:	83 ec 0c             	sub    $0xc,%esp
  800580:	56                   	push   %esi
  800581:	e8 84 ff ff ff       	call   80050a <close>

	newfd = INDEX2FD(newfdnum);
  800586:	89 f3                	mov    %esi,%ebx
  800588:	c1 e3 0c             	shl    $0xc,%ebx
  80058b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800591:	83 c4 04             	add    $0x4,%esp
  800594:	ff 75 e4             	pushl  -0x1c(%ebp)
  800597:	e8 de fd ff ff       	call   80037a <fd2data>
  80059c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80059e:	89 1c 24             	mov    %ebx,(%esp)
  8005a1:	e8 d4 fd ff ff       	call   80037a <fd2data>
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ac:	89 f8                	mov    %edi,%eax
  8005ae:	c1 e8 16             	shr    $0x16,%eax
  8005b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b8:	a8 01                	test   $0x1,%al
  8005ba:	74 37                	je     8005f3 <dup+0x99>
  8005bc:	89 f8                	mov    %edi,%eax
  8005be:	c1 e8 0c             	shr    $0xc,%eax
  8005c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c8:	f6 c2 01             	test   $0x1,%dl
  8005cb:	74 26                	je     8005f3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d4:	83 ec 0c             	sub    $0xc,%esp
  8005d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005dc:	50                   	push   %eax
  8005dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e0:	6a 00                	push   $0x0
  8005e2:	57                   	push   %edi
  8005e3:	6a 00                	push   $0x0
  8005e5:	e8 b3 fb ff ff       	call   80019d <sys_page_map>
  8005ea:	89 c7                	mov    %eax,%edi
  8005ec:	83 c4 20             	add    $0x20,%esp
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	78 2e                	js     800621 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f6:	89 d0                	mov    %edx,%eax
  8005f8:	c1 e8 0c             	shr    $0xc,%eax
  8005fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800602:	83 ec 0c             	sub    $0xc,%esp
  800605:	25 07 0e 00 00       	and    $0xe07,%eax
  80060a:	50                   	push   %eax
  80060b:	53                   	push   %ebx
  80060c:	6a 00                	push   $0x0
  80060e:	52                   	push   %edx
  80060f:	6a 00                	push   $0x0
  800611:	e8 87 fb ff ff       	call   80019d <sys_page_map>
  800616:	89 c7                	mov    %eax,%edi
  800618:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80061b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061d:	85 ff                	test   %edi,%edi
  80061f:	79 1d                	jns    80063e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 00                	push   $0x0
  800627:	e8 b3 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062c:	83 c4 08             	add    $0x8,%esp
  80062f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800632:	6a 00                	push   $0x0
  800634:	e8 a6 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	89 f8                	mov    %edi,%eax
}
  80063e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800641:	5b                   	pop    %ebx
  800642:	5e                   	pop    %esi
  800643:	5f                   	pop    %edi
  800644:	5d                   	pop    %ebp
  800645:	c3                   	ret    

00800646 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800646:	55                   	push   %ebp
  800647:	89 e5                	mov    %esp,%ebp
  800649:	53                   	push   %ebx
  80064a:	83 ec 14             	sub    $0x14,%esp
  80064d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	53                   	push   %ebx
  800655:	e8 86 fd ff ff       	call   8003e0 <fd_lookup>
  80065a:	83 c4 08             	add    $0x8,%esp
  80065d:	89 c2                	mov    %eax,%edx
  80065f:	85 c0                	test   %eax,%eax
  800661:	78 6d                	js     8006d0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800669:	50                   	push   %eax
  80066a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80066d:	ff 30                	pushl  (%eax)
  80066f:	e8 c2 fd ff ff       	call   800436 <dev_lookup>
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	85 c0                	test   %eax,%eax
  800679:	78 4c                	js     8006c7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80067b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80067e:	8b 42 08             	mov    0x8(%edx),%eax
  800681:	83 e0 03             	and    $0x3,%eax
  800684:	83 f8 01             	cmp    $0x1,%eax
  800687:	75 21                	jne    8006aa <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800689:	a1 08 40 80 00       	mov    0x804008,%eax
  80068e:	8b 40 48             	mov    0x48(%eax),%eax
  800691:	83 ec 04             	sub    $0x4,%esp
  800694:	53                   	push   %ebx
  800695:	50                   	push   %eax
  800696:	68 d9 22 80 00       	push   $0x8022d9
  80069b:	e8 00 0f 00 00       	call   8015a0 <cprintf>
		return -E_INVAL;
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006a8:	eb 26                	jmp    8006d0 <read+0x8a>
	}
	if (!dev->dev_read)
  8006aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ad:	8b 40 08             	mov    0x8(%eax),%eax
  8006b0:	85 c0                	test   %eax,%eax
  8006b2:	74 17                	je     8006cb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b4:	83 ec 04             	sub    $0x4,%esp
  8006b7:	ff 75 10             	pushl  0x10(%ebp)
  8006ba:	ff 75 0c             	pushl  0xc(%ebp)
  8006bd:	52                   	push   %edx
  8006be:	ff d0                	call   *%eax
  8006c0:	89 c2                	mov    %eax,%edx
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb 09                	jmp    8006d0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c7:	89 c2                	mov    %eax,%edx
  8006c9:	eb 05                	jmp    8006d0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d0:	89 d0                	mov    %edx,%eax
  8006d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d5:	c9                   	leave  
  8006d6:	c3                   	ret    

008006d7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	57                   	push   %edi
  8006db:	56                   	push   %esi
  8006dc:	53                   	push   %ebx
  8006dd:	83 ec 0c             	sub    $0xc,%esp
  8006e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006eb:	eb 21                	jmp    80070e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ed:	83 ec 04             	sub    $0x4,%esp
  8006f0:	89 f0                	mov    %esi,%eax
  8006f2:	29 d8                	sub    %ebx,%eax
  8006f4:	50                   	push   %eax
  8006f5:	89 d8                	mov    %ebx,%eax
  8006f7:	03 45 0c             	add    0xc(%ebp),%eax
  8006fa:	50                   	push   %eax
  8006fb:	57                   	push   %edi
  8006fc:	e8 45 ff ff ff       	call   800646 <read>
		if (m < 0)
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	85 c0                	test   %eax,%eax
  800706:	78 10                	js     800718 <readn+0x41>
			return m;
		if (m == 0)
  800708:	85 c0                	test   %eax,%eax
  80070a:	74 0a                	je     800716 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070c:	01 c3                	add    %eax,%ebx
  80070e:	39 f3                	cmp    %esi,%ebx
  800710:	72 db                	jb     8006ed <readn+0x16>
  800712:	89 d8                	mov    %ebx,%eax
  800714:	eb 02                	jmp    800718 <readn+0x41>
  800716:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800718:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071b:	5b                   	pop    %ebx
  80071c:	5e                   	pop    %esi
  80071d:	5f                   	pop    %edi
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	53                   	push   %ebx
  800724:	83 ec 14             	sub    $0x14,%esp
  800727:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	53                   	push   %ebx
  80072f:	e8 ac fc ff ff       	call   8003e0 <fd_lookup>
  800734:	83 c4 08             	add    $0x8,%esp
  800737:	89 c2                	mov    %eax,%edx
  800739:	85 c0                	test   %eax,%eax
  80073b:	78 68                	js     8007a5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800747:	ff 30                	pushl  (%eax)
  800749:	e8 e8 fc ff ff       	call   800436 <dev_lookup>
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	85 c0                	test   %eax,%eax
  800753:	78 47                	js     80079c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800755:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800758:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80075c:	75 21                	jne    80077f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075e:	a1 08 40 80 00       	mov    0x804008,%eax
  800763:	8b 40 48             	mov    0x48(%eax),%eax
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	53                   	push   %ebx
  80076a:	50                   	push   %eax
  80076b:	68 f5 22 80 00       	push   $0x8022f5
  800770:	e8 2b 0e 00 00       	call   8015a0 <cprintf>
		return -E_INVAL;
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80077d:	eb 26                	jmp    8007a5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800782:	8b 52 0c             	mov    0xc(%edx),%edx
  800785:	85 d2                	test   %edx,%edx
  800787:	74 17                	je     8007a0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800789:	83 ec 04             	sub    $0x4,%esp
  80078c:	ff 75 10             	pushl  0x10(%ebp)
  80078f:	ff 75 0c             	pushl  0xc(%ebp)
  800792:	50                   	push   %eax
  800793:	ff d2                	call   *%edx
  800795:	89 c2                	mov    %eax,%edx
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	eb 09                	jmp    8007a5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80079c:	89 c2                	mov    %eax,%edx
  80079e:	eb 05                	jmp    8007a5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a5:	89 d0                	mov    %edx,%eax
  8007a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <seek>:

int
seek(int fdnum, off_t offset)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007b2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b5:	50                   	push   %eax
  8007b6:	ff 75 08             	pushl  0x8(%ebp)
  8007b9:	e8 22 fc ff ff       	call   8003e0 <fd_lookup>
  8007be:	83 c4 08             	add    $0x8,%esp
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	78 0e                	js     8007d3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	83 ec 14             	sub    $0x14,%esp
  8007dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	53                   	push   %ebx
  8007e4:	e8 f7 fb ff ff       	call   8003e0 <fd_lookup>
  8007e9:	83 c4 08             	add    $0x8,%esp
  8007ec:	89 c2                	mov    %eax,%edx
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	78 65                	js     800857 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f2:	83 ec 08             	sub    $0x8,%esp
  8007f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f8:	50                   	push   %eax
  8007f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fc:	ff 30                	pushl  (%eax)
  8007fe:	e8 33 fc ff ff       	call   800436 <dev_lookup>
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	85 c0                	test   %eax,%eax
  800808:	78 44                	js     80084e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80080a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800811:	75 21                	jne    800834 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800813:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800818:	8b 40 48             	mov    0x48(%eax),%eax
  80081b:	83 ec 04             	sub    $0x4,%esp
  80081e:	53                   	push   %ebx
  80081f:	50                   	push   %eax
  800820:	68 b8 22 80 00       	push   $0x8022b8
  800825:	e8 76 0d 00 00       	call   8015a0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800832:	eb 23                	jmp    800857 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800834:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800837:	8b 52 18             	mov    0x18(%edx),%edx
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 14                	je     800852 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	50                   	push   %eax
  800845:	ff d2                	call   *%edx
  800847:	89 c2                	mov    %eax,%edx
  800849:	83 c4 10             	add    $0x10,%esp
  80084c:	eb 09                	jmp    800857 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084e:	89 c2                	mov    %eax,%edx
  800850:	eb 05                	jmp    800857 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800852:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800857:	89 d0                	mov    %edx,%eax
  800859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	53                   	push   %ebx
  800862:	83 ec 14             	sub    $0x14,%esp
  800865:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800868:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086b:	50                   	push   %eax
  80086c:	ff 75 08             	pushl  0x8(%ebp)
  80086f:	e8 6c fb ff ff       	call   8003e0 <fd_lookup>
  800874:	83 c4 08             	add    $0x8,%esp
  800877:	89 c2                	mov    %eax,%edx
  800879:	85 c0                	test   %eax,%eax
  80087b:	78 58                	js     8008d5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087d:	83 ec 08             	sub    $0x8,%esp
  800880:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800887:	ff 30                	pushl  (%eax)
  800889:	e8 a8 fb ff ff       	call   800436 <dev_lookup>
  80088e:	83 c4 10             	add    $0x10,%esp
  800891:	85 c0                	test   %eax,%eax
  800893:	78 37                	js     8008cc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800895:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800898:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80089c:	74 32                	je     8008d0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80089e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a8:	00 00 00 
	stat->st_isdir = 0;
  8008ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008b2:	00 00 00 
	stat->st_dev = dev;
  8008b5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	53                   	push   %ebx
  8008bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8008c2:	ff 50 14             	call   *0x14(%eax)
  8008c5:	89 c2                	mov    %eax,%edx
  8008c7:	83 c4 10             	add    $0x10,%esp
  8008ca:	eb 09                	jmp    8008d5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cc:	89 c2                	mov    %eax,%edx
  8008ce:	eb 05                	jmp    8008d5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d5:	89 d0                	mov    %edx,%eax
  8008d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	6a 00                	push   $0x0
  8008e6:	ff 75 08             	pushl  0x8(%ebp)
  8008e9:	e8 ef 01 00 00       	call   800add <open>
  8008ee:	89 c3                	mov    %eax,%ebx
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	85 c0                	test   %eax,%eax
  8008f5:	78 1b                	js     800912 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	50                   	push   %eax
  8008fe:	e8 5b ff ff ff       	call   80085e <fstat>
  800903:	89 c6                	mov    %eax,%esi
	close(fd);
  800905:	89 1c 24             	mov    %ebx,(%esp)
  800908:	e8 fd fb ff ff       	call   80050a <close>
	return r;
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	89 f0                	mov    %esi,%eax
}
  800912:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
  80091e:	89 c6                	mov    %eax,%esi
  800920:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800922:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800929:	75 12                	jne    80093d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80092b:	83 ec 0c             	sub    $0xc,%esp
  80092e:	6a 01                	push   $0x1
  800930:	e8 1c 16 00 00       	call   801f51 <ipc_find_env>
  800935:	a3 00 40 80 00       	mov    %eax,0x804000
  80093a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80093d:	6a 07                	push   $0x7
  80093f:	68 00 50 80 00       	push   $0x805000
  800944:	56                   	push   %esi
  800945:	ff 35 00 40 80 00    	pushl  0x804000
  80094b:	e8 b2 15 00 00       	call   801f02 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800950:	83 c4 0c             	add    $0xc,%esp
  800953:	6a 00                	push   $0x0
  800955:	53                   	push   %ebx
  800956:	6a 00                	push   $0x0
  800958:	e8 2f 15 00 00       	call   801e8c <ipc_recv>
}
  80095d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 40 0c             	mov    0xc(%eax),%eax
  800970:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
  800978:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80097d:	ba 00 00 00 00       	mov    $0x0,%edx
  800982:	b8 02 00 00 00       	mov    $0x2,%eax
  800987:	e8 8d ff ff ff       	call   800919 <fsipc>
}
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    

0080098e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 40 0c             	mov    0xc(%eax),%eax
  80099a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099f:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a9:	e8 6b ff ff ff       	call   800919 <fsipc>
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	53                   	push   %ebx
  8009b4:	83 ec 04             	sub    $0x4,%esp
  8009b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8009cf:	e8 45 ff ff ff       	call   800919 <fsipc>
  8009d4:	85 c0                	test   %eax,%eax
  8009d6:	78 2c                	js     800a04 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d8:	83 ec 08             	sub    $0x8,%esp
  8009db:	68 00 50 80 00       	push   $0x805000
  8009e0:	53                   	push   %ebx
  8009e1:	e8 5f 11 00 00       	call   801b45 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f1:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009fc:	83 c4 10             	add    $0x10,%esp
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	53                   	push   %ebx
  800a0d:	83 ec 08             	sub    $0x8,%esp
  800a10:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
  800a16:	8b 52 0c             	mov    0xc(%edx),%edx
  800a19:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a1f:	a3 04 50 80 00       	mov    %eax,0x805004
  800a24:	3d 08 50 80 00       	cmp    $0x805008,%eax
  800a29:	bb 08 50 80 00       	mov    $0x805008,%ebx
  800a2e:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a31:	53                   	push   %ebx
  800a32:	ff 75 0c             	pushl  0xc(%ebp)
  800a35:	68 08 50 80 00       	push   $0x805008
  800a3a:	e8 98 12 00 00       	call   801cd7 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a44:	b8 04 00 00 00       	mov    $0x4,%eax
  800a49:	e8 cb fe ff ff       	call   800919 <fsipc>
  800a4e:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  800a51:	85 c0                	test   %eax,%eax
  800a53:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  800a56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8b 40 0c             	mov    0xc(%eax),%eax
  800a69:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a6e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a74:	ba 00 00 00 00       	mov    $0x0,%edx
  800a79:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7e:	e8 96 fe ff ff       	call   800919 <fsipc>
  800a83:	89 c3                	mov    %eax,%ebx
  800a85:	85 c0                	test   %eax,%eax
  800a87:	78 4b                	js     800ad4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a89:	39 c6                	cmp    %eax,%esi
  800a8b:	73 16                	jae    800aa3 <devfile_read+0x48>
  800a8d:	68 28 23 80 00       	push   $0x802328
  800a92:	68 2f 23 80 00       	push   $0x80232f
  800a97:	6a 7c                	push   $0x7c
  800a99:	68 44 23 80 00       	push   $0x802344
  800a9e:	e8 24 0a 00 00       	call   8014c7 <_panic>
	assert(r <= PGSIZE);
  800aa3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa8:	7e 16                	jle    800ac0 <devfile_read+0x65>
  800aaa:	68 4f 23 80 00       	push   $0x80234f
  800aaf:	68 2f 23 80 00       	push   $0x80232f
  800ab4:	6a 7d                	push   $0x7d
  800ab6:	68 44 23 80 00       	push   $0x802344
  800abb:	e8 07 0a 00 00       	call   8014c7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ac0:	83 ec 04             	sub    $0x4,%esp
  800ac3:	50                   	push   %eax
  800ac4:	68 00 50 80 00       	push   $0x805000
  800ac9:	ff 75 0c             	pushl  0xc(%ebp)
  800acc:	e8 06 12 00 00       	call   801cd7 <memmove>
	return r;
  800ad1:	83 c4 10             	add    $0x10,%esp
}
  800ad4:	89 d8                	mov    %ebx,%eax
  800ad6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 20             	sub    $0x20,%esp
  800ae4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae7:	53                   	push   %ebx
  800ae8:	e8 1f 10 00 00       	call   801b0c <strlen>
  800aed:	83 c4 10             	add    $0x10,%esp
  800af0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af5:	7f 67                	jg     800b5e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af7:	83 ec 0c             	sub    $0xc,%esp
  800afa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800afd:	50                   	push   %eax
  800afe:	e8 8e f8 ff ff       	call   800391 <fd_alloc>
  800b03:	83 c4 10             	add    $0x10,%esp
		return r;
  800b06:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	78 57                	js     800b63 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b0c:	83 ec 08             	sub    $0x8,%esp
  800b0f:	53                   	push   %ebx
  800b10:	68 00 50 80 00       	push   $0x805000
  800b15:	e8 2b 10 00 00       	call   801b45 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b25:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2a:	e8 ea fd ff ff       	call   800919 <fsipc>
  800b2f:	89 c3                	mov    %eax,%ebx
  800b31:	83 c4 10             	add    $0x10,%esp
  800b34:	85 c0                	test   %eax,%eax
  800b36:	79 14                	jns    800b4c <open+0x6f>
		fd_close(fd, 0);
  800b38:	83 ec 08             	sub    $0x8,%esp
  800b3b:	6a 00                	push   $0x0
  800b3d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b40:	e8 44 f9 ff ff       	call   800489 <fd_close>
		return r;
  800b45:	83 c4 10             	add    $0x10,%esp
  800b48:	89 da                	mov    %ebx,%edx
  800b4a:	eb 17                	jmp    800b63 <open+0x86>
	}

	return fd2num(fd);
  800b4c:	83 ec 0c             	sub    $0xc,%esp
  800b4f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b52:	e8 13 f8 ff ff       	call   80036a <fd2num>
  800b57:	89 c2                	mov    %eax,%edx
  800b59:	83 c4 10             	add    $0x10,%esp
  800b5c:	eb 05                	jmp    800b63 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b5e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b63:	89 d0                	mov    %edx,%eax
  800b65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 08 00 00 00       	mov    $0x8,%eax
  800b7a:	e8 9a fd ff ff       	call   800919 <fsipc>
}
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	ff 75 08             	pushl  0x8(%ebp)
  800b8f:	e8 e6 f7 ff ff       	call   80037a <fd2data>
  800b94:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b96:	83 c4 08             	add    $0x8,%esp
  800b99:	68 5b 23 80 00       	push   $0x80235b
  800b9e:	53                   	push   %ebx
  800b9f:	e8 a1 0f 00 00       	call   801b45 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba4:	8b 46 04             	mov    0x4(%esi),%eax
  800ba7:	2b 06                	sub    (%esi),%eax
  800ba9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800baf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb6:	00 00 00 
	stat->st_dev = &devpipe;
  800bb9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc0:	30 80 00 
	return 0;
}
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd9:	53                   	push   %ebx
  800bda:	6a 00                	push   $0x0
  800bdc:	e8 fe f5 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be1:	89 1c 24             	mov    %ebx,(%esp)
  800be4:	e8 91 f7 ff ff       	call   80037a <fd2data>
  800be9:	83 c4 08             	add    $0x8,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 00                	push   $0x0
  800bef:	e8 eb f5 ff ff       	call   8001df <sys_page_unmap>
}
  800bf4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 1c             	sub    $0x1c,%esp
  800c02:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c05:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c07:	a1 08 40 80 00       	mov    0x804008,%eax
  800c0c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	ff 75 e0             	pushl  -0x20(%ebp)
  800c15:	e8 70 13 00 00       	call   801f8a <pageref>
  800c1a:	89 c3                	mov    %eax,%ebx
  800c1c:	89 3c 24             	mov    %edi,(%esp)
  800c1f:	e8 66 13 00 00       	call   801f8a <pageref>
  800c24:	83 c4 10             	add    $0x10,%esp
  800c27:	39 c3                	cmp    %eax,%ebx
  800c29:	0f 94 c1             	sete   %cl
  800c2c:	0f b6 c9             	movzbl %cl,%ecx
  800c2f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c32:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c38:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c3b:	39 ce                	cmp    %ecx,%esi
  800c3d:	74 1b                	je     800c5a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c3f:	39 c3                	cmp    %eax,%ebx
  800c41:	75 c4                	jne    800c07 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c43:	8b 42 58             	mov    0x58(%edx),%eax
  800c46:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c49:	50                   	push   %eax
  800c4a:	56                   	push   %esi
  800c4b:	68 62 23 80 00       	push   $0x802362
  800c50:	e8 4b 09 00 00       	call   8015a0 <cprintf>
  800c55:	83 c4 10             	add    $0x10,%esp
  800c58:	eb ad                	jmp    800c07 <_pipeisclosed+0xe>
	}
}
  800c5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 28             	sub    $0x28,%esp
  800c6e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c71:	56                   	push   %esi
  800c72:	e8 03 f7 ff ff       	call   80037a <fd2data>
  800c77:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c79:	83 c4 10             	add    $0x10,%esp
  800c7c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c81:	eb 4b                	jmp    800cce <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c83:	89 da                	mov    %ebx,%edx
  800c85:	89 f0                	mov    %esi,%eax
  800c87:	e8 6d ff ff ff       	call   800bf9 <_pipeisclosed>
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	75 48                	jne    800cd8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c90:	e8 a6 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c95:	8b 43 04             	mov    0x4(%ebx),%eax
  800c98:	8b 0b                	mov    (%ebx),%ecx
  800c9a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c9d:	39 d0                	cmp    %edx,%eax
  800c9f:	73 e2                	jae    800c83 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cab:	89 c2                	mov    %eax,%edx
  800cad:	c1 fa 1f             	sar    $0x1f,%edx
  800cb0:	89 d1                	mov    %edx,%ecx
  800cb2:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb8:	83 e2 1f             	and    $0x1f,%edx
  800cbb:	29 ca                	sub    %ecx,%edx
  800cbd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cc1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc5:	83 c0 01             	add    $0x1,%eax
  800cc8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ccb:	83 c7 01             	add    $0x1,%edi
  800cce:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cd1:	75 c2                	jne    800c95 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd6:	eb 05                	jmp    800cdd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 18             	sub    $0x18,%esp
  800cee:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cf1:	57                   	push   %edi
  800cf2:	e8 83 f6 ff ff       	call   80037a <fd2data>
  800cf7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf9:	83 c4 10             	add    $0x10,%esp
  800cfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d01:	eb 3d                	jmp    800d40 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d03:	85 db                	test   %ebx,%ebx
  800d05:	74 04                	je     800d0b <devpipe_read+0x26>
				return i;
  800d07:	89 d8                	mov    %ebx,%eax
  800d09:	eb 44                	jmp    800d4f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d0b:	89 f2                	mov    %esi,%edx
  800d0d:	89 f8                	mov    %edi,%eax
  800d0f:	e8 e5 fe ff ff       	call   800bf9 <_pipeisclosed>
  800d14:	85 c0                	test   %eax,%eax
  800d16:	75 32                	jne    800d4a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d18:	e8 1e f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d1d:	8b 06                	mov    (%esi),%eax
  800d1f:	3b 46 04             	cmp    0x4(%esi),%eax
  800d22:	74 df                	je     800d03 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d24:	99                   	cltd   
  800d25:	c1 ea 1b             	shr    $0x1b,%edx
  800d28:	01 d0                	add    %edx,%eax
  800d2a:	83 e0 1f             	and    $0x1f,%eax
  800d2d:	29 d0                	sub    %edx,%eax
  800d2f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d3a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d3d:	83 c3 01             	add    $0x1,%ebx
  800d40:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d43:	75 d8                	jne    800d1d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d45:	8b 45 10             	mov    0x10(%ebp),%eax
  800d48:	eb 05                	jmp    800d4f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d4a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d62:	50                   	push   %eax
  800d63:	e8 29 f6 ff ff       	call   800391 <fd_alloc>
  800d68:	83 c4 10             	add    $0x10,%esp
  800d6b:	89 c2                	mov    %eax,%edx
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	0f 88 2c 01 00 00    	js     800ea1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d75:	83 ec 04             	sub    $0x4,%esp
  800d78:	68 07 04 00 00       	push   $0x407
  800d7d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d80:	6a 00                	push   $0x0
  800d82:	e8 d3 f3 ff ff       	call   80015a <sys_page_alloc>
  800d87:	83 c4 10             	add    $0x10,%esp
  800d8a:	89 c2                	mov    %eax,%edx
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	0f 88 0d 01 00 00    	js     800ea1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d94:	83 ec 0c             	sub    $0xc,%esp
  800d97:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d9a:	50                   	push   %eax
  800d9b:	e8 f1 f5 ff ff       	call   800391 <fd_alloc>
  800da0:	89 c3                	mov    %eax,%ebx
  800da2:	83 c4 10             	add    $0x10,%esp
  800da5:	85 c0                	test   %eax,%eax
  800da7:	0f 88 e2 00 00 00    	js     800e8f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dad:	83 ec 04             	sub    $0x4,%esp
  800db0:	68 07 04 00 00       	push   $0x407
  800db5:	ff 75 f0             	pushl  -0x10(%ebp)
  800db8:	6a 00                	push   $0x0
  800dba:	e8 9b f3 ff ff       	call   80015a <sys_page_alloc>
  800dbf:	89 c3                	mov    %eax,%ebx
  800dc1:	83 c4 10             	add    $0x10,%esp
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	0f 88 c3 00 00 00    	js     800e8f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd2:	e8 a3 f5 ff ff       	call   80037a <fd2data>
  800dd7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd9:	83 c4 0c             	add    $0xc,%esp
  800ddc:	68 07 04 00 00       	push   $0x407
  800de1:	50                   	push   %eax
  800de2:	6a 00                	push   $0x0
  800de4:	e8 71 f3 ff ff       	call   80015a <sys_page_alloc>
  800de9:	89 c3                	mov    %eax,%ebx
  800deb:	83 c4 10             	add    $0x10,%esp
  800dee:	85 c0                	test   %eax,%eax
  800df0:	0f 88 89 00 00 00    	js     800e7f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfc:	e8 79 f5 ff ff       	call   80037a <fd2data>
  800e01:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e08:	50                   	push   %eax
  800e09:	6a 00                	push   $0x0
  800e0b:	56                   	push   %esi
  800e0c:	6a 00                	push   $0x0
  800e0e:	e8 8a f3 ff ff       	call   80019d <sys_page_map>
  800e13:	89 c3                	mov    %eax,%ebx
  800e15:	83 c4 20             	add    $0x20,%esp
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	78 55                	js     800e71 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e1c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e25:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e31:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e46:	83 ec 0c             	sub    $0xc,%esp
  800e49:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4c:	e8 19 f5 ff ff       	call   80036a <fd2num>
  800e51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e54:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e56:	83 c4 04             	add    $0x4,%esp
  800e59:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5c:	e8 09 f5 ff ff       	call   80036a <fd2num>
  800e61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e64:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6f:	eb 30                	jmp    800ea1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e71:	83 ec 08             	sub    $0x8,%esp
  800e74:	56                   	push   %esi
  800e75:	6a 00                	push   $0x0
  800e77:	e8 63 f3 ff ff       	call   8001df <sys_page_unmap>
  800e7c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e7f:	83 ec 08             	sub    $0x8,%esp
  800e82:	ff 75 f0             	pushl  -0x10(%ebp)
  800e85:	6a 00                	push   $0x0
  800e87:	e8 53 f3 ff ff       	call   8001df <sys_page_unmap>
  800e8c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	ff 75 f4             	pushl  -0xc(%ebp)
  800e95:	6a 00                	push   $0x0
  800e97:	e8 43 f3 ff ff       	call   8001df <sys_page_unmap>
  800e9c:	83 c4 10             	add    $0x10,%esp
  800e9f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ea1:	89 d0                	mov    %edx,%eax
  800ea3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb3:	50                   	push   %eax
  800eb4:	ff 75 08             	pushl  0x8(%ebp)
  800eb7:	e8 24 f5 ff ff       	call   8003e0 <fd_lookup>
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	78 18                	js     800edb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec9:	e8 ac f4 ff ff       	call   80037a <fd2data>
	return _pipeisclosed(fd, p);
  800ece:	89 c2                	mov    %eax,%edx
  800ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed3:	e8 21 fd ff ff       	call   800bf9 <_pipeisclosed>
  800ed8:	83 c4 10             	add    $0x10,%esp
}
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    

00800edd <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ee3:	68 7a 23 80 00       	push   $0x80237a
  800ee8:	ff 75 0c             	pushl  0xc(%ebp)
  800eeb:	e8 55 0c 00 00       	call   801b45 <strcpy>
	return 0;
}
  800ef0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	53                   	push   %ebx
  800efb:	83 ec 10             	sub    $0x10,%esp
  800efe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800f01:	53                   	push   %ebx
  800f02:	e8 83 10 00 00       	call   801f8a <pageref>
  800f07:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800f0a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800f0f:	83 f8 01             	cmp    $0x1,%eax
  800f12:	75 10                	jne    800f24 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800f14:	83 ec 0c             	sub    $0xc,%esp
  800f17:	ff 73 0c             	pushl  0xc(%ebx)
  800f1a:	e8 c0 02 00 00       	call   8011df <nsipc_close>
  800f1f:	89 c2                	mov    %eax,%edx
  800f21:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f24:	89 d0                	mov    %edx,%eax
  800f26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f29:	c9                   	leave  
  800f2a:	c3                   	ret    

00800f2b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f31:	6a 00                	push   $0x0
  800f33:	ff 75 10             	pushl  0x10(%ebp)
  800f36:	ff 75 0c             	pushl  0xc(%ebp)
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3c:	ff 70 0c             	pushl  0xc(%eax)
  800f3f:	e8 78 03 00 00       	call   8012bc <nsipc_send>
}
  800f44:	c9                   	leave  
  800f45:	c3                   	ret    

00800f46 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f4c:	6a 00                	push   $0x0
  800f4e:	ff 75 10             	pushl  0x10(%ebp)
  800f51:	ff 75 0c             	pushl  0xc(%ebp)
  800f54:	8b 45 08             	mov    0x8(%ebp),%eax
  800f57:	ff 70 0c             	pushl  0xc(%eax)
  800f5a:	e8 f1 02 00 00       	call   801250 <nsipc_recv>
}
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f67:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f6a:	52                   	push   %edx
  800f6b:	50                   	push   %eax
  800f6c:	e8 6f f4 ff ff       	call   8003e0 <fd_lookup>
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	78 17                	js     800f8f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f7b:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  800f81:	39 08                	cmp    %ecx,(%eax)
  800f83:	75 05                	jne    800f8a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f85:	8b 40 0c             	mov    0xc(%eax),%eax
  800f88:	eb 05                	jmp    800f8f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800f8a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800f8f:	c9                   	leave  
  800f90:	c3                   	ret    

00800f91 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	83 ec 1c             	sub    $0x1c,%esp
  800f99:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800f9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9e:	50                   	push   %eax
  800f9f:	e8 ed f3 ff ff       	call   800391 <fd_alloc>
  800fa4:	89 c3                	mov    %eax,%ebx
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 1b                	js     800fc8 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800fad:	83 ec 04             	sub    $0x4,%esp
  800fb0:	68 07 04 00 00       	push   $0x407
  800fb5:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb8:	6a 00                	push   $0x0
  800fba:	e8 9b f1 ff ff       	call   80015a <sys_page_alloc>
  800fbf:	89 c3                	mov    %eax,%ebx
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	79 10                	jns    800fd8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800fc8:	83 ec 0c             	sub    $0xc,%esp
  800fcb:	56                   	push   %esi
  800fcc:	e8 0e 02 00 00       	call   8011df <nsipc_close>
		return r;
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	89 d8                	mov    %ebx,%eax
  800fd6:	eb 24                	jmp    800ffc <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800fd8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800fed:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	50                   	push   %eax
  800ff4:	e8 71 f3 ff ff       	call   80036a <fd2num>
  800ff9:	83 c4 10             	add    $0x10,%esp
}
  800ffc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801009:	8b 45 08             	mov    0x8(%ebp),%eax
  80100c:	e8 50 ff ff ff       	call   800f61 <fd2sockid>
		return r;
  801011:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801013:	85 c0                	test   %eax,%eax
  801015:	78 1f                	js     801036 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801017:	83 ec 04             	sub    $0x4,%esp
  80101a:	ff 75 10             	pushl  0x10(%ebp)
  80101d:	ff 75 0c             	pushl  0xc(%ebp)
  801020:	50                   	push   %eax
  801021:	e8 12 01 00 00       	call   801138 <nsipc_accept>
  801026:	83 c4 10             	add    $0x10,%esp
		return r;
  801029:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	78 07                	js     801036 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80102f:	e8 5d ff ff ff       	call   800f91 <alloc_sockfd>
  801034:	89 c1                	mov    %eax,%ecx
}
  801036:	89 c8                	mov    %ecx,%eax
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801040:	8b 45 08             	mov    0x8(%ebp),%eax
  801043:	e8 19 ff ff ff       	call   800f61 <fd2sockid>
  801048:	85 c0                	test   %eax,%eax
  80104a:	78 12                	js     80105e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80104c:	83 ec 04             	sub    $0x4,%esp
  80104f:	ff 75 10             	pushl  0x10(%ebp)
  801052:	ff 75 0c             	pushl  0xc(%ebp)
  801055:	50                   	push   %eax
  801056:	e8 2d 01 00 00       	call   801188 <nsipc_bind>
  80105b:	83 c4 10             	add    $0x10,%esp
}
  80105e:	c9                   	leave  
  80105f:	c3                   	ret    

00801060 <shutdown>:

int
shutdown(int s, int how)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
  801069:	e8 f3 fe ff ff       	call   800f61 <fd2sockid>
  80106e:	85 c0                	test   %eax,%eax
  801070:	78 0f                	js     801081 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801072:	83 ec 08             	sub    $0x8,%esp
  801075:	ff 75 0c             	pushl  0xc(%ebp)
  801078:	50                   	push   %eax
  801079:	e8 3f 01 00 00       	call   8011bd <nsipc_shutdown>
  80107e:	83 c4 10             	add    $0x10,%esp
}
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
  80108c:	e8 d0 fe ff ff       	call   800f61 <fd2sockid>
  801091:	85 c0                	test   %eax,%eax
  801093:	78 12                	js     8010a7 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	ff 75 10             	pushl  0x10(%ebp)
  80109b:	ff 75 0c             	pushl  0xc(%ebp)
  80109e:	50                   	push   %eax
  80109f:	e8 55 01 00 00       	call   8011f9 <nsipc_connect>
  8010a4:	83 c4 10             	add    $0x10,%esp
}
  8010a7:	c9                   	leave  
  8010a8:	c3                   	ret    

008010a9 <listen>:

int
listen(int s, int backlog)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010af:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b2:	e8 aa fe ff ff       	call   800f61 <fd2sockid>
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 0f                	js     8010ca <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8010bb:	83 ec 08             	sub    $0x8,%esp
  8010be:	ff 75 0c             	pushl  0xc(%ebp)
  8010c1:	50                   	push   %eax
  8010c2:	e8 67 01 00 00       	call   80122e <nsipc_listen>
  8010c7:	83 c4 10             	add    $0x10,%esp
}
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8010d2:	ff 75 10             	pushl  0x10(%ebp)
  8010d5:	ff 75 0c             	pushl  0xc(%ebp)
  8010d8:	ff 75 08             	pushl  0x8(%ebp)
  8010db:	e8 3a 02 00 00       	call   80131a <nsipc_socket>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 05                	js     8010ec <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8010e7:	e8 a5 fe ff ff       	call   800f91 <alloc_sockfd>
}
  8010ec:	c9                   	leave  
  8010ed:	c3                   	ret    

008010ee <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	53                   	push   %ebx
  8010f2:	83 ec 04             	sub    $0x4,%esp
  8010f5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8010f7:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8010fe:	75 12                	jne    801112 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	6a 02                	push   $0x2
  801105:	e8 47 0e 00 00       	call   801f51 <ipc_find_env>
  80110a:	a3 04 40 80 00       	mov    %eax,0x804004
  80110f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801112:	6a 07                	push   $0x7
  801114:	68 00 60 80 00       	push   $0x806000
  801119:	53                   	push   %ebx
  80111a:	ff 35 04 40 80 00    	pushl  0x804004
  801120:	e8 dd 0d 00 00       	call   801f02 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801125:	83 c4 0c             	add    $0xc,%esp
  801128:	6a 00                	push   $0x0
  80112a:	6a 00                	push   $0x0
  80112c:	6a 00                	push   $0x0
  80112e:	e8 59 0d 00 00       	call   801e8c <ipc_recv>
}
  801133:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801148:	8b 06                	mov    (%esi),%eax
  80114a:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80114f:	b8 01 00 00 00       	mov    $0x1,%eax
  801154:	e8 95 ff ff ff       	call   8010ee <nsipc>
  801159:	89 c3                	mov    %eax,%ebx
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 20                	js     80117f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80115f:	83 ec 04             	sub    $0x4,%esp
  801162:	ff 35 10 60 80 00    	pushl  0x806010
  801168:	68 00 60 80 00       	push   $0x806000
  80116d:	ff 75 0c             	pushl  0xc(%ebp)
  801170:	e8 62 0b 00 00       	call   801cd7 <memmove>
		*addrlen = ret->ret_addrlen;
  801175:	a1 10 60 80 00       	mov    0x806010,%eax
  80117a:	89 06                	mov    %eax,(%esi)
  80117c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80117f:	89 d8                	mov    %ebx,%eax
  801181:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801184:	5b                   	pop    %ebx
  801185:	5e                   	pop    %esi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	53                   	push   %ebx
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801192:	8b 45 08             	mov    0x8(%ebp),%eax
  801195:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80119a:	53                   	push   %ebx
  80119b:	ff 75 0c             	pushl  0xc(%ebp)
  80119e:	68 04 60 80 00       	push   $0x806004
  8011a3:	e8 2f 0b 00 00       	call   801cd7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8011a8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8011ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8011b3:	e8 36 ff ff ff       	call   8010ee <nsipc>
}
  8011b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011bb:	c9                   	leave  
  8011bc:	c3                   	ret    

008011bd <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8011cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ce:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8011d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8011d8:	e8 11 ff ff ff       	call   8010ee <nsipc>
}
  8011dd:	c9                   	leave  
  8011de:	c3                   	ret    

008011df <nsipc_close>:

int
nsipc_close(int s)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8011e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e8:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8011ed:	b8 04 00 00 00       	mov    $0x4,%eax
  8011f2:	e8 f7 fe ff ff       	call   8010ee <nsipc>
}
  8011f7:	c9                   	leave  
  8011f8:	c3                   	ret    

008011f9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 08             	sub    $0x8,%esp
  801200:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801203:	8b 45 08             	mov    0x8(%ebp),%eax
  801206:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80120b:	53                   	push   %ebx
  80120c:	ff 75 0c             	pushl  0xc(%ebp)
  80120f:	68 04 60 80 00       	push   $0x806004
  801214:	e8 be 0a 00 00       	call   801cd7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801219:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80121f:	b8 05 00 00 00       	mov    $0x5,%eax
  801224:	e8 c5 fe ff ff       	call   8010ee <nsipc>
}
  801229:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801234:	8b 45 08             	mov    0x8(%ebp),%eax
  801237:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80123c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801244:	b8 06 00 00 00       	mov    $0x6,%eax
  801249:	e8 a0 fe ff ff       	call   8010ee <nsipc>
}
  80124e:	c9                   	leave  
  80124f:	c3                   	ret    

00801250 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	56                   	push   %esi
  801254:	53                   	push   %ebx
  801255:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801258:	8b 45 08             	mov    0x8(%ebp),%eax
  80125b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801260:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801266:	8b 45 14             	mov    0x14(%ebp),%eax
  801269:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80126e:	b8 07 00 00 00       	mov    $0x7,%eax
  801273:	e8 76 fe ff ff       	call   8010ee <nsipc>
  801278:	89 c3                	mov    %eax,%ebx
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 35                	js     8012b3 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80127e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801283:	7f 04                	jg     801289 <nsipc_recv+0x39>
  801285:	39 c6                	cmp    %eax,%esi
  801287:	7d 16                	jge    80129f <nsipc_recv+0x4f>
  801289:	68 86 23 80 00       	push   $0x802386
  80128e:	68 2f 23 80 00       	push   $0x80232f
  801293:	6a 62                	push   $0x62
  801295:	68 9b 23 80 00       	push   $0x80239b
  80129a:	e8 28 02 00 00       	call   8014c7 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80129f:	83 ec 04             	sub    $0x4,%esp
  8012a2:	50                   	push   %eax
  8012a3:	68 00 60 80 00       	push   $0x806000
  8012a8:	ff 75 0c             	pushl  0xc(%ebp)
  8012ab:	e8 27 0a 00 00       	call   801cd7 <memmove>
  8012b0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8012b3:	89 d8                	mov    %ebx,%eax
  8012b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 04             	sub    $0x4,%esp
  8012c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8012c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c9:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8012ce:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8012d4:	7e 16                	jle    8012ec <nsipc_send+0x30>
  8012d6:	68 a7 23 80 00       	push   $0x8023a7
  8012db:	68 2f 23 80 00       	push   $0x80232f
  8012e0:	6a 6d                	push   $0x6d
  8012e2:	68 9b 23 80 00       	push   $0x80239b
  8012e7:	e8 db 01 00 00       	call   8014c7 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8012ec:	83 ec 04             	sub    $0x4,%esp
  8012ef:	53                   	push   %ebx
  8012f0:	ff 75 0c             	pushl  0xc(%ebp)
  8012f3:	68 0c 60 80 00       	push   $0x80600c
  8012f8:	e8 da 09 00 00       	call   801cd7 <memmove>
	nsipcbuf.send.req_size = size;
  8012fd:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801303:	8b 45 14             	mov    0x14(%ebp),%eax
  801306:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80130b:	b8 08 00 00 00       	mov    $0x8,%eax
  801310:	e8 d9 fd ff ff       	call   8010ee <nsipc>
}
  801315:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801318:	c9                   	leave  
  801319:	c3                   	ret    

0080131a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801320:	8b 45 08             	mov    0x8(%ebp),%eax
  801323:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132b:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801330:	8b 45 10             	mov    0x10(%ebp),%eax
  801333:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801338:	b8 09 00 00 00       	mov    $0x9,%eax
  80133d:	e8 ac fd ff ff       	call   8010ee <nsipc>
}
  801342:	c9                   	leave  
  801343:	c3                   	ret    

00801344 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801347:	b8 00 00 00 00       	mov    $0x0,%eax
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801354:	68 b3 23 80 00       	push   $0x8023b3
  801359:	ff 75 0c             	pushl  0xc(%ebp)
  80135c:	e8 e4 07 00 00       	call   801b45 <strcpy>
	return 0;
}
  801361:	b8 00 00 00 00       	mov    $0x0,%eax
  801366:	c9                   	leave  
  801367:	c3                   	ret    

00801368 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	57                   	push   %edi
  80136c:	56                   	push   %esi
  80136d:	53                   	push   %ebx
  80136e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801374:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801379:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80137f:	eb 2d                	jmp    8013ae <devcons_write+0x46>
		m = n - tot;
  801381:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801384:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801386:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801389:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80138e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801391:	83 ec 04             	sub    $0x4,%esp
  801394:	53                   	push   %ebx
  801395:	03 45 0c             	add    0xc(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	57                   	push   %edi
  80139a:	e8 38 09 00 00       	call   801cd7 <memmove>
		sys_cputs(buf, m);
  80139f:	83 c4 08             	add    $0x8,%esp
  8013a2:	53                   	push   %ebx
  8013a3:	57                   	push   %edi
  8013a4:	e8 f5 ec ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a9:	01 de                	add    %ebx,%esi
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	89 f0                	mov    %esi,%eax
  8013b0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013b3:	72 cc                	jb     801381 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013cc:	74 2a                	je     8013f8 <devcons_read+0x3b>
  8013ce:	eb 05                	jmp    8013d5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013d0:	e8 66 ed ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013d5:	e8 e2 ec ff ff       	call   8000bc <sys_cgetc>
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	74 f2                	je     8013d0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 16                	js     8013f8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013e2:	83 f8 04             	cmp    $0x4,%eax
  8013e5:	74 0c                	je     8013f3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ea:	88 02                	mov    %al,(%edx)
	return 1;
  8013ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8013f1:	eb 05                	jmp    8013f8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013f3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801400:	8b 45 08             	mov    0x8(%ebp),%eax
  801403:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801406:	6a 01                	push   $0x1
  801408:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80140b:	50                   	push   %eax
  80140c:	e8 8d ec ff ff       	call   80009e <sys_cputs>
}
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <getchar>:

int
getchar(void)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80141c:	6a 01                	push   $0x1
  80141e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801421:	50                   	push   %eax
  801422:	6a 00                	push   $0x0
  801424:	e8 1d f2 ff ff       	call   800646 <read>
	if (r < 0)
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 0f                	js     80143f <getchar+0x29>
		return r;
	if (r < 1)
  801430:	85 c0                	test   %eax,%eax
  801432:	7e 06                	jle    80143a <getchar+0x24>
		return -E_EOF;
	return c;
  801434:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801438:	eb 05                	jmp    80143f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80143a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801447:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144a:	50                   	push   %eax
  80144b:	ff 75 08             	pushl  0x8(%ebp)
  80144e:	e8 8d ef ff ff       	call   8003e0 <fd_lookup>
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	85 c0                	test   %eax,%eax
  801458:	78 11                	js     80146b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80145a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801463:	39 10                	cmp    %edx,(%eax)
  801465:	0f 94 c0             	sete   %al
  801468:	0f b6 c0             	movzbl %al,%eax
}
  80146b:	c9                   	leave  
  80146c:	c3                   	ret    

0080146d <opencons>:

int
opencons(void)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	e8 15 ef ff ff       	call   800391 <fd_alloc>
  80147c:	83 c4 10             	add    $0x10,%esp
		return r;
  80147f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801481:	85 c0                	test   %eax,%eax
  801483:	78 3e                	js     8014c3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801485:	83 ec 04             	sub    $0x4,%esp
  801488:	68 07 04 00 00       	push   $0x407
  80148d:	ff 75 f4             	pushl  -0xc(%ebp)
  801490:	6a 00                	push   $0x0
  801492:	e8 c3 ec ff ff       	call   80015a <sys_page_alloc>
  801497:	83 c4 10             	add    $0x10,%esp
		return r;
  80149a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 23                	js     8014c3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014a0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014b5:	83 ec 0c             	sub    $0xc,%esp
  8014b8:	50                   	push   %eax
  8014b9:	e8 ac ee ff ff       	call   80036a <fd2num>
  8014be:	89 c2                	mov    %eax,%edx
  8014c0:	83 c4 10             	add    $0x10,%esp
}
  8014c3:	89 d0                	mov    %edx,%eax
  8014c5:	c9                   	leave  
  8014c6:	c3                   	ret    

008014c7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	56                   	push   %esi
  8014cb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014cc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014cf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014d5:	e8 42 ec ff ff       	call   80011c <sys_getenvid>
  8014da:	83 ec 0c             	sub    $0xc,%esp
  8014dd:	ff 75 0c             	pushl  0xc(%ebp)
  8014e0:	ff 75 08             	pushl  0x8(%ebp)
  8014e3:	56                   	push   %esi
  8014e4:	50                   	push   %eax
  8014e5:	68 c0 23 80 00       	push   $0x8023c0
  8014ea:	e8 b1 00 00 00       	call   8015a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014ef:	83 c4 18             	add    $0x18,%esp
  8014f2:	53                   	push   %ebx
  8014f3:	ff 75 10             	pushl  0x10(%ebp)
  8014f6:	e8 54 00 00 00       	call   80154f <vcprintf>
	cprintf("\n");
  8014fb:	c7 04 24 73 23 80 00 	movl   $0x802373,(%esp)
  801502:	e8 99 00 00 00       	call   8015a0 <cprintf>
  801507:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80150a:	cc                   	int3   
  80150b:	eb fd                	jmp    80150a <_panic+0x43>

0080150d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	53                   	push   %ebx
  801511:	83 ec 04             	sub    $0x4,%esp
  801514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801517:	8b 13                	mov    (%ebx),%edx
  801519:	8d 42 01             	lea    0x1(%edx),%eax
  80151c:	89 03                	mov    %eax,(%ebx)
  80151e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801521:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801525:	3d ff 00 00 00       	cmp    $0xff,%eax
  80152a:	75 1a                	jne    801546 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	68 ff 00 00 00       	push   $0xff
  801534:	8d 43 08             	lea    0x8(%ebx),%eax
  801537:	50                   	push   %eax
  801538:	e8 61 eb ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  80153d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801543:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801546:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80154a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801558:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80155f:	00 00 00 
	b.cnt = 0;
  801562:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801569:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80156c:	ff 75 0c             	pushl  0xc(%ebp)
  80156f:	ff 75 08             	pushl  0x8(%ebp)
  801572:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801578:	50                   	push   %eax
  801579:	68 0d 15 80 00       	push   $0x80150d
  80157e:	e8 54 01 00 00       	call   8016d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801583:	83 c4 08             	add    $0x8,%esp
  801586:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80158c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801592:	50                   	push   %eax
  801593:	e8 06 eb ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  801598:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015a9:	50                   	push   %eax
  8015aa:	ff 75 08             	pushl  0x8(%ebp)
  8015ad:	e8 9d ff ff ff       	call   80154f <vcprintf>
	va_end(ap);

	return cnt;
}
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    

008015b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	57                   	push   %edi
  8015b8:	56                   	push   %esi
  8015b9:	53                   	push   %ebx
  8015ba:	83 ec 1c             	sub    $0x1c,%esp
  8015bd:	89 c7                	mov    %eax,%edi
  8015bf:	89 d6                	mov    %edx,%esi
  8015c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015d8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015db:	39 d3                	cmp    %edx,%ebx
  8015dd:	72 05                	jb     8015e4 <printnum+0x30>
  8015df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015e2:	77 45                	ja     801629 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015e4:	83 ec 0c             	sub    $0xc,%esp
  8015e7:	ff 75 18             	pushl  0x18(%ebp)
  8015ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ed:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015f0:	53                   	push   %ebx
  8015f1:	ff 75 10             	pushl  0x10(%ebp)
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8015fd:	ff 75 dc             	pushl  -0x24(%ebp)
  801600:	ff 75 d8             	pushl  -0x28(%ebp)
  801603:	e8 c8 09 00 00       	call   801fd0 <__udivdi3>
  801608:	83 c4 18             	add    $0x18,%esp
  80160b:	52                   	push   %edx
  80160c:	50                   	push   %eax
  80160d:	89 f2                	mov    %esi,%edx
  80160f:	89 f8                	mov    %edi,%eax
  801611:	e8 9e ff ff ff       	call   8015b4 <printnum>
  801616:	83 c4 20             	add    $0x20,%esp
  801619:	eb 18                	jmp    801633 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	56                   	push   %esi
  80161f:	ff 75 18             	pushl  0x18(%ebp)
  801622:	ff d7                	call   *%edi
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	eb 03                	jmp    80162c <printnum+0x78>
  801629:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80162c:	83 eb 01             	sub    $0x1,%ebx
  80162f:	85 db                	test   %ebx,%ebx
  801631:	7f e8                	jg     80161b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	56                   	push   %esi
  801637:	83 ec 04             	sub    $0x4,%esp
  80163a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80163d:	ff 75 e0             	pushl  -0x20(%ebp)
  801640:	ff 75 dc             	pushl  -0x24(%ebp)
  801643:	ff 75 d8             	pushl  -0x28(%ebp)
  801646:	e8 b5 0a 00 00       	call   802100 <__umoddi3>
  80164b:	83 c4 14             	add    $0x14,%esp
  80164e:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801655:	50                   	push   %eax
  801656:	ff d7                	call   *%edi
}
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165e:	5b                   	pop    %ebx
  80165f:	5e                   	pop    %esi
  801660:	5f                   	pop    %edi
  801661:	5d                   	pop    %ebp
  801662:	c3                   	ret    

00801663 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801666:	83 fa 01             	cmp    $0x1,%edx
  801669:	7e 0e                	jle    801679 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80166b:	8b 10                	mov    (%eax),%edx
  80166d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801670:	89 08                	mov    %ecx,(%eax)
  801672:	8b 02                	mov    (%edx),%eax
  801674:	8b 52 04             	mov    0x4(%edx),%edx
  801677:	eb 22                	jmp    80169b <getuint+0x38>
	else if (lflag)
  801679:	85 d2                	test   %edx,%edx
  80167b:	74 10                	je     80168d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80167d:	8b 10                	mov    (%eax),%edx
  80167f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801682:	89 08                	mov    %ecx,(%eax)
  801684:	8b 02                	mov    (%edx),%eax
  801686:	ba 00 00 00 00       	mov    $0x0,%edx
  80168b:	eb 0e                	jmp    80169b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80168d:	8b 10                	mov    (%eax),%edx
  80168f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801692:	89 08                	mov    %ecx,(%eax)
  801694:	8b 02                	mov    (%edx),%eax
  801696:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016a7:	8b 10                	mov    (%eax),%edx
  8016a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8016ac:	73 0a                	jae    8016b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016b1:	89 08                	mov    %ecx,(%eax)
  8016b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b6:	88 02                	mov    %al,(%edx)
}
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016c3:	50                   	push   %eax
  8016c4:	ff 75 10             	pushl  0x10(%ebp)
  8016c7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ca:	ff 75 08             	pushl  0x8(%ebp)
  8016cd:	e8 05 00 00 00       	call   8016d7 <vprintfmt>
	va_end(ap);
}
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    

008016d7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	57                   	push   %edi
  8016db:	56                   	push   %esi
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 2c             	sub    $0x2c,%esp
  8016e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8016e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016e6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016e9:	eb 12                	jmp    8016fd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	0f 84 a9 03 00 00    	je     801a9c <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	53                   	push   %ebx
  8016f7:	50                   	push   %eax
  8016f8:	ff d6                	call   *%esi
  8016fa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016fd:	83 c7 01             	add    $0x1,%edi
  801700:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801704:	83 f8 25             	cmp    $0x25,%eax
  801707:	75 e2                	jne    8016eb <vprintfmt+0x14>
  801709:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80170d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801714:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80171b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801722:	ba 00 00 00 00       	mov    $0x0,%edx
  801727:	eb 07                	jmp    801730 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801729:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80172c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801730:	8d 47 01             	lea    0x1(%edi),%eax
  801733:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801736:	0f b6 07             	movzbl (%edi),%eax
  801739:	0f b6 c8             	movzbl %al,%ecx
  80173c:	83 e8 23             	sub    $0x23,%eax
  80173f:	3c 55                	cmp    $0x55,%al
  801741:	0f 87 3a 03 00 00    	ja     801a81 <vprintfmt+0x3aa>
  801747:	0f b6 c0             	movzbl %al,%eax
  80174a:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801751:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801754:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801758:	eb d6                	jmp    801730 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80175d:	b8 00 00 00 00       	mov    $0x0,%eax
  801762:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801765:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801768:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80176c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80176f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801772:	83 fa 09             	cmp    $0x9,%edx
  801775:	77 39                	ja     8017b0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801777:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80177a:	eb e9                	jmp    801765 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80177c:	8b 45 14             	mov    0x14(%ebp),%eax
  80177f:	8d 48 04             	lea    0x4(%eax),%ecx
  801782:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801785:	8b 00                	mov    (%eax),%eax
  801787:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80178d:	eb 27                	jmp    8017b6 <vprintfmt+0xdf>
  80178f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801792:	85 c0                	test   %eax,%eax
  801794:	b9 00 00 00 00       	mov    $0x0,%ecx
  801799:	0f 49 c8             	cmovns %eax,%ecx
  80179c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80179f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017a2:	eb 8c                	jmp    801730 <vprintfmt+0x59>
  8017a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017a7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017ae:	eb 80                	jmp    801730 <vprintfmt+0x59>
  8017b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017ba:	0f 89 70 ff ff ff    	jns    801730 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017cd:	e9 5e ff ff ff       	jmp    801730 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017d2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017d8:	e9 53 ff ff ff       	jmp    801730 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e0:	8d 50 04             	lea    0x4(%eax),%edx
  8017e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8017e6:	83 ec 08             	sub    $0x8,%esp
  8017e9:	53                   	push   %ebx
  8017ea:	ff 30                	pushl  (%eax)
  8017ec:	ff d6                	call   *%esi
			break;
  8017ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017f4:	e9 04 ff ff ff       	jmp    8016fd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fc:	8d 50 04             	lea    0x4(%eax),%edx
  8017ff:	89 55 14             	mov    %edx,0x14(%ebp)
  801802:	8b 00                	mov    (%eax),%eax
  801804:	99                   	cltd   
  801805:	31 d0                	xor    %edx,%eax
  801807:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801809:	83 f8 0f             	cmp    $0xf,%eax
  80180c:	7f 0b                	jg     801819 <vprintfmt+0x142>
  80180e:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801815:	85 d2                	test   %edx,%edx
  801817:	75 18                	jne    801831 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801819:	50                   	push   %eax
  80181a:	68 fb 23 80 00       	push   $0x8023fb
  80181f:	53                   	push   %ebx
  801820:	56                   	push   %esi
  801821:	e8 94 fe ff ff       	call   8016ba <printfmt>
  801826:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801829:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80182c:	e9 cc fe ff ff       	jmp    8016fd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801831:	52                   	push   %edx
  801832:	68 41 23 80 00       	push   $0x802341
  801837:	53                   	push   %ebx
  801838:	56                   	push   %esi
  801839:	e8 7c fe ff ff       	call   8016ba <printfmt>
  80183e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801841:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801844:	e9 b4 fe ff ff       	jmp    8016fd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801849:	8b 45 14             	mov    0x14(%ebp),%eax
  80184c:	8d 50 04             	lea    0x4(%eax),%edx
  80184f:	89 55 14             	mov    %edx,0x14(%ebp)
  801852:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801854:	85 ff                	test   %edi,%edi
  801856:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  80185b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80185e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801862:	0f 8e 94 00 00 00    	jle    8018fc <vprintfmt+0x225>
  801868:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80186c:	0f 84 98 00 00 00    	je     80190a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801872:	83 ec 08             	sub    $0x8,%esp
  801875:	ff 75 d0             	pushl  -0x30(%ebp)
  801878:	57                   	push   %edi
  801879:	e8 a6 02 00 00       	call   801b24 <strnlen>
  80187e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801881:	29 c1                	sub    %eax,%ecx
  801883:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801886:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801889:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80188d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801890:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801893:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801895:	eb 0f                	jmp    8018a6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	53                   	push   %ebx
  80189b:	ff 75 e0             	pushl  -0x20(%ebp)
  80189e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a0:	83 ef 01             	sub    $0x1,%edi
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	85 ff                	test   %edi,%edi
  8018a8:	7f ed                	jg     801897 <vprintfmt+0x1c0>
  8018aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018ad:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018b0:	85 c9                	test   %ecx,%ecx
  8018b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b7:	0f 49 c1             	cmovns %ecx,%eax
  8018ba:	29 c1                	sub    %eax,%ecx
  8018bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8018bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018c5:	89 cb                	mov    %ecx,%ebx
  8018c7:	eb 4d                	jmp    801916 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018cd:	74 1b                	je     8018ea <vprintfmt+0x213>
  8018cf:	0f be c0             	movsbl %al,%eax
  8018d2:	83 e8 20             	sub    $0x20,%eax
  8018d5:	83 f8 5e             	cmp    $0x5e,%eax
  8018d8:	76 10                	jbe    8018ea <vprintfmt+0x213>
					putch('?', putdat);
  8018da:	83 ec 08             	sub    $0x8,%esp
  8018dd:	ff 75 0c             	pushl  0xc(%ebp)
  8018e0:	6a 3f                	push   $0x3f
  8018e2:	ff 55 08             	call   *0x8(%ebp)
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	eb 0d                	jmp    8018f7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	ff 75 0c             	pushl  0xc(%ebp)
  8018f0:	52                   	push   %edx
  8018f1:	ff 55 08             	call   *0x8(%ebp)
  8018f4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018f7:	83 eb 01             	sub    $0x1,%ebx
  8018fa:	eb 1a                	jmp    801916 <vprintfmt+0x23f>
  8018fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801902:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801905:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801908:	eb 0c                	jmp    801916 <vprintfmt+0x23f>
  80190a:	89 75 08             	mov    %esi,0x8(%ebp)
  80190d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801910:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801913:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801916:	83 c7 01             	add    $0x1,%edi
  801919:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80191d:	0f be d0             	movsbl %al,%edx
  801920:	85 d2                	test   %edx,%edx
  801922:	74 23                	je     801947 <vprintfmt+0x270>
  801924:	85 f6                	test   %esi,%esi
  801926:	78 a1                	js     8018c9 <vprintfmt+0x1f2>
  801928:	83 ee 01             	sub    $0x1,%esi
  80192b:	79 9c                	jns    8018c9 <vprintfmt+0x1f2>
  80192d:	89 df                	mov    %ebx,%edi
  80192f:	8b 75 08             	mov    0x8(%ebp),%esi
  801932:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801935:	eb 18                	jmp    80194f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801937:	83 ec 08             	sub    $0x8,%esp
  80193a:	53                   	push   %ebx
  80193b:	6a 20                	push   $0x20
  80193d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80193f:	83 ef 01             	sub    $0x1,%edi
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	eb 08                	jmp    80194f <vprintfmt+0x278>
  801947:	89 df                	mov    %ebx,%edi
  801949:	8b 75 08             	mov    0x8(%ebp),%esi
  80194c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80194f:	85 ff                	test   %edi,%edi
  801951:	7f e4                	jg     801937 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801953:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801956:	e9 a2 fd ff ff       	jmp    8016fd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80195b:	83 fa 01             	cmp    $0x1,%edx
  80195e:	7e 16                	jle    801976 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801960:	8b 45 14             	mov    0x14(%ebp),%eax
  801963:	8d 50 08             	lea    0x8(%eax),%edx
  801966:	89 55 14             	mov    %edx,0x14(%ebp)
  801969:	8b 50 04             	mov    0x4(%eax),%edx
  80196c:	8b 00                	mov    (%eax),%eax
  80196e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801971:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801974:	eb 32                	jmp    8019a8 <vprintfmt+0x2d1>
	else if (lflag)
  801976:	85 d2                	test   %edx,%edx
  801978:	74 18                	je     801992 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80197a:	8b 45 14             	mov    0x14(%ebp),%eax
  80197d:	8d 50 04             	lea    0x4(%eax),%edx
  801980:	89 55 14             	mov    %edx,0x14(%ebp)
  801983:	8b 00                	mov    (%eax),%eax
  801985:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801988:	89 c1                	mov    %eax,%ecx
  80198a:	c1 f9 1f             	sar    $0x1f,%ecx
  80198d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801990:	eb 16                	jmp    8019a8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801992:	8b 45 14             	mov    0x14(%ebp),%eax
  801995:	8d 50 04             	lea    0x4(%eax),%edx
  801998:	89 55 14             	mov    %edx,0x14(%ebp)
  80199b:	8b 00                	mov    (%eax),%eax
  80199d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a0:	89 c1                	mov    %eax,%ecx
  8019a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8019a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019b3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019b7:	0f 89 90 00 00 00    	jns    801a4d <vprintfmt+0x376>
				putch('-', putdat);
  8019bd:	83 ec 08             	sub    $0x8,%esp
  8019c0:	53                   	push   %ebx
  8019c1:	6a 2d                	push   $0x2d
  8019c3:	ff d6                	call   *%esi
				num = -(long long) num;
  8019c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019cb:	f7 d8                	neg    %eax
  8019cd:	83 d2 00             	adc    $0x0,%edx
  8019d0:	f7 da                	neg    %edx
  8019d2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019da:	eb 71                	jmp    801a4d <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8019df:	e8 7f fc ff ff       	call   801663 <getuint>
			base = 10;
  8019e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019e9:	eb 62                	jmp    801a4d <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8019eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8019ee:	e8 70 fc ff ff       	call   801663 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8019f3:	83 ec 0c             	sub    $0xc,%esp
  8019f6:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8019fa:	51                   	push   %ecx
  8019fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8019fe:	6a 08                	push   $0x8
  801a00:	52                   	push   %edx
  801a01:	50                   	push   %eax
  801a02:	89 da                	mov    %ebx,%edx
  801a04:	89 f0                	mov    %esi,%eax
  801a06:	e8 a9 fb ff ff       	call   8015b4 <printnum>
			break;
  801a0b:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  801a11:	e9 e7 fc ff ff       	jmp    8016fd <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a16:	83 ec 08             	sub    $0x8,%esp
  801a19:	53                   	push   %ebx
  801a1a:	6a 30                	push   $0x30
  801a1c:	ff d6                	call   *%esi
			putch('x', putdat);
  801a1e:	83 c4 08             	add    $0x8,%esp
  801a21:	53                   	push   %ebx
  801a22:	6a 78                	push   $0x78
  801a24:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a26:	8b 45 14             	mov    0x14(%ebp),%eax
  801a29:	8d 50 04             	lea    0x4(%eax),%edx
  801a2c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a2f:	8b 00                	mov    (%eax),%eax
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a36:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a39:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a3e:	eb 0d                	jmp    801a4d <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a40:	8d 45 14             	lea    0x14(%ebp),%eax
  801a43:	e8 1b fc ff ff       	call   801663 <getuint>
			base = 16;
  801a48:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a4d:	83 ec 0c             	sub    $0xc,%esp
  801a50:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a54:	57                   	push   %edi
  801a55:	ff 75 e0             	pushl  -0x20(%ebp)
  801a58:	51                   	push   %ecx
  801a59:	52                   	push   %edx
  801a5a:	50                   	push   %eax
  801a5b:	89 da                	mov    %ebx,%edx
  801a5d:	89 f0                	mov    %esi,%eax
  801a5f:	e8 50 fb ff ff       	call   8015b4 <printnum>
			break;
  801a64:	83 c4 20             	add    $0x20,%esp
  801a67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a6a:	e9 8e fc ff ff       	jmp    8016fd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a6f:	83 ec 08             	sub    $0x8,%esp
  801a72:	53                   	push   %ebx
  801a73:	51                   	push   %ecx
  801a74:	ff d6                	call   *%esi
			break;
  801a76:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a7c:	e9 7c fc ff ff       	jmp    8016fd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a81:	83 ec 08             	sub    $0x8,%esp
  801a84:	53                   	push   %ebx
  801a85:	6a 25                	push   $0x25
  801a87:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	eb 03                	jmp    801a91 <vprintfmt+0x3ba>
  801a8e:	83 ef 01             	sub    $0x1,%edi
  801a91:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a95:	75 f7                	jne    801a8e <vprintfmt+0x3b7>
  801a97:	e9 61 fc ff ff       	jmp    8016fd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5f                   	pop    %edi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	83 ec 18             	sub    $0x18,%esp
  801aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801aad:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ab7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801aba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	74 26                	je     801aeb <vsnprintf+0x47>
  801ac5:	85 d2                	test   %edx,%edx
  801ac7:	7e 22                	jle    801aeb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ac9:	ff 75 14             	pushl  0x14(%ebp)
  801acc:	ff 75 10             	pushl  0x10(%ebp)
  801acf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad2:	50                   	push   %eax
  801ad3:	68 9d 16 80 00       	push   $0x80169d
  801ad8:	e8 fa fb ff ff       	call   8016d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801add:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	eb 05                	jmp    801af0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801aeb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801af8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801afb:	50                   	push   %eax
  801afc:	ff 75 10             	pushl  0x10(%ebp)
  801aff:	ff 75 0c             	pushl  0xc(%ebp)
  801b02:	ff 75 08             	pushl  0x8(%ebp)
  801b05:	e8 9a ff ff ff       	call   801aa4 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b12:	b8 00 00 00 00       	mov    $0x0,%eax
  801b17:	eb 03                	jmp    801b1c <strlen+0x10>
		n++;
  801b19:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b20:	75 f7                	jne    801b19 <strlen+0xd>
		n++;
	return n;
}
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b32:	eb 03                	jmp    801b37 <strnlen+0x13>
		n++;
  801b34:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b37:	39 c2                	cmp    %eax,%edx
  801b39:	74 08                	je     801b43 <strnlen+0x1f>
  801b3b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b3f:	75 f3                	jne    801b34 <strnlen+0x10>
  801b41:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	53                   	push   %ebx
  801b49:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b4f:	89 c2                	mov    %eax,%edx
  801b51:	83 c2 01             	add    $0x1,%edx
  801b54:	83 c1 01             	add    $0x1,%ecx
  801b57:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b5b:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b5e:	84 db                	test   %bl,%bl
  801b60:	75 ef                	jne    801b51 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b62:	5b                   	pop    %ebx
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	53                   	push   %ebx
  801b69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b6c:	53                   	push   %ebx
  801b6d:	e8 9a ff ff ff       	call   801b0c <strlen>
  801b72:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b75:	ff 75 0c             	pushl  0xc(%ebp)
  801b78:	01 d8                	add    %ebx,%eax
  801b7a:	50                   	push   %eax
  801b7b:	e8 c5 ff ff ff       	call   801b45 <strcpy>
	return dst;
}
  801b80:	89 d8                	mov    %ebx,%eax
  801b82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b92:	89 f3                	mov    %esi,%ebx
  801b94:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b97:	89 f2                	mov    %esi,%edx
  801b99:	eb 0f                	jmp    801baa <strncpy+0x23>
		*dst++ = *src;
  801b9b:	83 c2 01             	add    $0x1,%edx
  801b9e:	0f b6 01             	movzbl (%ecx),%eax
  801ba1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba4:	80 39 01             	cmpb   $0x1,(%ecx)
  801ba7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801baa:	39 da                	cmp    %ebx,%edx
  801bac:	75 ed                	jne    801b9b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bae:	89 f0                	mov    %esi,%eax
  801bb0:	5b                   	pop    %ebx
  801bb1:	5e                   	pop    %esi
  801bb2:	5d                   	pop    %ebp
  801bb3:	c3                   	ret    

00801bb4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	56                   	push   %esi
  801bb8:	53                   	push   %ebx
  801bb9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbf:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc4:	85 d2                	test   %edx,%edx
  801bc6:	74 21                	je     801be9 <strlcpy+0x35>
  801bc8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bcc:	89 f2                	mov    %esi,%edx
  801bce:	eb 09                	jmp    801bd9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bd0:	83 c2 01             	add    $0x1,%edx
  801bd3:	83 c1 01             	add    $0x1,%ecx
  801bd6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bd9:	39 c2                	cmp    %eax,%edx
  801bdb:	74 09                	je     801be6 <strlcpy+0x32>
  801bdd:	0f b6 19             	movzbl (%ecx),%ebx
  801be0:	84 db                	test   %bl,%bl
  801be2:	75 ec                	jne    801bd0 <strlcpy+0x1c>
  801be4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801be6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801be9:	29 f0                	sub    %esi,%eax
}
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bf8:	eb 06                	jmp    801c00 <strcmp+0x11>
		p++, q++;
  801bfa:	83 c1 01             	add    $0x1,%ecx
  801bfd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c00:	0f b6 01             	movzbl (%ecx),%eax
  801c03:	84 c0                	test   %al,%al
  801c05:	74 04                	je     801c0b <strcmp+0x1c>
  801c07:	3a 02                	cmp    (%edx),%al
  801c09:	74 ef                	je     801bfa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c0b:	0f b6 c0             	movzbl %al,%eax
  801c0e:	0f b6 12             	movzbl (%edx),%edx
  801c11:	29 d0                	sub    %edx,%eax
}
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	53                   	push   %ebx
  801c19:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1f:	89 c3                	mov    %eax,%ebx
  801c21:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c24:	eb 06                	jmp    801c2c <strncmp+0x17>
		n--, p++, q++;
  801c26:	83 c0 01             	add    $0x1,%eax
  801c29:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c2c:	39 d8                	cmp    %ebx,%eax
  801c2e:	74 15                	je     801c45 <strncmp+0x30>
  801c30:	0f b6 08             	movzbl (%eax),%ecx
  801c33:	84 c9                	test   %cl,%cl
  801c35:	74 04                	je     801c3b <strncmp+0x26>
  801c37:	3a 0a                	cmp    (%edx),%cl
  801c39:	74 eb                	je     801c26 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3b:	0f b6 00             	movzbl (%eax),%eax
  801c3e:	0f b6 12             	movzbl (%edx),%edx
  801c41:	29 d0                	sub    %edx,%eax
  801c43:	eb 05                	jmp    801c4a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c4a:	5b                   	pop    %ebx
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    

00801c4d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	8b 45 08             	mov    0x8(%ebp),%eax
  801c53:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c57:	eb 07                	jmp    801c60 <strchr+0x13>
		if (*s == c)
  801c59:	38 ca                	cmp    %cl,%dl
  801c5b:	74 0f                	je     801c6c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c5d:	83 c0 01             	add    $0x1,%eax
  801c60:	0f b6 10             	movzbl (%eax),%edx
  801c63:	84 d2                	test   %dl,%dl
  801c65:	75 f2                	jne    801c59 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    

00801c6e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	8b 45 08             	mov    0x8(%ebp),%eax
  801c74:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c78:	eb 03                	jmp    801c7d <strfind+0xf>
  801c7a:	83 c0 01             	add    $0x1,%eax
  801c7d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c80:	38 ca                	cmp    %cl,%dl
  801c82:	74 04                	je     801c88 <strfind+0x1a>
  801c84:	84 d2                	test   %dl,%dl
  801c86:	75 f2                	jne    801c7a <strfind+0xc>
			break;
	return (char *) s;
}
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	57                   	push   %edi
  801c8e:	56                   	push   %esi
  801c8f:	53                   	push   %ebx
  801c90:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c96:	85 c9                	test   %ecx,%ecx
  801c98:	74 36                	je     801cd0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c9a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ca0:	75 28                	jne    801cca <memset+0x40>
  801ca2:	f6 c1 03             	test   $0x3,%cl
  801ca5:	75 23                	jne    801cca <memset+0x40>
		c &= 0xFF;
  801ca7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cab:	89 d3                	mov    %edx,%ebx
  801cad:	c1 e3 08             	shl    $0x8,%ebx
  801cb0:	89 d6                	mov    %edx,%esi
  801cb2:	c1 e6 18             	shl    $0x18,%esi
  801cb5:	89 d0                	mov    %edx,%eax
  801cb7:	c1 e0 10             	shl    $0x10,%eax
  801cba:	09 f0                	or     %esi,%eax
  801cbc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cbe:	89 d8                	mov    %ebx,%eax
  801cc0:	09 d0                	or     %edx,%eax
  801cc2:	c1 e9 02             	shr    $0x2,%ecx
  801cc5:	fc                   	cld    
  801cc6:	f3 ab                	rep stos %eax,%es:(%edi)
  801cc8:	eb 06                	jmp    801cd0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccd:	fc                   	cld    
  801cce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cd0:	89 f8                	mov    %edi,%eax
  801cd2:	5b                   	pop    %ebx
  801cd3:	5e                   	pop    %esi
  801cd4:	5f                   	pop    %edi
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	57                   	push   %edi
  801cdb:	56                   	push   %esi
  801cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce5:	39 c6                	cmp    %eax,%esi
  801ce7:	73 35                	jae    801d1e <memmove+0x47>
  801ce9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cec:	39 d0                	cmp    %edx,%eax
  801cee:	73 2e                	jae    801d1e <memmove+0x47>
		s += n;
		d += n;
  801cf0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf3:	89 d6                	mov    %edx,%esi
  801cf5:	09 fe                	or     %edi,%esi
  801cf7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cfd:	75 13                	jne    801d12 <memmove+0x3b>
  801cff:	f6 c1 03             	test   $0x3,%cl
  801d02:	75 0e                	jne    801d12 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d04:	83 ef 04             	sub    $0x4,%edi
  801d07:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d0a:	c1 e9 02             	shr    $0x2,%ecx
  801d0d:	fd                   	std    
  801d0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d10:	eb 09                	jmp    801d1b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d12:	83 ef 01             	sub    $0x1,%edi
  801d15:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d18:	fd                   	std    
  801d19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d1b:	fc                   	cld    
  801d1c:	eb 1d                	jmp    801d3b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1e:	89 f2                	mov    %esi,%edx
  801d20:	09 c2                	or     %eax,%edx
  801d22:	f6 c2 03             	test   $0x3,%dl
  801d25:	75 0f                	jne    801d36 <memmove+0x5f>
  801d27:	f6 c1 03             	test   $0x3,%cl
  801d2a:	75 0a                	jne    801d36 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d2c:	c1 e9 02             	shr    $0x2,%ecx
  801d2f:	89 c7                	mov    %eax,%edi
  801d31:	fc                   	cld    
  801d32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d34:	eb 05                	jmp    801d3b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d36:	89 c7                	mov    %eax,%edi
  801d38:	fc                   	cld    
  801d39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d3b:	5e                   	pop    %esi
  801d3c:	5f                   	pop    %edi
  801d3d:	5d                   	pop    %ebp
  801d3e:	c3                   	ret    

00801d3f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d42:	ff 75 10             	pushl  0x10(%ebp)
  801d45:	ff 75 0c             	pushl  0xc(%ebp)
  801d48:	ff 75 08             	pushl  0x8(%ebp)
  801d4b:	e8 87 ff ff ff       	call   801cd7 <memmove>
}
  801d50:	c9                   	leave  
  801d51:	c3                   	ret    

00801d52 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	56                   	push   %esi
  801d56:	53                   	push   %ebx
  801d57:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5d:	89 c6                	mov    %eax,%esi
  801d5f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d62:	eb 1a                	jmp    801d7e <memcmp+0x2c>
		if (*s1 != *s2)
  801d64:	0f b6 08             	movzbl (%eax),%ecx
  801d67:	0f b6 1a             	movzbl (%edx),%ebx
  801d6a:	38 d9                	cmp    %bl,%cl
  801d6c:	74 0a                	je     801d78 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d6e:	0f b6 c1             	movzbl %cl,%eax
  801d71:	0f b6 db             	movzbl %bl,%ebx
  801d74:	29 d8                	sub    %ebx,%eax
  801d76:	eb 0f                	jmp    801d87 <memcmp+0x35>
		s1++, s2++;
  801d78:	83 c0 01             	add    $0x1,%eax
  801d7b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d7e:	39 f0                	cmp    %esi,%eax
  801d80:	75 e2                	jne    801d64 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	53                   	push   %ebx
  801d8f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d92:	89 c1                	mov    %eax,%ecx
  801d94:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d97:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d9b:	eb 0a                	jmp    801da7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9d:	0f b6 10             	movzbl (%eax),%edx
  801da0:	39 da                	cmp    %ebx,%edx
  801da2:	74 07                	je     801dab <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da4:	83 c0 01             	add    $0x1,%eax
  801da7:	39 c8                	cmp    %ecx,%eax
  801da9:	72 f2                	jb     801d9d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dab:	5b                   	pop    %ebx
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dba:	eb 03                	jmp    801dbf <strtol+0x11>
		s++;
  801dbc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dbf:	0f b6 01             	movzbl (%ecx),%eax
  801dc2:	3c 20                	cmp    $0x20,%al
  801dc4:	74 f6                	je     801dbc <strtol+0xe>
  801dc6:	3c 09                	cmp    $0x9,%al
  801dc8:	74 f2                	je     801dbc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dca:	3c 2b                	cmp    $0x2b,%al
  801dcc:	75 0a                	jne    801dd8 <strtol+0x2a>
		s++;
  801dce:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dd1:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd6:	eb 11                	jmp    801de9 <strtol+0x3b>
  801dd8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ddd:	3c 2d                	cmp    $0x2d,%al
  801ddf:	75 08                	jne    801de9 <strtol+0x3b>
		s++, neg = 1;
  801de1:	83 c1 01             	add    $0x1,%ecx
  801de4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801de9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801def:	75 15                	jne    801e06 <strtol+0x58>
  801df1:	80 39 30             	cmpb   $0x30,(%ecx)
  801df4:	75 10                	jne    801e06 <strtol+0x58>
  801df6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dfa:	75 7c                	jne    801e78 <strtol+0xca>
		s += 2, base = 16;
  801dfc:	83 c1 02             	add    $0x2,%ecx
  801dff:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e04:	eb 16                	jmp    801e1c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e06:	85 db                	test   %ebx,%ebx
  801e08:	75 12                	jne    801e1c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e0a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e0f:	80 39 30             	cmpb   $0x30,(%ecx)
  801e12:	75 08                	jne    801e1c <strtol+0x6e>
		s++, base = 8;
  801e14:	83 c1 01             	add    $0x1,%ecx
  801e17:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e21:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e24:	0f b6 11             	movzbl (%ecx),%edx
  801e27:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e2a:	89 f3                	mov    %esi,%ebx
  801e2c:	80 fb 09             	cmp    $0x9,%bl
  801e2f:	77 08                	ja     801e39 <strtol+0x8b>
			dig = *s - '0';
  801e31:	0f be d2             	movsbl %dl,%edx
  801e34:	83 ea 30             	sub    $0x30,%edx
  801e37:	eb 22                	jmp    801e5b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e39:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e3c:	89 f3                	mov    %esi,%ebx
  801e3e:	80 fb 19             	cmp    $0x19,%bl
  801e41:	77 08                	ja     801e4b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e43:	0f be d2             	movsbl %dl,%edx
  801e46:	83 ea 57             	sub    $0x57,%edx
  801e49:	eb 10                	jmp    801e5b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e4b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e4e:	89 f3                	mov    %esi,%ebx
  801e50:	80 fb 19             	cmp    $0x19,%bl
  801e53:	77 16                	ja     801e6b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e55:	0f be d2             	movsbl %dl,%edx
  801e58:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e5e:	7d 0b                	jge    801e6b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e60:	83 c1 01             	add    $0x1,%ecx
  801e63:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e67:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e69:	eb b9                	jmp    801e24 <strtol+0x76>

	if (endptr)
  801e6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e6f:	74 0d                	je     801e7e <strtol+0xd0>
		*endptr = (char *) s;
  801e71:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e74:	89 0e                	mov    %ecx,(%esi)
  801e76:	eb 06                	jmp    801e7e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e78:	85 db                	test   %ebx,%ebx
  801e7a:	74 98                	je     801e14 <strtol+0x66>
  801e7c:	eb 9e                	jmp    801e1c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e7e:	89 c2                	mov    %eax,%edx
  801e80:	f7 da                	neg    %edx
  801e82:	85 ff                	test   %edi,%edi
  801e84:	0f 45 c2             	cmovne %edx,%eax
}
  801e87:	5b                   	pop    %ebx
  801e88:	5e                   	pop    %esi
  801e89:	5f                   	pop    %edi
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    

00801e8c <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	56                   	push   %esi
  801e90:	53                   	push   %ebx
  801e91:	8b 75 08             	mov    0x8(%ebp),%esi
  801e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	74 0e                	je     801eac <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	50                   	push   %eax
  801ea2:	e8 63 e4 ff ff       	call   80030a <sys_ipc_recv>
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	eb 10                	jmp    801ebc <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801eac:	83 ec 0c             	sub    $0xc,%esp
  801eaf:	68 00 00 c0 ee       	push   $0xeec00000
  801eb4:	e8 51 e4 ff ff       	call   80030a <sys_ipc_recv>
  801eb9:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	79 17                	jns    801ed7 <ipc_recv+0x4b>
		if(*from_env_store)
  801ec0:	83 3e 00             	cmpl   $0x0,(%esi)
  801ec3:	74 06                	je     801ecb <ipc_recv+0x3f>
			*from_env_store = 0;
  801ec5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801ecb:	85 db                	test   %ebx,%ebx
  801ecd:	74 2c                	je     801efb <ipc_recv+0x6f>
			*perm_store = 0;
  801ecf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ed5:	eb 24                	jmp    801efb <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801ed7:	85 f6                	test   %esi,%esi
  801ed9:	74 0a                	je     801ee5 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801edb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee0:	8b 40 74             	mov    0x74(%eax),%eax
  801ee3:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801ee5:	85 db                	test   %ebx,%ebx
  801ee7:	74 0a                	je     801ef3 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801ee9:	a1 08 40 80 00       	mov    0x804008,%eax
  801eee:	8b 40 78             	mov    0x78(%eax),%eax
  801ef1:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ef3:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef8:	8b 40 70             	mov    0x70(%eax),%eax
}
  801efb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efe:	5b                   	pop    %ebx
  801eff:	5e                   	pop    %esi
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    

00801f02 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	57                   	push   %edi
  801f06:	56                   	push   %esi
  801f07:	53                   	push   %ebx
  801f08:	83 ec 0c             	sub    $0xc,%esp
  801f0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f14:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f16:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f1b:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f1e:	e8 18 e2 ff ff       	call   80013b <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f23:	ff 75 14             	pushl  0x14(%ebp)
  801f26:	53                   	push   %ebx
  801f27:	56                   	push   %esi
  801f28:	57                   	push   %edi
  801f29:	e8 b9 e3 ff ff       	call   8002e7 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f2e:	89 c2                	mov    %eax,%edx
  801f30:	f7 d2                	not    %edx
  801f32:	c1 ea 1f             	shr    $0x1f,%edx
  801f35:	83 c4 10             	add    $0x10,%esp
  801f38:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f3b:	0f 94 c1             	sete   %cl
  801f3e:	09 ca                	or     %ecx,%edx
  801f40:	85 c0                	test   %eax,%eax
  801f42:	0f 94 c0             	sete   %al
  801f45:	38 c2                	cmp    %al,%dl
  801f47:	77 d5                	ja     801f1e <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801f49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4c:	5b                   	pop    %ebx
  801f4d:	5e                   	pop    %esi
  801f4e:	5f                   	pop    %edi
  801f4f:	5d                   	pop    %ebp
  801f50:	c3                   	ret    

00801f51 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f57:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f5c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f5f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f65:	8b 52 50             	mov    0x50(%edx),%edx
  801f68:	39 ca                	cmp    %ecx,%edx
  801f6a:	75 0d                	jne    801f79 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f6c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f6f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f74:	8b 40 48             	mov    0x48(%eax),%eax
  801f77:	eb 0f                	jmp    801f88 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f79:	83 c0 01             	add    $0x1,%eax
  801f7c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f81:	75 d9                	jne    801f5c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f88:	5d                   	pop    %ebp
  801f89:	c3                   	ret    

00801f8a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f90:	89 d0                	mov    %edx,%eax
  801f92:	c1 e8 16             	shr    $0x16,%eax
  801f95:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa1:	f6 c1 01             	test   $0x1,%cl
  801fa4:	74 1d                	je     801fc3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa6:	c1 ea 0c             	shr    $0xc,%edx
  801fa9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb0:	f6 c2 01             	test   $0x1,%dl
  801fb3:	74 0e                	je     801fc3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb5:	c1 ea 0c             	shr    $0xc,%edx
  801fb8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fbf:	ef 
  801fc0:	0f b7 c0             	movzwl %ax,%eax
}
  801fc3:	5d                   	pop    %ebp
  801fc4:	c3                   	ret    
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
