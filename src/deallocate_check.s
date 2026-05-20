# deallocate_check(pointer)
#
# Checks if pointer is valid.
#
# Steps:
#   1. Check if pointer is non-null.
#   2. Check if pointer is within valid heap range.
#   3. Check if pointer has already been freed.
#   4. If no error return 0 in %eax to communicate so.
#   5. Else return error code in %eax which will be > 0.
#
# Arguments:
#   8(%ebp) = pointer to check
#
# Returns:
#   %eax = 0 for no error or > 0 for error.
#
# Notes:
#   This function checks basic range and double-free errors.
#   It does not yet prove that the pointer exactly matches the start of
#   a payload returned by allocate().
#

.include "constants/function_ids.s"
.include "constants/error_defs.s"
.include "constants/header_defs.s"
.include "constants/cmp_defs.s"

.globl deallocate_check
.type deallocate_check, @function

.equ ST_PTR_TO_CHECK, 8
deallocate_check:
    pushl %ebp
    movl %esp, %ebp

    pushl %ebx                              # save registers
    pushl %esi

    movl ST_PTR_TO_CHECK(%ebp), %esi

    cmpl $NULL_PTR, %esi                    # is it a null pointer?
    je deallocate_null_ptr 

    call return_heap_begin_and_end

    movl (%eax), %edx
    addl $HDR_SIZE, %edx

    cmpl %edx, %esi                         # is it less than valid heap range?
    jb deallocate_ptr_out_of_range_lt

    cmpl (%ebx), %esi                       # is it at or beyond valid heap range?
    jae deallocate_ptr_out_of_range_gt

    subl $HDR_SIZE, %esi                    # move the pointer to beginning of block header
                                                    
    cmpl $AVAILABLE, HDR_AVAIL_OFFSET(%esi) # check has it already been freed?        
    je deallocate_already_free

    movl $0, %eax                           # no error was found, return 0 in %eax

    end_check:
        popl %esi                           # restore registers
        popl %ebx

        movl %ebp, %esp
        popl %ebp
        ret

    deallocate_null_ptr: 
        movl $NULL_PTR_ERR, %eax
        jmp end_check

    deallocate_already_free:
        movl $ALREADY_FREE_PTR_ERR, %eax
        jmp end_check
    
    deallocate_ptr_out_of_range_lt:
        movl $OUT_OF_RANGE_PTR_LT, %eax
        jmp end_check

    deallocate_ptr_out_of_range_gt:
        movl $OUT_OF_RANGE_PTR_GT, %eax
        jmp end_check

