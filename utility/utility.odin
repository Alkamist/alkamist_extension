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

get_line :: proc(ctx: ^reaper.ProjectStateContext, backing_buffer: []byte) -> (result: string, ok: bool) {
    if reaper.ProjectStateContext_GetLine(ctx, &backing_buffer[0], i32(len(backing_buffer))) != 0 {
        return "", false
    }

    if backing_buffer[0] == '>' {
        return "", false
    }

    return strings.trim_null(cast(string)backing_buffer[:]), true
}

add_line :: proc(ctx: ^reaper.ProjectStateContext, format: string, args: ..any) {
    position := fmt.aprintf(format, ..args)
    defer delete(position)

    position_cstring := strings.clone_to_cstring(position)
    defer delete(position_cstring)

    reaper.ProjectStateContext_AddLine(ctx, position_cstring)
}