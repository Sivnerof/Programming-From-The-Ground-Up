# PURPOSE:              This program uses a function named factorial to
#                       find the factorial of 5.
#                       5! = 5 * 4 * 3 * 2 * 1
#                       5! = 120
#                       The factorial is then used as the exit status code for this program.
#                       The only difference between this program and the other factorial program is
#                       that this version is non-recursive.

# No data needed here since we're only using the stack and registers.
.section .data

.section .text

.globl _start
_start:
    # Push the number 5 onto the stack
    pushl $5

    # Call the factorial function.
    # Call sets the %eip pointer to the start of function and
    # pushes the return address onto the stack as well.
    call factorial

    # Set the pointer back by four bytes to overwrite the
    # parameter we passed to the function above.
    addl $4, %esp

    # The return value of factorial is stored in the %eax register but we need
    # the %eax register to store the system call to exit,
    # so we move the return value into the %ebx register.
    # That way the factorial function result can be used as an exit status code.
    movl %eax, %ebx

    # System call for exit setup.
    movl $1, %eax

    # System call for interrupt.
    int $0x80

.type factorial, @function
factorial:
    # Push the base pointer onto the stack.
    pushl %ebp

    # This will give us a stable reference point to the stack.
    movl %esp, %ebp

    # Move the first parameter (5) into the accumulator (%eax register).
    # This register will be used to store the result of every calculation.
    movl 8(%ebp), %eax

    # Move the first parameter stored in %eax into the %ebx register.
    # The %ebx register will be multiplied with %eax every loop.
    movl %eax, %ebx

factorial_loop:
    # Base Case: Has %ebx been decremented to 1? If so end the loop.
    cmp $1, %ebx
    je factorial_end

    # Otherwise decrement %ebx,
    # On the first loop this will cause %ebx to hold the number 4.
    decl %ebx

    # Multiply %ebx and %eax, store the result in %eax.
    # On the first loop this will store the number 20 in the %eax register.
    # On the next loop the result of 20 * 3 will be stored in %eax, etc. 
    imul %ebx, %eax

    # If program reaches this line then %ebx has not decremented to 1 yet.
    # Loop will start over. 
    jmp factorial_loop

factorial_end:
    # Restore stack pointer
    movl %ebp, %esp

    # Pop the base pointer off the stack.
    popl %ebp

    # Return to caller.
    # Ret pops the return address off the stack and stores it into the %eip register.
    ret
