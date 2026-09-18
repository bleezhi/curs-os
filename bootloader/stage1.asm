; Curs OS - Stage 1 Boot Sector
; More robust version with better error reporting

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

    ; Save boot drive
    mov [boot_drive], dl

    ; Set text mode and clear
    mov ax, 0x0003
    int 0x10

    mov si, msg_start
    call print

    ; Reset disk system first
    xor ah, ah
    mov dl, [boot_drive]
    int 0x13

    ; Try to read Stage 2 (16 sectors starting at sector 2)
    mov ax, 0x0200 + 16     ; AH=02 read, AL=16 sectors
    mov ch, 0               ; cylinder 0
    mov cl, 2               ; starting sector 2
    mov dh, 0               ; head 0
    mov dl, [boot_drive]
    mov bx, 0x8000          ; load address
    int 0x13
    jc disk_error

    mov si, msg_ok
    call print

    ; Jump to Stage 2
    jmp 0x0000:0x8000

disk_error:
    mov si, msg_err
    call print
    ; Print the error code in AH
    mov al, ah
    call print_hex_byte
.hang:
    hlt
    jmp .hang

print:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp print
.done:
    ret

; Print AL as two hex digits
print_hex_byte:
    push ax
    shr al, 4
    call .nibble
    pop ax
    and al, 0x0F
    call .nibble
    ret
.nibble:
    and al, 0x0F
    cmp al, 10
    jl .digit
    add al, 'A' - 10
    jmp .out
.digit:
    add al, '0'
.out:
    mov ah, 0x0E
    int 0x10
    ret

boot_drive db 0
msg_start db "Curs Stage 1...", 0
msg_ok    db " OK, jumping to TUI", 13, 10, 0
msg_err   db " Disk error AH=", 0

times 510-($-$$) db 0
dw 0xAA55
