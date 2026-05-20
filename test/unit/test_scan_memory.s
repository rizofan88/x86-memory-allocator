.include "constants/test_defs.s"
.include "constants/linux_defs.s"
.include "constants/header_defs.s"
.include "constants/error_defs.s"
.include "constants/cmp_defs.s"

.section .text

.globl test_scan_memory
.type test_scan_memory, @function

test_scan_memory:
    pushl $test_scan_memory_str
    pushl $test_str
    call printf
    addl $8, %esp

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_scan_memory_finds_available_block
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_scan_memory_fail

    pushl $0
    pushl $EXPECT_SUCCESS
    pushl $test_scan_memory_skips_unavailable_block
    call run_test
    addl $12, %esp
    cmpl $TEST_PASS, %eax
    jne end_scan_memory_fail


    end_scan_memory_pass:
        pushl $test_scan_memory_str
        pushl $passed
        call printf
        addl $8, %esp

        movl $TEST_PASS, %eax
        ret

    end_scan_memory_fail:
        pushl $test_scan_memory_str
        pushl $failed_str
        call printf
        addl $8, %esp

        movl $TEST_FAIL, %eax
        ret


.globl test_scan_memory_finds_available_block
.type test_scan_memory_finds_available_block, @function

test_scan_memory_finds_available_block:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    pushl $16
    call allocate
    addl $4, %esp

    movl %eax, -4(%ebp)             # save allocated pointer

    pushl -4(%ebp)
    call deallocate
    addl $4, %esp

    pushl $16
    call return_bin_info
    addl $4, %esp

    pushl $16
    pushl %eax                      # has start of bin list
    call scan_memory                # from return_bin_info()
    addl $8, %esp
    
    movl -4(%ebp), %ebx
    addl $HDR_SIZE, %eax
    cmpl %ebx, %eax                 # should find the freed block
    jne error_exit

    cmpl $FOUND_PTR, %edi
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################


.globl test_scan_memory_skips_unavailable_block
.type test_scan_memory_skips_unavailable_block, @function

test_scan_memory_skips_unavailable_block:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    pushl $16
    call allocate
    addl $4, %esp

    movl %eax, -4(%ebp)             # unavailable/used block

    pushl $16
    call return_bin_info
    addl $4, %esp
    
    pushl $16                       # has start of bin list     
    pushl %eax                      # from return_bin_info()
    call scan_memory
    addl $8, %esp

    movl -4(%ebp), %ebx             # returns last pointer of list
    addl $HDR_SIZE, %eax            # if none available
    cmpl %ebx, %eax             
    jne error_exit

    cmpl $PTR_NOT_FOUND, %edi       # should flag that it is not available
    jne error_exit

    movl %ebp, %esp
    popl %ebp
    ret
####################################################

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL

