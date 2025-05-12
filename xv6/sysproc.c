#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

int
sys_uthread_init(void)
{
  int sched;
  //사용자로부터 전달된 첫 번째 인자 (scheduler 함수 주소)를 읽어옴
  // 실패시 -1 반환
  if (argint(0, &sched) < 0)
    return -1;

  cprintf("[kernel] sys_uthread_init 호출됨, 전달된 주소 = 0x%x\n", sched);
  //현재 프로세스의 pcb해당 주소를 저장(함수주소이므로 uint로 저장)
  myproc()->scheduler = (uint)sched;
  //사용자 수준 스레드를 사용하는 프로세스임을 나타내는 플래그 설정
  myproc()->is_threaded = 1;
  cprintf("[kernel] 저장 완료: proc->scheduler = 0x%x\n", myproc()->scheduler);
  //시스템 콜 정상 종료
  return 0;
}

int
sys_yield(void)
{
  yield();  // 커널 내부의 scheduler.c 함수
  return 0;
}
