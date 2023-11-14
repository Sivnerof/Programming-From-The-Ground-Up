.section .data

# System Call Numbers
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

# File Intentions
# (create write only, truncate if already exists)
.equ O_CREAT_WRONLY_TRUNC, 03101

# System Call Interrupt
.equ LINUX_SYSCALL, 0x80

# Added filename using .asciz directive, this is a null terminated string.
filename:
    .asciz "heynow.txt"

# This will be the string printed to file.
string_to_print:
    .asciz "Hey diddle diddle!"


.section .bss


.section .text

# Stack Positions
.equ ST_SIZE_RESERVE, 4
.equ ST_FILE_DESCRIPTOR, -4

.globl _start
_start:
    movl %esp, %ebp
    subl $ST_SIZE_RESERVE, %esp

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

    # Move the returned value from system call (file descriptor) onto the stack.
    movl %eax, ST_FILE_DESCRIPTOR(%ebp)

close_file:
    movl $SYS_CLOSE, %eax
    movl ST_FILE_DESCRIPTOR(%ebp), %ebx
    int $LINUX_SYSCALL

restore_stack_pointer:
    movl %ebp, %esp

exit_program:
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
