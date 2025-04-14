
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:
thread_p  next_thread;
extern void thread_switch(void);

static void 
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
   6:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 c0 0d 00 00 	movl   $0xdc0,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 a0 0d 00 00       	mov    0xda0,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 a4 0d 00 00       	mov    %eax,0xda4
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  42:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }  

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 a0 0d 00 00       	mov    0xda0,%eax
  5b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 a0 0d 00 00       	mov    0xda0,%eax
  6b:	a3 a4 0d 00 00       	mov    %eax,0xda4
  }

  if (next_thread == 0) {    
  70:	a1 a4 0d 00 00       	mov    0xda4,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 08 0a 00 00       	push   $0xa08
  81:	6a 02                	push   $0x2
  83:	e8 c9 05 00 00       	call   651 <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit(); 
  8b:	e8 45 04 00 00       	call   4d5 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */    
  90:	8b 15 a0 0d 00 00    	mov    0xda0,%edx
  96:	a1 a4 0d 00 00       	mov    0xda4,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 16                	je     b5 <thread_schedule+0xb5>
    next_thread->state = RUNNING;    
  9f:	a1 a4 0d 00 00       	mov    0xda4,%eax
  a4:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  ab:	00 00 00 
    thread_switch();   
  ae:	e8 b5 01 00 00       	call   268 <thread_switch>
  } else
    next_thread = 0;
}
  b3:	eb 0a                	jmp    bf <thread_schedule+0xbf>
    next_thread = 0;
  b5:	c7 05 a4 0d 00 00 00 	movl   $0x0,0xda4
  bc:	00 00 00 
}
  bf:	90                   	nop
  c0:	c9                   	leave
  c1:	c3                   	ret

000000c2 <thread_yield>:


void
thread_yield(void)
{      
  c2:	55                   	push   %ebp
  c3:	89 e5                	mov    %esp,%ebp
  c5:	83 ec 08             	sub    $0x8,%esp
  current_thread->state = RUNNABLE;
  c8:	a1 a0 0d 00 00       	mov    0xda0,%eax
  cd:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  d4:	00 00 00 
  thread_schedule();
  d7:	e8 24 ff ff ff       	call   0 <thread_schedule>
}
  dc:	90                   	nop
  dd:	c9                   	leave
  de:	c3                   	ret

000000df <thread_init>:


void 
thread_init(void)
{
  df:	55                   	push   %ebp
  e0:	89 e5                	mov    %esp,%ebp
  e2:	83 ec 08             	sub    $0x8,%esp
  uthread_init((int)thread_yield); 
  e5:	b8 c2 00 00 00       	mov    $0xc2,%eax
  ea:	83 ec 0c             	sub    $0xc,%esp
  ed:	50                   	push   %eax
  ee:	e8 82 04 00 00       	call   575 <uthread_init>
  f3:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  f6:	c7 05 a0 0d 00 00 c0 	movl   $0xdc0,0xda0
  fd:	0d 00 00 
  current_thread->state = RUNNING;
 100:	a1 a0 0d 00 00       	mov    0xda0,%eax
 105:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 10c:	00 00 00 
}
 10f:	90                   	nop
 110:	c9                   	leave
 111:	c3                   	ret

00000112 <thread_exit>:

void
thread_exit(void)
{  
 112:	55                   	push   %ebp
 113:	89 e5                	mov    %esp,%ebp
 115:	83 ec 08             	sub    $0x8,%esp
  current_thread->state = FREE;
 118:	a1 a0 0d 00 00       	mov    0xda0,%eax
 11d:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 124:	00 00 00 
  thread_schedule();
 127:	e8 d4 fe ff ff       	call   0 <thread_schedule>
}
 12c:	90                   	nop
 12d:	c9                   	leave
 12e:	c3                   	ret

0000012f <thread_create>:


void 
thread_create(void (*func)())
{
 12f:	55                   	push   %ebp
 130:	89 e5                	mov    %esp,%ebp
 132:	83 ec 10             	sub    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 135:	c7 45 fc c0 0d 00 00 	movl   $0xdc0,-0x4(%ebp)
 13c:	eb 14                	jmp    152 <thread_create+0x23>
    if (t->state == FREE) break;
 13e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 141:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 147:	85 c0                	test   %eax,%eax
 149:	74 13                	je     15e <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 14b:	81 45 fc 08 20 00 00 	addl   $0x2008,-0x4(%ebp)
 152:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
 157:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 15a:	72 e2                	jb     13e <thread_create+0xf>
 15c:	eb 01                	jmp    15f <thread_create+0x30>
    if (t->state == FREE) break;
 15e:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 15f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 162:	83 c0 04             	add    $0x4,%eax
 165:	05 00 20 00 00       	add    $0x2000,%eax
 16a:	89 c2                	mov    %eax,%edx
 16c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 16f:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 171:	8b 45 fc             	mov    -0x4(%ebp),%eax
 174:	8b 00                	mov    (%eax),%eax
 176:	8d 50 fc             	lea    -0x4(%eax),%edx
 179:	8b 45 fc             	mov    -0x4(%ebp),%eax
 17c:	89 10                	mov    %edx,(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack
 17e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 181:	8b 00                	mov    (%eax),%eax
 183:	89 c2                	mov    %eax,%edx
 185:	8b 45 08             	mov    0x8(%ebp),%eax
 188:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 18a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 18d:	8b 00                	mov    (%eax),%eax
 18f:	8d 50 e0             	lea    -0x20(%eax),%edx
 192:	8b 45 fc             	mov    -0x4(%ebp),%eax
 195:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;  
 197:	8b 45 fc             	mov    -0x4(%ebp),%eax
 19a:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1a1:	00 00 00 
}
 1a4:	90                   	nop
 1a5:	c9                   	leave
 1a6:	c3                   	ret

000001a7 <mythread>:


static void 
mythread(void)
{
 1a7:	55                   	push   %ebp
 1a8:	89 e5                	mov    %esp,%ebp
 1aa:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1ad:	83 ec 08             	sub    $0x8,%esp
 1b0:	68 2e 0a 00 00       	push   $0xa2e
 1b5:	6a 01                	push   $0x1
 1b7:	e8 95 04 00 00       	call   651 <printf>
 1bc:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1c6:	eb 38                	jmp    200 <mythread+0x59>
    printf(1, "my thread 0x%x\n", (int) current_thread);      
 1c8:	a1 a0 0d 00 00       	mov    0xda0,%eax
 1cd:	83 ec 04             	sub    $0x4,%esp
 1d0:	50                   	push   %eax
 1d1:	68 41 0a 00 00       	push   $0xa41
 1d6:	6a 01                	push   $0x1
 1d8:	e8 74 04 00 00       	call   651 <printf>
 1dd:	83 c4 10             	add    $0x10,%esp
    for (volatile int j = 0; j < 100000; j++);  // delay 루프    
 1e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 1e7:	eb 09                	jmp    1f2 <mythread+0x4b>
 1e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1ec:	83 c0 01             	add    $0x1,%eax
 1ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
 1f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1f5:	3d 9f 86 01 00       	cmp    $0x1869f,%eax
 1fa:	7e ed                	jle    1e9 <mythread+0x42>
  for (i = 0; i < 100; i++) {
 1fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 200:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 204:	7e c2                	jle    1c8 <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 206:	83 ec 08             	sub    $0x8,%esp
 209:	68 51 0a 00 00       	push   $0xa51
 20e:	6a 01                	push   $0x1
 210:	e8 3c 04 00 00       	call   651 <printf>
 215:	83 c4 10             	add    $0x10,%esp
  thread_exit();
 218:	e8 f5 fe ff ff       	call   112 <thread_exit>
}
 21d:	90                   	nop
 21e:	c9                   	leave
 21f:	c3                   	ret

00000220 <main>:


int 
main(int argc, char *argv[]) 
{
 220:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 224:	83 e4 f0             	and    $0xfffffff0,%esp
 227:	ff 71 fc             	push   -0x4(%ecx)
 22a:	55                   	push   %ebp
 22b:	89 e5                	mov    %esp,%ebp
 22d:	51                   	push   %ecx
 22e:	83 ec 04             	sub    $0x4,%esp
  thread_init();  
 231:	e8 a9 fe ff ff       	call   df <thread_init>
  thread_create(mythread);
 236:	83 ec 0c             	sub    $0xc,%esp
 239:	68 a7 01 00 00       	push   $0x1a7
 23e:	e8 ec fe ff ff       	call   12f <thread_create>
 243:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 246:	83 ec 0c             	sub    $0xc,%esp
 249:	68 a7 01 00 00       	push   $0x1a7
 24e:	e8 dc fe ff ff       	call   12f <thread_create>
 253:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 256:	e8 a5 fd ff ff       	call   0 <thread_schedule>
  return 0;
 25b:	b8 00 00 00 00       	mov    $0x0,%eax
 260:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 263:	c9                   	leave
 264:	8d 61 fc             	lea    -0x4(%ecx),%esp
 267:	c3                   	ret

00000268 <thread_switch>:
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
 268:	60                   	pusha
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
 269:	a1 a0 0d 00 00       	mov    0xda0,%eax
    movl %esp, (%eax)              # current_thread->sp = %esp
 26e:	89 20                	mov    %esp,(%eax)

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
 270:	a1 a4 0d 00 00       	mov    0xda4,%eax
    movl (%eax), %esp              # %esp = next_thread->sp
 275:	8b 20                	mov    (%eax),%esp

    movl %eax, current_thread
 277:	a3 a0 0d 00 00       	mov    %eax,0xda0
    popal
 27c:	61                   	popa
    
    # return to next thread's stack context
 27d:	c3                   	ret

0000027e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 27e:	55                   	push   %ebp
 27f:	89 e5                	mov    %esp,%ebp
 281:	57                   	push   %edi
 282:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 283:	8b 4d 08             	mov    0x8(%ebp),%ecx
 286:	8b 55 10             	mov    0x10(%ebp),%edx
 289:	8b 45 0c             	mov    0xc(%ebp),%eax
 28c:	89 cb                	mov    %ecx,%ebx
 28e:	89 df                	mov    %ebx,%edi
 290:	89 d1                	mov    %edx,%ecx
 292:	fc                   	cld
 293:	f3 aa                	rep stos %al,%es:(%edi)
 295:	89 ca                	mov    %ecx,%edx
 297:	89 fb                	mov    %edi,%ebx
 299:	89 5d 08             	mov    %ebx,0x8(%ebp)
 29c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 29f:	90                   	nop
 2a0:	5b                   	pop    %ebx
 2a1:	5f                   	pop    %edi
 2a2:	5d                   	pop    %ebp
 2a3:	c3                   	ret

000002a4 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2a4:	55                   	push   %ebp
 2a5:	89 e5                	mov    %esp,%ebp
 2a7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2aa:	8b 45 08             	mov    0x8(%ebp),%eax
 2ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2b0:	90                   	nop
 2b1:	8b 55 0c             	mov    0xc(%ebp),%edx
 2b4:	8d 42 01             	lea    0x1(%edx),%eax
 2b7:	89 45 0c             	mov    %eax,0xc(%ebp)
 2ba:	8b 45 08             	mov    0x8(%ebp),%eax
 2bd:	8d 48 01             	lea    0x1(%eax),%ecx
 2c0:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2c3:	0f b6 12             	movzbl (%edx),%edx
 2c6:	88 10                	mov    %dl,(%eax)
 2c8:	0f b6 00             	movzbl (%eax),%eax
 2cb:	84 c0                	test   %al,%al
 2cd:	75 e2                	jne    2b1 <strcpy+0xd>
    ;
  return os;
 2cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2d2:	c9                   	leave
 2d3:	c3                   	ret

000002d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2d4:	55                   	push   %ebp
 2d5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2d7:	eb 08                	jmp    2e1 <strcmp+0xd>
    p++, q++;
 2d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2dd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2e1:	8b 45 08             	mov    0x8(%ebp),%eax
 2e4:	0f b6 00             	movzbl (%eax),%eax
 2e7:	84 c0                	test   %al,%al
 2e9:	74 10                	je     2fb <strcmp+0x27>
 2eb:	8b 45 08             	mov    0x8(%ebp),%eax
 2ee:	0f b6 10             	movzbl (%eax),%edx
 2f1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f4:	0f b6 00             	movzbl (%eax),%eax
 2f7:	38 c2                	cmp    %al,%dl
 2f9:	74 de                	je     2d9 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 2fb:	8b 45 08             	mov    0x8(%ebp),%eax
 2fe:	0f b6 00             	movzbl (%eax),%eax
 301:	0f b6 d0             	movzbl %al,%edx
 304:	8b 45 0c             	mov    0xc(%ebp),%eax
 307:	0f b6 00             	movzbl (%eax),%eax
 30a:	0f b6 c0             	movzbl %al,%eax
 30d:	29 c2                	sub    %eax,%edx
 30f:	89 d0                	mov    %edx,%eax
}
 311:	5d                   	pop    %ebp
 312:	c3                   	ret

00000313 <strlen>:

uint
strlen(char *s)
{
 313:	55                   	push   %ebp
 314:	89 e5                	mov    %esp,%ebp
 316:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 319:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 320:	eb 04                	jmp    326 <strlen+0x13>
 322:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 326:	8b 55 fc             	mov    -0x4(%ebp),%edx
 329:	8b 45 08             	mov    0x8(%ebp),%eax
 32c:	01 d0                	add    %edx,%eax
 32e:	0f b6 00             	movzbl (%eax),%eax
 331:	84 c0                	test   %al,%al
 333:	75 ed                	jne    322 <strlen+0xf>
    ;
  return n;
 335:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 338:	c9                   	leave
 339:	c3                   	ret

0000033a <memset>:

void*
memset(void *dst, int c, uint n)
{
 33a:	55                   	push   %ebp
 33b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 33d:	8b 45 10             	mov    0x10(%ebp),%eax
 340:	50                   	push   %eax
 341:	ff 75 0c             	push   0xc(%ebp)
 344:	ff 75 08             	push   0x8(%ebp)
 347:	e8 32 ff ff ff       	call   27e <stosb>
 34c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 352:	c9                   	leave
 353:	c3                   	ret

00000354 <strchr>:

char*
strchr(const char *s, char c)
{
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp
 357:	83 ec 04             	sub    $0x4,%esp
 35a:	8b 45 0c             	mov    0xc(%ebp),%eax
 35d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 360:	eb 14                	jmp    376 <strchr+0x22>
    if(*s == c)
 362:	8b 45 08             	mov    0x8(%ebp),%eax
 365:	0f b6 00             	movzbl (%eax),%eax
 368:	38 45 fc             	cmp    %al,-0x4(%ebp)
 36b:	75 05                	jne    372 <strchr+0x1e>
      return (char*)s;
 36d:	8b 45 08             	mov    0x8(%ebp),%eax
 370:	eb 13                	jmp    385 <strchr+0x31>
  for(; *s; s++)
 372:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 376:	8b 45 08             	mov    0x8(%ebp),%eax
 379:	0f b6 00             	movzbl (%eax),%eax
 37c:	84 c0                	test   %al,%al
 37e:	75 e2                	jne    362 <strchr+0xe>
  return 0;
 380:	b8 00 00 00 00       	mov    $0x0,%eax
}
 385:	c9                   	leave
 386:	c3                   	ret

00000387 <gets>:

char*
gets(char *buf, int max)
{
 387:	55                   	push   %ebp
 388:	89 e5                	mov    %esp,%ebp
 38a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 38d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 394:	eb 42                	jmp    3d8 <gets+0x51>
    cc = read(0, &c, 1);
 396:	83 ec 04             	sub    $0x4,%esp
 399:	6a 01                	push   $0x1
 39b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 39e:	50                   	push   %eax
 39f:	6a 00                	push   $0x0
 3a1:	e8 47 01 00 00       	call   4ed <read>
 3a6:	83 c4 10             	add    $0x10,%esp
 3a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3b0:	7e 33                	jle    3e5 <gets+0x5e>
      break;
    buf[i++] = c;
 3b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3b5:	8d 50 01             	lea    0x1(%eax),%edx
 3b8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3bb:	89 c2                	mov    %eax,%edx
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
 3c0:	01 c2                	add    %eax,%edx
 3c2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3c6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3c8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3cc:	3c 0a                	cmp    $0xa,%al
 3ce:	74 16                	je     3e6 <gets+0x5f>
 3d0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3d4:	3c 0d                	cmp    $0xd,%al
 3d6:	74 0e                	je     3e6 <gets+0x5f>
  for(i=0; i+1 < max; ){
 3d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3db:	83 c0 01             	add    $0x1,%eax
 3de:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3e1:	7f b3                	jg     396 <gets+0xf>
 3e3:	eb 01                	jmp    3e6 <gets+0x5f>
      break;
 3e5:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3e9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ec:	01 d0                	add    %edx,%eax
 3ee:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3f4:	c9                   	leave
 3f5:	c3                   	ret

000003f6 <stat>:

int
stat(char *n, struct stat *st)
{
 3f6:	55                   	push   %ebp
 3f7:	89 e5                	mov    %esp,%ebp
 3f9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3fc:	83 ec 08             	sub    $0x8,%esp
 3ff:	6a 00                	push   $0x0
 401:	ff 75 08             	push   0x8(%ebp)
 404:	e8 0c 01 00 00       	call   515 <open>
 409:	83 c4 10             	add    $0x10,%esp
 40c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 40f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 413:	79 07                	jns    41c <stat+0x26>
    return -1;
 415:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 41a:	eb 25                	jmp    441 <stat+0x4b>
  r = fstat(fd, st);
 41c:	83 ec 08             	sub    $0x8,%esp
 41f:	ff 75 0c             	push   0xc(%ebp)
 422:	ff 75 f4             	push   -0xc(%ebp)
 425:	e8 03 01 00 00       	call   52d <fstat>
 42a:	83 c4 10             	add    $0x10,%esp
 42d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 430:	83 ec 0c             	sub    $0xc,%esp
 433:	ff 75 f4             	push   -0xc(%ebp)
 436:	e8 c2 00 00 00       	call   4fd <close>
 43b:	83 c4 10             	add    $0x10,%esp
  return r;
 43e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 441:	c9                   	leave
 442:	c3                   	ret

00000443 <atoi>:

int
atoi(const char *s)
{
 443:	55                   	push   %ebp
 444:	89 e5                	mov    %esp,%ebp
 446:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 449:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 450:	eb 25                	jmp    477 <atoi+0x34>
    n = n*10 + *s++ - '0';
 452:	8b 55 fc             	mov    -0x4(%ebp),%edx
 455:	89 d0                	mov    %edx,%eax
 457:	c1 e0 02             	shl    $0x2,%eax
 45a:	01 d0                	add    %edx,%eax
 45c:	01 c0                	add    %eax,%eax
 45e:	89 c1                	mov    %eax,%ecx
 460:	8b 45 08             	mov    0x8(%ebp),%eax
 463:	8d 50 01             	lea    0x1(%eax),%edx
 466:	89 55 08             	mov    %edx,0x8(%ebp)
 469:	0f b6 00             	movzbl (%eax),%eax
 46c:	0f be c0             	movsbl %al,%eax
 46f:	01 c8                	add    %ecx,%eax
 471:	83 e8 30             	sub    $0x30,%eax
 474:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 477:	8b 45 08             	mov    0x8(%ebp),%eax
 47a:	0f b6 00             	movzbl (%eax),%eax
 47d:	3c 2f                	cmp    $0x2f,%al
 47f:	7e 0a                	jle    48b <atoi+0x48>
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	0f b6 00             	movzbl (%eax),%eax
 487:	3c 39                	cmp    $0x39,%al
 489:	7e c7                	jle    452 <atoi+0xf>
  return n;
 48b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 48e:	c9                   	leave
 48f:	c3                   	ret

00000490 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 490:	55                   	push   %ebp
 491:	89 e5                	mov    %esp,%ebp
 493:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 496:	8b 45 08             	mov    0x8(%ebp),%eax
 499:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 49c:	8b 45 0c             	mov    0xc(%ebp),%eax
 49f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4a2:	eb 17                	jmp    4bb <memmove+0x2b>
    *dst++ = *src++;
 4a4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4a7:	8d 42 01             	lea    0x1(%edx),%eax
 4aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4b0:	8d 48 01             	lea    0x1(%eax),%ecx
 4b3:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4b6:	0f b6 12             	movzbl (%edx),%edx
 4b9:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4bb:	8b 45 10             	mov    0x10(%ebp),%eax
 4be:	8d 50 ff             	lea    -0x1(%eax),%edx
 4c1:	89 55 10             	mov    %edx,0x10(%ebp)
 4c4:	85 c0                	test   %eax,%eax
 4c6:	7f dc                	jg     4a4 <memmove+0x14>
  return vdst;
 4c8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4cb:	c9                   	leave
 4cc:	c3                   	ret

000004cd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4cd:	b8 01 00 00 00       	mov    $0x1,%eax
 4d2:	cd 40                	int    $0x40
 4d4:	c3                   	ret

000004d5 <exit>:
SYSCALL(exit)
 4d5:	b8 02 00 00 00       	mov    $0x2,%eax
 4da:	cd 40                	int    $0x40
 4dc:	c3                   	ret

000004dd <wait>:
SYSCALL(wait)
 4dd:	b8 03 00 00 00       	mov    $0x3,%eax
 4e2:	cd 40                	int    $0x40
 4e4:	c3                   	ret

000004e5 <pipe>:
SYSCALL(pipe)
 4e5:	b8 04 00 00 00       	mov    $0x4,%eax
 4ea:	cd 40                	int    $0x40
 4ec:	c3                   	ret

000004ed <read>:
SYSCALL(read)
 4ed:	b8 05 00 00 00       	mov    $0x5,%eax
 4f2:	cd 40                	int    $0x40
 4f4:	c3                   	ret

000004f5 <write>:
SYSCALL(write)
 4f5:	b8 10 00 00 00       	mov    $0x10,%eax
 4fa:	cd 40                	int    $0x40
 4fc:	c3                   	ret

000004fd <close>:
SYSCALL(close)
 4fd:	b8 15 00 00 00       	mov    $0x15,%eax
 502:	cd 40                	int    $0x40
 504:	c3                   	ret

00000505 <kill>:
SYSCALL(kill)
 505:	b8 06 00 00 00       	mov    $0x6,%eax
 50a:	cd 40                	int    $0x40
 50c:	c3                   	ret

0000050d <exec>:
SYSCALL(exec)
 50d:	b8 07 00 00 00       	mov    $0x7,%eax
 512:	cd 40                	int    $0x40
 514:	c3                   	ret

00000515 <open>:
SYSCALL(open)
 515:	b8 0f 00 00 00       	mov    $0xf,%eax
 51a:	cd 40                	int    $0x40
 51c:	c3                   	ret

0000051d <mknod>:
SYSCALL(mknod)
 51d:	b8 11 00 00 00       	mov    $0x11,%eax
 522:	cd 40                	int    $0x40
 524:	c3                   	ret

00000525 <unlink>:
SYSCALL(unlink)
 525:	b8 12 00 00 00       	mov    $0x12,%eax
 52a:	cd 40                	int    $0x40
 52c:	c3                   	ret

0000052d <fstat>:
SYSCALL(fstat)
 52d:	b8 08 00 00 00       	mov    $0x8,%eax
 532:	cd 40                	int    $0x40
 534:	c3                   	ret

00000535 <link>:
SYSCALL(link)
 535:	b8 13 00 00 00       	mov    $0x13,%eax
 53a:	cd 40                	int    $0x40
 53c:	c3                   	ret

0000053d <mkdir>:
SYSCALL(mkdir)
 53d:	b8 14 00 00 00       	mov    $0x14,%eax
 542:	cd 40                	int    $0x40
 544:	c3                   	ret

00000545 <chdir>:
SYSCALL(chdir)
 545:	b8 09 00 00 00       	mov    $0x9,%eax
 54a:	cd 40                	int    $0x40
 54c:	c3                   	ret

0000054d <dup>:
SYSCALL(dup)
 54d:	b8 0a 00 00 00       	mov    $0xa,%eax
 552:	cd 40                	int    $0x40
 554:	c3                   	ret

00000555 <getpid>:
SYSCALL(getpid)
 555:	b8 0b 00 00 00       	mov    $0xb,%eax
 55a:	cd 40                	int    $0x40
 55c:	c3                   	ret

0000055d <sbrk>:
SYSCALL(sbrk)
 55d:	b8 0c 00 00 00       	mov    $0xc,%eax
 562:	cd 40                	int    $0x40
 564:	c3                   	ret

00000565 <sleep>:
SYSCALL(sleep)
 565:	b8 0d 00 00 00       	mov    $0xd,%eax
 56a:	cd 40                	int    $0x40
 56c:	c3                   	ret

0000056d <uptime>:
SYSCALL(uptime)
 56d:	b8 0e 00 00 00       	mov    $0xe,%eax
 572:	cd 40                	int    $0x40
 574:	c3                   	ret

00000575 <uthread_init>:
SYSCALL(uthread_init)
 575:	b8 16 00 00 00       	mov    $0x16,%eax
 57a:	cd 40                	int    $0x40
 57c:	c3                   	ret

0000057d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 57d:	55                   	push   %ebp
 57e:	89 e5                	mov    %esp,%ebp
 580:	83 ec 18             	sub    $0x18,%esp
 583:	8b 45 0c             	mov    0xc(%ebp),%eax
 586:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 589:	83 ec 04             	sub    $0x4,%esp
 58c:	6a 01                	push   $0x1
 58e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 591:	50                   	push   %eax
 592:	ff 75 08             	push   0x8(%ebp)
 595:	e8 5b ff ff ff       	call   4f5 <write>
 59a:	83 c4 10             	add    $0x10,%esp
}
 59d:	90                   	nop
 59e:	c9                   	leave
 59f:	c3                   	ret

000005a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a0:	55                   	push   %ebp
 5a1:	89 e5                	mov    %esp,%ebp
 5a3:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5ad:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5b1:	74 17                	je     5ca <printint+0x2a>
 5b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5b7:	79 11                	jns    5ca <printint+0x2a>
    neg = 1;
 5b9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c3:	f7 d8                	neg    %eax
 5c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5c8:	eb 06                	jmp    5d0 <printint+0x30>
  } else {
    x = xx;
 5ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 5cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5da:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5dd:	ba 00 00 00 00       	mov    $0x0,%edx
 5e2:	f7 f1                	div    %ecx
 5e4:	89 d1                	mov    %edx,%ecx
 5e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e9:	8d 50 01             	lea    0x1(%eax),%edx
 5ec:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5ef:	0f b6 91 78 0d 00 00 	movzbl 0xd78(%ecx),%edx
 5f6:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 5fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 600:	ba 00 00 00 00       	mov    $0x0,%edx
 605:	f7 f1                	div    %ecx
 607:	89 45 ec             	mov    %eax,-0x14(%ebp)
 60a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 60e:	75 c7                	jne    5d7 <printint+0x37>
  if(neg)
 610:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 614:	74 2d                	je     643 <printint+0xa3>
    buf[i++] = '-';
 616:	8b 45 f4             	mov    -0xc(%ebp),%eax
 619:	8d 50 01             	lea    0x1(%eax),%edx
 61c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 61f:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 624:	eb 1d                	jmp    643 <printint+0xa3>
    putc(fd, buf[i]);
 626:	8d 55 dc             	lea    -0x24(%ebp),%edx
 629:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62c:	01 d0                	add    %edx,%eax
 62e:	0f b6 00             	movzbl (%eax),%eax
 631:	0f be c0             	movsbl %al,%eax
 634:	83 ec 08             	sub    $0x8,%esp
 637:	50                   	push   %eax
 638:	ff 75 08             	push   0x8(%ebp)
 63b:	e8 3d ff ff ff       	call   57d <putc>
 640:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 643:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 647:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 64b:	79 d9                	jns    626 <printint+0x86>
}
 64d:	90                   	nop
 64e:	90                   	nop
 64f:	c9                   	leave
 650:	c3                   	ret

00000651 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 651:	55                   	push   %ebp
 652:	89 e5                	mov    %esp,%ebp
 654:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 657:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 65e:	8d 45 0c             	lea    0xc(%ebp),%eax
 661:	83 c0 04             	add    $0x4,%eax
 664:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 667:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 66e:	e9 59 01 00 00       	jmp    7cc <printf+0x17b>
    c = fmt[i] & 0xff;
 673:	8b 55 0c             	mov    0xc(%ebp),%edx
 676:	8b 45 f0             	mov    -0x10(%ebp),%eax
 679:	01 d0                	add    %edx,%eax
 67b:	0f b6 00             	movzbl (%eax),%eax
 67e:	0f be c0             	movsbl %al,%eax
 681:	25 ff 00 00 00       	and    $0xff,%eax
 686:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 689:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 68d:	75 2c                	jne    6bb <printf+0x6a>
      if(c == '%'){
 68f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 693:	75 0c                	jne    6a1 <printf+0x50>
        state = '%';
 695:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 69c:	e9 27 01 00 00       	jmp    7c8 <printf+0x177>
      } else {
        putc(fd, c);
 6a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6a4:	0f be c0             	movsbl %al,%eax
 6a7:	83 ec 08             	sub    $0x8,%esp
 6aa:	50                   	push   %eax
 6ab:	ff 75 08             	push   0x8(%ebp)
 6ae:	e8 ca fe ff ff       	call   57d <putc>
 6b3:	83 c4 10             	add    $0x10,%esp
 6b6:	e9 0d 01 00 00       	jmp    7c8 <printf+0x177>
      }
    } else if(state == '%'){
 6bb:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6bf:	0f 85 03 01 00 00    	jne    7c8 <printf+0x177>
      if(c == 'd'){
 6c5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6c9:	75 1e                	jne    6e9 <printf+0x98>
        printint(fd, *ap, 10, 1);
 6cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ce:	8b 00                	mov    (%eax),%eax
 6d0:	6a 01                	push   $0x1
 6d2:	6a 0a                	push   $0xa
 6d4:	50                   	push   %eax
 6d5:	ff 75 08             	push   0x8(%ebp)
 6d8:	e8 c3 fe ff ff       	call   5a0 <printint>
 6dd:	83 c4 10             	add    $0x10,%esp
        ap++;
 6e0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6e4:	e9 d8 00 00 00       	jmp    7c1 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6e9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6ed:	74 06                	je     6f5 <printf+0xa4>
 6ef:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6f3:	75 1e                	jne    713 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f8:	8b 00                	mov    (%eax),%eax
 6fa:	6a 00                	push   $0x0
 6fc:	6a 10                	push   $0x10
 6fe:	50                   	push   %eax
 6ff:	ff 75 08             	push   0x8(%ebp)
 702:	e8 99 fe ff ff       	call   5a0 <printint>
 707:	83 c4 10             	add    $0x10,%esp
        ap++;
 70a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70e:	e9 ae 00 00 00       	jmp    7c1 <printf+0x170>
      } else if(c == 's'){
 713:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 717:	75 43                	jne    75c <printf+0x10b>
        s = (char*)*ap;
 719:	8b 45 e8             	mov    -0x18(%ebp),%eax
 71c:	8b 00                	mov    (%eax),%eax
 71e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 721:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 725:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 729:	75 25                	jne    750 <printf+0xff>
          s = "(null)";
 72b:	c7 45 f4 62 0a 00 00 	movl   $0xa62,-0xc(%ebp)
        while(*s != 0){
 732:	eb 1c                	jmp    750 <printf+0xff>
          putc(fd, *s);
 734:	8b 45 f4             	mov    -0xc(%ebp),%eax
 737:	0f b6 00             	movzbl (%eax),%eax
 73a:	0f be c0             	movsbl %al,%eax
 73d:	83 ec 08             	sub    $0x8,%esp
 740:	50                   	push   %eax
 741:	ff 75 08             	push   0x8(%ebp)
 744:	e8 34 fe ff ff       	call   57d <putc>
 749:	83 c4 10             	add    $0x10,%esp
          s++;
 74c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 750:	8b 45 f4             	mov    -0xc(%ebp),%eax
 753:	0f b6 00             	movzbl (%eax),%eax
 756:	84 c0                	test   %al,%al
 758:	75 da                	jne    734 <printf+0xe3>
 75a:	eb 65                	jmp    7c1 <printf+0x170>
        }
      } else if(c == 'c'){
 75c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 760:	75 1d                	jne    77f <printf+0x12e>
        putc(fd, *ap);
 762:	8b 45 e8             	mov    -0x18(%ebp),%eax
 765:	8b 00                	mov    (%eax),%eax
 767:	0f be c0             	movsbl %al,%eax
 76a:	83 ec 08             	sub    $0x8,%esp
 76d:	50                   	push   %eax
 76e:	ff 75 08             	push   0x8(%ebp)
 771:	e8 07 fe ff ff       	call   57d <putc>
 776:	83 c4 10             	add    $0x10,%esp
        ap++;
 779:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 77d:	eb 42                	jmp    7c1 <printf+0x170>
      } else if(c == '%'){
 77f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 783:	75 17                	jne    79c <printf+0x14b>
        putc(fd, c);
 785:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 788:	0f be c0             	movsbl %al,%eax
 78b:	83 ec 08             	sub    $0x8,%esp
 78e:	50                   	push   %eax
 78f:	ff 75 08             	push   0x8(%ebp)
 792:	e8 e6 fd ff ff       	call   57d <putc>
 797:	83 c4 10             	add    $0x10,%esp
 79a:	eb 25                	jmp    7c1 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 79c:	83 ec 08             	sub    $0x8,%esp
 79f:	6a 25                	push   $0x25
 7a1:	ff 75 08             	push   0x8(%ebp)
 7a4:	e8 d4 fd ff ff       	call   57d <putc>
 7a9:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7af:	0f be c0             	movsbl %al,%eax
 7b2:	83 ec 08             	sub    $0x8,%esp
 7b5:	50                   	push   %eax
 7b6:	ff 75 08             	push   0x8(%ebp)
 7b9:	e8 bf fd ff ff       	call   57d <putc>
 7be:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7c8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7cc:	8b 55 0c             	mov    0xc(%ebp),%edx
 7cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d2:	01 d0                	add    %edx,%eax
 7d4:	0f b6 00             	movzbl (%eax),%eax
 7d7:	84 c0                	test   %al,%al
 7d9:	0f 85 94 fe ff ff    	jne    673 <printf+0x22>
    }
  }
}
 7df:	90                   	nop
 7e0:	90                   	nop
 7e1:	c9                   	leave
 7e2:	c3                   	ret

000007e3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e3:	55                   	push   %ebp
 7e4:	89 e5                	mov    %esp,%ebp
 7e6:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e9:	8b 45 08             	mov    0x8(%ebp),%eax
 7ec:	83 e8 08             	sub    $0x8,%eax
 7ef:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f2:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 7f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7fa:	eb 24                	jmp    820 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ff:	8b 00                	mov    (%eax),%eax
 801:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 804:	72 12                	jb     818 <free+0x35>
 806:	8b 45 f8             	mov    -0x8(%ebp),%eax
 809:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 80c:	72 24                	jb     832 <free+0x4f>
 80e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 811:	8b 00                	mov    (%eax),%eax
 813:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 816:	72 1a                	jb     832 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 818:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81b:	8b 00                	mov    (%eax),%eax
 81d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 820:	8b 45 f8             	mov    -0x8(%ebp),%eax
 823:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 826:	73 d4                	jae    7fc <free+0x19>
 828:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82b:	8b 00                	mov    (%eax),%eax
 82d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 830:	73 ca                	jae    7fc <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 832:	8b 45 f8             	mov    -0x8(%ebp),%eax
 835:	8b 40 04             	mov    0x4(%eax),%eax
 838:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	01 c2                	add    %eax,%edx
 844:	8b 45 fc             	mov    -0x4(%ebp),%eax
 847:	8b 00                	mov    (%eax),%eax
 849:	39 c2                	cmp    %eax,%edx
 84b:	75 24                	jne    871 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 84d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 850:	8b 50 04             	mov    0x4(%eax),%edx
 853:	8b 45 fc             	mov    -0x4(%ebp),%eax
 856:	8b 00                	mov    (%eax),%eax
 858:	8b 40 04             	mov    0x4(%eax),%eax
 85b:	01 c2                	add    %eax,%edx
 85d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 860:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 863:	8b 45 fc             	mov    -0x4(%ebp),%eax
 866:	8b 00                	mov    (%eax),%eax
 868:	8b 10                	mov    (%eax),%edx
 86a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86d:	89 10                	mov    %edx,(%eax)
 86f:	eb 0a                	jmp    87b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 871:	8b 45 fc             	mov    -0x4(%ebp),%eax
 874:	8b 10                	mov    (%eax),%edx
 876:	8b 45 f8             	mov    -0x8(%ebp),%eax
 879:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 87b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87e:	8b 40 04             	mov    0x4(%eax),%eax
 881:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 888:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88b:	01 d0                	add    %edx,%eax
 88d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 890:	75 20                	jne    8b2 <free+0xcf>
    p->s.size += bp->s.size;
 892:	8b 45 fc             	mov    -0x4(%ebp),%eax
 895:	8b 50 04             	mov    0x4(%eax),%edx
 898:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89b:	8b 40 04             	mov    0x4(%eax),%eax
 89e:	01 c2                	add    %eax,%edx
 8a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a3:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a9:	8b 10                	mov    (%eax),%edx
 8ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ae:	89 10                	mov    %edx,(%eax)
 8b0:	eb 08                	jmp    8ba <free+0xd7>
  } else
    p->s.ptr = bp;
 8b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b5:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8b8:	89 10                	mov    %edx,(%eax)
  freep = p;
 8ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bd:	a3 e8 8d 00 00       	mov    %eax,0x8de8
}
 8c2:	90                   	nop
 8c3:	c9                   	leave
 8c4:	c3                   	ret

000008c5 <morecore>:

static Header*
morecore(uint nu)
{
 8c5:	55                   	push   %ebp
 8c6:	89 e5                	mov    %esp,%ebp
 8c8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8cb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8d2:	77 07                	ja     8db <morecore+0x16>
    nu = 4096;
 8d4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8db:	8b 45 08             	mov    0x8(%ebp),%eax
 8de:	c1 e0 03             	shl    $0x3,%eax
 8e1:	83 ec 0c             	sub    $0xc,%esp
 8e4:	50                   	push   %eax
 8e5:	e8 73 fc ff ff       	call   55d <sbrk>
 8ea:	83 c4 10             	add    $0x10,%esp
 8ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8f0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8f4:	75 07                	jne    8fd <morecore+0x38>
    return 0;
 8f6:	b8 00 00 00 00       	mov    $0x0,%eax
 8fb:	eb 26                	jmp    923 <morecore+0x5e>
  hp = (Header*)p;
 8fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 900:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 903:	8b 45 f0             	mov    -0x10(%ebp),%eax
 906:	8b 55 08             	mov    0x8(%ebp),%edx
 909:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 90c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90f:	83 c0 08             	add    $0x8,%eax
 912:	83 ec 0c             	sub    $0xc,%esp
 915:	50                   	push   %eax
 916:	e8 c8 fe ff ff       	call   7e3 <free>
 91b:	83 c4 10             	add    $0x10,%esp
  return freep;
 91e:	a1 e8 8d 00 00       	mov    0x8de8,%eax
}
 923:	c9                   	leave
 924:	c3                   	ret

00000925 <malloc>:

void*
malloc(uint nbytes)
{
 925:	55                   	push   %ebp
 926:	89 e5                	mov    %esp,%ebp
 928:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 92b:	8b 45 08             	mov    0x8(%ebp),%eax
 92e:	83 c0 07             	add    $0x7,%eax
 931:	c1 e8 03             	shr    $0x3,%eax
 934:	83 c0 01             	add    $0x1,%eax
 937:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 93a:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 93f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 942:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 946:	75 23                	jne    96b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 948:	c7 45 f0 e0 8d 00 00 	movl   $0x8de0,-0x10(%ebp)
 94f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 952:	a3 e8 8d 00 00       	mov    %eax,0x8de8
 957:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 95c:	a3 e0 8d 00 00       	mov    %eax,0x8de0
    base.s.size = 0;
 961:	c7 05 e4 8d 00 00 00 	movl   $0x0,0x8de4
 968:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96e:	8b 00                	mov    (%eax),%eax
 970:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 973:	8b 45 f4             	mov    -0xc(%ebp),%eax
 976:	8b 40 04             	mov    0x4(%eax),%eax
 979:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 97c:	72 4d                	jb     9cb <malloc+0xa6>
      if(p->s.size == nunits)
 97e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 981:	8b 40 04             	mov    0x4(%eax),%eax
 984:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 987:	75 0c                	jne    995 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 989:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98c:	8b 10                	mov    (%eax),%edx
 98e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 991:	89 10                	mov    %edx,(%eax)
 993:	eb 26                	jmp    9bb <malloc+0x96>
      else {
        p->s.size -= nunits;
 995:	8b 45 f4             	mov    -0xc(%ebp),%eax
 998:	8b 40 04             	mov    0x4(%eax),%eax
 99b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 99e:	89 c2                	mov    %eax,%edx
 9a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a9:	8b 40 04             	mov    0x4(%eax),%eax
 9ac:	c1 e0 03             	shl    $0x3,%eax
 9af:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9b8:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9be:	a3 e8 8d 00 00       	mov    %eax,0x8de8
      return (void*)(p + 1);
 9c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c6:	83 c0 08             	add    $0x8,%eax
 9c9:	eb 3b                	jmp    a06 <malloc+0xe1>
    }
    if(p == freep)
 9cb:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 9d0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9d3:	75 1e                	jne    9f3 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9d5:	83 ec 0c             	sub    $0xc,%esp
 9d8:	ff 75 ec             	push   -0x14(%ebp)
 9db:	e8 e5 fe ff ff       	call   8c5 <morecore>
 9e0:	83 c4 10             	add    $0x10,%esp
 9e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9ea:	75 07                	jne    9f3 <malloc+0xce>
        return 0;
 9ec:	b8 00 00 00 00       	mov    $0x0,%eax
 9f1:	eb 13                	jmp    a06 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fc:	8b 00                	mov    (%eax),%eax
 9fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a01:	e9 6d ff ff ff       	jmp    973 <malloc+0x4e>
  }
}
 a06:	c9                   	leave
 a07:	c3                   	ret
