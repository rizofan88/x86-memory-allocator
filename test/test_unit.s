# test_integration()
#
# Calls all functions in test/unit/
#
#

.include "constants/test_defs.s"
.section .text

.globl _start
_start:
    call test_allocate_init
    cmpl $TEST_PASS, %eax
    jne exit_with_err
    
    call test_allocate
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    call test_update_break
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    call test_return_heap_begin_and_end
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    call test_deallocate
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    call test_deallocate_check
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    call test_exit_with_error
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    call test_extend_break
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    call test_mark_ptr
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    call test_return_bin_info
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    call test_scan_memory
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    call test_update_new_pointer
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    pushl $0
    call exit

    exit_with_err:
        pushl $1
        call exit
