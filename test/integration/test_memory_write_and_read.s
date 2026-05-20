.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"

.section .text

.globl test_memory_write_and_read
.type test_memory_write_and_read, @function

test_memory_write_and_read:
    pushl $test_memory_write_and_read_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_memory_write_and_read_word
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_memory_write_and_read_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_memory_write_and_read_multiple_words
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_memory_write_and_read_fail

    end_memory_write_and_read_pass:
        pushl $test_memory_write_and_read_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_memory_write_and_read_fail:
        pushl $test_memory_write_and_read_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret


.globl test_memory_write_and_read_word
.type test_memory_write_and_read_word, @function

test_memory_write_and_read_word:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    pushl $16
    call allocate
    addl $4, %esp

    cmpl $0, %eax
    je error_exit

    movl %eax, -4(%ebp)             # save allocated user pointer

    movl $0x12345678, (%eax)

    movl -4(%ebp), %eax
    cmpl $0x12345678, (%eax)
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################


.globl test_memory_write_and_read_multiple_words
.type test_memory_write_and_read_multiple_words, @function

test_memory_write_and_read_multiple_words:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    pushl $16
    call allocate
    addl $4, %esp

    cmpl $0, %eax
    je error_exit

    movl %eax, -4(%ebp)             # save allocated user pointer

    movl $0x11111111, 0(%eax)
    movl $0x22222222, 4(%eax)
    movl $0x33333333, 8(%eax)
    movl $0x44444444, 12(%eax)

    movl -4(%ebp), %eax

    cmpl $0x11111111, 0(%eax)
    jne error_exit

    cmpl $0x22222222, 4(%eax)
    jne error_exit

    cmpl $0x33333333, 8(%eax)
    jne error_exit

    cmpl $0x44444444, 12(%eax)
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
