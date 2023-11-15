.section .data

.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1


.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101


.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2


.equ LINUX_SYSCALL, 0x80

.equ END_OF_FILE, 0

.equ NUMBER_ARGUMENTS, 2

# This will be the error string printed to STDERR.
error_message:
    .asciz "An error occured..."

# Size of error message
.equ error_message_size, 19

.section .bss

.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE


.section .text


.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0
.equ ST_ARGV_0, 4
.equ ST_ARGV_1, 8
.equ ST_ARGV_2, 12

.globl _start
_start:
    movl %esp, %ebp
    subl $ST_SIZE_RESERVE, %esp

open_files:
open_fd_in:
    movl $SYS_OPEN, %eax
    movl ST_ARGV_1(%ebp), %ebx
    movl $O_RDONLY, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

error_check_first_open_file:
    # If %eax is a negative number, there was an error.
    cmpl $0, %eax
    jle open_first_file_error

    # Otherwise continue with the program.
    jge store_fd_in

# %eax was negative, write to STDERR
open_first_file_error:
    # Open System Call (4) moved into %eax
    movl $SYS_WRITE, %eax
    # Move the STDERR file descriptor into the %ebx register
    movl $STDERR, %ebx
    # Move the address of the first character in the error_message string into the %ecx register
    movl $error_message, %ecx
    # move the size of the string (19 bytes) into the %edx register.
    movl $error_message_size, %edx
    # Transfer control to Linux
    int $LINUX_SYSCALL
    # If there was an error opening the first file, end the program.
    jmp end_program

store_fd_in:
    movl %eax, ST_FD_IN(%ebp)

open_fd_out:
    movl $SYS_OPEN, %eax
    movl ST_ARGV_2(%ebp), %ebx
    movl $O_CREAT_WRONLY_TRUNC, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

store_fd_out:
    movl %eax, ST_FD_OUT(%ebp)


read_loop_begin:
    movl $SYS_READ, %eax
    movl ST_FD_IN(%ebp), %ebx
    movl $BUFFER_DATA, %ecx
    movl $BUFFER_SIZE, %edx
    int $LINUX_SYSCALL

    cmpl $END_OF_FILE, %eax
    jle end_loop

continue_read_loop:
    pushl $BUFFER_DATA
    pushl %eax
    call convert_to_upper
    popl %eax
    addl $4, %esp

    movl %eax, %edx
    movl $SYS_WRITE, %eax
    movl ST_FD_OUT(%ebp), %ebx
    movl $BUFFER_DATA, %ecx
    int $LINUX_SYSCALL

    jmp read_loop_begin

end_loop:
    movl $SYS_CLOSE, %eax
    movl ST_FD_OUT(%ebp), %ebx
    int $LINUX_SYSCALL

    movl $SYS_CLOSE, %eax
    movl ST_FD_IN(%ebp), %ebx
    int $LINUX_SYSCALL

end_program:
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL


.equ LOWERCASE_A, 'a'
.equ LOWERCASE_Z, 'z'
.equ UPPER_CONVERSION, 'A' - 'a'


.equ ST_BUFFER_LEN, 8
.equ ST_BUFFER, 12
convert_to_upper:
pushl %ebp
movl %esp, %ebp


movl ST_BUFFER(%ebp), %eax
movl ST_BUFFER_LEN(%ebp), %ebx
movl $0, %edi
cmpl $0, %ebx
je end_convert_loop

convert_loop:
    movb (%eax,%edi,1), %cl

    cmpb $LOWERCASE_A, %cl
    jl next_byte
    cmpb $LOWERCASE_Z, %cl
    jg next_byte

    addb $UPPER_CONVERSION, %cl
    movb %cl, (%eax,%edi,1)

next_byte:
    incl %edi
    cmpl %edi, %ebx
    jne convert_loop

end_convert_loop:
    movl %ebp, %esp
    popl %ebp
    ret
