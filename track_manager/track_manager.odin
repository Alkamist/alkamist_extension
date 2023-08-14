package test_action

import "core:fmt"
import "core:math"
import "core:slice"
import "../../gui"
import "../../gui/widgets"
import "../../reaper"


Vec2 :: gui.Vec2
Color :: gui.Color

SPACING :: Vec2{5, 5}
PADDING :: Vec2{5, 5}
GROUP_HEIGHT :: 24.0

consola := gui.Font{"Consola", #load("../consola.ttf")}
window: gui.Window
track_manager: Track_Manager

on_frame :: proc() {
    update_track_manager(&track_manager)
}

init :: proc() {
    gui.init_window(
        &window,
        title = "Track Manager",
        position = {200, 200},
        background_color = _color(0.2),
        default_font = &consola,
        child_kind = .Transient,
        on_frame = on_frame,
    )

    _add_new_track_group(&track_manager, "Verse")
    _add_new_track_group(&track_manager, "Chorus")
    _add_new_track_group(&track_manager, "Vocals")
    _add_new_track_group(&track_manager, "Drums")
    _add_new_track_group(&track_manager, "Guitars")
}

run :: proc() {
    if gui.window_is_open(&window) {
        gui.close_window()
        return
    }

    gui.set_window_parent(&window, reaper.window_handle())
    gui.open_window(&window)
}

Track_Group :: struct {
    track_manager: ^Track_Manager,
    name: string,
    tracks: [dynamic]^reaper.MediaTrack,
    position: Vec2,
    size: Vec2,
    is_visible: bool,
    visibility_button: widgets.Button,
    add_selection_button: widgets.Button,
    remove_selection_button: widgets.Button,

    _x_placement: f32,
}

// destroy_track_group :: proc(group: ^Track_Group) {
//     delete(group.name)
//     delete(group.tracks)
//     free(group)
// }

Track_Manager :: struct {
    project: ^reaper.ReaProject,
    selected_tracks: [dynamic]^reaper.MediaTrack,
    groups: [dynamic]^Track_Group,
}

// destroy_track_manager :: proc(manager: ^Track_Manager) {
//     delete(manager.selected_tracks)

//     for group in manager.groups {
//         destroy_track_group(group)
//     }
//     delete(manager.groups)
// }

update_track_manager :: proc(manager: ^Track_Manager) {
    reaper.PreventUIRefresh(1)

    _update_selected_tracks(manager)

    window_size := gui.window_size(&window)
    group_position := PADDING
    group_size := Vec2{window_size.x - group_position.x * 2, GROUP_HEIGHT}

    for group in manager.groups {
        group.position = group_position
        group.size = group_size
        _update_track_group(group)
        group_position.y += group_size.y + SPACING.y
    }

    _update_track_visibility(manager)

    reaper.PreventUIRefresh(-1)
}



_update_track_visibility :: proc(manager: ^Track_Manager) {
    tracks: [dynamic]^reaper.MediaTrack
    defer delete(tracks)

    for group in manager.groups {
        for track in group.tracks {
            if !slice.contains(tracks[:], track) {
                append(&tracks, track)
            }
        }
    }

    for track in tracks {
        track_should_be_visible := false

        for group in manager.groups {
            if group.is_visible && slice.contains(group.tracks[:], track) {
                track_should_be_visible = true
            }
        }

        track_is_visible := _track_is_visible(track)

        if track_should_be_visible && !track_is_visible {
            _set_track_visible(track, true)
        } else if !track_should_be_visible && track_is_visible {
            _set_track_visible(track, false)
        }
    }
}

_update_group_name :: proc(group: ^Track_Group) {
    ascender, descender, line_height := gui.text_metrics()
    y := (group.size.y - line_height - descender) * 0.5
    gui.fill_text_line(group.name, {group._x_placement, y}, color = _color(0.98))
}

_update_visibility_button :: proc(group: ^Track_Group) {
    button := &group.visibility_button

    button.size = {16, 16}
    button.position = {
        group._x_placement,
        (group.size.y - button.size.y) * 0.5,
    }

    widgets.update_button(button)

    if button.clicked {
        group.is_visible = !group.is_visible
    }

    gui.begin_path()
    gui.path_rounded_rect(button.position, button.size, 3)
    gui.fill_path(_color(0.1))

    if group.is_visible {
        gui.begin_path()
        gui.path_rect(button.position + {4, 4}, button.size - {8, 8})
        if button.is_down {
            gui.fill_path(_color(0.5))
        } else if gui.is_hovered(button) {
            gui.fill_path(_color(0.9))
        } else {
            gui.fill_path(_color(0.7))
        }
    }
}

_update_add_selection_button :: proc(group: ^Track_Group) {
    button := &group.add_selection_button

    button.size = {12, 12}
    button.position = {
        group._x_placement - button.size.x,
        (group.size.y - button.size.y) * 0.5,
    }

    widgets.update_button(button)

    if button.clicked {
        _add_selected_tracks_to_group(group)
    }

    color_intensity := f32(0.7)
    if button.is_down {
        color_intensity = 0.5
    } else if gui.is_hovered(button) {
        color_intensity = 0.9
    }

    _draw_plus(button.position, button.size, 1, _color(color_intensity))
}

_update_remove_selection_button :: proc(group: ^Track_Group) {
    button := &group.remove_selection_button

    button.size = {12, 12}
    button.position = {
        group._x_placement - button.size.x,
        (group.size.y - button.size.y) * 0.5,
    }

    widgets.update_button(button)

    if button.clicked {
        _remove_selected_tracks_from_group(group)
    }

    color_intensity := f32(0.7)
    if button.is_down {
        color_intensity = 0.5
    } else if gui.is_hovered(button) {
        color_intensity = 0.9
    }

    _draw_minus(button.position, button.size, 1, _color(color_intensity))
}

_update_track_group :: proc(group: ^Track_Group) {
    gui.offset(group.position)

    gui.begin_path()
    gui.path_rounded_rect({0, 0}, group.size, 3)

    if _any_selected_track_belongs_to_group(group) {
        gui.fill_path(_color(0.31))
    } else {
        gui.fill_path(_color(0.26))
    }

    // Visibility button
    group._x_placement = PADDING.x
    _update_visibility_button(group)

    // Group name
    group._x_placement += group.visibility_button.size.x + SPACING.x
    _update_group_name(group)

    // Add selection button
    group._x_placement = group.size.x - PADDING.x
    _update_add_selection_button(group)

    // Remove selection button
    group._x_placement -= group.add_selection_button.size.x + SPACING.x
    _update_remove_selection_button(group)
}

_add_new_track_group :: proc(manager: ^Track_Manager, name: string) {
    group := new(Track_Group)
    group.track_manager = manager
    group.name = name
    group.is_visible = true
    append(&manager.groups, group)
}

_add_selected_tracks_to_group :: proc(group: ^Track_Group) {
    manager := group.track_manager
    for track in manager.selected_tracks {
        if !slice.contains(group.tracks[:], track) {
            append(&group.tracks, track)
        }
    }
}

_remove_selected_tracks_from_group :: proc(group: ^Track_Group) {
    manager := group.track_manager
    keep_position := 0

    for i in 0 ..< len(group.tracks) {
        if !slice.contains(manager.selected_tracks[:], group.tracks[i]) {
            if keep_position != i {
                group.tracks[keep_position] = group.tracks[i]
            }
            keep_position += 1
        }
    }

    resize(&group.tracks, keep_position)
}

_update_selected_tracks :: proc(manager: ^Track_Manager) {
    clear(&manager.selected_tracks)
    count := reaper.CountSelectedTracks(manager.project)
    for i in 0 ..< count {
        append(&manager.selected_tracks, reaper.GetSelectedTrack(manager.project, i))
    }
}

_any_selected_track_belongs_to_group :: proc(group: ^Track_Group) -> bool {
    manager := group.track_manager
    for track in manager.selected_tracks {
        if slice.contains(group.tracks[:], track) {
            return true
        }
    }
    return false
}

_track_is_visible :: proc(track: ^reaper.MediaTrack) -> bool {
    return reaper.GetMediaTrackInfo_Value(track, "B_SHOWINMIXER") == 1 &&
           reaper.GetMediaTrackInfo_Value(track, "B_SHOWINTCP") == 1
}

_set_track_visible :: proc(track: ^reaper.MediaTrack, visible: bool) {
    reaper.SetMediaTrackInfo_Value(track, "B_SHOWINMIXER", visible ? 1 : 0)
    reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", visible ? 1 : 0)
    reaper.TrackList_AdjustWindows(false)
}

_color :: proc(intensity: f32) -> Color {
    return {intensity, intensity, intensity, 1}
}

_draw_minus :: proc(position, size: Vec2, thickness: f32, color: Color) {
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

_draw_plus :: proc(position, size: Vec2, thickness: f32, color: Color) {
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