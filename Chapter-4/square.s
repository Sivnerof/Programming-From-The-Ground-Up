# PURPOSE: This program calculates the square of the number 5.
#          5 ^ 2

# Everything in the main program is stored in registers,
# so the data section doesn’t have anything.
.section .data

.section .text

.globl _start
_start:
    pushl $5                    # Pushes the number 5 onto the stack
    call square                 # Sets %eip to start of square function, pushes return address onto stack.
    addl $4, %esp               # Adds 4 bytes to stack pointer, this will make sure the parameter pushed above will be overwritten. 
    movl %eax, %ebx             # Moves result from square into %ebx so we can use the result as a status code.
    movl $1, %eax               # System call for exit
    int $0x80                   # System call

.type square, @function
square:
    pushl %ebp                  # Pushes the old base pointer onto the stack
    movl %esp, %ebp             # Moves stack pointer into %ebp, this allows for a stable reference point.
    movl 8(%ebp), %ebx          # Moves the first and only parameter into the %ebx register.
    movl %ebx, %eax             # Moves the value of the %ebx register into %eax, %ebx is holding the parameter given earlier.
    imul %ebx, %eax             # Multiplies %ebx and %eax, result is stored in %eax. Both values before were exactly the same.
    movl %ebp, %esp             # Restore stack pointer.
    popl %ebp                   # Pop base pointer off of stack.
    ret                         # Pops return address off of stack, stores result in %eip.
