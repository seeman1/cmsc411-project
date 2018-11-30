	section .bss
result: 	resd 2
str: 	resb 1

	section .text
	global _start

_start:
	mov eax, [input]
	call cos

	mov ebx, 0
	mov eax, 1
	int 0x80

cos:
	mov ebx, 2
	call power

	shr rax, 32		;Shift right 32 because of the 16 decimal places
	shr rax, 1		;Divide by 2
	
	mov rbx, 0x010000
	sub rbx, rax
	mov rax, rbx
	ret	

;Put num in rax, put exp in rbx
;Result is stored in rax
power:
	mov rcx, rbx
	mov rbx, rax

	dec rcx

power_loop:
	cmp rcx, 0
	jle power_done

	push rbx
	push rcx
	push rdx
	call multiply
	pop rdx
	pop rcx
	pop rbx

	dec rcx
	jmp power_loop
power_done:
	cmp rax, 0
	jz power_zero
	ret
power_zero:
	mov rax, 1
	ret

;Put operands in rax and rbx. Result is stored in rax
multiply:
	mov dword [result], 0
	mov rcx, 32

mul_loop:
	cmp rcx, 0
	jz done_mul

	push rbx		;Save rbx
	and rbx, 1		;Get first bit
	mov rdx, rbx	;Copy first bit to rdx
	pop rbx			;Restore rbx

	cmp rdx, 0
	jz restart_mul_loop	;If it's a zero, no need to add, continue to next bit

	push rbx		;Save rbx
	mov rbx, rax	;Move first operand to second
	mov rdx, 32
	sub rdx, rcx	;Store the number of iterations so far in rdx

shl_loop:
	cmp rdx, 0
	jz done_shl_loop

	shl rbx, 1
	dec rdx
	jmp shl_loop

done_shl_loop:
	add [result], rbx
	;mov rax, [result]
	pop rbx

restart_mul_loop:	;Continue to next bit
	shr rbx, 1		;Shift second operand right
	dec rcx
	jmp mul_loop

done_mul:
	mov rax, [result]
	ret

	section .data
input	db 0x0, 0x0, 0x0, 0x00
