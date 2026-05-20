.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"

.section .text

.globl test_mark_ptr
.type test_mark_ptr, @function

test_mark_ptr:
    pushl $test_mark_ptr_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_mark_ptr_marks_unavailable
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_mark_ptr_fail

    end_mark_ptr_pass:
        pushl $test_mark_ptr_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_mark_ptr_fail:
        pushl $test_mark_ptr_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret


.globl test_mark_ptr_marks_unavailable
.type test_mark_ptr_marks_unavailable, @function

test_mark_ptr_marks_unavailable:
    pushl %ebp
    movl %esp, %ebp

    pushl $16
    call allocate
    addl $4, %esp

    pushl $UNAVAILABLE
    pushl %eax
    call mark_ptr
    addl $8, %esp

    cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
