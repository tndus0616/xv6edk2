
_uthread4:     file format elf32-i386


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
   6:	c7 05 44 0f 00 00 00 	movl   $0x0,0xf44
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 60 0f 00 00 	movl   $0xf60,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 40 0f 00 00       	mov    0xf40,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 44 0f 00 00       	mov    %eax,0xf44
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
  42:	b8 00 50 01 00       	mov    $0x15000,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 00 50 01 00       	mov    $0x15000,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 40 0f 00 00       	mov    0xf40,%eax
  5b:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 40 0f 00 00       	mov    0xf40,%eax
  6b:	a3 44 0f 00 00       	mov    %eax,0xf44
  }

  if (next_thread == 0) {
  70:	a1 44 0f 00 00       	mov    0xf44,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 58 0b 00 00       	push   $0xb58
  81:	6a 02                	push   $0x2
  83:	e8 17 07 00 00       	call   79f <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 93 05 00 00       	call   623 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  90:	8b 15 40 0f 00 00    	mov    0xf40,%edx
  96:	a1 44 0f 00 00       	mov    0xf44,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 25                	je     c4 <thread_schedule+0xc4>
    next_thread->state = RUNNING;
  9f:	a1 44 0f 00 00       	mov    0xf44,%eax
  a4:	c7 80 0c 20 00 00 01 	movl   $0x1,0x200c(%eax)
  ab:	00 00 00 
    current_thread->state = RUNNABLE;
  ae:	a1 40 0f 00 00       	mov    0xf40,%eax
  b3:	c7 80 0c 20 00 00 02 	movl   $0x2,0x200c(%eax)
  ba:	00 00 00 
    thread_switch();
  bd:	e8 f4 02 00 00       	call   3b6 <thread_switch>
  } else
    next_thread = 0;
}
  c2:	eb 0a                	jmp    ce <thread_schedule+0xce>
    next_thread = 0;
  c4:	c7 05 44 0f 00 00 00 	movl   $0x0,0xf44
  cb:	00 00 00 
}
  ce:	90                   	nop
  cf:	c9                   	leave
  d0:	c3                   	ret

000000d1 <thread_yield>:

void
thread_yield(void)
{      
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  d4:	83 ec 08             	sub    $0x8,%esp
  current_thread->state = RUNNABLE;
  d7:	a1 40 0f 00 00       	mov    0xf40,%eax
  dc:	c7 80 0c 20 00 00 02 	movl   $0x2,0x200c(%eax)
  e3:	00 00 00 
  thread_schedule();
  e6:	e8 15 ff ff ff       	call   0 <thread_schedule>
}
  eb:	90                   	nop
  ec:	c9                   	leave
  ed:	c3                   	ret

000000ee <thread_init>:

void 
thread_init(void)
{
  ee:	55                   	push   %ebp
  ef:	89 e5                	mov    %esp,%ebp
  f1:	83 ec 08             	sub    $0x8,%esp
  uthread_init((int)thread_yield);
  f4:	b8 d1 00 00 00       	mov    $0xd1,%eax
  f9:	83 ec 0c             	sub    $0xc,%esp
  fc:	50                   	push   %eax
  fd:	e8 c1 05 00 00       	call   6c3 <uthread_init>
 102:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
 105:	c7 05 40 0f 00 00 60 	movl   $0xf60,0xf40
 10c:	0f 00 00 
  current_thread->state = RUNNING;
 10f:	a1 40 0f 00 00       	mov    0xf40,%eax
 114:	c7 80 0c 20 00 00 01 	movl   $0x1,0x200c(%eax)
 11b:	00 00 00 
  current_thread->tid=0;
 11e:	a1 40 0f 00 00       	mov    0xf40,%eax
 123:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  current_thread->ptid=0;
 129:	a1 40 0f 00 00       	mov    0xf40,%eax
 12e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
}
 135:	90                   	nop
 136:	c9                   	leave
 137:	c3                   	ret

00000138 <thread_create>:

int 
thread_create(void (*func)())
{
 138:	55                   	push   %ebp
 139:	89 e5                	mov    %esp,%ebp
 13b:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 13e:	c7 45 f4 60 0f 00 00 	movl   $0xf60,-0xc(%ebp)
 145:	eb 14                	jmp    15b <thread_create+0x23>
    if (t->state == FREE) break;
 147:	8b 45 f4             	mov    -0xc(%ebp),%eax
 14a:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
 150:	85 c0                	test   %eax,%eax
 152:	74 13                	je     167 <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 154:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
 15b:	b8 00 50 01 00       	mov    $0x15000,%eax
 160:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 163:	72 e2                	jb     147 <thread_create+0xf>
 165:	eb 01                	jmp    168 <thread_create+0x30>
    if (t->state == FREE) break;
 167:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 168:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16b:	83 c0 0c             	add    $0xc,%eax
 16e:	05 00 20 00 00       	add    $0x2000,%eax
 173:	89 c2                	mov    %eax,%edx
 175:	8b 45 f4             	mov    -0xc(%ebp),%eax
 178:	89 50 08             	mov    %edx,0x8(%eax)
  t->sp -= 4;                              // space for return address
 17b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17e:	8b 40 08             	mov    0x8(%eax),%eax
 181:	8d 50 fc             	lea    -0x4(%eax),%edx
 184:	8b 45 f4             	mov    -0xc(%ebp),%eax
 187:	89 50 08             	mov    %edx,0x8(%eax)
  t->tid = t - all_thread;
 18a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18d:	2d 60 0f 00 00       	sub    $0xf60,%eax
 192:	c1 f8 04             	sar    $0x4,%eax
 195:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
 19b:	89 c2                	mov    %eax,%edx
 19d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a0:	89 10                	mov    %edx,(%eax)
  t->ptid = current_thread->tid;
 1a2:	a1 40 0f 00 00       	mov    0xf40,%eax
 1a7:	8b 10                	mov    (%eax),%edx
 1a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ac:	89 50 04             	mov    %edx,0x4(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack
 1af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b2:	8b 40 08             	mov    0x8(%eax),%eax
 1b5:	89 c2                	mov    %eax,%edx
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ba:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 1bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bf:	8b 40 08             	mov    0x8(%eax),%eax
 1c2:	8d 50 e0             	lea    -0x20(%eax),%edx
 1c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c8:	89 50 08             	mov    %edx,0x8(%eax)
  memset((void*)t->sp, 0, 32);
 1cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ce:	8b 40 08             	mov    0x8(%eax),%eax
 1d1:	83 ec 04             	sub    $0x4,%esp
 1d4:	6a 20                	push   $0x20
 1d6:	6a 00                	push   $0x0
 1d8:	50                   	push   %eax
 1d9:	e8 aa 02 00 00       	call   488 <memset>
 1de:	83 c4 10             	add    $0x10,%esp
  t->state = RUNNABLE;
 1e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e4:	c7 80 0c 20 00 00 02 	movl   $0x2,0x200c(%eax)
 1eb:	00 00 00 
  
  return t->tid;
 1ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f1:	8b 00                	mov    (%eax),%eax
}
 1f3:	c9                   	leave
 1f4:	c3                   	ret

000001f5 <thread_join>:

static void 
thread_join(int tid)
{
 1f5:	55                   	push   %ebp
 1f6:	89 e5                	mov    %esp,%ebp
 1f8:	83 ec 18             	sub    $0x18,%esp
  thread_p t;
  int found = 0;
 1fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  while(1) {
    for(t = all_thread; t < all_thread + MAX_THREAD; t++)
 202:	c7 45 f4 60 0f 00 00 	movl   $0xf60,-0xc(%ebp)
 209:	eb 1a                	jmp    225 <thread_join+0x30>
    {
      if(t->tid == tid)
 20b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20e:	8b 00                	mov    (%eax),%eax
 210:	39 45 08             	cmp    %eax,0x8(%ebp)
 213:	75 09                	jne    21e <thread_join+0x29>
      {
        found = 1;
 215:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        break;
 21c:	eb 11                	jmp    22f <thread_join+0x3a>
    for(t = all_thread; t < all_thread + MAX_THREAD; t++)
 21e:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
 225:	b8 00 50 01 00       	mov    $0x15000,%eax
 22a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 22d:	72 dc                	jb     20b <thread_join+0x16>
      }
    }

    if(!found)
 22f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 233:	75 17                	jne    24c <thread_join+0x57>
    {
      printf(2, "no thread with tid %d\n", tid);
 235:	83 ec 04             	sub    $0x4,%esp
 238:	ff 75 08             	push   0x8(%ebp)
 23b:	68 7e 0b 00 00       	push   $0xb7e
 240:	6a 02                	push   $0x2
 242:	e8 58 05 00 00       	call   79f <printf>
 247:	83 c4 10             	add    $0x10,%esp
      return;
 24a:	eb 15                	jmp    261 <thread_join+0x6c>
    }

    if(t->state == FREE) {
 24c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24f:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
 255:	85 c0                	test   %eax,%eax
 257:	74 07                	je     260 <thread_join+0x6b>
      return;
    }

    thread_schedule();
 259:	e8 a2 fd ff ff       	call   0 <thread_schedule>
    for(t = all_thread; t < all_thread + MAX_THREAD; t++)
 25e:	eb a2                	jmp    202 <thread_join+0xd>
      return;
 260:	90                   	nop
  }
}
 261:	c9                   	leave
 262:	c3                   	ret

00000263 <child_thread>:

static void 
child_thread(void)
{
 263:	55                   	push   %ebp
 264:	89 e5                	mov    %esp,%ebp
 266:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "child thread running\n");
 269:	83 ec 08             	sub    $0x8,%esp
 26c:	68 95 0b 00 00       	push   $0xb95
 271:	6a 01                	push   $0x1
 273:	e8 27 05 00 00       	call   79f <printf>
 278:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 27b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 282:	eb 38                	jmp    2bc <child_thread+0x59>
    printf(1, "child thread 0x%x\n", (int) current_thread);
 284:	a1 40 0f 00 00       	mov    0xf40,%eax
 289:	83 ec 04             	sub    $0x4,%esp
 28c:	50                   	push   %eax
 28d:	68 ab 0b 00 00       	push   $0xbab
 292:	6a 01                	push   $0x1
 294:	e8 06 05 00 00       	call   79f <printf>
 299:	83 c4 10             	add    $0x10,%esp
    for (volatile int j = 0; j < 100000; j++);  // delay 루프 
 29c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 2a3:	eb 09                	jmp    2ae <child_thread+0x4b>
 2a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2a8:	83 c0 01             	add    $0x1,%eax
 2ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
 2ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2b1:	3d 9f 86 01 00       	cmp    $0x1869f,%eax
 2b6:	7e ed                	jle    2a5 <child_thread+0x42>
  for (i = 0; i < 100; i++) {
 2b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2bc:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 2c0:	7e c2                	jle    284 <child_thread+0x21>
  }
  printf(1, "child thread: exit\n");
 2c2:	83 ec 08             	sub    $0x8,%esp
 2c5:	68 be 0b 00 00       	push   $0xbbe
 2ca:	6a 01                	push   $0x1
 2cc:	e8 ce 04 00 00       	call   79f <printf>
 2d1:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 2d4:	a1 40 0f 00 00       	mov    0xf40,%eax
 2d9:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
 2e0:	00 00 00 
}
 2e3:	90                   	nop
 2e4:	c9                   	leave
 2e5:	c3                   	ret

000002e6 <mythread>:

static void 
mythread(void)
{
 2e6:	55                   	push   %ebp
 2e7:	89 e5                	mov    %esp,%ebp
 2e9:	83 ec 28             	sub    $0x28,%esp
  int i;
  int tid[5];

  printf(1, "my thread running\n");
 2ec:	83 ec 08             	sub    $0x8,%esp
 2ef:	68 d2 0b 00 00       	push   $0xbd2
 2f4:	6a 01                	push   $0x1
 2f6:	e8 a4 04 00 00       	call   79f <printf>
 2fb:	83 c4 10             	add    $0x10,%esp

  for (i = 0; i < 5; i++) {
 2fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 305:	eb 1b                	jmp    322 <mythread+0x3c>
    tid[i]=thread_create(child_thread);
 307:	83 ec 0c             	sub    $0xc,%esp
 30a:	68 63 02 00 00       	push   $0x263
 30f:	e8 24 fe ff ff       	call   138 <thread_create>
 314:	83 c4 10             	add    $0x10,%esp
 317:	8b 55 f4             	mov    -0xc(%ebp),%edx
 31a:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
  for (i = 0; i < 5; i++) {
 31e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 322:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 326:	7e df                	jle    307 <mythread+0x21>
  }
  
  for (i = 0; i < 5; i++) {
 328:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 32f:	eb 17                	jmp    348 <mythread+0x62>
    thread_join(tid[i]);
 331:	8b 45 f4             	mov    -0xc(%ebp),%eax
 334:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 338:	83 ec 0c             	sub    $0xc,%esp
 33b:	50                   	push   %eax
 33c:	e8 b4 fe ff ff       	call   1f5 <thread_join>
 341:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 344:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 348:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 34c:	7e e3                	jle    331 <mythread+0x4b>
  }
  
  printf(1, "my thread: exit\n");
 34e:	83 ec 08             	sub    $0x8,%esp
 351:	68 e5 0b 00 00       	push   $0xbe5
 356:	6a 01                	push   $0x1
 358:	e8 42 04 00 00       	call   79f <printf>
 35d:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 360:	a1 40 0f 00 00       	mov    0xf40,%eax
 365:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
 36c:	00 00 00 
}
 36f:	90                   	nop
 370:	c9                   	leave
 371:	c3                   	ret

00000372 <main>:

int 
main(int argc, char *argv[]) 
{
 372:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 376:	83 e4 f0             	and    $0xfffffff0,%esp
 379:	ff 71 fc             	push   -0x4(%ecx)
 37c:	55                   	push   %ebp
 37d:	89 e5                	mov    %esp,%ebp
 37f:	51                   	push   %ecx
 380:	83 ec 14             	sub    $0x14,%esp
  int tid;
  thread_init();
 383:	e8 66 fd ff ff       	call   ee <thread_init>
  tid=thread_create(mythread);
 388:	83 ec 0c             	sub    $0xc,%esp
 38b:	68 e6 02 00 00       	push   $0x2e6
 390:	e8 a3 fd ff ff       	call   138 <thread_create>
 395:	83 c4 10             	add    $0x10,%esp
 398:	89 45 f4             	mov    %eax,-0xc(%ebp)
  thread_join(tid);
 39b:	83 ec 0c             	sub    $0xc,%esp
 39e:	ff 75 f4             	push   -0xc(%ebp)
 3a1:	e8 4f fe ff ff       	call   1f5 <thread_join>
 3a6:	83 c4 10             	add    $0x10,%esp
  return 0;
 3a9:	b8 00 00 00 00       	mov    $0x0,%eax
 3ae:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 3b1:	c9                   	leave
 3b2:	8d 61 fc             	lea    -0x4(%ecx),%esp
 3b5:	c3                   	ret

000003b6 <thread_switch>:
       * restore the new thread's registers.
    */

    .globl thread_switch
thread_switch:
    pushal
 3b6:	60                   	pusha
    # Save old context
    movl current_thread, %eax      # %eax = current_thread
 3b7:	a1 40 0f 00 00       	mov    0xf40,%eax
    movl %esp, (%eax)              # current_thread->sp = %esp
 3bc:	89 20                	mov    %esp,(%eax)

    # Restore new context
    movl next_thread, %eax         # %eax = next_thread
 3be:	a1 44 0f 00 00       	mov    0xf44,%eax
    movl (%eax), %esp              # %esp = next_thread->sp
 3c3:	8b 20                	mov    (%eax),%esp

    movl %eax, current_thread
 3c5:	a3 40 0f 00 00       	mov    %eax,0xf40
    popal
 3ca:	61                   	popa
    
    # return to next thread's stack context
 3cb:	c3                   	ret

000003cc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 3cc:	55                   	push   %ebp
 3cd:	89 e5                	mov    %esp,%ebp
 3cf:	57                   	push   %edi
 3d0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 3d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3d4:	8b 55 10             	mov    0x10(%ebp),%edx
 3d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3da:	89 cb                	mov    %ecx,%ebx
 3dc:	89 df                	mov    %ebx,%edi
 3de:	89 d1                	mov    %edx,%ecx
 3e0:	fc                   	cld
 3e1:	f3 aa                	rep stos %al,%es:(%edi)
 3e3:	89 ca                	mov    %ecx,%edx
 3e5:	89 fb                	mov    %edi,%ebx
 3e7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3ea:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3ed:	90                   	nop
 3ee:	5b                   	pop    %ebx
 3ef:	5f                   	pop    %edi
 3f0:	5d                   	pop    %ebp
 3f1:	c3                   	ret

000003f2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3f2:	55                   	push   %ebp
 3f3:	89 e5                	mov    %esp,%ebp
 3f5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3f8:	8b 45 08             	mov    0x8(%ebp),%eax
 3fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3fe:	90                   	nop
 3ff:	8b 55 0c             	mov    0xc(%ebp),%edx
 402:	8d 42 01             	lea    0x1(%edx),%eax
 405:	89 45 0c             	mov    %eax,0xc(%ebp)
 408:	8b 45 08             	mov    0x8(%ebp),%eax
 40b:	8d 48 01             	lea    0x1(%eax),%ecx
 40e:	89 4d 08             	mov    %ecx,0x8(%ebp)
 411:	0f b6 12             	movzbl (%edx),%edx
 414:	88 10                	mov    %dl,(%eax)
 416:	0f b6 00             	movzbl (%eax),%eax
 419:	84 c0                	test   %al,%al
 41b:	75 e2                	jne    3ff <strcpy+0xd>
    ;
  return os;
 41d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 420:	c9                   	leave
 421:	c3                   	ret

00000422 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 422:	55                   	push   %ebp
 423:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 425:	eb 08                	jmp    42f <strcmp+0xd>
    p++, q++;
 427:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 42b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
 432:	0f b6 00             	movzbl (%eax),%eax
 435:	84 c0                	test   %al,%al
 437:	74 10                	je     449 <strcmp+0x27>
 439:	8b 45 08             	mov    0x8(%ebp),%eax
 43c:	0f b6 10             	movzbl (%eax),%edx
 43f:	8b 45 0c             	mov    0xc(%ebp),%eax
 442:	0f b6 00             	movzbl (%eax),%eax
 445:	38 c2                	cmp    %al,%dl
 447:	74 de                	je     427 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 449:	8b 45 08             	mov    0x8(%ebp),%eax
 44c:	0f b6 00             	movzbl (%eax),%eax
 44f:	0f b6 d0             	movzbl %al,%edx
 452:	8b 45 0c             	mov    0xc(%ebp),%eax
 455:	0f b6 00             	movzbl (%eax),%eax
 458:	0f b6 c0             	movzbl %al,%eax
 45b:	29 c2                	sub    %eax,%edx
 45d:	89 d0                	mov    %edx,%eax
}
 45f:	5d                   	pop    %ebp
 460:	c3                   	ret

00000461 <strlen>:

uint
strlen(char *s)
{
 461:	55                   	push   %ebp
 462:	89 e5                	mov    %esp,%ebp
 464:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 467:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 46e:	eb 04                	jmp    474 <strlen+0x13>
 470:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 474:	8b 55 fc             	mov    -0x4(%ebp),%edx
 477:	8b 45 08             	mov    0x8(%ebp),%eax
 47a:	01 d0                	add    %edx,%eax
 47c:	0f b6 00             	movzbl (%eax),%eax
 47f:	84 c0                	test   %al,%al
 481:	75 ed                	jne    470 <strlen+0xf>
    ;
  return n;
 483:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 486:	c9                   	leave
 487:	c3                   	ret

00000488 <memset>:

void*
memset(void *dst, int c, uint n)
{
 488:	55                   	push   %ebp
 489:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 48b:	8b 45 10             	mov    0x10(%ebp),%eax
 48e:	50                   	push   %eax
 48f:	ff 75 0c             	push   0xc(%ebp)
 492:	ff 75 08             	push   0x8(%ebp)
 495:	e8 32 ff ff ff       	call   3cc <stosb>
 49a:	83 c4 0c             	add    $0xc,%esp
  return dst;
 49d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4a0:	c9                   	leave
 4a1:	c3                   	ret

000004a2 <strchr>:

char*
strchr(const char *s, char c)
{
 4a2:	55                   	push   %ebp
 4a3:	89 e5                	mov    %esp,%ebp
 4a5:	83 ec 04             	sub    $0x4,%esp
 4a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ab:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 4ae:	eb 14                	jmp    4c4 <strchr+0x22>
    if(*s == c)
 4b0:	8b 45 08             	mov    0x8(%ebp),%eax
 4b3:	0f b6 00             	movzbl (%eax),%eax
 4b6:	38 45 fc             	cmp    %al,-0x4(%ebp)
 4b9:	75 05                	jne    4c0 <strchr+0x1e>
      return (char*)s;
 4bb:	8b 45 08             	mov    0x8(%ebp),%eax
 4be:	eb 13                	jmp    4d3 <strchr+0x31>
  for(; *s; s++)
 4c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4c4:	8b 45 08             	mov    0x8(%ebp),%eax
 4c7:	0f b6 00             	movzbl (%eax),%eax
 4ca:	84 c0                	test   %al,%al
 4cc:	75 e2                	jne    4b0 <strchr+0xe>
  return 0;
 4ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4d3:	c9                   	leave
 4d4:	c3                   	ret

000004d5 <gets>:

char*
gets(char *buf, int max)
{
 4d5:	55                   	push   %ebp
 4d6:	89 e5                	mov    %esp,%ebp
 4d8:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4e2:	eb 42                	jmp    526 <gets+0x51>
    cc = read(0, &c, 1);
 4e4:	83 ec 04             	sub    $0x4,%esp
 4e7:	6a 01                	push   $0x1
 4e9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4ec:	50                   	push   %eax
 4ed:	6a 00                	push   $0x0
 4ef:	e8 47 01 00 00       	call   63b <read>
 4f4:	83 c4 10             	add    $0x10,%esp
 4f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4fe:	7e 33                	jle    533 <gets+0x5e>
      break;
    buf[i++] = c;
 500:	8b 45 f4             	mov    -0xc(%ebp),%eax
 503:	8d 50 01             	lea    0x1(%eax),%edx
 506:	89 55 f4             	mov    %edx,-0xc(%ebp)
 509:	89 c2                	mov    %eax,%edx
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	01 c2                	add    %eax,%edx
 510:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 514:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 516:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 51a:	3c 0a                	cmp    $0xa,%al
 51c:	74 16                	je     534 <gets+0x5f>
 51e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 522:	3c 0d                	cmp    $0xd,%al
 524:	74 0e                	je     534 <gets+0x5f>
  for(i=0; i+1 < max; ){
 526:	8b 45 f4             	mov    -0xc(%ebp),%eax
 529:	83 c0 01             	add    $0x1,%eax
 52c:	39 45 0c             	cmp    %eax,0xc(%ebp)
 52f:	7f b3                	jg     4e4 <gets+0xf>
 531:	eb 01                	jmp    534 <gets+0x5f>
      break;
 533:	90                   	nop
      break;
  }
  buf[i] = '\0';
 534:	8b 55 f4             	mov    -0xc(%ebp),%edx
 537:	8b 45 08             	mov    0x8(%ebp),%eax
 53a:	01 d0                	add    %edx,%eax
 53c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 53f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 542:	c9                   	leave
 543:	c3                   	ret

00000544 <stat>:

int
stat(char *n, struct stat *st)
{
 544:	55                   	push   %ebp
 545:	89 e5                	mov    %esp,%ebp
 547:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 54a:	83 ec 08             	sub    $0x8,%esp
 54d:	6a 00                	push   $0x0
 54f:	ff 75 08             	push   0x8(%ebp)
 552:	e8 0c 01 00 00       	call   663 <open>
 557:	83 c4 10             	add    $0x10,%esp
 55a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 55d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 561:	79 07                	jns    56a <stat+0x26>
    return -1;
 563:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 568:	eb 25                	jmp    58f <stat+0x4b>
  r = fstat(fd, st);
 56a:	83 ec 08             	sub    $0x8,%esp
 56d:	ff 75 0c             	push   0xc(%ebp)
 570:	ff 75 f4             	push   -0xc(%ebp)
 573:	e8 03 01 00 00       	call   67b <fstat>
 578:	83 c4 10             	add    $0x10,%esp
 57b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 57e:	83 ec 0c             	sub    $0xc,%esp
 581:	ff 75 f4             	push   -0xc(%ebp)
 584:	e8 c2 00 00 00       	call   64b <close>
 589:	83 c4 10             	add    $0x10,%esp
  return r;
 58c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 58f:	c9                   	leave
 590:	c3                   	ret

00000591 <atoi>:

int
atoi(const char *s)
{
 591:	55                   	push   %ebp
 592:	89 e5                	mov    %esp,%ebp
 594:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 597:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 59e:	eb 25                	jmp    5c5 <atoi+0x34>
    n = n*10 + *s++ - '0';
 5a0:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5a3:	89 d0                	mov    %edx,%eax
 5a5:	c1 e0 02             	shl    $0x2,%eax
 5a8:	01 d0                	add    %edx,%eax
 5aa:	01 c0                	add    %eax,%eax
 5ac:	89 c1                	mov    %eax,%ecx
 5ae:	8b 45 08             	mov    0x8(%ebp),%eax
 5b1:	8d 50 01             	lea    0x1(%eax),%edx
 5b4:	89 55 08             	mov    %edx,0x8(%ebp)
 5b7:	0f b6 00             	movzbl (%eax),%eax
 5ba:	0f be c0             	movsbl %al,%eax
 5bd:	01 c8                	add    %ecx,%eax
 5bf:	83 e8 30             	sub    $0x30,%eax
 5c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5c5:	8b 45 08             	mov    0x8(%ebp),%eax
 5c8:	0f b6 00             	movzbl (%eax),%eax
 5cb:	3c 2f                	cmp    $0x2f,%al
 5cd:	7e 0a                	jle    5d9 <atoi+0x48>
 5cf:	8b 45 08             	mov    0x8(%ebp),%eax
 5d2:	0f b6 00             	movzbl (%eax),%eax
 5d5:	3c 39                	cmp    $0x39,%al
 5d7:	7e c7                	jle    5a0 <atoi+0xf>
  return n;
 5d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5dc:	c9                   	leave
 5dd:	c3                   	ret

000005de <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 5de:	55                   	push   %ebp
 5df:	89 e5                	mov    %esp,%ebp
 5e1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 5e4:	8b 45 08             	mov    0x8(%ebp),%eax
 5e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5f0:	eb 17                	jmp    609 <memmove+0x2b>
    *dst++ = *src++;
 5f2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5f5:	8d 42 01             	lea    0x1(%edx),%eax
 5f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fe:	8d 48 01             	lea    0x1(%eax),%ecx
 601:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 604:	0f b6 12             	movzbl (%edx),%edx
 607:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 609:	8b 45 10             	mov    0x10(%ebp),%eax
 60c:	8d 50 ff             	lea    -0x1(%eax),%edx
 60f:	89 55 10             	mov    %edx,0x10(%ebp)
 612:	85 c0                	test   %eax,%eax
 614:	7f dc                	jg     5f2 <memmove+0x14>
  return vdst;
 616:	8b 45 08             	mov    0x8(%ebp),%eax
}
 619:	c9                   	leave
 61a:	c3                   	ret

0000061b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 61b:	b8 01 00 00 00       	mov    $0x1,%eax
 620:	cd 40                	int    $0x40
 622:	c3                   	ret

00000623 <exit>:
SYSCALL(exit)
 623:	b8 02 00 00 00       	mov    $0x2,%eax
 628:	cd 40                	int    $0x40
 62a:	c3                   	ret

0000062b <wait>:
SYSCALL(wait)
 62b:	b8 03 00 00 00       	mov    $0x3,%eax
 630:	cd 40                	int    $0x40
 632:	c3                   	ret

00000633 <pipe>:
SYSCALL(pipe)
 633:	b8 04 00 00 00       	mov    $0x4,%eax
 638:	cd 40                	int    $0x40
 63a:	c3                   	ret

0000063b <read>:
SYSCALL(read)
 63b:	b8 05 00 00 00       	mov    $0x5,%eax
 640:	cd 40                	int    $0x40
 642:	c3                   	ret

00000643 <write>:
SYSCALL(write)
 643:	b8 10 00 00 00       	mov    $0x10,%eax
 648:	cd 40                	int    $0x40
 64a:	c3                   	ret

0000064b <close>:
SYSCALL(close)
 64b:	b8 15 00 00 00       	mov    $0x15,%eax
 650:	cd 40                	int    $0x40
 652:	c3                   	ret

00000653 <kill>:
SYSCALL(kill)
 653:	b8 06 00 00 00       	mov    $0x6,%eax
 658:	cd 40                	int    $0x40
 65a:	c3                   	ret

0000065b <exec>:
SYSCALL(exec)
 65b:	b8 07 00 00 00       	mov    $0x7,%eax
 660:	cd 40                	int    $0x40
 662:	c3                   	ret

00000663 <open>:
SYSCALL(open)
 663:	b8 0f 00 00 00       	mov    $0xf,%eax
 668:	cd 40                	int    $0x40
 66a:	c3                   	ret

0000066b <mknod>:
SYSCALL(mknod)
 66b:	b8 11 00 00 00       	mov    $0x11,%eax
 670:	cd 40                	int    $0x40
 672:	c3                   	ret

00000673 <unlink>:
SYSCALL(unlink)
 673:	b8 12 00 00 00       	mov    $0x12,%eax
 678:	cd 40                	int    $0x40
 67a:	c3                   	ret

0000067b <fstat>:
SYSCALL(fstat)
 67b:	b8 08 00 00 00       	mov    $0x8,%eax
 680:	cd 40                	int    $0x40
 682:	c3                   	ret

00000683 <link>:
SYSCALL(link)
 683:	b8 13 00 00 00       	mov    $0x13,%eax
 688:	cd 40                	int    $0x40
 68a:	c3                   	ret

0000068b <mkdir>:
SYSCALL(mkdir)
 68b:	b8 14 00 00 00       	mov    $0x14,%eax
 690:	cd 40                	int    $0x40
 692:	c3                   	ret

00000693 <chdir>:
SYSCALL(chdir)
 693:	b8 09 00 00 00       	mov    $0x9,%eax
 698:	cd 40                	int    $0x40
 69a:	c3                   	ret

0000069b <dup>:
SYSCALL(dup)
 69b:	b8 0a 00 00 00       	mov    $0xa,%eax
 6a0:	cd 40                	int    $0x40
 6a2:	c3                   	ret

000006a3 <getpid>:
SYSCALL(getpid)
 6a3:	b8 0b 00 00 00       	mov    $0xb,%eax
 6a8:	cd 40                	int    $0x40
 6aa:	c3                   	ret

000006ab <sbrk>:
SYSCALL(sbrk)
 6ab:	b8 0c 00 00 00       	mov    $0xc,%eax
 6b0:	cd 40                	int    $0x40
 6b2:	c3                   	ret

000006b3 <sleep>:
SYSCALL(sleep)
 6b3:	b8 0d 00 00 00       	mov    $0xd,%eax
 6b8:	cd 40                	int    $0x40
 6ba:	c3                   	ret

000006bb <uptime>:
SYSCALL(uptime)
 6bb:	b8 0e 00 00 00       	mov    $0xe,%eax
 6c0:	cd 40                	int    $0x40
 6c2:	c3                   	ret

000006c3 <uthread_init>:
SYSCALL(uthread_init)
 6c3:	b8 16 00 00 00       	mov    $0x16,%eax
 6c8:	cd 40                	int    $0x40
 6ca:	c3                   	ret

000006cb <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6cb:	55                   	push   %ebp
 6cc:	89 e5                	mov    %esp,%ebp
 6ce:	83 ec 18             	sub    $0x18,%esp
 6d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d4:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6d7:	83 ec 04             	sub    $0x4,%esp
 6da:	6a 01                	push   $0x1
 6dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6df:	50                   	push   %eax
 6e0:	ff 75 08             	push   0x8(%ebp)
 6e3:	e8 5b ff ff ff       	call   643 <write>
 6e8:	83 c4 10             	add    $0x10,%esp
}
 6eb:	90                   	nop
 6ec:	c9                   	leave
 6ed:	c3                   	ret

000006ee <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6ee:	55                   	push   %ebp
 6ef:	89 e5                	mov    %esp,%ebp
 6f1:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6f4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6fb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6ff:	74 17                	je     718 <printint+0x2a>
 701:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 705:	79 11                	jns    718 <printint+0x2a>
    neg = 1;
 707:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 70e:	8b 45 0c             	mov    0xc(%ebp),%eax
 711:	f7 d8                	neg    %eax
 713:	89 45 ec             	mov    %eax,-0x14(%ebp)
 716:	eb 06                	jmp    71e <printint+0x30>
  } else {
    x = xx;
 718:	8b 45 0c             	mov    0xc(%ebp),%eax
 71b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 71e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 725:	8b 4d 10             	mov    0x10(%ebp),%ecx
 728:	8b 45 ec             	mov    -0x14(%ebp),%eax
 72b:	ba 00 00 00 00       	mov    $0x0,%edx
 730:	f7 f1                	div    %ecx
 732:	89 d1                	mov    %edx,%ecx
 734:	8b 45 f4             	mov    -0xc(%ebp),%eax
 737:	8d 50 01             	lea    0x1(%eax),%edx
 73a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 73d:	0f b6 91 2c 0f 00 00 	movzbl 0xf2c(%ecx),%edx
 744:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 748:	8b 4d 10             	mov    0x10(%ebp),%ecx
 74b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 74e:	ba 00 00 00 00       	mov    $0x0,%edx
 753:	f7 f1                	div    %ecx
 755:	89 45 ec             	mov    %eax,-0x14(%ebp)
 758:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 75c:	75 c7                	jne    725 <printint+0x37>
  if(neg)
 75e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 762:	74 2d                	je     791 <printint+0xa3>
    buf[i++] = '-';
 764:	8b 45 f4             	mov    -0xc(%ebp),%eax
 767:	8d 50 01             	lea    0x1(%eax),%edx
 76a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 76d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 772:	eb 1d                	jmp    791 <printint+0xa3>
    putc(fd, buf[i]);
 774:	8d 55 dc             	lea    -0x24(%ebp),%edx
 777:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77a:	01 d0                	add    %edx,%eax
 77c:	0f b6 00             	movzbl (%eax),%eax
 77f:	0f be c0             	movsbl %al,%eax
 782:	83 ec 08             	sub    $0x8,%esp
 785:	50                   	push   %eax
 786:	ff 75 08             	push   0x8(%ebp)
 789:	e8 3d ff ff ff       	call   6cb <putc>
 78e:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 791:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 795:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 799:	79 d9                	jns    774 <printint+0x86>
}
 79b:	90                   	nop
 79c:	90                   	nop
 79d:	c9                   	leave
 79e:	c3                   	ret

0000079f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 79f:	55                   	push   %ebp
 7a0:	89 e5                	mov    %esp,%ebp
 7a2:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7a5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7ac:	8d 45 0c             	lea    0xc(%ebp),%eax
 7af:	83 c0 04             	add    $0x4,%eax
 7b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7b5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7bc:	e9 59 01 00 00       	jmp    91a <printf+0x17b>
    c = fmt[i] & 0xff;
 7c1:	8b 55 0c             	mov    0xc(%ebp),%edx
 7c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c7:	01 d0                	add    %edx,%eax
 7c9:	0f b6 00             	movzbl (%eax),%eax
 7cc:	0f be c0             	movsbl %al,%eax
 7cf:	25 ff 00 00 00       	and    $0xff,%eax
 7d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7d7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7db:	75 2c                	jne    809 <printf+0x6a>
      if(c == '%'){
 7dd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7e1:	75 0c                	jne    7ef <printf+0x50>
        state = '%';
 7e3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7ea:	e9 27 01 00 00       	jmp    916 <printf+0x177>
      } else {
        putc(fd, c);
 7ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7f2:	0f be c0             	movsbl %al,%eax
 7f5:	83 ec 08             	sub    $0x8,%esp
 7f8:	50                   	push   %eax
 7f9:	ff 75 08             	push   0x8(%ebp)
 7fc:	e8 ca fe ff ff       	call   6cb <putc>
 801:	83 c4 10             	add    $0x10,%esp
 804:	e9 0d 01 00 00       	jmp    916 <printf+0x177>
      }
    } else if(state == '%'){
 809:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 80d:	0f 85 03 01 00 00    	jne    916 <printf+0x177>
      if(c == 'd'){
 813:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 817:	75 1e                	jne    837 <printf+0x98>
        printint(fd, *ap, 10, 1);
 819:	8b 45 e8             	mov    -0x18(%ebp),%eax
 81c:	8b 00                	mov    (%eax),%eax
 81e:	6a 01                	push   $0x1
 820:	6a 0a                	push   $0xa
 822:	50                   	push   %eax
 823:	ff 75 08             	push   0x8(%ebp)
 826:	e8 c3 fe ff ff       	call   6ee <printint>
 82b:	83 c4 10             	add    $0x10,%esp
        ap++;
 82e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 832:	e9 d8 00 00 00       	jmp    90f <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 837:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 83b:	74 06                	je     843 <printf+0xa4>
 83d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 841:	75 1e                	jne    861 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 843:	8b 45 e8             	mov    -0x18(%ebp),%eax
 846:	8b 00                	mov    (%eax),%eax
 848:	6a 00                	push   $0x0
 84a:	6a 10                	push   $0x10
 84c:	50                   	push   %eax
 84d:	ff 75 08             	push   0x8(%ebp)
 850:	e8 99 fe ff ff       	call   6ee <printint>
 855:	83 c4 10             	add    $0x10,%esp
        ap++;
 858:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 85c:	e9 ae 00 00 00       	jmp    90f <printf+0x170>
      } else if(c == 's'){
 861:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 865:	75 43                	jne    8aa <printf+0x10b>
        s = (char*)*ap;
 867:	8b 45 e8             	mov    -0x18(%ebp),%eax
 86a:	8b 00                	mov    (%eax),%eax
 86c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 86f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 873:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 877:	75 25                	jne    89e <printf+0xff>
          s = "(null)";
 879:	c7 45 f4 f6 0b 00 00 	movl   $0xbf6,-0xc(%ebp)
        while(*s != 0){
 880:	eb 1c                	jmp    89e <printf+0xff>
          putc(fd, *s);
 882:	8b 45 f4             	mov    -0xc(%ebp),%eax
 885:	0f b6 00             	movzbl (%eax),%eax
 888:	0f be c0             	movsbl %al,%eax
 88b:	83 ec 08             	sub    $0x8,%esp
 88e:	50                   	push   %eax
 88f:	ff 75 08             	push   0x8(%ebp)
 892:	e8 34 fe ff ff       	call   6cb <putc>
 897:	83 c4 10             	add    $0x10,%esp
          s++;
 89a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 89e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a1:	0f b6 00             	movzbl (%eax),%eax
 8a4:	84 c0                	test   %al,%al
 8a6:	75 da                	jne    882 <printf+0xe3>
 8a8:	eb 65                	jmp    90f <printf+0x170>
        }
      } else if(c == 'c'){
 8aa:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8ae:	75 1d                	jne    8cd <printf+0x12e>
        putc(fd, *ap);
 8b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8b3:	8b 00                	mov    (%eax),%eax
 8b5:	0f be c0             	movsbl %al,%eax
 8b8:	83 ec 08             	sub    $0x8,%esp
 8bb:	50                   	push   %eax
 8bc:	ff 75 08             	push   0x8(%ebp)
 8bf:	e8 07 fe ff ff       	call   6cb <putc>
 8c4:	83 c4 10             	add    $0x10,%esp
        ap++;
 8c7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8cb:	eb 42                	jmp    90f <printf+0x170>
      } else if(c == '%'){
 8cd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8d1:	75 17                	jne    8ea <printf+0x14b>
        putc(fd, c);
 8d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8d6:	0f be c0             	movsbl %al,%eax
 8d9:	83 ec 08             	sub    $0x8,%esp
 8dc:	50                   	push   %eax
 8dd:	ff 75 08             	push   0x8(%ebp)
 8e0:	e8 e6 fd ff ff       	call   6cb <putc>
 8e5:	83 c4 10             	add    $0x10,%esp
 8e8:	eb 25                	jmp    90f <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8ea:	83 ec 08             	sub    $0x8,%esp
 8ed:	6a 25                	push   $0x25
 8ef:	ff 75 08             	push   0x8(%ebp)
 8f2:	e8 d4 fd ff ff       	call   6cb <putc>
 8f7:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8fd:	0f be c0             	movsbl %al,%eax
 900:	83 ec 08             	sub    $0x8,%esp
 903:	50                   	push   %eax
 904:	ff 75 08             	push   0x8(%ebp)
 907:	e8 bf fd ff ff       	call   6cb <putc>
 90c:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 90f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 916:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 91a:	8b 55 0c             	mov    0xc(%ebp),%edx
 91d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 920:	01 d0                	add    %edx,%eax
 922:	0f b6 00             	movzbl (%eax),%eax
 925:	84 c0                	test   %al,%al
 927:	0f 85 94 fe ff ff    	jne    7c1 <printf+0x22>
    }
  }
}
 92d:	90                   	nop
 92e:	90                   	nop
 92f:	c9                   	leave
 930:	c3                   	ret

00000931 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 931:	55                   	push   %ebp
 932:	89 e5                	mov    %esp,%ebp
 934:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 937:	8b 45 08             	mov    0x8(%ebp),%eax
 93a:	83 e8 08             	sub    $0x8,%eax
 93d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 940:	a1 08 50 01 00       	mov    0x15008,%eax
 945:	89 45 fc             	mov    %eax,-0x4(%ebp)
 948:	eb 24                	jmp    96e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 94a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94d:	8b 00                	mov    (%eax),%eax
 94f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 952:	72 12                	jb     966 <free+0x35>
 954:	8b 45 f8             	mov    -0x8(%ebp),%eax
 957:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 95a:	72 24                	jb     980 <free+0x4f>
 95c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95f:	8b 00                	mov    (%eax),%eax
 961:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 964:	72 1a                	jb     980 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 966:	8b 45 fc             	mov    -0x4(%ebp),%eax
 969:	8b 00                	mov    (%eax),%eax
 96b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 96e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 971:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 974:	73 d4                	jae    94a <free+0x19>
 976:	8b 45 fc             	mov    -0x4(%ebp),%eax
 979:	8b 00                	mov    (%eax),%eax
 97b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 97e:	73 ca                	jae    94a <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 980:	8b 45 f8             	mov    -0x8(%ebp),%eax
 983:	8b 40 04             	mov    0x4(%eax),%eax
 986:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 98d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 990:	01 c2                	add    %eax,%edx
 992:	8b 45 fc             	mov    -0x4(%ebp),%eax
 995:	8b 00                	mov    (%eax),%eax
 997:	39 c2                	cmp    %eax,%edx
 999:	75 24                	jne    9bf <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 99b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99e:	8b 50 04             	mov    0x4(%eax),%edx
 9a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a4:	8b 00                	mov    (%eax),%eax
 9a6:	8b 40 04             	mov    0x4(%eax),%eax
 9a9:	01 c2                	add    %eax,%edx
 9ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ae:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b4:	8b 00                	mov    (%eax),%eax
 9b6:	8b 10                	mov    (%eax),%edx
 9b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9bb:	89 10                	mov    %edx,(%eax)
 9bd:	eb 0a                	jmp    9c9 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c2:	8b 10                	mov    (%eax),%edx
 9c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c7:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cc:	8b 40 04             	mov    0x4(%eax),%eax
 9cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d9:	01 d0                	add    %edx,%eax
 9db:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9de:	75 20                	jne    a00 <free+0xcf>
    p->s.size += bp->s.size;
 9e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e3:	8b 50 04             	mov    0x4(%eax),%edx
 9e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e9:	8b 40 04             	mov    0x4(%eax),%eax
 9ec:	01 c2                	add    %eax,%edx
 9ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f7:	8b 10                	mov    (%eax),%edx
 9f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fc:	89 10                	mov    %edx,(%eax)
 9fe:	eb 08                	jmp    a08 <free+0xd7>
  } else
    p->s.ptr = bp;
 a00:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a03:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a06:	89 10                	mov    %edx,(%eax)
  freep = p;
 a08:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a0b:	a3 08 50 01 00       	mov    %eax,0x15008
}
 a10:	90                   	nop
 a11:	c9                   	leave
 a12:	c3                   	ret

00000a13 <morecore>:

static Header*
morecore(uint nu)
{
 a13:	55                   	push   %ebp
 a14:	89 e5                	mov    %esp,%ebp
 a16:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a19:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a20:	77 07                	ja     a29 <morecore+0x16>
    nu = 4096;
 a22:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a29:	8b 45 08             	mov    0x8(%ebp),%eax
 a2c:	c1 e0 03             	shl    $0x3,%eax
 a2f:	83 ec 0c             	sub    $0xc,%esp
 a32:	50                   	push   %eax
 a33:	e8 73 fc ff ff       	call   6ab <sbrk>
 a38:	83 c4 10             	add    $0x10,%esp
 a3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a3e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a42:	75 07                	jne    a4b <morecore+0x38>
    return 0;
 a44:	b8 00 00 00 00       	mov    $0x0,%eax
 a49:	eb 26                	jmp    a71 <morecore+0x5e>
  hp = (Header*)p;
 a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a54:	8b 55 08             	mov    0x8(%ebp),%edx
 a57:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a5d:	83 c0 08             	add    $0x8,%eax
 a60:	83 ec 0c             	sub    $0xc,%esp
 a63:	50                   	push   %eax
 a64:	e8 c8 fe ff ff       	call   931 <free>
 a69:	83 c4 10             	add    $0x10,%esp
  return freep;
 a6c:	a1 08 50 01 00       	mov    0x15008,%eax
}
 a71:	c9                   	leave
 a72:	c3                   	ret

00000a73 <malloc>:

void*
malloc(uint nbytes)
{
 a73:	55                   	push   %ebp
 a74:	89 e5                	mov    %esp,%ebp
 a76:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a79:	8b 45 08             	mov    0x8(%ebp),%eax
 a7c:	83 c0 07             	add    $0x7,%eax
 a7f:	c1 e8 03             	shr    $0x3,%eax
 a82:	83 c0 01             	add    $0x1,%eax
 a85:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a88:	a1 08 50 01 00       	mov    0x15008,%eax
 a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a94:	75 23                	jne    ab9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a96:	c7 45 f0 00 50 01 00 	movl   $0x15000,-0x10(%ebp)
 a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa0:	a3 08 50 01 00       	mov    %eax,0x15008
 aa5:	a1 08 50 01 00       	mov    0x15008,%eax
 aaa:	a3 00 50 01 00       	mov    %eax,0x15000
    base.s.size = 0;
 aaf:	c7 05 04 50 01 00 00 	movl   $0x0,0x15004
 ab6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abc:	8b 00                	mov    (%eax),%eax
 abe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac4:	8b 40 04             	mov    0x4(%eax),%eax
 ac7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 aca:	72 4d                	jb     b19 <malloc+0xa6>
      if(p->s.size == nunits)
 acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acf:	8b 40 04             	mov    0x4(%eax),%eax
 ad2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 ad5:	75 0c                	jne    ae3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ada:	8b 10                	mov    (%eax),%edx
 adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 adf:	89 10                	mov    %edx,(%eax)
 ae1:	eb 26                	jmp    b09 <malloc+0x96>
      else {
        p->s.size -= nunits;
 ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae6:	8b 40 04             	mov    0x4(%eax),%eax
 ae9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 aec:	89 c2                	mov    %eax,%edx
 aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af7:	8b 40 04             	mov    0x4(%eax),%eax
 afa:	c1 e0 03             	shl    $0x3,%eax
 afd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b03:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b06:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b0c:	a3 08 50 01 00       	mov    %eax,0x15008
      return (void*)(p + 1);
 b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b14:	83 c0 08             	add    $0x8,%eax
 b17:	eb 3b                	jmp    b54 <malloc+0xe1>
    }
    if(p == freep)
 b19:	a1 08 50 01 00       	mov    0x15008,%eax
 b1e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b21:	75 1e                	jne    b41 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 b23:	83 ec 0c             	sub    $0xc,%esp
 b26:	ff 75 ec             	push   -0x14(%ebp)
 b29:	e8 e5 fe ff ff       	call   a13 <morecore>
 b2e:	83 c4 10             	add    $0x10,%esp
 b31:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b34:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b38:	75 07                	jne    b41 <malloc+0xce>
        return 0;
 b3a:	b8 00 00 00 00       	mov    $0x0,%eax
 b3f:	eb 13                	jmp    b54 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b44:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4a:	8b 00                	mov    (%eax),%eax
 b4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b4f:	e9 6d ff ff ff       	jmp    ac1 <malloc+0x4e>
  }
}
 b54:	c9                   	leave
 b55:	c3                   	ret
