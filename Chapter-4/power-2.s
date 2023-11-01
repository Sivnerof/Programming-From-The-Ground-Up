# PURPOSE: Program to illustrate how functions work
#          This program will compute the value of
#          2^3 + 5^2
#

# Everything in the main program is stored in registers,
# so the data section doesn’t have anything.
.section .data

.section .text

.globl _start
_start:
    # Push functions second argument
    pushl $3

    # Push functions first argument
    pushl $2

    # Call the power function
    # Call pushes the next instructions address onto the stack as the return address
    # Then it changes the %eip pointer to point to the start of the function.
    call power

    addl $8, %esp
    pushl %eax
    pushl $2
    pushl $5
    call power
    addl $8, %esp
    popl %ebx
    addl %eax, %ebx
    movl $1, %eax
    int $0x80

.type power, @function
power:
    # Pushes the base pointer onto the stack
    pushl %ebp

    # Moves the stack pointer into the base pointer register
    # This will make it easier to select our data by offsetting from the point where
    # the stack pointer was at this point in the program.
    movl %esp, %ebp

    # Create a space in the stacks memory by subtracting 4 bytes (1 word) from the stack pointer registers value.
    subl $4, %esp

    # Move the contents of (%ebp + 8) into the %ebx register.
    # 0(%ebp) Contains the base pointer, 4(%ebp) contains the return address, so 8(%ebp) will contain the number 2.
    movl 8(%ebp), %ebx

    # Move the number 3 into the %ecx register.
    movl 12(%ebp), %ecx

    # Move the number 2 from the %ebx register onto the stack space we cleared up with the instruction on line 47.
    movl %ebx, -4(%ebp)

power_loop_start:
    cmpl $1, %ecx
    je end_power
    movl -4(%ebp), %eax
    imull %ebx, %eax
    movl %eax, -4(%ebp)
    decl %ecx
    jmp power_loop_start

end_power:
    movl -4(%ebp), %eax
    movl %ebp, %esp
    popl %ebp
    ret
