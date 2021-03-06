
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 80 1e 80 00       	push   $0x801e80
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 c3 01 00 00       	call   800221 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 83 1e 80 00       	push   $0x801e83
  80008f:	6a 01                	push   $0x1
  800091:	e8 8b 0a 00 00       	call   800b21 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 9a 00 00 00       	call   80013e <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 6f 0a 00 00       	call   800b21 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 a6 1f 80 00       	push   $0x801fa6
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 4e 0a 00 00       	call   800b21 <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000e9:	e8 4e 04 00 00       	call   80053c <sys_getenvid>
	thisenv = &envs [ENVX(id)];
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fb:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x2d>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	e8 1e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800115:	e8 0a 00 00 00       	call   800124 <exit>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 07 08 00 00       	call   800936 <close_all>
	sys_env_destroy(0);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	6a 00                	push   $0x0
  800134:	e8 c2 03 00 00       	call   8004fb <sys_env_destroy>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800144:	b8 00 00 00 00       	mov    $0x0,%eax
  800149:	eb 03                	jmp    80014e <strlen+0x10>
		n++;
  80014b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80014e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800152:	75 f7                	jne    80014b <strlen+0xd>
		n++;
	return n;
}
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	eb 03                	jmp    800169 <strnlen+0x13>
		n++;
  800166:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800169:	39 c2                	cmp    %eax,%edx
  80016b:	74 08                	je     800175 <strnlen+0x1f>
  80016d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800171:	75 f3                	jne    800166 <strnlen+0x10>
  800173:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800181:	89 c2                	mov    %eax,%edx
  800183:	83 c2 01             	add    $0x1,%edx
  800186:	83 c1 01             	add    $0x1,%ecx
  800189:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80018d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800190:	84 db                	test   %bl,%bl
  800192:	75 ef                	jne    800183 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800194:	5b                   	pop    %ebx
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80019e:	53                   	push   %ebx
  80019f:	e8 9a ff ff ff       	call   80013e <strlen>
  8001a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	01 d8                	add    %ebx,%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 c5 ff ff ff       	call   800177 <strcpy>
	return dst;
}
  8001b2:	89 d8                	mov    %ebx,%eax
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	89 f3                	mov    %esi,%ebx
  8001c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001c9:	89 f2                	mov    %esi,%edx
  8001cb:	eb 0f                	jmp    8001dc <strncpy+0x23>
		*dst++ = *src;
  8001cd:	83 c2 01             	add    $0x1,%edx
  8001d0:	0f b6 01             	movzbl (%ecx),%eax
  8001d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8001d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001dc:	39 da                	cmp    %ebx,%edx
  8001de:	75 ed                	jne    8001cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001e0:	89 f0                	mov    %esi,%eax
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8001f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001f6:	85 d2                	test   %edx,%edx
  8001f8:	74 21                	je     80021b <strlcpy+0x35>
  8001fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	eb 09                	jmp    80020b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800202:	83 c2 01             	add    $0x1,%edx
  800205:	83 c1 01             	add    $0x1,%ecx
  800208:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80020b:	39 c2                	cmp    %eax,%edx
  80020d:	74 09                	je     800218 <strlcpy+0x32>
  80020f:	0f b6 19             	movzbl (%ecx),%ebx
  800212:	84 db                	test   %bl,%bl
  800214:	75 ec                	jne    800202 <strlcpy+0x1c>
  800216:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800218:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80021b:	29 f0                	sub    %esi,%eax
}
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80022a:	eb 06                	jmp    800232 <strcmp+0x11>
		p++, q++;
  80022c:	83 c1 01             	add    $0x1,%ecx
  80022f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800232:	0f b6 01             	movzbl (%ecx),%eax
  800235:	84 c0                	test   %al,%al
  800237:	74 04                	je     80023d <strcmp+0x1c>
  800239:	3a 02                	cmp    (%edx),%al
  80023b:	74 ef                	je     80022c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80023d:	0f b6 c0             	movzbl %al,%eax
  800240:	0f b6 12             	movzbl (%edx),%edx
  800243:	29 d0                	sub    %edx,%eax
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 c3                	mov    %eax,%ebx
  800253:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800256:	eb 06                	jmp    80025e <strncmp+0x17>
		n--, p++, q++;
  800258:	83 c0 01             	add    $0x1,%eax
  80025b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80025e:	39 d8                	cmp    %ebx,%eax
  800260:	74 15                	je     800277 <strncmp+0x30>
  800262:	0f b6 08             	movzbl (%eax),%ecx
  800265:	84 c9                	test   %cl,%cl
  800267:	74 04                	je     80026d <strncmp+0x26>
  800269:	3a 0a                	cmp    (%edx),%cl
  80026b:	74 eb                	je     800258 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026d:	0f b6 00             	movzbl (%eax),%eax
  800270:	0f b6 12             	movzbl (%edx),%edx
  800273:	29 d0                	sub    %edx,%eax
  800275:	eb 05                	jmp    80027c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800277:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80027c:	5b                   	pop    %ebx
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800289:	eb 07                	jmp    800292 <strchr+0x13>
		if (*s == c)
  80028b:	38 ca                	cmp    %cl,%dl
  80028d:	74 0f                	je     80029e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80028f:	83 c0 01             	add    $0x1,%eax
  800292:	0f b6 10             	movzbl (%eax),%edx
  800295:	84 d2                	test   %dl,%dl
  800297:	75 f2                	jne    80028b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002aa:	eb 03                	jmp    8002af <strfind+0xf>
  8002ac:	83 c0 01             	add    $0x1,%eax
  8002af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002b2:	38 ca                	cmp    %cl,%dl
  8002b4:	74 04                	je     8002ba <strfind+0x1a>
  8002b6:	84 d2                	test   %dl,%dl
  8002b8:	75 f2                	jne    8002ac <strfind+0xc>
			break;
	return (char *) s;
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c8:	85 c9                	test   %ecx,%ecx
  8002ca:	74 36                	je     800302 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002d2:	75 28                	jne    8002fc <memset+0x40>
  8002d4:	f6 c1 03             	test   $0x3,%cl
  8002d7:	75 23                	jne    8002fc <memset+0x40>
		c &= 0xFF;
  8002d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002dd:	89 d3                	mov    %edx,%ebx
  8002df:	c1 e3 08             	shl    $0x8,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	c1 e6 18             	shl    $0x18,%esi
  8002e7:	89 d0                	mov    %edx,%eax
  8002e9:	c1 e0 10             	shl    $0x10,%eax
  8002ec:	09 f0                	or     %esi,%eax
  8002ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8002f0:	89 d8                	mov    %ebx,%eax
  8002f2:	09 d0                	or     %edx,%eax
  8002f4:	c1 e9 02             	shr    $0x2,%ecx
  8002f7:	fc                   	cld    
  8002f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8002fa:	eb 06                	jmp    800302 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	fc                   	cld    
  800300:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800302:	89 f8                	mov    %edi,%eax
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 75 0c             	mov    0xc(%ebp),%esi
  800314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800317:	39 c6                	cmp    %eax,%esi
  800319:	73 35                	jae    800350 <memmove+0x47>
  80031b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80031e:	39 d0                	cmp    %edx,%eax
  800320:	73 2e                	jae    800350 <memmove+0x47>
		s += n;
		d += n;
  800322:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800325:	89 d6                	mov    %edx,%esi
  800327:	09 fe                	or     %edi,%esi
  800329:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032f:	75 13                	jne    800344 <memmove+0x3b>
  800331:	f6 c1 03             	test   $0x3,%cl
  800334:	75 0e                	jne    800344 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800336:	83 ef 04             	sub    $0x4,%edi
  800339:	8d 72 fc             	lea    -0x4(%edx),%esi
  80033c:	c1 e9 02             	shr    $0x2,%ecx
  80033f:	fd                   	std    
  800340:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800342:	eb 09                	jmp    80034d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800344:	83 ef 01             	sub    $0x1,%edi
  800347:	8d 72 ff             	lea    -0x1(%edx),%esi
  80034a:	fd                   	std    
  80034b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80034d:	fc                   	cld    
  80034e:	eb 1d                	jmp    80036d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800350:	89 f2                	mov    %esi,%edx
  800352:	09 c2                	or     %eax,%edx
  800354:	f6 c2 03             	test   $0x3,%dl
  800357:	75 0f                	jne    800368 <memmove+0x5f>
  800359:	f6 c1 03             	test   $0x3,%cl
  80035c:	75 0a                	jne    800368 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80035e:	c1 e9 02             	shr    $0x2,%ecx
  800361:	89 c7                	mov    %eax,%edi
  800363:	fc                   	cld    
  800364:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800366:	eb 05                	jmp    80036d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800368:	89 c7                	mov    %eax,%edi
  80036a:	fc                   	cld    
  80036b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 87 ff ff ff       	call   800309 <memmove>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 c6                	mov    %eax,%esi
  800391:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800394:	eb 1a                	jmp    8003b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800396:	0f b6 08             	movzbl (%eax),%ecx
  800399:	0f b6 1a             	movzbl (%edx),%ebx
  80039c:	38 d9                	cmp    %bl,%cl
  80039e:	74 0a                	je     8003aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003a0:	0f b6 c1             	movzbl %cl,%eax
  8003a3:	0f b6 db             	movzbl %bl,%ebx
  8003a6:	29 d8                	sub    %ebx,%eax
  8003a8:	eb 0f                	jmp    8003b9 <memcmp+0x35>
		s1++, s2++;
  8003aa:	83 c0 01             	add    $0x1,%eax
  8003ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b0:	39 f0                	cmp    %esi,%eax
  8003b2:	75 e2                	jne    800396 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	53                   	push   %ebx
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8003c4:	89 c1                	mov    %eax,%ecx
  8003c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003cd:	eb 0a                	jmp    8003d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003cf:	0f b6 10             	movzbl (%eax),%edx
  8003d2:	39 da                	cmp    %ebx,%edx
  8003d4:	74 07                	je     8003dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003d6:	83 c0 01             	add    $0x1,%eax
  8003d9:	39 c8                	cmp    %ecx,%eax
  8003db:	72 f2                	jb     8003cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003dd:	5b                   	pop    %ebx
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ec:	eb 03                	jmp    8003f1 <strtol+0x11>
		s++;
  8003ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003f1:	0f b6 01             	movzbl (%ecx),%eax
  8003f4:	3c 20                	cmp    $0x20,%al
  8003f6:	74 f6                	je     8003ee <strtol+0xe>
  8003f8:	3c 09                	cmp    $0x9,%al
  8003fa:	74 f2                	je     8003ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003fc:	3c 2b                	cmp    $0x2b,%al
  8003fe:	75 0a                	jne    80040a <strtol+0x2a>
		s++;
  800400:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800403:	bf 00 00 00 00       	mov    $0x0,%edi
  800408:	eb 11                	jmp    80041b <strtol+0x3b>
  80040a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80040f:	3c 2d                	cmp    $0x2d,%al
  800411:	75 08                	jne    80041b <strtol+0x3b>
		s++, neg = 1;
  800413:	83 c1 01             	add    $0x1,%ecx
  800416:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80041b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800421:	75 15                	jne    800438 <strtol+0x58>
  800423:	80 39 30             	cmpb   $0x30,(%ecx)
  800426:	75 10                	jne    800438 <strtol+0x58>
  800428:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80042c:	75 7c                	jne    8004aa <strtol+0xca>
		s += 2, base = 16;
  80042e:	83 c1 02             	add    $0x2,%ecx
  800431:	bb 10 00 00 00       	mov    $0x10,%ebx
  800436:	eb 16                	jmp    80044e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800438:	85 db                	test   %ebx,%ebx
  80043a:	75 12                	jne    80044e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80043c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800441:	80 39 30             	cmpb   $0x30,(%ecx)
  800444:	75 08                	jne    80044e <strtol+0x6e>
		s++, base = 8;
  800446:	83 c1 01             	add    $0x1,%ecx
  800449:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800456:	0f b6 11             	movzbl (%ecx),%edx
  800459:	8d 72 d0             	lea    -0x30(%edx),%esi
  80045c:	89 f3                	mov    %esi,%ebx
  80045e:	80 fb 09             	cmp    $0x9,%bl
  800461:	77 08                	ja     80046b <strtol+0x8b>
			dig = *s - '0';
  800463:	0f be d2             	movsbl %dl,%edx
  800466:	83 ea 30             	sub    $0x30,%edx
  800469:	eb 22                	jmp    80048d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80046b:	8d 72 9f             	lea    -0x61(%edx),%esi
  80046e:	89 f3                	mov    %esi,%ebx
  800470:	80 fb 19             	cmp    $0x19,%bl
  800473:	77 08                	ja     80047d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800475:	0f be d2             	movsbl %dl,%edx
  800478:	83 ea 57             	sub    $0x57,%edx
  80047b:	eb 10                	jmp    80048d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80047d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800480:	89 f3                	mov    %esi,%ebx
  800482:	80 fb 19             	cmp    $0x19,%bl
  800485:	77 16                	ja     80049d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800487:	0f be d2             	movsbl %dl,%edx
  80048a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80048d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800490:	7d 0b                	jge    80049d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800492:	83 c1 01             	add    $0x1,%ecx
  800495:	0f af 45 10          	imul   0x10(%ebp),%eax
  800499:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80049b:	eb b9                	jmp    800456 <strtol+0x76>

	if (endptr)
  80049d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a1:	74 0d                	je     8004b0 <strtol+0xd0>
		*endptr = (char *) s;
  8004a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a6:	89 0e                	mov    %ecx,(%esi)
  8004a8:	eb 06                	jmp    8004b0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004aa:	85 db                	test   %ebx,%ebx
  8004ac:	74 98                	je     800446 <strtol+0x66>
  8004ae:	eb 9e                	jmp    80044e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004b0:	89 c2                	mov    %eax,%edx
  8004b2:	f7 da                	neg    %edx
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	0f 45 c2             	cmovne %edx,%eax
}
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	57                   	push   %edi
  8004c2:	56                   	push   %esi
  8004c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	89 c7                	mov    %eax,%edi
  8004d3:	89 c6                	mov    %eax,%esi
  8004d5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d7:	5b                   	pop    %ebx
  8004d8:	5e                   	pop    %esi
  8004d9:	5f                   	pop    %edi
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8004ec:	89 d1                	mov    %edx,%ecx
  8004ee:	89 d3                	mov    %edx,%ebx
  8004f0:	89 d7                	mov    %edx,%edi
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f6:	5b                   	pop    %ebx
  8004f7:	5e                   	pop    %esi
  8004f8:	5f                   	pop    %edi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	57                   	push   %edi
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
  800501:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800504:	b9 00 00 00 00       	mov    $0x0,%ecx
  800509:	b8 03 00 00 00       	mov    $0x3,%eax
  80050e:	8b 55 08             	mov    0x8(%ebp),%edx
  800511:	89 cb                	mov    %ecx,%ebx
  800513:	89 cf                	mov    %ecx,%edi
  800515:	89 ce                	mov    %ecx,%esi
  800517:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800519:	85 c0                	test   %eax,%eax
  80051b:	7e 17                	jle    800534 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	50                   	push   %eax
  800521:	6a 03                	push   $0x3
  800523:	68 8f 1e 80 00       	push   $0x801e8f
  800528:	6a 23                	push   $0x23
  80052a:	68 ac 1e 80 00       	push   $0x801eac
  80052f:	e8 6a 0f 00 00       	call   80149e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800534:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800537:	5b                   	pop    %ebx
  800538:	5e                   	pop    %esi
  800539:	5f                   	pop    %edi
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	57                   	push   %edi
  800540:	56                   	push   %esi
  800541:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800542:	ba 00 00 00 00       	mov    $0x0,%edx
  800547:	b8 02 00 00 00       	mov    $0x2,%eax
  80054c:	89 d1                	mov    %edx,%ecx
  80054e:	89 d3                	mov    %edx,%ebx
  800550:	89 d7                	mov    %edx,%edi
  800552:	89 d6                	mov    %edx,%esi
  800554:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800556:	5b                   	pop    %ebx
  800557:	5e                   	pop    %esi
  800558:	5f                   	pop    %edi
  800559:	5d                   	pop    %ebp
  80055a:	c3                   	ret    

0080055b <sys_yield>:

void
sys_yield(void)
{
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	57                   	push   %edi
  80055f:	56                   	push   %esi
  800560:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800561:	ba 00 00 00 00       	mov    $0x0,%edx
  800566:	b8 0b 00 00 00       	mov    $0xb,%eax
  80056b:	89 d1                	mov    %edx,%ecx
  80056d:	89 d3                	mov    %edx,%ebx
  80056f:	89 d7                	mov    %edx,%edi
  800571:	89 d6                	mov    %edx,%esi
  800573:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800575:	5b                   	pop    %ebx
  800576:	5e                   	pop    %esi
  800577:	5f                   	pop    %edi
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	57                   	push   %edi
  80057e:	56                   	push   %esi
  80057f:	53                   	push   %ebx
  800580:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800583:	be 00 00 00 00       	mov    $0x0,%esi
  800588:	b8 04 00 00 00       	mov    $0x4,%eax
  80058d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800590:	8b 55 08             	mov    0x8(%ebp),%edx
  800593:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800596:	89 f7                	mov    %esi,%edi
  800598:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80059a:	85 c0                	test   %eax,%eax
  80059c:	7e 17                	jle    8005b5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80059e:	83 ec 0c             	sub    $0xc,%esp
  8005a1:	50                   	push   %eax
  8005a2:	6a 04                	push   $0x4
  8005a4:	68 8f 1e 80 00       	push   $0x801e8f
  8005a9:	6a 23                	push   $0x23
  8005ab:	68 ac 1e 80 00       	push   $0x801eac
  8005b0:	e8 e9 0e 00 00       	call   80149e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b8:	5b                   	pop    %ebx
  8005b9:	5e                   	pop    %esi
  8005ba:	5f                   	pop    %edi
  8005bb:	5d                   	pop    %ebp
  8005bc:	c3                   	ret    

008005bd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	57                   	push   %edi
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8005cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8005da:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	7e 17                	jle    8005f7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	50                   	push   %eax
  8005e4:	6a 05                	push   $0x5
  8005e6:	68 8f 1e 80 00       	push   $0x801e8f
  8005eb:	6a 23                	push   $0x23
  8005ed:	68 ac 1e 80 00       	push   $0x801eac
  8005f2:	e8 a7 0e 00 00       	call   80149e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5f                   	pop    %edi
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    

008005ff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	57                   	push   %edi
  800603:	56                   	push   %esi
  800604:	53                   	push   %ebx
  800605:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800608:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060d:	b8 06 00 00 00       	mov    $0x6,%eax
  800612:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800615:	8b 55 08             	mov    0x8(%ebp),%edx
  800618:	89 df                	mov    %ebx,%edi
  80061a:	89 de                	mov    %ebx,%esi
  80061c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80061e:	85 c0                	test   %eax,%eax
  800620:	7e 17                	jle    800639 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800622:	83 ec 0c             	sub    $0xc,%esp
  800625:	50                   	push   %eax
  800626:	6a 06                	push   $0x6
  800628:	68 8f 1e 80 00       	push   $0x801e8f
  80062d:	6a 23                	push   $0x23
  80062f:	68 ac 1e 80 00       	push   $0x801eac
  800634:	e8 65 0e 00 00       	call   80149e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5e                   	pop    %esi
  80063e:	5f                   	pop    %edi
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	57                   	push   %edi
  800645:	56                   	push   %esi
  800646:	53                   	push   %ebx
  800647:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80064a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
  800654:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800657:	8b 55 08             	mov    0x8(%ebp),%edx
  80065a:	89 df                	mov    %ebx,%edi
  80065c:	89 de                	mov    %ebx,%esi
  80065e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800660:	85 c0                	test   %eax,%eax
  800662:	7e 17                	jle    80067b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	50                   	push   %eax
  800668:	6a 08                	push   $0x8
  80066a:	68 8f 1e 80 00       	push   $0x801e8f
  80066f:	6a 23                	push   $0x23
  800671:	68 ac 1e 80 00       	push   $0x801eac
  800676:	e8 23 0e 00 00       	call   80149e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80067b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5e                   	pop    %esi
  800680:	5f                   	pop    %edi
  800681:	5d                   	pop    %ebp
  800682:	c3                   	ret    

00800683 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	57                   	push   %edi
  800687:	56                   	push   %esi
  800688:	53                   	push   %ebx
  800689:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80068c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800691:	b8 09 00 00 00       	mov    $0x9,%eax
  800696:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800699:	8b 55 08             	mov    0x8(%ebp),%edx
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	89 de                	mov    %ebx,%esi
  8006a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	7e 17                	jle    8006bd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a6:	83 ec 0c             	sub    $0xc,%esp
  8006a9:	50                   	push   %eax
  8006aa:	6a 09                	push   $0x9
  8006ac:	68 8f 1e 80 00       	push   $0x801e8f
  8006b1:	6a 23                	push   $0x23
  8006b3:	68 ac 1e 80 00       	push   $0x801eac
  8006b8:	e8 e1 0d 00 00       	call   80149e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c0:	5b                   	pop    %ebx
  8006c1:	5e                   	pop    %esi
  8006c2:	5f                   	pop    %edi
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	57                   	push   %edi
  8006c9:	56                   	push   %esi
  8006ca:	53                   	push   %ebx
  8006cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
  8006de:	89 df                	mov    %ebx,%edi
  8006e0:	89 de                	mov    %ebx,%esi
  8006e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	7e 17                	jle    8006ff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e8:	83 ec 0c             	sub    $0xc,%esp
  8006eb:	50                   	push   %eax
  8006ec:	6a 0a                	push   $0xa
  8006ee:	68 8f 1e 80 00       	push   $0x801e8f
  8006f3:	6a 23                	push   $0x23
  8006f5:	68 ac 1e 80 00       	push   $0x801eac
  8006fa:	e8 9f 0d 00 00       	call   80149e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80070d:	be 00 00 00 00       	mov    $0x0,%esi
  800712:	b8 0c 00 00 00       	mov    $0xc,%eax
  800717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071a:	8b 55 08             	mov    0x8(%ebp),%edx
  80071d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800720:	8b 7d 14             	mov    0x14(%ebp),%edi
  800723:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	57                   	push   %edi
  80072e:	56                   	push   %esi
  80072f:	53                   	push   %ebx
  800730:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	b8 0d 00 00 00       	mov    $0xd,%eax
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
  800740:	89 cb                	mov    %ecx,%ebx
  800742:	89 cf                	mov    %ecx,%edi
  800744:	89 ce                	mov    %ecx,%esi
  800746:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800748:	85 c0                	test   %eax,%eax
  80074a:	7e 17                	jle    800763 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80074c:	83 ec 0c             	sub    $0xc,%esp
  80074f:	50                   	push   %eax
  800750:	6a 0d                	push   $0xd
  800752:	68 8f 1e 80 00       	push   $0x801e8f
  800757:	6a 23                	push   $0x23
  800759:	68 ac 1e 80 00       	push   $0x801eac
  80075e:	e8 3b 0d 00 00       	call   80149e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5f                   	pop    %edi
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	05 00 00 00 30       	add    $0x30000000,%eax
  800776:	c1 e8 0c             	shr    $0xc,%eax
}
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	05 00 00 00 30       	add    $0x30000000,%eax
  800786:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80078b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800798:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	c1 ea 16             	shr    $0x16,%edx
  8007a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007a9:	f6 c2 01             	test   $0x1,%dl
  8007ac:	74 11                	je     8007bf <fd_alloc+0x2d>
  8007ae:	89 c2                	mov    %eax,%edx
  8007b0:	c1 ea 0c             	shr    $0xc,%edx
  8007b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007ba:	f6 c2 01             	test   $0x1,%dl
  8007bd:	75 09                	jne    8007c8 <fd_alloc+0x36>
			*fd_store = fd;
  8007bf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c6:	eb 17                	jmp    8007df <fd_alloc+0x4d>
  8007c8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8007cd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007d2:	75 c9                	jne    80079d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007d4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8007da:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8007e7:	83 f8 1f             	cmp    $0x1f,%eax
  8007ea:	77 36                	ja     800822 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8007ec:	c1 e0 0c             	shl    $0xc,%eax
  8007ef:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	c1 ea 16             	shr    $0x16,%edx
  8007f9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800800:	f6 c2 01             	test   $0x1,%dl
  800803:	74 24                	je     800829 <fd_lookup+0x48>
  800805:	89 c2                	mov    %eax,%edx
  800807:	c1 ea 0c             	shr    $0xc,%edx
  80080a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800811:	f6 c2 01             	test   $0x1,%dl
  800814:	74 1a                	je     800830 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	89 02                	mov    %eax,(%edx)
	return 0;
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	eb 13                	jmp    800835 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800827:	eb 0c                	jmp    800835 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800829:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082e:	eb 05                	jmp    800835 <fd_lookup+0x54>
  800830:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800840:	ba 38 1f 80 00       	mov    $0x801f38,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800845:	eb 13                	jmp    80085a <dev_lookup+0x23>
  800847:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80084a:	39 08                	cmp    %ecx,(%eax)
  80084c:	75 0c                	jne    80085a <dev_lookup+0x23>
			*dev = devtab[i];
  80084e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800851:	89 01                	mov    %eax,(%ecx)
			return 0;
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	eb 2e                	jmp    800888 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80085a:	8b 02                	mov    (%edx),%eax
  80085c:	85 c0                	test   %eax,%eax
  80085e:	75 e7                	jne    800847 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800860:	a1 04 40 80 00       	mov    0x804004,%eax
  800865:	8b 40 48             	mov    0x48(%eax),%eax
  800868:	83 ec 04             	sub    $0x4,%esp
  80086b:	51                   	push   %ecx
  80086c:	50                   	push   %eax
  80086d:	68 bc 1e 80 00       	push   $0x801ebc
  800872:	e8 00 0d 00 00       	call   801577 <cprintf>
	*dev = 0;
  800877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800880:	83 c4 10             	add    $0x10,%esp
  800883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	83 ec 10             	sub    $0x10,%esp
  800892:	8b 75 08             	mov    0x8(%ebp),%esi
  800895:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800898:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089b:	50                   	push   %eax
  80089c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008a2:	c1 e8 0c             	shr    $0xc,%eax
  8008a5:	50                   	push   %eax
  8008a6:	e8 36 ff ff ff       	call   8007e1 <fd_lookup>
  8008ab:	83 c4 08             	add    $0x8,%esp
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 05                	js     8008b7 <fd_close+0x2d>
	    || fd != fd2)
  8008b2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008b5:	74 0c                	je     8008c3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8008b7:	84 db                	test   %bl,%bl
  8008b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008be:	0f 44 c2             	cmove  %edx,%eax
  8008c1:	eb 41                	jmp    800904 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c9:	50                   	push   %eax
  8008ca:	ff 36                	pushl  (%esi)
  8008cc:	e8 66 ff ff ff       	call   800837 <dev_lookup>
  8008d1:	89 c3                	mov    %eax,%ebx
  8008d3:	83 c4 10             	add    $0x10,%esp
  8008d6:	85 c0                	test   %eax,%eax
  8008d8:	78 1a                	js     8008f4 <fd_close+0x6a>
		if (dev->dev_close)
  8008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008dd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8008e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8008e5:	85 c0                	test   %eax,%eax
  8008e7:	74 0b                	je     8008f4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8008e9:	83 ec 0c             	sub    $0xc,%esp
  8008ec:	56                   	push   %esi
  8008ed:	ff d0                	call   *%eax
  8008ef:	89 c3                	mov    %eax,%ebx
  8008f1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	56                   	push   %esi
  8008f8:	6a 00                	push   $0x0
  8008fa:	e8 00 fd ff ff       	call   8005ff <sys_page_unmap>
	return r;
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	89 d8                	mov    %ebx,%eax
}
  800904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800911:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800914:	50                   	push   %eax
  800915:	ff 75 08             	pushl  0x8(%ebp)
  800918:	e8 c4 fe ff ff       	call   8007e1 <fd_lookup>
  80091d:	83 c4 08             	add    $0x8,%esp
  800920:	85 c0                	test   %eax,%eax
  800922:	78 10                	js     800934 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800924:	83 ec 08             	sub    $0x8,%esp
  800927:	6a 01                	push   $0x1
  800929:	ff 75 f4             	pushl  -0xc(%ebp)
  80092c:	e8 59 ff ff ff       	call   80088a <fd_close>
  800931:	83 c4 10             	add    $0x10,%esp
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <close_all>:

void
close_all(void)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80093d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800942:	83 ec 0c             	sub    $0xc,%esp
  800945:	53                   	push   %ebx
  800946:	e8 c0 ff ff ff       	call   80090b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80094b:	83 c3 01             	add    $0x1,%ebx
  80094e:	83 c4 10             	add    $0x10,%esp
  800951:	83 fb 20             	cmp    $0x20,%ebx
  800954:	75 ec                	jne    800942 <close_all+0xc>
		close(i);
}
  800956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	57                   	push   %edi
  80095f:	56                   	push   %esi
  800960:	53                   	push   %ebx
  800961:	83 ec 2c             	sub    $0x2c,%esp
  800964:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800967:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80096a:	50                   	push   %eax
  80096b:	ff 75 08             	pushl  0x8(%ebp)
  80096e:	e8 6e fe ff ff       	call   8007e1 <fd_lookup>
  800973:	83 c4 08             	add    $0x8,%esp
  800976:	85 c0                	test   %eax,%eax
  800978:	0f 88 c1 00 00 00    	js     800a3f <dup+0xe4>
		return r;
	close(newfdnum);
  80097e:	83 ec 0c             	sub    $0xc,%esp
  800981:	56                   	push   %esi
  800982:	e8 84 ff ff ff       	call   80090b <close>

	newfd = INDEX2FD(newfdnum);
  800987:	89 f3                	mov    %esi,%ebx
  800989:	c1 e3 0c             	shl    $0xc,%ebx
  80098c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800992:	83 c4 04             	add    $0x4,%esp
  800995:	ff 75 e4             	pushl  -0x1c(%ebp)
  800998:	e8 de fd ff ff       	call   80077b <fd2data>
  80099d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80099f:	89 1c 24             	mov    %ebx,(%esp)
  8009a2:	e8 d4 fd ff ff       	call   80077b <fd2data>
  8009a7:	83 c4 10             	add    $0x10,%esp
  8009aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	c1 e8 16             	shr    $0x16,%eax
  8009b2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009b9:	a8 01                	test   $0x1,%al
  8009bb:	74 37                	je     8009f4 <dup+0x99>
  8009bd:	89 f8                	mov    %edi,%eax
  8009bf:	c1 e8 0c             	shr    $0xc,%eax
  8009c2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009c9:	f6 c2 01             	test   $0x1,%dl
  8009cc:	74 26                	je     8009f4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8009ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009d5:	83 ec 0c             	sub    $0xc,%esp
  8009d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8009dd:	50                   	push   %eax
  8009de:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009e1:	6a 00                	push   $0x0
  8009e3:	57                   	push   %edi
  8009e4:	6a 00                	push   $0x0
  8009e6:	e8 d2 fb ff ff       	call   8005bd <sys_page_map>
  8009eb:	89 c7                	mov    %eax,%edi
  8009ed:	83 c4 20             	add    $0x20,%esp
  8009f0:	85 c0                	test   %eax,%eax
  8009f2:	78 2e                	js     800a22 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009f7:	89 d0                	mov    %edx,%eax
  8009f9:	c1 e8 0c             	shr    $0xc,%eax
  8009fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a03:	83 ec 0c             	sub    $0xc,%esp
  800a06:	25 07 0e 00 00       	and    $0xe07,%eax
  800a0b:	50                   	push   %eax
  800a0c:	53                   	push   %ebx
  800a0d:	6a 00                	push   $0x0
  800a0f:	52                   	push   %edx
  800a10:	6a 00                	push   $0x0
  800a12:	e8 a6 fb ff ff       	call   8005bd <sys_page_map>
  800a17:	89 c7                	mov    %eax,%edi
  800a19:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a1c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a1e:	85 ff                	test   %edi,%edi
  800a20:	79 1d                	jns    800a3f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a22:	83 ec 08             	sub    $0x8,%esp
  800a25:	53                   	push   %ebx
  800a26:	6a 00                	push   $0x0
  800a28:	e8 d2 fb ff ff       	call   8005ff <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a2d:	83 c4 08             	add    $0x8,%esp
  800a30:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a33:	6a 00                	push   $0x0
  800a35:	e8 c5 fb ff ff       	call   8005ff <sys_page_unmap>
	return r;
  800a3a:	83 c4 10             	add    $0x10,%esp
  800a3d:	89 f8                	mov    %edi,%eax
}
  800a3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	53                   	push   %ebx
  800a4b:	83 ec 14             	sub    $0x14,%esp
  800a4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a54:	50                   	push   %eax
  800a55:	53                   	push   %ebx
  800a56:	e8 86 fd ff ff       	call   8007e1 <fd_lookup>
  800a5b:	83 c4 08             	add    $0x8,%esp
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	85 c0                	test   %eax,%eax
  800a62:	78 6d                	js     800ad1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a64:	83 ec 08             	sub    $0x8,%esp
  800a67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a6a:	50                   	push   %eax
  800a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a6e:	ff 30                	pushl  (%eax)
  800a70:	e8 c2 fd ff ff       	call   800837 <dev_lookup>
  800a75:	83 c4 10             	add    $0x10,%esp
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	78 4c                	js     800ac8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a7f:	8b 42 08             	mov    0x8(%edx),%eax
  800a82:	83 e0 03             	and    $0x3,%eax
  800a85:	83 f8 01             	cmp    $0x1,%eax
  800a88:	75 21                	jne    800aab <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a8a:	a1 04 40 80 00       	mov    0x804004,%eax
  800a8f:	8b 40 48             	mov    0x48(%eax),%eax
  800a92:	83 ec 04             	sub    $0x4,%esp
  800a95:	53                   	push   %ebx
  800a96:	50                   	push   %eax
  800a97:	68 fd 1e 80 00       	push   $0x801efd
  800a9c:	e8 d6 0a 00 00       	call   801577 <cprintf>
		return -E_INVAL;
  800aa1:	83 c4 10             	add    $0x10,%esp
  800aa4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800aa9:	eb 26                	jmp    800ad1 <read+0x8a>
	}
	if (!dev->dev_read)
  800aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aae:	8b 40 08             	mov    0x8(%eax),%eax
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	74 17                	je     800acc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800ab5:	83 ec 04             	sub    $0x4,%esp
  800ab8:	ff 75 10             	pushl  0x10(%ebp)
  800abb:	ff 75 0c             	pushl  0xc(%ebp)
  800abe:	52                   	push   %edx
  800abf:	ff d0                	call   *%eax
  800ac1:	89 c2                	mov    %eax,%edx
  800ac3:	83 c4 10             	add    $0x10,%esp
  800ac6:	eb 09                	jmp    800ad1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ac8:	89 c2                	mov    %eax,%edx
  800aca:	eb 05                	jmp    800ad1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800acc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800ad1:	89 d0                	mov    %edx,%eax
  800ad3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ad6:	c9                   	leave  
  800ad7:	c3                   	ret    

00800ad8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800ae7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aec:	eb 21                	jmp    800b0f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800aee:	83 ec 04             	sub    $0x4,%esp
  800af1:	89 f0                	mov    %esi,%eax
  800af3:	29 d8                	sub    %ebx,%eax
  800af5:	50                   	push   %eax
  800af6:	89 d8                	mov    %ebx,%eax
  800af8:	03 45 0c             	add    0xc(%ebp),%eax
  800afb:	50                   	push   %eax
  800afc:	57                   	push   %edi
  800afd:	e8 45 ff ff ff       	call   800a47 <read>
		if (m < 0)
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	85 c0                	test   %eax,%eax
  800b07:	78 10                	js     800b19 <readn+0x41>
			return m;
		if (m == 0)
  800b09:	85 c0                	test   %eax,%eax
  800b0b:	74 0a                	je     800b17 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b0d:	01 c3                	add    %eax,%ebx
  800b0f:	39 f3                	cmp    %esi,%ebx
  800b11:	72 db                	jb     800aee <readn+0x16>
  800b13:	89 d8                	mov    %ebx,%eax
  800b15:	eb 02                	jmp    800b19 <readn+0x41>
  800b17:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	53                   	push   %ebx
  800b25:	83 ec 14             	sub    $0x14,%esp
  800b28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b2e:	50                   	push   %eax
  800b2f:	53                   	push   %ebx
  800b30:	e8 ac fc ff ff       	call   8007e1 <fd_lookup>
  800b35:	83 c4 08             	add    $0x8,%esp
  800b38:	89 c2                	mov    %eax,%edx
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	78 68                	js     800ba6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b3e:	83 ec 08             	sub    $0x8,%esp
  800b41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b44:	50                   	push   %eax
  800b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b48:	ff 30                	pushl  (%eax)
  800b4a:	e8 e8 fc ff ff       	call   800837 <dev_lookup>
  800b4f:	83 c4 10             	add    $0x10,%esp
  800b52:	85 c0                	test   %eax,%eax
  800b54:	78 47                	js     800b9d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b59:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b5d:	75 21                	jne    800b80 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b5f:	a1 04 40 80 00       	mov    0x804004,%eax
  800b64:	8b 40 48             	mov    0x48(%eax),%eax
  800b67:	83 ec 04             	sub    $0x4,%esp
  800b6a:	53                   	push   %ebx
  800b6b:	50                   	push   %eax
  800b6c:	68 19 1f 80 00       	push   $0x801f19
  800b71:	e8 01 0a 00 00       	call   801577 <cprintf>
		return -E_INVAL;
  800b76:	83 c4 10             	add    $0x10,%esp
  800b79:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b7e:	eb 26                	jmp    800ba6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b83:	8b 52 0c             	mov    0xc(%edx),%edx
  800b86:	85 d2                	test   %edx,%edx
  800b88:	74 17                	je     800ba1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b8a:	83 ec 04             	sub    $0x4,%esp
  800b8d:	ff 75 10             	pushl  0x10(%ebp)
  800b90:	ff 75 0c             	pushl  0xc(%ebp)
  800b93:	50                   	push   %eax
  800b94:	ff d2                	call   *%edx
  800b96:	89 c2                	mov    %eax,%edx
  800b98:	83 c4 10             	add    $0x10,%esp
  800b9b:	eb 09                	jmp    800ba6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b9d:	89 c2                	mov    %eax,%edx
  800b9f:	eb 05                	jmp    800ba6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ba1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ba6:	89 d0                	mov    %edx,%eax
  800ba8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <seek>:

int
seek(int fdnum, off_t offset)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bb3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800bb6:	50                   	push   %eax
  800bb7:	ff 75 08             	pushl  0x8(%ebp)
  800bba:	e8 22 fc ff ff       	call   8007e1 <fd_lookup>
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	78 0e                	js     800bd4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800bc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 14             	sub    $0x14,%esp
  800bdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800be0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800be3:	50                   	push   %eax
  800be4:	53                   	push   %ebx
  800be5:	e8 f7 fb ff ff       	call   8007e1 <fd_lookup>
  800bea:	83 c4 08             	add    $0x8,%esp
  800bed:	89 c2                	mov    %eax,%edx
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	78 65                	js     800c58 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bf3:	83 ec 08             	sub    $0x8,%esp
  800bf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf9:	50                   	push   %eax
  800bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bfd:	ff 30                	pushl  (%eax)
  800bff:	e8 33 fc ff ff       	call   800837 <dev_lookup>
  800c04:	83 c4 10             	add    $0x10,%esp
  800c07:	85 c0                	test   %eax,%eax
  800c09:	78 44                	js     800c4f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c0e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c12:	75 21                	jne    800c35 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c14:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c19:	8b 40 48             	mov    0x48(%eax),%eax
  800c1c:	83 ec 04             	sub    $0x4,%esp
  800c1f:	53                   	push   %ebx
  800c20:	50                   	push   %eax
  800c21:	68 dc 1e 80 00       	push   $0x801edc
  800c26:	e8 4c 09 00 00       	call   801577 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c33:	eb 23                	jmp    800c58 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800c35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c38:	8b 52 18             	mov    0x18(%edx),%edx
  800c3b:	85 d2                	test   %edx,%edx
  800c3d:	74 14                	je     800c53 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c3f:	83 ec 08             	sub    $0x8,%esp
  800c42:	ff 75 0c             	pushl  0xc(%ebp)
  800c45:	50                   	push   %eax
  800c46:	ff d2                	call   *%edx
  800c48:	89 c2                	mov    %eax,%edx
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	eb 09                	jmp    800c58 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c4f:	89 c2                	mov    %eax,%edx
  800c51:	eb 05                	jmp    800c58 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c53:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800c58:	89 d0                	mov    %edx,%eax
  800c5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	53                   	push   %ebx
  800c63:	83 ec 14             	sub    $0x14,%esp
  800c66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c6c:	50                   	push   %eax
  800c6d:	ff 75 08             	pushl  0x8(%ebp)
  800c70:	e8 6c fb ff ff       	call   8007e1 <fd_lookup>
  800c75:	83 c4 08             	add    $0x8,%esp
  800c78:	89 c2                	mov    %eax,%edx
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	78 58                	js     800cd6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c7e:	83 ec 08             	sub    $0x8,%esp
  800c81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c84:	50                   	push   %eax
  800c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c88:	ff 30                	pushl  (%eax)
  800c8a:	e8 a8 fb ff ff       	call   800837 <dev_lookup>
  800c8f:	83 c4 10             	add    $0x10,%esp
  800c92:	85 c0                	test   %eax,%eax
  800c94:	78 37                	js     800ccd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c99:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c9d:	74 32                	je     800cd1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c9f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800ca2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ca9:	00 00 00 
	stat->st_isdir = 0;
  800cac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cb3:	00 00 00 
	stat->st_dev = dev;
  800cb6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800cbc:	83 ec 08             	sub    $0x8,%esp
  800cbf:	53                   	push   %ebx
  800cc0:	ff 75 f0             	pushl  -0x10(%ebp)
  800cc3:	ff 50 14             	call   *0x14(%eax)
  800cc6:	89 c2                	mov    %eax,%edx
  800cc8:	83 c4 10             	add    $0x10,%esp
  800ccb:	eb 09                	jmp    800cd6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ccd:	89 c2                	mov    %eax,%edx
  800ccf:	eb 05                	jmp    800cd6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800cd1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800cd6:	89 d0                	mov    %edx,%eax
  800cd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ce2:	83 ec 08             	sub    $0x8,%esp
  800ce5:	6a 00                	push   $0x0
  800ce7:	ff 75 08             	pushl  0x8(%ebp)
  800cea:	e8 2c 02 00 00       	call   800f1b <open>
  800cef:	89 c3                	mov    %eax,%ebx
  800cf1:	83 c4 10             	add    $0x10,%esp
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	78 1b                	js     800d13 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800cf8:	83 ec 08             	sub    $0x8,%esp
  800cfb:	ff 75 0c             	pushl  0xc(%ebp)
  800cfe:	50                   	push   %eax
  800cff:	e8 5b ff ff ff       	call   800c5f <fstat>
  800d04:	89 c6                	mov    %eax,%esi
	close(fd);
  800d06:	89 1c 24             	mov    %ebx,(%esp)
  800d09:	e8 fd fb ff ff       	call   80090b <close>
	return r;
  800d0e:	83 c4 10             	add    $0x10,%esp
  800d11:	89 f0                	mov    %esi,%eax
}
  800d13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
	   static int
fsipc(unsigned type, void *dstva)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	89 c6                	mov    %eax,%esi
  800d21:	89 d3                	mov    %edx,%ebx
	   static envid_t fsenv;
	   if (fsenv == 0)
  800d23:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d2a:	75 12                	jne    800d3e <fsipc+0x24>
			 fsenv = ipc_find_env(ENV_TYPE_FS);
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	6a 01                	push   $0x1
  800d31:	e8 40 0e 00 00       	call   801b76 <ipc_find_env>
  800d36:	a3 00 40 80 00       	mov    %eax,0x804000
  800d3b:	83 c4 10             	add    $0x10,%esp
	   static_assert(sizeof(fsipcbuf) == PGSIZE);

	   if (debug)
			 cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	   ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d3e:	6a 07                	push   $0x7
  800d40:	68 00 50 80 00       	push   $0x805000
  800d45:	56                   	push   %esi
  800d46:	ff 35 00 40 80 00    	pushl  0x804000
  800d4c:	e8 d1 0d 00 00       	call   801b22 <ipc_send>
	   return ipc_recv(NULL, dstva, NULL);
  800d51:	83 c4 0c             	add    $0xc,%esp
  800d54:	6a 00                	push   $0x0
  800d56:	53                   	push   %ebx
  800d57:	6a 00                	push   $0x0
  800d59:	e8 65 0d 00 00       	call   801ac3 <ipc_recv>
}
  800d5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
	   static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	8b 40 0c             	mov    0xc(%eax),%eax
  800d71:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.set_size.req_size = newsize;
  800d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d79:	a3 04 50 80 00       	mov    %eax,0x805004
	   return fsipc(FSREQ_SET_SIZE, NULL);
  800d7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d83:	b8 02 00 00 00       	mov    $0x2,%eax
  800d88:	e8 8d ff ff ff       	call   800d1a <fsipc>
}
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
	   static int
devfile_flush(struct Fd *fd)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 08             	sub    $0x8,%esp
	   fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d95:	8b 45 08             	mov    0x8(%ebp),%eax
  800d98:	8b 40 0c             	mov    0xc(%eax),%eax
  800d9b:	a3 00 50 80 00       	mov    %eax,0x805000
	   return fsipc(FSREQ_FLUSH, NULL);
  800da0:	ba 00 00 00 00       	mov    $0x0,%edx
  800da5:	b8 06 00 00 00       	mov    $0x6,%eax
  800daa:	e8 6b ff ff ff       	call   800d1a <fsipc>
}
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <devfile_stat>:
	   //panic("devfile_write not implemented");
}

	   static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	53                   	push   %ebx
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   int r;

	   fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	8b 40 0c             	mov    0xc(%eax),%eax
  800dc1:	a3 00 50 80 00       	mov    %eax,0x805000
	   if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800dc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcb:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd0:	e8 45 ff ff ff       	call   800d1a <fsipc>
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	78 2c                	js     800e05 <devfile_stat+0x54>
			 return r;
	   strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800dd9:	83 ec 08             	sub    $0x8,%esp
  800ddc:	68 00 50 80 00       	push   $0x805000
  800de1:	53                   	push   %ebx
  800de2:	e8 90 f3 ff ff       	call   800177 <strcpy>
	   st->st_size = fsipcbuf.statRet.ret_size;
  800de7:	a1 80 50 80 00       	mov    0x805080,%eax
  800dec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	   st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800df2:	a1 84 50 80 00       	mov    0x805084,%eax
  800df7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	   return 0;
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e08:	c9                   	leave  
  800e09:	c3                   	ret    

00800e0a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
	   static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 08             	sub    $0x8,%esp
  800e11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // careful: fsipcbuf.write.req_buf is only so large, but
	   // remember that write is always allowed to write *fewer*
	   // bytes than requested.
	   // LAB 5: Your code here

	   fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	8b 40 0c             	mov    0xc(%eax),%eax
  800e1a:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.write.req_n = n;
  800e1f:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	   int bytes_written = sizeof(fsipcbuf.write.req_buf);
	   memmove (fsipcbuf.write.req_buf, buf, MIN(bytes_written, n));
  800e25:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800e2b:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800e30:	0f 46 c3             	cmovbe %ebx,%eax
  800e33:	50                   	push   %eax
  800e34:	ff 75 0c             	pushl  0xc(%ebp)
  800e37:	68 08 50 80 00       	push   $0x805008
  800e3c:	e8 c8 f4 ff ff       	call   800309 <memmove>
	   int r;

	   if ((r = fsipc (FSREQ_WRITE, NULL)) < 0)
  800e41:	ba 00 00 00 00       	mov    $0x0,%edx
  800e46:	b8 04 00 00 00       	mov    $0x4,%eax
  800e4b:	e8 ca fe ff ff       	call   800d1a <fsipc>
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	78 3d                	js     800e94 <devfile_write+0x8a>
			 return r;

	   assert (r <= n);
  800e57:	39 c3                	cmp    %eax,%ebx
  800e59:	73 19                	jae    800e74 <devfile_write+0x6a>
  800e5b:	68 48 1f 80 00       	push   $0x801f48
  800e60:	68 4f 1f 80 00       	push   $0x801f4f
  800e65:	68 9a 00 00 00       	push   $0x9a
  800e6a:	68 64 1f 80 00       	push   $0x801f64
  800e6f:	e8 2a 06 00 00       	call   80149e <_panic>
	   assert (r <= bytes_written);
  800e74:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800e79:	7e 19                	jle    800e94 <devfile_write+0x8a>
  800e7b:	68 6f 1f 80 00       	push   $0x801f6f
  800e80:	68 4f 1f 80 00       	push   $0x801f4f
  800e85:	68 9b 00 00 00       	push   $0x9b
  800e8a:	68 64 1f 80 00       	push   $0x801f64
  800e8f:	e8 0a 06 00 00       	call   80149e <_panic>

	   return r;

	   //panic("devfile_write not implemented");
}
  800e94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e97:	c9                   	leave  
  800e98:	c3                   	ret    

00800e99 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
	   static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	8b 75 10             	mov    0x10(%ebp),%esi
	   // filling fsipcbuf.read with the request arguments.  The
	   // bytes read will be written back to fsipcbuf by the file
	   // system server.
	   int r;

	   fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea4:	8b 40 0c             	mov    0xc(%eax),%eax
  800ea7:	a3 00 50 80 00       	mov    %eax,0x805000
	   fsipcbuf.read.req_n = n;
  800eac:	89 35 04 50 80 00    	mov    %esi,0x805004
	   if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800eb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb7:	b8 03 00 00 00       	mov    $0x3,%eax
  800ebc:	e8 59 fe ff ff       	call   800d1a <fsipc>
  800ec1:	89 c3                	mov    %eax,%ebx
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	78 4b                	js     800f12 <devfile_read+0x79>
			 return r;
	   assert(r <= n);
  800ec7:	39 c6                	cmp    %eax,%esi
  800ec9:	73 16                	jae    800ee1 <devfile_read+0x48>
  800ecb:	68 48 1f 80 00       	push   $0x801f48
  800ed0:	68 4f 1f 80 00       	push   $0x801f4f
  800ed5:	6a 7c                	push   $0x7c
  800ed7:	68 64 1f 80 00       	push   $0x801f64
  800edc:	e8 bd 05 00 00       	call   80149e <_panic>
	   assert(r <= PGSIZE);
  800ee1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ee6:	7e 16                	jle    800efe <devfile_read+0x65>
  800ee8:	68 82 1f 80 00       	push   $0x801f82
  800eed:	68 4f 1f 80 00       	push   $0x801f4f
  800ef2:	6a 7d                	push   $0x7d
  800ef4:	68 64 1f 80 00       	push   $0x801f64
  800ef9:	e8 a0 05 00 00       	call   80149e <_panic>
	   memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800efe:	83 ec 04             	sub    $0x4,%esp
  800f01:	50                   	push   %eax
  800f02:	68 00 50 80 00       	push   $0x805000
  800f07:	ff 75 0c             	pushl  0xc(%ebp)
  800f0a:	e8 fa f3 ff ff       	call   800309 <memmove>
	   return r;
  800f0f:	83 c4 10             	add    $0x10,%esp
}
  800f12:	89 d8                	mov    %ebx,%eax
  800f14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
	   int
open(const char *path, int mode)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 20             	sub    $0x20,%esp
  800f22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // file descriptor.

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
  800f25:	53                   	push   %ebx
  800f26:	e8 13 f2 ff ff       	call   80013e <strlen>
  800f2b:	83 c4 10             	add    $0x10,%esp
  800f2e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f33:	7f 67                	jg     800f9c <open+0x81>
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800f35:	83 ec 0c             	sub    $0xc,%esp
  800f38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3b:	50                   	push   %eax
  800f3c:	e8 51 f8 ff ff       	call   800792 <fd_alloc>
  800f41:	83 c4 10             	add    $0x10,%esp
			 return r;
  800f44:	89 c2                	mov    %eax,%edx
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;

	   if ((r = fd_alloc(&fd)) < 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 57                	js     800fa1 <open+0x86>
			 return r;

	   strcpy(fsipcbuf.open.req_path, path);
  800f4a:	83 ec 08             	sub    $0x8,%esp
  800f4d:	53                   	push   %ebx
  800f4e:	68 00 50 80 00       	push   $0x805000
  800f53:	e8 1f f2 ff ff       	call   800177 <strcpy>
	   fsipcbuf.open.req_omode = mode;
  800f58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5b:	a3 00 54 80 00       	mov    %eax,0x805400

	   if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f60:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f63:	b8 01 00 00 00       	mov    $0x1,%eax
  800f68:	e8 ad fd ff ff       	call   800d1a <fsipc>
  800f6d:	89 c3                	mov    %eax,%ebx
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	79 14                	jns    800f8a <open+0x6f>
			 fd_close(fd, 0);
  800f76:	83 ec 08             	sub    $0x8,%esp
  800f79:	6a 00                	push   $0x0
  800f7b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f7e:	e8 07 f9 ff ff       	call   80088a <fd_close>
			 return r;
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	89 da                	mov    %ebx,%edx
  800f88:	eb 17                	jmp    800fa1 <open+0x86>
	   }

	   return fd2num(fd);
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f90:	e8 d6 f7 ff ff       	call   80076b <fd2num>
  800f95:	89 c2                	mov    %eax,%edx
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	eb 05                	jmp    800fa1 <open+0x86>

	   int r;
	   struct Fd *fd;

	   if (strlen(path) >= MAXPATHLEN)
			 return -E_BAD_PATH;
  800f9c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
			 fd_close(fd, 0);
			 return r;
	   }

	   return fd2num(fd);
}
  800fa1:	89 d0                	mov    %edx,%eax
  800fa3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <sync>:


// Synchronize disk with buffer cache
	   int
sync(void)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	83 ec 08             	sub    $0x8,%esp
	   // Ask the file server to update the disk
	   // by writing any dirty blocks in the buffer cache.

	   return fsipc(FSREQ_SYNC, NULL);
  800fae:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb3:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb8:	e8 5d fd ff ff       	call   800d1a <fsipc>
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    

00800fbf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
  800fc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	ff 75 08             	pushl  0x8(%ebp)
  800fcd:	e8 a9 f7 ff ff       	call   80077b <fd2data>
  800fd2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800fd4:	83 c4 08             	add    $0x8,%esp
  800fd7:	68 8e 1f 80 00       	push   $0x801f8e
  800fdc:	53                   	push   %ebx
  800fdd:	e8 95 f1 ff ff       	call   800177 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800fe2:	8b 46 04             	mov    0x4(%esi),%eax
  800fe5:	2b 06                	sub    (%esi),%eax
  800fe7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800fed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ff4:	00 00 00 
	stat->st_dev = &devpipe;
  800ff7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ffe:	30 80 00 
	return 0;
}
  801001:	b8 00 00 00 00       	mov    $0x0,%eax
  801006:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801009:	5b                   	pop    %ebx
  80100a:	5e                   	pop    %esi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	53                   	push   %ebx
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801017:	53                   	push   %ebx
  801018:	6a 00                	push   $0x0
  80101a:	e8 e0 f5 ff ff       	call   8005ff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80101f:	89 1c 24             	mov    %ebx,(%esp)
  801022:	e8 54 f7 ff ff       	call   80077b <fd2data>
  801027:	83 c4 08             	add    $0x8,%esp
  80102a:	50                   	push   %eax
  80102b:	6a 00                	push   $0x0
  80102d:	e8 cd f5 ff ff       	call   8005ff <sys_page_unmap>
}
  801032:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	57                   	push   %edi
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	83 ec 1c             	sub    $0x1c,%esp
  801040:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801043:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801045:	a1 04 40 80 00       	mov    0x804004,%eax
  80104a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	ff 75 e0             	pushl  -0x20(%ebp)
  801053:	e8 57 0b 00 00       	call   801baf <pageref>
  801058:	89 c3                	mov    %eax,%ebx
  80105a:	89 3c 24             	mov    %edi,(%esp)
  80105d:	e8 4d 0b 00 00       	call   801baf <pageref>
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	39 c3                	cmp    %eax,%ebx
  801067:	0f 94 c1             	sete   %cl
  80106a:	0f b6 c9             	movzbl %cl,%ecx
  80106d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801070:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801076:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801079:	39 ce                	cmp    %ecx,%esi
  80107b:	74 1b                	je     801098 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80107d:	39 c3                	cmp    %eax,%ebx
  80107f:	75 c4                	jne    801045 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801081:	8b 42 58             	mov    0x58(%edx),%eax
  801084:	ff 75 e4             	pushl  -0x1c(%ebp)
  801087:	50                   	push   %eax
  801088:	56                   	push   %esi
  801089:	68 95 1f 80 00       	push   $0x801f95
  80108e:	e8 e4 04 00 00       	call   801577 <cprintf>
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	eb ad                	jmp    801045 <_pipeisclosed+0xe>
	}
}
  801098:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80109b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 28             	sub    $0x28,%esp
  8010ac:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010af:	56                   	push   %esi
  8010b0:	e8 c6 f6 ff ff       	call   80077b <fd2data>
  8010b5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8010bf:	eb 4b                	jmp    80110c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010c1:	89 da                	mov    %ebx,%edx
  8010c3:	89 f0                	mov    %esi,%eax
  8010c5:	e8 6d ff ff ff       	call   801037 <_pipeisclosed>
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	75 48                	jne    801116 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8010ce:	e8 88 f4 ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010d3:	8b 43 04             	mov    0x4(%ebx),%eax
  8010d6:	8b 0b                	mov    (%ebx),%ecx
  8010d8:	8d 51 20             	lea    0x20(%ecx),%edx
  8010db:	39 d0                	cmp    %edx,%eax
  8010dd:	73 e2                	jae    8010c1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8010e6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8010e9:	89 c2                	mov    %eax,%edx
  8010eb:	c1 fa 1f             	sar    $0x1f,%edx
  8010ee:	89 d1                	mov    %edx,%ecx
  8010f0:	c1 e9 1b             	shr    $0x1b,%ecx
  8010f3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8010f6:	83 e2 1f             	and    $0x1f,%edx
  8010f9:	29 ca                	sub    %ecx,%edx
  8010fb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8010ff:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801103:	83 c0 01             	add    $0x1,%eax
  801106:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801109:	83 c7 01             	add    $0x1,%edi
  80110c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80110f:	75 c2                	jne    8010d3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801111:	8b 45 10             	mov    0x10(%ebp),%eax
  801114:	eb 05                	jmp    80111b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801116:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	57                   	push   %edi
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
  801129:	83 ec 18             	sub    $0x18,%esp
  80112c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80112f:	57                   	push   %edi
  801130:	e8 46 f6 ff ff       	call   80077b <fd2data>
  801135:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113f:	eb 3d                	jmp    80117e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801141:	85 db                	test   %ebx,%ebx
  801143:	74 04                	je     801149 <devpipe_read+0x26>
				return i;
  801145:	89 d8                	mov    %ebx,%eax
  801147:	eb 44                	jmp    80118d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801149:	89 f2                	mov    %esi,%edx
  80114b:	89 f8                	mov    %edi,%eax
  80114d:	e8 e5 fe ff ff       	call   801037 <_pipeisclosed>
  801152:	85 c0                	test   %eax,%eax
  801154:	75 32                	jne    801188 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801156:	e8 00 f4 ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80115b:	8b 06                	mov    (%esi),%eax
  80115d:	3b 46 04             	cmp    0x4(%esi),%eax
  801160:	74 df                	je     801141 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801162:	99                   	cltd   
  801163:	c1 ea 1b             	shr    $0x1b,%edx
  801166:	01 d0                	add    %edx,%eax
  801168:	83 e0 1f             	and    $0x1f,%eax
  80116b:	29 d0                	sub    %edx,%eax
  80116d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801172:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801175:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801178:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80117b:	83 c3 01             	add    $0x1,%ebx
  80117e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801181:	75 d8                	jne    80115b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801183:	8b 45 10             	mov    0x10(%ebp),%eax
  801186:	eb 05                	jmp    80118d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801188:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80118d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801190:	5b                   	pop    %ebx
  801191:	5e                   	pop    %esi
  801192:	5f                   	pop    %edi
  801193:	5d                   	pop    %ebp
  801194:	c3                   	ret    

00801195 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	56                   	push   %esi
  801199:	53                   	push   %ebx
  80119a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80119d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a0:	50                   	push   %eax
  8011a1:	e8 ec f5 ff ff       	call   800792 <fd_alloc>
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	0f 88 2c 01 00 00    	js     8012df <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	68 07 04 00 00       	push   $0x407
  8011bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8011be:	6a 00                	push   $0x0
  8011c0:	e8 b5 f3 ff ff       	call   80057a <sys_page_alloc>
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	0f 88 0d 01 00 00    	js     8012df <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011d2:	83 ec 0c             	sub    $0xc,%esp
  8011d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d8:	50                   	push   %eax
  8011d9:	e8 b4 f5 ff ff       	call   800792 <fd_alloc>
  8011de:	89 c3                	mov    %eax,%ebx
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	0f 88 e2 00 00 00    	js     8012cd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	68 07 04 00 00       	push   $0x407
  8011f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8011f6:	6a 00                	push   $0x0
  8011f8:	e8 7d f3 ff ff       	call   80057a <sys_page_alloc>
  8011fd:	89 c3                	mov    %eax,%ebx
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	85 c0                	test   %eax,%eax
  801204:	0f 88 c3 00 00 00    	js     8012cd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80120a:	83 ec 0c             	sub    $0xc,%esp
  80120d:	ff 75 f4             	pushl  -0xc(%ebp)
  801210:	e8 66 f5 ff ff       	call   80077b <fd2data>
  801215:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801217:	83 c4 0c             	add    $0xc,%esp
  80121a:	68 07 04 00 00       	push   $0x407
  80121f:	50                   	push   %eax
  801220:	6a 00                	push   $0x0
  801222:	e8 53 f3 ff ff       	call   80057a <sys_page_alloc>
  801227:	89 c3                	mov    %eax,%ebx
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	0f 88 89 00 00 00    	js     8012bd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801234:	83 ec 0c             	sub    $0xc,%esp
  801237:	ff 75 f0             	pushl  -0x10(%ebp)
  80123a:	e8 3c f5 ff ff       	call   80077b <fd2data>
  80123f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801246:	50                   	push   %eax
  801247:	6a 00                	push   $0x0
  801249:	56                   	push   %esi
  80124a:	6a 00                	push   $0x0
  80124c:	e8 6c f3 ff ff       	call   8005bd <sys_page_map>
  801251:	89 c3                	mov    %eax,%ebx
  801253:	83 c4 20             	add    $0x20,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	78 55                	js     8012af <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80125a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801260:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801263:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801265:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801268:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80126f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801275:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801278:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80127a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801284:	83 ec 0c             	sub    $0xc,%esp
  801287:	ff 75 f4             	pushl  -0xc(%ebp)
  80128a:	e8 dc f4 ff ff       	call   80076b <fd2num>
  80128f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801292:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801294:	83 c4 04             	add    $0x4,%esp
  801297:	ff 75 f0             	pushl  -0x10(%ebp)
  80129a:	e8 cc f4 ff ff       	call   80076b <fd2num>
  80129f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ad:	eb 30                	jmp    8012df <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012af:	83 ec 08             	sub    $0x8,%esp
  8012b2:	56                   	push   %esi
  8012b3:	6a 00                	push   $0x0
  8012b5:	e8 45 f3 ff ff       	call   8005ff <sys_page_unmap>
  8012ba:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012bd:	83 ec 08             	sub    $0x8,%esp
  8012c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c3:	6a 00                	push   $0x0
  8012c5:	e8 35 f3 ff ff       	call   8005ff <sys_page_unmap>
  8012ca:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012cd:	83 ec 08             	sub    $0x8,%esp
  8012d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d3:	6a 00                	push   $0x0
  8012d5:	e8 25 f3 ff ff       	call   8005ff <sys_page_unmap>
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8012df:	89 d0                	mov    %edx,%eax
  8012e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    

008012e8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f1:	50                   	push   %eax
  8012f2:	ff 75 08             	pushl  0x8(%ebp)
  8012f5:	e8 e7 f4 ff ff       	call   8007e1 <fd_lookup>
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	78 18                	js     801319 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801301:	83 ec 0c             	sub    $0xc,%esp
  801304:	ff 75 f4             	pushl  -0xc(%ebp)
  801307:	e8 6f f4 ff ff       	call   80077b <fd2data>
	return _pipeisclosed(fd, p);
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801311:	e8 21 fd ff ff       	call   801037 <_pipeisclosed>
  801316:	83 c4 10             	add    $0x10,%esp
}
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80131e:	b8 00 00 00 00       	mov    $0x0,%eax
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80132b:	68 ad 1f 80 00       	push   $0x801fad
  801330:	ff 75 0c             	pushl  0xc(%ebp)
  801333:	e8 3f ee ff ff       	call   800177 <strcpy>
	return 0;
}
  801338:	b8 00 00 00 00       	mov    $0x0,%eax
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	57                   	push   %edi
  801343:	56                   	push   %esi
  801344:	53                   	push   %ebx
  801345:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80134b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801350:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801356:	eb 2d                	jmp    801385 <devcons_write+0x46>
		m = n - tot;
  801358:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80135b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80135d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801360:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801365:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801368:	83 ec 04             	sub    $0x4,%esp
  80136b:	53                   	push   %ebx
  80136c:	03 45 0c             	add    0xc(%ebp),%eax
  80136f:	50                   	push   %eax
  801370:	57                   	push   %edi
  801371:	e8 93 ef ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  801376:	83 c4 08             	add    $0x8,%esp
  801379:	53                   	push   %ebx
  80137a:	57                   	push   %edi
  80137b:	e8 3e f1 ff ff       	call   8004be <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801380:	01 de                	add    %ebx,%esi
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	89 f0                	mov    %esi,%eax
  801387:	3b 75 10             	cmp    0x10(%ebp),%esi
  80138a:	72 cc                	jb     801358 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80138c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138f:	5b                   	pop    %ebx
  801390:	5e                   	pop    %esi
  801391:	5f                   	pop    %edi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80139f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013a3:	74 2a                	je     8013cf <devcons_read+0x3b>
  8013a5:	eb 05                	jmp    8013ac <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013a7:	e8 af f1 ff ff       	call   80055b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013ac:	e8 2b f1 ff ff       	call   8004dc <sys_cgetc>
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	74 f2                	je     8013a7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	78 16                	js     8013cf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013b9:	83 f8 04             	cmp    $0x4,%eax
  8013bc:	74 0c                	je     8013ca <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c1:	88 02                	mov    %al,(%edx)
	return 1;
  8013c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c8:	eb 05                	jmp    8013cf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013ca:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    

008013d1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013da:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013dd:	6a 01                	push   $0x1
  8013df:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	e8 d6 f0 ff ff       	call   8004be <sys_cputs>
}
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <getchar>:

int
getchar(void)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8013f3:	6a 01                	push   $0x1
  8013f5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013f8:	50                   	push   %eax
  8013f9:	6a 00                	push   $0x0
  8013fb:	e8 47 f6 ff ff       	call   800a47 <read>
	if (r < 0)
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	85 c0                	test   %eax,%eax
  801405:	78 0f                	js     801416 <getchar+0x29>
		return r;
	if (r < 1)
  801407:	85 c0                	test   %eax,%eax
  801409:	7e 06                	jle    801411 <getchar+0x24>
		return -E_EOF;
	return c;
  80140b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80140f:	eb 05                	jmp    801416 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801411:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801416:	c9                   	leave  
  801417:	c3                   	ret    

00801418 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80141e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801421:	50                   	push   %eax
  801422:	ff 75 08             	pushl  0x8(%ebp)
  801425:	e8 b7 f3 ff ff       	call   8007e1 <fd_lookup>
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 11                	js     801442 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801431:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801434:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80143a:	39 10                	cmp    %edx,(%eax)
  80143c:	0f 94 c0             	sete   %al
  80143f:	0f b6 c0             	movzbl %al,%eax
}
  801442:	c9                   	leave  
  801443:	c3                   	ret    

00801444 <opencons>:

int
opencons(void)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80144a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144d:	50                   	push   %eax
  80144e:	e8 3f f3 ff ff       	call   800792 <fd_alloc>
  801453:	83 c4 10             	add    $0x10,%esp
		return r;
  801456:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 3e                	js     80149a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80145c:	83 ec 04             	sub    $0x4,%esp
  80145f:	68 07 04 00 00       	push   $0x407
  801464:	ff 75 f4             	pushl  -0xc(%ebp)
  801467:	6a 00                	push   $0x0
  801469:	e8 0c f1 ff ff       	call   80057a <sys_page_alloc>
  80146e:	83 c4 10             	add    $0x10,%esp
		return r;
  801471:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801473:	85 c0                	test   %eax,%eax
  801475:	78 23                	js     80149a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801477:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801480:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801482:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801485:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80148c:	83 ec 0c             	sub    $0xc,%esp
  80148f:	50                   	push   %eax
  801490:	e8 d6 f2 ff ff       	call   80076b <fd2num>
  801495:	89 c2                	mov    %eax,%edx
  801497:	83 c4 10             	add    $0x10,%esp
}
  80149a:	89 d0                	mov    %edx,%eax
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	56                   	push   %esi
  8014a2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014a3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014a6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014ac:	e8 8b f0 ff ff       	call   80053c <sys_getenvid>
  8014b1:	83 ec 0c             	sub    $0xc,%esp
  8014b4:	ff 75 0c             	pushl  0xc(%ebp)
  8014b7:	ff 75 08             	pushl  0x8(%ebp)
  8014ba:	56                   	push   %esi
  8014bb:	50                   	push   %eax
  8014bc:	68 bc 1f 80 00       	push   $0x801fbc
  8014c1:	e8 b1 00 00 00       	call   801577 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014c6:	83 c4 18             	add    $0x18,%esp
  8014c9:	53                   	push   %ebx
  8014ca:	ff 75 10             	pushl  0x10(%ebp)
  8014cd:	e8 54 00 00 00       	call   801526 <vcprintf>
	cprintf("\n");
  8014d2:	c7 04 24 a6 1f 80 00 	movl   $0x801fa6,(%esp)
  8014d9:	e8 99 00 00 00       	call   801577 <cprintf>
  8014de:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014e1:	cc                   	int3   
  8014e2:	eb fd                	jmp    8014e1 <_panic+0x43>

008014e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 04             	sub    $0x4,%esp
  8014eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014ee:	8b 13                	mov    (%ebx),%edx
  8014f0:	8d 42 01             	lea    0x1(%edx),%eax
  8014f3:	89 03                	mov    %eax,(%ebx)
  8014f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8014fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  801501:	75 1a                	jne    80151d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	68 ff 00 00 00       	push   $0xff
  80150b:	8d 43 08             	lea    0x8(%ebx),%eax
  80150e:	50                   	push   %eax
  80150f:	e8 aa ef ff ff       	call   8004be <sys_cputs>
		b->idx = 0;
  801514:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80151a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80151d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801521:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801524:	c9                   	leave  
  801525:	c3                   	ret    

00801526 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80152f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801536:	00 00 00 
	b.cnt = 0;
  801539:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801540:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801543:	ff 75 0c             	pushl  0xc(%ebp)
  801546:	ff 75 08             	pushl  0x8(%ebp)
  801549:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	68 e4 14 80 00       	push   $0x8014e4
  801555:	e8 54 01 00 00       	call   8016ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80155a:	83 c4 08             	add    $0x8,%esp
  80155d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801563:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	e8 4f ef ff ff       	call   8004be <sys_cputs>

	return b.cnt;
}
  80156f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80157d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801580:	50                   	push   %eax
  801581:	ff 75 08             	pushl  0x8(%ebp)
  801584:	e8 9d ff ff ff       	call   801526 <vcprintf>
	va_end(ap);

	return cnt;
}
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	57                   	push   %edi
  80158f:	56                   	push   %esi
  801590:	53                   	push   %ebx
  801591:	83 ec 1c             	sub    $0x1c,%esp
  801594:	89 c7                	mov    %eax,%edi
  801596:	89 d6                	mov    %edx,%esi
  801598:	8b 45 08             	mov    0x8(%ebp),%eax
  80159b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015af:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015b2:	39 d3                	cmp    %edx,%ebx
  8015b4:	72 05                	jb     8015bb <printnum+0x30>
  8015b6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015b9:	77 45                	ja     801600 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	ff 75 18             	pushl  0x18(%ebp)
  8015c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015c7:	53                   	push   %ebx
  8015c8:	ff 75 10             	pushl  0x10(%ebp)
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8015d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8015da:	e8 11 06 00 00       	call   801bf0 <__udivdi3>
  8015df:	83 c4 18             	add    $0x18,%esp
  8015e2:	52                   	push   %edx
  8015e3:	50                   	push   %eax
  8015e4:	89 f2                	mov    %esi,%edx
  8015e6:	89 f8                	mov    %edi,%eax
  8015e8:	e8 9e ff ff ff       	call   80158b <printnum>
  8015ed:	83 c4 20             	add    $0x20,%esp
  8015f0:	eb 18                	jmp    80160a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	56                   	push   %esi
  8015f6:	ff 75 18             	pushl  0x18(%ebp)
  8015f9:	ff d7                	call   *%edi
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	eb 03                	jmp    801603 <printnum+0x78>
  801600:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801603:	83 eb 01             	sub    $0x1,%ebx
  801606:	85 db                	test   %ebx,%ebx
  801608:	7f e8                	jg     8015f2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	56                   	push   %esi
  80160e:	83 ec 04             	sub    $0x4,%esp
  801611:	ff 75 e4             	pushl  -0x1c(%ebp)
  801614:	ff 75 e0             	pushl  -0x20(%ebp)
  801617:	ff 75 dc             	pushl  -0x24(%ebp)
  80161a:	ff 75 d8             	pushl  -0x28(%ebp)
  80161d:	e8 fe 06 00 00       	call   801d20 <__umoddi3>
  801622:	83 c4 14             	add    $0x14,%esp
  801625:	0f be 80 df 1f 80 00 	movsbl 0x801fdf(%eax),%eax
  80162c:	50                   	push   %eax
  80162d:	ff d7                	call   *%edi
}
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801635:	5b                   	pop    %ebx
  801636:	5e                   	pop    %esi
  801637:	5f                   	pop    %edi
  801638:	5d                   	pop    %ebp
  801639:	c3                   	ret    

0080163a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80163d:	83 fa 01             	cmp    $0x1,%edx
  801640:	7e 0e                	jle    801650 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801642:	8b 10                	mov    (%eax),%edx
  801644:	8d 4a 08             	lea    0x8(%edx),%ecx
  801647:	89 08                	mov    %ecx,(%eax)
  801649:	8b 02                	mov    (%edx),%eax
  80164b:	8b 52 04             	mov    0x4(%edx),%edx
  80164e:	eb 22                	jmp    801672 <getuint+0x38>
	else if (lflag)
  801650:	85 d2                	test   %edx,%edx
  801652:	74 10                	je     801664 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801654:	8b 10                	mov    (%eax),%edx
  801656:	8d 4a 04             	lea    0x4(%edx),%ecx
  801659:	89 08                	mov    %ecx,(%eax)
  80165b:	8b 02                	mov    (%edx),%eax
  80165d:	ba 00 00 00 00       	mov    $0x0,%edx
  801662:	eb 0e                	jmp    801672 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801664:	8b 10                	mov    (%eax),%edx
  801666:	8d 4a 04             	lea    0x4(%edx),%ecx
  801669:	89 08                	mov    %ecx,(%eax)
  80166b:	8b 02                	mov    (%edx),%eax
  80166d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801672:	5d                   	pop    %ebp
  801673:	c3                   	ret    

00801674 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80167a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80167e:	8b 10                	mov    (%eax),%edx
  801680:	3b 50 04             	cmp    0x4(%eax),%edx
  801683:	73 0a                	jae    80168f <sprintputch+0x1b>
		*b->buf++ = ch;
  801685:	8d 4a 01             	lea    0x1(%edx),%ecx
  801688:	89 08                	mov    %ecx,(%eax)
  80168a:	8b 45 08             	mov    0x8(%ebp),%eax
  80168d:	88 02                	mov    %al,(%edx)
}
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801697:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80169a:	50                   	push   %eax
  80169b:	ff 75 10             	pushl  0x10(%ebp)
  80169e:	ff 75 0c             	pushl  0xc(%ebp)
  8016a1:	ff 75 08             	pushl  0x8(%ebp)
  8016a4:	e8 05 00 00 00       	call   8016ae <vprintfmt>
	va_end(ap);
}
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	57                   	push   %edi
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 2c             	sub    $0x2c,%esp
  8016b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016c0:	eb 12                	jmp    8016d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	0f 84 89 03 00 00    	je     801a53 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	53                   	push   %ebx
  8016ce:	50                   	push   %eax
  8016cf:	ff d6                	call   *%esi
  8016d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016d4:	83 c7 01             	add    $0x1,%edi
  8016d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016db:	83 f8 25             	cmp    $0x25,%eax
  8016de:	75 e2                	jne    8016c2 <vprintfmt+0x14>
  8016e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fe:	eb 07                	jmp    801707 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801700:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801703:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801707:	8d 47 01             	lea    0x1(%edi),%eax
  80170a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80170d:	0f b6 07             	movzbl (%edi),%eax
  801710:	0f b6 c8             	movzbl %al,%ecx
  801713:	83 e8 23             	sub    $0x23,%eax
  801716:	3c 55                	cmp    $0x55,%al
  801718:	0f 87 1a 03 00 00    	ja     801a38 <vprintfmt+0x38a>
  80171e:	0f b6 c0             	movzbl %al,%eax
  801721:	ff 24 85 20 21 80 00 	jmp    *0x802120(,%eax,4)
  801728:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80172b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80172f:	eb d6                	jmp    801707 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801734:	b8 00 00 00 00       	mov    $0x0,%eax
  801739:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80173c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80173f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801743:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801746:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801749:	83 fa 09             	cmp    $0x9,%edx
  80174c:	77 39                	ja     801787 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80174e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801751:	eb e9                	jmp    80173c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801753:	8b 45 14             	mov    0x14(%ebp),%eax
  801756:	8d 48 04             	lea    0x4(%eax),%ecx
  801759:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80175c:	8b 00                	mov    (%eax),%eax
  80175e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801764:	eb 27                	jmp    80178d <vprintfmt+0xdf>
  801766:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801769:	85 c0                	test   %eax,%eax
  80176b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801770:	0f 49 c8             	cmovns %eax,%ecx
  801773:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801779:	eb 8c                	jmp    801707 <vprintfmt+0x59>
  80177b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80177e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801785:	eb 80                	jmp    801707 <vprintfmt+0x59>
  801787:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80178a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80178d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801791:	0f 89 70 ff ff ff    	jns    801707 <vprintfmt+0x59>
				width = precision, precision = -1;
  801797:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80179a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80179d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017a4:	e9 5e ff ff ff       	jmp    801707 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017af:	e9 53 ff ff ff       	jmp    801707 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b7:	8d 50 04             	lea    0x4(%eax),%edx
  8017ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	53                   	push   %ebx
  8017c1:	ff 30                	pushl  (%eax)
  8017c3:	ff d6                	call   *%esi
			break;
  8017c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017cb:	e9 04 ff ff ff       	jmp    8016d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d3:	8d 50 04             	lea    0x4(%eax),%edx
  8017d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8017d9:	8b 00                	mov    (%eax),%eax
  8017db:	99                   	cltd   
  8017dc:	31 d0                	xor    %edx,%eax
  8017de:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017e0:	83 f8 0f             	cmp    $0xf,%eax
  8017e3:	7f 0b                	jg     8017f0 <vprintfmt+0x142>
  8017e5:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  8017ec:	85 d2                	test   %edx,%edx
  8017ee:	75 18                	jne    801808 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8017f0:	50                   	push   %eax
  8017f1:	68 f7 1f 80 00       	push   $0x801ff7
  8017f6:	53                   	push   %ebx
  8017f7:	56                   	push   %esi
  8017f8:	e8 94 fe ff ff       	call   801691 <printfmt>
  8017fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801800:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801803:	e9 cc fe ff ff       	jmp    8016d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801808:	52                   	push   %edx
  801809:	68 61 1f 80 00       	push   $0x801f61
  80180e:	53                   	push   %ebx
  80180f:	56                   	push   %esi
  801810:	e8 7c fe ff ff       	call   801691 <printfmt>
  801815:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801818:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80181b:	e9 b4 fe ff ff       	jmp    8016d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801820:	8b 45 14             	mov    0x14(%ebp),%eax
  801823:	8d 50 04             	lea    0x4(%eax),%edx
  801826:	89 55 14             	mov    %edx,0x14(%ebp)
  801829:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80182b:	85 ff                	test   %edi,%edi
  80182d:	b8 f0 1f 80 00       	mov    $0x801ff0,%eax
  801832:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801835:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801839:	0f 8e 94 00 00 00    	jle    8018d3 <vprintfmt+0x225>
  80183f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801843:	0f 84 98 00 00 00    	je     8018e1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801849:	83 ec 08             	sub    $0x8,%esp
  80184c:	ff 75 d0             	pushl  -0x30(%ebp)
  80184f:	57                   	push   %edi
  801850:	e8 01 e9 ff ff       	call   800156 <strnlen>
  801855:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801858:	29 c1                	sub    %eax,%ecx
  80185a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80185d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801860:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801864:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801867:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80186a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80186c:	eb 0f                	jmp    80187d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80186e:	83 ec 08             	sub    $0x8,%esp
  801871:	53                   	push   %ebx
  801872:	ff 75 e0             	pushl  -0x20(%ebp)
  801875:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801877:	83 ef 01             	sub    $0x1,%edi
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	85 ff                	test   %edi,%edi
  80187f:	7f ed                	jg     80186e <vprintfmt+0x1c0>
  801881:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801884:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801887:	85 c9                	test   %ecx,%ecx
  801889:	b8 00 00 00 00       	mov    $0x0,%eax
  80188e:	0f 49 c1             	cmovns %ecx,%eax
  801891:	29 c1                	sub    %eax,%ecx
  801893:	89 75 08             	mov    %esi,0x8(%ebp)
  801896:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801899:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80189c:	89 cb                	mov    %ecx,%ebx
  80189e:	eb 4d                	jmp    8018ed <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018a4:	74 1b                	je     8018c1 <vprintfmt+0x213>
  8018a6:	0f be c0             	movsbl %al,%eax
  8018a9:	83 e8 20             	sub    $0x20,%eax
  8018ac:	83 f8 5e             	cmp    $0x5e,%eax
  8018af:	76 10                	jbe    8018c1 <vprintfmt+0x213>
					putch('?', putdat);
  8018b1:	83 ec 08             	sub    $0x8,%esp
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	6a 3f                	push   $0x3f
  8018b9:	ff 55 08             	call   *0x8(%ebp)
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	eb 0d                	jmp    8018ce <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018c1:	83 ec 08             	sub    $0x8,%esp
  8018c4:	ff 75 0c             	pushl  0xc(%ebp)
  8018c7:	52                   	push   %edx
  8018c8:	ff 55 08             	call   *0x8(%ebp)
  8018cb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ce:	83 eb 01             	sub    $0x1,%ebx
  8018d1:	eb 1a                	jmp    8018ed <vprintfmt+0x23f>
  8018d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8018d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018dc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018df:	eb 0c                	jmp    8018ed <vprintfmt+0x23f>
  8018e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018ed:	83 c7 01             	add    $0x1,%edi
  8018f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018f4:	0f be d0             	movsbl %al,%edx
  8018f7:	85 d2                	test   %edx,%edx
  8018f9:	74 23                	je     80191e <vprintfmt+0x270>
  8018fb:	85 f6                	test   %esi,%esi
  8018fd:	78 a1                	js     8018a0 <vprintfmt+0x1f2>
  8018ff:	83 ee 01             	sub    $0x1,%esi
  801902:	79 9c                	jns    8018a0 <vprintfmt+0x1f2>
  801904:	89 df                	mov    %ebx,%edi
  801906:	8b 75 08             	mov    0x8(%ebp),%esi
  801909:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80190c:	eb 18                	jmp    801926 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80190e:	83 ec 08             	sub    $0x8,%esp
  801911:	53                   	push   %ebx
  801912:	6a 20                	push   $0x20
  801914:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801916:	83 ef 01             	sub    $0x1,%edi
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	eb 08                	jmp    801926 <vprintfmt+0x278>
  80191e:	89 df                	mov    %ebx,%edi
  801920:	8b 75 08             	mov    0x8(%ebp),%esi
  801923:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801926:	85 ff                	test   %edi,%edi
  801928:	7f e4                	jg     80190e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80192d:	e9 a2 fd ff ff       	jmp    8016d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801932:	83 fa 01             	cmp    $0x1,%edx
  801935:	7e 16                	jle    80194d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801937:	8b 45 14             	mov    0x14(%ebp),%eax
  80193a:	8d 50 08             	lea    0x8(%eax),%edx
  80193d:	89 55 14             	mov    %edx,0x14(%ebp)
  801940:	8b 50 04             	mov    0x4(%eax),%edx
  801943:	8b 00                	mov    (%eax),%eax
  801945:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801948:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80194b:	eb 32                	jmp    80197f <vprintfmt+0x2d1>
	else if (lflag)
  80194d:	85 d2                	test   %edx,%edx
  80194f:	74 18                	je     801969 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801951:	8b 45 14             	mov    0x14(%ebp),%eax
  801954:	8d 50 04             	lea    0x4(%eax),%edx
  801957:	89 55 14             	mov    %edx,0x14(%ebp)
  80195a:	8b 00                	mov    (%eax),%eax
  80195c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80195f:	89 c1                	mov    %eax,%ecx
  801961:	c1 f9 1f             	sar    $0x1f,%ecx
  801964:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801967:	eb 16                	jmp    80197f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801969:	8b 45 14             	mov    0x14(%ebp),%eax
  80196c:	8d 50 04             	lea    0x4(%eax),%edx
  80196f:	89 55 14             	mov    %edx,0x14(%ebp)
  801972:	8b 00                	mov    (%eax),%eax
  801974:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801977:	89 c1                	mov    %eax,%ecx
  801979:	c1 f9 1f             	sar    $0x1f,%ecx
  80197c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80197f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801982:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801985:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80198a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80198e:	79 74                	jns    801a04 <vprintfmt+0x356>
				putch('-', putdat);
  801990:	83 ec 08             	sub    $0x8,%esp
  801993:	53                   	push   %ebx
  801994:	6a 2d                	push   $0x2d
  801996:	ff d6                	call   *%esi
				num = -(long long) num;
  801998:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80199b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80199e:	f7 d8                	neg    %eax
  8019a0:	83 d2 00             	adc    $0x0,%edx
  8019a3:	f7 da                	neg    %edx
  8019a5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019ad:	eb 55                	jmp    801a04 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019af:	8d 45 14             	lea    0x14(%ebp),%eax
  8019b2:	e8 83 fc ff ff       	call   80163a <getuint>
			base = 10;
  8019b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019bc:	eb 46                	jmp    801a04 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8019be:	8d 45 14             	lea    0x14(%ebp),%eax
  8019c1:	e8 74 fc ff ff       	call   80163a <getuint>
			base = 8;
  8019c6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8019cb:	eb 37                	jmp    801a04 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
  8019cd:	83 ec 08             	sub    $0x8,%esp
  8019d0:	53                   	push   %ebx
  8019d1:	6a 30                	push   $0x30
  8019d3:	ff d6                	call   *%esi
			putch('x', putdat);
  8019d5:	83 c4 08             	add    $0x8,%esp
  8019d8:	53                   	push   %ebx
  8019d9:	6a 78                	push   $0x78
  8019db:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e0:	8d 50 04             	lea    0x4(%eax),%edx
  8019e3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019e6:	8b 00                	mov    (%eax),%eax
  8019e8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8019ed:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019f0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8019f5:	eb 0d                	jmp    801a04 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8019f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8019fa:	e8 3b fc ff ff       	call   80163a <getuint>
			base = 16;
  8019ff:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a04:	83 ec 0c             	sub    $0xc,%esp
  801a07:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a0b:	57                   	push   %edi
  801a0c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a0f:	51                   	push   %ecx
  801a10:	52                   	push   %edx
  801a11:	50                   	push   %eax
  801a12:	89 da                	mov    %ebx,%edx
  801a14:	89 f0                	mov    %esi,%eax
  801a16:	e8 70 fb ff ff       	call   80158b <printnum>
			break;
  801a1b:	83 c4 20             	add    $0x20,%esp
  801a1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a21:	e9 ae fc ff ff       	jmp    8016d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a26:	83 ec 08             	sub    $0x8,%esp
  801a29:	53                   	push   %ebx
  801a2a:	51                   	push   %ecx
  801a2b:	ff d6                	call   *%esi
			break;
  801a2d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a33:	e9 9c fc ff ff       	jmp    8016d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	53                   	push   %ebx
  801a3c:	6a 25                	push   $0x25
  801a3e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	eb 03                	jmp    801a48 <vprintfmt+0x39a>
  801a45:	83 ef 01             	sub    $0x1,%edi
  801a48:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a4c:	75 f7                	jne    801a45 <vprintfmt+0x397>
  801a4e:	e9 81 fc ff ff       	jmp    8016d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5f                   	pop    %edi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	83 ec 18             	sub    $0x18,%esp
  801a61:	8b 45 08             	mov    0x8(%ebp),%eax
  801a64:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a67:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a6a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a6e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	74 26                	je     801aa2 <vsnprintf+0x47>
  801a7c:	85 d2                	test   %edx,%edx
  801a7e:	7e 22                	jle    801aa2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a80:	ff 75 14             	pushl  0x14(%ebp)
  801a83:	ff 75 10             	pushl  0x10(%ebp)
  801a86:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a89:	50                   	push   %eax
  801a8a:	68 74 16 80 00       	push   $0x801674
  801a8f:	e8 1a fc ff ff       	call   8016ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a94:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a97:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	eb 05                	jmp    801aa7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801aa2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801aa7:	c9                   	leave  
  801aa8:	c3                   	ret    

00801aa9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801aaf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ab2:	50                   	push   %eax
  801ab3:	ff 75 10             	pushl  0x10(%ebp)
  801ab6:	ff 75 0c             	pushl  0xc(%ebp)
  801ab9:	ff 75 08             	pushl  0x8(%ebp)
  801abc:	e8 9a ff ff ff       	call   801a5b <vsnprintf>
	va_end(ap);

	return rc;
}
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
	   int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	56                   	push   %esi
  801ac7:	53                   	push   %ebx
  801ac8:	8b 75 08             	mov    0x8(%ebp),%esi
  801acb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ace:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   int a = 0;
	   if (!pg)
  801ad1:	85 c0                	test   %eax,%eax
			 pg = (void*) KERNBASE;
  801ad3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ad8:	0f 44 c2             	cmove  %edx,%eax

	   a = sys_ipc_recv (pg);
  801adb:	83 ec 0c             	sub    $0xc,%esp
  801ade:	50                   	push   %eax
  801adf:	e8 46 ec ff ff       	call   80072a <sys_ipc_recv>

	   envid_t s_envid = 0;
	   int s_perm = 0;

	   if (a >= 0)
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 0e                	js     801af9 <ipc_recv+0x36>
	   {
			 s_envid = thisenv -> env_ipc_from;
  801aeb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801af1:	8b 4a 74             	mov    0x74(%edx),%ecx
			 s_perm = thisenv -> env_ipc_perm;
  801af4:	8b 52 78             	mov    0x78(%edx),%edx
  801af7:	eb 0a                	jmp    801b03 <ipc_recv+0x40>
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
	   int s_perm = 0;
  801af9:	ba 00 00 00 00       	mov    $0x0,%edx
	   if (!pg)
			 pg = (void*) KERNBASE;

	   a = sys_ipc_recv (pg);

	   envid_t s_envid = 0;
  801afe:	b9 00 00 00 00       	mov    $0x0,%ecx
	   {
			 s_envid = thisenv -> env_ipc_from;
			 s_perm = thisenv -> env_ipc_perm;
	   }

	   if (from_env_store)
  801b03:	85 f6                	test   %esi,%esi
  801b05:	74 02                	je     801b09 <ipc_recv+0x46>
			 *from_env_store = s_envid;
  801b07:	89 0e                	mov    %ecx,(%esi)

	   if (perm_store)
  801b09:	85 db                	test   %ebx,%ebx
  801b0b:	74 02                	je     801b0f <ipc_recv+0x4c>
			 *perm_store = s_perm;
  801b0d:	89 13                	mov    %edx,(%ebx)

	   return (a >=0) ? thisenv -> env_ipc_value : a;
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	78 08                	js     801b1b <ipc_recv+0x58>
  801b13:	a1 04 40 80 00       	mov    0x804004,%eax
  801b18:	8b 40 70             	mov    0x70(%eax),%eax

	   //	panic("ipc_recv not implemented");
	   //	return 0;
}
  801b1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b1e:	5b                   	pop    %ebx
  801b1f:	5e                   	pop    %esi
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
	   void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	57                   	push   %edi
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // LAB 4: Your code here.
	   if (!pg) {
  801b34:	85 db                	test   %ebx,%ebx
			 pg = (void *)KERNBASE;
  801b36:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801b3b:	0f 44 d8             	cmove  %eax,%ebx
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
  801b3e:	ff 75 14             	pushl  0x14(%ebp)
  801b41:	53                   	push   %ebx
  801b42:	56                   	push   %esi
  801b43:	57                   	push   %edi
  801b44:	e8 be eb ff ff       	call   800707 <sys_ipc_try_send>
			 if (err == -E_IPC_NOT_RECV) {
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b4f:	75 07                	jne    801b58 <ipc_send+0x36>
				    sys_yield();
  801b51:	e8 05 ea ff ff       	call   80055b <sys_yield>
			 } else if (err == 0) {
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
			 }
	   }
  801b56:	eb e6                	jmp    801b3e <ipc_send+0x1c>
	   }
	   while(true) {
			 int err = sys_ipc_try_send(to_env, val, pg, perm);
			 if (err == -E_IPC_NOT_RECV) {
				    sys_yield();
			 } else if (err == 0) {
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	74 12                	je     801b6e <ipc_send+0x4c>
				    break;
			 } else {
				    panic("ipc_send failed: %e", err);
  801b5c:	50                   	push   %eax
  801b5d:	68 e0 22 80 00       	push   $0x8022e0
  801b62:	6a 4b                	push   $0x4b
  801b64:	68 f4 22 80 00       	push   $0x8022f4
  801b69:	e8 30 f9 ff ff       	call   80149e <_panic>
			 }
	   }
}
  801b6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b71:	5b                   	pop    %ebx
  801b72:	5e                   	pop    %esi
  801b73:	5f                   	pop    %edi
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    

00801b76 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
	   int i;
	   for (i = 0; i < NENV; i++)
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
			 if (envs[i].env_type == type)
  801b81:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b84:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b8a:	8b 52 50             	mov    0x50(%edx),%edx
  801b8d:	39 ca                	cmp    %ecx,%edx
  801b8f:	75 0d                	jne    801b9e <ipc_find_env+0x28>
				    return envs[i].env_id;
  801b91:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b94:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b99:	8b 40 48             	mov    0x48(%eax),%eax
  801b9c:	eb 0f                	jmp    801bad <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
	   envid_t
ipc_find_env(enum EnvType type)
{
	   int i;
	   for (i = 0; i < NENV; i++)
  801b9e:	83 c0 01             	add    $0x1,%eax
  801ba1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ba6:	75 d9                	jne    801b81 <ipc_find_env+0xb>
			 if (envs[i].env_type == type)
				    return envs[i].env_id;
	   return 0;
  801ba8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bb5:	89 d0                	mov    %edx,%eax
  801bb7:	c1 e8 16             	shr    $0x16,%eax
  801bba:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bc1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bc6:	f6 c1 01             	test   $0x1,%cl
  801bc9:	74 1d                	je     801be8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bcb:	c1 ea 0c             	shr    $0xc,%edx
  801bce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bd5:	f6 c2 01             	test   $0x1,%dl
  801bd8:	74 0e                	je     801be8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bda:	c1 ea 0c             	shr    $0xc,%edx
  801bdd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801be4:	ef 
  801be5:	0f b7 c0             	movzwl %ax,%eax
}
  801be8:	5d                   	pop    %ebp
  801be9:	c3                   	ret    
  801bea:	66 90                	xchg   %ax,%ax
  801bec:	66 90                	xchg   %ax,%ax
  801bee:	66 90                	xchg   %ax,%ax

00801bf0 <__udivdi3>:
  801bf0:	55                   	push   %ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 1c             	sub    $0x1c,%esp
  801bf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c07:	85 f6                	test   %esi,%esi
  801c09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0d:	89 ca                	mov    %ecx,%edx
  801c0f:	89 f8                	mov    %edi,%eax
  801c11:	75 3d                	jne    801c50 <__udivdi3+0x60>
  801c13:	39 cf                	cmp    %ecx,%edi
  801c15:	0f 87 c5 00 00 00    	ja     801ce0 <__udivdi3+0xf0>
  801c1b:	85 ff                	test   %edi,%edi
  801c1d:	89 fd                	mov    %edi,%ebp
  801c1f:	75 0b                	jne    801c2c <__udivdi3+0x3c>
  801c21:	b8 01 00 00 00       	mov    $0x1,%eax
  801c26:	31 d2                	xor    %edx,%edx
  801c28:	f7 f7                	div    %edi
  801c2a:	89 c5                	mov    %eax,%ebp
  801c2c:	89 c8                	mov    %ecx,%eax
  801c2e:	31 d2                	xor    %edx,%edx
  801c30:	f7 f5                	div    %ebp
  801c32:	89 c1                	mov    %eax,%ecx
  801c34:	89 d8                	mov    %ebx,%eax
  801c36:	89 cf                	mov    %ecx,%edi
  801c38:	f7 f5                	div    %ebp
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	39 ce                	cmp    %ecx,%esi
  801c52:	77 74                	ja     801cc8 <__udivdi3+0xd8>
  801c54:	0f bd fe             	bsr    %esi,%edi
  801c57:	83 f7 1f             	xor    $0x1f,%edi
  801c5a:	0f 84 98 00 00 00    	je     801cf8 <__udivdi3+0x108>
  801c60:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	89 c5                	mov    %eax,%ebp
  801c69:	29 fb                	sub    %edi,%ebx
  801c6b:	d3 e6                	shl    %cl,%esi
  801c6d:	89 d9                	mov    %ebx,%ecx
  801c6f:	d3 ed                	shr    %cl,%ebp
  801c71:	89 f9                	mov    %edi,%ecx
  801c73:	d3 e0                	shl    %cl,%eax
  801c75:	09 ee                	or     %ebp,%esi
  801c77:	89 d9                	mov    %ebx,%ecx
  801c79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c7d:	89 d5                	mov    %edx,%ebp
  801c7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c83:	d3 ed                	shr    %cl,%ebp
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e2                	shl    %cl,%edx
  801c89:	89 d9                	mov    %ebx,%ecx
  801c8b:	d3 e8                	shr    %cl,%eax
  801c8d:	09 c2                	or     %eax,%edx
  801c8f:	89 d0                	mov    %edx,%eax
  801c91:	89 ea                	mov    %ebp,%edx
  801c93:	f7 f6                	div    %esi
  801c95:	89 d5                	mov    %edx,%ebp
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	f7 64 24 0c          	mull   0xc(%esp)
  801c9d:	39 d5                	cmp    %edx,%ebp
  801c9f:	72 10                	jb     801cb1 <__udivdi3+0xc1>
  801ca1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e6                	shl    %cl,%esi
  801ca9:	39 c6                	cmp    %eax,%esi
  801cab:	73 07                	jae    801cb4 <__udivdi3+0xc4>
  801cad:	39 d5                	cmp    %edx,%ebp
  801caf:	75 03                	jne    801cb4 <__udivdi3+0xc4>
  801cb1:	83 eb 01             	sub    $0x1,%ebx
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 d8                	mov    %ebx,%eax
  801cb8:	89 fa                	mov    %edi,%edx
  801cba:	83 c4 1c             	add    $0x1c,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
  801cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc8:	31 ff                	xor    %edi,%edi
  801cca:	31 db                	xor    %ebx,%ebx
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	89 fa                	mov    %edi,%edx
  801cd0:	83 c4 1c             	add    $0x1c,%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
  801cd8:	90                   	nop
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	89 d8                	mov    %ebx,%eax
  801ce2:	f7 f7                	div    %edi
  801ce4:	31 ff                	xor    %edi,%edi
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	89 fa                	mov    %edi,%edx
  801cec:	83 c4 1c             	add    $0x1c,%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	5f                   	pop    %edi
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	39 ce                	cmp    %ecx,%esi
  801cfa:	72 0c                	jb     801d08 <__udivdi3+0x118>
  801cfc:	31 db                	xor    %ebx,%ebx
  801cfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d02:	0f 87 34 ff ff ff    	ja     801c3c <__udivdi3+0x4c>
  801d08:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d0d:	e9 2a ff ff ff       	jmp    801c3c <__udivdi3+0x4c>
  801d12:	66 90                	xchg   %ax,%ax
  801d14:	66 90                	xchg   %ax,%ax
  801d16:	66 90                	xchg   %ax,%ax
  801d18:	66 90                	xchg   %ax,%ax
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <__umoddi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d37:	85 d2                	test   %edx,%edx
  801d39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d41:	89 f3                	mov    %esi,%ebx
  801d43:	89 3c 24             	mov    %edi,(%esp)
  801d46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d4a:	75 1c                	jne    801d68 <__umoddi3+0x48>
  801d4c:	39 f7                	cmp    %esi,%edi
  801d4e:	76 50                	jbe    801da0 <__umoddi3+0x80>
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	f7 f7                	div    %edi
  801d56:	89 d0                	mov    %edx,%eax
  801d58:	31 d2                	xor    %edx,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	39 f2                	cmp    %esi,%edx
  801d6a:	89 d0                	mov    %edx,%eax
  801d6c:	77 52                	ja     801dc0 <__umoddi3+0xa0>
  801d6e:	0f bd ea             	bsr    %edx,%ebp
  801d71:	83 f5 1f             	xor    $0x1f,%ebp
  801d74:	75 5a                	jne    801dd0 <__umoddi3+0xb0>
  801d76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d7a:	0f 82 e0 00 00 00    	jb     801e60 <__umoddi3+0x140>
  801d80:	39 0c 24             	cmp    %ecx,(%esp)
  801d83:	0f 86 d7 00 00 00    	jbe    801e60 <__umoddi3+0x140>
  801d89:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d91:	83 c4 1c             	add    $0x1c,%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5f                   	pop    %edi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	85 ff                	test   %edi,%edi
  801da2:	89 fd                	mov    %edi,%ebp
  801da4:	75 0b                	jne    801db1 <__umoddi3+0x91>
  801da6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dab:	31 d2                	xor    %edx,%edx
  801dad:	f7 f7                	div    %edi
  801daf:	89 c5                	mov    %eax,%ebp
  801db1:	89 f0                	mov    %esi,%eax
  801db3:	31 d2                	xor    %edx,%edx
  801db5:	f7 f5                	div    %ebp
  801db7:	89 c8                	mov    %ecx,%eax
  801db9:	f7 f5                	div    %ebp
  801dbb:	89 d0                	mov    %edx,%eax
  801dbd:	eb 99                	jmp    801d58 <__umoddi3+0x38>
  801dbf:	90                   	nop
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	83 c4 1c             	add    $0x1c,%esp
  801dc7:	5b                   	pop    %ebx
  801dc8:	5e                   	pop    %esi
  801dc9:	5f                   	pop    %edi
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    
  801dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	8b 34 24             	mov    (%esp),%esi
  801dd3:	bf 20 00 00 00       	mov    $0x20,%edi
  801dd8:	89 e9                	mov    %ebp,%ecx
  801dda:	29 ef                	sub    %ebp,%edi
  801ddc:	d3 e0                	shl    %cl,%eax
  801dde:	89 f9                	mov    %edi,%ecx
  801de0:	89 f2                	mov    %esi,%edx
  801de2:	d3 ea                	shr    %cl,%edx
  801de4:	89 e9                	mov    %ebp,%ecx
  801de6:	09 c2                	or     %eax,%edx
  801de8:	89 d8                	mov    %ebx,%eax
  801dea:	89 14 24             	mov    %edx,(%esp)
  801ded:	89 f2                	mov    %esi,%edx
  801def:	d3 e2                	shl    %cl,%edx
  801df1:	89 f9                	mov    %edi,%ecx
  801df3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801df7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dfb:	d3 e8                	shr    %cl,%eax
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	89 c6                	mov    %eax,%esi
  801e01:	d3 e3                	shl    %cl,%ebx
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 d0                	mov    %edx,%eax
  801e07:	d3 e8                	shr    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	09 d8                	or     %ebx,%eax
  801e0d:	89 d3                	mov    %edx,%ebx
  801e0f:	89 f2                	mov    %esi,%edx
  801e11:	f7 34 24             	divl   (%esp)
  801e14:	89 d6                	mov    %edx,%esi
  801e16:	d3 e3                	shl    %cl,%ebx
  801e18:	f7 64 24 04          	mull   0x4(%esp)
  801e1c:	39 d6                	cmp    %edx,%esi
  801e1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e22:	89 d1                	mov    %edx,%ecx
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	72 08                	jb     801e30 <__umoddi3+0x110>
  801e28:	75 11                	jne    801e3b <__umoddi3+0x11b>
  801e2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e2e:	73 0b                	jae    801e3b <__umoddi3+0x11b>
  801e30:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e34:	1b 14 24             	sbb    (%esp),%edx
  801e37:	89 d1                	mov    %edx,%ecx
  801e39:	89 c3                	mov    %eax,%ebx
  801e3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e3f:	29 da                	sub    %ebx,%edx
  801e41:	19 ce                	sbb    %ecx,%esi
  801e43:	89 f9                	mov    %edi,%ecx
  801e45:	89 f0                	mov    %esi,%eax
  801e47:	d3 e0                	shl    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	d3 ea                	shr    %cl,%edx
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	d3 ee                	shr    %cl,%esi
  801e51:	09 d0                	or     %edx,%eax
  801e53:	89 f2                	mov    %esi,%edx
  801e55:	83 c4 1c             	add    $0x1c,%esp
  801e58:	5b                   	pop    %ebx
  801e59:	5e                   	pop    %esi
  801e5a:	5f                   	pop    %edi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    
  801e5d:	8d 76 00             	lea    0x0(%esi),%esi
  801e60:	29 f9                	sub    %edi,%ecx
  801e62:	19 d6                	sbb    %edx,%esi
  801e64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e6c:	e9 18 ff ff ff       	jmp    801d89 <__umoddi3+0x69>
