# print_status(status)
#
# Prints encoded status from child process in case of 
# failure in test when not expected. 
#
# Steps:
#   1. Print whole status number.
#   2. Extrapolate signal number, core dump flag and exit code,
#      then print them.
#
# Arguments:
#   8(%ebp) = status
#
# Returns:
#   No return value.
#
# Notes:
#   If a test which was not expected to crash, exited with an error,
#   run_test() calls this function so we can inspect where and what the crash occured.
#

.section .data
    status_pr:
    .ascii "\nSTATUS: %d\n\0"
    signal_num:
    .ascii "SIG: %d\n\0"
    dump_file:
    .ascii "DUMP: %d\n\0"
    exit_status:
    .ascii "EXIT STATUS: %d\n\0"
    no_error:
    .ascii "NORM EXIT: %d\n\0"

.section .text

.globl print_status
.type print_status, @function

.equ ST_STATUS, 8
print_status:
    pushl %ebp
    movl %esp, %ebp
    
    cmpl $0, ST_STATUS(%ebp)
    jne print_full_status

    pushl ST_STATUS(%ebp)
    pushl $no_error
    call printf
    addl $8, %esp

    jmp exit_print_status
    
    print_full_status:
        movl ST_STATUS(%ebp), %eax
        pushl %eax                
        pushl $status_pr
        call printf
        addl $8, %esp

        movl ST_STATUS(%ebp), %eax
        andl $0x7f, %eax

        pushl %eax               
        pushl $signal_num
        call printf
        addl $8, %esp

        movl ST_STATUS(%ebp), %eax
        shrl $7, %eax
        andl $0b1, %eax

        pushl %eax
        pushl $dump_file
        call printf
        addl $8, %esp

        movl ST_STATUS(%ebp), %eax
        shrl $8, %eax
        andl $0xff, %eax

        pushl %eax
        pushl $exit_status
        call printf
        addl $8, %esp

    exit_print_status:
        movl %ebp, %esp
        popl %ebp
        ret
