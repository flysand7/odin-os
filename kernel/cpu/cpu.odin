
package cpu

@(require)
foreign import cpu "cpu/cpu.asm"

@(default_calling_convention="sysv")
foreign cpu {
    enable_sse      :: proc() ---
    halt_catch_fire :: proc() -> ! ---
}
