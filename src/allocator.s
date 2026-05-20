.section .data

.include "state/heap_state.s"
.include "constants/header_defs.s"
.include "constants/cmp_defs.s"
.include "constants/linux_defs.s"
.include "constants/function_ids.s"
.include "constants/error_defs.s"

.section .text


# allocate_init()
#
#  Initializes heap state.
#
# Steps:
#   1. Send brk syscall to query current program break.
#   2. Update the variables heap_begin and current_break to be that value.
#
# Arguments:
#   None.
#
# Returns:
#   No return value.
#
# Notes:
#   This is only meant to be called once at program start,
#   but if you try and allocate memory, the allocate() function will lazily
#   detect that heap state has not been initialized, and will initialize it for you.
#   It also assumes the user has not already extended the heap, therefore
#   heap break point and heap beginning coincide.
#

.globl allocate_init
.type allocate_init,@function

allocate_init:
    pushl %ebp                  
    movl  %esp, %ebp

    pushl %ebx                      # save register

    movl  $SYS_BRK, %eax
    movl  $REQUEST_CUR_BRK, %ebx
    int   $LINUX_SYSCALL

    cmpl $0, %eax
    je allocate_init_error

    movl  %eax, current_break                       
    movl  %eax, heap_begin                          
    
    popl %ebx                       # restore it

    movl  %ebp, %esp                                
    popl  %ebp                                      
    ret                                              

    allocate_init_error:
        pushl $INVALID_CUR_BRK
        pushl $allocate_init_str
        call exit_with_error



# allocate(size)
#
# Allocates a block of at least `size` bytes.
#
# Steps:
#   1. Initialize allocator state on first use.
#   2. Reject non-positive allocation sizes.
#   3. Round the requested size into a bin size.
#   4. Scan the matching bin's free list for an available block.
#   5. The scan function will return a flag in %edi if an available pointer was found.
#   6. If an available block is found, mark it unavailable.
#   7. Otherwise, extend the heap with brk and create a new block header.
#   8. Return a pointer to the payload area, not the header.
#
# Arguments:
#   8(%ebp) = requested payload size
#
# Returns:
#   %eax = pointer to allocated payload
#
# Notes:
#   Internally, block pointers refer to the header address.
#   The public pointer returned to the caller is header + HDR_SIZE.
#

.globl allocate
.type allocate,@function

.equ ST_REQ_SIZE, 8

.equ LOC_OLD_BREAK, -4
.equ LOC_BIN_ADDRESS, -8
.equ LOC_BIN_SIZE, -12
.equ LOC_PREVIOUS_POINTER, -16
allocate:
    pushl %ebp                             
    movl  %esp, %ebp
    subl $16, %esp
    
    pushl %ebx
    pushl %esi
    pushl %edi

    cmpl $0, ST_REQ_SIZE(%ebp)
    jle allocate_error

    cmpl $0, heap_begin
    je init_mem

    cmpl $0, current_break
    je init_mem

    continue_alloc:

    pushl ST_REQ_SIZE(%ebp)
    call return_bin_info
    addl $4, %esp

    movl current_break, %edx
    movl %edx, LOC_OLD_BREAK(%ebp)
    movl %ecx, LOC_BIN_ADDRESS(%ebp)
    movl %ebx, LOC_BIN_SIZE(%ebp)

    movl $NULL_PTR, LOC_PREVIOUS_POINTER(%ebp)  # default: this is first block of bin 
                                                
    cmpl $BIN_NOT_INIT, %eax                    # if bin is empty, no free-list scan needed 
    je extend_break_jmp

    pushl %ebx
    pushl %eax
    call scan_memory
    addl $8, %esp
    
    movl %eax, LOC_PREVIOUS_POINTER(%ebp)       # if we need to extend the break, the result 
                                                # of scan memory (%eax) will be the last valid ptr
    cmpl $FOUND_PTR, %edi                       # did scan_memory return a usable pointer? 
    jne extend_break_jmp                        # if not append new block of memory
    
    pushl %eax                                  # else we found unused ptr, %eax points to the beginning of header
    call mark_ptr                               # we mark it as used
    popl %eax                                   # clean stack and restore found pointer 
                                                
                                                

    end_func:
        addl $HDR_SIZE, %eax                    # add the header size, so now it points to actual usable memory

        popl %edi
        popl %esi
        popl %ebx

        movl %ebp, %esp
        popl %ebp
        ret
    
    extend_break_jmp:
        pushl LOC_BIN_SIZE(%ebp)
        pushl current_break 
        call extend_break
        addl $8, %esp

    initialize_new_block:
        pushl LOC_BIN_ADDRESS(%ebp)
        pushl LOC_BIN_SIZE(%ebp)
        pushl LOC_PREVIOUS_POINTER(%ebp)
        pushl LOC_OLD_BREAK(%ebp)
        call update_new_pointer
        addl $16, %esp

        jmp end_func
    
    allocate_error:
       pushl $INVALID_SIZE_REQ
       pushl $allocate_str
       call exit_with_error 

init_mem:
    call allocate_init
    jmp continue_alloc



# update_break(new_break)
#
# Updates current_break variable with result of extend_break(), `new_break`.
# 
# Steps:
#   1. Update current_break with new break value.
# 
# Arguments:
#   4(%esp) = new_break
#
# Returns:
#   No return value.
#

.globl update_break
.type update_break, @function

update_break:
    movl 4(%esp), %edx
    movl %edx, current_break
    ret



# return_heap_begin_and_end()
#
# Returns address of heap_begin and current_break variables.
# 
# Arguments:
#   None.
#
# Returns:
#   %eax = address of heap_begin variable.
#   %ebx = address of current_break variable.
#
# Notes:    
#  Exposes the addresses of heap state variables so callers don't 
#  depend on the storage labels.
#



.globl return_heap_begin_and_end
.type return_heap_begin_and_end, @function

return_heap_begin_and_end:
        pushl %ebp
        movl %esp, %ebp

        movl $heap_begin, %eax
        movl $current_break, %ebx

        movl %ebp, %esp
        popl %ebp
        ret
        
