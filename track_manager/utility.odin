package track_manager

import "../../gui"
import "../../reaper"

track_is_visible :: proc(track: ^reaper.MediaTrack) -> bool {
    return reaper.GetMediaTrackInfo_Value(track, "B_SHOWINMIXER") == 1 &&
           reaper.GetMediaTrackInfo_Value(track, "B_SHOWINTCP") == 1
}

set_track_visible :: proc(track: ^reaper.MediaTrack, visible: bool) {
    reaper.SetMediaTrackInfo_Value(track, "B_SHOWINMIXER", visible ? 1 : 0)
    reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", visible ? 1 : 0)
    reaper.TrackList_AdjustWindows(false)
}

draw_minus :: proc(position, size: Vec2, thickness: f32, color: Color) {
    if size.x <= 0 || size.y <= 0 {
        return
    }

    pixel := gui.pixel_distance()
    position := gui.pixel_align(position)
    size := gui.quantize(size, pixel * 2.0) + pixel

    half_size := size * 0.5

    gui.begin_path()

    gui.path_move_to(position + {0, half_size.y})
    gui.path_line_to(position + {size.x, half_size.y})

    gui.stroke_path(color, thickness)
}

draw_plus :: proc(position, size: Vec2, thickness: f32, color: Color) {
    if size.x <= 0 || size.y <= 0 {
        return
    }

    pixel := gui.pixel_distance()
    position := gui.pixel_align(position)
    size := gui.quantize(size, pixel * 2.0) + pixel

    half_size := size * 0.5

    gui.begin_path()

    gui.path_move_to(position + {0, half_size.y})
    gui.path_line_to(position + {size.x, half_size.y})

    gui.path_move_to(position + {half_size.x, 0})
    gui.path_line_to(position + {half_size.x, size.y})

    gui.stroke_path(color, thickness)
}