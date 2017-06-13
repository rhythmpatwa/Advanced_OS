
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 a6 04 00 00       	call   80053e <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 6a 22 80 00       	push   $0x80226a
  800111:	6a 23                	push   $0x23
  800113:	68 87 22 80 00       	push   $0x802287
  800118:	e8 b3 13 00 00       	call   8014d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 6a 22 80 00       	push   $0x80226a
  800192:	6a 23                	push   $0x23
  800194:	68 87 22 80 00       	push   $0x802287
  800199:	e8 32 13 00 00       	call   8014d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 6a 22 80 00       	push   $0x80226a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 87 22 80 00       	push   $0x802287
  8001db:	e8 f0 12 00 00       	call   8014d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 6a 22 80 00       	push   $0x80226a
  800216:	6a 23                	push   $0x23
  800218:	68 87 22 80 00       	push   $0x802287
  80021d:	e8 ae 12 00 00       	call   8014d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 6a 22 80 00       	push   $0x80226a
  800258:	6a 23                	push   $0x23
  80025a:	68 87 22 80 00       	push   $0x802287
  80025f:	e8 6c 12 00 00       	call   8014d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 6a 22 80 00       	push   $0x80226a
  80029a:	6a 23                	push   $0x23
  80029c:	68 87 22 80 00       	push   $0x802287
  8002a1:	e8 2a 12 00 00       	call   8014d0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 6a 22 80 00       	push   $0x80226a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 87 22 80 00       	push   $0x802287
  8002e3:	e8 e8 11 00 00       	call   8014d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 6a 22 80 00       	push   $0x80226a
  800340:	6a 23                	push   $0x23
  800342:	68 87 22 80 00       	push   $0x802287
  800347:	e8 84 11 00 00       	call   8014d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
  80035f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800364:	89 d1                	mov    %edx,%ecx
  800366:	89 d3                	mov    %edx,%ebx
  800368:	89 d7                	mov    %edx,%edi
  80036a:	89 d6                	mov    %edx,%esi
  80036c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800376:	8b 45 08             	mov    0x8(%ebp),%eax
  800379:	05 00 00 00 30       	add    $0x30000000,%eax
  80037e:	c1 e8 0c             	shr    $0xc,%eax
}
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800386:	8b 45 08             	mov    0x8(%ebp),%eax
  800389:	05 00 00 00 30       	add    $0x30000000,%eax
  80038e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800393:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a5:	89 c2                	mov    %eax,%edx
  8003a7:	c1 ea 16             	shr    $0x16,%edx
  8003aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b1:	f6 c2 01             	test   $0x1,%dl
  8003b4:	74 11                	je     8003c7 <fd_alloc+0x2d>
  8003b6:	89 c2                	mov    %eax,%edx
  8003b8:	c1 ea 0c             	shr    $0xc,%edx
  8003bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c2:	f6 c2 01             	test   $0x1,%dl
  8003c5:	75 09                	jne    8003d0 <fd_alloc+0x36>
			*fd_store = fd;
  8003c7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ce:	eb 17                	jmp    8003e7 <fd_alloc+0x4d>
  8003d0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003da:	75 c9                	jne    8003a5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003dc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ef:	83 f8 1f             	cmp    $0x1f,%eax
  8003f2:	77 36                	ja     80042a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f4:	c1 e0 0c             	shl    $0xc,%eax
  8003f7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fc:	89 c2                	mov    %eax,%edx
  8003fe:	c1 ea 16             	shr    $0x16,%edx
  800401:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800408:	f6 c2 01             	test   $0x1,%dl
  80040b:	74 24                	je     800431 <fd_lookup+0x48>
  80040d:	89 c2                	mov    %eax,%edx
  80040f:	c1 ea 0c             	shr    $0xc,%edx
  800412:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800419:	f6 c2 01             	test   $0x1,%dl
  80041c:	74 1a                	je     800438 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800421:	89 02                	mov    %eax,(%edx)
	return 0;
  800423:	b8 00 00 00 00       	mov    $0x0,%eax
  800428:	eb 13                	jmp    80043d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042f:	eb 0c                	jmp    80043d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800436:	eb 05                	jmp    80043d <fd_lookup+0x54>
  800438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043d:	5d                   	pop    %ebp
  80043e:	c3                   	ret    

0080043f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800448:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044d:	eb 13                	jmp    800462 <dev_lookup+0x23>
  80044f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800452:	39 08                	cmp    %ecx,(%eax)
  800454:	75 0c                	jne    800462 <dev_lookup+0x23>
			*dev = devtab[i];
  800456:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800459:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045b:	b8 00 00 00 00       	mov    $0x0,%eax
  800460:	eb 2e                	jmp    800490 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800462:	8b 02                	mov    (%edx),%eax
  800464:	85 c0                	test   %eax,%eax
  800466:	75 e7                	jne    80044f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800468:	a1 08 40 80 00       	mov    0x804008,%eax
  80046d:	8b 40 48             	mov    0x48(%eax),%eax
  800470:	83 ec 04             	sub    $0x4,%esp
  800473:	51                   	push   %ecx
  800474:	50                   	push   %eax
  800475:	68 98 22 80 00       	push   $0x802298
  80047a:	e8 2a 11 00 00       	call   8015a9 <cprintf>
	*dev = 0;
  80047f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800482:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800490:	c9                   	leave  
  800491:	c3                   	ret    

00800492 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800492:	55                   	push   %ebp
  800493:	89 e5                	mov    %esp,%ebp
  800495:	56                   	push   %esi
  800496:	53                   	push   %ebx
  800497:	83 ec 10             	sub    $0x10,%esp
  80049a:	8b 75 08             	mov    0x8(%ebp),%esi
  80049d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a3:	50                   	push   %eax
  8004a4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004aa:	c1 e8 0c             	shr    $0xc,%eax
  8004ad:	50                   	push   %eax
  8004ae:	e8 36 ff ff ff       	call   8003e9 <fd_lookup>
  8004b3:	83 c4 08             	add    $0x8,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 05                	js     8004bf <fd_close+0x2d>
	    || fd != fd2)
  8004ba:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bd:	74 0c                	je     8004cb <fd_close+0x39>
		return (must_exist ? r : 0);
  8004bf:	84 db                	test   %bl,%bl
  8004c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c6:	0f 44 c2             	cmove  %edx,%eax
  8004c9:	eb 41                	jmp    80050c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d1:	50                   	push   %eax
  8004d2:	ff 36                	pushl  (%esi)
  8004d4:	e8 66 ff ff ff       	call   80043f <dev_lookup>
  8004d9:	89 c3                	mov    %eax,%ebx
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	78 1a                	js     8004fc <fd_close+0x6a>
		if (dev->dev_close)
  8004e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	74 0b                	je     8004fc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f1:	83 ec 0c             	sub    $0xc,%esp
  8004f4:	56                   	push   %esi
  8004f5:	ff d0                	call   *%eax
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	56                   	push   %esi
  800500:	6a 00                	push   $0x0
  800502:	e8 e1 fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	89 d8                	mov    %ebx,%eax
}
  80050c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050f:	5b                   	pop    %ebx
  800510:	5e                   	pop    %esi
  800511:	5d                   	pop    %ebp
  800512:	c3                   	ret    

00800513 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800519:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051c:	50                   	push   %eax
  80051d:	ff 75 08             	pushl  0x8(%ebp)
  800520:	e8 c4 fe ff ff       	call   8003e9 <fd_lookup>
  800525:	83 c4 08             	add    $0x8,%esp
  800528:	85 c0                	test   %eax,%eax
  80052a:	78 10                	js     80053c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	6a 01                	push   $0x1
  800531:	ff 75 f4             	pushl  -0xc(%ebp)
  800534:	e8 59 ff ff ff       	call   800492 <fd_close>
  800539:	83 c4 10             	add    $0x10,%esp
}
  80053c:	c9                   	leave  
  80053d:	c3                   	ret    

0080053e <close_all>:

void
close_all(void)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	53                   	push   %ebx
  800542:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800545:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80054a:	83 ec 0c             	sub    $0xc,%esp
  80054d:	53                   	push   %ebx
  80054e:	e8 c0 ff ff ff       	call   800513 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800553:	83 c3 01             	add    $0x1,%ebx
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	83 fb 20             	cmp    $0x20,%ebx
  80055c:	75 ec                	jne    80054a <close_all+0xc>
		close(i);
}
  80055e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800561:	c9                   	leave  
  800562:	c3                   	ret    

00800563 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
  800566:	57                   	push   %edi
  800567:	56                   	push   %esi
  800568:	53                   	push   %ebx
  800569:	83 ec 2c             	sub    $0x2c,%esp
  80056c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800572:	50                   	push   %eax
  800573:	ff 75 08             	pushl  0x8(%ebp)
  800576:	e8 6e fe ff ff       	call   8003e9 <fd_lookup>
  80057b:	83 c4 08             	add    $0x8,%esp
  80057e:	85 c0                	test   %eax,%eax
  800580:	0f 88 c1 00 00 00    	js     800647 <dup+0xe4>
		return r;
	close(newfdnum);
  800586:	83 ec 0c             	sub    $0xc,%esp
  800589:	56                   	push   %esi
  80058a:	e8 84 ff ff ff       	call   800513 <close>

	newfd = INDEX2FD(newfdnum);
  80058f:	89 f3                	mov    %esi,%ebx
  800591:	c1 e3 0c             	shl    $0xc,%ebx
  800594:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80059a:	83 c4 04             	add    $0x4,%esp
  80059d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a0:	e8 de fd ff ff       	call   800383 <fd2data>
  8005a5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a7:	89 1c 24             	mov    %ebx,(%esp)
  8005aa:	e8 d4 fd ff ff       	call   800383 <fd2data>
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b5:	89 f8                	mov    %edi,%eax
  8005b7:	c1 e8 16             	shr    $0x16,%eax
  8005ba:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c1:	a8 01                	test   $0x1,%al
  8005c3:	74 37                	je     8005fc <dup+0x99>
  8005c5:	89 f8                	mov    %edi,%eax
  8005c7:	c1 e8 0c             	shr    $0xc,%eax
  8005ca:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d1:	f6 c2 01             	test   $0x1,%dl
  8005d4:	74 26                	je     8005fc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dd:	83 ec 0c             	sub    $0xc,%esp
  8005e0:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e5:	50                   	push   %eax
  8005e6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e9:	6a 00                	push   $0x0
  8005eb:	57                   	push   %edi
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 b3 fb ff ff       	call   8001a6 <sys_page_map>
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	83 c4 20             	add    $0x20,%esp
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	78 2e                	js     80062a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ff:	89 d0                	mov    %edx,%eax
  800601:	c1 e8 0c             	shr    $0xc,%eax
  800604:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	25 07 0e 00 00       	and    $0xe07,%eax
  800613:	50                   	push   %eax
  800614:	53                   	push   %ebx
  800615:	6a 00                	push   $0x0
  800617:	52                   	push   %edx
  800618:	6a 00                	push   $0x0
  80061a:	e8 87 fb ff ff       	call   8001a6 <sys_page_map>
  80061f:	89 c7                	mov    %eax,%edi
  800621:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800624:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800626:	85 ff                	test   %edi,%edi
  800628:	79 1d                	jns    800647 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 00                	push   $0x0
  800630:	e8 b3 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800635:	83 c4 08             	add    $0x8,%esp
  800638:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063b:	6a 00                	push   $0x0
  80063d:	e8 a6 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	89 f8                	mov    %edi,%eax
}
  800647:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064a:	5b                   	pop    %ebx
  80064b:	5e                   	pop    %esi
  80064c:	5f                   	pop    %edi
  80064d:	5d                   	pop    %ebp
  80064e:	c3                   	ret    

0080064f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064f:	55                   	push   %ebp
  800650:	89 e5                	mov    %esp,%ebp
  800652:	53                   	push   %ebx
  800653:	83 ec 14             	sub    $0x14,%esp
  800656:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800659:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065c:	50                   	push   %eax
  80065d:	53                   	push   %ebx
  80065e:	e8 86 fd ff ff       	call   8003e9 <fd_lookup>
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	89 c2                	mov    %eax,%edx
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 6d                	js     8006d9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800672:	50                   	push   %eax
  800673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800676:	ff 30                	pushl  (%eax)
  800678:	e8 c2 fd ff ff       	call   80043f <dev_lookup>
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	85 c0                	test   %eax,%eax
  800682:	78 4c                	js     8006d0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800684:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800687:	8b 42 08             	mov    0x8(%edx),%eax
  80068a:	83 e0 03             	and    $0x3,%eax
  80068d:	83 f8 01             	cmp    $0x1,%eax
  800690:	75 21                	jne    8006b3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800692:	a1 08 40 80 00       	mov    0x804008,%eax
  800697:	8b 40 48             	mov    0x48(%eax),%eax
  80069a:	83 ec 04             	sub    $0x4,%esp
  80069d:	53                   	push   %ebx
  80069e:	50                   	push   %eax
  80069f:	68 d9 22 80 00       	push   $0x8022d9
  8006a4:	e8 00 0f 00 00       	call   8015a9 <cprintf>
		return -E_INVAL;
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b1:	eb 26                	jmp    8006d9 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b6:	8b 40 08             	mov    0x8(%eax),%eax
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	74 17                	je     8006d4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bd:	83 ec 04             	sub    $0x4,%esp
  8006c0:	ff 75 10             	pushl  0x10(%ebp)
  8006c3:	ff 75 0c             	pushl  0xc(%ebp)
  8006c6:	52                   	push   %edx
  8006c7:	ff d0                	call   *%eax
  8006c9:	89 c2                	mov    %eax,%edx
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	eb 09                	jmp    8006d9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d0:	89 c2                	mov    %eax,%edx
  8006d2:	eb 05                	jmp    8006d9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d9:	89 d0                	mov    %edx,%eax
  8006db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	57                   	push   %edi
  8006e4:	56                   	push   %esi
  8006e5:	53                   	push   %ebx
  8006e6:	83 ec 0c             	sub    $0xc,%esp
  8006e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f4:	eb 21                	jmp    800717 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f6:	83 ec 04             	sub    $0x4,%esp
  8006f9:	89 f0                	mov    %esi,%eax
  8006fb:	29 d8                	sub    %ebx,%eax
  8006fd:	50                   	push   %eax
  8006fe:	89 d8                	mov    %ebx,%eax
  800700:	03 45 0c             	add    0xc(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	57                   	push   %edi
  800705:	e8 45 ff ff ff       	call   80064f <read>
		if (m < 0)
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	85 c0                	test   %eax,%eax
  80070f:	78 10                	js     800721 <readn+0x41>
			return m;
		if (m == 0)
  800711:	85 c0                	test   %eax,%eax
  800713:	74 0a                	je     80071f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800715:	01 c3                	add    %eax,%ebx
  800717:	39 f3                	cmp    %esi,%ebx
  800719:	72 db                	jb     8006f6 <readn+0x16>
  80071b:	89 d8                	mov    %ebx,%eax
  80071d:	eb 02                	jmp    800721 <readn+0x41>
  80071f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800721:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800724:	5b                   	pop    %ebx
  800725:	5e                   	pop    %esi
  800726:	5f                   	pop    %edi
  800727:	5d                   	pop    %ebp
  800728:	c3                   	ret    

00800729 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	53                   	push   %ebx
  80072d:	83 ec 14             	sub    $0x14,%esp
  800730:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800733:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800736:	50                   	push   %eax
  800737:	53                   	push   %ebx
  800738:	e8 ac fc ff ff       	call   8003e9 <fd_lookup>
  80073d:	83 c4 08             	add    $0x8,%esp
  800740:	89 c2                	mov    %eax,%edx
  800742:	85 c0                	test   %eax,%eax
  800744:	78 68                	js     8007ae <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800746:	83 ec 08             	sub    $0x8,%esp
  800749:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074c:	50                   	push   %eax
  80074d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800750:	ff 30                	pushl  (%eax)
  800752:	e8 e8 fc ff ff       	call   80043f <dev_lookup>
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	85 c0                	test   %eax,%eax
  80075c:	78 47                	js     8007a5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800761:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800765:	75 21                	jne    800788 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800767:	a1 08 40 80 00       	mov    0x804008,%eax
  80076c:	8b 40 48             	mov    0x48(%eax),%eax
  80076f:	83 ec 04             	sub    $0x4,%esp
  800772:	53                   	push   %ebx
  800773:	50                   	push   %eax
  800774:	68 f5 22 80 00       	push   $0x8022f5
  800779:	e8 2b 0e 00 00       	call   8015a9 <cprintf>
		return -E_INVAL;
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800786:	eb 26                	jmp    8007ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800788:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078b:	8b 52 0c             	mov    0xc(%edx),%edx
  80078e:	85 d2                	test   %edx,%edx
  800790:	74 17                	je     8007a9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800792:	83 ec 04             	sub    $0x4,%esp
  800795:	ff 75 10             	pushl  0x10(%ebp)
  800798:	ff 75 0c             	pushl  0xc(%ebp)
  80079b:	50                   	push   %eax
  80079c:	ff d2                	call   *%edx
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	eb 09                	jmp    8007ae <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a5:	89 c2                	mov    %eax,%edx
  8007a7:	eb 05                	jmp    8007ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ae:	89 d0                	mov    %edx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	ff 75 08             	pushl  0x8(%ebp)
  8007c2:	e8 22 fc ff ff       	call   8003e9 <fd_lookup>
  8007c7:	83 c4 08             	add    $0x8,%esp
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 0e                	js     8007dc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	53                   	push   %ebx
  8007e2:	83 ec 14             	sub    $0x14,%esp
  8007e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007eb:	50                   	push   %eax
  8007ec:	53                   	push   %ebx
  8007ed:	e8 f7 fb ff ff       	call   8003e9 <fd_lookup>
  8007f2:	83 c4 08             	add    $0x8,%esp
  8007f5:	89 c2                	mov    %eax,%edx
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 65                	js     800860 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800801:	50                   	push   %eax
  800802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800805:	ff 30                	pushl  (%eax)
  800807:	e8 33 fc ff ff       	call   80043f <dev_lookup>
  80080c:	83 c4 10             	add    $0x10,%esp
  80080f:	85 c0                	test   %eax,%eax
  800811:	78 44                	js     800857 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800813:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800816:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081a:	75 21                	jne    80083d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800821:	8b 40 48             	mov    0x48(%eax),%eax
  800824:	83 ec 04             	sub    $0x4,%esp
  800827:	53                   	push   %ebx
  800828:	50                   	push   %eax
  800829:	68 b8 22 80 00       	push   $0x8022b8
  80082e:	e8 76 0d 00 00       	call   8015a9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083b:	eb 23                	jmp    800860 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800840:	8b 52 18             	mov    0x18(%edx),%edx
  800843:	85 d2                	test   %edx,%edx
  800845:	74 14                	je     80085b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800847:	83 ec 08             	sub    $0x8,%esp
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	50                   	push   %eax
  80084e:	ff d2                	call   *%edx
  800850:	89 c2                	mov    %eax,%edx
  800852:	83 c4 10             	add    $0x10,%esp
  800855:	eb 09                	jmp    800860 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800857:	89 c2                	mov    %eax,%edx
  800859:	eb 05                	jmp    800860 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800860:	89 d0                	mov    %edx,%eax
  800862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	83 ec 14             	sub    $0x14,%esp
  80086e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800871:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	ff 75 08             	pushl  0x8(%ebp)
  800878:	e8 6c fb ff ff       	call   8003e9 <fd_lookup>
  80087d:	83 c4 08             	add    $0x8,%esp
  800880:	89 c2                	mov    %eax,%edx
  800882:	85 c0                	test   %eax,%eax
  800884:	78 58                	js     8008de <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088c:	50                   	push   %eax
  80088d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800890:	ff 30                	pushl  (%eax)
  800892:	e8 a8 fb ff ff       	call   80043f <dev_lookup>
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	85 c0                	test   %eax,%eax
  80089c:	78 37                	js     8008d5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a5:	74 32                	je     8008d9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008aa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b1:	00 00 00 
	stat->st_isdir = 0;
  8008b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008bb:	00 00 00 
	stat->st_dev = dev;
  8008be:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	53                   	push   %ebx
  8008c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8008cb:	ff 50 14             	call   *0x14(%eax)
  8008ce:	89 c2                	mov    %eax,%edx
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	eb 09                	jmp    8008de <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d5:	89 c2                	mov    %eax,%edx
  8008d7:	eb 05                	jmp    8008de <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008de:	89 d0                	mov    %edx,%eax
  8008e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	6a 00                	push   $0x0
  8008ef:	ff 75 08             	pushl  0x8(%ebp)
  8008f2:	e8 ef 01 00 00       	call   800ae6 <open>
  8008f7:	89 c3                	mov    %eax,%ebx
  8008f9:	83 c4 10             	add    $0x10,%esp
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	78 1b                	js     80091b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800900:	83 ec 08             	sub    $0x8,%esp
  800903:	ff 75 0c             	pushl  0xc(%ebp)
  800906:	50                   	push   %eax
  800907:	e8 5b ff ff ff       	call   800867 <fstat>
  80090c:	89 c6                	mov    %eax,%esi
	close(fd);
  80090e:	89 1c 24             	mov    %ebx,(%esp)
  800911:	e8 fd fb ff ff       	call   800513 <close>
	return r;
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	89 f0                	mov    %esi,%eax
}
  80091b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	89 c6                	mov    %eax,%esi
  800929:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800932:	75 12                	jne    800946 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800934:	83 ec 0c             	sub    $0xc,%esp
  800937:	6a 01                	push   $0x1
  800939:	e8 1c 16 00 00       	call   801f5a <ipc_find_env>
  80093e:	a3 00 40 80 00       	mov    %eax,0x804000
  800943:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800946:	6a 07                	push   $0x7
  800948:	68 00 50 80 00       	push   $0x805000
  80094d:	56                   	push   %esi
  80094e:	ff 35 00 40 80 00    	pushl  0x804000
  800954:	e8 b2 15 00 00       	call   801f0b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800959:	83 c4 0c             	add    $0xc,%esp
  80095c:	6a 00                	push   $0x0
  80095e:	53                   	push   %ebx
  80095f:	6a 00                	push   $0x0
  800961:	e8 2f 15 00 00       	call   801e95 <ipc_recv>
}
  800966:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 40 0c             	mov    0xc(%eax),%eax
  800979:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800981:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800986:	ba 00 00 00 00       	mov    $0x0,%edx
  80098b:	b8 02 00 00 00       	mov    $0x2,%eax
  800990:	e8 8d ff ff ff       	call   800922 <fsipc>
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b2:	e8 6b ff ff ff       	call   800922 <fsipc>
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	83 ec 04             	sub    $0x4,%esp
  8009c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d8:	e8 45 ff ff ff       	call   800922 <fsipc>
  8009dd:	85 c0                	test   %eax,%eax
  8009df:	78 2c                	js     800a0d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e1:	83 ec 08             	sub    $0x8,%esp
  8009e4:	68 00 50 80 00       	push   $0x805000
  8009e9:	53                   	push   %ebx
  8009ea:	e8 5f 11 00 00       	call   801b4e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ef:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009fa:	a1 84 50 80 00       	mov    0x805084,%eax
  8009ff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a05:	83 c4 10             	add    $0x10,%esp
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	83 ec 08             	sub    $0x8,%esp
  800a19:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a22:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a28:	a3 04 50 80 00       	mov    %eax,0x805004
  800a2d:	3d 08 50 80 00       	cmp    $0x805008,%eax
  800a32:	bb 08 50 80 00       	mov    $0x805008,%ebx
  800a37:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a3a:	53                   	push   %ebx
  800a3b:	ff 75 0c             	pushl  0xc(%ebp)
  800a3e:	68 08 50 80 00       	push   $0x805008
  800a43:	e8 98 12 00 00       	call   801ce0 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a48:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a52:	e8 cb fe ff ff       	call   800922 <fsipc>
  800a57:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  800a5a:	85 c0                	test   %eax,%eax
  800a5c:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  800a5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a72:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a77:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	b8 03 00 00 00       	mov    $0x3,%eax
  800a87:	e8 96 fe ff ff       	call   800922 <fsipc>
  800a8c:	89 c3                	mov    %eax,%ebx
  800a8e:	85 c0                	test   %eax,%eax
  800a90:	78 4b                	js     800add <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a92:	39 c6                	cmp    %eax,%esi
  800a94:	73 16                	jae    800aac <devfile_read+0x48>
  800a96:	68 28 23 80 00       	push   $0x802328
  800a9b:	68 2f 23 80 00       	push   $0x80232f
  800aa0:	6a 7c                	push   $0x7c
  800aa2:	68 44 23 80 00       	push   $0x802344
  800aa7:	e8 24 0a 00 00       	call   8014d0 <_panic>
	assert(r <= PGSIZE);
  800aac:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab1:	7e 16                	jle    800ac9 <devfile_read+0x65>
  800ab3:	68 4f 23 80 00       	push   $0x80234f
  800ab8:	68 2f 23 80 00       	push   $0x80232f
  800abd:	6a 7d                	push   $0x7d
  800abf:	68 44 23 80 00       	push   $0x802344
  800ac4:	e8 07 0a 00 00       	call   8014d0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ac9:	83 ec 04             	sub    $0x4,%esp
  800acc:	50                   	push   %eax
  800acd:	68 00 50 80 00       	push   $0x805000
  800ad2:	ff 75 0c             	pushl  0xc(%ebp)
  800ad5:	e8 06 12 00 00       	call   801ce0 <memmove>
	return r;
  800ada:	83 c4 10             	add    $0x10,%esp
}
  800add:	89 d8                	mov    %ebx,%eax
  800adf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	53                   	push   %ebx
  800aea:	83 ec 20             	sub    $0x20,%esp
  800aed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800af0:	53                   	push   %ebx
  800af1:	e8 1f 10 00 00       	call   801b15 <strlen>
  800af6:	83 c4 10             	add    $0x10,%esp
  800af9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800afe:	7f 67                	jg     800b67 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b00:	83 ec 0c             	sub    $0xc,%esp
  800b03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b06:	50                   	push   %eax
  800b07:	e8 8e f8 ff ff       	call   80039a <fd_alloc>
  800b0c:	83 c4 10             	add    $0x10,%esp
		return r;
  800b0f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b11:	85 c0                	test   %eax,%eax
  800b13:	78 57                	js     800b6c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b15:	83 ec 08             	sub    $0x8,%esp
  800b18:	53                   	push   %ebx
  800b19:	68 00 50 80 00       	push   $0x805000
  800b1e:	e8 2b 10 00 00       	call   801b4e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b26:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b33:	e8 ea fd ff ff       	call   800922 <fsipc>
  800b38:	89 c3                	mov    %eax,%ebx
  800b3a:	83 c4 10             	add    $0x10,%esp
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	79 14                	jns    800b55 <open+0x6f>
		fd_close(fd, 0);
  800b41:	83 ec 08             	sub    $0x8,%esp
  800b44:	6a 00                	push   $0x0
  800b46:	ff 75 f4             	pushl  -0xc(%ebp)
  800b49:	e8 44 f9 ff ff       	call   800492 <fd_close>
		return r;
  800b4e:	83 c4 10             	add    $0x10,%esp
  800b51:	89 da                	mov    %ebx,%edx
  800b53:	eb 17                	jmp    800b6c <open+0x86>
	}

	return fd2num(fd);
  800b55:	83 ec 0c             	sub    $0xc,%esp
  800b58:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5b:	e8 13 f8 ff ff       	call   800373 <fd2num>
  800b60:	89 c2                	mov    %eax,%edx
  800b62:	83 c4 10             	add    $0x10,%esp
  800b65:	eb 05                	jmp    800b6c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b67:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b6c:	89 d0                	mov    %edx,%eax
  800b6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    

00800b73 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b79:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b83:	e8 9a fd ff ff       	call   800922 <fsipc>
}
  800b88:	c9                   	leave  
  800b89:	c3                   	ret    

00800b8a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b92:	83 ec 0c             	sub    $0xc,%esp
  800b95:	ff 75 08             	pushl  0x8(%ebp)
  800b98:	e8 e6 f7 ff ff       	call   800383 <fd2data>
  800b9d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b9f:	83 c4 08             	add    $0x8,%esp
  800ba2:	68 5b 23 80 00       	push   $0x80235b
  800ba7:	53                   	push   %ebx
  800ba8:	e8 a1 0f 00 00       	call   801b4e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bad:	8b 46 04             	mov    0x4(%esi),%eax
  800bb0:	2b 06                	sub    (%esi),%eax
  800bb2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bbf:	00 00 00 
	stat->st_dev = &devpipe;
  800bc2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc9:	30 80 00 
	return 0;
}
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be2:	53                   	push   %ebx
  800be3:	6a 00                	push   $0x0
  800be5:	e8 fe f5 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bea:	89 1c 24             	mov    %ebx,(%esp)
  800bed:	e8 91 f7 ff ff       	call   800383 <fd2data>
  800bf2:	83 c4 08             	add    $0x8,%esp
  800bf5:	50                   	push   %eax
  800bf6:	6a 00                	push   $0x0
  800bf8:	e8 eb f5 ff ff       	call   8001e8 <sys_page_unmap>
}
  800bfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 1c             	sub    $0x1c,%esp
  800c0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c0e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c10:	a1 08 40 80 00       	mov    0x804008,%eax
  800c15:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	ff 75 e0             	pushl  -0x20(%ebp)
  800c1e:	e8 70 13 00 00       	call   801f93 <pageref>
  800c23:	89 c3                	mov    %eax,%ebx
  800c25:	89 3c 24             	mov    %edi,(%esp)
  800c28:	e8 66 13 00 00       	call   801f93 <pageref>
  800c2d:	83 c4 10             	add    $0x10,%esp
  800c30:	39 c3                	cmp    %eax,%ebx
  800c32:	0f 94 c1             	sete   %cl
  800c35:	0f b6 c9             	movzbl %cl,%ecx
  800c38:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c3b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c41:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c44:	39 ce                	cmp    %ecx,%esi
  800c46:	74 1b                	je     800c63 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c48:	39 c3                	cmp    %eax,%ebx
  800c4a:	75 c4                	jne    800c10 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c4c:	8b 42 58             	mov    0x58(%edx),%eax
  800c4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c52:	50                   	push   %eax
  800c53:	56                   	push   %esi
  800c54:	68 62 23 80 00       	push   $0x802362
  800c59:	e8 4b 09 00 00       	call   8015a9 <cprintf>
  800c5e:	83 c4 10             	add    $0x10,%esp
  800c61:	eb ad                	jmp    800c10 <_pipeisclosed+0xe>
	}
}
  800c63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 28             	sub    $0x28,%esp
  800c77:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c7a:	56                   	push   %esi
  800c7b:	e8 03 f7 ff ff       	call   800383 <fd2data>
  800c80:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8a:	eb 4b                	jmp    800cd7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c8c:	89 da                	mov    %ebx,%edx
  800c8e:	89 f0                	mov    %esi,%eax
  800c90:	e8 6d ff ff ff       	call   800c02 <_pipeisclosed>
  800c95:	85 c0                	test   %eax,%eax
  800c97:	75 48                	jne    800ce1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c99:	e8 a6 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c9e:	8b 43 04             	mov    0x4(%ebx),%eax
  800ca1:	8b 0b                	mov    (%ebx),%ecx
  800ca3:	8d 51 20             	lea    0x20(%ecx),%edx
  800ca6:	39 d0                	cmp    %edx,%eax
  800ca8:	73 e2                	jae    800c8c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cb1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cb4:	89 c2                	mov    %eax,%edx
  800cb6:	c1 fa 1f             	sar    $0x1f,%edx
  800cb9:	89 d1                	mov    %edx,%ecx
  800cbb:	c1 e9 1b             	shr    $0x1b,%ecx
  800cbe:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cc1:	83 e2 1f             	and    $0x1f,%edx
  800cc4:	29 ca                	sub    %ecx,%edx
  800cc6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cce:	83 c0 01             	add    $0x1,%eax
  800cd1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd4:	83 c7 01             	add    $0x1,%edi
  800cd7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cda:	75 c2                	jne    800c9e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdf:	eb 05                	jmp    800ce6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 18             	sub    $0x18,%esp
  800cf7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cfa:	57                   	push   %edi
  800cfb:	e8 83 f6 ff ff       	call   800383 <fd2data>
  800d00:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d02:	83 c4 10             	add    $0x10,%esp
  800d05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0a:	eb 3d                	jmp    800d49 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d0c:	85 db                	test   %ebx,%ebx
  800d0e:	74 04                	je     800d14 <devpipe_read+0x26>
				return i;
  800d10:	89 d8                	mov    %ebx,%eax
  800d12:	eb 44                	jmp    800d58 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d14:	89 f2                	mov    %esi,%edx
  800d16:	89 f8                	mov    %edi,%eax
  800d18:	e8 e5 fe ff ff       	call   800c02 <_pipeisclosed>
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	75 32                	jne    800d53 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d21:	e8 1e f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d26:	8b 06                	mov    (%esi),%eax
  800d28:	3b 46 04             	cmp    0x4(%esi),%eax
  800d2b:	74 df                	je     800d0c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d2d:	99                   	cltd   
  800d2e:	c1 ea 1b             	shr    $0x1b,%edx
  800d31:	01 d0                	add    %edx,%eax
  800d33:	83 e0 1f             	and    $0x1f,%eax
  800d36:	29 d0                	sub    %edx,%eax
  800d38:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d43:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d46:	83 c3 01             	add    $0x1,%ebx
  800d49:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d4c:	75 d8                	jne    800d26 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d51:	eb 05                	jmp    800d58 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d53:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d6b:	50                   	push   %eax
  800d6c:	e8 29 f6 ff ff       	call   80039a <fd_alloc>
  800d71:	83 c4 10             	add    $0x10,%esp
  800d74:	89 c2                	mov    %eax,%edx
  800d76:	85 c0                	test   %eax,%eax
  800d78:	0f 88 2c 01 00 00    	js     800eaa <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	68 07 04 00 00       	push   $0x407
  800d86:	ff 75 f4             	pushl  -0xc(%ebp)
  800d89:	6a 00                	push   $0x0
  800d8b:	e8 d3 f3 ff ff       	call   800163 <sys_page_alloc>
  800d90:	83 c4 10             	add    $0x10,%esp
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	85 c0                	test   %eax,%eax
  800d97:	0f 88 0d 01 00 00    	js     800eaa <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d9d:	83 ec 0c             	sub    $0xc,%esp
  800da0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da3:	50                   	push   %eax
  800da4:	e8 f1 f5 ff ff       	call   80039a <fd_alloc>
  800da9:	89 c3                	mov    %eax,%ebx
  800dab:	83 c4 10             	add    $0x10,%esp
  800dae:	85 c0                	test   %eax,%eax
  800db0:	0f 88 e2 00 00 00    	js     800e98 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	68 07 04 00 00       	push   $0x407
  800dbe:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc1:	6a 00                	push   $0x0
  800dc3:	e8 9b f3 ff ff       	call   800163 <sys_page_alloc>
  800dc8:	89 c3                	mov    %eax,%ebx
  800dca:	83 c4 10             	add    $0x10,%esp
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	0f 88 c3 00 00 00    	js     800e98 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ddb:	e8 a3 f5 ff ff       	call   800383 <fd2data>
  800de0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de2:	83 c4 0c             	add    $0xc,%esp
  800de5:	68 07 04 00 00       	push   $0x407
  800dea:	50                   	push   %eax
  800deb:	6a 00                	push   $0x0
  800ded:	e8 71 f3 ff ff       	call   800163 <sys_page_alloc>
  800df2:	89 c3                	mov    %eax,%ebx
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	85 c0                	test   %eax,%eax
  800df9:	0f 88 89 00 00 00    	js     800e88 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	ff 75 f0             	pushl  -0x10(%ebp)
  800e05:	e8 79 f5 ff ff       	call   800383 <fd2data>
  800e0a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e11:	50                   	push   %eax
  800e12:	6a 00                	push   $0x0
  800e14:	56                   	push   %esi
  800e15:	6a 00                	push   $0x0
  800e17:	e8 8a f3 ff ff       	call   8001a6 <sys_page_map>
  800e1c:	89 c3                	mov    %eax,%ebx
  800e1e:	83 c4 20             	add    $0x20,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	78 55                	js     800e7a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e25:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e33:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e3a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e43:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e48:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e4f:	83 ec 0c             	sub    $0xc,%esp
  800e52:	ff 75 f4             	pushl  -0xc(%ebp)
  800e55:	e8 19 f5 ff ff       	call   800373 <fd2num>
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e5f:	83 c4 04             	add    $0x4,%esp
  800e62:	ff 75 f0             	pushl  -0x10(%ebp)
  800e65:	e8 09 f5 ff ff       	call   800373 <fd2num>
  800e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e70:	83 c4 10             	add    $0x10,%esp
  800e73:	ba 00 00 00 00       	mov    $0x0,%edx
  800e78:	eb 30                	jmp    800eaa <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e7a:	83 ec 08             	sub    $0x8,%esp
  800e7d:	56                   	push   %esi
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 63 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e85:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e8e:	6a 00                	push   $0x0
  800e90:	e8 53 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e95:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9e:	6a 00                	push   $0x0
  800ea0:	e8 43 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eaa:	89 d0                	mov    %edx,%eax
  800eac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebc:	50                   	push   %eax
  800ebd:	ff 75 08             	pushl  0x8(%ebp)
  800ec0:	e8 24 f5 ff ff       	call   8003e9 <fd_lookup>
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	78 18                	js     800ee4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ecc:	83 ec 0c             	sub    $0xc,%esp
  800ecf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed2:	e8 ac f4 ff ff       	call   800383 <fd2data>
	return _pipeisclosed(fd, p);
  800ed7:	89 c2                	mov    %eax,%edx
  800ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800edc:	e8 21 fd ff ff       	call   800c02 <_pipeisclosed>
  800ee1:	83 c4 10             	add    $0x10,%esp
}
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800eec:	68 7a 23 80 00       	push   $0x80237a
  800ef1:	ff 75 0c             	pushl  0xc(%ebp)
  800ef4:	e8 55 0c 00 00       	call   801b4e <strcpy>
	return 0;
}
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	c9                   	leave  
  800eff:	c3                   	ret    

00800f00 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	53                   	push   %ebx
  800f04:	83 ec 10             	sub    $0x10,%esp
  800f07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800f0a:	53                   	push   %ebx
  800f0b:	e8 83 10 00 00       	call   801f93 <pageref>
  800f10:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800f13:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800f18:	83 f8 01             	cmp    $0x1,%eax
  800f1b:	75 10                	jne    800f2d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800f1d:	83 ec 0c             	sub    $0xc,%esp
  800f20:	ff 73 0c             	pushl  0xc(%ebx)
  800f23:	e8 c0 02 00 00       	call   8011e8 <nsipc_close>
  800f28:	89 c2                	mov    %eax,%edx
  800f2a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800f2d:	89 d0                	mov    %edx,%eax
  800f2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800f3a:	6a 00                	push   $0x0
  800f3c:	ff 75 10             	pushl  0x10(%ebp)
  800f3f:	ff 75 0c             	pushl  0xc(%ebp)
  800f42:	8b 45 08             	mov    0x8(%ebp),%eax
  800f45:	ff 70 0c             	pushl  0xc(%eax)
  800f48:	e8 78 03 00 00       	call   8012c5 <nsipc_send>
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f55:	6a 00                	push   $0x0
  800f57:	ff 75 10             	pushl  0x10(%ebp)
  800f5a:	ff 75 0c             	pushl  0xc(%ebp)
  800f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f60:	ff 70 0c             	pushl  0xc(%eax)
  800f63:	e8 f1 02 00 00       	call   801259 <nsipc_recv>
}
  800f68:	c9                   	leave  
  800f69:	c3                   	ret    

00800f6a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f70:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f73:	52                   	push   %edx
  800f74:	50                   	push   %eax
  800f75:	e8 6f f4 ff ff       	call   8003e9 <fd_lookup>
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	78 17                	js     800f98 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f84:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  800f8a:	39 08                	cmp    %ecx,(%eax)
  800f8c:	75 05                	jne    800f93 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f8e:	8b 40 0c             	mov    0xc(%eax),%eax
  800f91:	eb 05                	jmp    800f98 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800f93:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 1c             	sub    $0x1c,%esp
  800fa2:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800fa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa7:	50                   	push   %eax
  800fa8:	e8 ed f3 ff ff       	call   80039a <fd_alloc>
  800fad:	89 c3                	mov    %eax,%ebx
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	78 1b                	js     800fd1 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800fb6:	83 ec 04             	sub    $0x4,%esp
  800fb9:	68 07 04 00 00       	push   $0x407
  800fbe:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc1:	6a 00                	push   $0x0
  800fc3:	e8 9b f1 ff ff       	call   800163 <sys_page_alloc>
  800fc8:	89 c3                	mov    %eax,%ebx
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	79 10                	jns    800fe1 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	56                   	push   %esi
  800fd5:	e8 0e 02 00 00       	call   8011e8 <nsipc_close>
		return r;
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	89 d8                	mov    %ebx,%eax
  800fdf:	eb 24                	jmp    801005 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800fe1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fea:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ff6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	50                   	push   %eax
  800ffd:	e8 71 f3 ff ff       	call   800373 <fd2num>
  801002:	83 c4 10             	add    $0x10,%esp
}
  801005:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801012:	8b 45 08             	mov    0x8(%ebp),%eax
  801015:	e8 50 ff ff ff       	call   800f6a <fd2sockid>
		return r;
  80101a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 1f                	js     80103f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801020:	83 ec 04             	sub    $0x4,%esp
  801023:	ff 75 10             	pushl  0x10(%ebp)
  801026:	ff 75 0c             	pushl  0xc(%ebp)
  801029:	50                   	push   %eax
  80102a:	e8 12 01 00 00       	call   801141 <nsipc_accept>
  80102f:	83 c4 10             	add    $0x10,%esp
		return r;
  801032:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801034:	85 c0                	test   %eax,%eax
  801036:	78 07                	js     80103f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801038:	e8 5d ff ff ff       	call   800f9a <alloc_sockfd>
  80103d:	89 c1                	mov    %eax,%ecx
}
  80103f:	89 c8                	mov    %ecx,%eax
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801049:	8b 45 08             	mov    0x8(%ebp),%eax
  80104c:	e8 19 ff ff ff       	call   800f6a <fd2sockid>
  801051:	85 c0                	test   %eax,%eax
  801053:	78 12                	js     801067 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801055:	83 ec 04             	sub    $0x4,%esp
  801058:	ff 75 10             	pushl  0x10(%ebp)
  80105b:	ff 75 0c             	pushl  0xc(%ebp)
  80105e:	50                   	push   %eax
  80105f:	e8 2d 01 00 00       	call   801191 <nsipc_bind>
  801064:	83 c4 10             	add    $0x10,%esp
}
  801067:	c9                   	leave  
  801068:	c3                   	ret    

00801069 <shutdown>:

int
shutdown(int s, int how)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
  801072:	e8 f3 fe ff ff       	call   800f6a <fd2sockid>
  801077:	85 c0                	test   %eax,%eax
  801079:	78 0f                	js     80108a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80107b:	83 ec 08             	sub    $0x8,%esp
  80107e:	ff 75 0c             	pushl  0xc(%ebp)
  801081:	50                   	push   %eax
  801082:	e8 3f 01 00 00       	call   8011c6 <nsipc_shutdown>
  801087:	83 c4 10             	add    $0x10,%esp
}
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	e8 d0 fe ff ff       	call   800f6a <fd2sockid>
  80109a:	85 c0                	test   %eax,%eax
  80109c:	78 12                	js     8010b0 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80109e:	83 ec 04             	sub    $0x4,%esp
  8010a1:	ff 75 10             	pushl  0x10(%ebp)
  8010a4:	ff 75 0c             	pushl  0xc(%ebp)
  8010a7:	50                   	push   %eax
  8010a8:	e8 55 01 00 00       	call   801202 <nsipc_connect>
  8010ad:	83 c4 10             	add    $0x10,%esp
}
  8010b0:	c9                   	leave  
  8010b1:	c3                   	ret    

008010b2 <listen>:

int
listen(int s, int backlog)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bb:	e8 aa fe ff ff       	call   800f6a <fd2sockid>
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	78 0f                	js     8010d3 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8010c4:	83 ec 08             	sub    $0x8,%esp
  8010c7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ca:	50                   	push   %eax
  8010cb:	e8 67 01 00 00       	call   801237 <nsipc_listen>
  8010d0:	83 c4 10             	add    $0x10,%esp
}
  8010d3:	c9                   	leave  
  8010d4:	c3                   	ret    

008010d5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8010db:	ff 75 10             	pushl  0x10(%ebp)
  8010de:	ff 75 0c             	pushl  0xc(%ebp)
  8010e1:	ff 75 08             	pushl  0x8(%ebp)
  8010e4:	e8 3a 02 00 00       	call   801323 <nsipc_socket>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 05                	js     8010f5 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8010f0:	e8 a5 fe ff ff       	call   800f9a <alloc_sockfd>
}
  8010f5:	c9                   	leave  
  8010f6:	c3                   	ret    

008010f7 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 04             	sub    $0x4,%esp
  8010fe:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801100:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801107:	75 12                	jne    80111b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801109:	83 ec 0c             	sub    $0xc,%esp
  80110c:	6a 02                	push   $0x2
  80110e:	e8 47 0e 00 00       	call   801f5a <ipc_find_env>
  801113:	a3 04 40 80 00       	mov    %eax,0x804004
  801118:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80111b:	6a 07                	push   $0x7
  80111d:	68 00 60 80 00       	push   $0x806000
  801122:	53                   	push   %ebx
  801123:	ff 35 04 40 80 00    	pushl  0x804004
  801129:	e8 dd 0d 00 00       	call   801f0b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80112e:	83 c4 0c             	add    $0xc,%esp
  801131:	6a 00                	push   $0x0
  801133:	6a 00                	push   $0x0
  801135:	6a 00                	push   $0x0
  801137:	e8 59 0d 00 00       	call   801e95 <ipc_recv>
}
  80113c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113f:	c9                   	leave  
  801140:	c3                   	ret    

00801141 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801149:	8b 45 08             	mov    0x8(%ebp),%eax
  80114c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801151:	8b 06                	mov    (%esi),%eax
  801153:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801158:	b8 01 00 00 00       	mov    $0x1,%eax
  80115d:	e8 95 ff ff ff       	call   8010f7 <nsipc>
  801162:	89 c3                	mov    %eax,%ebx
  801164:	85 c0                	test   %eax,%eax
  801166:	78 20                	js     801188 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	ff 35 10 60 80 00    	pushl  0x806010
  801171:	68 00 60 80 00       	push   $0x806000
  801176:	ff 75 0c             	pushl  0xc(%ebp)
  801179:	e8 62 0b 00 00       	call   801ce0 <memmove>
		*addrlen = ret->ret_addrlen;
  80117e:	a1 10 60 80 00       	mov    0x806010,%eax
  801183:	89 06                	mov    %eax,(%esi)
  801185:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801188:	89 d8                	mov    %ebx,%eax
  80118a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	53                   	push   %ebx
  801195:	83 ec 08             	sub    $0x8,%esp
  801198:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80119b:	8b 45 08             	mov    0x8(%ebp),%eax
  80119e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8011a3:	53                   	push   %ebx
  8011a4:	ff 75 0c             	pushl  0xc(%ebp)
  8011a7:	68 04 60 80 00       	push   $0x806004
  8011ac:	e8 2f 0b 00 00       	call   801ce0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8011b1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8011b7:	b8 02 00 00 00       	mov    $0x2,%eax
  8011bc:	e8 36 ff ff ff       	call   8010f7 <nsipc>
}
  8011c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c4:	c9                   	leave  
  8011c5:	c3                   	ret    

008011c6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8011d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8011dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8011e1:	e8 11 ff ff ff       	call   8010f7 <nsipc>
}
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <nsipc_close>:

int
nsipc_close(int s)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8011ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f1:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8011f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8011fb:	e8 f7 fe ff ff       	call   8010f7 <nsipc>
}
  801200:	c9                   	leave  
  801201:	c3                   	ret    

00801202 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	53                   	push   %ebx
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80120c:	8b 45 08             	mov    0x8(%ebp),%eax
  80120f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801214:	53                   	push   %ebx
  801215:	ff 75 0c             	pushl  0xc(%ebp)
  801218:	68 04 60 80 00       	push   $0x806004
  80121d:	e8 be 0a 00 00       	call   801ce0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801222:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801228:	b8 05 00 00 00       	mov    $0x5,%eax
  80122d:	e8 c5 fe ff ff       	call   8010f7 <nsipc>
}
  801232:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801235:	c9                   	leave  
  801236:	c3                   	ret    

00801237 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80123d:	8b 45 08             	mov    0x8(%ebp),%eax
  801240:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801245:	8b 45 0c             	mov    0xc(%ebp),%eax
  801248:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80124d:	b8 06 00 00 00       	mov    $0x6,%eax
  801252:	e8 a0 fe ff ff       	call   8010f7 <nsipc>
}
  801257:	c9                   	leave  
  801258:	c3                   	ret    

00801259 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	56                   	push   %esi
  80125d:	53                   	push   %ebx
  80125e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801261:	8b 45 08             	mov    0x8(%ebp),%eax
  801264:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801269:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80126f:	8b 45 14             	mov    0x14(%ebp),%eax
  801272:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801277:	b8 07 00 00 00       	mov    $0x7,%eax
  80127c:	e8 76 fe ff ff       	call   8010f7 <nsipc>
  801281:	89 c3                	mov    %eax,%ebx
  801283:	85 c0                	test   %eax,%eax
  801285:	78 35                	js     8012bc <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801287:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80128c:	7f 04                	jg     801292 <nsipc_recv+0x39>
  80128e:	39 c6                	cmp    %eax,%esi
  801290:	7d 16                	jge    8012a8 <nsipc_recv+0x4f>
  801292:	68 86 23 80 00       	push   $0x802386
  801297:	68 2f 23 80 00       	push   $0x80232f
  80129c:	6a 62                	push   $0x62
  80129e:	68 9b 23 80 00       	push   $0x80239b
  8012a3:	e8 28 02 00 00       	call   8014d0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8012a8:	83 ec 04             	sub    $0x4,%esp
  8012ab:	50                   	push   %eax
  8012ac:	68 00 60 80 00       	push   $0x806000
  8012b1:	ff 75 0c             	pushl  0xc(%ebp)
  8012b4:	e8 27 0a 00 00       	call   801ce0 <memmove>
  8012b9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8012bc:	89 d8                	mov    %ebx,%eax
  8012be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c1:	5b                   	pop    %ebx
  8012c2:	5e                   	pop    %esi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 04             	sub    $0x4,%esp
  8012cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8012cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d2:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8012d7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8012dd:	7e 16                	jle    8012f5 <nsipc_send+0x30>
  8012df:	68 a7 23 80 00       	push   $0x8023a7
  8012e4:	68 2f 23 80 00       	push   $0x80232f
  8012e9:	6a 6d                	push   $0x6d
  8012eb:	68 9b 23 80 00       	push   $0x80239b
  8012f0:	e8 db 01 00 00       	call   8014d0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8012f5:	83 ec 04             	sub    $0x4,%esp
  8012f8:	53                   	push   %ebx
  8012f9:	ff 75 0c             	pushl  0xc(%ebp)
  8012fc:	68 0c 60 80 00       	push   $0x80600c
  801301:	e8 da 09 00 00       	call   801ce0 <memmove>
	nsipcbuf.send.req_size = size;
  801306:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80130c:	8b 45 14             	mov    0x14(%ebp),%eax
  80130f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801314:	b8 08 00 00 00       	mov    $0x8,%eax
  801319:	e8 d9 fd ff ff       	call   8010f7 <nsipc>
}
  80131e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801321:	c9                   	leave  
  801322:	c3                   	ret    

00801323 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801329:	8b 45 08             	mov    0x8(%ebp),%eax
  80132c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801331:	8b 45 0c             	mov    0xc(%ebp),%eax
  801334:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801339:	8b 45 10             	mov    0x10(%ebp),%eax
  80133c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801341:	b8 09 00 00 00       	mov    $0x9,%eax
  801346:	e8 ac fd ff ff       	call   8010f7 <nsipc>
}
  80134b:	c9                   	leave  
  80134c:	c3                   	ret    

0080134d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801350:	b8 00 00 00 00       	mov    $0x0,%eax
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    

00801357 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80135d:	68 b3 23 80 00       	push   $0x8023b3
  801362:	ff 75 0c             	pushl  0xc(%ebp)
  801365:	e8 e4 07 00 00       	call   801b4e <strcpy>
	return 0;
}
  80136a:	b8 00 00 00 00       	mov    $0x0,%eax
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	57                   	push   %edi
  801375:	56                   	push   %esi
  801376:	53                   	push   %ebx
  801377:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80137d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801382:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801388:	eb 2d                	jmp    8013b7 <devcons_write+0x46>
		m = n - tot;
  80138a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80138d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80138f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801392:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801397:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80139a:	83 ec 04             	sub    $0x4,%esp
  80139d:	53                   	push   %ebx
  80139e:	03 45 0c             	add    0xc(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	57                   	push   %edi
  8013a3:	e8 38 09 00 00       	call   801ce0 <memmove>
		sys_cputs(buf, m);
  8013a8:	83 c4 08             	add    $0x8,%esp
  8013ab:	53                   	push   %ebx
  8013ac:	57                   	push   %edi
  8013ad:	e8 f5 ec ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b2:	01 de                	add    %ebx,%esi
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	89 f0                	mov    %esi,%eax
  8013b9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013bc:	72 cc                	jb     80138a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5f                   	pop    %edi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	83 ec 08             	sub    $0x8,%esp
  8013cc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013d5:	74 2a                	je     801401 <devcons_read+0x3b>
  8013d7:	eb 05                	jmp    8013de <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013d9:	e8 66 ed ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013de:	e8 e2 ec ff ff       	call   8000c5 <sys_cgetc>
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	74 f2                	je     8013d9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 16                	js     801401 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013eb:	83 f8 04             	cmp    $0x4,%eax
  8013ee:	74 0c                	je     8013fc <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f3:	88 02                	mov    %al,(%edx)
	return 1;
  8013f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8013fa:	eb 05                	jmp    801401 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801401:	c9                   	leave  
  801402:	c3                   	ret    

00801403 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
  80140c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80140f:	6a 01                	push   $0x1
  801411:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	e8 8d ec ff ff       	call   8000a7 <sys_cputs>
}
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <getchar>:

int
getchar(void)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801425:	6a 01                	push   $0x1
  801427:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142a:	50                   	push   %eax
  80142b:	6a 00                	push   $0x0
  80142d:	e8 1d f2 ff ff       	call   80064f <read>
	if (r < 0)
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 0f                	js     801448 <getchar+0x29>
		return r;
	if (r < 1)
  801439:	85 c0                	test   %eax,%eax
  80143b:	7e 06                	jle    801443 <getchar+0x24>
		return -E_EOF;
	return c;
  80143d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801441:	eb 05                	jmp    801448 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801443:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801450:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801453:	50                   	push   %eax
  801454:	ff 75 08             	pushl  0x8(%ebp)
  801457:	e8 8d ef ff ff       	call   8003e9 <fd_lookup>
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 11                	js     801474 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801466:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80146c:	39 10                	cmp    %edx,(%eax)
  80146e:	0f 94 c0             	sete   %al
  801471:	0f b6 c0             	movzbl %al,%eax
}
  801474:	c9                   	leave  
  801475:	c3                   	ret    

00801476 <opencons>:

int
opencons(void)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	e8 15 ef ff ff       	call   80039a <fd_alloc>
  801485:	83 c4 10             	add    $0x10,%esp
		return r;
  801488:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 3e                	js     8014cc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80148e:	83 ec 04             	sub    $0x4,%esp
  801491:	68 07 04 00 00       	push   $0x407
  801496:	ff 75 f4             	pushl  -0xc(%ebp)
  801499:	6a 00                	push   $0x0
  80149b:	e8 c3 ec ff ff       	call   800163 <sys_page_alloc>
  8014a0:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 23                	js     8014cc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014a9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014be:	83 ec 0c             	sub    $0xc,%esp
  8014c1:	50                   	push   %eax
  8014c2:	e8 ac ee ff ff       	call   800373 <fd2num>
  8014c7:	89 c2                	mov    %eax,%edx
  8014c9:	83 c4 10             	add    $0x10,%esp
}
  8014cc:	89 d0                	mov    %edx,%eax
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014d5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014d8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014de:	e8 42 ec ff ff       	call   800125 <sys_getenvid>
  8014e3:	83 ec 0c             	sub    $0xc,%esp
  8014e6:	ff 75 0c             	pushl  0xc(%ebp)
  8014e9:	ff 75 08             	pushl  0x8(%ebp)
  8014ec:	56                   	push   %esi
  8014ed:	50                   	push   %eax
  8014ee:	68 c0 23 80 00       	push   $0x8023c0
  8014f3:	e8 b1 00 00 00       	call   8015a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014f8:	83 c4 18             	add    $0x18,%esp
  8014fb:	53                   	push   %ebx
  8014fc:	ff 75 10             	pushl  0x10(%ebp)
  8014ff:	e8 54 00 00 00       	call   801558 <vcprintf>
	cprintf("\n");
  801504:	c7 04 24 73 23 80 00 	movl   $0x802373,(%esp)
  80150b:	e8 99 00 00 00       	call   8015a9 <cprintf>
  801510:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801513:	cc                   	int3   
  801514:	eb fd                	jmp    801513 <_panic+0x43>

00801516 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	53                   	push   %ebx
  80151a:	83 ec 04             	sub    $0x4,%esp
  80151d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801520:	8b 13                	mov    (%ebx),%edx
  801522:	8d 42 01             	lea    0x1(%edx),%eax
  801525:	89 03                	mov    %eax,(%ebx)
  801527:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80152a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80152e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801533:	75 1a                	jne    80154f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	68 ff 00 00 00       	push   $0xff
  80153d:	8d 43 08             	lea    0x8(%ebx),%eax
  801540:	50                   	push   %eax
  801541:	e8 61 eb ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  801546:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80154c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80154f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801553:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801561:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801568:	00 00 00 
	b.cnt = 0;
  80156b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801572:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801575:	ff 75 0c             	pushl  0xc(%ebp)
  801578:	ff 75 08             	pushl  0x8(%ebp)
  80157b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	68 16 15 80 00       	push   $0x801516
  801587:	e8 54 01 00 00       	call   8016e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80158c:	83 c4 08             	add    $0x8,%esp
  80158f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801595:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80159b:	50                   	push   %eax
  80159c:	e8 06 eb ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  8015a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015b2:	50                   	push   %eax
  8015b3:	ff 75 08             	pushl  0x8(%ebp)
  8015b6:	e8 9d ff ff ff       	call   801558 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	57                   	push   %edi
  8015c1:	56                   	push   %esi
  8015c2:	53                   	push   %ebx
  8015c3:	83 ec 1c             	sub    $0x1c,%esp
  8015c6:	89 c7                	mov    %eax,%edi
  8015c8:	89 d6                	mov    %edx,%esi
  8015ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015e1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015e4:	39 d3                	cmp    %edx,%ebx
  8015e6:	72 05                	jb     8015ed <printnum+0x30>
  8015e8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015eb:	77 45                	ja     801632 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	ff 75 18             	pushl  0x18(%ebp)
  8015f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015f9:	53                   	push   %ebx
  8015fa:	ff 75 10             	pushl  0x10(%ebp)
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	ff 75 e4             	pushl  -0x1c(%ebp)
  801603:	ff 75 e0             	pushl  -0x20(%ebp)
  801606:	ff 75 dc             	pushl  -0x24(%ebp)
  801609:	ff 75 d8             	pushl  -0x28(%ebp)
  80160c:	e8 bf 09 00 00       	call   801fd0 <__udivdi3>
  801611:	83 c4 18             	add    $0x18,%esp
  801614:	52                   	push   %edx
  801615:	50                   	push   %eax
  801616:	89 f2                	mov    %esi,%edx
  801618:	89 f8                	mov    %edi,%eax
  80161a:	e8 9e ff ff ff       	call   8015bd <printnum>
  80161f:	83 c4 20             	add    $0x20,%esp
  801622:	eb 18                	jmp    80163c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	56                   	push   %esi
  801628:	ff 75 18             	pushl  0x18(%ebp)
  80162b:	ff d7                	call   *%edi
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	eb 03                	jmp    801635 <printnum+0x78>
  801632:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801635:	83 eb 01             	sub    $0x1,%ebx
  801638:	85 db                	test   %ebx,%ebx
  80163a:	7f e8                	jg     801624 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	56                   	push   %esi
  801640:	83 ec 04             	sub    $0x4,%esp
  801643:	ff 75 e4             	pushl  -0x1c(%ebp)
  801646:	ff 75 e0             	pushl  -0x20(%ebp)
  801649:	ff 75 dc             	pushl  -0x24(%ebp)
  80164c:	ff 75 d8             	pushl  -0x28(%ebp)
  80164f:	e8 ac 0a 00 00       	call   802100 <__umoddi3>
  801654:	83 c4 14             	add    $0x14,%esp
  801657:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  80165e:	50                   	push   %eax
  80165f:	ff d7                	call   *%edi
}
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	5f                   	pop    %edi
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80166f:	83 fa 01             	cmp    $0x1,%edx
  801672:	7e 0e                	jle    801682 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801674:	8b 10                	mov    (%eax),%edx
  801676:	8d 4a 08             	lea    0x8(%edx),%ecx
  801679:	89 08                	mov    %ecx,(%eax)
  80167b:	8b 02                	mov    (%edx),%eax
  80167d:	8b 52 04             	mov    0x4(%edx),%edx
  801680:	eb 22                	jmp    8016a4 <getuint+0x38>
	else if (lflag)
  801682:	85 d2                	test   %edx,%edx
  801684:	74 10                	je     801696 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801686:	8b 10                	mov    (%eax),%edx
  801688:	8d 4a 04             	lea    0x4(%edx),%ecx
  80168b:	89 08                	mov    %ecx,(%eax)
  80168d:	8b 02                	mov    (%edx),%eax
  80168f:	ba 00 00 00 00       	mov    $0x0,%edx
  801694:	eb 0e                	jmp    8016a4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801696:	8b 10                	mov    (%eax),%edx
  801698:	8d 4a 04             	lea    0x4(%edx),%ecx
  80169b:	89 08                	mov    %ecx,(%eax)
  80169d:	8b 02                	mov    (%edx),%eax
  80169f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016a4:	5d                   	pop    %ebp
  8016a5:	c3                   	ret    

008016a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016ac:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016b0:	8b 10                	mov    (%eax),%edx
  8016b2:	3b 50 04             	cmp    0x4(%eax),%edx
  8016b5:	73 0a                	jae    8016c1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016ba:	89 08                	mov    %ecx,(%eax)
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	88 02                	mov    %al,(%edx)
}
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016c9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016cc:	50                   	push   %eax
  8016cd:	ff 75 10             	pushl  0x10(%ebp)
  8016d0:	ff 75 0c             	pushl  0xc(%ebp)
  8016d3:	ff 75 08             	pushl  0x8(%ebp)
  8016d6:	e8 05 00 00 00       	call   8016e0 <vprintfmt>
	va_end(ap);
}
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	57                   	push   %edi
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
  8016e6:	83 ec 2c             	sub    $0x2c,%esp
  8016e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016ef:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016f2:	eb 12                	jmp    801706 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	0f 84 a9 03 00 00    	je     801aa5 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8016fc:	83 ec 08             	sub    $0x8,%esp
  8016ff:	53                   	push   %ebx
  801700:	50                   	push   %eax
  801701:	ff d6                	call   *%esi
  801703:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801706:	83 c7 01             	add    $0x1,%edi
  801709:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80170d:	83 f8 25             	cmp    $0x25,%eax
  801710:	75 e2                	jne    8016f4 <vprintfmt+0x14>
  801712:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801716:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80171d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801724:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80172b:	ba 00 00 00 00       	mov    $0x0,%edx
  801730:	eb 07                	jmp    801739 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801732:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801735:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801739:	8d 47 01             	lea    0x1(%edi),%eax
  80173c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80173f:	0f b6 07             	movzbl (%edi),%eax
  801742:	0f b6 c8             	movzbl %al,%ecx
  801745:	83 e8 23             	sub    $0x23,%eax
  801748:	3c 55                	cmp    $0x55,%al
  80174a:	0f 87 3a 03 00 00    	ja     801a8a <vprintfmt+0x3aa>
  801750:	0f b6 c0             	movzbl %al,%eax
  801753:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80175a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80175d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801761:	eb d6                	jmp    801739 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801763:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801766:	b8 00 00 00 00       	mov    $0x0,%eax
  80176b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80176e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801771:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801775:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801778:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80177b:	83 fa 09             	cmp    $0x9,%edx
  80177e:	77 39                	ja     8017b9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801780:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801783:	eb e9                	jmp    80176e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801785:	8b 45 14             	mov    0x14(%ebp),%eax
  801788:	8d 48 04             	lea    0x4(%eax),%ecx
  80178b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80178e:	8b 00                	mov    (%eax),%eax
  801790:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801793:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801796:	eb 27                	jmp    8017bf <vprintfmt+0xdf>
  801798:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80179b:	85 c0                	test   %eax,%eax
  80179d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017a2:	0f 49 c8             	cmovns %eax,%ecx
  8017a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ab:	eb 8c                	jmp    801739 <vprintfmt+0x59>
  8017ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017b0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017b7:	eb 80                	jmp    801739 <vprintfmt+0x59>
  8017b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017bc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017c3:	0f 89 70 ff ff ff    	jns    801739 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017d6:	e9 5e ff ff ff       	jmp    801739 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017db:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017e1:	e9 53 ff ff ff       	jmp    801739 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e9:	8d 50 04             	lea    0x4(%eax),%edx
  8017ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8017ef:	83 ec 08             	sub    $0x8,%esp
  8017f2:	53                   	push   %ebx
  8017f3:	ff 30                	pushl  (%eax)
  8017f5:	ff d6                	call   *%esi
			break;
  8017f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017fd:	e9 04 ff ff ff       	jmp    801706 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801802:	8b 45 14             	mov    0x14(%ebp),%eax
  801805:	8d 50 04             	lea    0x4(%eax),%edx
  801808:	89 55 14             	mov    %edx,0x14(%ebp)
  80180b:	8b 00                	mov    (%eax),%eax
  80180d:	99                   	cltd   
  80180e:	31 d0                	xor    %edx,%eax
  801810:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801812:	83 f8 0f             	cmp    $0xf,%eax
  801815:	7f 0b                	jg     801822 <vprintfmt+0x142>
  801817:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80181e:	85 d2                	test   %edx,%edx
  801820:	75 18                	jne    80183a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801822:	50                   	push   %eax
  801823:	68 fb 23 80 00       	push   $0x8023fb
  801828:	53                   	push   %ebx
  801829:	56                   	push   %esi
  80182a:	e8 94 fe ff ff       	call   8016c3 <printfmt>
  80182f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801832:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801835:	e9 cc fe ff ff       	jmp    801706 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80183a:	52                   	push   %edx
  80183b:	68 41 23 80 00       	push   $0x802341
  801840:	53                   	push   %ebx
  801841:	56                   	push   %esi
  801842:	e8 7c fe ff ff       	call   8016c3 <printfmt>
  801847:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80184d:	e9 b4 fe ff ff       	jmp    801706 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801852:	8b 45 14             	mov    0x14(%ebp),%eax
  801855:	8d 50 04             	lea    0x4(%eax),%edx
  801858:	89 55 14             	mov    %edx,0x14(%ebp)
  80185b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80185d:	85 ff                	test   %edi,%edi
  80185f:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  801864:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801867:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80186b:	0f 8e 94 00 00 00    	jle    801905 <vprintfmt+0x225>
  801871:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801875:	0f 84 98 00 00 00    	je     801913 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	ff 75 d0             	pushl  -0x30(%ebp)
  801881:	57                   	push   %edi
  801882:	e8 a6 02 00 00       	call   801b2d <strnlen>
  801887:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80188a:	29 c1                	sub    %eax,%ecx
  80188c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80188f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801892:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801896:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801899:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80189c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80189e:	eb 0f                	jmp    8018af <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018a0:	83 ec 08             	sub    $0x8,%esp
  8018a3:	53                   	push   %ebx
  8018a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8018a7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a9:	83 ef 01             	sub    $0x1,%edi
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 ff                	test   %edi,%edi
  8018b1:	7f ed                	jg     8018a0 <vprintfmt+0x1c0>
  8018b3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018b6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018b9:	85 c9                	test   %ecx,%ecx
  8018bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c0:	0f 49 c1             	cmovns %ecx,%eax
  8018c3:	29 c1                	sub    %eax,%ecx
  8018c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8018c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018ce:	89 cb                	mov    %ecx,%ebx
  8018d0:	eb 4d                	jmp    80191f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018d6:	74 1b                	je     8018f3 <vprintfmt+0x213>
  8018d8:	0f be c0             	movsbl %al,%eax
  8018db:	83 e8 20             	sub    $0x20,%eax
  8018de:	83 f8 5e             	cmp    $0x5e,%eax
  8018e1:	76 10                	jbe    8018f3 <vprintfmt+0x213>
					putch('?', putdat);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	ff 75 0c             	pushl  0xc(%ebp)
  8018e9:	6a 3f                	push   $0x3f
  8018eb:	ff 55 08             	call   *0x8(%ebp)
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	eb 0d                	jmp    801900 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	ff 75 0c             	pushl  0xc(%ebp)
  8018f9:	52                   	push   %edx
  8018fa:	ff 55 08             	call   *0x8(%ebp)
  8018fd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801900:	83 eb 01             	sub    $0x1,%ebx
  801903:	eb 1a                	jmp    80191f <vprintfmt+0x23f>
  801905:	89 75 08             	mov    %esi,0x8(%ebp)
  801908:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80190b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80190e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801911:	eb 0c                	jmp    80191f <vprintfmt+0x23f>
  801913:	89 75 08             	mov    %esi,0x8(%ebp)
  801916:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801919:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80191c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80191f:	83 c7 01             	add    $0x1,%edi
  801922:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801926:	0f be d0             	movsbl %al,%edx
  801929:	85 d2                	test   %edx,%edx
  80192b:	74 23                	je     801950 <vprintfmt+0x270>
  80192d:	85 f6                	test   %esi,%esi
  80192f:	78 a1                	js     8018d2 <vprintfmt+0x1f2>
  801931:	83 ee 01             	sub    $0x1,%esi
  801934:	79 9c                	jns    8018d2 <vprintfmt+0x1f2>
  801936:	89 df                	mov    %ebx,%edi
  801938:	8b 75 08             	mov    0x8(%ebp),%esi
  80193b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80193e:	eb 18                	jmp    801958 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801940:	83 ec 08             	sub    $0x8,%esp
  801943:	53                   	push   %ebx
  801944:	6a 20                	push   $0x20
  801946:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801948:	83 ef 01             	sub    $0x1,%edi
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	eb 08                	jmp    801958 <vprintfmt+0x278>
  801950:	89 df                	mov    %ebx,%edi
  801952:	8b 75 08             	mov    0x8(%ebp),%esi
  801955:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801958:	85 ff                	test   %edi,%edi
  80195a:	7f e4                	jg     801940 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80195c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80195f:	e9 a2 fd ff ff       	jmp    801706 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801964:	83 fa 01             	cmp    $0x1,%edx
  801967:	7e 16                	jle    80197f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801969:	8b 45 14             	mov    0x14(%ebp),%eax
  80196c:	8d 50 08             	lea    0x8(%eax),%edx
  80196f:	89 55 14             	mov    %edx,0x14(%ebp)
  801972:	8b 50 04             	mov    0x4(%eax),%edx
  801975:	8b 00                	mov    (%eax),%eax
  801977:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80197a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80197d:	eb 32                	jmp    8019b1 <vprintfmt+0x2d1>
	else if (lflag)
  80197f:	85 d2                	test   %edx,%edx
  801981:	74 18                	je     80199b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801983:	8b 45 14             	mov    0x14(%ebp),%eax
  801986:	8d 50 04             	lea    0x4(%eax),%edx
  801989:	89 55 14             	mov    %edx,0x14(%ebp)
  80198c:	8b 00                	mov    (%eax),%eax
  80198e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801991:	89 c1                	mov    %eax,%ecx
  801993:	c1 f9 1f             	sar    $0x1f,%ecx
  801996:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801999:	eb 16                	jmp    8019b1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80199b:	8b 45 14             	mov    0x14(%ebp),%eax
  80199e:	8d 50 04             	lea    0x4(%eax),%edx
  8019a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a4:	8b 00                	mov    (%eax),%eax
  8019a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a9:	89 c1                	mov    %eax,%ecx
  8019ab:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019c0:	0f 89 90 00 00 00    	jns    801a56 <vprintfmt+0x376>
				putch('-', putdat);
  8019c6:	83 ec 08             	sub    $0x8,%esp
  8019c9:	53                   	push   %ebx
  8019ca:	6a 2d                	push   $0x2d
  8019cc:	ff d6                	call   *%esi
				num = -(long long) num;
  8019ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019d4:	f7 d8                	neg    %eax
  8019d6:	83 d2 00             	adc    $0x0,%edx
  8019d9:	f7 da                	neg    %edx
  8019db:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019de:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019e3:	eb 71                	jmp    801a56 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8019e8:	e8 7f fc ff ff       	call   80166c <getuint>
			base = 10;
  8019ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019f2:	eb 62                	jmp    801a56 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8019f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8019f7:	e8 70 fc ff ff       	call   80166c <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801a03:	51                   	push   %ecx
  801a04:	ff 75 e0             	pushl  -0x20(%ebp)
  801a07:	6a 08                	push   $0x8
  801a09:	52                   	push   %edx
  801a0a:	50                   	push   %eax
  801a0b:	89 da                	mov    %ebx,%edx
  801a0d:	89 f0                	mov    %esi,%eax
  801a0f:	e8 a9 fb ff ff       	call   8015bd <printnum>
			break;
  801a14:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  801a1a:	e9 e7 fc ff ff       	jmp    801706 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a1f:	83 ec 08             	sub    $0x8,%esp
  801a22:	53                   	push   %ebx
  801a23:	6a 30                	push   $0x30
  801a25:	ff d6                	call   *%esi
			putch('x', putdat);
  801a27:	83 c4 08             	add    $0x8,%esp
  801a2a:	53                   	push   %ebx
  801a2b:	6a 78                	push   $0x78
  801a2d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a32:	8d 50 04             	lea    0x4(%eax),%edx
  801a35:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a38:	8b 00                	mov    (%eax),%eax
  801a3a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a3f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a42:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a47:	eb 0d                	jmp    801a56 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a49:	8d 45 14             	lea    0x14(%ebp),%eax
  801a4c:	e8 1b fc ff ff       	call   80166c <getuint>
			base = 16;
  801a51:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a56:	83 ec 0c             	sub    $0xc,%esp
  801a59:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a5d:	57                   	push   %edi
  801a5e:	ff 75 e0             	pushl  -0x20(%ebp)
  801a61:	51                   	push   %ecx
  801a62:	52                   	push   %edx
  801a63:	50                   	push   %eax
  801a64:	89 da                	mov    %ebx,%edx
  801a66:	89 f0                	mov    %esi,%eax
  801a68:	e8 50 fb ff ff       	call   8015bd <printnum>
			break;
  801a6d:	83 c4 20             	add    $0x20,%esp
  801a70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a73:	e9 8e fc ff ff       	jmp    801706 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a78:	83 ec 08             	sub    $0x8,%esp
  801a7b:	53                   	push   %ebx
  801a7c:	51                   	push   %ecx
  801a7d:	ff d6                	call   *%esi
			break;
  801a7f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a85:	e9 7c fc ff ff       	jmp    801706 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a8a:	83 ec 08             	sub    $0x8,%esp
  801a8d:	53                   	push   %ebx
  801a8e:	6a 25                	push   $0x25
  801a90:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	eb 03                	jmp    801a9a <vprintfmt+0x3ba>
  801a97:	83 ef 01             	sub    $0x1,%edi
  801a9a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a9e:	75 f7                	jne    801a97 <vprintfmt+0x3b7>
  801aa0:	e9 61 fc ff ff       	jmp    801706 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5e                   	pop    %esi
  801aaa:	5f                   	pop    %edi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 18             	sub    $0x18,%esp
  801ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801abc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ac0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ac3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801aca:	85 c0                	test   %eax,%eax
  801acc:	74 26                	je     801af4 <vsnprintf+0x47>
  801ace:	85 d2                	test   %edx,%edx
  801ad0:	7e 22                	jle    801af4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ad2:	ff 75 14             	pushl  0x14(%ebp)
  801ad5:	ff 75 10             	pushl  0x10(%ebp)
  801ad8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801adb:	50                   	push   %eax
  801adc:	68 a6 16 80 00       	push   $0x8016a6
  801ae1:	e8 fa fb ff ff       	call   8016e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ae6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	eb 05                	jmp    801af9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801af4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b01:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b04:	50                   	push   %eax
  801b05:	ff 75 10             	pushl  0x10(%ebp)
  801b08:	ff 75 0c             	pushl  0xc(%ebp)
  801b0b:	ff 75 08             	pushl  0x8(%ebp)
  801b0e:	e8 9a ff ff ff       	call   801aad <vsnprintf>
	va_end(ap);

	return rc;
}
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b20:	eb 03                	jmp    801b25 <strlen+0x10>
		n++;
  801b22:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b25:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b29:	75 f7                	jne    801b22 <strlen+0xd>
		n++;
	return n;
}
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b33:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b36:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3b:	eb 03                	jmp    801b40 <strnlen+0x13>
		n++;
  801b3d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b40:	39 c2                	cmp    %eax,%edx
  801b42:	74 08                	je     801b4c <strnlen+0x1f>
  801b44:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b48:	75 f3                	jne    801b3d <strnlen+0x10>
  801b4a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    

00801b4e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	53                   	push   %ebx
  801b52:	8b 45 08             	mov    0x8(%ebp),%eax
  801b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b58:	89 c2                	mov    %eax,%edx
  801b5a:	83 c2 01             	add    $0x1,%edx
  801b5d:	83 c1 01             	add    $0x1,%ecx
  801b60:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b64:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b67:	84 db                	test   %bl,%bl
  801b69:	75 ef                	jne    801b5a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b6b:	5b                   	pop    %ebx
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	53                   	push   %ebx
  801b72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b75:	53                   	push   %ebx
  801b76:	e8 9a ff ff ff       	call   801b15 <strlen>
  801b7b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b7e:	ff 75 0c             	pushl  0xc(%ebp)
  801b81:	01 d8                	add    %ebx,%eax
  801b83:	50                   	push   %eax
  801b84:	e8 c5 ff ff ff       	call   801b4e <strcpy>
	return dst;
}
  801b89:	89 d8                	mov    %ebx,%eax
  801b8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	56                   	push   %esi
  801b94:	53                   	push   %ebx
  801b95:	8b 75 08             	mov    0x8(%ebp),%esi
  801b98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9b:	89 f3                	mov    %esi,%ebx
  801b9d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba0:	89 f2                	mov    %esi,%edx
  801ba2:	eb 0f                	jmp    801bb3 <strncpy+0x23>
		*dst++ = *src;
  801ba4:	83 c2 01             	add    $0x1,%edx
  801ba7:	0f b6 01             	movzbl (%ecx),%eax
  801baa:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bad:	80 39 01             	cmpb   $0x1,(%ecx)
  801bb0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bb3:	39 da                	cmp    %ebx,%edx
  801bb5:	75 ed                	jne    801ba4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bb7:	89 f0                	mov    %esi,%eax
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	56                   	push   %esi
  801bc1:	53                   	push   %ebx
  801bc2:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc8:	8b 55 10             	mov    0x10(%ebp),%edx
  801bcb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bcd:	85 d2                	test   %edx,%edx
  801bcf:	74 21                	je     801bf2 <strlcpy+0x35>
  801bd1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bd5:	89 f2                	mov    %esi,%edx
  801bd7:	eb 09                	jmp    801be2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bd9:	83 c2 01             	add    $0x1,%edx
  801bdc:	83 c1 01             	add    $0x1,%ecx
  801bdf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801be2:	39 c2                	cmp    %eax,%edx
  801be4:	74 09                	je     801bef <strlcpy+0x32>
  801be6:	0f b6 19             	movzbl (%ecx),%ebx
  801be9:	84 db                	test   %bl,%bl
  801beb:	75 ec                	jne    801bd9 <strlcpy+0x1c>
  801bed:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bf2:	29 f0                	sub    %esi,%eax
}
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bfe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c01:	eb 06                	jmp    801c09 <strcmp+0x11>
		p++, q++;
  801c03:	83 c1 01             	add    $0x1,%ecx
  801c06:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c09:	0f b6 01             	movzbl (%ecx),%eax
  801c0c:	84 c0                	test   %al,%al
  801c0e:	74 04                	je     801c14 <strcmp+0x1c>
  801c10:	3a 02                	cmp    (%edx),%al
  801c12:	74 ef                	je     801c03 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c14:	0f b6 c0             	movzbl %al,%eax
  801c17:	0f b6 12             	movzbl (%edx),%edx
  801c1a:	29 d0                	sub    %edx,%eax
}
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    

00801c1e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	53                   	push   %ebx
  801c22:	8b 45 08             	mov    0x8(%ebp),%eax
  801c25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c2d:	eb 06                	jmp    801c35 <strncmp+0x17>
		n--, p++, q++;
  801c2f:	83 c0 01             	add    $0x1,%eax
  801c32:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c35:	39 d8                	cmp    %ebx,%eax
  801c37:	74 15                	je     801c4e <strncmp+0x30>
  801c39:	0f b6 08             	movzbl (%eax),%ecx
  801c3c:	84 c9                	test   %cl,%cl
  801c3e:	74 04                	je     801c44 <strncmp+0x26>
  801c40:	3a 0a                	cmp    (%edx),%cl
  801c42:	74 eb                	je     801c2f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c44:	0f b6 00             	movzbl (%eax),%eax
  801c47:	0f b6 12             	movzbl (%edx),%edx
  801c4a:	29 d0                	sub    %edx,%eax
  801c4c:	eb 05                	jmp    801c53 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c4e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c53:	5b                   	pop    %ebx
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c60:	eb 07                	jmp    801c69 <strchr+0x13>
		if (*s == c)
  801c62:	38 ca                	cmp    %cl,%dl
  801c64:	74 0f                	je     801c75 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c66:	83 c0 01             	add    $0x1,%eax
  801c69:	0f b6 10             	movzbl (%eax),%edx
  801c6c:	84 d2                	test   %dl,%dl
  801c6e:	75 f2                	jne    801c62 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    

00801c77 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c81:	eb 03                	jmp    801c86 <strfind+0xf>
  801c83:	83 c0 01             	add    $0x1,%eax
  801c86:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c89:	38 ca                	cmp    %cl,%dl
  801c8b:	74 04                	je     801c91 <strfind+0x1a>
  801c8d:	84 d2                	test   %dl,%dl
  801c8f:	75 f2                	jne    801c83 <strfind+0xc>
			break;
	return (char *) s;
}
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	57                   	push   %edi
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c9f:	85 c9                	test   %ecx,%ecx
  801ca1:	74 36                	je     801cd9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ca3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ca9:	75 28                	jne    801cd3 <memset+0x40>
  801cab:	f6 c1 03             	test   $0x3,%cl
  801cae:	75 23                	jne    801cd3 <memset+0x40>
		c &= 0xFF;
  801cb0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cb4:	89 d3                	mov    %edx,%ebx
  801cb6:	c1 e3 08             	shl    $0x8,%ebx
  801cb9:	89 d6                	mov    %edx,%esi
  801cbb:	c1 e6 18             	shl    $0x18,%esi
  801cbe:	89 d0                	mov    %edx,%eax
  801cc0:	c1 e0 10             	shl    $0x10,%eax
  801cc3:	09 f0                	or     %esi,%eax
  801cc5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cc7:	89 d8                	mov    %ebx,%eax
  801cc9:	09 d0                	or     %edx,%eax
  801ccb:	c1 e9 02             	shr    $0x2,%ecx
  801cce:	fc                   	cld    
  801ccf:	f3 ab                	rep stos %eax,%es:(%edi)
  801cd1:	eb 06                	jmp    801cd9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd6:	fc                   	cld    
  801cd7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cd9:	89 f8                	mov    %edi,%eax
  801cdb:	5b                   	pop    %ebx
  801cdc:	5e                   	pop    %esi
  801cdd:	5f                   	pop    %edi
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	57                   	push   %edi
  801ce4:	56                   	push   %esi
  801ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ceb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cee:	39 c6                	cmp    %eax,%esi
  801cf0:	73 35                	jae    801d27 <memmove+0x47>
  801cf2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf5:	39 d0                	cmp    %edx,%eax
  801cf7:	73 2e                	jae    801d27 <memmove+0x47>
		s += n;
		d += n;
  801cf9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cfc:	89 d6                	mov    %edx,%esi
  801cfe:	09 fe                	or     %edi,%esi
  801d00:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d06:	75 13                	jne    801d1b <memmove+0x3b>
  801d08:	f6 c1 03             	test   $0x3,%cl
  801d0b:	75 0e                	jne    801d1b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d0d:	83 ef 04             	sub    $0x4,%edi
  801d10:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d13:	c1 e9 02             	shr    $0x2,%ecx
  801d16:	fd                   	std    
  801d17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d19:	eb 09                	jmp    801d24 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d1b:	83 ef 01             	sub    $0x1,%edi
  801d1e:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d21:	fd                   	std    
  801d22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d24:	fc                   	cld    
  801d25:	eb 1d                	jmp    801d44 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d27:	89 f2                	mov    %esi,%edx
  801d29:	09 c2                	or     %eax,%edx
  801d2b:	f6 c2 03             	test   $0x3,%dl
  801d2e:	75 0f                	jne    801d3f <memmove+0x5f>
  801d30:	f6 c1 03             	test   $0x3,%cl
  801d33:	75 0a                	jne    801d3f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d35:	c1 e9 02             	shr    $0x2,%ecx
  801d38:	89 c7                	mov    %eax,%edi
  801d3a:	fc                   	cld    
  801d3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d3d:	eb 05                	jmp    801d44 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d3f:	89 c7                	mov    %eax,%edi
  801d41:	fc                   	cld    
  801d42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d44:	5e                   	pop    %esi
  801d45:	5f                   	pop    %edi
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    

00801d48 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d4b:	ff 75 10             	pushl  0x10(%ebp)
  801d4e:	ff 75 0c             	pushl  0xc(%ebp)
  801d51:	ff 75 08             	pushl  0x8(%ebp)
  801d54:	e8 87 ff ff ff       	call   801ce0 <memmove>
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	56                   	push   %esi
  801d5f:	53                   	push   %ebx
  801d60:	8b 45 08             	mov    0x8(%ebp),%eax
  801d63:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d66:	89 c6                	mov    %eax,%esi
  801d68:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d6b:	eb 1a                	jmp    801d87 <memcmp+0x2c>
		if (*s1 != *s2)
  801d6d:	0f b6 08             	movzbl (%eax),%ecx
  801d70:	0f b6 1a             	movzbl (%edx),%ebx
  801d73:	38 d9                	cmp    %bl,%cl
  801d75:	74 0a                	je     801d81 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d77:	0f b6 c1             	movzbl %cl,%eax
  801d7a:	0f b6 db             	movzbl %bl,%ebx
  801d7d:	29 d8                	sub    %ebx,%eax
  801d7f:	eb 0f                	jmp    801d90 <memcmp+0x35>
		s1++, s2++;
  801d81:	83 c0 01             	add    $0x1,%eax
  801d84:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d87:	39 f0                	cmp    %esi,%eax
  801d89:	75 e2                	jne    801d6d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    

00801d94 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	53                   	push   %ebx
  801d98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d9b:	89 c1                	mov    %eax,%ecx
  801d9d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801da0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da4:	eb 0a                	jmp    801db0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801da6:	0f b6 10             	movzbl (%eax),%edx
  801da9:	39 da                	cmp    %ebx,%edx
  801dab:	74 07                	je     801db4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dad:	83 c0 01             	add    $0x1,%eax
  801db0:	39 c8                	cmp    %ecx,%eax
  801db2:	72 f2                	jb     801da6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801db4:	5b                   	pop    %ebx
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	57                   	push   %edi
  801dbb:	56                   	push   %esi
  801dbc:	53                   	push   %ebx
  801dbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc3:	eb 03                	jmp    801dc8 <strtol+0x11>
		s++;
  801dc5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc8:	0f b6 01             	movzbl (%ecx),%eax
  801dcb:	3c 20                	cmp    $0x20,%al
  801dcd:	74 f6                	je     801dc5 <strtol+0xe>
  801dcf:	3c 09                	cmp    $0x9,%al
  801dd1:	74 f2                	je     801dc5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dd3:	3c 2b                	cmp    $0x2b,%al
  801dd5:	75 0a                	jne    801de1 <strtol+0x2a>
		s++;
  801dd7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dda:	bf 00 00 00 00       	mov    $0x0,%edi
  801ddf:	eb 11                	jmp    801df2 <strtol+0x3b>
  801de1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801de6:	3c 2d                	cmp    $0x2d,%al
  801de8:	75 08                	jne    801df2 <strtol+0x3b>
		s++, neg = 1;
  801dea:	83 c1 01             	add    $0x1,%ecx
  801ded:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801df8:	75 15                	jne    801e0f <strtol+0x58>
  801dfa:	80 39 30             	cmpb   $0x30,(%ecx)
  801dfd:	75 10                	jne    801e0f <strtol+0x58>
  801dff:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e03:	75 7c                	jne    801e81 <strtol+0xca>
		s += 2, base = 16;
  801e05:	83 c1 02             	add    $0x2,%ecx
  801e08:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e0d:	eb 16                	jmp    801e25 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e0f:	85 db                	test   %ebx,%ebx
  801e11:	75 12                	jne    801e25 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e13:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e18:	80 39 30             	cmpb   $0x30,(%ecx)
  801e1b:	75 08                	jne    801e25 <strtol+0x6e>
		s++, base = 8;
  801e1d:	83 c1 01             	add    $0x1,%ecx
  801e20:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e25:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e2d:	0f b6 11             	movzbl (%ecx),%edx
  801e30:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e33:	89 f3                	mov    %esi,%ebx
  801e35:	80 fb 09             	cmp    $0x9,%bl
  801e38:	77 08                	ja     801e42 <strtol+0x8b>
			dig = *s - '0';
  801e3a:	0f be d2             	movsbl %dl,%edx
  801e3d:	83 ea 30             	sub    $0x30,%edx
  801e40:	eb 22                	jmp    801e64 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e42:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e45:	89 f3                	mov    %esi,%ebx
  801e47:	80 fb 19             	cmp    $0x19,%bl
  801e4a:	77 08                	ja     801e54 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e4c:	0f be d2             	movsbl %dl,%edx
  801e4f:	83 ea 57             	sub    $0x57,%edx
  801e52:	eb 10                	jmp    801e64 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e54:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e57:	89 f3                	mov    %esi,%ebx
  801e59:	80 fb 19             	cmp    $0x19,%bl
  801e5c:	77 16                	ja     801e74 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e5e:	0f be d2             	movsbl %dl,%edx
  801e61:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e64:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e67:	7d 0b                	jge    801e74 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e69:	83 c1 01             	add    $0x1,%ecx
  801e6c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e70:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e72:	eb b9                	jmp    801e2d <strtol+0x76>

	if (endptr)
  801e74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e78:	74 0d                	je     801e87 <strtol+0xd0>
		*endptr = (char *) s;
  801e7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e7d:	89 0e                	mov    %ecx,(%esi)
  801e7f:	eb 06                	jmp    801e87 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e81:	85 db                	test   %ebx,%ebx
  801e83:	74 98                	je     801e1d <strtol+0x66>
  801e85:	eb 9e                	jmp    801e25 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e87:	89 c2                	mov    %eax,%edx
  801e89:	f7 da                	neg    %edx
  801e8b:	85 ff                	test   %edi,%edi
  801e8d:	0f 45 c2             	cmovne %edx,%eax
}
  801e90:	5b                   	pop    %ebx
  801e91:	5e                   	pop    %esi
  801e92:	5f                   	pop    %edi
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	56                   	push   %esi
  801e99:	53                   	push   %ebx
  801e9a:	8b 75 08             	mov    0x8(%ebp),%esi
  801e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	74 0e                	je     801eb5 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801ea7:	83 ec 0c             	sub    $0xc,%esp
  801eaa:	50                   	push   %eax
  801eab:	e8 63 e4 ff ff       	call   800313 <sys_ipc_recv>
  801eb0:	83 c4 10             	add    $0x10,%esp
  801eb3:	eb 10                	jmp    801ec5 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801eb5:	83 ec 0c             	sub    $0xc,%esp
  801eb8:	68 00 00 c0 ee       	push   $0xeec00000
  801ebd:	e8 51 e4 ff ff       	call   800313 <sys_ipc_recv>
  801ec2:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	79 17                	jns    801ee0 <ipc_recv+0x4b>
		if(*from_env_store)
  801ec9:	83 3e 00             	cmpl   $0x0,(%esi)
  801ecc:	74 06                	je     801ed4 <ipc_recv+0x3f>
			*from_env_store = 0;
  801ece:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801ed4:	85 db                	test   %ebx,%ebx
  801ed6:	74 2c                	je     801f04 <ipc_recv+0x6f>
			*perm_store = 0;
  801ed8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ede:	eb 24                	jmp    801f04 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801ee0:	85 f6                	test   %esi,%esi
  801ee2:	74 0a                	je     801eee <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801ee4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee9:	8b 40 74             	mov    0x74(%eax),%eax
  801eec:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801eee:	85 db                	test   %ebx,%ebx
  801ef0:	74 0a                	je     801efc <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801ef2:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef7:	8b 40 78             	mov    0x78(%eax),%eax
  801efa:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801efc:	a1 08 40 80 00       	mov    0x804008,%eax
  801f01:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f07:	5b                   	pop    %ebx
  801f08:	5e                   	pop    %esi
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    

00801f0b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	57                   	push   %edi
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f17:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f1d:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f1f:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f24:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f27:	e8 18 e2 ff ff       	call   800144 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f2c:	ff 75 14             	pushl  0x14(%ebp)
  801f2f:	53                   	push   %ebx
  801f30:	56                   	push   %esi
  801f31:	57                   	push   %edi
  801f32:	e8 b9 e3 ff ff       	call   8002f0 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f37:	89 c2                	mov    %eax,%edx
  801f39:	f7 d2                	not    %edx
  801f3b:	c1 ea 1f             	shr    $0x1f,%edx
  801f3e:	83 c4 10             	add    $0x10,%esp
  801f41:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f44:	0f 94 c1             	sete   %cl
  801f47:	09 ca                	or     %ecx,%edx
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	0f 94 c0             	sete   %al
  801f4e:	38 c2                	cmp    %al,%dl
  801f50:	77 d5                	ja     801f27 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801f52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	5f                   	pop    %edi
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f65:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f68:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f6e:	8b 52 50             	mov    0x50(%edx),%edx
  801f71:	39 ca                	cmp    %ecx,%edx
  801f73:	75 0d                	jne    801f82 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f75:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f78:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f7d:	8b 40 48             	mov    0x48(%eax),%eax
  801f80:	eb 0f                	jmp    801f91 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f82:	83 c0 01             	add    $0x1,%eax
  801f85:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f8a:	75 d9                	jne    801f65 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f91:	5d                   	pop    %ebp
  801f92:	c3                   	ret    

00801f93 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f99:	89 d0                	mov    %edx,%eax
  801f9b:	c1 e8 16             	shr    $0x16,%eax
  801f9e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801faa:	f6 c1 01             	test   $0x1,%cl
  801fad:	74 1d                	je     801fcc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801faf:	c1 ea 0c             	shr    $0xc,%edx
  801fb2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb9:	f6 c2 01             	test   $0x1,%dl
  801fbc:	74 0e                	je     801fcc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fbe:	c1 ea 0c             	shr    $0xc,%edx
  801fc1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc8:	ef 
  801fc9:	0f b7 c0             	movzwl %ax,%eax
}
  801fcc:	5d                   	pop    %ebp
  801fcd:	c3                   	ret    
  801fce:	66 90                	xchg   %ax,%ax

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
