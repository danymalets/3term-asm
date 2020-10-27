.model small
.stack 100h
.data
    ten dw 10

    tile_w db 10
    h db 20
    w db 32
    total_h dw 200
    total_w dw 320
    total_size dw 640
    arr db 640 dup (?)
    start_len db 7
    
    max_len db 17
    
    start_snake1_x db 5, 5, 5, 5, 5, 5, 5
    start_snake1_y db 6, 5, 4, 3, 2, 1, 0
    lose1 db 0
    
    
    start_snake2_x db 26,26,26,26,26,26,26
    start_snake2_y db 13,14,15,16,17,18,19
    lose2 db 0
    
    len1 db 7
    dir1 db 2
    new_dir1 db 2
    snake1_x db 18 dup (?)
    snake1_y db 18 dup (?)
    len2 db 7
    dir2 db 0
    new_dir2 db 0
    snake2_x db 18 dup (?)
    snake2_y db 18 dup (?)
    candy_x db ?
    candy_y db ?
    
    ticks db 0
    delay db 10
    
    bgr db 08h
    sb1 db 20h
    sh1 db 01h
    sb2 db 02h
    sh2 db 79h
    cnd db 0bh
    
    tile_color db ?
    tile_x db ?
    tile_y db ?

    rect_color db ?
    rect_x1 dw ?
    rect_y1 dw ?
    rect_x2 dw ?
    rect_y2 dw ?
    
      
    
    x db 15
    y db 15
    
    last_time dw ?
    
    rand_A db 227
    rand_B dw 229
    last_rand_num db ?
    
    thnd dw 1000
    
    old_int_1ch dd 00
    
    file_name db 'lab5_log',0
    
    esc_pressed db 0
    wait_new_game db 0
.code
main:
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    mov ah, 00h
    mov al, 13h
    int 10h
    
    mov ah, 0bh
    mov bh, 00h
    mov bl, 00h
    int 10h
    
    call randomize
    

    call file_read
    call build_arr
    
    call set_my_handler
    
    cycle:
        cmp esc_pressed, 1
        jne cycle
    
    call set_sys_handler
    
    call file_write
    
    mov ah, 00h
    mov al, 13h
    int 10h
    
    mov ax, 4c00h
    int 21h
    
    set_my_handler proc
        mov ax,351ch
        int 21h
        mov word ptr old_int_1ch,bx
        mov word ptr old_int_1ch+2,es
        
        push ds
        mov ax, 251ch
        mov dx, @code
        mov ds, dx
        mov dx,offset my_int_1ch
        int 21h
        pop ds
        
        ret
    set_my_handler endp
        
    set_sys_handler proc
        push ds
        mov ax,251ch
        mov dx,word ptr old_int_1ch
        mov bx,word ptr old_int_1ch+2
        mov ds,bx
        int 21h
        pop ds
        
        ret
    set_sys_handler endp
    
    my_int_1ch proc
        cli
        
        inc ticks
        mov al, ticks
        cmp al, delay
        je update_all
            sti
            iret
        update_all:
        mov ticks, 0
        
        cmp wait_new_game, 1
        jne not_wait
            call check_new_game
            sti
            iret
        not_wait:
        
        call update_dirs
        call update_snakes
        call check_collision
        call check_lose
        
        cmp wait_new_game, 1
        je not_display
            call build_arr
            call display_arr
        not_display:
        
        sti
        iret
    my_int_1ch endp
    
    check_new_game proc
        mov ah, 01h
        int 16h
        jz check_new_game_continue
        
        mov ah, 00h
        int 16h
        
        cmp ah, 1ch
        je key_space
        
        cmp ah,01h
        je key_esc2
        
        check_new_game_continue:
        ret
        
        key_space:
            mov wait_new_game, 0
            call build_arr
            ret
        key_esc2:
            mov esc_pressed, 1
            ret
    check_new_game endp
    
    randomize proc
        mov ah, 2ch
        int 21h
        mov last_rand_num, dl
        ret
    randomize endp
    
    file_write proc
        mov ah, 3ch
        mov cx, 0
        lea dx, file_name
        int 21h
        
        mov bx, ax
        mov ah, 40h
        mov cx, 80
        lea dx, len1
        int 21h
        
        mov ah, 3eh
        int 21h
        
        ret
    file_write endp
    
    file_read proc
        mov ah, 3dh
        mov al, 0
        lea dx, file_name
        int 21h
    
        jnc c
            call new_game
            ret
        c:
    
        mov bx, ax
        mov ah, 3fh
        mov cx, 80
        lea dx, len1
        int 21h
        
        mov ah, 3eh
        int 21h
        
        mov lose1, 0
        mov lose2, 0
        
        call build_arr
        
        ret
    file_read endp
    
    new_game proc
        mov len1, 7
        mov len2, 7
        mov lose1, 0
        mov lose2, 0
        mov dir1, 2
        mov new_dir1, 2
        mov dir2, 0
        mov new_dir2, 0
        
        mov si, 0
        mov ch, 0
        mov cl, len1
        new_game_cycle:
        
            mov al, start_snake1_x[si]
            mov snake1_x[si], al
            
            mov al, start_snake1_y[si]
            mov snake1_y[si], al
            
            mov al, start_snake2_x[si]
            mov snake2_x[si], al
            
            mov al, start_snake2_y[si]
            mov snake2_y[si], al
            
            inc si
            
        loop new_game_cycle
        
        call build_arr
        call new_candy
        ret
    new_game endp
    
    check_lose proc
        cmp lose1, 1
        jne check_continue1
            cmp lose2, 1
            jne check_continue1
                mov rect_x1, 0
                mov rect_y1, 0
                mov rect_x2, 160
                mov rect_y2, 200
                mov al, sb1
                mov rect_color, al
                call fill_rect
                
                mov rect_x1, 160
                mov rect_y1, 0
                mov rect_x2, 320
                mov rect_y2, 200
                mov al, sb2
                mov rect_color, al
                call fill_rect
                
                call new_game
                mov wait_new_game, 1
                ret
        check_continue1:
        
        cmp lose1, 1
        jne check_continue2
            mov rect_x1, 0
            mov rect_y1, 0
            mov rect_x2, 320
            mov rect_y2, 200
            mov al, sb2
            mov rect_color, al
            call fill_rect
            call new_game
            mov wait_new_game, 1
            ret
        check_continue2:
            
        cmp lose2, 1
        jne check_continue3
            mov rect_x1, 0
            mov rect_y1, 0
            mov rect_x2, 320
            mov rect_y2, 200
            mov al, sb1
            mov rect_color, al
            call fill_rect
            call new_game
            mov wait_new_game, 1
            ret
        check_continue3:
        ret
    check_lose endp
    
    new_candy proc
        push ax
    
        new_candy_cycle:
            mov al, w
            call rand
            mov candy_x, al
            
            mov al, h
            call rand
            mov candy_y, al
            
            mov ah, candy_y
            mov al, candy_x
            call get_val
            
            cmp al, bgr
            jne new_candy_cycle
        
        pop ax
        
        ret
    new_candy endp
    
    ; al = random % al
    rand proc
        push bx
    
        mov bl, al
        mov al, last_rand_num
        mul rand_A
        add ax, rand_B
        mov last_rand_num, al
        mov ah, 0
        div bl
        mov al, ah
        
        pop bx
        ret
    rand endp
    
    update_snakes proc
        mov al, new_dir1
        mov dir1, al
        
        mov ch, 0
        mov cl, len1
        mov si, cx
        mov di, cx
        dec si
        update_snakes_cycle1:
            mov al, snake1_y[si]
            mov snake1_y[di], al
            mov al, snake1_x[si]
            mov snake1_x[di], al
            dec si
            dec di
        loop update_snakes_cycle1
        
        cmp dir1, 0
        je update_snakes_up1
        cmp dir1, 1
        je update_snakes_right1
        cmp dir1, 2
        je update_snakes_down1
        jmp update_snakes_left1
        
        update_snakes_up1:
            dec snake1_y
            jmp update_snakes_continue1
        update_snakes_right1:
            inc snake1_x
            jmp update_snakes_continue1
        update_snakes_down1:
            inc snake1_y
            jmp update_snakes_continue1
        update_snakes_left1:
            dec snake1_x
            jmp update_snakes_continue1
        update_snakes_continue1:
        
        mov al, new_dir2
        mov dir2, al
        
        mov ch, 0
        mov cl, len2
        mov si, cx
        mov di, cx
        dec si
        update_snakes_cycle2:
            mov al, snake2_y[si]
            mov snake2_y[di], al
            mov al, snake2_x[si]
            mov snake2_x[di], al
            dec si
            dec di
        loop update_snakes_cycle2
        
        cmp dir2, 0
        je update_snakes_up2
        cmp dir2, 1
        je update_snakes_right2
        cmp dir2, 2
        je update_snakes_down2
        jmp update_snakes_left2
        
        update_snakes_up2:
            dec snake2_y
            jmp update_snakes_continue2
        update_snakes_right2:
            inc snake2_x
            jmp update_snakes_continue2
        update_snakes_down2:
            inc snake2_y
            jmp update_snakes_continue2
        update_snakes_left2:
            dec snake2_x
            jmp update_snakes_continue2
        update_snakes_continue2:
        
        ret
    update_snakes endp
    
    build_arr proc
        call clear_arr
        
        mov ah, candy_y
        mov al, candy_x
        mov cl, cnd
        call set_val
        
        mov si, 0
        mov ch, 0
        mov cl, len1
        build_cycle1:
            push cx
            mov ah, snake1_y[si]
            mov al, snake1_x[si]
            mov cl, sb1
            call set_val
            inc si
            pop cx
        loop build_cycle1
        
        mov ah, snake1_y
        mov al, snake1_x
        mov cl, sh1
        call set_val
        
        mov si, 0
        mov ch, 0
        mov cl, len2
        build_cycle2:
            push cx
            mov ah, snake2_y[si]
            mov al, snake2_x[si]
            mov cl, sb2
            call set_val
            inc si
            pop cx
        loop build_cycle2
        
        mov ah, snake2_y
        mov al, snake2_x
        mov cl, sh2
        call set_val
        
        ret
    build_arr endp
    
    check_collision proc
        mov ah, snake1_y
        mov al, snake1_x
        
        cmp ah, h
        jb check_lose_continue1
            mov lose1, 1
        check_lose_continue1:
        
        cmp al, w
        jb check_lose_continue2
            mov lose1, 1
        check_lose_continue2:
        
        call get_val ; -------------------maybe bug
        
        cmp al, bgr
        je check_lose_continue3
            cmp al, cnd
            je check_lose_continue3
                mov lose1, 1
        check_lose_continue3:
        
        cmp al, cnd
        jne check_lose_continue4
            inc len1
            mov bl, len1
            cmp bl, max_len
            jne check_lose_continue5
                mov lose2, 1
            check_lose_continue5:
            call new_candy
        check_lose_continue4:
        
        mov ah, snake2_y
        mov al, snake2_x
        
        cmp ah, h
        jb check_lose_continue6
            mov lose2, 1
        check_lose_continue6:
        
        cmp al, w
        jb check_lose_continue7
            mov lose2, 1
        check_lose_continue7:
        
        call get_val
        cmp al, cnd
        je check_lose_continue8
            cmp al, bgr
            je check_lose_continue8
                mov lose2, 1
        check_lose_continue8:
        
        cmp al, cnd
        jne check_lose_continue9
            inc len2
            mov bl, len2
            cmp bl, max_len
            jne check_lose_continue10
                mov lose1, 1
            check_lose_continue10:
            call new_candy
        check_lose_continue9:
        
        mov ah, snake2_y
        mov al, snake2_x
        
        cmp ah, snake1_y
        jne check_lose_continue11
            cmp al, snake1_x
            jne check_lose_continue11
                mov lose1, 1
                mov lose2, 1
        check_lose_continue11:
        
        ret
    check_collision endp
    
    update_dirs proc
        update_dirs_cycle:
            mov ah, 01h
            int 16h
            jz update_dirs_continue_a
            
            mov ah, 00h
            int 16h
            cmp ah,11h
            je key_up1
            cmp ah,1Fh
            je key_down1
            cmp ah,20h
            je key_right1
            cmp ah,1Eh
            je key_left1
            
            cmp ah,48h
            je key_up2
            cmp ah,50h
            je key_down2
            cmp ah,4dh
            je key_right2
            cmp ah,4bh
            je key_left2
            
            cmp ah,01h
            je key_esc
        
            jmp update_dirs_cycle
            
            jmp cnt1
                update_dirs_cycle_a:
                jmp update_dirs_cycle
            cnt1:
            
            jmp cnt
                update_dirs_continue_a:
                jmp update_dirs_continue
            cnt:
            
            key_up1:
                cmp dir1, 2
                je update_dirs_cycle_a
                mov new_dir1, 0
                jmp update_dirs_cycle_a
            key_down1:
                cmp dir1, 0
                je update_dirs_cycle_a
                mov new_dir1, 2
                jmp update_dirs_cycle_a
            key_right1:
                cmp dir1, 3
                je update_dirs_cycle_a
                mov new_dir1, 1
                jmp update_dirs_cycle_a
                
            key_left1:
                cmp dir1, 1
                je update_dirs_cycle_a
                mov new_dir1, 3
                jmp update_dirs_cycle_a
            key_up2:
                cmp dir2, 2
                je update_dirs_cycle_a
                mov new_dir2, 0
                jmp update_dirs_cycle_a
            key_down2:
                cmp dir2, 0
                je update_dirs_cycle_a
                mov new_dir2, 2
                jmp update_dirs_cycle_a
            key_right2:
                cmp dir2, 3
                je update_dirs_cycle_a
                mov new_dir2, 1
                jmp update_dirs_cycle_a
            key_left2:
                cmp dir2, 1
                je update_dirs_cycle_a
                mov new_dir2, 3
                jmp update_dirs_cycle_a
                
            key_esc:
    
                mov esc_pressed, 1
        update_dirs_continue:
        ret
    update_dirs endp
    
    get_time proc
        push bx
        push cx
        push dx
    
        mov ah, 2ch
        int 21h
        
        mov bx, dx
        mov dx, 0
        mov ah, 0
        mov al, bh
        mul thnd
        mov bh, 0
        add ax, bx
        
        pop dx
        pop cx
        pop bx
        
        ret
    get_time endp
    
    ; arr[ah][al] = cl
    set_val proc
        push si
        push bx
    
        mov bh, 0
        mov bl, al
        mov al, ah
        mov ah, 0
        mul w
        add ax, bx
        mov si, ax
        mov arr[si], cl
        
        pop bx
        pop si
        ret
    set_val endp
    
    ; al = arr[ah][al]
    get_val proc
        push si
        push bx
    
        mov bh, 0
        mov bl, al
        mov al, ah
        mov ah, 0
        mul w
        add ax, bx
        mov si, ax
        mov al, arr[si]
        
        pop bx
        pop si
        ret
    get_val endp
    
    clear_arr proc
        push ax
        push cx
        push di
        
        mov ch, 0
        clear_label1:
            mov cl, 0
                clear_label2:
                push cx
                mov ax, cx
                mov cl, bgr
                call set_val
                pop cx
                inc cl
                cmp cl, w
                jne clear_label2
            inc ch
            cmp ch, h
            jne clear_label1
        
        pop di
        pop cx
        pop ax
        
        ret
    clear_arr endp
    
    display_arr proc
        push ax
        push cx
        push si
        
        mov ch, 0
        display_label1:
            mov cl, 0
            display_label2:
                push cx
                mov tile_x, cl
                mov tile_y, ch
                mov ax, cx
                call get_val
                mov tile_color, al
                
                call fill_tile
                pop cx
                
                inc cl
                cmp cl, w
                jne display_label2
            inc ch
            cmp ch, h
            jne display_label1
            
        pop si
        pop cx
        pop ax
        
        ret
    display_arr endp
    
    fill_tile proc
        push ax
        push bx
        
        mov al, tile_color
        mov rect_color, al
        
        mov ah, 0
        mov bh, 0
        mov bl, tile_w
        
        mov al, tile_x
        mul bl
        mov rect_x1, ax
        add ax, bx
        mov rect_x2, ax
        
        mov al, tile_y
        mul bl
        mov rect_y1, ax
        add ax, bx
        mov rect_y2, ax
        
        call fill_rect
            
        pop bx
        pop ax
        ret
    fill_tile endp
    
    fill_rect proc
        push ax
        push bx
        push cx
        push dx
        mov ah, 0ch
        mov bx, 00h
        mov al, rect_color
        mov cx, rect_x1
        mov dx, rect_y1
        rect_label:
            int 10h
            inc cx
            cmp cx, rect_x2
            jne rect_label
            mov cx, rect_x1
            inc dx
            cmp dx, rect_y2
        jne rect_label
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    fill_rect endp
    
    
    write_signed_num PROC
        push cx
        push dx

        test ax, 8000h
        jz w_go_to_cycle
            neg ax
            push ax
            mov ah, 02h
            mov dl, '-'
            int 21h

            pop ax
        w_go_to_cycle:

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
    write_signed_num ENDP
end main
