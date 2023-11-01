/*
    The sole purpose of this file existing is to prevent compiler from segfaulting.
    I do not use RTTI in my kernel, but it's totally usable.
*/
package runtime

Calling_Convention :: enum u8 {
    Invalid     = 0,
    Odin        = 1,
    Contextless = 2,
    CDecl       = 3,
    Std_Call    = 4,
    Fast_Call   = 5,
    None        = 6,
    Naked       = 7,
    _           = 8,
    Win64       = 9,
    SysV        = 10,
}

Platform_Endianness :: enum u8 {
    Platform = 0,
    Little   = 1,
    Big      = 2,
}

Equal_Proc :: distinct proc "contextless" (rawptr, rawptr) -> bool
Hasher_Proc :: distinct proc "contextless" (data: rawptr, seed: uintptr = 0) -> uintptr

Type_Info_Struct_Soa_Kind :: enum u8 {
    None    = 0,
    Fixed   = 1,
    Slice   = 2,
    Dynamic = 3,
}

Type_Info_Named :: struct {
    name: string,
    base: ^Type_Info,
    pkg:  string,
    loc:  Source_Code_Location,
}

Type_Info_Integer    :: struct {signed: bool, endianness: Platform_Endianness}

Type_Info_Rune       :: struct {}

Type_Info_Float      :: struct {endianness: Platform_Endianness}

Type_Info_Complex    :: struct {}

Type_Info_Quaternion :: struct {}

Type_Info_String     :: struct {is_cstring: bool}

Type_Info_Boolean    :: struct {}

Type_Info_Any        :: struct {}

Type_Info_Type_Id    :: struct {}

Type_Info_Pointer :: struct {
    elem: ^Type_Info, // nil -> rawptr
}

Type_Info_Multi_Pointer :: struct {
    elem: ^Type_Info,
}

Type_Info_Procedure :: struct {
    params:     ^Type_Info, // Type_Info_Parameters
    results:    ^Type_Info, // Type_Info_Parameters
    variadic:   bool,
    convention: Calling_Convention,
}

Type_Info_Array :: struct {
    elem:      ^Type_Info,
    elem_size: int,
    count:     int,
}

Type_Info_Enum_Value :: distinct i64
Type_Info_Enumerated_Array :: struct {
    elem:      ^Type_Info,
    index:     ^Type_Info,
    elem_size: int,
    count:     int,
    min_value: Type_Info_Enum_Value,
    max_value: Type_Info_Enum_Value,
    is_sparse: bool,
}

Type_Info_Dynamic_Array :: struct {elem: ^Type_Info, elem_size: int}

Type_Info_Slice         :: struct {elem: ^Type_Info, elem_size: int}

Type_Info_Parameters :: struct {
    types:        []^Type_Info,
    names:        []string,
}

Type_Info_Tuple :: Type_Info_Parameters

Type_Info_Struct :: struct {
    types:        []^Type_Info,
    names:        []string,
    offsets:      []uintptr,
    usings:       []bool,
    tags:         []string,
    is_packed:    bool,
    is_raw_union: bool,
    is_no_copy:   bool,
    custom_align: bool,
    equal: Equal_Proc,
    soa_kind:      Type_Info_Struct_Soa_Kind,
    soa_base_type: ^Type_Info,
    soa_len:       int,
}

Type_Info_Union :: struct {
    variants:     []^Type_Info,
    tag_offset:   uintptr,
    tag_type:     ^Type_Info,

    equal: Equal_Proc,

    custom_align: bool,
    no_nil:       bool,
    shared_nil:   bool,
}

Type_Info_Enum :: struct {
    base:      ^Type_Info,
    names:     []string,
    values:    []Type_Info_Enum_Value,
}

Type_Info_Map :: struct {
    key:      ^Type_Info,
    value:    ^Type_Info,
    map_info: ^Map_Info,
}

Map_Hash :: uintptr

Map_Info :: struct {
    ks: ^Map_Cell_Info,
    vs: ^Map_Cell_Info,
    key_hasher: proc "contextless" (key: rawptr, seed: Map_Hash) -> Map_Hash,
    key_equal:  proc "contextless" (lhs, rhs: rawptr) -> bool,
}

Map_Cell_Info :: struct {
    size_of_type:      uintptr,
    align_of_type:     uintptr,
    size_of_cell:      uintptr,
    elements_per_cell: uintptr,
}

Type_Info_Bit_Set :: struct {
    elem:       ^Type_Info,
    underlying: ^Type_Info,
    lower:      i64,
    upper:      i64,
}

Type_Info_Simd_Vector :: struct {
    elem:       ^Type_Info,
    elem_size:  int,
    count:      int,
}

Type_Info_Relative_Pointer :: struct {
    pointer:      ^Type_Info,
    base_integer: ^Type_Info,
}

Type_Info_Relative_Multi_Pointer :: struct {
    pointer:      ^Type_Info,
    base_integer: ^Type_Info,
}

Type_Info_Matrix :: struct {
    elem:         ^Type_Info,
    elem_size:    int,
    elem_stride:  int,
    row_count:    int,
    column_count: int,
}

Type_Info_Soa_Pointer :: struct {
    elem: ^Type_Info,
}

Type_Info_Flags :: distinct bit_set[Type_Info_Flag; u32]
Type_Info_Flag :: enum u8 {
    Comparable     = 0,
    Simple_Compare = 1,
}

Type_Info :: struct {
    size:  int,
    align: int,
    flags: Type_Info_Flags,
    id:    typeid,
    variant: union {
        Type_Info_Named,
        Type_Info_Integer,
        Type_Info_Rune,
        Type_Info_Float,
        Type_Info_Complex,
        Type_Info_Quaternion,
        Type_Info_String,
        Type_Info_Boolean,
        Type_Info_Any,
        Type_Info_Type_Id,
        Type_Info_Pointer,
        Type_Info_Multi_Pointer,
        Type_Info_Procedure,
        Type_Info_Array,
        Type_Info_Enumerated_Array,
        Type_Info_Dynamic_Array,
        Type_Info_Slice,
        Type_Info_Parameters,
        Type_Info_Struct,
        Type_Info_Union,
        Type_Info_Enum,
        Type_Info_Map,
        Type_Info_Bit_Set,
        Type_Info_Simd_Vector,
        Type_Info_Relative_Pointer,
        Type_Info_Relative_Multi_Pointer,
        Type_Info_Matrix,
        Type_Info_Soa_Pointer,
    },
}

Typeid_Kind :: enum u8 {
    Invalid,
    Integer,
    Rune,
    Float,
    Complex,
    Quaternion,
    String,
    Boolean,
    Any,
    Type_Id,
    Pointer,
    Multi_Pointer,
    Procedure,
    Array,
    Enumerated_Array,
    Dynamic_Array,
    Slice,
    Tuple,
    Struct,
    Union,
    Enum,
    Map,
    Bit_Set,
    Simd_Vector,
    Relative_Pointer,
    Relative_Multi_Pointer,
    Matrix,
    Soa_Pointer,
}

type_table: []Type_Info

__type_info_of :: proc "contextless" (id: typeid) -> ^Type_Info #no_bounds_check {
    MASK :: 1<<(8*size_of(typeid) - 8) - 1
    data := transmute(uintptr)id
    n := int(data & MASK)
    if n < 0 || n >= len(type_table) {
        n = 0
    }
    return &type_table[n]
}
