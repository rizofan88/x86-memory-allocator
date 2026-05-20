.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"

.section .text

.globl test_update_new_pointer
.type test_update_new_pointer, @function

test_update_new_pointer:
    pushl $test_update_new_pointer_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_update_new_pointer_writes_size
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_update_new_pointer_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_update_new_pointer_marks_unavailable
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_update_new_pointer_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_update_new_pointer_sets_previous_pointer
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_update_new_pointer_fail

    end_update_new_pointer_pass:
        pushl $test_update_new_pointer_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_update_new_pointer_fail:
        pushl $test_update_new_pointer_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret


.globl test_update_new_pointer_writes_size
.type test_update_new_pointer_writes_size, @function

test_update_new_pointer_writes_size:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp
    
    call allocate_init
    call return_heap_begin_and_end
    movl (%ebx), %eax
    movl %eax, -4(%ebp)             # store old break
    
    pushl $32                       # 16 plus header size
    pushl (%ebx)                    # old break
    call extend_break
    addl $8, %esp

    pushl $16
    call return_bin_info
    
    pushl %ecx                      # bin address to update
    pushl $16                       # size of payload
    pushl $0                        # previous pointer
    pushl -4(%ebp)                  # old break, where updated pointer will start
    call update_new_pointer
    addl $16, %esp

    movl -4(%ebp), %eax             # old break is start of header pointer
    cmpl $16, HDR_SIZE_OFFSET(%eax) # check if size was correctly written
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################


.globl test_update_new_pointer_marks_unavailable
.type test_update_new_pointer_marks_unavailable, @function

test_update_new_pointer_marks_unavailable:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    call allocate_init
    call return_heap_begin_and_end
    movl (%ebx), %eax
    movl %eax, -4(%ebp)             # store old break
    
    pushl $32                       # 16 plus header size
    pushl (%ebx)                    # old break
    call extend_break
    addl $8, %esp

    pushl $16
    call return_bin_info
    
    pushl %ecx                      # bin address to update
    pushl $16                       # size of payload
    pushl $0                        # previous pointer
    pushl -4(%ebp)                  # old break, where updated pointer will start
    call update_new_pointer
    addl $16, %esp

    movl -4(%ebp), %eax
    cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

.globl test_update_new_pointer_sets_previous_pointer
.type test_update_new_pointer_sets_previous_pointer, @function

test_update_new_pointer_sets_previous_pointer:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp
    
    pushl $16
    call allocate
    addl $4, %esp
    movl %eax, -4(%ebp)             # store previous pointer

    call return_heap_begin_and_end
    movl (%ebx), %eax
    movl %eax, -8(%ebp)             # store old break
    
    pushl $32                       # 16 plus header size
    pushl (%ebx)                    # old break
    call extend_break
    addl $8, %esp

    pushl $16
    call return_bin_info
    
    pushl %ecx                      # bin address to update
    pushl $16                       # size of payload
    pushl -4(%ebp)                  # previous pointer
    pushl -8(%ebp)                  # old break, where updated pointer will start
    call update_new_pointer
    addl $16, %esp

    movl -8(%ebp), %eax             # new pointer start
    movl -4(%ebp), %ebx             # previous pointer
    cmpl %ebx, HDR_PREV_ADDR_OFFSET(%eax)
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
