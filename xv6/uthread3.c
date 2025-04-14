#include "types.h"
#include "stat.h"
#include "user.h"

#define FREE     0x0
#define RUNNING  0x1
#define RUNNABLE 0x2
#define WAIT     0x3

#define STACK_SIZE  8192
#define MAX_THREAD  10

typedef struct thread thread_t, *thread_p;
typedef struct mutex mutex_t, *mutex_p;

struct thread {
  int        tid;
  int        sp;
  char       stack[STACK_SIZE];
  int        state;
};

static thread_t all_thread[MAX_THREAD];
thread_p current_thread;
thread_p next_thread;
extern void thread_switch(void);

static void 
thread_schedule(void)
{
  thread_p t;

  next_thread = 0;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == RUNNABLE && t != current_thread) {
      next_thread = t;
      break;
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
    next_thread = current_thread;
  }

  if (next_thread == 0) {
    printf(2, "thread_schedule: no runnable threads\n");
    exit();
  }

  if (current_thread != next_thread) {
    next_thread->state = RUNNING;
    current_thread->state = RUNNABLE;
    thread_switch();
  } else {
    next_thread = 0;
  }
}

void
thread_yield(void)
{
  current_thread->state = RUNNABLE;
  thread_schedule();
}

void
thread_exit(void)
{
  current_thread->state = FREE;
  thread_schedule();
}

void 
thread_init(void)
{
  uthread_init((int)thread_yield);
  current_thread = &all_thread[0];
  current_thread->state = RUNNING;
  current_thread->tid = 0;
}

int
thread_create(void (*func)())
{
  static int global_tid = 1;
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) {
      t->sp = (int)(t->stack + STACK_SIZE);
      t->sp -= 4;
      *(int*)(t->sp) = (int)func;
      t->sp -= 32;
      t->tid = global_tid++;
      t->state = RUNNABLE;
      return t->tid;
    }
  }
  return -1;
}

static void
thread_suspend(int tid)
{
  thread_p t;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->tid == tid) {
      if (t->state == RUNNABLE || t->state == RUNNING) {
        t->state = WAIT;
        printf(1, "Suspended thread %d\n", tid);
      }
      break;
    }
  }
}

static void
thread_resume(int tid)
{
  thread_p t;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->tid == tid) {
      if (t->state == WAIT) {
        t->state = RUNNABLE;
        printf(1, "Resumed thread %d\n", tid);
      }
      break;
    }
  }
}

static void 
mythread(void)
{
  int i;
  printf(1, "my thread running: tid=%d\n", current_thread->tid);
  for (i = 0; i < 10; i++) {
    printf(1, "my thread %d\n", current_thread->tid);
    for (volatile int j = 0; j < 100000; j++);
    thread_yield();
  }
  printf(1, "my thread: exit %d\n", current_thread->tid);
  thread_exit();
}

int 
main(int argc, char *argv[])
{
  int tid1, tid2;
  thread_init();
  tid1 = thread_create(mythread);
  tid2 = thread_create(mythread);

  for (volatile int i = 0; i < 100000000; i++);
  thread_suspend(tid1);

  for (volatile int i = 0; i < 100000000; i++);
  thread_suspend(tid2);

  thread_resume(tid1);
  for (volatile int i = 0; i < 100000000; i++);

  thread_resume(tid2);
  for (volatile int i = 0; i < 100000000; i++);

  thread_yield();
  exit();
}
