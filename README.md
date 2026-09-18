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
- Long-term goal: bootable ISO with a usable environment

## Architecture (planned)

1. **Stage 1** – Tiny assembly boot sector (512 bytes)
2. **Stage 2** – Larger bootloader with a pure VGA text-mode TUI menu
3. **Kernel** – Freestanding Rust kernel
4. **Shell** – The `curs` shell

## Current Status

Early foundation + decision locked: we are building our own bootloader with a custom TUI instead of using an existing one.

## Building

(Build instructions and ISO generation will be added as the bootloader and kernel take shape.)

## License

TBD
