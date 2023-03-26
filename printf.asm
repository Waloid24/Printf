		global _printf
		global _start

;section .rodata

section .data
		msg: db "Hel %d \n", 0


section .text

;%define DEBUG


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%ifdef DEBUG
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_start:
		mov rdi, msg
		mov rsi, -19
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
;
;----------------------------------------------------------
;
;
;==========================================================
_printf:	
		push rbp
       	mov rbp, rsp
		push rbx
		
		push r9
		push r8
		push rcx
		push rdx
		push rsi

		mov r8, rdi			; string
		dec r8

.aftSpec:
		xor rdx, rdx		; buffer
		dec rdx
	
.next:		
		inc r8
		inc rdx			; distance between specifiers
		cmp byte [r8], 0	; end of str
		je .end
		cmp byte [r8], 0x25	; 0x25 = %
		jne .next
		
		inc r8

		sub r8, rdx
		dec r8
		mov rsi, r8
		mov rax, 1
		mov rdi, rax
		syscall
		add r8, rdx
		inc r8

		mov rcx, [r8]
		and rcx, 127
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


.s:		pop rsi
		mov rdi, rsi
		call __strlen		; in rdx - length
		mov rdi, 1
		mov rax, rdi
		syscall
		jmp .aftSpec

.c:		pop rsi
		mov rdi, 1			; fd = console
		mov rax, rdi		; write
		mov rdx, 1			; length word
		syscall
		jmp .aftSpec

.d:		pop rax
		call _dec
		jmp .aftSpec

.b:		mov rbx, 1
		pop rax
		call _boh
		jmp .aftSpec

.o:		mov rbx, 3
		pop rax
		call _boh
		jmp .aftSpec

.x:		mov rbx, 4
		pop rax
		call _boh
		jmp .aftSpec

.default:	jmp .next			
		

.end:	mov rsi, r8
		sub rsi, rdx
		mov rax, 1
		mov rdi, rax
		syscall

		mov rsp, rbp 
		sub rsp, 0x8
		pop rbx
		pop rbp


		ret

;==========================================================
;strchr
;==========================================================
;----------------------------------------------------------
;The function that looks for the first occurence of
;a character in a string.
;----------------------------------------------------------
;Arguments:
;	1) rdi (pointer to the string)
;	2) al  (ascii code of the desired character)
;Returns:
;	1) rsi (pointer to the first occurrence of a
;		 character in a string)
;	2) zf  (1 if char was found, 0 otherwise)
;Destroys:
;	1) FLAGS
;	2) rsi
;==========================================================

__strchr:	push rdi 
 
		cld
.next:		
		cmp byte [rdi], 0
		je .end
		scasb			; sets zf=1 if char was found
		jne .next

		mov rsi, rdi
		dec rsi	
		pop rdi
		ret

.end:		
		or al, al		; sets zf = 0

		mov rsi, rdi	
		pop rdi
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
;	2)  rdx
;==========================================================

__strlen:	
		push rdi

		xor rdx, rdx
		mov al, 0

.Next:		
		scasb
		je .End
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
		mask db 18446744073709551615	; 111111...11111
		buf db 64 dup(0)	

section .text

_boh:	
		mov rdi, buf
		add rdi, 63

.next:
		cmp rax, 0
		je .end
		mov rsi, 18446744073709551615	; 111111...11111
		mov rcx, 64
		sub rcx, rbx			; how much to shift ->
		shr rsi, cl				; for exmpl: 000..01111
								; mask for hex     ^^^^
		push rax
		and rax, rsi			; for exmpl: rsi -> 000..01001
		
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