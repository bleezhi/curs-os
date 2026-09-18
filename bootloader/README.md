# Curs Bootloader

Custom two-stage bootloader with its own text-mode TUI.

## Stages

### Stage 1 (`stage1.asm`)
- Classic 512-byte boot sector
- Loaded by the BIOS at 0x7C00
- Loads Stage 2 into memory and jumps to it

### Stage 2 (TUI)
- Larger second stage
- Draws a clean text-mode menu directly to VGA memory (0xB8000)
- Keyboard input (arrow keys + Enter)
- Options:
  - Boot Curs OS
  - Boot with debug output
  - Reboot
  - About

No external bootloader. Everything is ours.
