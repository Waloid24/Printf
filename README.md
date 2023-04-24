# Printf 
## My printf

Hello everyone :wave:! This is my own implementation of the printf function, written in the assembler language on the x86-64 architecture. It largely mimics the operation of the standard printf function.

### Description

I implemented my own analog of the standard printf function, which supports the following specifiers:

* `%d` - decimal representation of a number
* `%b` - binary representation of a number
* `%x` - hexadecimal representation of a number
* `%c` - character output in ASCII notation
* `%s` - line output
* `%%` - percentage withdrawal

### Compile
Type a line of code below in the console to compile and run a call to my printf function from the .cpp file
```
make printf
```

File execution result main.cpp:
<img src = "images/For git.png">

## C+Asm

### Description

Here I experimented with calling the standard printf function from under the assembler. I learned some interesting facts, here are some of them:
1. aligning the stack to the 16-byte boundary before calling the function;
2. floating point numbers are stored in xmm registers and the number of registers used in the printf function is passed in the argument rax.

### Compile
Type a line of code below in the console to compile and run a call to the standard printf function from under the assembler.
```
make prcasm
```

## Useful links
I save this sources that I used:
1) https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#x86_64-64_bit
2) https://filippo.io/linux-syscall-table/
3) https://cs.lmu.edu/~ray/notes/nasmtutorial/


