package track_manager

import "core:fmt"
import "core:math"
import "core:strings"
import "../../gui"
import "../../reaper"

debug :: proc(format: string, args: ..any) {
    msg := fmt.aprintf(format, ..args)
    defer delete(msg)

    msg_with_newline := strings.concatenate({msg, "\n"})
    defer delete(msg_with_newline)

    msg_cstring := strings.clone_to_cstring(msg_with_newline)
    defer delete(msg_cstring)

    reaper.ShowConsoleMsg(msg_cstring)
}

distance :: proc(a, b: Vec2) -> f32 {
    return math.sqrt(math.pow((b.x - a.x), 2) + math.pow((b.y - a.y), 2))
}

track_is_visible :: proc(track: ^reaper.MediaTrack) -> bool {
    return reaper.GetMediaTrackInfo_Value(track, "B_SHOWINMIXER") == 1 &&
           reaper.GetMediaTrackInfo_Value(track, "B_SHOWINTCP") == 1
}

set_track_visible :: proc(track: ^reaper.MediaTrack, visible: bool) {
    reaper.SetMediaTrackInfo_Value(track, "B_SHOWINMIXER", visible ? 1 : 0)
    reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", visible ? 1 : 0)
    reaper.TrackList_AdjustWindows(false)
}

fill_rounded_rect :: proc(position, size: Vec2, rounding: f32, color: Color) {
    gui.begin_path()
    gui.path_rounded_rect(position, size, rounding)
    gui.fill_path(color)
}

outline_rounded_rect :: proc(position, size: Vec2, rounding: f32, color: Color) {
    pixel := gui.pixel_distance()
    gui.begin_path()
    gui.path_rounded_rect(position + pixel * 0.5, size - pixel, rounding)
    gui.stroke_path(color, 1)
}

fill_rect :: proc(position, size: Vec2, color: Color) {
    gui.begin_path()
    gui.path_rect(position, size)
    gui.fill_path(color)
}

outline_rect :: proc(position, size: Vec2, color: Color) {
    pixel := gui.pixel_distance()
    gui.begin_path()
    gui.path_rect(position + pixel * 0.5, size - pixel)
    gui.stroke_path(color, 1)
}

fill_circle :: proc(center: Vec2, radius: f32, color: Color) {
    gui.begin_path()
    gui.path_circle(center, radius)
    gui.fill_path(color)
}

// draw_minus :: proc(position, size: Vec2, thickness: f32, color: Color) {
//     if size.x <= 0 || size.y <= 0 {
//         return
//     }

//     pixel := gui.pixel_distance()
//     position := gui.pixel_align(position)
//     size := gui.quantize(size, pixel * 2.0) + pixel

//     half_size := size * 0.5

//     gui.begin_path()

//     gui.path_move_to(position + {0, half_size.y})
//     gui.path_line_to(position + {size.x, half_size.y})

//     gui.stroke_path(color, thickness)
// }

// draw_plus :: proc(position, size: Vec2, thickness: f32, color: Color) {
//     if size.x <= 0 || size.y <= 0 {
//         return
//     }

//     pixel := gui.pixel_distance()
//     position := gui.pixel_align(position)
//     size := gui.quantize(size, pixel * 2.0) + pixel

//     half_size := size * 0.5

//     gui.begin_path()

//     gui.path_move_to(position + {0, half_size.y})
//     gui.path_line_to(position + {size.x, half_size.y})

//     gui.path_move_to(position + {half_size.x, 0})
//     gui.path_line_to(position + {half_size.x, size.y})

//     gui.stroke_path(color, thickness)
// }