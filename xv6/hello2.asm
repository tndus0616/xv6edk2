
_hello2:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"

int main(int argc, char *argv[]){
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
 printf(1, "Hello world!\n");
  11:	83 ec 08             	sub    $0x8,%esp
  14:	68 bc 07 00 00       	push   $0x7bc
  19:	6a 01                	push   $0x1
  1b:	e8 e5 03 00 00       	call   405 <printf>
  20:	83 c4 10             	add    $0x10,%esp
 printf(1, "My student # is 201901593.\n");
  23:	83 ec 08             	sub    $0x8,%esp
  26:	68 ca 07 00 00       	push   $0x7ca
  2b:	6a 01                	push   $0x1
  2d:	e8 d3 03 00 00       	call   405 <printf>
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
  c6:	0f b6 c8             	movzbl %al,%ecx
  c9:	89 d0                	mov    %edx,%eax
  cb:	29 c8                	sub    %ecx,%eax
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

00000331 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 331:	55                   	push   %ebp
 332:	89 e5                	mov    %esp,%ebp
 334:	83 ec 18             	sub    $0x18,%esp
 337:	8b 45 0c             	mov    0xc(%ebp),%eax
 33a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 33d:	83 ec 04             	sub    $0x4,%esp
 340:	6a 01                	push   $0x1
 342:	8d 45 f4             	lea    -0xc(%ebp),%eax
 345:	50                   	push   %eax
 346:	ff 75 08             	push   0x8(%ebp)
 349:	e8 63 ff ff ff       	call   2b1 <write>
 34e:	83 c4 10             	add    $0x10,%esp
}
 351:	90                   	nop
 352:	c9                   	leave  
 353:	c3                   	ret    

00000354 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp
 357:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 35a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 361:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 365:	74 17                	je     37e <printint+0x2a>
 367:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 36b:	79 11                	jns    37e <printint+0x2a>
    neg = 1;
 36d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 374:	8b 45 0c             	mov    0xc(%ebp),%eax
 377:	f7 d8                	neg    %eax
 379:	89 45 ec             	mov    %eax,-0x14(%ebp)
 37c:	eb 06                	jmp    384 <printint+0x30>
  } else {
    x = xx;
 37e:	8b 45 0c             	mov    0xc(%ebp),%eax
 381:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 384:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 38b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 38e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 391:	ba 00 00 00 00       	mov    $0x0,%edx
 396:	f7 f1                	div    %ecx
 398:	89 d1                	mov    %edx,%ecx
 39a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39d:	8d 50 01             	lea    0x1(%eax),%edx
 3a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3a3:	0f b6 91 34 0a 00 00 	movzbl 0xa34(%ecx),%edx
 3aa:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3b4:	ba 00 00 00 00       	mov    $0x0,%edx
 3b9:	f7 f1                	div    %ecx
 3bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3be:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3c2:	75 c7                	jne    38b <printint+0x37>
  if(neg)
 3c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3c8:	74 2d                	je     3f7 <printint+0xa3>
    buf[i++] = '-';
 3ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3cd:	8d 50 01             	lea    0x1(%eax),%edx
 3d0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3d3:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3d8:	eb 1d                	jmp    3f7 <printint+0xa3>
    putc(fd, buf[i]);
 3da:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e0:	01 d0                	add    %edx,%eax
 3e2:	0f b6 00             	movzbl (%eax),%eax
 3e5:	0f be c0             	movsbl %al,%eax
 3e8:	83 ec 08             	sub    $0x8,%esp
 3eb:	50                   	push   %eax
 3ec:	ff 75 08             	push   0x8(%ebp)
 3ef:	e8 3d ff ff ff       	call   331 <putc>
 3f4:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 3f7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 3fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3ff:	79 d9                	jns    3da <printint+0x86>
}
 401:	90                   	nop
 402:	90                   	nop
 403:	c9                   	leave  
 404:	c3                   	ret    

00000405 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 405:	55                   	push   %ebp
 406:	89 e5                	mov    %esp,%ebp
 408:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 40b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 412:	8d 45 0c             	lea    0xc(%ebp),%eax
 415:	83 c0 04             	add    $0x4,%eax
 418:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 41b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 422:	e9 59 01 00 00       	jmp    580 <printf+0x17b>
    c = fmt[i] & 0xff;
 427:	8b 55 0c             	mov    0xc(%ebp),%edx
 42a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 42d:	01 d0                	add    %edx,%eax
 42f:	0f b6 00             	movzbl (%eax),%eax
 432:	0f be c0             	movsbl %al,%eax
 435:	25 ff 00 00 00       	and    $0xff,%eax
 43a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 43d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 441:	75 2c                	jne    46f <printf+0x6a>
      if(c == '%'){
 443:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 447:	75 0c                	jne    455 <printf+0x50>
        state = '%';
 449:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 450:	e9 27 01 00 00       	jmp    57c <printf+0x177>
      } else {
        putc(fd, c);
 455:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 458:	0f be c0             	movsbl %al,%eax
 45b:	83 ec 08             	sub    $0x8,%esp
 45e:	50                   	push   %eax
 45f:	ff 75 08             	push   0x8(%ebp)
 462:	e8 ca fe ff ff       	call   331 <putc>
 467:	83 c4 10             	add    $0x10,%esp
 46a:	e9 0d 01 00 00       	jmp    57c <printf+0x177>
      }
    } else if(state == '%'){
 46f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 473:	0f 85 03 01 00 00    	jne    57c <printf+0x177>
      if(c == 'd'){
 479:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 47d:	75 1e                	jne    49d <printf+0x98>
        printint(fd, *ap, 10, 1);
 47f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 482:	8b 00                	mov    (%eax),%eax
 484:	6a 01                	push   $0x1
 486:	6a 0a                	push   $0xa
 488:	50                   	push   %eax
 489:	ff 75 08             	push   0x8(%ebp)
 48c:	e8 c3 fe ff ff       	call   354 <printint>
 491:	83 c4 10             	add    $0x10,%esp
        ap++;
 494:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 498:	e9 d8 00 00 00       	jmp    575 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 49d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4a1:	74 06                	je     4a9 <printf+0xa4>
 4a3:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4a7:	75 1e                	jne    4c7 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ac:	8b 00                	mov    (%eax),%eax
 4ae:	6a 00                	push   $0x0
 4b0:	6a 10                	push   $0x10
 4b2:	50                   	push   %eax
 4b3:	ff 75 08             	push   0x8(%ebp)
 4b6:	e8 99 fe ff ff       	call   354 <printint>
 4bb:	83 c4 10             	add    $0x10,%esp
        ap++;
 4be:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4c2:	e9 ae 00 00 00       	jmp    575 <printf+0x170>
      } else if(c == 's'){
 4c7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4cb:	75 43                	jne    510 <printf+0x10b>
        s = (char*)*ap;
 4cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d0:	8b 00                	mov    (%eax),%eax
 4d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4d5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4dd:	75 25                	jne    504 <printf+0xff>
          s = "(null)";
 4df:	c7 45 f4 e6 07 00 00 	movl   $0x7e6,-0xc(%ebp)
        while(*s != 0){
 4e6:	eb 1c                	jmp    504 <printf+0xff>
          putc(fd, *s);
 4e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4eb:	0f b6 00             	movzbl (%eax),%eax
 4ee:	0f be c0             	movsbl %al,%eax
 4f1:	83 ec 08             	sub    $0x8,%esp
 4f4:	50                   	push   %eax
 4f5:	ff 75 08             	push   0x8(%ebp)
 4f8:	e8 34 fe ff ff       	call   331 <putc>
 4fd:	83 c4 10             	add    $0x10,%esp
          s++;
 500:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 504:	8b 45 f4             	mov    -0xc(%ebp),%eax
 507:	0f b6 00             	movzbl (%eax),%eax
 50a:	84 c0                	test   %al,%al
 50c:	75 da                	jne    4e8 <printf+0xe3>
 50e:	eb 65                	jmp    575 <printf+0x170>
        }
      } else if(c == 'c'){
 510:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 514:	75 1d                	jne    533 <printf+0x12e>
        putc(fd, *ap);
 516:	8b 45 e8             	mov    -0x18(%ebp),%eax
 519:	8b 00                	mov    (%eax),%eax
 51b:	0f be c0             	movsbl %al,%eax
 51e:	83 ec 08             	sub    $0x8,%esp
 521:	50                   	push   %eax
 522:	ff 75 08             	push   0x8(%ebp)
 525:	e8 07 fe ff ff       	call   331 <putc>
 52a:	83 c4 10             	add    $0x10,%esp
        ap++;
 52d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 531:	eb 42                	jmp    575 <printf+0x170>
      } else if(c == '%'){
 533:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 537:	75 17                	jne    550 <printf+0x14b>
        putc(fd, c);
 539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 53c:	0f be c0             	movsbl %al,%eax
 53f:	83 ec 08             	sub    $0x8,%esp
 542:	50                   	push   %eax
 543:	ff 75 08             	push   0x8(%ebp)
 546:	e8 e6 fd ff ff       	call   331 <putc>
 54b:	83 c4 10             	add    $0x10,%esp
 54e:	eb 25                	jmp    575 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 550:	83 ec 08             	sub    $0x8,%esp
 553:	6a 25                	push   $0x25
 555:	ff 75 08             	push   0x8(%ebp)
 558:	e8 d4 fd ff ff       	call   331 <putc>
 55d:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 560:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 563:	0f be c0             	movsbl %al,%eax
 566:	83 ec 08             	sub    $0x8,%esp
 569:	50                   	push   %eax
 56a:	ff 75 08             	push   0x8(%ebp)
 56d:	e8 bf fd ff ff       	call   331 <putc>
 572:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 575:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 57c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 580:	8b 55 0c             	mov    0xc(%ebp),%edx
 583:	8b 45 f0             	mov    -0x10(%ebp),%eax
 586:	01 d0                	add    %edx,%eax
 588:	0f b6 00             	movzbl (%eax),%eax
 58b:	84 c0                	test   %al,%al
 58d:	0f 85 94 fe ff ff    	jne    427 <printf+0x22>
    }
  }
}
 593:	90                   	nop
 594:	90                   	nop
 595:	c9                   	leave  
 596:	c3                   	ret    

00000597 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 597:	55                   	push   %ebp
 598:	89 e5                	mov    %esp,%ebp
 59a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 59d:	8b 45 08             	mov    0x8(%ebp),%eax
 5a0:	83 e8 08             	sub    $0x8,%eax
 5a3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5a6:	a1 50 0a 00 00       	mov    0xa50,%eax
 5ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5ae:	eb 24                	jmp    5d4 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5b3:	8b 00                	mov    (%eax),%eax
 5b5:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5b8:	72 12                	jb     5cc <free+0x35>
 5ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5bd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5c0:	77 24                	ja     5e6 <free+0x4f>
 5c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c5:	8b 00                	mov    (%eax),%eax
 5c7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5ca:	72 1a                	jb     5e6 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5cf:	8b 00                	mov    (%eax),%eax
 5d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5d7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5da:	76 d4                	jbe    5b0 <free+0x19>
 5dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5df:	8b 00                	mov    (%eax),%eax
 5e1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5e4:	73 ca                	jae    5b0 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5e9:	8b 40 04             	mov    0x4(%eax),%eax
 5ec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 5f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f6:	01 c2                	add    %eax,%edx
 5f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fb:	8b 00                	mov    (%eax),%eax
 5fd:	39 c2                	cmp    %eax,%edx
 5ff:	75 24                	jne    625 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 601:	8b 45 f8             	mov    -0x8(%ebp),%eax
 604:	8b 50 04             	mov    0x4(%eax),%edx
 607:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60a:	8b 00                	mov    (%eax),%eax
 60c:	8b 40 04             	mov    0x4(%eax),%eax
 60f:	01 c2                	add    %eax,%edx
 611:	8b 45 f8             	mov    -0x8(%ebp),%eax
 614:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 617:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61a:	8b 00                	mov    (%eax),%eax
 61c:	8b 10                	mov    (%eax),%edx
 61e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 621:	89 10                	mov    %edx,(%eax)
 623:	eb 0a                	jmp    62f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 625:	8b 45 fc             	mov    -0x4(%ebp),%eax
 628:	8b 10                	mov    (%eax),%edx
 62a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 62f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 632:	8b 40 04             	mov    0x4(%eax),%eax
 635:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 63c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63f:	01 d0                	add    %edx,%eax
 641:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 644:	75 20                	jne    666 <free+0xcf>
    p->s.size += bp->s.size;
 646:	8b 45 fc             	mov    -0x4(%ebp),%eax
 649:	8b 50 04             	mov    0x4(%eax),%edx
 64c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64f:	8b 40 04             	mov    0x4(%eax),%eax
 652:	01 c2                	add    %eax,%edx
 654:	8b 45 fc             	mov    -0x4(%ebp),%eax
 657:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 65a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65d:	8b 10                	mov    (%eax),%edx
 65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 662:	89 10                	mov    %edx,(%eax)
 664:	eb 08                	jmp    66e <free+0xd7>
  } else
    p->s.ptr = bp;
 666:	8b 45 fc             	mov    -0x4(%ebp),%eax
 669:	8b 55 f8             	mov    -0x8(%ebp),%edx
 66c:	89 10                	mov    %edx,(%eax)
  freep = p;
 66e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 671:	a3 50 0a 00 00       	mov    %eax,0xa50
}
 676:	90                   	nop
 677:	c9                   	leave  
 678:	c3                   	ret    

00000679 <morecore>:

static Header*
morecore(uint nu)
{
 679:	55                   	push   %ebp
 67a:	89 e5                	mov    %esp,%ebp
 67c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 67f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 686:	77 07                	ja     68f <morecore+0x16>
    nu = 4096;
 688:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 68f:	8b 45 08             	mov    0x8(%ebp),%eax
 692:	c1 e0 03             	shl    $0x3,%eax
 695:	83 ec 0c             	sub    $0xc,%esp
 698:	50                   	push   %eax
 699:	e8 7b fc ff ff       	call   319 <sbrk>
 69e:	83 c4 10             	add    $0x10,%esp
 6a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6a4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6a8:	75 07                	jne    6b1 <morecore+0x38>
    return 0;
 6aa:	b8 00 00 00 00       	mov    $0x0,%eax
 6af:	eb 26                	jmp    6d7 <morecore+0x5e>
  hp = (Header*)p;
 6b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ba:	8b 55 08             	mov    0x8(%ebp),%edx
 6bd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c3:	83 c0 08             	add    $0x8,%eax
 6c6:	83 ec 0c             	sub    $0xc,%esp
 6c9:	50                   	push   %eax
 6ca:	e8 c8 fe ff ff       	call   597 <free>
 6cf:	83 c4 10             	add    $0x10,%esp
  return freep;
 6d2:	a1 50 0a 00 00       	mov    0xa50,%eax
}
 6d7:	c9                   	leave  
 6d8:	c3                   	ret    

000006d9 <malloc>:

void*
malloc(uint nbytes)
{
 6d9:	55                   	push   %ebp
 6da:	89 e5                	mov    %esp,%ebp
 6dc:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6df:	8b 45 08             	mov    0x8(%ebp),%eax
 6e2:	83 c0 07             	add    $0x7,%eax
 6e5:	c1 e8 03             	shr    $0x3,%eax
 6e8:	83 c0 01             	add    $0x1,%eax
 6eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6ee:	a1 50 0a 00 00       	mov    0xa50,%eax
 6f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 6f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6fa:	75 23                	jne    71f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 6fc:	c7 45 f0 48 0a 00 00 	movl   $0xa48,-0x10(%ebp)
 703:	8b 45 f0             	mov    -0x10(%ebp),%eax
 706:	a3 50 0a 00 00       	mov    %eax,0xa50
 70b:	a1 50 0a 00 00       	mov    0xa50,%eax
 710:	a3 48 0a 00 00       	mov    %eax,0xa48
    base.s.size = 0;
 715:	c7 05 4c 0a 00 00 00 	movl   $0x0,0xa4c
 71c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 71f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 722:	8b 00                	mov    (%eax),%eax
 724:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 727:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72a:	8b 40 04             	mov    0x4(%eax),%eax
 72d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 730:	77 4d                	ja     77f <malloc+0xa6>
      if(p->s.size == nunits)
 732:	8b 45 f4             	mov    -0xc(%ebp),%eax
 735:	8b 40 04             	mov    0x4(%eax),%eax
 738:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 73b:	75 0c                	jne    749 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 73d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 740:	8b 10                	mov    (%eax),%edx
 742:	8b 45 f0             	mov    -0x10(%ebp),%eax
 745:	89 10                	mov    %edx,(%eax)
 747:	eb 26                	jmp    76f <malloc+0x96>
      else {
        p->s.size -= nunits;
 749:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74c:	8b 40 04             	mov    0x4(%eax),%eax
 74f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 752:	89 c2                	mov    %eax,%edx
 754:	8b 45 f4             	mov    -0xc(%ebp),%eax
 757:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 75a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75d:	8b 40 04             	mov    0x4(%eax),%eax
 760:	c1 e0 03             	shl    $0x3,%eax
 763:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 766:	8b 45 f4             	mov    -0xc(%ebp),%eax
 769:	8b 55 ec             	mov    -0x14(%ebp),%edx
 76c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 76f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 772:	a3 50 0a 00 00       	mov    %eax,0xa50
      return (void*)(p + 1);
 777:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77a:	83 c0 08             	add    $0x8,%eax
 77d:	eb 3b                	jmp    7ba <malloc+0xe1>
    }
    if(p == freep)
 77f:	a1 50 0a 00 00       	mov    0xa50,%eax
 784:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 787:	75 1e                	jne    7a7 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 789:	83 ec 0c             	sub    $0xc,%esp
 78c:	ff 75 ec             	push   -0x14(%ebp)
 78f:	e8 e5 fe ff ff       	call   679 <morecore>
 794:	83 c4 10             	add    $0x10,%esp
 797:	89 45 f4             	mov    %eax,-0xc(%ebp)
 79a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 79e:	75 07                	jne    7a7 <malloc+0xce>
        return 0;
 7a0:	b8 00 00 00 00       	mov    $0x0,%eax
 7a5:	eb 13                	jmp    7ba <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b0:	8b 00                	mov    (%eax),%eax
 7b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7b5:	e9 6d ff ff ff       	jmp    727 <malloc+0x4e>
  }
}
 7ba:	c9                   	leave  
 7bb:	c3                   	ret    
