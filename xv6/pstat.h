#ifndef _PSTAT_H_
#define _PSTAT_H_

#include "param.h"  // NPROC 정의용

struct pstat {
  int inuse[NPROC];          // 프로세스 테이블 슬롯 사용 여부 (0 또는 1)
  int pid[NPROC];            // 프로세스 PID
  int priority[NPROC];       // 현재 우선순위 (MLFQ 기준, 0~3)
  int state[NPROC];          // 현재 상태 (SLEEPING, RUNNABLE 등)
  int ticks[NPROC][4];       // 각 우선순위에서 사용한 틱 수
  int wait_ticks[NPROC][4];  // 각 우선순위에서 대기한 틱 수
};

#endif // _PSTAT_H_
