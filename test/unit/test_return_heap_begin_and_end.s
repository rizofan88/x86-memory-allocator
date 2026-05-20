.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"

.section .text

.globl test_return_heap_begin_and_end
.type test_return_heap_begin_and_end, @function

test_return_heap_begin_and_end:
    
    pushl $test_return_heap_begin_and_end_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_return_heap_state_returns_correct_variables
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_return_heap_begin_and_end_fail
    
    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_return_heap_state_returns_correctly_after_an_extend_break_call
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_return_heap_begin_and_end_fail

    end_return_heap_begin_and_end_pass:
        pushl $test_return_heap_begin_and_end_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_return_heap_begin_and_end_fail: 
        pushl $test_return_heap_begin_and_end_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret



.globl test_return_heap_state_returns_correct_variables 
.type  test_return_heap_state_returns_correct_variables , @function

test_return_heap_state_returns_correct_variables:
    
    call allocate_init
    
    call return_heap_begin_and_end
    movl (%eax), %ecx
    movl (%ebx), %edx

    cmpl %ecx, %edx
    jne error_exit

    ret
####################################################

.globl test_return_heap_state_returns_correctly_after_an_extend_break_call 
.type   test_return_heap_state_returns_correctly_after_an_extend_break_call, @function

test_return_heap_state_returns_correctly_after_an_extend_break_call:
    
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    call allocate_init

    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

    movl %eax, %ebx                     # get current break
    addl $100, %ebx                     # and extend manually
    movl $SYS_BRK, %eax
    int $LINUX_SYSCALL

    movl %eax, -4(%ebp)                 # store new break

    pushl %eax                          # update break
    call update_break
    addl $4, %esp

    call return_heap_begin_and_end      # get value of variable
    movl (%eax), %ecx                   # to check that it returns correct value
    movl (%ebx), %edx

    cmpl %edx, %ecx
    jge error_exit

    subl %ecx, %edx
    cmpl $100, %edx
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL

