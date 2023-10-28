
package rt

import "kernel:stream"

Log_Level :: enum {
    OFF,
    DEBUG,
    INFO,
    WARNING,
    ERROR,
    FATAL,
}

Logger :: struct {
    level: Log_Level,
    output: stream.IO_Stream,
}


