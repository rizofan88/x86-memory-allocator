# redirect()
#
# Redirects stdout and stderr to /dev/null.
#
# Steps:
#   1. Save stdout and stderr file descriptors.
#   2. Open /dev/null for writing.
#   3. Redirect stdout and stderr to /dev/null.
#
# Arguments:
#   None.
#
# Returns:
#   %eax = saved stdout
#   %ebx = saved stderr
#
# Notes:
#   The reason for redirection is to keep terminal output clean during test execution,
#   as some tests will be expected to fail and may contain error messages which we 
#   wish to supress.
#

.include "constants/linux_defs.s"

.section .data
    null_file:
    .ascii "/dev/null\0"

.section .text

.globl redirect
.type redirect, @function

.equ LOC_SAVED_STDOUT, -4
.equ LOC_SAVED_STDERR, -8
.equ LOC_NULL_FILE_FD, -12
redirect:
    pushl %ebp
    movl %esp, %ebp
    subl $12, %esp

    movl $STDOUT, %ebx
    movl $SYS_DUP, %eax
    int $LINUX_SYSCALL

    cmpl $0, %eax
    jl redirect_error

    movl %eax, LOC_SAVED_STDOUT(%ebp)                 # save stdout
    
    movl $STDERR, %ebx
    movl $SYS_DUP, %eax
    int $LINUX_SYSCALL

    cmpl $0, %eax
    jl redirect_error

    movl %eax, LOC_SAVED_STDERR(%ebp)                 # save stderr

    movl $SYS_OPEN, %eax
    movl $null_file, %ebx
    movl $O_WRONLY, %ecx
    movl $0666, %edx 
    int $LINUX_SYSCALL

    cmpl $0, %eax
    jl redirect_error

    movl %eax, LOC_NULL_FILE_FD(%ebp)                 # save fd

    movl %eax, %ebx
    movl $STDOUT, %ecx
    movl $SYS_DUP2, %eax
    int $LINUX_SYSCALL

    cmpl $0, %eax
    jl redirect_error

    movl $STDOUT, %ebx
    movl $STDERR, %ecx
    movl $SYS_DUP2, %eax
    int $LINUX_SYSCALL

    cmpl $0, %eax
    jl redirect_error

    movl $SYS_CLOSE, %eax                              # close original file descriptor
    movl LOC_NULL_FILE_FD(%ebp), %ebx
    int $LINUX_SYSCALL
    
    movl LOC_SAVED_STDOUT(%ebp), %eax
    movl LOC_SAVED_STDERR(%ebp), %ebx
    
    redirect_error:
        movl %ebp, %esp
        popl %ebp
        ret

# close_redirect(saved_stdout, saved_stderr)
#
# Closes previously performed redirection and restores
# stdout and stderr file descriptors.
#
# Steps:
#   1. Redirect saved stdout and stderr to current file descriptors.
#   2. Close old saved file descriptors.
#
# Arguments:
#   8(%ebp)  = saved stdout
#   12(%ebp) = saved stderr
#
# Returns:
#   No return values.
#

.globl close_redirect
.type close_redirect, @function

.equ ST_SAVED_STDOUT, 8
.equ ST_SAVED_STDERR, 12
close_redirect:
    pushl %ebp
    movl %esp, %ebp

    movl ST_SAVED_STDOUT(%ebp), %ebx
    movl $STDOUT, %ecx
    movl $SYS_DUP2, %eax
    int $LINUX_SYSCALL

    cmpl $0, %eax
    jl close_redirect_error

    movl ST_SAVED_STDERR(%ebp), %ebx
    movl $STDERR, %ecx
    movl $SYS_DUP2, %eax
    int $LINUX_SYSCALL

    cmpl $0, %eax
    jl close_redirect_error

    movl $SYS_CLOSE, %eax               # close saved STDOUT
    movl ST_SAVED_STDOUT(%ebp), %ebx
    int $LINUX_SYSCALL

    movl $SYS_CLOSE, %eax               # close saved STDERR
    movl ST_SAVED_STDERR(%ebp), %ebx
    int $LINUX_SYSCALL

    close_redirect_error:
        movl %ebp, %esp
        popl %ebp
        ret
