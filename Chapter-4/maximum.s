.section .data

data_items_1:
    .long 3,67,34,222,45,75,54,34,44,33,22,11,66,0

data_items_2:
    .long 2,65,24,122,35,95,242,31,14,13,27,18,75,0

data_items_3:
    .long 10,37,44,111,98,170,50,107,200,84,33,15,62,0

.section .text

.globl _start

_start:
    pushl $data_items_1
    call maximum
    addl $4, %esp
    pushl $data_items_2
    call maximum
    addl $4, %esp
    pushl $data_items_3
    call maximum
    addl $4, %esp
    movl %eax, %ebx
    movl $1, %eax
    int $0x80

.type maximum, @function

maximum:
    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %edi
    movl (%edi), %ebx
    movl %ebx, %eax

maximum_loop_start:
    cmp $0, %ebx
    je maximum_end
    addl $4, %edi
    movl (%edi), %ebx
    cmp %eax, %ebx
    jle maximum_loop_start
    movl %ebx, %eax
    jmp maximum_loop_start

maximum_end:
    movl %ebp, %esp
    popl %ebp
    ret
