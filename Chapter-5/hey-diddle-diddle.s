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

# Size of "buffer" named string_to_print.
.equ STRING_SIZE, 18


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

write_file:
    # Open System Call (4) moved into %eax
    movl $SYS_WRITE, %eax
    # Move the file descriptor on the stack into the %ebx register
    movl ST_FILE_DESCRIPTOR(%ebp), %ebx
    # Move the address of the first character in the string_to_print string into the %ecx register
    movl $string_to_print, %ecx
    # move the size of the string (18 bytes) into the %edx register.
    movl $STRING_SIZE, %edx
    # Transfer control to Linux
    int $LINUX_SYSCALL

close_file:
    # Close System Call (6) moved into %eax
    movl $SYS_CLOSE, %eax
    # Move the file descriptor on the stack into the %ebx register
    movl ST_FILE_DESCRIPTOR(%ebp), %ebx
    # Transfer control to Linux
    int $LINUX_SYSCALL

restore_stack_pointer:
    movl %ebp, %esp

exit_program:
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
