		global _printf
		global _start

section .data
		msg: db "Hello, Andrei!", 10, 0

section .text

%define DEBUG


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%ifdef DEBUG
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_start:
		mov rdi, msg
		mov al, "A"
		call  __strchr		; rsi -> symbol
		
		mov rdi, rsi
		call __strlen		; length A in rcx
		mov rdx, rcx

		mov rax, 1
		mov rdi, rax
		syscall

		mov rax, 0x3C		;exit64(rdi)
		xor rdi, rdi
		syscall

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%endif
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


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
;	- FLAGS
;	- rsi
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
;	1) rcx (string length)
;Destroys:
;	- FLAGS
;	- rcx
;==========================================================

__strlen:	push rdi

		xor rcx, rcx
		mov al, 0

.Next:		scasb
		je .End
		inc rcx
		jmp .Next	
	
.End:		pop rdi
		ret


