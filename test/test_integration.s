# test_integration()
#
# Calls all functions in test/integration/
#
#

.include "constants/test_defs.s"
.section .text

.globl _start
_start:
    call test_allocate_and_deallocate
    cmpl $TEST_PASS, %eax
    jne exit_with_err
    
    call test_memory_write_and_read
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    call test_valid_heap_growth
    cmpl $TEST_PASS, %eax
    jne exit_with_err

    pushl $0
    call exit

    exit_with_err:
        pushl $1
        call exit
