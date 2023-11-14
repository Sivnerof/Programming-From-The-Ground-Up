.section .data

.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

.equ O_CREAT_WRONLY_TRUNC, 03101

.equ LINUX_SYSCALL, 0x80

# Added filename using .asciz directive, this is a null terminated string.
filename:
    .asciz "heynow.txt"

# This will be the string printed to file.
string_to_print:
    .asciz "Hey diddle diddle!"


.section .bss


.section .text

.globl _start
_start:

open_file:
    # Open System Call (5) moved into %eax
    movl $SYS_OPEN, %eax

    # Pointer to null terminated string moved into %ebx
    movl $filename, %ebx

    # File intentions stored in %ecx 
    # (create write only, truncate if already exists)
    movl $O_CREAT_WRONLY_TRUNC, %ecx

    # Permissions stored in %edx
    # Read, write permissions for Owner, Group, and Others.
    movl $0666, %edx

    # Transfer control to Linux
    int $LINUX_SYSCALL



exit_program:
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
