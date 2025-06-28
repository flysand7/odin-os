
package runtime

Source_Code_Location :: struct {
    file_path: string,
    line:      i32,
    column:    i32,
    procedure: string,
}

Context :: struct {
    allocator:              Allocator,
    temp_allocator:         Allocator,
    assertion_failure_proc: Assertion_Failure_Proc,
    logger:                 Logger,
    user_ptr:               rawptr,
    user_index:             int,
    _internal:              rawptr,
}

Assertion_Failure_Proc :: #type proc(prefix, message: string, loc: Source_Code_Location) -> !

Logger_Proc :: #type proc(
    ctx: rawptr,
    level: Logger_Level,
    text: string,
    options: Logger_Options,
    location := #caller_location)

Allocator_Proc :: #type proc(
    ctx: rawptr,
    mode: Allocator_Mode,
    size: int,
    align: int,
    old_addr: rawptr,
    old_size: int,
    loc := #caller_location) -> ([]byte, Allocator_Error)

Allocator :: struct {
    procedure:    Allocator_Proc,
    data:         rawptr,
}

Logger :: struct {
    procedure:    Logger_Proc,
    data:         rawptr,
    lowest_level: Logger_Level,
    options:      Logger_Options,
}

Allocator_Mode :: enum byte {
    Alloc,
    Free,
    Free_All,
    Resize,
    Query_Features,
    Query_Info,
    Alloc_Non_Zeroed,
}

Allocator_Mode_Set :: distinct bit_set[Allocator_Mode]

Allocator_Query_Info :: struct {
    pointer:   rawptr,
    size:      Maybe(int),
    alignment: Maybe(int),
}

Allocator_Error :: enum byte {
    None                 = 0,
    Out_Of_Memory        = 1,
    Invalid_Pointer      = 2,
    Invalid_Argument     = 3,
    Mode_Not_Implemented = 4,
}

Logger_Level :: enum uint {
    Debug   = 0,
    Info    = 10,
    Warning = 20,
    Error   = 30,
    Fatal   = 40,
}

Logger_Options :: bit_set[Logger_Option]
Logger_Option :: enum {
    Level,
    Date,
    Time,
    Short_File_Path,
    Long_File_Path,
    Line,
    Procedure,
    Terminal_Color,
    Thread_Id,
}

foreign {
    @(link_name="__$startup_runtime") rt_startup :: proc "odin" () ---
    @(link_name="__$cleanup_runtime") rt_cleanup :: proc "odin" () ---
}

@(private)
__init_context :: proc "contextless" (c: ^Context) {
    return
}
