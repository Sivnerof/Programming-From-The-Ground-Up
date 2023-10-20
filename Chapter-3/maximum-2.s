# PURPOSE:      This program finds the maximum number of a set
#               of data items.

# VARIABLES:    The registers have the following uses:
#
# %edi (Extended Destination Index) - Holds the index of the data item being examined
# %ebx (Extended Base) - Largest data item found
# %eax (Extended Accumulator) - Current data item
#
# The following memory locations are used:
#
# data_items - contains the item data. A 0 is used
#              to terminate the data.

# Data section partition for program
.section .data


# data_items: is a label that will point to the location in memory that follows it,
# in this case, the location of the number 3.
data_items:
    # Data used, all 4-byte long integers (longs), hence the .long directive.
    .long 3,67,34,222,45,75,54,34,44,33,22,11,66,0

# Text section partition for program
.section .text

# .globl directive used to tell assembler not to get rid of this directive,
# as it will be used later by the linker.
# Without the _start label, the assembler/linker would not know where the program begins.
.globl _start

# Program starts
_start:
    # Move (movl - Move Long) the value 0 into the %edi register,
    # this register will be used as our array (data_items) index.
    # For now we load it with the first element position (0).
    movl $0, %edi

    # Move the 4-byte integer located at the %edi index of the data_items array into the accumulator (%eax)
    # data_items is the location in memory of the first array element
    # %edi is our array index
    # 4 is the multiplier we will use on the index, in order to make sure we grab 4-byte long integers.
    # In this part of the program %edi is 0, so 4 * 0 makes sure we get the value of the first array element (3).
    # Indexed Addressing Mode Syntax: movl BEGINNINGADDRESS(,%INDEXREGISTER,WORDSIZE)
    movl data_items(,%edi,4), %eax

    # Move the value stored in the accumulator (%eax) into the %ebx register.
    # At this point in the program the %ebx register will store the value 3.
    # Since this is the first element of the array, it will be the largest.
    movl %eax, %ebx

# start_loop label will be used to jump back here to restart loop
start_loop:

    # compare longs (cmpl) between the hardcoded value of 0, and the contents of the accumulator.
    # This is done in order to tell when we've reached the end of the array.
    # Results of operations like cmpl, jle, je, etc, are stored in the %eflags register, which is not seen in this program.
    cmpl $0, %eax

    # if 0 and the contents of %eax are equal, (je- jump if equal) jump to the loop_exit label.
    # At this point the largest number will be stored in the accumulator (%eax).
    je loop_exit

    # $0 and %eax were not equal, so we increment (incl - increment long) the %edi (Extended Destination Index) register value.
    incl %edi

    # Move the 4-byte integer located at the %edi index of the data_items array into the accumulator.
    movl data_items(,%edi,4), %eax

    # Compare the contents of the %ebx and %eax registers.
    cmpl %ebx, %eax

    # If the contents of the accumulator (%eax register) were less than or equal to what is currently stored in the %ebx register,
    # jump to the start_loop label (jle - jump if less or equal), and repeat the process.
    jle start_loop

    # The contents of %eax register were greater than what was in the %ebx register.
    # Move the value stored in the accumulator into the %ebx register.
    movl %eax, %ebx

    # Start the loop again.
    jmp start_loop

loop_exit:
    # %ebx is the status code for the exit system call.
    # and it already has the maximum number.
    # Move the value 1 into the accumulator to signal the system call to exit.
    movl $1, %eax

    # Interrupt, and hand control flow to Linux kernal.
    int $0x80
