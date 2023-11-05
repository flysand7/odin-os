/*
    Odin compiler automatically inserts bounds checking calls, the calls to
    functions in the runtime package. This file defines those functions.
    
    TODO: Threading considerations
    TODO: Output to core:io
*/
package runtime

import "kernel:cpu"
import "core:io"

g_error_out: io.IO_Stream

bounds_check_error :: proc "contextless" (file: string, line, column: i32,
    index, count: int) #no_bounds_check
{
    if index < count {
        return
    }
    context = {}
    io.write_str(&g_error_out, file)
    io.write_str(&g_error_out, "(")
    io.write_int(&g_error_out, line)
    io.write_str(&g_error_out, ":")
    io.write_int(&g_error_out, column)
    io.write_str(&g_error_out, "): Index ")
    io.write_int(&g_error_out, index)
    io.write_str(&g_error_out, " is out of range 0..<")
    io.write_int(&g_error_out, count)
    cpu.halt_catch_fire()
}

multi_pointer_slice_expr_error :: proc "contextless" (file: string, line, column: i32,
    lo, hi: int) #no_bounds_check
{
    if lo >= 0 && hi >= 0 || lo <= hi {
        return
    }
    context = {}
    io.write_str(&g_error_out, file)
    io.write_str(&g_error_out, "(")
    io.write_int(&g_error_out, line)
    io.write_str(&g_error_out, ":")
    io.write_int(&g_error_out, column)
    io.write_str(&g_error_out, "): Invalid slice indices: ")
    io.write_int(&g_error_out, lo)
    io.write_str(&g_error_out, ":")
    io.write_int(&g_error_out, hi)
    io.write_str(&g_error_out, "\n")
    cpu.halt_catch_fire()
}

slice_expr_error_hi :: proc "contextless" (file: string, line, column: i32,
    hi: int, len: int) #no_bounds_check
{
    if hi < len {
        return
    }
    context = {}
    io.write_str(&g_error_out, file)
    io.write_str(&g_error_out, "(")
    io.write_int(&g_error_out, line)
    io.write_str(&g_error_out, ":")
    io.write_int(&g_error_out, column)
    io.write_str(&g_error_out, "): Invalid slice indices ")
    io.write_int(&g_error_out, 0)
    io.write_str(&g_error_out, ":")
    io.write_int(&g_error_out, hi)
    io.write_str(&g_error_out, " is out of range 0..<")
    io.write_int(&g_error_out, len)
    io.write_str(&g_error_out, "\n")
    cpu.halt_catch_fire()
}

slice_expr_error_lo_hi :: proc "contextless" (file: string, line, column: i32,
    lo, hi: int, len: int) #no_bounds_check
{
    if lo >= 0 && lo <= hi && hi < len {
        return
    }
    context = {}
    io.write_str(&g_error_out, file)
    io.write_str(&g_error_out, "(")
    io.write_int(&g_error_out, line)
    io.write_str(&g_error_out, ":")
    io.write_int(&g_error_out, column)
    io.write_str(&g_error_out, "): Invalid slice indices: ")
    io.write_int(&g_error_out, lo)
    io.write_str(&g_error_out, ":")
    io.write_int(&g_error_out, hi)
    io.write_str(&g_error_out, "\n")
    cpu.halt_catch_fire()
}

dynamic_array_expr_error :: proc "contextless" (file: string, line, column: i32,
    lo, hi, len: int) #no_bounds_check
{
    if lo >= 0 && lo <= hi && hi < len {
        return
    }
    context = {}
    io.write_str(&g_error_out, file)
    io.write_str(&g_error_out, "(")
    io.write_int(&g_error_out, line)
    io.write_str(&g_error_out, ":")
    io.write_int(&g_error_out, column)
    io.write_str(&g_error_out, "): Invalid dynamic array indices ")
    io.write_int(&g_error_out, lo)
    io.write_str(&g_error_out, ":")
    io.write_int(&g_error_out, hi)
    io.write_str(&g_error_out, " is out of range 0..<")
    io.write_int(&g_error_out, len)
    io.write_str(&g_error_out, "\n")
    cpu.halt_catch_fire()
}
