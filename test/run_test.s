# run_test(func_to_call,
#          expected_outcome_flag,
#          expected_exit_code
#          )
#
# Forks current process and calls function passed as argument.
#
# Steps:
#   1. Fork process so that if function called creates an error, program doesn't crash
#      and we can inspect exit status.
#   2. If fork is successful, call function in child process.
#   3. When child returns, compare exit status returned with expected outcome.
#   4. Return whether expected outcome was met or not.
#
# Arguments:
#   8(%ebp)  = function_to_call
#   12(%ebp) = expected_outcome_flag
#   16(%ebp) = expected_exit_code
#
# Returns:
#   %eax = failure or success flag
#
# Notes:
#   This function checks the flags passed as arguments to determine whether to 
#   treat an error or no error as failure or success of the test.
#   If the flag indicates a check for success, it will return failure on any status
#   different than 0.
#   Otherwise it will check that an error occured and that the exit code returned
#   coincides with the one passed as argument. Only in that case will a function
#   expected to fail, be evaluated as successful.
#

.include "constants/test_defs.s"
.include "constants/linux_defs.s"

.section .bss
    status:
    .space 4
    child_pid:
    .space 4

.section .text

.globl run_test
.type run_test, @function

.equ ST_FUNC_CALL, 8
.equ ST_STATUS_FLAG, 12
.equ ST_EXIT_CODE, 16
run_test:
    pushl %ebp
    movl %esp, %ebp

    movl $SYS_FORK, %eax            # fork happens, now there are two processes:
    int $LINUX_SYSCALL              # parent, and child

    cmpl $0, %eax                   # both processes go on from here
    jl fail_fork                    # the parent has the child PID in %eax, which will be > 0 so doesn't jump anywhere
    je child                        # the child instead has 0, so jumps to child label


    parent:
        movl %eax, child_pid        # tell WAITPID which child process to wait for
                                    
        movl $SYS_WAITPID, %eax     # parent will now call WAITPID, which will wait
        movl child_pid, %ebx        # until the child process is done
        movl $status, %ecx          # this will contain the status of the child process
        int $LINUX_SYSCALL
        

        cmpl $EXPECT_FAILURE, ST_STATUS_FLAG(%ebp)
        je expect_failure

        cmpl $0, status             # already checks exit code since 
        jne fail_test               # if whole status is not 0, exit code
                                    # can't be 0
        jmp pass_test

        expect_failure:
            cmpl $0, status
            jle fail_test
            
            movl status, %eax
            shrl $8, %eax
            cmpl ST_EXIT_CODE(%ebp), %eax
            jne fail_test

            jmp pass_test

    child:
        call redirect
        pushl %eax
        pushl %ebx

        call *ST_FUNC_CALL(%ebp)    # if fork is sucessful
                                    # it will jump here, we call the function passed as argument
                                    # and then in the parent process check the status of child
        popl %ebx
        popl %eax
        pushl %ebx
        pushl %eax
        call close_redirect
        addl $8, %esp

        movl $SYS_EXIT, %eax        # if it reaches here no error occured
        movl $0, %ebx
        int $LINUX_SYSCALL

    pass_test:
        movl $TEST_PASS, %eax

        movl %ebp, %esp
        popl %ebp
        ret

    fail_test:
        pushl status
        call print_status
        addl $4, %esp

        movl $TEST_FAIL, %eax

        movl %ebp, %esp
        popl %ebp
        ret
    

    fail_fork:
        pushl $fork_fail
        call printf
        addl $4, %esp

        movl $TEST_FAIL, %eax

        movl %ebp, %esp
        popl %ebp
        ret
