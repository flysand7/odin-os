#!/bin/bash

mkdir -p bin/ovmf

# Build the limine-deploy script
echo "==> Building limine"
cd limine-v3
make limine-deploy
make limine-version
cd ..

# Compile our kernel
echo "==> Compiling the kernel"
odin build kernel                     \
    -out:bin/kernel                   \
    -collection:kernel=kernel         \
    -debug                            \
    -build-mode:obj                   \
    -target:freestanding_amd64_sysv   \
    -no-crt                           \
    -no-thread-local                  \
    -no-entry-point                   \
    -reloc-mode:pic                   \
    -disable-red-zone                 \
    -default-to-nil-allocator         \
    -foreign-error-procedures         \
    -vet                              \
    -strict-style                     \
    -disallow-do                      \
    -no-threaded-checker              \
    -no-rtti                          \
    -max-error-count:5
if [ $? -ne 0 ]; then
    exit 1
fi

nasm kernel/cpu/cpu.asm               \
    -o bin/cpu.o                      \
    -f elf64

ld bin/kernel.o bin/cpu.o             \
    -o bin/kernel.elf                 \
    -m elf_x86_64                     \
    -nostdlib                         \
    -static                           \
    -pie                              \
    --no-dynamic-linker               \
    -z text                           \
    -z max-page-size=0x1000           \
    -T kernel/link.ld
if [ $? -ne 0 ]; then
    exit 1
fi

# Allocate a raw image
echo "==> Creating a 4GiB raw image (this can be slow)"
# fallocate -x -l 4G disk.raw
truncate disk.raw --size=4294967296

# Partition the disk as GPT
#   /dev/sda1 - EFI partition
#   /dev/sda2 - ext2 root partition
echo "==> Partitioning the image"
sgdisk disk.raw --clear          > /dev/null 2>&1
sgdisk disk.raw --new=1:0M:+512M > /dev/null 2>&1
sgdisk disk.raw --new=2:+2M:-2M  > /dev/null 2>&1
sgdisk disk.raw --type=1:ef00    > /dev/null 2>&1
sgdisk disk.raw --type=2:8304    > /dev/null 2>&1

# Set up loop devices on the image
echo "==> Setting up loop devices (root permission required)"
LOOP=$(sudo losetup --partscan --find --show disk.raw)
LOOP_P1=${LOOP}p1
LOOP_P2=${LOOP}p2

# Format the EFI partition with FAT 32
echo "==> Formatting filesystems"
sudo mkfs.vfat -F 32 $LOOP_P1       > /dev/null
sudo mkfs.ext2 $LOOP_P2 -d ./root   > /dev/null

# Deploy limine bootloader on EFI partition
echo "==> Installing bootloader on EFI partition"
mkdir -p boot
sudo mount $LOOP_P1 boot
sudo mkdir -p boot/EFI/BOOT
sudo cp limine-v3/BOOTX64.EFI boot/EFI/BOOT
sudo umount $LOOP_P1
rmdir boot

# Mount the EXT2 partition and copy the kernel
echo "==> Copying the data to root partition"
mkdir -p root
sudo mount $LOOP_P2 root
sudo cp bin/kernel.elf root/kernel.elf
sudo cp ./limine.cfg   root/
sudo umount $LOOP_P2

echo "==> Removing the loop device"
sudo losetup -d $LOOP



