
package kernel

// import odin_runtime "core:runtime"

import "limine"
import "kernel:cpu"
import "core:io"
import "base:runtime"

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

limine_terminal_write :: proc(iostream: ^io.IO_Stream, buf: []u8) #no_bounds_check {
    terminal_response := cast(^limine.Terminal_Response) iostream.payload
    terminal_response.write(terminal_response.terminals[0], raw_data(buf), cast(u64) len(buf))
}

limine_terminal_stream :: proc(term_response: ^limine.Terminal_Response)->io.IO_Stream {
    error_stream := io.IO_Stream{}
    error_stream.flags |= {.Write}
    error_stream.write = limine_terminal_write
    error_stream.payload = cast(rawptr) term_response
    return error_stream
}

@(export, link_name="_start")
kmain :: proc "sysv" () {
    // Odin will not be able to work without SSE, so we enable it
    // right away. There's performance costs to that later on, but
    // we'll ignore that for now
    // Even if we don't directly use SSE, Odin uses it by default
    // on struct initializers, like `context` below, and as of now
    // there's no way to disable it.
    cpu.enable_sse()
    context = {}
    // Initialize our globals and call @init functions
    #force_no_inline _startup_runtime()
    // Get the terminal and try writing a message
    if limine_terminal_rq.response == nil || limine_terminal_rq.response.terminal_count < 1 {
        // If we didn't get a terminal from limine there's not much else we can do
        cpu.halt_catch_fire()
    }
    limine_terminal := limine_terminal_stream(limine_terminal_rq.response)
    runtime.g_error_out = limine_terminal
    a: [4]i32
    b := a[:]
    b[5] = 0
    // stream.write_fmt(&limine_terminal, "Hello, world I have {0b} friends", 65)
    // runtime.set_error_stream(limine_terminal)
    // Create the error output stream out of limine terminal
    cpu.halt_catch_fire()
}
