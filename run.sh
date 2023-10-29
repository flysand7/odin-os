#!/bin/bash

qemu-system-x86_64 \
    -m 512M \
    -drive file=disk.raw,index=0,media=disk,format=raw \
    -bios ovmf/ovmf_x64.fd \
    -net none
