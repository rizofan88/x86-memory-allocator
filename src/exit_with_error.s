# exit_with_error(originating_function, error_code)
#
# Prints error message and exits with given exit code.
#
# Steps:
#   1. Call printf with function arguments.
#   2. Exit with error code as exit status.
#
# Arguments:
#   8(%ebp)  = string representing which function error occured in
#   12(%ebp) = error code
#
# Returns:
#   Error code as exit status of program.
#

.section .data
    err_msg:
    .ascii "====>\nError occured in %s function. Exiting with status: %d\n\n\0"

.include "constants/linux_defs.s"

.section .text

.globl exit_with_error 
.type exit_with_error, @function

.equ ST_FUNC_STR, 8
.equ ST_ERR_CODE, 12
exit_with_error:
    pushl %ebp
    movl %esp, %ebp

    pushl ST_ERR_CODE(%ebp)
    pushl ST_FUNC_STR(%ebp)
    pushl $err_msg
    call printf
    addl $12, %esp
    
    movl ST_ERR_CODE(%ebp), %ebx
    movl $SYS_EXIT, %eax
    int $LINUX_SYSCALL

