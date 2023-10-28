#!/bin/bash

qemu-system-x86_64 \
    -drive file=disk.raw,index=0,media=disk \
    -bios /usr/share/edk2/x64/OVMF.fd
