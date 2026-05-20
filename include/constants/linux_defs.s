.equ SYS_EXIT, 1
.equ SYS_FORK, 2

.equ SYS_READ, 3
.equ SYS_WRITE, 4
.equ SYS_OPEN,  5
.equ SYS_CLOSE, 6

.equ SYS_WAITPID, 7

.equ SYS_BRK, 45

.equ SYS_DUP, 41
.equ SYS_DUP2,  63

.equ O_WRONLY,  01
.equ O_CREAT,   0100
.equ O_TRUNC,   01000

.equ STDIN,    0
.equ STDOUT,    1
.equ STDERR,    2
.equ LINUX_SYSCALL, 0x80
