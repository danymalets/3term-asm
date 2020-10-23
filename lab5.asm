.model small
.stack 100h
.data
    tile_w db 10
    h db 20
    w db 32
    total_h dw 200
    total_w dw 320
    total_size dw 640
    arr db 640 dup (?)
    delay dw 40
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
    
    file_name db 'lab5_log',0
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
    call timer_reset
    
    cycle:
    
        call build_arr
        
        call display_arr
        
        call timer_wait
        call timer_reset
        
        call update_dirs
        call update_snakes
        call check_collision
        
        call check_lose
        
        
    jmp cycle
    
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
        
        cld
        mov ch, 0
        
        mov cl, start_len
        lea si, start_snake1_x
        lea di, snake1_x
        rep movsb
        
        mov cl, start_len
        lea si, start_snake1_y
        lea di, snake1_y
        rep movsb
        
        mov cl, start_len
        lea si, start_snake2_x
        lea di, snake2_x
        rep movsb
        
        mov cl, start_len
        lea si, start_snake2_y
        lea di, snake2_y
        rep movsb
        
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
                call wait_space
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
            call wait_space
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
            call wait_space
        check_continue3:
        ret
    check_lose endp
    
    wait_space proc
        push ax
        wait_cycle:
            mov ah, 08h
            int 21h
            cmp al, ' '
            jne wait_cycle
        pop ax
        ret
    wait_space endp
    
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
        
        
        
        call display_arr
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
        
        call get_val
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
    
            call file_write
            call clear_arr
            call display_arr
            
            mov ah, 00h
            mov al, 13h
            int 10h
            
            mov ax, 4c00h
            int 21h
        update_dirs_continue:
        ret
    update_dirs endp
    
    timer_wait proc
        push ax
        
        timer_wait_cycle:
            call get_time
            cmp ax, last_time
            jnb wait_continue
                add ax, 60000
            wait_continue:
            sub ax, last_time
            cmp ax, delay
            jb timer_wait_cycle
            
        pop ax
        ret
    timer_wait endp
    
    timer_reset proc
        push ax
        
        call get_time
        mov last_time, ax
        
        pop ax
        
        ret
    timer_reset endp
    
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
        
        cld
        lea di, arr
        mov cx, total_size
        mov al, bgr
        rep stosb
        
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
                mov ah, 0
                mov al, ch
                mul w
                add al, cl
                mov si, ax
            
                mov ah, arr[si]
                mov tile_color, ah
                mov tile_x, cl
                mov tile_y, ch
                call fill_tile
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
end main
