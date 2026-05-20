# debug()
#
# Helper function to print current heap state.
# 
# Steps:
#   1. Pass heap_begin and current_break variables to init_debug() to start scan.
# 
# Arguments:
#   None.
#
# Returns:
#   No return value.
#

.globl debug
.type debug, @function

debug:
    pushl %ebp
    movl %esp, %ebp

    pushl %ebx
    pushl %edi
    pushl %esi

    call return_heap_begin_and_end

    pushl (%ebx)
    pushl (%eax)
    call init_debug
    addl $8, %esp

    popl %esi
    popl %edi
    popl %ebx

    movl %ebp, %esp
    popl %ebp
    ret

