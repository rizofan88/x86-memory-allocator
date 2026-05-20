.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"

.section .text

.globl test_extend_break
.type test_extend_break, @function

test_extend_break:
    pushl $test_extend_break_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_extend_break_moves_break_forward
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_extend_break_fail
    
    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_extend_break_updates_break
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_extend_break_fail

    end_extend_break_pass:
        pushl $test_extend_break_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_extend_break_fail:
        pushl $test_extend_break_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret


.globl test_extend_break_moves_break_forward
.type test_extend_break_moves_break_forward, @function

test_extend_break_moves_break_forward:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

    movl %eax, -4(%ebp)             # save old break

    pushl $16
    pushl %eax
    call extend_break
    addl $4, %esp

    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

    cmpl -4(%ebp), %eax             # new break should be greater than old break
    jle error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

.globl test_extend_break_updates_break
.type test_extend_break_updates_break, @function

test_extend_break_updates_break:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

    movl %eax, -4(%ebp)             # save old break

    pushl $16
    pushl %eax
    call extend_break
    addl $4, %esp

    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

    addl $HDR_SIZE, -4(%ebp)        
    addl $16, -4(%ebp)
    cmpl -4(%ebp), %eax          
    jne error_exit                  # new break should be old + requested size
                                    # plus the header size
    movl %ebp, %esp
    popl %ebp
    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
