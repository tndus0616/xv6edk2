	.text

	/*
         * save the old thread's registers,
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	# 레지스터를 스택에 저장
        pushl %ebp
        pushl %ebx
        pushl %esi
        pushl %edi

        # 현재 스택 포인터(%esp)를 current_thread->sp에 저장
        movl current_thread, %eax
        movl %esp, (%eax)

        # next_thread->sp 값을 %esp에 복원 (스택 포인터 전환)
        movl next_thread, %eax
        movl (%eax), %esp

        # 스택에서 레지스터를 복원
        popl %edi
        popl %esi
        popl %ebx
        popl %ebp

        # current_thread를 next_thread로 갱신
        movl next_thread, %eax
        movl %eax, current_thread
	

	ret    /* return to ra */
