		gloval _printf
		
		gloval _start

section .text

_start:	
		mov rax, 0x3C		;exit64(rdi)
		xor rdi, rdi
		syscall


