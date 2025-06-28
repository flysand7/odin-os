
## Odin-OS

A mini-kernel written in Odin for study purposes. The point is to test Odin out as a language for low-level tasks.
Both the language and some of the tools I'm using are fairly young and unstable and it's possible that by the time
you see this it's already outdated.

This kernel uses [limine v3.0](https://github.com/limine-bootloader/limine/tree/v3.0-branch) bootloader for booting.
I personally know it as breaking the compatibility a lot so I picked up a fairly old version for stability.

## Requirements

- `dosfstools`
- `make`
- `nasm`
- `gptfdisk`
- probably some stuff like gcc and clang for building limine