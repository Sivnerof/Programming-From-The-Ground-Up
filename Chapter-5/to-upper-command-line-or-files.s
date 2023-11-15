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

    # Check if no arguments were passed in (no files).
    cmpl $1, ST_ARGC(%ebp)

    # If no files passed as arguments, skip the following:
    # open_files. open_fd_in, store_fd_in, open_fd_out
    # store_fd_out
    je read_loop_begin

open_files:
open_fd_in:
    movl $SYS_OPEN, %eax
    movl ST_ARGV_1(%ebp), %ebx
    movl $O_RDONLY, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

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
    # Check if NO files passed in as arguments
    cmpl $1, ST_ARGC(%ebp)

    # If so, set the file descriptor to STDIN
    je set_ebx_to_stdin

    # If not so, set the file descriptor to file descriptor on stack
    jne set_ebx_to_fd_in_on_stack

# No files were passed in as arguments, if this reached.
set_ebx_to_stdin:
    movl $STDIN, %ebx
    jmp continue_loop_with_correct_fd_in

# Files were passed in as arguments, set file descriptor to input file on stack.
set_ebx_to_fd_in_on_stack:
    movl ST_FD_IN(%ebp), %ebx

# The %ebx register is now loaded with the correct file descriptor.
continue_loop_with_correct_fd_in:
    movl $SYS_READ, %eax
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

    # Check if NO files were passed in as arguments
    cmpl $1, ST_ARGC(%ebp)

    # If so, set the file descriptor to STDOUT
    je set_ebx_to_stdout

    # If not so, set the file descriptor to the file descriptor on the stack
    jne set_ebx_to_fd_out_on_stack

# No files were passed in as arguments, if this reached.
set_ebx_to_stdout:
    movl $STDOUT, %ebx
    jmp continue_loop_with_correct_fd_out

# Files were passed in as arguments, set file descriptor to output file on stack.
set_ebx_to_fd_out_on_stack:
    movl ST_FD_OUT(%ebp), %ebx

continue_loop_with_correct_fd_out:
    movl $BUFFER_DATA, %ecx
    int $LINUX_SYSCALL

    jmp read_loop_begin

end_loop:
    # Check if NO files were passed in as arguments.
    cmpl $1, ST_ARGC(%ebp)

    # If so end program, no need for closing files we never opened.
    je end_program

    # Otherwise, files WERE passed in as arguments and need to be closed now.
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
