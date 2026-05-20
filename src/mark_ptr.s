# mark_ptr(pointer)
#
# Mark `pointer` as used.
#
# Steps:
#   1. Treat pointer as block header pointer.
#   2. Mark pointer as unavailable.
#
# Arguments:
#   8(%ebp) = pointer to mark
#
# Returns:
#   No return value.
#
# Notes:
#   This functions assumes the pointer was already checked by allocate(),
#   therefore it does not error-check it again.
#   It also expects the header pointer, not the memory payload pointer.
#

.include "constants/header_defs.s"

.globl mark_ptr
.type mark_ptr, @function

.equ ST_PTR, 8
mark_ptr:
    pushl %ebp
    movl %esp, %ebp

    movl ST_PTR(%ebp), %eax
    movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)

    movl %ebp, %esp
    popl %ebp
    ret

