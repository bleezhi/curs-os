; Curs OS - Stage 1 Boot Sector
; Assembles to a classic 512-byte boot sector
; Goal: load Stage 2 and jump to it

[org 0x7C00]
[bits 16]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Clear screen (simple)
    mov ax, 0x0003
    int 0x10

    ; Print a tiny banner so we know Stage 1 is alive
    mov si, msg
.print:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .print
.done:

    ; TODO: Load Stage 2 from disk into memory
    ; TODO: Jump to Stage 2

.hang:
    hlt
    jmp .hang

msg db "Curs Stage 1", 0

; Boot signature
times 510-($-$$) db 0
dw 0xAA55
