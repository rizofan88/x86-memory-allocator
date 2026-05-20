.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"

.section .text

.globl test_deallocate_check
.type test_deallocate_check, @function

test_deallocate_check:
    pushl $test_deallocate_check_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_deallocate_check_fails_on_null_ptr
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_deallocate_check_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_deallocate_check_passes_on_valid_ptr
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_deallocate_check_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_deallocate_check_fails_before_heap
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_deallocate_check_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_deallocate_check_fails_if_value_greater_than_break
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_deallocate_check_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_deallocate_check_fails_on_double_free
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_deallocate_check_fail

    end_deallocate_check_pass:
        pushl $test_deallocate_check_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_deallocate_check_fail:
        pushl $test_deallocate_check_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret

.globl test_deallocate_check_fails_on_null_ptr
.type test_deallocate_check_fails_on_null_ptr, @function

test_deallocate_check_fails_on_null_ptr:

    pushl $0
    call deallocate_check
    addl $4, %esp
    
    cmpl $NULL_PTR_ERR, %eax
    jne error_exit

    ret    
####################################################

.globl test_deallocate_check_passes_on_valid_ptr
.type test_deallocate_check_passes_on_valid_ptr, @function

test_deallocate_check_passes_on_valid_ptr:

    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    call allocate_init

    pushl $16
    call allocate
    addl $4, %esp

    pushl %eax                  # pointer is valid so shouldn't fail
    call deallocate_check
    addl $4, %esp

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

.globl test_deallocate_check_fails_before_heap
.type test_deallocate_check_fails_before_heap, @function

test_deallocate_check_fails_before_heap:

    call allocate_init
    call return_heap_begin_and_end

    movl (%eax), %eax
    subl $1, %eax

    pushl %eax
    call deallocate_check
    addl $4, %esp

    cmpl $OUT_OF_RANGE_PTR_LT, %eax
    jne error_exit

    ret
####################################################

.globl test_deallocate_check_fails_if_value_greater_than_break
.type test_deallocate_check_fails_if_value_greater_than_break, @function

test_deallocate_check_fails_if_value_greater_than_break:

    pushl $10
    call allocate
    addl $4, %esp

    call return_heap_begin_and_end

    movl (%ebx), %ebx
    addl $1, %ebx

    pushl %ebx
    call deallocate_check
    addl $4, %esp

    cmpl $OUT_OF_RANGE_PTR_GT, %eax
    jne error_exit

    ret
####################################################

.globl test_deallocate_check_fails_on_double_free
.type test_deallocate_check_fails_on_double_free, @function

test_deallocate_check_fails_on_double_free:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    call allocate_init

    pushl $16
    call allocate
    addl $4, %esp

    movl %eax, -4(%ebp)

    pushl %eax
    call deallocate
    addl $4, %esp

    pushl -4(%ebp)
    call deallocate_check
    addl $4, %esp

    cmpl $ALREADY_FREE_PTR_ERR, %eax
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
