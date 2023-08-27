package track_manager

import "core:fmt"
import "core:math"
import "core:strings"
import "core:strconv"
import "../shared"
import "../../gui"
import "../../gui/widgets"
import "../../reaper"

Vec2 :: gui.Vec2
Rect :: gui.Rect
Color :: gui.Color

debug :: shared.debug
add_line :: shared.add_line
add_linef :: shared.add_linef
get_line :: shared.get_line
save_project :: shared.save_project
load_tracks_from_guid_strings :: shared.load_tracks_from_guid_strings
Project_State_Parser :: shared.Project_State_Parser
make_project_state_parser :: shared.make_project_state_parser
is_empty_line :: shared.is_empty_line
advance_line :: shared.advance_line
get_string_field :: shared.get_string_field
get_f32_field :: shared.get_f32_field
get_int_field :: shared.get_int_field
get_vec2_field :: shared.get_vec2_field
keep_if :: shared.keep_if
format_f32_for_storage :: shared.format_f32_for_storage

fill_rounded_rect :: widgets.fill_rounded_rect
outline_rounded_rect :: widgets.outline_rounded_rect
fill_rect :: widgets.fill_rect
outline_rect :: widgets.outline_rect
fill_circle :: widgets.fill_circle

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