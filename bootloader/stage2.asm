; Curs OS - Stage 2 (VESA)
; Sets a graphics mode and fills the screen with blue so we can see it works

[bits 16]
[org 0x8000]

MODE_800x600x32  equ 0x115
MODE_1024x768x32 equ 0x118

vbe_info         equ 0x6000
mode_info        equ 0x6200

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    call vesa_setup
    jc no_vesa

    ; Mode is set. Now fill the entire framebuffer with blue.
    call fill_blue

.hang:
    hlt
    jmp .hang

no_vesa:
    mov ax, 0x0003
    int 0x10
    mov si, fail_msg
    call print
.hang2:
    hlt
    jmp .hang2

; ------------------------------------------------------------
; VESA setup
; ------------------------------------------------------------
vesa_setup:
    ; Get controller info
    mov di, vbe_info
    mov dword [di], 'VBE2'
    mov ax, 0x4F00
    int 0x10
    cmp ax, 0x004F
    jne .fail

    ; Try 800x600x32
    mov cx, MODE_800x600x32
    call set_mode
    jnc .ok

    ; Try 1024x768x32
    mov cx, MODE_1024x768x32
    call set_mode
    jnc .ok

.fail:
    stc
    ret
.ok:
    clc
    ret

; CX = mode
set_mode:
    push cx
    mov ax, 0x4F01
    mov di, mode_info
    int 0x10
    pop cx
    cmp ax, 0x004F
    jne .no

    ; Must have linear FB (bit 7)
    test word [mode_info], 0x80
    jz .no

    ; Bits per pixel
    cmp byte [mode_info+25], 24
    jb .no

    ; Save info
    mov ax, [mode_info+16]
    mov [pitch], ax
    mov ax, [mode_info+18]
    mov [width], ax
    mov ax, [mode_info+20]
    mov [height], ax
    mov eax, [mode_info+40]
    mov [fb], eax

    ; Set the mode + linear FB flag
    mov bx, cx
    or bx, 0x4000
    mov ax, 0x4F02
    int 0x10
    cmp ax, 0x004F
    jne .no
    clc
    ret
.no:
    stc
    ret

; ------------------------------------------------------------
; Fill the whole screen with blue
; ------------------------------------------------------------
fill_blue:
    mov eax, [fb]
    mov ecx, [width]
    imul ecx, [height]

    ; Blue color (try a couple of common formats)
    mov ebx, 0x000000AA

.next_pixel:
    a32 mov [eax], ebx
    add eax, 4
    dec ecx
    jnz .next_pixel
    ret

print:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret

fail_msg db "No usable VESA mode found", 0

fb      dd 0
pitch    dw 0
width    dw 0
height   dw 0

times 2048-($-$$) db 0
