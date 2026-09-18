; Curs OS - Stage 2 Bootloader with TUI
; Draws a simple text-mode menu directly to VGA memory

[bits 16]
[org 0x8000]          ; We will load Stage 2 here later

; VGA text mode buffer
VGA equ 0xB8000

start:
    ; For now this is just a skeleton.
    ; Later this will:
    ; 1. Set up a clean 80x25 text mode
    ; 2. Draw a nice bordered menu
    ; 3. Handle arrow keys + Enter
    ; 4. Jump to the kernel when "Boot Curs OS" is selected

    ; Clear screen with a dark attribute
    mov ax, 0x0003
    int 0x10

    ; Print a placeholder title
    mov si, title
    call print_string

.hang:
    hlt
    jmp .hang

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

title db "Curs Bootloader - TUI coming soon", 0
