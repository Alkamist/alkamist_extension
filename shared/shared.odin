package shared

import "core:fmt"
import "core:mem"
import "core:slice"
import "core:strings"
import "core:runtime"
import "../../gui"
import "../../reaper"

Vec2 :: gui.Vec2

plugin_info: ^reaper.plugin_info_t

main_context: runtime.Context
consola := gui.Font{"Consola", #load("../consola.ttf")}
save_requested := false

save_project :: proc() {
    save_requested = true
}

debug :: proc(format: string, args: ..any) {
    msg := fmt.tprintf(format, ..args)
    msg_with_newline := strings.concatenate({strings.trim_null(cast(string)msg[:]), "\n"}, context.temp_allocator)
    reaper.ShowConsoleMsg(strings.clone_to_cstring(msg_with_newline, context.temp_allocator))
}

load_tracks_from_guid_strings :: proc(tracks: ^[dynamic]^reaper.MediaTrack, project: ^reaper.ReaProject, guid_strings: []string) {
    guids := make([dynamic]reaper.GUID, context.temp_allocator)

    for guid_string in guid_strings {
        guid_cstring := strings.clone_to_cstring(guid_string, context.temp_allocator)

        guid: reaper.GUID
        reaper.stringToGuid(guid_cstring, &guid)

        append(&guids, guid)
    }

    for i in 0 ..< reaper.CountTracks(project) {
        track := reaper.GetTrack(project, i)
        track_guid := reaper.GetTrackGUID(track)

        if track_guid == nil do continue

        if !slice.contains(tracks[:], track) && slice.contains(guids[:], track_guid^) {
            append(tracks, track)
        }
    }
}

format_f32_for_storage :: proc(value: f32) -> string {
    value_string := fmt.tprintf("%f", value)
    no_zeros := strings.trim_right(value_string, "0")
    no_dot := strings.trim_right(no_zeros, ".")
    return no_dot
}

keep_if :: proc{
    keep_if_no_user_data,
    keep_if_user_data,
}

keep_if_no_user_data :: proc(array: ^[dynamic]$T, should_keep: proc(x: T) -> bool) {
    keep_position := 0

    for i in 0 ..< len(array) {
        if should_keep(array[i]) {
            if keep_position != i {
                array[keep_position] = array[i]
            }
            keep_position += 1
        }
    }

    resize(array, keep_position)
}

keep_if_user_data :: proc(array: ^[dynamic]$T, user_data: $D, should_keep: proc(x: T, user_data: D) -> bool) {
    keep_position := 0

    for i in 0 ..< len(array) {
        if should_keep(array[i], user_data) {
            if keep_position != i {
                array[keep_position] = array[i]
            }
            keep_position += 1
        }
    }

    resize(array, keep_position)
}