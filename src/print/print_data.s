# print_data( block_end,
#             available_flag,
#             payload_size,
#             current_pointer,
#             pointer_count,
#             header_prev_pointer,
#             header_next_pointer
#            )
#
# Prints one formatted debug row for a heap block.
#
# Arguments:
#   8(%ebp)  = block_end
#   12(%ebp) = available_flag
#   16(%ebp) = payload_size
#   20(%ebp) = current_pointer
#   24(%ebp) = pointer_count
#   28(%ebp) = header_prev_pointer
#   32(%ebp) = header_next_pointer
#
# Returns:
#   No return value.
#
# Notes:
#   The block starts at its header address. The block total size is considered to be:
#   payload_size + header size.
#   This function also prints the gap between two adjacent blocks as:
#   block_end (argument passed) - calculated_block_end.
#   If no error occured during allocation, gap expected == 0.
#

.include "constants/print_items_defs.s"
.include "constants/header_defs.s"

.globl print_data
.type print_data, @function

.equ ST_BLOCK_END, 8
.equ ST_AVAIL_FLAG, 12
.equ ST_SIZE, 16
.equ ST_CUR_PTR, 20
.equ ST_COUNT, 24
.equ ST_PREV_PTR_HDR, 28
.equ ST_NEXT_PTR_HDR, 32

.equ LOC_GAP, -4
.equ LOC_END_OF_PTR, -8
print_data:
    pushl %ebp 
    movl %esp, %ebp
    subl $8, %esp

    pushl ST_COUNT(%ebp)                
    call print_int
    addl $4, %esp
    
    call print_one_space 

    cmpl $UNAVAILABLE, ST_AVAIL_FLAG(%ebp)    # is pointer free? 
    je not_free                        

    pushl $free                         # otherwise push 'free' string
    
    jmp print_av

    not_free:
        pushl $used                     # if not push 'used' string
    
    print_av:
        call printf                     # print whichever string was pushed
        addl $4, %esp
    
    call print_eight_space              
    
    pushl ST_CUR_PTR(%ebp)             
    call print_int                    
    addl $4, %esp

    pushl $arrow                        # print graphical arrow
    call printf
    addl $4, %esp

    movl ST_CUR_PTR(%ebp), %edx         # add size of pointer and header size 
    addl ST_SIZE(%ebp), %edx            # to %edx to get the end of current pointer
    addl $HDR_SIZE, %edx

    movl %edx, LOC_END_OF_PTR(%ebp)     # store the end of current pointer

    movl ST_BLOCK_END(%ebp), %ecx       # calculate gap
    subl %edx, %ecx                                                               
    movl %ecx, LOC_GAP(%ebp)            # store gap for later
                                        
    pushl LOC_END_OF_PTR(%ebp)          
    call print_int
    addl $4, %esp
                                        
    call print_five_space            

    pushl ST_SIZE(%ebp)             
    call print_int
    addl $4, %esp

    call print_two_space

    pushl LOC_GAP(%ebp)           
    call print_int
    addl $4, %esp

    call print_three_space       

    pushl ST_PREV_PTR_HDR(%ebp) 
    call print_addr_int
    addl $4, %esp
 
    call print_two_space      
        
    pushl ST_NEXT_PTR_HDR(%ebp)
    call print_addr_int
    addl $4, %esp

    call print_newline                  # print end of formatted line
    call print_delimiter

    movl %ebp, %esp
    popl %ebp
    ret
