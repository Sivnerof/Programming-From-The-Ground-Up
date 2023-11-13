.section .data

.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_EXIT, 1


.equ STDIN, 0
.equ STDOUT, 1


.equ LINUX_SYSCALL, 0x80

.equ END_OF_FILE, 0


.section .bss

.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text


.globl _start
_start:
    movl %esp, %ebp

read_loop_begin:
    movl $SYS_READ, %eax
    movl $STDIN, %ebx
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
    movl $STDOUT, %ebx
    movl $BUFFER_DATA, %ecx
    int $LINUX_SYSCALL

    jmp read_loop_begin

end_loop:
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
