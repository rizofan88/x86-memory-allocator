.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"

.section .text

.globl test_valid_heap_growth
.type test_valid_heap_growth, @function

test_valid_heap_growth:
    pushl $test_valid_heap_growth_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_valid_heap_growth_moves_break_forward
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_valid_heap_growth_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_valid_heap_growth_by_header_plus_size
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_valid_heap_growth_fail

    end_valid_heap_growth_pass:
        pushl $test_valid_heap_growth_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_valid_heap_growth_fail:
        pushl $test_valid_heap_growth_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret


.globl test_valid_heap_growth_moves_break_forward
.type test_valid_heap_growth_moves_break_forward, @function

test_valid_heap_growth_moves_break_forward:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

    movl %eax, -4(%ebp)             # old break

    pushl $16
    call allocate
    addl $4, %esp

    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL              # new break

    cmpl -4(%ebp), %eax
    jle error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################


.globl test_valid_heap_growth_by_header_plus_size
.type test_valid_heap_growth_by_header_plus_size, @function

test_valid_heap_growth_by_header_plus_size:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp

    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

    movl %eax, -4(%ebp)             # old break

    pushl $16
    call allocate
    addl $4, %esp

    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

    movl %eax, -8(%ebp)             # new break

    movl -4(%ebp), %eax
    addl $HDR_SIZE, %eax
    addl $16, %eax                  # expected new break

    cmpl -8(%ebp), %eax
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
