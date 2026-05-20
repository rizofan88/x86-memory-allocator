# extend_break(old_break, size)
#
# Extend memory heap by at least `size`.
#
# Steps:
#   1. Add header size and requested size to old break.
#   2. Call brk syscall with new break.
#   3. Check that returned break equals requested break.
#   4. If break was not extend, exit with error.
#   5. Else update break.
#
# Arguments:
#   8(%ebp)  = old break
#   12(%ebp) = requested payload size
#
# Returns:
#   No return value.
#
# Notes:
#   Internally we add the header size to the requested size 
#   to make space for the header information. 
#   So actual length of extended break is `size` + header size.
#

.include "constants/header_defs.s"
.include "constants/cmp_defs.s"
.include "constants/linux_defs.s"
.include "constants/error_defs.s"
.include "constants/function_ids.s"

.globl extend_break
.type extend_break, @function

.equ ST_OLD_BRK, 8
.equ ST_REQ_SIZE, 12
extend_break:
    pushl %ebp
    movl %esp, %ebp
       
    movl ST_OLD_BRK(%ebp), %ebx

    addl $HDR_SIZE, %ebx
    addl ST_REQ_SIZE(%ebp), %ebx
    movl $SYS_BRK, %eax           # requested_break = old_break + header_size + requested_size
    int $LINUX_SYSCALL

    cmpl %ebx, %eax               # did kernel set break to requested value?
    jne extend_break_error

    pushl %eax                    # update current_break variable
    call update_break
    addl $4, %esp

    movl %ebp, %esp
    popl %ebp
    ret

    extend_break_error:
        pushl $EXTEND_BREAK_ERR
        pushl $extend_break_str
        call exit_with_error

