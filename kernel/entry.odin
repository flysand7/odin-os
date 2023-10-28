
package kernel

import "limine"

// CPU functions
@(require)
foreign import cpu "cpu/cpu.asm"

@(default_calling_convention="sysv")
foreign cpu {
    enable_sse      :: proc() ---
    halt_catch_fire :: proc() -> ! ---
}

// Odin runtime functions. You can see an example in core:runtime,
// but basically they initialize the global variables and call @(init)
// functions that we write. I show both functions here, but in we only
// care about __$startup_runtime
foreign {
    @(link_name="__$startup_runtime") _startup_runtime :: proc "odin" () ---
    @(link_name="__$cleanup_runtime") _cleanup_runtime :: proc "odin" () ---
}

@(export)
limine_terminal_rq := limine.Terminal_Request {
    id = limine.TERMINAL_REQUEST,
    revision = 0,
}

@(export)
limine_framebuffer_rq := limine.Framebuffer_Request {
    id = limine.FRAMEBUFFER_REQUEST,
    revision = 1,
}

@(export)
limine_memmap_rq := limine.Memmap_Request {
    id = limine.MEMMAP_REQUEST,
    revision = 0,
}

@(export, link_name="_start")
kmain :: proc "sysv" () {
    // Odin will not be able to work without SSE, so we enable it
    // right away. There's performance costs to that later on, but
    // we'll ignore that for now
    // Even if we don't directly use SSE, Odin uses it by default
    // on struct initializers, like `context` below, and as of now
    // there's no way to disable it.
    enable_sse()
    context = {}
    // Initialize our globals and call @init functions
    #force_no_inline _startup_runtime()
    // Get the terminal and try writing a message
    if limine_terminal_rq.response == nil || limine_terminal_rq.response.terminal_count < 1 {
        // If we didn't get a terminal from limine there's not much else we can do
        halt_catch_fire()
    }
    str := string("Hellope!")
    terminal_rs := limine_terminal_rq.response
    terminal := limine_terminal_rq.response.terminals[0]
    terminal_rs.write(terminal, cast([^]u8) raw_data(str), cast(u64) len(str))
    halt_catch_fire()
}
