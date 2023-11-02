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

    # Add 8 bytes to the address at %esp to overwrite the parameters passed in above.
    addl $8, %esp

    # Push the result stored in the accumulator onto the stack.
    pushl %eax

    # Push the two new parameters.
    pushl $2
    pushl $5

    # Call power again.
    call power

    # Add 8 bytes to the address at %esp to overwrite the two parameters passed in above.
    addl $8, %esp

    # Now that the stack is pointing at the value from %eax that we pushed onto the stack, on line 29,
    # we can pop it off into the %ebx register.
    popl %ebx

    # Now that we have the result from the second call to power in the %eax register,
    # and the result from  the first call to power in %ebx we can add them together.
    # The result will be stored in %ebx.
    addl %eax, %ebx

    # System call for exit
    movl $1, %eax
    int $0x80

# This tells the linker that the symbol power should be treated as a function.
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

    # Move the number 2 from the %ebx register onto the stack space we cleared up with the instruction on line 67.
    movl %ebx, -4(%ebp)

power_loop_start:
    # As the %ecx register (which holds the power) is decremented over the life of the loop eventually it will hit 1.
    # Once %ecx hits 1, the loop will end.
    cmpl $1, %ecx
    je end_power

    # Move the local variable into the accumulator (%eax).
    movl -4(%ebp), %eax

    # imull (Integer Multiply Long) multiplies long unsigned integers, in this case the contents of the %ebx and %eax register.
    # The result is stored into the accumulator.
    imull %ebx, %eax

    # Move the contents of the accumulator into the local variable.
    movl %eax, -4(%ebp)

    # Decrement the the %ecx register, which holds the power, and start the loop again.
    decl %ecx
    jmp power_loop_start

end_power:
    # Move the final result, stored in the local variable, into the accumulator.
    movl -4(%ebp), %eax

    # Move the base pointer into the stack pointer.
    # Now the stack pointer is pointing to the part of the stack 4 bytes above the return address.
    movl %ebp, %esp

    # Pop the base pointer off the stack and store the result in the %ebp register.
    popl %ebp

    # Now the top of the stack is the return address.
    # ret (return) will pop the return address off the stack and save the result in the %eip register.
    ret
