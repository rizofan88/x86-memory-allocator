# return_bin_info(size)
#
# Maps requested payload `size` to nearest bin's size and returns that bin's information.
#
# Steps:
#   1. Compare `size` with each bin's size.
#   2. Return the first bin whose size can hold the request.
#   3. If the request is larger the largest fixed bin, use the big bin.
#
# Arguments:
#   4(%esp) = requested payload size
#
# Returns:
#   %eax = current head pointer stored in selected bin variable
#           or 0 if the bin is empty
#   %ebx = size of bin selected or original size requested if no fixed-sized bins fit.
#   %ecx = address of bin variable.
#
# Notes:
#   Fixed bins round requests of 16, 32, 64 or 128 bytes. 
#   Requests larger than 128 bytes use the big bin and retain original requested size.
#

.section .data

.include "state/bin_state.s"

.section .text

.globl return_bin_info
.type return_bin_info, @function

.equ ST_REQ_SIZE, 4
return_bin_info:

    movl ST_REQ_SIZE(%esp), %ebx

    cmpl $16, %ebx
    jle return_16

    cmpl $32, %ebx
    jle return_32

    cmpl $64, %ebx
    jle return_64

    cmpl $128, %ebx
    jle return_128

    movl bin_big, %eax
    movl $bin_big, %ecx
    ret
    
    return_16:
        movl $16, %ebx
        movl bin_16, %eax
        movl $bin_16, %ecx
        ret
    return_32:
        movl $32, %ebx
        movl bin_32, %eax
        movl $bin_32, %ecx
        ret
    return_64:
        movl $64, %ebx
        movl bin_64, %eax
        movl $bin_64, %ecx
        ret
    return_128:
        movl $128, %ebx
        movl bin_128, %eax
        movl $bin_128, %ecx
        ret

