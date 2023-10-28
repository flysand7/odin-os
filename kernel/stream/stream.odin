
// This package is used to provide an abstract stream operations on various kernel objects -- IO ports, files,
// and other. Some of the streams can be used for error handling in the `runtime` package.
package stream

import "core:intrinsics"
import "core:runtime"

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
    count := 0
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
        count += 1
        buffer[index] = digit_ch
        if number == 0 {
            break
        }
    }
    // Hex is going to be padded, because I said so
    if base == 16 {
        desired_width := size_of(T) * 8 / 4
        for count < desired_width {
            index -= 1
            count += 1
            buffer[index] = u8('0')
        }
    }
    if is_negative && base != 16 {
        index -= 1
        buffer[index] = '-'
    }
    write_buf(stream, buffer[index:])
}

write_str :: proc(stream: ^IO_Stream, str: string) #no_bounds_check {
    write_buf(stream, transmute([]u8) str)
}

write_any_as :: proc(stream: ^IO_Stream, arg: any, as: u8) #no_bounds_check {
    type_id   := runtime.typeid_base(arg.id)
    type_info := type_info_of(type_id)
    #partial switch variant in type_info.variant {
    case runtime.Type_Info_Boolean:
        bool_value := (^bool)(arg.data)^
        if bool_value {
            write_str(stream, "true")
        } else {
            write_str(stream, "false")
        }
        return
    case runtime.Type_Info_Integer:
        break
    case runtime.Type_Info_Pointer:
        ptr := (^uintptr)(arg.data)^
        write_int(stream, ptr, 16)
        return
    case runtime.Type_Info_Multi_Pointer:
        ptr := (^uintptr)(arg.data)^
        write_int(stream, ptr, 16)
        return
    case runtime.Type_Info_String:
        str := (^string)(arg.data)^
        write_str(stream, str)
        return
    }
    // Integer types are handled separately
    base := u8(10)
    if as == 'x' {
        base = 16
    } else if as == 'b' {
        base = 2
    }
    switch a in arg {
    case i8:        write_int(stream, cast(i8) a,      base)
    case u8:        write_int(stream, cast(u8) a,      base)
    case i16:       write_int(stream, cast(i16) a,     base)
    case u16:       write_int(stream, cast(u16) a,     base)
    case i32:       write_int(stream, cast(i32) a,     base)
    case u32:       write_int(stream, cast(u32) a,     base)
    case i64:       write_int(stream, cast(i64) a,     base)
    case u64:       write_int(stream, cast(u64) a,      base)
    case int:       write_int(stream, cast(int) a,     base)
    case uint:      write_int(stream, cast(uint) a,    base)
    case uintptr:   write_int(stream, cast(uintptr) a, base)
    case i16le:     write_int(stream, cast(i16le) a,   base)
    case u16le:     write_int(stream, cast(u16le) a,   base)
    case i32le:     write_int(stream, cast(i32le) a,   base)
    case u32le:     write_int(stream, cast(u32le) a,   base)
    case i64le:     write_int(stream, cast(i64le) a,   base)
    case u64le:     write_int(stream, cast(u64le) a,   base)
    case i16be:     write_int(stream, cast(i16be) a,   base)
    case u16be:     write_int(stream, cast(u16be) a,   base)
    case i32be:     write_int(stream, cast(i32be) a,   base)
    case u32be:     write_int(stream, cast(u32be) a,   base)
    case i64be:     write_int(stream, cast(i64be) a,   base)
    case u64be:     write_int(stream, cast(u64be) a,   base)
    }
}

// Formats upto 10 arguments of arbitrary primitive type
write_fmt :: proc(stream: ^IO_Stream, fmt: string, args: ..any) #no_bounds_check {
    start_index := 0
    for index := 0; index < len(fmt); {
        if fmt[index] == '{' {
            // Write everything up until now
            write_str(stream, fmt[start_index:index])
            // Get the argument and the closing paren
            arg_num := fmt[index+1]-'0'
            cls_chr := fmt[index+2]
            fmt_chr := u8(0)
            if cls_chr != '}' {
                fmt_chr = cls_chr
                index += 4
            } else {
                index += 3
            }
            write_any_as(stream, args[arg_num], fmt_chr)
            // Reset the starting index to current index
            start_index = index
            continue
        }
        index += 1
    }
    write_str(stream, fmt[start_index:len(fmt)])
}
