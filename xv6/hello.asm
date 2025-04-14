
_hello:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"

int main(int argc, char *argv[]) {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
	printf(1, "Hello world!\n");
  11:	83 ec 08             	sub    $0x8,%esp
  14:	68 b2 07 00 00       	push   $0x7b2
  19:	6a 01                	push   $0x1
  1b:	e8 db 03 00 00       	call   3fb <printf>
  20:	83 c4 10             	add    $0x10,%esp
	exit();
  23:	e8 57 02 00 00       	call   27f <exit>

00000028 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  28:	55                   	push   %ebp
  29:	89 e5                	mov    %esp,%ebp
  2b:	57                   	push   %edi
  2c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  30:	8b 55 10             	mov    0x10(%ebp),%edx
  33:	8b 45 0c             	mov    0xc(%ebp),%eax
  36:	89 cb                	mov    %ecx,%ebx
  38:	89 df                	mov    %ebx,%edi
  3a:	89 d1                	mov    %edx,%ecx
  3c:	fc                   	cld
  3d:	f3 aa                	rep stos %al,%es:(%edi)
  3f:	89 ca                	mov    %ecx,%edx
  41:	89 fb                	mov    %edi,%ebx
  43:	89 5d 08             	mov    %ebx,0x8(%ebp)
  46:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  49:	90                   	nop
  4a:	5b                   	pop    %ebx
  4b:	5f                   	pop    %edi
  4c:	5d                   	pop    %ebp
  4d:	c3                   	ret

0000004e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  4e:	55                   	push   %ebp
  4f:	89 e5                	mov    %esp,%ebp
  51:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  54:	8b 45 08             	mov    0x8(%ebp),%eax
  57:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  5a:	90                   	nop
  5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  5e:	8d 42 01             	lea    0x1(%edx),%eax
  61:	89 45 0c             	mov    %eax,0xc(%ebp)
  64:	8b 45 08             	mov    0x8(%ebp),%eax
  67:	8d 48 01             	lea    0x1(%eax),%ecx
  6a:	89 4d 08             	mov    %ecx,0x8(%ebp)
  6d:	0f b6 12             	movzbl (%edx),%edx
  70:	88 10                	mov    %dl,(%eax)
  72:	0f b6 00             	movzbl (%eax),%eax
  75:	84 c0                	test   %al,%al
  77:	75 e2                	jne    5b <strcpy+0xd>
    ;
  return os;
  79:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  7c:	c9                   	leave
  7d:	c3                   	ret

0000007e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7e:	55                   	push   %ebp
  7f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  81:	eb 08                	jmp    8b <strcmp+0xd>
    p++, q++;
  83:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  87:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  8b:	8b 45 08             	mov    0x8(%ebp),%eax
  8e:	0f b6 00             	movzbl (%eax),%eax
  91:	84 c0                	test   %al,%al
  93:	74 10                	je     a5 <strcmp+0x27>
  95:	8b 45 08             	mov    0x8(%ebp),%eax
  98:	0f b6 10             	movzbl (%eax),%edx
  9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  9e:	0f b6 00             	movzbl (%eax),%eax
  a1:	38 c2                	cmp    %al,%dl
  a3:	74 de                	je     83 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  a5:	8b 45 08             	mov    0x8(%ebp),%eax
  a8:	0f b6 00             	movzbl (%eax),%eax
  ab:	0f b6 d0             	movzbl %al,%edx
  ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  b1:	0f b6 00             	movzbl (%eax),%eax
  b4:	0f b6 c0             	movzbl %al,%eax
  b7:	29 c2                	sub    %eax,%edx
  b9:	89 d0                	mov    %edx,%eax
}
  bb:	5d                   	pop    %ebp
  bc:	c3                   	ret

000000bd <strlen>:

uint
strlen(char *s)
{
  bd:	55                   	push   %ebp
  be:	89 e5                	mov    %esp,%ebp
  c0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  c3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  ca:	eb 04                	jmp    d0 <strlen+0x13>
  cc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  d0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  d3:	8b 45 08             	mov    0x8(%ebp),%eax
  d6:	01 d0                	add    %edx,%eax
  d8:	0f b6 00             	movzbl (%eax),%eax
  db:	84 c0                	test   %al,%al
  dd:	75 ed                	jne    cc <strlen+0xf>
    ;
  return n;
  df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e2:	c9                   	leave
  e3:	c3                   	ret

000000e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e4:	55                   	push   %ebp
  e5:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
  e7:	8b 45 10             	mov    0x10(%ebp),%eax
  ea:	50                   	push   %eax
  eb:	ff 75 0c             	push   0xc(%ebp)
  ee:	ff 75 08             	push   0x8(%ebp)
  f1:	e8 32 ff ff ff       	call   28 <stosb>
  f6:	83 c4 0c             	add    $0xc,%esp
  return dst;
  f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  fc:	c9                   	leave
  fd:	c3                   	ret

000000fe <strchr>:

char*
strchr(const char *s, char c)
{
  fe:	55                   	push   %ebp
  ff:	89 e5                	mov    %esp,%ebp
 101:	83 ec 04             	sub    $0x4,%esp
 104:	8b 45 0c             	mov    0xc(%ebp),%eax
 107:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 10a:	eb 14                	jmp    120 <strchr+0x22>
    if(*s == c)
 10c:	8b 45 08             	mov    0x8(%ebp),%eax
 10f:	0f b6 00             	movzbl (%eax),%eax
 112:	38 45 fc             	cmp    %al,-0x4(%ebp)
 115:	75 05                	jne    11c <strchr+0x1e>
      return (char*)s;
 117:	8b 45 08             	mov    0x8(%ebp),%eax
 11a:	eb 13                	jmp    12f <strchr+0x31>
  for(; *s; s++)
 11c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	0f b6 00             	movzbl (%eax),%eax
 126:	84 c0                	test   %al,%al
 128:	75 e2                	jne    10c <strchr+0xe>
  return 0;
 12a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 12f:	c9                   	leave
 130:	c3                   	ret

00000131 <gets>:

char*
gets(char *buf, int max)
{
 131:	55                   	push   %ebp
 132:	89 e5                	mov    %esp,%ebp
 134:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 137:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 13e:	eb 42                	jmp    182 <gets+0x51>
    cc = read(0, &c, 1);
 140:	83 ec 04             	sub    $0x4,%esp
 143:	6a 01                	push   $0x1
 145:	8d 45 ef             	lea    -0x11(%ebp),%eax
 148:	50                   	push   %eax
 149:	6a 00                	push   $0x0
 14b:	e8 47 01 00 00       	call   297 <read>
 150:	83 c4 10             	add    $0x10,%esp
 153:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 156:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 15a:	7e 33                	jle    18f <gets+0x5e>
      break;
    buf[i++] = c;
 15c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 15f:	8d 50 01             	lea    0x1(%eax),%edx
 162:	89 55 f4             	mov    %edx,-0xc(%ebp)
 165:	89 c2                	mov    %eax,%edx
 167:	8b 45 08             	mov    0x8(%ebp),%eax
 16a:	01 c2                	add    %eax,%edx
 16c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 170:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 172:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 176:	3c 0a                	cmp    $0xa,%al
 178:	74 16                	je     190 <gets+0x5f>
 17a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 17e:	3c 0d                	cmp    $0xd,%al
 180:	74 0e                	je     190 <gets+0x5f>
  for(i=0; i+1 < max; ){
 182:	8b 45 f4             	mov    -0xc(%ebp),%eax
 185:	83 c0 01             	add    $0x1,%eax
 188:	39 45 0c             	cmp    %eax,0xc(%ebp)
 18b:	7f b3                	jg     140 <gets+0xf>
 18d:	eb 01                	jmp    190 <gets+0x5f>
      break;
 18f:	90                   	nop
      break;
  }
  buf[i] = '\0';
 190:	8b 55 f4             	mov    -0xc(%ebp),%edx
 193:	8b 45 08             	mov    0x8(%ebp),%eax
 196:	01 d0                	add    %edx,%eax
 198:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 19b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 19e:	c9                   	leave
 19f:	c3                   	ret

000001a0 <stat>:

int
stat(char *n, struct stat *st)
{
 1a0:	55                   	push   %ebp
 1a1:	89 e5                	mov    %esp,%ebp
 1a3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1a6:	83 ec 08             	sub    $0x8,%esp
 1a9:	6a 00                	push   $0x0
 1ab:	ff 75 08             	push   0x8(%ebp)
 1ae:	e8 0c 01 00 00       	call   2bf <open>
 1b3:	83 c4 10             	add    $0x10,%esp
 1b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1bd:	79 07                	jns    1c6 <stat+0x26>
    return -1;
 1bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1c4:	eb 25                	jmp    1eb <stat+0x4b>
  r = fstat(fd, st);
 1c6:	83 ec 08             	sub    $0x8,%esp
 1c9:	ff 75 0c             	push   0xc(%ebp)
 1cc:	ff 75 f4             	push   -0xc(%ebp)
 1cf:	e8 03 01 00 00       	call   2d7 <fstat>
 1d4:	83 c4 10             	add    $0x10,%esp
 1d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1da:	83 ec 0c             	sub    $0xc,%esp
 1dd:	ff 75 f4             	push   -0xc(%ebp)
 1e0:	e8 c2 00 00 00       	call   2a7 <close>
 1e5:	83 c4 10             	add    $0x10,%esp
  return r;
 1e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1eb:	c9                   	leave
 1ec:	c3                   	ret

000001ed <atoi>:

int
atoi(const char *s)
{
 1ed:	55                   	push   %ebp
 1ee:	89 e5                	mov    %esp,%ebp
 1f0:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1fa:	eb 25                	jmp    221 <atoi+0x34>
    n = n*10 + *s++ - '0';
 1fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ff:	89 d0                	mov    %edx,%eax
 201:	c1 e0 02             	shl    $0x2,%eax
 204:	01 d0                	add    %edx,%eax
 206:	01 c0                	add    %eax,%eax
 208:	89 c1                	mov    %eax,%ecx
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	8d 50 01             	lea    0x1(%eax),%edx
 210:	89 55 08             	mov    %edx,0x8(%ebp)
 213:	0f b6 00             	movzbl (%eax),%eax
 216:	0f be c0             	movsbl %al,%eax
 219:	01 c8                	add    %ecx,%eax
 21b:	83 e8 30             	sub    $0x30,%eax
 21e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 221:	8b 45 08             	mov    0x8(%ebp),%eax
 224:	0f b6 00             	movzbl (%eax),%eax
 227:	3c 2f                	cmp    $0x2f,%al
 229:	7e 0a                	jle    235 <atoi+0x48>
 22b:	8b 45 08             	mov    0x8(%ebp),%eax
 22e:	0f b6 00             	movzbl (%eax),%eax
 231:	3c 39                	cmp    $0x39,%al
 233:	7e c7                	jle    1fc <atoi+0xf>
  return n;
 235:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 238:	c9                   	leave
 239:	c3                   	ret

0000023a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 23a:	55                   	push   %ebp
 23b:	89 e5                	mov    %esp,%ebp
 23d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 240:	8b 45 08             	mov    0x8(%ebp),%eax
 243:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 246:	8b 45 0c             	mov    0xc(%ebp),%eax
 249:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 24c:	eb 17                	jmp    265 <memmove+0x2b>
    *dst++ = *src++;
 24e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 251:	8d 42 01             	lea    0x1(%edx),%eax
 254:	89 45 f8             	mov    %eax,-0x8(%ebp)
 257:	8b 45 fc             	mov    -0x4(%ebp),%eax
 25a:	8d 48 01             	lea    0x1(%eax),%ecx
 25d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 260:	0f b6 12             	movzbl (%edx),%edx
 263:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 265:	8b 45 10             	mov    0x10(%ebp),%eax
 268:	8d 50 ff             	lea    -0x1(%eax),%edx
 26b:	89 55 10             	mov    %edx,0x10(%ebp)
 26e:	85 c0                	test   %eax,%eax
 270:	7f dc                	jg     24e <memmove+0x14>
  return vdst;
 272:	8b 45 08             	mov    0x8(%ebp),%eax
}
 275:	c9                   	leave
 276:	c3                   	ret

00000277 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 277:	b8 01 00 00 00       	mov    $0x1,%eax
 27c:	cd 40                	int    $0x40
 27e:	c3                   	ret

0000027f <exit>:
SYSCALL(exit)
 27f:	b8 02 00 00 00       	mov    $0x2,%eax
 284:	cd 40                	int    $0x40
 286:	c3                   	ret

00000287 <wait>:
SYSCALL(wait)
 287:	b8 03 00 00 00       	mov    $0x3,%eax
 28c:	cd 40                	int    $0x40
 28e:	c3                   	ret

0000028f <pipe>:
SYSCALL(pipe)
 28f:	b8 04 00 00 00       	mov    $0x4,%eax
 294:	cd 40                	int    $0x40
 296:	c3                   	ret

00000297 <read>:
SYSCALL(read)
 297:	b8 05 00 00 00       	mov    $0x5,%eax
 29c:	cd 40                	int    $0x40
 29e:	c3                   	ret

0000029f <write>:
SYSCALL(write)
 29f:	b8 10 00 00 00       	mov    $0x10,%eax
 2a4:	cd 40                	int    $0x40
 2a6:	c3                   	ret

000002a7 <close>:
SYSCALL(close)
 2a7:	b8 15 00 00 00       	mov    $0x15,%eax
 2ac:	cd 40                	int    $0x40
 2ae:	c3                   	ret

000002af <kill>:
SYSCALL(kill)
 2af:	b8 06 00 00 00       	mov    $0x6,%eax
 2b4:	cd 40                	int    $0x40
 2b6:	c3                   	ret

000002b7 <exec>:
SYSCALL(exec)
 2b7:	b8 07 00 00 00       	mov    $0x7,%eax
 2bc:	cd 40                	int    $0x40
 2be:	c3                   	ret

000002bf <open>:
SYSCALL(open)
 2bf:	b8 0f 00 00 00       	mov    $0xf,%eax
 2c4:	cd 40                	int    $0x40
 2c6:	c3                   	ret

000002c7 <mknod>:
SYSCALL(mknod)
 2c7:	b8 11 00 00 00       	mov    $0x11,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret

000002cf <unlink>:
SYSCALL(unlink)
 2cf:	b8 12 00 00 00       	mov    $0x12,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret

000002d7 <fstat>:
SYSCALL(fstat)
 2d7:	b8 08 00 00 00       	mov    $0x8,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret

000002df <link>:
SYSCALL(link)
 2df:	b8 13 00 00 00       	mov    $0x13,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret

000002e7 <mkdir>:
SYSCALL(mkdir)
 2e7:	b8 14 00 00 00       	mov    $0x14,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret

000002ef <chdir>:
SYSCALL(chdir)
 2ef:	b8 09 00 00 00       	mov    $0x9,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret

000002f7 <dup>:
SYSCALL(dup)
 2f7:	b8 0a 00 00 00       	mov    $0xa,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret

000002ff <getpid>:
SYSCALL(getpid)
 2ff:	b8 0b 00 00 00       	mov    $0xb,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret

00000307 <sbrk>:
SYSCALL(sbrk)
 307:	b8 0c 00 00 00       	mov    $0xc,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret

0000030f <sleep>:
SYSCALL(sleep)
 30f:	b8 0d 00 00 00       	mov    $0xd,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret

00000317 <uptime>:
SYSCALL(uptime)
 317:	b8 0e 00 00 00       	mov    $0xe,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret

0000031f <uthread_init>:
SYSCALL(uthread_init)
 31f:	b8 16 00 00 00       	mov    $0x16,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret

00000327 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 327:	55                   	push   %ebp
 328:	89 e5                	mov    %esp,%ebp
 32a:	83 ec 18             	sub    $0x18,%esp
 32d:	8b 45 0c             	mov    0xc(%ebp),%eax
 330:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 333:	83 ec 04             	sub    $0x4,%esp
 336:	6a 01                	push   $0x1
 338:	8d 45 f4             	lea    -0xc(%ebp),%eax
 33b:	50                   	push   %eax
 33c:	ff 75 08             	push   0x8(%ebp)
 33f:	e8 5b ff ff ff       	call   29f <write>
 344:	83 c4 10             	add    $0x10,%esp
}
 347:	90                   	nop
 348:	c9                   	leave
 349:	c3                   	ret

0000034a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 34a:	55                   	push   %ebp
 34b:	89 e5                	mov    %esp,%ebp
 34d:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 350:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 357:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 35b:	74 17                	je     374 <printint+0x2a>
 35d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 361:	79 11                	jns    374 <printint+0x2a>
    neg = 1;
 363:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 36a:	8b 45 0c             	mov    0xc(%ebp),%eax
 36d:	f7 d8                	neg    %eax
 36f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 372:	eb 06                	jmp    37a <printint+0x30>
  } else {
    x = xx;
 374:	8b 45 0c             	mov    0xc(%ebp),%eax
 377:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 37a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 381:	8b 4d 10             	mov    0x10(%ebp),%ecx
 384:	8b 45 ec             	mov    -0x14(%ebp),%eax
 387:	ba 00 00 00 00       	mov    $0x0,%edx
 38c:	f7 f1                	div    %ecx
 38e:	89 d1                	mov    %edx,%ecx
 390:	8b 45 f4             	mov    -0xc(%ebp),%eax
 393:	8d 50 01             	lea    0x1(%eax),%edx
 396:	89 55 f4             	mov    %edx,-0xc(%ebp)
 399:	0f b6 91 0c 0a 00 00 	movzbl 0xa0c(%ecx),%edx
 3a0:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3aa:	ba 00 00 00 00       	mov    $0x0,%edx
 3af:	f7 f1                	div    %ecx
 3b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3b4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3b8:	75 c7                	jne    381 <printint+0x37>
  if(neg)
 3ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3be:	74 2d                	je     3ed <printint+0xa3>
    buf[i++] = '-';
 3c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c3:	8d 50 01             	lea    0x1(%eax),%edx
 3c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3c9:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3ce:	eb 1d                	jmp    3ed <printint+0xa3>
    putc(fd, buf[i]);
 3d0:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d6:	01 d0                	add    %edx,%eax
 3d8:	0f b6 00             	movzbl (%eax),%eax
 3db:	0f be c0             	movsbl %al,%eax
 3de:	83 ec 08             	sub    $0x8,%esp
 3e1:	50                   	push   %eax
 3e2:	ff 75 08             	push   0x8(%ebp)
 3e5:	e8 3d ff ff ff       	call   327 <putc>
 3ea:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 3ed:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 3f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3f5:	79 d9                	jns    3d0 <printint+0x86>
}
 3f7:	90                   	nop
 3f8:	90                   	nop
 3f9:	c9                   	leave
 3fa:	c3                   	ret

000003fb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 3fb:	55                   	push   %ebp
 3fc:	89 e5                	mov    %esp,%ebp
 3fe:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 401:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 408:	8d 45 0c             	lea    0xc(%ebp),%eax
 40b:	83 c0 04             	add    $0x4,%eax
 40e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 411:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 418:	e9 59 01 00 00       	jmp    576 <printf+0x17b>
    c = fmt[i] & 0xff;
 41d:	8b 55 0c             	mov    0xc(%ebp),%edx
 420:	8b 45 f0             	mov    -0x10(%ebp),%eax
 423:	01 d0                	add    %edx,%eax
 425:	0f b6 00             	movzbl (%eax),%eax
 428:	0f be c0             	movsbl %al,%eax
 42b:	25 ff 00 00 00       	and    $0xff,%eax
 430:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 433:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 437:	75 2c                	jne    465 <printf+0x6a>
      if(c == '%'){
 439:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 43d:	75 0c                	jne    44b <printf+0x50>
        state = '%';
 43f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 446:	e9 27 01 00 00       	jmp    572 <printf+0x177>
      } else {
        putc(fd, c);
 44b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 44e:	0f be c0             	movsbl %al,%eax
 451:	83 ec 08             	sub    $0x8,%esp
 454:	50                   	push   %eax
 455:	ff 75 08             	push   0x8(%ebp)
 458:	e8 ca fe ff ff       	call   327 <putc>
 45d:	83 c4 10             	add    $0x10,%esp
 460:	e9 0d 01 00 00       	jmp    572 <printf+0x177>
      }
    } else if(state == '%'){
 465:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 469:	0f 85 03 01 00 00    	jne    572 <printf+0x177>
      if(c == 'd'){
 46f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 473:	75 1e                	jne    493 <printf+0x98>
        printint(fd, *ap, 10, 1);
 475:	8b 45 e8             	mov    -0x18(%ebp),%eax
 478:	8b 00                	mov    (%eax),%eax
 47a:	6a 01                	push   $0x1
 47c:	6a 0a                	push   $0xa
 47e:	50                   	push   %eax
 47f:	ff 75 08             	push   0x8(%ebp)
 482:	e8 c3 fe ff ff       	call   34a <printint>
 487:	83 c4 10             	add    $0x10,%esp
        ap++;
 48a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 48e:	e9 d8 00 00 00       	jmp    56b <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 493:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 497:	74 06                	je     49f <printf+0xa4>
 499:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 49d:	75 1e                	jne    4bd <printf+0xc2>
        printint(fd, *ap, 16, 0);
 49f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4a2:	8b 00                	mov    (%eax),%eax
 4a4:	6a 00                	push   $0x0
 4a6:	6a 10                	push   $0x10
 4a8:	50                   	push   %eax
 4a9:	ff 75 08             	push   0x8(%ebp)
 4ac:	e8 99 fe ff ff       	call   34a <printint>
 4b1:	83 c4 10             	add    $0x10,%esp
        ap++;
 4b4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4b8:	e9 ae 00 00 00       	jmp    56b <printf+0x170>
      } else if(c == 's'){
 4bd:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4c1:	75 43                	jne    506 <printf+0x10b>
        s = (char*)*ap;
 4c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4c6:	8b 00                	mov    (%eax),%eax
 4c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4cb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4d3:	75 25                	jne    4fa <printf+0xff>
          s = "(null)";
 4d5:	c7 45 f4 c0 07 00 00 	movl   $0x7c0,-0xc(%ebp)
        while(*s != 0){
 4dc:	eb 1c                	jmp    4fa <printf+0xff>
          putc(fd, *s);
 4de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e1:	0f b6 00             	movzbl (%eax),%eax
 4e4:	0f be c0             	movsbl %al,%eax
 4e7:	83 ec 08             	sub    $0x8,%esp
 4ea:	50                   	push   %eax
 4eb:	ff 75 08             	push   0x8(%ebp)
 4ee:	e8 34 fe ff ff       	call   327 <putc>
 4f3:	83 c4 10             	add    $0x10,%esp
          s++;
 4f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 4fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fd:	0f b6 00             	movzbl (%eax),%eax
 500:	84 c0                	test   %al,%al
 502:	75 da                	jne    4de <printf+0xe3>
 504:	eb 65                	jmp    56b <printf+0x170>
        }
      } else if(c == 'c'){
 506:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 50a:	75 1d                	jne    529 <printf+0x12e>
        putc(fd, *ap);
 50c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50f:	8b 00                	mov    (%eax),%eax
 511:	0f be c0             	movsbl %al,%eax
 514:	83 ec 08             	sub    $0x8,%esp
 517:	50                   	push   %eax
 518:	ff 75 08             	push   0x8(%ebp)
 51b:	e8 07 fe ff ff       	call   327 <putc>
 520:	83 c4 10             	add    $0x10,%esp
        ap++;
 523:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 527:	eb 42                	jmp    56b <printf+0x170>
      } else if(c == '%'){
 529:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 52d:	75 17                	jne    546 <printf+0x14b>
        putc(fd, c);
 52f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 532:	0f be c0             	movsbl %al,%eax
 535:	83 ec 08             	sub    $0x8,%esp
 538:	50                   	push   %eax
 539:	ff 75 08             	push   0x8(%ebp)
 53c:	e8 e6 fd ff ff       	call   327 <putc>
 541:	83 c4 10             	add    $0x10,%esp
 544:	eb 25                	jmp    56b <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 546:	83 ec 08             	sub    $0x8,%esp
 549:	6a 25                	push   $0x25
 54b:	ff 75 08             	push   0x8(%ebp)
 54e:	e8 d4 fd ff ff       	call   327 <putc>
 553:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 556:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 559:	0f be c0             	movsbl %al,%eax
 55c:	83 ec 08             	sub    $0x8,%esp
 55f:	50                   	push   %eax
 560:	ff 75 08             	push   0x8(%ebp)
 563:	e8 bf fd ff ff       	call   327 <putc>
 568:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 56b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 572:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 576:	8b 55 0c             	mov    0xc(%ebp),%edx
 579:	8b 45 f0             	mov    -0x10(%ebp),%eax
 57c:	01 d0                	add    %edx,%eax
 57e:	0f b6 00             	movzbl (%eax),%eax
 581:	84 c0                	test   %al,%al
 583:	0f 85 94 fe ff ff    	jne    41d <printf+0x22>
    }
  }
}
 589:	90                   	nop
 58a:	90                   	nop
 58b:	c9                   	leave
 58c:	c3                   	ret

0000058d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 58d:	55                   	push   %ebp
 58e:	89 e5                	mov    %esp,%ebp
 590:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 593:	8b 45 08             	mov    0x8(%ebp),%eax
 596:	83 e8 08             	sub    $0x8,%eax
 599:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 59c:	a1 28 0a 00 00       	mov    0xa28,%eax
 5a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5a4:	eb 24                	jmp    5ca <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5a9:	8b 00                	mov    (%eax),%eax
 5ab:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5ae:	72 12                	jb     5c2 <free+0x35>
 5b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5b3:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5b6:	72 24                	jb     5dc <free+0x4f>
 5b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5bb:	8b 00                	mov    (%eax),%eax
 5bd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5c0:	72 1a                	jb     5dc <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c5:	8b 00                	mov    (%eax),%eax
 5c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5cd:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5d0:	73 d4                	jae    5a6 <free+0x19>
 5d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d5:	8b 00                	mov    (%eax),%eax
 5d7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5da:	73 ca                	jae    5a6 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5df:	8b 40 04             	mov    0x4(%eax),%eax
 5e2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 5e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5ec:	01 c2                	add    %eax,%edx
 5ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f1:	8b 00                	mov    (%eax),%eax
 5f3:	39 c2                	cmp    %eax,%edx
 5f5:	75 24                	jne    61b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 5f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5fa:	8b 50 04             	mov    0x4(%eax),%edx
 5fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 600:	8b 00                	mov    (%eax),%eax
 602:	8b 40 04             	mov    0x4(%eax),%eax
 605:	01 c2                	add    %eax,%edx
 607:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 60d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 610:	8b 00                	mov    (%eax),%eax
 612:	8b 10                	mov    (%eax),%edx
 614:	8b 45 f8             	mov    -0x8(%ebp),%eax
 617:	89 10                	mov    %edx,(%eax)
 619:	eb 0a                	jmp    625 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 61b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61e:	8b 10                	mov    (%eax),%edx
 620:	8b 45 f8             	mov    -0x8(%ebp),%eax
 623:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 625:	8b 45 fc             	mov    -0x4(%ebp),%eax
 628:	8b 40 04             	mov    0x4(%eax),%eax
 62b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 632:	8b 45 fc             	mov    -0x4(%ebp),%eax
 635:	01 d0                	add    %edx,%eax
 637:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 63a:	75 20                	jne    65c <free+0xcf>
    p->s.size += bp->s.size;
 63c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63f:	8b 50 04             	mov    0x4(%eax),%edx
 642:	8b 45 f8             	mov    -0x8(%ebp),%eax
 645:	8b 40 04             	mov    0x4(%eax),%eax
 648:	01 c2                	add    %eax,%edx
 64a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 650:	8b 45 f8             	mov    -0x8(%ebp),%eax
 653:	8b 10                	mov    (%eax),%edx
 655:	8b 45 fc             	mov    -0x4(%ebp),%eax
 658:	89 10                	mov    %edx,(%eax)
 65a:	eb 08                	jmp    664 <free+0xd7>
  } else
    p->s.ptr = bp;
 65c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 662:	89 10                	mov    %edx,(%eax)
  freep = p;
 664:	8b 45 fc             	mov    -0x4(%ebp),%eax
 667:	a3 28 0a 00 00       	mov    %eax,0xa28
}
 66c:	90                   	nop
 66d:	c9                   	leave
 66e:	c3                   	ret

0000066f <morecore>:

static Header*
morecore(uint nu)
{
 66f:	55                   	push   %ebp
 670:	89 e5                	mov    %esp,%ebp
 672:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 675:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 67c:	77 07                	ja     685 <morecore+0x16>
    nu = 4096;
 67e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 685:	8b 45 08             	mov    0x8(%ebp),%eax
 688:	c1 e0 03             	shl    $0x3,%eax
 68b:	83 ec 0c             	sub    $0xc,%esp
 68e:	50                   	push   %eax
 68f:	e8 73 fc ff ff       	call   307 <sbrk>
 694:	83 c4 10             	add    $0x10,%esp
 697:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 69a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 69e:	75 07                	jne    6a7 <morecore+0x38>
    return 0;
 6a0:	b8 00 00 00 00       	mov    $0x0,%eax
 6a5:	eb 26                	jmp    6cd <morecore+0x5e>
  hp = (Header*)p;
 6a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b0:	8b 55 08             	mov    0x8(%ebp),%edx
 6b3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b9:	83 c0 08             	add    $0x8,%eax
 6bc:	83 ec 0c             	sub    $0xc,%esp
 6bf:	50                   	push   %eax
 6c0:	e8 c8 fe ff ff       	call   58d <free>
 6c5:	83 c4 10             	add    $0x10,%esp
  return freep;
 6c8:	a1 28 0a 00 00       	mov    0xa28,%eax
}
 6cd:	c9                   	leave
 6ce:	c3                   	ret

000006cf <malloc>:

void*
malloc(uint nbytes)
{
 6cf:	55                   	push   %ebp
 6d0:	89 e5                	mov    %esp,%ebp
 6d2:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6d5:	8b 45 08             	mov    0x8(%ebp),%eax
 6d8:	83 c0 07             	add    $0x7,%eax
 6db:	c1 e8 03             	shr    $0x3,%eax
 6de:	83 c0 01             	add    $0x1,%eax
 6e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6e4:	a1 28 0a 00 00       	mov    0xa28,%eax
 6e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 6ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6f0:	75 23                	jne    715 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 6f2:	c7 45 f0 20 0a 00 00 	movl   $0xa20,-0x10(%ebp)
 6f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6fc:	a3 28 0a 00 00       	mov    %eax,0xa28
 701:	a1 28 0a 00 00       	mov    0xa28,%eax
 706:	a3 20 0a 00 00       	mov    %eax,0xa20
    base.s.size = 0;
 70b:	c7 05 24 0a 00 00 00 	movl   $0x0,0xa24
 712:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 715:	8b 45 f0             	mov    -0x10(%ebp),%eax
 718:	8b 00                	mov    (%eax),%eax
 71a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 71d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 720:	8b 40 04             	mov    0x4(%eax),%eax
 723:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 726:	72 4d                	jb     775 <malloc+0xa6>
      if(p->s.size == nunits)
 728:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72b:	8b 40 04             	mov    0x4(%eax),%eax
 72e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 731:	75 0c                	jne    73f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 733:	8b 45 f4             	mov    -0xc(%ebp),%eax
 736:	8b 10                	mov    (%eax),%edx
 738:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73b:	89 10                	mov    %edx,(%eax)
 73d:	eb 26                	jmp    765 <malloc+0x96>
      else {
        p->s.size -= nunits;
 73f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 742:	8b 40 04             	mov    0x4(%eax),%eax
 745:	2b 45 ec             	sub    -0x14(%ebp),%eax
 748:	89 c2                	mov    %eax,%edx
 74a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 750:	8b 45 f4             	mov    -0xc(%ebp),%eax
 753:	8b 40 04             	mov    0x4(%eax),%eax
 756:	c1 e0 03             	shl    $0x3,%eax
 759:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 75c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 762:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 765:	8b 45 f0             	mov    -0x10(%ebp),%eax
 768:	a3 28 0a 00 00       	mov    %eax,0xa28
      return (void*)(p + 1);
 76d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 770:	83 c0 08             	add    $0x8,%eax
 773:	eb 3b                	jmp    7b0 <malloc+0xe1>
    }
    if(p == freep)
 775:	a1 28 0a 00 00       	mov    0xa28,%eax
 77a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 77d:	75 1e                	jne    79d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 77f:	83 ec 0c             	sub    $0xc,%esp
 782:	ff 75 ec             	push   -0x14(%ebp)
 785:	e8 e5 fe ff ff       	call   66f <morecore>
 78a:	83 c4 10             	add    $0x10,%esp
 78d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 790:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 794:	75 07                	jne    79d <malloc+0xce>
        return 0;
 796:	b8 00 00 00 00       	mov    $0x0,%eax
 79b:	eb 13                	jmp    7b0 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a6:	8b 00                	mov    (%eax),%eax
 7a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7ab:	e9 6d ff ff ff       	jmp    71d <malloc+0x4e>
  }
}
 7b0:	c9                   	leave
 7b1:	c3                   	ret
