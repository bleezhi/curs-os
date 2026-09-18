#!/bin/bash
set -e

echo "Assembling Stage 1..."
nasm -f bin stage1.asm -o stage1.bin

echo "Assembling Stage 2 (TUI)..."
nasm -f bin stage2.asm -o stage2.bin

echo "Creating disk image..."
dd if=/dev/zero of=curs.img bs=512 count=32 status=none
dd if=stage1.bin of=curs.img conv=notrunc status=none
dd if=stage2.bin of=curs.img bs=512 seek=1 conv=notrunc status=none

echo "Creating ISO..."
mkdir -p iso_root
cp curs.img iso_root/
xorriso -as mkisofs -o ../curs-os.iso -b curs.img -no-emul-boot -boot-load-size 4 -boot-info-table iso_root >/dev/null 2>&1

echo "Done!"
echo "  Disk image : bootloader/curs.img"
echo "  ISO        : curs-os.iso"
echo ""
echo "Test with:"
echo "  qemu-system-x86_64 -cdrom curs-os.iso"
echo "  or"
echo "  qemu-system-x86_64 -drive format=raw,file=bootloader/curs.img"
