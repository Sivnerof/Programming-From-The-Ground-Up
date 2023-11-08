# PURPOSE:      This program uses a function named maximum to
#               find the maximum number of a set of data items.
#               The largest number within the third list is used
#               as the exit status code.

# data_items_1, data_items_2, data_items_3,  - Contain the item data. A 0 is used
#              to terminate the data.


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
    # Push the memory address of the first element in data_items_1 onto the stack.
    # Notice the difference between our use of $data_items_1 instead of just data_items_1.
    # Here we push the address ($data_items_1), not the value (data_items_1).
    pushl $data_items_1

    # Call the maximum function, this sets the %eip to the start of the function and
    # pushes the return address onto the stack.
    call maximum

    # Add four bytes to stack pointer, this will make sure that we overwrite the location of the parameter we passed in above.
    addl $4, %esp

    # The 3 lines of code above will be repeated two more times during this program.

    pushl $data_items_2
    call maximum
    addl $4, %esp

    pushl $data_items_3
    call maximum
    addl $4, %esp

    # The return value of the last call to maximum is stored in the %eax register.
    # The value in %eax is moved to %ebx so that we can use it as the exit status code.
    movl %eax, %ebx

    # System call number for exit (1) is moved into the %eax register.
    movl $1, %eax

    # Program end, Interrupt.
    int $0x80

# Type directive used to define maximum symbol,
# @function tells the linker/assembler to treat maximum as a function.
# @function is not needed unless we plan to share this with another program.
.type maximum, @function

maximum:
    # Push old base pointer onto stack.
    pushl %ebp

    # Move stack pointer location to %ebp register.
    # This will provide us with a stable reference to our functions data.
    movl %esp, %ebp

    # Move the function parameter (address of first element in array) into the %edi register.
    # The %edi register will be used to traverse the data items.
    movl 8(%ebp), %edi

    # %edi contains the address of the first element in the array passed into this function.
    # Here we use indirect addressing to access the value of the address stored in %edi.
    # That value is then moved into %ebx, since it is the first item it is the largest so far.
    movl (%edi), %ebx

    # The first element is then copied into the %eax register.
    # The %eax register will store the largest number so far.
    # The %ebx register will store the current element.
    movl %ebx, %eax

maximum_loop_start:
    # If the current element in %ebx is the number 0, then our array has ended.
    cmp $0, %ebx
    je maximum_end

    # Add 4 bytes to the memory address stored at %edi,
    # this will give us the address of the next element in the array.
    addl $4, %edi

    # Indirect addressing used here to get the value of the element stored at the address in %edi.
    # The new element is stored in %ebx.
    movl (%edi), %ebx

    # Compare current largest number and current element.
    cmp %eax, %ebx

    # If %ebx was smaller than %eax restart the loop. 
    jle maximum_loop_start

    # If this line was reached, %ebx was larger.
    # Move it into %eax and restart the loop so we can continue searching. 
    movl %ebx, %eax
    jmp maximum_loop_start

maximum_end:
    # Restore stack pointer.
    # Even though it hasn't moved, this is done as a good habit.
    movl %ebp, %esp

    # Pop the base pointer off the stack.
    popl %ebp

    # Return from function, the ret instruction pops the return address off of
    # the stack and sets the %eip register to the value just popped off.
    ret
