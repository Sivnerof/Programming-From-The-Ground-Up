# This version of exit is exactly the same except for the exit status code,
# and the added comments.

#PURPOSE:    Simple program that exits and returns a
#            status code back to the Linux kernel
#
#INPUT:      none
#
#OUTPUT:     returns a status code. This can be viewed
#            by typing
#
#            echo $?
#
#            after running the program
#

#VARIABLES:
#            %eax holds the system call number
#            %ebx holds the return status
#

# .section and .data are assembly directives.
# Assembly directives are not translated into machine instructions, instead,
# They are instructions to the assembler itself.
# In this case, we're telling the assembler that the section is reserved for memory storage that will be used in our program.
# However, this program will use no data (from memory) so we can leave the line after the directives blank.
.section .data

# This section of our program deals with the intructions themselves.
.section .text

# _start is a symbol, that marks the beginning of our program.
# .globl is a directive that tells the assembler not to get rid of the symbol because the linker will need to use it.
.globl _start

# _start: defines a labels value,
# it also tells the assembler to use the value of the following instruction as the location in memory. 
_start:

# The next line of code moves (movl) the harcoded value 1 into the %eax register.
# The dollar sign indicates immediate mode, otherwise the value would be loaded from memory location 1.
# %eax is the register that needs to be loaded with the system call number,
# in this case, we load %eax with the system call number for exit (1).
movl $1, %eax

# The %ebx register needs to hold the status code we want to output when the system call to exit has taken place.
# In this case we'll output a status code of 0 to indicate that the program has exited successfuly.
movl $57, %ebx

#
int $0x80

# Program needs to end with a new line or the assembler will throw an error.
