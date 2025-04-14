
_hello2:     file format elf32-i386


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
  14:	68 c4 07 00 00       	push   $0x7c4
  19:	6a 01                	push   $0x1
  1b:	e8 ed 03 00 00       	call   40d <printf>
  20:	83 c4 10             	add    $0x10,%esp
	printf(1, "My student # is 202101480.\n");
  23:	83 ec 08             	sub    $0x8,%esp
  26:	68 d2 07 00 00       	push   $0x7d2
  2b:	6a 01                	push   $0x1
  2d:	e8 db 03 00 00       	call   40d <printf>
  32:	83 c4 10             	add    $0x10,%esp
	exit();
  35:	e8 57 02 00 00       	call   291 <exit>

0000003a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  3a:	55                   	push   %ebp
  3b:	89 e5                	mov    %esp,%ebp
  3d:	57                   	push   %edi
  3e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  42:	8b 55 10             	mov    0x10(%ebp),%edx
  45:	8b 45 0c             	mov    0xc(%ebp),%eax
  48:	89 cb                	mov    %ecx,%ebx
  4a:	89 df                	mov    %ebx,%edi
  4c:	89 d1                	mov    %edx,%ecx
  4e:	fc                   	cld
  4f:	f3 aa                	rep stos %al,%es:(%edi)
  51:	89 ca                	mov    %ecx,%edx
  53:	89 fb                	mov    %edi,%ebx
  55:	89 5d 08             	mov    %ebx,0x8(%ebp)
  58:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  5b:	90                   	nop
  5c:	5b                   	pop    %ebx
  5d:	5f                   	pop    %edi
  5e:	5d                   	pop    %ebp
  5f:	c3                   	ret

00000060 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  60:	55                   	push   %ebp
  61:	89 e5                	mov    %esp,%ebp
  63:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  66:	8b 45 08             	mov    0x8(%ebp),%eax
  69:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  6c:	90                   	nop
  6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  70:	8d 42 01             	lea    0x1(%edx),%eax
  73:	89 45 0c             	mov    %eax,0xc(%ebp)
  76:	8b 45 08             	mov    0x8(%ebp),%eax
  79:	8d 48 01             	lea    0x1(%eax),%ecx
  7c:	89 4d 08             	mov    %ecx,0x8(%ebp)
  7f:	0f b6 12             	movzbl (%edx),%edx
  82:	88 10                	mov    %dl,(%eax)
  84:	0f b6 00             	movzbl (%eax),%eax
  87:	84 c0                	test   %al,%al
  89:	75 e2                	jne    6d <strcpy+0xd>
    ;
  return os;
  8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8e:	c9                   	leave
  8f:	c3                   	ret

00000090 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  90:	55                   	push   %ebp
  91:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  93:	eb 08                	jmp    9d <strcmp+0xd>
    p++, q++;
  95:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  99:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  9d:	8b 45 08             	mov    0x8(%ebp),%eax
  a0:	0f b6 00             	movzbl (%eax),%eax
  a3:	84 c0                	test   %al,%al
  a5:	74 10                	je     b7 <strcmp+0x27>
  a7:	8b 45 08             	mov    0x8(%ebp),%eax
  aa:	0f b6 10             	movzbl (%eax),%edx
  ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  b0:	0f b6 00             	movzbl (%eax),%eax
  b3:	38 c2                	cmp    %al,%dl
  b5:	74 de                	je     95 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  b7:	8b 45 08             	mov    0x8(%ebp),%eax
  ba:	0f b6 00             	movzbl (%eax),%eax
  bd:	0f b6 d0             	movzbl %al,%edx
  c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  c3:	0f b6 00             	movzbl (%eax),%eax
  c6:	0f b6 c0             	movzbl %al,%eax
  c9:	29 c2                	sub    %eax,%edx
  cb:	89 d0                	mov    %edx,%eax
}
  cd:	5d                   	pop    %ebp
  ce:	c3                   	ret

000000cf <strlen>:

uint
strlen(char *s)
{
  cf:	55                   	push   %ebp
  d0:	89 e5                	mov    %esp,%ebp
  d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  dc:	eb 04                	jmp    e2 <strlen+0x13>
  de:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  e5:	8b 45 08             	mov    0x8(%ebp),%eax
  e8:	01 d0                	add    %edx,%eax
  ea:	0f b6 00             	movzbl (%eax),%eax
  ed:	84 c0                	test   %al,%al
  ef:	75 ed                	jne    de <strlen+0xf>
    ;
  return n;
  f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f4:	c9                   	leave
  f5:	c3                   	ret

000000f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f6:	55                   	push   %ebp
  f7:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
  f9:	8b 45 10             	mov    0x10(%ebp),%eax
  fc:	50                   	push   %eax
  fd:	ff 75 0c             	push   0xc(%ebp)
 100:	ff 75 08             	push   0x8(%ebp)
 103:	e8 32 ff ff ff       	call   3a <stosb>
 108:	83 c4 0c             	add    $0xc,%esp
  return dst;
 10b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 10e:	c9                   	leave
 10f:	c3                   	ret

00000110 <strchr>:

char*
strchr(const char *s, char c)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	83 ec 04             	sub    $0x4,%esp
 116:	8b 45 0c             	mov    0xc(%ebp),%eax
 119:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 11c:	eb 14                	jmp    132 <strchr+0x22>
    if(*s == c)
 11e:	8b 45 08             	mov    0x8(%ebp),%eax
 121:	0f b6 00             	movzbl (%eax),%eax
 124:	38 45 fc             	cmp    %al,-0x4(%ebp)
 127:	75 05                	jne    12e <strchr+0x1e>
      return (char*)s;
 129:	8b 45 08             	mov    0x8(%ebp),%eax
 12c:	eb 13                	jmp    141 <strchr+0x31>
  for(; *s; s++)
 12e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 132:	8b 45 08             	mov    0x8(%ebp),%eax
 135:	0f b6 00             	movzbl (%eax),%eax
 138:	84 c0                	test   %al,%al
 13a:	75 e2                	jne    11e <strchr+0xe>
  return 0;
 13c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 141:	c9                   	leave
 142:	c3                   	ret

00000143 <gets>:

char*
gets(char *buf, int max)
{
 143:	55                   	push   %ebp
 144:	89 e5                	mov    %esp,%ebp
 146:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 149:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 150:	eb 42                	jmp    194 <gets+0x51>
    cc = read(0, &c, 1);
 152:	83 ec 04             	sub    $0x4,%esp
 155:	6a 01                	push   $0x1
 157:	8d 45 ef             	lea    -0x11(%ebp),%eax
 15a:	50                   	push   %eax
 15b:	6a 00                	push   $0x0
 15d:	e8 47 01 00 00       	call   2a9 <read>
 162:	83 c4 10             	add    $0x10,%esp
 165:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 168:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 16c:	7e 33                	jle    1a1 <gets+0x5e>
      break;
    buf[i++] = c;
 16e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 171:	8d 50 01             	lea    0x1(%eax),%edx
 174:	89 55 f4             	mov    %edx,-0xc(%ebp)
 177:	89 c2                	mov    %eax,%edx
 179:	8b 45 08             	mov    0x8(%ebp),%eax
 17c:	01 c2                	add    %eax,%edx
 17e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 182:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 184:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 188:	3c 0a                	cmp    $0xa,%al
 18a:	74 16                	je     1a2 <gets+0x5f>
 18c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 190:	3c 0d                	cmp    $0xd,%al
 192:	74 0e                	je     1a2 <gets+0x5f>
  for(i=0; i+1 < max; ){
 194:	8b 45 f4             	mov    -0xc(%ebp),%eax
 197:	83 c0 01             	add    $0x1,%eax
 19a:	39 45 0c             	cmp    %eax,0xc(%ebp)
 19d:	7f b3                	jg     152 <gets+0xf>
 19f:	eb 01                	jmp    1a2 <gets+0x5f>
      break;
 1a1:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1a5:	8b 45 08             	mov    0x8(%ebp),%eax
 1a8:	01 d0                	add    %edx,%eax
 1aa:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1ad:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1b0:	c9                   	leave
 1b1:	c3                   	ret

000001b2 <stat>:

int
stat(char *n, struct stat *st)
{
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b8:	83 ec 08             	sub    $0x8,%esp
 1bb:	6a 00                	push   $0x0
 1bd:	ff 75 08             	push   0x8(%ebp)
 1c0:	e8 0c 01 00 00       	call   2d1 <open>
 1c5:	83 c4 10             	add    $0x10,%esp
 1c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1cf:	79 07                	jns    1d8 <stat+0x26>
    return -1;
 1d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1d6:	eb 25                	jmp    1fd <stat+0x4b>
  r = fstat(fd, st);
 1d8:	83 ec 08             	sub    $0x8,%esp
 1db:	ff 75 0c             	push   0xc(%ebp)
 1de:	ff 75 f4             	push   -0xc(%ebp)
 1e1:	e8 03 01 00 00       	call   2e9 <fstat>
 1e6:	83 c4 10             	add    $0x10,%esp
 1e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1ec:	83 ec 0c             	sub    $0xc,%esp
 1ef:	ff 75 f4             	push   -0xc(%ebp)
 1f2:	e8 c2 00 00 00       	call   2b9 <close>
 1f7:	83 c4 10             	add    $0x10,%esp
  return r;
 1fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1fd:	c9                   	leave
 1fe:	c3                   	ret

000001ff <atoi>:

int
atoi(const char *s)
{
 1ff:	55                   	push   %ebp
 200:	89 e5                	mov    %esp,%ebp
 202:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 205:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 20c:	eb 25                	jmp    233 <atoi+0x34>
    n = n*10 + *s++ - '0';
 20e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 211:	89 d0                	mov    %edx,%eax
 213:	c1 e0 02             	shl    $0x2,%eax
 216:	01 d0                	add    %edx,%eax
 218:	01 c0                	add    %eax,%eax
 21a:	89 c1                	mov    %eax,%ecx
 21c:	8b 45 08             	mov    0x8(%ebp),%eax
 21f:	8d 50 01             	lea    0x1(%eax),%edx
 222:	89 55 08             	mov    %edx,0x8(%ebp)
 225:	0f b6 00             	movzbl (%eax),%eax
 228:	0f be c0             	movsbl %al,%eax
 22b:	01 c8                	add    %ecx,%eax
 22d:	83 e8 30             	sub    $0x30,%eax
 230:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	0f b6 00             	movzbl (%eax),%eax
 239:	3c 2f                	cmp    $0x2f,%al
 23b:	7e 0a                	jle    247 <atoi+0x48>
 23d:	8b 45 08             	mov    0x8(%ebp),%eax
 240:	0f b6 00             	movzbl (%eax),%eax
 243:	3c 39                	cmp    $0x39,%al
 245:	7e c7                	jle    20e <atoi+0xf>
  return n;
 247:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 24a:	c9                   	leave
 24b:	c3                   	ret

0000024c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 24c:	55                   	push   %ebp
 24d:	89 e5                	mov    %esp,%ebp
 24f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 252:	8b 45 08             	mov    0x8(%ebp),%eax
 255:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 258:	8b 45 0c             	mov    0xc(%ebp),%eax
 25b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 25e:	eb 17                	jmp    277 <memmove+0x2b>
    *dst++ = *src++;
 260:	8b 55 f8             	mov    -0x8(%ebp),%edx
 263:	8d 42 01             	lea    0x1(%edx),%eax
 266:	89 45 f8             	mov    %eax,-0x8(%ebp)
 269:	8b 45 fc             	mov    -0x4(%ebp),%eax
 26c:	8d 48 01             	lea    0x1(%eax),%ecx
 26f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 272:	0f b6 12             	movzbl (%edx),%edx
 275:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 277:	8b 45 10             	mov    0x10(%ebp),%eax
 27a:	8d 50 ff             	lea    -0x1(%eax),%edx
 27d:	89 55 10             	mov    %edx,0x10(%ebp)
 280:	85 c0                	test   %eax,%eax
 282:	7f dc                	jg     260 <memmove+0x14>
  return vdst;
 284:	8b 45 08             	mov    0x8(%ebp),%eax
}
 287:	c9                   	leave
 288:	c3                   	ret

00000289 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 289:	b8 01 00 00 00       	mov    $0x1,%eax
 28e:	cd 40                	int    $0x40
 290:	c3                   	ret

00000291 <exit>:
SYSCALL(exit)
 291:	b8 02 00 00 00       	mov    $0x2,%eax
 296:	cd 40                	int    $0x40
 298:	c3                   	ret

00000299 <wait>:
SYSCALL(wait)
 299:	b8 03 00 00 00       	mov    $0x3,%eax
 29e:	cd 40                	int    $0x40
 2a0:	c3                   	ret

000002a1 <pipe>:
SYSCALL(pipe)
 2a1:	b8 04 00 00 00       	mov    $0x4,%eax
 2a6:	cd 40                	int    $0x40
 2a8:	c3                   	ret

000002a9 <read>:
SYSCALL(read)
 2a9:	b8 05 00 00 00       	mov    $0x5,%eax
 2ae:	cd 40                	int    $0x40
 2b0:	c3                   	ret

000002b1 <write>:
SYSCALL(write)
 2b1:	b8 10 00 00 00       	mov    $0x10,%eax
 2b6:	cd 40                	int    $0x40
 2b8:	c3                   	ret

000002b9 <close>:
SYSCALL(close)
 2b9:	b8 15 00 00 00       	mov    $0x15,%eax
 2be:	cd 40                	int    $0x40
 2c0:	c3                   	ret

000002c1 <kill>:
SYSCALL(kill)
 2c1:	b8 06 00 00 00       	mov    $0x6,%eax
 2c6:	cd 40                	int    $0x40
 2c8:	c3                   	ret

000002c9 <exec>:
SYSCALL(exec)
 2c9:	b8 07 00 00 00       	mov    $0x7,%eax
 2ce:	cd 40                	int    $0x40
 2d0:	c3                   	ret

000002d1 <open>:
SYSCALL(open)
 2d1:	b8 0f 00 00 00       	mov    $0xf,%eax
 2d6:	cd 40                	int    $0x40
 2d8:	c3                   	ret

000002d9 <mknod>:
SYSCALL(mknod)
 2d9:	b8 11 00 00 00       	mov    $0x11,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret

000002e1 <unlink>:
SYSCALL(unlink)
 2e1:	b8 12 00 00 00       	mov    $0x12,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret

000002e9 <fstat>:
SYSCALL(fstat)
 2e9:	b8 08 00 00 00       	mov    $0x8,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret

000002f1 <link>:
SYSCALL(link)
 2f1:	b8 13 00 00 00       	mov    $0x13,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret

000002f9 <mkdir>:
SYSCALL(mkdir)
 2f9:	b8 14 00 00 00       	mov    $0x14,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret

00000301 <chdir>:
SYSCALL(chdir)
 301:	b8 09 00 00 00       	mov    $0x9,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret

00000309 <dup>:
SYSCALL(dup)
 309:	b8 0a 00 00 00       	mov    $0xa,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret

00000311 <getpid>:
SYSCALL(getpid)
 311:	b8 0b 00 00 00       	mov    $0xb,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret

00000319 <sbrk>:
SYSCALL(sbrk)
 319:	b8 0c 00 00 00       	mov    $0xc,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret

00000321 <sleep>:
SYSCALL(sleep)
 321:	b8 0d 00 00 00       	mov    $0xd,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret

00000329 <uptime>:
SYSCALL(uptime)
 329:	b8 0e 00 00 00       	mov    $0xe,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret

00000331 <uthread_init>:
SYSCALL(uthread_init)
 331:	b8 16 00 00 00       	mov    $0x16,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret

00000339 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 339:	55                   	push   %ebp
 33a:	89 e5                	mov    %esp,%ebp
 33c:	83 ec 18             	sub    $0x18,%esp
 33f:	8b 45 0c             	mov    0xc(%ebp),%eax
 342:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 345:	83 ec 04             	sub    $0x4,%esp
 348:	6a 01                	push   $0x1
 34a:	8d 45 f4             	lea    -0xc(%ebp),%eax
 34d:	50                   	push   %eax
 34e:	ff 75 08             	push   0x8(%ebp)
 351:	e8 5b ff ff ff       	call   2b1 <write>
 356:	83 c4 10             	add    $0x10,%esp
}
 359:	90                   	nop
 35a:	c9                   	leave
 35b:	c3                   	ret

0000035c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 35c:	55                   	push   %ebp
 35d:	89 e5                	mov    %esp,%ebp
 35f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 362:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 369:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 36d:	74 17                	je     386 <printint+0x2a>
 36f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 373:	79 11                	jns    386 <printint+0x2a>
    neg = 1;
 375:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 37c:	8b 45 0c             	mov    0xc(%ebp),%eax
 37f:	f7 d8                	neg    %eax
 381:	89 45 ec             	mov    %eax,-0x14(%ebp)
 384:	eb 06                	jmp    38c <printint+0x30>
  } else {
    x = xx;
 386:	8b 45 0c             	mov    0xc(%ebp),%eax
 389:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 38c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 393:	8b 4d 10             	mov    0x10(%ebp),%ecx
 396:	8b 45 ec             	mov    -0x14(%ebp),%eax
 399:	ba 00 00 00 00       	mov    $0x0,%edx
 39e:	f7 f1                	div    %ecx
 3a0:	89 d1                	mov    %edx,%ecx
 3a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a5:	8d 50 01             	lea    0x1(%eax),%edx
 3a8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3ab:	0f b6 91 3c 0a 00 00 	movzbl 0xa3c(%ecx),%edx
 3b2:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3bc:	ba 00 00 00 00       	mov    $0x0,%edx
 3c1:	f7 f1                	div    %ecx
 3c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3c6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3ca:	75 c7                	jne    393 <printint+0x37>
  if(neg)
 3cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3d0:	74 2d                	je     3ff <printint+0xa3>
    buf[i++] = '-';
 3d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d5:	8d 50 01             	lea    0x1(%eax),%edx
 3d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3db:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3e0:	eb 1d                	jmp    3ff <printint+0xa3>
    putc(fd, buf[i]);
 3e2:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e8:	01 d0                	add    %edx,%eax
 3ea:	0f b6 00             	movzbl (%eax),%eax
 3ed:	0f be c0             	movsbl %al,%eax
 3f0:	83 ec 08             	sub    $0x8,%esp
 3f3:	50                   	push   %eax
 3f4:	ff 75 08             	push   0x8(%ebp)
 3f7:	e8 3d ff ff ff       	call   339 <putc>
 3fc:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 3ff:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 403:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 407:	79 d9                	jns    3e2 <printint+0x86>
}
 409:	90                   	nop
 40a:	90                   	nop
 40b:	c9                   	leave
 40c:	c3                   	ret

0000040d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 40d:	55                   	push   %ebp
 40e:	89 e5                	mov    %esp,%ebp
 410:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 413:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 41a:	8d 45 0c             	lea    0xc(%ebp),%eax
 41d:	83 c0 04             	add    $0x4,%eax
 420:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 423:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 42a:	e9 59 01 00 00       	jmp    588 <printf+0x17b>
    c = fmt[i] & 0xff;
 42f:	8b 55 0c             	mov    0xc(%ebp),%edx
 432:	8b 45 f0             	mov    -0x10(%ebp),%eax
 435:	01 d0                	add    %edx,%eax
 437:	0f b6 00             	movzbl (%eax),%eax
 43a:	0f be c0             	movsbl %al,%eax
 43d:	25 ff 00 00 00       	and    $0xff,%eax
 442:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 445:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 449:	75 2c                	jne    477 <printf+0x6a>
      if(c == '%'){
 44b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 44f:	75 0c                	jne    45d <printf+0x50>
        state = '%';
 451:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 458:	e9 27 01 00 00       	jmp    584 <printf+0x177>
      } else {
        putc(fd, c);
 45d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 460:	0f be c0             	movsbl %al,%eax
 463:	83 ec 08             	sub    $0x8,%esp
 466:	50                   	push   %eax
 467:	ff 75 08             	push   0x8(%ebp)
 46a:	e8 ca fe ff ff       	call   339 <putc>
 46f:	83 c4 10             	add    $0x10,%esp
 472:	e9 0d 01 00 00       	jmp    584 <printf+0x177>
      }
    } else if(state == '%'){
 477:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 47b:	0f 85 03 01 00 00    	jne    584 <printf+0x177>
      if(c == 'd'){
 481:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 485:	75 1e                	jne    4a5 <printf+0x98>
        printint(fd, *ap, 10, 1);
 487:	8b 45 e8             	mov    -0x18(%ebp),%eax
 48a:	8b 00                	mov    (%eax),%eax
 48c:	6a 01                	push   $0x1
 48e:	6a 0a                	push   $0xa
 490:	50                   	push   %eax
 491:	ff 75 08             	push   0x8(%ebp)
 494:	e8 c3 fe ff ff       	call   35c <printint>
 499:	83 c4 10             	add    $0x10,%esp
        ap++;
 49c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4a0:	e9 d8 00 00 00       	jmp    57d <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4a5:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4a9:	74 06                	je     4b1 <printf+0xa4>
 4ab:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4af:	75 1e                	jne    4cf <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4b4:	8b 00                	mov    (%eax),%eax
 4b6:	6a 00                	push   $0x0
 4b8:	6a 10                	push   $0x10
 4ba:	50                   	push   %eax
 4bb:	ff 75 08             	push   0x8(%ebp)
 4be:	e8 99 fe ff ff       	call   35c <printint>
 4c3:	83 c4 10             	add    $0x10,%esp
        ap++;
 4c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4ca:	e9 ae 00 00 00       	jmp    57d <printf+0x170>
      } else if(c == 's'){
 4cf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4d3:	75 43                	jne    518 <printf+0x10b>
        s = (char*)*ap;
 4d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d8:	8b 00                	mov    (%eax),%eax
 4da:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4e5:	75 25                	jne    50c <printf+0xff>
          s = "(null)";
 4e7:	c7 45 f4 ee 07 00 00 	movl   $0x7ee,-0xc(%ebp)
        while(*s != 0){
 4ee:	eb 1c                	jmp    50c <printf+0xff>
          putc(fd, *s);
 4f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f3:	0f b6 00             	movzbl (%eax),%eax
 4f6:	0f be c0             	movsbl %al,%eax
 4f9:	83 ec 08             	sub    $0x8,%esp
 4fc:	50                   	push   %eax
 4fd:	ff 75 08             	push   0x8(%ebp)
 500:	e8 34 fe ff ff       	call   339 <putc>
 505:	83 c4 10             	add    $0x10,%esp
          s++;
 508:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 50c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50f:	0f b6 00             	movzbl (%eax),%eax
 512:	84 c0                	test   %al,%al
 514:	75 da                	jne    4f0 <printf+0xe3>
 516:	eb 65                	jmp    57d <printf+0x170>
        }
      } else if(c == 'c'){
 518:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 51c:	75 1d                	jne    53b <printf+0x12e>
        putc(fd, *ap);
 51e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 521:	8b 00                	mov    (%eax),%eax
 523:	0f be c0             	movsbl %al,%eax
 526:	83 ec 08             	sub    $0x8,%esp
 529:	50                   	push   %eax
 52a:	ff 75 08             	push   0x8(%ebp)
 52d:	e8 07 fe ff ff       	call   339 <putc>
 532:	83 c4 10             	add    $0x10,%esp
        ap++;
 535:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 539:	eb 42                	jmp    57d <printf+0x170>
      } else if(c == '%'){
 53b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 53f:	75 17                	jne    558 <printf+0x14b>
        putc(fd, c);
 541:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 544:	0f be c0             	movsbl %al,%eax
 547:	83 ec 08             	sub    $0x8,%esp
 54a:	50                   	push   %eax
 54b:	ff 75 08             	push   0x8(%ebp)
 54e:	e8 e6 fd ff ff       	call   339 <putc>
 553:	83 c4 10             	add    $0x10,%esp
 556:	eb 25                	jmp    57d <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 558:	83 ec 08             	sub    $0x8,%esp
 55b:	6a 25                	push   $0x25
 55d:	ff 75 08             	push   0x8(%ebp)
 560:	e8 d4 fd ff ff       	call   339 <putc>
 565:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 568:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 56b:	0f be c0             	movsbl %al,%eax
 56e:	83 ec 08             	sub    $0x8,%esp
 571:	50                   	push   %eax
 572:	ff 75 08             	push   0x8(%ebp)
 575:	e8 bf fd ff ff       	call   339 <putc>
 57a:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 57d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 584:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 588:	8b 55 0c             	mov    0xc(%ebp),%edx
 58b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 58e:	01 d0                	add    %edx,%eax
 590:	0f b6 00             	movzbl (%eax),%eax
 593:	84 c0                	test   %al,%al
 595:	0f 85 94 fe ff ff    	jne    42f <printf+0x22>
    }
  }
}
 59b:	90                   	nop
 59c:	90                   	nop
 59d:	c9                   	leave
 59e:	c3                   	ret

0000059f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 59f:	55                   	push   %ebp
 5a0:	89 e5                	mov    %esp,%ebp
 5a2:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5a5:	8b 45 08             	mov    0x8(%ebp),%eax
 5a8:	83 e8 08             	sub    $0x8,%eax
 5ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5ae:	a1 58 0a 00 00       	mov    0xa58,%eax
 5b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5b6:	eb 24                	jmp    5dc <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5bb:	8b 00                	mov    (%eax),%eax
 5bd:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5c0:	72 12                	jb     5d4 <free+0x35>
 5c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5c5:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5c8:	72 24                	jb     5ee <free+0x4f>
 5ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5cd:	8b 00                	mov    (%eax),%eax
 5cf:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5d2:	72 1a                	jb     5ee <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d7:	8b 00                	mov    (%eax),%eax
 5d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5df:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5e2:	73 d4                	jae    5b8 <free+0x19>
 5e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e7:	8b 00                	mov    (%eax),%eax
 5e9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5ec:	73 ca                	jae    5b8 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f1:	8b 40 04             	mov    0x4(%eax),%eax
 5f4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 5fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5fe:	01 c2                	add    %eax,%edx
 600:	8b 45 fc             	mov    -0x4(%ebp),%eax
 603:	8b 00                	mov    (%eax),%eax
 605:	39 c2                	cmp    %eax,%edx
 607:	75 24                	jne    62d <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 609:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60c:	8b 50 04             	mov    0x4(%eax),%edx
 60f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 612:	8b 00                	mov    (%eax),%eax
 614:	8b 40 04             	mov    0x4(%eax),%eax
 617:	01 c2                	add    %eax,%edx
 619:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 61f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 622:	8b 00                	mov    (%eax),%eax
 624:	8b 10                	mov    (%eax),%edx
 626:	8b 45 f8             	mov    -0x8(%ebp),%eax
 629:	89 10                	mov    %edx,(%eax)
 62b:	eb 0a                	jmp    637 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 62d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 630:	8b 10                	mov    (%eax),%edx
 632:	8b 45 f8             	mov    -0x8(%ebp),%eax
 635:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 637:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63a:	8b 40 04             	mov    0x4(%eax),%eax
 63d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 644:	8b 45 fc             	mov    -0x4(%ebp),%eax
 647:	01 d0                	add    %edx,%eax
 649:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 64c:	75 20                	jne    66e <free+0xcf>
    p->s.size += bp->s.size;
 64e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 651:	8b 50 04             	mov    0x4(%eax),%edx
 654:	8b 45 f8             	mov    -0x8(%ebp),%eax
 657:	8b 40 04             	mov    0x4(%eax),%eax
 65a:	01 c2                	add    %eax,%edx
 65c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 662:	8b 45 f8             	mov    -0x8(%ebp),%eax
 665:	8b 10                	mov    (%eax),%edx
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	89 10                	mov    %edx,(%eax)
 66c:	eb 08                	jmp    676 <free+0xd7>
  } else
    p->s.ptr = bp;
 66e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 671:	8b 55 f8             	mov    -0x8(%ebp),%edx
 674:	89 10                	mov    %edx,(%eax)
  freep = p;
 676:	8b 45 fc             	mov    -0x4(%ebp),%eax
 679:	a3 58 0a 00 00       	mov    %eax,0xa58
}
 67e:	90                   	nop
 67f:	c9                   	leave
 680:	c3                   	ret

00000681 <morecore>:

static Header*
morecore(uint nu)
{
 681:	55                   	push   %ebp
 682:	89 e5                	mov    %esp,%ebp
 684:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 687:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 68e:	77 07                	ja     697 <morecore+0x16>
    nu = 4096;
 690:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 697:	8b 45 08             	mov    0x8(%ebp),%eax
 69a:	c1 e0 03             	shl    $0x3,%eax
 69d:	83 ec 0c             	sub    $0xc,%esp
 6a0:	50                   	push   %eax
 6a1:	e8 73 fc ff ff       	call   319 <sbrk>
 6a6:	83 c4 10             	add    $0x10,%esp
 6a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6ac:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6b0:	75 07                	jne    6b9 <morecore+0x38>
    return 0;
 6b2:	b8 00 00 00 00       	mov    $0x0,%eax
 6b7:	eb 26                	jmp    6df <morecore+0x5e>
  hp = (Header*)p;
 6b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c2:	8b 55 08             	mov    0x8(%ebp),%edx
 6c5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6cb:	83 c0 08             	add    $0x8,%eax
 6ce:	83 ec 0c             	sub    $0xc,%esp
 6d1:	50                   	push   %eax
 6d2:	e8 c8 fe ff ff       	call   59f <free>
 6d7:	83 c4 10             	add    $0x10,%esp
  return freep;
 6da:	a1 58 0a 00 00       	mov    0xa58,%eax
}
 6df:	c9                   	leave
 6e0:	c3                   	ret

000006e1 <malloc>:

void*
malloc(uint nbytes)
{
 6e1:	55                   	push   %ebp
 6e2:	89 e5                	mov    %esp,%ebp
 6e4:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6e7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ea:	83 c0 07             	add    $0x7,%eax
 6ed:	c1 e8 03             	shr    $0x3,%eax
 6f0:	83 c0 01             	add    $0x1,%eax
 6f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6f6:	a1 58 0a 00 00       	mov    0xa58,%eax
 6fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 6fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 702:	75 23                	jne    727 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 704:	c7 45 f0 50 0a 00 00 	movl   $0xa50,-0x10(%ebp)
 70b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 70e:	a3 58 0a 00 00       	mov    %eax,0xa58
 713:	a1 58 0a 00 00       	mov    0xa58,%eax
 718:	a3 50 0a 00 00       	mov    %eax,0xa50
    base.s.size = 0;
 71d:	c7 05 54 0a 00 00 00 	movl   $0x0,0xa54
 724:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 727:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72a:	8b 00                	mov    (%eax),%eax
 72c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 72f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 732:	8b 40 04             	mov    0x4(%eax),%eax
 735:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 738:	72 4d                	jb     787 <malloc+0xa6>
      if(p->s.size == nunits)
 73a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73d:	8b 40 04             	mov    0x4(%eax),%eax
 740:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 743:	75 0c                	jne    751 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 745:	8b 45 f4             	mov    -0xc(%ebp),%eax
 748:	8b 10                	mov    (%eax),%edx
 74a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74d:	89 10                	mov    %edx,(%eax)
 74f:	eb 26                	jmp    777 <malloc+0x96>
      else {
        p->s.size -= nunits;
 751:	8b 45 f4             	mov    -0xc(%ebp),%eax
 754:	8b 40 04             	mov    0x4(%eax),%eax
 757:	2b 45 ec             	sub    -0x14(%ebp),%eax
 75a:	89 c2                	mov    %eax,%edx
 75c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 762:	8b 45 f4             	mov    -0xc(%ebp),%eax
 765:	8b 40 04             	mov    0x4(%eax),%eax
 768:	c1 e0 03             	shl    $0x3,%eax
 76b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 76e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 771:	8b 55 ec             	mov    -0x14(%ebp),%edx
 774:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 777:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77a:	a3 58 0a 00 00       	mov    %eax,0xa58
      return (void*)(p + 1);
 77f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 782:	83 c0 08             	add    $0x8,%eax
 785:	eb 3b                	jmp    7c2 <malloc+0xe1>
    }
    if(p == freep)
 787:	a1 58 0a 00 00       	mov    0xa58,%eax
 78c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 78f:	75 1e                	jne    7af <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 791:	83 ec 0c             	sub    $0xc,%esp
 794:	ff 75 ec             	push   -0x14(%ebp)
 797:	e8 e5 fe ff ff       	call   681 <morecore>
 79c:	83 c4 10             	add    $0x10,%esp
 79f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7a6:	75 07                	jne    7af <malloc+0xce>
        return 0;
 7a8:	b8 00 00 00 00       	mov    $0x0,%eax
 7ad:	eb 13                	jmp    7c2 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b8:	8b 00                	mov    (%eax),%eax
 7ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7bd:	e9 6d ff ff ff       	jmp    72f <malloc+0x4e>
  }
}
 7c2:	c9                   	leave
 7c3:	c3                   	ret
