
## Odin-OS

> [!NOTE]
> This kernel does not support pretty much anything yet. It's simply a "Hello, World!" kernel
> application that is being booted by a bootloader.

A mini-kernel written in Odin for study purposes. The point is to test Odin out as a language for low-level tasks.
Both the language and some of the tools I'm using are fairly young and unstable and it's possible that by the time
you see this it's already outdated.

This kernel uses [limine v3.0](https://github.com/limine-bootloader/limine/tree/v3.0-branch) bootloader for booting.
I personally know it as breaking the compatibility a lot so I picked up a fairly old version for stability.

## Building and running

In order to build and run the kernel, you need to install the following requirements:

- `dosfstools` (provides `mkfs.vfat`)
- `gptfdisk` (provides `sgdisk`)
- `nasm`
- `make`
- gcc or clang to build limine

To install them on arch, you can just copy-paste this:

```
$ pacman -S dosfstools gptfdisk nasm
```

And add whatever's missing later. For other distributions simply run the `build.sh` script and install
whatever it complains about being missing.

The, you can simply run the build script:

```
$ ./build.sh
```

It compile the kernel and burn it into the disk image `disk.raw`. You can run this image with qemu,
by running the command in the `run.sh` script.

```
$ ./run.sh
```

