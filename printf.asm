		global _printf
		global _start

;section .rodata

section .data
		msg: db "%a", 0
		name: db "Andrei", 0

	
		char: db 0h

section .text

;%define DEBUG


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%ifdef DEBUG
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_start:
		mov rdi, msg
		mov rsi, name
		call _printf

		mov rax, 0x3C		;exit64(rdi)
		xor rdi, rdi
		syscall

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%endif
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;section .text

;==========================================================
;printf
;==========================================================
;----------------------------------------------------------
;The function outputs a string to the console. Supports
;%d, %c, %s, %o (octal number system), %x, the designations
;of the specifiers correspond to the standard printf 
;function
;----------------------------------------------------------
;Arguments:
;	1) an arbitrary number, placed in accordance with
;	   the C standard
;Returns:
;	1) A string to the console, quoted with ASCII 
;	   characters
;Destroys:
;	1) flags
;==========================================================
_printf:	

		pop r15				; removing return address

		push r9         ; pushing register arguments (6 args)
        push r8
        push rcx
        push rdx
        push rsi
        push rdi        ; first argument is format string

		call scanFormat

		pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop r8
        pop r9 

		push r15
		ret

;==========================================================
;scanFormat
;==========================================================
;----------------------------------------------------------
;service function of the printf function
;----------------------------------------------------------
;Arguments:
;		1) none (works with stack)
;Returns:
;	1) A string to the console, quoted with ASCII 
;	   characters
;Destroys:
;	1) rax	4) rbx	7) flags
;	2) rsi	5) rcx
;	3) rdi	6) rdx
;
;==========================================================

scanFormat:
		push rbp
       		mov rbp, rsp

		add rbp, 16			
		mov r8, [rbp]		; rdi points to format string 
		add rbp, 8			; rbp points to first arg
		dec r8

.aftSpec:	
		inc r8
		xor rdx, rdx

.next:
		cmp byte [r8], 0
		je .end
		cmp byte [r8], '%'
		je .specifier
		
		inc r8
		inc rdx
		jmp .next		

.specifier:
		sub r8, rdx
		mov rsi, r8
		mov rdi, 1
		mov rax, 1
		syscall

		add r8, rdx
		inc r8			; ...%d...
					;     ^	
		mov rcx, [r8]
		and rcx, 127
		cmp rcx, '%'
		je .percent
		cmp rcx, 'b'
		jl .default
		cmp rcx, 'x'
		jg .default
		sub rcx, 'b'

		jmp [.jumpTable + rcx*8]


.jumpTable:
		dq .b			; binary mode
		dq .c			; char
		dq .d			; int
		times 10 dq (.default)
		dq .o			; octal
		times 3 dq (.default)
		dq .s			; string
		times 4 dq (.default)
		dq .x			; hex
		times 2 dq (.default)


.s:		mov rsi, [rbp]		; rsi - pointer to string
		mov rdi, rsi
		call _strlen		; in rdx - length
		mov rdi, 1
		mov rax, rdi
		syscall
		add rbp, 8
		jmp .aftSpec

.c:		mov rax, [rbp]		; get elem in the stack
		mov rsi, char
		mov byte [rsi], al
		mov rdi, 1			; fd = console
		mov rax, rdi		; write
		mov rdx, 1			; length word
		syscall
		add rbp, 8
		jmp .aftSpec

.d:		mov rax, [rbp]		; get elem in the stack
		call _dec
		add rbp, 8
		jmp .aftSpec

.b:		mov rbx, 1
		mov rax, [rbp]		; get elem in the stack
		call _boh
		add rbp, 8
		jmp .aftSpec

.o:		mov rbx, 3
		mov rax, [rbp]		; get elem in the stack
		call _boh
		add rbp, 8
		jmp .aftSpec

.x:		mov rbx, 4
		mov rax, [rbp]		; get elem in the stack
		call _boh
		add rbp, 8
		jmp .aftSpec

.percent:	
		mov rsi, r8
		mov rdx, 1
		mov rdi, 1
		mov rax, 1
		syscall
		jmp .aftSpec		

.default:	
		add rdx, 2
		inc r8
		jmp .next

.end:	
		mov rsi, r8
		sub rsi, rdx
		mov rax, 1
		mov rdi, rax
		syscall				; print the remaining text

		pop rbp
		ret

;==========================================================
;strlen
;==========================================================
;----------------------------------------------------------
;The function that finds the length of a string.
;----------------------------------------------------------
;Arguments:
;	1) rdi (pointer to the string)
;Returns:
;	1) rdx (string length)
;Destroys:
;	1) FLAGS
;	2) rdx
;	3) al
;==========================================================

_strlen:	
		push rdi

		xor rdx, rdx
		mov al, 0

.Next:		
		cmp [rdi], al
		je .End
		inc rdi
		inc rdx
		jmp .Next	
	
.End:		
		pop rdi
		ret

;==========================================================
;boh function
;==========================================================
;----------------------------------------------------------
;The function that prints a number in a number system that
;is a power of 2.
;----------------------------------------------------------
;Arguments:
;	1) rax (number)
;	2) rbx (number system)
;	
;Destroys:
;	1) rdi	4)rdx
;	2) rsi
;	3) rcx
;
;Returns: Outputs to the console a number from the eax
;		  register in the number system, a multiple of two
;==========================================================


section .data
		buf db 64 dup(0)	

section .text

_boh:	
		mov rdi, buf
		add rdi, 63

.next:
		cmp rax, 0
		je .end
		mov rsi, 0xffffffffffffffff	; 111111...11111
		mov rcx, 64
		sub rcx, rbx			; how much to shift ->
		shr rsi, cl			; for exmpl: 000..01111
						; mask for hex     ^^^^
		push rax
		and rax, rsi			; for exmpl: rsi -> 000..01001

		; maybe remove 2 jumps to unconditional add rax, 0x30 + add rax, ???	
		cmp rax, 9
		ja .letter
		add rax, 0x30	
		jmp .skip

.letter:
		add rax, 0x31			; block of letters in ascii

.skip:
		std
		stosb

		pop rax
		mov rcx, rbx
		shr rax, cl
		jmp .next	
	
.end:	
		mov rdi, buf
		cld
		mov rcx, 64
		repe scasb
		dec rdi
		inc rcx

		mov rdx, rcx
		mov rsi, rdi
		mov rdi, 1
		mov rax, rdi
		syscall 
		ret


;==========================================================
;Print in decimal notation
;==========================================================
;----------------------------------------------------------
;The function writes an int number to an ASCII-encoded
;array, which is then output to the console. In the 64-bit
; version, int takes 4 bytes.
;----------------------------------------------------------
;Arguments:
;	1)rax
;Destroys:
;	1)rdi	3)rdx	5)flags
;	2)rbx	4)rsi
;Returns:
;	1) Outputs a number from the eax register in the decimal
;	   system to the console
;==========================================================

section .data
		grNeg db "-2147483648"
		sign db 0	
		bufDec db 11 dup (0)	

section .text

_dec:
		push r8
		xor r8, r8				; counter
		cmp eax, 0x80000000		; 10000...000
		je .greatestNeg
		
		mov rdi, bufDec
		add rdi, 10

		test eax, eax
		jns .notNeg

		mov bl, 0x2D
		mov [sign], bl
		neg eax

.notNeg:
		inc r8
		cmp rax, 10
		jb .end 
		mov ebx, 10
		xor rdx, rdx	; xor for div
		div rbx			; (rdx, rax) / rbx
		
		push rax
		mov rax, rdx
		add rax, 0x30
		std
		stosb 
		pop rax
		jmp .notNeg
	
.end:
		add rax, 0x30
		std
		stosb
		mov al, [sign]
		cmp al, 0
		je .next
		stosb
		inc r8
	
.next:
		inc rdi
		mov rsi, rdi		
		mov rdi, 1
		mov rax, rdi
		mov rdx, r8
		syscall
		mov al, 0
		mov [sign], al
		pop r8
		ret


.greatestNeg:
		mov rsi, grNeg
		mov rdi, 1
		mov rax, rdi
		mov rdx, 11
		syscall
		pop r8
		ret
