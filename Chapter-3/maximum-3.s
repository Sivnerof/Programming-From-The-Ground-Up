# The Purpose of this program is to find the largest integer (222)
# The integer 255 is used to check when the array has ended.

.section .data

data_items:
    .long 3,67,34,222,45,75,54,34,44,33,22,11,66,255

.section .text

.globl _start
_start:
    movl $0, %edi
    movl data_items(,%edi,4), %eax
    movl %eax, %ebx

start_loop:
    cmpl $255, %eax
    je loop_exit
    incl %edi
    movl data_items(,%edi,4), %eax
    cmpl %ebx, %eax
    jle start_loop
    cmpl $255, %eax
    je loop_exit
    movl %eax, %ebx
    jmp start_loop

loop_exit:
    movl $1, %eax
    int $0x80
