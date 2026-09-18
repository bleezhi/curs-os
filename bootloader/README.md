# Curs Bootloader

Custom two-stage bootloader with its own text-mode TUI.

## Current Status (BIOS / Legacy)

### Stage 1 (`stage1.asm`)
- Classic 512-byte boot sector
- Loads Stage 2 from disk into memory at `0x8000`
- Jumps to Stage 2

### Stage 2 (`stage2.asm`) — **TUI is live**
- Pure VGA text-mode interface (80×25)
- Arrow keys to move, Enter to select
- Menu options:
  - Boot Curs OS
  - Boot with Debug
  - Reboot
  - About Curs
- Highlighted selection, clean borders, no external bootloader involved

## UEFI Support (planned)

UEFI is a completely different world (no 512-byte sector, PE executables, EFI protocols).

Planned approach:
- Keep the current BIOS path working
- Add a separate UEFI entry point later (`bootloader/uefi/`)
- Share as much of the TUI design language as possible
- Goal: one ISO that can boot on both legacy BIOS and modern UEFI systems

For now the focus stays on finishing a solid BIOS TUI boot path that can actually hand off to the kernel.
