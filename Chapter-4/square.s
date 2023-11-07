# PURPOSE: This program calculates the square of the number 5.
#          5 ^ 2

# Everything in the main program is stored in registers,
# so the data section doesn’t have anything.
.section .data

.section .text

.globl _start
_start:
    pushl $5
    call square
    addl $4, %esp
    movl %eax, %ebx
    movl $1, %eax
    int $0x80

.type square, @function
square:
    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %ebx
    movl %ebx, %eax
    imul %ebx, %eax
    movl %ebp, %esp
    popl %ebp
    ret
