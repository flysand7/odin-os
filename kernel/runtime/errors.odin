
package rt

import "kernel:cpu"
import "kernel:stream"

// We don't expect to ever get these errors:
//    matrix_bounds_check_error
//    type_assertion_check
//    type_assertion_check2
// I'm not exporting these symbols because I'm not expecting a kernel
// to use matrices or RTTI

@(export, link_name="bounds_check_error")
bounds_check_error :: proc "contextless" (file: string, line, column: i32,
    index, count: int) #no_bounds_check
{
    if index < count {
        return
    }
    context = {}
    stream.write_str(&g_error_stream, file)
    stream.write_str(&g_error_stream, "(")
    stream.write_int(&g_error_stream, line)
    stream.write_str(&g_error_stream, ":")
    stream.write_int(&g_error_stream, column)
    stream.write_str(&g_error_stream, "): Bounds check error [")
    stream.write_int(&g_error_stream, index)
    stream.write_str(&g_error_stream, "] < [")
    stream.write_int(&g_error_stream, count)
    stream.write_str(&g_error_stream, "]\n")
    cpu.halt_catch_fire()
}

@(export, link_name="multi_pointer_slice_expr_error")
multi_pointer_slice_expr_error :: proc "contextless" (file: string, line, column: i32,
    lo, hi: int) #no_bounds_check
{
    if lo >= 0 && hi >= 0 || lo <= hi {
        return
    }
    context = {}
    stream.write_str(&g_error_stream, file)
    stream.write_str(&g_error_stream, "(")
    stream.write_int(&g_error_stream, line)
    stream.write_str(&g_error_stream, ":")
    stream.write_int(&g_error_stream, column)
    stream.write_str(&g_error_stream, "): Multi-pointer subslice error [")
    stream.write_int(&g_error_stream, lo)
    stream.write_str(&g_error_stream, ":")
    stream.write_int(&g_error_stream, hi)
    stream.write_str(&g_error_stream, "] >= [0:]\n")
}

@(export, link_name="slice_expr_error_hi")
slice_expr_error_hi :: proc "contextless" (file: string, line, column: i32,
    hi: int, len: int) #no_bounds_check
{
    if hi < len {
        return
    }
    context = {}
    stream.write_str(&g_error_stream, file)
    stream.write_str(&g_error_stream, "(")
    stream.write_int(&g_error_stream, line)
    stream.write_str(&g_error_stream, ":")
    stream.write_int(&g_error_stream, column)
    stream.write_str(&g_error_stream, "): Subslice error [:")
    stream.write_int(&g_error_stream, hi)
    stream.write_str(&g_error_stream, "] >= [:")
    stream.write_int(&g_error_stream, len)
    stream.write_str(&g_error_stream, "]\n")
}

@(export, link_name="slice_expr_error_lo_hi")
slice_expr_error_lo_hi :: proc "contextless" (file: string, line, column: i32,
    lo, hi: int, len: int) #no_bounds_check
{
    if lo >= 0 && lo <= hi && hi < len {
        return
    }
    context = {}
    stream.write_str(&g_error_stream, file)
    stream.write_str(&g_error_stream, "(")
    stream.write_int(&g_error_stream, line)
    stream.write_str(&g_error_stream, ":")
    stream.write_int(&g_error_stream, column)
    stream.write_str(&g_error_stream, "): Subslice error [:")
    stream.write_int(&g_error_stream, hi)
    stream.write_str(&g_error_stream, "] >= [0:")
    stream.write_int(&g_error_stream, len)
    stream.write_str(&g_error_stream, "]\n")
}

@(export, link_name="dynamic_array_expr_error")
dynamic_array_expr_error :: proc "contextless" (file: string, line, column: i32,
    lo, hi, len: int) #no_bounds_check
{
    if lo >= 0 && lo <= hi && hi < len {
        return
    }
    context = {}
    stream.write_str(&g_error_stream, file)
    stream.write_str(&g_error_stream, "(")
    stream.write_int(&g_error_stream, line)
    stream.write_str(&g_error_stream, ":")
    stream.write_int(&g_error_stream, column)
    stream.write_str(&g_error_stream, "): Dynamic array subslice error [")
    stream.write_int(&g_error_stream, lo)
    stream.write_str(&g_error_stream, ":")
    stream.write_int(&g_error_stream, hi)
    stream.write_str(&g_error_stream, "] >= [0:")
    stream.write_int(&g_error_stream, len)
    stream.write_str(&g_error_stream, "]\n")
}

make_slice_error_loc :: proc "contextless" (loc := #caller_location, len: int) #no_bounds_check {
    // TODO
}

make_dynamic_array_error_loc :: proc "contextless" (using loc := #caller_location, len, cap: int) #no_bounds_check
{
    // TODO
}

make_map_expr_error_loc :: proc "contextless" (loc := #caller_location, cap: int) #no_bounds_check
{
    // TODO
}
