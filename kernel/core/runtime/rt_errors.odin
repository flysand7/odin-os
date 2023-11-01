/*
    Odin compiler automatically inserts bounds checking calls, the calls to
    functions in the runtime package. This file defines those functions.
    
    TODO: Threading considerations
    TODO: Output to core:io
*/
package runtime

import "kernel:cpu"

bounds_check_error :: proc "contextless" (file: string, line, column: i32,
    index, count: int) #no_bounds_check
{
    if index < count {
        return
    }
    cpu.halt_catch_fire()
}

multi_pointer_slice_expr_error :: proc "contextless" (file: string, line, column: i32,
    lo, hi: int) #no_bounds_check
{
    if lo >= 0 && hi >= 0 || lo <= hi {
        return
    }
    cpu.halt_catch_fire()
}

slice_expr_error_hi :: proc "contextless" (file: string, line, column: i32,
    hi: int, len: int) #no_bounds_check
{
    if hi < len {
        return
    }
    cpu.halt_catch_fire()
}

slice_expr_error_lo_hi :: proc "contextless" (file: string, line, column: i32,
    lo, hi: int, len: int) #no_bounds_check
{
    if lo >= 0 && lo <= hi && hi < len {
        return
    }
    cpu.halt_catch_fire()
}

dynamic_array_expr_error :: proc "contextless" (file: string, line, column: i32,
    lo, hi, len: int) #no_bounds_check
{
    if lo >= 0 && lo <= hi && hi < len {
        return
    }
    cpu.halt_catch_fire()
}

make_slice_error_loc :: proc "contextless" (loc := #caller_location, len: int) #no_bounds_check {
    cpu.halt_catch_fire()
}

make_dynamic_array_error_loc :: proc "contextless" (using loc := #caller_location, len, cap: int) #no_bounds_check {
    cpu.halt_catch_fire()
}

make_map_expr_error_loc :: proc "contextless" (loc := #caller_location, cap: int) #no_bounds_check {
    cpu.halt_catch_fire()
}
