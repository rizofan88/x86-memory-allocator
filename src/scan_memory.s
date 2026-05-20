# scan_memory(start_pointer, size)
#
# Searches a bin's pointer list by using the bin head pointer as starting point.
#
# Steps:
#   1. Starting at bin head pointer.
#   2. Check whether the current pointer is available
#   3. If available, check if size is big enough.
#   4. If available, and size is big enough, return pointer.
#   3. Otherwise, follow next pointer until end of list.
#   4. If no free pointer is found, return last pointer of the list.
#
# Arguments:
#   8(%ebp)  = starting address for loop
#   12(%ebp) = minimum payload size required
#
# Returns:
#   %eax = pointer found or last non-free pointer of list
#   %edi = FOUND_PTR if pointer available, PTR_NOT_FOUND otherwise.
#
# Notes:
#   Return the last pointer of the list on failure lets allocate() append
#   a newly extended block at the end of the bin without scanning
#   through memory again.
#

.include "constants/header_defs.s"
.include "constants/cmp_defs.s"

.globl scan_memory
.type scan_memory, @function

.equ ST_START_PTR, 8
.equ ST_MIN_SIZE, 12
scan_memory:
    pushl %ebp
    movl %esp, %ebp

    movl $PTR_NOT_FOUND, %edi                          # initialize flag as not found
    movl ST_START_PTR(%ebp), %eax


    check_ptr:
        cmpl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)        # is current pointer available?
        jne next_ptr_check                             # if not check next pointer

        movl ST_MIN_SIZE(%ebp), %edx                       # is size of current pointer big enough?
        cmpl %edx, HDR_SIZE_OFFSET(%eax)               # this is mainly a check for the big bin linked list
        jge ptr_found                                  # if big enough return pointer
    
        next_ptr_check:
            cmpl $NULL_PTR, HDR_NEXT_ADDR_OFFSET(%eax) # does the list have a next pointer?
            jne move_on                                # if it does check it
                                                       
                                                       
            jmp return_ptr                             # if not, we reached end of list
                                                       
        move_on:
            movl HDR_NEXT_ADDR_OFFSET(%eax), %eax      # move next pointer to check in %eax             
                                                                                                        
            jmp check_ptr                              # restart loop                                   
                                                                                                        
    ptr_found:                                         # flag that a free ptr was found                      
        movl $FOUND_PTR, %edi                                                                           
                                                                                                        
    return_ptr:                                                                                         
        movl %ebp, %esp
        popl %ebp
        ret
    
