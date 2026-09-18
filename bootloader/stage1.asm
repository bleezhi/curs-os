; Curs OS - Stage 1 Boot Sector
; 512-byte BIOS boot sector
; Loads Stage 2 and jumps to it

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

    ; Save boot drive (BIOS puts it in DL)
    mov [boot_drive], dl

    ; Clear screen
    mov ax, 0x0003
    int 0x10

    ; Tiny banner
    mov si, msg
    call print

    ; Load Stage 2 from sector 2 onwards into 0x8000
    ; (This assumes the image is built so Stage 2 starts at LBA 1)
    mov ah, 0x02          ; read sectors
    mov al, 16            ; number of sectors to read (8 KB for now)
    mov ch, 0             ; cylinder
    mov cl, 2             ; sector (1-based, sector 2)
    mov dh, 0             ; head
    mov dl, [boot_drive]
    mov bx, 0x8000        ; destination
    int 0x13
    jc disk_error

    ; Jump to Stage 2
    jmp 0x0000:0x8000

disk_error:
    mov si, err_msg
    call print
.hang:
    hlt
    jmp .hang

print:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret

boot_drive db 0
msg      db "Curs Stage 1 - loading TUI...", 0
err_msg  db " Disk error!", 0

times 510-($-$$) db 0
dw 0xAA55
