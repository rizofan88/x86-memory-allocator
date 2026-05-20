.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"

.section .text

.globl test_allocate
.type test_allocate, @function

test_allocate:
    
    pushl $test_allocate_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_allocate_returns_valid_pointer
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_fail
    
    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_allocate_returns_non_null_pointer
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_allocate_extends_break_if_needed
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_fail

    pushl $INVALID_SIZE_REQ
    pushl $EXPECT_FAILURE
    pushl $test_allocate_with_zero_must_fail
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_allocate_stores_requested_size_correctly
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_allocate_fail

    end_allocate_pass:
        pushl $test_allocate_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_allocate_fail: 
        pushl $test_allocate_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret

.globl test_allocate_returns_valid_pointer
.type test_allocate_returns_valid_pointer, @function

test_allocate_returns_valid_pointer:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    pushl $10
    call allocate 
    addl $4, %esp
    
    movl %eax, -4(%ebp)
    movb $'a', (%eax)
    
    call return_heap_begin_and_end

    movl (%eax), %ecx                   # heap start
    movl (%ebx), %edx                   # heap break

    cmpl %ecx, -4(%ebp)                 # if less than heap start
    jl error_exit                       # exit with error

    cmpl %edx, -4(%ebp)                 # if greater or equal than break
    jge error_exit                      # exit with error

    movl %ebp, %esp
    popl %ebp
    ret 
####################################################

.globl test_allocate_returns_non_null_pointer 
.type  test_allocate_returns_non_null_pointer, @function

test_allocate_returns_non_null_pointer:
    
    pushl $20
    call allocate
    addl $4, %esp

    cmpl $0, %eax
    je error_exit

    ret
####################################################

.globl test_allocate_extends_break_if_needed
.type  test_allocate_extends_break_if_needed, @function

test_allocate_extends_break_if_needed:

    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp
    
    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
    
    movl %eax, -4(%ebp)             # store current break

    pushl $200
    call allocate
    addl $4, %esp

    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
    
    cmpl -4(%ebp), %eax             # compare previous break with
    jle error_exit                  # break after allocate() call
                                    # if old break is less than new, exit
    movl -4(%ebp), %ecx             
    subl %ecx, %eax                 # subtract old break from new break
                
    cmpl $200, %eax                 # if less than requested size, exit
    jl error_exit

    movl %ebp, %esp
    popl %ebp
    ret 
####################################################

.globl test_allocate_with_zero_must_fail 
.type  test_allocate_with_zero_must_fail, @function

test_allocate_with_zero_must_fail:
    
    pushl $0            # if it fails it passes
    call allocate
    addl $4, %esp

    jmp error_exit      # if it reaches here test failed
####################################################

.globl test_allocate_stores_requested_size_correctly 
.type  test_allocate_stores_requested_size_correctly, @function

test_allocate_stores_requested_size_correctly:
    
    pushl $10                           
    call allocate
    addl $4, %esp
    subl $HDR_SIZE, %eax

    cmpl $16, HDR_SIZE_OFFSET(%eax)         # should be rounded to 16
    jne error_exit

    pushl $32
    call allocate
    addl $4, %esp
    subl $HDR_SIZE, %eax
    
    cmpl $32, HDR_SIZE_OFFSET(%eax)         # should be rounded to 32
    jne error_exit

    pushl $60
    call allocate
    addl $4, %esp
    subl $HDR_SIZE, %eax
    
    cmpl $64, HDR_SIZE_OFFSET(%eax)         # should be rounded to 64
    jne error_exit

    pushl $128
    call allocate
    addl $4, %esp
    subl $HDR_SIZE, %eax
    
    cmpl $128, HDR_SIZE_OFFSET(%eax)        # should be rounded to 128
    jne error_exit

    pushl $140                          
    call allocate
    addl $4, %esp
    subl $HDR_SIZE, %eax
    
    cmpl $140, HDR_SIZE_OFFSET(%eax)        # should allocate exact size
    jne error_exit

    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
