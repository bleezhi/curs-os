# Curs OS

A minimal, no-nonsense operating system written in **Rust**.

No blue screens. No "is not recognized as an internal or external command". Just a clean custom shell and a kernel that behaves.

## Vision

- Written entirely in Rust for memory safety
- **Custom bootloader** with its own text-mode TUI (no GRUB, no Limine)
- Custom shell called **curs** (not a cmd.exe or bash clone)
- Official shell prompt style:

```
(%USER%@%HOSTNAME%, %DIR)>
```

Example:

```
(alice@curs-box, /home/alice/projects)>
```

- Focus on clarity, reliability, and not fighting the user

## Current Status

**Bootable ISO exists.**

The custom BIOS bootloader with full TUI menu is working and can be turned into a bootable ISO.

### Bootloader features right now
- Stage 1: classic 512-byte boot sector
- Stage 2: pure VGA text-mode TUI
  - Arrow keys to navigate
  - Enter to select
  - Options: Boot Curs OS / Boot with Debug / Reboot / About

## Building the ISO

Requirements: `nasm` and `xorriso`

```bash
cd bootloader
bash build.sh
```

This produces:
- `bootloader/curs.img` (raw disk image)
- `curs-os.iso` (bootable ISO)

### Testing

```bash
qemu-system-x86_64 -cdrom curs-os.iso
# or
qemu-system-x86_64 -drive format=raw,file=bootloader/curs.img
```

## Architecture

1. **Stage 1** – Tiny assembly boot sector (512 bytes)
2. **Stage 2** – Larger bootloader with pure VGA text-mode TUI menu
3. **Kernel** – Freestanding Rust kernel (next)
4. **Shell** – The `curs` shell

## License

TBD
