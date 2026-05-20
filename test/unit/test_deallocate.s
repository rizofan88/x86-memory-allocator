.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"

.section .text

.globl test_deallocate
.type test_deallocate, @function

test_deallocate:
    pushl $test_deallocate_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_deallocate_marks_allocated_block_free
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_deallocate_fail

    pushl $NULL_PTR_ERR
    pushl $EXPECT_FAILURE
    pushl $test_deallocate_fails_when_freeing_null_block
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_deallocate_fail

    pushl $ALREADY_FREE_PTR_ERR
    pushl $EXPECT_FAILURE
    pushl $test_deallocate_double_free_fails
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_deallocate_fail

    pushl $OUT_OF_RANGE_PTR_GT
    pushl $EXPECT_FAILURE
    pushl $test_deallocate_fails_when_block_is_out_of_range
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_deallocate_fail

    end_deallocate_pass:
        pushl $test_deallocate_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_deallocate_fail:
        pushl $test_deallocate_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret


.globl test_deallocate_marks_allocated_block_free
.type test_deallocate_marks_allocated_block_free, @function

test_deallocate_marks_allocated_block_free:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    call allocate_init

    pushl $16
    call allocate
    addl $4, %esp

    movl %eax, -4(%ebp)         # save user pointer

    pushl %eax
    call deallocate
    addl $4, %esp

    movl -4(%ebp), %eax
    subl $HDR_SIZE, %eax        # go back to block header

    cmpl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

.globl test_deallocate_fails_when_freeing_null_block
.type test_deallocate_fails_when_freeing_null_block, @function

test_deallocate_fails_when_freeing_null_block:

    pushl $0
    call deallocate
    addl $4, %esp
    
    jmp error_exit      # if it reaches here test failed
####################################################

.globl test_deallocate_double_free_fails
.type test_deallocate_double_free_fails, @function

test_deallocate_double_free_fails:

    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    call allocate_init

    pushl $16
    call allocate
    addl $4, %esp

    movl %eax, -4(%ebp)         # save user pointer

    pushl %eax
    call deallocate
    addl $4, %esp

    pushl -4(%ebp)
    call deallocate             # should fail
    addl $4, %esp

    jmp error_exit              # if it reaches here test failed
####################################################

.globl test_deallocate_fails_when_block_is_out_of_range
.type test_deallocate_fails_when_block_is_out_of_range, @function

test_deallocate_fails_when_block_is_out_of_range:
    
    pushl $10
    call allocate
    addl $4, %esp

    call return_heap_begin_and_end
    
    pushl (%ebx)                    # freeing a block equal or greater than break
    call deallocate                 # will trigger an error
    addl $4, %esp
    
    jmp error_exit                  # if it reaches here test failed
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
