.model small
.stack 100h
.data
	a dw ?
	b dw ?
	s1 db 'Enter divisor:',10,13,'$'
	s2 db 'Enter dividend:',10,13,'$'
	s3 db 'Quotient: $'
	s4 db 10,13,'Remainder: $'
	err db 'Error! Division by zero.$'
	ten dw 10
.code
main:
	write_num PROC
		push cx
		push dx

		mov cx, 0
		w_cycle1:
			mov dx, 0
			div ten
			push dx
			inc cx
			cmp ax, 0
			jnz w_cycle1

		w_cycle2:
			mov ah, 02h
			pop dx
			add dx, '0'
			int 21h
			dec cx
			cmp cx, 0
			jnz w_cycle2

		pop dx
		pop cx
		ret
	write_num ENDP

	read_num PROC
		push bx
		push cx
		push dx

		mov bx, 0
		push 0
		mov ch, 0

		r_cycle1:
			mov ah, 08h
			int 21h

			mov cl, al

			cmp cl, 8
			jnz r_continue1
				cmp bx, 0
				jz r_continue1
					mov dx, 0
					pop ax
					div ten
					push ax

					mov ah, 02h
					mov dl, 8
					int 21h
					mov dl, 32
					int 21h
					mov dl, 8
					int 21h

					dec bx
					jmp r_cycle1
			r_continue1:

			cmp cl, 27
			jnz r_continue2
				pop ax
				push 0

				r_cycle2:
					cmp bx, 0
					jz r_continue3
					dec bx
					mov ah, 02h
					mov dl, 8
					int 21h
					mov dl, 32
					int 21h
					mov dl, 8
					int 21h
					jmp r_cycle2
				r_continue3:

				mov ah, 02h
				mov dl, 8

				jmp r_cycle1
			r_continue2:

			cmp bx, 0
			jz r_continue4
			cmp cl, 13
				jz r_enter_pressed
			r_continue4:

pop ax
cmp ax, 0
push ax
jnz r_continue5
cmp bx, 1
jnz r_continue5
jmp r_cycle1
r_continue5:

			sub cl, '0'
			jc r_cycle1

			cmp cl, 10
			jnc r_cycle1

		 	pop ax
			mov dx, 0

			mul ten
			jnc r_continue6
				div ten
				push ax
				jmp r_cycle1
			r_continue6:

			add ax, cx
			jnc r_continue7
				sub ax, cx
				div ten
				push ax
				jmp r_cycle1
			r_continue7:

			push ax

			inc bx
			add cl, '0'
			mov ah, 02h
			mov dl, cl
			int 21h

			jmp r_cycle1
		r_enter_pressed:

		mov ah, 02h
		mov dl, 13
		int 21h
		mov dl, 10
		int 21h

		pop ax

		pop dx
		pop cx
		pop bx
		ret
	read_num ENDP

	start:
		mov ax, @data
		mov ds, ax

		mov ah, 09
		lea dx, s1
		int 21h

		call read_num
		mov a, ax

		mov ah, 09
		lea dx, s2
		int 21h

		call read_num
		mov b, ax

		cmp ax, 0
		jz if0
			mov ah, 09
			lea dx, s3
			int 21h

			mov dx, 0
			mov ax, a
			mov bx, b
			div b
			mov bx, dx

			call write_num

			mov ah, 09
			lea dx, s4
			int 21h

			mov ax, bx
			call write_num

			jmp continue
		if0:
			mov ah, 09h
			lea dx, err
			int 21h
		continue:

		mov ax, 4c00h
		int 21h
	end start
end main
