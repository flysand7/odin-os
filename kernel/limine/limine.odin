
// Bindings related to Limine boot protocol.
// Docs:   https://github.com/limine-bootloader/limine/blob/v3.0-branch/PROTOCOL.md
// Source: https://github.com/limine-bootloader/limine/blob/v3.0-branch/limine.h

package limine

COMMON_MAGIC_1 :: 0xc7b1dd30df4c8b88
COMMON_MAGIC_2 :: 0x0a82e883a194f07b

UUID :: struct {
    a: u32,
    b: u16,
    c: u16,
    d: [8]u8,
}

Media_Type :: enum u32 {
    GENERIC = 0,
    OPTICAL = 1,
    TFTP    = 2,
}

File :: struct {
    revision:        u64,
    address:         rawptr,
    size:            u64,
    path:            [^]u8,
    cmdline:         [^]u8,
    media_type:      Media_Type,
    unused:          u32,
    tftp_ip:         u32,
    tftp_port:       u32,
    partition_index: u32,
    mbr_disk_id:     u32,
    gpt_disk_uuid:   UUID,
    gpt_part_uuid:   UUID,
    part_uuid:       UUID,
}

/* Boot info */

BOOTLOADER_INFO_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0xf55038d8e2a1202f,
    0x279426fcf5f59740,
}

Bootloader_Info_Response :: struct {
    revision: u64,
    name:     [^]u8,
    version:  [^]u8,
}

Bootloader_Info_Request :: struct {
    id:       [4]u64,
    revision: u64,
    response: ^Bootloader_Info_Response,
}

/* Stack size */

STACK_SIZE_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x224ef0460a8e8926,
    0xe1cb0fc25f46ea3d,
}

Stack_Size_Response :: struct {
    revision: u64,
}

Stack_Size_Request :: struct {
    id:         [4]u64,
    revision:   u64,
    response:   ^Stack_Size_Response,
    stack_size: u64,
}

/* HHDM */

HHDM_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x48dcf1cb8ad2b852,
    0x63984e959a98244b,
}

HHDM_Response :: struct {
    revision: u64,
    offset:   u64,
}

HHDM_Request :: struct {
    id:       [4]u64,
    revision: u64,
    response: ^HHDM_Response,
}

/* Framebuffer */

FRAMEBUFFER_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x9d5827dcd881dd75,
    0xa3148604f6fab11b,
}

FRAMEBUFFER_RGB :: u8(1)

Video_Mode :: struct {
    pitch:            u64,
    width:            u64,
    height:           u64,
    bpp:              u16,
    memory_model:     u8,
    red_mask_size:    u8,
    red_mask_shift:   u8,
    green_mask_size:  u8,
    green_mask_shift: u8,
    blue_mask_size:   u8,
    blue_mask_shift:  u8,
}

Framebuffer :: struct {
    address:          rawptr,
    width:            u64,
    height:           u64,
    pitch:            u64,
    bpp:              u16,
    memory_model:     u8,
    red_mask_size:    u8,
    red_mask_shift:   u8,
    green_mask_size:  u8,
    green_mask_shift: u8,
    blue_mask_size:   u8,
    blue_mask_shift:  u8,
    unused:           [7]u8,
    edid_size:        u64,
    edid:             rawptr,
    /* Response revision 1 */
    mode_count:       u64,
    modes:            [^]^Video_Mode,
}

Framebuffer_Response :: struct {
    revision:          u64,
    framebuffer_count: u64,
    framebuffers:      [^]^Framebuffer,
}

Framebuffer_Request :: struct {
    id:       [4]u64,
    revision: u64,
    response: ^Framebuffer_Response,
}

/* Terminal */

TERMINAL_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0xc8ac59310c2b0844,
    0xa68d0c7265d38878,
}

Terminal_Cb_Type :: enum u64 {
    Cb_Dec            = 10,
    Cb_Bell           = 20,
    Cb_Private_Id     = 30,
    Cb_Status_Report  = 40,
    Cb_Pos_Report     = 50,
    Cb_Kbd_Leds       = 60,
    Cb_Mode           = 70,
    Cb_Linux          = 80,
}

TERMINAL_CTX_SIZE          :: transmute(u64)i64(-1)
TERMINAL_CTX_SAVE          :: transmute(u64)i64(-2)
TERMINAL_CTX_RESTORE       :: transmute(u64)i64(-3)
TERMINAL_FULL_REFRESH      :: transmute(u64)i64(-4)

/* Response revision 1 */
TERMINAL_OOB_OUTPUT_GET    :: transmute(u64)i64(-10)
TERMINAL_OOB_OUTPUT_SET    :: transmute(u64)i64(-11)

TERMINAL_OOB_OUTPUT_OCRNL  :: (1 << 0)
TERMINAL_OOB_OUTPUT_OFDEL  :: (1 << 1)
TERMINAL_OOB_OUTPUT_OFILL  :: (1 << 2)
TERMINAL_OOB_OUTPUT_OLCUC  :: (1 << 3)
TERMINAL_OOB_OUTPUT_ONLCR  :: (1 << 4)
TERMINAL_OOB_OUTPUT_ONLRET :: (1 << 5)
TERMINAL_OOB_OUTPUT_ONOCR  :: (1 << 6)
TERMINAL_OOB_OUTPUT_OPOST  :: (1 << 7)

Terminal_Write :: #type proc "sysv" (term: ^Terminal, str: [^]u8, len: u64)
Terminal_Callback :: #type proc "sysv" (term: ^Terminal, type: u64, arg1, arg2, arg3: u64)

Terminal :: struct {
    columns:     u64,
    rows:        u64,
    framebuffer: ^Framebuffer,
}

Terminal_Response :: struct {
    revision:       u64,
    terminal_count: u64,
    terminals:      [^]^Terminal,
    write:          Terminal_Write,
}

Terminal_Request :: struct {
    id:       [4]u64,
    revision: u64,
    response: ^Terminal_Response,
    callback: Terminal_Callback,
}

/* 5-level paging */

L5_PAGING_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x94469551da9b3192,
    0xebe5e86db7382888,
}

L5_Paging_Response :: struct {
    revision: u64,
}

L5_Paging_Request :: struct {
    id:       [4]u64,
    revision: u64,
    response: ^L5_Paging_Response,
}

/* SMP */

SMP_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x95a67b819a1b857e,
    0xa0b61b723b6a73e0,
}

Goto_Address :: #type proc "sysv" (smp_info: ^SMP_Info)

SMP_X2APIC :: (1 << 0)

SMP_Info :: struct {
    processor_id:   u32,
    lapic_id:       u32,
    reserved:       u64,
    goto_address:   Goto_Address,
    extra_argument: u64,
}

SMP_Response :: struct {
    revision:     u64,
    flags:        u32,
    bsp_lapic_id: u32,
    cpu_count:    u64,
    cpus:         ^^SMP_Info,
}

// #elif defined (__aarch64__)
// struct smp_info {
//     uint32_t processor_id;
//     uint32_t gic_iface_no;
//     uint64_t mpidr;
//     uint64_t reserved;
//     PTR(goto_address) goto_address;
//     uint64_t extra_argument;
// };
// struct smp_response {
//     uint64_t revision;
//     uint32_t flags;
//     uint64_t bsp_mpidr;
//     uint64_t cpu_count;
//     PTR(struct smp_info **) cpus;
// };
// #endif

SMP_Request :: struct {
    id: [4]u64,
    revision: u64,
    response: ^SMP_Response,
    flags: u64,
}

/* Memory map */

MEMMAP_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x67cf3d9d378a806f,
    0xe304acdfc50c3c62,
}

Memmap_Type :: enum u64 {
    Usable                 = 0,
    Reserved               = 1,
    Acpi_Reclaimable       = 2,
    Acpi_Nvs               = 3,
    Bad_Memory             = 4,
    Bootloader_Reclaimable = 5,
    Kernel_And_Modules     = 6,
    Framebuffer            = 7,
}

Memmap_Entry :: struct {
    base:   u64,
    length: u64,
    type:   u64,
}

Memmap_Response :: struct {
    revision:    u64,
    entry_count: u64,
    entries:     [^]^Memmap_Entry,
}

Memmap_Request :: struct {
    id:       [4]u64,
    revision: u64,
    response: ^Memmap_Response,
}

/* Entry point */

ENTRY_POINT_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x13d86c035a1cd3e1,
    0x2b0caa89d8f3026a,
}

Entry_Point :: #type proc "sysv" ()

 Entry_Point_Response :: struct {
    revision: u64,
}

Entry_Point_Request :: struct {
    id: [4]u64,
    revision: u64,
    response: ^Entry_Point_Response,
    entry: Entry_Point,
}

/* Kernel File */

KERNEL_FILE_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0xad97e90e83f1ed67,
    0x31eb5d1c5ff23b69,
}

Kernel_File_Response :: struct {
    revision: u64,
    kernel_file: ^File,
}

Kernel_File_Request :: struct {
    id: [4]u64,
    revision: u64,
    response: ^Kernel_File_Response,
}

/* Module */

MODULE_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x3e7e279702be32af,
    0xca1c4f3bd1280cee,
}

Module_Response :: struct {
    revision: u64,
    module_count: u64,
    modules: ^^File,
}

Module_Request :: struct {
    id: [4]u64,
    revision: u64,
    response: ^Module_Response,
}

/* RSDP */

RSDP_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0xc5e77b6b397e7b43,
    0x27637845accdcf3c,
}

RSDP_Response :: struct {
    revision: u64,
    address: rawptr,
}

RSDP_Request :: struct {
    id: [4]u64,
    revision: u64,
    response: ^RSDP_Response,
}

/* SMBIOS */

SMBIOS_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x9e9046f11e095391,
    0xaa4a520fefbde5ee,
}

SMBIOS_Response :: struct {
    revision: u64,
    entry_32: rawptr,
    entry_64: rawptr,
}

SMBIOS_Request :: struct {
    id: [4]u64,
    revision: u64,
    response: ^SMBIOS_Response,
}

/* EFI system table */

EFI_SYSTEM_TABLE_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x5ceba5163eaaf6d6,
    0x0a6981610cf65fcc,
}

EFI_System_Table_Response :: struct {
    revision: u64,
    address: rawptr,
}

EFI_System_Table_Request :: struct {
    id: [4]u64,
    revision: u64,
    response: ^EFI_System_Table_Response,
}

/* Boot time */

BOOT_TIME_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x502746e184c088aa,
    0xfbc5ec83e6327893,
}

Boot_Time_Response :: struct {
    revision: u64,
    boot_time: i64,
}

Boot_Time_Request :: struct {
    id: [4]u64,
    revision: u64,
    response: ^Boot_Time_Response,
}

/* Kernel address */

KERNEL_ADDRESS_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0x71ba76863cc55f63,
    0xb2644a48c516a487,
}

Kernel_Address_Response :: struct {
    revision: u64,
    physical_base: u64,
    virtual_base: u64,
}

Kernel_Address_Request :: struct {
    id: [4]u64,
    revision: u64,
    response: ^Kernel_Address_Response,
}

/* Device Tree Blob */

DTB_REQUEST :: [4]u64{
    COMMON_MAGIC_1,
    COMMON_MAGIC_2,
    0xb40ddb48fb54bac7,
    0x545081493f81ffb7,
}

DTB_Response :: struct {
    revision: u64,
    dtb_ptr: rawptr,
}

DTB_Request :: struct {
    id: [4]u64,
    revision: u64,
    response: ^DTB_Response,
}
