.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"

.section .text

.globl test_exit_with_error
.type test_exit_with_error, @function

test_exit_with_error:
    pushl $test_exit_with_error_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $TEST_ERR_CODE
    pushl $EXPECT_FAILURE
    pushl $test_exit_with_error_exits_with_given_code
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_exit_with_error_fail

    end_exit_with_error_pass:
        pushl $test_exit_with_error_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_exit_with_error_fail:
        pushl $test_exit_with_error_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret


.globl test_exit_with_error_exits_with_given_code
.type test_exit_with_error_exits_with_given_code, @function

test_exit_with_error_exits_with_given_code:
    pushl $TEST_ERR_CODE
    pushl $test_exit_with_error_str
    call exit_with_error

    jmp error_exit
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
