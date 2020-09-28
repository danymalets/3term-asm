.model small
.stack 100h
.data
	len db 0
    sublen db -1
    s db 201 dup (?)
    p dd 201 dup (?)
    yes db 'yes$'
    no  db 'no$'
.code
main:
	mov ax, @data
	mov ds, ax
       mov es, ax
       
       cld
       lea di, s
       mov cx, 0
       mov bx, 0
       
       cycle1:
           mov ah, 01h
           int 21h
           
           cmp al, 10
           je break1
           cmp al, 13
           je break1
           
           stosb
           
           cmp al, ' '
           jne continue1
               mov sublen, cl
           continue1:
           
           cmp cx, 0
           je if0
           
           cycle2:
               cmp bl, 0
               je break2
               
               lea si, s
               add si, bx
               
               cmp al, [si]
               je break2
               
               add bx, offset p
               dec bx
               mov bx, [bx]
           jmp cycle2
           break2:
           
           lea si, s
           add si, bx
           cmp al, [si]
           jne continue2
               inc bx
           continue2:
           
           if0:
           
           cmp bl, sublen
           je write_yes
           
           lea si, p
           add si, cx
           mov [si], bx
           
           inc cl
           
           jmp cycle1
       break1:
       
       lea si, p
       
      
       
       mov ah, 09h
       lea dx, no
       
       jmp finish
       write_yes:
           mov ah, 09h
           lea dx, yes
       finish:
       
       int 21h
       
	mov ax, 4c00h
	int 21h
end main
