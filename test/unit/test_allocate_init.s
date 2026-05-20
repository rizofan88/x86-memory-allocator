.include "constants/test_defs.s"
.include "constants/linux_defs.s"

.section .text

.globl test_allocate_init
.type test_allocate_init, @function

test_allocate_init:
    
    pushl $test_allocate_init_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_no_allocate_init_returns_null_heap_state
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_init_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_allocate_init_initializes_heap
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_init_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_after_allocate_init_heap_start_and_break_are_equal
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_init_fail
    
    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_allocate_init_does_not_extend_heap
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_init_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_allocate_init_called_twice_initializes_same_values
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_init_fail
    
    end_allocate_init_pass:
        pushl $test_allocate_init_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_allocate_init_fail: 
        pushl $test_allocate_init_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret
####################################################


.globl test_no_allocate_init_returns_null_heap_state
.type test_no_allocate_init_returns_null_heap_state, @function

test_no_allocate_init_returns_null_heap_state:

    call return_heap_begin_and_end

    cmpl $0, (%eax)
    jne error_exit

    cmpl $0, (%ebx)
    jne error_exit
    
    ret 
####################################################


.globl test_allocate_init_initializes_heap
.type test_allocate_init_initializes_heap, @function

test_allocate_init_initializes_heap:
    
    call allocate_init
    call return_heap_begin_and_end

    cmpl $0, (%eax)
    je error_exit

    cmpl $0, (%ebx)
    je error_exit

    ret 
####################################################

.globl test_after_allocate_init_heap_start_and_break_are_equal
.type test_after_allocate_init_heap_start_and_break_are_equal, @function

test_after_allocate_init_heap_start_and_break_are_equal:
        
    call allocate_init
    
    call return_heap_begin_and_end
    
    movl (%eax), %ecx
    cmpl (%ebx), %ecx 
    jne error_exit

    ret 
####################################################

.globl test_allocate_init_does_not_extend_heap
.type test_allocate_init_does_not_extend_heap, @function

test_allocate_init_does_not_extend_heap:

    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    mov $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
    
    movl %eax, -4(%ebp)             # actual current break
    
    call allocate_init
    
    call return_heap_begin_and_end

    movl (%ebx), %ecx               # holds break initialized by allocate_init
    cmpl -4(%ebp), %ecx
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret 
####################################################


.globl test_allocate_init_called_twice_initializes_same_values
.type test_allocate_init_called_twice_initializes_same_values, @function

test_allocate_init_called_twice_initializes_same_values:

    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp

    call allocate_init
    call return_heap_begin_and_end

    movl (%eax), %ecx 
    movl %ecx, -4(%ebp)                 # save result of first init

    movl (%ebx), %ecx 
    movl %ecx, -8(%ebp)
    
    call allocate_init
    call return_heap_begin_and_end
    
    movl (%eax), %ecx                   # compare result of second init
    cmpl %ecx, -4(%ebp)                 # with result of first init
    jne error_exit

    movl (%ebx), %ecx
    cmpl %ecx, -8(%ebp)
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret 
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
