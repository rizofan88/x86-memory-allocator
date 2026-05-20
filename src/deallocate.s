# deallocate(pointer)
#
# Marks previously allocated payload pointer as free.
#
# Steps:
#   1. Push pointer received to error checking function.
#   2. Frees pointer if no error was found, if not exits with error.
#
# Arguments:
#   8(%ebp) = pointer to free
#
# Returns:
#   The public pointer points to the payload area. The block header
#   is located HDR_SIZE bytes before it.
#   On validation error, the function exits with error.
#

.include "constants/header_defs.s" 
.include "constants/function_ids.s"

.globl deallocate 
.type deallocate,@function 
 
.equ ST_PAYLOAD_PTR, 8
deallocate: 
    pushl %ebp
    movl %esp, %ebp

    pushl ST_PAYLOAD_PTR(%ebp)
    call deallocate_check
    addl $4, %esp

    cmpl $0, %eax                                   # deallocate_check() returns > 0 in case of error
    jne deallocate_error                            # and 0 if no error was found
    
    movl  ST_PAYLOAD_PTR(%ebp), %eax 

    subl  $HDR_SIZE, %eax                           # %eax was pointing at start of valid memory                      
                                                    # subtract header size to get at block header beginning    
    movl  $AVAILABLE, HDR_AVAIL_OFFSET(%eax)        # free it
                                                    
    end_deallocate:                                 
        movl %ebp, %esp
        popl %ebp
        ret 

    deallocate_error:
        pushl %eax
        pushl $deallocate_str
        call exit_with_error

