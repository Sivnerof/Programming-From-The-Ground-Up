# This program is designed to find the maximum number (222).
# The program finds the end of the array by comparing the address of 255 with
# the current address.

.section .data

data_items:
    .long 3,67,34,222,45,75,54,34,44,33,22,11,66,255

.section .text

.globl _start
_start:
    movl $0, %edi
    movl data_items(,%edi,4), %eax
    movl %eax, %ebx
    movl $data_items, %ecx
    add $48, %ecx

start_loop:
    leal data_items(,%edi,4), %edx
    cmpl %ecx, %edx
    je loop_exit
    incl %edi
    movl data_items(,%edi,4), %eax
    cmpl %ebx, %eax
    jle start_loop
    movl %eax, %ebx
    jmp start_loop

loop_exit:
    movl $1, %eax
    int $0x80
