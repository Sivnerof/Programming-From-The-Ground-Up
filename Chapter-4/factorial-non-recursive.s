# PURPOSE:              This program uses a function named factorial to
#                       find the factorial of 5.
#                       5! = 5 * 4 * 3 * 2 * 1
#                       5! = 120
#                       The factorial is then used as the exit status code for this program.
#                       The only difference between this program and the other factorial program is
#                       that this version is non-recursive.

.section .data

.section .text

.globl _start
_start:
    pushl $5
    call factorial
    addl $4, %esp
    movl %eax, %ebx
    movl $1, %eax
    int $0x80

.type factorial, @function
factorial:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %ebx
    movl %ebx, %ecx

factorial_loop:
    cmp $1, %ecx
    je factorial_end
    decl %ecx
    imul %ecx, %ebx
    jmp factorial_loop

factorial_end:
    movl %ebx, %eax
    movl %ebp, %esp
    popl %ebp
    ret
