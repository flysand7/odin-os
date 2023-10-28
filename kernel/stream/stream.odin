
// This package is used to provide an abstract stream operations on various kernel objects -- IO ports, files,
// and other. Some of the streams can be used for error handling in the `runtime` package.
package stream

import "core:intrinsics"

Flags_Bits :: enum {
    Read,
    Write,
    Blocking,
}

Flags :: bit_set[Flags_Bits; u8]

IO_Stream_Read_Proc :: #type proc(stream: ^IO_Stream, buf: []u8)
IO_Stream_Write_Proc :: #type proc(stream: ^IO_Stream, buf: []u8)

IO_Stream :: struct {
    flags:   Flags,
    write:   IO_Stream_Write_Proc,
    read:    IO_Stream_Read_Proc,
    payload: rawptr,
}

read_buf :: proc(stream: ^IO_Stream, buf: []u8) {
    stream.read(stream, buf)
}

write_buf :: proc(stream: ^IO_Stream, buf: []u8) {
    stream.write(stream, buf)
}

write_int :: proc(stream: ^IO_Stream, number: $T, base: u8 = 10)
where
    intrinsics.type_is_integer(T) #no_bounds_check
{
    number := number
    buffer: [64]u8
    is_negative := false
    if number < 0 {
        is_negative = true
        number = -number
    }
    index := len(buffer)
    for {
        digit := number % cast(T) base
        number /= cast(T) base
        digit_ch: u8
        if digit < 10 {
            digit_ch = cast(u8) (digit + T('0'))
        } else {
            digit_ch = cast(u8) (digit - 10 + T('a'))
        }
        index -= 1
        buffer[index] = digit_ch
        if number == 0 {
            break
        }
    }
    if is_negative {
        index -= 1
        buffer[index] = '-'
    }
    write_buf(stream, buffer[index:])
}

write_str :: proc(stream: ^IO_Stream, str: string) #no_bounds_check {
    write_buf(stream, transmute([]u8) str)
}
