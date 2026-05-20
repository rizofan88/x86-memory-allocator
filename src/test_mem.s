.section .data
    form:
    .ascii "pointer for bin %d is %d\n\0"

.section .text
.globl _start
_start:
    pushl %ebp
    movl %esp, %ebp
    subl $24, %esp

    pushl $10
    call allocate
    addl $4, %esp

    pushl $200
    call allocate
    addl $4, %esp

    pushl $32
    call allocate
    addl $4, %esp

    pushl $200
    call allocate
    addl $4, %esp

    pushl $64
    call allocate
    addl $4, %esp

    pushl $32
    call allocate
    addl $4, %esp
    movl %eax, -4(%ebp)

    pushl $128
    call allocate
    addl $4, %esp

    pushl $64
    call allocate
    addl $4, %esp

    pushl $200
    call allocate
    addl $4, %esp

    pushl $10
    call allocate
    addl $4, %esp

    pushl $200
    call allocate
    addl $4, %esp

    pushl $128
    call allocate
    addl $4, %esp

    pushl %eax
    call deallocate

    pushl $128
    call allocate
    addl $4, %esp

    call debug

    movl $0, %ebx
    movl $1, %eax
    int $0x80
