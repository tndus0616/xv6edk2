#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"
#include "i8254.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:  //타이머 인터럽트가 발생했을때
    if(cpuid() == 0){   //cpu 0번만 global tick 증가 및 sleep-wakeup처리
      acquire(&tickslock);  //tick 값 보호를 위한 락 획득
      ticks++;              //전역 tick 카운터 증가
      wakeup(&ticks);       // tick을 기다리는 프로세스 깨움
      release(&tickslock);    //락 해제
    }
    lapiceoi();     //LOCAl apic에 인터럽트 처리 완료 알림
    struct proc *proc = myproc();
    if (proc && proc->state == RUNNING && proc->is_threaded && proc->scheduler) {
      ((void (*)(void))proc->scheduler)();  // 🎯 사용자 스케줄러 함수 호출
    }

    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 0xB:
    i8254_intr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();


  
  //myproc() 현재 cpu에서 실행중인 프로세스 
  //myproc()->state == RUNNING 현재 프로세스가 실행 중인지 확인
  //tf->trapno == T_IRQ0+IRQ_TIMER trap 번호가 타이머 인터럽트인지 확인
  // yield() 현재 프로세스를 RUNNABLE로 바꾸고, sched() 호출해서 다른 프로세스로 문맥을 전환
  if(myproc() && myproc()->state == RUNNING &&tf->trapno == T_IRQ0+IRQ_TIMER) 
  {
    myproc()->ticks[myproc()->priority]++; //타이머 인터럽트가 발생할때 마다 1틱이 추가됨
    yield();
  }

//myproc() 현재 CPU에서 실행 중인 프로세스
//myproc()->killed 커널에서 이 프로세스를 종료하라고 표시 했는지 확인
//(tf->cs & 3) == DPL_USER 현재 trap이 user space 에서 발생했는지 확인|
//exit() 프로세스를 종료하는 시스템 콜 
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
