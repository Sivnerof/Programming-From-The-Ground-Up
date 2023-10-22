# This program is a modification of the first program.
# It returns the value 3.

.section .data

.section .text
.globl _start
_start:
movl $1, %eax
movl $3, %ebx
int $0x80
