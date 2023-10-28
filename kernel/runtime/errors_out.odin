
// Implements the console output functions for kernel runtime
// The basic idea is that throughout the execution different output buffers become available
// so we'll need to unify the errors from those different sources and provide an abstraction
// the bounds checking and assert routines can call into and make sure the errors arive to the user
// in one form or another.
package rt

import "kernel:stream"

// TODO(flysand): Synchronization on error streams
g_error_stream: stream.IO_Stream

set_error_stream :: proc "contextless" (new_stream: stream.IO_Stream) {
    g_error_stream = new_stream
}
