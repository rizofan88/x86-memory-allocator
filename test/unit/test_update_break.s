.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"

.section .text

.globl test_update_break
.type test_update_break, @function

test_update_break:
    
    pushl $test_update_break_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_update_breaks_sets_current_break_to_argument
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_update_break_fail
    
    end_update_break_pass:
        pushl $test_update_break_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_update_break_fail: 
        pushl $test_update_break_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret


.globl test_update_breaks_sets_current_break_to_argument 
.type  test_update_breaks_sets_current_break_to_argument , @function

test_update_breaks_sets_current_break_to_argument:
    
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp
    

    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL    
    
    movl %eax, -4(%ebp)

    pushl %eax
    call update_break
    addl $4, %esp

    call return_heap_begin_and_end
    movl (%ebx), %eax

    cmpl %eax, -4(%ebp)
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
