# Curs OS

A minimal, no-nonsense operating system written in **Rust**.

No blue screens. No "is not recognized as an internal or external command". Just a clean custom shell and a kernel that behaves.

## Vision

- Written entirely in Rust for memory safety
- Custom shell called **curs** (not a cmd.exe or bash clone)
- Official prompt style:

```
(%USER%@%HOSTNAME%, %DIR)>
```

Example:

```
(alice@curs-box, /home/alice/projects)>
```

- Focus on clarity, reliability, and not fighting the user
- Long-term goal: bootable ISO with a usable environment

## Current Status

This is the early foundation. The project is being structured as a freestanding Rust kernel.

A full bootable OS (with proper bootloader, memory management, filesystem, and the custom shell) is a large undertaking. We are building it step by step.

## Building

(Build instructions and ISO generation will be added as the kernel takes shape. The goal is to have a one-command / GitHub Action path that produces a bootable image.)

## License

TBD
