.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"

.section .text

.globl test_return_bin_info
.type test_return_bin_info, @function

test_return_bin_info:
    pushl $test_return_bin_info_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_return_bin_info_returns_bin_16
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_return_bin_info_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_return_bin_info_returns_bin_32
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_return_bin_info_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_return_bin_info_returns_bin_64
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_return_bin_info_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_return_bin_info_returns_bin_128
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_return_bin_info_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_return_bin_info_returns_big_bin
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_return_bin_info_fail

    end_return_bin_info_pass:
        pushl $test_return_bin_info_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_return_bin_info_fail:
        pushl $test_return_bin_info_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret


.globl test_return_bin_info_returns_bin_16
.type test_return_bin_info_returns_bin_16, @function

test_return_bin_info_returns_bin_16:
    pushl %ebp
    movl %esp, %ebp

    pushl $16
    call return_bin_info
    addl $4, %esp

    cmpl $16, %ebx
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################


.globl test_return_bin_info_returns_bin_32
.type test_return_bin_info_returns_bin_32, @function

test_return_bin_info_returns_bin_32:
    pushl %ebp
    movl %esp, %ebp

    pushl $32
    call return_bin_info
    addl $4, %esp

    cmpl $32, %ebx
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################


.globl test_return_bin_info_returns_bin_64
.type test_return_bin_info_returns_bin_64, @function

test_return_bin_info_returns_bin_64:
    pushl %ebp
    movl %esp, %ebp

    pushl $64
    call return_bin_info
    addl $4, %esp

    cmpl $64, %ebx
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################


.globl test_return_bin_info_returns_bin_128
.type test_return_bin_info_returns_bin_128, @function

test_return_bin_info_returns_bin_128:
    pushl %ebp
    movl %esp, %ebp

    pushl $128
    call return_bin_info
    addl $4, %esp

    cmpl $128, %ebx
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################


.globl test_return_bin_info_returns_big_bin
.type test_return_bin_info_returns_big_bin, @function

test_return_bin_info_returns_big_bin:
    pushl %ebp
    movl %esp, %ebp

    pushl $129
    call return_bin_info
    addl $4, %esp

    cmpl $129, %ebx
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
