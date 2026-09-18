; Curs OS - Stage 2 Bootloader TUI
; Debian-style dialog with custom colors

[bits 16]
[org 0x8000]

VGA_SEG      equ 0xB800

; Color attributes (bg << 4 | fg)
; 0=black 1=blue 2=green 3=cyan 4=red 5=magenta 6=brown 7=lightgrey
; 8=darkgrey 9=lightblue ... 15=brightwhite

ATTR_BG      equ 0x17      ; light grey on blue   (whole screen background)
ATTR_BOX     equ 0x7F      ; bright white on light grey  (box border - gray-white)
ATTR_INSIDE  equ 0x1F      ; bright white on blue        (inside box / selection window)
ATTR_TITLE   equ 0x1F      ; bright white on blue
ATTR_SELECT  equ 0x40      ; black on red                (selected - red "outline" feel)
ATTR_NORMAL  equ 0x17      ; light grey on blue          (unselected - gray text on low blue)
ATTR_HINT    equ 0x1E      ; yellow on blue

NUM_ITEMS    equ 4

; Box geometry
BOX_TOP      equ 5
BOX_LEFT     equ 18
BOX_WIDTH    equ 44
BOX_HEIGHT   equ 14

start:
    mov ax, 0x0003
    int 0x10

    ; Hide cursor
    mov ah, 0x01
    mov cx, 0x2000
    int 0x10

    mov byte [selected], 0
    call draw_all

.main_loop:
    call wait_key
    cmp ah, 0x48            ; Up
    je .up
    cmp ah, 0x50            ; Down
    je .down
    cmp al, 0x0D            ; Enter
    je .enter
    cmp al, 0x1B            ; Esc
    je do_reboot
    jmp .main_loop

.up:
    cmp byte [selected], 0
    je .main_loop
    dec byte [selected]
    call draw_menu_only
    jmp .main_loop

.down:
    cmp byte [selected], NUM_ITEMS-1
    je .main_loop
    inc byte [selected]
    call draw_menu_only
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

; ======================== DRAWING ========================

draw_all:
    call clear_screen
    call draw_box
    call draw_title
    call draw_menu_only
    call draw_hint
    ret

clear_screen:
    push es
    mov ax, VGA_SEG
    mov es, ax
    xor di, di
    mov cx, 80*25
    mov ax, (ATTR_BG << 8) | ' '
    rep stosw
    pop es
    ret

draw_box:
    push es
    mov ax, VGA_SEG
    mov es, ax

    ; Top border (gray-white)
    mov di, BOX_TOP*160 + BOX_LEFT*2
    mov ax, (ATTR_BOX << 8) | 0xC9      ; ╔
    stosw
    mov cx, BOX_WIDTH-2
    mov ax, (ATTR_BOX << 8) | 0xCD      ; ═
.top:
    stosw
    loop .top
    mov ax, (ATTR_BOX << 8) | 0xBB      ; ╗
    stosw

    ; Sides + blue inside fill
    mov cx, BOX_HEIGHT-2
    mov bx, 1
.sides:
    push cx
    mov ax, BOX_TOP
    add ax, bx
    imul ax, 160
    add ax, BOX_LEFT*2
    mov di, ax

    mov ax, (ATTR_BOX << 8) | 0xBA      ; ║
    stosw

    push cx
    mov cx, BOX_WIDTH-2
    mov ax, (ATTR_INSIDE << 8) | ' '    ; blue selection window
.fill:
    stosw
    loop .fill
    pop cx

    mov ax, (ATTR_BOX << 8) | 0xBA
    stosw

    inc bx
    pop cx
    loop .sides

    ; Bottom border
    mov ax, BOX_TOP + BOX_HEIGHT - 1
    imul ax, 160
    add ax, BOX_LEFT*2
    mov di, ax
    mov ax, (ATTR_BOX << 8) | 0xC8      ; ╚
    stosw
    mov cx, BOX_WIDTH-2
    mov ax, (ATTR_BOX << 8) | 0xCD
.bot:
    stosw
    loop .bot
    mov ax, (ATTR_BOX << 8) | 0xBC      ; ╝
    stosw

    pop es
    ret

draw_title:
    mov si, title_str
    mov dh, BOX_TOP + 1
    mov dl, BOX_LEFT + 12
    mov bl, ATTR_TITLE
    call print_at
    ret

draw_menu_only:
    ; Item 0
    mov si, item0
    mov dh, BOX_TOP + 4
    mov dl, BOX_LEFT + 4
    mov bl, ATTR_NORMAL
    cmp byte [selected], 0
    jne .i0
    mov bl, ATTR_SELECT
.i0:
    call print_at

    ; Item 1
    mov si, item1
    mov dh, BOX_TOP + 6
    mov dl, BOX_LEFT + 4
    mov bl, ATTR_NORMAL
    cmp byte [selected], 1
    jne .i1
    mov bl, ATTR_SELECT
.i1:
    call print_at

    ; Item 2
    mov si, item2
    mov dh, BOX_TOP + 8
    mov dl, BOX_LEFT + 4
    mov bl, ATTR_NORMAL
    cmp byte [selected], 2
    jne .i2
    mov bl, ATTR_SELECT
.i2:
    call print_at

    ; Item 3
    mov si, item3
    mov dh, BOX_TOP + 10
    mov dl, BOX_LEFT + 4
    mov bl, ATTR_NORMAL
    cmp byte [selected], 3
    jne .i3
    mov bl, ATTR_SELECT
.i3:
    call print_at
    ret

draw_hint:
    mov si, hint_str
    mov dh, BOX_TOP + BOX_HEIGHT - 2
    mov dl, BOX_LEFT + 5
    mov bl, ATTR_HINT
    call print_at
    ret

print_at:
    push es
    push ax
    push bx
    push di

    mov ax, VGA_SEG
    mov es, ax

    movzx ax, dh
    imul ax, 160
    movzx bx, dl
    shl bx, 1
    add ax, bx
    mov di, ax

.loop:
    lodsb
    or al, al
    jz .done
    mov ah, bl
    stosw
    jmp .loop
.done:
    pop di
    pop bx
    pop ax
    pop es
    ret

wait_key:
    xor ah, ah
    int 0x16
    ret

; ======================== ACTIONS ========================

boot_curs:
    call clear_screen
    mov si, msg_boot
    mov dh, 12
    mov dl, 28
    mov bl, ATTR_TITLE
    call print_at
    jmp $

boot_debug:
    call clear_screen
    mov si, msg_debug
    mov dh, 12
    mov dl, 26
    mov bl, ATTR_TITLE
    call print_at
    jmp $

do_reboot:
    db 0xEA
    dw 0x0000
    dw 0xFFFF

show_about:
    call clear_screen
    call draw_box
    mov si, about1
    mov dh, BOX_TOP + 4
    mov dl, BOX_LEFT + 14
    mov bl, ATTR_TITLE
    call print_at
    mov si, about2
    mov dh, BOX_TOP + 6
    mov dl, BOX_LEFT + 4
    mov bl, ATTR_NORMAL
    call print_at
    mov si, about3
    mov dh, BOX_TOP + 8
    mov dl, BOX_LEFT + 8
    mov bl, ATTR_NORMAL
    call print_at
    mov si, about4
    mov dh, BOX_TOP + 11
    mov dl, BOX_LEFT + 8
    mov bl, ATTR_HINT
    call print_at

    call wait_key
    call draw_all
    jmp start.main_loop

; ======================== DATA ========================

selected db 0

title_str db " Curs Bootloader ", 0

item0     db "  Boot Curs OS              ", 0
item1     db "  Boot with Debug           ", 0
item2     db "  Reboot                    ", 0
item3     db "  About Curs                ", 0

hint_str  db "Arrow keys to select  -  Enter to confirm", 0

msg_boot  db "Loading Curs OS...", 0
msg_debug db "Loading with debug...", 0

about1    db "Curs OS", 0
about2    db "Custom bootloader - no GRUB, no Limine", 0
about3    db "Pure VGA text-mode TUI", 0
about4    db "Press any key to return", 0
