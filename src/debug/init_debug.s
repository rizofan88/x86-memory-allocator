# init_debug()
#
# Scans through memory linearly and prints each block 
# and its header information.
#
# Steps:
#   1. If heap start == heap end, exit as there is nothing to scan.
#   2. Start looping through memory.
#   3. Store header information and push it to print helper.
#   4. Check if block end extends passed current break, if so exit with error.
#   5. When current position == current break, exit loop.
#
# Arguments:
#   8(%ebp)  = heap begin   
#   12(%ebp) = current break
#
# Returns:
#   No return value.
#

.include "constants/header_defs.s"
.include "constants/function_ids.s"
.include "constants/error_defs.s"

.section .text

.globl init_debug
.type init_debug, @function

.equ ST_HEAP_BEGIN, 8
.equ ST_CURRENT_BREAK, 12

.equ LOC_CUR_POS, -4
.equ LOC_SIZE, -8
.equ LOC_CUR_PTR, -12
.equ LOC_FLAG, -16
.equ LOC_PTR_COUNT, -20
.equ LOC_NEXT_PTR_HDR, -24
.equ LOC_PREV_PTR_HDR, -28
.equ LOC_BLOCK_TOTAL_SIZE, -32
init_debug:
    pushl %ebp
    movl %esp, %ebp
    subl $32, %esp

    movl $0, LOC_PTR_COUNT(%ebp)

    movl ST_HEAP_BEGIN(%ebp), %eax
    movl ST_CURRENT_BREAK(%ebp), %ebx

    cmpl %eax, %ebx                                     # if no memory to scan, exit
    je exit_now

    movl %eax, LOC_CUR_POS(%ebp)
    movl %eax, LOC_CUR_PTR(%ebp)

    pushl ST_CURRENT_BREAK(%ebp)
    pushl ST_HEAP_BEGIN(%ebp)
    call print_data_title
    addl $8, %esp

    start_debug:
        movl LOC_CUR_POS(%ebp), %eax
        
        movl HDR_AVAIL_OFFSET(%eax), %edx
        movl %edx, LOC_FLAG(%ebp)

        movl HDR_NEXT_ADDR_OFFSET(%eax), %edx           
        movl %edx, LOC_NEXT_PTR_HDR(%ebp)

        movl HDR_PREV_ADDR_OFFSET(%eax), %edx
        movl %edx, LOC_PREV_PTR_HDR(%ebp)              

        movl HDR_SIZE_OFFSET(%eax), %edx            
        movl %edx, LOC_SIZE(%ebp)                     

        addl $HDR_SIZE, %edx                            # move current position by size of pointer
        addl %edx, LOC_CUR_POS(%ebp)                    # plus size of header
        
        movl ST_CURRENT_BREAK(%ebp), %ebx            
        
        cmpl LOC_CUR_POS(%ebp), %ebx                    # if break < current position
        jl calculation_error                            # exit with error
        
        movl %edx, LOC_BLOCK_TOTAL_SIZE(%ebp)

        pushl LOC_NEXT_PTR_HDR(%ebp)                    
        pushl LOC_PREV_PTR_HDR(%ebp)
        pushl LOC_PTR_COUNT(%ebp)
        pushl LOC_CUR_PTR(%ebp)
        pushl LOC_SIZE(%ebp)
        pushl LOC_FLAG(%ebp)
        pushl LOC_CUR_POS(%ebp)
        call print_data
        addl $28, %esp

        movl ST_CURRENT_BREAK(%ebp), %ebx               
        cmpl LOC_CUR_POS(%ebp), %ebx                    # current position == break ?
        je exit_now                                     # stop printing

        movl LOC_BLOCK_TOTAL_SIZE(%ebp), %edx
        addl %edx, LOC_CUR_PTR(%ebp)                    # advance current block to next block

        incl LOC_PTR_COUNT(%ebp)

        jmp start_debug

        calculation_error:
            pushl $DEBUG_ERROR
            pushl $init_debug_str
            call exit_with_error

    exit_now:
        call print_four_newline
        
        movl %ebp, %esp
        popl %ebp
        ret
