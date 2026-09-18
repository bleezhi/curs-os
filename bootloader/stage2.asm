; Curs OS - Stage 2 Bootloader with TUI
; Pure VGA text-mode menu (80x25)
; Arrow keys + Enter to select

[bits 16]
[org 0x8000]

; VGA text buffer segment
VGA_SEG     equ 0xB800

; Colors
ATTR_NORMAL equ 0x07        ; light grey on black
ATTR_SELECT equ 0x70        ; black on light grey (highlight)
ATTR_TITLE  equ 0x0F        ; bright white
ATTR_BORDER equ 0x08        ; dark grey

; Menu items
NUM_ITEMS   equ 4

start:
    ; Set 80x25 text mode
    mov ax, 0x0003
    int 0x10

    ; Hide cursor
    mov ah, 0x01
    mov cx, 0x2000
    int 0x10

    ; Initial selection
    mov byte [selected], 0

    call draw_ui

.main_loop:
    call wait_key
    cmp ah, 0x48            ; Up arrow
    je .up
    cmp ah, 0x50            ; Down arrow
    je .down
    cmp al, 0x0D            ; Enter
    je .enter
    jmp .main_loop

.up:
    cmp byte [selected], 0
    je .main_loop
    dec byte [selected]
    call draw_ui
    jmp .main_loop

.down:
    cmp byte [selected], NUM_ITEMS-1
    je .main_loop
    inc byte [selected]
    call draw_ui
    jmp .main_loop

.enter:
    mov al, [selected]
    cmp al, 0
    je boot_curs
    cmp al, 1
    je boot_debug
    cmp al, 2
    je do_reboot
    cmp al, 3
    je show_about
    jmp .main_loop

; -------------------- UI Drawing --------------------

draw_ui:
    call clear_screen
    call draw_border
    call draw_title
    call draw_menu
    ret

clear_screen:
    push es
    mov ax, VGA_SEG
    mov es, ax
    xor di, di
    mov cx, 80*25
    mov ax, (ATTR_NORMAL << 8) | ' '
    rep stosw
    pop es
    ret

draw_border:
    push es
    mov ax, VGA_SEG
    mov es, ax

    ; Top line
    mov di, 1*160 + 2
    mov cx, 78
    mov ax, (ATTR_BORDER << 8) | 0xC4
.top:
    stosw
    loop .top

    ; Bottom line
    mov di, 23*160 + 2
    mov cx, 78
    mov ax, (ATTR_BORDER << 8) | 0xC4
.bot:
    stosw
    loop .bot

    pop es
    ret

draw_title:
    mov si, title_str
    mov dh, 3
    mov dl, 28
    mov bl, ATTR_TITLE
    call print_at
    ret

draw_menu:
    ; Item 0 - Boot Curs OS
    mov si, item0
    mov dh, 8
    mov dl, 26
    mov bl, ATTR_NORMAL
    cmp byte [selected], 0
    jne .p0
    mov bl, ATTR_SELECT
.p0:
    call print_at

    ; Item 1 - Boot with Debug
    mov si, item1
    mov dh, 10
    mov dl, 26
    mov bl, ATTR_NORMAL
    cmp byte [selected], 1
    jne .p1
    mov bl, ATTR_SELECT
.p1:
    call print_at

    ; Item 2 - Reboot
    mov si, item2
    mov dh, 12
    mov dl, 26
    mov bl, ATTR_NORMAL
    cmp byte [selected], 2
    jne .p2
    mov bl, ATTR_SELECT
.p2:
    call print_at

    ; Item 3 - About
    mov si, item3
    mov dh, 14
    mov dl, 26
    mov bl, ATTR_NORMAL
    cmp byte [selected], 3
    jne .p3
    mov bl, ATTR_SELECT
.p3:
    call print_at
    ret

; print_at: SI = string, DH = row, DL = col, BL = attribute
print_at:
    push es
    push ax
    push bx
    push di

    mov ax, VGA_SEG
    mov es, ax

    ; di = row * 160 + col * 2
    movzx ax, dh
    imul ax, 160
    movzx bx, dl
    shl bx, 1
    add ax, bx
    mov di, ax

.print_loop:
    lodsb
    or al, al
    jz .done
    mov ah, bl
    stosw
    jmp .print_loop
.done:
    pop di
    pop bx
    pop ax
    pop es
    ret

wait_key:
    xor ah, ah
    int 0x16            ; returns AH=scancode, AL=ascii
    ret

; -------------------- Actions --------------------

boot_curs:
    mov si, msg_boot
    mov dh, 20
    mov dl, 28
    mov bl, ATTR_TITLE
    call print_at
    ; TODO: Load kernel and jump
    jmp $

boot_debug:
    mov si, msg_debug
    mov dh, 20
    mov dl, 26
    mov bl, ATTR_TITLE
    call print_at
    ; TODO: Load kernel with debug flag
    jmp $

do_reboot:
    ; Jump to reset vector
    db 0xEA
    dw 0x0000
    dw 0xFFFF

show_about:
    call clear_screen
    mov si, about1
    mov dh, 8
    mov dl, 28
    mov bl, ATTR_TITLE
    call print_at
    mov si, about2
    mov dh, 10
    mov dl, 20
    mov bl, ATTR_NORMAL
    call print_at
    mov si, about3
    mov dh, 12
    mov dl, 24
    mov bl, ATTR_NORMAL
    call print_at

    call wait_key
    call draw_ui
    jmp start.main_loop

; -------------------- Data --------------------

selected db 0

title_str db "Curs Bootloader", 0
item0     db "  Boot Curs OS           ", 0
item1     db "  Boot with Debug        ", 0
item2     db "  Reboot                 ", 0
item3     db "  About Curs             ", 0

msg_boot  db "Loading Curs OS...", 0
msg_debug db "Loading with debug...", 0

about1    db "Curs OS Bootloader", 0
about2    db "Custom TUI - No GRUB, No Limine", 0
about3    db "Press any key to return", 0
