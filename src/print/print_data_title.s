# print_data_title( heap_begin, heap_break)
#
# Prints heap state. Start, break and total size.
#
# Arguments:
#   8(%ebp)  = heap_begin
#   12(%ebp) = heap_break
#
# Returns:
#   No return value.
#
# Notes:
#   Given the heap beginning and break calculates and prints the total size of 
#   currently extended heap.
#

.include "constants/print_items_defs.s"

.globl print_data_title
.type print_data_title, @function

.equ ST_HEAP_BG, 8
.equ ST_HEAP_BRK, 12
print_data_title:
    pushl %ebp
    movl %esp, %ebp

    call print_four_newline

    call print_delimiter

    pushl ST_HEAP_BG(%ebp)
    pushl $heap_start
    call print_str_int_newline
    addl $8, %esp

    pushl ST_HEAP_BRK(%ebp)
    pushl $heap_end
    call print_str_int_newline
    addl $8, %esp

    movl ST_HEAP_BG(%ebp), %ecx
    movl ST_HEAP_BRK(%ebp), %edx
    subl %ecx, %edx                 # %edx = heap_break - heap_begin

    pushl %edx
    pushl $heap_size
    call print_str_int_newline
    addl $8, %esp
    
    call print_delimiter

    pushl $hash
    call printf
    addl $4, %esp
    call print_eight_space

    pushl $state
    call printf
    addl $4, %esp
    call print_seven_space

    pushl $address
    call printf
    addl $4, %esp
    call print_seven_space

    call print_two_space

    pushl $addr_end
    call printf
    addl $4, %esp
    call print_eight_space
    
    call print_three_space
    
    pushl $size
    call printf
    addl $4, %esp
    call print_six_space

    pushl $gap
    call printf
    addl $4, %esp
    call print_eight_space

    pushl $prev
    call printf
    addl $4, %esp
    call print_eight_space

    pushl $next
    call printf
    addl $4, %esp
    call print_six_space

    call print_newline
    call print_delimiter

    movl %ebp, %esp
    popl %ebp
    ret

