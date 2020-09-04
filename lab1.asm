.model small
.stack 100h
.data
	a dw 1
	b dw 2
	c dw 3
	d dw 4
.code
main:
	mov ax, @data
	mov ds, ax

	mov ax, a
	and ax, d
	mov bx, c
	or  bx, d

	cmp ax, bx
	jnz else1
		mov ax, a
		and ax, c
		mov bx, b
		and bx, d
		add ax, bx
		jmp continue
	else1:
		mov ax, b
		and ax, d
		add ax, a
		
		jc else2

		mov bx, c
		cmp ax, bx
		jnz else2
			mov ax, c
			and ax, d
			or  ax, a
			or  ax, b
			jmp continue
		else2:
			mov ax, a
			xor ax, b
			mov bx, c
			and bx, d
			or  ax, bx
	continue:

	mov ax, 4c00h
	int 21h
end main
