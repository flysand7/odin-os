
cpu x86-64
bits 64

global enable_sse
global halt_catch_fire

section .text

enable_sse:
    ;; Clear CR0.EM and set CR0.MP
    mov rax, cr0
    and ax, 0xfffb
    or  ax, 0x0002
    mov cr0, rax
    ;; Set CR4.OSFXSR and CR4.OSXMMEXCPT
    mov rax, cr4
    or  ax, 3<<9
    mov cr4, rax
    ret

halt_catch_fire:
    cli
.loop:
    hlt
    jmp .loop
