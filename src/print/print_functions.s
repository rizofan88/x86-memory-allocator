# print_functions.s
#
# Printf-based helpers used by debug functions.
#
#
.section .data
    .include "constants/print_items_defs.s"

.section .text

.globl print_newline
.type print_newline, @function
print_newline:

    pushl $newline
    call printf
    addl $4, %esp

    ret

.globl print_four_newline
.type print_four_newline, @function
print_four_newline:

    pushl $four_newline
    call printf
    addl $4, %esp

    ret

.globl print_delimiter
.type print_delimiter, @function
print_delimiter:

    pushl $newline
    pushl $delimiter
    pushl $two_string
    call printf
    addl $12, %esp

    ret


# print_int(value)
#
# Arguments:
#   8(%ebp) = integer to print
#
.globl print_int
.type print_int, @function
print_int:
    pushl %ebp
    movl %esp, %ebp

    pushl 8(%ebp)
    pushl $int
    call printf
    addl $8, %esp
    
    movl %ebp, %esp
    popl %ebp
    ret

# print_addr_int(value)
#
# Arguments:
#   8(%ebp) = address to print
#
.globl print_addr_int
.type print_addr_int, @function
print_addr_int:
    pushl %ebp
    movl %esp, %ebp

    pushl 8(%ebp)
    pushl $addr_int
    call printf
    addl $8, %esp
    
    movl %ebp, %esp
    popl %ebp
    ret


# print_str_int_newline(value)
#
# Arguments:
#   8(%ebp) = label to print
#   12(%ebp) = integer to print
#
.globl print_str_int_newline
.type print_str_int_newline, @function
print_str_int_newline:

    pushl %ebp
    movl %esp, %ebp

    pushl $newline
    pushl 12(%ebp)
    pushl $one_space
    pushl 8(%ebp)
    pushl $one_str_int_str
    call printf
    addl $20, %esp

    movl %ebp, %esp
    popl %ebp
    ret



.globl print_one_space
.type print_one_space, @function
print_one_space:

    pushl $one_space
    call printf
    addl $4, %esp

    ret

.globl print_two_space
.type print_two_space, @function
print_two_space:

    pushl $two_space
    call printf
    addl $4, %esp

    ret

.globl print_three_space
.type print_three_space, @function
print_three_space:

    pushl $three_space
    call printf
    addl $4, %esp

    ret

.globl print_four_space
.type print_four_space, @function
print_four_space:

    pushl $four_space
    call printf
    addl $4, %esp

    ret

.globl print_five_space
.type print_five_space, @function
print_five_space:

    pushl $five_space
    call printf
    addl $4, %esp

    ret

.globl print_six_space
.type print_six_space, @function
print_six_space:

    pushl $six_space
    call printf
    addl $4, %esp

    ret

.globl print_seven_space
.type print_seven_space, @function
print_seven_space:

    pushl $seven_space
    call printf
    addl $4, %esp

    ret

.globl print_eight_space
.type print_eight_space, @function
print_eight_space:

    pushl $eight_space
    call printf
    addl $4, %esp

    ret

.globl print_nine_space
.type print_nine_space, @function
print_nine_space:

    pushl $nine_space
    call printf
    addl $4, %esp

    ret

.globl print_ten_space
.type print_ten_space, @function
print_ten_space:

    pushl $ten_space
    call printf
    addl $4, %esp

    ret

