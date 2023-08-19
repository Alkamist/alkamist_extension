package utility

import "core:fmt"
import "core:strings"
import "../../reaper"

save_requested := false

save_project :: proc() {
    save_requested = true
}

debug :: proc(format: string, args: ..any) {
    msg := fmt.aprintf(format, ..args)
    defer delete(msg)

    msg_with_newline := strings.concatenate({msg, "\n"})
    defer delete(msg_with_newline)

    msg_cstring := strings.clone_to_cstring(msg_with_newline)
    defer delete(msg_cstring)

    reaper.ShowConsoleMsg(msg_cstring)
}