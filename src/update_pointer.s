# update_new_pointer(old_break,
#                    previous_pointer,
#                    size,
#                    bin_address
#                    )
#
# Initializes the header of a newly allocated block and links it into  
# selected bin list.
#
# Steps:
#   1. Treat old_break as the start address of the new pointer.
#   2. Mark the pointer as unavailable.
#   3. Store its payload size.
#   4. Set its next pointer to NULL.
#   5. Store the previous pointer into the new block header.
#   6. If previous_pointer is not NULL, link previous_pointer->next to the new pointer.
#   7. If selected bin is empty, store new pointer as the bin head. 
#
# Arguments:
#   8(%ebp)  = old break (start of new pointer)
#   12(%ebp) = previous pointer in the selected bin, or NULL
#   16(%ebp) = payload size to store in header 
#   20(%ebp) = address of bin variable to update if need be
#
# Returns:
#   %eax = new block header pointer
#


.include "constants/header_defs.s"
.include "constants/cmp_defs.s"

.globl update_new_pointer
.type update_new_pointer, @function

.equ ST_OLD_BRK, 8
.equ ST_PREV_PTR, 12
.equ ST_PAYLOAD_SIZE, 16
.equ ST_BIN_ADDR, 20
update_new_pointer:
    pushl %ebp
    movl %esp, %ebp
       

    movl ST_OLD_BRK(%ebp), %eax                     # old_break will be the start of the header of new pointer

    movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)

    movl ST_PAYLOAD_SIZE(%ebp), %edx 
    movl %edx, HDR_SIZE_OFFSET(%eax)

    movl $NULL_PTR, HDR_NEXT_ADDR_OFFSET(%eax)      # we don't know future next pointer so initialize to NULL
       
    movl ST_PREV_PTR(%ebp), %edx                    # %edx now holds previous pointer
    movl %edx, HDR_PREV_ADDR_OFFSET(%eax)           # update new pointer's previous pointer

    cmpl $NULL_PTR, %edx                            # if previous pointer is not a valid pointer
    je skip_prev_link                               # don't update it's header

    movl %eax, HDR_NEXT_ADDR_OFFSET(%edx)           # else it's a valid pointer and 
                                                    # store new pointer (currently in %eax)
    skip_prev_link:                                 # as next of previous pointer
    
    movl ST_BIN_ADDR(%ebp), %ebx                    # if bin variable != 0
    cmpl $NULL_PTR, (%ebx)                          # it's already initialized 
    jne bin_already_initialized                               
                                                   
    movl %eax, (%ebx)                               # if not initialize it with new pointer's start address
    
    bin_already_initialized:

    movl %ebp, %esp
    popl %ebp
    ret

