.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"

.section .text

.globl test_allocate_and_deallocate
.type test_allocate_and_deallocate, @function

test_allocate_and_deallocate:
    pushl $test_allocate_and_deallocate_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_allocate_and_deallocate_marks_free
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_and_deallocate_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_allocate_and_deallocate_reuses_freed_block
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_and_deallocate_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_allocate_and_deallocate_skips_used_block
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_and_deallocate_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_correct_reuse_behaviour
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_and_deallocate_fail

    end_allocate_and_deallocate_pass:
        pushl $test_allocate_and_deallocate_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_allocate_and_deallocate_fail:
        pushl $test_allocate_and_deallocate_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret


.globl test_allocate_and_deallocate_marks_free
.type test_allocate_and_deallocate_marks_free, @function

test_allocate_and_deallocate_marks_free:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    pushl $16
    call allocate
    addl $4, %esp

    movl %eax, -4(%ebp)

    pushl -4(%ebp)
    call deallocate
    addl $4, %esp

    movl -4(%ebp), %eax
    subl $HDR_SIZE, %eax

    cmpl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################


.globl test_allocate_and_deallocate_reuses_freed_block
.type test_allocate_and_deallocate_reuses_freed_block, @function

test_allocate_and_deallocate_reuses_freed_block:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    pushl $16
    call allocate
    addl $4, %esp

    movl %eax, -4(%ebp)

    pushl -4(%ebp)
    call deallocate
    addl $4, %esp

    pushl $16
    call allocate
    addl $4, %esp

    cmpl -4(%ebp), %eax
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################


.globl test_allocate_and_deallocate_skips_used_block
.type test_allocate_and_deallocate_skips_used_block, @function

test_allocate_and_deallocate_skips_used_block:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp

    pushl $16
    call allocate
    addl $4, %esp
    movl %eax, -4(%ebp)             # ptr1

    pushl $16
    call allocate
    addl $4, %esp
    movl %eax, -8(%ebp)             # ptr2

    pushl -4(%ebp)
    call deallocate
    addl $4, %esp

    pushl $16
    call allocate
    addl $4, %esp

    cmpl -4(%ebp), %eax             # should reuse ptr1
    jne error_exit

    cmpl -8(%ebp), %eax             # should not return still-used ptr2
    je error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

.globl test_correct_reuse_behaviour
.type test_correct_reuse_behaviour, @function

test_correct_reuse_behaviour:
    pushl %ebp
    movl %esp, %ebp
    subl $12, %esp

    pushl $16
    call allocate
    addl $4, %esp
    movl %eax, -4(%ebp)             # ptr1

    pushl $16
    call allocate
    addl $4, %esp
    movl %eax, -8(%ebp)             # ptr2

    pushl -4(%ebp)
    call deallocate
    addl $4, %esp

    pushl $16
    call allocate
    addl $4, %esp
    movl %eax, -12(%ebp)            # ptr3

    cmpl -4(%ebp), %eax             # ptr3 should reuse ptr1
    jne error_exit

    cmpl -8(%ebp), %eax             # ptr3 should not be ptr2
    je error_exit

    movl -12(%ebp), %eax
    subl $HDR_SIZE, %eax

    cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
    jne error_exit                  # reused block should be marked used again

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
