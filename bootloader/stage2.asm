; Curs OS - Stage 2 Bootloader (VESA Framebuffer TUI)
; Early skeleton - sets a graphics mode and clears to blue
; NOTE: Still 16-bit real mode. Full drawing + font comes next.

[bits 16]
[org 0x8000]

; ============================================================
; VESA / VBE
; ============================================================

MODE_800x600x32   equ 0x115
MODE_1024x768x32  equ 0x118

vbe_info_block    equ 0x6000
mode_info_block   equ 0x6200

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    call vesa_init
    jc .fallback_text

    ; VESA mode is set - framebuffer is ready
    ; For now we just stop here so you can see the mode change
    ; (screen should go graphical / blue-ish depending on card)
.hang:
    hlt
    jmp .hang

.fallback_text:
    mov ax, 0x0003
    int 0x10
    mov si, msg_vesa_fail
    call print_text
.hang2:
    hlt
    jmp .hang2

; ============================================================
; VESA Initialization
; ============================================================

vesa_init:
    mov ax, 0x4F00
    mov di, vbe_info_block
    mov dword [di], 'VBE2'
    int 0x10
    cmp ax, 0x004F
    jne .fail

    mov cx, MODE_800x600x32
    call try_mode
    jnc .ok

    mov cx, MODE_1024x768x32
    call try_mode
    jnc .ok

.fail:
    stc
    ret
.ok:
    clc
    ret

try_mode:
    push cx
    mov ax, 0x4F01
    mov di, mode_info_block
    int 0x10
    pop cx
    cmp ax, 0x004F
    jne .no

    mov ax, [mode_info_block]
    test ax, 0x80
    jz .no

    mov al, [mode_info_block + 25]
    cmp al, 24
    jb .no

    mov ax, [mode_info_block + 16]
    mov [fb_pitch], ax
    mov ax, [mode_info_block + 18]
    mov [fb_width], ax
    mov ax, [mode_info_block + 20]
    mov [fb_height], ax
    mov eax, [mode_info_block + 40]
    mov [fb_addr], eax

    mov ax, 0x4F02
    mov bx, cx
    or bx, 0x4000
    int 0x10
    cmp ax, 0x004F
    jne .no

    clc
    ret
.no:
    stc
    ret

print_text:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_text
.done:
    ret

msg_vesa_fail db "VESA not available", 0

fb_addr   dd 0
fb_pitch  dw 0
fb_width  dw 0
fb_height dw 0

times 1024-($-$$) db 0
